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

function update()
	for k, v in ipairs(widgets) do
		v.destroy();
	end
	
	local holders = window.getViewers();
	local p = 1;

	setAnchoredWidth(#holders * portraitspacing[1]);
	setAnchoredHeight(portraitspacing[1]);
	
	for i = 1, #holders do
		local identity = User.getCurrentIdentity(holders[i]);

		if identity then
			local bitmapname = "portrait_" .. identity .. "_" .. portraitset[1];

			widgets[i] = addBitmapWidget(bitmapname);
			widgets[i].setPosition("left", portraitspacing[1] * (p-0.5), 0);
			
			p = p + 1;
		end
	end
end

function onLogin(username, activated)
	update(monitornode);
end

function onInit()
	if User.isHost() then
		window.onViewersChanged = update;
		update();
	else
		setVisible(false);
	end
end