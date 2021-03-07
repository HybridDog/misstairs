-- Warnings or errors when an avoidable function not compatible with Lua 5.3 is
-- used

local function warn(msg)
	--~ minetest.log("deprecated", "Compat: " .. msg)
	assert(false, "Compat: " .. msg)
end

function math.pow(x, y)
	warn("math.pow(x, y) will be deprecated, use x ^ y instead")
	return x ^ y
end

function math.ldexp(x, y)
	warn("math.ldexp(x, y) will be deprecated, use x * 2.0 ^ y instead")
	return x * 2.0 ^ y
end

for _,name in ipairs{"cosh", "sinh", "tanh", "frexp"} do
	local origfunc = math[name]
	math[name] = function(...)
		warn("math." .. name .. " will be deprecated")
		return origfunc(...)
	end
end

