local load_time_start = os.clock()

do_compat_tests = true

local path = minetest.get_modpath("misstairs")
if do_compat_tests then
	dofile(path .. "/lua_compat.lua")
end

--[[
local function msslab(nam, desc, snds, groups)
	stairs.register_stair_and_slab(nam, "default:"..nam,
		groups,
		{"default_"..nam..".png"},
		desc.." Stair",
		desc.." Slab",
		snds
	)
end
]]

local function msslab2(nam, desc, snds, groups, tnam)
	stairs.register_stair_and_slab(nam, "default:"..nam,
		groups,
		{"default_"..tnam..".png"},
		desc.." Stair",
		desc.." Slab",
		snds
	)
end

-- add a mesebrick
minetest.register_node(":default:mesebrick", {
	description = "Mese Brick",
	tiles = {"default_mese_brick.png"},
	groups = {cracky=1,level=2},
	sounds = default.node_sound_stone_defaults(),
})

--msslab("desert_stone", "Desert Stone", default.node_sound_stone_defaults(), {cracky=3, stone=1})
--msslab("obsidian", "Obsidian", default.node_sound_stone_defaults(), {cracky=1,level=2})
msslab2("mese", "Mese", default.node_sound_stone_defaults(), {cracky=1,level=2}, "mese_block")
--msslab2("desert_stonebrick", "Desert Stone Brick", default.node_sound_stone_defaults(), {cracky=2, stone=1}, "desert_stone_brick")
--msslab2("sandstonebrick", "Sandstone Brick", default.node_sound_stone_defaults(), {cracky=2}, "sandstone_brick")
msslab2("mesebrick", "Mese Brick", default.node_sound_stone_defaults(), {cracky=1,level=2}, "mese_brick")
msslab2("coalblock", "Coal Block", default.node_sound_stone_defaults(), {cracky=3}, "coal_block")

-- increase maximum cobble / stack
minetest.override_item("default:cobble", {stack_max = 999})

-- disallows torches to be placed into not pointable buildable_to nodes except air
local function torch_placeable(pos)
	if not pos then
		return true
	end
	local node = minetest.get_node(pos).name
	if node == "air"
	or (minetest.registered_nodes[node] and not minetest.registered_nodes[node].buildable_to) then
		return true
	end
	return false
end
local torch_place = minetest.registered_items["default:torch"].on_place
minetest.override_item("default:torch", {
	on_place = function(itemstack, placer, pt, ...)
		if torch_placeable(pt.above) then
			return torch_place(itemstack, placer, pt, ...)
		end
	end
})

-- changes papyrus and cactus fcts
local function get_pseudorandom(pos, seed)
	return PseudoRandom(math.abs(pos.x+pos.y*3+pos.z*5)+seed)
end

default.grow_papyrus = function(pos, node)
	pos.y = pos.y-1
	local name = minetest.get_node(pos).name
	if name ~= "default:dirt_with_grass"
	and name ~= "default:dirt" then
		return
	end
	if not minetest.find_node_near(pos, 3, {"group:water"}) then
		return
	end
	pos.y = pos.y+1
	local height = 0
	while node.name == "default:papyrus" and height < 4 do
		height = height+1
		pos.y = pos.y+1
		node = minetest.get_node(pos)
	end
	if height == 4
	or node.name ~= "air" then
		return
	end

	if height > 2 then
		local pr = get_pseudorandom(pos, 11)
		if pr:next(1,2) == 1 then
			return
		end
	end

	minetest.set_node(pos, {name="default:papyrus"})
	return true
end

default.grow_cactus = function(pos, node)
	if node.param2 ~= 0 then
		return
	end
	pos.y = pos.y-1
	if minetest.get_item_group(minetest.get_node(pos).name, "sand") == 0 then
		return
	end
	pos.y = pos.y+1
	local height = 0
	while node.name == "default:cactus" and height < 4 and node.param2 == 0 do
		height = height+1
		pos.y = pos.y+1
		node = minetest.get_node(pos)
	end
	if height == 4
	or node.name ~= "air" then
		return
	end

	if height > 2 then
		local pr = get_pseudorandom(pos, 10)
		if pr:next(1,2) == 1 then
			return
		end
	end

	minetest.set_node(pos, {name="default:cactus"})
	return true
end

-- gives singleplayer every priv
minetest.register_on_newplayer(function(player)
	local name = player:get_player_name()
	if name == "singleplayer" then
		minetest.set_player_privs(name, minetest.registered_privileges)
	end
end)

-- more info to terminal for print and chat_send_player
local realp = print
function print(a, ...)
	if tostring(a) == tostring(tonumber(a)) then
		return realp(minetest.get_last_run_mod(), a, ...)
	end
	return realp(a, ...)
end


local chatsend = minetest.chat_send_player
function minetest.chat_send_player(name, msg, ...)
	print"[2m"
	minetest.log("action", "msg to "..name..': "'..msg..'"[m')
	return chatsend(name, msg, ...)
end

-- [[ faster table insertion
local tinsert = table.insert
function table.insert(t, v, n)
	if n then
		return tinsert(t, v, n)
	end
	t[#t+1] = v
end--]]



-- Change the wield hand to use the skin

minetest.after(0, function()
	minetest.override_item("", {
		wield_image = "wield_dummy.png^[combine:16x16:2,2=wield_dummy.png:" ..
			"-52,-23=character.png^[transformfy",
		wield_scale = {x=1.8,y=1,z=2.8},
	})
end)




--[[ this one doesn't work faster
function unpack(t, i)
	i = i or 1
	if t[i] ~= nil then
		return t[i], unpack(t, i + 1)
	end
end]]


--[[
???

default:obsidian_brick default:obsidianbrick
--]]



--[[
tmp = minetest.registered_nodes["default:leaves"]
tmp.groups = {snappy=3, leafdecay=3, flammable=2, leaves=1, falling_node=1}
minetest.register_node(":default:leaves", tmp)
]]

--~ minetest.register_on_joinplayer(function(player)
	--~ player:set_sky("#ffffff", "skybox", {"bg.png", "bg.png", "bg.png", "bg.png", "bg.png", "bg.png"})
--~ end)

local time = math.floor(tonumber(os.clock()-load_time_start)*100+0.5)/100
local msg = "[misstairs] loaded after ca. "..time
if time > 0.05 then
	print(msg)
else
	minetest.log("info", msg)
end









--~ minetest.after(1, function()
	--~ for node, data in pairs(minetest.registered_nodes) do
		--~ if data.tiles then
			--~ for i = 1,#t do
				--~ local v = t[i]
				--~ if data.tiles[1] == v.tex then
					--~ print("	{name=" .. node .. ", r=" .. v.r .. ", g=" .. v.g ..
						--~ ", b=" .. v.b .. "},")
				--~ end
			--~ end
		--~ end
	--~ end
--~ end)
