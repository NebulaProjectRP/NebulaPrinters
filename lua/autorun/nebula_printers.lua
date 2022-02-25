NebulaPrinters = NebulaPrinters or {}

AddCSLuaFile("printers/shared.lua")
AddCSLuaFile("printers/cl_init.lua")

include("printers/shared.lua")
if CLIENT then
    include("printers/cl_init.lua")
else
    include("printers/sv_init.lua")
end
