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


function getClosestSnapPoint(x, y)
	local size = getGridSize();
	local ox, oy = getGridOffset();
	
	local centerx = math.floor((x - ox)/size)*size + size/2 + ox + 1;
	local centery = math.floor((y - oy)/size)*size + size/2 + oy + 1;
	
	local centerxdist = x - centerx;
	local centerydist = y - centery;

	local cornerx = math.floor((x - ox + size/2)/size)*size + ox + 1;
	local cornery = math.floor((y - oy + size/2)/size)*size + oy + 1;
	
	local cornerxdist = x - cornerx;
	local cornerydist = y - cornery;

	local cornerlimit = size / 4;
	
	if math.abs(cornerxdist) <=cornerlimit and math.abs(cornerydist) <=cornerlimit and 
	   centerxdist*centerxdist+centerydist*centerydist > cornerxdist*cornerxdist+cornerydist*cornerydist then
		return cornerx, cornery;
	else
		return centerx, centery;
	end
end

function onTokenSnap(token, x, y)
	if hasGrid() then
		return getClosestSnapPoint(x, y);
	else
		return x, y;
	end
end

function onPointerSnap(startx, starty, endx, endy, type)
	local newstartx = startx;
	local newstarty = starty;
	local newendx = endx;
	local newendy = endy;

	if hasGrid() then
		newstartx, newstarty = getClosestSnapPoint(startx, starty);
		newendx, newendy = getClosestSnapPoint(endx, endy);
	end

	return newstartx, newstarty, newendx, newendy;
end

function onMeasureVector(token, vector)
	if hasGrid() then
		local diagonals = 0;
		local straights = 0;
		local gridsize = getGridSize();
	
		for i = 1, #vector do
			local gx = math.abs(math.floor(vector[i].x / gridsize));
			local gy = math.abs(math.floor(vector[i].y / gridsize));
			
			if gx > gy then
				diagonals = diagonals + gy;
				straights = straights + gx - gy;
			else
				diagonals = diagonals + gx;
				straights = straights + gy - gx;
			end
		end
		
		local squares = math.floor(diagonals * 1.5) + straights;
		local feet = squares * 5;
		
		return feet .. "\'";
	else
		return "";
	end
end

function onMeasurePointer(length)
	if hasGrid() then
		return math.floor(length / getGridSize() * 5) .. "\'";
	else
		return "";
	end
end
