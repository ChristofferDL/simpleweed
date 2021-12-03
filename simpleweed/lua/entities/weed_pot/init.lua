AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("SIMPLEWEED:OpenMenu")
util.AddNetworkString("SIMPLEWEED:PurchaseSeed")
util.AddNetworkString("SIMPLEWEED:ChatNotification")

function ENT:Initialize()
	self:SetModel("models/nater/weedplant_pot.mdl") -- Initial Model
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self.IsCurrentlyGrowing = false
	self.IsFinishedGrowing = false
	self.GrowTime = 0
	self:SetWeedGrowStatus("Press 'E' to purchase seeds")
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:Use(a,c)
	if !IsValid(a) then return end
	if !self.IsCurrentlyGrowing then
		net.Start("SIMPLEWEED:OpenMenu")
		net.WriteEntity(a)
		net.WriteEntity(self)
		net.Send(a)
	end
	net.Receive("SIMPLEWEED:PurchaseSeed", function()
		local id = net.ReadInt(32)
		seedData = SIMPLEWEED.Types[id]
		if a:canAfford(seedData.price) and self.IsCurrentlyGrowing == false and self.IsFinishedGrowing == false then 
			ChatNotify(a,"Purchased "..seedData.name.." seed for "..DarkRP.formatMoney(seedData.price))
			a:addMoney(-seedData.price)
			self:SetWeedGrowStatus("GROWING: "..seedData.name)
			self.GrowStatus = "feit"
			self.IsCurrentlyGrowing = true
			self.GrowTime = CurTime() + seedData.time
			self:SetModel("models/nater/weedplant_pot_planted.mdl") -- Stage 1
			timer.Simple(seedData.time * 0.10, function()
				if (!IsValid(self)) then return end
				self:SetModel("models/nater/weedplant_pot_growing1.mdl") -- Stage 2
			end)
			timer.Simple(seedData.time * 0.20, function()
				if (!IsValid(self)) then return end
				self:SetModel("models/nater/weedplant_pot_growing2.mdl") -- Stage 3
			end)
			timer.Simple(seedData.time * 0.40, function()
				if (!IsValid(self)) then return end
				self:SetModel("models/nater/weedplant_pot_growing3.mdl") -- Stage 4
			end)
			timer.Simple(seedData.time * 0.60, function()
				if (!IsValid(self)) then return end
				self:SetModel("models/nater/weedplant_pot_growing4.mdl") -- Stage 5
			end)
			timer.Simple(seedData.time * 0.80, function()
				if (!IsValid(self)) then return end
				self:SetModel("models/nater/weedplant_pot_growing5.mdl") -- Stage 6
			end)
			timer.Simple(seedData.time * 0.95, function()
				if (!IsValid(self)) then return end
				self:SetModel("models/nater/weedplant_pot_growing6.mdl") -- Stage 6
			end)
		else
			ChatNotify(a,"You cannot afford this.")
		end
	end)

	if self.IsFinishedGrowing then
		self:SetModel("models/nater/weedplant_pot.mdl") -- Reset Model
		self.IsFinishedGrowing = false
		DarkRP.createMoneyBag(self:GetPos() + Vector(0,0,25), math.random(seedData.sellMin, seedData.sellMin))
		self:SetWeedGrowStatus("Press 'E' to purchase seeds")
	end 
end

function ENT:Think()
	if self.IsCurrentlyGrowing then
		if self.GrowTime <= CurTime() then
			self.IsFinishedGrowing = true
			self.IsCurrentlyGrowing = false
			self:SetModel("models/nater/weedplant_pot_growing7.mdl") -- Final Stage
			self:SetWeedGrowStatus("Finished Growing")
		end
	end
end

function ENT:OnTakeDamage(dmg)
	local a = dmg:GetInflictor()
	self:TakePhysicsDamage(dmg)

	self.PotHealth = self.PotHealth - dmg:GetDamage()
	if self.PotHealth <= 0 then
		self:Remove()
		ChatNotify(a,"You destroyed a weed pot")
	end
end

function ChatNotify(ply,text)
	net.Start("SIMPLEWEED:ChatNotification")
	net.WriteString(text)
	net.Send(ply)
end