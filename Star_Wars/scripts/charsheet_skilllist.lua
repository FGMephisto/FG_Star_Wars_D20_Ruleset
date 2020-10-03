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


function onSortCompare(w1, w2)
	if w1.label.getValue() == "" then
		return true;
	elseif w2.label.getValue() == "" then
		return false;
	end

	return w1.label.getValue() > w2.label.getValue();
end

function addNewInstance(label)
	local data = skilldata[label];
	
	if data and data.sublabeling then
		local newwin = createWindow();
		
		newwin.label.setValue(label);
		newwin.sublabel.setVisible(true);
		newwin.stat.setStat(data.stat);
		newwin.setCustom(false);
		
		newwin.sublabel.setFocus();
	end
end

function resetPlannedPoints()
	disablerecounts = true;

	for k,w in ipairs(getWindows()) do
		w.resetPlanned();
	end
	
	disablerecounts = false;
	skillPointsChanged();
end

function submitPlannedPoints()
	disablerecounts = true;

	-- Apply changes and count submitted ranks
	local total = 0;
	for k,w in ipairs(getWindows()) do
		total = total + w.submitPlanned();
		w.resetPlanned();
	end
	
	-- Adjust unspent count
	local unspentnode = window.getDatabaseNode().getChild("unspentskillpoints");
	if unspentnode then
		if unspentnode.getValue() - total >= 0 then
			unspentnode.setValue(unspentnode.getValue() - total);
		else
			unspentnode.setValue(0);
		end
	end
	
	disablerecounts = false;
	skillPointsChanged();
end

function setChanged()
	resetPlannedPoints();

	for k, w in pairs(getWindows()) do
		w.state.update();
	end
end

function skillPointsChanged()
	if not disablerecounts and window.plannedskillpoints then
--		window.skillpoints.calculatePoints();
		window.plannedskillpoints.calculatePoints();
	end
end

function onMenuSelection()
	resetMenuItems();
	resetPlannedPoints();

	if not directadjustment then
		registerMenuItem("Planned increment", "lock", 4);
		directadjustment = true;
	else
		registerMenuItem("Direct adjustment", "unlock", 4);
		directadjustment = false;
	end
end

function onInit()
	registerMenuItem("Direct adjustment", "unlock", 4);

	-- Initialize active set
	activesetnode = window.getDatabaseNode().getChild("activeskillset");
	
	if not activesetnode then
		activesetnode = window.getDatabaseNode().createChild("activeskillset", "number");
		activesetnode.setValue(1);
	end

	activesetnode.onUpdate = setChanged;

	-- Construct default skills
	constructDefaultSkills();

	-- Update set states
	setChanged();
end

-- Create default skill selection
function constructDefaultSkills()
	-- Collect existing entries
	local entrymap = {};

	for k, w in pairs(getWindows()) do
		local label = w.label.getValue(); 
	
		if skilldata[label] then
			if not entrymap[label] then
				entrymap[label] = { w };
			else
				table.insert(entrymap[label], w);
			end
		end
	end

	-- Set properties and create missing entries for all known skills
	for k, t in pairs(skilldata) do
		local matches = entrymap[k];
		
		if not matches then
			local newwin = createWindow();
			newwin.label.setValue(k);
			matches = { newwin };
		end
		
		-- Update properties
		for matchindex, match in pairs(matches) do
			if t.stat then
				match.stat.setStat(t.stat);
			else
				match.stat.setStat(nil);
				match.stat.setVisible(false);
				match.misc.setVisible(false);
				match.total.setVisible(false);
			end
			
			if t.sublabeling then
				match.sublabel.setVisible(true);
			end
			
			if t.armorcheckmultiplier then
				match.getDatabaseNode().createChild("armorcheckmultiplier", "number").setValue(t.armorcheckmultiplier);
			end
			
			match.setCustom(false);
		end
	end
end

-- Skill properties
skilldata = {
	["Appraise"] = {
			stat = "intelligence"
		},
	["Astrogate"] = {
			stat = "intelligence"
		},
	["Balance"] = {
			stat = "dexterity",
			armorcheckmultiplier = 1
		},
	["Bluff"] = {
			stat = "charisma"
		},
	["Climb"] = {
			stat = "strength",
			armorcheckmultiplier = 1
		},
	["Computer Use"] = {
			stat = "intelligence"
		},
	["Craft"] = {
			sublabeling = true,
			stat = "intelligence"
		},
	["Demolitions"] = {
			stat = "intelligence"
		},
	["Diplomacy"] = {
			stat = "charisma"
		},
	["Disable device"] = {
			stat = "intelligence"
		},
	["Disguise"] = {
			stat = "charisma"
		},
	["Entertain"] = {
			sublabeling = true,
			stat = "charisma"
		},
	["Escape artist"] = {
			stat = "dexterity",
			armorcheckmultiplier = 1
		},
	["Forgery"] = {
			stat = "intelligence"
		},
	["Gamble"] = {
			stat = "wisdom"
		},
	["Gather information"] = {
			stat = "charisma"
		},
	["Handle animal"] = {
			stat = "charisma"
		},
	["Hide"] = {
			stat = "dexterity",
			armorcheckmultiplier = 1
		},
	["Intimidate"] = {
			stat = "charisma"
		},
	["Jump"] = {
			stat = "strength",
			armorcheckmultiplier = 1
		},
	["Knowledge"] = {
			sublabeling = true,
			stat = "intelligence"
		},
	["Listen"] = {
			stat = "wisdom"
		},
	["Move silently"] = {
			stat = "dexterity",
			armorcheckmultiplier = 1
		},
	["Pilot"] = {
			stat = "dexterity"
		},
	["Profession"] = {
			sublabeling = true,
			stat = "wisdom"
		},
	["Read/Write language"] = {
			sublabeling = true
		},
	["Repair"] = {
			stat = "intelligence"
		},
	["Ride"] = {
			stat = "dexterity"
		},
	["Search"] = {
			stat = "intelligence"
		},
	["Sense motive"] = {
			stat = "wisdom"
		},
	["Sleight of hand"] = {
			stat = "dexterity",
			armorcheckmultiplier = 1
		},
	["Speak language"] = {
			sublabeling = true
		},
	["Spot"] = {
			stat = "wisdom"
		},
	["Survival"] = {
			stat = "wisdom"
		},
	["Swim"] = {
			stat = "strength",
			armorcheckmultiplier = 2
		},
	["Treat Injury"] = {
			stat = "wisdom"
		},
	["Tumble"] = {
			stat = "dexterity",
			armorcheckmultiplier = 1
		}
}
