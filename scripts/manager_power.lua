-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

SPELL_LEVELS = 9;

-------------------
-- POWER MANAGEMENT
-------------------

function resetPowers(nodeCaster, bLong)
	local aListGroups = {};
	
	-- Build list of power groups
	for _,vGroup in pairs(DB.getChildren(nodeCaster, "powergroup")) do
		local sGroup = DB.getValue(vGroup, "name", "");
		if not aListGroups[sGroup] then
			local rGroup = {};
			rGroup.sName = sGroup;
			rGroup.sType = DB.getValue(vGroup, "castertype", "");
			rGroup.nUses = DB.getValue(vGroup, "uses", 0);
			rGroup.sUsesPeriod = DB.getValue(vGroup, "usesperiod", "");
			rGroup.nodeGroup = vGroup;
			
			aListGroups[sGroup] = rGroup;
		end
	end
	
	-- Reset power usage
	for _,vPower in pairs(DB.getChildren(nodeCaster, "powers")) do
		local bReset = true;

		local sGroup = DB.getValue(vPower, "group", "");
		local rGroup = aListGroups[sGroup];
		local bCaster = (rGroup and rGroup.sType ~= "");
		
		if not bCaster then
			if rGroup and (rGroup.nUses > 0) then
				if rGroup.sUsesPeriod == "once" then
					bReset = false;
				elseif not bLong and rGroup.sUsesPeriod ~= "enc" then
					bReset = false;
				end
			else
				local sPowerUsesPeriod = DB.getValue(vPower, "usesperiod", "");
				if sPowerUsesPeriod == "once" then
					bReset = false;
				elseif not bLong and sPowerUsesPeriod ~= "enc" then
					bReset = false;
				end
			end
		end
		
		if bReset then
			DB.setValue(vPower, "cast", "number", 0);
		end
	end
	
	-- Reset spell slots
	for i = 1, SPELL_LEVELS do
		DB.setValue(nodeCaster, "powermeta.pactmagicslots" .. i .. ".used", "number", 0);
	end
	if bLong then
		for i = 1, SPELL_LEVELS do
			DB.setValue(nodeCaster, "powermeta.spellslots" .. i .. ".used", "number", 0);
		end
	end
end

function addPower(sClass, nodeSource, nodeCreature, sGroup)
	-- Validate
	if not nodeSource or not nodeCreature then
		return nil;
	end
	
	-- Create the powers list entry
	local nodePowers = nodeCreature.createChild("powers");
	if not nodePowers then
		return nil;
	end
	
	-- Create the new power entry
	local nodeNewPower = nodePowers.createChild();
	if not nodeNewPower then
		return nil;
	end
	
	-- Copy the power details over
	DB.copyNode(nodeSource, nodeNewPower);
	
	-- Determine group setting
	if sGroup then
		DB.setValue(nodeNewPower, "group", "string", sGroup);
	end
	
	-- Class specific handling
	if sClass ~= "reference_spell" and sClass ~= "power" then
		-- Remove level data
		DB.deleteChild(nodeNewPower, "level");
		
		-- Copy text to description
		local nodeText = nodeNewPower.getChild("text");
		if nodeText then
			local nodeDesc = nodeNewPower.createChild("description", "formattedtext");
			DB.copyNode(nodeText, nodeDesc);
			nodeText.delete();
		end
	end
	
	-- Set locked state for editing detailed record
	DB.setValue(nodeNewPower, "locked", "number", 1);
	
	-- Parse power details to create actions
	if DB.getChildCount(nodeNewPower, "actions") == 0 then
		parsePCPower(nodeNewPower);
	end

	-- If PC, then make sure all spells are visible
	if ActorManager.isPC(nodeCreature) then
		DB.setValue(nodeCreature, "powermode", "string", "standard");
	end
	
	return nodeNewPower;
end

-------------------------
-- POWER ACTION DISPLAY
-------------------------

function getPCPowerActionOutputOrder(nodeAction)
	if not nodeAction then
		return 1;
	end
	local nodeActionList = nodeAction.getParent();
	if not nodeActionList then
		return 1;
	end
	
	-- First, pull some ability attributes
	local sType = DB.getValue(nodeAction, "type", "");
	local nOrder = DB.getValue(nodeAction, "order", 0);
	
	-- Iterate through list node
	local nOutputOrder = 1;
	for k, v in pairs(nodeActionList.getChildren()) do
		if DB.getValue(v, "type", "") == sType then
			if DB.getValue(v, "order", 0) < nOrder then
				nOutputOrder = nOutputOrder + 1;
			end
		end
	end
	
	return nOutputOrder;
end

function getPCPowerAction(nodeAction, sSubRoll)
	if not nodeAction then
		return;
	end
	local rActor = ActorManager.resolveActor(nodeAction.getChild("....."));
	if not rActor then
		return;
	end
	
	local rAction = {};
	rAction.type = DB.getValue(nodeAction, "type", "");
	rAction.label = DB.getValue(nodeAction, "...name", "");
	rAction.order = getPCPowerActionOutputOrder(nodeAction);
	
	if rAction.type == "cast" then
		rAction.subtype = sSubRoll;
		rAction.onmissdamage = DB.getValue(nodeAction, "onmissdamage", "");
		
		local sAttackType = DB.getValue(nodeAction, "atktype", "");
		if sAttackType ~= "" then
			if sAttackType == "melee" then
				rAction.range = "M";
			else
				rAction.range = "R";
			end
			
			rAction.modifier = DB.getValue(nodeAction, "atkmod", 0);
			local sAttackBase = DB.getValue(nodeAction, "atkbase", "");
			if sAttackBase == "fixed" then
				rAction.base = "fixed";
			elseif sAttackBase == "ability" then
				rAction.base = "";
				rAction.stat = DB.getValue(nodeAction, "atkstat", "");
				rAction.prof = DB.getValue(nodeAction, "atkprof", 1);
				rAction.modifier = DB.getValue(nodeAction, "atkmod", 0);
			else
				rAction.base = "group";
			end
		end
		
		local sSaveType = DB.getValue(nodeAction, "savetype", "");
		if sSaveType ~= "" then
			rAction.save = sSaveType;
			rAction.savemod = DB.getValue(nodeAction, "savedcmod", 0);
			if DB.getValue(nodeAction, "savemagic", 0) == 1 then
				rAction.magic = true;
			end
			local sSaveBase = DB.getValue(nodeAction, "savedcbase", "");
			if sSaveBase == "fixed" then
				rAction.savebase = "fixed";
			elseif sSaveBase == "ability" then
				rAction.savebase = "";
				rAction.savestat = DB.getValue(nodeAction, "savedcstat", "");
				rAction.saveprof = DB.getValue(nodeAction, "savedcprof", 1);
				rAction.savemod = rAction.savemod + 8;
			else
				rAction.savebase = "group";
				rAction.savemod = rAction.savemod + 8;
			end
		else
			rAction.save = "";
		end
		
	elseif rAction.type == "damage" then
		rAction.clauses = {};
		local aDamageNodes = UtilityManager.getSortedTable(DB.getChildren(nodeAction, "damagelist"));
		for _,v in ipairs(aDamageNodes) do
			local sAbility = DB.getValue(v, "stat", "");
			local nMult = DB.getValue(v, "statmult", 1);
			local aDice = DB.getValue(v, "dice", {});
			local nMod = DB.getValue(v, "bonus", 0);
			local sDmgType = DB.getValue(v, "type", "");
			
			table.insert(rAction.clauses, { dice = aDice, stat = sAbility, statmult = nMult, modifier = nMod, dmgtype = sDmgType });
		end
		
	elseif rAction.type == "heal" then
		rAction.sTargeting = DB.getValue(nodeAction, "healtargeting", "");
		rAction.subtype = DB.getValue(nodeAction, "healtype", "");
		
		rAction.clauses = {};
		local aHealNodes = UtilityManager.getSortedTable(DB.getChildren(nodeAction, "heallist"));
		for _,v in ipairs(aHealNodes) do
			local sAbility = DB.getValue(v, "stat", "");
			local nMult = DB.getValue(v, "statmult", 1);
			local aDice = DB.getValue(v, "dice", {});
			local nMod = DB.getValue(v, "bonus", 0);
			
			table.insert(rAction.clauses, { dice = aDice, stat = sAbility, statmult = nMult, modifier = nMod });
		end
		
	elseif rAction.type == "effect" then
		rAction.sName = DB.getValue(nodeAction, "label", "");

		rAction.sApply = DB.getValue(nodeAction, "apply", "");
		rAction.sTargeting = DB.getValue(nodeAction, "targeting", "");
		
		rAction.nDuration = DB.getValue(nodeAction, "durmod", 0);
		rAction.sUnits = DB.getValue(nodeAction, "durunit", "");
	end
	
	return rAction, rActor;
end

function performPCPowerAction(draginfo, nodeAction, sSubRoll)
	local rAction, rActor = getPCPowerAction(nodeAction, sSubRoll);
	if rAction then
		performAction(draginfo, rActor, rAction, nodeAction.getChild("..."));
	end
end

function getPCPowerCastActionText(nodeAction)
	local sAttack = "";
	local sSave = "";

	local rAction, rActor = PowerManager.getPCPowerAction(nodeAction);
	if rAction then
		evalAction(rActor, nodeAction.getChild("..."), rAction);
		
		if (rAction.range or "") ~= "" then
			if rAction.range == "R" then
				sAttack = Interface.getString("ranged");
			else
				sAttack = Interface.getString("melee");
			end
			if rAction.modifier ~= 0 then
				sAttack = string.format("%s %+d", sAttack, rAction.modifier);
			end
		end
		if (rAction.save or "") ~= "" then
			sSave = StringManager.capitalize(rAction.save:sub(1,3)) .. " DC " .. rAction.savemod;
			if rAction.onmissdamage == "half" then
				sSave = sSave .. " (H)";
			end
		end
	end
	
	return sAttack, sSave;
end

function getPCPowerDamageActionText(nodeAction)
	local aOutput = {};
	local rAction, rActor = PowerManager.getPCPowerAction(nodeAction);
	if rAction then
		evalAction(rActor, nodeAction.getChild("..."), rAction);
		
		local aDamage = ActionDamage.getDamageStrings(rAction.clauses);
		for _,rDamage in ipairs(aDamage) do
			local sDice = StringManager.convertDiceToString(rDamage.aDice, rDamage.nMod);
			if rDamage.sType ~= "" then
				table.insert(aOutput, string.format("%s %s", sDice, rDamage.sType));
			else
				table.insert(aOutput, sDice);
			end
		end
	end
	return table.concat(aOutput, " + ");
end

function getPCPowerHealActionText(nodeAction)
	local sHeal = "";
	
	local rAction, rActor = PowerManager.getPCPowerAction(nodeAction);
	if rAction then
		evalAction(rActor, nodeAction.getChild("..."), rAction);
		
		local aHealDice = {};
		local nHealMod = 0;
		for _,vClause in ipairs(rAction.clauses) do
			for _,vDie in ipairs(vClause.dice) do
				table.insert(aHealDice, vDie);
			end
			nHealMod = nHealMod + vClause.modifier;
		end
		
		sHeal = StringManager.convertDiceToString(aHealDice, nHealMod);
		if DB.getValue(nodeAction, "healtype", "") == "temp" then
			sHeal = sHeal .. " temporary";
		end
		if DB.getValue(nodeAction, "healtargeting", "") == "self" then
			sHeal = sHeal .. " [SELF]";
		end
	end
	
	return sHeal;
end


-------------------------
-- POWER USAGE
-------------------------

function getPowerGroupRecord(rActor, nodePower, bNPCInnate)
	local aPowerGroup = nil;
	local bInnate = false;
	
	local sNodeType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if sNodeType == "pc" then
		local nodePowerGroup = nil;
		local sGroup = DB.getValue(nodePower, "group", "");
		for _,v in pairs(DB.getChildren(nodeActor, "powergroup")) do
			if DB.getValue(v, "name", "") == sGroup then
				nodePowerGroup = v;
			end
		end
		if nodePowerGroup then
			aPowerGroup = {};

			aPowerGroup.sStat = DB.getValue(nodePowerGroup, "stat", "");

			aPowerGroup.nAtkProf = DB.getValue(nodePowerGroup, "atkprof", 1);
			aPowerGroup.sAtkStat = DB.getValue(nodePowerGroup, "atkstat", "");
			if aPowerGroup.sAtkStat == "" then
				aPowerGroup.sAtkStat = aPowerGroup.sStat;
			end
			aPowerGroup.nAtkMod = DB.getValue(nodePowerGroup, "atkmod", 0);
			
			aPowerGroup.nSaveDCProf = DB.getValue(nodePowerGroup, "saveprof", 1);
			aPowerGroup.sSaveDCStat = DB.getValue(nodePowerGroup, "savestat", "");
			if aPowerGroup.sSaveDCStat == "" then
				aPowerGroup.sSaveDCStat = aPowerGroup.sStat;
			end
			aPowerGroup.nSaveDCMod = DB.getValue(nodePowerGroup, "savemod", 0);
		end
	else
		if nodePower then
			bInnate = (nodePower.getChild("..").getName() == "innatespells");
		else
			bInnate = bNPCInnate;
		end
			
		local nodeTrait = nil;
		for _,v in pairs(DB.getChildren(nodeActor, "actions")) do
			local sTraitName = StringManager.trim(DB.getValue(v, "name", ""):lower());
			if bInnate and sTraitName == "spellcasting" then
				nodeTrait = v;
				break;
			end
		end
		if not nodeTrait then
			for _,v in pairs(DB.getChildren(nodeActor, "traits")) do
				local sTraitName = StringManager.trim(DB.getValue(v, "name", ""):lower());
				if not bInnate and sTraitName == "spellcasting" then
					nodeTrait = v;
					break;
				elseif bInnate and sTraitName:match("^innate spellcasting") then
					nodeTrait = v;
					break;
				end
			end
		end
		if nodeTrait then
			aPowerGroup = {};
			aPowerGroup.bInnate = bInnate; 
			
			local sDesc = DB.getValue(nodeTrait, "desc", ""):lower();
			aPowerGroup.sStat = sDesc:match("spellcasting ability is (%w+)") or "";
			
			aPowerGroup.nAtkProf = 1;
			aPowerGroup.sAtkStat = aPowerGroup.sStat;
			aPowerGroup.nAtkMod = 0;
			local nFixedAtk = tonumber(sDesc:match("([+-]?%d+) to hit with spell attacks")) or nil;
			if nFixedAtk then
				local nTempMod = ActorManager5E.getAbilityBonus(rActor, aPowerGroup.sStat) + ActorManager5E.getAbilityBonus(rActor, "prf");
				aPowerGroup.nAtkMod = nFixedAtk - nTempMod;
			end

			aPowerGroup.nSaveDCProf = 1;
			aPowerGroup.sSaveDCStat = aPowerGroup.sStat;
			aPowerGroup.nSaveDCMod = 0;
			local nFixedSaveDC = tonumber(sDesc:match("spell save dc (%d+)")) or nil;
			if nFixedSaveDC then
				local nTempMod = 8 + ActorManager5E.getAbilityBonus(rActor, aPowerGroup.sStat) + ActorManager5E.getAbilityBonus(rActor, "prf");
				aPowerGroup.nSaveDCMod = nFixedSaveDC - nTempMod;
			end
			
			if not nodePower then
				local aLines = StringManager.split(DB.getValue(nodeTrait, "desc", ""), "\n");
				for _,sLine in ipairs(aLines) do
					local sLineLower = sLine:lower();
					local nLevel = -1;
					if bInnate then
						if sLineLower:match("^at will") then
							nLevel = 0;
						else
							nLevel = tonumber(sLineLower:match("^([1-9]) ?[\\/] ?day")) or -1;
						end
					else
						nLevel = tonumber(sLineLower:match("^([1-9])[snrt][tdh] level")) or -1;
						if nLevel > 0 then
							
						elseif nLevel == -1 and sLineLower:match("^cantrips") then
							nLevel = 0;
						end
					end
					if nLevel >= 0 then
						local aSpells = StringManager.split(sLine:match(":(.*)$"), ",", true);
						if nLevel > 0 then
							local nSlots = tonumber(sLineLower:match("%((%d+) slots?%)")) or 0;
							if nSlots > 0 then
								aSpells["slots"] = nSlots;
							end
						end
						if #aSpells > 0 then
							aPowerGroup[nLevel] = aSpells;
						end
					end
				end
			end
		end
	end
	
	if not aPowerGroup and nodePower then
		if sNodeType ~= "pc" then
			local nodeNPCGroup = nodePower.getParent();
			if nodeNPCGroup and StringManager.isWord(nodeNPCGroup.getName, { "innatespells", "spells" }) then
				if bInnate then
					ChatManager.SystemMessage(Interface.getString("power_error_innatespellcastingnotfound"));
				else
					ChatManager.SystemMessage(Interface.getString("power_error_spellcastingnotfound"));
				end
			end
		end
	end
	
	return aPowerGroup;
end

function evalAction(rActor, nodePower, rAction)
	local aPowerGroup = nil;

	if (rAction.type == "cast") or (rAction.type == "attack") then
		if (rAction.base or "") == "group" then
			if not aPowerGroup then
				aPowerGroup = getPowerGroupRecord(rActor, nodePower);
			end
			if aPowerGroup then
				rAction.stat = aPowerGroup.sAtkStat;
				rAction.prof = aPowerGroup.nAtkProf;
				rAction.modifier = (rAction.modifier or 0) + aPowerGroup.nAtkMod;
			end
		end
		if (rAction.stat or "") == "base" then
			if not aPowerGroup then
				aPowerGroup = getPowerGroupRecord(rActor, nodePower);
			end
			if aPowerGroup then
				rAction.stat = aPowerGroup.sStat or "";
			end
		end
		if (rAction.stat or "") ~= "" then
			rAction.modifier = (rAction.modifier or 0) + ActorManager5E.getAbilityBonus(rActor, rAction.stat);
		end
		if (rAction.prof or 0) == 1 then
			rAction.modifier = (rAction.modifier or 0) + ActorManager5E.getAbilityBonus(rActor, "prf");
		end
	end
	
	if (rAction.type == "cast") or (rAction.type == "powersave") then
		if (rAction.save or "") == "base" then
			if not aPowerGroup then
				aPowerGroup = getPowerGroupRecord(rActor, nodePower);
			end
			if aPowerGroup then
				rAction.save = aPowerGroup.sStat or "";
			end
		end
		if (rAction.savebase or "") == "group" then
			if not aPowerGroup then
				aPowerGroup = getPowerGroupRecord(rActor, nodePower);
			end
			if aPowerGroup then
				rAction.savestat = aPowerGroup.sSaveDCStat;
				rAction.saveprof = aPowerGroup.nSaveDCProf;
				rAction.savemod = (rAction.savemod or 8) + aPowerGroup.nSaveDCMod;
			end
		end
		if (rAction.savestat or "") == "base" then
			if not aPowerGroup then
				aPowerGroup = getPowerGroupRecord(rActor, nodePower);
			end
			if aPowerGroup then
				rAction.savestat = aPowerGroup.sSaveDCStat or "";
			end
		end
		if (rAction.savestat or "") ~= "" then
			rAction.savemod = (rAction.savemod or 8) + ActorManager5E.getAbilityBonus(rActor, rAction.savestat);
		end
		if (rAction.saveprof or 0) == 1 then
			rAction.savemod = (rAction.savemod or 8) + ActorManager5E.getAbilityBonus(rActor, "prf");
		end
	end
	
	if (rAction.type == "damage") or (rAction.type == "heal") then
		for _,vClause in ipairs(rAction.clauses) do
			if (vClause.stat or "") ~= "" then
				if vClause.stat == "base" then
					if not aPowerGroup then
						aPowerGroup = getPowerGroupRecord(rActor, nodePower);
					end
					if aPowerGroup then
						local nAbilityBonus = ActorManager5E.getAbilityBonus(rActor, aPowerGroup.sStat);
						local nMult = vClause.statmult or 1;
						if nAbilityBonus > 0 and nMult ~= 1 then
							nAbilityBonus = math.floor(nMult * nAbilityBonus);
						end
						vClause.modifier = vClause.modifier + nAbilityBonus;
						vClause.stat = aPowerGroup.sStat;
					end
				else
					local nAbilityBonus = ActorManager5E.getAbilityBonus(rActor, vClause.stat);
					local nMult = vClause.statmult or 1;
					if nAbilityBonus > 0 and nMult ~= 1 then
						nAbilityBonus = math.floor(nMult * nAbilityBonus);
					end
					vClause.modifier = vClause.modifier + nAbilityBonus;
				end
			end
		end
	end

	if (rAction.type == "effect") then
		if rAction.sName:match("%[BASE%]") then
			if not aPowerGroup then
				aPowerGroup = getPowerGroupRecord(rActor, nodePower);
			end
			if aPowerGroup and aPowerGroup.sStat and DataCommon.ability_ltos[aPowerGroup.sStat] then
				rAction.sName =  rAction.sName:gsub("%[BASE%]", "[" .. DataCommon.ability_ltos[aPowerGroup.sStat] .. "]");
			end
		end
		rAction.sName = EffectManager5E.evalEffect(rActor, rAction.sName);
	end
end

function performAction(draginfo, rActor, rAction, nodePower)
	if not rActor or not rAction then
		return false;
	end
	
	evalAction(rActor, nodePower, rAction);

	local rRolls = {};
	if rAction.type == "cast" then
		rAction.subtype = (rAction.subtype or "");
		if rAction.subtype == "" then
			table.insert(rRolls, ActionPower.getPowerCastRoll(rActor, rAction));
		end
		if ((rAction.subtype == "") or (rAction.subtype == "atk")) and rAction.range then
			table.insert(rRolls, ActionAttack.getRoll(rActor, rAction));
		end
		if ((rAction.subtype == "") or (rAction.subtype == "save")) and ((rAction.save or "") ~= "") then
			table.insert(rRolls, ActionPower.getSaveVsRoll(rActor, rAction));
		end
	
	elseif rAction.type == "attack" then
		table.insert(rRolls, ActionAttack.getRoll(rActor, rAction));
		
	elseif rAction.type == "powersave" then
		table.insert(rRolls, ActionPower.getSaveVsRoll(rActor, rAction));

	elseif rAction.type == "damage" then
		table.insert(rRolls, ActionDamage.getRoll(rActor, rAction));
		
	elseif rAction.type == "heal" then
		table.insert(rRolls, ActionHeal.getRoll(rActor, rAction));
		
	elseif rAction.type == "effect" then
		local rRoll = ActionEffect.getRoll(draginfo, rActor, rAction);
		if rRoll then
			table.insert(rRolls, rRoll);
		end
	end
	
	if #rRolls > 0 then
		ActionsManager.performMultiAction(draginfo, rActor, rRolls[1].sType, rRolls);
	end
	return true;
end


-------------------------
-- POWER PARSING
-------------------------

function parseAttacks(sPowerName, aWords)
	local attacks = {};
	
	for i = 1, #aWords do
		if StringManager.isWord(aWords[i], "attack") then
			local nIndex = i;
			if StringManager.isWord(aWords[nIndex + 1], ":") then
				nIndex = nIndex + 1;
			end
			if StringManager.isNumberString(aWords[nIndex+1]) and 
					StringManager.isWord(aWords[nIndex+2], "to") and
					StringManager.isWord(aWords[nIndex+3], "hit") then
				local rAttack = {};
				rAttack.startindex = i;
				rAttack.endindex = nIndex + 3;
				
				rAttack.label = sPowerName;
				
				if StringManager.isWord(aWords[i-1], "weapon") then
					rAttack.weapon = true;
					rAttack.startindex = i - 1;
				elseif StringManager.isWord(aWords[i-1], "spell") then
					rAttack.spell = true;
					rAttack.startindex = i - 1;
				end
				
				if StringManager.isWord(aWords[i-2], "melee") then
					rAttack.range = "M";
					rAttack.startindex = i - 2;
				elseif StringManager.isWord(aWords[i-2], "ranged") then
					rAttack.range = "R";
					rAttack.startindex = i - 2;
				end
				
				if StringManager.isWord(aWords[nIndex+4], "reach") then
					rAttack.rangedist = aWords[nIndex+5];
				elseif StringManager.isWord(aWords[nIndex+4], "range") then
					if StringManager.isNumberString(aWords[nIndex+5]) and StringManager.isWord(aWords[nIndex+6], "ft") then
						rAttack.rangedist = aWords[nIndex+5];
						
						local nIndex2 = nIndex + 7;
						if StringManager.isWord(aWords[nIndex2], ".") then
							nIndex2 = nIndex2 + 1;
						end
						if StringManager.isNumberString(aWords[nIndex2]) and StringManager.isWord(aWords[nIndex2+1], "ft") then
							rAttack.rangedist = rAttack.rangedist .. "/" .. aWords[nIndex2];
						end
					end
				end

				rAttack.modifier = tonumber(aWords[nIndex+1]) or 0;

				table.insert(attacks, rAttack);
			else
				local bValid = false;
				if StringManager.isWord(aWords[i-1], {"weapon", "spell"}) and StringManager.isWord(aWords[i-2], {"melee", "ranged"}) and
						StringManager.isWord(aWords[i-3], {"a", "one", "single"}) and StringManager.isWord(aWords[i-4], "make") then
					bValid = true;
				end
				if bValid == true then
					if StringManager.isWord(aWords[i+1], "during") then
						bValid = false;
					elseif StringManager.isWord(aWords[i-5], "you") and StringManager.isWord(aWords[i-6], "when") then
						bValid = false;
					end
				end
				if bValid == true then
					local rAttack = {};
					rAttack.startindex = i - 2;
					rAttack.endindex = i;
					
					rAttack.label = sPowerName;
				
					if StringManager.isWord(aWords[i-1], "weapon") then
						rAttack.weapon = true;
					elseif StringManager.isWord(aWords[i-1], "spell") then
						rAttack.spell = true;
					end
					
					if StringManager.isWord(aWords[i-2], "melee") then
						rAttack.range = "M";
					elseif StringManager.isWord(aWords[i-2], "ranged") then
						rAttack.range = "R";
					end
					
					rAttack.modifier = 0;
					if rAttack.weapon then
						rAttack.nomod = true;
					else
						rAttack.base = "group";
					end
					
					table.insert(attacks, rAttack);
				end
			end
		end
	end
	
	return attacks;
end

-- Assumes current index points to "damage"
function parseDamagePhrase(aWords, i)
	local rDamageFixed = nil;
	local rDamageVariable = nil;
	
	local bValid = false;
	local nDamageBegin = i;
	while StringManager.isWord(aWords[nDamageBegin - 1], DataCommon.dmgtypes) or
			(StringManager.isWord(aWords[nDamageBegin - 1], "iron") and StringManager.isWord(aWords[nDamageBegin - 2], "cold-forged")) or
			(StringManager.isWord(aWords[nDamageBegin - 1], "or") and StringManager.isWord(aWords[nDamageBegin - 2], DataCommon.dmgtypes)) or
			(StringManager.isWord(aWords[nDamageBegin - 1], "or") and StringManager.isWord(aWords[nDamageBegin - 2], "iron") and StringManager.isWord(aWords[nDamageBegin - 3], "cold-forged")) do
		if (StringManager.isWord(aWords[nDamageBegin - 1], "iron") and StringManager.isWord(aWords[nDamageBegin - 2], "cold-forged")) then
			nDamageBegin = nDamageBegin - 2;
		else
			nDamageBegin = nDamageBegin - 1;
		end
	end
	while StringManager.isDiceString(aWords[nDamageBegin - 1]) or (StringManager.isWord(aWords[nDamageBegin - 1], "plus") and StringManager.isDiceString(aWords[nDamageBegin - 2])) do
		bValid = true;
		nDamageBegin = nDamageBegin - 1;
	end
	if StringManager.isWord(aWords[nDamageBegin], "+") then
		nDamageBegin = nDamageBegin + 1;
	end
	
	if bValid then
		local nClauses = 0;
		local aFixedClauses = {};
		local aVariableClauses = {};
		local bHasVariableClause = false;
		local nDamageEnd = i;
		
		local j = nDamageBegin - 1;
		while bValid do
			local aDamage = {};

			while StringManager.isDiceString(aWords[j+1]) or (StringManager.isWord(aWords[j+1], "plus") and StringManager.isDiceString(aWords[j+2])) do
				if aWords[j+1] == "plus" then
					table.insert(aDamage, "+");
				else
					table.insert(aDamage, aWords[j+1]);
				end
				j = j + 1;
			end
			
			local aDmgType = {};
			while StringManager.isWord(aWords[j+1], DataCommon.dmgtypes) or
					(StringManager.isWord(aWords[j+1], "cold-forged") and StringManager.isWord(aWords[j+2], "iron")) or
					(StringManager.isWord(aWords[j+1], "or") and StringManager.isWord(aWords[j+2], DataCommon.dmgtypes)) or
					(StringManager.isWord(aWords[j+1], "or") and StringManager.isWord(aWords[j+2], "cold-forged") and StringManager.isWord(aWords[j+3], "iron")) do
				if StringManager.isWord(aWords[j+1], "cold-forged") and StringManager.isWord(aWords[j+2], "iron") then
					j = j + 1;
					table.insert(aDmgType, "cold-forged iron");
				elseif aWords[j+1] ~= "or" then
					table.insert(aDmgType, aWords[j+1]);
				end
				j = j + 1;
			end
			
			if #aDamage > 0 and StringManager.isWord(aWords[j+1], "damage") then
				j = j + 1;
				
				nClauses = nClauses + 1;
				
				local sDmgType = table.concat(aDmgType, ",");
				if #aDamage > 1 and StringManager.isNumberString(aDamage[1]) then
					bHasVariableClause = true;

					local rClauseFixed = {};
					rClauseFixed.dmgtype = sDmgType;
					rClauseFixed.dice, rClauseFixed.modifier = StringManager.convertStringToDice(aDamage[1]);
					aFixedClauses[nClauses] = rClauseFixed;

					local rClauseVariable = {};
					rClauseVariable.dmgtype = sDmgType;
					rClauseVariable.dice, rClauseVariable.modifier = StringManager.convertStringToDice(table.concat(aDamage, "", 2));
					aVariableClauses[nClauses] = rClauseVariable;
				else
					local rClauseFixed = {};
					rClauseFixed.dmgtype = sDmgType;
					rClauseFixed.dice, rClauseFixed.modifier = StringManager.convertStringToDice(table.concat(aDamage));
					aFixedClauses[nClauses] = rClauseFixed;
					
					local rClauseVariable = {};
					rClauseVariable.dmgtype = sDmgType;
					rClauseVariable.dice, rClauseVariable.modifier = StringManager.convertStringToDice(table.concat(aDamage));
					aVariableClauses[nClauses] = rClauseVariable;
				end
				
				nDamageEnd = j;

				if StringManager.isWord(aWords[j+1], {"and", "plus", "+"}) then
					j = j + 1;
					bValid = true;
				else
					bValid = false;
				end
			else
				bValid = false;
			end
		end

		if nClauses > 0 then
			rDamageFixed = {};
			rDamageFixed.startindex = nDamageBegin;
			rDamageFixed.endindex = nDamageEnd;

			rDamageFixed.clauses = aFixedClauses;
			
			if bHasVariableClause then
				rDamageVariable = {};
				rDamageVariable.startindex = nDamageBegin;
				rDamageVariable.endindex = nDamageEnd;

				rDamageVariable.clauses = aVariableClauses;
			end
		end
	elseif StringManager.isWord(aWords[i+1], "equal") and
			StringManager.isWord(aWords[i+2], "to") then
		local nStart = nDamageBegin;
		local aDamageDice = {};
		local aAbilities = {};
		local nMult = 1;
		
		j = i + 2;
		while aWords[j+1] do
			if StringManager.isDiceString(aWords[j+1]) then
				table.insert(aDamageDice, aWords[j+1]);
				nMult = 1;
			elseif StringManager.isWord(aWords[j+1], "twice") then
				nMult = 2;
			elseif StringManager.isWord(aWords[j+1], "three") and
					StringManager.isWord(aWords[j+2], "times") then
				nMult = 3;
				j = j + 1;
			elseif StringManager.isWord(aWords[j+1], "four") and
					StringManager.isWord(aWords[j+2], "times") then
				nMult = 4;
				j = j + 1;
			elseif StringManager.isWord(aWords[j+1], "five") and
					StringManager.isWord(aWords[j+2], "times") then
				nMult = 5;
				j = j + 1;
			elseif StringManager.isWord(aWords[j+1], "your") and
					StringManager.isWord(aWords[j+2], "spellcasting") and
					StringManager.isWord(aWords[j+3], "ability") and
					StringManager.isWord(aWords[j+4], "modifier") then
				for n = 1, nMult do
					table.insert(aAbilities, "base");
				end
				nMult = 1;
				j = j + 3;
			elseif StringManager.isWord(aWords[j+1], "your") and
					StringManager.isWord(aWords[j+3], "modifier") and
					StringManager.isWord(aWords[j+2], DataCommon.abilities) then
				for n = 1, nMult do
					table.insert(aAbilities, aWords[j+2]);
				end
				nMult = 1;
				j = j + 2;
			elseif StringManager.isWord(aWords[j+1], "your") and
					StringManager.isWord(aWords[j+2], "level") then
				for n = 1, nMult do
					table.insert(aAbilities, "level");
				end
				nMult = 1;
				j = j + 1;
			elseif StringManager.isWord(aWords[j+1], "your") and
					StringManager.isWord(aWords[j+3], "level") and
					DataCommon.class_nametovalue[StringManager.capitalize(aWords[j+2])] then
				for n = 1, nMult do
					table.insert(aAbilities, DataCommon.class_nametovalue[StringManager.capitalize(aWords[j+2])]);
				end
				nMult = 1;
				j = j + 2;
			else
				break;
			end
			
			j = j + 1;
		end
		
		if (#aAbilities > 0) or (#aDamageDice > 0) then
			rDamageFixed = {};
			rDamageFixed.startindex = nStart;
			rDamageFixed.endindex = j;
			
			rDamageFixed.label = sPowerName;
			
			rDamageFixed.clauses = {};
			local rDmgClause = {};
			rDmgClause.dice, rDmgClause.modifier = StringManager.convertStringToDice(table.concat(aDamageDice, ""));
			if #aAbilities > 0 then
				rDmgClause.stat = aAbilities[1];
			end
			
			local aDmgType = {};
			if i ~= nStart then
				local k = nStart;
				while StringManager.isWord(aWords[k], DataCommon.dmgtypes) or
						(StringManager.isWord(aWords[k], "cold-forged") and StringManager.isWord(aWords[k+1], "iron")) do
					if StringManager.isWord(aWords[k], "cold-forged") and StringManager.isWord(aWords[k+1], "iron") then
						k = k + 1;
						table.insert(aDmgType, "cold-forged iron");
					else
						table.insert(aDmgType, aWords[k]);
					end
					k = k + 1;
				end
			end
			rDmgClause.dmgtype = table.concat(aDmgType, ",");
			
			table.insert(rDamageFixed.clauses, rDmgClause);
			
			for n = 2, #aAbilities do
				table.insert(rDamageFixed.clauses, { dice = {}, modifier = 0, stat = aAbilities[i], dmgtype = sDmgType });
			end
		end
	end
	
	if rDamageFixed then
		if i < rDamageFixed.endindex then
			i = rDamageFixed.endindex;
		end
	end

	if rDamageVariable then 
		return i, rDamageVariable;
	end
	return i, rDamageFixed;
end

function parseDamages(sPowerName, aWords, bMagic)
	local damages = {};

	local bMagicAttack = false;
	
  	local i = 1;
  	while aWords[i] do
		-- MAIN TRIGGER ("damage")
		if StringManager.isWord(aWords[i], "damage") then
			local rDamage;
			i, rDamage = parseDamagePhrase(aWords, i);
			if rDamage then
				if StringManager.isWord(aWords[i+1], "at") and 
						StringManager.isWord(aWords[i+2], "the") and
						StringManager.isWord(aWords[i+3], { "start", "end" }) and
						StringManager.isWord(aWords[i+4], "of") then
					rDamage = nil;
				elseif StringManager.isWord(aWords[rDamage.startindex - 1], "extra") then
					rDamage = nil;
				end
			end
			if rDamage then
				rDamage.label = sPowerName;
				if StringManager.isWord(aWords[1], "ranged") then
					rDamage.range = "R";
				elseif StringManager.isWord(aWords[1], "melee") then
					rDamage.range = "M";
				end
				
				table.insert(damages, rDamage);
			end
  		-- CAPTURE MAGIC DAMAGE MODIFIER
		elseif StringManager.isWord(aWords[i], "attack") and StringManager.isWord(aWords[i-1], "weapon") and 
				StringManager.isWord(aWords[i-2], "magic") and StringManager.isWord(aWords[i-3], "a") and 
				StringManager.isWord(aWords[i-4], "is") and StringManager.isWord(aWords[i-5], "this") then
			bMagicAttack = true;
		end
		
		i = i + 1;
	end	

	-- SET MAGIC DAMAGE IF PHYSICAL DAMAGE SPECIFIED AND GENERATED BY SPELL
	if bMagic then
		for _,rDamage in ipairs(damages) do
			for _, rClause in ipairs(rDamage.clauses) do
				if (rClause.dmgtype or "") ~= "" then
					local aDmgType = StringManager.split(rClause.dmgtype, ",", true);
					if StringManager.contains(aDmgType, "bludgeoning") or StringManager.contains(aDmgType, "piercing") or StringManager.contains(aDmgType, "slashing") then
						bMagicAttack = true;
						break;
					end
				end
			end
		end
	end
	
	-- HANDLE MAGIC DAMAGE MODIFIER
	if bMagicAttack then
		for _,rDamage in ipairs(damages) do
			for _, rClause in ipairs(rDamage.clauses) do
				if not rClause.dmgtype or rClause.dmgtype == "" then
					rClause.dmgtype = "magic";
				else
					rClause.dmgtype = rClause.dmgtype .. ",magic";
				end
			end
		end
	end
	
	-- RESULTS
	return damages;
end

-- [-] regains additional hit points equal to 2 + spell's level.
-- [-] regains at least 1 hit point
-- [-] regains the maximum number of hit points possible from any healing.

-- regains <dice>+ hit points.
-- regains a number of hit points equal to <dice> + your spellcasting ability modifier.
-- regains hit points equal to <dice> + your spellcasting ability modifier.
-- regains hit points equal to <dice> + your spellcasting ability modifier.
-- regains 1 hit point at the start of each of its turns

function parseHeals(sPowerName, aWords)
	local heals = {};
	
  	-- Iterate through the words looking for clauses
  	local i = 1;
  	while aWords[i] do
  		-- Check for hit point gains (temporary or normal)
  		if StringManager.isWord(aWords[i], {"points", "point"}) and StringManager.isWord(aWords[i-1], "hit") then
  			-- Track the healing information
			local rHeal = nil;
  			local sTemp = nil;
   			local aHealDice = {};

  			-- Iterate backwards to determine values
  			local j = i - 2;
  			if StringManager.isWord(aWords[j], "temporary") then
				sTemp = "temp";
				j = j - 1;
   			end
			if StringManager.isWord(aWords[j], "of") and
					StringManager.isWord(aWords[j-1], "number") and
					StringManager.isWord(aWords[j-2], "a") then
				j = j - 3;
			end
 			if StringManager.isWord(aWords[j], "of") and
					StringManager.isWord(aWords[j-1], "number") and
					StringManager.isWord(aWords[j-2], "total") and
					StringManager.isWord(aWords[j-3], "a") then
				j = j - 4;
			end
 			while aWords[j] do
  				if StringManager.isDiceString(aWords[j]) and aWords[j] ~= "0" then
  					table.insert(aHealDice, 1, aWords[j]);
				else
  					break;
  				end
  				
  				j = j - 1;
  			end
			
			-- Make sure we started with "gain(s)" or "regain(s)" or "restore"
			if StringManager.isWord(aWords[j], {"gain", "gains", "regain", "regains", "restore"}) and 
					not StringManager.isWord(aWords[j-1], {"cannot", "can't"}) then
				-- Determine self-targeting
				local bSelf = false;
				if aWords[j] ~= "restore" then
					local nSelfIndex = j;
					if StringManager.isWord(aWords[nSelfIndex-1], "to") and
							StringManager.isWord(aWords[nSelfIndex-2], "action") and
							StringManager.isWord(aWords[nSelfIndex-3], "bonus") and
							StringManager.isWord(aWords[nSelfIndex-4], "a") and
							StringManager.isWord(aWords[nSelfIndex-5], "use") then
						nSelfIndex = nSelfIndex - 5;
					end
 					if StringManager.isWord(aWords[nSelfIndex-1], "can") then
						nSelfIndex = nSelfIndex - 1;
					end
					if StringManager.isWord(aWords[nSelfIndex-1], "you") then
						bSelf = true;
					end
				end
				
				-- Figure out if the values in the text support a heal roll
				if (#aHealDice > 0) then
					local rHealFixedClause = {};
					local rHealVariableClause = {};
					
					local bHasVariableClause = false;
					if #aHealDice > 1 and StringManager.isNumberString(aHealDice[1]) then
						bHasVariableClause = true;

						rHealFixedClause.dice, rHealFixedClause.modifier = StringManager.convertStringToDice(aHealDice[1]);

						rHealVariableClause.dice, rHealVariableClause.modifier = StringManager.convertStringToDice(table.concat(aHealDice, "", 2));
					else
						rHealFixedClause.dice, rHealFixedClause.modifier = StringManager.convertStringToDice(table.concat(aHealDice));
						
						rHealVariableClause.dice, rHealVariableClause.modifier = StringManager.convertStringToDice(table.concat(aHealDice));
					end
					
					rHeal = {};
					rHeal.startindex = j;
					rHeal.endindex = i;
					
					rHeal.label = sPowerName;
					if sTemp then
						rHeal.subtype = "temp";
					end
					if bSelf then
						rHeal.sTargeting = "self";
					end
					
					rHeal.clauses = {};
					if bHasVariableClause then 
						table.insert(rHeal.clauses, rHealVariableClause);
					else
						table.insert(rHeal.clauses, rHealFixedClause);
					end
				
				elseif StringManager.isWord(aWords[i+1], "equal") and
						StringManager.isWord(aWords[i+2], "to") then
					local nStart = j;
					local aAbilities = {};
					local nMult = 1;
					
					j = i + 2;
					while aWords[j+1] do
						if StringManager.isDiceString(aWords[j+1]) then
							table.insert(aHealDice, aWords[j+1]);
							nMult = 1;
						elseif StringManager.isWord(aWords[j+1], "twice") then
							nMult = 2;
						elseif StringManager.isWord(aWords[j+1], "three") and
								StringManager.isWord(aWords[j+2], "times") then
							nMult = 3;
							j = j + 1;
						elseif StringManager.isWord(aWords[j+1], "four") and
								StringManager.isWord(aWords[j+2], "times") then
							nMult = 4;
							j = j + 1;
						elseif StringManager.isWord(aWords[j+1], "five") and
								StringManager.isWord(aWords[j+2], "times") then
							nMult = 5;
							j = j + 1;
						elseif StringManager.isWord(aWords[j+1], "your") and
								StringManager.isWord(aWords[j+2], "spellcasting") and
								StringManager.isWord(aWords[j+3], "ability") and
								StringManager.isWord(aWords[j+4], "modifier") then
							for i = 1, nMult do
								table.insert(aAbilities, "base");
							end
							nMult = 1;
							j = j + 3;
						elseif StringManager.isWord(aWords[j+1], "your") and
								StringManager.isWord(aWords[j+3], "modifier") and
								StringManager.isWord(aWords[j+2], DataCommon.abilities) then
							for i = 1, nMult do
								table.insert(aAbilities, aWords[j+2]);
							end
							nMult = 1;
							j = j + 2;
						elseif StringManager.isWord(aWords[j+1], "your") and
								StringManager.isWord(aWords[j+2], "level") then
							for i = 1, nMult do
								table.insert(aAbilities, "level");
							end
							nMult = 1;
							j = j + 1;
						elseif StringManager.isWord(aWords[j+1], "your") and
								StringManager.isWord(aWords[j+3], "level") and
								DataCommon.class_nametovalue[StringManager.capitalize(aWords[j+2])] then
							-- One off - Lay on Hands
							local bAddOne = false;
							if StringManager.isWord(aWords[j+4], "x5") then
								bAddOne = true;
								nMult = 5;
							end
							for i = 1, nMult do
								table.insert(aAbilities, DataCommon.class_nametovalue[StringManager.capitalize(aWords[j+2])]);
							end
							nMult = 1;
							j = j + 2;
							if bAddOne then
								j = j + 1;
							end
						else
							break;
						end
						
						j = j + 1;
					end
					
					if (#aAbilities > 0) or (#aHealDice > 0) then
						rHeal = {};
						rHeal.startindex = nStart;
						rHeal.endindex = j;
						
						rHeal.label = sPowerName;
						if sTemp then
							rHeal.subtype = "temp";
						end
						if bSelf then
							rHeal.sTargeting = "self";
						end
						
						rHeal.clauses = {};
						local rHealClause = {};
						rHealClause.dice, rHealClause.modifier = StringManager.convertStringToDice(table.concat(aHealDice, ""));
						if #aAbilities > 0 then
							rHealClause.stat = aAbilities[1];
						end
						table.insert(rHeal.clauses, rHealClause);
						
						for i = 2, #aAbilities do
							table.insert(rHeal.clauses, { dice = {}, modifier = 0, stat = aAbilities[i] });
						end
					end
				end
			end
   		
			if rHeal then
				table.insert(heals, rHeal);
			end
		end
		
		-- Increment our counter
		i = i + 1;
	end	

	return heals;
end

function parseSaves(sPowerName, aWords, bPC, bMagic)
	local saves = {};
	
	for i = 1, #aWords do
		if StringManager.isWord(aWords[i], "magically") then
			bMagic = true;
		elseif StringManager.isWord(aWords[i], "throw") and
				StringManager.isWord(aWords[i-1], "saving") and
				StringManager.isWord(aWords[i-2], DataCommon.abilities) then
			local bValid = false;
			local nStart = i - 2;
			local nDC = nil;
			if StringManager.isWord(aWords[nStart - 1], { "a", "an" }) then
				nStart = nStart - 1;
				if StringManager.isWord(aWords[nStart - 1], "fails") then
					bValid = true;
					nStart = nStart - 1;
				elseif StringManager.isWord(aWords[nStart - 1], "make") and
						StringManager.isWord(aWords[nStart - 2], {"must", "to"}) then
					bValid = true;
					nStart = nStart - 2;
				elseif StringManager.isWord(aWords[nStart - 1], "on") and
						StringManager.isWord(aWords[nStart - 2], "succeed") and
						StringManager.isWord(aWords[nStart - 3], "must") then
					bValid = true;
					nStart = nStart - 3;
				end
				
			elseif StringManager.isNumberString(aWords[i-3]) and 
					StringManager.isWord(aWords[i-4], "dc") then
				bValid = true;
				nStart = i - 4;
				nDC = tonumber(aWords[i-3]) or 0;
			end
			
			if bValid then
				local sSave = aWords[i-2];
				if StringManager.isWord(aWords[i+1], "against") and 
						StringManager.isWord(aWords[i+2], "this") and
						StringManager.isWord(aWords[i+3], "magic") then
					i = i + 3;
					bMagic = true;
				end
				
				local rSave = {};
				rSave.startindex = nStart;
				rSave.endindex = i;
				rSave.label = sPowerName;
				rSave.save = sSave;
				if nDC then
					rSave.savemod = nDC;
				else
					-- Handle special saving throws in traits (Antimagic Susceptibility)
					if StringManager.isWord(aWords[i+1], "against") and StringManager.isWord(aWords[i+2], "the") and
							StringManager.isWord(aWords[i+3], "caster's") and StringManager.isWord(aWords[i+4], "spell") and
							StringManager.isWord(aWords[i+5], "save") and StringManager.isWord(aWords[i+6], "DC") then
						rSave.savemod = 0;
					else
						rSave.savebase = "group";
					end
				end

				table.insert(saves, rSave);
				
				-- Only pick up first save for PC powers
				if bPC then
					break;
				end
			end
		elseif StringManager.isWord(aWords[i], "throws") and
				StringManager.isWord(aWords[i-1], "saving") and
				StringManager.isWord(aWords[i-2], DataCommon.abilities) and
				StringManager.isWord(aWords[i-3], "make") and
				StringManager.isWord(aWords[i-4], "must") then
			local rSave = {};
			rSave.startindex = i-4;
			rSave.endindex = i;
			rSave.label = sPowerName;
			rSave.save = aWords[i-2];
			rSave.savebase = "group";

			table.insert(saves, rSave);
			
			-- Only pick up first save for PC powers
			if bPC then
				break;
			end
		elseif StringManager.isWord(aWords[i], "throw") and
				StringManager.isWord(aWords[i-1], "saving") and
				StringManager.isWord(aWords[i-2], "this") and
				StringManager.isWord(aWords[i-3], "for") and
				StringManager.isWord(aWords[i-4], "dc") and
				StringManager.isWord(aWords[i+1], "equals") and
				StringManager.isWord(aWords[i+2], "8") and
				StringManager.isWord(aWords[i+3], "+") and
				StringManager.isWord(aWords[i+4], "your") and
				StringManager.isWord(aWords[i+5], DataCommon.abilities) and
				StringManager.isWord(aWords[i+6], "modifier") and
				StringManager.isWord(aWords[i+7], "+") and
				StringManager.isWord(aWords[i+8], "your") and
				StringManager.isWord(aWords[i+9], "proficiency") and
				StringManager.isWord(aWords[i+10], "bonus") then
			
			rSave = {};
			rSave.startindex = i-4;
			rSave.endindex = i+10;
			rSave.label = sPowerName;
			rSave.save = "base";
			rSave.savestat = aWords[i+5];
			rSave.saveprof = 1;
		
			table.insert(saves, rSave);
			
			-- Only pick up first save for PC powers
			if bPC then
				break;
			end
		end
	end
	
	for i = 1,#saves do
		if bMagic then
			saves[i].magic = true;
		end
		local nHalfCheckStart = saves[i].startindex;
		local nHalfCheckEnd = #aWords;
		if i < #saves then
			nHalfCheckEnd = saves[i+1].startindex - 1;
		end
		for j = nHalfCheckStart,nHalfCheckEnd do
			if StringManager.isWord(aWords[j], "half") then
				if StringManager.isWord(aWords[j+1], "as") and
						StringManager.isWord(aWords[j+2], "much") and
						StringManager.isWord(aWords[j+3], "damage") then
					saves[i].onmissdamage = "half";
				else
					local k = j;
					if StringManager.isWord(aWords[k-1], "only") then
						k = k - 1;
					end
					if StringManager.isWord(aWords[k-1], "takes") and
							StringManager.isWord(aWords[k-2], {"creature", "target"}) then
						-- Exception: Air Elemental - Whirlwind
						if sPowerName:match("^Whirlwind") then
							saves[1].onmissdamage = "half";
						else
							saves[i].onmissdamage = "half";
						end
					end
				end
			end
			
		end
	end
	
	return saves;
end

function parseEffectsAdd(aWords, i, rEffect, effects)
	local nDurIndex = rEffect.endindex + 1;
	if StringManager.isWord(aWords[nDurIndex], "by") 
			and StringManager.isWord(aWords[nDurIndex + 1], "the") then
		nDurIndex = nDurIndex + 3;
	end
	
	-- Handle expiration phrases
	if StringManager.isWord(aWords[nDurIndex], "for") 
			and StringManager.isNumberString(aWords[nDurIndex + 1]) 
			and StringManager.isWord(aWords[nDurIndex + 2], {"round", "rounds", "minute", "minutes", "hour", "hours", "day", "days"}) then
		rEffect.nDuration = tonumber(aWords[nDurIndex + 1]) or 0;
		if StringManager.isWord(aWords[nDurIndex + 2], {"minute", "minutes"}) then
			rEffect.sUnits = "minute";
		elseif StringManager.isWord(aWords[nDurIndex + 2], {"hour", "hours"}) then
			rEffect.sUnits = "hour";
		elseif StringManager.isWord(aWords[nDurIndex + 2], {"day", "days"}) then
			rEffect.sUnits = "day";
		end
		rEffect.endindex = nDurIndex + 2;
		
	elseif StringManager.isWord(aWords[nDurIndex], { "until", "at" })
			and StringManager.isWord(aWords[nDurIndex + 1], "the")
			and StringManager.isWord(aWords[nDurIndex + 2], { "start", "end" })
			and StringManager.isWord(aWords[nDurIndex + 3], "of")
			and StringManager.isWord(aWords[nDurIndex + 4], "its")
			and StringManager.isWord(aWords[nDurIndex + 5], "next")
			and StringManager.isWord(aWords[nDurIndex + 6], "turn") then
		rEffect.nDuration = 1;
		rEffect.endindex = nDurIndex + 6;

	elseif StringManager.isWord(aWords[nDurIndex], { "until", "at" })
			and StringManager.isWord(aWords[nDurIndex + 1], "the")
			and StringManager.isWord(aWords[nDurIndex + 2], { "start", "end" })
			and StringManager.isWord(aWords[nDurIndex + 3], "of")
			and StringManager.isWord(aWords[nDurIndex + 4], "the")
			and StringManager.isWord(aWords[nDurIndex + 6], "next")
			and StringManager.isWord(aWords[nDurIndex + 7], "turn") then
		rEffect.nDuration = 1;
		rEffect.endindex = nDurIndex + 7;

	elseif StringManager.isWord(aWords[nDurIndex], "until")
			and StringManager.isWord(aWords[nDurIndex + 1], "its")
			and StringManager.isWord(aWords[nDurIndex + 2], "next")
			and StringManager.isWord(aWords[nDurIndex + 3], "turn") then
		rEffect.nDuration = 1;
		rEffect.endindex = nDurIndex + 3;

	elseif StringManager.isWord(aWords[nDurIndex], "until")
			and StringManager.isWord(aWords[nDurIndex + 1], "the")
			and StringManager.isWord(aWords[nDurIndex + 3], "next")
			and StringManager.isWord(aWords[nDurIndex + 4], "turn") then
		rEffect.nDuration = 1;
		rEffect.endindex = nDurIndex + 4;
	elseif StringManager.isWord(aWords[nDurIndex], "while")
			and StringManager.isWord(aWords[nDurIndex + 1], "poisoned") then
		if #effects > 0 and rEffect.sName == "Unconscious" and effects[#effects].sName == "Poisoned" then
			local rComboEffect = effects[#effects];
			rComboEffect.sName = rComboEffect.sName .. "; " .. rEffect.sName;
			rComboEffect.endindex = rEffect.endindex;
			return;
		end
	end

	-- Add or combine effect
	if #effects > 0 and effects[#effects].endindex + 1 == rEffect.startindex and not effects[#effects].nDuration then
		local rComboEffect = effects[#effects];
		rComboEffect.sName = rComboEffect.sName .. "; " .. rEffect.sName;
		rComboEffect.endindex = rEffect.endindex;
		rComboEffect.nDuration = rEffect.nDuration;
		rComboEffect.sUnits = rEffect.sUnits;
	else
		table.insert(effects, rEffect);
	end
end

function parseEffects(sPowerName, aWords)
	local effects = {};
	
	local rCurrent = nil;
	
	local i = 1;
	while aWords[i] do
		if StringManager.isWord(aWords[i], "damage") then
			i, rCurrent = parseDamagePhrase(aWords, i);
			if rCurrent then
				if StringManager.isWord(aWords[i+1], "at") and 
						StringManager.isWord(aWords[i+2], "the") and
						StringManager.isWord(aWords[i+3], { "start", "end" }) and
						StringManager.isWord(aWords[i+4], "of") then
					
					local nTrigger = i + 4;
					if StringManager.isWord(aWords[nTrigger+1], "each") and
							StringManager.isWord(aWords[nTrigger+2], "of") then
						if StringManager.isWord(aWords[nTrigger+3], "its") then
							nTrigger = nTrigger + 3;
						else
							nTrigger = nTrigger + 4;
						end
					elseif StringManager.isWord(aWords[nTrigger+1], "its") then
						nTrigger = i;
					elseif StringManager.isWord(aWords[nTrigger+1], "your") then
						nTrigger = nTrigger + 1;
					end
					if StringManager.isWord(aWords[nTrigger+1], { "turn", "turns" }) then
						nTrigger = nTrigger + 1;
					end
					rCurrent.endindex = nTrigger;
					
					if StringManager.isWord(aWords[rCurrent.startindex - 1], "takes") and
							StringManager.isWord(aWords[rCurrent.startindex - 2], "and") and
							StringManager.isWord(aWords[rCurrent.startindex - 3], DataCommon.conditions) then
						rCurrent.startindex = rCurrent.startindex - 2;
					end
					
					local aName = {};
					for _,v in ipairs(rCurrent.clauses) do
						local sDmg = StringManager.convertDiceToString(v.dice, v.modifier);
						if v.dmgtype and v.dmgtype ~= "" then
							sDmg = sDmg .. " " .. v.dmgtype;
						end
						table.insert(aName, "DMGO: " .. sDmg);
					end
					rCurrent.clauses = nil;
					rCurrent.sName = table.concat(aName, "; ");
				elseif StringManager.isWord(aWords[rCurrent.startindex - 1], "extra") then
					rCurrent.startindex = rCurrent.startindex - 1;
					rCurrent.sTargeting = "self";
					rCurrent.sApply = "roll";
					
					local aName = {};
					for _,v in ipairs(rCurrent.clauses) do
						local sDmg = StringManager.convertDiceToString(v.dice, v.modifier);
						if v.dmgtype and v.dmgtype ~= "" then
							sDmg = sDmg .. " " .. v.dmgtype;
						end
						table.insert(aName, "DMG: " .. sDmg);
					end
					rCurrent.clauses = nil;
					rCurrent.sName = table.concat(aName, "; ");
				else
					rCurrent = nil;
				end
			end

		elseif (i > 1) and StringManager.isWord(aWords[i], DataCommon.conditions) then
			local bValidCondition = false;
			local nConditionStart = i;
			local j = i - 1;
			
			while aWords[j] do
				if StringManager.isWord(aWords[j], "be") then
					if StringManager.isWord(aWords[j-1], "or") then
						bValidCondition = true;
						nConditionStart = j;
						break;
					end
				
				elseif StringManager.isWord(aWords[j], "being") and
						StringManager.isWord(aWords[j-1], "against") then
					bValidCondition = true;
					nConditionStart = j;
					break;
				
				elseif StringManager.isWord(aWords[j], { "also", "magically" }) then
				
				-- Special handling: Blindness/Deafness
				elseif StringManager.isWord(aWords[j], "or") and StringManager.isWord(aWords[j-1], DataCommon.conditions) and 
						StringManager.isWord(aWords[j-2], "either") and StringManager.isWord(aWords[j-3], "is") then
					bValidCondition = true;
					break;
					
				elseif StringManager.isWord(aWords[j], { "while", "when", "cannot", "not", "if", "be", "or" }) then
					bValidCondition = false;
					break;
				
				elseif StringManager.isWord(aWords[j], { "target", "creature", "it" }) then
					if StringManager.isWord(aWords[j-1], "the") then
						j = j - 1;
					end
					nConditionStart = j;
					
				elseif StringManager.isWord(aWords[j], "and") then
					if #effects == 0 then
						break;
					elseif effects[#effects].endindex ~= j - 1 then
						if not StringManager.isWord(aWords[i], "unconscious") and not StringManager.isWord(aWords[j-1], "minutes") then
							break;
						end
					end
					bValidCondition = true;
					nConditionStart = j;
					
				elseif StringManager.isWord(aWords[j], "is") then
					if bValidCondition or StringManager.isWord(aWords[i], "prone") or
							(StringManager.isWord(aWords[i], "invisible") and StringManager.isWord(aWords[j-1], {"wearing", "wears", "carrying", "carries"})) then
						break;
					end
					bValidCondition = true;
					nConditionStart = j;
				
				elseif StringManager.isWord(aWords[j], DataCommon.conditions) then
					break;

				elseif StringManager.isWord(aWords[i], "poisoned") then
					if (StringManager.isWord(aWords[j], "instead") and StringManager.isWord(aWords[j-1], "is")) then
						bValidCondition = true;
						nConditionStart = j - 1;
						break;
					elseif StringManager.isWord(aWords[j], "become") then
						bValidCondition = true;
						nConditionStart = j;
						break;
					end
				
				elseif StringManager.isWord(aWords[j], {"knock", "knocks", "knocked", "fall", "falls"}) and StringManager.isWord(aWords[i], "prone")  then
					bValidCondition = true;
					nConditionStart = j;
					
				elseif StringManager.isWord(aWords[j], {"knock", "knocks", "fall", "falls", "falling", "remain", "is"}) and StringManager.isWord(aWords[i], "unconscious") then
					if StringManager.isWord(aWords[j], "falling") and StringManager.isWord(aWords[j-1], "of") and StringManager.isWord(aWords[j-2], "instead") then
						break;
					end
					if StringManager.isWord(aWords[j], "fall") and StringManager.isWord(aWords[j-1], "you") and StringManager.isWord(aWords[j-1], "if") then
						break;
					end
					if StringManager.isWord(aWords[j], "falls") and StringManager.isWord(aWords[j-1], "or") then
						break;
					end
					bValidCondition = true;
					nConditionStart = j;
					if StringManager.isWord(aWords[j], "fall") and StringManager.isWord(aWords[j-1], "or") then
						break;
					end
					
				elseif StringManager.isWord(aWords[j], {"become", "becomes"}) and StringManager.isWord(aWords[i], "frightened")  then
					bValidCondition = true;
					nConditionStart = j;
					break;
					
				elseif StringManager.isWord(aWords[j], {"turns", "become", "becomes"}) 
						and StringManager.isWord(aWords[i], {"invisible"}) then
					if StringManager.isWord(aWords[j-1], {"can't", "cannot"}) then
						break;
					end
					bValidCondition = true;
					nConditionStart = j;
				
				-- Special handling: Blindness/Deafness
				elseif StringManager.isWord(aWords[j], "either") and StringManager.isWord(aWords[j-1], "is") then
					bValidCondition = true;
					break;
				
				else
					break;
				end

				j = j - 1;
			end
			
			if bValidCondition then
				rCurrent = {};
				rCurrent.sName = StringManager.capitalize(aWords[i]);
				rCurrent.startindex = nConditionStart;
				rCurrent.endindex = i;
			end
		end
		
		if rCurrent then
			parseEffectsAdd(aWords, i, rCurrent, effects);
			rCurrent = nil;
		end
		
		i = i + 1;
	end

	if rCurrent then
		parseEffectsAdd(aWords, i - 1, rCurrent, effects);
	end
	
	-- Handle duration field in NPC spell translations
	i = 1;
	while aWords[i] do
		if StringManager.isWord(aWords[i], "duration") and StringManager.isWord(aWords[i+1], ":") then
			j = i + 2;
			local bConc = false;
			if StringManager.isWord(aWords[j], "concentration") and StringManager.isWord(aWords[j+1], "up") and StringManager.isWord(aWords[j+2], "to") then
				bConc = true;
				j = j + 3;
			end
			if StringManager.isNumberString(aWords[j]) and StringManager.isWord(aWords[j+1], {"round", "rounds", "minute", "minutes", "hour", "hours", "day", "days"}) then
				local nDuration = tonumber(aWords[j]) or 0;
				local sUnits = "";
				if StringManager.isWord(aWords[j+1], {"minute", "minutes"}) then
					sUnits = "minute";
				elseif StringManager.isWord(aWords[j+1], {"hour", "hours"}) then
					sUnits = "hour";
				elseif StringManager.isWord(aWords[j+1], {"day", "days"}) then
					sUnits = "day";
				end

				for _,vEffect in ipairs(effects) do
					if not vEffect.nDuration and (vEffect.sName ~= "Prone") then
						if bConc then
							vEffect.sName = vEffect.sName .. "; (C)";
						end
						vEffect.nDuration = nDuration;
						vEffect.sUnits = sUnits;
					end
				end

				-- Add direct effect right from concentration text
				if bConc then
					local rConcentrate = {};
					rConcentrate.sName = sPowerName .. "; (C)";
					rConcentrate.startindex = i;
					rConcentrate.endindex = j+1;

					parseEffectsAdd(aWords, i, rConcentrate, effects);
				end
			end
		end
		i = i + 1;
	end
	
	return effects;
end

function parseHelper(s, words, words_stats)
  	local final_words = {};
  	local final_words_stats = {};
  	
  	-- Separate words ending in periods, colons and semicolons
  	for i = 1, #words do
		local nSpecialChar = string.find(words[i], "[%.:;\n]");
		if nSpecialChar then
			local sWord = words[i];
			local nStartPos = words_stats[i].startpos;
			while nSpecialChar do
				if nSpecialChar > 1 then
					table.insert(final_words, string.sub(sWord, 1, nSpecialChar - 1));
					table.insert(final_words_stats, {startpos = nStartPos, endpos = nStartPos + nSpecialChar - 1});
				end
				
				table.insert(final_words, string.sub(sWord, nSpecialChar, nSpecialChar));
				table.insert(final_words_stats, {startpos = nStartPos + nSpecialChar - 1, endpos = nStartPos + nSpecialChar});
				
				nStartPos = nStartPos + nSpecialChar;
				sWord = string.sub(sWord, nSpecialChar + 1);
				
				nSpecialChar = string.find(sWord, "[%.:;\n]");
			end
			if string.len(sWord) > 0 then
				table.insert(final_words, sWord);
				table.insert(final_words_stats, {startpos = nStartPos, endpos = words_stats[i].endpos});
			end
		else
			table.insert(final_words, words[i]);
			table.insert(final_words_stats, words_stats[i]);
		end
  	end
  	
	return final_words, final_words_stats;
end

function consolidationHelper(aMasterAbilities, aWordStats, sAbilityType, aNewAbilities)
	-- Iterate through new abilities
	for i = 1, #aNewAbilities do

		-- Add type
		aNewAbilities[i].type = sAbilityType;

		-- Convert word indices to character positions
		aNewAbilities[i].startpos = aWordStats[aNewAbilities[i].startindex].startpos;
		aNewAbilities[i].endpos = aWordStats[aNewAbilities[i].endindex].endpos;
		aNewAbilities[i].startindex = nil;
		aNewAbilities[i].endindex = nil;

		-- Add to master abilities list
		table.insert(aMasterAbilities, aNewAbilities[i]);
	end
end

function parsePower(sPowerName, sPowerDesc, bPC, bMagic)
	-- Get rid of some problem characters, and make lowercase
	local sLocal = sPowerDesc:gsub("’", "'");
	sLocal = sLocal:gsub("–", "-");
	sLocal = sLocal:lower();
	
	-- Parse the words
	local aWords, aWordStats = StringManager.parseWords(sLocal, ".:;\n");
	
	-- Add/separate markers for end of sentence, end of clause and clause label separators
	aWords, aWordStats = parseHelper(sPowerDesc, aWords, aWordStats);
	
	-- Build master list of all power abilities
	local aMasterAbilities = {};
	consolidationHelper(aMasterAbilities, aWordStats, "attack", parseAttacks(sPowerName, aWords));
	consolidationHelper(aMasterAbilities, aWordStats, "damage", parseDamages(sPowerName, aWords, bMagic));
	consolidationHelper(aMasterAbilities, aWordStats, "heal", parseHeals(sPowerName, aWords));
	consolidationHelper(aMasterAbilities, aWordStats, "powersave", parseSaves(sPowerName, aWords, bPC, bMagic));
	consolidationHelper(aMasterAbilities, aWordStats, "effect", parseEffects(sPowerName, aWords));
	
	-- Sort the abilities
	table.sort(aMasterAbilities, function(a,b) return a.startpos < b.startpos end)
	
	return aMasterAbilities;
end

function parseNPCPower(nodePower, bAllowSpellDataOverride)
	local sPowerName = DB.getValue(nodePower, "name", "");
	local sPowerDesc = DB.getValue(nodePower, "desc", "");
	
	if bAllowSpellDataOverride then
		local sPowerNameLower = StringManager.trim(sPowerName:lower());
		if sPowerNameLower:match(" - ") then
			sPowerNameLower = sPowerNameLower:gsub(" %- .*$", "");
		end
		local sSansSuffix = sPowerNameLower:match("^(.*) %([^)]+%)$");
		if sSansSuffix then
			sPowerNameLower = sSansSuffix;
		end
		if DataSpell.parsedata[sPowerNameLower] then
			return UtilityManager.copyDeep(DataSpell.parsedata[sPowerNameLower]);
		end
	end
	
	local bMagic = false;
	if nodePower then
		if StringManager.contains({"spells", "innatespells"}, nodePower.getParent().getName()) then
			bMagic = true;
		else
			-- Add exception for beholder type creatures, since Eye Rays are broken out into individual powers and are all magical
			local nodePowerList = nodePower.getParent();
			for _,v in pairs(DB.getChildren(nodePower, "..")) do
				local s = StringManager.trim(DB.getValue(v, "name", "")):lower();
				if StringManager.contains({ "eye ray", "eye rays" }, s) then
					bMagic = true;
				end
			end
		end
	end
	
	local aActions = parsePower(sPowerName, sPowerDesc, false, bMagic);
	
	if nodePower then
		-- Make sure correct duration and concentration applied to NPC spell effects
		if StringManager.contains({"spells", "innatespells"}, nodePower.getParent().getName()) then
			local sPowerDesc = DB.getValue(nodePower, "desc", ""):lower();
			local sDuration, sTempUnits = sPowerDesc:match("duration: concentration, up to (%d+) (%w+)");
			if sDuration and sTempUnits then
				local nDuration = tonumber(sDuration) or 0;
				if nDuration > 0 then
					local sDurationUnits = "";
					if StringManager.isWord(sTempUnits, {"minute", "minutes"}) then
						sDurationUnits = "minute";
					elseif StringManager.isWord(sTempUnits, {"hour", "hours"}) then
						sDurationUnits = "hour";
					elseif StringManager.isWord(sTempUnits, {"day", "days"}) then
						sDurationUnits = "day";
					end
					
					for _,v in ipairs(aActions) do
						if v.type == "effect" then
							if ((v.nDuration or 0) == 0) and (nDuration ~= 0) and (v.sName ~= "Prone") then
								if bConcentration then
									v.sName = v.sName .. "; (C)";
								end
								v.nDuration = nDuration;
								v.sUnits = sDurationUnits;
							end
						end
					end
				end
			end
		end
	end
	return aActions;
end

function parsePCPower(nodePower)
	-- CLean out old actions
	local nodeActions = nodePower.createChild("actions");
	for _,v in pairs(nodeActions.getChildren()) do
		v.delete();
	end
	
	-- Track whether cast action already created
	local nodeCastAction = nil;
	
	-- Get the power name
	local sPowerName = DB.getValue(nodePower, "name", "");
	local sPowerNameLower = StringManager.trim(sPowerName:lower());
	
	-- Pull the actions from the spell data table (if available)
	if DataSpell.parsedata[sPowerNameLower] then
		for _,vAction in ipairs(DataSpell.parsedata[sPowerNameLower]) do
			if vAction.type then
				if vAction.type == "attack" then
					if not nodeCastAction then
						nodeCastAction = DB.createChild(nodeActions);
						DB.setValue(nodeCastAction, "type", "string", "cast");
					end
					if nodeCastAction then
						if vAction.range == "R" then
							DB.setValue(nodeCastAction, "atktype", "string", "ranged");
						else
							DB.setValue(nodeCastAction, "atktype", "string", "melee");
						end
						
						if vAction.modifier then
							DB.setValue(nodeCastAction, "atkbase", "string", "fixed");
							DB.setValue(nodeCastAction, "atkmod", "number", tonumber(vAction.modifier) or 0);
						end
					end
				
				elseif vAction.type == "damage" then
					local nodeAction = DB.createChild(nodeActions);
					DB.setValue(nodeAction, "type", "string", "damage");
					
					local nodeDmgList = DB.createChild(nodeAction, "damagelist");
					for _,vDamage in ipairs(vAction.clauses) do
						local nodeEntry = DB.createChild(nodeDmgList);
						
						DB.setValue(nodeEntry, "dice", "dice", vDamage.dice);
						DB.setValue(nodeEntry, "bonus", "number", vDamage.bonus);
						if vDamage.stat then
							DB.setValue(nodeEntry, "stat", "string", vDamage.stat);
						end
						if vDamage.statmult then
							DB.setValue(nodeEntry, "statmult", "number", vDamage.statmult);
						end
						DB.setValue(nodeEntry, "type", "string", vDamage.dmgtype);
					end
				
				elseif vAction.type == "heal" then
					local nodeAction = DB.createChild(nodeActions);
					DB.setValue(nodeAction, "type", "string", "heal");
						
					if vAction.subtype == "temp" then
						DB.setValue(nodeAction, "healtype", "string", "temp");
					end
					if vAction.sTargeting then
						DB.setValue(nodeAction, "healtargeting", "string", vAction.sTargeting);
					end
					
					local nodeHealList = DB.createChild(nodeAction, "heallist");
					for _,vHeal in ipairs(vAction.clauses) do
						local nodeEntry = DB.createChild(nodeHealList);
						
						DB.setValue(nodeEntry, "dice", "dice", vHeal.dice);
						DB.setValue(nodeEntry, "bonus", "number", vHeal.bonus);
						if vHeal.stat then
							DB.setValue(nodeEntry, "stat", "string", vHeal.stat);
						end
						if vHeal.statmult then
							DB.setValue(nodeEntry, "statmult", "number", vHeal.statmult);
						end
					end

				elseif vAction.type == "powersave" then
					if not nodeCastAction then
						nodeCastAction = DB.createChild(nodeActions);
						DB.setValue(nodeCastAction, "type", "string", "cast");
					end
					if nodeCastAction then
						DB.setValue(nodeCastAction, "savetype", "string", vAction.save);
						DB.setValue(nodeCastAction, "savemagic", "number", 1);
						
						if vAction.savemod then
							DB.setValue(nodeCastAction, "savedcbase", "string", "fixed");
							DB.setValue(nodeCastAction, "savedcmod", "number", tonumber(vAction.savemod) or 8);
						elseif vAction.savestat then
							if vAction.savestat ~= "base" then
								DB.setValue(nodeCastAction, "savedcbase", "string", "ability");
								DB.setValue(nodeCastAction, "savedcstat", "string", vAction.savestat);
							end
						end
						if vAction.onmissdamage == "half" then
							DB.setValue(nodeCastAction, "onmissdamage", "string", "half");
						end
					end
				
				elseif vAction.type == "effect" then
					local nodeAction = DB.createChild(nodeActions);
					DB.setValue(nodeAction, "type", "string", "effect");
					
					DB.setValue(nodeAction, "label", "string", vAction.sName);

					if vAction.sTargeting then
						DB.setValue(nodeAction, "targeting", "string", vAction.sTargeting);
					end
					if vAction.sApply then
						DB.setValue(nodeAction, "apply", "string", vAction.sApply);
					end
					
					local nDuration = tonumber(vAction.nDuration) or 0;
					if nDuration ~= 0 then
						DB.setValue(nodeAction, "durmod", "number", nDuration);
						DB.setValue(nodeAction, "durunit", "string", vAction.sUnits);
					end

				end
			end
		end
	-- Otherwise, parse the power description for actions
	else
		-- Get the power duration
		local nDuration = 0;
		local sDurationUnits = "";
		local bConcentration = false;
		local sPowerDuration = DB.getValue(nodePower, "duration", "");
		local aDurationWords = StringManager.parseWords(sPowerDuration:lower());
		
		local j = 1;
		if StringManager.isWord(aDurationWords[j], "concentration") and StringManager.isWord(aDurationWords[j+1], "up") and StringManager.isWord(aDurationWords[j+2], "to") then
			bConcentration = true;
			j = j + 3;
		end
		if StringManager.isNumberString(aDurationWords[j]) and StringManager.isWord(aDurationWords[j+1], {"round", "rounds", "minute", "minutes", "hour", "hours", "day", "days"}) then
			nDuration = tonumber(aDurationWords[j]) or 0;
			if StringManager.isWord(aDurationWords[j+1], {"minute", "minutes"}) then
				sDurationUnits = "minute";
			elseif StringManager.isWord(aDurationWords[j+1], {"hour", "hours"}) then
				sDurationUnits = "hour";
			elseif StringManager.isWord(aDurationWords[j+1], {"day", "days"}) then
				sDurationUnits = "day";
			end
		end

		-- Determine whether this power is a spell
		local bMagic = false;
		local sGroup = DB.getValue(nodePower, "group", "");
		local bFoundGroup = false;
		local nodeActor = nodePower.getChild("...");
		for _,v in pairs(DB.getChildren(nodeActor, "powergroup")) do
			if DB.getValue(v, "name", "") == sGroup then
				bFoundGroup = true;
				if DB.getValue(v, "castertype", "") == "memorization" then
					bMagic = true;
				end
				break;
			end
		end
		if not bFoundGroup then
			bMagic = (sGroup == Interface.getString("power_label_groupspells"));
		end
		
		-- Parse the description
		local sPowerDesc = DB.getValue(nodePower, "description", "");
		local aActions = parsePower(sPowerName, sPowerDesc, true, bMagic);
		
		-- Handle effect duration based on spell
		local bConcEffectFound = false;
		for _,v in ipairs(aActions) do
			if v.type == "effect" then
				if ((v.nDuration or 0) == 0) and (nDuration ~= 0) and (v.sName ~= "Prone") then
					if bConcentration then
						bConcEffectFound = true;
						v.sName = v.sName .. "; (C)";
					end
					v.nDuration = nDuration;
					v.sUnits = sDurationUnits;
				end
			end
		end
		if bConcentration and not bConcEffectFound then
			table.insert(aActions, { type = "effect", sName = sPowerName .. "; (C)", sTargeting="self", nDuration = nDuration, sUnits = sDurationUnits });
		end
		
		-- Translate parsed power records into entries in the PC Actions tab
		local bAttackFound = false;
		for _, v in ipairs(aActions) do
			if v.type == "attack" then
				if not bAttackFound then
					bAttackFound = true;
					if not nodeCastAction then
						nodeCastAction = DB.createChild(nodeActions);
						DB.setValue(nodeCastAction, "type", "string", "cast");
					end
					if nodeCastAction then
						if v.range == "R" then
							DB.setValue(nodeCastAction, "atktype", "string", "ranged");
						else
							DB.setValue(nodeCastAction, "atktype", "string", "melee");
						end
						
						if v.spell then
							-- Use group attack mod
						else
							DB.setValue(nodeCastAction, "atkbase", "string", "fixed");
							DB.setValue(nodeCastAction, "atkmod", "number", v.modifier);
						end
					end
				end
			
			elseif v.type == "damage" then
				local nodeAction = DB.createChild(nodeActions);
				DB.setValue(nodeAction, "type", "string", "damage");
				
				local nodeDmgList = DB.createChild(nodeAction, "damagelist");
				for _,vDamage in ipairs(v.clauses) do
					local nodeEntry = DB.createChild(nodeDmgList);
					
					DB.setValue(nodeEntry, "dice", "dice", vDamage.dice);
					DB.setValue(nodeEntry, "bonus", "number", vDamage.modifier);
					if vDamage.stat then
						DB.setValue(nodeEntry, "stat", "string", vDamage.stat);
					end
					if vDamage.statmult then
						DB.setValue(nodeEntry, "statmult", "number", vDamage.statmult);
					end
					DB.setValue(nodeEntry, "type", "string", vDamage.dmgtype);
				end

			elseif v.type == "heal" then
				local nodeAction = DB.createChild(nodeActions);
				DB.setValue(nodeAction, "type", "string", "heal");
					
				if v.subtype == "temp" then
					DB.setValue(nodeAction, "healtype", "string", "temp");
				end
				if v.sTargeting then
					DB.setValue(nodeAction, "healtargeting", "string", v.sTargeting);
				end
				
				local nodeHealList = DB.createChild(nodeAction, "heallist");
				for _,vHeal in ipairs(v.clauses) do
					local nodeEntry = DB.createChild(nodeHealList);
					
					DB.setValue(nodeEntry, "dice", "dice", vHeal.dice);
					DB.setValue(nodeEntry, "bonus", "number", vHeal.modifier);
					if vHeal.stat then
						DB.setValue(nodeEntry, "stat", "string", vHeal.stat);
					end
					if vHeal.statmult then
						DB.setValue(nodeEntry, "statmult", "number", vHeal.statmult);
					end
				end

			elseif v.type == "powersave" then
				if not nodeCastAction then
					nodeCastAction = DB.createChild(nodeActions);
					DB.setValue(nodeCastAction, "type", "string", "cast");
				end
				if nodeCastAction then
					DB.setValue(nodeCastAction, "savetype", "string", v.save);
					if v.magic then
						DB.setValue(nodeCastAction, "savemagic", "number", 1);
					end
					if v.savestat then
						if v.savestat ~= "base" then
							DB.setValue(nodeCastAction, "savedcbase", "string", "ability");
							DB.setValue(nodeCastAction, "savedcstat", "string", v.savestat);
						end
					elseif v.savemod then
						DB.setValue(nodeCastAction, "savedcbase", "string", "fixed");
						DB.setValue(nodeCastAction, "savedcmod", "number", v.savemod);
					end
					if v.onmissdamage == "half" then
						DB.setValue(nodeCastAction, "onmissdamage", "string", "half");
					end
				end
				
			elseif v.type == "effect" then
				local nodeAction = DB.createChild(nodeActions);
				if nodeAction then
					DB.setValue(nodeAction, "type", "string", "effect");
					
					DB.setValue(nodeAction, "label", "string", v.sName);
					if v.sTargeting then
						DB.setValue(nodeAction, "targeting", "string", v.sTargeting);
					end
					if v.sApply then
						DB.setValue(nodeAction, "apply", "string", v.sApply);
					end
					if (v.nDuration or 0) ~= 0 then
						DB.setValue(nodeAction, "durmod", "number", v.nDuration);
						DB.setValue(nodeAction, "durunit", "string", v.sUnits);
					end
				end
			end
		end
	end
end
