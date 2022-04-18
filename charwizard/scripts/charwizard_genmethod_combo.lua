-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--
function onInit()
	super.onInit();

	local wndSummary = UtilityManager.getTopWindow(window);
	local nStr = wndSummary.summary.subwindow.summary_strength.getValue();
	local nDex = wndSummary.summary.subwindow.summary_dexterity.getValue();
	local nCon = wndSummary.summary.subwindow.summary_constitution.getValue();
	local nInt = wndSummary.summary.subwindow.summary_intelligence.getValue();
	local nWis = wndSummary.summary.subwindow.summary_wisdom.getValue();
	local nCha = wndSummary.summary.subwindow.summary_charisma.getValue();

	addItems(CharWizardData.genmethod);

	if wndSummary.import == 0 then
		onValueChanged();
	else
		setValue("MANUAL ENTRY");
		window.strength.setValue(nStr);
		window.dexterity.setValue(nDex);
		window.constitution.setValue(nCon);
		window.intelligence.setValue(nInt);
		window.wisdom.setValue(nWis);
		window.charisma.setValue(nCha);
	end
end

function onValueChanged()
	local w = UtilityManager.getTopWindow(window);

	w.ability_alert.setVisible(false);

	local aAlertList = w.alerts.getWindows();

	for i=1,w.alerts.getWindowCount() do
		if aAlertList then
			if aAlertList[i].alert_label.getValue() == "ABILITIES: POINTS UNSPENT" then
				aAlertList[i].close();
			end
		end
	end

	local genval = {};

	genval["StatArray"] = {15, 14, 13, 12, 10, 8};

	if getValue() == "STANDARD ARRAY" then
		for k,v in ipairs(DataCommon.abilities) do
			window[v].setValue(genval.StatArray[k]);
			window[v].setReadOnly(true);
			window[v .. "_up"].setVisible(false);
			window[v .. "_down"].setVisible(false);
			window["label_cost_" .. v].setVisible(false);
			window["cost_" .. v].setVisible(false);
			window[v .. "_moveup"].setVisible(true);
			window[v .. "_movedown"].setVisible(true);
		end

		window.point_total.setVisible(false);
		window.point_total_label.setVisible(false);
		window.reroll.setVisible(false);
		window.rerolllabel.setVisible(false);
		window.genmethod_dice_label.setVisible(false);
		window.genmethod_dice.setVisible(false);
		window.genmethod_drop_label.setVisible(false);
		window.genmethod_drop.setVisible(false);
		window.charisma_movedown.setVisible(false);
		window.strength_moveup.setVisible(false);
		w.summary.subwindow.summary_genmethod.setValue("(STANDARD ARRAY)");		
	elseif getValue() == "DICE ROLL" then
		for k,v in pairs(DataCommon.abilities) do
			local rRoll = { sType = "charwizardabilityroll", sDesc = "", nMod = 0 };	

			rRoll.aDice = {"d6", "d6", "d6", "d6"};
			ActionsManager.performAction(nil,nil,rRoll);
			window[v].setValue(0);
			window[v].setReadOnly(true);
			window[v .. "_up"].setVisible(false);
			window[v .. "_down"].setVisible(false);
			window["label_cost_" .. v].setVisible(false);
			window["cost_" .. v].setVisible(false);
			window[v .. "_moveup"].setVisible(true);
			window[v .. "_movedown"].setVisible(true);
		end

		window.point_total.setVisible(false);
		window.point_total_label.setVisible(false);		
		window.reroll.setVisible(true);
		window.rerolllabel.setVisible(true);
		window.genmethod_dice_label.setVisible(false);
		window.genmethod_dice.setVisible(false);
		window.genmethod_drop_label.setVisible(false);
		window.genmethod_drop.setVisible(false);
		window.charisma_movedown.setVisible(false);
		window.strength_moveup.setVisible(false);
		w.summary.subwindow.summary_genmethod.setValue("(DICE ROLL)");		
	elseif getValue() == "POINT BUY" then
		for k,v in pairs(DataCommon.abilities) do
			window[v].setValue(8);
			window[v].setReadOnly(true);
			window["cost_" .. v].setValue(0);
			window[v .. "_up"].setVisible(true);
			window["label_cost_" .. v].setVisible(true);
			window["cost_" .. v].setVisible(true);
			window[v .. "_moveup"].setVisible(false);
			window[v .. "_movedown"].setVisible(false);
		end

		window.point_total.setValue(27);
		window.point_total.setVisible(true);
		window.point_total_label.setVisible(true);		
		window.reroll.setVisible(false);
		window.rerolllabel.setVisible(false);
		window.genmethod_dice_label.setVisible(false);
		window.genmethod_dice.setVisible(false);
		window.genmethod_drop_label.setVisible(false);
		window.genmethod_drop.setVisible(false);
		window.charisma_movedown.setVisible(false);
		window.strength_moveup.setVisible(false);
		w.ability_alert.setVisible(true);

		local wndAlertList = w.alerts.createWindow();

		wndAlertList.alert_label.setValue("ABILITIES: POINTS UNSPENT");
		wndAlertList.alert_order.setValue(2);
		w.alerts.applySort();		
		w.summary.subwindow.summary_genmethod.setValue("(POINT BUY)");
	elseif getValue() == "MANUAL ENTRY" then
		for k,v in pairs(DataCommon.abilities) do
			window[v].setValue(10);
			window[v].setReadOnly(false);
			window[v .. "_up"].setVisible(false);
			window[v .. "_down"].setVisible(false);
			window["label_cost_" .. v].setVisible(false);
			window["cost_" .. v].setVisible(false);
			window[v .. "_moveup"].setVisible(false);
			window[v .. "_movedown"].setVisible(false);
		end

		window.point_total.setVisible(false);
		window.point_total_label.setVisible(false);
		window.reroll.setVisible(false);
		window.rerolllabel.setVisible(false);
		window.genmethod_dice_label.setVisible(false);
		window.genmethod_dice.setVisible(false);
		window.genmethod_drop_label.setVisible(false);
		window.genmethod_drop.setVisible(false);
		w.summary.subwindow.summary_genmethod.setValue("(MANUAL ENTRY)");		
	end

	w.ability_GateCheck.setValue(1);
	w.calcSummaryStats();
end