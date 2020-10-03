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


function update()
--	if ranknode and halfranknode then
--		setValue(ranknode.getValue() + 0.5 * halfranknode.getValue());
--	end

	setValue((ranknode.getValue() + plannedranknode.getValue()) + 0.5 * (halfranknode.getValue() + plannedhalfranknode.getValue()));
	
	if plannedranknode.getValue() ~= 0 or plannedhalfranknode.getValue() ~= 0 then
		setColor("ffbb0000");
	else
		setColor(nil);
	end

	window.windowlist.skillPointsChanged();
end

-- Helper function to get class skill status from state control
function isClassSkill()
	return window["state"].isClassSkill();
end

function checkAndSet(value)
	if not window.windowlist.directadjustment then
		-- Round down to nearest possible skill rank, i.e. increments of .5
		value = math.floor(value * 2) / 2;

		-- Calculate the planned ranks
		local ranks = ranknode.getValue();
		local halfranks = halfranknode.getValue();
		
		local plannedranks = 0;

		if isClassSkill() then
			local newranks = value - ranks - halfranks * 0.5;

			if newranks >= 0 and newranks == math.floor(newranks) then
				plannedranks = newranks;
			end
		else
			local newhalfranks = 2 * (value - ranks - halfranks * 0.5);
			
			if newhalfranks >= 0 then
				plannedranks = newhalfranks;
			end
		end
		
		-- Make sure the value doesn't go over the available skill points or the maximum rank
		local maxranks = levelnode.getValue() + 3;

		local totalplanned = 0;
		for k,w in ipairs(window.windowlist.getWindows()) do
			if w ~= window then
				totalplanned = totalplanned + w.getDatabaseNode().getChild("plannedranks").getValue();
				totalplanned = totalplanned + w.getDatabaseNode().getChild("plannedhalfranks").getValue();
			end
		end
		
		if availablenode.getValue() - totalplanned < plannedranks then
			maxranks = availablenode.getValue() - totalplanned + ranks + halfranks;
		end
		
--		print("planned " .. plannedranks .. ", total " .. totalplanned .. ", ranks " .. ranks .. ", half " .. halfranks .. ", max " .. maxranks);
		
		if plannedranks + ranks + halfranks > maxranks then
			plannedranks = maxranks - ranks - halfranks;
		end
		if plannedranks < 0 then
			plannedranks = 0;
		end

		-- Adjust values
		if isClassSkill() then
			plannedranknode.setValue(plannedranks);
		else
			plannedhalfranknode.setValue(plannedranks);
		end
	else		
		if isClassSkill() then
			local newranks = value - halfranknode.getValue() * 0.5;
			
			-- Adjust ranks, fall through to previous values if negative or fractional
			if newranks >= 0 and newranks == math.floor(newranks) then
				ranknode.setValue(newranks);
			end
		else
			local newhalfranks = 2 * (value - ranknode.getValue());
			
			-- Adjust half ranks, fall through to previous values if negative
			if newhalfranks >= 0 then
				halfranknode.setValue(newhalfranks);
			end
		end
	end

	update();
end

function onValueChanged()
	checkAndSet(getValue());
end

function onWheel(notches)
	if isClassSkill() then
		checkAndSet(getValue() + notches);
	else
		checkAndSet(getValue() + notches * 0.5);
	end
	
	return true;
end

function onInit()
	ranknode = window.getDatabaseNode().createChild("ranks", "number");
	halfranknode = window.getDatabaseNode().createChild("halfranks", "number");
	plannedranknode = window.getDatabaseNode().createChild("plannedranks", "number");
	plannedhalfranknode = window.getDatabaseNode().createChild("plannedhalfranks", "number");
	
	ranknode.onUpdate = update;
	halfranknode.onUpdate = update;
	plannedranknode.onUpdate = update;
	plannedhalfranknode.onUpdate = update;
	
	levelnode = window.windowlist.window.getDatabaseNode().createChild("characterlevel", "number");
	availablenode = window.windowlist.window.getDatabaseNode().createChild("skillpoints.unspent", "number");
	
	update();
end
