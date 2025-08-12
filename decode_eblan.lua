-- Attempt to decode MoonSec V3 protected file
-- Read the file content
local file = io.open("eblan", "r")
if not file then
    print("Could not open file eblan")
    return
end

local content = file:read("*all")
file:close()

print("File size:", #content, "bytes")
print("First 200 characters:")
print(string.sub(content, 1, 200))

-- Try to load and execute the content
print("\nAttempting to execute the protected code...")
local success, result = pcall(loadstring, content)
if success and result then
    print("Code loaded successfully, attempting to execute...")
    local exec_success, exec_result = pcall(result)
    if exec_success then
        print("Execution successful!")
        if exec_result then
            print("Result:", exec_result)
        end
    else
        print("Execution failed:", exec_result)
    end
else
    print("Failed to load code:", result)
end