-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	if Session.IsHost then
		registerMenuItem(Interface.getString("menu_rest"), "lockvisibilityon", 7);
		registerMenuItem(Interface.getString("menu_restshort"), "pointer_cone", 7, 8);
		registerMenuItem(Interface.getString("menu_restlong"), "pointer_circle", 7, 6);
	end

	OptionsManager.registerCallback("HRIS", onHRISOptionChanged);
	onHRISOptionChanged();

	local nodeChar = getDatabaseNode();
	CharEncumbranceManager5E.updateEncumbranceLimit(nodeChar);
end

function onClose()
	OptionsManager.unregisterCallback("HRIS", onHRISOptionChanged);
end

function onHRISOptionChanged()
	local sOptHRIS = OptionsManager.getOption("HRIS");
	local nOptHRIS = math.min(math.max(tonumber(sOptHRIS) or 1, 1), 3);
	
	if inspiration.getMaxValue() ~= nOptHRIS then
		inspiration.setMaxValue(nOptHRIS);
		inspiration.updateSlots();
	end
	inspiration.setAnchor("left", "inspirationtitle", "center", "absolute", -5 * nOptHRIS);
end

function onMenuSelection(selection, subselection)
	if selection == 7 then
		if subselection == 8 then
			local nodeChar = getDatabaseNode();
			ChatManager.Message(Interface.getString("message_restshort"), true, ActorManager.resolveActor(nodeChar));
			CharManager.rest(nodeChar, false);
		elseif subselection == 6 then
			local nodeChar = getDatabaseNode();
			ChatManager.Message(Interface.getString("message_restlong"), true, ActorManager.resolveActor(nodeChar));
			CharManager.rest(nodeChar, true);
		end
	end
end

function updateAttunement()
	if inventory.subwindow then
		if inventory.subwindow.contents.subwindow then
			inventory.subwindow.contents.subwindow.updateAttunement();
		end
	end
end
