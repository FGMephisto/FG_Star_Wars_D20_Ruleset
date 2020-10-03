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


control = nil;
freeadjustment = 0;
slots = {};

function registerControl(ctrl)
	control = ctrl;
end

function updateControl()
	if control then
		if adjustmentedit then
			control.label.setValue("Adjusting");
		else
			control.label.setValue("Modifier");
			
			if freeadjustment > 0 then
				control.label.setValue("(+" .. freeadjustment .. ")");
			elseif freeadjustment < 0 then
				control.label.setValue("(" .. freeadjustment .. ")");
			end
			
			control.modifier.setValue(getSum());
			
			control.base.resetCounters();
			
			for i = 1, #slots do
				control.base.addCounter();
			end
			
			if hoverslot and hoverslot ~= 0 and slots[hoverslot] then
				control.label.setValue(slots[hoverslot].description);
			end
		end
		
		if math.abs(control.modifier.getValue()) > 999 then
			control.modifier.setFont("modcollectorlabel");
		else
			control.modifier.setFont("modcollector");
		end
	end
end

function isEmpty()
	if freeadjustment == 0 and #slots == 0 then
		return true;
	end

	return false;
end

function getSum()
	local total = freeadjustment;
	
	for i = 1, #slots do
		total = total + slots[i].number;
	end
	
	return total;
end

function getDescription(forcebonus)
	local str = "";
	
	if not forcebonus and #slots == 1 and freeadjustment == 0 then
		str = slots[1].description;
	else
		for i = 1, #slots do
			if i ~= 1 then
				str = str .. ", ";
			end
			
			str = str .. slots[i].description;
			if slots[i].number > 0 then
				str = str .. " +" .. slots[i].number;
			else
				str = str .. " " .. slots[i].number;
			end
		end
		
		if freeadjustment ~= 0 and #slots > 0 then
			if freeadjustment > 0 then
				str = str .. ", +" .. freeadjustment;
			else
				str = str .. ", " .. freeadjustment;
			end
		end
	end
	
	return str;
end

function addSlot(description, number)
	if #slots < 6 then
		table.insert(slots, { ['description'] = description, ['number'] = number });
	end
	
	updateControl();
end

function removeSlot(number)
	table.remove(slots, number);
	updateControl();
end

function adjustFreeAdjustment(amount)
	freeadjustment = freeadjustment + amount;
	
	updateControl();
end

function setFreeAdjustment(amount)
	freeadjustment = amount;
	
	updateControl();
end

function setAdjustmentEdit(state)
	if state then
		control.modifier.setValue(freeadjustment);
	else
		setFreeAdjustment(control.modifier.getValue());
	end

	adjustmentedit = state;
	updateControl();
end

function reset()
	if control and control.modifier.hasFocus() then
		control.modifier.setFocus(false);
	end

	freeadjustment = 0;
	slots = {};
	updateControl();
end

function hoverDisplay(n)
	hoverslot = n;
	updateControl();
end

-- Hot key handling
function checkHotkey(keyinfo)
	if keyinfo.getType() == "number" or keyinfo.getType() == "modifierstack" then
		addSlot(keyinfo.getDescription(), keyinfo.getNumberData());
		return true;
	end
end

function onInit()
	Interface.onHotkeyActivated = checkHotkey;
end
