-- sanity checks
assert(type(advtrains.load_version_4) == "function")
assert(type(advtrains.ndb.save_callback) == "function")
assert(type(advtrains.ndb.load_callback) == "function")
assert(type(advtrains.read_component) == "function")
assert(type(advtrains.save_component) == "function")
assert(type(serialize_lib.load_atomic) == "function")
assert(type(serialize_lib.save_atomic_multiple) == "function")
assert(type(advtrains.fpath) == "string")

-- local old_advtrains_read_component = advtrains.read_component
function advtrains.read_component(name)
    assert(name == "version")
    return 4
end

-- local old_advtrains_save_component = advtrains.save_component
function advtrains.save_component()
    -- no-op
end

local old_load_atomic = serialize_lib.load_atomic
function serialize_lib.load_atomic(filename, load_callback)
    print(dump({
        fn = "serialize_lib.load_atomic",
        filename = filename,
        fpath = advtrains.fpath,
        relpath = string.sub(filename, #advtrains.fpath + 2)
    }))
    return old_load_atomic(filename, load_callback)
end

local old_save_atomic_multiple = serialize_lib.save_atomic_multiple
function serialize_lib.save_atomic_multiple(parts_table, filename_prefix, callback_table, config)
    print(dump({
        fn = "serialize_lib.save_atomic_multiple",
        parts_table = parts_table,
        filename_prefix = filename_prefix,
        config = config
    }))
    return old_save_atomic_multiple(parts_table, filename_prefix, callback_table, config)
end

local advtrains_parts = {"atlatc.ls", "interlocking.ls", "core.ls", "lines.ls", "ndb4.ls"}

minetest.register_chatcommand("mapsync_save_advtrains", {
    privs = { mapsync = true },
    func = function()
        for _, part in ipairs(advtrains_parts) do
            local path = advtrains.fpath .. "_" .. part
            print(path)
        end
    end
})