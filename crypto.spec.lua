mtt.register("mapsync.encrypt < 20 bytes", function(callback)
    local key = "mykey"
    local plaintext = "Hello world"
    local encrypted = mapsync.encrypt(key, plaintext)
    assert(plaintext ~= encrypted)
    assert(#plaintext == #encrypted)
    local plaintext2 = mapsync.decrypt(key, encrypted)
    assert(plaintext == plaintext2)
    callback()
end)

mtt.register("mapsync.encrypt > 20 bytes", function(callback)
    local key = "mykey"
    local plaintext = "Hello world"
    for _=1,10 do
        plaintext = plaintext .. plaintext
    end

    local encrypted = mapsync.encrypt(key, plaintext)
    assert(plaintext ~= encrypted)
    assert(#plaintext == #encrypted)
    local plaintext2 = mapsync.decrypt(key, encrypted)
    assert(plaintext == plaintext2)
    callback()
end)

mtt.register("mapsync.encrypt benchmark", function(callback)
    local key = "mykey"
    local t = {}
    for _=1,1000*1000 do
        table.insert(t, "x")
    end
    local plaintext = table.concat(t)

    local t1 = minetest.get_us_time()
    local encrypted = mapsync.encrypt(key, plaintext)
    local t2 = minetest.get_us_time()
    print("encryption of " .. #plaintext .. " bytes took " .. (t2 - t1) .. " us")
    -- make sure 1MB is en-/decrypted in under 100 ms
    assert( (t2 - t1) < 100*1000)

    assert(plaintext ~= encrypted)
    assert(#plaintext == #encrypted)
    callback()
end)