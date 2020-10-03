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


hoverontext = false;

function onHover(oncontrol)
	if not oncontrol then
		setUnderline(false);
		hoverontext = false;
	end
end

function onHoverUpdate(x, y)
	if getIndexAt(x, y) < #getValue() then
		setUnderline(true);
		hoverontext = true;
	else
		setUnderline(false);
		hoverontext = false;
	end
end

function onClickDown(button, x, y)
	if hoverontext then
		return true;
	else
		return false;
	end
end

function onClickRelease(button, x, y)
	if hoverontext then
		if self.activate then
			self.activate();
		else
			window[linktarget[1]].activate();
		end
		return true;
	end
end

function onDrag(button, x, y, draginfo)
	if linktarget and hoverontext then
		if window[linktarget[1]].onDrag then
			return window[linktarget[1]].onDrag(button, x, y, draginfo);
		end
	else
		return false;
	end
end
