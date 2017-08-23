--
-- Created by IntelliJ IDEA.
-- User: undownding
-- Date: 2017/7/5
-- Time: 12:26
-- To change this template use File | Settings | File Templates.
--

local AceAddon =  LibStub("AceAddon-3.0")
local MyKp = AceAddon:NewAddon("MyKillPoints", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")

local KpVaule
local questId = 0

-- 大使任务列表
local emissaryQuests = {
    [42420] = true,
    [42421] = true,
    [42422] = true,
    [42233] = true,
    [42234] = true,
    [42170] = true,
    [43179] = true,
    [46743] = true,
    [46745] = true,
    [46746] = true,
    [46747] = true,
    [46748] = true,
    [46777] = true
}

function MyKp:OnInitialize()
    MyKillPointsDB = MyKillPointsDB or {}
    if (MyKillPointsDB.value == nil) then
        MyKillPointsDB.value = 0
    end

    KpVaule = MyKillPointsDB.value

    self:RegisterChatCommand("mykp", "hanldCommand")
end

function MyKp:OnEnable()
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    self:RegisterEvent("SHOW_LOOT_TOAST_LEGENDARY_LOOTED")
    self:RegisterEvent("QUEST_COMPLETE")

    self:SecureHook(DBM, "EndCombat", "BOSS_KILL")

    self:printKp()
end

function MyKp:OnDisable()
    self:UnregisterMessage("CHALLENGE_MODE_COMPLETED")
    self:UnregisterMessage("SHOW_LOOT_TOAST_LEGENDARY_LOOTED")
    self:UnregisterMessage("QUEST_COMPLETE")
end

-- RAID BOSS 击杀
function MyKp:BOSS_KILL(v, wipe)

    local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
    if (maxPlayers == 5 or instanceMapID < 1027) then
        return
    end

    if (difficultyID == 14) then -- 普通 Raid
        KpVaule = KpVaule + 3
    elseif (difficultyID == 15) then -- 英雄 Raid
        KpVaule = KpVaule + 4
    elseif (difficultyID == 16) then -- 史诗 Raid
        KpVaule = KpVaule + 6
    elseif (difficultyID == 17) then -- 随机团
        KpVaule = KpVaule + 2
    end
    self:printKp()
end

-- 大米
function MyKp:CHALLENGE_MODE_COMPLETED()
    local mapID, level, time, onTime, keystoneUpgradeLevels = C_ChallengeMode.GetCompletionInfo()
    if (onTime) then
        KpVaule = KpVaule + 4
    else
        KpVaule = KpVaule + 3
    end
    self:printKp()
end

function MyKp:QUEST_COMPLETE()
    questId = GetQuestID()
    if (emissaryQuests[questId]) then
        self:RegisterEvent("QUEST_FINISHED")
    end
end

-- 大使任务
function MyKp:QUEST_FINISHED()
    self:UnregisterMessage("QUEST_FINISHED")
    if (emissaryQuests[questId]) then
        KpVaule = KpVaule + 4
        self:printKp()
        questId = 0
    end
end

function MyKp:SHOW_LOOT_TOAST_LEGENDARY_LOOTED()
    self:Print("恭喜出橙！当前 KP 值已清零")
    KpVaule = 0
    MyKillPointsDB.value = 0
end

function MyKp:hanldCommand(args)
    local command, arg = strsplit(" ", args)

    if (command == "cc") then
        KpVaule = 0
    elseif (command == "add") then
        KpVaule = KpVaule + arg
    elseif (command == "dec") then
        KpVaule = KpVaule - arg
    end

    self:printKp()
end

function MyKp:printKp()
    MyKillPointsDB.value = KpVaule
    local precent = 0
    if (KpVaule >= 900) then
        precent = 90
    elseif (KpVaule >= 800) then
        precent = 80
    elseif (KpVaule >= 700) then
        precent = 60
    elseif (KpVaule >= 650) then
        precent = 50
    elseif (KpVaule >= 600) then
        precent = 40
    elseif (KpVaule >= 500) then
        precent = 25
    elseif (KpVaule >= 400) then
        precent = 15
    else
        precent = 10
    end
    self:Print(format("当前 KP 值为 %s，约 %s%% 的玩家在当前 KP 值出了下一件橙|R", KpVaule, precent))
end

