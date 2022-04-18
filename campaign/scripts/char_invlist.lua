-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local sortLocked = false;

function setSortLock(isLocked)
	sortLocked = isLocked;
end

function onInit()
	registerMenuItem(Interface.getString("list_menu_createitem"), "insert", 5);

	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "*.isidentified"), "onUpdate", onIDChanged);
	DB.addHandler(DB.getPath(node, "*.bonus"), "onUpdate", onBonusChanged);
	DB.addHandler(DB.getPath(node, "*.ac"), "onUpdate", onArmorChanged);
	DB.addHandler(DB.getPath(node, "*.dexbonus"), "onUpdate", onArmorChanged);
	DB.addHandler(DB.getPath(node, "*.stealth"), "onUpdate", onArmorChanged);
	DB.addHandler(DB.getPath(node, "*.strength"), "onUpdate", onArmorChanged);
	DB.addHandler(DB.getPath(node, "*.carried"), "onUpdate", onCarriedChanged);
end

function onClose()
	local node = getDatabaseNode();
	DB.removeHandler(DB.getPath(node, "*.isidentified"), "onUpdate", onIDChanged);
	DB.removeHandler(DB.getPath(node, "*.bonus"), "onUpdate", onBonusChanged);
	DB.removeHandler(DB.getPath(node, "*.ac"), "onUpdate", onArmorChanged);
	DB.removeHandler(DB.getPath(node, "*.dexbonus"), "onUpdate", onArmorChanged);
	DB.removeHandler(DB.getPath(node, "*.stealth"), "onUpdate", onArmorChanged);
	DB.removeHandler(DB.getPath(node, "*.strength"), "onUpdate", onArmorChanged);
	DB.removeHandler(DB.getPath(node, "*.carried"), "onUpdate", onCarriedChanged);
end

function onMenuSelection(selection)
	if selection == 5 then
		addEntry(true);
	end
end

function onIDChanged(nodeField)
	local nodeItem = DB.getChild(nodeField, "..");
	if (DB.getValue(nodeItem, "carried", 0) == 2) and ItemManager2.isArmor(nodeItem) then
		CharArmorManager.calcItemArmorClass(DB.getChild(nodeItem, "..."));
	end
end

function onBonusChanged(nodeField)
	local nodeItem = DB.getChild(nodeField, "..");
	if (DB.getValue(nodeItem, "carried", 0) == 2) and ItemManager2.isArmor(nodeItem) then
		CharArmorManager.calcItemArmorClass(DB.getChild(nodeItem, "..."));
	end
end

function onArmorChanged(nodeField)
	local nodeItem = DB.getChild(nodeField, "..");
	if (DB.getValue(nodeItem, "carried", 0) == 2) and ItemManager2.isArmor(nodeItem) then
		CharArmorManager.calcItemArmorClass(DB.getChild(nodeItem, "..."));
	end
end

function onCarriedChanged(nodeField)
	local nodeChar = DB.getChild(nodeField, "....");
	if nodeChar then
		local nodeItem = DB.getChild(nodeField, "..");

		local nCarried = nodeField.getValue();
		local sCarriedItem = StringManager.trim(ItemManager.getDisplayName(nodeItem)):lower();
		if sCarriedItem ~= "" then
			for _,vNode in pairs(DB.getChildren(nodeChar, "inventorylist")) do
				if vNode ~= nodeItem then
					local sLoc = StringManager.trim(DB.getValue(vNode, "location", "")):lower();
					if sLoc == sCarriedItem then
						DB.setValue(vNode, "carried", "number", nCarried);
					end
				end
			end
		end
		
		if ItemManager2.isArmor(nodeItem) then
			CharArmorManager.calcItemArmorClass(nodeChar);
		end
	end
end

function onListChanged()
	update();
	updateContainers();
end

function update()
	local bEditMode = (window.parentcontrol.window.inventory_iedit.getValue() == 1);
	for _,w in ipairs(getWindows()) do
		w.idelete.setVisibility(bEditMode);
	end
end

function addEntry(bFocus)
	local w = createWindow();
	if w then
		if bFocus then
			w.name.setFocus();
		end
		w.count.setValue(1);
	end
	return w;
end

function onClickDown(button, x, y)
	return true;
end

function onClickRelease(button, x, y)
	if not getNextWindow(nil) then
		addEntry(true);
	end
	return true;
end

function onSortCompare(w1, w2)
	if sortLocked then
		return false;
	end
	return ItemManager.onInventorySortCompare(w1, w2);
end

function updateContainers()
	ItemManager.onInventorySortUpdate(self);
end

function onDrop(x, y, draginfo)
	return ItemManager.handleAnyDrop(window.getDatabaseNode(), draginfo);
end
