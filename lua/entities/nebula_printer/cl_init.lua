include("shared.lua")

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.FrameAutoAdvance = true
ENT.Side = 460

local scale = 0.05
local faces = surface.GetTextureID("nebularp/printer_faces")
local mouse = Material("oneprint/wb_cursor.png")

ENT.Noise = 0
ENT.Mx, ENT.My = 0, 0
ENT.ScreenName = "Screensaver"

function ENT:ProcessInput(pos, ang)
    local ply = LocalPlayer()
    if (LocalPlayer():GetEyeTrace().Entity != self) then return end

    local ray = util.IntersectRayWithPlane(ply:EyePos(), ply:GetAimVector(), pos, ang:Up())
    if (ray) then
        local posLocal = self:WorldToLocal(ray)
        posLocal.z = posLocal.z * -1 + 62
        posLocal.y = posLocal.y + 11
        self.Mx, self.My = posLocal.y / scale, posLocal.z / scale
    end
end

ENT.HurtAmount = 0
function ENT:FaceController()
    local x, y = self.Side / 2 - (self.Side * .25), 16 + self.Noise / 50
    local w, h = self.Side * .5, self.Side * .5 + self.Noise / 30 - 8

    local id = 0
    if (self:GetMoney() >= self:GetMaxMoney()) then
        id = 3
    end

    if (self.HurtAmount > 0) then
        self.HurtAmount = self.HurtAmount - FrameTime()
        id = 1
    end

    self.Noise = math.random(1, 100) == 1 and 255 or Lerp(FrameTime(), self.Noise, 150)
    if (IsValid(self:GetSyphon()) or self:Health() / NebulaPrinters.Config.Health < 0.25) then
        id = 2
        self.Noise = math.random(30, 255)
        draw.RoundedBox(8, -self.Side / 3 + x + self.Noise, y, w, h, Color(255, 0, 0, self.Noise))
    end
    
    surface.SetTexture(faces)
    surface.SetDrawColor(255, 255, 255, self.Noise)
    surface.DrawTexturedRectUV(x, y, w, h, id * .25, 0, (id * .25) + .25, 1)
end

function ENT:Hurt()
    self.HurtAmount = 3
end

local wasPressed = false
function ENT:AddButton(x, y, w, h, text, icon, func)
    local isHover = self.Mx >= x and self.Mx <= x + w and self.My >= y and self.My <= y + h
    draw.RoundedBox(4, x, y, w, h, Color(255, 255, 255, isHover and 50 or 10))
    draw.RoundedBox(4, x + 1, y + 1, w - 2, h - 2, Color(92, 36, 84, isHover and 200 or 150))
    local fontSize = h <= 48 and 24 or 32
    local tx, _ = 0, 0
    if (h <= 48) then
        tx, _ = draw.SimpleText(text, NebulaUI:Font(fontSize), x + w / 2 + 16, y + h / 2, Color(255, 255, 255, isHover and 200 or 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else
        tx, _ = draw.SimpleText(text, NebulaUI:Font(fontSize), x + w / 2 + 24, y + h / 2 - 2, Color(255, 255, 255, isHover and 200 or 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    surface.SetMaterial(icon)
    surface.SetDrawColor(255, 255, 255, isHover and 200 or 150)
    if (h <= 48) then
        surface.DrawTexturedRect(x + w / 2 - tx / 2 - 22, y + h / 2 - 14, 28, 28)
    else
        surface.DrawTexturedRect(x + w / 2 - tx / 2 - 30, y + h / 2 - 24, 48, 48)
    end
    
    if (not wasPressed and isHover and input.IsKeyDown(KEY_E)) then
        wasPressed = true
        func()
    elseif (not input.IsKeyDown(KEY_E)) then
        wasPressed = false
    end

    return isHover
end

function ENT:AddIconButton(x, y, w, h, icon, func)
    local isHover = self.Mx >= x and self.Mx <= x + w and self.My >= y and self.My <= y + h
    draw.RoundedBox(4, x, y, w, h, Color(255, 255, 255, isHover and 50 or 10))
    draw.RoundedBox(4, x + 1, y + 1, w - 2, h - 2, Color(92, 36, 84, isHover and 200 or 150))

    surface.SetMaterial(icon)
    surface.SetDrawColor(255, 255, 255, isHover and 200 or 150)
    surface.DrawTexturedRectRotated(x + w / 2, y + h / 2, h * .8, h * .8, 0)
    
    if (not wasPressed and isHover and input.IsKeyDown(KEY_E)) then
        wasPressed = true
        func()
    elseif (not input.IsKeyDown(KEY_E)) then
        wasPressed = false
    end

    return isHover
end

local upgrade = Material("oneprint/light.png")
local start = Material("oneprint/start.png")
local pause = Material("oneprint/stop.png")

function ENT:DrawOptions()
    local wi = self.Side / 2 - 32
    self:AddButton(16, 370, wi + 8, 72, "Upgrades", upgrade, function()
        self.ScreenName = "Upgrades"
    end)

    self:AddButton(self.Side / 2 + 8, 370, wi, 72, self:GetIsOn() and "Turn Off" or "Turn On", self:GetIsOn() and pause or start, function()
        net.Start("Nebula.Printers:UpdateState")
        net.WriteEntity(self)
        net.SendToServer()
    end)
end

local bloom = Material("pp/bloom")
local blur = Material("gui/center_gradient")

surface.CreateFont("Printer.MonoSpace", {
    font = "Digital-7 Mono",
    size = 58,
    weight = 500,
    antialias = true,
    shadow = false
})

surface.CreateFont("Printer.MonoSpace.Small", {
    font = "Digital-7 Mono",
    size = 32,
    weight = 500,
    antialias = true,
    shadow = false
})

ENT.CurrentMoney = 0
local extractIcon = Material("oneprint/oneprint_gsw.png")
local gright = Material("vgui/gradient-l", "clamp smooth")
function ENT:ScreenSaver()
    local money = self:GetMoney()
    self.CurrentMoney = Lerp(FrameTime() * 2, self.CurrentMoney, money)
    surface.SetDrawColor(6, 6, 6)
    surface.DrawRect(16, 270, self.Side - 32, 84)

    if (self.My > 270 and self.My < 270 + 84) then
        self:AddButton(16, 270, self.Side - 32, 84, "Extract", extractIcon, function()
            net.Start("Nebula.Printers:RequestMoney")
            net.WriteEntity(self)
            net.SendToServer()
        end)
    else
        local max = money / self:GetMaxMoney()
        surface.SetDrawColor(188, 255, 4)
        surface.DrawRect(16, 270 + 84 - 8, (self.Side - 32) * max, 8)
        if (max < .95) then
            surface.SetMaterial(gright)
            surface.DrawTexturedRect(16 + math.floor((self.Side - 32) * max), 270 + 84 - 8, 16, 8)
        end

        local size = 0
        surface.SetFont("Printer.MonoSpace")
        local w, _ = surface.GetTextSize(DarkRP.formatMoney(math.Round(self.CurrentMoney)))
        size = size + w
        surface.SetFont("Printer.MonoSpace.Small")
        w, _ = surface.GetTextSize(DarkRP.formatMoney(self:GetMoneyPerSecond()))
        size = size + w

        local tx, _ = draw.SimpleText(DarkRP.formatMoney(math.Round(self.CurrentMoney)), "Printer.MonoSpace", self.Side / 2 - size / 2, self.Side - 124, Color(64, 255, 58), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        draw.SimpleText("/" .. DarkRP.formatMoney(self:GetMoneyPerSecond()), "Printer.MonoSpace.Small", self.Side / 2 - size / 2 + tx, self.Side - 124 - 4, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    end
    self:DrawOptions()

end

local upgrade = Material("oneprint/upgrades/server.png")
local back = Material("oneprint/cancel.png")
local turbo = Material("oneprint/upgrades/power.png")
local silence = Material("oneprint/upgrades/silencer.png")

function ENT:DrawUpgrades()
    local offset = 16
    for k, v in pairs(NebulaPrinters.Upgrades) do
        local value = self[v.Get](self)
        if (NebulaPrinters:GetMaxUpgrade(LocalPlayer(), k) > value) then
            local isHover = self:AddIconButton(self.Side - 32 - 64 - 8, offset + 4, 64, 40, v.Icon, function()
                net.Start("Nebula.Printers:DoUpgrade")
                net.WriteEntity(self)
                net.WriteUInt(k, 3)
                net.SendToServer()
            end)
            draw.SimpleText(isHover and DarkRP.formatMoney(v.Price) or v.Name, NebulaUI:Font(48), 32, offset, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        else
            draw.SimpleText(v.Maxed, NebulaUI:Font(48), 32, offset, Color(134, 218, 78), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        local segment = (self.Side - 64) / (v.Upgrades + v.VIP) - 8
        for k = 1, v.Upgrades + v.VIP do
            draw.RoundedBox(4, 32 + (k - 1) * (segment + 8), offset + 56, segment, 24, self[v.Get](self) >= k and Color(235, 235, 235) or Color(75, 75, 75, 255))
        end
        offset = offset + 86
    end

    local wi = self.Side / 2 - 32
    self:AddButton(16, 370, wi + 8, 72, "Go Back", back, function()
        self.ScreenName = "Screensaver"
    end)

    self:AddButton(self.Side / 2 + 8, 370, wi, 72, self:GetFansOn() and "Silent" or "Turbo", self:GetFansOn() and silence or turbo, function()
        net.Start("Nebula.Printers:ToggleFans")
        net.WriteEntity(self)
        net.SendToServer()
    end)
end

function ENT:Draw()
    local pain = self:Health() / NebulaPrinters.Config.Health
    render.SetColorModulation(1, pain, pain)
    self:DrawModel()
    self:SetCycle(RealTime() % 1)
    render.SetColorModulation(1, 1, 1)
    if (halo.RenderedEntity() == self) then return end
    local angles = self:GetAngles()
    local pos = self:GetPos() + self:GetUp() * 62 + self:GetRight() * 11.1 + self:GetForward() * 22
    local trace = LocalPlayer():GetEyeTrace().HitPos
    local mousePos = self:WorldToLocal(trace)
    local plyMoney = string.Comma(LocalPlayer():getDarkRPVar("money") or 0)
    local w, h = 460, 460
    angles:RotateAroundAxis(angles:Up(), 90)
    angles:RotateAroundAxis(angles:Forward(), 75)
    if LocalPlayer():GetPos():Distance(self:GetPos()) > 500 then return end

    self:ProcessInput(pos, angles)

    cam.IgnoreZ(true)
    cam.Start3D2D(pos, angles, scale)
    surface.SetDrawColor(35, 30, 44)
    surface.DrawRect(0, 0, self.Side, self.Side)

    if (self.ScreenName == "Screensaver") then
        self:FaceController()
        self:ScreenSaver()
    elseif (self.ScreenName == "Upgrades") then
        self:DrawUpgrades()
    end
    
    surface.SetMaterial(mouse)
    surface.SetDrawColor(color_white)
    surface.DrawTexturedRect(self.Mx, self.My, 48, 48)
    cam.End3D2D()
    cam.IgnoreZ(false)
end

local from = Color(225, 145, 225)
local to = Color(147, 180, 209)
function ENT:GetTintColor()
    if (!self:GetIsOn()) then
        return Color(25, 25, 25)
    end
    if (self:GetMoney() < self:GetMaxMoney()) then
        local frame = math.cos(RealTime() * 4) / 2 + .5
        return Color(Lerp(frame, from.r, to.r), Lerp(frame, from.g, to.g), Lerp(frame, from.b, to.b))
    end
end

function ENT:DrawTranslucent()
end

matproxy.Add({
    name = "PrinterColor",
    init = function(self, mat, values)
        self.ResultTo = values["$resultvar"]
    end,
    bind = function(self, mat, ent)
        if not IsValid(ent) then return end
        if not ent.GetTintColor then return end
        local col = ent:GetTintColor()
        if (col) then
            mat:SetVector(self.ResultTo, Vector(col.r / 255, col.g / 255, col.b / 255))
        end
    end
})