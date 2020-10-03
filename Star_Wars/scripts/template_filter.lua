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


function hide()
	setVisible(false);
	window[trigger[1]].setVisible(true);
end

function onEnter()
	hide();
end

function onLoseFocus()
	hide();
end

function onValueChanged()
	-- The target value is a series of consecutive window lists or sub windows
	local targetnesting = {};
	
	for w in string.gmatch(target[1], "(%w+)") do
		table.insert(targetnesting, w);
	end

	local target = window[targetnesting[1]];
	applyTo(target, targetnesting, 2);

	window[trigger[1]].updateWidget(getValue() ~= "");
end

function applyTo(target, nesting, index)
	local targettype = type(target);
	
	if targettype == "windowlist" then
		if index > #nesting then
			target.applyFilter();
			return;
		end
		
		for k, w in pairs(target.getWindows()) do
			applyTo(w[nesting[index]], nesting, index+1);
		end
	elseif targettype == "subwindow" then
		applyTo(target.subwindow[nesting[index]], nesting, index+1);
	end
end
