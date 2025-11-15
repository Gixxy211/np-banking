local QBCore = exports['qb-core']:GetCoreObject()
local TwoNa = exports["2na_core"]:getSharedObject()

local pedSpawned = false
local peds = { basic = {}, adv = {} }
local blips = {}

-- Cleanup peds and blips
local function deletePeds()
    for _, ped in ipairs(peds.basic) do if DoesEntityExist(ped) then DeletePed(ped) end end
    for _, ped in ipairs(peds.adv) do if DoesEntityExist(ped) then DeletePed(ped) end end
    for _, blip in ipairs(blips) do if DoesBlipExist(blip) then RemoveBlip(blip) end end
    peds.basic = {}
    peds.adv = {}
    blips = {}
    pedSpawned = false
end

-- Spawn NPCs
local function createPeds()
    if pedSpawned then return end
    if not Config or not Config.peds then return end

    for _, cfg in ipairs(Config.peds) do
        local modelHash = joaat(cfg.model)
        RequestModel(modelHash)
        local waitStart = GetGameTimer()
        while not HasModelLoaded(modelHash) do
            Wait(0)
            if GetGameTimer() - waitStart > 5000 then
                break
            end
        end

        local coords = cfg.coords
        local bankPed = CreatePed(0, modelHash, coords.x, coords.y, coords.z - 1.0, coords.w, false, false)

        if DoesEntityExist(bankPed) then
            TaskStartScenarioInPlace(bankPed, 'PROP_HUMAN_STAND_IMPATIENT', 0, true)
            FreezeEntityPosition(bankPed, true)
            SetEntityInvincible(bankPed, true)
            SetBlockingOfNonTemporaryEvents(bankPed, true)

            if cfg.createAccounts then
                table.insert(peds.adv, bankPed)
            else
                table.insert(peds.basic, bankPed)
            end

            local blip = AddBlipForCoord(coords.x, coords.y, coords.z - 1.0)
            SetBlipSprite(blip, 108)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, 2)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(cfg.name or "Bank")
            EndTextCommandSetBlipName(blip)
            table.insert(blips, blip)
        end

        Wait(10)
    end

    pedSpawned = true
end

-- Open bank menu and fetch accounts/transactions
local function OpenBankMenu(isATM)
    TwoNa.TriggerServerCallback("np-banking:Server:GetUserAccounts", {}, function(bankData)
        if not bankData then return end
        SendNUIMessage({
            action = "showMenu",
            playerName = bankData.playerName,
            accounts = bankData.accounts or {},
            transactions = bankData.transactions or {},
            atm = isATM
        })
        SetNuiFocus(true, true)
    end)
end

-- Hide menu
RegisterNetEvent("np-banking:Client:BankMenu:Hide")
AddEventHandler("np-banking:Client:BankMenu:Hide", function()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "hideMenu" })
end)

-- Show bank menu (used by NPCs and generic triggers)
RegisterNetEvent("np-banking:Client:BankMenu:Show")
AddEventHandler("np-banking:Client:BankMenu:Show", function(data)
    local isATM = false
    if type(data) == "boolean" then
        isATM = data
    elseif type(data) == "table" then
        if data.args and data.args.atm ~= nil then
            isATM = data.args.atm
        elseif data.atm ~= nil then
            isATM = data.atm
        end
    end
    OpenBankMenu(isATM)
end)

-- ATM interaction
RegisterNetEvent("np-banking:Client:OpenBankUI")
AddEventHandler("np-banking:Client:OpenBankUI", function(data)
    local isATM = false
    if type(data) == "boolean" then
        isATM = data
    elseif type(data) == "table" then
        if data.args and data.args.atm ~= nil then
            isATM = data.args.atm
        elseif data.atm ~= nil then
            isATM = data.atm
        end
    end

    local ped = PlayerPedId()
    local function fetchAndOpen()
        OpenBankMenu(isATM)
    end

    if isATM then
        TaskStartScenarioInPlace(ped, "PROP_HUMAN_ATM", 0, true)
        QBCore.Functions.Progressbar("banking", "Accessing ATM...", 3000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function()
            ClearPedTasksImmediately(ped)
            fetchAndOpen()
        end, function()
            ClearPedTasksImmediately(ped)
            QBCore.Functions.Notify("Cancelled", "error")
        end)
    else
        fetchAndOpen()
    end
end)

-- Register qb-target
CreateThread(function()
    createPeds()
    while not pedSpawned do Wait(50) end
    Wait(50)

    if #peds.basic > 0 then
        exports['qb-target']:AddTargetEntity(peds.basic, {
            options = {{
                type = "client",
                event = "np-banking:Client:BankMenu:Show",
                icon = "fas fa-money-check",
                label = "View Bank",
                args = {}
            }},
            distance = 5.5
        })
    end

    if #peds.adv > 0 then
        exports['qb-target']:AddTargetEntity(peds.adv, {
            options = {
                {
                    type = "client",
                    event = "np-banking:Client:BankMenu:Show",
                    icon = "fas fa-money-check",
                    label = "View Bank",
                    args = {}
                },
                {
                    type = "client",
                    event = "np-banking:Client:BankMenu:Show",
                    icon = "fas fa-clipboard-list",
                    label = "Manage Bank",
                    args = {}
                }
            },
            distance = 5.5
        })
    end

    if Config.atms and #Config.atms > 0 then
        exports['qb-target']:AddTargetModel(Config.atms, {
            options = {{
                type = "client",
                event = "np-banking:Client:OpenBankUI",
                icon = "fas fa-money-check",
                label = "Use ATM",
                args = { atm = true }
            }},
            distance = 2.5
        })
    end
end) -- <--- THIS END closes the CreateThread

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        deletePeds()
    end
end)
