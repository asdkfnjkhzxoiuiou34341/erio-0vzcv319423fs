local HttpService = game:GetService("HttpService")

local M = {}

local function try(executorFn, ...) 
    local ok, result = pcall(executorFn, ...)
    if ok then return result end
    return nil
end

local function httpGet(url)
    if syn and syn.request then
        local res = syn.request({ Url = url, Method = "GET" })
        return res and res.Body
    end
    if request then
        local res = request({ Url = url, Method = "GET" })
        return res and res.Body
    end
    return game:HttpGet(url)
end

function M.get(url)
    return httpGet(url)
end

return M

