-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

OOB_MSGTYPE_APPLYATK = "applyatk";
OOB_MSGTYPE_APPLYHRFC = "applyhrfc";

function onInit()
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYATK, handleApplyAttack);
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYHRFC, handleApplyHRFC);

	ActionsManager.registerTargetingHandler("attack", onTargeting);
	ActionsManager.registerModHandler("attack", modAttack);
	ActionsManager.registerResultHandler("attack", onAttack);
end

function handleApplyAttack(msgOOB)
	local rSource = ActorManager.resolveActor(msgOOB.sSourceNode);
	local rTarget = ActorManager.resolveActor(msgOOB.sTargetNode);
	
	local nTotal = tonumber(msgOOB.nTotal) or 0;
	ActionAttack.applyAttack(rSource, rTarget, (tonumber(msgOOB.nSecret) == 1), msgOOB.sAttackType, msgOOB.sDesc, nTotal, msgOOB.sResults);
end

function notifyApplyAttack(rSource, rTarget, bSecret, sAttackType, sDesc, nTotal, sResults)
	if not rTarget then
		return;
	end

	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYATK;
	
	if bSecret then
		msgOOB.nSecret = 1;
	else
		msgOOB.nSecret = 0;
	end
	msgOOB.sAttackType = sAttackType;
	msgOOB.nTotal = nTotal;
	msgOOB.sDesc = sDesc;
	msgOOB.sResults = sResults;

	msgOOB.sSourceNode = ActorManager.getCreatureNodeName(rSource);
	msgOOB.sTargetNode = ActorManager.getCreatureNodeName(rTarget);

	Comm.deliverOOBMessage(msgOOB, "");
end

function handleApplyHRFC(msgOOB)
	TableManager.processTableRoll("", msgOOB.sTable);
end

function notifyApplyHRFC(sTable)
	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYHRFC;
	
	msgOOB.sTable = sTable;

	Comm.deliverOOBMessage(msgOOB, "");
end

function onTargeting(rSource, aTargeting, rRolls)
	local bRemoveOnMiss = false;
	local sOptRMMT = OptionsManager.getOption("RMMT");
	if sOptRMMT == "on" then
		bRemoveOnMiss = true;
	elseif sOptRMMT == "multi" then
		bRemoveOnMiss = (#aTargeting > 1);
	end
	
	if bRemoveOnMiss then
		for _,vRoll in ipairs(rRolls) do
			vRoll.bRemoveOnMiss = "true";
		end
	end

	return aTargeting;
end

function performPartySheetVsRoll(draginfo, rActor, rAction)
	local rRoll = ActionAttack.getRoll(nil, rAction);
	
	if DB.getValue("partysheet.hiderollresults", 0) == 1 then
		rRoll.bSecret = true;
		rRoll.bTower = true;
	end
	
	ActionsManager.actionDirect(nil, "attack", { rRoll }, { { rActor } });
end

function performRoll(draginfo, rActor, rAction)
	local rRoll = ActionAttack.getRoll(rActor, rAction);
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getRoll(rActor, rAction)
	local bADV = rAction.bADV or false;
	local bDIS = rAction.bDIS or false;
	
	-- Build basic roll
	local rRoll = {};
	rRoll.sType = "attack";
	rRoll.aDice = { "d20" };
	rRoll.nMod = rAction.modifier or 0;
	rRoll.bWeapon = rAction.bWeapon;
	
	-- Build the description label
	rRoll.sDesc = "[ATTACK";
	if rAction.order and rAction.order > 1 then
		rRoll.sDesc = rRoll.sDesc .. " #" .. rAction.order;
	end
	if rAction.range then
		rRoll.sDesc = rRoll.sDesc .. " (" .. rAction.range .. ")";
	end
	rRoll.sDesc = rRoll.sDesc .. "] " .. rAction.label;
	
	-- Add crit range
	if rAction.nCritRange then
		rRoll.sDesc = rRoll.sDesc .. " [CRIT " .. rAction.nCritRange .. "]";
	end
	
	-- Add ability modifiers
	if rAction.stat then
		local sAbilityEffect = DataCommon.ability_ltos[rAction.stat];
		if sAbilityEffect then
			rRoll.sDesc = rRoll.sDesc .. " [MOD:" .. sAbilityEffect .. "]";
		end

		-- Check for armor non-proficiency
		local sNodeType, nodeActor = ActorManager.getTypeAndNode(rActor);
		if nodeActor and (sNodeType == "pc") then
			if StringManager.contains({"strength", "dexterity"}, rAction.stat) then
				local nodePC = ActorManager.getCreatureNode(rActor);
				if DB.getValue(nodeActor, "defenses.ac.prof", 1) == 0 then
					rRoll.sDesc = rRoll.sDesc .. " " .. Interface.getString("roll_msg_armor_nonprof");
					bDIS = true;
				end
			end
		end
	end
	
	-- Add advantage/disadvantage tags
	if bADV then
		rRoll.sDesc = rRoll.sDesc .. " [ADV]";
	end
	if bDIS then
		rRoll.sDesc = rRoll.sDesc .. " [DIS]";
	end

	return rRoll;
end

function modAttack(rSource, rTarget, rRoll)
	ActionAttack.clearCritState(rSource);
	
	local aAddDesc = {};
	local aAddDice = {};
	local nAddMod = 0;
	
	-- Check for opportunity attack
	local bOpportunity = ModifierManager.getKey("ATT_OPP") or Input.isShiftPressed();

	if bOpportunity then
		table.insert(aAddDesc, "[OPPORTUNITY]");
	end

	-- Check defense modifiers
	local bCover = ModifierManager.getKey("DEF_COVER");
	local bSuperiorCover = ModifierManager.getKey("DEF_SCOVER");
	
	if bSuperiorCover then
		table.insert(aAddDesc, "[COVER -5]");
	elseif bCover then
		table.insert(aAddDesc, "[COVER -2]");
	end
	
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

	local aAttackFilter = {};
	if rSource then
		-- Determine attack type
		local sAttackType = rRoll.sDesc:match("%[ATTACK.*%((%w+)%)%]");
		if not sAttackType then
			sAttackType = "M";
		end

		-- Determine ability used
		local sActionStat = nil;
		local sModStat = rRoll.sDesc:match("%[MOD:(%w+)%]");
		if sModStat then
			sActionStat = DataCommon.ability_stol[sModStat];
		end
		
		-- Build attack filter
		if sAttackType == "M" then
			table.insert(aAttackFilter, "melee");
		elseif sAttackType == "R" then
			table.insert(aAttackFilter, "ranged");
		end
		if bOpportunity then
			table.insert(aAttackFilter, "opportunity");
		end
		
		-- Get attack effect modifiers
		local bEffects = false;
		local nEffectCount;
		aAddDice, nAddMod, nEffectCount = EffectManager5E.getEffectsBonus(rSource, {"ATK"}, false, aAttackFilter, rTarget);
		if (nEffectCount > 0) then
			bEffects = true;
		end
		
		-- Get condition modifiers
		if EffectManager5E.hasEffect(rSource, "ADVATK", rTarget) then
			bADV = true;
			bEffects = true;
		elseif #(EffectManager5E.getEffectsByType(rSource, "ADVATK", aAttackFilter, rTarget)) > 0 then
			bADV = true;
			bEffects = true;
		end
		if EffectManager5E.hasEffect(rSource, "DISATK", rTarget) then
			bDIS = true;
			bEffects = true;
		elseif #(EffectManager5E.getEffectsByType(rSource, "DISATK", aAttackFilter, rTarget)) > 0 then
			bDIS = true;
			bEffects = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "Blinded") then
			bEffects = true;
			bDIS = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "Encumbered") then
			bEffects = true;
			bDIS = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "Frightened") then
			bEffects = true;
			bDIS = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "Intoxicated") then
			bEffects = true;
			bDIS = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "Invisible") then
			bEffects = true;
			bADV = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "Poisoned") then
			bEffects = true;
			bDIS = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "Prone") then
			bEffects = true;
			bDIS = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "Restrained") then
			bEffects = true;
			bDIS = true;
		end
		if EffectManager5E.hasEffectCondition(rSource, "Unconscious") then
			bEffects = true;
			bDIS = true; -- (from assumed prone state)
		end

		-- Get ability modifiers
		local nBonusStat, nBonusEffects = ActorManager5E.getAbilityEffectsBonus(rSource, sActionStat);
		if nBonusEffects > 0 then
			bEffects = true;
			nAddMod = nAddMod + nBonusStat;
		end
		
		-- Get exhaustion modifiers
		local nExhaustMod, nExhaustCount = EffectManager5E.getEffectsBonus(rSource, {"EXHAUSTION"}, true);
		if nExhaustCount > 0 then
			bEffects = true;
			if nExhaustMod >= 3 then
				bDIS = true;
			end
		end
		
		-- Determine crit range
		local aCritRange = EffectManager5E.getEffectsByType(rSource, "CRIT", aAttackFilter, rTarget);
		if #aCritRange > 0 then
			local nCritThreshold = 20;
			for _,v in ipairs(aCritRange) do
				if v.mod > 1 and v.mod < nCritThreshold then
					bEffects = true;
					nCritThreshold = v.mod;
				end
			end
			if nCritThreshold < 20 then
				local sRollCritThreshold = rRoll.sDesc:match("%[CRIT (%d+)%]");
				local nRollCritThreshold = tonumber(sRollCritThreshold) or 20;
				if nCritThreshold < nRollCritThreshold then
					if rRoll.sDesc:match(" %[CRIT %d+%]") then
						rRoll.sDesc = rRoll.sDesc:gsub(" %[CRIT %d+%]", " [CRIT " .. nCritThreshold .. "]");
					else
						rRoll.sDesc = rRoll.sDesc ..  " [CRIT " .. nCritThreshold .. "]";
					end
				end
			end
		end

		-- If effects, then add them
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
	
	if bSuperiorCover then
		nAddMod = nAddMod - 5;
	elseif bCover then
		nAddMod = nAddMod - 2;
	end
	
	local bDefADV, bDefDIS = ActorManager5E.getDefenseAdvantage(rSource, rTarget, aAttackFilter);
	if bDefADV then
		bADV = true;
	end
	if bDefDIS then
		bDIS = true;
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

function onAttack(rSource, rTarget, rRoll)
	ActionsManager2.decodeAdvantage(rRoll);

	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	rMessage.text = string.gsub(rMessage.text, " %[MOD:[^]]*%]", "");

	rRoll.nTotal = ActionsManager.total(rRoll);
	rRoll.aMessages = {};
	
	local nDefenseVal, nAtkEffectsBonus, nDefEffectsBonus = ActorManager5E.getDefenseValue(rSource, rTarget, rRoll);
	if nAtkEffectsBonus ~= 0 then
		rRoll.nTotal = rRoll.nTotal + nAtkEffectsBonus;
		local sFormat = "[" .. Interface.getString("effects_tag") .. " %+d]"
		table.insert(rRoll.aMessages, string.format(sFormat, nAtkEffectsBonus));
	end
	if nDefEffectsBonus ~= 0 then
		nDefenseVal = nDefenseVal + nDefEffectsBonus;
		local sFormat = "[" .. Interface.getString("effects_def_tag") .. " %+d]"
		table.insert(rRoll.aMessages, string.format(sFormat, nDefEffectsBonus));
	end
	
	local sCritThreshold = string.match(rRoll.sDesc, "%[CRIT (%d+)%]");
	local nCritThreshold = tonumber(sCritThreshold) or 20;
	if nCritThreshold < 2 or nCritThreshold > 20 then
		nCritThreshold = 20;
	end
	
	rRoll.nFirstDie = 0;
	if #(rRoll.aDice) > 0 then
		rRoll.nFirstDie = rRoll.aDice[1].result or 0;
	end
	if rRoll.nFirstDie >= nCritThreshold then
		rRoll.bSpecial = true;
		rRoll.sResult = "crit";
		table.insert(rRoll.aMessages, "[CRITICAL HIT]");
	elseif rRoll.nFirstDie == 1 then
		rRoll.sResult = "fumble";
		table.insert(rRoll.aMessages, "[AUTOMATIC MISS]");
	elseif nDefenseVal then
		if rRoll.nTotal >= nDefenseVal then
			rRoll.sResult = "hit";
			table.insert(rRoll.aMessages, "[HIT]");
		else
			rRoll.sResult = "miss";
			table.insert(rRoll.aMessages, "[MISS]");
		end
	end
	
	if not rTarget then
		rMessage.text = rMessage.text .. " " .. table.concat(rRoll.aMessages, " ");
	end
	
	Comm.deliverChatMessage(rMessage);
	
	if rTarget then
		ActionAttack.notifyApplyAttack(rSource, rTarget, rRoll.bTower, rRoll.sType, rRoll.sDesc, rRoll.nTotal, table.concat(rRoll.aMessages, " "));
	end
	
	-- TRACK CRITICAL STATE
	if rRoll.sResult == "crit" then
		ActionAttack.setCritState(rSource, rTarget);
	end
	
	-- REMOVE TARGET ON MISS OPTION
	if rTarget then
		if (rRoll.sResult == "miss" or rRoll.sResult == "fumble") then
			if rRoll.bRemoveOnMiss then
				TargetingManager.removeTarget(ActorManager.getCTNodeName(rSource), ActorManager.getCTNodeName(rTarget));
			end
		end
	end
	
	ActionAttack.onPostAttackResolve(rRoll);
end

function onPostAttackResolve(rRoll)
	-- HANDLE FUMBLE/CRIT HOUSE RULES
	local sOptionHRFC = OptionsManager.getOption("HRFC");
	if rRoll.sResult == "fumble" and ((sOptionHRFC == "both") or (sOptionHRFC == "fumble")) then
		ActionAttack.notifyApplyHRFC("Fumble");
	end
	if rRoll.sResult == "crit" and ((sOptionHRFC == "both") or (sOptionHRFC == "criticalhit")) then
		ActionAttack.notifyApplyHRFC("Critical Hit");
	end
end

function applyAttack(rSource, rTarget, bSecret, sAttackType, sDesc, nTotal, sResults)
	local msgShort = {font = "msgfont"};
	local msgLong = {font = "msgfont"};
	
	msgShort.text = "Attack ->";
	msgLong.text = "Attack [" .. nTotal .. "] ->";
	if rTarget then
		msgShort.text = msgShort.text .. " [at " .. ActorManager.getDisplayName(rTarget) .. "]";
		msgLong.text = msgLong.text .. " [at " .. ActorManager.getDisplayName(rTarget) .. "]";
	end
	if sResults ~= "" then
		msgLong.text = msgLong.text .. " " .. sResults;
	end
	
	msgShort.icon = "roll_attack";
	if string.match(sResults, "%[CRITICAL HIT%]") then
		msgLong.icon = "roll_attack_crit";
	elseif string.match(sResults, "HIT%]") then
		msgLong.icon = "roll_attack_hit";
	elseif string.match(sResults, "MISS%]") then
		msgLong.icon = "roll_attack_miss";
	else
		msgLong.icon = "roll_attack";
	end
		
	ActionsManager.outputResult(bSecret, rSource, rTarget, msgLong, msgShort);
end

aCritState = {};

function setCritState(rSource, rTarget)
	local sSourceCT = ActorManager.getCreatureNodeName(rSource);
	if sSourceCT == "" then
		return;
	end
	local sTargetCT = "";
	if rTarget then
		sTargetCT = ActorManager.getCTNodeName(rTarget);
	end
	
	if not aCritState[sSourceCT] then
		aCritState[sSourceCT] = {};
	end
	table.insert(aCritState[sSourceCT], sTargetCT);
end

function clearCritState(rSource)
	local sSourceCT = ActorManager.getCreatureNodeName(rSource);
	if sSourceCT ~= "" then
		aCritState[sSourceCT] = nil;
	end
end

function isCrit(rSource, rTarget)
	local sSourceCT = ActorManager.getCreatureNodeName(rSource);
	if sSourceCT == "" then
		return;
	end
	local sTargetCT = "";
	if rTarget then
		sTargetCT = ActorManager.getCTNodeName(rTarget);
	end

	if not aCritState[sSourceCT] then
		return false;
	end
	
	for k,v in ipairs(aCritState[sSourceCT]) do
		if v == sTargetCT then
			table.remove(aCritState[sSourceCT], k);
			return true;
		end
	end
	
	return false;
end
