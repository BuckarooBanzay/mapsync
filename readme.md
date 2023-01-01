mapsync mod

![](https://github.com/BuckarooBanzay/mapsync/workflows/luacheck/badge.svg)
![](https://github.com/BuckarooBanzay/mapsync/workflows/test/badge.svg)
[![License](https://img.shields.io/badge/License-MIT%20and%20CC%20BY--SA%203.0-green.svg)](license.txt)
[![Download](https://img.shields.io/badge/Download-ContentDB-blue.svg)](https://content.minetest.net/packages/BuckarooBanzay/mapsync)

# Overview

Snychronized the ingame map with a lua-backend

Supported lua-backends:
* `fs` local filesystem (can be in a world- or mod-folder)

Planned backends:
* `http` http/webdav backend

# Howto

Create a new mod (or use an existing one) and add the backend-registration:

For storage in a world-folder:
```lua
local path = minetest.get_worldpath() .. "/mymap"
-- ensure the path exists
minetest.mkdir(path)

-- register the backend
mapsync.register_backend("my-backend", {
    type = "fs",
    path = path
})
```

To store it in a mod-folder:
```lua
-- store and load the map in the "map" folder of the "my-mod" mod:
-- NOTE: the `mapsync` mod needs to be in the `secure.trusted_mods` setting for write-access
mapsync.register_backend("my-backend", {
    type = "fs",
    path = minetest.get_modpath("my-mod") .. "/map"
})
```

## Restricting the backend to a world-region

The backend can implement the `select` function to only synchronize a subset of the world:
```lua
mapsync.register_backend("my-backend", {
    type = "fs",
    path = minetest.get_worldpath() .. "/mymap",
    select = function(chunk_pos)
        -- only save/load chunks between the 10 and -10 y-chunk layer
        return chunk_pos.y < 10 and chunk_pos.y > -10
    end
})
```

# Commands

* `mapsync_autosave [on|off]` enable or disable the autosave process
* `mapsync_save` saves the current chunk to the available backend

# Privs

* `mapsync` allows the player to use the mapsync commands and enables the hud

## Testing

Requirements:
* Docker
* docker-compose

Usage:
```bash
docker-compose up --build
```

# License

* Code: MIT
* Textures: CC-BY-SA 3.0 (http://www.small-icons.com/packs/16x16-free-application-icons.htm)
