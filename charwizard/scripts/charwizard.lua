-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

--
-- Import Tracking
--

import = 0;
levelUpClass = "";
impspells = {};
impskills = {};

--
-- Library Records
--

loaded_races = {};
loaded_classes = {};
loaded_origins = {};
loaded_spells = {};
loaded_feats = {};
loaded_items = {};

--
-- Wizard Tracking
--

proficiencies_race = {};
proficiencies_class = {};
proficiencies_origin = {};

spellslots = {};
pactslots = {};
spelllist = {};
innatespells = {};
origins = {};

inventory = {};
gold = 0;

function onInit()
	tabs.activateTab(1);

	collectRaces();
	collectClasses();
	collectOrigins();
	collectSpells();
	collectFeats();
end

function collectRaces()
	local aPHBRace = {};
	local aRestRace = {};
	local aMappings = LibraryData.getMappings("race");

	for _,vMapping in ipairs(aMappings) do
		for _,vRace in pairs(DB.getChildrenGlobal(vMapping)) do
			local sModule = vRace.getModule();
			local sRace = DB.getValue(vRace, "name", ""):lower();

			if sRace == "" then
				sRace = Interface.getString("library_recordtype_empty_race");
			end

			sRace = StringManager.trim(sRace):lower();

			if sModule == "DD PHB Deluxe" then
				aPHBRace[sRace] = vRace;
			elseif sModule ~= "Van Riichten's Guide to Ravenloft - Players" then
				aRestRace[sRace] = vRace;
			end
		end
	end

	for k,v in pairs(aPHBRace) do
		local sModule = v.getModule();
		local sTooltip = "";

		if sModule == nil then
			sTooltip = StringManager.titleCase(k) .. ": Campaign";
		else
			sTooltip = StringManager.titleCase(k) .. ": " .. sModule;
		end

		loaded_races[k] = { tooltip = sTooltip, class = "reference_race", record = v.getPath() };
	end

	for k,v in pairs(aRestRace) do
		if not aPHBRace[k] then
			local sModule = v.getModule();
			local sTooltip = "";

			if sModule == nil then
				sTooltip = StringManager.titleCase(k) .. ": Campaign";
			else
				sTooltip = StringManager.titleCase(k) .. ": " .. sModule;
			end

			loaded_races[k] = { tooltip = sTooltip, class = "reference_race", record = v.getPath() };
		end
	end
end

function collectClasses()
	local aTashaClass = {};
	local aPHBClass = {};
	local aRestClass = {};
	local aMappings = LibraryData.getMappings("class");

	for _,vMapping in ipairs(aMappings) do
		-- If Tashas is loaded load those classes first, otherwise load the PHB classes first.
		for _,vClass in pairs(DB.getChildrenGlobal(vMapping)) do
			local sModule = vClass.getModule();
			local sClass = DB.getValue(vClass, "name", ""):lower();

			if sClass == "" then
				sClass = vClass.getName();
			end
			sClass = StringManager.trim(sClass):lower();

			if sModule == "DD Tashas Cauldron of Everything - Players" then
				aTashaClass[sClass] = vClass;
			elseif sModule == "DD PHB Deluxe" then
				aPHBClass[sClass] = vClass;
			else
				aRestClass[sClass] = vClass;
			end
		end
	end

	for k,v in pairs(aTashaClass) do
		local sModule = v.getModule();
		local sTooltip = "";

		if sModule == nil then
			sTooltip = StringManager.titleCase(k) .. ": Campaign";
		else
			sTooltip = StringManager.titleCase(k) .. ": " .. sModule;
		end

		loaded_classes[k] = { tooltip = sTooltip, class = "reference_class", record = v.getPath() };
	end

	for k,v in pairs(aPHBClass) do
		if not aTashaClass[k] then
			local sModule = v.getModule();
			local sTooltip = "";

			if sModule == nil then
				sTooltip = StringManager.titleCase(k) .. ": Campaign";
			else
				sTooltip = StringManager.titleCase(k) .. ": " .. sModule;
			end

			loaded_classes[k] = { tooltip = sTooltip, class = "reference_class", record = v.getPath() };
		end
	end

	for k,v in pairs(aRestClass) do
		if not aTashaClass[k] and not aPHBClass[k] then
			local sModule = v.getModule();
			local sTooltip = "";

			if sModule == nil then
				sTooltip = StringManager.titleCase(k) .. ": Campaign";
			else
				sTooltip = StringManager.titleCase(k) .. ": " .. sModule;
			end

			loaded_classes[k] = { tooltip = sTooltip, class = "reference_class", record = v.getPath() };
		end
	end

	return loaded_classes;
end

function collectOrigins()
	local aOrigins = {};

	local aMappings = LibraryData.getMappings("origin");
	for _,vMapping in ipairs(aMappings) do
		for _,vOrigin in pairs(DB.getChildrenGlobal(vMapping)) do
			local sModule = vOrigin.getModule();
			local sOrigin = DB.getValue(vOrigin, "name", ""):lower();

			if sOrigin == "" then
				sOrigin = vOrigin.getName();
			end
			aOrigins[sOrigin] = vOrigin;
		end
	end


	for k,v in pairs(aOrigins) do
		local sModule = v.getModule();
		local sTooltip = "";

		if sModule == nil then
			sTooltip = StringManager.titleCase(k) .. ": Campaign";
		else
			sTooltip = StringManager.titleCase(k) .. ": " .. sModule;
		end

		loaded_origins[k] = { tooltip = sTooltip, class = "reference_origin", record = v.getPath() };
	end
end

function collectSpells()
	local aMappings = LibraryData.getMappings("spell");

	for _,vMapping in ipairs(aMappings) do
		for _,vSpell in pairs(DB.getChildrenGlobal(vMapping)) do
			local sSpell = StringManager.trim(DB.getValue(vSpell, "name", "")):lower();
			local sModule = vSpell.getModule();
			local sTooltip = "";

			if sModule == nil then
				sTooltip = StringManager.titleCase(sSpell) .. ": Campaign";
			else
				sTooltip = StringManager.titleCase(sSpell) .. ": " .. sModule;
			end

			loaded_spells[sSpell] = { tooltip = sTooltip, class = "reference_spell", record = vSpell.getPath() };
		end
	end
end

function collectFeats()
	local aPHBFeats = {};
	local aRestFeats = {};
	local aMappings = LibraryData.getMappings("feat");

	for _,vMapping in ipairs(aMappings) do
		-- If it is a PHB Feat, load it first
		for _,vPHBFeat in pairs(DB.getChildrenGlobal(vMapping)) do
			local sPHBFeatName = StringManager.trim(DB.getValue(vPHBFeat, "name", "")):lower();
			local sPHBFeatLink = vPHBFeat.getPath();
			local sPHBPrereq = getPrequisite(DB.getValue(vPHBFeat, "text", ""));

			if sPHBFeatLink:match("DD PHB Deluxe") then
				local sTooltip = StringManager.titleCase(sPHBFeatName) .. ": DD PHB Deluxe";

				loaded_feats[sPHBFeatName] =  { tooltip = sTooltip, class = "reference_feat", record = sPHBFeatLink, prereq = sPHBPrereq};
			end
		end

		-- Load all other feats ignoring their version of base feats.
		for _,vFeat in pairs(DB.getChildrenGlobal(vMapping)) do
			local sRestFeatName = StringManager.trim(DB.getValue(vFeat, "name", "")):lower();
			local sFeatLink = vFeat.getPath();
			local sPrereq = getPrequisite(DB.getValue(vFeat, "text", ""));

			if not loaded_feats[sRestFeatName] then
				local sModule = vFeat.getModule();

				loaded_feats[sRestFeatName] =  { tooltip = sPrereq, class = "reference_feat", record = sFeatLink, prereq = sPrereq};
			end
		end
	end
end

function getPrequisite(sText)
	local requirements = sText:match("(Requirement: .+)");
	if requirements then
		requirements = requirements:gsub("<(.*)", "");
		return requirements;
	end

	return "";
end

--
-- Utility
--

function calcSummaryStats()
	local nStr = summary.subwindow.summary_base_strength.getValue();
	local nDex = summary.subwindow.summary_base_dexterity.getValue();
	local nCon = summary.subwindow.summary_base_constitution.getValue();
	local nInt = summary.subwindow.summary_base_intelligence.getValue();
	local nWis = summary.subwindow.summary_base_wisdom.getValue();
	local nCha = summary.subwindow.summary_base_charisma.getValue();

	local nRaceStr = summary.subwindow.summary_race_strength.getValue();
	local nRaceDex = summary.subwindow.summary_race_dexterity.getValue();
	local nRaceCon = summary.subwindow.summary_race_constitution.getValue();
	local nRaceInt = summary.subwindow.summary_race_intelligence.getValue();
	local nRaceWis = summary.subwindow.summary_race_wisdom.getValue();
	local nRaceCha = summary.subwindow.summary_race_charisma.getValue();

	local nASIStr = 0;
	local nASIDex = 0;
	local nASICon = 0;
	local nASIInt = 0;
	local nASIWis = 0;
	local nASICha = 0;

	if genstats.subwindow then
		for _,vSelection in ipairs(genstats.subwindow.contents.subwindow.abilityscore_improvements.getWindows()) do
			local aAbilities = {};
			local nIncrease = 2;

			for _,vButton in pairs(vSelection.selection_window.getWindows()) do
				if vButton.value.getValue() == "1" then
					table.insert(aAbilities, vButton.name.getValue());
				end
			end

			if #aAbilities > 1 then
				nIncrease = 1;
			end

			for k,v in pairs(aAbilities) do
				if v == "strength" then
					nASIStr = nASIStr + nIncrease;
				elseif v == "dexterity" then
					nASIDex = nASIDex + nIncrease;
				elseif v == "constitution" then
					nASICon = nASICon + nIncrease;
				elseif v == "intelligence" then
					nASIInt = nASIInt + nIncrease;
				elseif v == "wisdom" then
					nASIWis = nASIWis + nIncrease;
				elseif v == "charisma" then
					nASICha = nASICha + nIncrease;
				end
			end
		end
	end

	local nFeatStr = 0;
	local nFeatDex = 0;
	local nFeatCon = 0;
	local nFeatInt = 0;
	local nFeatWis = 0;
	local nFeatCha = 0;

	if genfeats.subwindow then
		for _,vSelection in pairs(genfeats.subwindow.contents.subwindow.feat_window.getWindows()) do
			local sAbility = vSelection.ability.getValue();

			if sAbility == "strength" then
				nFeatStr = nFeatStr + 1;
			elseif sAbility == "dexterity" then
				nFeatDex = nFeatDex + 1;
			elseif sAbility == "constitution" then
				nFeatCon = nFeatCon + 1;
			elseif sAbility == "intelligence" then
				nFeatInt = nFeatInt + 1;
			elseif sAbility == "wisdom" then
				nFeatWis = nFeatWis + 1;
			elseif sAbility == "charisma" then
				nFeatCha = nFeatCha + 1;
			end
		end
	end

	for _, origin in pairs(origins) do
		local attribute = DB.getValue(origin.nodeSource, "attribute", "");
		local sAbility, sAmount = attribute:match("(%w+) %+(%d+)");
		if sAbility then
			sAbility = sAbility:lower();
			sAmount = tonumber(sAmount);
			if sAbility == "strength" then
				nFeatStr = nFeatStr + sAmount;
			elseif sAbility == "dexterity" then
				nFeatDex = nFeatDex + sAmount;
			elseif sAbility == "constitution" then
				nFeatCon = nFeatCon + sAmount;
			elseif sAbility == "intelligence" then
				nFeatInt = nFeatInt + sAmount;
			elseif sAbility == "wisdom" then
				nFeatWis = nFeatWis + sAmount;
			elseif sAbility == "charisma" then
				nFeatCha = nFeatCha + sAmount;
			end
		end
	end

	summary.subwindow.summary_strength.setValue(nStr + nRaceStr + nASIStr + nFeatStr);
	summary.subwindow.summary_dexterity.setValue(nDex + nRaceDex + nASIDex + nFeatDex);
	summary.subwindow.summary_constitution.setValue(nCon + nRaceCon + nASICon + nFeatCon);
	summary.subwindow.summary_intelligence.setValue(nInt + nRaceInt + nASIInt + nFeatInt);
	summary.subwindow.summary_wisdom.setValue(nWis + nRaceWis + nASIWis + nFeatWis);
	summary.subwindow.summary_charisma.setValue(nCha + nRaceCha + nASICha + nFeatCha);
end

function updateAlerts(aAlerts, sPage)
	local bDupeSkillAlert = false;
	for _,v in pairs(alerts.getWindows()) do
		if v.alert_label.getValue() ~= "DUPLICATE SKILLS" then
			v.close();
		elseif v.alert_label.getValue() == "DUPLICATE SKILLS" then
			bDupeSkillAlert = true;
		end
	end
	if sPage then
		if #aAlerts > 0 then
			for i=1,#aAlerts do
				local wndAlertList = alerts.createWindow();

				wndAlertList.alert_label.setValue(aAlerts[i]);
				self[sPage .. "_alert"].setVisible(true);
				self[sPage .. "_GateCheck"].setValue(0);
			end
		else
			self[sPage .. "_alert"].setVisible(false);
			self[sPage .. "_GateCheck"].setValue(1);
		end
	end
	if getSkillDuplicates() and not bDupeSkillAlert then
		local wndDupeAlertList = alerts.createWindow();

		wndDupeAlertList.alert_label.setValue("DUPLICATE SKILLS");
	elseif not getSkillDuplicates() then
		for _,v in pairs(alerts.getWindows()) do
			if v.alert_label.getValue() == "DUPLICATE SKILLS" then
				v.close();
			end
		end
	end
end

function updateAbilityAlerts()
	alerts.closeAll();

	local bAbilityCap = false;

	for _,v in pairs(DataCommon.abilities) do
		if summary.subwindow["summary_" .. v:lower()].getValue() > 20 then
			bAbilityCap = true;
		end
	end
	if bAbilityCap then
		local bAlertWindow = false;

		for _,vAlert in pairs(alerts.getWindows()) do
			if vAlert.alert_label.getValue() == "ABILITY SCORE ABOVE 20" then
				bAlertWindow = true;
			end
		end
		if not bAlertWindow then
			local wndAlertList = alerts.createWindow();

			wndAlertList.alert_label.setValue("ABILITY SCORE ABOVE 20");
			ability_alert.setVisible(true);
			ability_GateCheck.setValue(0);
		end		
	else
		for _,vAlert in pairs(alerts.getWindows()) do
			if vAlert.alert_label.getValue() == "ABILITY SCORE ABOVE 20" then
				vAlert.close();
			end
		end	

		ability_alert.setVisible(false);
		ability_GateCheck.setValue(1);
	end
end

function getToolType(sToolType)
	local aTools = {};

	if sToolType and sToolType ~= "" then
		sToolType = string.lower(sToolType);
	end

	local aMappings = LibraryData.getMappings("item");

	for _,vMapping in ipairs(aMappings) do
		for _,vItems in pairs(DB.getChildrenGlobal(vMapping)) do	
			if StringManager.trim(DB.getValue(vItems, "type", "")):lower() == "tools" then
				if sToolType and sToolType ~= "" then
					if StringManager.trim(DB.getValue(vItems, "subtype", "")):lower() == sToolType then
						table.insert(aTools, StringManager.trim(DB.getValue(vItems, "name", "")):lower());
					end
				else
					table.insert(aTools, StringManager.trim(DB.getValue(vItems, "name", "")):lower());
				end
			end
		end
	end

	local aFinalTools = {};
	local aDupes = {};

	for _,v in ipairs(aTools) do
		if not aDupes[v] then
			table.insert(aFinalTools, v);
			aDupes[v] = true;
		end
	end

	return aFinalTools;
end

function updateProficiencies()
	local aCurProfs = {};
	local aRaceProfs = {};
	local aClassProfs = {};
	local aOriginProfs = {};

	for k,v in pairs(proficiencies_race) do
		if k:lower() == "all armor" then
			for t,_ in pairs(CharWizardData.aAllArmor) do
				aCurProfs[t] = "";
			end
		else
			aRaceProfs[k:lower()] = v;
			aCurProfs[k:lower()] = v;
		end
	end
	for k,v in pairs(proficiencies_class) do
		if k:lower() == "all armor" then
			for t,_ in pairs(CharWizardData.aAllArmor) do
				aCurProfs[t] = "";
			end
		else
			aClassProfs[k:lower()] = v;
			aCurProfs[k:lower()] = v;
		end
	end
	for k,v in pairs(proficiencies_origin) do
		if k:lower() == "all armor" then
			for t,_ in pairs(CharWizardData.aAllArmor) do
				aCurProfs[t] = "";
			end
		else
			aOriginProfs[k:lower()] = v;
			aCurProfs[k:lower()] = v;
		end
	end

	summary.subwindow.summary_proficiencies.closeAll();

	local aFinalProfs = {};

	for k,v in pairs(aCurProfs) do
		if CharWizardData.aSimpleWeapons[k] then
			if not aCurProfs["simple weapons"] then
				aFinalProfs[k] = v;
			end
		elseif CharWizardData.aMartialWeapons[k] then
			if not aCurProfs["martial weapons"] then
				aFinalProfs[k] = v;
			end
		else
			aFinalProfs[k] = v;
		end
	end

	for k,v in pairs(aFinalProfs) do
		local w = summary.subwindow.summary_proficiencies.createWindow();
		w.name.setValue(StringManager.titleCase(k));

		if aCurProfs[k].expertise then
			w.expertise.setValue(aCurProfs[k].expertise);
		end

		if aCurProfs[k].type then
			w.type.setValue(aCurProfs[k].type);
		end
	end

	summary.subwindow.summary_proficiencies.applySort();
end

function updateExpertise()
	if genclass.subwindow then
		local aSkills = {};
		local aExpSkillWin = {};
		local aSelectedExp = {};

		for _,vSkill in pairs(summary.subwindow.summary_skills.getWindows()) do
			aSkills[vSkill.name.getValue():lower()] = vSkill;
		end

		for _,vClassWin in ipairs(genclass.subwindow.contents.subwindow.class_window.getWindows()) do
			if vClassWin.group_name.getValue():lower():match("expertise") then
				local sClassName = vClassWin.group_name.getValue():lower():match("(.-) expertise");

				if sClassName == "rogue" then
					for _,vSkill in pairs(summary.subwindow.summary_proficiencies.getWindows()) do
						if vSkill.name.getValue():lower() == "thieves' tools" then
							if vSkill.expertise.getValue() == 1 then
								aSkills[vSkill.name.getValue():lower()] = vSkill;

								break
							end
						end
					end

					if not aSkills["thieves' tools"] then
						aSkills["thieves' tools"] = "";
					end
				end

				for _,vExp in pairs(vClassWin.selection_window.getWindows()) do
					if aSkills[vExp.name.getValue():lower()] and aSkills[vExp.name.getValue():lower()] ~= "" then
						if aSkills[vExp.name.getValue():lower()].expertise.getValue() ~= 1 then
							vExp.close();
						else
							aSelectedExp[vExp.name.getValue():lower()] = "";
						end
					else
						for _,vSelected in pairs(StringManager.split(vClassWin.selection_name.getValue():lower(), ",")) do
							if vExp.name.getValue():lower():match(vSelected) then
								vExp.bname.onButtonPress();
								vClassWin.selection_window.setVisible(true);
								vClassWin.button_expand.setValue(1);
							end
						end

						vExp.close();
					end
				end

				for kSkillName,vSkillWin in pairs(aSkills) do
					if not aSelectedExp[kSkillName] then
						local wndSkills = vClassWin.selection_window.createWindow();

						wndSkills.bname.setText(StringManager.titleCase(kSkillName));
						wndSkills.name.setValue(kSkillName);
					end
				end
			end
		end
	end
end

function updateOrigins()
	local text = "";

	for _, origin in pairs(origins) do
		if text ~= "" then
			text = text .. " / ";
		end
		text = text .. DB.getValue(origin.nodeSource, "name", "");
	end

	summary.subwindow.summary_origins.setValue(text);
end

function getAvailableLanguages()
	local aLanguages = {};
	local aAvailableLanguages = {};
	local aLangWin = summary.subwindow.summary_languages.getWindows();

	for _,v in pairs(aLangWin) do
		table.insert(aLanguages, v.name.getValue());
	end

	for _,vLang in pairs(DB.getChildren(DB.findNode("languages"))) do
		local sLangName = DB.getValue(vLang, "name", "");
		if not StringManager.contains(aLanguages, sLangName) then
			aAvailableLanguages[sLangName:lower()] = { tooltip = "Select Language" };
		end	
	end

	return aAvailableLanguages;
end

function getSkillDuplicates(sPage)
	local aSkillWindows = summary.subwindow.summary_skills.getWindows();
	local aSkillNames = {};
	local aDuplicateSkills = {};	
	local aDupes = {};
	for _,vSkillWin in pairs(aSkillWindows) do
		table.insert(aSkillNames, vSkillWin.name.getValue());
	end
	for _,vSkill in pairs(aSkillNames) do
		if not aDupes[vSkill] then
			aDupes[vSkill] = true;
		else
			table.insert(aDuplicateSkills, vSkill);
		end
	end
	if #aDuplicateSkills > 0 then
		summary.subwindow.summary_skilltitle.setValue("SKILLS (DUPLICATES)");
		return true, aDuplicateSkills;
	else
		summary.subwindow.summary_skilltitle.setValue("SKILLS");
		return false;		
	end
end

function getAvailableSkills()
	local aSkills = {};
	local aAvailableSkills = {};
	local aSkillWin = summary.subwindow.summary_skills.getWindows();
	for _,v in pairs(aSkillWin) do
		table.insert(aSkills, v.name.getValue());
	end
	for kSkill,_ in pairs(DataCommon.skilldata) do
		if not StringManager.contains(aSkills, kSkill) then
			aAvailableSkills[kSkill:lower()] = { tooltip = "Select skill" };
			--table.insert(aAvailableSkills, kSkill:lower());
		end	
	end

	return aAvailableSkills;
end

function getTotalLevel()
	local aClasses = summary.subwindow.summary_class.getWindows();
	local nTotalLevel = 0;

	for _,v in pairs(aClasses) do
		nTotalLevel = nTotalLevel + tonumber(v.classlevel.getValue());
	end

	return nTotalLevel;
end

function checkFeatSpellInv()
	local nClassCount = summary.subwindow.summary_class.getWindowCount();
	local sRace = summary.subwindow.summary_race.getValue();
	local bInv = (nClassCount > 0);
	local bSpell = false;

	for _,v in pairs(summary.subwindow.summary_class.getWindows()) do
		local sClass,sRecord = v.link.getValue();
		local sClassName = v.name.getValue();
		local sClassLevel = v.classlevel.getValue();
		local aFeatures = {};

		for _,vFeature in pairs(DB.getChildren(DB.findNode(sRecord), "features")) do
			aFeatures[DB.getValue(vFeature, "name", ""):lower()] = vFeature;
		end

		if aFeatures["spellcasting"] or aFeatures["pact magic"] then
			if DB.getValue(aFeatures["spellcasting"], "specialization", "") == "" then
				if DB.getValue(aFeatures["spellcasting"], "level", 0) <= tonumber(sClassLevel) then
					bSpell = true;
				end

				if DB.getValue(aFeatures["pact magic"], "level", 0) >= tonumber(sClassLevel) then
					bSpell = true;
				end

				break
			end
		end
	end

	for _,v in pairs(summary.subwindow.summary_specialization.getWindows()) do
		local sClass,sRecord = v.link.getValue();
		local sName = DB.getValue(DB.findNode(sRecord), "name", ""):lower();
		local aFeatures = {};

		for _,vFeature in pairs(DB.getChildren(DB.findNode(sRecord).getParent().getParent(), "features")) do
			aFeatures[DB.getValue(vFeature, "name", ""):lower()] = vFeature;
		end

		if aFeatures["spellcasting"] then
			if DB.getValue(aFeatures["spellcasting"], "specialization", ""):lower():match(sName) then
				bSpell = true;

				break
			end
		end
	end

	charwizard_invtab.setVisible(bInv and import == 0);
	charwizard_spelltab.setVisible(bSpell);
	charwizard_feattab.setVisible(sRace ~= "" and nClassCount > 0);
	feat_GateCheck.setVisible(sRace ~= "" and nClassCount > 0);
	feat_alert.setVisible(sRace ~= "" and nClassCount > 0)
end

--
-- COMMIT
--

_tWarnings = {};

function onCommitButtonPressed()
	if checkCompletion() then
		onCommitButtonHelper();
	else
		tabs.activateTab(9);

		if genwarnings.subwindow then
			genwarnings.subwindow.contents.subwindow.setWarnings(_tWarnings);
		end
	end
end

function onWarningSaveButtonPressed()
	onCommitButtonHelper();
end

function onCommitButtonHelper()
	if import == 1 then
		levelupCharacter(summary.subwindow.summary_identity.getValue());
	else
		if Session.IsHost then
			commitCharacter(summary.subwindow.summary_identity.getValue());
		else
			requestCommit();
		end
	end
end

function checkCompletion()
	local wndSummary = Interface.findWindow("charwizard", "");
	_tWarnings = {};
	local aCurRaceWarnings, aCurClassWarnings, aCurOriginWarnings;
	local bImport = wndSummary.import == 1;

	if genraces.subwindow then
		aCurRaceWarnings = CharWizardManager.getAlerts(wndSummary, genraces.subwindow.contents.subwindow.race_window);
	else
		if not bImport then
			table.insert(_tWarnings, {warning = "Select Race", severity = 2, group1 = "race", group2 = "race", order = 2, grouporder = 1});
		end
	end
	--local aCurStatWarnings = genstats.subwindow.contents.subwindow.race_window.getRaceAlerts(wndSummary);
	if genclass.subwindow then
		aCurClassWarnings = CharWizardManager.getAlerts(wndSummary, genclass.subwindow.contents.subwindow.class_window);
	else
		table.insert(_tWarnings, {warning = "Select Class", severity = 2, group1 = "class", group2 = "class", order = 3, grouporder = 2});
	end
	if genorigin.subwindow then
		aCurOriginWarnings = CharWizardManager.getAlerts(wndSummary, genorigin.subwindow.contents.subwindow.origin_window);
	else
		if not bImport then
			table.insert(_tWarnings, {warning = "Select Origins", severity = 2, group1 = "origin", group2 = "origin", order = 4, grouporder = 3});
		end
	end

	local bComplete = true;
	if not bImport then
		if aCurRaceWarnings then
			for _,vRaceAlerts in pairs(aCurRaceWarnings) do
				table.insert(_tWarnings, {warning = StringManager.titleCase(vRaceAlerts) .. " (RACE)", severity = 2, group1 = "race", group2 = "race", order = 2, grouporder = 1});
			end
		end
	end
	if aCurClassWarnings then
		for _,vClassAlerts in pairs(aCurClassWarnings) do
			table.insert(_tWarnings, {warning = StringManager.titleCase(vClassAlerts), severity = 2, group1 = "class", group2 = "class", order = 3, grouporder = 2});
		end
	end
	if not bImport then
		if aCurOriginWarnings then
			for _,vOriginAlerts in pairs(aCurOriginWarnings) do
				table.insert(_tWarnings, {warning = StringManager.titleCase(vOriginAlerts .. " (ORIGIN)"), severity = 2, group1 = "origin", group2 = "origin", order = 4, grouporder = 3});
			end
		end
		if geninv.subwindow then
			local nKitList = geninv.subwindow.contents.subwindow.kitlist.getWindowCount();
			local nInvList = geninv.subwindow.contents.subwindow.inventory.getWindowCount();

			if nKitList == 0 and nInvList == 0 then
				bComplete = false;
			end
		end
	end

	if #_tWarnings > 0 then
		bComplete = false;
	end

	return bComplete;
end

function requestResponse(bResult, sIdentity)
	if bResult then
		commitCharacter(sIdentity);
	else
		ChatManager.SystemMessage("Error: Failed to create new PC identity.")
	end
	bRequested = false;
end

function requestCommit()
	if not bRequested then
		User.requestIdentity(nil, "charsheet", "name", nil, requestResponse);
		bRequested = true;
	end
end

function commitCharacter(identity)
	local nodeChar;
	local w;

	if Session.IsHost then
		nodeChar = DB.createChild("charsheet");
		w = Interface.openWindow("charsheet", nodeChar);
	else
		nodeChar = DB.findNode("charsheet." .. identity);
		w = Interface.findWindow("charsheet", nodeChar);
	end

	-- Set Warnings
	if #_tWarnings > 0 then
		local tNotes = {};
		for _,v in ipairs(_tWarnings) do
			table.insert(tNotes, v.warning);
		end
		DB.setValue(nodeChar, "notes", "string", table.concat(tNotes, "\r"));
	end

	-- Set Name
	if name.getValue() ~= "" then
		w.name.setValue(name.getValue());
	end

	-- Set Senses
	DB.setValue(nodeChar, "senses", "string", summary.subwindow.summary_senses.getValue());

	-- Set Size
	DB.setValue(nodeChar, "size", "string", summary.subwindow.summary_size.getValue());

	-- Set Ability Scores
	setAbilityScores(nodeChar)

	-- Set Origin Text and Link
	if summary.subwindow.summary_origins.getValue() ~= "" then
		setOrigins(nodeChar)
	end

	-- Set Race or Subrace Text and Link
	if summary.subwindow.summary_race.getValue() ~= "" then
		setRaceSubRace(nodeChar)
	end

	-- Add Traits
	if summary.subwindow.summary_traits.getWindowCount() > 0 then
		addTraits(nodeChar);
	end

	-- Add Feats
	if genfeats.subwindow then
		addFeats(nodeChar);
	end

	-- Set Class Text and Link
	if genclass.subwindow and summary.subwindow.summary_class.getWindowCount() > 0 then
		setClasses(nodeChar);
		addClassFeats(nodeChar);

		-- Add Spell Slots
		local aSpellCasters = CharWizardManager.retrieveCasterClasses(self);
		local nCantrips, nSpells, nCasterLevel, aSpellSlots, aPactSlots = CharWizardManager.getSpellsAvailable(self, aSpellCasters);

		for k,vSlot in ipairs(aSpellSlots) do
			DB.setValue(nodeChar, "powermeta.spellslots" .. k .. ".max", "number", vSlot)
		end

		for k,vPactSlot in ipairs(aPactSlots) do
			DB.setValue(nodeChar, "powermeta.pactmagicslots" .. k .. ".max", "number", vPactSlot)
		end
	end

	addProficiencyDB(nodeChar);
	addSkillDB(nodeChar);

	-- Add Features
	if summary.subwindow.summary_features.getWindowCount() > 0 then
		addFeatures(nodeChar);
	end

	-- Move Listed Languages, Skills, and Proficiencies to Character DB
	if summary.subwindow.summary_languages.getWindowCount() > 0 then
		for _,v in pairs(summary.subwindow.summary_languages.getWindows()) do
			CharManager.addLanguageDB(nodeChar, v.name.getValue());
		end
	end

	if #innatespells > 0 then
		addInnateSpells(nodeChar)
	end

	-- Add Inventory
	if #inventory > 0 then
		for _,vItem in pairs(inventory) do
			for i = 1, vItem.count do
				ItemManager.handleItem("charsheet." .. nodeChar.getName(), "inventorylist", CharWizardManager.getShortcutClass(vItem.record), vItem.record, true);
			end
		end

		calcItemArmorClass(nodeChar);
	end

	if gold > 0 then
		CurrencyManager.addCharCurrency(nodeChar, "GP", gold);
	end

	-- Add Spells
	if genspells.subwindow then
		addSpells(nodeChar);
	end

	close();
end

function levelupCharacter(identity)
	nodeChar = DB.findNode(summary.subwindow.summary_identity.getValue());
	w = Interface.openWindow("charsheet", nodeChar);

	if levelUpClass ~= "" then
		-- Update Ability Scores
		setAbilityScores(nodeChar);

		-- Move Listed Languages, Skills, and Proficiencies to Character DB
		if summary.subwindow.summary_languages.getWindowCount() > 0 then
			for _,v in pairs(summary.subwindow.summary_languages.getWindows()) do
				CharManager.addLanguageDB(nodeChar, v.name.getValue());
			end
		end

		addProficiencyDB(nodeChar);
		addSkillDB(nodeChar);

		-- Update Class Text and Link
		CharManager.addClassRef(nodeChar, "reference_class", levelUpClass, true);

		-- Add Features
		if summary.subwindow.summary_features.getWindowCount() > 0 then
			addFeatures(nodeChar);
		end

		-- Add Spell Slots
		local aSpellCasters = CharWizardManager.retrieveCasterClasses(self);
		local nCantrips, nSpells, nCasterLevel, aSpellSlots, aPactSlots = CharWizardManager.getSpellsAvailable(self, aSpellCasters);

		for k,vSlot in ipairs(aSpellSlots) do
			DB.setValue(nodeChar, "powermeta.spellslots" .. k .. ".max", "number", vSlot)
		end

		for k,vPactSlot in ipairs(aPactSlots) do
			DB.setValue(nodeChar, "powermeta.pactmagicslots" .. k .. ".max", "number", vPactSlot)
		end

		-- Add Feats
		if genfeats.subwindow then
			addFeats(nodeChar);
		end

		addClassFeats(nodeChar);
	end

	-- Add Spells
	if genspells.subwindow then
		addSpells(nodeChar);
	end

	close();
end

function setAbilityScores(nodeChar)
	for _,v in ipairs(DataCommon.abilities) do
		local nScore = summary.subwindow["summary_" .. v].getValue()
		DB.setValue(nodeChar, "abilities." .. v .. ".score", "number", nScore);

		local nBonus = ActorManager5E.getAbilityBonus(nodeChar, v);
		DB.setValue(nodeChar, "abilities." .. v .. ".bonus", "number", nBonus);

		CharManager.outputUserMessage("char_abilities_message_abilityadd", StringManager.titleCase(v), nScore, DB.getValue(nodeChar, "name", ""));
	end
end

function setOrigins(nodeChar)
	local originA, originB;

	for _,v in pairs(origins) do
		if originA then
			originB = v.nodeSource;
			break
		else
			originA = v.nodeSource;
		end
	end

	if originA then
		-- Notify
		CharManager.outputUserMessage("char_abilities_message_originadd", DB.getValue(originA, "name", ""), DB.getValue(nodeChar, "name", ""));

		-- Add the name and link to the main character sheet
		DB.setValue(nodeChar, "origin_a", "string", DB.getValue(originA, "name", ""));
		DB.setValue(nodeChar, "origin_a_link", "windowreference", "reference_origin", originA.getPath());
	end

	if originB then
		-- Notify
		CharManager.outputUserMessage("char_abilities_message_originadd", DB.getValue(originB, "name", ""), DB.getValue(nodeChar, "name", ""));

		-- Add the name and link to the main character sheet
		DB.setValue(nodeChar, "origin_b", "string", DB.getValue(originB, "name", ""));
		DB.setValue(nodeChar, "origin_b_link", "windowreference", "reference_origin", originB.getPath());
	end
end

function setRaceSubRace(nodeChar)
	local sSubRaceClass,sSubRaceRecord = summary.subwindow.summary_subrace_link.getValue()

	if sSubRaceClass ~= "" and sSubRaceClass ~= "none" then
		local nodeSource = CharManager.resolveRefNode(sSubRaceRecord);

		if not nodeSource then
			return;
		end

		DB.setValue(nodeChar, "race", "string", summary.subwindow.summary_race.getValue());
		DB.setValue(nodeChar, "racelink", "windowreference", "reference_race", nodeSource.getParent().getParent().getPath());

		local raceHP = DB.getChild(sSubRaceRecord, "hitpoints", "");
		if raceHP then
			raceHP = tonumber(raceHP:getText():match("(%d+)"));
			if raceHP then
				local nHP = DB.getValue(nodeChar, "hp.total", 0);
				DB.setValue(nodeChar, "hp.total", "number", nHP + raceHP);
				CharManager.outputUserMessage("char_abilities_message_hpaddrace", DB.getValue(sSubRaceRecord, "name", ""), DB.getValue(nodeChar, "name", ""), raceHP);
			end
		end
	else
		local sRaceClass, sRaceRecord;
		for _,v in pairs(genraces.subwindow.contents.subwindow.race_window.getWindows()) do
			if v.group_name.getValue() == "RACE" then
				sRaceClass, sRaceRecord = v.selection_shortcut.getValue();

				break
			end
		end

		local nodeSource = CharManager.resolveRefNode(sRaceRecord);

		if not nodeSource then
			return;
		end

		DB.setValue(nodeChar, "race", "string", DB.getValue(nodeSource, "name", ""));
		DB.setValue(nodeChar, "racelink", "windowreference", "reference_race", nodeSource.getPath());
	end
end

function addTraits(nodeChar)
	for _,vTrait in pairs(summary.subwindow.summary_traits.getWindows()) do
		local sTraitClass,sTraitRecord = vTrait.link.getValue();

		if CharWizardDataAction.parsedata[CampaignDataManager2.sanitize(vTrait.name.getValue():lower())] then
			local aAction = CharWizardDataAction.parsedata[CampaignDataManager2.sanitize(vTrait.name.getValue():lower())];
			if aAction["actions"] then
				addAction(nodeChar, DB.findNode(sTraitRecord), vTrait.type.getValue(), nil, aAction)
			elseif aAction["multiple_actions"] then
				for k,v in pairs(aAction["multiple_actions"]) do
					addAction(nodeChar, DB.findNode(sTraitRecord), vTrait.type.getValue(), k, v)
				end
			end
		end

		if CharWizardData.aRaceSpells[CampaignDataManager2.sanitize(vTrait.name.getValue():lower())] then
			addRaceSpell(nodeChar, DB.findNode(sTraitRecord));
		end

		local nodeList = nodeChar.createChild("traitlist");

		if not nodeList then
			return false;
		end

		vNew = nodeList.createChild();
		DB.copyNode(DB.findNode(sTraitRecord), vNew);
		DB.setValue(vNew, "name", "string", vTrait.name.getValue());
		DB.setValue(vNew, "locked", "number", 1);

		if sTraitClass == "reference_racialtrait" then
			DB.setValue(vNew, "type", "string", "racial");
		elseif sTraitClass == "reference_subracialtrait" then
			DB.setValue(vNew, "type", "string", "subracial");
		elseif sTraitClass == "reference_origintrait" then
			DB.setValue(vNew, "type", "string", "origin");
		end

		CharManager.outputUserMessage("char_abilities_message_traitadd", DB.getValue(vNew, "name", ""), DB.getValue(nodeChar, "name", ""));
	end
end

function addRaceSpell(nodeChar, nodeSpellTrait)
	local aRaceSpells = {};
	local aThirdLvlSpells = {}
	local aFifthLvlSpells = {}
	local aRaceChoiceSpells = {};
	local sChoices = "";
	local sSpellList = "";
	local bChoice = false;
	local aSpells = {};

	local sText = DB.getText(nodeSpellTrait, "text"):lower();
	local aSentences = StringManager.split(sText, ".");

	for _,vSentence in pairs(aSentences) do
	 	local sSpellText = vSentence:match("you know the (.-) cantrip");

		if not sSpellText then
		 	sSpellText = vSentence:match("you know the cantrip[s]? ([%w%s]+)");
		end

	 	if not sSpellText then
		 	sSpellText = vSentence:match("you can cast the (.-) on");
		 end

		if not sSpellText then
			sSpellText = vSentence:match("to cast the (.-) spell");
		end

		if not sSpellText then
			sSpellText = vSentence:match("you can cast (.-) once with ");
		end

		if not sSpellText then
			sSpellText = vSentence:match("you can cast the (.-) with this trait");
		end

		if not sSpellText then
			sSpellText = vSentence:match("you can cast (.-) with this trait");
		end

		if not sSpellText then
			sSpellText = vSentence:match("you can also cast the (.-) with this trait");
		end

		if not sSpellText then
			sSpellText = vSentence:match("gain the ability to cast (.-), but only");
		end

		if not sSpellText then
			break
		else
			sSpellText = sSpellText:gsub(" an unlimited number of times", "")
			sSpellText = sSpellText:gsub(" %(targeting yourself", "")
			sSpellText = sSpellText:gsub(" as a 2nd-level", "")
			sSpellText = sSpellText:gsub(" as a 2nd level", "")
			sSpellText = sSpellText:gsub(", but", "")
			sSpellText = sSpellText:gsub(" spell", "")

			sSpellText = StringManager.trim(sSpellText);

			local aSplit = {};

			--if not aSpells[sSpellText] then
				local sSplit1, sSplit2 = sSpellText:match("(detect magic) and (detect poison and disease)")

				if not sSplit1 and not sSplit2 then
					sSplit1, sSplit2 = sSpellText:match("([%w%s]+) and ([%w%s]+)");
				end

				if sSplit1 and sSplit2 then
					table.insert(aSplit, sSplit1);
					table.insert(aSplit, sSplit2);
				end
			--end

			if #aSplit > 0 then
				for _,v in pairs(aSplit) do
					if vSentence:match("3rd") then
						table.insert(aThirdLvlSpells, v);
					elseif vSentence:match("5th") then
						table.insert(aFifthLvlSpells, v);
					else
						aRaceSpells[v:lower()] = v;
					end
				end
			else
				if vSentence:match("3rd") then
					table.insert(aThirdLvlSpells, sSpellText);
				elseif vSentence:match("5th") then
					table.insert(aFifthLvlSpells, sSpellText);
				else
					aRaceSpells[sSpellText:lower()] = sSpellText;
				end
			end
		end
	end

	local aSpells = {};
	local aMappings = LibraryData.getMappings("spell");

	for _,vMapping in ipairs(aMappings) do
		for _,vSpell in pairs(DB.getChildrenGlobal(vMapping)) do
			local sSpell = StringManager.trim(DB.getValue(vSpell, "name", "")):lower();

			if aRaceSpells[sSpell] then
				PowerManager.addPower("reference_spell", vSpell, nodeChar, summary.subwindow.summary_race.getValue() .. " Innate Spells");

				break
			end
		end
	end
end

function addAction(nodeChar, nodeSource, sClassName, sPowerName, aAction)
	local nodePowers = nodeChar.createChild("powers");
	local nodeNewPower = nodePowers.createChild();

	-- Copy the power details over
	DB.copyNode(nodeSource, nodeNewPower);

	DB.setValue(nodeNewPower, "group", "string", StringManager.titleCase(sClassName) .. " Actions/Effects");

	if aAction.prepared then
		if aAction.prepared > 0 then
			DB.setValue(nodeNewPower, "prepared", "number", aAction.prepared);
		end
	end

	-- Remove level data
	DB.deleteChild(nodeNewPower, "level");

	-- Copy text to description
	local nodeText = nodeNewPower.getChild("text");
	if nodeText then
		local nodeDesc = nodeNewPower.createChild("description", "formattedtext");
		DB.copyNode(nodeText, nodeDesc);
		nodeText.delete();
	end

	-- Set locked state for editing detailed record
	DB.setValue(nodeNewPower, "locked", "number", 1);

	-- CLean out old actions
	local nodeActions = nodeNewPower.createChild("actions");
	for _,v in pairs(nodeActions.getChildren()) do
		v.delete();
	end

	-- Track whether cast action already created
	local nodeCastAction = nil;

	-- Set the power name
	if sPowerName ~= nil then
		DB.setValue(nodeNewPower, "name", "string", sPowerName);
	end

	-- Pull the actions from the action data table (if available)
	if aAction["actions"] == nil then
		return
	end

	for _,vAction in pairs(aAction["actions"]) do
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
end

function addProficiencyDB(nodeChar)
	-- Get the list we are going to add to
	local nodeList = nodeChar.createChild("proficiencylist");
	if not nodeList then
		return false;
	end

	local vNew;
	for _,v in pairs(summary.subwindow.summary_proficiencies.getWindows()) do
		if v.type.getValue() ~= "imported" then
			-- Add Proficiencies
			vNew = nodeList.createChild();
			DB.setValue(vNew, "name", "string", v.name.getValue());

			-- Announce
			CharManager.outputUserMessage("char_abilities_message_profadd", DB.getValue(vNew, "name", ""), DB.getValue(nodeChar, "name", ""));
		end
	end
	return true;
end

function addSkillDB(nodeChar, nProficient)
	-- Get the list we are going to add to
	local nodeList = nodeChar.createChild("skilllist");

	if not nodeList then
		return nil;
	end

	for _,v in pairs(summary.subwindow.summary_skills.getWindows()) do
		-- Add Skills

		local nodeSkill = "";
		local sSkill = v.name.getValue();

		if v.type.getValue() ~= "imported" then
			nodeSkill = nodeList.createChild();
		else
			for _,vSkill in pairs(DB.getChildren(nodeChar, "skilllist")) do
				if sSkill:lower() == DB.getValue(vSkill, "name", ""):lower() then
					nodeSkill = vSkill;
				end
			end
		end

		local bExpertise = v.expertise.getValue() == 1;
		local nProficient = 1;

		if string.lower(sSkill) == "sleight of hand" then
			sSkill = "Sleight of Hand";
		end

		DB.setValue(nodeSkill, "name", "string", sSkill);

		if DataCommon.skilldata[sSkill] then
			DB.setValue(nodeSkill, "stat", "string", DataCommon.skilldata[sSkill].stat);
		end

		if bExpertise then
			nProficient = 2;
		end

		DB.setValue(nodeSkill, "prof", "number", nProficient);

		-- Announce
		if nProficient == 2 then
			CharManager.outputUserMessage("Expertise " .. "char_abilities_message_skilladd", DB.getValue(nodeSkill, "name", ""), DB.getValue(nodeChar, "name", ""));
		else
			CharManager.outputUserMessage("char_abilities_message_skilladd", DB.getValue(nodeSkill, "name", ""), DB.getValue(nodeChar, "name", ""));
		end
	end
end

function addInnateSpells(nodeChar)
	local aSelectedSpells = {};
	local aGroups = {};

	for _,v in pairs(innatespells) do
		local nodePowerGroups = DB.createChild(nodeChar, "powergroup");

		nodeNewGroup = nodePowerGroups.createChild();

		DB.setValue(nodeNewGroup, "castertype", "string", "memorization");
		-- Could only find High Elf with a Cantrip choice assume intelligence
		DB.setValue(nodeNewGroup, "stat", "string", "intelligence");
		DB.setValue(nodeNewGroup, "name", "string", StringManager.titleCase(v.source .. " Innate Spell"));

		PowerManager.addPower("reference_spell", v.record, nodeChar, StringManager.titleCase(v.source .. " Innate Spell"));

		CharManager.outputUserMessage("char_abilities_message_spelladd", StringManager.titleCase(v.name), DB.getValue(nodeChar, "name", ""));
	end
end

function setClasses(nodeChar)
	local nMainClassLevel = 0;
	local sMainClass, sMainRecord = "", "";
	local aRestClasses = {};

	for _,vClass in pairs(genclass.subwindow.contents.subwindow.class_window.getWindows()) do
		if vClass.group_name.getValue() == "CLASS" then
			sMainClass,sMainRecord = vClass.selection_shortcut.getValue();
			nMainClassLevel = vClass.level.getValue();
		end
	end

	for i = 1, nMainClassLevel do
		if i == 1 then
			addSaveProf(nodeChar, sMainClass, sMainRecord);
		end

		CharManager.addClassRef(nodeChar, sMainClass, sMainRecord, true);
	end

	if #aRestClasses > 0 then
		for _,vRestClass in pairs(aRestClasses) do
			for i = 1, vRestClass.level do
				CharManager.addClassRef(nodeChar, "reference_class", vRestClass.record, true);
			end
		end
	end
end

function addSaveProf(nodeChar, sClass, sRecord)
	local nodeSource = CharManager.resolveRefNode(sRecord);

	if not nodeSource then
		return;
	end

	for _,vClassProf in pairs(DB.getChildren(nodeSource, "proficiencies", "")) do
		if vClassProf.getName() == "savingthrows" then
			local sText = DB.getText(vClassProf, "text"):lower();

			if sText and sText ~= "" then
				for _,vProf in pairs(StringManager.split(sText, ",")) do
					vProf = StringManager.trim(vProf);

					if StringManager.contains(DataCommon.abilities, vProf) then
						DB.setValue(nodeChar, "abilities." .. vProf .. ".saveprof", "number", 1);
						CharManager.outputUserMessage("char_abilities_message_saveadd", vProf, DB.getValue(nodeChar, "name", ""));
					end
				end
			else

				return;
			end
		end
	end
end

function addFeatures(nodeChar)
	for _,vFeature in pairs(summary.subwindow.summary_features.getWindows()) do
		local sFeatureClass,sFeatureRecord = vFeature.link.getValue();
		local sClassName = DB.getValue(DB.findNode(sFeatureRecord).getParent().getParent(), "name", "");
		local nodeClass = "";

		for _,v in pairs(DB.getChildren(nodeChar, "classes")) do
			if sClassName == DB.getValue(v, "name", "") then
				nodeClass = v;
			end
		end

		CharManager.addClassFeatureDB(nodeChar, sFeatureClass, sFeatureRecord, nodeClass, true)

		if CharWizardDataAction.parsedata[CampaignDataManager2.sanitize(vFeature.name.getValue():lower())] then
			local aAction = CharWizardDataAction.parsedata[CampaignDataManager2.sanitize(vFeature.name.getValue():lower())];

			if aAction["actions"] then
				addAction(nodeChar, DB.findNode(sFeatureRecord), vFeature.type.getValue(), nil, aAction)
			elseif aAction["multiple_actions"] then
				for k,v in pairs(aAction["multiple_actions"]) do
					addAction(nodeChar, DB.findNode(sFeatureRecord), vFeature.type.getValue(), k, v)
				end
			end
		end
	end

	for _,vSpec in pairs(summary.subwindow.summary_specialization.getWindows()) do
		local sFeatureClass,sFeatureRecord = vSpec.link.getValue();
		local sClassName = DB.getValue(DB.findNode(sFeatureRecord), "name", "");
		local nodeClass = "";

		for _,v in pairs(DB.getChildren(nodeChar, "classes")) do
			if sClassName == DB.getValue(v, "name", "") then
				nodeClass = v;
			end
		end

		CharManager.addClassFeatureDB(nodeChar, sFeatureClass, sFeatureRecord, nodeClass, true)
	end
end

function setSpellSlots(nodeChar)
end

function addSpells(nodeChar)
	local aSelectedSpells = {};
	local aGroups = {};

	for _,v in pairs(DB.getChildren(nodeChar, "powergroup")) do
		aGroups[DB.getValue(v, "name", ""):lower()] = "";
	end

	for _,vImpSpell in pairs(impspells) do
		if vImpSpell.delete then
			vImpSpell.window.delete();
		end
	end

	for _,vSelectedSpell in pairs(genspells.subwindow.contents.subwindow.selectedspells.getWindows()) do
		local sSpellName = vSelectedSpell.name.getValue();
		local sClass, sRecord = vSelectedSpell.link.getValue();

		if not impspells[sSpellName:lower()] then
			if not aGroups["spells (" .. vSelectedSpell.group.getValue():lower() .. ")"] then
				PowerManager.addPower("reference_spell", sRecord, nodeChar, "Spells");
			else
				PowerManager.addPower("reference_spell", sRecord, nodeChar, "Spells (" .. StringManager.titleCase(vSelectedSpell.group.getValue()) .. ")");
			end
		end
	end
end

function getSpellcastingAbility(sClass)
	aINT = {"wizard", "fighter", "rogue", "artificer", "arcane trickster", "eldritch knight"};
	aWIS = {"cleric", "druid", "ranger"};
	aCHA = {"bard", "paladin", "sorcerer", "warlock"};
	sAbility = "";
	if sClass and sClass ~= "" then
		sClass = string.lower(sClass);
		if StringManager.contains(aINT, sClass) then
			sAbility = "intelligence";
		elseif StringManager.contains(aWIS, sClass) then
			sAbility = "wisdom";
		else
			sAbility = "charisma";
		end
	end
	return sAbility;
end

function addClassFeats(nodeChar)
	local aFeats = {};

	for _,v in pairs(genclass.subwindow.contents.subwindow.class_window.getWindows()) do
		if v.group_name.getValue():match(" FEAT") then
			if v.selection_name.getValue() ~= "" then
				local sClass,sRecord = v.selection_shortcut.getValue()

				table.insert(aFeats, {name = v.selection_name.getValue(), record = sRecord} )
			end
		end
	end

	for _,v in pairs(aFeats) do
		if v.record == "" then
			return
		end

		CharManager.addFeatDB(nodeChar, "reference_feat", v.record, true);
	end
end

function addFeats(nodeChar)
	local aFeats = {};

	for _,v in pairs(genfeats.subwindow.contents.subwindow.feat_window.getWindows()) do
		if v.selection_name.getValue() ~= "" then
			local sClass,sRecord = v.selection_shortcut.getValue()

			table.insert(aFeats, {name = v.selection_name.getValue(), record = sRecord} )
		end
	end

	for _,v in pairs(aFeats) do
		if v.record == "" then
			return
		end

		CharManager.addFeatDB(nodeChar, "reference_feat", v.record, true);
	end
end

function addItemToList(vList, sClass, vSource, bTransferAll, nTransferCount)
	-- Get the source item database node object
	local nodeSource = nil;
	if type(vSource) == "databasenode" then
		nodeSource = vSource;
	elseif type(vSource) == "string" then
		nodeSource = DB.findNode(vSource);
	end
	local nodeList = nil;
	if type(vList) == "databasenode" then
		nodeList = vList;
	elseif type(vList) == "string" then
		nodeList = DB.createNode(vList);
	end
	if not nodeSource or not nodeList then
		return nil;
	end

	-- Determine the source and target item location type
	local sSourceRecordType = ItemManager.getItemSourceType(nodeSource);
	local sTargetRecordType = ItemManager.getItemSourceType(nodeList);

	-- Make sure that the source and target locations are not the same character
	if sSourceRecordType == "charsheet" and sTargetRecordType == "charsheet" then
		if nodeSource.getParent().getPath() == nodeList.getPath() then
			return nil;
		end
	end

	-- Use a temporary location to create an item copy for manipulation, if the item type is supported
	local sTempPath;
	if nodeList.getParent() then
		sTempPath = nodeList.getParent().getPath("temp.item");
	else
		sTempPath = "temp.item";
	end
	DB.deleteNode(sTempPath);
	local nodeTemp = DB.createNode(sTempPath);
	local bCopy = false;
	if sClass == "item" then
		DB.copyNode(nodeSource, nodeTemp);
		bCopy = true;
	elseif ItemManager2 and ItemManager2.addItemToList2 then
		bCopy = ItemManager2.addItemToList2(sClass, nodeSource, nodeTemp, nodeList);
	end

	local nodeNew = nil;
	if bCopy then
		-- Determine target node for source item data.
		-- If we already have an item with the same fields, then just append the item count.
		-- Otherwise, create a new item and copy from the source item.
		local bAppend = false;
		if sTargetRecordType ~= "item" then
			for _,vItem in pairs(DB.getChildren(nodeList, "")) do
				if ItemManager.compareFields(vItem, nodeTemp, true) then
					nodeNew = vItem;
					bAppend = true;
					break;
				end
			end
		end
		if not nodeNew then
			nodeNew = DB.createChild(nodeList);
			DB.copyNode(nodeTemp, nodeNew);
		end

		-- Determine the source, target and item names
		local sSrcName, sTrgtName;
		if sSourceRecordType == "charsheet" then
			sSrcName = DB.getValue(nodeSource, "...name", "");
		elseif sSourceRecordType == "partysheet" then
			sSrcName = "PARTY";
		else
			sSrcName = "";
		end
		if sTargetRecordType == "charsheet" then
			sTrgtName = DB.getValue(nodeNew, "...name", "");
		elseif sTargetRecordType == "partysheet" then
			sTrgtName = "PARTY";
		else
			sTrgtName = "";
		end
		local sItemName = ItemManager.getDisplayName(nodeNew, true);

		-- Determine whether to copy all items at once or just one item at a time (based on source and target)

		local nCount = 1;
		if nTransferCount then
			nCount = nTransferCount;
		end
		if bAppend then
			local nAppendCount = math.max(DB.getValue(nodeNew, "count", 1), 1);
			DB.setValue(nodeNew, "count", "number", nCount + nAppendCount);
		else
			DB.setValue(nodeNew, "count", "number", nCount);
		end

		-- If not adding to an existing record, then lock the new record and generate events
		if not bAppend then
			DB.setValue(nodeNew, "locked", "number", 1);
			if sTargetRecordType == "charsheet" then
				ItemManager.onCharAddEvent(nodeNew);
			end
		end

		-- Generate output message if transferring between characters or between party sheet and character
		if sSourceRecordType == "charsheet" and (sTargetRecordType == "partysheet" or sTargetRecordType == "charsheet") then
			local msg = {font = "msgfont", icon = "coins"};
			msg.text = "[" .. sSrcName .. "] -> [" .. sTrgtName .. "] : " .. sItemName;
			if nCount > 1 then
				msg.text = msg.text .. " (" .. nCount .. "x)";
			end
			Comm.deliverChatMessage(msg);

			local nCharCount = DB.getValue(nodeSource, "count", 0);
			if nCharCount <= nCount then
				ItemManager.onCharRemoveEvent(nodeSource);
				nodeSource.delete();
			else
				DB.setValue(nodeSource, "count", "number", nCharCount - nCount);
			end
		elseif sSourceRecordType == "partysheet" and sTargetRecordType == "charsheet" then
			local msg = {font = "msgfont", icon = "coins"};
			msg.text = "[" .. sSrcName .. "] -> [" .. sTrgtName .. "] : " .. sItemName;
			if nCount > 1 then
				msg.text = msg.text .. " (" .. nCount .. "x)";
			end
			Comm.deliverChatMessage(msg);

			local nPartyCount = DB.getValue(nodeSource, "count", 0);
			if nPartyCount <= nCount then
				nodeSource.delete();
			else
				DB.setValue(nodeSource, "count", "number", nPartyCount - nCount);
			end
		end
	end

	-- Clean up
	DB.deleteNode(sTempPath);

	return nodeNew;
end

function calcItemArmorClass(nodeChar)
	local nMainArmorTotal = 0;
	local nNaturalArmorTotal = 0;
	local nMainShieldTotal = 0;
	local sMainDexBonus = "";
	local nMainStealthDis = 0;
	local nMainStrRequired = 0;

	local nodeNaturalArmor = CharManager.getTraitRecord(nodeChar, CharManager.TRAIT_NATURAL_ARMOR);
	if nodeNaturalArmor then
		local sNaturalArmorDesc = DB.getText(nodeNaturalArmor, "text", ""):lower();
		if sNaturalArmorDesc:match("your dexterity modifier doesn't affect this number") then
			sMainDexBonus = "no";
		end
		local sNaturalArmorTotal = sNaturalArmorDesc:match("your ac is (%d+)");
		if not sNaturalArmorTotal then
			sNaturalArmorTotal = sNaturalArmorDesc:match("base ac of (%d+)");
		end
		if sNaturalArmorTotal then
			nNaturalArmorTotal = (tonumber(sNaturalArmorTotal) or 10) - 10;
		end
	end
	local nodeDragonHide = CharManager.getFeatRecord(nodeChar, CharManager.FEAT_DRAGON_HIDE);
	if nodeDragonHide then
		local sNaturalArmorDesc = DB.getText(nodeDragonHide, "text", ""):lower();
		local sNaturalArmorTotal = sNaturalArmorDesc:match("your ac as (%d+)");
		if sNaturalArmorTotal then
			local nNewNaturalArmorTotal = (tonumber(sNaturalArmorTotal) or 10) - 10;
			nNaturalArmorTotal = math.max(nNaturalArmorTotal, nNewNaturalArmorTotal);
		end
	end

	for _,vNode in pairs(DB.getChildren(nodeChar, "inventorylist")) do
		if DB.getValue(vNode, "carried", 0) == 2 then
			local bIsArmor, _, sSubtypeLower = ItemManager2.isArmor(vNode);
			if bIsArmor then
				local bID = LibraryData.getIDState("item", vNode, true);

				local bIsShield = (sSubtypeLower == "shield");
				if bIsShield then
					if bID then
						nMainShieldTotal = nMainShieldTotal + DB.getValue(vNode, "ac", 0) + DB.getValue(vNode, "bonus", 0);
					else
						nMainShieldTotal = nMainShieldTotal + DB.getValue(vNode, "ac", 0);
					end
				else
					local bLightArmor = false;
					local bMediumArmor = false;
					local bHeavyArmor = false;
					local sSubType = DB.getValue(vNode, "subtype", "");
					if sSubType:lower():match("^heavy") then
						bHeavyArmor = true;
					elseif sSubType:lower():match("^medium") then
						bMediumArmor = true;
					else
						bLightArmor = true;
					end

					if bID then
						nMainArmorTotal = nMainArmorTotal + (DB.getValue(vNode, "ac", 0) - 10) + DB.getValue(vNode, "bonus", 0);
					else
						nMainArmorTotal = nMainArmorTotal + (DB.getValue(vNode, "ac", 0) - 10);
					end

					if sMainDexBonus ~= "no" then
						local sItemDexBonus = DB.getValue(vNode, "dexbonus", ""):lower();
						if sItemDexBonus:match("yes") then
							local nMaxBonus = tonumber(sItemDexBonus:match("max (%d)")) or 0;
							if nMaxBonus == 2 then
							elseif nMaxBonus == 3 then
								if sMainDexBonus == "" then
									sMainDexBonus = "max3";
								end
							end
						else
							sMainDexBonus = "no";
						end
					end

					local sItemStealth = DB.getValue(vNode, "stealth", ""):lower();
					local sItemStrength = StringManager.trim(DB.getValue(vNode, "strength", "")):lower();
					local nItemStrRequired = tonumber(sItemStrength:match("str (%d+)")) or 0;
					if nItemStrRequired > 0 then
						nMainStrRequired = math.max(nMainStrRequired, nItemStrRequired);
					end
				end
			end
		end
	end

	nMainArmorTotal = math.max(nMainArmorTotal, nNaturalArmorTotal);

	DB.setValue(nodeChar, "defenses.ac.armor", "number", nMainArmorTotal);
	DB.setValue(nodeChar, "defenses.ac.shield", "number", nMainShieldTotal);
	DB.setValue(nodeChar, "defenses.ac.dexbonus", "string", sMainDexBonus);
	DB.setValue(nodeChar, "defenses.ac.disstealth", "number", nMainStealthDis);
end

function applyUnarmoredDefense(nodeChar, nodeClass)
	local sAbility = "";
	local sClassLower = DB.getValue(nodeClass, "name", ""):lower();
	if sClassLower == CharManager.CLASS_BARBARIAN then
		sAbility = "constitution";
	elseif sClassLower == CharManager.CLASS_MONK then
		sAbility = "wisdom";
	end

	if (sAbility ~= "") and (DB.getValue(nodeChar,  "defenses.ac.stat2", "") == "") then
		DB.setValue(nodeChar, "defenses.ac.stat2", "string", sAbility);
	end
end

