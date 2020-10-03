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


function onInit()
	Interface.onHotkeyActivated = onHotkey;
	
	getWindows()[1].close();
	
	restoreFromRegistry();
	
	if #getWindows() == 0 then
		createWindow();
	end
end

function onClose()
	storeToRegistry();
end

function restoreFromRegistry()
	local trackertable = CampaignRegistry.combattracker;
	
	if trackertable then
		local idmap = {};		-- Mapping id -> window
	
		-- First pass, create entries
		for k, v in ipairs(trackertable) do
			local win = createWindow();
			win.restore(v);
			idmap[k] = win;
		end

		-- Second pass, create effects with ids
		for k, v in ipairs(trackertable) do
			idmap[k].restoreEffects(v, idmap);
		end
	end
end

function storeToRegistry()
	local trackertable = {};	-- Table to receive entries to store
	local idmap = {};			-- Mapping window -> id

	-- First pass, store entries
	for k,v in ipairs(getWindows()) do
		table.insert(trackertable, v.store());
		idmap[v] = #trackertable;
	end

	-- Second pass, store effects
	for k,v in pairs(idmap) do
		k.storeEffects(trackertable[v], idmap);
	end
	
	CampaignRegistry.combattracker = trackertable;
end

function onHotkey(draginfo)
	if draginfo.isType("combattrackernextactor") then
		nextActor();
		return true;
	end
	if draginfo.isType("combattrackernextround") then
		nextRound();
		return true;
	end
end

function addPc(source, token)
	local newentry = createWindow();
	
	newentry.setType("pc");
	
	-- Shortcut
	newentry.name.setReadOnly(true);
	newentry.name.setFrame(nil);
	
	newentry.link.setValue("charsheet", source.getNodeName());
	newentry.link.setVisible(true);
	
	-- Token
	if token then
		newentry.token.setPrototype(token);
	end
	
	-- FoF
	newentry.friendfoe.setState("friend");
	
	-- Linked fields
	newentry.name.setLink(source.getChild("name"));
	newentry.hp.setLink(source.getChild("hp.total"));
	newentry.wounds.setLink(source.getChild("hp.wounds"));
	
	newentry.ac.setLink(source.getChild("ac.totals.general"), source.getChild("ac.totals.touch"), source.getChild("ac.totals.flatfooted"));

	newentry.fortitudesave.setLink(source.getChild("saves.fortitude.total"));
	newentry.reflexsave.setLink(source.getChild("saves.reflex.total"));
	newentry.willsave.setLink(source.getChild("saves.will.total"));
	
	return newentry;
end

function addNpc(source)
	local newentry = createWindow();

	newentry.setType("npc");

	-- Name
	if source.getChild("name") then
		newentry.name.setValue(source.getChild("name").getValue());
	end
	
	-- Space/reach
	if source.getChild("spacereach") then
		local spacereachstr = source.getChild("spacereach").getValue();
		local space, reach = string.match(spacereachstr, "(%d+)%D*/?(%d+)%D*");
		if space then
			newentry.space.setValue(space);
			newentry.reach.setValue(reach);
		end
	end
	
	-- Token
	if source.getChild("token") then
		newentry.token.setPrototype(source.getChild("token").getValue());
	end
	
	-- FoF
	if source.getChild("alignment") then
		local alignment = source.getChild("alignment").getValue();
		if string.find(string.lower(alignment), "good", 0, true) then
			newentry.friendfoe.setState("friend");
		elseif string.find(string.lower(alignment), "evil", 0, true) then
			newentry.friendfoe.setState("foe");
		else
			newentry.friendfoe.setState("neutral");
		end
	else
		newentry.friendfoe.setState("neutral");
	end

	-- HP
	if source.getChild("hp") then
		newentry.hp.setValue(source.getChild("hp").getValue());
	end

	-- Defensive properties
	if source.getChild("ac") then newentry.ac.setValue(source.getChild("ac").getValue()) end;
	if source.getChild("fortitudesave") then newentry.fortitudesave.setValue(source.getChild("fortitudesave").getValue()) end;
	if source.getChild("reflexsave") then newentry.reflexsave.setValue(source.getChild("reflexsave").getValue()) end;
	if source.getChild("willsave") then newentry.willsave.setValue(source.getChild("willsave").getValue()) end;

	-- Active properties
	if source.getChild("init") then newentry.init.setValue(source.getChild("init").getValue()) end;
	if source.getChild("speed") then newentry.speed.setValue(source.getChild("speed").getValue()) end;
	if source.getChild("atk") then newentry.atk.setValue(source.getChild("atk").getValue()) end;
	if source.getChild("fullatk") then newentry.fullatk.setValue(source.getChild("fullatk").getValue()) end;
	
	return newentry;
end

function onDrop(x, y, draginfo)
	if draginfo.isType("playercharacter")  then
		local source = draginfo.getDatabaseNode();
		local token = draginfo.getTokenData();

		if source then
			local newentry = addPc(source, token);
		end
		
		return true;
	elseif draginfo.isType("shortcut")  then
		local class, datasource = draginfo.getShortcutData();
		local source = draginfo.getDatabaseNode();

		if source and class == "npc" then
			local newentry = addNpc(source);
			newentry.link.setValue(class, datasource);
			newentry.link.setVisible(true);
		end

		return true;
	end
end

function onSortCompare(w1, w2)
	return w1.initresult.getValue() < w2.initresult.getValue();
end;

function getActiveEntry()
	for k, v in ipairs(getWindows()) do
		if v.isActive() then
			return v;
		end
	end
	
	return nil;
end

function requestActivation(entry)
	for k, v in ipairs(getWindows()) do
		v.setActive(false);
	end
	
	entry.setActive(true);
end

function nextActor()
	local entry = getNextWindow(getActiveEntry());
	if entry then
		requestActivation(entry);
	
		for k, v in ipairs(getWindows()) do
			v.effects.progressEffects(entry);
		end
	else
		nextRound();
	end
end

function nextRound()
	local entry = getNextWindow(nil);
	if entry then
		requestActivation(entry);
		for k, v in ipairs(getWindows()) do
			v.effects.progressEffects(entry);
		end
	end
	
	window.roundcounter.setValue(window.roundcounter.getValue() + 1);
	
	for k, v in ipairs(getWindows()) do
		v.effects.progressEffects(nil);
	end
end