ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Weed Pot"
ENT.Category = "Simple Weed Pots"
ENT.Author = "Christoffer"
ENT.Spawnable = true

ENT.PotHealth = 250

function ENT:SetupDataTables()
    self:NetworkVar("String" , 3, "WeedGrowStatus")
end