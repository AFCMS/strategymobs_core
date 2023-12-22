minetest.log("action", "[strategy_core] Loading...")

local S = minetest.get_translator("strategymobs_core")
local modpath = minetest.get_modpath("strategymobs_core")

dofile(modpath .. "/items.lua")

arena_lib.register_minigame("strategymobs", {
    name = S("StrategyMobs"),
    prefix = "[" .. S("StrategyMobs") .. "] ",
    min_players = 2,
    max_players = 2,
    properties = {
        player_1_pos = vector.zero(),
        player_2_pos = vector.zero(),
        player_1_rot = -90,
        player_2_rot = 90,
        board_pos = vector.zero(),
    },
    temp_properties = {
        ---@type mt.LuaObjectRef
        player_1_chair = {},
        ---@type mt.LuaObjectRef
        player_2_chair = {},
        placing_time = true,
        ---@type strategymobs_board
        board = {
            units = {},
        },
        ---@type mt.LuaObjectRef[]
        unit_selectors = {}
    },
    disable_inventory = true,
    can_drop = false,
    damage_modifiers = { immortal = 1 },
})

---@alias strategymobs_unit_level
---|0 # NONE
---|1
---|2
---|3

---@class strategymobs_unit
---@field level strategymobs_unit_level
---@field owner string
---@field w integer
---@field h integer

---@class strategymobs_board
---@field units strategymobs_unit[]

local mob_texture = "strategymobs_unit.png"

---@return mt.PlayerObjectRef
---@return mt.PlayerObjectRef
local function get_arena_players(arena)
    local player_1, _ = next(arena.players)
    local player_2, _ = next(arena.players, player_1)

    assert(player_1 and player_2, "This minigame can only be played by two players!")

    local player_1_obj = minetest.get_player_by_name(player_1)
    local player_2_obj = minetest.get_player_by_name(player_2)

    return player_1_obj, player_2_obj
end

minetest.register_entity("strategymobs_core:unit_selector", {
    initial_properties = {
        selectionbox = { -0.16, -0.16, -0.16, 0.16, 0.16, 0.16 },
        physical = false,
        visual = "mesh",
        mesh = "strategymobs_unit.obj",
        use_texture_alpha = true,
        --textures = { "default_stone.png", "default_mese_crystal.png" },
        textures = { "blank.png", "blank.png" }, --by default invisible
        visual_size = vector.new(2, 2, 2),
        pointable = true,                        ---TODO: replace by raycast?
        static_save = false,
    },
    ---@param clicker mt.PlayerObjectRef
    on_rightclick = function(self, clicker)
        --print(dump(self.object:get_luaentity()))
        --minetest.add_particle({
        --    pos = pos_on_grid(self.object:get_pos(), w, h),
        --    texture = "default_mese_crystal.png",
        --    size = 2,
        --    expirationtime = 120,
        --})
        if clicker:is_player() then
            local item = clicker:get_wielded_item()
            local g = minetest.get_item_group(item.name, "strategymobs_unit")
            --minetest.log("error", "CLICK:" .. minetest.get_item_group(item.name, "strategymobs_unit"))
            self.unit = g
            local player_1, _ = get_arena_players(select(2, arena_lib.get_arena_by_name("strategymobs", self.arena_name)))
            self.player = (clicker == player_1 and 1 or 2)
            self:update_graphics()
            item:take_item()
            clicker:set_wielded_item(item)
        end
    end,
    update_textures = function(self)
        self.object:set_properties({
            textures = { mob_texture .. "^[colorize:" .. (self.player == 1 and "#FF0000" or "#0000FF") .. ":100", (self.selected and "strategymobs_unit_ring_selected.png" or "blank.png") }
        })
    end,
    update_rotation = function(self)
        self.object:set_rotation(vector.new(0, (self.player == 1 and (math.pi / 2) or (math.pi)), 0))
    end,
    update_graphics = function(self)
        minetest.log("error", "Updating graphics:" .. self.unit .. ", " .. self.player)
        if self.unit == 0 or self.player == 0 then
            self:make_invisible()
        else
            self:update_textures()
            self:update_rotation()
        end
    end,
    make_invisible = function(self)
        self.object:set_properties({
            textures = { "blank.png", "blank.png" }
        })
    end
})


arena_lib.register_editor_section(":strategymobs", {
    name = "Strategy Mobs",
    icon = "default_stone_brick.png",
    give_items = function(itemstack, user, arena)
        return { "strategymobs_core:player_1_pos", "strategymobs_core:player_2_pos", "strategymobs_core:board_pos" }
    end
})

--- Tools for arena editor

minetest.register_tool("strategymobs_core:player_1_pos", {
    description = "Set player 1 chair position",
    inventory_image = "default_mese_crystal.png",
    groups = { not_in_creative_inventory = 1 },
    on_place = function() end,
    on_drop = function() end,
    on_use = function(itemstack, user, pointed_thing)
        local arena_name = user:get_meta():get_string("arena_lib_editor.arena")
        arena_lib.change_arena_property(user:get_player_name(), "strategymobs", arena_name, "player_1_pos",
            vector.round(user:get_pos()), true)
    end
})

minetest.register_tool("strategymobs_core:player_2_pos", {
    description = "Set player 2 chair position",
    inventory_image = "default_mese_crystal.png",
    groups = { not_in_creative_inventory = 1 },
    on_place = function() end,
    on_drop = function() end,
    on_use = function(itemstack, user, pointed_thing)
        local arena_name = user:get_meta():get_string("arena_lib_editor.arena")
        arena_lib.change_arena_property(user:get_player_name(), "strategymobs", arena_name, "player_2_pos",
            vector.round(user:get_pos()), true)
    end
})

minetest.register_tool("strategymobs_core:board_pos", {
    description = "Set board bottom left position",
    inventory_image = "default_mese_crystal.png",
    groups = { not_in_creative_inventory = 1 },
    on_place = function() end,
    on_drop = function() end,
    on_use = function(itemstack, user, pointed_thing)
        local arena_name = user:get_meta():get_string("arena_lib_editor.arena")
        arena_lib.change_arena_property(user:get_player_name(), "strategymobs", arena_name, "board_pos",
            vector.round(user:get_pos()), true)
    end
})

minetest.register_node("strategymobs_core:placing_time", {
    drawtype = "mesh",
    mesh = "strategymobs_placing_time.obj",
    tiles = { "default_stone.png^strategymobs_placing_time.png" },
    buildable_to = true,
    use_texture_alpha = "opaque",
})

---@param pos mt.Vector
---@param w integer
---@param h integer
---@return mt.Vector
local function pos_on_grid(pos, w, h)
    return vector.offset(pos, (3 / 9 * (w - 1)) - 0.3, 0.5, (3 / 9 * (h - 1)) - 0.3)
end

---@param player mt.PlayerObjectRef
local function add_player_inventory_units(player)
    local inv = player:get_inventory()
    for i = 1, 9 do
        inv:set_stack("main", i, "strategymobs_core:unit_" .. i)
    end
end

arena_lib.on_load("strategymobs", function(arena)
    minetest.log("error", dump(arena.players))

    arena.player_1_chair = minetest.add_entity(arena.player_1_pos, "strategymobs_core:attach_chair")
    arena.player_2_chair = minetest.add_entity(arena.player_2_pos, "strategymobs_core:attach_chair")
    arena.player_1_chair:set_armor_groups({ immortal = 1 })
    arena.player_2_chair:set_armor_groups({ immortal = 1 })

    local player_1, _ = next(arena.players)
    local player_2, _ = next(arena.players, player_1)

    assert(player_1 and player_2, "This minigame can only be played by two players!")

    local player_1_obj = minetest.get_player_by_name(player_1)
    local player_2_obj = minetest.get_player_by_name(player_2)

    player_1_obj:set_attach(arena.player_1_chair, nil, nil, vector.new(0, arena.player_1_rot, 0))
    player_2_obj:set_attach(arena.player_2_chair, nil, nil, vector.new(0, arena.player_2_rot, 0))

    player_1_obj:hud_set_flags({ hotbar = true })
    player_2_obj:hud_set_flags({ hotbar = true })

    --Sitting animation
    player_1_obj:set_animation({ x = 81, y = 160 }, 30, 0)
    player_2_obj:set_animation({ x = 81, y = 160 }, 30, 0)

    add_player_inventory_units(player_1_obj)
    add_player_inventory_units(player_2_obj)

    --minetest.set_node(vector.offset(arena.board_pos, 1, 1, 1),
    --    { name = "strategymobs_core:placing_time", param1 = 0, param2 = 0 })

    ---print(dump(arena.board_pos))
    for w = 1, 9 do
        for h = 1, 9 do
            --print(w, h, dump(vector.offset(pos_on_grid(arena.board_pos, w, h), 0, 0.3333, 0)))
            --[[minetest.add_particle({
                pos = pos_on_grid(arena.board_pos, w, h),
                texture = "default_mese_crystal.png",
                size = 2,
                expirationtime = 120,
            })]]

            local e = minetest.add_entity(vector.offset(pos_on_grid(arena.board_pos, w, h), 0, 0.1, 0),
                "strategymobs_core:unit_selector")
            e:set_armor_groups({ immortal = 1 })
            local lent = e:get_luaentity()
            lent.arena_name = arena.name
            lent.unit = 0
            lent.w = w
            lent.h = h
            lent.player = 0
            lent.selected = false
            lent:update_graphics()
            e:set_properties({
                ---textures = { "default_stone.png^[colorize:red:255" },
                infotext = "w: " .. w .. ", h: " .. h, --TODO: remove
            })
            table.insert(arena.unit_selectors, e)
        end
    end

    minetest.log("error", "StrategyMobs > Players are " .. tostring(player_1) .. ", " .. tostring(player_2))

    for pl_name, _ in pairs(arena.players) do
        local player = minetest.get_player_by_name(pl_name)
        minetest.log("error", player:get_player_name())
    end
end)

minetest.register_globalstep(function(dtime)
    for _, pl_name in pairs(arena_lib.get_players_in_minigame("strategymobs")) do
        if not arena_lib.is_player_spectating(pl_name) then
            local player = minetest.get_player_by_name(pl_name)
            local p_nodename = minetest.get_node(player:get_pos()).name
            local arena = arena_lib.get_arena_by_player(pl_name)

            if arena.in_loading then return end
        end
    end
end)

arena_lib.on_end("strategymobs", function(arena, winners, is_forced)
    if arena.player_1_chair then
        arena.player_1_chair:remove()
    end
    if arena.player_2_chair then
        arena.player_2_chair:remove()
    end

    for _, e in ipairs(arena.unit_selectors) do
        if e then
            e:remove()
        end
    end
    local player_1, _ = next(arena.players)
    local player_2, _ = next(arena.players, player_1)

    local player_1_obj = minetest.get_player_by_name(player_1)
    local player_2_obj = minetest.get_player_by_name(player_2)

    player_1_obj:hud_set_flags({ hotbar = false })
    player_2_obj:hud_set_flags({ hotbar = false })
end)

minetest.log("action", "[strategy_core] Loaded successfully")
