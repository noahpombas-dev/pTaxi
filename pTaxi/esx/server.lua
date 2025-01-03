-- Made with ❤️ by noahpombas.ch
ESX = exports["es_extended"]:getSharedObject()

RegisterServerEvent("taxi:verificarSaldo")
AddEventHandler("taxi:verificarSaldo", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local saldo = xPlayer.getAccount('bank').money

    if saldo >= Pombas.minBalance then 
        TriggerClientEvent("taxi:saldoVerificado", source, true)
    else
        TriggerClientEvent("taxi:saldoVerificado", source, false)
    end
end)

RegisterServerEvent("taxi:chargeFullPrice")
AddEventHandler("taxi:chargeFullPrice", function(preco)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer.getAccount('bank').money >= preco then
        xPlayer.removeAccountMoney('bank', preco)
        TriggerClientEvent('esx:showNotification', _source, "Você foi cobrado pelo valor total da viagem: $" .. preco)
    else
        TriggerClientEvent('esx:showNotification', _source, "Você não tem dinheiro suficiente para pagar a viagem!")
    end
end)
-- Made with ❤️ by noahpombas.ch