-- lpanes: leaded glass panes --  from xPanes mod by xyz, customized by davedevils, reworked and converted to leaded/stained panes by Britt. Textures by Britt


--Leaded glass uses a 'leading' (pronounced "led-ing") material to secure the glass pieces in place.  This is traditionally the metal lead. Specify which 'leading'  metal will be used in crafting the panes.  Lead or Tin might be appropriate, but for the default game, these are not available:
local leadingMetal = "default:steel_ingot"


local function split(string, separator)
        local separator, fields = separator or ":", {}
        local pattern = string.format("([^%s]+)", separator)
        self:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end

local directions = {
  {x = 1, y = 0, z = 0},
  {x = 0, y = 0, z = 1},
  {x = -1, y = 0, z = 0},
  {x = 0, y = 0, z = -1},
}
  
local function update_pane(pos)
  local nodeName = minetest.env:get_node(pos).name
  if nodeName:find("lpanes:pane_") == nil then
    return
  end
  --print("Found: "..nodeName)
  
  --Determine the shade/color of the node
  local shade
  local nodeNameParts = nodeName:split("_")
  local partCount = table.getn(nodeNameParts)
  local lastPart = nodeNameParts[partCount]
  --If the last part is simply a number, then its a 'shape' designator and not part of the color name
  if tonumber(lastPart) ~= nil then
    shade = table.concat(nodeNameParts, "_", 2, partCount - 1) --take off the 'shape' part of the node name
  else
    shade = table.concat(nodeNameParts, "_", 2) --start with the second entry and go to the end
  end
  --print("Shade: "..shade)
  
  local sum = 0
  for i = 1, 4 do
    local node = minetest.env:get_node({x = pos.x + directions[i].x, y = pos.y + directions[i].y, z = pos.z + directions[i].z})
    if minetest.registered_nodes[node.name].walkable ~= false then
      sum = sum + 2 ^ (i - 1)
    end
  end
  if sum == 0 then
    sum = 15
  end
  print("Adding node: lpanes:pane_"..shade.."_"..sum)
  minetest.env:add_node(pos, {name = "lpanes:pane_"..shade.."_"..sum})
end

local function update_nearby(pos)
  for i = 1,4 do
    update_pane({x = pos.x + directions[i].x, y = pos.y + directions[i].y, z = pos.z + directions[i].z})
  end
end




function pane(node, desc, dropitem, shade)
	local function rshift(x, by)
	  return math.floor(x / 2 ^ by)
	end

	local half_blocks = {
		{0, -0.5, -0.06, 0.5, 0.5, 0.06},
		{-0.06, -0.5, 0, 0.06, 0.5, 0.5},
		{-0.5, -0.5, -0.06, 0, 0.5, 0.06},
		{-0.06, -0.5, -0.5, 0.06, 0.5, 0}
	}

	local full_blocks = {
		{-0.5, -0.5, -0.06, 0.5, 0.5, 0.06},
		{-0.06, -0.5, -0.5, 0.06, 0.5, 0.5}
	}

	for i = 1, 15 do
		local need = {}
		local cnt = 0
		for j = 1, 4 do
			if rshift(i, j - 1) % 2 == 1 then
				need[j] = true
				cnt = cnt + 1
			end
		end
		local take = {}
		if need[1] == true and need[3] == true then
			need[1] = nil
			need[3] = nil
			table.insert(take, full_blocks[1])
		end
		if need[2] == true and need[4] == true then
			need[2] = nil
			need[4] = nil
			table.insert(take, full_blocks[2])
		end
		for k in pairs(need) do
			table.insert(take, half_blocks[k])
		end
		local texture = "lpanes_"..shade..".png"
		if cnt == 1 then
			texture = "lpanes_half_"..shade..".png"
		end
		
    -- Position-appropriate node.  One of these nodes will replace the generic node immediately upon placement
		minetest.register_node("lpanes:pane_"..shade.."_"..i, {
			drawtype = "nodebox",
			--tiles = {"xpanes_top_"..node..""..shade..".png", "xpanes_top_"..node..""..shade..".png", texture},
			tiles = {"lpanes_top.png", "lpanes_top.png", texture},
			paramtype = "light",
			use_texture_alpha = true,
			groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3},
			drop = dropitem,
			node_box = {
				type = "fixed",
				fixed = take
			},
			selection_box = {
				type = "fixed",
				fixed = take
			}
		})
	end

  --This is the node that is originally placed.  It will be replaced immediately by one
  -- of the position-appropriate nodes
	minetest.register_node("lpanes:pane_"..shade, {
		description = desc,
		tiles = {"lpanes_"..shade..".png"},
		inventory_image = "lpanes_"..shade..".png",
		paramtype = "light",
		stack_max = 64,
		use_texture_alpha = true,
		wield_image = "lpanes_"..shade..".png",
		node_placement_prediction = "",
		on_construct = update_pane, 
		drop = "",
	})

  --Crafing
  --The Clear, Black, and Grey shades need special handling.
  if shade == "clear" then
    minetest.register_craft({
      type = "shapeless",
      output = 'lpanes:pane_'..shade..' 6',
      recipe = {"default:glass", leadingMetal},
      cooktime = 3,
    })
  elseif shade == "black" then
    minetest.register_craft({
      type = "shapeless",
      output = 'lpanes:pane_'..shade..' 6',
      recipe = {"default:glass", leadingMetal, "dye:black"},
      cooktime = 3,
    })
  elseif shade == "white" then
    minetest.register_craft({
      type = "shapeless",
      output = 'lpanes:pane_'..shade..' 6',
      recipe = {"default:glass", leadingMetal, "dye:white"},
      cooktime = 3,
    })
  elseif shade == "grey" then
    minetest.register_craft({
      type = "shapeless",
      output = 'lpanes:pane_'..shade..' 6',
      recipe = {"default:glass", leadingMetal, "dye:grey"},
      cooktime = 3,
    })
  elseif shade == "light_grey" then
    minetest.register_craft({
      type = "shapeless",
      output = 'lpanes:pane_'..shade..' 6',
      recipe = {"default:glass", leadingMetal, "dye:light_grey"},
      cooktime = 3,
    })
  elseif shade == "dark_grey" then
    minetest.register_craft({
      type = "shapeless",
      output = 'lpanes:pane_'..shade..' 6',
      recipe = {"default:glass", leadingMetal, "dye:dark_grey"},
      cooktime = 3,
    })
  else
    minetest.register_craft({
      type = "shapeless",
      output = 'lpanes:pane_'..shade..' 6',
      recipe = {"default:glass", leadingMetal, "unifieddyes:"..shade},
      cooktime = 3,
    })
  end

end

minetest.register_on_placenode(update_nearby)
minetest.register_on_dignode(update_nearby)


colors = {
	{ "aqua", true },
	--{ "black", true},
	{ "blue", true },
	{ "cyan", true },
	{ "green", true },
	{ "lime", true },
	{ "magenta", true },
	{ "orange", true },
	{ "red", true },
  { "redviolet", true },
	{ "skyblue", true },
	{ "violet", true },
	{ "yellow", true },
}

--Do the colors that follow Unified Dye's naming pattern
for i in ipairs(colors) do
	local hue = colors[i][1]
  --    node,   desc,                           dropItem, shade
	pane("glass", "Glass Pane "..hue, 				        "",   hue)
	pane("glass", "Glass Pane Medium "..hue, 			    "",   "medium_"..hue)
	pane("glass", "Glass Pane Medium "..hue.." s50", 	"",   "medium_"..hue.."_s50")
	pane("glass", "Glass Pane Dark "..hue, 			      "",   "dark_"..hue)
	pane("glass", "Glass Pane Dark "..hue.." s50", 	  "",   "dark_"..hue.."_s50")
end

--Do the colors that don't follow Unified Dye's naming pattern
pane("glass",   "Glass Pane white",                 "",   "white")
pane("glass",   "Glass Pane light grey",            "",   "light_grey")
pane("glass",   "Glass Pane grey",                  "",   "grey")
pane("glass",   "Glass Pane dark grey",             "",   "dark_grey")
pane("glass",   "Glass Pane black",                 "",   "black")
pane("glass",   "Glass Pane clear",                 "",   "clear")

print("[LPanes] Loaded!")
