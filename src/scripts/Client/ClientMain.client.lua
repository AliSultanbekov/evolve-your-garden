--[[
	@class ClientMain
]]
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loader = ReplicatedStorage:WaitForChild("Game"):WaitForChild("loader")
local require = require(loader).bootstrapGame(loader.Parent) :: any

local serviceBag = require("ServiceBag").new()
serviceBag:GetService(require("InitServiceShared"))
serviceBag:Init()
serviceBag:Start()

task.spawn(function()
	local Success = false

	while not Success do
		Success = pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		end)

		if not Success then
			task.wait(0.5)
		end
	end
end)
