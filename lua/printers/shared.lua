NebulaPrinters.Config = {
    Health = 400,
    MinimumRequired = 30000,
    MoneyPerTick = 12,
    TickDelay = 1,
    VIPPrinters = 2,
}

NebulaPrinters.VIPConfig = {
    ["cosmic"] = {
        extraPrinters = 1 -- Amount of extra printers this rank can have.
    }
}

NebulaPrinters.Upgrades = {
    [1] = {
        Name = "Printers",
        Maxed = "Printers Maxed",
        Get = "GetPrinters",
        Icon = Material("oneprint/upgrades/server.png"),
        Upgrades = 3, -- The amount of upgrades the default player can have.
        Max = 6,
        Price = 3500,
        func = function(ent)
            ent:AddPrinter()
        end
    },
    [2] = {
        Name = "Overclock",
        Maxed = "Capacity Maxed",
        Get = "GetSpeedUpgrade",
        Icon = Material("oneprint/upgrades/overclocking.png"),
        Upgrades = 5, -- The amount of upgrades the default player can have.
        Max = 5, -- The max amount of upgrades anyone can have.
        Price = 7500,
        func = function(ent)
            ent:SetSpeedUpgrade(ent:GetSpeedUpgrade() + 1)
        end
    },
    [3] = {
        Name = "Capacity",
        Maxed = "Fully Bundled",
        Get = "GetCapacity",
        Icon = Material("oneprint/shop.png"),
        Upgrades = 5, -- The amount of upgrades the default player can have.
        Max = 5, -- The max amount of upgrades anyone can have.
        Price = 2500,
        func = function(ent)
            ent:SetCapacity(ent:GetCapacity() + 1)
        end
    },
    [4] = {
        Name = "Security",
        Maxed = "Fully Secured",
        Get = "GetRaidUpgrade",
        Icon = Material("oneprint/upgrades/defense.png"),
        Upgrades = 5, -- The amount of upgrades the default player can have.
        Max = 5, -- The max amount of upgrades anyone can have.
        Price = 2000,
        func = function(ent)
            ent:SetRaidUpgrade(ent:GetRaidUpgrade() + 1)
        end
    }
}

function NebulaPrinters:GetMaxUpgrade(ply, id)
    local config = NebulaPrinters.VIPConfig[ply:getTitle()]
    if id == 1 then return (config and config.extraPrinters or 0) + self.Upgrades[id].Upgrades end
    return self.Upgrades[id].Upgrades
end