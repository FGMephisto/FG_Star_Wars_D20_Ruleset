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


iscustom = true;
sets = {};

-- This function is called to set the entry to non-custom or custom.
-- Custom entries have configurable stats and editable labels.
function setCustom(state)
	iscustom = state;
	
	if not iscustom then
		label.setEnabled(false);
		label.setFrame(nil);
		
		statlabel.setStateFrame("hover", nil);
	end
	
	setRadialDeleteOption();
end

-- Planned rank management
function resetPlanned()
	if getDatabaseNode().getChild("plannedranks") then
		getDatabaseNode().getChild("plannedranks").setValue(0);
	end
	if getDatabaseNode().getChild("plannedhalfranks") then
		getDatabaseNode().getChild("plannedhalfranks").setValue(0);
	end
end

function submitPlanned()
	local submitted = 0;

	if getDatabaseNode().getChild("ranks") and getDatabaseNode().getChild("plannedranks") then
		local planned = getDatabaseNode().getChild("plannedranks").getValue();
		getDatabaseNode().getChild("ranks").setValue(getDatabaseNode().getChild("ranks").getValue() + planned);
		submitted = submitted + planned;
	end
	if getDatabaseNode().getChild("halfranks") and getDatabaseNode().getChild("plannedhalfranks") then
		local planned = getDatabaseNode().getChild("plannedhalfranks").getValue();
		getDatabaseNode().getChild("halfranks").setValue(getDatabaseNode().getChild("halfranks").getValue() + planned);
		submitted = submitted + planned;
	end
	
	return submitted;
end

-- Functions to manage and store class skill set membership
function parseSets()
	sets = {};

	-- Set strings are number entries separated by commas and optional whitespace
	for w in string.gmatch(setnode.getValue(), "(%d),?%s*") do
		if tonumber(w) then
			sets[tonumber(w)] = true;
		end
	end
end

function storeSets()
	local setstring = "";

	for k, v in pairs(sets) do
		setstring = setstring .. k .. ",";
	end
	
	setnode.setValue(setstring);
end

function setInSet(set, state)
	if not state then
		sets[tonumber(set)] = nil;
	else
		sets[tonumber(set)] = true;
	end
	
	resetPlanned();
	storeSets();
end

function isInSet(set)
	return sets[tonumber(set)];
end

function setUpdated()
	parseSets();
	state.update();
end

function setRadialDeleteOption()
	resetMenuItems();

	if not iscustom then
		-- Disallow deletion of non-custom skills
		local labelval = label.getValue();
		
		if windowlist.skilldata[labelval].sublabeling then
			-- Except for sublabeled skills that have several instances
			local count = 0;
			
			for k, w in pairs(windowlist.getWindows()) do
				if w.label.getValue() == labelval then
					count = count + 1;
				end
			end
			
			if count > 1 then
				registerMenuItem("Delete", "delete", 6);
			end
		end
	else
		registerMenuItem("Delete", "delete", 6);
	end
end

function onMenuSelection(item)
	if item == 6 then
		getDatabaseNode().delete();
	end
end

function onInit()
	setnode = getDatabaseNode().createChild("sets", "string");
	setnode.onUpdate = setUpdated;
	
	parseSets();
	
	setRadialDeleteOption();
end

function onClose()
	storeSets();
end
