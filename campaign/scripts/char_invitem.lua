-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	if super and super.onInit then
		super.onInit();
	end

	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "isidentified"), "onUpdate", onAttuneRelatedAttributeUpdate);
	DB.addHandler(DB.getPath(node, "rarity"), "onUpdate", onAttuneRelatedAttributeUpdate);
	onAttuneRelatedAttributeUpdate();
end

function onClose()
	if super and super.onClose then
		super.onClose();
	end

	local node = getDatabaseNode();
	DB.removeHandler(DB.getPath(node, "isidentified"), "onUpdate", onAttuneRelatedAttributeUpdate);
	DB.removeHandler(DB.getPath(node, "rarity"), "onUpdate", onAttuneRelatedAttributeUpdate);
end

function onAttuneRelatedAttributeUpdate(nodeAttribute)
	local bRequiresAttune = CharAttunementManager.doesItemAllowAttunement(getDatabaseNode());
	attune.setVisible(bRequiresAttune);
	attune_na.setVisible(not bRequiresAttune);
end
