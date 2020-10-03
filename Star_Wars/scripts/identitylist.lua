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


identitycontrols = {};

function setCurrent(name)
	local idctrl = identitycontrols[name];

	if idctrl then	
		-- Deactivate all identities
		for k, v in pairs(identitycontrols) do
			v.setCurrent(false);
		end

		-- Set active	
		idctrl.setCurrent(true);
	end
end

function addIdentity(name, isgm)
	local idctrl = identitycontrols[name];
	
	-- Create control if not found
	if not idctrl then
		createControl("identitylist_entry", "ctrl_" .. name);

		idctrl = self["ctrl_" .. name];
		identitycontrols[name] = idctrl;
		
		idctrl.createLabel(name, isgm);
	end
end

function removeIdentity(name)
	local idctrl = identitycontrols[name];

	if idctrl then
		idctrl.destroy();
		identitycontrols[name] = nil;
	end	
end

function renameGmIdentity(name)
	for k,v in pairs(identitycontrols) do
		if v.gmidentity then
			v.rename(name);
			
			identitycontrols[name] = v;
			identitycontrols[k] = nil;
			
			return;
		end
	end
end

function onInit()
	GmIdentityManager.registerIdentityList(self);
end
