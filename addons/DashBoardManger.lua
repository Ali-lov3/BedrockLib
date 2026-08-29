local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)

local Players: Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local DashboardManager = {
    Library = nil,
    AppliedTabs = {},
}

local function copySettings(info)
    local settings = {
        Name = "Dashboard",
        Icon = "layout-dashboard",
        Description = "Your Roblox profile",
        Order = 1,
        ProfileName = "Profile",
        ProfileIcon = "user-round",
        AccountName = "Account",
        AccountIcon = "id-card",
        AvatarType = "AvatarHeadShot",
        AvatarWidth = 420,
        AvatarHeight = 420,
        AvatarImageHeight = 190,
        Show = true,
    }

    if typeof(info) == "table" then
        for key, value in info do
            settings[key] = value
        end
    end

    return settings
end

local function resolveTab(target, settings)
    if typeof(target) ~= "table" then
        error("ApplyDashBoard requires a Window or Tab.")
    end

    if type(target.AddGroupbox) == "function" then
        return target
    end

    if type(target.AddTab) == "function" then
        return target:AddTab({
            Name = settings.Name,
            Icon = settings.Icon,
            Description = settings.Description,
            Order = settings.Order,
        })
    end

    error("ApplyDashBoard requires a Window or Tab.")
end

local function getPlayer(info)
    if typeof(info.Player) == "Instance" and info.Player:IsA("Player") then
        return info.Player
    end

    return LocalPlayer
end

local function getAvatarUrl(player, settings)
    local avatarType = settings.AvatarType
    if avatarType ~= "AvatarBust" and avatarType ~= "AvatarHeadShot" then
        avatarType = "AvatarHeadShot"
    end

    local width = tonumber(settings.AvatarWidth) or 420
    local height = tonumber(settings.AvatarHeight) or 420

    return string.format(
        "rbxthumb://type=%s&id=%s&w=%d&h=%d",
        avatarType,
        tostring(player.UserId),
        width,
        height
    )
end

function DashboardManager:SetLibrary(library)
    self.Library = library
    return self
end

function DashboardManager:ApplyDashBoard(target, info)
    assert(self.Library, "Library is not set, call DashboardManager:SetLibrary(Library) first.")

    local settings = copySettings(info)
    local tab = resolveTab(target, settings)

    if self.AppliedTabs[tab] then
        return self.AppliedTabs[tab]
    end

    local player = getPlayer(settings)
    local profile = tab:AddGroupbox({
        Side = "Left",
        Name = settings.ProfileName,
        IconName = settings.ProfileIcon,
    })

    local account = tab:AddGroupbox({
        Side = "Right",
        Name = settings.AccountName,
        IconName = settings.AccountIcon,
    })

    local avatar = profile:AddImage("DashboardAvatar", {
        Image = getAvatarUrl(player, settings),
        Height = settings.AvatarImageHeight,
        ScaleType = Enum.ScaleType.Fit,
    })

    local displayName = profile:AddLabel({
        Text = player.DisplayName,
        Size = 20,
    })

    local username = profile:AddLabel({
        Text = "@" .. player.Name,
        Size = 14,
    })

    local accountDisplayName = account:AddLabel({
        Text = "Display name: " .. player.DisplayName,
        Size = 14,
    })

    local accountUsername = account:AddLabel({
        Text = "Username: @" .. player.Name,
        Size = 14,
    })

    account:AddDivider({
        Text = "Details",
        MarginTop = 4,
        MarginBottom = 4,
    })

    local userId = account:AddLabel({
        Text = "User ID: " .. tostring(player.UserId),
        Size = 14,
    })

    local dashboard = {
        Library = self.Library,
        Tab = tab,
        Player = player,
        Profile = profile,
        Account = account,
        Avatar = avatar,
        Username = username,
        DisplayName = displayName,
        UserId = userId,
        AccountUsername = accountUsername,
        AccountDisplayName = accountDisplayName,
    }

    self.AppliedTabs[tab] = dashboard

    if settings.Show and type(tab.Show) == "function" then
        tab:Show()
    end

    return dashboard
end

function DashboardManager:ApplyDashboard(target, info)
    return self:ApplyDashBoard(target, info)
end

getgenv().ObsidianDashboardManager = DashboardManager

return DashboardManager
