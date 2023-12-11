minetest.log("action", "[strategy_core] Loading...")

local S = minetest.get_translator("tntrun")

arena_lib.register_minigame("strategymobs", {
    name = S("StrategyMobs"),
    prefix = "[" .. S("StrategyMobs") .. "] ",
    teams = {
        "Player 1",
        "Player 2",
    },
    teams_color_overlay = {
        "blue",
        "red",
    },
    is_team_chat_default = false,
    min_players = 2,
    max_players = 2,
    disable_inventory = true,
    can_drop = false,
})

arena_lib.on_load("strategymobs", function(arena)
    for pl_name, _ in pairs(arena.players) do
        local player = minetest.get_player_by_name(pl_name)
        minetest.log("error", player:get_player_name())
    end
end)


minetest.log("action", "[strategy_core] Loaded successfully")