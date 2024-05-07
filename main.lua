local httpService = cloneref(game:GetService('HttpService'))

local msg = Instance.new('Message', game:GetService('CoreGui'))
msg.Text = 'Starting decompilation...'

--//Credits to lonegladiator for the decompiler
local function decompile(script)
    local success, bytecode = pcall(getscriptbytecode, script)
    if not success then
        warn('Failed to get bytecode:', bytecode)
        return nil
    end

    local response
    pcall(function()
        response = request({
            Url = 'https://unluau.lonegladiator.dev/unluau/decompile',
            Method = 'POST',
            Headers = {
                ['Content-Type'] = 'application/json',
            },
            Body = httpService:JSONEncode({
                version = 5,
                bytecode = crypt.base64.encode(bytecode)
            })
        })
    end)

    if not response or response.StatusCode ~= 200 then
        warn('Failed to get a valid response from decompiler.')
        return nil
    end

    local decoded = httpService:JSONDecode(response.Body)
    if decoded.status ~= 'ok' then
        warn('Decompilation failed:', decoded.status)
        return nil
    end

    return decoded.output
end

--//Main loop
local scripts = {}
for _, obj in ipairs(game:GetDescendants()) do
    if obj:IsA('LocalScript') or obj:IsA('ModuleScript') or (obj:IsA('Script') and obj.RunContext == Enum.RunContext.Client) then
        table.insert(scripts, obj)
    end
end

local total = #scripts
local processed = 0

for _, script in ipairs(scripts) do
    local source = decompile(script)
    if source then
        script.Source = source
        processed = processed + 1
        msg.Text = string.format('Decompiled %d of %d scripts', processed, total)
    end
end

-- Save the game instance
saveinstance(game, {FileName = "saved-" .. tostring(game.PlaceId)})
msg.Text = 'All scripts decompiled and game instance saved.'