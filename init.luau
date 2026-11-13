local raku = {}

export type raku = typeof(raku)

type service = {
	Client: { (Player, ...any) -> ...any },
	Init: () -> nil,
	Start: () -> nil,
}

raku.Services = {} :: { service }

--[[
creates a new service

@param name the name of the service (this will be used for any service-specific functions run)
]]
function raku.CreateService(name: string)
	local service = raku.Services[name]
	service.Client = {} :: { (Player, ...any) -> ...any }

	service.Init = function()
		error("a raku service's init function cannot be undefined")
	end :: () -> nil
	service.Start = function()
		error("a raku service's start function cannot be undefined")
	end :: () -> nil
end

--[[
requires all modulescripts in a folder

@param basePath the folder containing all your services

@param extraPath if your folder structure does not directly contain modulescripts, but they are instead in other folders, use this (the string must lead to a modulescript not a folder)
]]
function raku.AddServices(basePath: Instance, extraPath: string?)
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
runs init on all services
]]
function raku.InitialiseAllServices()
	for service in ipairs(raku.Services) do
		service.Init()
	end
end

--[[
runs start on all services
]]
function raku.StartAllServices()
	for service in ipairs(raku.Services) do
		service.Start()
	end
end

return raku :: raku
