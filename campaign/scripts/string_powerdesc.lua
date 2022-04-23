-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local bParsed = false;
local aAbilities = {};

local bDragging = nil;
local hoverAbility = nil;
local clickAbility = nil;

function getPowerNode()	
	local nodePower = window.getDatabaseNode();
	if not nodePower then
		nodePower = window.windowlist.window.getDatabaseNode();
	end
	return nodePower;
end

function getActor()
	local nodePower = getPowerNode();
	local nodeCreature = nodePower.getChild("...");
	return ActorManager.resolveActor(nodeCreature);
end

function onValueChanged()
	bParsed = false;
end

function parseComponents()
	aAbilities = PowerManager.parseNPCPower(window.getDatabaseNode());
	bParsed = true;
end

-- Reset selection when the cursor leaves the control
function onHover(bOnControl)
	if bDragging or bOnControl then
		return;
	end

	hoverAbility = nil;
	setSelectionPosition(0);
end

-- Hilight attack or damage hovered on
function onHoverUpdate(x, y)
	if bDragging then
		return;
	end

	if not bParsed then
		parseComponents();
	end
	local nMouseIndex = getIndexAt(x, y);
	hoverAbility = nil;

	for i = 1, #aAbilities do
		if aAbilities[i].startpos <= nMouseIndex and aAbilities[i].endpos > nMouseIndex then
			setCursorPosition(aAbilities[i].startpos);
			setSelectionPosition(aAbilities[i].endpos);

			hoverAbility = i;			
		end
	end
	
	if hoverAbility then
		setHoverCursor("hand");
	else
		setHoverCursor("arrow");
	end
end

function action(draginfo, rAction)
	local rActionCopy = UtilityManager.copyDeep(rAction);
	return PowerManager.performAction(draginfo, getActor(), rActionCopy, window.getDatabaseNode());
end

-- Suppress default processing to support dragging
function onClickDown(button, x, y)
	clickAbility = hoverAbility;
	return true;
end

-- On mouse click, set focus, set cursor position and clear selection
function onClickRelease(button, x, y)
	setFocus();
	
	local n = getIndexAt(x, y);
	setSelectionPosition(n);
	setCursorPosition(n);
	
	return true;
end

function onDoubleClick(x, y)
	if hoverAbility then
		action(nil, aAbilities[hoverAbility]);
		return true;
	end
end

function onDragStart(button, x, y, draginfo)
	return onDrag(button, x, y, draginfo);
end

function onDrag(button, x, y, draginfo)
	if bDragging then
		return true;
	end

	if clickAbility then
		action(draginfo, aAbilities[clickAbility]);
		clickAbility = nil;
		bDragging = true;
		return true;
	end
	
	return true;
end

function onDragEnd(dragdata)
	setCursorPosition(0);
	bDragging = false;
end
