include("shared.lua")

surface.CreateFont("SIMPLEWEED:Title", { font = "Roboto", size = 25, weight = 500})
surface.CreateFont("SIMPLEWEED:Close", { font = "Roboto", size = 25, weight = 500})
surface.CreateFont("SIMPLEWEED:Purchase", { font = "Roboto", size = 14, weight = 550})
surface.CreateFont("SIMPLEWEED:Type", { font = "Roboto", size = 18, weight = 550})
surface.CreateFont("SIMPLEWEED:3D2DText", { font = "Roboto", size = 50, weight = 550})

function ENT:Draw()
	self:DrawModel()
	if self:GetPos():Distance(LocalPlayer():GetPos()) > 200 then return end
	local mins,maxs = self:GetModelBounds()
	local pos = self:GetPos()+Vector(0,0,maxs.z + 15)
	local ang = self:GetAngles()
	local scale = 0.1
	local text = self:GetWeedGrowStatus()
	ang:RotateAroundAxis(ang:Forward(), 90)
	ang.y = LocalPlayer():EyeAngles().y - 90
	cam.Start3D2D(pos,ang,scale)
		draw.SimpleTextOutlined(text,"SIMPLEWEED:3D2DText",0,0,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,2,Color(0,0,0))
	cam.End3D2D()
end

net.Receive("SIMPLEWEED:OpenMenu", function()
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	local frame_height = table.Count(SIMPLEWEED.Types)*2
	local sw,sh = ScrW(),ScrH()
	local frame = vgui.Create("DFrame")
	frame:SetSize(270, 360)
	frame:Center()
	frame:MakePopup()
	frame:SetSizable(false)
	frame:SetDraggable(true)
	frame:ShowCloseButton(false)
	frame:SetTitle("")
	frame.Paint = function(self,w,h)
		draw.RoundedBoxEx(8,0,0,w,35,SIMPLEWEED.Config.Header,true,true,false,false)
		draw.RoundedBoxEx(8,0,35,w,h-35,SIMPLEWEED.Config.Background,false,false,true,true)
		draw.SimpleText("Weed Seeds","SIMPLEWEED:Title",frame:GetWide()*0.25,17.5,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	frame.close = frame:Add("DButton",frame)
	frame.close:SetSize(28,28)
	frame.close:SetPos(frame:GetWide()-28,2)
	frame.close:SetText("")
	frame.close.DoClick = function()
		frame:Remove()
	end
	frame.close.Paint = function()
		draw.SimpleText("x","SIMPLEWEED:Close",6,2,Color(255,100,100))
	end
	frame.seedsPanel = frame:Add("DScrollPanel")
	frame.seedsPanel:Dock(FILL)
	frame.seedsPanel:DockMargin(0,15,0,0)
	frame.seedsPanel.Paint = nil
	for k,v in pairs(SIMPLEWEED.Types) do
		seeds = frame.seedsPanel:Add("DPanel")
		seeds:SetSize(0,45)
		seeds:SetPos(0,15)
		seeds:Dock(TOP)
		seeds:DockMargin(0,0,0,7)
		seeds.Paint = function(self,w,h)
			draw.RoundedBox(8,0,0,w,h,SIMPLEWEED.Config.Header)
		end
		local seedType = seeds:Add("DPanel")
		seedType:Dock(LEFT)
		seedType:SetSize(150,0)
		seedType.Paint = function(self,w,h)
			draw.SimpleText(v.name,"SIMPLEWEED:Type",8,seedType:GetTall()/2,v.color,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
		end
		seeds.Purchase = seeds:Add("DButton")
		seeds.Purchase:Dock(RIGHT)
		seeds.Purchase:DockMargin(5,5,5,5)
		seeds.Purchase:SetText("")
		seeds.Purchase.Paint = function(self,w,h)
			if LocalPlayer():canAfford(v.price) then
				draw.SimpleText("BUY","SIMPLEWEED:Purchase",seeds.Purchase:GetWide()/2,seeds.Purchase:GetTall()/2,Color(89,212,72),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			else
				draw.SimpleText("BUY","SIMPLEWEED:Purchase",seeds.Purchase:GetWide()/2,seeds.Purchase:GetTall()/2,Color(212,72,72),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			end
		end
		seeds.Purchase.DoClick = function()
			net.Start("SIMPLEWEED:PurchaseSeed")
			net.WriteInt(k,32)
			net.SendToServer()
			frame:Remove()
		end
	end
end)

net.Receive("SIMPLEWEED:ChatNotification", function()
	local text = net.ReadString()
	chat.AddText(color_black,"[",Color(89,212,72),"WEED",color_black,"] ",color_white,text)
end)