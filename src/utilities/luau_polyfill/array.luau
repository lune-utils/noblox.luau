local Types = require("./types")

type Array<T> = Types.Array<T>
type callbackFn<T> = (element: T, index: number, array: Array<T>) -> boolean
type callbackFnWithThisArg<T, U> = (thisArg: U, element: T, index: number, array: Array<T>) -> boolean
type callbackFnMap<T, U> = (element: T, index: number, array: Array<T>) -> U
type callbackFnWithThisArgMap<T, U, V> = (thisArg: V, element: T, index: number, array: Array<T>) -> U

local Array = {}

function Array.isArray(value: any): boolean
	if typeof(value) ~= "table" then
		return false
	end

	if next(value) == nil then
		return true
	end

	local count = 0
	local sum = 0

	for key in pairs(value) do
		if typeof(key) ~= "number" or key % 1 ~= 0 or key < 1 then
			return false
		end
		count += 1
		sum += key
	end

	return sum == (count * (count + 1) / 2)
end

function Array.some<T, U>(t: Array<T>, callback: callbackFn<T> | callbackFnWithThisArg<T, U>, thisArg: U?): boolean
	if typeof(t) ~= "table" then
		error(string.format("Array.some called on %s", typeof(t)))
	end
	if typeof(callback) ~= "function" then
		error("callback is not a function")
	end

	if thisArg ~= nil then
		for i, value in t do
			if value and (callback :: callbackFnWithThisArg<T, U>)(thisArg, value, i, t) then
				return true
			end
		end
	else
		for i, value in t do
			if value and (callback :: callbackFn<T>)(value, i, t) then
				return true
			end
		end
	end

	return false
end

function Array.indexOf<T>(array: Array<T>, searchElement: T, fromIndex: number?): number
	local fromIndex_ = fromIndex or 1
	local length = #array

	if fromIndex_ < 1 then
		fromIndex_ = math.max(length - math.abs(fromIndex_), 1)
	end

	for i = fromIndex_, length do
		if array[i] == searchElement then
			return i
		end
	end

	return -1
end

function Array.includes<T>(array: Array<T>, searchElement: T, fromIndex: number?): boolean
	return Array.indexOf(array, searchElement, fromIndex) ~= -1
end

function Array.join<T>(arr: Array<T>, separator: string?): string
	if #arr == 0 then
		return ""
	end
	-- JS does tostring conversion implicitely but in Lua we need to do that explicitely
	local stringifiedArray = Array.map(arr, function(item)
		return tostring(item)
	end)

	return table.concat(stringifiedArray, separator or ",")
end

function Array.map<T, U, V>(t: Array<T>, callback: callbackFnMap<T, U> | callbackFnWithThisArgMap<T, U, V>, thisArg: V?)
	local len = #t
	local Map = table.create(len)

	if thisArg ~= nil then
		for i = 1, len do
			Map[i] = (callback :: callbackFnWithThisArgMap<T, U, V>)(thisArg, t[i], i, t)
		end
	else
		for i = 1, len do
			Map[i] = (callback :: callbackFnMap<T, U>)(t[i], i, t)
		end
	end

	return Map
end

return Array
