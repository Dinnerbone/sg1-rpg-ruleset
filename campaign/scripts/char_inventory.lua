-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	OptionsManager.registerCallback("HREN", onHRENOptionChanged);
	onHRENOptionChanged();

	updateAttunement();
end

function onClose()
	OptionsManager.unregisterCallback("HREN", onHRENOptionChanged);
end

function onHRENOptionChanged()
	local sOptionHREN = OptionsManager.getOption("HREN");
	local bShowVariant = (sOptionHREN == "variant");
	encumbrancebase_label.setVisible(bShowVariant);
	encumbrancebase.setVisible(bShowVariant);
	encumbranceheavy_label.setVisible(bShowVariant);
	encumbranceheavy.setVisible(bShowVariant);
end

function onDrop(x, y, draginfo)
	return ItemManager.handleAnyDrop(getDatabaseNode(), draginfo);
end

function updateAttunement()
	local nodeChar = getDatabaseNode();
	local nUsed = CharAttunementManager.getUsedSlots(nodeChar);
	local nAllowed = CharAttunementManager.getTotalSlots(nodeChar);
	local sUsage = string.format("%d / %d", nUsed, nAllowed);
	
	attunecalc.setValue(sUsage);
	if nUsed > nAllowed then
		attunecalc.setColor(attunecalc.warning[1])
	else
		attunecalc.setColor(nil);
	end
end
