-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	local node = window.getDatabaseNode();
	
	local sType = DB.getValue(node, "type", "");
	local sSubType = DB.getValue(node, "subtype", "");
	local sTechLevel = DB.getValue(node, "techlevel", "");
	local nTemplate = DB.getValue(node, "istemplate", 0);
	Debug.console(node);
	Debug.console(sTechLevel);

	local aValues = {};

	if nTemplate ~= 0 then
		table.insert(aValues, Interface.getString("ref_type_template"));
	end
	if sSubType ~= "" then
		if sType ~= "" then
			sType = sType .. " ";
		end
		sType = sType .. "(" .. sSubType .. ")";
	end
	table.insert(aValues, sType);
	if sTechLevel ~= "" then
		table.insert(aValues, sTechLevel);
	end

	setValue(table.concat(aValues, ", "));
	
	super.onInit();
end
