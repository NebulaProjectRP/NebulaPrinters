util.AddNetworkString("Nebula.Printers:RequestMoney")
util.AddNetworkString("Nebula.Printers:UpdateState")
util.AddNetworkString("Nebula.Printers:DoUpgrade")
util.AddNetworkString("Nebula.Printers:ToggleFans")

net.Receive("Nebula.Printers:UpdateState", function(l, ply)
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    if (ply:GetEyeTrace().Entity ~= ent) then
        ply:addWarning("Attempting to set state on a printer they are not near.", WARNING_MEDIUM, debug.traceback())
        return
    end
    
    local owner = ent:Getowning_ent():getGang()
    if (ent:Getowning_ent() != ply) then
        if (owner:getGang() and owner:getGang() != ply:getGang()) then return end
    end
    
    ent:UpdateState(!ent:GetIsOn(), ply)
end)

net.Receive("Nebula.Printers:DoUpgrade", function(l, ply)
    local ent = net.ReadEntity()
    local upgrade = net.ReadUInt(3)
    if not IsValid(ent) then return end
    
    local data = NebulaPrinters.Upgrades[upgrade]
    if data then
        if (!ply:canAfford(data.Price)) then
            DarkRP.notify(ply, 1, 4, "You can't afford this upgrade.")
            return
        end

        if (ent[data.Get](ent) >= NebulaPrinters:GetMaxUpgrade(ply, upgrade)) then
            DarkRP.notify(ply, 1, 4, "You can't upgrade this printer any further.")
            return
        end

        ply:addMoney(-data.Price)
        data.func(ent)
    end
end)

net.Receive("Nebula.Printers:ToggleFans", function(l, ply)
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end

    if (ply:GetEyeTrace().Entity ~= ent) then
        ply:addWarning("Attempting to set state on a printer they are not near.", WARNING_MEDIUM, debug.traceback())
        return
    end
    
    local owner = ent:Getowning_ent():getGang()
    if (ent:Getowning_ent() != ply) then
        if (owner:getGang() and owner:getGang() != ply:getGang()) then
            DarkRP.notify(ply, 1, 4, "You can't toggle fans on a printer that isn't yours.")
            return
        end
    end

    ent:ToggleFans()
end)

net.Receive("Nebula.Printers:RequestMoney", function(l, ply)
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    if (ply:GetEyeTrace().Entity ~= ent) then
        ply:addWarning("Attempting to request money on a printer they are not near.", WARNING_HIGH, debug.traceback())
        return
    end

    if (ent:GetMoney() < NebulaPrinters.Config.MinimumRequired) then
        DarkRP.notify(ply, 1, 4, "This printer doesn't have enough money to print.")
        return
    end

    local owner = ent:Getowning_ent():getGang()
    if (ent:Getowning_ent() != ply) then
        if (owner:getGang() and owner:getGang() != ply:getGang()) then
            ent:StartSyphoning(ply)
            return
        end
    end

    ply:addMoney(ent:GetMoney())
    ent:SetMoney(0)
    ent:EmitSound("buttons/bell1.wav")
end)