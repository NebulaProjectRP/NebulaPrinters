NebulaPrinters = NebulaPrinters or {}

AddCSLuaFile("printers/shared.lua")
AddCSLuaFile("printers/cl_init.lua")

include("printers/shared.lua")

if SERVER then
    include("printers/sv_init.lua")
end
