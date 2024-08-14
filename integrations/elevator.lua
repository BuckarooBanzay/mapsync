assert(type(elevator.save_elevator) == "function")
assert(type(elevator.motors) == "table")

-- save into backend
local old_elevator_save_elevator = elevator.save_elevator
function elevator.save_elevator()
    mapsync.save_data("elevator", {motors = elevator.motors})
    old_elevator_save_elevator()
end

-- load from backend if available
local data = mapsync.load_data("elevator")
if data and data.motors then
    elevator.motors = data.motors
end