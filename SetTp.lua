-- Delta: Teleport Mod Menu + TP Finis (Open/Close + Hotkey)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- Variabel Data
local savedLocations = {}
local selectedIndex = nil
local autoTPEnabled = false
local autoTPInterval = 0.3
local lastTP = 0
local isMenuOpen = true

-- Variabel untuk Finis
local finishPart = nil
local autoTPFinish = false

-- ===== GUI =====
local sg = Instance.new("ScreenGui")
sg.Name = "TPMenuFinal"
sg.ResetOnSpawn = false
sg.Parent = lp:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 250, 0, 420) -- Diperbesar untuk fitur baru
main.Position = UDim2.new(0, 20, 0, 100)
main.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Visible = true
main.Parent = sg

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

-- === FITUR FINIS ===
local tpFinishBtn = Instance.new("TextButton")
tpFinishBtn.Size = UDim2.new(0, 210, 0, 30)
tpFinishBtn.Position = UDim2.new(0, 20, 0, 35)
tpFinishBtn.BackgroundColor3 = Color3.fromRGB(150, 80, 0) -- Warna Oranye
tpFinishBtn.BorderSizePixel = 0
tpFinishBtn.Text = "TP ke Finis / End"
tpFinishBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpFinishBtn.Font = Enum.Font.GothamBold
tpFinishBtn.TextSize = 13
tpFinishBtn.Parent = main

local autoFinishBtn = Instance.new("TextButton")
autoFinishBtn.Size = UDim2.new(0, 210, 0, 30)
autoFinishBtn.Position = UDim2.new(0, 20, 0, 70)
autoFinishBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
autoFinishBtn.BorderSizePixel = 0
autoFinishBtn.Text = "Auto TP Finis: OFF"
autoFinishBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoFinishBtn.Font = Enum.Font.GothamBold
autoFinishBtn.TextSize = 13
autoFinishBtn.Parent = main
-- ==================

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(0, 210, 0, 30)
saveBtn.Position = UDim2.new(0, 20, 0, 110)
saveBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
saveBtn.BorderSizePixel = 0
saveBtn.Text = "Simpan Lokasi Saat Ini (Set TP)"
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 13
saveBtn.Parent = main

local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0, 210, 0, 30)
autoBtn.Position = UDim2.new(0, 20, 0, 150)
autoBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
autoBtn.BorderSizePixel = 0
autoBtn.Text = "Auto TP Save: OFF"
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextSize = 13
autoBtn.Parent = main

local listLabel = Instance.new("TextLabel")
listLabel.Size = UDim2.new(1, -40, 0, 20)
listLabel.Position = UDim2.new(0, 20, 0, 190)
listLabel.BackgroundTransparency = 1
listLabel.Text = "Daftar Lokasi Tersimpan:"
listLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
listLabel.Font = Enum.Font.Gotham
listLabel.TextSize = 12
listLabel.TextXAlignment = Enum.TextXAlignment.Left
listLabel.Parent = main

local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(0, 210, 0, 160)
listFrame.Position = UDim2.new(0, 20, 0, 215)
listFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 4
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
listFrame.Parent = main

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = listFrame

-- Tombol Buka
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 130, 0, 35)
openBtn.Position = UDim2.new(0, 20, 0, 100)
openBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 60)
openBtn.BorderSizePixel = 0
openBtn.Text = "Buka Menu TP"
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 13
openBtn.Active = true
openBtn.Draggable = true
openBtn.Visible = false
openBtn.Parent = sg

-- ===== FUNGSI UTAMA =====
local function toggleMenu()
    isMenuOpen = not isMenuOpen
    main.Visible = isMenuOpen
    openBtn.Visible = not isMenuOpen
end

closeBtn.MouseButton1Click:Connect(toggleMenu)
openBtn.MouseButton1Click:Connect(toggleMenu)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then toggleMenu() end
end)

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

-- Fungsi Mencari Part Finis
local function findFinishPart()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("finish") or n:find("end") or n:find("win") or n:find("goal") then
                return obj
            end
        end
    end
    return nil
end

-- Fungsi TP ke Finis
local function tpToFinish()
    if not finishPart or not finishPart.Parent then
        finishPart = findFinishPart()
    end
    
    local hrp = getHRP()
    if finishPart and hrp then
        -- Posisi sedikit di atas part agar tidak nyangkut
        local targetPos = finishPart.Position + Vector3.new(0, 3, 0)
        doTP(CFrame.new(targetPos))
    else
        tpFinishBtn.Text = "Finis Tidak Ditemukan!"
        task.wait(2)
        tpFinishBtn.Text = "TP ke Finis / End"
    end
end

-- ===== EVENT HANDLERS =====
tpFinishBtn.MouseButton1Click:Connect(tpToFinish)

autoFinishBtn.MouseButton1Click:Connect(function()
    autoTPFinish = not autoTPFinish
    autoFinishBtn.Text = "Auto TP Finis: " .. (autoTPFinish and "ON" or "OFF")
    autoFinishBtn.BackgroundColor3 = autoTPFinish and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(80, 80, 90)
    if autoTPFinish then autoTPEnabled = false; autoBtn.Text = "Auto TP Save: OFF"; autoBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90) end
end)

autoBtn.MouseButton1Click:Connect(function()
    if not selectedIndex then
        autoBtn.Text = "Pilih Lokasi Dulu!"
        task.wait(1.5)
        autoBtn.Text = "Auto TP Save: " .. (autoTPEnabled and "ON" or "OFF")
        return
    end
    autoTPEnabled = not autoTPEnabled
    autoBtn.Text = "Auto TP Save: " .. (autoTPEnabled and "ON" or "OFF")
    autoBtn.BackgroundColor3 = autoTPEnabled and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(80, 80, 90)
    if autoTPEnabled then autoTPFinish = false; autoFinishBtn.Text = "Auto TP Finis: OFF"; autoFinishBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90) end
end)

-- (Fungsi updateList, Save, Hapus sama seperti sebelumnya)
local function updateList()
    for _, child in ipairs(listFrame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
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
            autoTPFinish = false; autoFinishBtn.Text = "Auto TP Finis: OFF"; autoFinishBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
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
            if selectedIndex == i then selectedIndex = nil
            elseif selectedIndex and selectedIndex > i then selectedIndex = selectedIndex - 1 end
            updateList()
        end)
    end
    listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end

saveBtn.MouseButton1Click:Connect(function()
    local hrp = getHRP()
    if not hrp then return end
    table.insert(savedLocations, { name = "Lokasi " .. (#savedLocations + 1), cframe = hrp.CFrame })
    updateList()
end)

-- ===== AUTO TP LOOP =====
RunService.Heartbeat:Connect(function()
    if tick() - lastTP < autoTPInterval then return end
    
    if autoTPFinish then
        tpToFinish()
        lastTP = tick()
    elseif autoTPEnabled and selectedIndex then
        local data = savedLocations[selectedIndex]
        if data then
            doTP(data.cframe)
            lastTP = tick()
        end
    end
end)
