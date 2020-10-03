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


function getCompletion(str)
	-- Find a matching completion for the given string
	for i = 1, #autofill do
		if string.lower(str) == string.lower(string.sub(autofill[i], 1, #str)) then
			return string.sub(autofill[i], #str + 1);
		end
	end
	
	return "";
end

function onChar()
	if getCursorPosition() == #getValue()+1 then
		completion = getCompletion(getValue());

		if completion ~= "" then
			value = getValue();
			newvalue = value .. completion;

			setValue(newvalue);
			setSelectionPosition(getCursorPosition() + #completion);
		end

		return;
	end
end

function onGainFocus()
	autofill = {};
	
	for k, v in ipairs(window.windowlist.getWindows()) do
		local s = v.name.getValue();
		if s ~= "" then
			table.insert(autofill, s);
		end
	end
	
	super.onGainFocus();
end

function onLoseFocus()
	super.onLoseFocus();
	window.windowlist.applySort();
end
