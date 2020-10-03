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


skillstatenode = nil;

function update()
	if activesetnode then
		if window.isInSet(activesetnode.getValue()) then
			setIcon("indicator_checkon");
		else
			setIcon("indicator_checkoff");
		end
	end
end

function toggle()
	if activesetnode then
		local newstate = not window.isInSet(activesetnode.getValue());
		window.setInSet(activesetnode.getValue(), newstate);
	end
end

function isClassSkill()
	if activesetnode and window.isInSet(activesetnode.getValue()) then
		return true;
	end

	return false;
end

function onClickDown(button, x, y)
	toggle();
end

function onInit()
	-- Set selection
	activesetnode = window.windowlist.window.getDatabaseNode().createChild("activeskillset", "number");
end
