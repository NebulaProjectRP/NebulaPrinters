AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Printer"
ENT.Category = "NebulaRP"
ENT.Spawnable = true

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "IsOn")
    self:NetworkVar("Int", 0, "Money")
    self:NetworkVar("Int", 1, "Printers")
    self:NetworkVar("Int", 2, "SpeedUpgrade")
    self:NetworkVar("Int", 3, "RaidUpgrade")
    self:NetworkVar("Int", 4, "Capacity")
    self:NetworkVar("Entity", 0, "owning_ent")
    self:NetworkVar("Bool", 1, "FansOn")
    self:NetworkVar("Entity", 1, "Syphon")
    self:SetFansOn(true)
end

function ENT:GetMoneyPerSecond()
    local base = self:GetPrinters() * (NebulaPrinters.Config.MoneyPerTick / NebulaPrinters.Config.TickDelay)
    base = base + (base * (self:GetSpeedUpgrade() / 10))

    local multiplier = hook.Run("GetPrinterMoneyMultiplier", self, self:Getowning_ent()) or 1

    if (self:GetFansOn()) then
        multiplier = multiplier * 1.25
    end

    return math.Round(base * multiplier)
end