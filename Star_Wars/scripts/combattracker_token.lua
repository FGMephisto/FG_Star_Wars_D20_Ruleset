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


function refDeleted(deleted)
	ref = nil;
end

function refTargeted(targeted)
	window.targeting.update(ref);
end

function setActive(status)
	if ref then
		ref.setActive(status);
	end
end

function setName(name)
	if ref then
		ref.setName(name);
	end
end

function updateUnderlay()
	if ref then
		ref.removeAllUnderlays();
		
		local space = math.ceil(window.space.getValue() / 5) / 2;
		local reach = math.ceil(window.reach.getValue() / 5) + space;
		
		if window.getType() == "pc" then
			ref.addUnderlay(reach, "4f000000", "hover");
		else
			ref.addUnderlay(reach, "4f000000", "hover,gmonly");
		end
		
		if window.getFoF() == "friend" then
			ref.addUnderlay(space, "2f00ff00");
		elseif window.getFoF() == "foe" then
			ref.addUnderlay(space, "2fff0000");
		elseif window.getFoF() == "neutral" then
			ref.addUnderlay(space, "2fffff00");
		end
	end
end

function acquireReference(dropref)
	if dropref then
		if ref and ref ~= dropref then
			ref.delete();
		end

		ref = dropref;
		
		ref.onDelete = refDeleted;
		ref.onTargetUpdate = refTargeted;

		ref.setActivable(true);
		ref.setTargetable(true);

		if window.getType() == "pc" then
			ref.setVisible(true);
		else
			ref.setModifiable(false);
		end
			
		ref.setActive(window.active.getState());
		ref.setName(window.name.getValue());

		updateUnderlay();
		
		scale = ref.getScale();
		
		return true;
	end
end

function onDrop(x, y, draginfo)
	if draginfo.isType("token") then
		local prototype, dropref = draginfo.getTokenData();
		setPrototype(prototype);
		return acquireReference(dropref);
	end
end

function onDragEnd(draginfo)
	local prototype, dropref = draginfo.getTokenData();
	return acquireReference(dropref);
end

function onClickDown(button, x, y)
	return true;
end

function onClickRelease(button, x, y)
	if ref then
		if button == 1 then
			if ref.isActive() then
				ref.setActive(false);
			else
				ref.setActive(true);
			end
		else
			ref.setScale(1.0)
			scale = 0;
			if scaleWidget then
				scaleWidget.setVisible(false);
			end
		end
	end
	
	return true;
end

function onWheel(notches)
	if ref then
		if not scaleWidget then		
			scaleWidget = addTextWidget("sheetlabelsmall", "0");
			scaleWidget.setFrame("tempmodmini", 4, 1, 6, 3);
			scaleWidget.setPosition("topright", -2, 2);
		end
	
		if Input.isControlPressed() then
			scale = math.floor(scale + notches);
			if scale < 1 then
				scale = 1;
			end
		else
			scale = scale + notches*0.1;
	
			if scale < 0.1 then
				scale = 0.1;
			end
		end
		
		if scale == 1 then
			ref.setScale(1.0);
			scaleWidget.setVisible(false);
		else
			ref.setScale(scale);
			scaleWidget.setVisible(true);
			scaleWidget.setText(scale);
		end
	end
		
	return true;
end