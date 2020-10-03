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

function setRows(n)
	if n < 0 then
		return;
	end

	local windows = getWindows();
	
	if #windows > n then
		-- Need to close some entries
		for i = n+1, #windows do
			windows[i].close();
		end
		return;
	end
	
	-- Otherwise, need to create some
	for i = 1, n - #windows do
		createWindow();
	end
end

function updateTotals()
	local sum = 0;

	for k, w in ipairs(getWindows()) do
		local score = w.score.getValue();
		local points = calculatePointCost(score);
		
		w.points.setValue(points);
		
		sum = sum + points;
	end
	
	window.total.setValue(sum);
	
	if not window.ranges.hasNonzeroCosts() then
		window.costwarning.setVisible(true);
	else
		window.costwarning.setVisible(false);
	end
end

function calculatePointCost(score)
	return window.ranges.calculatePointCost(score);
end
