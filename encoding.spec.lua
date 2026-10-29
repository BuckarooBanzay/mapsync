mtt.register("encode/decode uint16", function(callback)
    for _, v in ipairs({0, 1, 255, 256, 257, 4096, 0x1234, 65534, 65535}) do
        local str = mapsync.encode_uint16(v)
        assert(#str == 2)
        assert(mapsync.decode_uint16(str) == v)
    end

    -- little endian
    assert(mapsync.encode_uint16(0x0102) == string.char(0x02, 0x01))

    -- offset
    local str = "xx" .. mapsync.encode_uint16(0xABCD) .. mapsync.encode_uint16(7)
    assert(mapsync.decode_uint16(str, 2) == 0xABCD)
    assert(mapsync.decode_uint16(str, 4) == 7)

    callback()
end)

mtt.register("encode uint32", function(callback)
    -- little endian
    assert(mapsync.encode_uint32(0) == string.char(0, 0, 0, 0))
    assert(mapsync.encode_uint32(1) == string.char(1, 0, 0, 0))
    assert(mapsync.encode_uint32(0x01020304) == string.char(4, 3, 2, 1))
    assert(mapsync.encode_uint32(256) == string.char(0, 1, 0, 0))

    -- values above 2^31
    assert(mapsync.encode_uint32(0x80000000) == string.char(0, 0, 0, 0x80))
    assert(mapsync.encode_uint32(0xFFFFFFFF) == string.char(255, 255, 255, 255))

    callback()
end)
