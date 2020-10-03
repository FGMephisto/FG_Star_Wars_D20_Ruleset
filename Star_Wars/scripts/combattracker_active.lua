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


function setState(s)
	state = s;
	activewidget.setVisible(state);
	window.token.setActive(state);
	window.setActiveVisible(state);
end

function getState()
	return state;
end

function onInit()
	activewidget = addBitmapWidget(activeicon[1]);
	activewidget.setVisible(false);
	
	state = false;
end

function onClickDown(button, x, y)
	return true;
end

function onClickRelease(button, x, y)
	if not state then
		window.windowlist.requestActivation(window);
	end
end

function onDrag(button, x, y, draginfo)
	draginfo.setType("combattrackeractivation");
	draginfo.setIcon(activeicon[1]);

	activewidget.setVisible(false);

	return true;
end

function onDragEnd(draginfo)
	if state then
		activewidget.setVisible(true);
	end
end

function onDrop(x, y, draginfo)
	if draginfo.isType("combattrackeractivation") then
		window.windowlist.requestActivation(window);
	end
end