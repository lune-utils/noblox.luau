local Types = require("./types")

type Table = Types.Table
type Array<T> = Types.Array<T>
type Tuple<T, V> = Types.Tuple<T, V>

local Object = {}

local len = string.len
local sub = string.sub

function Object.keys(value: Table | string): Array<string>
	assert(value ~= nil, "cannot extract keys from a nil value")

	local valueType = typeof(value)
	local keys: Array<string>

	if valueType == "table" then
		keys = {}
		for key in value :: Table do
			table.insert(keys, key)
		end
	elseif valueType == "string" then
		local length = len(value :: string)
		keys = table.create(length)
		for i = 1, length do
			keys[i] = tostring(i)
		end
	end

	return keys
end

function Object.values<T>(value: { [string]: T } | Array<T> | string): Array<T> | Array<string>
	assert(value ~= nil, "cannot extract values from a nil value")
	local valueType = typeof(value)

	local array: Array<T> | Array<string>
	if valueType == "table" then
		array = {}
		for _, keyValue in value :: any do
			table.insert(array, keyValue)
		end
	elseif valueType == "string" then
		-- optimization to avoid rehashing/growth
		local valueStringLength = len(value :: string)
		array = table.create(valueStringLength)
		for i = 1, valueStringLength do
			(array :: Array<string>)[i] = sub(value :: string, i, i)
		end
	end

	return array
end

function Object.entries<T>(value: string | { [string]: T } | Array<T>): Array<Tuple<string, T>>
	assert(value :: any ~= nil, "cannot get entries from a nil value")
	local valueType = typeof(value)

	local entries: Array<Tuple<string, T>> = {}
	if valueType == "table" then
		for key, keyValue in value :: any do
			table.insert(entries, { key, keyValue })
		end
	elseif valueType == "string" then
		for i = 1, string.len(value :: string) do
			entries[i] = { tostring(i), sub(value :: string, i, i) }
		end
	end

	return entries
end

return Object
