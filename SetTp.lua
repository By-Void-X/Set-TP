-- Delta: Teleport Mod Menu (Open/Close + Hotkey + Save/Auto TP)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService") -- Untuk Hotkey
local lp = Players.LocalPlayer

-- Variabel Data
local savedLocations = {}
local selectedIndex = nil
local autoTPEnabled = false
local autoTPInterval = 0.3
local lastTP = 0

-- Variabel UI
local isMenuOpen = true

-- ===== GUI =====
local sg = Instance.new("ScreenGui")
sg.Name = "TPMenuFinal"
sg.ResetOnSpawn = false
sg.Parent = lp:WaitForChild("PlayerGui")

-- 1. FRAME UTAMA (Menu lengkap)
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 250, 0, 350)
main.Position = UDim2.new(0, 20, 0, 100)
main.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true -- Bisa digeser bebas
main.Visible = true
main.Parent = sg

-- Title Bar
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
title.BorderSizePixel = 0
title.Text = "Teleport Menu (Shift Kanan)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = main

-- Tombol Tutup (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 15
closeBtn.Parent = main

-- Tombol Save
local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(0, 210, 0, 35)
saveBtn.Position = UDim2.new(0, 20, 0, 40)
saveBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
saveBtn.BorderSizePixel = 0
saveBtn.Text = "Simpan Lokasi Saat Ini (Set TP)"
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 13
saveBtn.Parent = main

-- Tombol Auto TP
local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0, 210, 0, 35)
autoBtn.Position = UDim2.new(0, 20, 0, 85)
autoBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
autoBtn.BorderSizePixel = 0
autoBtn.Text = "Auto TP: OFF"
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextSize = 13
autoBtn.Parent = main

-- Label List
local listLabel = Instance.new("TextLabel")
listLabel.Size = UDim2.new(1, -40, 0, 20)
listLabel.Position = UDim2.new(0, 20, 0, 130)
listLabel.BackgroundTransparency = 1
listLabel.Text = "Daftar Lokasi (Klik untuk pilih):"
listLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
listLabel.Font = Enum.Font.Gotham
listLabel.TextSize = 12
listLabel.TextXAlignment = Enum.TextXAlignment.Left
listLabel.Parent = main

-- Scrolling Frame untuk List
local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(0, 210, 0, 180)
listFrame.Position = UDim2.new(0, 20, 0, 155)
listFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 4
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
listFrame.Parent = main

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = listFrame
listLayout.SortOrder = Enum.SortOrder.LayoutOrder


-- 2. TOMBOL BUKA (Floating Button saat menu ditutup)
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 130, 0, 35)
openBtn.Position = UDim2.new(0, 20, 0, 100)
openBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 60) -- Warna hijau agar mudah dilihat
openBtn.BorderSizePixel = 0
openBtn.Text = "Buka Menu TP"
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 13
openBtn.Active = true
openBtn.Draggable = true -- Bisa digeser bebas
openBtn.Visible = false  -- Sembunyikan awalnya (karena menu utama terbuka)
openBtn.Parent = sg


-- ===== FUNGSI BUKA / TUTUP =====
local function toggleMenu()
    isMenuOpen = not isMenuOpen
    main.Visible = isMenuOpen
    openBtn.Visible = not isMenuOpen
end

-- Klik tombol X (Tutup)
closeBtn.MouseButton1Click:Connect(toggleMenu)

-- Klik tombol Buka
openBtn.MouseButton1Click:Connect(toggleMenu)

-- HOTKEY: Tekan "Right Shift" (Shift Kanan) untuk Buka/Tutup
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        toggleMenu()
    end
end)


-- ===== FUNGSI TP =====
local function getHRP()
    local char = lp.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function doTP(cframe)
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = cframe
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end

local function updateList()
    for _, child in ipairs(listFrame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for i, data in ipairs(savedLocations) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -4, 0, 30)
        row.BackgroundColor3 = (selectedIndex == i) and Color3.fromRGB(0, 120, 60) or Color3.fromRGB(50, 50, 62)
        row.BorderSizePixel = 0
        row.Parent = listFrame

        local selectBtn = Instance.new("TextButton")
        selectBtn.Size = UDim2.new(1, -30, 1, 0)
        selectBtn.BackgroundTransparency = 1
        selectBtn.Text = "  " .. data.name
        selectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        selectBtn.Font = Enum.Font.Gotham
        selectBtn.TextSize = 12
        selectBtn.TextXAlignment = Enum.TextXAlignment.Left
        selectBtn.Parent = row
        
        selectBtn.MouseButton1Click:Connect(function()
            selectedIndex = i
            updateList()
            doTP(data.cframe)
        end)

        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0, 30, 1, 0)
        delBtn.Position = UDim2.new(1, -30, 0, 0)
        delBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        delBtn.BorderSizePixel = 0
        delBtn.Text = "X"
        delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        delBtn.Font = Enum.Font.GothamBold
        delBtn.TextSize = 12
        delBtn.Parent = row

        delBtn.MouseButton1Click:Connect(function()
            table.remove(savedLocations, i)
            if selectedIndex == i then
                selectedIndex = nil
            elseif selectedIndex and selectedIndex > i then
                selectedIndex = selectedIndex - 1
            end
            updateList()
        end)
    end

    listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end

-- ===== EVENT HANDLERS =====
saveBtn.MouseButton1Click:Connect(function()
    local hrp = getHRP()
    if not hrp then return end

    local name = "Lokasi " .. (#savedLocations + 1)
    table.insert(savedLocations, {
        name = name,
        cframe = hrp.CFrame
    })
    updateList()
end)

autoBtn.MouseButton1Click:Connect(function()
    if not selectedIndex then
        autoBtn.Text = "Pilih Lokasi Dulu!"
        task.wait(1.5)
        autoBtn.Text = "Auto TP: " .. (autoTPEnabled and "ON" or "OFF")
        return
    end

    autoTPEnabled = not autoTPEnabled
    autoBtn.Text = "Auto TP: " .. (autoTPEnabled and "ON" or "OFF")
    autoBtn.BackgroundColor3 = autoTPEnabled and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(80, 80, 90)
end)

-- ===== AUTO TP LOOP =====
RunService.Heartbeat:Connect(function()
    if not autoTPEnabled or not selectedIndex then return end
    if tick() - lastTP < autoTPInterval then return end

    local data = savedLocations[selectedIndex]
    if data then
        doTP(data.cframe)
        lastTP = tick()
    end
end)
