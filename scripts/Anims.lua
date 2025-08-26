-- Required script
local parts = require("lib.PartsAPI")

function events.RENDER(delta, context)
	
	-- Crouch offset
	local bodyRot = vanilla_model.BODY:getOriginRot(delta)
	local crouchPos = vec(0, -math.sin(math.rad(bodyRot.x)) * 2, -math.sin(math.rad(bodyRot.x)) * 12)
	parts.group.UpperBody:offsetPivot(crouchPos):pos(-crouchPos.x_z / 2 + crouchPos._y_)
	parts.group.Player:pos(crouchPos.x_z + crouchPos._y_ * 2)
	
end