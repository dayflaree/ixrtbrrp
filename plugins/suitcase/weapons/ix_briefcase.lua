SWEP.PrintName = "Briefcase"
SWEP.Author = "Riggs"
SWEP.Instructions = "You are carrying a briefcase."
SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.Category = "Suitcase"

SWEP.ViewModel = "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel = "models/props_c17/BriefCase001a.mdl"
SWEP.UseHands = true
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "normal"

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
    return false
end

function SWEP:SecondaryAttack()
    return false
end

function SWEP:Deploy()
    return true
end

function SWEP:Holster()
    return true
end

function SWEP:DrawWorldModel()
    local owner = self:GetOwner()
    if IsValid(owner) and owner:IsPlayer() then
        local attachID = owner:LookupAttachment("anim_attachment_RH")
        if attachID and attachID > 0 then
            local att = owner:GetAttachment(attachID)
            if att then
                local pos, ang = att.Pos, att.Ang
                -- Adjust these values for best fit
                local offset = Vector(5, 2, -2)
                local angle = Angle(-90, 180, 0)
                ang:RotateAroundAxis(ang:Right(), angle.p)
                ang:RotateAroundAxis(ang:Up(), angle.y)
                ang:RotateAroundAxis(ang:Forward(), angle.r)
                pos = pos + ang:Forward() * offset.x + ang:Right() * offset.y + ang:Up() * offset.z
                self:SetRenderOrigin(pos)
                self:SetRenderAngles(ang)
                self:DrawModel()
                self:SetRenderOrigin()
                self:SetRenderAngles()
                return
            end
        end
        local bone = owner:LookupBone("ValveBiped.Bip01_R_Hand")
        if bone then
            local pos, ang = owner:GetBonePosition(bone)
            if pos and ang then
                local offset = Vector(5, 2, -2)
                local angle = Angle(-90, 180, 0)
                ang:RotateAroundAxis(ang:Right(), angle.p)
                ang:RotateAroundAxis(ang:Up(), angle.y)
                ang:RotateAroundAxis(ang:Forward(), angle.r)
                pos = pos + ang:Forward() * offset.x + ang:Right() * offset.y + ang:Up() * offset.z
                self:SetRenderOrigin(pos)
                self:SetRenderAngles(ang)
                self:DrawModel()
                self:SetRenderOrigin()
                self:SetRenderAngles()
                return
            end
        end
    end
    self:DrawModel()
end 