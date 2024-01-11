mapsync mod

![LuaCheck](https://github.com/BuckarooBanzay/mapsync/workflows/luacheck/badge.svg)
![Integration test](https://github.com/BuckarooBanzay/mapsync/workflows/test/badge.svg)
[![License](https://img.shields.io/badge/License-MIT%20and%20CC%20BY--SA%203.0-green.svg)](license.txt)
[![Download](https://img.shields.io/badge/Download-ContentDB-blue.svg)](https://content.minetest.net/packages/BuckarooBanzay/mapsync)

# Overview

Synchronize the ingame map with a lua-backend

Supported lua-backends:
* `fs` local filesystem (can be in a world- or mod-folder)

Planned backends:
* `http` http/webdav backend

Features:
* Auto-update chunks if a newer version on the backend is found

Planned features:
* Diffing/Merging/Applying changes from multiple sources (git merges for example)
* `placeholder` support

# Use case

* Map-exchange
* Mod integrated maps (like the `modgen` mod but with an additional central mod)
* Adventure maps

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

To save the map you can either turn on autosave with `/mapsync_autosave on` or manually save on or multiple chunks with `/mapsync_save [chunk-range]`.

The saved chunks will now automatically be loaded if the destination area is generated (on mapgen).

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

## Registering multiple backends

Multiple backends can be registered as long as the `select` function is returning an area exclusive to each other (no overlapping regions)

Otherwise the save/load mechanism won't be deterministic

# Storage

Chunks are stored as multiple mapblocks in a zip file in the backend folder:
```
'chunk_(2,0,1).zip'
'chunk_(3,0,1).zip'
'chunk_(3,0,2).zip'
'chunk_(4,0,1).zip'
'chunk_(4,0,2).zip'
```

The contents:
```
# unzip -l chunk_\(2\,0\,1\).zip 
Archive:  chunk_(2,0,1).zip
  Length      Date    Time    Name
---------  ---------- -----   ----
      668  2022-12-25 19:54   metadata.json
  1359872  2022-12-25 19:54   mapdata.bin
     2768  2022-12-25 19:54   manifest.json
---------                     -------
  1363308                     3 files
```

* `metadata.json` the metadata (node-timers, inventories, etc)
* `mapdata.bin` the mapdata (node-ids, param1, param2)
* `manifest.json` the node-id mappings and mapblock-placements inside the exported chunk

# Commands

* `mapsync_autosave [on|off]` enable or disable the autosave process
* `mapsync_save [chunk-range]` saves the current chunk to the available backend (optionally takes a cubic radius as argument)

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
