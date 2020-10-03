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


local topWidget = nil;
local tabIndex = 1;
local tabWidgets = {};

function activateTab(index)
	-- Hide active tab, fade text labels
	tabWidgets[tabIndex].setColor("80ffffff");
	window[tab[tabIndex].subwindow[1]].setVisible(false);
	if tab[tabIndex].scroller then
		window[tab[tabIndex].scroller[1]].setVisible(false);
	end

	-- Set new index
	tabIndex = tonumber(index);

	-- Move helper graphic into position
	topWidget.setPosition("topleft", 5, 67*(tabIndex-1)+7);
	if tabIndex == 1 then
		topWidget.setVisible(false);
	else
		topWidget.setVisible(true);
	end
	
	-- Activate text label and subwindow
	tabWidgets[tabIndex].setColor("ffffffff");

	window[tab[tabIndex].subwindow[1]].setVisible(true);
	if tab[tabIndex].scroller then
		window[tab[tabIndex].scroller[1]].setVisible(true);
	end
end

function onClickDown(button, x, y)
	local i = math.ceil(y/67);
	
	-- Make sure index is in range and activate selected
	if i > 0 and i < #tab+1 then
		activateTab(i);
	end
end

function onDoubleClick(x, y)
	-- Emulate single click
	onClickDown(1, x, y);
end

function onInit()
	-- Create a helper graphic widget to indicate that the selected tab is on top
	topWidget = addBitmapWidget("tabtop");
	topWidget.setVisible(false);

	-- Deactivate all labels	
	for n, v in ipairs(tab) do
		tabWidgets[n] = addBitmapWidget(v.icon[1]);
		tabWidgets[n].setPosition("topleft", 7, 67*(n-1)+41);
		tabWidgets[n].setColor("80ffffff");
	end

	if activate then
		activateTab(activate[1]);
	else
		activateTab(1);
	end
end
