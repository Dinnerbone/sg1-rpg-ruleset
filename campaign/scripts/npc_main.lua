-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	onSummaryChanged();
	update();
end

function onSummaryChanged()
	local sSize = size.getValue();
	
	local aText = {};
	if sSize ~= "" then
		table.insert(aText, sSize);
	end
	if sType ~= "" then
		table.insert(aText, sType);
	end
	local sText = table.concat(aText, " ");
	
	summary_label.setValue(sText);
end

function updateControl(sControl, bReadOnly, bForceHide)
	if not self[sControl] then
		return false;
	end
		
	return self[sControl].update(bReadOnly, bForceHide);
end

function update()
	local nodeRecord = getDatabaseNode();
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
	local bID = LibraryData.getIDState("npc", nodeRecord);

	local bSection1 = false;
	if Session.IsHost then
		if updateControl("nonid_name", bReadOnly) then bSection1 = true; end;
	else
		updateControl("nonid_name", bReadOnly, true);
	end
	divider.setVisible(bSection1);

	updateControl("size", bReadOnly, bReadOnly);
	updateControl("type", bReadOnly, bReadOnly);
	summary_label.setVisible(bReadOnly);
	
	ac.setReadOnly(bReadOnly);
	actext.setReadOnly(bReadOnly);
	hp.setReadOnly(bReadOnly);
	hd.setReadOnly(bReadOnly);
	speed.setReadOnly(bReadOnly);
	
	updateControl("strength", bReadOnly);
	updateControl("constitution", bReadOnly);
	updateControl("dexterity", bReadOnly);
	updateControl("intelligence", bReadOnly);
	updateControl("wisdom", bReadOnly);
	updateControl("charisma", bReadOnly);

	updateControl("savingthrows", bReadOnly);
	updateControl("skills", bReadOnly);
	updateControl("damagevulnerabilities", bReadOnly);
	updateControl("damageresistances", bReadOnly);
	updateControl("damageimmunities", bReadOnly);
	updateControl("conditionimmunities", bReadOnly);
	updateControl("senses", bReadOnly);
	updateControl("languages", bReadOnly);
	updateControl("challengerating", bReadOnly);
	
	cr.setReadOnly(bReadOnly);
	xp.setReadOnly(bReadOnly);
	
	if bReadOnly then
		if traits_iedit then
			traits_iedit.setValue(0);
			traits_iedit.setVisible(false);
			traits_iadd.setVisible(false);
		end
		
		local bShow = (traits.getWindowCount() ~= 0);
		header_traits.setVisible(bShow);
		traits.setVisible(bShow);
	else
		if traits_iedit then
			traits_iedit.setVisible(true);
			traits_iadd.setVisible(true);
		end
		header_traits.setVisible(true);
		traits.setVisible(true);
	end
	for _,w in ipairs(traits.getWindows()) do
		w.name.setReadOnly(bReadOnly);
		w.desc.setReadOnly(bReadOnly);
	end

	if bReadOnly then
		if actions_iedit then
			actions_iedit.setValue(0);
			actions_iedit.setVisible(false);
			actions_iadd.setVisible(false);
		end
		
		local bShow = (actions.getWindowCount() ~= 0);
		header_actions.setVisible(bShow);
		actions.setVisible(bShow);
	else
		if actions_iedit then
			actions_iedit.setVisible(true);
			actions_iadd.setVisible(true);
		end
		header_actions.setVisible(true);
		actions.setVisible(true);
	end
	for _,w in ipairs(actions.getWindows()) do
		w.name.setReadOnly(bReadOnly);
		w.desc.setReadOnly(bReadOnly);
	end
	
	if bReadOnly then
		if bonusactions_iedit then
			bonusactions_iedit.setValue(0);
			bonusactions_iedit.setVisible(false);
			bonusactions_iadd.setVisible(false);
		end
		
		local bShow = (bonusactions.getWindowCount() ~= 0);
		header_bonusactions.setVisible(bShow);
		bonusactions.setVisible(bShow);
	else
		if bonusactions_iedit then
			bonusactions_iedit.setVisible(true);
			bonusactions_iadd.setVisible(true);
		end
		header_bonusactions.setVisible(true);
		bonusactions.setVisible(true);
	end
	for _,w in ipairs(bonusactions.getWindows()) do
		w.name.setReadOnly(bReadOnly);
		w.desc.setReadOnly(bReadOnly);
	end
	
	if bReadOnly then
		if reactions_iedit then
			reactions_iedit.setValue(0);
			reactions_iedit.setVisible(false);
			reactions_iadd.setVisible(false);
		end
		
		local bShow = (reactions.getWindowCount() ~= 0);
		header_reactions.setVisible(bShow);
		reactions.setVisible(bShow);
	else
		if reactions_iedit then
			reactions_iedit.setVisible(true);
			reactions_iadd.setVisible(true);
		end
		header_reactions.setVisible(true);
		reactions.setVisible(true);
	end
	for _,w in ipairs(reactions.getWindows()) do
		w.name.setReadOnly(bReadOnly);
		w.desc.setReadOnly(bReadOnly);
	end
	
	if bReadOnly then
		if legendaryactions_iedit then
			legendaryactions_iedit.setValue(0);
			legendaryactions_iedit.setVisible(false);
			legendaryactions_iadd.setVisible(false);
		end
		
		local bShow = (legendaryactions.getWindowCount() ~= 0);
		header_legendaryactions.setVisible(bShow);
		legendaryactions.setVisible(bShow);
	else
		if legendaryactions_iedit then
			legendaryactions_iedit.setVisible(true);
			legendaryactions_iadd.setVisible(true);
		end
		header_legendaryactions.setVisible(true);
		legendaryactions.setVisible(true);
	end
	for _,w in ipairs(legendaryactions.getWindows()) do
		w.name.setReadOnly(bReadOnly);
		w.desc.setReadOnly(bReadOnly);
	end
	
	if bReadOnly then
		if lairactions_iedit then
			lairactions_iedit.setValue(0);
			lairactions_iedit.setVisible(false);
			lairactions_iadd.setVisible(false);
		end
		
		local bShow = (lairactions.getWindowCount() ~= 0);
		header_lairactions.setVisible(bShow);
		lairactions.setVisible(bShow);
	else
		if lairactions_iedit then
			lairactions_iedit.setVisible(true);
			lairactions_iadd.setVisible(true);
		end
		header_lairactions.setVisible(true);
		lairactions.setVisible(true);
	end
	for _,w in ipairs(lairactions.getWindows()) do
		w.name.setReadOnly(bReadOnly);
		w.desc.setReadOnly(bReadOnly);
	end
	
	if bReadOnly then
		if innatespells_iedit then
			innatespells_iedit.setValue(0);
			innatespells_iedit.setVisible(false);
			innatespells_iadd.setVisible(false);
		end
		
		local bShow = (innatespells.getWindowCount() ~= 0);
		header_innatespells.setVisible(bShow);
		innatespells.setVisible(bShow);
	else
		if innatespells_iedit then
			innatespells_iedit.setVisible(true);
			innatespells_iadd.setVisible(true);
		end
		header_innatespells.setVisible(true);
		innatespells.setVisible(true);
	end
	for _,w in ipairs(innatespells.getWindows()) do
		w.name.setReadOnly(bReadOnly);
		w.desc.setReadOnly(bReadOnly);
	end
	
	if bReadOnly then
		if spells_iedit then
			spells_iedit.setValue(0);
			spells_iedit.setVisible(false);
			spells_iadd.setVisible(false);
		end
		
		local bShow = (spells.getWindowCount() ~= 0);
		header_spells.setVisible(bShow);
		spells.setVisible(bShow);
	else
		if spells_iedit then
			spells_iedit.setVisible(true);
			spells_iadd.setVisible(true);
		end
		header_spells.setVisible(true);
		spells.setVisible(true);
	end
	for _,w in ipairs(spells.getWindows()) do
		w.name.setReadOnly(bReadOnly);
		w.desc.setReadOnly(bReadOnly);
	end
end

function addTrait(sName, sDesc)
	local w = traits.createWindow();
	if w then
		w.name.setValue(sName);
		w.desc.setValue(sDesc);
	end
end

function addAction(sName, sDesc)
	local w = actions.createWindow();
	if w then
		w.name.setValue(sName);
		w.desc.setValue(sDesc);
	end
end

function addSpellDrop(nodeSource, bInnate)
	CampaignDataManager2.addNPCSpell(getDatabaseNode(), nodeSource, bInnate);
end

function onDrop(x, y, draginfo)
	if WindowManager.getReadOnlyState(getDatabaseNode()) then
		return true;
	end
	if draginfo.isType("shortcut") then
		local sClass = draginfo.getShortcutData();
		local nodeSource = draginfo.getDatabaseNode();
		
		if sClass == "reference_spell" or sClass == "power" then
			addSpellDrop(nodeSource);
		elseif sClass == "reference_originfeature" then
			addAction(DB.getValue(nodeSource, "name", ""), DB.getText(nodeSource, "text", ""));
		elseif sClass == "reference_classfeature" then
			addAction(DB.getValue(nodeSource, "name", ""), DB.getText(nodeSource, "text", ""));
		elseif sClass == "reference_feat" then
			addAction(DB.getValue(nodeSource, "name", ""), DB.getText(nodeSource, "text", ""));
		elseif sClass == "reference_racialtrait" or sClass == "reference_subracialtrait" then
			addTrait(DB.getValue(nodeSource, "name", ""), DB.getText(nodeSource, "text", ""));
		end
		return true;
	end
end
