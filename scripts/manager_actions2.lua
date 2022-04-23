-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function encodeDesktopMods(rRoll)
	local nMod = 0;
	
	if ModifierManager.getKey("PLUS2") then
		nMod = nMod + 2;
	end
	if ModifierManager.getKey("MINUS2") then
		nMod = nMod - 2;
	end
	if ModifierManager.getKey("PLUS5") then
		nMod = nMod + 5;
	end
	if ModifierManager.getKey("MINUS5") then
		nMod = nMod - 5;
	end
	
	if nMod == 0 then
		return;
	end
	
	rRoll.nMod = rRoll.nMod + nMod;
	rRoll.sDesc = rRoll.sDesc .. string.format(" [%+d]", nMod);
end

function encodeAdvantage(rRoll, bADV, bDIS)
	local bButtonADV = ModifierManager.getKey("ADV");
	local bButtonDIS = ModifierManager.getKey("DIS");
	if bButtonADV then
		bADV = true;
	end
	if bButtonDIS then
		bDIS = true;
	end
	
	if bADV then
		rRoll.sDesc = rRoll.sDesc .. " [ADV]";
	end
	if bDIS then
		rRoll.sDesc = rRoll.sDesc .. " [DIS]";
	end
	if (bADV and not bDIS) or (bDIS and not bADV) then
		table.insert(rRoll.aDice, 2, "d20");
		rRoll.aDice.expr = nil;
	end
end

function decodeAdvantage(rRoll)
	local bADV = string.match(rRoll.sDesc, "%[ADV%]");
	local bDIS = string.match(rRoll.sDesc, "%[DIS%]");
	if (bADV and not bDIS) or (bDIS and not bADV) then
		if #(rRoll.aDice) > 1 then
			local nDecodeDie;
			if (bADV and not bDIS) then
				nDecodeDie = math.max(rRoll.aDice[1].result, rRoll.aDice[2].result);
				nDroppedDie = math.min(rRoll.aDice[1].result, rRoll.aDice[2].result);
				rRoll.aDice[1].type = "g" .. string.sub(rRoll.aDice[1].type, 2);
			else
				nDecodeDie = math.min(rRoll.aDice[1].result, rRoll.aDice[2].result);
				nDroppedDie = math.max(rRoll.aDice[1].result, rRoll.aDice[2].result);
				rRoll.aDice[1].type = "r" .. string.sub(rRoll.aDice[1].type, 2);
			end
			rRoll.aDice[1].result = nDecodeDie;
			rRoll.aDice[1].value = nil;
			table.remove(rRoll.aDice, 2);
			rRoll.aDice.expr = nil;
			rRoll.sDesc = rRoll.sDesc .. " [DROPPED " .. nDroppedDie .. "]";
		end
	end	
end
