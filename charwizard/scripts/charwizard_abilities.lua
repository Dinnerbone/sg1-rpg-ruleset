-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

POINT_BUY_TOTAL = 27;

function onInit()
	ActionsManager.registerResultHandler("charwizardabilityroll", onRoll);

	local wndSummary = UtilityManager.getTopWindow(parentcontrol.window);

	if wndSummary.import == 0 then
		setupRacialBonuses(wndSummary);
	else
		statslabel.setVisible(false)
		genmethodframe.setVisible(false)
		cb_genmethod.setVisible(false)
		cb_genmethod_cbbutton.setVisible(false)
		strength.setVisible(false)
		dexterity.setVisible(false)
		constitution.setVisible(false)
		intelligence.setVisible(false)
		wisdom.setVisible(false)
		charisma.setVisible(false)
		summarytitle.setVisible(false)
		summaryframe.setVisible(false)
		race_statstitle.setVisible(false)
		race_strength.setVisible(false)
		race_dexterity.setVisible(false)
		race_constitution.setVisible(false)
		race_intelligence.setVisible(false)
		race_wisdom.setVisible(false)
		race_charisma.setVisible(false)
	end
end

function setupRacialBonuses(wndSummary)
	--local wndSummary = UtilityManager.getTopWindow(window);

	self["race_strength"].setValue(wndSummary.summary.subwindow.summary_race_strength.getValue());
	self["race_dexterity"].setValue(wndSummary.summary.subwindow.summary_race_dexterity.getValue());
	self["race_constitution"].setValue(wndSummary.summary.subwindow.summary_race_constitution.getValue());
	self["race_intelligence"].setValue(wndSummary.summary.subwindow.summary_race_intelligence.getValue());
	self["race_wisdom"].setValue(wndSummary.summary.subwindow.summary_race_wisdom.getValue());
	self["race_charisma"].setValue(wndSummary.summary.subwindow.summary_race_charisma.getValue());

	wndSummary.calcSummaryStats();
end

function onRoll(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	local resultMin = 0;
	local resultMinIndex = 0;
	local resultTotal = 0;
	for k,v in ipairs(rMessage.dice) do
		if (resultMin == 0) or (v.result < resultMin) then
			resultMinIndex = k;
			resultMin = v.result;
		end
		resultTotal = resultTotal + v.result;
	end
	if resultMinIndex > 0 then
		rMessage.dice.expr = "4d6d1";
		rMessage.dice[resultMinIndex].dropped = true;
		rMessage.dice[resultMinIndex].iconcolor = "7FFFFFFF";
		resultTotal = resultTotal - resultMin;
	end

	Comm.deliverChatMessage(rMessage);

	for k,v in ipairs(DataCommon.abilities) do
		if self[v].getValue() == 0 then
			self[v].setValue(resultTotal);
			break;
		end
	end
end

function onCharGenPageChange()
	local sMethod = genmethod_select.getValue();
	local aAbilityScores = {};
	for k,v in ipairs(DataCommon.abilities) do
		local nScore = window[v].getValue() or 0;
		table.insert(aAbilityScores, nScore);
	end
	CharWizardManager.setAbilityScores(sMethod, aAbilityScores);
end

function recalcAbilityPointsSpent()
	local nPointTotal = 0;
	for k,v in ipairs(DataCommon.abilities) do
		local currStatControl = v;
		local currCostControl = "cost_" .. v;
		local nCurrStat = self[currStatControl].getValue();

		if nCurrStat >= 15 then
			nPointTotal = nPointTotal + 9;
			self[currCostControl].setValue(9);
		elseif nCurrStat == 14 then
			nPointTotal = nPointTotal + 7;
			self[currCostControl].setValue(7);
		elseif nCurrStat == 13 then
			nPointTotal = nPointTotal + 5;
			self[currCostControl].setValue(5);
		elseif nCurrStat == 12 then
			nPointTotal = nPointTotal + 4;
			self[currCostControl].setValue(4);
		elseif nCurrStat == 11 then
			nPointTotal = nPointTotal + 3;
			self[currCostControl].setValue(3);
		elseif nCurrStat == 10 then
			nPointTotal = nPointTotal + 2;
			self[currCostControl].setValue(2);
		elseif nCurrStat == 9 then
			nPointTotal = nPointTotal + 1;
			self[currCostControl].setValue(1);
		elseif nCurrStat == 8 then
			self[currCostControl].setValue(0);
		end
	end

	point_total.setValue(POINT_BUY_TOTAL - nPointTotal);

	local w = Interface.findWindow("charwizard", "");
	local aAlertList = w.alerts.getWindows();
	local bPointAlert = false;

	for k,v in ipairs(DataCommon.abilities) do
		self[v .. "_up"].setVisible(point_total.getValue() > 0 and self[v].getValue() < 15);
		self[v .. "_down"].setVisible(self[v].getValue() > 8);
	end
end

function handleMoveAbility(sName, nMove)
	local sGiveName = "";
	if nMove == 1 then
		sGiveName = sName:gsub("_movedown", "")
	else
		sGiveName = sName:gsub("_moveup", "")
	end

	if sGiveName == nil then
		return
	end

	local nGiveIndex = 1;
	local nGiveValue = self[sGiveName].getValue();

	for k,v in ipairs(DataCommon.abilities) do
		if sGiveName == v then
			nGiveIndex = k;

			break
		end
	end

	local sTakeName = "";
	local nTakeIndex = nGiveIndex + nMove;
	if nTakeIndex > 6 then
		nTakeIndex = 1;
	elseif nTakeIndex < 1 then
		nTakeIndex = 6;
	end

	for k,v in ipairs(DataCommon.abilities) do
		if nTakeIndex == k then
			sTakeName = v;

			break
		end
	end

	local nTakeValue = self[sTakeName].getValue();
	self[sGiveName].setValue(nTakeValue);
	self[sTakeName].setValue(nGiveValue);

	return;
end

function handleReroll()
	for k,v in pairs(DataCommon.ability_ltos) do
		self[k].setValue(0);
		
		local rRoll = { sType = "charwizardabilityroll", sDesc = "", aDice = aDice, nMod = 0 };	
		rRoll.aDice = {"d6", "d6", "d6", "d6"};
		ActionsManager.performAction(nil,nil,rRoll);
	end
end

function handleAbilityPointBuy(sName, nMod)
	local sAbility = "";
	local bUp = false;

	if nMod > 0 then
		sAbility = sName:gsub("_up", "");
		bUp = true;
	else
		sAbility = sName:gsub("_down", "");
	end

	local nCurrStatValue = self[sAbility].getValue();
	nCurrStatValue = nCurrStatValue + nMod;

	self[sAbility].setValue(nCurrStatValue);
	
	recalcAbilityPointsSpent();
end
