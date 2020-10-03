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


sheets = {};
connections = {};

function addConnection(parent, child, source, target)
	local list = connections[parent];
	if not list then
		list = {};
		connections[parent] = list;
	end
	
	for i = 1, #list do
		if list[i].target == child then
			return;
		end
	end
	
	local connectioninfo = {};
	connectioninfo.target = child;
	connectioninfo.sourceindex = source;
	connectioninfo.targetindex = target;
	
	table.insert(list, connectioninfo);
end

function removeConnectionsTo(window)
	for k, v in pairs(connections) do
		for i = 1, #v do
			if v[i].target == window then
				table.remove(v, i);
				break;
			end
		end
	end
end

function isConnectedTo(parent, child)
	local list = connections[parent];
	if not list then
		return false;
	end
	
	for i = 1, #list do
		if list[i].target == child then
			return true;
		end
	end
	
	return false;
end

function calculateCorners(window)
	-- Calculate corner points
	local corners = {};
	
	local x, y = window.getPosition();
	local w, h = window.getSize();
	
	corners[1] = {};
	corners[2] = {};
	corners[3] = {};
	corners[4] = {};

	corners[1].x = x;
	corners[1].y = y;
	corners[2].x = x+w;
	corners[2].y = y;
	corners[3].x = x;
	corners[3].y = y+h;
	corners[4].x = x+w;
	corners[4].y = y+h;
	
	return corners;
end

function getClosestCorner(c1, c2)
	-- Loop through all corner combinations, preserving the closest
	local distance, source, target;
	
	for si = 1,4 do
		for ti = 1,4 do
			local dx = c1[si].x - c2[ti].x;
			local dy = c1[si].y - c2[ti].y;
			local d = math.sqrt(dx*dx + dy*dy);
			
			if not distance or d < distance then
				distance = d;
				source = si;
				target = ti;
			end
		end
	end
	
	return distance, source, target;
end

function getConnectedPosition(parentwindow, childwindow, source, target)
	local tx, ty = parentwindow.getPosition();
	local tw, th = parentwindow.getSize();
	local sw, sh = childwindow.getSize();
	
	local nx, ny;

	if source == 3 and target == 1 then
		nx = tx;
		ny = ty - sh;
	end

	if source == 4 and target == 2 then
		nx = tx + tw - sw;
		ny = ty - sh;
	end

	if source == 1 and target == 2 then
		nx = tx + tw;
		ny = ty;
	end

	if source == 3 and target == 4 then
		nx = tx + tw;
		ny = ty + th - sh;
	end

	if source == 2 and target == 4 then
		nx = tx + tw - sw;
		ny = ty + th;
	end

	if source == 1 and target == 3 then
		nx = tx;
		ny = ty + th;
	end

	if source == 4 and target == 3 then
		nx = tx - sw;
		ny = ty + th - sh;
	end

	if source == 2 and target == 1 then
		nx = tx - sw;
		ny = ty;
	end
	
	return nx, ny;
end

function moveConnected(window)
	local childlist = connections[window];
	if childlist then
		for i = 1, #childlist do
			local nx, ny = getConnectedPosition(window, childlist[i].target, childlist[i].sourceindex, childlist[i].targetindex);
			childlist[i].target.setPosition(nx, ny);
		end
	end
end

function onMove(window)
	local corners = calculateCorners(window);

	-- Check snap
	local snapped = false;
	for i = 1, #sheets do
		if sheets[i] ~= window and not isConnectedTo(window, sheets[i]) then
			local targetcorners = calculateCorners(sheets[i]);
			local distance, source, target = getClosestCorner(corners, targetcorners);
			
			if distance <= 15 then
				if source == 3 and target == 1 or
				   source == 4 and target == 2 or
				   source == 1 and target == 2 or
				   source == 3 and target == 4 or
				   source == 2 and target == 4 or
				   source == 1 and target == 3 or
				   source == 4 and target == 3 or
				   source == 2 and target == 1 then
					addConnection(sheets[i], window, source, target);
					
					local nx, ny = getConnectedPosition(sheets[i], window, source, target);
					window.setPosition(nx, ny);
					
					snapped = true;
				end
			end
		end
	end
	
	if not snapped then
		removeConnectionsTo(window);
	end
	
	-- Move connected
	moveConnected(window);
end

function registerSheet(window)
	table.insert(sheets, window);
	
	-- Register move handler
	window.onMove = onMove;
	window.onSizeChanged = onMove;
end

function unregisterSheet(window)
	-- Unregister move handler
	window.onMove = function() end;
	window.onSizeChanged = function() end;

	for i = 1, #sheets do
		if sheets[i] == window then
			table.remove(sheets, i);
			i = i - 1;
		end
	end
end

