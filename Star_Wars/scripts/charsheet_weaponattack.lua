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

local modifiernode = nil;
local bonusnode = nil;
local typenode = nil;
local rangeattackbonusnode = nil;
local meleeattackbonusnode = nil;

function getModifier()
	return modifiernode.getValue();
end

function setModifier(value)
	modifiernode.setValue(value);
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

function update()
	setModifierDisplay(modifiernode.getValue());
	
	local value = modifiernode.getValue() + modifier[1] + bonusnode.getValue();
	
	if typenode.getValue() == 0 then
		value = value + meleeattackbonusnode.getValue();
	else
		value = value + rangeattackbonusnode.getValue();
	end
	setValue(value);
end

function onInit()
	modifierWidget = addTextWidget("sheetlabelsmall", "0");
	modifierWidget.setFrame("tempmodmini", 3, 1, 6, 3);
	modifierWidget.setPosition("topright", 3, 1);
	modifierWidget.setVisible(false);
	
	local modifiernodename = getName() .. "modifier";
	modifiernode = window.getDatabaseNode().createChild(modifiernodename, "number");
	modifiernode.onUpdate = update;
	
	bonusnode = window.getDatabaseNode().createChild(sourcefields[1].bonus[1], "number");
	bonusnode.onUpdate = update;
	
	typenode = window.getDatabaseNode().createChild(sourcefields[1].type[1], "number");
	typenode.onUpdate = update;

	rangeattackbonusnode = window.getDatabaseNode().createChild(sourcefields[1].range[1], "number");
	rangeattackbonusnode.onUpdate = update;

	meleeattackbonusnode = window.getDatabaseNode().createChild(sourcefields[1].melee[1], "number");
	meleeattackbonusnode.onUpdate = update;

	update();
end

function onWheel(notches)
	setModifier(getModifier() + notches);
	return true;
end

function onDrop(x, y, draginfo)
	if draginfo.isType("number") then
		setModifier(draginfo.getNumberData());
	end

	return true;
end

function getDescriptionString()
	return window.getDatabaseNode().getChild(sourcefields[1].weaponname[1]).getValue() .. " (" .. name[1] .. ")";
end

function onDrag(button, x, y, draginfo)
	draginfo.setType("dice");
	
	draginfo.setDieList({ "d20" });
	draginfo.setNumberData(getValue());
	draginfo.setDescription(getDescriptionString());
	
	return true;
end
