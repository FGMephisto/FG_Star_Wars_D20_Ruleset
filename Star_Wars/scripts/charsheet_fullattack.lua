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
offsetx = 0;
offsety = 0;

function updateWidgets()
	for k, v in ipairs(widgets) do
		v.destroy();
	end

	local wt = window[icons[1].container[1]];
	local c = getValue();
	
	local w, h = getSize();
	
	for i = 1, c do
		local ox = offsetx * (-1 + ((i-1) % 2) * 2);
		local oy = offsety * (1 - math.floor((i-1) / 2) * 2);
	
		local widget = wt.addBitmapWidget(icons[1].icon[1]);
		widget.setPosition("center", ox, oy);
		
		widgets[i] = widget;
	end
end

function updateAttackFields()
	local c = getValue();
	
	window[attackfields[1].attack1[1]].setVisible(c >= 1);
	window[attackfields[1].attack2[1]].setVisible(c >= 2);
	window[attackfields[1].attack3[1]].setVisible(c >= 3);
	window[attackfields[1].attack4[1]].setVisible(c >= 4);
end

function onValueChanged()
	if getValue() < 1 then
		setValue(1);
	elseif getValue() > 4 then
		setValue(4);
	end
	
	updateWidgets();
	updateAttackFields();
end

function onDrag(button, x, y, draginfo)
	draginfo.setType("fullattack");
	draginfo.setDescription(window[namefield[1]].getValue() .. " (Full atk)");
	
	for i = 1, getValue() do
		draginfo.setSlot(i);
		
		draginfo.setDieList({ "d20" });
		
		local ctrlname = attackfields[1]["attack" .. i][1];
		draginfo.setStringData(window[ctrlname].getDescriptionString());
		draginfo.setNumberData(window[ctrlname].getValue());
	end
	
	return true;
end

function onInit()
	offsetx = tonumber(icons[1].offsetx[1]);
	offsety = tonumber(icons[1].offsety[1]);

	updateWidgets();
	updateAttackFields();
end