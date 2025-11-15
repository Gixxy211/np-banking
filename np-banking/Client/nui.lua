-- Make TwoNa available inside NUI callbacks
local TwoNa = exports["2na_core"]:getSharedObject()

-- Exit bank menu
RegisterNUICallback("exitMenu", function()
    TriggerEvent("np-banking:Client:BankMenu:Hide")
end)

-- Deposit money
RegisterNUICallback("deposit", function(modalData, cb)
    TwoNa.TriggerServerCallback(
        "np-banking:Server:DepositMoney",
        { accountId = modalData.account.id, amount = modalData.action.amount, description = modalData.action.description },
        function(data)
            if data then
                SendNUIMessage({
                    action = "updateAccounts",
                    accounts = data
                })
            else
                cb(nil)
            end
        end
    )
end)

-- Transfer money
RegisterNUICallback("transfer", function(modalData, cb)
    TwoNa.TriggerServerCallback(
        "np-banking:Server:TransferMoney",
        { accountId = modalData.account.id, amount = modalData.action.amount, description = modalData.action.description, targetId = modalData.action.targetId },
        function(data)
            if data then
                SendNUIMessage({
                    action = "updateAccounts",
                    accounts = data
                })
            else
                cb(nil)
            end
        end
    )
end)

-- Withdraw money
RegisterNUICallback("withdraw", function(modalData, cb)
    TwoNa.TriggerServerCallback(
        "np-banking:Server:WithdrawMoney",
        { accountId = modalData.account.id, amount = modalData.action.amount, description = modalData.action.description },
        function(data)
            if data then
                SendNUIMessage({
                    action = "updateAccounts",
                    accounts = data
                })
            else
                cb(nil)
            end
        end
    )
end)

-- Create new account
RegisterNUICallback("create-account", function(modalData, cb)
    TwoNa.TriggerServerCallback(
        "np-banking:Server:CreateAccount",
        { accountName = modalData.action.name },
        function(data)
            if data then
                SendNUIMessage({
                    action = "addAccount",
                    account = data
                })
            else
                cb(nil)
            end
        end
    )
end)

-- Delete account
RegisterNUICallback("delete-account", function(modalData, cb)
    TwoNa.TriggerServerCallback(
        "np-banking:Server:DeleteAccount",
        { accountId = modalData.account.id },
        function(success)
            if success then
                SendNUIMessage({
                    action = "deleteAccount",
                    account = modalData.account
                })
            else
                cb(false)
            end
        end
    )
end)
