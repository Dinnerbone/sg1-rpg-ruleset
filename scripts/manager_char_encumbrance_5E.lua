-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	Interface.onDesktopInit = onDesktopInit;
end
function onDesktopInit()
	DB.addHandler("charsheet.*.size", "onUpdate", CharEncumbranceManager5E.onSizeChange);
	DB.addHandler("charsheet.*.abilities.strength.score", "onUpdate", CharEncumbranceManager5E.onStrengthChange);
	DB.addHandler("charsheet.*.featurelist.*.name", "onUpdate", CharEncumbranceManager5E.onAbilityFieldChange);
	DB.addHandler("charsheet.*.featurelist", "onChildDeleted", CharEncumbranceManager5E.onAbilityDelete);
	DB.addHandler("charsheet.*.traitlist.*.name", "onUpdate", CharEncumbranceManager5E.onAbilityFieldChange);
	DB.addHandler("charsheet.*.traitlist", "onChildDeleted", CharEncumbranceManager5E.onAbilityDelete);
end

function onSizeChange(nodeField)
	local nodeChar = DB.getChild(nodeField, "..");
	CharEncumbranceManager5E.updateEncumbranceLimit(nodeChar);
end
function onStrengthChange(nodeField)
	local nodeChar = DB.getChild(nodeField, "....");
	CharEncumbranceManager5E.updateEncumbranceLimit(nodeChar);
end
function onAbilityFieldChange(nodeField)
	local nodeChar = DB.getChild(nodeField, "....");
	CharEncumbranceManager5E.updateEncumbranceLimit(nodeChar);
end
function onAbilityDelete(nodeList)
	local nodeChar = DB.getChild(nodeList, "..");
	CharEncumbranceManager5E.updateEncumbranceLimit(nodeChar);
end

function updateEncumbranceLimit(nodeChar)
	local nStat = DB.getValue(nodeChar, "abilities.strength.score", 10);
	local nEncLimit = math.max(nStat, 0) * 5;

	nEncLimit = nEncLimit * CharEncumbranceManager5E.getEncumbranceMult(nodeChar);
	
	DB.setValue(nodeChar, "encumbrance.encumbered", "number", nEncLimit);
	DB.setValue(nodeChar, "encumbrance.encumberedheavy", "number", nEncLimit * 2);
	DB.setValue(nodeChar, "encumbrance.max", "number", nEncLimit * 3);
	DB.setValue(nodeChar, "encumbrance.liftpushdrag", "number", nEncLimit * 6);
end
function getEncumbranceMult(nodeChar)
	local sSize = StringManager.trim(DB.getValue(nodeChar, "size", ""):lower());
	
	local nSize = 2; -- Medium
	if sSize == "tiny" then
		nSize = 0;
	elseif sSize == "small" then
		nSize = 1;
	elseif sSize == "large" then
		nSize = 3;
	elseif sSize == "huge" then
		nSize = 4;
	elseif sSize == "gargantuan" then
		nSize = 5;
	end
	
	if CharManager.hasTrait(nodeChar, CharManager.TRAIT_POWERFUL_BUILD) then
		nSize = nSize + 1;
	end
	
	local nMult = 1; -- Both Small and Medium use a multiplier of 1
	if nSize == 0 then
		nMult = 0.5;
	elseif nSize == 3 then
		nMult = 2;
	elseif nSize == 4 then
		nMult = 4;
	elseif nSize == 5 then
		nMult = 8;
	elseif nSize == 6 then
		nMult = 16;
	end

	if CharManager.hasFeature(nodeChar, CharManager.FEATURE_ASPECT_OF_THE_BEAR) then
		nMult = nMult * 2;
	end
	
	return nMult;
end

