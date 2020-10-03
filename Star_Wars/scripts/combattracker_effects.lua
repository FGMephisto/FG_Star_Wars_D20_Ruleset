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


function checkForEmpty()
	if not disablecheck then
		local found = false;
		for k, v in ipairs(getWindows()) do
			if v.label.getValue() == "" then
				found = true;
				break;
			end
		end
		
		if not found then
			local w = createWindow();
		end
	end
end

function onListRearranged()
	checkForEmpty();
end

function clearAndDisableCheck()
	disablecheck = true;
	closeAll();
end

function enableCheck()
	disablecheck = false;
end

function progressEffects(source)
	for k, v in ipairs(getWindows()) do
		if v.caster.getSource() == source then
			local oldvalue = v.duration.getValue();
			local newvalue = oldvalue + v.adjustment.getValue()
			v.duration.setValue(newvalue);
			
			if newvalue == 0 and newvalue ~= oldvalue then
				local msg = {};
				msg.text = "'" .. v.label.getValue() .. "' on " .. window.name.getValue() .. " expired";
				msg.font = "systemfont";
				msg.icon = "indicator_effect";
				
				ChatManager.addMessage(msg);
				
				v.close();
			end
		end
	end
end
