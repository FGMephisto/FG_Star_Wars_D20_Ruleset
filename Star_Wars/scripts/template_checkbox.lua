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

-- The sourceless value is used if the checkbox is used in a window not bound to the database
-- or if the <sourceless /> flag is specifically set
local sourcelessvalue = false;

function setState(state)
	local datavalue = 1;
	
	if state == nil or state == false or state == 0 then
		datavalue = 0;
	end
	
	if source then
		source.setValue(datavalue);
	else
		if datavalue == 0 then
			sourcelessvalue = false;
		else
			sourcelessvalue = true;
		end
		
		update();
	end
end

function update()
	if source then
		if source.getValue() ~= 0 then
			setIcon(stateicons[1].on[1]);
		else
			setIcon(stateicons[1].off[1]);
		end
	else
		if sourcelessvalue then
			setIcon(stateicons[1].on[1]);
		else
			setIcon(stateicons[1].off[1]);
		end
	end
	
	if self.onValueChanged then
		self.onValueChanged();
	end
end

function getState()
	if source then
		local datavalue = source.getValue();
		return datavalue ~= 0;
	else
		return sourcelessvalue;
	end
end

function onClickDown(button, x, y)
	setState(not getState());
end

function onInit()
	setIcon(stateicons[1].off[1]);

	if not sourceless and window.getDatabaseNode() then
		-- Get value from source node
		if sourcename then
			source = window.getDatabaseNode().createChild(sourcename[1], "number");
		else
			source = window.getDatabaseNode().createChild(getName(), "number");
		end
		if source then
			source.onUpdate = update;
			update();
		end
	else
		-- Use internal value, initialize to checked if <checked /> is specified
		if checked then
			sourcelessvalue = true;
			update();
		end
	end
end
