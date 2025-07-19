local getThumbnails = require("@self/thumbnails/getThumbnails")
local getPlayerThumbnail = require("@self/thumbnails/getPlayerThumbnail")
local getLogo = require("@self/thumbnails/getLogo")
return {
	getPlayerThumbnail = getPlayerThumbnail,
	getThumbnails = getThumbnails,
	getLogo = getLogo,
}
