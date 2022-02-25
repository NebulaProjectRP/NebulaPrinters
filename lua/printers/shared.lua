NebulaPrinters.Config = {
    Health = 200,
    MinimumRequired = 50000,
    MoneyPerPrinter = 10000,
    MoneyPerTick = 25,
    TickDelay = 1,
    VIPPrinters = 2,
}

NebulaPrinters.Upgrades = {
    [1] = {
        Name = "Printers",
        Maxed = "Printers Maxed",
        Get = "GetPrinters",
        Icon = Material("oneprint/upgrades/server.png"),
        Upgrades = 4,
        VIP = 2,
        Price = 10000,
        func = function(ent)
            ent:AddPrinter()
        end
    },
    [2] = {
        Name = "Overclock",
        Maxed = "Capacity Maxed",
        Get = "GetSpeedUpgrade",
        Icon = Material("oneprint/upgrades/overclocking.png"),
        Upgrades = 3,
        VIP = 2,
        Price = 50000,
        func = function(ent)
            ent:SetSpeedUpgrade(ent:GetSpeedUpgrade() + 1)
        end
    },
    [3] = {
        Name = "Capacity",
        Maxed = "Fully Bundled",
        Get = "GetCapacity",
        Icon = Material("oneprint/shop.png"),
        Upgrades = 3,
        VIP = 2,
        Price = 75000,
        func = function(ent)
            ent:SetCapacity(ent:GetCapacity() + 1)
        end
    },
    [4] = {
        Name = "Security",
        Maxed = "Fully Secured",
        Get = "GetRaidUpgrade",
        Icon = Material("oneprint/upgrades/defense.png"),
        Upgrades = 3,
        VIP = 2,
        Price = 75000,
        func = function(ent)
            ent:SetRaidUpgrade(ent:GetRaidUpgrade() + 1)
        end
    }
}

function NebulaPrinters:GetMaxUpgrade(ply, id)
    return (ply:isVip() and self.Upgrades[id].VIP or 0) + self.Upgrades[id].Upgrades
end