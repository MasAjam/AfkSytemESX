RegisterCommand("quitafk", function(source, args, raw)
    TriggerClientEvent("esx_afk:tryExitAFK", source)
end, false)

RegisterCommand("redeemafk", function(source, args, raw)
    local code = args[1]
    if code then
        TriggerClientEvent("esx_afk:clientRedeem", source, code)
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 255},
            args = {"AFK SYSTEM", "❌ Format salah. Gunakan: /redeemafk <kode>"}
        })
    end
end, false)
