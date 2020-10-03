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


gmidentity = false;

function createLabel(name, isgm)
	identityname = name;
	gmidentity = isgm;

	namewidget = addTextWidget("chatfont", name);
	namewidget.setPosition("center", 0, 0);
	namewidget.setMaxWidth(60);
	
	if gmidentity then
		namewidget.setFont("chatitalicfont");
	else
		resetMenuItems();
		registerMenuItem("Remove", "erase", 1);
	end
end

function rename(name)
	if namewidget then
		namewidget.setText(name);
	end
	
	identityname = name;
end

function setCurrent(state)
	if state then
		if gmidentity then
			namewidget.setFont("chatbolditalicfont");
		else
			namewidget.setFont("narratorfont");
		end
	else
		if gmidentity then
			namewidget.setFont("chatitalicfont");
		else
			namewidget.setFont("chatfont");
		end
	end
end

function onClickDown(button, x, y)
	return true;
end

function onClickRelease(button, x, y)
	if button == 1 then
		GmIdentityManager.setCurrent(identityname);
	elseif button == 2 then
		GmIdentityManager.removeIdentity(identityname);
	end
end

function onMenuSelection(...)
	GmIdentityManager.removeIdentity(identityname);
end

function onInit()
end