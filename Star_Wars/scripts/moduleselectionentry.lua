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


modulename = nil;
active = false;

info = nil;

function onInit()
	Module.onModuleUpdated = onUpdate;
	Module.onModuleRemoved = onRemove;
end

function onUpdate(updatename)
	if updatename == modulename then
		update()
	end
end

function onRemove(name)
	if name == modulename then
		close();
	end
end

function update()
	info = Module.getModuleInfo(modulename);
	
	-- Name
	name.setValue(info.name);
	author.setValue(info.author);
	
	-- Load status
	if info.loaded then
		load.setIcon(load.states[1].loaded[1]);
		active = true;
	else
		load.setIcon(load.states[1].unloaded[1]);
		active = false;
	end
	
	-- Permission/pending
	if info.permission == "disallow" then
		permissions.setIcon(permissions.states[1].block[1]);
	elseif info.permission == "allow" then
		permissions.setIcon(permissions.states[1].allow[1]);
	elseif info.permission == "autoload" then
		permissions.setIcon(permissions.states[1].autoload[1]);
	elseif info.loadpending then
		permissions.setIcon(permissions.states[1].pending[1]);
	else
		permissions.setIcon(permissions.states[1].none[1]);
	end
	
	-- Install state
	if info.installed then
		thumbnail.localwidget.setVisible(false);
	else
		thumbnail.localwidget.setVisible(true);
		load.setVisible(false);
		thumbnail.setColor("7fffffff");
		name.setColor("7f000000");
		author.setColor("7f000000");
	end
end

function setName(n)
	modulename = n;
	thumbnail.setIcon("module_" .. modulename);
	update();
end

function activate()
	Module.activate(modulename);
end

function deactivate()
	Module.deactivate(modulename);
end

function setPermissions(p)
	if p == "disallow" then
		Module.setModulePermissions(modulename, false, false);
	elseif p == "allow" then
		Module.setModulePermissions(modulename, true, false);
	elseif p == "autoload" then
		Module.setModulePermissions(modulename, true, true);
	end
end