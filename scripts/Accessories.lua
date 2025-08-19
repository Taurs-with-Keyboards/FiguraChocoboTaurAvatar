-- Required script
local parts = require("lib.PartsAPI")

-- Config setup
config:name("ChocoboTaur")
local saddle = config:load("AccessoriesSaddle") or 1

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
local _type = saddleTypes[saddle]

function events.RENDER(delta, context)
	
	-- State
	local state = saddleTypes[saddle]
	
	-- Apply
	parts.group.Saddles:visible(state.saddle)
	parts.group.Saddlebags:visible(state.bags)
	parts.group.Saddles.Storage:visible(state.storage)
	
	-- Apply textures
	if saddleTypes[saddle].texture then
		parts.group.Saddles:primaryTexture("CUSTOM", state.texture)
	end
	
end

-- Saddle states
function pings.setSaddle(i)
	
	saddle = ((saddle + i - 1) % #saddleTypes) + 1
	config:save("AccessoriesSaddle", saddle)
	
	-- Sounds
	if player:isLoaded() then
		if saddleTypes[saddle].saddle ~= _type.saddle then
			sounds:playSound("entity.horse.saddle", player:getPos(), 0.5)
		end
		if saddleTypes[saddle].bags ~= _type.bags then
			sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
		end
		if saddleTypes[saddle].storage ~= _type.storage then
			sounds:playSound("block.wood.place", player:getPos(), 0.5)
		end
	end
	
	-- Save last saddle
	_type = saddleTypes[saddle]
	
end

-- Sync variables
function pings.syncAccessories(a)
	
	saddle = a
	_type = saddleTypes[saddle]
	
end

-- Host only instructions
if not host:isHost() then return end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncAccessories(saddle)
	end
	
end

-- Required scripts
local s, wheel, itemCheck, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found

-- Check for if page already exists
local pageExists = action_wheel:getPage("Chocobo")

-- Pages
local parentPage  = action_wheel:getPage("Main")
local chocoboPage = pageExists or action_wheel:newPage("Chocobo")

-- Actions table setup
local a = {}

-- Actions
if not pageExists then
	a.pageAct = parentPage:newAction()
		:item(itemCheck("egg"))
		:onLeftClick(function() wheel:descend(chocoboPage) end)
end

a.saddleAct = chocoboPage:newAction()
	:onLeftClick(function() pings.setSaddle(1) end)
	:onRightClick(function() pings.setSaddle(-1) end)
	:onScroll(pings.setSaddle)

-- Saddle context info table
local saddleInfo = {
	{
		title = {label = "No Saddle", text = "You do not have a saddle equiped."},
		item  = "feather"
	},
	{
		title = {label = "Saddle", text = "You have a saddle equiped."},
		item  = "saddle"
	},
	{
		title = {label = "Saddle Bags", text = "You have a saddle with some storage."},
		item  = "bundle"
	},
	{
		title = {label = "Saddle Pack", text = "You have a large saddle pack."},
		item  = "chest"
	},
	{
		title = {label = "Saddle Storage", text = "Doesn\'t your back hurt?"},
		item  = "chest_minecart"
	}
}

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		if a.pageAct then
			a.pageAct
				:title(toJson(
					{text = "Chocobo Settings", bold = true, color = c.primary}
				))
		end
		
		local actionSetup = saddleInfo[saddle]
		a.saddleAct
			:title(toJson(
				{
					"",
					{text = "Saddle\n\n", bold = true, color = c.primary},
					{text = "Scroll or click to set a saddle configuration!\n\n", color = c.secondary},
					{text = "Current configuration: ", bold = true, color = c.secondary},
					{text = actionSetup.title.label},
					{text = " | "},
					{text = actionSetup.title.text, color = c.secondary}
				}
			))
			:item(itemCheck(actionSetup.item))
		
		for _, act in pairs(a) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end