-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

OOB_MSGTYPE_APPLYDMG = "applydmg";
OOB_MSGTYPE_APPLYDMGSTATE = "applydmgstate";

function onInit()
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYDMG, handleApplyDamage);
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYDMGSTATE, handleApplyDamageState);

	ActionsManager.registerModHandler("damage", modDamage);
	ActionsManager.registerPostRollHandler("damage", onDamageRoll);
	ActionsManager.registerResultHandler("damage", onDamage);
end

function handleApplyDamage(msgOOB)
	local rSource = ActorManager.resolveActor(msgOOB.sSourceNode);
	local rTarget = ActorManager.resolveActor(msgOOB.sTargetNode);
	if rTarget then
		rTarget.nOrder = msgOOB.nTargetOrder;
	end
	
	local nTotal = tonumber(msgOOB.nTotal) or 0;
	ActionDamage.applyDamage(rSource, rTarget, (tonumber(msgOOB.nSecret) == 1), msgOOB.sDamage, nTotal);
end

function notifyApplyDamage(rSource, rTarget, bSecret, sDesc, nTotal)
	if not rTarget then
		return;
	end

	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYDMG;
	
	if bSecret then
		msgOOB.nSecret = 1;
	else
		msgOOB.nSecret = 0;
	end
	msgOOB.nTotal = nTotal;
	msgOOB.sDamage = sDesc;

	msgOOB.sSourceNode = ActorManager.getCreatureNodeName(rSource);
	msgOOB.sTargetNode = ActorManager.getCreatureNodeName(rTarget);
	msgOOB.nTargetOrder = rTarget.nOrder;

	Comm.deliverOOBMessage(msgOOB, "");
end

function getRoll(rActor, rAction)
	local rRoll = {};
	rRoll.sType = "damage";
	rRoll.aDice = {};
	rRoll.nMod = 0;
	rRoll.bWeapon = rAction.bWeapon;
	
	rRoll.sDesc = "[DAMAGE";
	if rAction.order and rAction.order > 1 then
		rRoll.sDesc = rRoll.sDesc .. " #" .. rAction.order;
	end
	if rAction.range then
		rRoll.sDesc = rRoll.sDesc .. " (" .. rAction.range ..")";
		rRoll.range = rAction.range;
	end
	rRoll.sDesc = rRoll.sDesc .. "] " .. rAction.label;
	
	-- Save the damage properties in the roll structure
	rRoll.clauses = rAction.clauses;
	
	-- Add the dice and modifiers
	for _,vClause in ipairs(rRoll.clauses) do
		for _,vDie in ipairs(vClause.dice) do
			table.insert(rRoll.aDice, vDie);
		end
		rRoll.nMod = rRoll.nMod + vClause.modifier;
	end
	
	if rAction.nReroll then
		rRoll.sDesc = rRoll.sDesc .. " [REROLL " .. rAction.nReroll.. "]";
	end
	
	-- Encode the damage types
	ActionDamage.encodeDamageTypes(rRoll);
	
	return rRoll;
end

function performRoll(draginfo, rActor, rAction)
	local rRoll = ActionDamage.getRoll(rActor, rAction);
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function modDamage(rSource, rTarget, rRoll)
	ActionDamage.setupModRoll(rRoll, rSource, rTarget);

	if rSource then
		ActionDamage.applyAbilityEffectsToModRoll(rRoll, rSource, rTarget);
		ActionDamage.applyDmgEffectsToModRoll(rRoll, rSource, rTarget);
		ActionDamage.applyEffectModNotificationToModRoll(rRoll);

		ActionDamage.applyDmgTypeEffectsToModRoll(rRoll, rSource, rTarget);
	end
	
	if rRoll.bCritical then
		ActionDamage.applyCriticalToModRoll(rRoll, rSource, rTarget);
	end
	
	if ActorManager.isRecordType(rSource, "npc") and OptionsManager.isOption("NPCD", "fixed") then
		ActionDamage.applyFixedDamageOptionToModRoll(rRoll, rSource, rTarget);
	end

	ActionDamage.applyModifierKeysToModRoll(rRoll, rSource, rTarget);
	
	ActionDamage.finalizeModRoll(rRoll);
end

function onDamageRoll(rSource, rRoll)
	-- Handle max damage
	local bMax = rRoll.sDesc:match("%[MAX%]");
	if bMax then
		for _,vDie in ipairs(rRoll.aDice) do
			local sSign, sColor, sDieSides = vDie.type:match("^([%-%+]?)([dDrRgGbBpP])([%dF]+)");
			if sDieSides then
				local nResult;
				if sDieSides == "F" then
					nResult = 1;
				else
					nResult = tonumber(sDieSides) or 0;
				end
				
				if sSign == "-" then
					nResult = 0 - nResult;
				end
				
				vDie.result = nResult;
				vDie.value = vDie.result;
				if sColor == "d" or sColor == "D" then
					if sSign == "-" then
						vDie.type = "-b" .. sDieSides;
					else
						vDie.type = "b" .. sDieSides;
					end
				end
			end
		end
		if rRoll.aDice.expr then
			rRoll.aDice.expr = nil;
		end
	end
	
	ActionDamage.decodeDamageTypes(rRoll, true);
end

function onDamage(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	rMessage.text = string.gsub(rMessage.text, " %[MOD:[^]]*%]", "");

	-- Send the chat message
	local bShowMsg = true;
	if rTarget and rTarget.nOrder and rTarget.nOrder ~= 1 then
		bShowMsg = false;
	end
	if bShowMsg then
		Comm.deliverChatMessage(rMessage);
	end

	-- Apply damage to the PC or CT entry referenced
	local nTotal = ActionsManager.total(rRoll);
	ActionDamage.notifyApplyDamage(rSource, rTarget, rRoll.bTower, rMessage.text, nTotal);
end

--
-- MOD ROLL HELPERS
--

function setupModRoll(rRoll, rSource, rTarget)
	ActionDamage.decodeDamageTypes(rRoll);
	CombatManager2.addRightClickDiceToClauses(rRoll);
	
	rRoll.tNotifications = {};

	rRoll.bCritical = rRoll.bCritical or ModifierManager.getKey("DMG_CRIT") or Input.isShiftPressed();
	if ActionAttack.isCrit(rSource, rTarget) then
		rRoll.bCritical = true;
	end
	rRoll.tAttackFilter = {};
	if rRoll.range == "R" then
		table.insert(rRoll.tAttackFilter, "ranged");
	elseif rRoll.range == "M" then
		table.insert(rRoll.tAttackFilter, "melee");
	end
	rRoll.nOrigClauses = #(rRoll.clauses);

	rRoll.bEffects = false;
	rRoll.tEffectDice = {};
	rRoll.nEffectMod = 0;
end

function applyAbilityEffectsToModRoll(rRoll, rSource, rTarget)
	-- NOTE: Ability effects do not support targeting
	for _,rClause in ipairs(rRoll.clauses) do
		local nBonusStat, nBonusEffects = ActorManager5E.getAbilityEffectsBonus(rSource, rClause.stat);
		if nBonusEffects > 0 then
			rRoll.bEffects = true;
			local nMult = rClause.statmult or 1;
			if nBonusStat > 0 and nMult ~= 1 then
				nBonusStat = math.floor(nMult * nBonusStat);
			end
			rRoll.nEffectMod = rRoll.nEffectMod + nBonusStat;
			rClause.modifier = rClause.modifier + nBonusStat;
			rRoll.nMod = rRoll.nMod + nBonusStat;
		end
	end
end

function applyDmgEffectsToModRoll(rRoll, rSource, rTarget)
	local tDmgEffects, nDmgEffects = EffectManager5E.getEffectsBonusByType(rSource, "DMG", true, rRoll.tAttackFilter, rTarget);
	if nDmgEffects > 0 then
		local sEffectBaseType = "";
		if #(rRoll.clauses) > 0 then
			sEffectBaseType = rRoll.clauses[1].dmgtype or "";
		end
		
		for _,v in pairs(tDmgEffects) do
			local bCritEffect = false;
			local aEffectDmgType = {};
			local aEffectSpecialDmgType = {};
			for _,sType in ipairs(v.remainder) do
				if StringManager.contains(DataCommon.specialdmgtypes, sType) then
					table.insert(aEffectSpecialDmgType, sType);
					if sType == "critical" then
						bCritEffect = true;
					end
				elseif StringManager.contains(DataCommon.dmgtypes, sType) then
					table.insert(aEffectDmgType, sType);
				end
			end
			
			if not bCritEffect or rRoll.bCritical then
				rRoll.bEffects = true;
		
				local rClause = {};
				
				rClause.dice = {};
				for _,vDie in ipairs(v.dice) do
					table.insert(rRoll.tEffectDice, vDie);
					table.insert(rClause.dice, vDie);
					if rClause.reroll then
						table.insert(rClause.reroll, 0);
					end
					if vDie:sub(1,1) == "-" then
						table.insert(rRoll.aDice, "-p" .. vDie:sub(3));
					else
						table.insert(rRoll.aDice, "p" .. vDie:sub(2));
					end
				end

				rRoll.nEffectMod = rRoll.nEffectMod + v.mod;
				rClause.modifier = v.mod;
				rRoll.nMod = rRoll.nMod + v.mod;
				
				rClause.stat = "";

				if #aEffectDmgType == 0 then
					table.insert(aEffectDmgType, sEffectBaseType);
				end
				for _,vSpecialDmgType in ipairs(aEffectSpecialDmgType) do
					table.insert(aEffectDmgType, vSpecialDmgType);
				end
				rClause.dmgtype = table.concat(aEffectDmgType, ",");

				table.insert(rRoll.clauses, rClause);
			end
		end
	end
end

function applyEffectModNotificationToModRoll(rRoll)
	if rRoll.bEffects then
		local sEffects = "";
		local sMod = StringManager.convertDiceToString(rRoll.tEffectDice, rRoll.nEffectMod, true);
		if sMod ~= "" then
			sEffects = "[" .. Interface.getString("effects_tag") .. " " .. sMod .. "]";
		else
			sEffects = "[" .. Interface.getString("effects_tag") .. "]";
		end
		table.insert(rRoll.tNotifications, sEffects);
	end
end

function applyDmgTypeEffectsToModRoll(rRoll, rSource, rTarget)
	local tAddDmgTypes = {};
	local tDmgTypeEffects = EffectManager5E.getEffectsByType(rSource, "DMGTYPE", nil, rTarget);
	for _,rEffectComp in ipairs(tDmgTypeEffects) do
		for _,v in ipairs(rEffectComp.remainder) do
			local tSplitDmgTypes = StringManager.split(v, ",", true);
			for _,v2 in ipairs(tSplitDmgTypes) do
				table.insert(tAddDmgTypes, v2);
			end
		end
	end

	if #tAddDmgTypes > 0 then
		for _,rClause in ipairs(rRoll.clauses) do
			local tSplitDmgTypes = StringManager.split(rClause.dmgtype, ",", true);
			for _,v in ipairs(tAddDmgTypes) do
				if not StringManager.contains(tSplitDmgTypes, v) then
					if rClause.dmgtype ~= "" then
						rClause.dmgtype = rClause.dmgtype .. "," .. v;
					else
						rClause.dmgtype = v;
					end
				end
			end
		end

		local sNotification = "[" .. Interface.getString("effects_tag") .. " " .. table.concat(tAddDmgTypes, ",") .. "]";
		table.insert(rRoll.tNotifications, sNotification);
	end
end

function applyCriticalToModRoll(rRoll, rSource, rTarget)
	table.insert(rRoll.tNotifications, "[CRITICAL]");
	
	-- Double the dice, and add extra critical dice
	local aNewClauses = {};
	local aNewDice = {};
	local nMaxSides = 0;
	local nMaxClause = 0;
	local nMaxDieIndex = 0;

	-- Insert the original dice
	local nOldDieIndex = 1;
	for _,vClause in ipairs(rRoll.clauses) do
		for _,vDie in ipairs(vClause.dice) do
			table.insert(aNewDice, rRoll.aDice[nOldDieIndex]);
			nOldDieIndex = nOldDieIndex + 1;
		end
	end

	-- Add critical dice by clause
	for kClause,vClause in ipairs(rRoll.clauses) do
		local bApplyCritToClause = true;
		local aSplitByDmgType = StringManager.split(vClause.dmgtype, ",", true);
		for _,vDmgType in ipairs(aSplitByDmgType) do
			if vDmgType == "critical" then
				bApplyCritToClause = false;
				break;
			end
		end
		
		if bApplyCritToClause then
			local bNewMax = false;
			local aCritClauseDice = {};
			local aCritClauseReroll = {};
			for kDie,vDie in ipairs(vClause.dice) do
				if vDie:sub(1,1) == "-" then
					table.insert(aNewDice, "-g" .. vDie:sub(3));
				else
					table.insert(aNewDice, "g" .. vDie:sub(2));
				end
				table.insert(aCritClauseDice, vDie);
				if vClause.reroll then
					table.insert(aCritClauseReroll, vClause.reroll[kDie]);
				end
				
				if kClause <= rRoll.nOrigClauses and vDie:sub(1,1) ~= "-" then
					local nDieSides = tonumber(vDie:sub(2)) or 0;
					if nDieSides > nMaxSides then
						bNewMax = true;
						nMaxSides = nDieSides;
					end
				end
			end

			if #aCritClauseDice > 0 then
				local rNewClause = { dice = {}, reroll = {}, modifier = 0, stat = "", bCritical = true };
				if vClause.dmgtype == "" then
					rNewClause.dmgtype = "critical";
				else
					rNewClause.dmgtype = vClause.dmgtype .. ",critical";
				end
				for kDie, vDie in ipairs(aCritClauseDice) do
					table.insert(rNewClause.dice, vDie);
					table.insert(rNewClause.reroll, aCritClauseReroll[kDie]);
				end
				table.insert(aNewClauses, rNewClause);
				
				if bNewMax then
					nMaxClause = #aNewClauses;
					nMaxDieIndex = #aNewDice + 1;
				end
			end
		end
	end
	if nMaxSides > 0 then
		local nCritDice = 0;
		if rRoll.bWeapon then
			local sSourceNodeType, nodeSource = ActorManager.getTypeAndNode(rSource);
			if nodeSource and (sSourceNodeType == "pc") then
				if rRoll.range == "R" then
					nCritDice = DB.getValue(nodeSource, "weapon.critdicebonus.ranged", 0);
				else
					nCritDice = DB.getValue(nodeSource, "weapon.critdicebonus.melee", 0);
				end
			end
		end
		
		if nCritDice > 0 then
			for i = 1, nCritDice do
				table.insert(aNewDice, nMaxDieIndex, "g" .. nMaxSides);
				table.insert(aNewClauses[nMaxClause].dice, "d" .. nMaxSides);
				if aNewClauses[nMaxClause].reroll then
					table.insert(aNewClauses[nMaxClause].reroll, aNewClauses[nMaxClause].reroll[1]);
				end
			end
		end
	end
	local aFinalClauses = {};
	for _,vClause in ipairs(aNewClauses) do
		table.insert(rRoll.clauses, vClause);
	end
	rRoll.aDice = aNewDice;
end

function applyFixedDamageOptionToModRoll(rRoll, rSource, rTarget)
	local aFixedClauses = {};
	local aFixedDice = {};
	local nFixedPositiveCount = 0;
	local nFixedNegativeCount = 0;
	local nFixedMod = 0;

	for kClause,vClause in ipairs(rRoll.clauses) do
		if kClause <= rRoll.nOrigClauses then
			local nClauseFixedMod = 0;
			for kDie,vDie in ipairs(vClause.dice) do
				if vDie:sub(1,1) == "-" then
					nFixedNegativeCount = nFixedNegativeCount + 1;
					nClauseFixedMod = nClauseFixedMod - math.floor(math.ceil(tonumber(vDie:sub(3)) or 0) / 2);
					if nFixedNegativeCount % 2 == 0 then
						nClauseFixedMod = nClauseFixedMod - 1;
					end
				else
					nFixedPositiveCount = nFixedPositiveCount + 1;
					nClauseFixedMod = nClauseFixedMod + math.floor(math.ceil(tonumber(vDie:sub(2)) or 0) / 2);
					if nFixedPositiveCount % 2 == 0 then
						nClauseFixedMod = nClauseFixedMod + 1;
					end
				end
				vClause.modifier = vClause.modifier + nClauseFixedMod;
			end
			vClause.dice = {};
			nFixedMod = nFixedMod + nClauseFixedMod;
		else
			for _,vDie in ipairs(vClause.dice) do
				if vClause.bCritical then
					if vDie:sub(1,1) == "-" then
						table.insert(aFixedDice, "-g" .. vDie:sub(3));
					else
						table.insert(aFixedDice, "g" .. vDie:sub(2));
					end
				else
					table.insert(aFixedDice, vDie);
				end
			end
		end
		
		table.insert(aFixedClauses, vClause);
	end
	
	rRoll.clauses = aFixedClauses;
	rRoll.aDice = aFixedDice;
	rRoll.nMod = rRoll.nMod + nFixedMod;
end

function applyModifierKeysToModRoll(rRoll, rSource, rTarget)
	if ModifierManager.getKey("DMG_MAX") then
		table.insert(rRoll.tNotifications, "[MAX]");
	end
	if ModifierManager.getKey("DMG_HALF") then
		table.insert(rRoll.tNotifications, "[HALF]");
	end
end

function finalizeModRoll(rRoll)
	if #(rRoll.tNotifications) > 0 then
		rRoll.sDesc = rRoll.sDesc .. " " .. table.concat(rRoll.tNotifications, " ");
	end

	rRoll.tNotifications = nil;
	rRoll.tAttackFilter = nil;
	rRoll.bEffects = nil;
	rRoll.tEffectDice = nil;
	rRoll.nEffectMod = nil;

	ActionDamage.encodeDamageTypes(rRoll);
	ActionsManager2.encodeDesktopMods(rRoll);
end

--
-- APPLY DAMAGE EFFECT HELPERS
--

-- NOTE: Dice determined randomly, instead of rolled
function applyTargetedDmgEffectsToDamageOutput(rDamageOutput, rSource, rTarget)
	local tTargetedDamage = EffectManager5E.getEffectsBonusByType(rSource, "DMG", true, rDamageOutput.aDamageFilter, rTarget, true);

	local nDamageEffectTotal = 0;
	local nDamageEffectCount = 0;
	for k, v in pairs(tTargetedDamage) do
		local bValid = true;
		local aSplitByDmgType = StringManager.split(k, ",", true);
		for _,vDmgType in ipairs(aSplitByDmgType) do
			if vDmgType == "critical" and not rDamageOutput.bCritical then
				bValid = false;
			end
		end
		
		if bValid then
			local nSubTotal = StringManager.evalDice(v.dice, v.mod);
			
			local sDamageType = rDamageOutput.sFirstDamageType;
			if sDamageType then
				sDamageType = sDamageType .. "," .. k;
			else
				sDamageType = k;
			end

			rDamageOutput.aDamageTypes[sDamageType] = (rDamageOutput.aDamageTypes[sDamageType] or 0) + nSubTotal;
			
			nDamageEffectTotal = nDamageEffectTotal + nSubTotal;
			nDamageEffectCount = nDamageEffectCount + 1;
		end
	end

	if nDamageEffectCount > 0 then
		local sNotification;
		if nDamageEffectTotal ~= 0 then
			sNotification = string.format("[" .. Interface.getString("effects_tag") .. " %+d]", nDamageEffectTotal);
		else
			sNotification = "[" .. Interface.getString("effects_tag") .. "]";
		end
		table.insert(rDamageOutput.tNotifications, sNotification);
	end

	rDamageOutput.nVal = rDamageOutput.nVal + nDamageEffectTotal;
end

function applyTargetedDmgTypeEffectsToDamageOutput(rDamageOutput, rSource, rTarget)
	local tAddDmgTypes = {};
	local tDmgTypeEffects = EffectManager5E.getEffectsByType(rSource, "DMGTYPE", nil, rTarget, true);
	for _,rEffectComp in ipairs(tDmgTypeEffects) do
		for _,v in ipairs(rEffectComp.remainder) do
			local tSplitDmgTypes = StringManager.split(v, ",", true);
			for _,v2 in ipairs(tSplitDmgTypes) do
				table.insert(tAddDmgTypes, v2);
			end
		end
	end
	if #tAddDmgTypes > 0 then
		local tNewDmgTypes = {};
		for k,v in pairs(rDamageOutput.aDamageTypes) do
			local tSplitDmgTypes = StringManager.split(k, ",", true);
			for _,v2 in ipairs(tAddDmgTypes) do
				if not StringManager.contains(tSplitDmgTypes, v2) then
					if k ~= "" then
						k = k .. "," .. v2;
					else
						k = v2;
					end
				end
			end
			tNewDmgTypes[k] = v;
		end
		rDamageOutput.aDamageTypes = tNewDmgTypes;

		local sNotification = "[" .. Interface.getString("effects_tag") .. " " .. table.concat(tAddDmgTypes, ",") .. "]";
		table.insert(rDamageOutput.tNotifications, sNotification);
	end
end

--
-- UTILITY FUNCTIONS
--

function encodeDamageTypes(rRoll)
	for _,vClause in ipairs(rRoll.clauses) do
		if vClause.dmgtype and vClause.dmgtype ~= "" then
			local sDice = StringManager.convertDiceToString(vClause.dice, vClause.modifier);
			rRoll.sDesc = rRoll.sDesc .. string.format(" [TYPE: %s (%s)(%s)(%s)(%s)]", vClause.dmgtype, sDice, vClause.stat or "", vClause.statmult or 1, table.concat(vClause.reroll or {}, ","));
		end
	end
end

function decodeDamageTypes(rRoll, bFinal)
	-- Process each type clause in the damage description (INITIAL ROLL)
	local nMainDieIndex = 0;
	local aRerollOutput = {};
	rRoll.clauses = {};
	for sDamageType, sDamageDice, sDamageAbility, sDamageAbilityMult, sDamageReroll in string.gmatch(rRoll.sDesc, "%[TYPE: ([^(]*) %(([^)]*)%)%(([^)]*)%)%(([^)]*)%)%(([^)]*)%)%]") do
		local rClause = {};
		rClause.dmgtype = StringManager.trim(sDamageType);
		rClause.stat = sDamageAbility;
		rClause.statmult = tonumber(sDamageAbilityMult) or 1;
		rClause.dice, rClause.modifier = StringManager.convertStringToDice(sDamageDice);
		rClause.nTotal = rClause.modifier;
		local aReroll = {};
		for sReroll in sDamageReroll:gmatch("%d+") do
			table.insert(aReroll, tonumber(sReroll) or 0);
		end
		if #aReroll > 0 then
			rClause.reroll = aReroll;
		end
		for kDie,vDie in ipairs(rClause.dice) do
			nMainDieIndex = nMainDieIndex + 1;
			if rRoll.aDice[nMainDieIndex] then
				if bFinal and 
						rClause.reroll and rClause.reroll[kDie] and 
						rRoll.aDice[nMainDieIndex].result and 
						(math.abs(rRoll.aDice[nMainDieIndex].result) <= rClause.reroll[kDie]) then
					local nDieSides = tonumber(string.match(rRoll.aDice[nMainDieIndex].type, "[%-%+]?[a-z](%d+)")) or 0;
					if nDieSides > 0 then
						table.insert(aRerollOutput, "D" .. nMainDieIndex .. "=" .. rRoll.aDice[nMainDieIndex].result);
						local nSubtotal = math.random(nDieSides);
						if rRoll.aDice[nMainDieIndex].result < 0 then
							rRoll.aDice[nMainDieIndex].result = -nSubtotal;
						else
							rRoll.aDice[nMainDieIndex].result = nSubtotal;
						end
						rRoll.aDice[nMainDieIndex].value = nil;
					end
				end
				rClause.nTotal = rClause.nTotal + (rRoll.aDice[nMainDieIndex].result or 0);
			end
		end
		
		table.insert(rRoll.clauses, rClause);
	end
	if #aRerollOutput > 0 then
		rRoll.sDesc = rRoll.sDesc .. " [REROLL " .. table.concat(aRerollOutput, ",") .. "]";
	end

	-- Process each type clause in the damage description (DRAG ROLL RESULT)
	local nClauses = #(rRoll.clauses);
	for sDamageType, sDamageDice in string.gmatch(rRoll.sDesc, "%[TYPE: ([^(]*) %(([^)]*)%)]") do
		local sTotal = string.match(sDamageDice, "=(%d+)");
		if sTotal then
			local nTotal = tonumber(sTotal) or 0;
			
			local rClause = {};
			rClause.dmgtype = StringManager.trim(sDamageType);
			rClause.stat = "";
			rClause.dice = {};
			rClause.modifier = nTotal;
			rClause.nTotal = nTotal;

			table.insert(rRoll.clauses, rClause);
		end
	end
	
	-- Add untyped clause if no TYPE tag found
	if #(rRoll.clauses) == 0 then
		local rClause = {};
		rClause.dmgtype = "";
		rClause.stat = "";
		rClause.dice = {};
		rClause.modifier = rRoll.nMod;
		rClause.nTotal = rRoll.nMod;
		for _,vDie in ipairs(rRoll.aDice) do
			if type(vDie) == "table" then
				table.insert(rClause.dice, vDie.type);
				rClause.nTotal = rClause.nTotal + (vDie.value or vDie.result or 0);
			else
				table.insert(rClause.dice, vDie);
			end
		end

		table.insert(rRoll.clauses, rClause);
	end
	
	-- Handle drag results that are halved or doubled
	if #(rRoll.aDice) == 0 then
		local nResultTotal = 0;
		for i = nClauses + 1, #(rRoll.clauses) do
			nResultTotal = rRoll.clauses[i].nTotal;
		end
		if nResultTotal > 0 and nResultTotal ~= rRoll.nMod then
			if math.floor(nResultTotal / 2) == rRoll.nMod then
				for _,vClause in ipairs(rRoll.clauses) do
					vClause.modifier = math.floor(vClause.modifier / 2);
					vClause.nTotal = math.floor(vClause.nTotal / 2);
				end
			elseif nResultTotal * 2 == rRoll.nMod then
				for _,vClause in ipairs(rRoll.clauses) do
					vClause.modifier = 2 * vClause.modifier;
					vClause.nTotal = 2 * vClause.nTotal;
				end
			end
		end
	end
	
	-- Remove damage type information from roll description
	rRoll.sDesc = string.gsub(rRoll.sDesc, " %[TYPE:[^]]*%]", "");
	
	if bFinal then
		local nFinalTotal = ActionsManager.total(rRoll);

		-- Handle minimum damage
		if nFinalTotal < 0 and rRoll.aDice and #rRoll.aDice > 0 then
			rRoll.sDesc = rRoll.sDesc .. " [MIN DAMAGE]";
			rRoll.nMod = rRoll.nMod - nFinalTotal;
			nFinalTotal = 0;
		end

		-- Capture any manual modifiers and adjust damage types accordingly
		-- NOTE: Positive values are added to first damage clause, Negative values reduce damage clauses until none remain
		local nClausesTotal = 0;
		for _,vClause in ipairs(rRoll.clauses) do
			nClausesTotal = nClausesTotal + vClause.nTotal;
		end
		if nFinalTotal ~= nClausesTotal then
			local nRemainder = nFinalTotal - nClausesTotal;
			if nRemainder > 0 then
				if #(rRoll.clauses) == 0 then
					table.insert(rRoll.clauses, { dmgtype = "", stat = "", dice = {}, modifier = nRemainder, nTotal = nRemainder})
				else
					rRoll.clauses[1].modifier = rRoll.clauses[1].modifier + nRemainder;
					rRoll.clauses[1].nTotal = rRoll.clauses[1].nTotal + nRemainder;
				end
			else
				for _,vClause in ipairs(rRoll.clauses) do
					if vClause.nTotal >= -nRemainder then
						vClause.modifier = vClause.modifier + nRemainder;
						vClause.nTotal = vClause.nTotal + nRemainder;
						break;
					else
						vClause.modifier = vClause.modifier - vClause.nTotal;
						nRemainder = nRemainder + vClause.nTotal;
						vClause.nTotal = 0;
					end
				end
			end
		end
		
		-- Collapse damage clauses into smallest set, then add to roll description as text
		local aDamage = ActionDamage.getDamageStrings(rRoll.clauses);
		for _, rDamage in ipairs(aDamage) do
			local sDice = StringManager.convertDiceToString(rDamage.aDice, rDamage.nMod);
			local sDmgTypeOutput = rDamage.sType;
			if sDmgTypeOutput == "" then
				sDmgTypeOutput = "untyped";
			end
			rRoll.sDesc = rRoll.sDesc .. string.format(" [TYPE: %s (%s=%d)]", sDmgTypeOutput, sDice, rDamage.nTotal);
		end
	end
end

-- Collapse damage clauses by damage type (in the original order, if possible)
function getDamageStrings(clauses)
	local aOrderedTypes = {};
	local aDmgTypes = {};
	for _,vClause in ipairs(clauses) do
		local rDmgType = aDmgTypes[vClause.dmgtype];
		if not rDmgType then
			rDmgType = {};
			rDmgType.aDice = {};
			rDmgType.nMod = 0;
			rDmgType.nTotal = 0;
			rDmgType.sType = vClause.dmgtype;
			aDmgTypes[vClause.dmgtype] = rDmgType;
			table.insert(aOrderedTypes, rDmgType);
		end

		for _,vDie in ipairs(vClause.dice) do
			table.insert(rDmgType.aDice, vDie);
		end
		rDmgType.nMod = rDmgType.nMod + vClause.modifier;
		rDmgType.nTotal = rDmgType.nTotal + (vClause.nTotal or 0);
	end
	
	return aOrderedTypes;
end

function getDamageTypesFromString(sDamageTypes)
	local sLower = string.lower(sDamageTypes);
	local aSplit = StringManager.split(sLower, ",", true);
	
	local aDamageTypes = {};
	for _,v in ipairs(aSplit) do
		if StringManager.contains(DataCommon.dmgtypes, v) then
			table.insert(aDamageTypes, v);
		end
	end
	
	return aDamageTypes;
end

--
-- DAMAGE APPLICATION
--

function getReductionType(rSource, rTarget, sEffectType)
	local aEffects = EffectManager5E.getEffectsByType(rTarget, sEffectType, {}, rSource);
	
	local aFinal = {};
	for _,v in pairs(aEffects) do
		local rReduction = {};
		
		rReduction.mod = v.mod;
		rReduction.aNegatives = {};
		for _,vType in pairs(v.remainder) do
			if #vType > 1 and ((vType:sub(1,1) == "!") or (vType:sub(1,1) == "~")) then
				if StringManager.contains(DataCommon.dmgtypes, vType:sub(2)) then
					table.insert(rReduction.aNegatives, vType:sub(2));
				end
			end
		end

		for _,vType in pairs(v.remainder) do
			if vType ~= "untyped" and vType ~= "" and vType:sub(1,1) ~= "!" and vType:sub(1,1) ~= "~" then
				if StringManager.contains(DataCommon.dmgtypes, vType) or vType == "all" then
					aFinal[vType] = rReduction;
				end
			end
		end
	end
	
	return aFinal;
end

function checkReductionTypeHelper(rMatch, aDmgType)
	if not rMatch or (rMatch.mod ~= 0) then
		return false;
	end
	if #(rMatch.aNegatives) > 0 then
		local bMatchNegative = false;
		for _,vNeg in pairs(rMatch.aNegatives) do
			if StringManager.contains(aDmgType, vNeg) then
				bMatchNegative = true;
				break;
			end
		end
		return not bMatchNegative;
	end
	return true;
end

function checkReductionType(aReduction, aDmgType)
	for _,sDmgType in pairs(aDmgType) do
		if ActionDamage.checkReductionTypeHelper(aReduction[sDmgType], aDmgType) or ActionDamage.checkReductionTypeHelper(aReduction["all"], aDmgType) then
			return true;
		end
	end
	
	return false;
end

function checkNumericalReductionTypeHelper(rMatch, aDmgType, nLimit)
	if not rMatch or (rMatch.mod == 0) then
		return 0;
	end

	local bMatch = false;
	if #rMatch.aNegatives > 0 then
		local bMatchNegative = false;
		for _,vNeg in pairs(rMatch.aNegatives) do
			if StringManager.contains(aDmgType, vNeg) then
				bMatchNegative = true;
				break;
			end
		end
		if not bMatchNegative then
			bMatch = true;
		end
	else
		bMatch = true;
	end
	
	local nAdjust = 0;
	if bMatch then
		nAdjust = rMatch.mod - (rMatch.nApplied or 0);
		if nLimit then
			nAdjust = math.min(nAdjust, nLimit);
		end
		rMatch.nApplied = (rMatch.nApplied or 0) + nAdjust;
	end
	
	return nAdjust;
end

function checkNumericalReductionType(aReduction, aDmgType, nLimit)
	local nAdjust = 0;
	
	for _,sDmgType in pairs(aDmgType) do
		if nLimit then
			local nSpecificAdjust = ActionDamage.checkNumericalReductionTypeHelper(aReduction[sDmgType], aDmgType, nLimit);
			nAdjust = nAdjust + nSpecificAdjust;
			local nGlobalAdjust = ActionDamage.checkNumericalReductionTypeHelper(aReduction["all"], aDmgType, nLimit - nSpecificAdjust);
			nAdjust = nAdjust + nGlobalAdjust;
		else
			nAdjust = nAdjust + ActionDamage.checkNumericalReductionTypeHelper(aReduction[sDmgType], aDmgType);
			nAdjust = nAdjust + ActionDamage.checkNumericalReductionTypeHelper(aReduction["all"], aDmgType);
		end
	end
	
	return nAdjust;
end

function getDamageAdjust(rSource, rTarget, nDamage, rDamageOutput)
	local nDamageAdjust = 0;
	local bVulnerable = false;
	local bResist = false;
	
	-- Get damage adjustment effects
	local aImmune = ActionDamage.getReductionType(rSource, rTarget, "IMMUNE");
	local aVuln = ActionDamage.getReductionType(rSource, rTarget, "VULN");
	local aResist = ActionDamage.getReductionType(rSource, rTarget, "RESIST");
	
	-- Handle immune all
	if aImmune["all"] then
		nDamageAdjust = 0 - nDamage;
		bResist = true;
		return nDamageAdjust, bVulnerable, bResist;
	end
	
	-- Iterate through damage type entries for vulnerability, resistance and immunity
	local nVulnApplied = 0;
	local bResistCarry = false;
	for k, v in pairs(rDamageOutput.aDamageTypes) do
		-- Get individual damage types for each damage clause
		local aSrcDmgClauseTypes = {};
		local aTemp = StringManager.split(k, ",", true);
		for _,vType in ipairs(aTemp) do
			if vType ~= "untyped" and vType ~= "" then
				table.insert(aSrcDmgClauseTypes, vType);
			end
		end
		
		-- Handle standard immunity, vulnerability and resistance
		local bLocalVulnerable = ActionDamage.checkReductionType(aVuln, aSrcDmgClauseTypes);
		local bLocalResist = ActionDamage.checkReductionType(aResist, aSrcDmgClauseTypes);
		local bLocalImmune = ActionDamage.checkReductionType(aImmune, aSrcDmgClauseTypes);
		
		-- Calculate adjustment
		-- Vulnerability = double
		-- Resistance = half
		-- Immunity = none
		local nLocalDamageAdjust = 0;
		if bLocalImmune then
			nLocalDamageAdjust = -v;
			bResist = true;
		else
			-- Handle numerical resistance
			local nLocalResist = ActionDamage.checkNumericalReductionType(aResist, aSrcDmgClauseTypes, v);
			if nLocalResist ~= 0 then
				nLocalDamageAdjust = nLocalDamageAdjust - nLocalResist;
				bResist = true;
			end
			-- Handle numerical vulnerability
			local nLocalVulnerable = ActionDamage.checkNumericalReductionType(aVuln, aSrcDmgClauseTypes);
			if nLocalVulnerable ~= 0 then
				nLocalDamageAdjust = nLocalDamageAdjust + nLocalVulnerable;
				bVulnerable = true;
			end
			-- Handle standard resistance
			if bLocalResist then
				local nResistOddCheck = (nLocalDamageAdjust + v) % 2;
				local nAdj = math.ceil((nLocalDamageAdjust + v) / 2);
				nLocalDamageAdjust = nLocalDamageAdjust - nAdj;
				if nResistOddCheck == 1 then
					if bResistCarry then
						nLocalDamageAdjust = nLocalDamageAdjust + 1;
						bResistCarry = false;
					else
						bResistCarry = true;
					end
				end
				bResist = true;
			end
			-- Handle standard vulnerability
			if bLocalVulnerable then
				nLocalDamageAdjust = nLocalDamageAdjust + (nLocalDamageAdjust + v);
				bVulnerable = true;
			end
		end
		
		-- Apply adjustment to this damage type clause
		nDamageAdjust = nDamageAdjust + nLocalDamageAdjust;
	end
	
	-- Handle damage threshold
	local nDTMod, nDTCount = EffectManager5E.getEffectsBonus(rTarget, {"DT"}, true);
	if nDTMod > 0 then
		if nDTMod > (nDamage + nDamageAdjust) then 
			nDamageAdjust = 0 - nDamage;
			bResist = true;
		end
	end

	-- Results
	return nDamageAdjust, bVulnerable, bResist;
end

function decodeDamageText(nDamage, sDamageDesc)
	local rDamageOutput = {};
	
	if string.match(sDamageDesc, "%[RECOVERY") then
		rDamageOutput.sType = "recovery";
		rDamageOutput.sTypeOutput = "Recovery";
		rDamageOutput.sVal = string.format("%01d", nDamage);
		rDamageOutput.nVal = nDamage;

	elseif string.match(sDamageDesc, "%[HEAL") then
		if string.match(sDamageDesc, "%[TEMP%]") then
			rDamageOutput.sType = "temphp";
			rDamageOutput.sTypeOutput = "Temporary hit points";
		else
			rDamageOutput.sType = "heal";
			rDamageOutput.sTypeOutput = "Heal";
		end
		rDamageOutput.sVal = string.format("%01d", nDamage);
		rDamageOutput.nVal = nDamage;

	elseif nDamage < 0 then
		rDamageOutput.sType = "heal";
		rDamageOutput.sTypeOutput = "Heal";
		rDamageOutput.sVal = string.format("%01d", (0 - nDamage));
		rDamageOutput.nVal = 0 - nDamage;

	else
		rDamageOutput.sType = "damage";
		rDamageOutput.sTypeOutput = "Damage";
		rDamageOutput.sVal = string.format("%01d", nDamage);
		rDamageOutput.nVal = nDamage;

		-- Determine critical
		rDamageOutput.bCritical = string.match(sDamageDesc, "%[CRITICAL%]");

		-- Determine range
		rDamageOutput.sRange = string.match(sDamageDesc, "%[DAMAGE %((%w)%)%]") or "";
		rDamageOutput.aDamageFilter = {};
		if rDamageOutput.sRange == "M" then
			table.insert(rDamageOutput.aDamageFilter, "melee");
		elseif rDamageOutput.sRange == "R" then
			table.insert(rDamageOutput.aDamageFilter, "ranged");
		end

		-- Determine damage energy types
		local nDamageRemaining = nDamage;
		rDamageOutput.aDamageTypes = {};
		for sDamageType, sDamageDice, sDamageSubTotal in string.gmatch(sDamageDesc, "%[TYPE: ([^(]*) %(([%d%+%-dD]+)%=(%d+)%)%]") do
			local nDamageSubTotal = (tonumber(sDamageSubTotal) or 0);
			rDamageOutput.aDamageTypes[sDamageType] = nDamageSubTotal + (rDamageOutput.aDamageTypes[sDamageType] or 0);
			if not rDamageOutput.sFirstDamageType then
				rDamageOutput.sFirstDamageType = sDamageType;
			end
			
			nDamageRemaining = nDamageRemaining - nDamageSubTotal;
		end
		if nDamageRemaining > 0 then
			rDamageOutput.aDamageTypes[""] = nDamageRemaining;
		elseif nDamageRemaining < 0 then
			ChatManager.SystemMessage("Total mismatch in damage type totals");
		end
	end
	
	return rDamageOutput;
end

function applyDamage(rSource, rTarget, bSecret, sDamage, nTotal)
	-- Get health fields
	local nTotalHP, nTempHP, nWounds, nDeathSaveSuccess, nDeathSaveFail;

	local sTargetNodeType, nodeTarget = ActorManager.getTypeAndNode(rTarget);
	if not nodeTarget then
		return;
	end
	if sTargetNodeType == "pc" then
		nTotalHP = DB.getValue(nodeTarget, "hp.total", 0);
		nTempHP = DB.getValue(nodeTarget, "hp.temporary", 0);
		nWounds = DB.getValue(nodeTarget, "hp.wounds", 0);
		nDeathSaveSuccess = DB.getValue(nodeTarget, "hp.deathsavesuccess", 0);
		nDeathSaveFail = DB.getValue(nodeTarget, "hp.deathsavefail", 0);
	elseif sTargetNodeType == "ct" then
		nTotalHP = DB.getValue(nodeTarget, "hptotal", 0);
		nTempHP = DB.getValue(nodeTarget, "hptemp", 0);
		nWounds = DB.getValue(nodeTarget, "wounds", 0);
		nDeathSaveSuccess = DB.getValue(nodeTarget, "deathsavesuccess", 0);
		nDeathSaveFail = DB.getValue(nodeTarget, "deathsavefail", 0);
	else
		return;
	end

	-- Prepare for notifications
	local nConcentrationDamage = 0;
	local bRemoveTarget = false;

	-- Remember current health status
	local sOriginalStatus = ActorHealthManager.getHealthStatus(rTarget);

	-- Decode damage/heal description
	local rDamageOutput = ActionDamage.decodeDamageText(nTotal, sDamage);
	rDamageOutput.tNotifications = {};
	
	-- Healing
	if rDamageOutput.sType == "recovery" then
		local sClassNode = string.match(sDamage, "%[NODE:([^]]+)%]");
		
		if nWounds <= 0 then
			table.insert(rDamageOutput.tNotifications, "[NOT WOUNDED]");
		else
			-- Determine whether HD available
			local nClassHD = 0;
			local nClassHDMult = 0;
			local nClassHDUsed = 0;
			if (sTargetNodeType == "pc") and sClassNode then
				local nodeClass = DB.findNode(sClassNode);
				if nodeClass then
					nClassHD = DB.getValue(nodeClass, "level", 0);
					nClassHDMult = #(DB.getValue(nodeClass, "hddie", {}));
					nClassHDUsed = DB.getValue(nodeClass, "hdused", 0);
				end
			end
			
			if (nClassHD * nClassHDMult) <= nClassHDUsed then
				table.insert(rDamageOutput.tNotifications, "[INSUFFICIENT HIT DICE FOR THIS CLASS]");
			else
				-- Calculate heal amounts
				local nHealAmount = rDamageOutput.nVal;
				
				-- If healing from zero (or negative), then remove Stable effect and reset wounds to match HP
				if (nHealAmount > 0) and (nWounds >= nTotalHP) then
					EffectManager.removeEffect(ActorManager.getCTNode(rTarget), "Stable");
					nWounds = nTotalHP;
				end
				
				local nWoundHealAmount = math.min(nHealAmount, nWounds);
				nWounds = nWounds - nWoundHealAmount;
				
				-- Display actual heal amount
				rDamageOutput.nVal = nWoundHealAmount;
				rDamageOutput.sVal = string.format("%01d", nWoundHealAmount);
				
				-- Decrement HD used
				if (sTargetNodeType == "pc") and sClassNode then
					local nodeClass = DB.findNode(sClassNode);
					if nodeClass then
						DB.setValue(nodeClass, "hdused", "number", nClassHDUsed + 1);
						rDamageOutput.sVal = rDamageOutput.sVal .. "][HD-1";
					end
				end
			end
		end

	-- Healing
	elseif rDamageOutput.sType == "heal" then
		if nWounds <= 0 then
			table.insert(rDamageOutput.tNotifications, "[NOT WOUNDED]");
		else
			-- Calculate heal amounts
			local nHealAmount = rDamageOutput.nVal;
			
			-- If healing from zero (or negative), then remove Stable effect and reset wounds to match HP
			if (nHealAmount > 0) and (nWounds >= nTotalHP) then
				EffectManager.removeEffect(ActorManager.getCTNode(rTarget), "Stable");
				nWounds = nTotalHP;
			end
			
			local nWoundHealAmount = math.min(nHealAmount, nWounds);
			nWounds = nWounds - nWoundHealAmount;
			
			-- Display actual heal amount
			rDamageOutput.nVal = nWoundHealAmount;
			rDamageOutput.sVal = string.format("%01d", nWoundHealAmount);
		end

	-- Temporary hit points
	elseif rDamageOutput.sType == "temphp" then
		nTempHP = math.max(nTempHP, rDamageOutput.nVal);

	-- Damage
	else
		-- Apply any targeted damage effects 
		if rSource and rTarget and rTarget.nOrder then
			ActionDamage.applyTargetedDmgEffectsToDamageOutput(rDamageOutput, rSource, rTarget);
			ActionDamage.applyTargetedDmgTypeEffectsToDamageOutput(rDamageOutput, rSource, rTarget);
		end
		
		-- Handle avoidance/evasion and half damage
		local isAvoided = false;
		local isHalf = string.match(sDamage, "%[HALF%]");
		local sAttack = string.match(sDamage, "%[DAMAGE[^]]*%] ([^[]+)");
		if sAttack then
			local sDamageState = getDamageState(rSource, rTarget, StringManager.trim(sAttack));
			if sDamageState == "none" then
				isAvoided = true;
				bRemoveTarget = true;
			elseif sDamageState == "half_success" then
				isHalf = true;
				bRemoveTarget = true;
			elseif sDamageState == "half_failure" then
				isHalf = true;
			end
		end
		if isAvoided then
			table.insert(rDamageOutput.tNotifications, "[EVADED]");
			for kType, nType in pairs(rDamageOutput.aDamageTypes) do
				rDamageOutput.aDamageTypes[kType] = 0;
			end
			rDamageOutput.nVal = 0;
		elseif isHalf then
			table.insert(rDamageOutput.tNotifications, "[HALF]");
			local bCarry = false;
			for kType, nType in pairs(rDamageOutput.aDamageTypes) do
				local nOddCheck = nType % 2;
				rDamageOutput.aDamageTypes[kType] = math.floor(nType / 2);
				if nOddCheck == 1 then
					if bCarry then
						rDamageOutput.aDamageTypes[kType] = rDamageOutput.aDamageTypes[kType] + 1;
						bCarry = false;
					else
						bCarry = true;
					end
				end
			end
			rDamageOutput.nVal = math.max(math.floor(rDamageOutput.nVal / 2), 1);
		end
		
		-- Apply damage type adjustments
		local nDamageAdjust, bVulnerable, bResist = getDamageAdjust(rSource, rTarget, rDamageOutput.nVal, rDamageOutput);
		local nAdjustedDamage = rDamageOutput.nVal + nDamageAdjust;
		if nAdjustedDamage < 0 then
			nAdjustedDamage = 0;
		end
		if bResist then
			if nAdjustedDamage <= 0 then
				table.insert(rDamageOutput.tNotifications, "[RESISTED]");
			else
				table.insert(rDamageOutput.tNotifications, "[PARTIALLY RESISTED]");
			end
		end
		if bVulnerable then
			table.insert(rDamageOutput.tNotifications, "[VULNERABLE]");
		end
		
		-- Prepare for concentration checks if damaged
		nConcentrationDamage = nAdjustedDamage;
		
		-- Reduce damage by temporary hit points
		if nTempHP > 0 and nAdjustedDamage > 0 then
			if nAdjustedDamage > nTempHP then
				nAdjustedDamage = nAdjustedDamage - nTempHP;
				nTempHP = 0;
				table.insert(rDamageOutput.tNotifications, "[PARTIALLY ABSORBED]");
			else
				nTempHP = nTempHP - nAdjustedDamage;
				nAdjustedDamage = 0;
				table.insert(rDamageOutput.tNotifications, "[ABSORBED]");
			end
		end

		-- Apply remaining damage
		if nAdjustedDamage > 0 then
			-- Remember previous wounds
			local nPrevWounds = nWounds;
			
			-- Apply wounds
			nWounds = math.max(nWounds + nAdjustedDamage, 0);
			
			-- Calculate wounds above HP
			local nRemainder = 0;
			if nWounds > nTotalHP then
				nRemainder = nWounds - nTotalHP;
				nWounds = nTotalHP;
			end
			
			-- Deal with remainder damage
			if nRemainder >= nTotalHP then
				table.insert(rDamageOutput.tNotifications, "[DAMAGE EXCEEDS HIT POINTS BY " .. nRemainder.. "]");
				table.insert(rDamageOutput.tNotifications, "[INSTANT DEATH]");
				nDeathSaveFail = 3;
			elseif nRemainder > 0 then
				table.insert(rDamageOutput.tNotifications, "[DAMAGE EXCEEDS HIT POINTS BY " .. nRemainder.. "]");
				if nPrevWounds >= nTotalHP then
					if rDamageOutput.bCritical then
						nDeathSaveFail = nDeathSaveFail + 2;
					else
						nDeathSaveFail = nDeathSaveFail + 1;
					end
				end
			else
				if OptionsManager.isOption("HRMD", "on") and (nAdjustedDamage >= (nTotalHP / 2)) then
					ActionSave.performSystemShockRoll(nil, rTarget);
				end
			end
			
			local nodeTargetCT = ActorManager.getCTNode(rTarget);
			if nodeTargetCT then
				-- Handle stable situation
				EffectManager.removeEffect(nodeTargetCT, "Stable");

				-- Disable regeneration next round on correct damage type
				-- Calculate which damage types actually did damage
				local aTempDamageTypes = {};
				local aActualDamageTypes = {};
				for k,v in pairs(rDamageOutput.aDamageTypes) do
					if v > 0 then
						table.insert(aTempDamageTypes, k);
					end
				end
				local aActualDamageTypes = StringManager.split(table.concat(aTempDamageTypes, ","), ",", true);
				
				-- Check target's effects for regeneration effects that match
				for _,v in pairs(DB.getChildren(nodeTargetCT, "effects")) do
					local nActive = DB.getValue(v, "isactive", 0);
					if (nActive == 1) then
						local bMatch = false;
						local sLabel = DB.getValue(v, "label", "");
						local aEffectComps = EffectManager.parseEffect(sLabel);
						for i = 1, #aEffectComps do
							local rEffectComp = EffectManager5E.parseEffectComp(aEffectComps[i]);
							if rEffectComp.type == "REGEN" then
								for _,v2 in pairs(rEffectComp.remainder) do
									if StringManager.contains(aActualDamageTypes, v2) then
										bMatch = true;
									end
								end
							end
							
							if bMatch then
								EffectManager.disableEffect(nodeTargetCT, v);
							end
						end
					end
				end
			end
		end
		
		-- Update the damage output variable to reflect adjustments
		rDamageOutput.nVal = nAdjustedDamage;
		rDamageOutput.sVal = string.format("%01d", nAdjustedDamage);
	end
	
	-- Clear death saves if health greater than zero
	if nWounds < nTotalHP then
		nDeathSaveSuccess = 0;
		nDeathSaveFail = 0;
		if EffectManager5E.hasEffect(rTarget, "Stable") then
			EffectManager.removeEffect(ActorManager.getCTNode(rTarget), "Stable");
		end
		if EffectManager5E.hasEffect(rTarget, "Unconscious") then
			EffectManager.removeEffect(ActorManager.getCTNode(rTarget), "Unconscious");
		end
	else
		if not EffectManager5E.hasEffect(rTarget, "Unconscious") then
			EffectManager.addEffect("", "", ActorManager.getCTNode(rTarget), { sName = "Unconscious", nDuration = 0 }, true);
		end
	end

	-- Set health fields
	if sTargetNodeType == "pc" then
		DB.setValue(nodeTarget, "hp.deathsavesuccess", "number", math.min(nDeathSaveSuccess, 3));
		DB.setValue(nodeTarget, "hp.deathsavefail", "number", math.min(nDeathSaveFail, 3));
		DB.setValue(nodeTarget, "hp.temporary", "number", nTempHP);
		DB.setValue(nodeTarget, "hp.wounds", "number", nWounds);
	else
		DB.setValue(nodeTarget, "deathsavesuccess", "number", math.min(nDeathSaveSuccess, 3));
		DB.setValue(nodeTarget, "deathsavefail", "number", math.min(nDeathSaveFail, 3));
		DB.setValue(nodeTarget, "hptemp", "number", nTempHP);
		DB.setValue(nodeTarget, "wounds", "number", nWounds);
	end

	-- Check for status change
	local bShowStatus = false;
	if ActorManager.isFaction(rTarget, "friend") then
		bShowStatus = not OptionsManager.isOption("SHPC", "off");
	else
		bShowStatus = not OptionsManager.isOption("SHNPC", "off");
	end
	if bShowStatus then
		local sNewStatus = ActorHealthManager.getHealthStatus(rTarget);
		if sOriginalStatus ~= sNewStatus then
			table.insert(rDamageOutput.tNotifications, "[" .. Interface.getString("combat_tag_status") .. ": " .. sNewStatus .. "]");
		end
	end
	
	-- Output results
	ActionDamage.messageDamage(rSource, rTarget, bSecret, rDamageOutput.sTypeOutput, sDamage, rDamageOutput.sVal, table.concat(rDamageOutput.tNotifications, " "));

	-- Remove target after applying damage
	if bRemoveTarget and rSource and rTarget then
		TargetingManager.removeTarget(ActorManager.getCTNodeName(rSource), ActorManager.getCTNodeName(rTarget));
	end

	-- Check for required concentration checks
	if nConcentrationDamage > 0 and ActionSave.hasConcentrationEffects(rTarget) then
		if nWounds < nTotalHP then
			local nTargetDC = math.max(math.floor(nConcentrationDamage / 2), 10);
			ActionSave.performConcentrationRoll(nil, rTarget, nTargetDC);
		else
			ActionSave.expireConcentrationEffects(rTarget);
		end
	end
end

function messageDamage(rSource, rTarget, bSecret, sDamageType, sDamageDesc, sTotal, sExtraResult)
	if not (rTarget or sExtraResult ~= "") then
		return;
	end
	
	local msgShort = {font = "msgfont"};
	local msgLong = {font = "msgfont"};

	if sDamageType == "Recovery" then
		msgShort.icon = "roll_heal";
		msgLong.icon = "roll_heal";
	elseif sDamageType == "Heal" then
		msgShort.icon = "roll_heal";
		msgLong.icon = "roll_heal";
	else
		msgShort.icon = "roll_damage";
		msgLong.icon = "roll_damage";
	end

	msgShort.text = sDamageType .. " ->";
	msgLong.text = sDamageType .. " [" .. sTotal .. "] ->";
	if rTarget then
		msgShort.text = msgShort.text .. " [to " .. ActorManager.getDisplayName(rTarget) .. "]";
		msgLong.text = msgLong.text .. " [to " .. ActorManager.getDisplayName(rTarget) .. "]";
	end
	
	if sExtraResult and sExtraResult ~= "" then
		msgLong.text = msgLong.text .. " " .. sExtraResult;
	end
	
	ActionsManager.outputResult(bSecret, rSource, rTarget, msgLong, msgShort);
end

--
-- TRACK DAMAGE STATE
--

local aDamageState = {};

function applyDamageState(rSource, rTarget, sAttack, sState)
	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYDMGSTATE;
	
	msgOOB.sSourceNode = ActorManager.getCTNodeName(rSource);
	msgOOB.sTargetNode = ActorManager.getCTNodeName(rTarget);
	
	msgOOB.sAttack = sAttack;
	msgOOB.sState = sState;

	Comm.deliverOOBMessage(msgOOB, "");
end

function handleApplyDamageState(msgOOB)
	local rSource = ActorManager.resolveActor(msgOOB.sSourceNode);
	local rTarget = ActorManager.resolveActor(msgOOB.sTargetNode);
	
	if Session.IsHost then
		ActionDamage.setDamageState(rSource, rTarget, msgOOB.sAttack, msgOOB.sState);
	end
end

function setDamageState(rSource, rTarget, sAttack, sState)
	if not Session.IsHost then
		ActionDamage.applyDamageState(rSource, rTarget, sAttack, sState);
		return;
	end
	
	local sSourceCT = ActorManager.getCTNodeName(rSource);
	local sTargetCT = ActorManager.getCTNodeName(rTarget);
	if sSourceCT == "" or sTargetCT == "" then
		return;
	end
	
	if not aDamageState[sSourceCT] then
		aDamageState[sSourceCT] = {};
	end
	if not aDamageState[sSourceCT][sAttack] then
		aDamageState[sSourceCT][sAttack] = {};
	end
	if not aDamageState[sSourceCT][sAttack][sTargetCT] then
		aDamageState[sSourceCT][sAttack][sTargetCT] = {};
	end
	aDamageState[sSourceCT][sAttack][sTargetCT] = sState;
end

function getDamageState(rSource, rTarget, sAttack)
	local sSourceCT = ActorManager.getCTNodeName(rSource);
	local sTargetCT = ActorManager.getCTNodeName(rTarget);
	if sSourceCT == "" or sTargetCT == "" then
		return "";
	end
	
	if not aDamageState[sSourceCT] then
		return "";
	end
	if not aDamageState[sSourceCT][sAttack] then
		return "";
	end
	if not aDamageState[sSourceCT][sAttack][sTargetCT] then
		return "";
	end
	
	local sState = aDamageState[sSourceCT][sAttack][sTargetCT];
	aDamageState[sSourceCT][sAttack][sTargetCT] = nil;
	return sState;
end
