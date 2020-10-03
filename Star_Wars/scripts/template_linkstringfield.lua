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


editmode = false;
hoverontext = false;

function setEditMode(state)
	if state then
		editmode = true;
		resetMenuItems();
		registerMenuItem("Stop editing", "stopedit", 5);

		setUnderline(false);
		setFocus();
		
		setCursorPosition(#getValue()+1);
		setSelectionPosition(0);
	else
		editmode = false;
		resetMenuItems();
		registerMenuItem("Edit", "edit", 4);
	end
end

function onInit()
	setEditMode(false);
end

function onHover(oncontrol)
	if not editmode then
		if not oncontrol then
			setUnderline(false);
			hoverontext = false;
		end
	end
end

function onHoverUpdate(x, y)
	if not editmode then
		if getIndexAt(x, y) < #getValue() then
			setUnderline(true);
			hoverontext = true;
		else
			setUnderline(false);
			hoverontext = false;
		end
	end
end

function onLoseFocus()
	setEditMode(false);
end

function onClickDown(button, x, y)
	if not editmode then
		if hoverontext then
			return true;
		else
			return false;
		end
	end
end

function onClickRelease(button, x, y)
	if not editmode and hoverontext then
		window[linktarget[1]].activate();
		return true;
	end
end

function onDrag(button, x, y, draginfo)
	if not editmode then
		if hoverontext then
			draginfo.setType("shortcut");
			draginfo.setShortcutData(window[linktarget[1]].getValue());
			draginfo.setIcon(window[linktarget[1]].icon[1].normal[1])
			return true;
		else
			return false;
		end
	end
end

function onMenuSelection(...)
	setEditMode(not editmode);
end
