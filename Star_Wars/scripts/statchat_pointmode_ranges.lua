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

rangedata = {};

function hasNonzeroCosts()
	for to, cost in pairs(rangedata) do
		if cost ~= 0 then
			return true;
		end
	end
	
	return false;
end

function onSortCompare(w1, w2)
	return w1.to.getValue() > w2.to.getValue();
end

function onListRearranged(listchanged)
	if listchanged then
		update();
	end
end

function update()
	applySort(true);
	
	for k,w in ipairs(getWindows()) do
		local prev = getPrevWindow(w);
		
		if prev then
			w.from.setValue(prev.to.getValue()+1);
			
			w.from.setVisible(true);
			w.dash.setVisible(true);
			w.upto.setVisible(false);
		else
			w.from.setValue(0);
			
			w.from.setVisible(false);
			w.dash.setVisible(false);
			w.upto.setVisible(true);
		end
	end

	rangedata = {};
	for k,w in ipairs(getWindows()) do
		rangedata[w.to.getValue()] = w.cost.getValue();
	end
	
	save();
end

function calculatePointCost(score)
	local counter = 0;
	local totalcost = 0;

	-- Determine order of point ranges
	local rangeorder = {};
	for to, cost in pairs(rangedata) do
		table.insert(rangeorder, to);
	end
	table.sort(rangeorder);

	-- Calculate cost for each point
	for i, to in ipairs(rangeorder) do
		local cost = rangedata[to];
		
		while counter < score and counter < to do
			counter = counter + 1;
			totalcost = totalcost + cost;
		end
		
		if counter >= score then
			return totalcost;
		end
	end
	
	return totalcost;
end

function load()
	if GlobalRegistry.statpointranges then
		local loadtable = GlobalRegistry.statpointranges[User.getRulesetName()];
		
		if loadtable then
			for to, cost in pairs(loadtable) do
				w = createWindow();
				w.to.setValue(to)
				w.cost.setValue(cost);
			end
			
			update();
		end
	end
end

function save()
	-- Write to registry
	if not GlobalRegistry.statpointranges then
		GlobalRegistry.statpointranges = {};
	end
	
	GlobalRegistry.statpointranges[User.getRulesetName()] = rangedata;
end

function onInit()
	load();
	
	if not getNextWindow(nil) then
		createWindow();
	end
	
	update();
end

function onClose()
	save();
end
