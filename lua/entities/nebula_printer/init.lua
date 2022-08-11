AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr, cs)
    if (!tr.Hit) then return end
    local ent=ents.Create(cs)
    ent:SetPos(tr.HitPos+tr.HitNormal*16)
    ent:Spawn()
    ent:Activate()
    ent:Setowning_ent(ply)
    return ent
end

function ENT:OnRemove()
    if (self.LoopingMachine) then
        self:StopLoopingSound(self.LoopingMachine)
    end
end

function ENT:StartSyphoning(ply)
    self:SetSyphon(ply)
    if (self:GetRaidUpgrade() > 0) then
        DarkRP.notify(self:Getowning_ent(), 1, 4, "Your printer has been tampered")
    end
    self:EmitSound("npc/strider/striderx_alert5.wav")
end

function ENT:Initialize()
    self:SetModel("models/ogl/ogl_oneprint_nebula.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:Activate()
    self:SetHealth(NebulaPrinters.Config.Health)
    for k = 1, 6 do
        self:SetBodygroup(k + 1, 1)
        self:SetBodygroup(k + 7, 1)
        self:SetBodygroup(k + 7 + 6, 1)
        self:SetBodygroup(k + 7 + 12, 1)
    end
    self:GetPhysicsObject():Wake()
    self:AddPrinter()
end

function ENT:AddPrinter()
    if (self:GetPrinters() > 5) then return end
    self:SetPrinters(self:GetPrinters() + 1)

    local offset = (self:GetPrinters() - 1) * 6 
    for k = 1, 4 do
        self:SetBodygroup(self:GetPrinters() + 1, 0)
        self:SetBodygroup(self:GetPrinters() + 1 + k * 6, 0)
    end
    self:EmitSound("doors/door_latch1.wav")
end

function ENT:ToggleFans()
    self:SetFansOn(!self:GetFansOn())
    if (self.LoopingMachine) then
        self:StopLoopingSound(self.LoopingMachine)
    end
    if (self:GetFansOn() and self:GetIsOn()) then
        self.LoopingMachine = self:StartLoopingSound("ambient/machines/lab_loop1.wav")
    end
end

ENT.HealingIn = 0
function ENT:Think()
    if IsValid(self:GetSyphon()) then
        local dist = self:GetPos():Distance(self:GetSyphon():GetPos())
        if (!self:GetSyphon():Alive() or dist > 512) then
            self:EmitSound("npc/strider/strider_step2.wav")
            self:SetSyphon(nil)
            self:NextThink(CurTime())
            return true
        end
        self:EmitSound("npc/strider/strider_minigun.wav", 90, 175, .6)
        local eff =EffectData()
        eff:SetOrigin(self:GetPos() + self:GetForward() * 28 + self:GetUp() * 56)
        eff:SetMagnitude(2)
        eff:SetScale(2)
        eff:SetRadius(16)
        eff:SetNormal(self:GetForward())
        util.Effect("Sparks", eff, true, true)
        local ten = self:GetRaidUpgrade() / 10
        local percent = self:GetMaxMoney() * .025 - ten * self:GetMaxMoney() * .025
        self:GetSyphon():addMoney(percent)
        self:SetMoney(self:GetMoney() - percent)
        if (self:GetMoney() <= 0) then
            self:UpdateState(false, self:GetSyphon())
            self:SetMoney(0)
            self:SetSyphon(nil)
            self:NextThink(CurTime())    
            return true
        end
        self:NextThink(CurTime() + NebulaPrinters.Config.TickDelay + ten * 2)
        return true    
    end

    if (self:GetIsOn()) then
        self:SetMoney(self:GetMoney() + self:GetMoneyPerSecond())
        if (self:GetMoney() > self:GetMaxMoney()) then
            self:SetSkin(1)
            self:SetMoney(math.Round(self:GetMaxMoney()))
            self:SetIsOn(false)
        end
    end

    if (self:Health() != NebulaPrinters.Config.Health and self.HealingIn < CurTime()) then
        self:SetHealth(self:Health() + 15)
        self:SetSkin(2)
        if (self:Health() >= NebulaPrinters.Config.Health) then
            self:SetSkin(0)
            self:SetHealth(NebulaPrinters.Config.Health)
        end
    end

    self:NextThink(CurTime() + NebulaPrinters.Config.TickDelay)
    return true
end

ENT.Cooldown = 0
function ENT:UpdateState(b, triggered)
    if (self.Cooldown > CurTime()) then return end
    self.Cooldown = CurTime() + 1
    if (self:GetPrinters() == 0) then
        DarkRP.notify(triggered, 1, 4, "You need to have at least one printer to use this.")
        self:EmitSound("buttons/button10.wav")
        return
    end
    self:SetIsOn(b)
    local animName = b and (self:GetFansOn() and "printer on" or "moneyfall") or "idle"
    self:SetSequence(animName)
    self:ResetSequence(animName)
    self:EmitSound(b and "buttons/button1.wav" or "buttons/button16.wav")
    if (self.LoopingMachine) then
        self:StopLoopingSound(self.LoopingMachine)
    end
    if (self:GetFansOn() and b) then
        self.LoopingMachine = self:StartLoopingSound("ambient/machines/lab_loop1.wav")
    end
    self:NextThink(CurTime())    
end

function ENT:OnTakeDamage(dmg)
    if (self:Health() <= 0) then return end
    self:SetHealth(self:Health() - dmg:GetDamage())
    self.HealingIn = CurTime() + 5
    self:SetSkin(3)
    if (self:Health() <= 0) then
        local explode = ents.Create( "env_explosion" ) -- creates the explosion
        explode:SetPos( self:GetPos() )
        explode:SetOwner( dmg:GetAttacker() )
        explode:Spawn()
        explode:SetKeyValue( "iMagnitude", "220" )
        explode:Fire( "Explode", 0, 0 )
        self:Remove()
    else
        self:callOnClient(RPC_PVS, "Hurt")
    end
end