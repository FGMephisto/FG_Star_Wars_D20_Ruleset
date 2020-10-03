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


function onDrop(x, y, draginfo)
	if minisheet then
		return false;
	end

	if draginfo.isType("spelllistentry") then
		local droptarget = getWindowAt(x, y);
		if droptarget then
			local dropsource = draginfo.getCustomData();

			if dropsource.windowlist ~= droptarget.spelllist then
				-- Create new entry based on entry in another level
				local newwin = droptarget.spelllist.createWindow();
				newwin.name.setValue(dropsource.name.getValue());
				newwin.shortdescription.setValue(dropsource.shortdescription.getValue());
				newwin.shortcut.setValue(dropsource.shortcut.getValue());

				newwin.counter.updateSlots();
				
				-- Close the source window
				dropsource.getDatabaseNode().delete();
			end
		
			return true;
		end
	elseif draginfo.isType("spelldescwithlevel") then
		-- find the proper level window
		local targetlevel = draginfo.getNumberData();
		local droptarget = nil;
		for k, w in pairs(getWindows()) do
			local winlevel = tonumber(string.sub(w.getDatabaseNode().getName(), 6));
			if winlevel == targetlevel then
				droptarget = w;
				break;
			end
		end
		
		local availablenode = getDatabaseNode().getChild("..availablelevel" .. targetlevel);
		
		if droptarget then
			if availablenode and availablenode.getValue() ~= 0 then
				-- Create new entry based on shortcut with level
				local sourcenode = draginfo.getDatabaseNode();
				
				local newwin = droptarget.spelllist.createWindow();
				newwin.name.setValue(sourcenode.getChild("name").getValue());
				newwin.shortdescription.setValue(sourcenode.getChild("shortdescription").getValue());
				newwin.shortcut.setValue(draginfo.getShortcutData());
				
				newwin.counter.updateSlots();
			end
			
			return true;
		end
	elseif draginfo.isType("shortcut") then
		if draginfo.getShortcutData() == "spelldesc" then
			-- Create new entry based on shortcut
			local droptarget = getWindowAt(x, y);
			if droptarget then
				local sourcenode = draginfo.getDatabaseNode();
				
				local newwin = droptarget.spelllist.createWindow();
				newwin.name.setValue(sourcenode.getChild("name").getValue());
				newwin.shortdescription.setValue(sourcenode.getChild("shortdescription").getValue());
				newwin.shortcut.setValue(draginfo.getShortcutData());
				
				newwin.counter.updateSlots();
			
				return true;
			end
		end
	end
end

function onInit()
	getDatabaseNode().createChild("level0");
	getDatabaseNode().createChild("level1");
	getDatabaseNode().createChild("level2");
	getDatabaseNode().createChild("level3");
	getDatabaseNode().createChild("level4");
	getDatabaseNode().createChild("level5");
	getDatabaseNode().createChild("level6");
	getDatabaseNode().createChild("level7");
	getDatabaseNode().createChild("level8");
	getDatabaseNode().createChild("level9");
end

function onFilter(w)
	local levelname = w.getDatabaseNode().getName();
	local availablenode = getDatabaseNode().createChild("..available" .. levelname, "number");
	
	if availablenode and availablenode.getValue() ~= 0 then
		return true;
	end
	
	return false;
end
