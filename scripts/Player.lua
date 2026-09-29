-- Required scripts
local parts = require("lib.PartsAPI")
local sync  = require("lib.LetThatSyncFig")

-- Parts setup
local chocobo = parts.new(models.ChocoboTaur)

-- Synced variables setup
local skin = sync.new("AvatarVanillaSkin", true):config()
local slim = sync.new("AvatarSlim", false):config()

-- Skull setup
chocobo:deepCopy(chocobo.outliner.Head)
	:moveTo(chocobo.root)
	:parentType("SKULL")
	:pos(-chocobo.outliner.Head:getPivot())

-- Portrait setup
chocobo:deepCopy(chocobo.outliner.Head)
	:moveTo(chocobo.root)
	:parentType("PORTRAIT")
	:pos(-chocobo.outliner.Head:getPivot())

-- Arm parts
local defaultParts = chocobo:createGroup(function(part) return part:getName():find("ArmDefault") end)
local slimParts    = chocobo:createGroup(function(part) return part:getName():find("ArmSlim")    end)

-- Vanilla skin parts
local skinParts = chocobo:createGroup(function(part) return part:getName():find("_[sS]kin") end)

-- Layer parts
local layerTypes = {"HAT", "JACKET", "LEFT_SLEEVE", "RIGHT_SLEEVE", "LEFT_PANTS_LEG", "RIGHT_PANTS_LEG", "CAPE"}
local layerParts = {}
for i = 1, #layerTypes do
	local type = layerTypes[i]
	layerParts[type] = chocobo:createGroup(function(part) return part:getName():find(type) end)
end

-- Apply translucent cull
chocobo:createGroup(function(part) return part:getName():find("_[fF]lat") end):primaryRenderType("TRANSLUCENT_CULL")

-- Determine vanilla player type on init
local vanillaAvatarType
function events.ENTITY_INIT()
	
	vanillaAvatarType = player:getModelType()
	
end

function events.RENDER(delta, context)
	
	-- Model shape
	local slimShape = (skin.curr and vanillaAvatarType == "SLIM") or (slim.curr and not skin.curr)
	defaultParts:visible(not slimShape)
	slimParts:visible(slimShape)
	
	-- Skin textures
	local skinType = skin.curr and "SKIN" or "PRIMARY"
	skinParts:primaryTexture(skinType)
	
	-- Cape textures
	chocobo.outliner.Cape:primaryTexture(skin.curr and "CAPE" or "PRIMARY")
	
	-- Layer toggling
	for layerType, parts in pairs(layerParts) do
		local enabled = player:isSkinLayerVisible(layerType)
		parts:visible(enabled)
	end
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required script
local s, pageNav, acts, colors = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isn't found

-- Pages
local parentPage = action_wheel:getPage("Main")
local playerPage = action_wheel:newPage("Player")

-- Actions
acts.playerPage = parentPage:newAction()
	:item("armor_stand")
	:onLeftClick(function() pageNav.descend(playerPage) end)

acts.playerVanillaToggle = playerPage:newAction()
	:item("player_head{SkullOwner:"..avatar:getEntityName().."}")
	:onToggle(function(bool)
		skin:update(bool)
	end)
	:toggled(skin.curr)

acts.playerModelToggle = playerPage:newAction()
	:item("player_head")
	:toggleItem("player_head{SkullOwner:MHF_Alex}")
	:onToggle(function(bool)
		slim:update(bool)
	end)
	:toggled(slim.curr)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		acts.playerPage
			:title(toJson(
				{text = "Player Settings", bold = true, color = colors.primary}
			))
			:hoverColor(colors.hover)
		
		acts.playerVanillaToggle
			:title(toJson(
				{
					"",
					{text = "Toggle Vanilla Texture\n\n", bold = true, color = colors.primary},
					{text = "Toggles the usage of your vanilla skin.", color = colors.secondary}
				}
			))
			:hoverColor(colors.hover)
			:toggleColor(colors.active)
		
		acts.playerModelToggle
			:title(toJson(
				{
					"",
					{text = "Toggle Model Shape\n\n", bold = true, color = colors.primary},
					{text = "Adjust the model shape to use Default or Slim Proportions.\nWill be overridden by the vanilla skin toggle.", color = colors.secondary}
				}
			))
			:hoverColor(colors.hover)
			:toggleColor(colors.active)
		
	end
	
end