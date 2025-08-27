local executor = require(script.Parent.utils.executor)

local CONFIG_PATH = "era_like/config.json"

local M = {}

function M.load()
    local data = executor.readFile(CONFIG_PATH)
    if not data then return {} end
    local ok, decoded = pcall(function()
        return game:GetService("HttpService"):JSONDecode(data)
    end)
    if ok and decoded then return decoded end
    return {}
end

function M.save(tbl)
    if not executor.features.filesystem then return end
    local ok, encoded = pcall(function()
        return game:GetService("HttpService"):JSONEncode(tbl)
    end)
    if ok then
        executor.writeFile(CONFIG_PATH, encoded)
    end
end

return M

