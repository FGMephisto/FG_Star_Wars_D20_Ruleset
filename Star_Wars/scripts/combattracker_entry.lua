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


-- Section visibility handling

forceactive = false;
forcedefensive = false;
forceeffects = false;
defensiveon = false;
activeon = false;
effectson = false;

charactertype = nil;

function setSpacerState()
	if defensiveon or activeon or effectson then
		spacer.setVisible(true);
	else
		spacer.setVisible(false);
	end
end

function setDefensiveVisible(status)
	if forcedefensive then
		status = true;
	end
	if not targeting.isEmpty() then
		status = true;
	end
	
	defensiveon = status;

	ac.setVisible(status);
	aclabel.setVisible(status);
	fortitudesave.setVisible(status);
	fortitudesavelabel.setVisible(status);
	reflexsave.setVisible(status);
	reflexsavelabel.setVisible(status);
	willsave.setVisible(status);
	willsavelabel.setVisible(status);
	targeting.setVisible(status);
	defensiveicon.setVisible(status);
	
	setSpacerState();
end
	
function setActiveVisible(status)
	if forceactive then
		status = true;
	end
	if active.getState() then
		status = true;
	end
	
	activeon = status;

	speed.setVisible(status);
	speedlabel.setVisible(status);
	init.setVisible(status);
	initlabel.setVisible(status);
	atk.setVisible(status);
	atklabel.setVisible(status);
	fullatk.setVisible(status);
	fullatklabel.setVisible(status);
	activeicon.setVisible(status);
	
	setSpacerState();
end

function setEffectsVisible(status)
	if forceeffects then
		status = true;
	end
	
	effectson = status;
	
	effecticon.setVisible(status);
	effects.setVisible(status);
	
	setSpacerState();
end

function toggleForceEffects()
	forceeffects = not forceeffects;
	
	if forceeffects then
		activateeffects.setColor("ffffffff");
	else
		activateeffects.setColor("7fffffff");
	end
end

function toggleForceActive()
	forceactive = not forceactive;
	
	if forceactive then
		activateactive.setColor("ffffffff");
	else
		activateactive.setColor("7fffffff");
	end
end

function toggleForceDefensive()
	forcedefensive = not forcedefensive;
	
	if forcedefensive then
		activatedefensive.setColor("ffffffff");
	else
		activatedefensive.setColor("7fffffff");
	end
end

-- FoF State

function getFoF()
	return friendorfoe;
end

function setFoF(state)
	friendorfoe = state;
	token.updateUnderlay();
end

-- Activity state

function isActive()
	return active.getState();
end

function setActive(state)
	active.setState(state);
	
	if state and charactertype == "pc" then
		-- Turn notification
		local msg = {};
		msg.text = name.getValue();
		msg.font = "narratorfont";
		msg.icon = "indicator_flag";
		
		ChatManager.deliverMessage(msg);
		
		local usernode = link.getTargetDatabaseNode()
		if usernode then
			User.ringBell(usernode.getName());
		end
	end
end

-- Observers to support effects linked here

observers = {};

function addObserver(o)
	table.insert(observers, o);
end

function removeObserver(o)
	for i = 1, #observers do
		if observers[i] == o then
			table.remove(observers, i);
			break;
		end
	end
end



function onInit()
	setDefensiveVisible(false);
	setActiveVisible(false);
	setEffectsVisible(false);
end

function onClose()
	for k, v in ipairs(observers) do
		v.observedClosed(self);
	end
end

function nameChanged()
	for k, v in ipairs(observers) do
		v.observedNameChanged(self);
	end
end

function setType(t)
	charactertype = t;
end

function getType()
	return charactertype;
end

function store()
	local entry = {};

	-- Name, type and link target
	entry.name = name.getValue();
	entry.type = charactertype;
	
	if link.getTargetDatabaseNode() then
		entry.dbnode = link.getTargetDatabaseNode().getNodeName();
	end

	-- Token and token instance
	entry.token = token.getPrototype();

	if token.ref and token.ref.getContainerNode() then
		entry.tokenrefnode = token.ref.getContainerNode().getNodeName();
		entry.tokenrefid = token.ref.getId();
	end
	
	-- FoF
	entry.fof = getFoF();

	-- Value fields
	if charactertype ~= "pc" then
		entry.hp = hp.getValue();
		entry.wounds = wounds.getValue();
	end

	entry.initresult = initresult.getValue();
	entry.space = space.getValue();
	entry.reach = reach.getValue();
	entry.ac = ac.getValue();
	entry.fortitudesave = fortitudesave.getValue();
	entry.reflexsave = reflexsave.getValue();
	entry.willsave = willsave.getValue();
	entry.speed = speed.getValue();
	entry.init = init.getValue();
	entry.atk = atk.getValue();
	entry.fullatk = fullatk.getValue();

	return entry;
end

function storeEffects(entry, idmap)
	-- effects
	local e = {};
	for k, v in ipairs(effects.getWindows()) do
		local effect = {};
		effect.label = v.label.getValue();
		effect.duration = v.duration.getValue();
		effect.adjustment = v.adjustment.getValue();
		if v.caster.sourceentry then
			effect.sourceid = idmap[v.caster.sourceentry];
		end
		
		table.insert(e, effect);
	end
	
	entry.effects = e;
end	

function restore(entry)
	-- Name, type and linking
	name.setValue(entry.name);

	local targetnode = nil;
	if entry.dbnode then
		targetnode = DB.findNode(entry.dbnode);
	end
	
	if entry.type == "pc" and targetnode then
		charactertype = "pc";
		link.setValue("charsheet", entry.dbnode);
		link.setVisible(true);

		name.setReadOnly(true);
		name.setFrame(nil);
		
		-- Links to data
		name.setLink(targetnode.getChild("name"));
		hp.setLink(targetnode.getChild("hp.total"));
		wounds.setLink(targetnode.getChild("hp.wounds"));
		
		ac.setLink(targetnode.getChild("ac.totals.general"), targetnode.getChild("ac.totals.touch"), targetnode.getChild("ac.totals.flatfooted"));

		fortitudesave.setLink(targetnode.getChild("saves.fortitude.total"));
		reflexsave.setLink(targetnode.getChild("saves.reflex.total"));
		willsave.setLink(targetnode.getChild("saves.will.total"));
	else
		if entry.type == "npc" and targetnode then
			charactertype = "npc";
			link.setValue("npc", entry.dbnode);
			link.setVisible(true);
		end
		
		-- HP, wounds
		hp.setValue(entry.hp);
		wounds.setValue(entry.wounds);
	end
	
	-- Token
	if entry.tokenrefnode and entry.tokenrefid then
		token.acquireReference(token.populateFromImageNode(entry.tokenrefnode, entry.tokenrefid));
	elseif entry.token then
		token.setPrototype(entry.token);
	end
	
	-- FoF
	friendfoe.setState(entry.fof);
	
	-- Value fields
	initresult.setValue(entry.initresult);
	space.setValue(entry.space);
	reach.setValue(entry.reach);
	ac.setValue(entry.ac);
	fortitudesave.setValue(entry.fortitudesave);
	reflexsave.setValue(entry.reflexsave);
	willsave.setValue(entry.willsave);
	speed.setValue(entry.speed);
	init.setValue(entry.init);
	atk.setValue(entry.atk);
	fullatk.setValue(entry.fullatk);
	
	token.updateUnderlay();
end

function restoreEffects(entry, idmap)
	effects.clearAndDisableCheck();

	if entry.effects then
		for k,v in ipairs(entry.effects) do
			local win = effects.createWindow();
			win.label.setValue(v.label);
			win.duration.setValue(v.duration);
			win.adjustment.setValue(v.adjustment);
			win.caster.setSource(idmap[v.sourceid]);
		end
	end
	
	effects.enableCheck();
end