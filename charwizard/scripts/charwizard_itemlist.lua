-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	addItems();
end

function addItems(sTypeGroup, sFilter)
	local aItems = {};
	local aItemCheck = {};	

	closeAll();

	if not sTypeGroup then
		sTypeGroup = "Adventuring Gear";
	end

	local sToolGroup = "Tools";

	if not sFilter or sFilter == "" then
		sFilter = "%a";
	end

	local aMappings = LibraryData.getMappings("item");
	for _,vMapping in ipairs(aMappings) do
		for _,vItem in pairs(DB.getChildrenGlobal(vMapping)) do	
			local sItemLower = "";
			local sItemType = DB.getValue(vItem, "type", "");
			local sItemSubType = DB.getValue(vItem, "subtype", "");
			local sItemProperties = DB.getValue(vItem, "properties", "");			
			if sTypeGroup == "Adventuring Gear" then
				if sItemType == sTypeGroup or sItemType == sToolGroup then
					sItemLower = StringManager.trim(DB.getValue(vItem, "name", "")):lower();
				end
			else
				if sItemType == sTypeGroup then
					sItemLower = StringManager.trim(DB.getValue(vItem, "name", "")):lower();
				end
			end
			local sCost = DB.getValue(vItem, "cost", "");
			local nWeight = DB.getValue(vItem, "weight", "");
			local nArmorClass = DB.getValue(vItem, "ac", "");
			local sDamage = DB.getValue(vItem, "damage", "");
			local sItemLink = vItem.getPath();
			
			if not StringManager.contains(aItemCheck, sItemLower) and sItemLower:match(sFilter:lower()) then
				if not string.match(sItemProperties, "magic") then
					table.insert(aItemCheck, sItemLower);

					local w = createWindow();

					w.name.setValue(StringManager.titleCase(sItemLower));
					w.cost.setValue(sCost);
					w.weight.setValue(nWeight);
					w.type.setValue(sItemType);
					w.subtype.setValue(sItemSubType);
					w.ac.setValue(nArmorClass);
					w.damage.setValue(sDamage);					
					w.link.setValue("reference_equipment", sItemLink);
					
					if sTypeGroup == "Armor" then
						w.subtype.setVisible(true);
						w.subtype.setValue(string.gsub(sItemSubType, " Armor", ""));
						w.ac.setVisible(true);
						
						w.damage.setVisible(false);
					elseif sTypeGroup == "Weapon" then
						w.damage.setVisible(true);
						w.subtype.setValue(string.gsub(sItemSubType, " Weapons", ""));
						w.subtype.setVisible(true);
						
						w.ac.setVisible(false);
					else
						w.subtype.setVisible(false);					
						w.ac.setVisible(false);
						w.damage.setVisible(false);						
					end
				end
			end
		end
	end
	applySort();
end
