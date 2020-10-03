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


function parseComponents()
	-- Break the string in the control into attacks, and record their respective positions
	str = getValue();

	damages = {};
	attacks = {};
	attackcombinations = {};
	
	local currentcombination = {};
	
	starts = true;
	nextindex = 1;
	attackindex = 1;
	
	while starts and nextindex < #str do
		-- Find component parts: count, label, modifier, attack type, damage and combinatory word
--		starts, ends, all, pcount, plabel, pmodifier, patktype, dmgstart, pdamage, dmgend, combination = string.find(str, '((%d*) ?([%w%s]*) ([%+%-]?%d*) (%w*) %(()([^%)]*)()%) ?(%w*))%s*', nextindex);
		starts, ends, all, pcount, plabel, pmodifier, patktype, dmgstart, pdamage, dmgend, combination = string.find(str, '((%+?%d*) ?([%w%s,]*) ([%+%-%d/]*) (%w*%s?%w*) ?%(()([^%)]*)()%) ?(%w*))%s*', nextindex);
		
		if not starts then
			return {};
		end
		
		if #pcount < 1 then
			pcount = 1;
		end
		
		-- Magical weapons
		if string.sub(pcount, 1, 1) == "+" then
			plabel = pcount .. " " .. plabel;
			pcount = 1;
		end
		
		-- Capitalize first letter of label
		plabel = string.upper(string.sub(plabel, 1, 1)) .. string.sub(plabel, 2);

		-- Add component to list
		if starts then
			nextindex = ends+1;
			
			table.insert(damages, { startpos = dmgstart, endpos = dmgend, damage = pdamage, label = plabel .. " damage" });
			table.insert(attacks, { startpos = starts, endpos = dmgend+1, label = plabel, modifier = pmodifier, count = pcount });
			table.insert(currentcombination, attackindex);
			
--			window.print("damage: " .. dmgstart .. "," .. dmgend .. ":" .. pdamage);
--			window.print("attack[" .. attackindex .. "]: " .. starts .. "," .. (starts+#all) .. "," .. plabel .. "," .. pmodifier .. "," .. pcount);
			
			if string.lower(combination) ~= "and" then
				-- Finish combination
				table.insert(attackcombinations, currentcombination);
				currentcombination = {};
			end
		end
		
		attackindex = attackindex + 1;
	end

	return components;
end

function onHover(oncontrol)
	if hasFocus() or dragging then
		return;
	end

	-- Reset selection when the cursor leaves the control
	if not oncontrol then
		hoverDamage = nil;
		hoverAttackCombo = nil;
		
		setCursorPosition(0);
	end
end

function onHoverUpdate(x, y)
	hoverx, hovery = x, y;

	if hasFocus() or dragging then
		return;
	end

	-- Hilight skill hovered on
	components = parseComponents();
	local index = getIndexAt(x, y);

	hoverDamage = nil;
	hoverAttackCombo = nil;
	
	for i = 1, #damages do
		if damages[i].startpos < index and damages[i].endpos > index then
			setCursorPosition(damages[i].startpos);
			setSelectionPosition(damages[i].endpos);

			hoverDamage = i;			
			
			setHoverCursor("hand");
			
			return;
		end
	end
	
	if Input.isControlPressed() then
		for i = 1, #attacks do
			if attacks[i].startpos < index and attacks[i].endpos > index then
				setCursorPosition(damages[i].startpos);
				setSelectionPosition(damages[i].endpos);
	
				hoverDamage = i;			
				
				setHoverCursor("hand");
				
				return;
			end
		end
	end
	
	for i = 1, #attackcombinations do
		local firstattack = attackcombinations[i][1];
		local lastattack = attackcombinations[i][#(attackcombinations[i])];
		
		if attacks[firstattack].startpos < index and attacks[lastattack].endpos > index then
			setCursorPosition(attacks[firstattack].startpos);
			setSelectionPosition(attacks[lastattack].endpos);

			hoverAttackCombo = i;
			
			setHoverCursor("hand");
			
			return;
		end
	end
	
	setHoverCursor("arrow");
	
	setCursorPosition(0);
end

function onDrag(button, x, y, draginfo)
	if dragging then
		return true;
	end

	if clickDamage then
		local str = damages[clickDamage].damage;
		local starts = true;
		local nextindex = 1;
		
		local modifier = 0;
		local dice = {};
		
		while starts and nextindex < #str do
			if string.sub(str, nextindex, nextindex) == "/" then
				-- End at critical range declaration start
				break;
			end
			
			starts, ends, sign, count, die, remainder = string.find(str, "([+-]?)(%d*)(%w*)([^+-/]*)", nextindex);

			local signmultiplier = 1;
			if sign == "-" then
				signmultiplier = -1;
			end
			
			if #die == 0 then
				modifier = modifier + signmultiplier * count;
			else
				local diecount = tonumber(count) or 1;
				for c = 1, diecount do
					table.insert(dice, die);
				end
			end

			nextindex = ends+1;
		end
		
		draginfo.setType("dice");
		
		draginfo.setDescription(damages[clickDamage].label);
		draginfo.setDieList(dice);
		draginfo.setNumberData(modifier);
		
		clickDamage = nil;
		dragging = true;
		return true;
	end

	if clickAttackCombo then
		draginfo.setType("fullattack");

		local firstattack = attackcombinations[clickAttackCombo][1];
		local lastattack = attackcombinations[clickAttackCombo][#(attackcombinations[clickAttackCombo])];
		local a = 1;
		
		for i = firstattack, lastattack do
			local attack = attacks[i];

			-- Break modifier into attacks
			local modifiers = {}
			for w in string.gmatch(attack.modifier, "([%+%-]?%d+)/?") do
				table.insert(modifiers, w);
			end
			
			for j = 1, attack.count do
				for k = 1, #modifiers do
					draginfo.setDieList({ "d20" });
					draginfo.setNumberData(modifiers[k]);
					
					if #modifiers <= 1 then
						draginfo.setStringData(attack.label);
					else
						draginfo.setStringData(attack.label .. " (attack " .. k .. ")");
					end

					a = a + 1;
					draginfo.setSlot(a);
				end
			end
		end
		
		clickAttackCombo = nil;
		dragging = true;
		return true;
	end

	return true;
end

function onDragEnd(dragdata)
	setCursorPosition(0);
	dragging = false;
end

function onClickDown(button, x, y)
	-- Suppress default processing to support dragging
	clickDamage = hoverDamage;
	clickAttackCombo = hoverAttackCombo;
	
	return true;
end

function onClickRelease(button, x, y)
	-- Enable edit mode on mouse release
	setFocus();
	
	local n = getIndexAt(x, y);
	
	setSelectionPosition(n);
	setCursorPosition(n);
	
	return true;
end

function onControl(pressed)
	if hoverAttackCombo or hoverDamage then
		onHoverUpdate(hoverx, hovery);
	end
end

function onInit()
	if super and super.onInit then
		super.onInit();
	end
	
	Input.onControl = onControl;
end