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


-- Chat window registration for general purpose message dispatching
function registerControl(ctrl)
	control = ctrl;
end

function registerEntryControl(ctrl)
	entrycontrol = ctrl;
	ctrl.onSlashCommand = onSlashCommand;
end

-- Generic message delivery
function deliverMessage(msg, recipients)
	if control then
		control.deliverMessage(msg, recipients);
	end
end

function addMessage(msg)
	if control then
		control.addMessage(msg);
	end
end

-- Slash command dispatching
slashhandlers = {};

function registerSlashHandler(command, callback)
	slashhandlers[command] = callback;
end

function unregisterSlashHandler(command, callback)
	slashhandlers[command] = nil;
end

function onSlashCommand(command, parameters)
	for c, h in pairs(slashhandlers) do
		if string.find(string.lower(c), string.lower(command), 1, true) == 1 then
			h(parameters);
			return;
		end
	end
end


-- Aliases
function doAutocomplete()
	local buffer = entrycontrol.getValue();
	local spacepos = string.find(string.reverse(buffer), " ", 1, true);
	
	local search = "";
	local remainder = buffer;
	
	if spacepos then
		search = string.sub(buffer, #buffer - spacepos + 2);
		remainder = string.sub(buffer, 1, #buffer - spacepos + 1);
	else
		search = buffer;
		remainder = "";
	end
	
	-- Check identities
	for k, v in ipairs(User.getAllActiveIdentities()) do
		local label = User.getIdentityLabel(v);
		if label and string.find(string.lower(label), string.lower(search), 1, true) == 1 then
			local replacement = remainder .. label;
			entrycontrol.setValue(replacement);
			entrycontrol.setCursorPosition(#replacement + 1);
			entrycontrol.setSelectionPosition(#replacement + 1);
			return;
		end
	end
end


-- Whispers
function processWhisper(params)
	if User.isHost() then
		local msg = {};
		msg.font = "msgfont";

		local spacepos = string.find(params, " ", 1, true);
		if spacepos then
			local recipient = string.sub(params, 1, spacepos-1);
			local originalrecipient = recipient;
			local message = string.sub(params, spacepos+1);

			-- Find user
			local user = nil;

			for k, v in ipairs(User.getAllActiveIdentities()) do
				local label = User.getIdentityLabel(v);
				if string.lower(label) == string.lower(originalrecipient) then
					-- Direct match
					user = User.getIdentityOwner(v);
					if user then
						recipient = label;
						break;
					end
				elseif not user and string.find(string.lower(label), string.lower(recipient), 1, true) == 1 then
					-- Partial match
					user = User.getIdentityOwner(v);
					if user then
						recipient = label;
					end
				end
			end

			if user then
				msg.text = message;

				msg.sender = "<heard whisper>";
				control.deliverMessage(msg, user);

				msg.sender = "-> " .. recipient;
				control.addMessage(msg);
				
				return;
			end

			msg.font = "systemfont";
			msg.text = "Whisper recipient not found";
			control.addMessage(msg);
			
			return;
		end

		msg.font = "systemfont";
		msg.text = "Usage: /whisper [recipient] [message]";
		control.addMessage(msg);
	else
		local msg = {};
		msg.font = "msgfont";
		msg.text = params;

		msg.sender = User.getIdentityLabel();
		control.deliverMessage(msg, "");

		msg.sender = "<sent whisper>";
		control.addMessage(msg);
	end
end

-- Dice
function getDieRevealFlag()
	if revealalldice then
		return true;
	end
	
	return false;
end

function processDie(params)
	if control then
		if User.isHost() then
			if params == "reveal" then
				revealalldice = true;

				local msg = {};
				msg.font = "systemfont";
				msg.text = "Revealing all die rolls";
				control.addMessage(msg);

				return;
			end
			if params == "hide" then
				revealalldice = false;

				local msg = {};
				msg.font = "systemfont";
				msg.text = "Hiding all die rolls";
				control.addMessage(msg);

				return;
			end
		end
	
		local diestring, descriptionstring = string.match(params, "%s*(%S+)%s*(.*)");
		
		if not diestring then
			local msg = {};
			msg.font = "systemfont";
			msg.text = "Usage: /die [dice] [description]";
			control.addMessage(msg);
			return;
		end
		
		local dice = {};
		local modifier = 0;
		
		for s, m, d in string.gmatch(diestring, "([%+%-]?)(%d*)(%w*)") do
			if m == "" and d == "" then
				break;
			end

			if d ~= "" then
				for i = 1, tonumber(m) or 1 do
					table.insert(dice, d);
					if d == "d100" then
						table.insert(dice, "d10");
					end
				end
			else
				if s == "-" then
					modifier = modifier - m;
				else
					modifier = modifier + m;
				end
			end
		end

		if #dice == 0 then
			local msg = {};
			
			msg.font = "systemfont";
			msg.text = descriptionstring;
			msg.dice = {};
			msg.diemodifier = modifier;
			msg.dicesecret = false;

			if User.isHost() then
				msg.sender = GmIdentityManager.getCurrent();
			else
				msg.sender = User.getIdentityLabel();
			end
		
			deliverMessage(msg);
		else
			control.throwDice("dice", dice, modifier, descriptionstring);
		end
	end
end

-- Initialization
function onInit()
	registerSlashHandler("/whisper", processWhisper);
	registerSlashHandler("/die", processDie);
end
