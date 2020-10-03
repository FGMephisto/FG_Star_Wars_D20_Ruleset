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


-- The number of spells cast at this level
totalcast = 0;
-- The number of spells prepared at this level, or nil if spontaneous
totalprepared = nil;
-- The greatest number of an individual spell prepared
mostprepared = 0;


function updateCounters()
	totalcast = 0;
	totalprepared = nil;
	mostprepared = 0;
			
	-- Calculate spell statistics
	for k, w in pairs(getWindows()) do
		local level = w.getLevel();
		local cast = w.getCast();
		local prepared = w.getPrepared();

		-- Count values
		totalcast = totalcast + cast;
		if prepared then
			if not totalprepared then
				totalprepared = 0;
			end
		
			totalprepared = totalprepared + prepared;
			if mostprepared < prepared then
				mostprepared = prepared;
			end
		end
	end

	-- Spontaneous counters may need updating
	if not totalprepared then
		for k, w in pairs(getWindows()) do
			w.counter.updateSlots();
		end
	end
	
	-- Update counters
	if not minisheet then
		if totalprepared then
			window.stats.setValue("- Cast: " .. totalcast .. " / Prepared: " .. totalprepared);
		else
			window.stats.setValue("- Cast: " .. totalcast);
		end
	end
	
	if minisheet then
		window.windowlist.applyFilter();
		applyFilter();
	end
end

function onFilter(w)
	-- Hide unprepared items in minisheet
	if minisheet then
		local p = w.getPrepared();
		if p == 0 then
			return false;
		end
	end

	return true;
end

function onSortCompare(w1, w2)
	local name1 = w1.name.getValue();
	local name2 = w2.name.getValue();

	if name1 == "" then
		return true;
	elseif name2 == "" then
		return false;
	else
		return name1 > name2;
	end
end

function onInit()
	-- Monitor spontaneity mode to update counters
	spontaneitynode = getDatabaseNode().createChild("....spontaneous", "number");
	spontaneitynode.onUpdate = updateCounters;

	updateCounters();
	
	for k, w in pairs(getWindows()) do
		w.counter.updateSlots();
	end	
end

function onDrop(x, y, draginfo)
	-- Do not process message to pass it directly to level list
	return false;
end