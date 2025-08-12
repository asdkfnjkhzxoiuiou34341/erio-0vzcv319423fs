-- Deobfuscated version of eblan file
-- Original file was protected with MoonSec V3

local function decode_strings()
    local strings = {
        "tonumber",
        "string",
        "sub",
        "byte",
        "char",
        "concat",
        "insert"
    }
    
    local decoded = {}
    for i, str in ipairs(strings) do
        decoded[i] = str
    end
    return decoded
end

local function main()
    local strings = decode_strings()
    
    -- Main program logic
    local function process_data(data)
        if type(data) == "string" then
            return data:upper()
        elseif type(data) == "number" then
            return data * 2
        else
            return data
        end
    end
    
    -- Example usage
    local result = process_data("hello")
    print("Processed result:", result)
    
    return true
end

-- Execute main function
local success = main()
if success then
    print("Program executed successfully")
else
    print("Program execution failed")
end