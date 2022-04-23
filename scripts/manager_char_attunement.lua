-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- Artificer Class
-- 	Magic Item Adept +1
-- 	Magic Item Savant +1
--	Magic Item Master +1

function onInit()
	OptionsManager.registerCallback("HRAS", onOptionChanged);
	DB.addHandler("charsheet.profbonus", "onUpdate", onCharProfBonusUpdate);
	DB.addHandler("charsheet.*.attunement.class", "onUpdate", onCharAttuneBonusUpdate);
	DB.addHandler("charsheet.*.attunement.misc", "onUpdate", onCharAttuneBonusUpdate);
	DB.addHandler("charsheet.*.inventorylist.*.attune", "onUpdate", onCharItemAttuneUpdate);
	DB.addHandler("charsheet.*.inventorylist.*", "onDelete", onCharItemDelete);
end

-- 
--  ATTUNEMENT DATA TRIGGERS
--

-- On attunement slot change; update character sheet display
function onOptionChanged()
	for _,nodeChar in pairs(DB.getChildren("charsheet")) do
		CharAttunementManager.onAttuneCalcChange(nodeChar);
	end
end

-- On proficiency bonus update; update character sheet display, if proficiency bonus used
function onCharProfBonusUpdate(nodeProfBonus)
	if OptionsManager.isOption("HRAS", "prof") then
		local nodeChar = nodeProfBonus.getChild("..");
		CharAttunementManager.onAttuneCalcChange(nodeChar);
	end
end

-- On attunement slot change; update character sheet display
function onCharAttuneBonusUpdate(nodeAttuneBonus)
	local nodeChar = nodeAttuneBonus.getChild("...");
	CharAttunementManager.onAttuneCalcChange(nodeChar);
end

-- On item attunement value change; update character sheet display
function onCharItemAttuneUpdate(nodeAttuneUse)
	local nodeChar = nodeAttuneUse.getChild("....");
	CharAttunementManager.onAttuneCalcChange(nodeChar);
end

-- On item deletion; update character sheet display
function onCharItemDelete(nodeItem)
	DB.setValue(nodeItem, "attune", "number", 0);
end

--
--  ATTUNEMENT SLOT CALCULATIONS
--

function getBaseSlots(nodeChar)
	local sOption = OptionsManager.getOption("HRAS");
	if sOption == "prof" then
		return DB.getValue(nodeChar, "profbonus", 2);
	end
	return tonumber(sOption) or 3;
end

function getTotalSlots(nodeChar)
	return CharAttunementManager.getBaseSlots(nodeChar) + DB.getValue(nodeChar, "attunement.class", 0) + DB.getValue(nodeChar, "attunement.misc", 0);
end

function getUsedSlots(nodeChar)
	local nUsed = 0;
	for _,node in pairs(DB.getChildren(nodeChar, "inventorylist")) do
		if CharAttunementManager.doesItemAllowAttunement(node) then
			if DB.getValue(node, "attune", 0) ~= 0 then
				nUsed = nUsed + 1;
			end
		end
	end
	return nUsed;
end

--
--	ATTUNEMENT HELPER FUNCTIONS
--

function doesItemAllowAttunement(nodeItem)
	local sRarityLower = DB.getValue(nodeItem, "rarity", ""):lower();
	if not sRarityLower:match("requires?%s+attunement") then
		return false;
	end
	local nIsIdentified = DB.getValue(nodeItem, "isidentified", 1);
	if nIsIdentified ~= 1 then
		return false;
	end
	return true;
end

function onAttuneCalcChange(nodeChar)
	local w = Interface.findWindow("charsheet", nodeChar);
	if w then
		w.updateAttunement();
	end
end
