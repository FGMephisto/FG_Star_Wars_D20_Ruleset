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
	Interface.onWindowOpened = onWindowOpened;
	Interface.onWindowClosed = onWindowClosed;
end

function onWindowOpened(window)
	local sourcename = "";
	if window.getDatabaseNode() then
		sourcename = window.getDatabaseNode().getNodeName();
	end

	if CampaignRegistry.windowpositions then
		if CampaignRegistry.windowpositions[window.getClass()] then
			if CampaignRegistry.windowpositions[window.getClass()][sourcename] then
				local pos = CampaignRegistry.windowpositions[window.getClass()][sourcename];
				
				window.setPosition(pos.x, pos.y);
				window.setSize(pos.w, pos.h);
			end
		end
	end
end

function onWindowClosed(window)
	if not CampaignRegistry.windowpositions then
		CampaignRegistry.windowpositions = {};
	end
	
	if not CampaignRegistry.windowpositions[window.getClass()] then
		CampaignRegistry.windowpositions[window.getClass()] = {};
	end
	
	-- Get window data source node name
	local sourcename = "";
	if window.getDatabaseNode() then
		sourcename = window.getDatabaseNode().getNodeName();
	end
	
	-- Get window positioning data
	local x, y = window.getPosition();
	local w, h = window.getSize();
	
	-- Store positioning data
	local pos = {};
	pos.x = x;
	pos.y = y;
	pos.w = w;
	pos.h = h;
	
	CampaignRegistry.windowpositions[window.getClass()][sourcename] = pos;
end
