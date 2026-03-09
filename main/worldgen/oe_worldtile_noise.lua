local _G                 = GLOBAL
local require            = _G.require
local WORLD_TILES        = _G.WORLD_TILES
local NoiseTileFunctions = require("noisetilefunctions")

local function GetTileForMesaNoise(noise)
	if noise < 0.25 then
		return WORLD_TILES.SAVANNA
	elseif noise < 0.35 then
		return WORLD_TILES.OE_MESA_SAND_CREAM
	elseif noise < 0.40 then
		return WORLD_TILES.OE_MESA_SAND_BROWN
	elseif noise < 0.45 then
		return WORLD_TILES.OE_MESA_SAND_CREAM
	elseif noise < 0.50 then
		return WORLD_TILES.OE_MESA_PEBBLE_BEIGE
	elseif noise < 0.75 then
		return WORLD_TILES.OE_MESA_CRACKED
	end

	return WORLD_TILES.OE_MESA_SAND_BROWN
end

NoiseTileFunctions[WORLD_TILES.OE_MESA_NOISE] = GetTileForMesaNoise