-- This file is provided under the Open Game License version 1.0a
-- For more information on OGL and related issues, see 
--   http://www.wizards.com/d20
--
-- For information on the Fantasy Grounds d20 Ruleset licensing and
-- the OGL license text, see the d20 ruleset license in the program
-- options.
--
-- All producers of work derived from this definition are adviced to
-- familiarize themselves with the above licenses, and to take special
-- care in providing the definition of Product Identity (as specified
-- by the OGL) in their products.
--
-- Copyright 2007 SmiteWorks Ltd.


function updateEncumbrance()
	local encumbrancetotal = 0;

	for k, w in pairs(getWindows()) do
		if w.carried.getState() then
			local count = w.count.getValue();
			if count == 0 then
				count = 1;
			end
			
			encumbrancetotal = encumbrancetotal + count * w.weight.getValue();
		end
	end

	if window.encumbranceload then						
		window.encumbranceload.setValue(encumbrancetotal);
	end
end

function onSortCompare(w1, w2)
	local name1 = string.lower(w1.name.getValue());
	local name2 = string.lower(w2.name.getValue());
	local loc1 = string.lower(w1.location.getValue());
	local loc2 = string.lower(w2.location.getValue());

	-- Empty entries at the end of the list
	if name1 == "" then
		return true;
	elseif name2 == "" then
		return false;
	end
	
	-- Name comparison if both locations the same
	if loc1 == loc2 then
		return name1 > name2;
	end

	-- One is located in the other
	if loc1 == name2 then
		return true;
	end
	if loc2 == name1 then
		return false;
	end
	
	-- Different containers
	if loc1 == "" then
		return name1 > loc2;
	elseif loc2 == "" then
		return loc1 > name2;
	else
		return loc1 > loc2;
	end
end

function onListRearranged(listchanged)
	local containermapping = {};

	for k, w in ipairs(getWindows()) do
		local entry = {};
		entry.name = w.name.getValue();
		entry.location = w.location.getValue();
		entry.window = w;
		table.insert(containermapping, entry);
	end
	
	local lastcontainer = 1;
	for n, w in ipairs(containermapping) do
		if n > 1 and string.lower(w.location) == string.lower(containermapping[lastcontainer].name) and w.location ~= "" then
			-- Item in a container
			w.window.name.setAnchor("left", nil, "left", "absolute", 35);
		else
			-- Top level item
			w.window.name.setAnchor("left", nil, "left", "absolute", 25);
			lastcontainer = n;
		end
	end
end

function onInit()
	updateEncumbrance();
end
