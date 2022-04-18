-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
end

function onItemDeleted(nCount, sClass, sRecord)
end

function setInventory()
end

function updateInventory(wItem)
	local wndSummary = UtilityManager.getTopWindow(window);
	local aInventory = {};
	local sWindowClass = "";
	local sWindowRecord = "";

	for _,vListItem in pairs(getWindows()) do
		if wItem == nil or wItem ~= vListItem then
			local sWindowClass, sWindowRecord = vListItem.shortcut.getValue();

			table.insert(aInventory, {record = sWindowRecord, count = vListItem.count.getValue(), carried = vListItem.carried.getValue(), import = vListItem.import.getValue()});
		end
	end

	wndSummary.inventory = aInventory;

	updateCost();	
end

function onDrop(x, y, draginfo)
	if draginfo.isType("shortcut") then
		local sClass, sRecord = draginfo.getShortcutData();
		local nodeSource = draginfo.getDatabaseNode();
		local aInventory = {};
		local nCount = 1;
		local bFound = false;
		local bArmorEquipped = false;
		local bShieldEquipped = false;

		if LibraryData.isRecordDisplayClass("item", sClass) then
			for _,wndItem in pairs(getWindows()) do
				local sItemClass, sItemRecord = wndItem.shortcut.getValue();
				local sCRRecordUnique = StringManager.split(sItemRecord, "@")[1];
				local sDragRecordUnique = StringManager.split(sRecord, "@")[1];

				if sCRRecordUnique == sDragRecordUnique then
					bFound = true;
					wndItem.count.setValue(wndItem.count.getValue() + 1);
				end
			end
			if not bFound then
				local nCarried = 1;

				if DB.getValue(nodeSource, "type", "") == "Weapon" then 
					nCarried = 2;
				end

				if DB.getValue(nodeSource, "type", "") == "Armor" and not bArmorEquipped then
					nCarried = 2;					
				end

				if DB.getValue(nodeSource, "type", "") == "Shield" and not bShieldEquipped then
					nCarried = 2;					
				end

				local wndInventory = createWindow();

				wndInventory.shortcut.setValue(sClass, sRecord);
				wndInventory.carried.setValue(nCarried);
				wndInventory.name.setValue(DB.getValue(nodeSource, "name", ""));
				wndInventory.count.setValue(1);
				--wndInventory.import.setValue(0);
			end
		end

		updateInventory();
	end
end

function updateCost()
	local wndSummary = UtilityManager.getTopWindow(window);

	window.total_cost_pp.setValue(0);
	window.total_cost_gp.setValue(0);
	window.total_cost_sp.setValue(0);
	window.total_cost_cp.setValue(0);

	local nTotal = 0;
	for _,vItem in pairs(wndSummary.inventory) do
		local nCount = vItem.count;

		local nodeTarget = DB.findNode(vItem.record);
		if nodeTarget then
			local sCost = DB.getValue(nodeTarget, "cost", "");
			local nItemTotal = 0;
			if string.match(sCost, "-") then
				sCost = "0";
			end
			sCost = sCost:gsub(",", "");
			local nCostAmount = tonumber(sCost:match("(%d+)"));
			local nNewCost = 0;

			if string.match(sCost, "pp") then
				nCostAmount = nCostAmount * 1000
			elseif string.match(sCost, "gp") then
				nCostAmount = nCostAmount * 100
			elseif string.match(sCost, "sp") then
				nCostAmount = nCostAmount * 10
			end

			nItemTotal = nCostAmount * nCount;
			nTotal = nTotal + nItemTotal;
		end

		if nTotal > 999 then
			local nPlatinumCoins = math.floor(nTotal / 1000);
			window.total_cost_pp.setValue(nPlatinumCoins);
			nTotal = nTotal - (nPlatinumCoins * 1000);
		end
		if nTotal > 99 then
			local nGoldCoins = math.floor(nTotal / 100);
			window.total_cost_gp.setValue(nGoldCoins);
			nTotal = nTotal - (nGoldCoins * 100);
		end
		if nTotal > 9 then
			local nSilverCoins = math.floor(nTotal / 10);
			window.total_cost_sp.setValue(nSilverCoins);
			nTotal = nTotal - (nSilverCoins * 10);
		end
		if nTotal > 0 then
			window.total_cost_cp.setValue(nTotal);
		end

	end
end

function updateContainers()
	for _,w in ipairs(getWindows()) do
		if not w.hidden_locationpath then
			w.createControl("hsc", "hidden_locationpath");
		end
		local aSortPath, bContained = getInventorySortPath(self, w);
		w.hidden_locationpath.setValue(table.concat(aSortPath, "\a"));
		if w.name then
			if bContained then
				w.name.setAnchor("left", nil, "left", "absolute", 35 + (10 * (#aSortPath - 1)));
			else
				w.name.setAnchor("left", nil, "left", "absolute", 35);
			end
		end
		if w.nonid_name then
			if bContained then
				w.nonid_name.setAnchor("left", nil, "left", "absolute", 35 + (10 * (#aSortPath - 1)));
			else
				w.nonid_name.setAnchor("left", nil, "left", "absolute", 35);
			end
		end
	end
	
	applySort();
end

function getInventorySortPath(cList, w)
	if not w.name or not w.location then
		return {}, false;
	end
	
	local sName = ItemManager.getSortName(w.getDatabaseNode());
	local sLocation = StringManager.trim(w.location.getValue()):lower();
	if (sLocation == "") or (sName == sLocation) then
		return { sName }, false;
	end
	
	for _,wList in ipairs(cList.getWindows()) do
		local sListName = getSortName(wList.getDatabaseNode());
		if sListName == sLocation then
			local aSortPath = getInventorySortPath(cList, wList);
			table.insert(aSortPath, sName);
			return aSortPath, true;
		end
	end
	return { sLocation, sName }, false;
end

function addInvItemToList(vList, sClass, vSource, bTransferAll, nTransferCount)
	-- Get the source item database node object
	local nodeSource = nil;
	if type(vSource) == "databasenode" then
		nodeSource = vSource;
	elseif type(vSource) == "string" then
		nodeSource = DB.findNode(vSource);
	end
	local nodeList = nil;
	if type(vList) == "databasenode" then
		nodeList = vList;
	elseif type(vList) == "string" then
		nodeList = DB.createNode(vList);
	end
	if not nodeSource or not nodeList then
		return nil;
	end
	
	-- Determine the source and target item location type
	local sSourceRecordType = ItemManager.getItemSourceType(nodeSource);
	local sTargetRecordType = ItemManager.getItemSourceType(nodeList);
	
	-- Make sure that the source and target locations are not the same character
	if sSourceRecordType == "charsheet" and sTargetRecordType == "charsheet" then
		if nodeSource.getParent().getPath() == nodeList.getPath() then
			return nil;
		end
	end
	
	-- Use a temporary location to create an item copy for manipulation, if the item type is supported
	local sTempPath;
	if nodeList.getParent() then
		sTempPath = nodeList.getParent().getPath("temp.item");
	else
		sTempPath = "temp.item";
	end
	DB.deleteNode(sTempPath);
	local nodeTemp = DB.createNode(sTempPath);
	local bCopy = false;
	if sClass == "item" then
		DB.copyNode(nodeSource, nodeTemp);
		bCopy = true;
	elseif ItemManager2 and ItemManager2.addItemToList2 then
		bCopy = ItemManager2.addItemToList2(sClass, nodeSource, nodeTemp, nodeList);
	end
	
	local nodeNew = nil;
	if bCopy then
		-- Determine target node for source item data.  
		-- If we already have an item with the same fields, then just append the item count.  
		-- Otherwise, create a new item and copy from the source item.
		local bAppend = false;
		if sTargetRecordType ~= "item" then
			for _,vItem in pairs(DB.getChildren(nodeList, "")) do
				if ItemManager.compareFields(vItem, nodeTemp, true) then
					nodeNew = vItem;
					bAppend = true;
					break;
				end
			end
		end
		if not nodeNew then
			nodeNew = DB.createChild(nodeList);
			DB.copyNode(nodeTemp, nodeNew);
		end
		
		-- Determine the source, target and item names
		local sSrcName, sTrgtName;
		if sSourceRecordType == "charsheet" then
			sSrcName = DB.getValue(nodeSource, "...name", "");
		elseif sSourceRecordType == "partysheet" then
			sSrcName = "PARTY";
		else
			sSrcName = "";
		end
		if sTargetRecordType == "charsheet" then
			sTrgtName = DB.getValue(nodeNew, "...name", "");
		elseif sTargetRecordType == "partysheet" then
			sTrgtName = "PARTY";
		else
			sTrgtName = "";
		end
		local sItemName = ItemManager.getDisplayName(nodeNew, true);

		-- Determine whether to copy all items at once or just one item at a time (based on source and target)

		local nCount = 1;
		if nTransferCount then
			nCount = nTransferCount;
		end
		if bAppend then
			local nAppendCount = math.max(DB.getValue(nodeNew, "count", 1), 1);
			DB.setValue(nodeNew, "count", "number", nCount + nAppendCount);
		else
			DB.setValue(nodeNew, "count", "number", nCount);
		end

		-- If not adding to an existing record, then lock the new record and generate events
		if not bAppend then
			DB.setValue(nodeNew, "locked", "number", 1);
			if sTargetRecordType == "charsheet" then
				ItemManager.onCharAddEvent(nodeNew);
			end
		end

		-- Generate output message if transferring between characters or between party sheet and character
		if sSourceRecordType == "charsheet" and (sTargetRecordType == "partysheet" or sTargetRecordType == "charsheet") then
			local msg = {font = "msgfont", icon = "coins"};
			msg.text = "[" .. sSrcName .. "] -> [" .. sTrgtName .. "] : " .. sItemName;
			if nCount > 1 then
				msg.text = msg.text .. " (" .. nCount .. "x)";
			end
			Comm.deliverChatMessage(msg);

			local nCharCount = DB.getValue(nodeSource, "count", 0);
			if nCharCount <= nCount then
				ItemManager.onCharRemoveEvent(nodeSource);
				nodeSource.delete();
			else
				DB.setValue(nodeSource, "count", "number", nCharCount - nCount);
			end
		elseif sSourceRecordType == "partysheet" and sTargetRecordType == "charsheet" then
			local msg = {font = "msgfont", icon = "coins"};
			msg.text = "[" .. sSrcName .. "] -> [" .. sTrgtName .. "] : " .. sItemName;
			if nCount > 1 then
				msg.text = msg.text .. " (" .. nCount .. "x)";
			end
			Comm.deliverChatMessage(msg);

			local nPartyCount = DB.getValue(nodeSource, "count", 0);
			if nPartyCount <= nCount then
				nodeSource.delete();
			else
				DB.setValue(nodeSource, "count", "number", nPartyCount - nCount);
			end
		end
	end
	
	-- Clean up
	DB.deleteNode(sTempPath);

	return nodeNew;
end
