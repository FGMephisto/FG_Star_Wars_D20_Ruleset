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
	local characterroot = DB.findNode("charsheet");

	-- Get the previously updated versions
--	local currentmajor, currentminor = 0, 0;
--	if CampaignRegistry.updateversion then
--		currentmajor = CampaignRegistry.updateversion.major;
--		currentminor = CampaignRegistry.updateversion.minor;
--	end
	
	if characterroot then
		local major, minor = characterroot.getVersion();
		
		if major < 2 then
			for name,charnode in pairs(characterroot.getChildren()) do
				print("Importing character " .. name);
				checkSkills(charnode);
				checkInventory(charnode);
				checkFeats(charnode);
				checkSpecialAbilities(charnode);
				checkWeapons(charnode);
				convertFields(charnode);
			end
		end
		
--		CampaignRegistry.updateversion = { ["major"] = major, ["minor"] = minor };
		characterroot.updateVersion();
	end
end


-- Skill update functions
function checkSkills(charnode)
	-- All legacy nodes found will be added to this list for deletion
	local legacynodelist = {};

	for k, t in pairs(skillimportdata) do
		local slotcount = t.slots or 1;
		
		for s = 1, slotcount do
			local ranknode = nil;
			local miscnode = nil;
			local statenode = nil;
			local sublabelnode = nil;
			
			if t.slots then
				ranknode = charnode.getChild(k .. "ranks" .. s)
				miscnode = charnode.getChild(k .. "misc" .. s);
				statenode = charnode.getChild(k .. "state");
				sublabelnode = charnode.getChild(k .. "name" .. s);

				-- Add total and stat fields to delete list
				if charnode.getChild(k .. "total" .. s) then
					legacynodelist[charnode.getChild(k .. "total" .. s)] = true;
				end
				if charnode.getChild(k .. "stat") then
					legacynodelist[charnode.getChild(k .. "stat")] = true;
				end
			else
				ranknode = charnode.getChild(k .. "ranks");
				miscnode = charnode.getChild(k .. "misc");
				statenode = charnode.getChild(k .. "state");

				-- Add total and stat fields to delete list
				if charnode.getChild(k .. "total") then
					legacynodelist[charnode.getChild(k .. "total")] = true;
				end
				if charnode.getChild(k .. "stat") then
					legacynodelist[charnode.getChild(k .. "stat")] = true;
				end
			end
			
			if ranknode and (not t.skipzeroranks or ranknode.getValue() > 0) and (not t.slots or s == 1 or ranknode.getValue() > 0) then
				-- The skill was found, and is not a secondary entry with no ranks, create entry
				local newnode = charnode.createChild("skilllist").createChild();

				-- Assign label
				newnode.createChild("label", "string").setValue(t.label);
				if t.sublabel then
					newnode.createChild("sublabel", "string").setValue(t.sublabel);
				end
				
				-- Copy data and mark legacy nodes for deletion
				if ranknode then
					-- Convert old state and ranks into state, ranks and half ranks
					local ranks = ranknode.getValue();
					local halfranks = 0;
					
					if statenode and statenode.getValue() ~= 1 then
						-- Cross class skill
						halfranks = 2 * ranks;
						ranks = 0;

						-- Old state 2 means half a rank invested
						if statenode.getValue() == 2 then
							halfranks = halfranks + 1;
						end
					end
				
					newnode.createChild("ranks", "number").setValue(ranks);
					newnode.createChild("halfranks", "number").setValue(halfranks);

					legacynodelist[ranknode] = true;
				end
				if miscnode then
					newnode.createChild("misc", "number").setValue(miscnode.getValue());
					legacynodelist[miscnode] = true;
				end
				if statenode then
					-- If the skill is a class skill, mark it into the first set
					if statenode.getValue() == 1 then
						newnode.createChild("sets", "string").setValue("1");
					else
						newnode.createChild("sets", "string").setValue("");
					end
					
					legacynodelist[statenode] = true;
				end
				if sublabelnode then
					newnode.createChild("sublabel", "string").setValue(sublabelnode.getValue());
					legacynodelist[sublabelnode] = true;
				end
			elseif ranknode then
				-- Mark for delete
				if ranknode then
					legacynodelist[ranknode] = true;
				end
				if miscnode then
					legacynodelist[miscnode] = true;
				end
				if statenode then
					legacynodelist[statenode] = true;
				end
				if sublabelnode then
					legacynodelist[sublabelnode] = true;
				end
			end
		end
	end
	
	-- Clear node list
	for k, n in pairs(legacynodelist) do
		k.delete();
	end
end

-- Data used to import skills from legacy version databases
skillimportdata = {
	appraise = {
			label = "Appraise" 
		},
	balance = {
			label = "Balance" 
		},
	bluff = {
			label = "Bluff" 
		},
	climb = {
			label = "Climb" 
		},
	concentration = {
			label = "Concentration" 
		},
	craft = {
			label = "Craft",
			slots = 2
		},
	decipherscript = {
			label = "Decipher script" 
		},
	diplomacy = {
			label = "Diplomacy" 
		},
	disabledevice = {
			label = "Disable device" 
		},
	disguise = {
			label = "Disguise" 
		},
	escapeartist = {
			label = "Escape artist" 
		},
	forgery = {
			label = "Forgery" 
		},
	gatherinformation = {
			label = "Gather information" 
		},
	handleanimal = {
			label = "Handle animal" 
		},
	heal = {
			label = "Heal" 
		},
	hide = {
			label = "Hide" 
		},
	intimidate = {
			label = "Intimidate" 
		},
	jump = {
			label = "Jump" 
		},
	knowledgearcana = {
			label = "Knowledge",
			sublabel = "arcana",
			skipzeroranks = true
		},
	knowledgeengineering = {
			label = "Knowledge",
			sublabel = "engineering",
			skipzeroranks = true
		},
	knowledgedungeoneering = {
			label = "Knowledge",
			sublabel = "dungeoneering",
			skipzeroranks = true
		},
	knowledgegeography = {
			label = "Knowledge",
			sublabel = "geography",
			skipzeroranks = true
		},
	knowledgehistory = {
			label = "Knowledge",
			sublabel = "history",
			skipzeroranks = true
		},
	knowledgelocal = {
			label = "Knowledge",
			sublabel = "local",
			skipzeroranks = true
		},
	knowledgenature = {
			label = "Knowledge",
			sublabel = "nature",
			skipzeroranks = true
		},
	knowledgenobility = {
			label = "Knowledge",
			sublabel = "nobility",
			skipzeroranks = true
		},
	knowledgereligion = {
			label = "Knowledge",
			sublabel = "religion",
			skipzeroranks = true
		},
	knowledgetheplanes = {
			label = "Knowledge",
			sublabel = "the planes",
			skipzeroranks = true
		},
	listen = {
			label = "Listen" 
		},
	movesilently = {
			label = "Move silently" 
		},
	openlock = {
			label = "Open lock" 
		},
	perform = {
			label = "Perform",
			slots = 2
		},
	profession = {
			label = "Profession",
			slots = 2
		},
	ride = {
			label = "Ride" 
		},
	search = {
			label = "Search" 
		},
	sensemotive = {
			label = "Sense motive" 
		},
	sleightofhand = {
			label = "Sleight of hand" 
		},
	speaklanguage = {
			label = "Speak language" 
		},
	spellcraft = {
			label = "Spellcraft" 
		},
	spot = {
			label = "Spot" 
		},
	survival = {
			label = "Survival" 
		},
	swim = {
			label = "Swim" 
		},
	tumble = {
			label = "Tumble" 
		},
	usemagicdevice = {
			label = "Use magic device" 
		},
	userope = {
			label = "Use rope" 
		}
	}

function checkInventory(charnode)
	local legacytext = charnode.getChild("inventory");
	if legacytext then
		charnode.createChild("inventorylist").createChild().createChild("name", "string").setValue(legacytext.getValue());
		legacytext.delete();

--		local node = charnode.createChild("inventorylist").createChild();
--		if node then
--			local valuenode = node.createChild("name", "string");
--			valuenode.setValue(legacytext.getValue());
--			legacytext.delete();
--		end
	end

	legacytext = charnode.getChild("equippedinventory");
	if legacytext then
		charnode.createChild("inventorylist").createChild().createChild("name", "string").setValue(legacytext.getValue());
		legacytext.delete();
	
--		local node = charnode.createChild("inventorylist").createChild();
--		if node then
--			local valuenode = node.createChild("name", "string");
--			valuenode.setValue(legacytext.getValue());
--			legacytext.delete();
--		end
	end
end

function checkFeats(charnode)
	local legacytext = charnode.getChild("feats");
	if legacytext then
		charnode.createChild("featlist").createChild().createChild("value", "string").setValue(legacytext.getValue());
		legacytext.delete();
	end

	--[[ Legacy data import ]]
--	local legacytext = window.getDatabaseNode().getChild("feats");
--	if legacytext then
--		local w = createWindow();
--		w.value.setValue(legacytext.getValue());
--		legacytext.delete();
--	end
end

function checkSpecialAbilities(charnode)
	local legacytext = charnode.getChild("specialabilities");
	if legacytext then
		charnode.createChild("specialabilitylist").createChild().createChild("value", "string").setValue(legacytext.getValue());
		legacytext.delete();
	end
					
	--[[ Legacy data import ]]
--	local legacytext = window.getDatabaseNode().getChild("specialabilities");
--	if legacytext then
--		local w = createWindow();
--		w.value.setValue(legacytext.getValue());
--		legacytext.delete();
--	end
end

function checkWeapons(charnode)
end

function convertFields(charnode)
	local inputvalues = {};

	-- Store values and delete legacy nodes
	for k, v in pairs(fieldconversions) do
		local source = charnode.getChild(k);
		if source then
			inputvalues[v] = {};
			
			inputvalues[v].sourcetype = source.getType();
			inputvalues[v].sourcevalue = source.getValue();

			source.delete();
		end
	end
	
	-- Enter values into the database
	for k, v in pairs(inputvalues) do
		local target = charnode.createChild(k, v.sourcetype);
		target.setValue(v.sourcevalue);
	end
end

fieldconversions = {
	["strength"] = "abilities.strength.score",
	["strengthdamage"] = "abilities.strength.damage",
	["strengthbonus"] = "abilities.strength.bonus",
	["strengthbonusmodifier"] = "abilities.strength.bonusmodifier",
	["dexterity"] = "abilities.dexterity.score",
	["dexteritydamage"] = "abilities.dexterity.damage",
	["dexteritybonus"] = "abilities.dexterity.bonus",
	["dexteritybonusmodifier"] = "abilities.dexterity.bonusmodifier",
	["constitution"] = "abilities.constitution.score",
	["constitutiondamage"] = "abilities.constitution.damage",
	["constitutionbonus"] = "abilities.constitution.bonus",
	["constitutionbonusmodifier"] = "abilities.constitution.bonusmodifier",
	["intelligence"] = "abilities.intelligence.score",
	["intelligencedamage"] = "abilities.intelligence.damage",
	["intelligencebonus"] = "abilities.intelligence.bonus",
	["intelligencebonusmodifier"] = "abilities.intelligence.bonusmodifier",
	["wisdom"] = "abilities.wisdom.score",
	["wisdomdamage"] = "abilities.wisdom.damage",
	["wisdombonus"] = "abilities.wisdom.bonus",
	["wisdombonusmodifier"] = "abilities.wisdom.bonusmodifier",
	["charisma"] = "abilities.charisma.score",
	["charismadamage"] = "abilities.charisma.damage",
	["charismabonus"] = "abilities.charisma.bonus",
	["charismabonusmodifier"] = "abilities.charisma.bonusmodifier",
	
	["class1"] = "classes.slot1.name",
	["level1"] = "classes.slot1.level",
	["class2"] = "classes.slot2.name",
	["level2"] = "classes.slot2.level",
	["class3"] = "classes.slot3.name",
	["level3"] = "classes.slot3.level",
	
	["hp"] = "hp.total",
	["wounds"] = "hp.wounds",
	["subdual"] = "hp.nonlethal",
	
	["ac"] = "ac.totals.general",
	["acmodifier"] = "ac.sources.temporary",
	["acarmorbonus"] = "ac.sources.armor",
	["acshieldbonus"] = "ac.sources.shield",
	["acsizebonus"] = "ac.sources.size",
	["acnaturalarmorbonus"] = "ac.sources.naturalarmor",
	["acdeflectionbonus"] = "ac.sources.deflection",
	["acmiscbonus"] = "ac.sources.misc",
	["flatfootedac"] = "ac.totals.flatfooted",
	["touchac"] = "ac.totals.touch",
	
	["fortitudesave"] = "saves.fortitude.total",
	["fortitudesavemodifier"] = "saves.fortitude.temporary",
	["fortitudesavebase"] = "saves.fortitude.base",
	["fortitudesavemisc"] = "saves.fortitude.misc",
	["reflexsave"] = "saves.reflex.total",
	["reflexsavemodifier"] = "saves.reflex.temporary",
	["reflexsavebase"] = "saves.reflex.base",
	["reflexsavemisc"] = "saves.reflex.misc",
	["willsave"] = "saves.will.total",
	["willsavemodifier"] = "saves.will.temporary",
	["willsavebase"] = "saves.will.base",
	["willsavemisc"] = "saves.will.misc",
	
	["initiative"] = "initiative.total",
	["initiativemiscbonus"] = "initiative.misc",
	
	["baseattackbonus"] = "attackbonus.base",
	["meleeattackbonus"] = "attackbonus.melee",
	["rangeattackbonus"] = "attackbonus.ranged",
	["grapplebonus"] = "attackbonus.grapple.total",
	["grapplesizebonus"] = "attackbonus.grapple.size",
	["grapplemiscbonus"] = "attackbonus.grapple.misc",
	
	["speed"] = "speed",
	["spellfailure"] = "special.spellfailure",
	["damagereduction"] = "special.damagereduction",
	["spellresistance"] = "special.spellresistance",
	
	["unspentskillpoints"] = "skillpoints.unspent",
	["plannedskillpoints"] = "skillpoints.planned",
	
	["armorcheckpenalty"] = "encumbrance.armorcheckpenalty",
	["encumbranceload"] = "encumbrance.load",
	["encumbrancelightload"] = "encumbrance.lightload",
	["encumbrancemediumload"] = "encumbrance.mediumload",
	["encumbranceheavyload"] = "encumbrance.heavyload",
	["encumbranceliftoverhead"] = "encumbrance.liftoverhead",
	["encumbranceliftoffground"] = "encumbrance.liftoffground",
	["encumbrancepushordrag"] = "encumbrance.pushordrag",
	
	["coinname1"] = "coins.slot1.name",
	["coinamount1"] = "coins.slot1.amount",
	["coinname2"] = "coins.slot2.name",
	["coinamount2"] = "coins.slot2.amount",
	["coinname3"] = "coins.slot3.name",
	["coinamount3"] = "coins.slot3.amount",
	["coinname4"] = "coins.slot4.name",
	["coinamount4"] = "coins.slot4.amount",
	["coinname5"] = "coins.slot5.name",
	["coinamount5"] = "coins.slot5.amount",
	["coinname6"] = "coins.slot6.name",
	["coinamount6"] = "coins.slot6.amount"
}