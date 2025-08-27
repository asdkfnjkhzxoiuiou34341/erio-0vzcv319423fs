local M = {}

local function has(name)
    local ok, _ = pcall(function() return _G[name] or getfenv()[name] end)
    return ok and (_G[name] ~= nil or getfenv()[name] ~= nil)
end

M.features = {
    filesystem = (typeof(isfile) == "function") and (typeof(writefile) == "function"),
    protectGui = syn and syn.protect_gui ~= nil,
}

function M.readFile(path)
    if not M.features.filesystem then return nil end
    local ok, data = pcall(readfile, path)
    if ok then return data end
    return nil
end

function M.writeFile(path, data)
    if not M.features.filesystem then return false end
    local ok = pcall(writefile, path, data)
    return ok == true
end

return M

