
-- type => fn(backend_def)
local backend_types = {}

function mapsync.register_backend_type(name, fn)
    backend_types[name] = fn
end

-- name => backend_def
local backends = {}

-- register a map backend
function mapsync.register_backend(name, backend_def)
    local backend_fn = backend_types[backend_def.type]
    if type(backend_fn) == "function" then
        backend_fn(backend_def)
    else
        error("unknown backend type: '" .. backend_def.type .. "' for backend '" .. name .. "'")
    end

    backend_def.name = name
    -- default to always-on backend if no selector specified
    backend_def.select = backend_def.select or function() return true end
    backends[name] = backend_def
end

-- unregisters a backend
function mapsync.unregister_backend(name)
    backends[name] = nil
end

-- returns all backends
function mapsync.get_backends()
    return backends
end

-- returns the backend by name or nil
function mapsync.get_backend(name)
    return backends[name]
end

-- returns the matched backends
function mapsync.select_backends(chunk_pos)
    local matched_backends = {}
    for name, backend_def in pairs(backends) do
        if backend_def.select(chunk_pos) then
            matched_backends[name] = backend_def
        end
    end
    return matched_backends
end

-- returns the first match or nil
function mapsync.select_backend(chunk_pos)
    for _, backend_def in pairs(backends) do
        if backend_def.select(chunk_pos) then
            return backend_def
        end
    end
end