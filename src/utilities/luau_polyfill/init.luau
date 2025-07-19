local Types = require("@self/types")

export type Array<T> = Types.Array<T>

return {
	Array = require("@self/array"),
	Number = require("@self/number"),
	Object = require("@self/object"),
}
