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