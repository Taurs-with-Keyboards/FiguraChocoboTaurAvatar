-- Required script
local parts = require("lib.PartsAPI")

-- All colors
local texs = {
	
	{
		tex   = textures["textures.yellowchocobo"] or textures["ChocoboTaur.yellowchocobo"],
		color = vectors.hexToRGB("F5F372")
	},
	{
		tex   = textures["textures.greenchocobo"] or textures["ChocoboTaur.greenchocobo"],
		color = vectors.hexToRGB("45C04B")
	},
	{
		tex   = textures["textures.bluechocobo"] or textures["ChocoboTaur.bluechocobo"],
		color = vectors.hexToRGB("5696F3")
	},
	{
		tex   = textures["textures.whitechocobo"] or textures["ChocoboTaur.whitechocobo"],
		color = vectors.hexToRGB("C4C4BE")
	},
	{
		tex   = textures["textures.blackchocobo"] or textures["ChocoboTaur.blackchocobo"],
		color = vectors.hexToRGB("495254")
	},
	{
		tex   = textures["textures.goldchocobo"] or textures["ChocoboTaur.goldchocobo"],
		color = vectors.hexToRGB("CAA028")
	},
	{
		tex   = textures["textures.pinkchocobo"] or textures["ChocoboTaur.pinkchocobo"],
		color = vectors.hexToRGB("E298AE")
	},
	{
		tex   = textures["textures.redchocobo"] or textures["ChocoboTaur.redchocobo"],
		color = vectors.hexToRGB("DD464A")
	},
	{
		tex   = textures["textures.purplechocobo"] or textures["ChocoboTaur.purplechocobo"],
		color = vectors.hexToRGB("AA5CF5")
	},
	{
		tex   = textures["textures.flamechocobo"] or textures["ChocoboTaur.flamechocobo"],
		color = vectors.hexToRGB("954040")
	}
	
}

-- Config setup
config:name("ChocoboTaur")
local tex = config:load("TextureColor") or vec(client.uuidToIntArray(avatar:getUUID())).x % (#colors - 1) + 1

-- Reset if color is out of bounds
if tex > #texs then
	tex = 1
end

-- Texture parts
local texParts = parts:createTable(function(part) return part:getName():find("_[sS]wap") end)

function events.RENDER(delta, context)
	
	-- Apply textures
	for _, part in ipairs(texParts) do
		
		part:primaryTexture("CUSTOM", texs[tex].tex)
		
	end
	
	-- Glowing outline
	renderer:outlineColor(texs[tex].color)
	
	-- Avatar color
	avatar:color(texs[tex].color)
	
end

-- Set the primary texture
function pings.setTextureColor(i)
	
	-- Saves color
	tex = ((tex + i - 1) % #texs) + 1
	config:save("TextureColor", tex)
	
end

-- Sync variable
function pings.syncTextures(a)
	
	tex = a
	
end

-- Host only instructions
if not host:isHost() then return end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncTextures(tex)
	end
	
end

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
		local color = texs[tex].color
		
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

-- Primary info table
local texInfo = {
	{
		text = "Yellow",
		item = itemCheck("yellow_dye")
	},
	{
		text = "Green",
		item = itemCheck("green_dye")
	},
	{
		text = "Blue",
		item = itemCheck("blue_dye")
	},
	{
		text = "White",
		item = itemCheck("white_dye")
	},
	{
		text = "Black",
		item = itemCheck("black_dye")
	},
	{
		text = "Gold",
		item = itemCheck("gold_ingot")
	},
	{
		text = "Pink",
		item = itemCheck("pink_dye")
	},
	{
		text = "Red",
		item = itemCheck("red_dye")
	},
	{
		text = "Purple",
		item = itemCheck("purple_dye")
	},
	{
		text = "Flame",
		item = itemCheck("blaze_powder")
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
		
		a.texAct
			:title(toJson(
				{
					"",
					{text = "Chocobo Texture\n\n", bold = true, color = c.primary},
					{text = ("Sets the lower body to use the %s varient chocobo!"):format(texInfo[tex].text), color = c.secondary}
				}
			))
			:item(texInfo[tex].item)
		
		for _, act in pairs(a) do
			act:hoverColor(c.hover)
		end
		
	end
	
end