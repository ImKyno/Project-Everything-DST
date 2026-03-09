local _G          = GLOBAL
local WORLD_TILES = _G.WORLD_TILES

-- A bit of bones, plants and formations.
AddRoom("BGMesa",
{
    colour = { r = 0.30, g = 0.20, b = 0.10, a = 0.30 },
    value  = WORLD_TILES.OE_MESA_NOISE,
    tags   = { "RoadPoison", "ExitPiece" },
    level_set_piece_blocker = true,
    contents =
    {
        distributepercent = 0.15,
        distributeprefabs =
        {
            houndbone                   = 0.40,
            marsh_bush                  = 0.30,
            flower_withered             = 0.40,
            oe_mesa_cactus_small       = 0.10,
            oe_mesa_agave_bush         = 0.20,
            -- Clay only on MESA_CRACKED ? Hm....
            oe_mesa_rock_clay          = 0.10,
            -- TO DO:
            -- mesa_rock      = 0.60,
            -- mesa_formation = 0.50,
            -- mesa_cactus    = 0.20,
        },
    }
})


-- Lots of rocks and fossils, formations occasionally, no trees and cacti.
-- GLOOMS: Cracked should have the big rock formations, we will keep the "shorter" stuff for the lower priority / less saturated turfs
AddRoom("MesaRocky", 
{
    colour   = { r = 0.30, g = 0.20, b = 0.10, a = 0.30 },
    value    = WORLD_TILES.OE_MESA_CRACKED,
    tags     = { "RoadPoison", "Astral_1" },
    level_set_piece_blocker = true,
    contents =
    {
        countprefabs =
        {
            rock1 = function() return math.random(3, 5) end,
        },
					                
        distributepercent = 0.10,
        distributeprefabs =
        {
            rock_flintless          = 1.00,
            rock2                   = 0.40,
            houndbone               = 0.30,
            oe_mesa_rock_clay          = 0.40,
            oe_mesa_pillar_rock        = 0.20,
            --mesa_pillar_stalactite  = 0.20, -- Won't make sense without a canopy

            -- TO DO:
            -- mesa_rock         = 0.80,
            -- mesa_fossil_beast = 0.60,
            -- mesa_formation    = 0.40,
            -- mesa_cactus       = 0.30,
        },
    }
})

-- Lots of cacti and withered plants, formations occasionally, no trees.
AddRoom("MesaPlains",
{
    colour   = { r = 0.30, g = 0.20, b = 0.10, a = 0.30 },
    value    = WORLD_TILES.OE_MESA_SAND_CREAM,
    tags     = { "RoadPoison" },
    level_set_piece_blocker = true,
    contents =
    {
        countprefabs =
        {
            -- mesa_cactus = function() return math.random(3, 5) end,
        },

        distributepercent = 0.10,
        distributeprefabs =
        {
            marsh_bush          = 0.50,
            sapling             = 0.40,
            flower_withered     = 0.40,
            oe_mesa_agave_bush     = 0.30,
            oe_mesa_cactus_small   = 0.10,
            -- TO DO:
            -- mesa_cactus    = 0.30,
            -- mesa_formation = 0.20,
        },
    }
})

-- GLOOMS: Mesa is too big imo, I don't think we need this.
-- Trees and plants on the outside, empty in the middle.
AddRoom("MesaClearing", 
{
    colour   = { r = 0.30, g = 0.20, b = 0.10, a = 0.30 },
    value    = WORLD_TILES.SAVANNA,
    tags     = { "RoadPoison" },
    level_set_piece_blocker = true,
    contents =
    {			                
        distributepercent = 0.10,
        distributeprefabs =
        {
            -- TO DO: Replace with mesa trees.
            evergreen         = 1.50,
            fireflies         = 1.00,
            marsh_bush        = 0.20,
            houndbone         = 0.10,
            ground_twigs      = 0.05,
            -- TO DO:
            -- mesa_cactus    = 0.30,
            -- mesa_formation = 0.20,
        },
    }
})

-- Lots of trees and plants, formation occasionally, no rocks and fossils.
-- GLOOMS: Testing this as being a forest "under" large rocks (canyon).
AddRoom("MesaForest", 
{
    colour   = { r = 0.30, g = 0.20, b = 0.10, a = 0.30 },
    value    = WORLD_TILES.GRASS,
    tags     = { "RoadPoison", "Astral_2" },
    level_set_piece_blocker = true,
    contents =
    {			                
        distributepercent = 0.20,
        distributeprefabs =
        {
            -- TO DO: Replace with mesa trees.
            trees                       = { weight = 3, prefabs = { "evergreen", "evergreen_sparse" } },
            marsh_bush                  = 0.40,
            houndbone                   = 0.30,
            ground_twigs                = 0.25,
            fireflies                   = 0.20,
            oe_mesa_pillar_tree            = 0.20,
            oe_mesa_pillar_stalactite      = 0.20,
            --mesa_cactus_small    = 0.40,
            -- TO DO:
            -- mesa_cactus    = 0.40,
            -- mesa_formation = 0.20,
        },
    }
})

-- GLOOMS:
-- Archeologist's Dig Site Setpiece.
-- Keep the foundation turf Pebble Beige and we will do Sand Brown in Tiled for the setpiece
-- Also a boon w/ an Archeologist's set (shovel, etc)
AddRoom("MesaDigSite", 
{
	colour   = { r = 0.30, g = 0.20, b = 0.10, a = 0.30 },
    value    = WORLD_TILES.OE_MESA_PEBBLE_BEIGE,
    tags     = { "RoadPoison", "ExitPiece" },
    level_set_piece_blocker = true,
    contents =  
    {
        countprefabs = 
        {
            -- TO DO: Replace with static layout.
            critterlab = 1,
        },
					                
        distributepercent = 0.30,
        distributeprefabs =
        {
            sapling             = 0.70,
            houndbone           = 0.30,
            rock2               = 0.30,
            fossil_piece        = 0.20,
            fireflies           = 0.20,
            fossil_stalker      = 0.05,
            oe_mesa_flipping_rock  = 0.30,
            --mesa_cactus_small    = 0.40,
            -- TO DO:
            -- mesa_rock      = 0.60,
            -- mesa_cactus    = 0.30,
            -- mesa_formation = 0.20,
        },
    }
})