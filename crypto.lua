-- simple cipher with sha1 as kdf and xor'ed in EBF mode
-- NOTE: this is not a secure cipher, don't use it for anything sensitive!

-- references:
-- https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation#Electronic_codebook_(ECB)
-- https://en.wikipedia.org/wiki/Key_derivation_function
-- https://en.wikipedia.org/wiki/SHA-1

local byte, char, xor, insert = string.byte, string.char, mapsync.xor, table.insert

local function get_block_key(key)
    return minetest.sha1(key, true)
end

function mapsync.encrypt(key, data)
    local bk = get_block_key(key)
    assert(#bk == 20)
    local ki = 1
    local out = {}
    for i = 1,#data do
        insert(out, char(xor(byte(data, i), byte(bk, ki))))
        ki = ki + 1
        if ki > #bk then
            ki = 1
        end
    end
    return table.concat(out)
end

function mapsync.decrypt(key, data)
    return mapsync.encrypt(key, data)
end