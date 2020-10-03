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


widgets = {};
empty = true;

function isEmpty()
	return empty;
end

function update(token)
	for k, v in ipairs(widgets) do
		v.destroy();
	end
	empty = true;
	
	local ids = token.getTargetingIdentities();
	
	local w, h = getSize();
	local spacing = w / #ids;
	if spacing > tonumber(iconspacing[1]) then
		spacing = iconspacing[1];
	end

	for i = #ids, 1, -1 do
		widgets[i] = addBitmapWidget("portrait_" .. ids[i] .. "_miniportrait");
		widgets[i].setPosition("right", -(iconspacing[1]/2 + (i-1)*spacing), 0);
		empty = false;
	end
	
	window.setDefensiveVisible(not isEmpty());
end