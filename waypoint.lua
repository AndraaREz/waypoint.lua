local WaypointSystem = {}
WaypointSystem.__index = WaypointSystem

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

function WaypointSystem.new()
    local self = setmetatable({}, WaypointSystem)
    
    self.player = Players.LocalPlayer
    self.waypoints = {}
    self.gui = nil
    self.mainFrame = nil
    
    self:Initialize()
    return self
end

function WaypointSystem:Initialize()
    self:CreateGUI()
    self:SetupEvents()
    print("✅ Waypoint System loaded successfully!")
end

function WaypointSystem:GetCharacter()
    return self.player.Character or self.player.CharacterAdded:Wait()
end

function WaypointSystem:GetHumanoidRootPart()
    local character = self:GetCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

function WaypointSystem:CreateGUI()
    -- Remove old GUI if exists
    if self.player.PlayerGui:FindFirstChild("WaypointGui") then
        self.player.PlayerGui.WaypointGui:Destroy()
    end
    
    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WaypointGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.gui = screenGui
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 380, 0, 480)
    mainFrame.Position = UDim2.new(0.5, -190, 0.5, -240)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    self.mainFrame = mainFrame
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame
    
    -- Shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ZIndex = 0
    shadow.Parent = mainFrame
    
    -- Title Bar
    self:CreateTitleBar(mainFrame)
    
    -- Input Section
    self:CreateInputSection(mainFrame)
    
    -- Waypoints List
    self:CreateWaypointsList(mainFrame)
    
    -- Info Label
    self:CreateInfoLabel(mainFrame)
    
    screenGui.Parent = self.player.PlayerGui
end

function WaypointSystem:CreateTitleBar(parent)
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.BackgroundColor3 = Color3.fromRGB(45, 120, 200)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = parent
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0.5, 0)
    titleFix.Position = UDim2.new(0, 0, 0.5, 0)
    titleFix.BackgroundColor3 = Color3.fromRGB(45, 120, 200)
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar
    
    -- Title Text
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "📍 Waypoint Manager"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0.5, -17.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        self:ToggleGUI()
    end)
    
    self:MakeDraggable(titleBar)
end

function WaypointSystem:CreateInputSection(parent)
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "InputFrame"
    inputFrame.Size = UDim2.new(1, -30, 0, 110)
    inputFrame.Position = UDim2.new(0, 15, 0, 60)
    inputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = parent
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 10)
    inputCorner.Parent = inputFrame
    
    -- Name TextBox
    local nameBox = Instance.new("TextBox")
    nameBox.Name = "NameBox"
    nameBox.Size = UDim2.new(1, -20, 0, 35)
    nameBox.Position = UDim2.new(0, 10, 0, 10)
    nameBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    nameBox.PlaceholderText = "Enter waypoint name..."
    nameBox.Text = ""
    nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    nameBox.TextSize = 14
    nameBox.Font = Enum.Font.Gotham
    nameBox.ClearTextOnFocus = false
    nameBox.Parent = inputFrame
    self.nameBox = nameBox
    
    local nameCorner = Instance.new("UICorner")
    nameCorner.CornerRadius = UDim.new(0, 8)
    nameCorner.Parent = nameBox
    
    local namePadding = Instance.new("UIPadding")
    namePadding.PaddingLeft = UDim.new(0, 10)
    namePadding.Parent = nameBox
    
    -- Set Waypoint Button
    local setBtn = Instance.new("TextButton")
    setBtn.Name = "SetButton"
    setBtn.Size = UDim2.new(1, -20, 0, 40)
    setBtn.Position = UDim2.new(0, 10, 0, 55)
    setBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    setBtn.Text = "💾 Save Current Position"
    setBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setBtn.TextSize = 15
    setBtn.Font = Enum.Font.GothamBold
    setBtn.Parent = inputFrame
    
    local setCorner = Instance.new("UICorner")
    setCorner.CornerRadius = UDim.new(0, 8)
    setCorner.Parent = setBtn
    
    setBtn.MouseButton1Click:Connect(function()
        self:SetWaypoint()
    end)
end

function WaypointSystem:CreateWaypointsList(parent)
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "WaypointsList"
    scrollFrame.Size = UDim2.new(1, -30, 1, -245)
    scrollFrame.Position = UDim2.new(0, 15, 0, 185)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = parent
    self.scrollFrame = scrollFrame
    
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 10)
    scrollCorner.Parent = scrollFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = scrollFrame
    self.listLayout = listLayout
    
    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, 8)
    listPadding.PaddingBottom = UDim.new(0, 8)
    listPadding.PaddingLeft = UDim.new(0, 8)
    listPadding.PaddingRight = UDim.new(0, 8)
    listPadding.Parent = scrollFrame
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 16)
    end)
end

function WaypointSystem:CreateInfoLabel(parent)
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 0, 20)
    infoLabel.Position = UDim2.new(0, 0, 1, -25)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "Waypoints: 0"
    infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    infoLabel.TextSize = 12
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.Parent = parent
    self.infoLabel = infoLabel
end

function WaypointSystem:SetWaypoint()
    local name = self.nameBox.Text:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
    
    if name == "" then
        self:ShowNotification("❌ Please enter a waypoint name!", Color3.fromRGB(220, 50, 50))
        return
    end
    
    if self.waypoints[name] then
        self:ShowNotification("⚠️ Waypoint already exists!", Color3.fromRGB(220, 150, 50))
        return
    end
    
    local hrp = self:GetHumanoidRootPart()
    if not hrp then
        self:ShowNotification("❌ Character not found!", Color3.fromRGB(220, 50, 50))
        return
    end
    
    self.waypoints[name] = hrp.Position
    self:CreateWaypointItem(name, hrp.Position)
    self.nameBox.Text = ""
    self:UpdateInfo()
    self:ShowNotification("✅ Waypoint saved: " .. name, Color3.fromRGB(50, 180, 50))
end

function WaypointSystem:CreateWaypointItem(name, position)
    local item = Instance.new("Frame")
    item.Name = name
    item.Size = UDim2.new(1, -16, 0, 50)
    item.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    item.BorderSizePixel = 0
    item.Parent = self.scrollFrame
    
    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 8)
    itemCorner.Parent = item
    
    -- Name Label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.45, -10, 1, 0)
    nameLabel.Position = UDim2.new(0, 10, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "📌 " .. name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = item
    
    -- GoTo Button
    local gotoBtn = Instance.new("TextButton")
    gotoBtn.Size = UDim2.new(0, 80, 0, 35)
    gotoBtn.Position = UDim2.new(0.5, -5, 0.5, -17.5)
    gotoBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
    gotoBtn.Text = "➜ Go"
    gotoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    gotoBtn.TextSize = 13
    gotoBtn.Font = Enum.Font.GothamBold
    gotoBtn.Parent = item
    
    local gotoCorner = Instance.new("UICorner")
    gotoCorner.CornerRadius = UDim.new(0, 6)
    gotoCorner.Parent = gotoBtn
    
    -- Delete Button
    local delBtn = Instance.new("TextButton")
    delBtn.Size = UDim2.new(0, 80, 0, 35)
    delBtn.Position = UDim2.new(1, -85, 0.5, -17.5)
    delBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    delBtn.Text = "🗑️ Delete"
    delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    delBtn.TextSize = 13
    delBtn.Font = Enum.Font.GothamBold
    delBtn.Parent = item
    
    local delCorner = Instance.new("UICorner")
    delCorner.CornerRadius = UDim.new(0, 6)
    delCorner.Parent = delBtn
    
    -- Events
    gotoBtn.MouseButton1Click:Connect(function()
        self:GoToWaypoint(name)
    end)
    
    delBtn.MouseButton1Click:Connect(function()
        self:DeleteWaypoint(name)
    end)
end

function WaypointSystem:GoToWaypoint(name)
    local position = self.waypoints[name]
    if not position then
        self:ShowNotification("❌ Waypoint not found!", Color3.fromRGB(220, 50, 50))
        return
    end
    
    local hrp = self:GetHumanoidRootPart()
    if not hrp then
        self:ShowNotification("❌ Character not found!", Color3.fromRGB(220, 50, 50))
        return
    end
    
    hrp.CFrame = CFrame.new(position)
    self:ShowNotification("✅ Teleported to: " .. name, Color3.fromRGB(50, 180, 50))
end

function WaypointSystem:DeleteWaypoint(name)
    if not self.waypoints[name] then return end
    
    self.waypoints[name] = nil
    local item = self.scrollFrame:FindFirstChild(name)
    if item then item:Destroy() end
    
    self:UpdateInfo()
    self:ShowNotification("🗑️ Deleted: " .. name, Color3.fromRGB(220, 150, 50))
end

function WaypointSystem:UpdateInfo()
    local count = 0
    for _ in pairs(self.waypoints) do count = count + 1 end
    self.infoLabel.Text = "Waypoints: " .. count
end

function WaypointSystem:ShowNotification(text, color)
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 300, 0, 40)
    notif.Position = UDim2.new(0.5, -150, 0, -50)
    notif.BackgroundColor3 = color
    notif.Text = text
    notif.TextColor3 = Color3.fromRGB(255, 255, 255)
    notif.TextSize = 14
    notif.Font = Enum.Font.GothamBold
    notif.Parent = self.gui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notif
    
    local tweenIn = TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -150, 0, 20)})
    tweenIn:Play()
    
    task.wait(2)
    
    local tweenOut = TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -150, 0, -50)})
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        notif:Destroy()
    end)
end

function WaypointSystem:ToggleGUI()
    self.mainFrame.Visible = not self.mainFrame.Visible
end

function WaypointSystem:MakeDraggable(titleBar)
    local dragging, dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.mainFrame.Position
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function WaypointSystem:SetupEvents()
    self.player.CharacterAdded:Connect(function()
        task.wait(1)
        -- Character respawned, GUI persists
    end)
end

-- Initialize and return
return WaypointSystem.new()