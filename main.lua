
-- [[ Koji HUD: Remote Loader ]]
local data_url = "https://raw.githubusercontent.com/jiop9981qwer-byte/MurderDuelScript/refs/heads/main/main.lua"
local key = "KOJI_HUD_SECRET_KEY"

local function decode_base64(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r, f = '', (b:find(x) - 1)
        for i = 6, 1, -1 do r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d%d%d%d%d%d', function(x)
        local c = 0
        for i = 1, 8 do c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0) end
        return string.char(c)
    end))
end

local function xor_decrypt(data, key)
    local res = {}
    for i = 1, #data do
        local b = data:byte(i)
        local k = key:byte((i - 1) % #key + 1)
        -- bit32.bxor 대신 산술 연산으로 호환성 확보 시도 (또는 bit32 체크)
        local bxor = bit32 and bit32.bxor or function(a,b)
            local r, p, t = 0, 1, {0,1,2,3,4,5,6,7}
            for i=0,7 do
                local aa, bb = a%2, b%2
                if aa ~= bb then r = r + p end
                a, b, p = (a-aa)/2, (b-bb)/2, p*2
            end
            return r
        end
        table.insert(res, string.char(bxor(b, k)))
    end
    return table.concat(res)
end

local success, encoded_data = pcall(function()
    return game:HttpGet(data_url)
end)

if success then
    local decrypted = xor_decrypt(decode_base64(encoded_data), key)
    local func, err = loadstring(decrypted)
    if func then
        task.spawn(function()
            local s, e = pcall(func)
            if not s then warn("스크립트 실행 중 오류: " .. tostring(e)) end
        end)
    else
        warn("복호화된 스크립트 구문 오류: " .. tostring(err))
    end
else
    warn("데이터 로딩 실패: GitHub URL을 확인하세요.")
end
