local Number = {}

function Number.isNan(value: any)
	return type(value) == "number" and value ~= value
end

return Number
