-- [[ Koji HUD: Remote Loader ]]
-- 사용자가 GitHub 링크를 타고 들어와도 이 코드만 보이며, 실제 핵심 로직은 암호화된 상태로 호출됩니다.

local data_url = "https://raw.githubusercontent.com/jiop9981qwer-byte/MurderDuelScript/main/data.txt"
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
    local res = ""
    for i = 1, #data do
        local b = data:byte(i)
        local k = key:byte((i - 1) % #key + 1)
        res = res .. string.char(bit32.bxor(b, k))
    end
    return res
end

local success, encoded_data = pcall(function()
    return game:HttpGet(data_url)
end)

if success then
    local decrypted = xor_decrypt(decode_base64(encoded_data), key)
    local func, err = loadstring(decrypted)
    if func then
        func()
    else
        warn("로딩 중 오류 발생: " .. tostring(err))
    end
else
    warn("데이터를 불러오지 못했습니다. 인터넷 연결 또는 URL을 확인하세요.")
end
