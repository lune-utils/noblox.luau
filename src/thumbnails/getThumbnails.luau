local Roxios = require("@packages/roxios")
local LuauPolyfill = require("../utilities/luau_polyfill")
local Types = require("../types")

local Array = LuauPolyfill.Array

type ThumbnailData = Types.ThumbnailData
type ThumbnailRequest = Types.ThumbnailRequest
type Array<T> = LuauPolyfill.Array<T>

local function deduplicate<T>(arr: { T }): { T }
	local seen = {}
	local result = {}

	for _, v in arr do
		if not seen[v] then
			seen[v] = true
			table.insert(result, v)
		end
	end

	return result
end

return function(requests: Array<ThumbnailRequest>): Array<ThumbnailData>?
	if not Array.isArray(requests) then
		error("thumbnailRequests are not an array", 2)
	end
	requests = deduplicate(requests)
	if #requests > 100 then
		error(`Too many thumbnailRequests provided ({#requests}); maximum 100`, 2)
	end

	for _, request in requests do
		if not request.size or not request.type then
			error("thumbnailRequest must have a size and type", 2)
		elseif request.format then
			local format = string.lower(request.format)
			if format ~= "png" and format ~= "jpeg" then
				error(`Invalid image type provided: {request.format} | Use: png, jpeg`, 2)
			end
		end

		if typeof(request.size) == "number" then
			request.size = `{request.size}x{request.size}`
		end
	end

	local rawData = Roxios.post("https://thumbnails.roblox.com/v1/batch", requests, {
		headers = { ["Content-Type"] = "application/json" },
	}):await()
	if rawData:isOk() then
		local data = rawData:unwrapOk()

		if data.data and #data.data > 0 then
			return data.data
		end

		return nil
	end

	return nil
end
