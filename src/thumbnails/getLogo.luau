local Roxios = require("@packages/roxios")
local Types = require("../types")

type GroupIconSize = Types.GroupIconSize
type ThumbnailRequest = Types.ThumbnailRequest

return function(group: number, size: GroupIconSize?, circular: boolean?): string?
	local iconSize = size or "150x150"
	if typeof(iconSize) == "number" then
		iconSize = `{iconSize}x{iconSize}`
	end

	local format = "Png"
	local rawData = Roxios.get("https://thumbnails.roblox.com/v1/groups/icons", {
		params = {
			groupIds = group,
			size = iconSize,
			format = format,
			isCircular = circular and tostring(circular) or "false",
		},
		headers = { ["Content-Type"] = "application/json" },
	}):await()
	if rawData:isOk() then
		local data = rawData:unwrapOk()
		local imageData = data.data and data.data or nil

		if imageData and #imageData > 0 then
			return imageData[1].imageUrl
		end

		return nil
	end

	return nil
end
