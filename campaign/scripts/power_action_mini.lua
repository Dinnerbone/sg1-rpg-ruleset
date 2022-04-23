-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	local sNode = getDatabaseNode().getPath();
	DB.addHandler(sNode, "onChildUpdate", onDataChanged);
	onDataChanged();
end

function onClose()
	local sNode = getDatabaseNode().getPath();
	DB.removeHandler(sNode, "onChildUpdate", onDataChanged);
end

function onDataChanged()
	updateDisplay();
	updateViews();
end

function updateDisplay()
	local sType = DB.getValue(getDatabaseNode(), "type", "");
	
	if sType == "cast" then
		button.setIcons("button_roll", "button_roll_down");
	elseif sType == "damage" then
		button.setIcons("button_action_damage", "button_action_damage_down");
	elseif sType == "heal" then
		button.setIcons("button_action_heal", "button_action_heal_down");
	elseif sType == "effect" then
		button.setIcons("button_action_effect", "button_action_effect_down");
	end
end

function updateViews()
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
	local sTooltip = "CAST: ";
	if sAttack ~= "" then
		sTooltip = sTooltip .. "\rATK: " .. sAttack;
	end
	if sSave ~= "" then
		sTooltip = sTooltip .. "\rSAVE: " .. sSave;
	end
	button.setTooltipText(sTooltip);
end

function onDamageChanged()
	local sDamage = PowerManager.getPCPowerDamageActionText(getDatabaseNode());
	button.setTooltipText("DMG: " .. sDamage);
end

function onHealChanged()
	local sHeal = PowerManager.getPCPowerHealActionText(getDatabaseNode());
	button.setTooltipText("HEAL: " .. sHeal);
end

function onEffectChanged()
	local node = getDatabaseNode();
	if not node then
		return;
	end
	
	local sTooltip = DB.getValue(node, "label", "");

	local sApply = DB.getValue(node, "apply", "");
	if sApply == "action" then
		sTooltip = sTooltip .. "; [ACTION]";
	elseif sApply == "roll" then
		sTooltip = sTooltip .. "; [ROLL]";
	elseif sApply == "single" then
		sTooltip = sTooltip .. "; [SINGLES]";
	end
	
	local sTargeting = DB.getValue(node, "targeting", "");
	if sTargeting == "self" then
		sTooltip = sTooltip .. "; [SELF]";
	end
	
	sTooltip = "EFFECT: " .. sTooltip;
	
	button.setTooltipText(sTooltip);
end
