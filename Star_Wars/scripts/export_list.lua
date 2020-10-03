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


entrymap = {};

function addCategories()
	local w;
	
	w = createWindow();
	w.setExportName("encounter");
	w.setExportClass("encounter");
	w.label.setValue("Story");
	
	w = createWindow();
	w.setExportName("image");
	w.setExportClass("imagewindow");
	w.label.setValue("Images & Maps");
	
	w = createWindow();
	w.setExportName("npc");
	w.setExportClass("npc");
	w.label.setValue("Personalities");
	
	w = createWindow();
	w.setExportName("item");
	w.setExportClass("item");
	w.label.setValue("Items");
end

function onInit()
	getNextWindow(nil).close();

	addCategories();
end

function onDrop(x, y, draginfo)
	if draginfo.isType("shortcut") then
		for k,v in ipairs(getWindows()) do
			local class, recordname = draginfo.getShortcutData();
		
			-- Find matching export category
			if string.find(recordname, v.exportsource) == 1 then
				-- Check duplicates
				for l,c in ipairs(v.entries.getWindows()) do
					if c.getDatabaseNode().getNodeName() == recordname then
						return true;
					end
				end
			
				-- Create entry
				local w = v.entries.createWindow(draginfo.getDatabaseNode());
				w.open.setValue(class, recordname);
				
				v.all.setState(false);
				break;
			end
		end
		
		return true;
	end
end
