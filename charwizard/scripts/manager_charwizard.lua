--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

local sAbilityGenMethod = "";
local aAbilityGenScores = {};

--
-- Wizard Utility
--

function getWizardWindow()
	local window = Interface.findWindow("charwizard", "");
	return window;
end

function impCharacter(nodeChar)
	local wndWizard = CharWizardManager.getWizardWindow()

	wndWizard.import = 1;

	wndWizard.summary.subwindow.summary_identity.setValue(nodeChar.getPath());
	wndWizard.name.setValue(DB.getValue(nodeChar, "name", ""));
	wndWizard.summary.subwindow.summary_name.setValue(DB.getValue(nodeChar, "name", ""));
	wndWizard.summary.subwindow.summary_race.setValue(StringManager.titleCase(DB.getValue(nodeChar, "race", "")));
	wndWizard.summary.subwindow.summary_background.setValue(StringManager.titleCase(DB.getValue(nodeChar, "background", "")));
	wndWizard.summary.subwindow.summary_senses.setValue(DB.getValue(nodeChar, "senses", ""));
	wndWizard.summary.subwindow.summary_size.setValue(DB.getValue(nodeChar, "size", ""));
	wndWizard.summary.subwindow.summary_speed.setValue(DB.getValue(nodeChar, "speed.total", ""));
	wndWizard.summary.subwindow.summary_speedspecial.setValue(DB.getValue(nodeChar, "speed.special", ""));

	wndWizard.charwizard_racetab.setVisible(false);
	wndWizard.race_alert.setVisible(false);
	wndWizard.race_GateCheck.setVisible(false);
	wndWizard.ability_alert.setVisible(false);
	wndWizard.ability_GateCheck.setVisible(false);
	wndWizard.class_alert.setVisible(false);
	wndWizard.class_GateCheck.setVisible(false);
	wndWizard.charwizard_backtab.setVisible(false);
	wndWizard.background_alert.setVisible(false);
	wndWizard.background_GateCheck.setVisible(false);
	wndWizard.charwizard_invtab.setVisible(false);
	wndWizard.charwizard_spelltab.setVisible(true);
	wndWizard.charwizard_feattab.setVisible(true);
	wndWizard.summary.subwindow.summary_genmethod.setVisible(false);
	wndWizard.summary.subwindow.summarytitle.setValue("LEVEL UP SUMMARY")
	wndWizard.tabs.activateTab(3);

	for k,vAbilityScore in pairs(DB.getChildren(nodeChar, "abilities", "")) do
		if k == "strength" then
			wndWizard.summary.subwindow.summary_base_strength.setValue(DB.getValue(vAbilityScore, "score", 0));
		elseif k == "dexterity" then
			wndWizard.summary.subwindow.summary_base_dexterity.setValue(DB.getValue(vAbilityScore, "score", 0));
		elseif k == "constitution" then
			wndWizard.summary.subwindow.summary_base_constitution.setValue(DB.getValue(vAbilityScore, "score", 0));
		elseif k == "intelligence" then
			wndWizard.summary.subwindow.summary_base_intelligence.setValue(DB.getValue(vAbilityScore, "score", 0));
		elseif k == "wisdom" then
			wndWizard.summary.subwindow.summary_base_wisdom.setValue(DB.getValue(vAbilityScore, "score", 0));
		elseif k == "charisma" then
			wndWizard.summary.subwindow.summary_base_charisma.setValue(DB.getValue(vAbilityScore, "score", 0));
		end
	end

	wndWizard.calcSummaryStats();

	for _,vSkills in pairs(DB.getChildren(nodeChar, "skilllist")) do
		if DB.getValue(vSkills, "prof", 0) > 0 then
			local wSkill = wndWizard.summary.subwindow.summary_skills.createWindow();

			wSkill.name.setValue(DB.getValue(vSkills, "name", ""));
			wSkill.type.setValue("imported");

			if DB.getValue(vSkills, "prof", 0) == 2 then
				wSkill.expertise.setValue(1);
			end

			wndWizard.summary.subwindow.summary_skills.applySort();
		end
	end

	for _,vProfs in pairs(DB.getChildren(nodeChar, "proficiencylist")) do
		local wProf = wndWizard.summary.subwindow.summary_proficiencies.createWindow();

		wProf.name.setValue(DB.getValue(vProfs, "name", ""));
		wProf.type.setValue("imported");
		wndWizard.proficiencies_class[StringManager.trim(DB.getValue(vProfs, "name", "")):lower()] = { type = "imported", expertise = 0 };

		wndWizard.summary.subwindow.summary_skills.applySort();
	end

	for k,vClass in pairs(DB.getChildren(nodeChar, "classes")) do
		local sClassName = DB.getValue(vClass, "name", ""):lower();
		local sClassRef, sClassRecord = DB.getValue(vClass, "shortcut", "");

		wndClass = wndWizard.summary.subwindow.summary_class.createWindow();
		wndClass.name.setValue(StringManager.titleCase(sClassName));
		wndClass.link.setValue(DB.getValue(vClass, "shortcut", ""));
		wndClass.classlevel.setValue(tostring(DB.getValue(vClass, "level", "")));
		wndClass.classlevel.setVisible(true);
		wndClass.import.setValue(1);

		local tFeatures = {};
		for _,v in pairs(DB.getChildren(nodeChar, "featurelist")) do
			tFeatures[StringManager.trim(DB.getValue(v, "name", "")):lower()] = v;
		end

		local tClassSpecOptions = CharManager.getClassSpecializationOptions(DB.findNode(sClassRecord));
		for _,v in pairs(tClassSpecOptions) do
			if tFeatures[StringManager.trim(v.text):lower()] then
				wndSpecialization = wndWizard.summary.subwindow.summary_specialization.createWindow();
				wndSpecialization.name.setValue(StringManager.titleCase(v.text));
				wndSpecialization.classlevel.setVisible(false);
				wndSpecialization.classlevel.setValue(sClassName);
				wndSpecialization.link.setValue(v.linkclass, v.linkrecord);
				break;
			end
		end
	end

	for _,vPower in pairs(DB.getChildren(nodeChar, "powers", "")) do
		local sPowerName = DB.getValue(vPower, "name", "");
		local sSanPowerName = CampaignDataManager2.sanitize(sPowerName):lower();
		local sSchool =	DB.getValue(vPower, "school", "");
		local sGroup = DB.getValue(vPower, "group", "");

		local aCasters = CharWizardData.getCasterClasses();
		if sSchool ~= "" or sSource ~= "" then
			if wndWizard.loaded_spells[DB.getValue(vPower, "name", ""):lower()] then
				local sSource = "";

				for k,_ in pairs(aCasters) do
					if sGroup:lower():match(k) then
						sSource = k;

						break
					end
				end

				if sSource == "" then
					sSource = "Innate";
				end

				wndWizard.impspells[DB.getValue(vPower, "name", ""):lower()] = { class = "reference_spell", record = wndWizard.loaded_spells[DB.getValue(vPower, "name", ""):lower()].record, source = StringManager.titleCase(sSource), window = vPower, delete = false };
				table.insert(wndWizard.spelllist, {class = "reference_spell", record = wndWizard.loaded_spells[DB.getValue(vPower, "name", ""):lower()].record, source = StringManager.titleCase(sSource), window = vPower});
			end
		end
	end

	wndWizard.checkFeatSpellInv();
end

function setAbilityScores(sMethod, aAbilityScores)
	sAbilityGenMethod = sMethod;
	aAbilityScores = aAbilityScores or {};

	updateSummary();
end

function updateSummary()
	local wWizard = getWizardWindow();
	local wSummary = wWizard.summary_subwindow.subwindow;
	wSummary.update();
end

function closeListWindowsMatch(wList, sMatch)
	local tCloseWin = {};
	for _,v in pairs(wList.getWindows()) do
		if v.group_name.getValue():match(sMatch) then
			table.insert(tCloseWin, v);
		end
	end
	for _,v in pairs(tCloseWin) do
		v.close();
	end
end

function closeListWindowsExcept(wList, tTitles)
	local tCloseWin = {};
	for _,v in pairs(wList.getWindows()) do
		local sGroup = v.group_name.getValue();
		local bMatch = false;
		for _,sTitle in ipairs(tTitles) do
			if (sGroup == sTitle) or (sGroup == "SELECT " .. sTitle) then
				bMatch = true;
			end
		end
		if not bMatch then
			table.insert(tCloseWin, v);
		end
	end
	for _,v in pairs(tCloseWin) do
		v.close();
	end
end

function onSelectionChange(wSelection, sLinkClass, sLinkPath)
	local sGroup = wSelection.group_name.getValue();
	local nCount = wSelection.selection_count.getValue();
	if nCount <= 0 then
		if sGroup:match("^SELECT ") then
			wSelection.group_name.setValue(sGroup:gsub("^SELECT ", ""));
		end
		
		local tSelections = {};
		for _,v in pairs(wSelection.selection_window.getWindows()) do
			if v.value.getValue() == "1" then
				table.insert(tSelections, v.name.getValue())
			end
		end
		local sName = table.concat(tSelections, ", ");

		CharWizardManager.completeSelection(wSelection, sName, sLinkClass, sLinkPath);
	else
		local sGroup = wSelection.group_name.getValue();
		if not sGroup:match("^SELECT ") then
			wSelection.group_name.setValue("SELECT " .. sGroup);
		end
		wSelection.selection_name.setValue("CHOICES:");
	end
end

function completeSelection(wSelection, sSelectionName, sLinkClass, sLinkPath)
	wSelection.selection_name.setValue(StringManager.titleCase(sSelectionName));
	wSelection.selection_name.setVisible(true);
	wSelection.selection_window.setVisible(false);
	wSelection.button_expand.setValue(0);

	if sLinkClass and sLinkPath then
		wSelection.selection_shortcut.setValue(sLinkClass, sLinkPath);
		wSelection.selection_shortcut.setVisible(true);
	end
end

function createSelectionWindows(wList, sType, aSelections, nChoices, bShortcut)
	local w = wList.createWindow();
	local aSortSelections = {};

	for k,v in pairs(aSelections) do
		table.insert(aSortSelections, k);
	end

	table.sort(aSortSelections);
	w.group_name.setValue(sType);

	if nChoices > 1 then
		w.selection_name.setValue("CHOICES:");
		w.selection_name.setVisible(true);
		w.selection_count.setValue(nChoices);
		w.selection_count.setVisible(true);
	end

	w.button_expand.setValue(1);

	for _,v in ipairs(aSortSelections) do
		local wndSubwindow = w.selection_window.createWindow();

		wndSubwindow.name.setValue(v);
		wndSubwindow.bname.setText(StringManager.titleCase(v));
		wndSubwindow.bname.setTooltipText(aSelections[v].tooltip);

		if bShortcut then
			wndSubwindow.shortcut.setValue(aSelections[v].class, aSelections[v].record);
			wndSubwindow.shortcut.setVisible(true);
		end

		if aSelections[v].count then
			wndSubwindow.count.setValue(aSelections[v].count);
		end
	end

	wList.applySort();

	return w
end

function parseSelection(wList, wSelection, sSelectionGroup, sSelectionName, bIncrease, sSelectionClass, sSelectionRecord)
	local nodeSource = "";
	if sSelectionRecord then
		nodeSource = DB.findNode(sSelectionRecord);
	end

	local wndSummary = UtilityManager.getTopWindow(wSelection);
	local sType = wList.getName():gsub("_window", "");

	local sSelectionKey = sSelectionGroup:gsub("^SELECT ", "");
	sSelectionName = StringManager.trim(sSelectionName)

	if sType == "race" then
		if sSelectionKey == "RACE" then
			parseSelectRace(wndSummary, wList, wSelection, nodeSource);
		elseif sSelectionKey == "RACE OPTION" then
			parseSelectSubRace(wndSummary, wList, wSelection, nodeSource);
		elseif sSelectionKey == "RACIAL MODIFIERS" then
			parseRacialModChoice(wSelection, wList, sSelectionName, wndSummary);
		elseif sSelectionKey:match("CHOICE RACIAL MOD") then
			parseChoiceRacialMod(wSelection, wList, sSelectionName, wndSummary, bIncrease);
		elseif sSelectionKey == "TOOL PROFICIENCY" then
			parseSelectRaceToolProficiency(wSelection, wList, sSelectionName, wndSummary)
		elseif sSelectionKey == "SKILL PROFICIENCY" then
			parseSelectRaceSkillProficiency(wSelection, wList, sSelectionName, wndSummary, bIncrease)
		elseif sSelectionKey == "LANGUAGES" then
			parseSelectRaceLanguage(wSelection, wList, sSelectionName, wndSummary, bIncrease)
		elseif sSelectionKey == "SPELL" then
			parseSelectRaceSpell(wSelection, wList, nodeSource, wndSummary, bIncrease)
		elseif sSelectionKey == "SIZE" then
			parseSelectSize(wSelection, wList, sSelectionName, wndSummary, bIncrease)
		elseif sSelectionKey == "VARIABLE TRAIT" then
			parseSelectVariableTrait(wSelection, wList, sSelectionName, wndSummary, bIncrease)
		end

		CharWizardManager.getAlerts(wndSummary, wList)
	elseif sType == "class" then
		if sSelectionKey == "CLASS" then
			parseClass(wSelection, wList, wndSummary, sSelectionName, nodeSource);
		elseif sSelectionKey == "MULTICLASS" then
			parseClass(wSelection, wList, wndSummary, sSelectionName, nodeSource, true)
		elseif sSelectionKey:match("SKILL PROFICIENCY") then
			parseClassSkillProficiency(wSelection, wList, sSelectionName, wndSummary, bIncrease);
		elseif sSelectionKey:match("TOOL PROFICIENCY") then
			parseClassToolProficiency(wSelection, wList, sSelectionName, wndSummary, bIncrease);
		elseif sSelectionKey:match("SPECIALIZATION") then
			parseSpecialization(wSelection, wList, wndSummary, nodeSource, sSelectionName, sSelectionClass);
		elseif sSelectionKey:match("EXPERTISE") then
			parseExpertise(wSelection, wList, wndSummary, sSelectionName);
		elseif sSelectionKey:match("ASI CHOICE") then
			parseASIChoice(wSelection, wList, wndSummary, nodeSource, sSelectionName);
		end

		CharWizardManager.getAlerts(wndSummary, wList)
	elseif sType == "background" then
		if sSelectionKey == "BACKGROUND" then
			parseBackground(wSelection, wList, wndSummary, sSelectionName, nodeSource)
		elseif sSelectionKey == "SKILL PROFICIENCY" then
			parseBackgroundSkillProf(wSelection, wndSummary, sSelectionName, bIncrease, nodeSource)
		elseif sSelectionKey == "LANGUAGES" then
			parseBackgroundLanguage(wSelection, sSelectionName, wndSummary, bIncrease)
		elseif sSelectionKey == "TOOL PROFICIENCY" then
			parseBackgroundToolProf(wSelection, wndSummary, sSelectionName, bIncrease, nodeSource)
		end

		CharWizardManager.getAlerts(wndSummary, wList)
	elseif sType == "kitlist" then
		local nodeSource = DB.findNode(sSelectionRecord);
		local _,sOldRecord = wSelection.selection_shortcut.getValue();

		CharWizardManager.completeSelection(wSelection, sSelectionName, sSelectionClass, sSelectionRecord);

		for k,v in pairs(wndSummary.inventory) do
			if v.record == sOldRecord then
				table.remove(wndSummary.inventory, k);
				break
			end
		end

		if sSelectionGroup:match("BACKGROUND") then
			table.insert(wndSummary.inventory, {record = sSelectionRecord, carried = 0, count = 1, source = "background"})
		else
			table.insert(wndSummary.inventory, {record = sSelectionRecord, carried = 0, count = 1, source = "class"})
		end
	elseif sType == "feat" then
		if sSelectionGroup:match("FEAT") then
			parseFeat(wndSummary, wList, sSelectionGroup, sSelectionName, sSelectionRecord, wSelection)
		elseif sSelectionGroup:match("ABILITY") then
			parseFeatAbilitySelect(wndSummary, wList, sSelectionGroup, sSelectionName, sSelectionRecord, wSelection);
		end

		CharWizardManager.getAlerts(wndSummary, wList)
	elseif sType == "abilityscore_improvements" then
		local nCount = wSelection.selection_count.getValue();

		local aMods = {};
		for k,v in pairs(wSelection.selection_window.getWindows()) do
			if v.value.getValue() == "1" then
				table.insert(aMods, v.name.getValue())
			end
		end

		local sName = table.concat(aMods, ", ")
		wSelection.selection_name.setValue(StringManager.titleCase(sName));
		wSelection.selection_name.setVisible(true);

		if nCount == 0 then
			wSelection.selection_window.setVisible(false);
			wSelection.button_expand.setValue(0);
		end

		wndSummary.calcSummaryStats();
	end
end

function getAlerts(wndSummary, wList)
	local aAlerts = {};
	for _,vAlert in pairs(wList.getWindows()) do
		if (vAlert.selection_name.getValue() == "" or vAlert.selection_name.getValue() == "CHOICES:") and vAlert.group_name.getValue() ~= "SELECT MULTICLASS" then
			table.insert(aAlerts, vAlert.group_name.getValue());
		end
	end

	local aFinalAlerts = {};
	local aDupes = {};
	for _,v in ipairs(aAlerts) do
		if not aDupes[v] then
			table.insert(aFinalAlerts, v);
			aDupes[v] = true;
		end
	end

	if aFinalAlerts then
		local sType = wList.getName():gsub("_window", "");

		wndSummary.updateAlerts(aFinalAlerts, sType);
	end

	return aFinalAlerts
end

function clearSummary(wndSummary, sType, sSubType, nLevel)
	if sType == "race" and sSubType == "all" then
		wndSummary.summary.subwindow.summary_size.setValue(nil)
		wndSummary.summary.subwindow.summary_speed.setValue(nil)
		wndSummary.summary.subwindow.summary_speedspecial.setValue(nil)
		wndSummary.summary.subwindow.summary_senses.setValue(nil)
	end

	local aCloseWin = {};
	if sSubType == "languages" or sSubType == "all" then
		local aLangSubType = wndSummary.summary.subwindow.summary_languages.getWindows();

		for _,v in pairs(aLangSubType) do
			if v.type.getValue() == sType then
				table.insert(aCloseWin, v)
			end
		end
	end
	if sSubType == "skills" or sSubType == "all" then
		local aSkillSubType = wndSummary.summary.subwindow.summary_skills.getWindows();

		for _,v in pairs(aSkillSubType) do
			if v.type.getValue() == sType then
				table.insert(aCloseWin, v)
			end
		end
	end

	if sSubType == "toolproficiency" or sSubType == "all" then
		local aNewProfList = {};
		local sProfSummaryList = "";

		if not StringManager.contains({"race", "background"}, sType:gsub("_choice", "")) then
			sProfSummaryList = "proficiencies_class";
		else
			sProfSummaryList = "proficiencies_" .. sType:gsub("_choice", "");
		end

		for k,v in pairs(wndSummary[sProfSummaryList]) do
			if v.type ~= sType then
				aNewProfList[k] = v;
			end
		end

		wndSummary[sProfSummaryList] = aNewProfList;
		wndSummary.updateProficiencies();
	end
	if sSubType == "traits" or sSubType == "all" then
		local aTraitSubType = wndSummary.summary.subwindow.summary_traits.getWindows();

		for _,v in pairs(aTraitSubType) do
			if v.type.getValue() == sType then
				table.insert(aCloseWin, v)
			end
		end
	end
	if sSubType == "features" or sSubType == "all" then
		local aTraitSubType = wndSummary.summary.subwindow.summary_features.getWindows();

		for _,v in pairs(aTraitSubType) do
			if v.type.getValue() == sType then
				local _,sFeatureRecord = v.link.getValue();
				local nFeatureLevel = DB.getValue(DB.findNode(sFeatureRecord), "level", 0);

				if nFeatureLevel >= nLevel then
					table.insert(aCloseWin, v)
				end
			end
		end
	end
	if sSubType == "specialization" or sSubType == "all" then
		local aTraitSubType = wndSummary.summary.subwindow.summary_specialization.getWindows();

		for _,v in pairs(aTraitSubType) do
			if v.name.getValue():lower() == sType then
				table.insert(aCloseWin, v)
			end
		end
	end

	for _,v in pairs(aCloseWin) do
		v.close()
	end
end

function getShortcutToolTip(node, sName)
	local sTooltip = "";

	if node.getModule() == nil then
		sTooltip = StringManager.titleCase(sName) .. ": Campaign";
	else
		sTooltip = StringManager.titleCase(sName) .. ": " .. node.getModule();
	end

	return sTooltip;
end

function cleanupText(s)
	local sSanitized = s:gsub("[%(%)%.%+%-%*%?,:'’/–]", "_"):gsub("%s", ""):lower();
	return sSanitized
end

--
-- Race
--

function clearRacialAbilityMods(wndSummary)
	wndSummary.summary.subwindow.summary_race_strength.setValue(0);
	wndSummary.summary.subwindow.summary_race_dexterity.setValue(0);
	wndSummary.summary.subwindow.summary_race_constitution.setValue(0);
	wndSummary.summary.subwindow.summary_race_intelligence.setValue(0);
	wndSummary.summary.subwindow.summary_race_wisdom.setValue(0);
	wndSummary.summary.subwindow.summary_race_charisma.setValue(0);
end

function getDefaultRaceMods(wList)
	local sRacePath, sSubRacePath;
	for _,w in pairs(wList.getWindows()) do
		local sGroup = w.group_name.getValue();
		if sGroup == "RACE" then
			_,sRacePath = w.selection_shortcut.getValue();
		elseif sGroup == "RACE OPTION" then
			_,sSubRacePath = w.selection_shortcut.getValue();
		end
	end

	local aRaceIncreases, aSubRaceIncreases;
	if sRacePath then
		local raw = DB.getChild(sRacePath, "abilityscoreincrease");
		if raw then
			aRaceIncreases = CharWizardManager.getDefaultRaceMod(raw:getText());
		end
	end
	if sSubRacePath then
		local raw = DB.getChild(sSubRacePath, "abilityscoreincrease");
		if raw then
			aSubRaceIncreases = CharWizardManager.getDefaultRaceMod(raw:getText());
		end
	end

	local tFinalIncreases = {};

	if aRaceIncreases then
		for k,v in pairs(aRaceIncreases) do
			table.insert(tFinalIncreases, v)
		end
	end
	if aSubRaceIncreases then
		for k,v in pairs(aSubRaceIncreases) do
			table.insert(tFinalIncreases, v)
		end
	end

	return tFinalIncreases;
end

function getDefaultRaceMod(sAdjust)
	local aIncreases = {};

	local a1, a2, sIncrease = sAdjust:match("either (%w+) or (%w+) to improve by %+(%d+)");

	if a2 then
		local nIncrease = tonumber(sIncrease) or 0;

		table.insert(aIncreases, {stat = a1, increase = nIncrease});
		table.insert(aIncreases, {stat = a2, increase = nIncrease});
	end

	return aIncreases;
end

function parseSelectRace(wndSummary, wList, wSelection, nodeSource)
	local sSelectionName = DB.getValue(nodeSource, "name", ""):lower();

	CharWizardManager.clearSummary(wndSummary, "race", "all");
	CharWizardManager.clearSummary(wndSummary, "race_choice", "all");

	if wndSummary.genfeats.subwindow then
		for _,v in pairs(wndSummary.genfeats.subwindow.contents.subwindow.feat_window.getWindows()) do
			if v.group_name.getValue():lower():match("race") then
				v.close();
			end
		end
	end

	CharWizardManager.closeListWindowsExcept(wList, { "RACE" });
	CharWizardManager.onSelectionChange(wSelection, "reference_race", nodeSource.getPath());

	wndSummary.summary.subwindow.summary_race.setValue(StringManager.titleCase(sSelectionName));
	wndSummary.summary.subwindow.summary_race_link.setValue("reference_race", nodeSource.getPath());

	local tRaceSubraces = CharManager.getRaceSubraceOptions(nodeSource);
	if #tRaceSubraces > 0 then
		local aSubraceOptions = {};
		for _,v in pairs(tRaceSubraces) do
			local sSpecName = v.text:lower();
			local sModule = v.linkrecord:match("[^@]*@(.+)") or "Campaign";
			local sTooltip = string.format("%s: %s", v.text, sModule);

			aSubraceOptions[sSpecName] = { tooltip = sTooltip, class = v.linkclass, record = v.linkrecord };
		end

		CharWizardManager.createSelectionWindows(wList, "SELECT RACE OPTION", aSubraceOptions, 1, true);
	else
		local aRacialModifiers = {};
		local bDefault = false;

		--[[aRacialModifiers["default"] = { tooltip = Interface.getString("charwizard_tooltip_raceability_default") };
		aRacialModifiers["option 2"] = { tooltip = Interface.getString("charwizard_tooltip_raceability_option2") };

		wndSummary.summary.subwindow.summary_subrace_link.setValue("none");
		CharWizardManager.createSelectionWindows(wList, "SELECT RACIAL MODIFIERS", aRacialModifiers, 1);--]]
		local bDefault = CharWizardManager.applyRacialAbilityDefault(wndSummary, wList);
		if not bDefault  then
			aRacialModifiers["choice 1"] = { tooltip = Interface.getString("charwizard_tooltip_raceability_choice1") };
			aRacialModifiers["choice 2"] = { tooltip = Interface.getString("charwizard_tooltip_raceability_choice2") };

			wndSummary.summary.subwindow.summary_subrace_link.setValue("none");
			CharWizardManager.createSelectionWindows(wList, "SELECT RACIAL MODIFIERS", aRacialModifiers, 1);
		end

		CharWizardManager.updateRace(wndSummary, wList, nodeSource);

		if wndSummary.genfeats.subwindow then
			for _,v in pairs(wndSummary.genfeats.subwindow.contents.subwindow.feat_window.getWindows()) do
				if v.group_name.getValue():lower() == "race feat" then
					v.close();
				end
			end

			if StringManager.contains({"human-variant", "custom lineage"}, sSelectionName:lower()) then
				wndSummary.genfeats.subwindow.contents.subwindow.feat_window.createRaceFeatWindow();
			end
		end

		wndSummary.checkFeatSpellInv();
	end

	CharWizardManager.calcRacialAbilityMods(wndSummary, wList);
end

function parseSelectSubRace(wndSummary, wList, wSelection, nodeSource)
	CharWizardManager.closeListWindowsExcept(wList, { "RACE", "RACE OPTION" });
	CharWizardManager.onSelectionChange(wSelection, "reference_subrace", nodeSource.getPath());

	local sRaceRecord;
	for _,w in pairs(wList.getWindows()) do
		if w.group_name.getValue() == "RACE" then
			_,sRaceRecord = w.selection_shortcut.getValue();
		end
	end

	local bDefault = CharWizardManager.applyRacialAbilityDefault(wndSummary, wList);
	if not bDefault  then
		local tRacialModifiers = {};
		tRacialModifiers["choice 1"] = { tooltip = Interface.getString("charwizard_tooltip_raceability_choice1") };
		tRacialModifiers["choice 2"] = { tooltip = Interface.getString("charwizard_tooltip_raceability_choice2") };

		wndSummary.summary.subwindow.summary_subrace_link.setValue("none");
		CharWizardManager.createSelectionWindows(wList, "SELECT RACIAL MODIFIERS", tRacialModifiers, 1);
	end

	CharWizardManager.clearSummary(wndSummary, "race", "all");
	CharWizardManager.clearSummary(wndSummary, "race_choice", "all");
	CharWizardManager.updateRace(wndSummary, wList, DB.findNode(sRaceRecord), nodeSource);

	local sRaceName = DB.getValue(DB.findNode(sRaceRecord), "name", "");
	local sSubRaceName = DB.getValue(nodeSource, "name", "");
	wndSummary.summary.subwindow.summary_race.setValue(sRaceName .. " (" .. sSubRaceName .. ")");
	wndSummary.summary.subwindow.summary_subrace_link.setValue("reference_subrace", nodeSource.getPath());

	wndSummary.checkFeatSpellInv();

	CharWizardManager.calcRacialAbilityMods(wndSummary, wList);
end

function parseRacialModChoice(wSelection, wList, sSelectionName, wndSummary)
	CharWizardManager.closeListWindowsMatch(wList, "CHOICE RACIAL MOD");
	CharWizardManager.onSelectionChange(wSelection);

	if sSelectionName == "choice 1" then
		CharWizardManager.applyRacialAbilityOption1(wndSummary, wList);
	elseif sSelectionName == "choice 2" then
		CharWizardManager.applyRacialAbilityOption2(wndSummary, wList, aChoices);
	end

	CharWizardManager.calcRacialAbilityMods(wndSummary, wList);
end

function applyRacialAbilityDefault(wndSummary, wList)
	local aRaceIncreases = CharWizardManager.getDefaultRaceMods(wList);

	local tSelectChoices = {};

	for _,v in pairs(aRaceIncreases) do
		tSelectChoices[v.stat] = { tooltip = "Select Ability to increase." };
	end

	local tFinalChoices = {};
	local tFinalDefaults = {};
	local increaseAmount = 2; -- Hardcoding this for now

	for k,v in pairs(aRaceIncreases) do
		tFinalChoices[v.increase] = 1;

		if v.stat ~= "any" then
			tFinalDefaults[v.stat] = v.increase;
		end
	end

	for k,v in pairs(tFinalChoices) do
		CharWizardManager.createSelectionWindows(wList, "SELECT CHOICE RACIAL MOD +" ..  increaseAmount, tSelectChoices, 1);
	end

	for _,vModWin in pairs(wList.getWindows()) do
		if vModWin.group_name.getValue():lower():match("select choice racial mod") then
			local sIncrease = vModWin.group_name.getValue():lower():match("select choice racial mod %+(%d+)");
			local nIncrease = tonumber(sIncrease);

			for k,v in pairs(tFinalDefaults) do
				if v == nIncrease then
					for _,vMod in pairs(vModWin.selection_window.getWindows()) do
						if vMod.name.getValue():lower() == k then
							vMod.bname.onButtonPress();
							break
						end
					end
				end
			end
		end
	end

	return true
end

function applyRacialAbilityOption1(wndSummary, wList, aChoices)
	local aChoices = {};
	for _,i in pairs(DataCommon.abilities) do
		aChoices[i] = { tooltip = "Select Ability to increase." };
	end

	CharWizardManager.createSelectionWindows(wList, "SELECT CHOICE RACIAL MOD +2", aChoices, 1);
	CharWizardManager.createSelectionWindows(wList, "SELECT CHOICE RACIAL MOD +1", aChoices, 1);
end

function applyRacialAbilityOption2(wndSummary, wList, aChoices)
	local aChoices = {};
	for _,i in pairs(DataCommon.abilities) do
		aChoices[i] = { tooltip = "Select Ability to increase." };
	end

	CharWizardManager.createSelectionWindows(wList, "SELECT CHOICE RACIAL MOD +1", aChoices, 3);
end

function parseChoiceRacialMod(wSelection, wList, sSelectionName, wndSummary, bIncrease)
	CharWizardManager.onSelectionChange(wSelection);
	local aChoices = {};
	local aChoiceWin = {};

	for _,w in pairs(wList.getWindows()) do
		local sGroup = w.group_name.getValue();
		if sGroup:match("CHOICE RACIAL MOD") then
			for _,wMod in pairs(w.selection_window.getWindows()) do
				if wMod.value.getValue() == "1" then
					aChoices[wMod.name.getValue():lower()] = w;
				else
					wMod.close();
				end
			end
			aChoiceWin[w] = w;
		end
	end

	local aRaceIncreases = CharWizardManager.getDefaultRaceMods(wList);
	for _,wChoice in pairs(aChoiceWin) do
		for _,v in pairs(aRaceIncreases) do
			local vAbil = v.stat;
			local bCreate = true;

			if aChoices[vAbil:lower()] then
				bCreate = false;
			end

			if bCreate then
				local wMod = wChoice.selection_window.createWindow();

				wMod.name.setValue(vAbil:lower());
				wMod.bname.setText(StringManager.titleCase(vAbil));
				wMod.value.setValue("0");
				wMod.bname.setVisible(true);
			end
		end
	end

	CharWizardManager.calcRacialAbilityMods(wndSummary, wList);
end

function calcRacialAbilityMods(wndSummary, wList)
	CharWizardManager.clearRacialAbilityMods(wndSummary);

	local tRacialMod = {};
	for _,wGroup in pairs(wList.getWindows()) do
		local sGroup = wGroup.group_name.getValue();
		if sGroup:match("^CHOICE RACIAL MOD") then
			local nIncrease = tonumber(sGroup:match("%d+")) or 0;
			if nIncrease then
				for _,wSelection in pairs(wGroup.selection_window.getWindows()) do
					if wSelection.value.getValue() == "1" then
						local sAbilityLower = wSelection.name.getValue():lower();
						tRacialMod[sAbilityLower] = (tRacialMod[sAbilityLower] or 0) + nIncrease;
					end
				end

			end
		end
	end

	for k,v in pairs(tRacialMod) do
		if StringManager.contains(DataCommon.abilities, k) then
			wndSummary.summary.subwindow["summary_race_" .. k].setValue(v);
		end
	end

	wndSummary.calcSummaryStats();
end

function updateRace(wndSummary, wList, nodeRace, nodeSubRace)
	if not nodeRace then
		return;
	end

	local aChoiceWindows = {};
	local aTraits = {};

	for _,v in pairs(wList.getWindows()) do
		local sGroupName = v.group_name.getValue();

		aChoiceWindows[sGroupName] = "";
	end

	for _,v in pairs(DB.getChildren(nodeRace, "traits")) do
		local sTraitType = CampaignDataManager2.sanitize(DB.getValue(v, "name", ""));

		if not CharWizardData.aRaceNonParse[sTraitType] then
			table.insert(aTraits, v)
		end
	end

	if nodeSubRace then
		for _,v in pairs(DB.getChildren(nodeSubRace, "traits")) do
			local sTraitType = CampaignDataManager2.sanitize(DB.getValue(v, "name", ""));

			if not CharWizardData.aRaceNonParse[sTraitType] then
				table.insert(aTraits, v)
			end
		end
	end

	for _,v in pairs(aTraits) do
		local bParsed = false;
		local sTraitType = CampaignDataManager2.sanitize(DB.getValue(v, "name", ""));
		local aRaceSkill = CharWizardData.getRaceSkill();
		local aRaceLanguages = CharWizardData.getRaceLanguages();
		local aRaceProficiency = CharWizardData.getRaceProficiency();
		local aRaceSpeed = CharWizardData.getRaceSpeed();
		local aRaceSpells = CharWizardData.getRaceSpells();

		if sTraitType:match("size") then
			local sSizeText = DB.getText(v, "text"):lower();

			if sSizeText:match("choice") then
				local aChoices = { ["small"] = { tooltip = "Choose racial size." }, ["medium"] = { tooltip = "Choose racial size." } };

				CharWizardManager.createSelectionWindows(wList, "SELECT SIZE", aChoices, 1);
			else
				sSize = sSizeText:match("your size is (%w+)");

				if not sSize then
					sSize = sSizeText:match("you are (%w+)");
				end

				if not sSize then
					sSize = "Medium";
				end

				wndSummary.summary.subwindow.summary_size.setValue(StringManager.capitalize(sSize));
			end

			bParsed = true;
		end
		if aRaceSpeed[sTraitType] then
			CharWizardManager.updateRaceSpeed(wndSummary, v);

			bParsed = true;
		end
		if aRaceLanguages[sTraitType] then
			local bChoice, aChoices, nChoices = CharWizardManager.updateRaceLanguages(wndSummary, v);

			if bChoice then
				CharWizardManager.createSelectionWindows(wList, "SELECT LANGUAGES", aChoices, nChoices);
			end

			wndSummary.summary.subwindow.summary_languages.applySort();

			bParsed = true;
		end
		if aRaceProficiency[sTraitType] then
			local bChoice, aChoices, nChoices = CharWizardManager.updateRaceProficiencies(wndSummary, v);
			if bChoice then
				CharWizardManager.createSelectionWindows(wList, "SELECT TOOL PROFICIENCY", aChoices, nChoices);
			end

			wndSummary.updateProficiencies(wndSummary);
			bParsed = true;
		end
		if aRaceSkill[sTraitType] then
			local bChoice, aChoices, nChoices = CharWizardManager.updateRaceSkills(wndSummary, wList, v);
			if bChoice then
				CharWizardManager.createSelectionWindows(wList, "SELECT SKILL PROFICIENCY", aChoices, nChoices);
			end

			bParsed = true;
		end
		if sTraitType == "cantrip" then
			local bChoice, aChoices, nChoices = CharWizardManager.updateRaceSpells(wndSummary, v);
			if bChoice then
				CharWizardManager.createSelectionWindows(wList, "SELECT SPELL", aChoices, nChoices, true);
			end

			bParsed = true;
		end
		if sTraitType == ("variabletrait") then
			local wVariableTrait = wList.createWindow();
			wVariableTrait.group_name.setValue("SELECT VARIABLE TRAIT");

			for _,v in pairs({"darkvision", "skill"}) do
				local wndVariableTrait = wVariableTrait.selection_window.createWindow();
				wndVariableTrait.bname.setText(StringManager.titleCase(v));
				wndVariableTrait.name.setValue(v);
			end

			bParsed = true;
		end
		if sTraitType == "darkvision" then
			local sSenses = DB.getText(v, "text");
			local sDarkVision = sSenses:match("(%d+)");

			if sDarkVision then
				local nDist = tonumber(sDarkVision) or 60;

				wndSummary.summary.subwindow.summary_senses.setValue("Darkvision " .. nDist);
			end
			bParsed = true;
		end
		if sTraitType == "superiordarkvision" then
			local sSenses = DB.getText(v, "text");
			local sDarkVision = sSenses:match("(%d+)");

			if sDarkVision then
				local nDist = tonumber(sDarkVision) or 120;

				wndSummary.summary.subwindow.summary_senses.setValue("Superior Darkvision " .. nDist);
			end
			bParsed = true;
		end
		if not bParsed then
			local wndTraitList = wndSummary.summary.subwindow.summary_traits.createWindow();

			wndTraitList.name.setValue(DB.getValue(v, "name", ""));
			wndTraitList.link.setValue("reference_racialtrait", v.getPath());
			wndTraitList.type.setValue("race");
			wndSummary.summary.subwindow.summary_traits.applySort();
		end
	end

	wndSummary.updateExpertise()
end

function parseSelectSize(wSelection, wList, sSelectionName, wndSummary, bIncrease)
	CharWizardManager.onSelectionChange(wSelection);
	wndSummary.summary.subwindow.summary_size.setValue(StringManager.titleCase(sSelectionName));
end

function updateRaceSpeed(wndSummary, nodeSpeed)
	local sSpeed = DB.getText(nodeSpeed, "text"):lower();
	local bEqualWalkClimb = false;
	local bEqualWalkFlight = false;
	local bCurEqualWalkClimb = false;
	local bCurEqualWalkFlight = false;
	local sWalkSpeedInc, sWalkSpeedReplace, nClimbSpeed;
	local sWalkSpeed, nSwimSpeed, nFlightSpeed;

	sCurWalkSpeed = sSpeed:match("walking speed is (%d+)");

	if not sCurWalkSpeed then
		sCurWalkSpeed = sSpeed:match("land speed is (%d+)");
	end

	if sSpeed:match("walking speed increases") then
		local sSpeedInc = sSpeed:match("increases ([^.]+)");

		if sSpeedInc:match("to") then
			sCurWalkSpeedReplace = sSpeedInc:match("%d+");
		else
			sCurWalkSpeedInc = sSpeed:match("%d+");
		end
	end

	local nCurSwimSpeed = sSpeed:match("swimming speed of (%d+) feet.");
	if not nCurSwimSpeed then
		nCurSwimSpeed = sSpeed:match("swim speed of (%d+) feet.");
	end

	local nCurClimbSpeed = sSpeed:match("climbing speed of (%d+) feet.");
	if sSpeed:match("you have a climbing speed equal to your walking speed") then
		bCurEqualWalkClimb = true
	end

	local nCurFlightSpeed = sSpeed:match("flying speed of (%d+) feet");
	if not nCurFlightSpeed then
		local sFlightSpeed = sSpeed:match("flying speed ([^%)]+)");

		if sFlightSpeed then
			if sFlightSpeed:match("equal to your walking speed") then
				bCurEqualWalkFlight = true
			else
				nCurFlightSpeed = sFlightSpeed:match("%d+");
			end
		end
	end

	if sCurWalkSpeed then
		sWalkSpeed = sCurWalkSpeed;
	end
	if sCurWalkSpeedInc then
		sWalkSpeedInc = sCurWalkSpeedInc;
	end
	if sCurWalkSpeedReplace then
		sWalkSpeedReplace = sCurWalkSpeedReplace;
	end
	if nCurSwimSpeed then
		nSwimSpeed = nCurSwimSpeed;
	end
	if nCurClimbSpeed then
		nClimbSpeed = nCurClimbSpeed;
	end
	if nCurFlightSpeed then
		nFlightSpeed = nCurFlightSpeed;
	end
	if bCurEqualWalkClimb then
		bEqualWalkClimb = bCurEqualWalkClimb;
	end
	if bCurEqualWalkFlight then
		bEqualWalkFlight = bCurEqualWalkFlight;
	end

	if sWalkSpeedInc then
		sWalkSpeed = tonumber(sWalkSpeed) + tonumber(sWalkSpeedInc:match("%d+"));
	end

	if sWalkSpeedReplace then
		sWalkSpeed = sWalkSpeedReplace;
	end

	if not sWalkSpeed then
		sWalkSpeed = "30";
	end

	local aSpeedSpecial = {};
	if nSwimSpeed then
		table.insert(aSpeedSpecial, "Swim " .. nSwimSpeed .. " ft.");
	end
	if nClimbSpeed then
		table.insert(aSpeedSpecial, "Climb " .. nClimbSpeed .. " ft.");
	elseif bEqualWalkClimb then
		table.insert(aSpeedSpecial, "Climb " .. sWalkSpeed .. " ft.");
	end
	if nFlightSpeed then
		table.insert(aSpeedSpecial, "Fly " .. nFlightSpeed .. " ft.");
	elseif bEqualWalkFlight then
		table.insert(aSpeedSpecial, "Fly " .. sWalkSpeed .. " ft.");
	end

	wndSummary.summary.subwindow.summary_speed.setValue(tonumber(sWalkSpeed));

	if #aSpeedSpecial > 0 then
		local sSpeedSpecial = table.concat(aSpeedSpecial, ",");

		wndSummary.summary.subwindow.summary_speedspecial.setValue(sSpeedSpecial);
	end

	if #aSpeedSpecial == 0 then
		wndSummary.summary.subwindow.summary_speedspecial.setValue("");
	end
end

function updateRaceLanguages(wndSummary, nodeLanguage)
	local aLanguages = {};
	local aChoiceLanguages = {};
	local nChoices = 1;
	local bChoice = false;
	local bChoiceLanguages = false;
	local aAvailableLanguages = wndSummary.getAvailableLanguages();

	if DB.getText(nodeLanguage, "text") == nil then
		return
	end

	local sText = DB.getText(nodeLanguage, "text"):lower();
	local sLanguages = sText:match("you can speak, read, and write ([^.]+)");
	local aSortLanguages = {};

	for k,v in pairs(aAvailableLanguages) do
		aSortLanguages[k:lower()] = "";
	end

	if not sLanguages then
		sLanguages = sText:match("you can read and write ([^.]+)");
	end
	if not sLanguages then
		sLanguages = sText:match("you speak, read, and write ([^.]+)");
	end
	if not sLanguages then
		sLanguages = sText:match("your character can speak, read, and write ([^.]+)");
	end
	if not sLanguages then
		sLanguages = sText:match("(, and fluency in one language of your choice.)")
	end
	if not sLanguages then
		return
	end
	if sLanguages:match("and your choice of (%w+) or (%w+)") then
		local sLanguage1, sLanguage2 = sText:match("and your choice of (%w+) or (%w+)");
		aChoiceLanguages[sLanguage1] = { tooltip = "Select Language" };
		aChoiceLanguages[sLanguage2] = { tooltip = "Select Language" };

		sLanguages = sLanguages:gsub("and your choice of (%w+) or (%w+)", "")
		bChoice = true;
		bChoiceLanguages = true;
	end

	if sLanguages:match(" two ") then
		nChoices = 2;
		sLanguages = sLanguages:gsub("two other languages of your choice", "");
	end

	for k,v in pairs(CharWizardData.aParseRaceLangChoices) do
		if sLanguages:match(k) then
			bChoice = true;
		end

		sLanguages = sLanguages:gsub(k, "");
	end

	sLanguages = sLanguages:gsub(", but you can speak only by using your mimicry trait", "");
	sLanguages = sLanguages:gsub(" and ", ",");
	sLanguages = sLanguages:gsub(" ", "");
	sLanguages = sLanguages:gsub(", but you.*$", "");

	aLanguages = StringManager.split(sLanguages, ",");

	for _,v in pairs(aLanguages) do
		if aSortLanguages[v] then
			local wndLangList = wndSummary.summary.subwindow.summary_languages.createWindow();

			wndLangList.name.setValue(StringManager.titleCase(v));
			wndLangList.type.setValue("race");
		end
	end

	if not bChoice then
		return bChoice;
	else
		aAvailableLanguages = wndSummary.getAvailableLanguages();
		local aFinalLanguages = {};

		for k,v in pairs(aAvailableLanguages) do
			aFinalLanguages[k:lower()] = {tooltip = "Select Language" };
		end

		if bChoiceLanguages then
			local aFinalChoiceLanguages = {};

			for k,v in pairs(aChoiceLanguages) do
				if aFinalLanguages[k:lower()] then
					aFinalChoiceLanguages[k:lower()] = v;
				end
			end

			return bChoice, aFinalChoiceLanguages, nChoices;
		else

			return bChoice, aFinalLanguages, nChoices;
		end
	end
end

function parseSelectRaceLanguage(wSelection, wList, sSelectionName, wndSummary, bIncrease)
	CharWizardManager.onSelectionChange(wSelection);

	if wSelection.selection_count.isVisible() then
		local nCount = wSelection.selection_count.getValue();
		if nCount > 1 then
			CharWizardManager.clearSummary(wndSummary, "race_choice", "languages");
		end

		if bIncrease == false then
			local aLanguages = wndSummary.summary.subwindow.summary_languages.getWindows();

			local aRaceChoiceLang = {};
			for _,v in pairs(aLanguages) do
				if v.name.getValue():lower() == sSelectionName then
					table.insert(aRaceChoiceLang, v)
				end
			end
			if #aRaceChoiceLang > 0 then
				for _,v in pairs(aRaceChoiceLang) do
					v.close();
				end
			end
		else
			local wLanguages = wndSummary.summary.subwindow.summary_languages.createWindow();

			wLanguages.name.setValue(StringManager.titleCase(sSelectionName:lower()));
			wLanguages.type.setValue("race_choice");

			wndSummary.summary.subwindow.summary_languages.applySort();
		end
	else
		CharWizardManager.clearSummary(wndSummary, "race_choice", "languages");

		local wLanguages = wndSummary.summary.subwindow.summary_languages.createWindow();

		wLanguages.name.setValue(StringManager.titleCase(sSelectionName:lower()));
		wLanguages.type.setValue("race_choice");

		wndSummary.summary.subwindow.summary_languages.applySort();
	end
end

function updateRaceProficiencies(wndSummary, nodeProficiency)
	local aProficiencies = {};
	local aChoiceProficiencies = {};
	local nChoices = 1;
	local bChoice = false;
	local bChoiceProficiency = false;
	local sText = DB.getText(nodeProficiency, "text"):lower();
	local sProficiency = sText:match("you have proficiency with ([^.]+)")

	if not sProficiency then
		sProficiency = sText:match("you gain proficiency with ([^.]+)")
	end

	if not sProficiency then
		sProficiency = sText:match("you are proficient with ([^.]+)")
	end

	if not sProficiency then
		sProficiency = sText:match("one tool proficiency of your choice")
	end

	if not sProficiency then
		sProficiency = sText:match("artisan's tools %((.*)%)");
	end

	if not sProficiency then
		sProficiency = sText:match("you have proficiency with ([^.]+)")
	end

	if not sProficiency then
		return bChoice
	end

	sProficiency = sProficiency:gsub(" and ", ",")
	sProficiency = sProficiency:gsub(" or ", ",")
	sProficiency = sProficiency:gsub("the ", "")

	if sProficiency:match("choice") then
		if sProficiency:match("choice: (.*)") then
			sProficiency = sProficiency:match("choice: (.*)")
		end

		bChoice = true;
	elseif sProficiency:match("type") then
		bChoice = true;
	end

	if bChoice then
		for _,vProf in pairs(StringManager.split(sProficiency, ",")) do
			if vProf:match("of your choice") then
				for _,vAllTool in pairs(wndSummary.getToolType()) do
					aChoiceProficiencies[StringManager.trim(vAllTool)] = { tooltip = "Select proficiency." };
				end

				bChoice = true;
			elseif vProf:lower():match("one type of") then
				for _,vAllTool in pairs(wndSummary.getToolType("artisan's tools")) do
					aChoiceProficiencies[StringManager.trim(vAllTool)] = { tooltip = "Select proficiency." };
				end

				bChoice = true;
			else
				aChoiceProficiencies[StringManager.trim(vProf)] = { tooltip = "Select proficiency." };
			end
		end

		return bChoice, aChoiceProficiencies, nChoices;
	else
		for _,v in pairs(StringManager.split(sProficiency, ",")) do
			if v == "light" then
				v = "light armor";
			end

			wndSummary.proficiencies_race[StringManager.trim(v)] = { type = "race", expertise = 0 }
		end

		return bChoice;
	end
end

function parseSelectRaceToolProficiency(wSelection, wList, sSelectionName, wndSummary)
	CharWizardManager.onSelectionChange(wSelection);

	CharWizardManager.clearSummary(wndSummary, "race_choice", "toolproficiency");
	wndSummary.proficiencies_race[StringManager.titleCase(sSelectionName:lower())] = { type = "race_choice", expertise = 0 }
	wndSummary.updateProficiencies(wndSummary);
end

function updateRaceSkills(wndSummary, wList, nodeSkill)
	local aRaceChoiceSkills = {};
	local nChoices = 1;
	local bChoice = false;
	local aAvailableSkills = wndSummary.getAvailableSkills();
	local aSortAvailableSkills = {};
	local sText = DB.getText(nodeSkill, "text"):lower();
	local sSkillText = sText:match("two skills of your choice");
	local sToolType = nil;

	for k,v in pairs(aAvailableSkills) do
		aSortAvailableSkills[k] = "";
	end

	if not sSkillText then
		sSkillText, sToolType = sText:match("you have proficiency in the (.-) skills, and you have proficiency with one (.-) of your choice");
	end

	if not sSkillText then
		sSkillText = sText:match("proficiency in ([^.]+)");
	end

	if not sSkillText then
		sSkillText = sText:match("proficient in the (.-) skill");
	end

	if not sSkillText then
		sSkillText = sText:match("proficiency with ([^.]+)");
	end

	if not sSkillText then
		sSkillText = sText:match("proficiency of ([^.]+)");
	end

	if not sSkillText then
		sSkillText = sText:match("trained in ([^.]+)");
	end

	if not sSkillText then
		sSkillText = sText:match("you are proficient in your choice of two of the following skills: [^.]+");
		nChoices = 2;
	end

	if not sSkillText then
		sSkillText = sText:match("following skills of your choice: [^.]+");
	end

	if not sSkillText then
		sSkillText = sText:match("choose one of the following skills: [^.]+")
	end

	if sSkillText:match("choice") or sSkillText:match("choose") then
		if sSkillText:match("choice: ([^.]+)") or sSkillText:match("skills: ([^.]+)") then
			local sChoiceSkills = sSkillText:match("choice: ([^.]+)");

			if not sChoiceSkills then
				sChoiceSkills = sSkillText:match("skills: ([^.]+)");
			end

			if sChoiceSkills then
				sChoiceSkills = sChoiceSkills:gsub("and ", "");
				sChoiceSkills = sChoiceSkills:gsub("or ", "");

				local aWords = StringManager.split(sChoiceSkills, ",")
				for _,t in pairs(aWords) do
					t = StringManager.trim(t);
					sCleanText = CharWizardManager.cleanupText(t);

					for _,v in pairs(DataCommon.skilldata) do
						if v.lookup == sCleanText then
							table.insert(aRaceChoiceSkills, t);
						end
					end
					if t == "two" then
						nChoices = 2;
					end
				end
			end
		else
			if sSkillText:match("of your choice") then
				if sSkillText:match("two ") then
					nChoices = 2;
				end
			end
		end

		bChoice = true;
	else
		sSkillText = sSkillText:gsub(" and ", " ")

		local aWords = StringManager.split(sSkillText, " ")
		for _,t in pairs(aWords) do
			if DataCommon.skilldata[StringManager.titleCase(t)] then
				if aSortAvailableSkills[t] then
					local wndSkillList = wndSummary.summary.subwindow.summary_skills.createWindow();

					wndSkillList.name.setValue(StringManager.titleCase(t));
					wndSkillList.type.setValue("race");
				end
			end
		end

		if sToolType then
			local aChoiceProficiencies = {};
			for _,vAllTool in pairs(wndSummary.getToolType(sToolType)) do
				aChoiceProficiencies[vAllTool] = { tooltip = "Select proficiency." };
			end

			CharWizardManager.createSelectionWindows(wList, "SELECT TOOL PROFICIENCY", aChoiceProficiencies, 1);
		end
	end

	if not bChoice then
		return bChoice;
	else
		aAvailableSkills = wndSummary.getAvailableSkills();
		local aFinalSkills = {};

		for k,v in pairs(aAvailableSkills) do
			aFinalSkills[k:lower()] = { tooltip = "Select Skill." };
		end

		if #aRaceChoiceSkills > 0 then
			local aFinalChoiceSkills = {};

			for _,v in pairs(aRaceChoiceSkills) do
				v = StringManager.trim(v);

				if aFinalSkills[v:lower()] then
					aFinalChoiceSkills[v:lower()] = { tooltip = "Select skill" };
				end
			end

			return bChoice, aFinalChoiceSkills, nChoices;
		else

			return bChoice, aFinalSkills, nChoices;
		end
	end
end

function parseSelectRaceSkillProficiency(wSelection, wList, sSelectionName, wndSummary, bIncrease)
	CharWizardManager.onSelectionChange(wSelection);

	if wSelection.selection_count.isVisible() then
		local nCount = wSelection.selection_count.getValue();
		if nCount > 1 then
			CharWizardManager.clearSummary(wndSummary, "race_choice", "skills");
		end

		if bIncrease == false then
			local aSkills = wndSummary.summary.subwindow.summary_skills.getWindows();
			local aRaceChoiceSkill = {};
			for _,v in pairs(aSkills) do
				if v.name.getValue():lower() == sSelectionName then
					table.insert(aRaceChoiceSkill, v)
				end
			end
			if #aRaceChoiceSkill > 0 then
				for _,v in pairs(aRaceChoiceSkill) do
					v.close();
				end
			end
		else
			local wSkill = wndSummary.summary.subwindow.summary_skills.createWindow();
			wSkill.name.setValue(StringManager.titleCase(sSelectionName:lower()));
			wSkill.type.setValue("race_choice");
			wndSummary.summary.subwindow.summary_skills.applySort();
		end
	else
		CharWizardManager.clearSummary(wndSummary, "race_choice", "skills");

		local wSkills = wndSummary.summary.subwindow.summary_skills.createWindow();
		wSkills.name.setValue(StringManager.titleCase(sSelectionName:lower()));
		wSkills.type.setValue("race_choice");
		wndSummary.summary.subwindow.summary_skills.applySort();
	end

	wndSummary.updateExpertise();
end

function updateRaceSpells(wndSummary, nodeSpell)
	local aRaceSpells = {};
	local aThirdLvlSpells = {}
	local aFifthLvlSpells = {}
	local aRaceChoiceSpells = {};
	local sChoices = "";
	local sSpellList = "";
	local bChoice = false;

	local sText = DB.getText(nodeSpell, "text"):lower();
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

			if not wndSummary.aSpells[sSpellText] then
				local sSplit1, sSplit2 = sSpellText:match("(detect magic) and (detect poison and disease)")

				if not sSplit1 and not sSplit2 then
					sSplit1, sSplit2 = sSpellText:match("([%w%s]+) and ([%w%s]+)");
				end

				if sSplit1 and sSplit2 then
					table.insert(aSplit, sSplit1);
					table.insert(aSplit, sSplit2);
				end
			end

			if #aSplit > 0 then
				for _,v in pairs(aSplit) do
					if vSentence:match("3rd") then
						table.insert(aThirdLvlSpells, v);
					elseif vSentence:match("5th") then
						table.insert(aFifthLvlSpells, v);
					else
						table.insert(aRaceSpells, v);
					end
				end
			else
				if vSentence:match("3rd") then
					table.insert(aThirdLvlSpells, sSpellText);
				elseif vSentence:match("5th") then
					table.insert(aFifthLvlSpells, sSpellText);
				else
					table.insert(aRaceSpells, sSpellText);
				end
			end
		end
	end

	local sCurChoices, sCurSpellList = sText:match("you know (.-) cantrip of your choice from the (.-) spell list")

	if sCurChoices then
		sChoices = sCurChoices;
		bChoice = true;
	end
	if sCurSpellList then
		sSpellList = sCurSpellList;
		bChoice = true;
	end

	if #aRaceSpells > 0 then
		for _,v in pairs(aRaceSpells) do
			if wndSummary.loaded_spells[v] then
				table.insert(wndSummary.innatespells, {class = "reference_spelldata", record = wndSummary.aSpells[v].getPath() })
			end
		end
	end

	if sChoices ~= "" then
		if sChoices == "one" then
			sChoices = "1";
		elseif sChoices == "two" then
			sChoices = "2";
		end

		bChoice = true;
	end

	if bChoice then
		local aChoiceSpells = {};
		local nChoices = tonumber(sChoices);

		for k,vSpell in pairs(wndSummary.loaded_spells) do
			local sSpellName = k;
			local sSpellLevel = DB.getValue(DB.findNode(vSpell.record), "level", "");
			local sSpellSource = DB.getValue(DB.findNode(vSpell.record), "source", "");
			local aSpellSources = StringManager.split(sSpellSource:lower(), ",");

			for _,vSource in pairs(aSpellSources) do
				vSource = StringManager.trim(vSource);

				if sSpellList then
					if vSource == sSpellList:lower() then
						if tonumber(sSpellLevel) == 0 then
							aChoiceSpells[sSpellName] = vSpell;
						end
					end
				else
					if tonumber(sSpellLevel) == 0 then
						aChoiceSpells[sSpellName] = vSpell;
					end
				end
			end
		end

		return bChoice, aChoiceSpells, nChoices;
	end

	return bChoice
end

function parseSelectRaceSpell(wSelection, wList, nodeSource, wndSummary, bIncrease)
	for k,v in ipairs(wndSummary.innatespells) do
		if v.source == wndSummary.summary.subwindow.summary_race.getValue() then
			table.remove(wndSummary.innatespells, k);
		end
	end

	local sName = DB.getValue(nodeSource, "name", ""):lower();
	CharWizardManager.completeSelection(wSelection, sName, "reference_spell", nodeSource.getPath());

	table.insert(wndSummary.innatespells, { name = DB.getValue(nodeSource, "name", ""):lower(), class = "reference_spell", record = nodeSource.getPath(), source = wndSummary.summary.subwindow.summary_race.getValue()});
end

function parseSelectVariableTrait(wSelection, wList, sSelectionName, wndSummary, bIncrease)
	CharWizardManager.closeListWindowsMatch(wList, "SELECT SKILL PROFICIENCY");
	CharWizardManager.onSelectionChange(wSelection);

	wndSummary.summary.subwindow.summary_senses.setValue("");
	CharWizardManager.clearSummary(wndSummary, "race_choice", "skills");

	if sSelectionName:lower() == "darkvision" then
		wndSummary.summary.subwindow.summary_senses.setValue("Darkvision 60");
	else
		local aAvailableSkills = wndSummary.getAvailableSkills();

		CharWizardManager.createSelectionWindows(wList, "SELECT SKILL PROFICIENCY", aAvailableSkills, 1)
	end
end

--
-- Class
--

function createLevelUpLabels(wndSummary)
    local nGroup = 0;
    local wList = wndSummary.genclass.subwindow.contents.subwindow.class_window;
    local aClasses = {}

    for k,vClass in pairs(wndSummary.summary.subwindow.summary_class.getWindows()) do
        local sSourceClass, sSourceRecord = vClass.link.getValue();
        local w = wList.createWindow();

        w.button_expand.setVisible(false);
        w.group_name.setValue("INCREASE LEVEL");
        w.order.setValue(nGroup + 1);
        w.selection_name.setValue(StringManager.titleCase(vClass.name.getValue()));
        w.selection_name.setVisible(true);
        w.selection_shortcut.setValue(sSourceClass, sSourceRecord);
        w.selection_shortcut.setVisible(true);
        w.level_up.setVisible(true);
        w.level.setValue(tonumber(vClass.classlevel.getValue()));
        w.level.setVisible(true);
        nGroup = nGroup + 1;

        aClasses[sSourceRecord] = vClass.name.getValue():lower();
    end

    for _,vSpec in pairs(wndSummary.summary.subwindow.summary_specialization.getWindows()) do
        local sLinkClass,sLinkRecord = vSpec.link.getValue();
        local nodeSpec = DB.findNode(sLinkRecord);
        local nodeClass = nodeSpec.getParent().getParent();
        local sClassName = DB.getValue(nodeClass, "name", "");
        local w = wList.createWindow();

        w.button_expand.setVisible(false);
        w.group_name.setValue(sClassName:upper() .. " SPECIALIZATION");
        w.order.setValue(nGroup + 1);
        w.selection_name.setValue(vSpec.name.getValue());
        w.selection_name.setVisible(true);
        w.selection_shortcut.setValue(sLinkClass, sLinkRecord);
        w.selection_shortcut.setVisible(true);

        nGroup = nGroup + 1;
    end

    local aSelectedClasses = {};
    local aFinalClasses = {};

    for _,vGroup in pairs(wList.getWindows()) do
        if vGroup.group_name.getValue() == "CLASS" or vGroup.group_name.getValue() == "MULTICLASS" or vGroup.group_name.getValue() == "INCREASE LEVEL" then
            if vGroup.selection_name.getValue() ~= "" then
                aSelectedClasses[vGroup.selection_name.getValue():lower()] = "";
            end
        end
    end

    for k,vClass in pairs(wndSummary.loaded_classes) do
        if not aSelectedClasses[k] then
            aFinalClasses[k] = vClass;
        end
    end

    local wndMultiClass = CharWizardManager.createSelectionWindows(wList, "SELECT CLASS", aFinalClasses, 1, true);
    wndMultiClass.group_name.setValue("SELECT MULTICLASS");
    wndMultiClass.order.setValue(99);
    wndMultiClass.selection_window.setVisible(false);
    wndMultiClass.button_expand.setValue(0);
end

function parseClass(wSelection, wList, wndSummary, sSelectionName, nodeSource, bMultiClassSelection)
	local bMultiClass = false;
	local sOldClass = wSelection.selection_name.getValue():lower();

	CharWizardManager.clearSummary(wndSummary, sOldClass, "all", 0);
	CharWizardManager.clearSummary(wndSummary, sOldClass .. "_choice", "all", 0);

	if wSelection.group_name.getValue():match("SELECT MULTICLASS") then
		wSelection.group_name.setValue("MULTICLASS");
	else
		wSelection.group_name.setValue("CLASS");
	end

	local aCloseWin = {}
	for _,vSelectClass in pairs(wList.getWindows()) do
		if vSelectClass.group_name.getValue():lower():match("select multiclass") or vSelectClass.group_name.getValue():lower():match("increase level") then
			bMultiClass = true;
			if wndSummary.import == 1 then
				wndSummary.levelUpClass = nodeSource.getPath();
			end
		end
		if vSelectClass.group_name.getValue():lower():match("multiclass") or vSelectClass.group_name.getValue():lower():match("increase level") then
			vSelectClass.level_up.setVisible(false)
			vSelectClass.level_down.setVisible(false)
		end

		if vSelectClass.group_name.getValue():lower():match(sOldClass) and sOldClass ~= "" then
			if vSelectClass.group_name.getValue():lower():match("specialization") then
				local sSpecialization = vSelectClass.selection_name.getValue():lower();

				for _,vSpec in pairs(wndSummary.summary.subwindow.summary_specialization.getWindows()) do
					if vSpec.name.getValue():lower() == sSpecialization then
						CharWizardManager.clearSummary(wndSummary, sSpecialization, "all", 0);
						CharWizardManager.clearSummary(wndSummary, sSpecialization .. "_choice", "all", 0);

						--table.insert(aCloseWin, vSpec);
					end
				end
			end

			table.insert(aCloseWin, vSelectClass);
		end
	end

	for _,v in pairs(wndSummary.summary.subwindow.summary_class.getWindows()) do
		if v.name.getValue():lower() == sOldClass then
			table.insert(aCloseWin, v)
		end
	end

	if wndSummary.genstats.subwindow then
		for _,vASI in pairs(wndSummary.genstats.subwindow.contents.subwindow.abilityscore_improvements.getWindows()) do
			if vASI.group_name.getValue():lower():match(sOldClass) then
				table.insert(aCloseWin, vASI)
			end
		end
	end

	if wndSummary.genfeats.subwindow then
		for _,vASI in pairs(wndSummary.genfeats.subwindow.contents.subwindow.feat_window.getWindows()) do
			if vASI.group_name.getValue():lower():match(sOldClass) and sOldClass ~= "" then
				table.insert(aCloseWin, vASI)
			end
		end
	end

	if wndSummary.geninv.subwindow then
		for _,v in pairs(wndSummary.geninv.subwindow.contents.subwindow.kitlist.getWindows()) do
			local sGroupName = v.group_name.getValue():lower();

			if sGroupName:match("class choice") or sGroupName:match("included") then
				table.insert(aCloseWin, v)
			end
		end

		local aFinalInv = {};
		for _,v in pairs(wndSummary.inventory) do
			if v.source ~= "class" then
				table.insert(aFinalInv, v)
			end
		end
		wndSummary.inventory = aFinalInv;
	end

	for _,v in pairs(aCloseWin) do
		v.close()
	end

	if wndSummary.genspells.subwindow then
		for _,v in pairs(wndSummary.genspells.subwindow.contents.subwindow.selectedspells.getWindows()) do
			if v.group.getValue():lower() == sOldClass:lower() then
				v.selectedspells_idelete.onButtonPress();
			else
				local aClasses = v.group.getValues();
				local aRemove = {};
				for k,vClassGroup in pairs(aClasses) do
					if vClassGroup:lower() == sOldClass then
						v.group.remove(k);
					end
				end

				v.group.add(StringManager.titleCase(sSelectionName), StringManager.titleCase(sSelectionName), false)
			end
		end

		CharWizardManager.setSpellClasses(wndSummary, wndSummary.genspells.subwindow.contents.subwindow.spellclass);
	end

	local wndAddClass = wndSummary.summary.subwindow.summary_class.createWindow();
	wndAddClass.name.setValue(StringManager.titleCase(sSelectionName));
	wndAddClass.classlevel.setValue(1);
	wndAddClass.classlevel.setVisible(true);
	wndAddClass.link.setValue("reference_class", nodeSource.getPath());

	wSelection.selection_name.setValue(StringManager.titleCase(sSelectionName));
	wSelection.selection_shortcut.setValue("reference_class", nodeSource.getPath());
	wSelection.selection_name.setVisible(true);
	wSelection.selection_shortcut.setVisible(true);
	--wSelection.level_label.setVisible(true);
	wSelection.level.setValue(1);
	wSelection.level.setVisible(true);

	if wndSummary.import == 1 then
		wSelection.level_up.setVisible(false);
	else
		wSelection.level_up.setVisible(true);
	end
	wSelection.selection_window.setVisible(false);
	wSelection.button_expand.setValue(0);

	if not bMultiClass then
		local aSelectedClasses = {};
		local aFinalClasses = {};

		for _,vGroup in pairs(wList.getWindows()) do
			if vGroup.group_name.getValue() == "CLASS" or vGroup.group_name.getValue() == "MULTICLASS" or vGroup.group_name.getValue() == "INCREASE LEVEL" then
				if vGroup.selection_name.getValue() ~= "" then
					aSelectedClasses[vGroup.selection_name.getValue():lower()] = "";
				end
			end
		end

		for k,vClass in pairs(wndSummary.loaded_classes) do
			if not aSelectedClasses[k] then
				aFinalClasses[k] = vClass;
			end
		end

		local wndMultiClass = CharWizardManager.createSelectionWindows(wList, "SELECT CLASS", aFinalClasses, 1, true);
		wndMultiClass.group_name.setValue("SELECT MULTICLASS");
		wndMultiClass.order.setValue(99);
		wndMultiClass.selection_window.setVisible(false);
		wndMultiClass.button_expand.setValue(0);
	end

	CharWizardManager.createFeatureWindows(wSelection, wList, sSelectionName, wndSummary, nodeSource, 1, 1);

	wndSummary.checkFeatSpellInv();
end

function handleLevelChange(nLevel, cLevel, nChange)
	local wndSummary = UtilityManager.getTopWindow(cLevel.window);
	local bImport = wndSummary.import == 1;
	local nPrevLevel = nLevel;
	local nNextLevel = nLevel + nChange;
	local sClass,sRecord = cLevel.window.selection_shortcut.getValue();
	local nodeSource = DB.findNode(sRecord);
	local sClass = cLevel.window.selection_name.getValue():lower();
	local sSpec = "";

	cLevel.setValue(nLevel + nChange);

	for _,v in pairs(wndSummary.summary.subwindow.summary_class.getWindows()) do
		if v.name.getValue():lower() == DB.getValue(nodeSource, "name", ""):lower() then
			v.classlevel.setValue(nNextLevel)

			break
		end
	end

	for _,v in pairs(wndSummary.summary.subwindow.summary_specialization.getWindows()) do
		local _,sSpecRecord = v.link.getValue();

		if DB.getValue(DB.findNode(sSpecRecord).getChild("..."), "name", ""):lower() == DB.getValue(nodeSource, "name", ""):lower() then
			sSpec = v.name.getValue():lower();
			v.classlevel.setValue(nNextLevel);

			break
		end
	end

	if nChange > 0 then
		CharWizardManager.createFeatureWindows(cLevel.window, cLevel.window.windowlist, sClass, wndSummary, nodeSource, nNextLevel, nPrevLevel, sSpec)

		if wndSummary.import == 1 then
			wndSummary.levelUpClass = sRecord;
		end
	else
		CharWizardManager.removeFeatures(cLevel.window, cLevel.window.windowlist, sClass, wndSummary, nodeSource, nNextLevel, nPrevLevel)

		if wndSummary.import == 1 then
			wndSummary.levelUpClass = "";
		end
	end
	-- Still need to make sure only choice has down and rest are false
	local bUp = false;
	local bDown = false;
	local nTotalLevel = wndSummary.getTotalLevel();

	if nTotalLevel > 1 and nTotalLevel < 20 then
		bUp = true;
		bDown = true;
	elseif nTotalLevel == 20 then
		bUp = false;
		bDown = true;
	else
		bUp = true;
		bDown = false;
	end

	local aCloseWin = {};
	local bMultiClass = false;
	local aSelectedClasses = {};

	for _,v in pairs(cLevel.window.windowlist.getWindows()) do
		if StringManager.contains({"CLASS", "MULTICLASS", "INCREASE LEVEL"}, v.group_name.getValue()) or v.group_name.getValue():match("MULTICLASS") then
			if v.selection_name.getValue() ~= "" then
				aSelectedClasses[v.selection_name.getValue():lower()] = "";
			end

			if bImport then
				if nChange > 0 then
					if v.group_name.getValue():match("MULTICLASS") then
						table.insert(aCloseWin, v);

						bMultiClass = true;
					end

					if v == cLevel.window then
						v.level_up.setVisible(false);
						v.level_down.setVisible(true);
					else
						v.level_up.setVisible(false);
						v.level_down.setVisible(false);
					end
				else
					if v == cLevel.window then
						v.level_up.setVisible(bUp);
						v.level_down.setVisible(false);
					else
						v.level_up.setVisible(bUp);
						v.level_down.setVisible(false);
					end
				end
			else
				if v.selection_name.isVisible() then
					v.level_up.setVisible(bUp);
					v.level_down.setVisible(bDown);
				end

				if v.group_name.getValue():match("MULTICLASS") then
					bMultiClass = true;
				end
			end
		end
	end

	for _,v in pairs(aCloseWin) do
		v.close()
	end

	if not bMultiClass then
		local aFinalClasses = {};

		for k,vClass in pairs(wndSummary.loaded_classes) do
			if not aSelectedClasses[k] then
				aFinalClasses[k] = vClass;
			end
		end

		local wndMultiClass = CharWizardManager.createSelectionWindows(cLevel.window.windowlist, "SELECT MULTICLASS", aFinalClasses, 1, true);
		wndMultiClass.order.setValue(99);
		wndMultiClass.selection_window.setVisible(false);
		wndMultiClass.button_expand.setValue(0);
	end
end

function createFeatureWindows(wSelection, wList, sSelectionName, wndSummary, nodeSource, nLevel, nPrevLevel, sSpecialization)
	local aProfList = {};
	local aFeatList = {};
	local bExpertise = false;
	local bOptions = false;

	if sSpecialization == nil or sSpecialization == "" then
		for _,v in pairs(wList.getWindows()) do
			if v.group_name.getValue():match(sSelectionName:upper() .. " SPECIALIZATION") then
				if v.selection_name.getValue() ~= "" then
					local sClass, sRecord = v.selection_shortcut.getValue()

					sSpecialization = v.selection_name.getValue():lower();
					nodeSource = DB.findNode(sRecord).getParent().getParent();

					break
				end
			end
		end
	end

	if (nLevel == 1 and nPrevLevel == 1) and (sSpecialization == nil or sSpecialization == "") then
		if wSelection.group_name.getValue() == "CLASS" then
			for _,vProf in pairs(DB.getChildren(nodeSource, "proficiencies")) do
				table.insert(aProfList, vProf);
			end
		else
			for _,vMultiProf in pairs(DB.getChildren(nodeSource, "multiclassproficiencies")) do
				table.insert(aProfList, vMultiProf);
			end
		end

		for _,vProficiencies in pairs(aProfList) do
			if DB.getValue(vProficiencies, "name", ""):lower() == "skills" then
				bChoice, aChoiceSkills, nSkillChoices = CharWizardManager.updateClassSkills(wndSummary, DB.getText(vProficiencies, "text", ""):lower());
				if bChoice then
					CharWizardManager.createSelectionWindows(wList, sSelectionName:upper() .. " SKILL PROFICIENCY", aChoiceSkills, nSkillChoices);
				end
				wndSummary.summary.subwindow.summary_skills.applySort();
			end
			if DB.getValue(vProficiencies, "name", ""):lower() ~= "saving throws" and DB.getValue(vProficiencies, "name", ""):lower() ~= "skills" then
				bChoice, aChoiceTools, nProfChoices = CharWizardManager.updateClassTools(wndSummary, sSelectionName:lower(), DB.getText(vProficiencies, "text", ""):lower());
				if bChoice then
					CharWizardManager.createSelectionWindows(wList, sSelectionName:upper() .. " TOOL PROFICIENCY", aChoiceTools, nProfChoices);
				end
			end
		end
	end

	if sSpecialization == nil or sSpecialization == "" then
		sSpecialization = sSelectionName:lower();
	end

	local aClassFeatures = {};
	local aMappings = LibraryData.getMappings("class");
	for _,vMapping in ipairs(aMappings) do
		for _,vClass in pairs(DB.getChildrenGlobal(vMapping)) do
			local sSourceClass = DB.getValue(nodeSource, "name", "");
			local sClass = DB.getValue(vClass, "name", "");

			if sClass:lower():match(sSourceClass:lower()) then
				for _,vFeature in pairs(DB.getChildren(vClass, "features")) do
					table.insert(aClassFeatures, vFeature)
				end
			end
		end
	end

	--for _,v in pairs(DB.getChildren(nodeSource, "features")) do
	for _,v in pairs(aClassFeatures) do
		local sFeatureType = CharWizardManager.cleanupText(DB.getValue(v, "name", ""));
		local nFeatureLevel = tonumber(DB.getValue(v, "level", ""));
		local sSpecReq = DB.getValue(v, "specialization", ""):lower();

		if sSpecReq == "" then
			sSpecReq = DB.getValue(nodeSource, "name", ""):lower();
		end

		if nFeatureLevel == nLevel and (sSpecReq == sSpecialization or sSpecReq == sSelectionName:lower()) then
			local bParsed = false;

			if sFeatureType == "" then
				sFeatureType = nodeSource.getName();
			end
			if (DB.getValue(v, "specializationchoice", 0) == 1) then
				local bSpecialization = false;

				for _,vSpecWindow in pairs(wList.getWindows()) do
					if vSpecWindow.group_name.getValue():match(sSelectionName:upper() .. " SPECIALIZATION") then
						bSpecialization = true;
					end
				end

				if not bSpecialization then
					local tClassSpecOptions = CharManager.getClassSpecializationOptions(nodeSource);
					local aSpecializationOptions = {};
					for _,v in ipairs(tClassSpecOptions) do
						local sSpecName = v.text:lower();
						local sModule = v.linkrecord:match("[^@]*@(.+)") or "Campaign";
						local sTooltip = string.format("%s: %s", v.text, sModule);
						aSpecializationOptions[sSpecName] = { tooltip = sTooltip, class = v.linkclass, record = v.linkrecord };
					end

					CharWizardManager.createSelectionWindows(wList, sSelectionName:upper() .. " SPECIALIZATION", aSpecializationOptions, 1, true);
				end
				bParsed = true;
			end
			if sFeatureType == "abilityscoreimprovement" then
				local bASI = false;
				for _,v in pairs(wList.getWindows()) do
					if v.group_name.getValue():match(sSelectionName:upper() .. " " .. nLevel .. " ASI CHOICE") then
						bASI = true;
						break
					end
				end

				if not bASI then
					local aASIChoice = { ["asi"] = {tooltip = "Ability Score Increase"}, ["feat"] = { tooltip = "Feat" } };
					CharWizardManager.createSelectionWindows(wList, sSelectionName:upper() .. " " .. nLevel .. " ASI CHOICE", aASIChoice, 1);
				end
				bParsed = true;
			end
			if sFeatureType == "expertise" then
				local bExpertise = false;
				for _,v in pairs(wList.getWindows()) do
					if v.group_name.getValue():match(sSelectionName:upper() .. " EXPERTISE") then
						bExpertise = true;
						break
					end
				end

				if not bExpertise then
					local bThievesTools = false;
					local aSkills = {};

					for _,vSkill in pairs(wndSummary.summary.subwindow.summary_skills.getWindows()) do
						if vSkill.expertise.getValue() == 0 then
							aSkills[vSkill.name.getValue():lower()] = { tooltip = "Provides double proficiency for skill." }
						end
					end

					for _,vProf in pairs(wndSummary.summary.subwindow.summary_proficiencies.getWindows()) do
						if vProf.name.getValue():lower() == "thieves' tools" and vProf.expertise.getValue() == 1 then
							bThievesTools = true;
						end
					end

					if sClassName == "rogue" and not bThievesTools then
						aSkills["thieves' tools"] = { tooltip = "Provides double proficiency for skill." }
					end

					CharWizardManager.createSelectionWindows(wList, sSelectionName:upper() .. " EXPERTISE", aSkills, 2);
				end

				bParsed = true;
			end
			if not bParsed then
				if CharWizardDataAction.parsedata[sFeatureType] then
					if CharWizardDataAction.parsedata[sFeatureType].proficiency then
						if CharWizardDataAction.parsedata[sFeatureType].proficiency.innate then
							for _,v in pairs(CharWizardDataAction.parsedata[sFeatureType].proficiency.innate) do
								wndSummary.proficiencies_class[v] = { type = sSpecialization:lower(), expertise = 0 };
							end
						end
						if CharWizardDataAction.parsedata[sFeatureType].proficiency.choice then
							local aChoiceTools = {};
							local sTool = CharWizardDataAction.parsedata[sFeatureType].proficiency.choice_profs[1];

							if sTool:match("gaming") or sTool:match("musical") or sTool:match("artisan") then
								local aToolGroups = {};

								if sTool:match("gaming") then
									table.insert(aToolGroups, "gaming set");
								end

								if sTool:match("musical") then
									table.insert(aToolGroups, "musical instrument");
								end

								if sTool:match("artisan") then
									table.insert(aToolGroups, "artisan's tools");
								end

								for _,vGroup in pairs(aToolGroups) do
									local a = wndSummary.getToolType(vGroup);

									for _,i in pairs(a) do
										aChoiceTools[i] = { tooltip = "Select Tool Proficiency." };
									end
								end
							else
								for _,v in pairs(CharWizardDataAction.parsedata[sFeatureType].proficiency.choice_profs) do
									aChoiceTools[v] = { tooltip = "Select proficiency" };
								end
							end

							CharWizardManager.createSelectionWindows(wList, sSelectionName:upper() .. " TOOL PROFICIENCY", aChoiceTools, CharWizardDataAction.parsedata[sFeatureType].proficiency.choice);
						end

						wndSummary.updateProficiencies();
					end
					if CharWizardDataAction.parsedata[sFeatureType].skills then
						if CharWizardDataAction.parsedata[sFeatureType].skills.innate then
							for _,v in pairs(CharWizardDataAction.parsedata[sFeatureType].skills.innate) do
								local wSkill = wndSummary.summary.subwindow.summary_skills.createWindow();

								wSkill.name.setValue(StringManager.titleCase(v:lower()));
								wSkill.type.setValue(sSpecialization:lower());
								wndSummary.summary.subwindow.summary_skills.applySort();
							end
						end
						if CharWizardDataAction.parsedata[sFeatureType].skills.choice then
							local aChoiceSkills = {};
							if CharWizardDataAction.parsedata[sFeatureType].skills.choice_skills[1] == "any" then
								aChoiceSkills = wndSummary.getAvailableSkills()
							else
								for _,v in pairs(CharWizardDataAction.parsedata[sFeatureType].skills.choice_skills) do
									aChoiceSkills[v] = { tooltip = "Select skill" };
								end
							end

							CharWizardManager.createSelectionWindows(wList, sSelectionName:upper() .. " SKILL PROFICIENCY", aChoiceSkills, CharWizardDataAction.parsedata[sFeatureType].skills.choice);
						end
					end
					if CharWizardDataAction.parsedata[sFeatureType].languages then
						if CharWizardDataAction.parsedata[sFeatureType].languages.innate then
							for _,v in pairs(CharWizardDataAction.parsedata[sFeatureType].languages.innate) do
								local wLang = wndSummary.summary.subwindow.summary_languages.createWindow();

								wLang.name.setValue(StringManager.titleCase(v:lower()));
								wLang.type.setValue(sSpecialization:lower());
								wndSummary.summary.subwindow.summary_languages.applySort();
							end
						end
						if CharWizardDataAction.parsedata[sFeatureType].languages.choice then
							local aChoiceLang = {};

							if CharWizardDataAction.parsedata[sFeatureType].languages.choice_languages[1] == "any" then
								aChoiceLang = wndSummary.getAvailableLanguages()
							else
								for k,v in pairs(CharWizardDataAction.parsedata[sFeatureType].languages.choice_languages) do
									aChoiceLang[k] = { tooltip = "Select skill" };
								end
							end

							CharWizardManager.createSelectionWindows(wList, sSelectionName:upper() .. " LANGUAGE", aChoiceLang, CharWizardDataAction.parsedata[sFeatureType].languages.choice);
						end
					end
				end

				local bFound = false;
				for _,vSumFeature in pairs(wndSummary.summary.subwindow.summary_features.getWindows()) do
					if vSumFeature.name.getValue() == DB.getValue(v, "name", "") then
						bFound = true;
					end
				end

				if not bFound then
					local wndTrait = wndSummary.summary.subwindow.summary_features.createWindow();

					wndTrait.name.setValue(DB.getValue(v, "name", ""));
					wndTrait.link.setValue("reference_classfeature", v.getPath());
					wndTrait.classlevel.setValue(nFeatureLevel);
					wndTrait.type.setValue(sSpecReq:lower());

					wndSummary.summary.subwindow.summary_features.applySort();
				end
			end
		end
	end

	if #aFeatList > 0 then
		CharWizardManager.updateASI(wndSummary, aFeatList);
	end

	CharWizardManager.getAlerts(wndSummary, wList)

	wndSummary.updateProficiencies(wndSummary);
	wndSummary.checkFeatSpellInv();
end

function removeFeatures(wSelection, wList, sSelectionName, wndSummary, nodeSource, nLevel, nPrevLevel)
	local sClassName = DB.getValue(nodeSource, "name", ""):lower();
	local aCloseWin = {};
	local sSpecialization = ""
	local nSpecLvl = 3;
	local nASIMaxLvl = 0;

	for _,v in pairs(DB.getChildren(nodeSource, "features")) do
		local nFeatureLvl = DB.getValue(v, "level", 0)
		if (DB.getValue(v, "specializationchoice", 0) == 1) then
			nSpecLvl = nFeatureLvl;
		end
		if (DB.getValue(v, "abilityscoreimprovement", 0) == 1) and nFeatureLvL < nLevel then
			if nFeatureLvl >= nASIMaxLvl then
				nASIMaxLvl = nFeatureLvl;
			end
		end
	end

	for _,vSpecWindow in pairs(wList.getWindows()) do
		if vSpecWindow.group_name.getValue():match("SPECIALIZATION") and vSpecWindow.group_name.getValue():match(sClassName:upper()) then
			sSpecialization = vSpecWindow.selection_name.getValue():lower();

			if nPrevLevel <= nSpecLvl then
				table.insert(aCloseWin, vSpecWindow)

				CharWizardManager.clearSummary(wndSummary, sSpecialization, "specialization")
			end
		elseif vSpecWindow.group_name.getValue():match("ASI CHOICE") and vSpecWindow.group_name.getValue():match(sClassName:upper()) then
			local nASILvl = vSpecWindow.group_name.getValue():match("(%d+)");

			if tonumber(nASILvl) >= nLevel then
				table.insert(aCloseWin, vSpecWindow)

				if wndSummary.genfeats.subwindow then
					for _,v in pairs(wndSummary.genfeats.subwindow.contents.subwindow.feat_window.getWindows()) do
						if v.group_name.getValue():match(sClassName:upper()) then
							local nFeatLvl = vSpecWindow.group_name.getValue():match("(%d+)");

							if tonumber(nFeatLvl) >= nLevel then
								table.insert(aCloseWin, v)
							end
						end
					end
				end

				if wndSummary.genstats.subwindow then
					for _,v in pairs(wndSummary.genstats.subwindow.contents.subwindow.abilityscore_improvements.getWindows()) do
						if v.group_name.getValue():match(sClassName:upper()) then
							local nStatLvl = vSpecWindow.group_name.getValue():match("(%d+)");

							if tonumber(nStatLvl) >= nLevel then
								table.insert(aCloseWin, v)
							end
						end
					end
				end
			end
		end
	end

	CharWizardManager.clearSummary(wndSummary, sClassName, "features", nLevel)
	CharWizardManager.clearSummary(wndSummary, sSpecialization, "features", nLevel)

	for _,v in pairs(aCloseWin) do
		v.close();
	end

	if wndSummary.import == 0 then
		CharWizardManager.createFeatureWindows(wSelection, wList, sSelectionName, wndSummary, nodeSource, nLevel, nPrevLevel)
	end
end

function updateClassSkills(wndSummary, sSkillText)
	local aSkills = {};
	local aClassSkills = {};
	local aChoiceSkills = {};
	local nSkillChoices = 2;
	local bChoice = false;
	local bFreeSkill = false;
	local aAvailableSkills = wndSummary.getAvailableSkills();

	if sSkillText:match("four") then
		nSkillChoices = 4;
	elseif sSkillText:match("three") then
		nSkillChoices = 3;
	end

	local sSkills = sSkillText:match("from ([^.]+)");

	if sSkills then
		sSkills = sSkills:gsub("or ", "");
		sSkills = sSkills:gsub("and ", "");

		for _,v in pairs(StringManager.split(sSkills, ",")) do
			v = StringManager.trim(v)

			if aAvailableSkills[v] then
				aChoiceSkills[v:lower()] = { tooltip = "Select skill." };
			end
		end

		bChoice = true
	end

	if sSkillText:match("choose") and sSkillText:match("any") then
		for k,v in pairs(aAvailableSkills) do
			aChoiceSkills[k:lower()] = { tooltip = "Select skill." };
		end

		bChoice = true
	end

	return bChoice, aChoiceSkills, nSkillChoices;
end

function parseClassSkillProficiency(wSelection, wList, sSelectionName, wndSummary, bIncrease)
	CharWizardManager.onSelectionChange(wSelection);

	local sClassName = wSelection.group_name.getValue():lower():match("([%w]+) skill proficiency");
	if wSelection.selection_count.isVisible() then
		local nCount = wSelection.selection_count.getValue();
		if nCount > 1 then
			CharWizardManager.clearSummary(wndSummary, sClassName, "skills_choice");
		end

		if bIncrease == false then
			local aSkills = wndSummary.summary.subwindow.summary_skills.getWindows();
			local aClassChoiceSkill = {};

			for _,v in pairs(aSkills) do
				if v.name.getValue():lower() == sSelectionName:lower() then
					table.insert(aClassChoiceSkill, v)
				end
			end

			if #aClassChoiceSkill > 0 then
				for _,v in pairs(aClassChoiceSkill) do
					v.close();
				end
			end
		else
			local wSkill = wndSummary.summary.subwindow.summary_skills.createWindow();
			wSkill.name.setValue(StringManager.titleCase(sSelectionName:lower()));
			wSkill.type.setValue(sClassName);
			wndSummary.summary.subwindow.summary_skills.applySort();
		end
	else
		CharWizardManager.clearSummary(wndSummary, sClassName, "skills_choice");

		local wSkills = wndSummary.summary.subwindow.summary_skills.createWindow();
		wSkills.name.setValue(StringManager.titleCase(sSelectionName:lower()));
		wSkills.type.setValue(sClassName);
		wndSummary.summary.subwindow.summary_skills.applySort();
	end

	wndSummary.updateExpertise();
end

function updateClassTools(wndSummary, sSpecialization, sToolText)
	local aClassTools = {};
	local aTools = {};
	local nToolChoices = 1;
	local aChoiceTools = {};
	local bChoice = false;

	sToolText = sToolText:gsub(" or ", ",")
	aTools = StringManager.split(sToolText, ",");

	for _,v in pairs(aTools) do
		v = StringManager.trim(v);

		if v:match("three") then
			nToolChoices = 3;
		elseif v:match("two") then
			nToolChoices = 2;
		end

		if v:match("gaming") or v:match("musical") or v:match("artisan") then
			local aToolGroups = {};
			local sChoiceTools = v:match("type of (.+)");

			if v:match("gaming") then
				table.insert(aToolGroups, "gaming set");
			end

			if v:match("musical") then
				table.insert(aToolGroups, "musical instrument");
			end

			if v:match("artisan") then
				table.insert(aToolGroups, "artisan's tools");
			end

			for _,vGroup in pairs(aToolGroups) do
				local a = wndSummary.getToolType(vGroup);

				for _,i in pairs(a) do
					aChoiceTools[i] = { tooltip = "Select Tool Proficiency." };
				end
			end

			bChoice = true;
		else
			if v ~= "none" then
				--v = v:gsub("all ", "")
				table.insert(aClassTools, v);
			end
		end

	end

	for _,v in pairs(aClassTools) do
		wndSummary.proficiencies_class[StringManager.trim(v):lower()] = { type = sSpecialization:lower(), expertise = 0 };
	end

	return bChoice, aChoiceTools, nToolChoices;
end

function parseClassToolProficiency(wSelection, wList, sSelectionName, wndSummary, bIncrease)
	CharWizardManager.onSelectionChange(wSelection);

	local sClassName = wSelection.group_name.getValue():lower():match("([%w]+) tool proficiency");
	if wSelection.selection_count.isVisible() then
		local nCount = wSelection.selection_count.getValue();
		if nCount > 1 then
			CharWizardManager.clearSummary(wndSummary, sClassName .. "_choice", "toolproficiency")
		end

		if bIncrease == false then
			CharWizardManager.clearSummary(wndSummary, sClassName .. "_choice", "toolproficiency")
		else
			wndSummary.proficiencies_class[sSelectionName:lower()] = { type = sClassName .. "_choice", expertise = 0 };
		end
	else
		CharWizardManager.clearSummary(wndSummary, sClassName .. "_choice", "toolproficiency")

		wndSummary.proficiencies_class[sSelectionName:lower()] = { type = sClassName .. "_choice", expertise = 0 };
	end

	wndSummary.updateProficiencies(wndSummary);
end

function parseSpecialization(wSelection, wList, wndSummary, nodeSource, sSelectionName, sSelectionClass)
	local sClassName = wSelection.group_name.getValue():gsub(" SPECIALIZATION", ""):lower();
	local sOldSpec = wSelection.selection_name.getValue():lower();
	local aCloseWin = {};

	for _,v in pairs(wndSummary.summary.subwindow.summary_features.getWindows()) do
		if v.type.getValue() == sOldSpec then
			table.insert(aCloseWin, v);
		end
	end

	for _,v in pairs(wndSummary.summary.subwindow.summary_specialization.getWindows()) do
		if v.name.getValue():lower() == sOldSpec then
			table.insert(aCloseWin, v);
		end
	end

	for _,v in pairs(aCloseWin) do
		v.close();
	end

	for _,vSelectSpecialization in pairs(wList.getWindows()) do
		if StringManager.contains({"CLASS", "MULTICLASS", "INCREASE LEVEL"}, vSelectSpecialization.group_name.getValue()) then
			if vSelectSpecialization.selection_name.getValue():lower() == sClassName then
				sClassRef, sClassRecord = vSelectSpecialization.selection_shortcut.getValue();
				nClassLevel = vSelectSpecialization.level.getValue();
				nSpecLvl = 0;

				for _,vFeature in pairs(DB.getChildren(nodeSource.getParent().getParent(), "features")) do
					if (DB.getValue(vFeature, "specializationchoice", 0) == 1) then
						nSpecLvl = DB.getValue(vFeature, "level", 0);
					end
				end

				CharWizardManager.completeSelection(wSelection, sSelectionName, sSelectionClass, nodeSource.getPath());

				local wndSpecialization = wndSummary.summary.subwindow.summary_specialization.createWindow();

				wndSpecialization.name.setValue(StringManager.titleCase(sSelectionName));
				wndSpecialization.classlevel.setValue(nClassLevel);
				wndSpecialization.link.setValue(sSelectionClass, nodeSource.getPath());

				--check how many levels between levelup and selection

				local nAdd = nClassLevel - nSpecLvl;
				if nAdd == 0 then
					nAdd = 1;
				end
				for i = 1, nClassLevel do
					CharWizardManager.createFeatureWindows(wSelection, wList, sSelectionName, wndSummary, nodeSource.getParent().getParent(), i, i, sSelectionName:lower())
				end

				break
			end
		end
	end

	wndSummary.checkFeatSpellInv();
end

function parseASIChoice(wSelection, wList, wndSummary, nodeSource, sSelectionName)
	CharWizardManager.onSelectionChange(wSelection);

    local sClassName = wSelection.group_name.getValue():lower():match("(.-) asi choice")
    local sClassLevel = wSelection.group_name.getValue():lower():match("(%d+)")
    local sType = StringManager.trim(sClassName:upper());
    sClassName = sClassName:gsub("%d+", "")

    if sSelectionName == "asi" then
        if wndSummary.genfeats.subwindow then
            for _,v in pairs(wndSummary.genfeats.subwindow.contents.subwindow.feat_window.getWindows()) do
                if v.group_name.getValue():lower():match(StringManager.trim(sClassName)) then
                    if v.group_name.getValue():match(StringManager.trim(sClassLevel)) then
                        v.close();
                    end
                end
            end
        end

        if wndSummary.genstats.subwindow then
	        local aAbilities = {};

	        for _,i in pairs(DataCommon.abilities) do
	            aAbilities[i:lower()] = { tooltip = Interface.getString("charwizard_tooltip_asi") };
	        end

            CharWizardManager.createSelectionWindows(wndSummary.genstats.subwindow.contents.subwindow.abilityscore_improvements, sType .. " ASI", aAbilities, 2)
        end
    elseif sSelectionName == "feat" then
        if wndSummary.genstats.subwindow then
            for _,v in pairs(wndSummary.genstats.subwindow.contents.subwindow.abilityscore_improvements.getWindows()) do
                if v.group_name.getValue():lower():match(StringManager.trim(sClassName)) then
                    if v.group_name.getValue():lower():match(StringManager.trim(sClassLevel)) then
                        v.close();
                    end
                end
            end
        end

        if wndSummary.genfeats.subwindow then
            CharWizardManager.createSelectionWindows(wndSummary.genfeats.subwindow.contents.subwindow.feat_window, sType .. " FEAT", wndSummary.loaded_feats, 1, true)
        end
    end
end

function parseExpertise(wSelection, wList, wndSummary, sSelectionName)
	CharWizardManager.onSelectionChange(wSelection);

	for _,v in pairs(wndSummary.summary.subwindow.summary_skills.getWindows()) do
		if v.name.getValue():lower() == sSelectionName:lower() then
			v.expertise.setValue(1);
		else
			if v.type.getValue() ~= "imported" and v.expertise.getValue() ~= 1 then
				v.expertise.setValue(0);
			end
		end
	end
	for k,v in pairs(wndSummary.proficiencies_class) do
		if k:lower() == sSelectionName:lower() then
			v.expertise = 1;
		else
			v.expertise = 0;
		end
	end

	wndSummary.updateProficiencies();
end

function updateFeats()
	local aFeatList = {};

	for k,v in pairs(getWindows()) do
		if v.group_name.getValue() == "CLASS" or v.group_name.getValue() == "MULTICLASS" or v.group_name.getValue() == "INCREASE LEVEL" then
			if v.selection_name.getValue() ~= "" then
				local sClassName = v.selection_name.getValue();
				local sClass, sRecord = v.selection_shortcut.getValue();
				local nClassLevel = tonumber(v.level.getValue());
				local nMaxFeatLevel = 0;

				if #aFeatList > 0 then
					for _,vFeats in pairs(aFeatList) do
						if vFeats.name == sClassName then
							if vFeats.level > nMaxFeatLevel then
								nMaxFeatLevel = vFeats.level;
							end
						end
					end
				end

				for _,v in pairs(DB.getChildren(DB.findNode(sRecord), "features")) do
					local sFeatureType = CampaignDataManager2.sanitize(DB.getValue(v, "name", ""));
					local nFeatureLevel = tonumber(DB.getValue(v, "level", ""));

					if sFeatureType == "abilityscoreimprovement" and nFeatureLevel <= nClassLevel then--and nFeatureLevel > nMaxFeatLevel then
						table.insert(aFeatList, {name = sClassName, level = nFeatureLevel});
					end
				end
			end
		end
	end

	return aFeatList;
end

--
-- Background
--

function parseBackground(wSelection, wList, wndSummary, sSelectionName, nodeSource)
	CharWizardManager.closeListWindowsExcept(wList, { "BACKGROUND" });
	CharWizardManager.onSelectionChange(wSelection, "reference_background", nodeSource.getPath());

	wndSummary.summary.subwindow.summary_background.setValue(StringManager.titleCase(sSelectionName));
	CharWizardManager.clearSummary(wndSummary, "background", "all")
	CharWizardManager.clearSummary(wndSummary, "background_choice", "all")

	if wndSummary.geninv.subwindow then
		local aCloseWin = {}

		for _,v in pairs(wndSummary.geninv.subwindow.contents.subwindow.kitlist.getWindows()) do
			if v.group_name.getValue():match("BACKGROUND") then
				table.insert(aCloseWin, v)
			end
		end

		for _,v in pairs(aCloseWin) do
			v.close();
		end

		local aFinalInv = {};
		for _,v in pairs(wndSummary.inventory) do
			if v.source ~= "background" then
				table.insert(aFinalInv, v)
			end
		end

		wndSummary.inventory = aFinalInv;
		wndSummary.geninv.subwindow.contents.subwindow.kitlist.parseBackground();
	end

	if DB.getValue(nodeSource, "skill", "") ~= "" then
		aBackgroundSkills, bChoice, aChoiceSkills, nSkillChoices = updateBackgroundSkills(wndSummary, DB.getValue(nodeSource, "skill", ""):lower());
		if bChoice then
			CharWizardManager.createSelectionWindows(wList, "SELECT SKILL PROFICIENCY", aChoiceSkills, nSkillChoices);
		end
		wndSummary.summary.subwindow.summary_skills.applySort();
		wndSummary.updateExpertise()
	end
	if DB.getValue(nodeSource, "languages", "") ~= "" then
		local aBackgroundLanguages, bChoice, aChoiceLanguages, nLanguageChoices = updateBackgroundLanguages(wndSummary, DB.getValue(nodeSource, "languages", ""):lower());
		if bChoice then
			CharWizardManager.createSelectionWindows(wList, "SELECT LANGUAGES", aChoiceLanguages, nLanguageChoices);
		end
		wndSummary.summary.subwindow.summary_languages.applySort();
	end
	if DB.getValue(nodeSource, "tool", "") ~= "" then
		-- House Agent needs attention
		local aBackgroundTools, bChoice, aItemTools, nToolChoices = updateBackgroundTools(wndSummary, DB.getValue(nodeSource, "tool", ""):lower());
		if bChoice then
			CharWizardManager.createSelectionWindows(wList, "SELECT TOOL PROFICIENCY", aItemTools, nToolChoices);
		end
	end

	for _,v in pairs(DB.getChildren(nodeSource, "features")) do
		local wndTrait = wndSummary.summary.subwindow.summary_traits.createWindow();
		wndTrait.name.setValue(DB.getValue(v, "name", ""));
		wndTrait.link.setValue("reference_backgroundfeature", v.getPath());
		wndTrait.type.setValue("background");

		wndSummary.summary.subwindow.summary_traits.applySort();
	end

	wndSummary.updateProficiencies(wndSummary);
	wndSummary.checkFeatSpellInv();
end

function updateBackgroundSkills(wndSummary, sSkillText)
	CharWizardManager.clearSummary(wndSummary, "background", "skills")

	local aSkills = {};
	local aBackgroundSkills = {};
	local aChoiceSkills = {};
	local nSkillChoices = 1;
	local bChoice = false;
	local bFreeSkill = false;
	local aSelectedSkills = wndSummary.getAvailableSkills();

	if sSkillText:lower():match("two") then
		nSkillChoices = 2;
	end

	local sFreeSkill,sSkills = sSkillText:match("(.-) and one (.-) skill of your choice");

	if not sSkills then
		sFreeSkill = sSkillText:match("(.-), plus one");
		sSkills = sSkillText:match("of your choice from among ([^.]+)");
	end

	if not sSkills then
		sFreeSkill = sSkillText:match("(.-), plus your choice")
		sSkills = sSkillText:match("of one from among ([^.]+)");
	end

	if not sSkills then
		sSkills = sSkillText:match("choose two from among ([^.]+)");
	end

	if not sSkills then
		aBackgroundSkills = StringManager.split(sSkillText, ",");
	end

	sFreeSkill = StringManager.trim(sFreeSkill);
	if (sFreeSkill or "") ~= "" then
		table.insert(aBackgroundSkills, sFreeSkill)
	end

	if sSkills ~= nil then
		if sSkills:match("intelligence") then
			for k,v in pairs(DataCommon.skilldata) do
				if v.stat == "intelligence" or v.stat == "wisdom" or v.stat == "charisma" then
					table.insert(aChoiceSkills, k:lower());
				end
			end
		else
			local tSkillParse = StringManager.splitByPattern(sSkills, ",");
			for _,v in pairs(tSkillParse) do
				v = StringManager.trim(v);
				v = v:gsub("^and ", "");
				if aSelectedSkills[v] then
					table.insert(aChoiceSkills, v:lower());
				end
			end
		end

		bChoice = true;
	end

	for _,v in pairs(aBackgroundSkills) do
		v = StringManager.trim(v);

		if not aSelectedSkills[v:lower()] then
			if wndSummary.genclass.subwindow then
				local aCloseWin = {};

				for _,vClass in pairs(wndSummary.genclass.subwindow.contents.subwindow.class_window.getWindows()) do
					if vClass.group_name.getValue():lower():match("skill proficiency") then
						for _,vSelect in pairs(vClass.selection_window.getWindows()) do
							if vSelect.name.getValue():lower() == v:lower() then
								if vSelect.value.getValue() == "1" then
									vSelect.bname.onButtonPress();
								end

								table.insert(aCloseWin, vSelect);
								vClass.selection_window.setVisible(true);
								vClass.button_expand.setValue(1);
							end
						end
					end
				end

				for _,vClose in pairs(aCloseWin) do
					vClose.close();
				end

				CharWizardManager.getAlerts(wndSummary, wndSummary.genclass.subwindow.contents.subwindow.class_window);
				wndSummary.updateExpertise();
			end
		end

		local wndSkillList = wndSummary.summary.subwindow.summary_skills.createWindow();
		wndSkillList.name.setValue(StringManager.trim(StringManager.titleCase(v)));
		wndSkillList.type.setValue("background");
		wndSummary.summary.subwindow.summary_skills.applySort();
	end

	aFinalChoiceSkills = {};
	if #aChoiceSkills > 0 then
		for _,v in pairs(aChoiceSkills) do
			aFinalChoiceSkills[v:lower()] = { tooltip = "Select skill" };
		end
	end

	return aBackgroundSkills, bChoice, aFinalChoiceSkills, nSkillChoices;
end

function parseBackgroundSkillProf(wSelection, wndSummary, sSelectionName, bIncrease, nodeSource)
	CharWizardManager.onSelectionChange(wSelection);

	if wSelection.selection_count.isVisible() then
		local nCount = wSelection.selection_count.getValue();
		if nCount > 1 then
			CharWizardManager.clearSummary(wndSummary, "background_choice", "skills")
		end

		if bIncrease == false then
			local aSkills = wndSummary.summary.subwindow.summary_skills.getWindows();
			local aBackgroundChoiceSkill = {};
			for _,v in pairs(aSkills) do
				if v.name.getValue():lower() == sSelectionName then
					table.insert(aBackgroundChoiceSkill, v)
				end
			end
			if #aBackgroundChoiceSkill > 0 then
				for _,v in pairs(aBackgroundChoiceSkill) do
					v.close();
				end
			end
		else
			local wSkills = wndSummary.summary.subwindow.summary_skills.createWindow();
			wSkills.name.setValue(StringManager.titleCase(sSelectionName:lower()));
			wSkills.type.setValue("background_choice");
			wndSummary.summary.subwindow.summary_skills.applySort();
		end
	else
		CharWizardManager.clearSummary(wndSummary, "background_choice", "skills")

		local wSkills = wndSummary.summary.subwindow.summary_skills.createWindow();
		wSkills.name.setValue(StringManager.titleCase(sSelectionName:lower()));
		wSkills.type.setValue("background_choice");
		wndSummary.summary.subwindow.summary_skills.applySort();
	end

	wndSummary.updateExpertise()
end

function updateBackgroundTools(wndSummary, sToolText, aIncomingTools)
	CharWizardManager.clearSummary(wndSummary, "background", "proficiencies")

	local aBackgroundTools = {};
	local aItemTools = {};
	local nToolChoices = 1;
	local bChoice = false;

	if sToolText:lower():match("two") then
		nToolChoices = 2;
	end

	local sTools = sToolText:match("choose two from among ([^.]+)");

	if not sTools then
		sTools = sToolText:gsub(", likely something native to your homeland", "");

		if sTools:match(" or") then
			sTools = sTools:gsub(" or", ",");
			bChoice = true;
		end
	end

	sTools = sTools:gsub("and", "");
	aBackgroundTools = StringManager.split(sTools, ",");

	for _,vTools in pairs(aBackgroundTools) do
		vTools = StringManager.trim(vTools);

		if vTools:match("type") or vTools:match("choice") or nToolChoices > 1 then
			bChoice = true;

			if vTools:match("thieves%'") then
				table.insert(aItemTools, "thieves' tools");
			end
		end

		if vTools:match("gaming") or vTools:match("musical") or vTools:match("artisan") then
			local aToolGroups = {};
			local sChoiceTools = vTools:match("type of (.+)");

			if vTools:match("gaming") then
				table.insert(aToolGroups, "gaming set");
			end

			if vTools:match("musical") then
				table.insert(aToolGroups, "musical instrument");
			end

			if vTools:match("artisan") then
				table.insert(aToolGroups, "artisan's tools");
			end

			for _,v in pairs(aToolGroups) do
				local a = wndSummary.getToolType(v);

				for _,i in pairs(a) do
					table.insert(aItemTools, i);
				end
			end
		else
			if not bChoice then
				wndSummary.proficiencies_background[vTools:lower()] = { type = "background", expertise = 0 };
			end
		end
	end

	aChoiceTools = {};
	if #aItemTools > 0 then
		for _,v in pairs(aItemTools) do
			aChoiceTools[v:lower()] = { tooltip = "Select proficiency" };
		end
	end

	return aBackgroundTools, bChoice, aChoiceTools, nToolChoices;
end

function parseBackgroundToolProf(wSelection, wndSummary, sSelectionName, bIncrease, nodeSource)
	CharWizardManager.onSelectionChange(wSelection);

	if wSelection.selection_count.isVisible() then
		local nCount = wSelection.selection_count.getValue();
		if nCount > 1 then
			CharWizardManager.clearSummary(wndSummary, "background_choice", "toolproficiency")
		end

		if bIncrease == false then
			local aTools = wndSummary.proficiencies_background;
			local aBackgroundChoiceTools = {};

			for k,v in pairs(aTools) do
				if k:lower() ~= sSelectionName:lower() then
					table.insert(aBackgroundChoiceTools, v)
				end
			end

			wndSummary.proficiencies_background = aBackgroundChoiceTools;
		else
			wndSummary.proficiencies_background[sSelectionName:lower()] = { type = "background_choice", expertise = 0 };
		end
	else
		clearSummary(wndSummary, "background_choice", "toolproficiency")

		wndSummary.proficiencies_background[sSelectionName:lower()] = { type = "background_choice", expertise = 0 };
	end

	wndSummary.updateProficiencies(wndSummary);
end

function updateBackgroundLanguages(wndSummary, sLanguageText)
	clearSummary(wndSummary, "background", "languages");

	local aLanguages = {};
	local aBackgroundLanguages = {};
	local aChoiceLanguages = {};
	local nLanguageChoices = 1;
	local bChoice = true;
	local aAvailableLanguages = wndSummary.getAvailableLanguages()

	if sLanguageText:match("two") then
		nLanguageChoices = 2;
	end

	if sLanguageText:match("if you already speak Dwarvish") then
		if StringManager.contains(aAvailableLanguages, "dwarvish") then
			table.insert(aBackgroundLanguages, "Dwarvish");
			bChoice = false;
		end
	end

	if sLanguageText:match("choose") then
		local sChoiceLanguages = string.match(sLanguageText, "choose one of (.+)");

		if not sChoiceLanguages then
			sChoiceLanguages = string.match(sLanguageText, "choose either (.+)");
		end

		if not sChoiceLanguages then
			sChoiceLanguages = string.match(sLanguageText, "choose two languages one of which is an exotic language %((.+)%)");
			aChoiceLanguages = aAvailableLanguages;
		end

		if not sChoiceLanguages then
			return false;
		end

		sChoiceLanguages = string.gsub(sChoiceLanguages, "and ", "");
		sChoiceLanguages = string.gsub(sChoiceLanguages, "or ", "");
		sChoiceLanguages = string.gsub(sChoiceLanguages, "plus(.+)", "");
		sChoiceLanguages = string.gsub(sChoiceLanguages, "one(.+)", "");

		for s in sChoiceLanguages:gmatch("(%a[%a%s]+)%,?") do
			aChoiceLanguages[s:lower()] = {tooltip = "Select Language" };
		end
	end

	for _,v in pairs(aBackgroundLanguages) do
		local wndLangList = wndSummary.summary.subwindow.summary_languages.createWindow();

		wndLangList.name.setValue(StringManager.titleCase(v));
		wndLangList.type.setValue("background");
	end

	if not bChoice then
		return aBackgroundLanguages, bChoice, {}, nLanguageChoices;
	else
		if #aChoiceLanguages > 0 then
			return {}, bChoice, aChoiceLanguages, nLanguageChoices;
		else
			return {}, bChoice, aAvailableLanguages, nLanguageChoices;
		end
	end
end

function parseBackgroundLanguage(wSelection, sSelectionName, wndSummary, bIncrease)
	CharWizardManager.onSelectionChange(wSelection);

	if wSelection.selection_count.isVisible() then
		local nCount = wSelection.selection_count.getValue();
		if nCount > 1 then
			clearSummary(wndSummary, "background_choice", "languages");
		end

		if bIncrease == false then
			local aLanguages = wndSummary.summary.subwindow.summary_languages.getWindows();
			local aBackgroundChoiceLang = {};

			for _,v in pairs(aLanguages) do
				if v.name.getValue():lower() == sSelectionName then
					table.insert(aBackgroundChoiceLang, v)
				end
			end

			if #aBackgroundChoiceLang > 0 then
				for _,v in pairs(aBackgroundChoiceLang) do
					v.close();
				end
			end
		else
			local wLanguages = wndSummary.summary.subwindow.summary_languages.createWindow();
			wLanguages.name.setValue(StringManager.titleCase(sSelectionName:lower()));
			wLanguages.type.setValue("background_choice");
			wndSummary.summary.subwindow.summary_languages.applySort();
		end
	else
		clearSummary(wndSummary, "background_choice", "languages");

		local wLanguages = wndSummary.summary.subwindow.summary_languages.createWindow();
		wLanguages.name.setValue(StringManager.titleCase(sSelectionName:lower()));
		wLanguages.type.setValue("background_choice");
		wndSummary.summary.subwindow.summary_languages.applySort();
	end
end

--[[function updateBackgroundSpells(wndSummary, sBackgroundText, sSelectionClass, sSelectionRecord) Needed for factoring guild spells
	local sSpellText = "";
	local sSpellTableText = "";
	local aSpells = {};
	local aLevelSpells = {};
	CampaignRegistry.charwizard.background = CampaignRegistry.charwizard.background or {};
	CampaignRegistry.charwizard.background.spells = CampaignRegistry.charwizard.background.spells or {};
	for _,vBackgroundFeatures in pairs(DB.getChildren(DB.findNode(sSelectionRecord), "features")) do
		if string.match(DB.getValue(vBackgroundFeatures, "name", ""), "Guild Spells") then
			sSpellText = DB.getValue(vBackgroundFeatures, "text");
			CampaignRegistry.charwizard.background.spells.name = DB.getValue(vBackgroundFeatures, "name", "");
		end
	end

	sSpellTableText = string.match(sSpellText, "Cantrip(.+)1st");
	sSpellTableText = string.gsub(sSpellTableText, "</td>", "");
	sSpellTableText = string.gsub(sSpellTableText, '<td colspan="3">', "");
	sSpellTableText = string.gsub(sSpellTableText, "<td>", "");
	sSpellTableText = string.gsub(sSpellTableText, "<tr>", "");
	sSpellTableText = string.gsub(sSpellTableText, "</tr>", "");
	sSpellTableText = string.gsub(sSpellTableText, "\n", "");
	sSpellTableText = string.gsub(sSpellTableText, ", ", ",");
	local _,nCount = string.gsub(sSpellTableText, ",", "");
	for sSpellName in sSpellTableText:gmatch('[^,]+') do
		table.insert(aLevelSpells, sSpellName);
	end
	CampaignRegistry.charwizard.background.spells[0] = aLevelSpells;
	sSpellTableText = string.match(sSpellText, "1st(.+)2nd");
	sSpellTableText = string.gsub(sSpellTableText, "</td>", "");
	sSpellTableText = string.gsub(sSpellTableText, '<td colspan="3">', "");
	sSpellTableText = string.gsub(sSpellTableText, "<td>", "");
	sSpellTableText = string.gsub(sSpellTableText, "<tr>", "");
	sSpellTableText = string.gsub(sSpellTableText, "</tr>", "");
	sSpellTableText = string.gsub(sSpellTableText, "\n", "");
	sSpellTableText = string.gsub(sSpellTableText, ", ", ",");
	local _,nCount = string.gsub(sSpellTableText, ",", "");
	aLevelSpells = {};
	for sSpellName in sSpellTableText:gmatch('[^,]+') do
		table.insert(aLevelSpells, sSpellName);
	end
	CampaignRegistry.charwizard.background.spells[1] = aLevelSpells;
	sSpellTableText = string.match(sSpellText, "2nd(.+)3rd");
	sSpellTableText = string.gsub(sSpellTableText, "</td>", "");
	sSpellTableText = string.gsub(sSpellTableText, '<td colspan="3">', "");
	sSpellTableText = string.gsub(sSpellTableText, "<td>", "");
	sSpellTableText = string.gsub(sSpellTableText, "<tr>", "");
	sSpellTableText = string.gsub(sSpellTableText, "</tr>", "");
	sSpellTableText = string.gsub(sSpellTableText, "\n", "");
	sSpellTableText = string.gsub(sSpellTableText, ", ", ",");
	local _,nCount = string.gsub(sSpellTableText, ",", "");
	aLevelSpells = {};
	for sSpellName in sSpellTableText:gmatch('[^,]+') do
		table.insert(aLevelSpells, sSpellName);
	end
	CampaignRegistry.charwizard.background.spells[2] = aLevelSpells;
	sSpellTableText = string.match(sSpellText, "3rd(.+)4th");
	sSpellTableText = string.gsub(sSpellTableText, "</td>", "");
	sSpellTableText = string.gsub(sSpellTableText, '<td colspan="3">', "");
	sSpellTableText = string.gsub(sSpellTableText, "<td>", "");
	sSpellTableText = string.gsub(sSpellTableText, "<tr>", "");
	sSpellTableText = string.gsub(sSpellTableText, "</tr>", "");
	sSpellTableText = string.gsub(sSpellTableText, "\n", "");
	sSpellTableText = string.gsub(sSpellTableText, ", ", ",");
	local _,nCount = string.gsub(sSpellTableText, ",", "");
	aLevelSpells = {};
	for sSpellName in sSpellTableText:gmatch('[^,]+') do
		table.insert(aLevelSpells, sSpellName);
	end
	CampaignRegistry.charwizard.background.spells[3] = aLevelSpells;
	sSpellTableText = string.match(sSpellText, "4th(.+)5th");
	sSpellTableText = string.gsub(sSpellTableText, "</td>", "");
	sSpellTableText = string.gsub(sSpellTableText, '<td colspan="3">', "");
	sSpellTableText = string.gsub(sSpellTableText, "<td>", "");
	sSpellTableText = string.gsub(sSpellTableText, "<tr>", "");
	sSpellTableText = string.gsub(sSpellTableText, "</tr>", "");
	sSpellTableText = string.gsub(sSpellTableText, "\n", "");
	sSpellTableText = string.gsub(sSpellTableText, ", ", ",");
	local _,nCount = string.gsub(sSpellTableText, ",", "");
	aLevelSpells = {};
	for sSpellName in sSpellTableText:gmatch('[^,]+') do
		table.insert(aLevelSpells, sSpellName);
	end
	CampaignRegistry.charwizard.background.spells[4] = aLevelSpells;
	sSpellTableText = string.match(sSpellText, "5th(.+)</table>");
	sSpellTableText = string.gsub(sSpellTableText, "</td>", "");
	sSpellTableText = string.gsub(sSpellTableText, '<td colspan="3">', "");
	sSpellTableText = string.gsub(sSpellTableText, "<td>", "");
	sSpellTableText = string.gsub(sSpellTableText, "<tr>", "");
	sSpellTableText = string.gsub(sSpellTableText, "</tr>", "");
	sSpellTableText = string.gsub(sSpellTableText, "\n", "");
	sSpellTableText = string.gsub(sSpellTableText, ", ", ",");
	local _,nCount = string.gsub(sSpellTableText, ",", "");
	aLevelSpells = {};
	for sSpellName in sSpellTableText:gmatch('[^,]+') do
		table.insert(aLevelSpells, sSpellName);
	end
	CampaignRegistry.charwizard.background.spells[5] = aLevelSpells;
end--]]

--
-- Inventory
--

function createStartingKit(sClass, wList)
	if CharWizardData.charwizard_starting_equipemnt[sClass] then
		for k,v in pairs(CharWizardData.charwizard_starting_equipemnt[sClass]) do
			if k:lower():match("included") then
				local w = wList.createWindow();

				w.group_name.setValue(k:upper());
				w.selection_name.setValue(StringManager.titleCase(v["selection_name"]));
				w.button_expand.setVisible(false);
				w.selection_window.setVisible(false);
				w.selection_name.setVisible(true);

				for _,vItem in pairs(v.addItemToInventory) do
					CharWizardManager.addItemToInventory(UtilityManager.getTopWindow(wList.window), vItem[1], vItem[2], vItem[3]);
				end
			else--if k:lower():match("choice") then
				if v["add equipment"] then
					local w = wList.createWindow();

					w.group_name.setValue(k)
					CharWizardManager.addEquipment(v["add equipment"][1], v["add equipment"][2], w);
				elseif v["selection"] then
					CharWizardManager.createSelectionWindows(wList, k, v["selection"], 1, true)
				elseif v["tool selection"] then
					local aChoiceTool = CharWizardManager.getItemByType(v["tool selection"][1]);
					local aFinalChoiceTool = {};

					for _,vItems in pairs(aChoiceTool) do
						aFinalChoiceTool[vItems.name] = { tooltip = "", class = "reference_equipment", record = vItems.link };
					end

					CharWizardManager.createSelectionWindows(wList, k, aFinalChoiceTool, 1, true)
				end
			end
		end
	end
end

function getItemByType(sItemType)
	local aTools = {};
	if sItemType and sItemType ~= "" then
		sItemType = string.lower(sItemType);
	end
	local aMappings = LibraryData.getMappings("item");
	for _,vMapping in ipairs(aMappings) do
		for _,vItem in pairs(DB.getChildrenGlobal(vMapping)) do
			if StringManager.trim(DB.getValue(vItem, "subtype", "")):lower() == sItemType then
				table.insert(aTools, { name = StringManager.trim(DB.getValue(vItem, "name", "")):lower(), link = vItem.getPath() });
			end
		end
	end
	local aFinalTools = {};
	local aDupes = {};
	for _,v in ipairs(aTools) do
		if not aDupes[v.name] then
			table.insert(aFinalTools, { name = v.name, link = v.link });
			aDupes[v.name] = true;
		end
	end
	return aFinalTools;
end

function parseBackgroundKit(wndSummary, wList)
	local aRPItems = {};
	local nodeBackground;
	local sEquipment = "";

	if wndSummary.genback.subwindow then
		for _,v in pairs(wndSummary.genback.subwindow.contents.subwindow.background_window.getWindows()) do
			if v.group_name.getValue() == "BACKGROUND" then
				local _,sRecord = v.selection_shortcut.getValue();
				if sRecord and sRecord ~= "" then
					nodeBackground = DB.findNode(sRecord);
				end
			end
		end
	end

	if nodeBackground then
		sEquipment = DB.getValue(nodeBackground, "equipment", "");

		-- FIND RP TEXT AND STORE IT IN TABLE TO MAKE RP ITEM IN INVENTORY LATER
		if sEquipment and sEquipment ~= "" then
			if sEquipment:match("tools of the con of your choice") then
				local sRPText = sEquipment:match("%((.+)%)");
				if sRPText and sRPText ~= "" then
					table.insert(aRPItems, { name = "Tools of the Con", record = "reference.equipmentdata.custom@DD PHB Deluxe", desc = sRPText });
					sEquipment = sEquipment:gsub(" tools of the con of your choice %((.+)%)", "");
					createCustomInventoryItem(wndSummary, aRPItems, true);
				end
			end
			if sEquipment:match("the favor of an admirer") then
				local sRPText = sEquipment:match("the favor of an admirer %((.+)%)");
				if sRPText and sRPText ~= "" then
					table.insert(aRPItems, { name = "The Favor of an Admirer", record = "reference.equipmentdata.custom@DD PHB Deluxe", desc = sRPText });
					sEquipment = sEquipment:gsub(" the favor of an admirer %((.+)%)", "");
					createCustomInventoryItem(wndSummary, aRPItems, true);
				end
			end
			if sEquipment:match("a trophy taken from a fallen enemy") then
				local sRPText = sEquipment:match("a trophy taken from a fallen enemy %((.+)%)");
				if sRPText and sRPText ~= "" then
					table.insert(aRPItems, { name = "Trophy from Fallen Enemy", record = "reference.equipmentdata.custom@DD PHB Deluxe", desc = sRPText });
					sEquipment = sEquipment:gsub(" a trophy taken from a fallen enemy %((.+)%)", "");
					createCustomInventoryItem(wndSummary, aRPItems, true);
				end
			end
		end
		if sEquipment and sEquipment ~= "" then
			for _,vItem in pairs(StringManager.split(sEquipment, ",")) do
				vItem = vItem:gsub("[ Aa]n ", "");
				vItem = vItem:gsub("[ Aa] ", "");

				local nGold = 0;

				if vItem then
					if vItem:match("pouch containing") or vItem:match("purse containing") then
						nGold = tonumber(vItem:match("(%d+)"));
						addItemToInventory(wndSummary, "Adventuring Gear", "pouch", 1, true);
						vItem = "";
					end
				end

				if vItem then
					vItem = StringManager.trim(vItem);
				end


				local sItemClothes = "";
				if vItem then
					if vItem:match("common clothes") or vItem:match("commoner's clothes") then
						sItemClothes = "clothes, common";
					elseif vItem:match("traveler's clothes") then
						sItemClothes = "clothes, traveler's";
					elseif vItem:match("fine clothes") then
						sItemClothes = "clothes, fine";
					elseif vItem:match("vestments") then
						sItemClothes = "clothes, vestments";
					elseif vItem:match("costume") then
						sItemClothes = "clothes, costume";
					end
				end
				if sItemClothes and sItemClothes ~= "" then
					addItemToInventory(wndSummary, "Adventuring Gear", sItemClothes, 1, true);
					vItem = nil;
				end

				if vItem then
					if vItem:match("belaying pin") then
						addItemToInventory(wndSummary, "Weapon", "club", 1, true);
						vItem = "";
					end

					if vItem:match("blanket") then
						addItemToInventory(wndSummary, "Adventuring Gear", "blanket", 1, true);
						vItem = "";
					end

					if vItem:match("block and tackle") then
						addItemToInventory(wndSummary, "Adventuring Gear", "block and tackle", 1, true);
						vItem = "";
					end

					if vItem:match("book") then
						addItemToInventory(wndSummary, "Adventuring Gear", "book", 1, true);
						vItem = "";
					end

					if vItem:match("bullseye lantern") then
						addItemToInventory(wndSummary, "Adventuring Gear", "lantern, bullseye", 1, true);
						vItem = "";
					end

					if vItem:match("carpenter's tools") then
						addItemToInventory(wndSummary, "Adventuring Gear", "carpenter's tools", 1, true);
						vItem = "";
					end

					if vItem:match("crowbar") then
						addItemToInventory(wndSummary, "Adventuring Gear", "crowbar", 1, true);
						vItem = "";
					end

					if vItem:match("dagger") then
						addItemToInventory(wndSummary, "Weapon", "dagger", 1, true);
						vItem = "";
					end

					if vItem:match("[Dd]isguise kit") then
						addItemToInventory(wndSummary, "Adventuring Gear", "disguise kit", 1, true);
						vItem = "";
					end

					if vItem:match("emblem") then
						addItemToInventory(wndSummary, "Adventuring Gear", "emblem", 1, true);
						vItem = "";
					end

					if vItem:match("[Ff]ishing tackle") then
						addItemToInventory(wndSummary, "Adventuring Gear", "fishing tackle", 1, true);
						vItem = "";
					end

					if vItem:match("forgery kit") then
						addItemToInventory(wndSummary, "Adventuring Gear", "forgery kit", 1, true);
						vItem = "";
					end

					if vItem:match("healer's kit") then
						addItemToInventory(wndSummary, "Adventuring Gear", "healer's kit", 1, true);
						vItem = "";
					end

					if vItem:match("herbalism kit") then
						addItemToInventory(wndSummary, "Adventuring Gear", "herbalism kit", 1, true);
						vItem = "";
					end

					if vItem:match("hammer") then
						addItemToInventory(wndSummary, "Adventuring Gear", "hammer", 1, true);
						vItem = "";
					end

					if vItem:match("horn") then
						addItemToInventory(wndSummary, "Adventuring Gear", "horn", 1, true);
						vItem = "";
					end

					if vItem:match("incense") then
						addItemToInventory(wndSummary, "Adventuring Gear", "incense", 5, true);
						vItem = "";
					end

					if vItem:match("ink") then
						addItemToInventory(wndSummary, "Adventuring Gear", "ink (1-ounce bottle)", 1, true);
						vItem = "";
					end

					if vItem:match("iron pot") then
						addItemToInventory(wndSummary, "Adventuring Gear", "pot, iron", 1, true);
						vItem = "";
					end

					if vItem:match("manacles") then
						addItemToInventory(wndSummary, "Adventuring Gear", "manacles", 1, true);
						vItem = "";
					end

					if vItem:match("miner's pick") then
						addItemToInventory(wndSummary, "Adventuring Gear", "pick, miner's", 1, true);
						vItem = "";
					end

					if vItem:match("parchment") then
						addItemToInventory(wndSummary, "Adventuring Gear", "parchment (one sheet)", 1, true);
						vItem = "";
					end

					if vItem:match("pen ") or vItem:match("quill") or vItem == "pen" then
						addItemToInventory(wndSummary, "Adventuring Gear", "ink pen", 1, true);
						vItem = "";
					end

					if vItem:match("poisoner's kit") then
						addItemToInventory(wndSummary, "Adventuring Gear", "poisoner's kit", 1, true);
						vItem = "";
					end

					if vItem:match("pouch") then
						addItemToInventory(wndSummary, "Adventuring Gear", "pouch", 1, true);
						vItem = "";
					end

					if vItem:match("robes") then
						addItemToInventory(wndSummary, "Adventuring Gear", "robes", 1, true);
						vItem = "";
					end

					if vItem:match("staff") then
						addItemToInventory(wndSummary, "Adventuring Gear", "staff", 1, true);
						vItem = "";
					end

					if vItem:match("shovel") then
						addItemToInventory(wndSummary, "Adventuring Gear", "shovel", 1, true);
						vItem = "";
					end

					if vItem:match("silk rope") then
						addItemToInventory(wndSummary, "Adventuring Gear", "rope, silk (50 Feet)", 1, true);
						vItem = "";
					end

					if vItem:match("tent") then
						addItemToInventory(wndSummary, "Adventuring Gear", "tent", 1, true);
						vItem = "";
					end

					if vItem:match("tinderbox") then
						addItemToInventory(wndSummary, "Adventuring Gear", "tinderbox", 1, true);
						vItem = "";
					end

					if vItem:match("torch") then
						addItemToInventory(wndSummary, "Adventuring Gear", "torch", 10, true);
						vItem = "";
					end
					if vItem:match("set of bone dice or deck of cards") then
						CharWizardManager.createBackgroundKitChoices(wndSummary, wList, CharWizardManager.getItemByType("gaming set"), "dice set or playing card set");
						vItem = "";
					end

					if vItem:match("artisan") then
						CharWizardManager.createBackgroundKitChoices(wndSummary, wList, CharWizardManager.getItemByType("artisan's tools"));
						vItem = "";
					end

					if vItem:match("gaming set") then
						CharWizardManager.createBackgroundKitChoices(wndSummary, wList, CharWizardManager.getItemByType("gaming set"));
						vItem = "";
					end

					if vItem:match("holy symbol") then
						CharWizardManager.createBackgroundKitChoices(wndSummary, wList, CharWizardManager.getItemByType("holy symbol"));
						vItem = "";
					end

					if vItem:match("musical instrument") then
						CharWizardManager.createBackgroundKitChoices(wndSummary, wList, CharWizardManager.getItemByType("musical instrument"));
						vItem = "";
					end
				end

				wndSummary.gold = nGold;

				vItem = "";
			end
		end
	end
end

function createBackgroundKitChoices(wndSummary, wList, aChoices, sLimit)
	local aFinalChoiceTool = {};

	if sLimit and sLimit ~= "" then
		for _,vChoice in pairs(aChoices) do
			if sLimit:match(vChoice.name) then
				aFinalChoiceTool[vChoice.name] = { tooltip = "", class = CharWizardManager.getShortcutClass(vChoice.link), record = vChoice.link };
			end
		end
	else
		for _,vChoice in pairs(aChoices) do
			aFinalChoiceTool[vChoice.name] = { tooltip = "", class = CharWizardManager.getShortcutClass(vChoice.link), record = vChoice.link };
		end
	end

	CharWizardManager.createSelectionWindows(wList, "BACKGROUND CHOICE", aFinalChoiceTool, 1, true)
end

function addEquipment(sTypeGroup, sSubType, w)
	local aItems = {};
	local aSortItem = {};

	if not sTypeGroup then
		sTypeGroup = "Adventuring Gear";
	end

	local sToolGroup = "Tools";
	local aMappings = LibraryData.getMappings("item");

	for _,vMapping in ipairs(aMappings) do
		for _,vItem in pairs(DB.getChildrenGlobal(vMapping)) do
			local sItem = "";
			local sItemType = DB.getValue(vItem, "type", "");
			local sItemSubType = DB.getValue(vItem, "subtype", "");
			local sItemProperties = DB.getValue(vItem, "properties", "");

			if sTypeGroup == "Adventuring Gear" then
				if sItemType == sTypeGroup or sItemType == sToolGroup then
					sItem = StringManager.trim(DB.getValue(vItem, "name", "")):lower();
				end
			else
				if sItemType == sTypeGroup then
					sItem = StringManager.trim(DB.getValue(vItem, "name", "")):lower();
				end
			end

			local sItemLink = vItem.getPath();

			if not StringManager.contains(aSortItem, sItem) then
				if not sItemProperties:match("magic") and sItemSubType:match(sSubType) then
					aItems[sItem] = vItem;
					table.insert(aSortItem, sItem);
				end
			end
		end
	end

	table.sort(aSortItem);

	for _,v in pairs(aSortItem) do
		local wndSubwindow = w.selection_window.createWindow();

		wndSubwindow.bname.setText(StringManager.titleCase(v));
		wndSubwindow.name.setValue(v);
		wndSubwindow.type.setValue(sTypeGroup);
		wndSubwindow.value.setValue(1);
		wndSubwindow.shortcut.setValue(CharWizardManager.getShortcutClass(aItems[v].getPath()), aItems[v].getPath());
		wndSubwindow.shortcut.setVisible(true);
	end
end

function getShortcutClass(sRecord)
	local sType = DB.getValue(DB.findNode(sRecord), "type", ""):lower();
	local sClass = "reference_equipment";

	if sType == "armor" then
		sClass = "reference_armor";
	elseif sType == "weapon" then
		sClass = "reference_weapon";
	end

	return sClass
end

function addItemToInventory(wndSummary, sTypeGroup, sItem, nCount, bBackground)
	--local wndSummary = UtilityManager.getTopWindow(window);
	local aItems = {};
	local aItemCheck = {};

	if not sTypeGroup then
		sTypeGroup = "Adventuring Gear";
	end

	if not nCount or nCount == 0 then
		nCount = 1;
	end

	local sToolGroup = "Tools";
	local aMappings = LibraryData.getMappings("item");
	for _,vMapping in ipairs(aMappings) do
		for _,vItem in pairs(DB.getChildrenGlobal(vMapping)) do
			local sItemLower = "";
			local sItemType = DB.getValue(vItem, "type", "");
			local sItemSubType = DB.getValue(vItem, "subtype", "");
			local sItemProperties = DB.getValue(vItem, "properties", "");

			if sTypeGroup == "Adventuring Gear" then
				if sItemType == sTypeGroup or sItemType == sToolGroup then
					sItemLower = StringManager.trim(DB.getValue(vItem, "name", "")):lower();
				end
			else
				if sItemType == sTypeGroup then
					sItemLower = StringManager.trim(DB.getValue(vItem, "name", "")):lower();
				end
			end

			local sCost = DB.getValue(vItem, "cost", "");
			local nWeight = DB.getValue(vItem, "weight", "");
			local nArmorClass = DB.getValue(vItem, "ac", "");
			local sDamage = DB.getValue(vItem, "damage", "");

			if sItemLower == sItem:lower() and vItem.getModule() == "DD PHB Deluxe" then
				if not string.match(sItemProperties, "magic") then
					if bBackground then
						table.insert(wndSummary.inventory, {record = vItem.getPath(), carried = 0, count = nCount, source = "background"})
					else
						table.insert(wndSummary.inventory, {record = vItem.getPath(), carried = 0, count = nCount, source = "class"})
					end
				end
			end
		end
	end
end

function createCustomInventoryItem(wndSummary, aCustomItems, bBackground)
	for _,vCustomItem in pairs(aCustomItems) do
		if bBackground then
			table.insert(wndSummary.inventory, { name = vCustomItem.name, record = vCustomItem.record, carried=0, count=1, description = vCustomItem.desc, source = "background" });
		else
			table.insert(wndSummary.inventory, { name = vCustomItem.name, record = vCustomItem.record, carried=0, count=1, description = vCustomItem.desc, source = "class" });
		end
	end
end

--
-- Spells
--

function createSpellList(wndSummary, wList, nLevel, sClass)
	local aKnownSpells = {};
	local aAvailableSpells = {};
	local aSortSpells = {};

	wList.closeAll();

	for k,v in pairs(wndSummary.spelllist) do
		if v.source ~= "Innate" then
			aKnownSpells[DB.getValue(DB.findNode(v.record), "name", ""):lower()] = v;
		end
	end

	local aMappings = LibraryData.getMappings("spell");
	for _,vMapping in ipairs(aMappings) do
		for _,vSpell in pairs(DB.getChildrenGlobal(vMapping)) do
			local sSpell = StringManager.trim(DB.getValue(vSpell, "name", "")):lower();
			sSpell = StringManager.trim(sSpell);

			local nSpellLevel = DB.getValue(vSpell, "level", 0);
			local aSpellSource = StringManager.split(DB.getValue(vSpell, "source", ""), ",");
			local sModule = vSpell.getModule();
			local sTooltip = "";

			if sModule == nil then
				sTooltip = StringManager.titleCase(sSpell) .. ": Campaign";
			else
				sTooltip = StringManager.titleCase(sSpell) .. ": " .. sModule;
			end

			for _,vSource in pairs(aSpellSource) do
				vSource = vSource:lower():gsub("%(optional%)", "")
				vSource = vSource:lower():gsub("%(new%)", "")
				vSource = StringManager.trim(vSource);

				if nSpellLevel == nLevel then
					if not aKnownSpells[sSpell:lower()] then
						if StringManager.trim(vSource:lower()) == sClass:lower() then
							if not aAvailableSpells[sSpell:lower()] then
								table.insert(aSortSpells, sSpell:lower())
							end
							aAvailableSpells[sSpell:lower()] = { tooltip = sTooltip, class = "reference_spell", record = vSpell.getPath() };
						end
					end
				end
			end

		end
	end

	table.sort(aSortSpells);
	for _,vSpellRecord in pairs(aSortSpells) do
		local w = wList.createWindow();

		w.name.setValue(StringManager.titleCase(vSpellRecord));
		w.source.setValue(StringManager.titleCase(sClass));

		if nLevel == 0 then
			w.level.setValue("Cantrip");
		else
			w.level.setValue(tonumber(nLevel));
		end

		w.link.setValue("reference_spell", aAvailableSpells[vSpellRecord].record);
	end
end

function setSpellClasses(wndSummary, wList)
	local sMainClass = "";
	local aSpellCasters = CharWizardManager.retrieveCasterClasses(wndSummary);
	local aCasters = CharWizardData.getCasterClasses();

	for k,v in pairs(aSpellCasters) do
		local wndClassList = wList.createWindow();
		local sClassLevel = v.classlevel.getValue();

		wndClassList.bname.setText(v.name.getValue());
		wndClassList.name.setValue(v.name.getValue():lower());
		wndClassList.shortcut.setValue(v.link.getValue());
		wndClassList.level.setValue(sClassLevel);
	end

	for k,v in pairs(aCasters) do
		if not aSpellCasters[k] then
			local wndClassList = wList.createWindow();
			wndClassList.bname.setText(StringManager.titleCase(k));
			wndClassList.name.setValue(k);
		end
	end

	local nCantrips, nSpells, nCasterLevel, aSlots, aPactSlots = CharWizardManager.getSpellsAvailable(wndSummary, aSpellCasters);
	local nCantripsSelected, nSpellsSelected = CharWizardManager.getSelectedSpellCount(wList.window.selectedspells);
	wList.window.cantrips_available.setValue(nCantripsSelected .. "/" .. nCantrips);
	wList.window.spells_available.setValue(nSpellsSelected .. "/" .. nSpells);

	for i = 1, 9 do
		if aSlots[i] ~= 0 and aSlots[i] ~= -1 and i <= nCasterLevel then
			wList.window["slots_available_" .. i].setValue(aSlots[i]);
			wList.window["slots_available_" .. i].setVisible(true);
			wList.window["label_slots_available_" .. i].setVisible(true);
			wList.window["button_spelllevel_" .. i].setVisible(true);
		else
			wList.window["slots_available_" .. i].setVisible(false);
			wList.window["slots_available_" .. i].setValue(0);
			wList.window["label_slots_available_" .. i].setVisible(false);
			wList.window["button_spelllevel_" .. i].setVisible(false);
		end
	end

	if #aPactSlots > 0 then
		for i = 1, 5 do
			if aPactSlots[i] then
				wList.window["pactslots_available_" .. i].setValue(aPactSlots[i]);
				wList.window["pactslots_available_" .. i].setVisible(true);
				wList.window["label_pactslots_available_" .. i].setVisible(true);
				wList.window["button_spelllevel_" .. i].setVisible(true);
			else
				wList.window["pactslots_available_" .. i].setVisible(false);
				wList.window["pactslots_available_" .. i].setValue(0);
				wList.window["label_pactslots_available_" .. i].setVisible(false);
			end
		end
	end

	wndSummary.spellslots = aSlots;
	wndSummary.pactslots = aPactSlots;
end

function retrieveCasterClasses(wndSummary)
	local aSpellCasters = {};
	local aCasters = CharWizardData.getCasterClasses(wndSummary);

	for _,v in pairs(wndSummary.summary.subwindow.summary_class.getWindows()) do
		local sClassName = v.name.getValue():lower()
		local nClassLevel = tonumber(v.classlevel.getValue());

		if aCasters[v.name.getValue():lower()] then
			if sClassName == "ranger" or sClassName == "paladin" then
				if nClassLevel > 1 then
					aSpellCasters[v.name.getValue():lower()] = v;
				end
			else
				aSpellCasters[v.name.getValue():lower()] = v;
			end
		end
	end
	for _,v in pairs(wndSummary.summary.subwindow.summary_specialization.getWindows()) do
		if aCasters[v.name.getValue():lower()] then
			aSpellCasters[v.name.getValue():lower()] = v;
		end
	end

	return aSpellCasters
end

function getSpellsAvailable(wndSummary, aSpellCasters)
	local aSlots = {};
	local aPactSlots = {};
	local nCantrips = 0;
	local nSpells = 0;
	local nCasterLevel = 0;
	local bWarlock = false;

	for k,vClass in pairs(aSpellCasters) do
		local nClassLevel = tonumber(vClass.classlevel.getValue());

		if k == "artificer" then
			local nAbilityBonus = CharWizardManager.getSpellBonus(wndSummary, "summary_intelligence");
			local nArtificerSpells = math.floor(nClassLevel / 2) + nAbilityBonus;

			if nArtificerSpells < 1 then
				nArtificerSpells = 1;
			end

			local nArtificerLevel = math.floor(nClassLevel / 2);
			if nArtificerLevel == 0 then
				nArtificerLevel = 1;
			end

			nCasterLevel = nCasterLevel + nArtificerLevel;
			nCantrips = nCantrips + CharWizardData.ARTIFICER_SPELLS[nClassLevel][1];
			nSpells = nSpells + nArtificerSpells;
		elseif k == "bard" then
			nCasterLevel = nCasterLevel + nClassLevel;
			nCantrips = nCantrips + CharWizardData.BARD_SPELLS[nClassLevel][1];
			nSpells = nSpells + CharWizardData.BARD_SPELLS[nClassLevel][2];
		elseif k == "cleric" then
			local nAbilityBonus = CharWizardManager.getSpellBonus(wndSummary, "summary_wisdom");
			local nClericSpells = nClassLevel + nAbilityBonus;

			if nClericSpells < 1 then
				nClericSpells = 1;
			end

			nCasterLevel = nCasterLevel + nClassLevel;
			nCantrips = nCantrips + CharWizardData.CLERIC_SPELLS[nClassLevel][1];
			nSpells = nSpells + nClericSpells;
		elseif k == "druid" then
			local nAbilityBonus = CharWizardManager.getSpellBonus(wndSummary, "summary_wisdom");
			local nDruidSpells = nClassLevel + nAbilityBonus;

			if nDruidSpells < 1 then
				nDruidSpells = 1;
			end

			nCasterLevel = nCasterLevel + nClassLevel;
			nCantrips = nCantrips + CharWizardData.DRUID_SPELLS[nClassLevel][1];
			nSpells = nSpells + nDruidSpells;
		elseif k == "paladin" then
			local nAbilityBonus = CharWizardManager.getSpellBonus(wndSummary, "summary_charisma");
			local nPaladinSpells = math.floor(nClassLevel / 2) + nAbilityBonus;

			if nPaladinSpells < 1 then
				nPaladinSpells = 1;
			end

			if nClassLevel < 2 then
				nPaladinSpells = 0;
			end

			nCasterLevel = nCasterLevel + math.floor(nClassLevel / 2);
			nSpells = nSpells + nPaladinSpells;
		elseif k == "ranger" then
			nCasterLevel = nCasterLevel + math.floor(nClassLevel / 2);
			nSpells = nSpells + CharWizardData.RANGER_SPELLS[nClassLevel][2];
		elseif k == "sorcerer" then
			nCasterLevel = nCasterLevel + nClassLevel;
			nCantrips = nCantrips + CharWizardData.SORCERER_SPELLS[nClassLevel][1];
			nSpells = nSpells + CharWizardData.SORCERER_SPELLS[nClassLevel][2];
		elseif k == "warlock" then
			nCantrips = nCantrips + CharWizardData.WARLOCK_SPELLS[nClassLevel][1];
			nSpells = nSpells + CharWizardData.WARLOCK_SPELLS[nClassLevel][2];

			for k,v in pairs(CharWizardData.WARLOCK_SPELLS) do
				if k <= nClassLevel then
					aPactSlots[CharWizardData.WARLOCK_SPELLS[k][4]] = CharWizardData.WARLOCK_SPELLS[k][3];
				end
			end
		elseif k == "wizard" then
			nCasterLevel = nCasterLevel + nClassLevel;
			nCantrips = nCantrips + CharWizardData.WIZARD_SPELLS[nClassLevel][1];
			nSpells = nSpells + ((nClassLevel - 1) * 2) + 6;
		elseif k == "eldritch knight" then
			nCasterLevel = nCasterLevel + math.ceil(nClassLevel / 3);
			nCantrips = nCantrips + CharWizardData.ELDRITCH_KNIGHT_SPELLS[nClassLevel][1];
			nSpells = nSpells + CharWizardData.ELDRITCH_KNIGHT_SPELLS[nClassLevel][2];
		elseif k == "arcane trickster" then
			nCasterLevel = nCasterLevel + math.ceil(nClassLevel / 3);
			nCantrips = nCantrips + CharWizardData.ARCANE_TRICKSTER_SPELLS[nClassLevel][1];
			nSpells = nSpells + CharWizardData.ARCANE_TRICKSTER_SPELLS[nClassLevel][2];
		end
	end

	aSlots = CharWizardData.SPELLSLOTS[tonumber(nCasterLevel)];

	if aSlots == nil then
		aSlots = {}
	end

	return nCantrips, nSpells, nCasterLevel, aSlots, aPactSlots, aArtificerSlots;
end

function getSelectedSpellCount(wList)
	local nCantrips = 0;
	local nSpells = 0;

	for _,vSpell in pairs (wList.getWindows()) do
		local sSpellLevel = vSpell.displaylevel.getValue();

		if vSpell.group.getValue():lower() ~= "innate" then
			if sSpellLevel == "Cantrip" then
				nCantrips = nCantrips + 1;
			else
				nSpells = nSpells + 1;
			end
		end
	end

	return nCantrips, nSpells;
end

function getSpellBonus(wndSummary, sBonus)
	local nAbilityScore = wndSummary.summary.subwindow[sBonus].getValue() or 0;
	local nAbilityBonus = math.floor((nAbilityScore - 10) / 2);

	return nAbilityBonus;
end

--
-- Feats
--

function parseFeat(wndSummary, wList, sSelectionGroup, sSelectionName, sSelectionRecord, wSelection)
	CharWizardManager.onSelectionChange(wSelection, "reference_feat", sSelectionRecord);

	local nodeSource = DB.findNode(sSelectionRecord);
	local sFeatText = DB.getValue(nodeSource, "text", "");
	local aFeatMods = {};
	local sFeatTitle = sSelectionGroup:match("(.-) FEAT")
	local aAbilityScores = {};

	for _,v in pairs(wSelection.windowlist.getWindows()) do
		if v.group_name.getValue() ~= wSelection.group_name.getValue() then
			if v.group_name.getValue():match(sFeatTitle:upper()) then
				v.close();
			end
		end
	end

	for s in sFeatText:gmatch("<li>(.-)</li>") do
		table.insert(aFeatMods, s);
	end

	for _,v in pairs(aFeatMods) do
		local sAbilityScores = "";

		if v:lower():match("increase your (.-) score by 1, to a maximum of 20") then
			sAbilityScores = v:lower():match("increase your (.-) score by 1, to a maximum of 20");
			sAbilityScores = sAbilityScores:gsub(" or ", " ")
			sAbilityScores = sAbilityScores:gsub(",", "")
			aAbilityScores = StringManager.split(sAbilityScores, " ")
		elseif v:lower():match("increase either your (.-) ability score by 1, to a maximum of 20") then
			sAbilityScores = v:lower():match("increase either your (.-) ability score by 1, to a maximum of 20");
			sAbilityScores = sAbilityScores:gsub(",", "")
			sAbilityScores = sAbilityScores:gsub(" or ", " ")
			aAbilityScores = StringManager.split(sAbilityScores, " ")
		end
	end

	if #aAbilityScores > 1 then
		local aSortAbilityScores = {};
		for _,v in pairs(aAbilityScores) do
			aSortAbilityScores[v] = v;
		end

		CharWizardManager.createSelectionWindows(wList, sFeatTitle:upper() .. " ABILITY SCORE INCREASE", aSortAbilityScores, 1);
		wSelection.ability.setValue("");
	elseif #aAbilityScores == 1 then
		wSelection.ability.setValue(aAbilityScores[1]);
	else
		wSelection.ability.setValue("");
	end

	CharWizardManager.getAlerts(wndSummary, wList)
	wndSummary.calcSummaryStats();
end

function parseFeatAbilitySelect(wndSummary, wList, sSelectionGroup, sSelectionName, sSelectionRecord, wSelection)
	CharWizardManager.onSelectionChange(wSelection);

	wSelection.ability.setValue(sSelectionName:lower());
	CharWizardManager.getAlerts(wndSummary, wList)
	wndSummary.calcSummaryStats();
end