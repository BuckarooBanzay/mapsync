--- returns an iterator function for the coordinate range
function mapsync.pos_iterator(pos1, pos2)
	local total_count = ((pos2.x - pos1.x) + 1) * ((pos2.y - pos1.y) + 1) * ((pos2.z - pos1.z) + 1)
	local pos
	return function()
		if not pos then
			-- init, copy values
			pos = { x=pos1.x, y=pos1.y, z=pos1.z }
		else
			-- shift x
			pos.x = pos.x + 1
			if pos.x > pos2.x then
				-- shift z
				pos.x = pos1.x
				pos.z = pos.z + 1
				if pos.z > pos2.z then
					--shift y
					pos.z = pos1.z
					pos.y = pos.y + 1
					if pos.y > pos2.y then
						-- done
						pos = nil
					end
				end
			end
		end

		return pos
	end, total_count
end