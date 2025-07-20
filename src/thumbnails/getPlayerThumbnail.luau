local Roxios = require("@packages/roxios")
local LuauPolyfill = require("../utilities/luau_polyfill")
local Types = require("../types")

local Array = LuauPolyfill.Array
local Number = LuauPolyfill.Number
local Object = LuauPolyfill.Object

type ThumbnailFormat = Types.ThumbnailFormat
type ThumbnailSize = Types.ThumbnailSize
type ThumbnailCropType = Types.ThumbnailCropType

type EligibleSizeData = {
	sizes: { string },
	endpoint: string,
}

local eligibleSizes: { [ThumbnailCropType]: EligibleSizeData } = {
	body = {
		sizes = {
			"30x30",
			"48x48",
			"60x60",
			"75x75",
			"100x100",
			"110x110",
			"140x140",
			"150x150",
			"150x200",
			"180x180",
			"250x250",
			"352x352",
			"420x420",
			"720x720",
		},
		endpoint = "avatar",
	},
	bust = {
		sizes = {
			"48x48",
			"50x50",
			"60x60",
			"75x75",
			"100x100",
			"150x150",
			"180x180",
			"352x352",
			"420x420",
		},
		endpoint = "avatar-bust",
	},
	headshot = {
		sizes = {
			"48x48",
			"50x50",
			"60x60",
			"75x75",
			"100x100",
			"110x110",
			"150x150",
			"180x180",
			"352x352",
			"420x420",
			"720x720",
		},
		endpoint = "avatar-headshot",
	},
}

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

return function(
	userIds: number | { number },
	size: ThumbnailSize?,
	format: ThumbnailFormat?,
	isCircular: boolean?,
	cropType: ThumbnailCropType?
): string?
	if Array.isArray(userIds) then
		if Array.some(userIds, Number.isNan) then
			error("userIds must be a number or an array of numbers", 2)
		end
		userIds = deduplicate(userIds :: { number })

		if #(userIds :: { number }) > 100 then
			error(`too many userIds provided ({#(userIds :: { number })}); maximum 100`, 2)
		end
	else
		if Number.isNan(userIds) then
			error("userId is not a number", 2)
		end
		userIds = { userIds }
	end

	print(userIds)

	local cropType = string.lower(cropType or "body")
	local cropKeys = Object.keys(eligibleSizes)
	if not Array.includes(cropKeys, cropType) then
		error(`Invalid cropping type provided: {cropType} | Use: {Array.join(cropKeys, ", ")}`, 2)
	end

	local eligibleSize = eligibleSizes[cropType]
	local sizes = eligibleSize.sizes
	local endpoint = eligibleSize.endpoint
	local size = size or sizes[#sizes]

	if typeof(size) == "number" then
		size = `{size}x{size}`
	end

	if not Array.includes(sizes, size) then
		error(`Invalid size parameter provided: {size} | [{string.upper(cropType)}] Use: {Array.join(sizes, ", ")}`, 2)
	end

	local format = string.lower(format or "png")

	if format ~= "png" and format ~= "jpeg" then
		error(`Invalid image type provided: {format} | Use: png, jpeg`, 2)
	end

	local isCircular = isCircular or false

	local url =
		`https://thumbnails.roblox.com/v1/users/{endpoint}?userIds={Array.join(userIds, ",")}&size={size}&format={format}&isCircular={not not isCircular}`

	local rawData = Roxios.get(url):await()
	if rawData:isOk() then
		local data = rawData:unwrapOk()
		local imageData = data and data.data or nil
		if imageData and #imageData > 0 then
			local imageUrl = imageData[1].imageUrl
			print(imageUrl)
			return imageUrl
		end
	end

	return nil
end
