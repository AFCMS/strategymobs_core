local S = minetest.get_translator("strategymobs_core")

local title = {
    [1] = S("Dirt Monster (1)"),
    [2] = S("Stone Monster (2)")
}

for i = 1, 10 do
    minetest.register_tool("strategymobs_core:unit_" .. i, {
        description = title[i] and title[i] or "Unit " .. i,
        inventory_image = "default_mese_crystal.png",
        groups = { strategymobs_unit = i, not_in_creative_inventory = 1 },
        on_place = function() end,
        on_drop = function() end,
        on_use = function() end,
    })
end
