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


slots = {};

function isSpontaneous()
	return spontaneitynode.getValue() ~= 0;
end

function isCastingMode()
	if minisheet then
		return true;
	end

	return castingmodenode.getValue() ~= 0;
end

function getTotalCast()
	return window.windowlist.totalcast or 0;
end

function getMaxPrepared()
	local valuenode = window.getDatabaseNode().createChild(".....availablelevel" .. window.getLevel(), "number");
	return valuenode.getValue();
end

function getMostPrepared()
	return window.windowlist.mostprepared or 0;
end

function updateSlots()
	-- Clear
	for k, v in ipairs(slots) do
		v.destroy();
	end
	
	slots = {};
	
	-- Construct based on values
	local p = preparednode.getValue();
	local c = castnode.getValue();

	local max = p;
	if isSpontaneous() or not isCastingMode() then
		max = getMaxPrepared();
	end
	
	local totalcast = getTotalCast();
	
	for i = 1, max do
		local widget = nil;

		if not isSpontaneous() then		
			if i > c then
				widget = addBitmapWidget(stateicons[1].off[1]);
			else
				widget = addBitmapWidget(stateicons[1].on[1]);
			end
			
			if i > p then
				widget.setColor("4fffffff");
			end
		else
			if i > totalcast then
				widget = addBitmapWidget(stateicons[1].off[1]);
			else
				widget = addBitmapWidget(stateicons[1].on[1]);
			end
			
			if i <= totalcast-c or not isCastingMode() then
				widget.setColor("4fffffff");
			end
		end
		
		local pos = spacing[1]*(i-0.5);
		widget.setPosition("left", pos, 0);
		
		slots[i] = widget;
	end

	local width = spacing[1]*max;
	
	if not minisheet and not isSpontaneous() and isCastingMode() then
		setAnchoredWidth(spacing[1]*getMostPrepared());
	else
		setAnchoredWidth(width);
	end
end

function onWheel(notches)
	if isCastingMode() then
		local n = castnode.getValue();
		
		n = n + notches;

		if not isSpontaneous() then		
			local max = preparednode.getValue();

			if n > max then
				castnode.setValue(max);
			elseif n < 0 then
				castnode.setValue(0);
			else
				castnode.setValue(n);
			end
		else
			local max = getMaxPrepared();
			local totalcast = getTotalCast() + notches;
		
			if totalcast > max then
				if n - (totalcast - max) > 0 then
					castnode.setValue(n - (totalcast - max));
				else
					castnode.setValue(0);
				end
			elseif n < 0 then
				castnode.setValue(0);
			else
				castnode.setValue(n);
			end
		end
	else
		if isSpontaneous() then
			-- No nothing in preparation mode if spontaneous
			return true;
		end
	
		local max = getMaxPrepared();
		local n = preparednode.getValue();

		n = n + notches;
		
		if n > max then
			preparednode.setValue(max);
		elseif n < 0 then
			preparednode.setValue(0);
		else
			preparednode.setValue(n);
		end
	end
	
	return true;
end

function onClickDown(button, x, y)
	if isCastingMode() then
		-- Middle button resets
		if button == 2 then
			castnode.setValue(0);
			return;
		end
	
		local n = math.floor(x / spacing[1]) + 1;
		local current = castnode.getValue();
		
		if isSpontaneous() then
			local totalcast = getTotalCast();
			
			if n > totalcast then
				castnode.setValue(current+1);
			elseif current > 0 then
				castnode.setValue(current-1);
			end
		else
			if n > current then
				castnode.setValue(current+1);
			else
				castnode.setValue(current-1);
			end
		end
	else
		-- Middle button resets
		if button == 2 then
			preparednode.setValue(0);
			return;
		end
	
		-- Adjust value
		local n = math.floor(x / spacing[1]) + 1;
		local current = preparednode.getValue();
		
		if n == current then
			preparednode.setValue(n-1);
		else
			preparednode.setValue(n);
		end
	end
end

function onInit()
	preparednode = window.getDatabaseNode().createChild("prepared", "number");
	castnode = window.getDatabaseNode().createChild("cast", "number");
	spontaneitynode = window.getDatabaseNode().createChild(".....spontaneous", "number");
	availablenode = window.getDatabaseNode().createChild(".....availablelevel" .. window.getLevel(), "number");
	castingmodenode = window.getDatabaseNode().createChild(".......castingmode", "number");

	preparednode.onUpdate = updateSlots;
	castnode.onUpdate = updateSlots;
	spontaneitynode.onUpdate = updateSlots;
	availablenode.onUpdate = updateSlots;
	castingmodenode.onUpdate = updateSlots;
end
