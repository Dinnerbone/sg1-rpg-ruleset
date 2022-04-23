-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function action(draginfo)
	local aParty = {};
	for _,v in pairs(window.list.getWindows()) do
		local rActor = ActorManager.resolveActor(v.link.getTargetDatabaseNode());
		if rActor then
			table.insert(aParty, rActor);
		end
	end
	if #aParty == 0 then
		aParty = nil;
	end
	
	local sSave = DB.getValue("partysheet.saveselected", ""):lower();
	
	ModifierManager.lock();
	for _,v in pairs(aParty) do
		ActionSave.performPartySheetRoll(nil, v, sSave);
	end
	ModifierManager.unlock(true);

	return true;
end

function onButtonPress()
	return action();
end
