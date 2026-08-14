-- Required scripts
local parts = require("lib.PartsAPI")
local sync  = require("lib.LetThatSyncFig")

-- Synced variables setup
local saddleType = sync.new("AccessoriesSaddle", 1):config()

local saddleTypes = {
	-- Nothing
	{
		saddle = false, bags = false, storage = false,
	},
	-- Saddle
	{
		saddle = true, bags = false, storage = false,
		texture = textures["textures.misc.saddle"] or textures["ChocoboTaur.saddle"]
	},
	-- Saddle (with bags)
	{
		saddle = true, bags = true, storage = false,
		texture = textures["textures.misc.saddle_bag"] or textures["ChocoboTaur.saddle_bag"]
	},
	-- Storage
	{
		saddle = true, bags = false, storage = true,
		texture = textures["textures.misc.pack_bag"] or textures["ChocoboTaur.pack_bag"]
	},
	-- Storage (with bags)
	{
		saddle = true, bags = true, storage = true,
		texture = textures["textures.misc.pack_bag"] or textures["ChocoboTaur.pack_bag"]
	}
}

-- Variable
local _type = saddleTypes[saddleType.curr]

function events.RENDER(delta, context)
	
	-- State
	local state = saddleTypes[saddleType.curr]
	
	-- Apply
	parts.group.Saddles:visible(state.saddle)
	parts.group.Saddlebags:visible(state.bags)
	parts.group.Saddles.Storage:visible(state.storage)
	
	-- Apply textures
	if saddleTypes[saddleType.curr].texture then
		parts.group.Saddles:primaryTexture("CUSTOM", state.texture)
	end
	
end

-- Play sound if adjusting saddle
local function saddleSound()
	
	-- Sounds
	if player:isLoaded() then
		if saddleTypes[saddleType.curr].saddle ~= _type.saddle then
			sounds:playSound("entity.horse.saddle", player:getPos(), 0.5)
		end
		if saddleTypes[saddleType.curr].bags ~= _type.bags then
			sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
		end
		if saddleTypes[saddleType.curr].storage ~= _type.storage then
			sounds:playSound("block.wood.place", player:getPos(), 0.5)
		end
	end
	
	-- Save last saddle
	_type = saddleTypes[saddleType.curr]
	
end

-- Apply sound to sync updates
saddleType:addFunc(saddleSound)

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local s, pageNav, acts, colors = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found

-- Check for if page already exists
local pageExists = action_wheel:getPage("Chocobo")

-- Pages
local parentPage  = action_wheel:getPage("Main")
local chocoboPage = pageExists or action_wheel:newPage("Chocobo")

-- Actions
if not pageExists then
	acts.chocoboPage = parentPage:newAction()
		:item("chococraft:chocobo_feather", "feather")
		:onLeftClick(function() pageNav.descend(chocoboPage) end)
end

-- Set saddle
local function setSaddle(i)
	return ((saddleType.curr + i - 1) % #saddleTypes) + 1
end

acts.accessoriesSaddle = chocoboPage:newAction()
	:onLeftClick(function() saddleType:update(setSaddle(1)) end)
	:onRightClick(function() saddleType:update(setSaddle(-1)) end)
	:onScroll(function(x) saddleType:update(setSaddle(x), 20) end)

-- Saddle context info table
local saddleInfo = {
	{
		title = {label = "No Saddle", text = "You do not have a saddle equiped."},
		item  = {"chococraft:chocobo_feather", "feather"}
	},
	{
		title = {label = "Saddle", text = "You have a saddle equiped."},
		item  = {"chococraft:chocobo_saddle", "saddle"}
	},
	{
		title = {label = "Saddle Bags", text = "You have a saddle with some storage."},
		item  = {"chococraft:chocobo_saddle_bags", "bundle"}
	},
	{
		title = {label = "Saddle Pack", text = "You have a large saddle pack."},
		item  = {"chococraft:chocobo_saddle_pack", "chest"}
	},
	{
		title = {label = "Saddle Storage", text = "Doesn\'t your back hurt?"},
		item  = {"chococraft:chocobo_saddle_pack", "chest_minecart"}
	}
}

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		if acts.chocoboPage then
			acts.chocoboPage
				:title(toJson(
					{text = "Chocobo Settings", bold = true, color = colors.primary}
				))
				:hoverColor(colors.hover)
		end
		
		local actionSetup = saddleInfo[saddleType.curr]
		acts.accessoriesSaddle
			:title(toJson(
				{
					"",
					{text = "Saddle\n\n", bold = true, color = colors.primary},
					{text = "Scroll or click to set a saddle configuration!\n\n", color = colors.secondary},
					{text = "Current configuration: ", bold = true, color = colors.secondary},
					{text = actionSetup.title.label},
					{text = " | "},
					{text = actionSetup.title.text, color = colors.secondary}
				}
			))
			:item(table.unpack(actionSetup.item))
			:hoverColor(colors.hover)
			:toggleColor(colors.active)
		
	end
	
end