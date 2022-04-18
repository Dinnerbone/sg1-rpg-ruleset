-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	ActionsManager.registerModHandler("skill", modRoll);
	ActionsManager.registerResultHandler("skill", onRoll);
end

function performNPCRoll(draginfo, rActor, sSkill, nSkill)
	local rRoll = {};
	rRoll.sType = "skill";
	rRoll.aDice = { "d20" };
	
	rRoll.sDesc = "[SKILL] " .. sSkill;
	rRoll.nMod = nSkill;

	if Session.IsHost and CombatManager.isCTHidden(ActorManager.getCTNode(rActor)) then
		rRoll.bSecret = true;
	end
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function performPartySheetRoll(draginfo, rActor, sSkill)
	local sNodeType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if sNodeType ~= "pc" then
		return;
	end

	local rRoll = nil;
	for _,v in pairs(DB.getChildren(nodeActor, "skilllist")) do
		if DB.getValue(v, "name", "") == sSkill then
			rRoll = getRoll(rActor, v);
			break;
		end
	end
	if not rRoll then
		rRoll = getUnlistedRoll(rActor, sSkill);
	end
	
	local nTargetDC = DB.getValue("partysheet.skilldc", 0);
	if nTargetDC == 0 then
		nTargetDC = nil;
	end
	rRoll.nTarget = nTargetDC;
	if DB.getValue("partysheet.hiderollresults", 0) == 1 then
		rRoll.bSecret = true;
		rRoll.bTower = true;
	end
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function performRoll(draginfo, rActor, nodeSkill, nTargetDC, bSecretRoll)
	local rRoll = getRoll(rActor, nodeSkill, nTargetDC, bSecretRoll);
	
	if Session.IsHost and CombatManager.isCTHidden(ActorManager.getCTNode(rActor)) then
		rRoll.bSecret = true;
	end
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getRoll(rActor, nodeSkill)
	local rRoll = {};
	rRoll.sType = "skill";
	rRoll.aDice = { "d20" };
	
	local sSkill = DB.getValue(nodeSkill, "name", "");
	local sAbility = DB.getValue(nodeSkill, "stat", "");
	
	local nMod, bADV, bDIS, sAddText = ActorManager5E.getCheck(rActor, sAbility:lower(), sSkill);
	rRoll.nMod = nMod;
	rRoll.nMod = rRoll.nMod + DB.getValue(nodeSkill, "misc", 0);
	
	rRoll.sDesc = "[SKILL] " .. sSkill;
	if not DataCommon.skilldata[sSkill] and sAbility ~= "" then
		rRoll.sDesc = rRoll.sDesc .. " [MOD:" .. DataCommon.ability_ltos[sAbility] .. "]";
	end

	local nodeChar = nodeSkill.getChild("...");
	local nProf = DB.getValue(nodeSkill, "prof", 0);
	if nProf == 1 then
		rRoll.nMod = rRoll.nMod + DB.getValue(nodeChar, "profbonus", 0);
		rRoll.sDesc = rRoll.sDesc .. " [PROF]";
	elseif nProf == 2 then
		rRoll.nMod = rRoll.nMod + (2 * DB.getValue(nodeChar, "profbonus", 0));
		rRoll.sDesc = rRoll.sDesc .. " [PROF x2]";
	elseif nProf == 3 then
		rRoll.nMod = rRoll.nMod + math.floor(DB.getValue(nodeChar, "profbonus", 0) / 2);
		rRoll.sDesc = rRoll.sDesc .. " [PROF x1/2]";
	end
	
	if sAddText and sAddText ~= "" then
		rRoll.sDesc = rRoll.sDesc .. " " .. sAddText;
	end
	if bADV then
		rRoll.sDesc = rRoll.sDesc .. " [ADV]";
	end
	if bDIS then
		rRoll.sDesc = rRoll.sDesc .. " [DIS]";
	end

	return rRoll;
end

function getUnlistedRoll(rActor, sSkill)
	local rRoll = {};
	rRoll.sType = "skill";
	rRoll.aDice = { "d20" };
	rRoll.nMod = 0;
	
	local nMod = 0;
	local bADV = false;
	local bDIS = false;
	local sAddText = "";
	
	local sAbility = nil;
	if DataCommon.skilldata[sSkill] then
		sAbility = DataCommon.skilldata[sSkill].stat;
	end
	if sAbility then
		nMod, bADV, bDIS, sAddText = ActorManager5E.getCheck(rActor, sAbility, sSkill);
	end
	
	rRoll.sDesc = "[SKILL] " .. sSkill;
	if sAddText and sAddText ~= "" then
		rRoll.sDesc = rRoll.sDesc .. " " .. sAddText;
	end
	if nMod and nMod ~= 0 then
		rRoll.sDesc = rRoll.sDesc .. string.format(" [%+d]", nMod);
		rRoll.nMod = rRoll.nMod + nMod;
	end
	if bADV then
		rRoll.sDesc = rRoll.sDesc .. " [ADV]";
	end
	if bDIS then
		rRoll.sDesc = rRoll.sDesc .. " [DIS]";
	end

	return rRoll;
end

function modRoll(rSource, rTarget, rRoll)
	local aAddDesc = {};
	local aAddDice = {};
	local nAddMod = 0;
	
	local bADV = false;
	local bDIS = false;
	if rRoll.sDesc:match(" %[ADV%]") then
		bADV = true;
		rRoll.sDesc = rRoll.sDesc:gsub(" %[ADV%]", "");
	end
	if rRoll.sDesc:match(" %[DIS%]") then
		bDIS = true;
		rRoll.sDesc = rRoll.sDesc:gsub(" %[DIS%]", "");
	end

	if rSource then
		local bEffects = false;

		-- Get ability used
		local sActionStat = nil;
		local sAbility = string.match(rRoll.sDesc, "%[CHECK%] (%w+)");
		local sSkill = StringManager.trim(string.match(rRoll.sDesc, "%[SKILL%] ([^[]+)"));
		if not sAbility and sSkill then
			sAbility = string.match(rRoll.sDesc, "%[MOD:(%w+)%]");
			if sAbility then
				sAbility = DataCommon.ability_stol[sAbility];
			else
				local sSkillLower = sSkill:lower();
				for k, v in pairs(DataCommon.skilldata) do
					if k:lower() == sSkillLower then
						sAbility = v.stat;
					end
				end
			end
		end
		if sAbility then
			sAbility = string.lower(sAbility);
		end

		-- Build filters
		local aCheckFilter = {};
		if sAbility then
			table.insert(aCheckFilter, sAbility);
		end
		local aSkillFilter = {};
		if sSkill then
			table.insert(aSkillFilter, sSkill:lower());
		end

		-- Get roll effect modifiers
		local nEffectCount;
		aAddDice, nAddMod, nEffectCount = EffectManager5E.getEffectsBonus(rSource, {"CHECK"}, false, aCheckFilter);
		if (nEffectCount > 0) then
			bEffects = true;
		end
		local aSkillAddDice, nSkillAddMod, nSkillEffectCount = EffectManager5E.getEffectsBonus(rSource, {"SKILL"}, false, aSkillFilter);
		if (nSkillEffectCount > 0) then
			bEffects = true;
			for _,v in ipairs(aSkillAddDice) do
				table.insert(aAddDice, v);
			end
			nAddMod = nAddMod + nSkillAddMod;
		end
		
		-- Get condition modifiers
		if EffectManager5E.hasEffectCondition(rSource, "ADVSKILL") then
			bADV = true;
			bEffects = true;
		elseif #(EffectManager5E.getEffectsByType(rSource, "ADVSKILL", aSkillFilter)) > 0 then
			bADV = true;
			bEffects = true;
		elseif EffectManager5E.hasEffectCondition(rSource, "ADVCHK") then
			bADV = true;
			bEffects = true;
		elseif #(EffectManager5E.getEffectsByType(rSource, "ADVCHK", aCheckFilter)) > 0 then
			bADV = true;
			bEffects = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "DISSKILL") then
			bDIS = true;
			bEffects = true;
		elseif #(EffectManager5E.getEffectsByType(rSource, "DISSKILL", aSkillFilter)) > 0 then
			bDIS = true;
			bEffects = true;
		elseif EffectManager5E.hasEffectCondition(rSource, "DISCHK") then
			bDIS = true;
			bEffects = true;
		elseif #(EffectManager5E.getEffectsByType(rSource, "DISCHK", aCheckFilter)) > 0 then
			bDIS = true;
			bEffects = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "Frightened") then
			bDIS = true;
			bEffects = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "Intoxicated") then
			bDIS = true;
			bEffects = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "Poisoned") then
			bDIS = true;
			bEffects = true;
		end
		if StringManager.contains({ "strength", "dexterity", "constitution" }, sAbility) then
			if EffectManager5E.hasEffectCondition(rSource, "Encumbered") then
				bEffects = true;
				bDIS = true;
			end
		end

		-- Get ability modifiers
		local nBonusStat, nBonusEffects = ActorManager5E.getAbilityEffectsBonus(rSource, sAbility);
		if nBonusEffects > 0 then
			bEffects = true;
			nAddMod = nAddMod + nBonusStat;
		end
		
		-- Get exhaustion modifiers
		local nExhaustMod, nExhaustCount = EffectManager5E.getEffectsBonus(rSource, {"EXHAUSTION"}, true);
		if nExhaustCount > 0 then
			bEffects = true;
			if nExhaustMod >= 1 then
				bDIS = true;
			end
		end
		
		-- If effects happened, then add note
		if bEffects then
			local sEffects = "";
			local sMod = StringManager.convertDiceToString(aAddDice, nAddMod, true);
			if sMod ~= "" then
				sEffects = "[" .. Interface.getString("effects_tag") .. " " .. sMod .. "]";
			else
				sEffects = "[" .. Interface.getString("effects_tag") .. "]";
			end
			table.insert(aAddDesc, sEffects);
		end
	end
	
	if #aAddDesc > 0 then
		rRoll.sDesc = rRoll.sDesc .. " " .. table.concat(aAddDesc, " ");
	end
	ActionsManager2.encodeDesktopMods(rRoll);
	for _,vDie in ipairs(aAddDice) do
		if vDie:sub(1,1) == "-" then
			table.insert(rRoll.aDice, "-p" .. vDie:sub(3));
		else
			table.insert(rRoll.aDice, "p" .. vDie:sub(2));
		end
	end
	rRoll.nMod = rRoll.nMod + nAddMod;
	
	ActionsManager2.encodeAdvantage(rRoll, bADV, bDIS);
end

function onRoll(rSource, rTarget, rRoll)
	ActionsManager2.decodeAdvantage(rRoll);
	
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

	if rRoll.nTarget then
		local nTotal = ActionsManager.total(rRoll);
		local nTargetDC = tonumber(rRoll.nTarget) or 0;
		
		rMessage.text = rMessage.text .. " (vs. DC " .. nTargetDC .. ")";
		if nTotal >= nTargetDC then
			rMessage.text = rMessage.text .. " [SUCCESS]";
		else
			rMessage.text = rMessage.text .. " [FAILURE]";
		end
	end
	
	Comm.deliverChatMessage(rMessage);
end
