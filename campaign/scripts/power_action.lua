-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	registerMenuItem(Interface.getString("power_menu_actiondelete"), "deletepointer", 4);
	registerMenuItem(Interface.getString("list_menu_deleteconfirm"), "delete", 4, 3);
	
	updateDisplay();
	
	local node = getDatabaseNode();
	windowlist.setOrder(node);

	local sNode = getDatabaseNode().getPath();
	DB.addHandler(sNode, "onChildUpdate", onDataChanged);
	onDataChanged();
end

function onClose()
	local sNode = getDatabaseNode().getPath();
	DB.removeHandler(sNode, "onChildUpdate", onDataChanged);
end

function onMenuSelection(selection, subselection)
	if selection == 4 and subselection == 3 then
		getDatabaseNode().delete();
	end
end

function highlight(bState)
	if bState then
		setFrame("rowshade");
	else
		setFrame(nil);
	end
end

function updateDisplay()
	local node = getDatabaseNode();
	
	local sType = DB.getValue(node, "type", "");
	
	local bShowCast = (sType == "cast");
	local bShowDamage = (sType == "damage");
	local bShowHeal = (sType == "heal");
	local bShowEffect = (sType == "effect");
	
	castbutton.setVisible(bShowCast);
	castlabel.setVisible(bShowCast);
	castbutton.setVisible(bShowCast);
	attackbutton.setVisible(bShowCast);
	attackviewlabel.setVisible(bShowCast);
	attackview.setVisible(bShowCast);
	savebutton.setVisible(bShowCast);
	saveviewlabel.setVisible(bShowCast);
	saveview.setVisible(bShowCast);
	castdetail.setVisible(bShowCast);
	
	damagebutton.setVisible(bShowDamage);
	damagelabel.setVisible(bShowDamage);
	damageview.setVisible(bShowDamage);
	damagedetail.setVisible(bShowDamage);

	healbutton.setVisible(bShowHeal);
	heallabel.setVisible(bShowHeal);
	healview.setVisible(bShowHeal);
	healdetail.setVisible(bShowHeal);

	effectbutton.setVisible(bShowEffect);
	effectlabel.setVisible(bShowEffect);
	effectview.setVisible(bShowEffect);
	durationview.setVisible(bShowEffect);
	effectdetail.setVisible(bShowEffect);
end

function updateViews()
	onDataChanged();
end

function onDataChanged()
	local sType = DB.getValue(getDatabaseNode(), "type", "");
	
	if sType == "cast" then
		onCastChanged();
	elseif sType == "damage" then
		onDamageChanged();
	elseif sType == "heal" then
		onHealChanged();
	elseif sType == "effect" then
		onEffectChanged();
	end
end

function onCastChanged()
	local sAttack, sSave = PowerManager.getPCPowerCastActionText(getDatabaseNode());
	attackview.setValue(sAttack);
	saveview.setValue(sSave);
end

function onDamageChanged()
	local sDamage = PowerManager.getPCPowerDamageActionText(getDatabaseNode());
	damageview.setValue(sDamage);
end

function onHealChanged()
	local sHeal = PowerManager.getPCPowerHealActionText(getDatabaseNode());
	healview.setValue(sHeal);
end

function onEffectChanged()
	local nodeAction = getDatabaseNode();
	
	local sLabel = DB.getValue(nodeAction, "label", "");
	
	local sApply = DB.getValue(nodeAction, "apply", "");
	if sApply == "action" then
		sLabel = sLabel .. "; [ACTION]";
	elseif sApply == "roll" then
		sLabel = sLabel .. "; [ROLL]";
	elseif sApply == "single" then
		sLabel = sLabel .. "; [SINGLES]";
	end
	
	local sTargeting = DB.getValue(nodeAction, "targeting", "");
	if sTargeting == "self" then
		sLabel = sLabel .. "; [SELF]";
	end

	local sDuration = "" .. DB.getValue(nodeAction, "durmod", 0);
	
	local sUnits = DB.getValue(nodeAction, "durunit", "");
	if sDuration ~= "" then
		if sUnits == "minute" then
			sDuration = sDuration .. " min";
		elseif sUnits == "hour" then
			sDuration = sDuration .. " hr";
		elseif sUnits == "day" then
			sDuration = sDuration .. " dy";
		else
			sDuration = sDuration .. " rd";
		end
	end
	
	effectview.setValue(sLabel);
	durationview.setValue(sDuration);
end