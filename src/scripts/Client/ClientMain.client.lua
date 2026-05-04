--[[
	@class ClientMain
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loader = ReplicatedStorage:WaitForChild("Game"):WaitForChild("loader")
local require = require(loader).bootstrapGame(loader.Parent) :: any

local serviceBag = require("ServiceBag").new()
serviceBag:GetService(require("InitServiceShared"))
serviceBag:Init()
serviceBag:Start()