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


function findControlForIdentity(identity)
	return self["ctrl_" .. identity];
end

function controlSortCmp(t1, t2)
	return t1.name < t2.name;
end

function layoutControls()
	local identitylist = {};
	
	for key, val in pairs(User.getAllActiveIdentities()) do
		table.insert(identitylist, { name = val, control = findControlForIdentity(val) });
	end
	
	table.sort(identitylist, controlSortCmp);

	local n = 0;
	for key, val in pairs(identitylist) do
		val.control.sendToBack();
	end
	
	anchor.sendToBack();
end

function onLogin(username, activated)
end

function onUserStateChange(username, statename, state)
	if username ~= "" and User.getCurrentIdentity(username) then
		local ctrl = findControlForIdentity(User.getCurrentIdentity(username));
		if ctrl then
			ctrl.stateChange(statename, state);
		end
	end
end

function onIdentityActivation(identity, username, activated)
	if activated then
		do
			if not findControlForIdentity(identity) then
				createControl("characterlist_entry", "ctrl_" .. identity);
				
				userctrl = findControlForIdentity(identity);
				userctrl.createWidgets(identity);
				
				layoutControls();
			end
		end
	else
		findControlForIdentity(identity).destroy();
		layoutControls();
	end
end

function onIdentityStateChange(identity, username, statename, state)
	local ctrl = findControlForIdentity(identity);
	if ctrl then
		ctrl.stateChange(statename, state);
	end
end

function onInit()
	User.onLogin = onLogin;
	User.onUserStateChange = onUserStateChange;
	User.onIdentityActivation = onIdentityActivation;
	User.onIdentityStateChange = onIdentityStateChange;
end
