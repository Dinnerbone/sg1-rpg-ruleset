-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

OOB_MSGTYPE_APPLYINIT = "applyinit";

function onInit()
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYINIT, handleApplyInit);

	ActionsManager.registerModHandler("init", modRoll);
	ActionsManager.registerResultHandler("init", onResolve);
end

function handleApplyInit(msgOOB)
	local rSource = ActorManager.resolveActor(msgOOB.sSourceNode);
	local nTotal = tonumber(msgOOB.nTotal) or 0;

	DB.setValue(ActorManager.getCTNode(rSource), "initresult", "number", nTotal);
end

function notifyApplyInit(rSource, nTotal)
	if not rSource then
		return;
	end
	
	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYINIT;
	
	msgOOB.nTotal = nTotal;

	msgOOB.sSourceNode = ActorManager.getCreatureNodeName(rSource);

	Comm.deliverOOBMessage(msgOOB, "");
end

function getRoll(rActor, bSecretRoll)
	local rRoll = {};
	rRoll.sType = "init";
	rRoll.aDice = { "d20" };
	rRoll.nMod = 0;
	
	rRoll.sDesc = "[INIT]";
	
	rRoll.bSecret = bSecretRoll;

	-- Determine the modifier and ability to use for this roll
	local sNodeType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if nodeActor then
		if sNodeType == "pc" then
			rRoll.nMod = DB.getValue(nodeActor, "initiative.total", 0);
		else
			rRoll.nMod = DB.getValue(nodeActor, "init", 0);
		end
	end
	
	return rRoll;
end

function performRoll(draginfo, rActor, bSecretRoll)
	local rRoll = getRoll(rActor, bSecretRoll);
	
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function modRoll(rSource, rTarget, rRoll)
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
		local bEffects, aEffectDice, nEffectMod, bEffectADV, bEffectDIS = getEffectAdjustments(rSource);
		if bEffects then
			for _,vDie in ipairs(aEffectDice) do
				if vDie:sub(1,1) == "-" then
					table.insert(rRoll.aDice, "-p" .. vDie:sub(3));
				else
					table.insert(rRoll.aDice, "p" .. vDie:sub(2));
				end
			end
			rRoll.nMod = rRoll.nMod + nEffectMod;
			if bEffectADV then
				bADV = true;
			end
			if bEffectDIS then
				bDIS = true;
			end

			local sEffects = "";
			local sMod = StringManager.convertDiceToString(aEffectDice, nEffectMod, true);
			if sMod ~= "" then
				sEffects = "[" .. Interface.getString("effects_tag") .. " " .. sMod .. "]";
			else
				sEffects = "[" .. Interface.getString("effects_tag") .. "]";
			end
			rRoll.sDesc = rRoll.sDesc .. " " .. sEffects;
		end
	end
	
	ActionsManager2.encodeDesktopMods(rRoll);
	ActionsManager2.encodeAdvantage(rRoll, bADV, bDIS);
end

-- Returns effect existence, effect dice, effect mod, effect advantage, effect disadvantage
function getEffectAdjustments(rActor)
	if rActor == nil then
		return false, {}, 0, false, false;
	end
	
	-- Determine ability used - Only dexterity for this ruleset
	local sActionStat = "dexterity";
	
	-- Set up
	local bEffects = false;
	local aEffectDice = {};
	local nEffectMod = 0;
	local bEffectADV = false;
	local bEffectDIS = false;
	
	-- Determine general effect modifiers
	local aInitDice, nInitMod, nInitCount = EffectManager5E.getEffectsBonus(rActor, {"INIT"});
	if nInitCount > 0 then
		bEffects = true;
		for _,vDie in ipairs(aInitDice) do
			table.insert(aEffectDice, vDie);
		end
		nEffectMod = nEffectMod + nInitMod;
	end
	
	-- Get ability effect modifiers
	local nAbilityMod, nAbilityEffects = ActorManager5E.getAbilityEffectsBonus(rActor, sActionStat);
	if nAbilityEffects > 0 then
		bEffects = true;
		nEffectMod = nEffectMod + nAbilityMod;
	end
	
	-- Get condition modifiers
	if EffectManager5E.hasEffectCondition(rActor, "ADVINIT") then
		bEffects = true;
		bEffectADV = true;
	end
	if EffectManager5E.hasEffectCondition(rActor, "DISINIT") then
		bEffects = true;
		bEffectDIS = true;
	end
	
	-- Ability check modifiers
	local aCheckFilter = { sActionStat };
	local aAbilityCheckDice, nAbilityCheckMod, nAbilityCheckCount = EffectManager5E.getEffectsBonus(rActor, {"CHECK"}, false, aCheckFilter);
	if (nAbilityCheckCount > 0) then
		bEffects = true;
		for _,vDie in ipairs(aAbilityCheckDice) do
			table.insert(aEffectDice, vDie);
		end
		nEffectMod = nEffectMod + nAbilityCheckMod;
	end
	
	-- Dexterity check conditions
	if EffectManager5E.hasEffectCondition(rActor, "ADVCHK") then
		bEffects = true;
		bEffectADV = true;
	elseif #(EffectManager5E.getEffectsByType(rActor, "ADVCHK", aCheckFilter)) > 0 then
		bEffects = true;
		bEffectADV = true;
	end
	if EffectManager5E.hasEffectCondition(rActor, "DISCHK") then
		bEffects = true;
		bEffectDIS = true;
	elseif #(EffectManager5E.getEffectsByType(rActor, "DISCHK", aCheckFilter)) > 0 then
		bEffects = true;
		bEffectDIS = true;
	end
	if EffectManager5E.hasEffectCondition(rActor, "Frightened") then
		bEffects = true;
		bEffectDIS = true;
	end
	if EffectManager5E.hasEffectCondition(rActor, "Intoxicated") then
		bEffects = true;
		bEffectDIS = true;
	end
	if EffectManager5E.hasEffectCondition(rActor, "Poisoned") then
		bEffects = true;
		bEffectDIS = true;
	end
	if EffectManager5E.hasEffectCondition(rActor, "Encumbered") then
		bEffects = true;
		bEffectDIS = true;
	end

	-- Get exhaustion modifiers
	local nExhaustMod, nExhaustCount = EffectManager5E.getEffectsBonus(rActor, {"EXHAUSTION"}, true);
	if nExhaustCount > 0 then
		bEffects = true;
		if nExhaustMod >= 1 then
			bEffectDIS = true;
		end
	end
	
	return bEffects, aEffectDice, nEffectMod, bEffectADV, bEffectDIS;
end

function onResolve(rSource, rTarget, rRoll)
	ActionsManager2.decodeAdvantage(rRoll);

	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	Comm.deliverChatMessage(rMessage);
	
	local nTotal = ActionsManager.total(rRoll);
	notifyApplyInit(rSource, nTotal);
end
