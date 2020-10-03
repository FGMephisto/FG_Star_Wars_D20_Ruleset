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


function getLevel()
	return tonumber(string.sub(getDatabaseNode().getChild("...").getName(), 6));
end

function getCast()
	return castnode.getValue();
end

function getPrepared()
	if isSpontaneous() then
		return nil;
	end

	return preparednode.getValue();
end

function preparedChanged()
	windowlist.updateCounters();
end

function castChanged()
	windowlist.updateCounters();
end

function isSpontaneous()
	return spontaneitynode.getValue() ~= 0;
end

function onInit()
	preparednode = getDatabaseNode().createChild("prepared", "number");
	castnode = getDatabaseNode().createChild("cast", "number");

	preparednode.onUpdate = preparedChanged;
	castnode.onUpdate = castChanged;

	spontaneitynode = getDatabaseNode().createChild(".....spontaneous", "number");
	
	counter.updateSlots();
end