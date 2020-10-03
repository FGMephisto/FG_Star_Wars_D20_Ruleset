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


sources = {};
ops = {};
hasSources = false;

function sourceUpdate()
	if self.onSourceUpdate then
		self.onSourceUpdate();
	end
end

function calculateSources()
	local n = 0;

	local c = 0;
	for k, v in pairs(ops) do
		if sources[k] then
			if v == "+" then
				n = n + self.onSourceValue(sources[k], k); --sources[k].getValue();
			elseif v == "-" then
				n = n - self.onSourceValue(sources[k], k); --sources[k].getValue();
			elseif v == "*" then
				n = n * self.onSourceValue(sources[k], k); --sources[k].getValue();
			elseif v == "/" then
				n = n / self.onSourceValue(sources[k], k); --sources[k].getValue();
			elseif v == "neg+" then
				if self.onSourceValue(sources[k], k) < 0 then
					n = n + self.onSourceValue(sources[k], k); --sources[k].getValue();
				end
			end
			
			c = c+1;
		end
	end

	return n;
end

function onSourceValue(source, sourcename)
	return source.getValue();
end

function onSourceUpdate(source)
	setValue(calculateSources());
end

function addSource(name)
	local node = window.getDatabaseNode().createChild(name, "number");
	if node then
		sources[name] = node;
		node.onUpdate = sourceUpdate;
		hasSources = true;
	end
end

function addSourceWithOp(name, op)
	addSource(name);
	ops[name] = op;
end

function onInit()
	if source and type(source[1]) == "table" then
		for k, v in ipairs(source) do
			if v.name and type(v.name) == "table" then
				addSource(v.name[1]);
				
				if (v.op) then
					ops[v.name[1]] = v.op[1];
				end
			end
		end
	end

	if hasSources then
		sourceUpdate();
	end
end
