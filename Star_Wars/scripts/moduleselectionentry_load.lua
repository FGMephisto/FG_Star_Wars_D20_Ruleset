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


local startx, dx;

function onClickDown(button, x, y)
	local w, h = getSize();
	startx = x;

	if window.active then
		setIcon(states[1].unloading[1]);
	else
		setIcon(states[1].loading[1]);
	end
	
	return true;
end

function onClickRelease(button, x, y)
	if window.active then
		setIcon(states[1].loaded[1]);
	else
		setIcon(states[1].unloaded[1]);
	end
	
	return true;
end

function onDragEnd(dragdata)
	local w, h = getSize();
	
	if window.active then
		if dx > w/2 then
			window.deactivate();
		else
			setIcon(states[1].loaded[1]);
		end
	else
		if dx < -w/2 then
			window.activate();
		else
			setIcon(states[1].unloaded[1]);
		end
	end
end

function onDrag(button, x, y, dragdata)
	local w, h = getSize();
	
	dx = x - startx;
	
	if window.active then
		if dx > w/2 then
			setIcon(states[1].unloaded[1]);
		else
			setIcon(states[1].unloading[1]);
		end
	else
		if dx < -w/2 then
			setIcon(states[1].loaded[1]);
		else
			setIcon(states[1].loading[1]);
		end
	end

	return true;
end
