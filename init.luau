local RunService = game:GetService("RunService")
local raku = {}

export type raku = typeof(raku)

type service = {
	Client: { (Player, ...any) -> ...any }?,
	Init: () -> nil,
	Start: () -> nil,
}

raku.Services = {} :: { service }

--[[
creates a new service

@param name the name of the service (this will be used for any service-specific functions run)

@return the created service
]]
function raku.CreateService(name: string)
	local service = raku.Services[name]

	if RunService.IsServer() then
		service.Client = {} :: { (Player, ...any) -> ...any }
	end

	service.Init = function()
		error("a raku service's init function cannot be undefined")
	end :: () -> nil
	service.Start = function()
		error("a raku service's start function cannot be undefined")
	end :: () -> nil

	return service
end

--[[
meant only to be used on the client

@param name the registered name of a server service

@return the client section of the service
]]
function raku.GetService(name: string)
	local service = raku.Services[name]

	if not service then
		error("the given service does not exist")
	end

	if RunService:IsClient() then
		service = raku.Services[name].Client
	end

	return service
end

--[[
requires all modulescripts in a folder

@param basePath the folder containing all your services

@param extraPath if your folder structure does not directly contain modulescripts, but they are instead in other folders, use this (the string must lead to a modulescript not a folder)
]]
function raku.LoadServices(basePath: Instance, extraPath: string?)
	for _, path in ipairs(basePath:GetChildren()) do
		local module = path
		if extraPath then
			module = path:FindFirstChild(extraPath)
			if not module then
				error("extraPath was not found: " .. extraPath)
			end
		end

		if module:IsA("ModuleScript") then
			require(module)
		else
			warn("Service entrypoint not found")
		end
	end
end

--[[
runs init on all registered services
]]
function raku.InitialiseAllServices()
	for service in pairs(raku.Services) do
		service.Init()
	end
end

--[[
runs start on all registered services
]]
function raku.StartAllServices()
	for service in pairs(raku.Services) do
		service.Start()
	end
end

return raku :: raku
