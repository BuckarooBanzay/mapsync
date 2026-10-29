mtt.register("mapsync.pos_iterator", function(callback)
    -- single position
    local iter, count = mapsync.pos_iterator({x=1, y=2, z=3}, {x=1, y=2, z=3})
    assert(count == 1)
    assert(vector.equals({x=1, y=2, z=3}, iter()))
    assert(iter() == nil)

    -- 2x3x4 range
    local pos1, pos2 = {x=-1, y=0, z=5}, {x=0, y=2, z=8}
    iter, count = mapsync.pos_iterator(pos1, pos2)
    assert(count == 24)

    local seen = {}
    local n = 0
    for pos in iter do
        assert(pos.x >= pos1.x and pos.x <= pos2.x)
        assert(pos.y >= pos1.y and pos.y <= pos2.y)
        assert(pos.z >= pos1.z and pos.z <= pos2.z)

        local key = minetest.pos_to_string(pos)
        assert(not seen[key], "position visited twice: " .. key)
        seen[key] = true
        n = n + 1
    end
    assert(n == 24)

    -- iteration order: x fastest, then z, then y
    iter = mapsync.pos_iterator({x=0, y=0, z=0}, {x=1, y=1, z=1})
    local expected = {
        {x=0, y=0, z=0}, {x=1, y=0, z=0},
        {x=0, y=0, z=1}, {x=1, y=0, z=1},
        {x=0, y=1, z=0}, {x=1, y=1, z=0},
        {x=0, y=1, z=1}, {x=1, y=1, z=1}
    }
    for _, exp in ipairs(expected) do
        assert(vector.equals(exp, iter()))
    end
    assert(iter() == nil)

    -- input positions are not mutated
    assert(vector.equals({x=-1, y=0, z=5}, pos1))
    assert(vector.equals({x=0, y=2, z=8}, pos2))

    callback()
end)
