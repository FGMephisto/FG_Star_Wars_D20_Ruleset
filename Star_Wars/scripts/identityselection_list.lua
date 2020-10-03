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

function clearSelection()
	for k, w in ipairs(getWindows()) do
		w.base.setFrame(nil);
	end
end

function addIdentity(id, label, localdatabasenode)
	for k, v in ipairs(activeidentities) do
		if v == id then
			return;
		end
	end

	win = createWindow();
	win.setId(id);
	win.label.setValue(label);

	win.setLocalNode(localdatabasenode);

	if id then
		win.portrait.setIcon("portrait_" .. id .. "_charlist");
	end
end

function onInit()
	activeidentities = User.getAllActiveIdentities();

	getWindows()[1].close();
	createWindowWithClass("identityselection_newentry");

	localIdentities = User.getLocalIdentities();
	for n, v in ipairs(localIdentities) do
		local localnode = v.databasenode;
		local labelnode = v.databasenode.createChild("name", "string");
		addIdentity(v.id, labelnode.getValue(), localnode);
	end

	User.getRemoteIdentities("charsheet", "name", addIdentity);
end
