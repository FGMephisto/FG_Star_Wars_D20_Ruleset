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


local modifierWidget = nil;
local modifierFieldNode = nil;

function getModifier()
	return modifierFieldNode.getValue();
end

function setModifier(value)
	modifierFieldNode.setValue(value);
end

function setModifierDisplay(value)
	if value > 0 then
		modifierWidget.setText("+" .. value);
	else
		modifierWidget.setText(value);
	end
	
	if value == 0 then
		modifierWidget.setVisible(false);
	else
		modifierWidget.setVisible(true);
	end
end

function updateModifier(source)
	setModifierDisplay(modifierFieldNode.getValue());
end

function onInit()
	modifierWidget = addTextWidget("sheettextsmall", "0");
	modifierWidget.setFrame("tempmodsmall", 6, 3, 8, 5);
	modifierWidget.setPosition("topright", 0, 0);
	modifierWidget.setVisible(false);
	
	-- By default, the modifier is in a field named based on the parent control.
	local modifierFieldName = getName() .. "modifier";
	if modifierfield then
		-- Use a <modifierfield> override
		modifierFieldName = modifierfield[1];
	end
	
	modifierFieldNode = window.getDatabaseNode().createChild(modifierFieldName, "number");
	modifierFieldNode.onUpdate = updateModifier;
	addSourceWithOp(modifierFieldName, "+");

	updateModifier(modifierFieldNode);

	super.onInit();
end

function onWheel(notches)
	setModifier(getModifier() + notches);
	return true;
end

function onDrop(x, y, draginfo)
	if draginfo.getType() == "number" then
		setModifier(draginfo.getNumberData());
	end
	return true;
end
