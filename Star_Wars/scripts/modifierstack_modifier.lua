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

function onGainFocus()
	ModifierStack.setAdjustmentEdit(true);
end

function onLoseFocus()
	ModifierStack.setAdjustmentEdit(false);
end

function onWheel(notches)
	if not hasFocus() then
		ModifierStack.adjustFreeAdjustment(notches);
	end

	return true;
end

function onValueChanged()
	if hasFocus() then
		ModifierStack.setFreeAdjustment(getValue());
	end
end

function onClickDown(button, x, y)
	if button == 2 then
		ModifierStack.reset();
		return true;
	end
end

function onDrop(x, y, draginfo)
	return window.base.onDrop(x, y, draginfo);
end

function onDrag(button, x, y, draginfo)
	-- Create a composite drag type so that a simple drag into the chat window won't use the modifiers twice
	draginfo.setType("modifierstack");
	draginfo.setNumberData(ModifierStack.getSum());

	local basedata = draginfo.createBaseData("number");
	basedata.setDescription(ModifierStack.getDescription());
	basedata.setNumberData(ModifierStack.getSum());
	return true;
end

function onDragEnd(draginfo)
	ModifierStack.reset();
end
