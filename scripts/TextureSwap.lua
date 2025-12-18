-- Required scripts
local parts   = require("lib.PartsAPI")
local sync    = require("lib.LetThatSyncFig")
local origins = require("lib.OriginsAPI")

-- All colors
local texs = {
	
	yellow = {
		tex   = textures["textures.yellowchocobo"] or textures["ChocoboTaur.yellowchocobo"],
		color = vectors.hexToRGB("F5F372")
	},
	green = {
		tex   = textures["textures.greenchocobo"] or textures["ChocoboTaur.greenchocobo"],
		color = vectors.hexToRGB("45C04B")
	},
	blue = {
		tex   = textures["textures.bluechocobo"] or textures["ChocoboTaur.bluechocobo"],
		color = vectors.hexToRGB("5696F3")
	},
	white = {
		tex   = textures["textures.whitechocobo"] or textures["ChocoboTaur.whitechocobo"],
		color = vectors.hexToRGB("C4C4BE")
	},
	black = {
		tex   = textures["textures.blackchocobo"] or textures["ChocoboTaur.blackchocobo"],
		color = vectors.hexToRGB("495254")
	},
	gold = {
		tex   = textures["textures.goldchocobo"] or textures["ChocoboTaur.goldchocobo"],
		color = vectors.hexToRGB("CAA028")
	},
	pink = {
		tex   = textures["textures.pinkchocobo"] or textures["ChocoboTaur.pinkchocobo"],
		color = vectors.hexToRGB("E298AE")
	},
	red = {
		tex   = textures["textures.redchocobo"] or textures["ChocoboTaur.redchocobo"],
		color = vectors.hexToRGB("DD464A")
	},
	purple = {
		tex   = textures["textures.purplechocobo"] or textures["ChocoboTaur.purplechocobo"],
		color = vectors.hexToRGB("AA5CF5")
	},
	flame = {
		tex   = textures["textures.flamechocobo"] or textures["ChocoboTaur.flamechocobo"],
		color = vectors.hexToRGB("954040")
	}
	
}

-- Color order
local texMap = {
	"yellow",
	"green",
	"blue",
	"white",
	"black",
	"gold",
	"pink",
	"red",
	"purple",
	"flame"
}

-- Remove missing colors/textures
for i = #texMap, 1, -1 do
	if not texs[texMap[i]] or not texs[texMap[i]].tex then
		table.remove(texMap, i)
	end
end

-- Synced variables setup
local tex = sync.add(config:load("TextureColor"), vec(client.uuidToIntArray(avatar:getUUID())).x % (#texMap - 1) + 1)

-- Reset if color is out of bounds
if sync[tex] > #texMap then
	sync[tex] = 1
end

-- Variables
local _tex = nil
local override = false

-- Texture parts
local texParts = parts:createTable(function(part) return part:getName():find("_[sS]wap") end)

function events.RENDER(delta, context)
	
	-- Origin check
	override = false
	for i, v in ipairs(texMap) do
		if origins.hasOrigin(player, "chocobotaur:chocobotaur_"..v) then
			sync[tex] = i
			override = true
			break
		end
	end
	
	if sync[tex] ~= _tex then
		
		local curTex = texs[texMap[sync[tex]]]
		
		-- Apply textures
		for _, part in ipairs(texParts) do
			
			part:primaryTexture("CUSTOM", curTex.tex)
			
		end
		
		-- Glowing outline
		renderer:outlineColor(curTex.color)
		
		-- Avatar color
		avatar:color(curTex.color)
		
	end
	
	-- Store data
	_tex = sync[tex]
	
end

-- Set the primary texture
function pings.setTextureColor(i)
	
	-- Kills function early if origin is controling the texture
	if override then return end
	
	-- Saves color
	sync[tex] = ((sync[tex] + i - 1) % #texMap) + 1
	config:save("TextureColor", sync[tex])
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local s, wheel, itemCheck, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found
pcall(require, "scripts.Accessories") -- Tries to find script, not required

-- Dont preform if color properties is empty
if next(c) ~= nil then
	
	-- Store init colors
	local initColors = {}
	for k, v in pairs(c) do
		initColors[k] = v
	end
	
	-- Update action wheel colors
	function events.RENDER(delta, context)
		
		-- Variable
		local color = texs[texMap[sync[tex]]].color
		
		-- Create mermod colors
		local appliedColors = {
			hover     = color,
			active    = (color + 0.25):applyFunc(function(a) return math.min(a, 1) end),
			primary   = "#"..vectors.rgbToHex(color),
			secondary = "#"..vectors.rgbToHex((color - 0.1):applyFunc(function(a) return math.min(a, 1) end))
		}
		
		-- Update action wheel colors
		for k in pairs(c) do
			c[k] = appliedColors[k]
		end
		
	end
	
end

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
		:item(itemCheck("chococraft:chocobo_feather", "feather"))
		:onLeftClick(function() wheel:descend(chocoboPage) end)
end

a.texAct = chocoboPage:newAction()
	:onLeftClick(function() pings.setTextureColor(1) end)
	:onRightClick(function() pings.setTextureColor(-1) end)
	:onScroll(pings.setTextureColor)

-- Texture items table
local texItems = {
	yellow = itemCheck("yellow_dye"),
	green  = itemCheck("green_dye"),
	blue   = itemCheck("blue_dye"),
	white  = itemCheck("white_dye"),
	black  = itemCheck("black_dye"),
	gold   = itemCheck("gold_ingot"),
	pink   = itemCheck("pink_dye"),
	red    = itemCheck("red_dye"),
	purple = itemCheck("purple_dye"),
	flame  = itemCheck("blaze_powder")
}
-- Inserts items into table
for k, v in pairs(texItems) do
	if texs[k] then texs[k].item = v end
end

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		if a.pageAct then
			a.pageAct
				:title(toJson(
					{text = "Chocobo Settings", bold = true, color = c.primary}
				))
		end
		
		a.texAct
			:title(toJson(
				{
					"",
					{text = "Chocobo Texture\n\n", bold = true, color = c.primary},
					{text = ("Sets the lower body to use the %s varient chocobo!\n"):format(texMap[sync[tex]]:gsub("^%l", string.upper)), color = c.secondary},
					{text = override and "Your origin is currently controling your texture!" or "Left click, Right click, or scroll to select a texture!", color = override and "gold" or c.secondary}
				}
			))
			:item(texs[texMap[sync[tex]]].item)
		
		for _, act in pairs(a) do
			act:hoverColor(c.hover)
		end
		
	end
	
end