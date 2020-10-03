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


function applyModifierStackToRoll(draginfo)
	if ModifierStack.isEmpty() then
		--[[ do nothing ]]
	elseif draginfo.getNumberData() == 0 and draginfo.getDescription() == "" then
		draginfo.setDescription(ModifierStack.getDescription());
		draginfo.setNumberData(ModifierStack.getSum());
	else
		local originalnumber = draginfo.getNumberData();
		local numstr = tostring(originalnumber);
		if originalnumber > 0 then
			numstr = "+" .. originalnumber;
		end

		local moddesc = ModifierStack.getDescription(true);
		local desc = draginfo.getDescription();
		
		if numstr ~= "0" then
			desc = desc .. " " .. numstr;
		end
		if moddesc ~= "" then
			desc = desc .. " (" .. moddesc .. ")";
		end
		
		draginfo.setDescription(desc);
		draginfo.setNumberData(draginfo.getNumberData() + ModifierStack.getSum());
	end
	
	ModifierStack.reset();
end

function onDiceLanded(draginfo)
	if ChatManager.getDieRevealFlag() then
		draginfo.revealDice(true);
	end

	if draginfo.isType("fullattack") then
		for i = 1, draginfo.getSlotCount() do
			draginfo.setSlot(i);

			if not ModifierStack.isEmpty() then
				local originalnumber = draginfo.getNumberData();
				local numstr = originalnumber;
				if originalnumber > 0 then
					numstr = "+" .. originalnumber;
				end
				
				draginfo.setStringData(draginfo.getStringData() .. " " .. numstr .. " (" .. ModifierStack.getDescription(true) .. ")");
				draginfo.setNumberData(draginfo.getNumberData() + ModifierStack.getSum());
			end

			local entry = {};
			entry.text = draginfo.getStringData();
			entry.font = "systemfont";
			entry.dice = draginfo.getDieList();
			entry.diemodifier = draginfo.getNumberData();
			
			if User.isHost() then
				if ChatManager.getDieRevealFlag() then
					entry.dicesecret = false;
				end
				entry.sender = GmIdentityManager.getCurrent();
			else
				entry.sender = User.getIdentityLabel();
			end
			
			deliverMessage(entry);
		end
		
		ModifierStack.reset();
		return true;
	elseif draginfo.isType("dice") then
		applyModifierStackToRoll(draginfo);
	end
end

function onDrop(x, y, draginfo)
	if draginfo.getType() == "number" then
		applyModifierStackToRoll(draginfo);
	end
end

function moduleActivationRequested(module)
	local msg = {};
	msg.text = "Players have requested permission to load '" .. module .. "'";
	msg.font = "systemfont";
	msg.icon = "indicator_moduleloaded";
	addMessage(msg);
end

function moduleUnloadedReference(module)
	local msg = {};
	msg.text = "Could not open sheet with data from unloaded module '" .. module .. "'";
	msg.font = "systemfont";
	addMessage(msg);
end

function onInit()
	ChatManager.registerControl(self);
	
	if User.isHost() then
		Module.onActivationRequested = moduleActivationRequested;
	end

	Module.onUnloadedReference = moduleUnloadedReference;
end

function onClose()
	ChatManager.registerControl(nil);
end
