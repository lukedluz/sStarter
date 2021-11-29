local subTag = "[SEU PREFIXO]" -- Prefixo dos mods que serão carregados, só serão carregados os mods em que as pastas começam com esse prefixo.

local importantResources = { -- Arquivos importantes após o prefixo, exemplo:
    subTag .. "database", --  [PREFIX].....database é importante, caso queira editar, adicionar mais, ou apagar, fique a vontade.
    subTag .. "marker",
    subTag .. "core",
    subTag .. "logs",
    subTag .. "admin",
    subTag .. "assets",
    subTag .. "hud",
}

local excludeResources = {}
for k,v in pairs(importantResources) do
    excludeResources[v] = true
end

local threadTimer
local threads = {}
local load_speed = 1000 -- Velocidade em segundos para carregar os mods.
local load_speed_multipler = 1 -- Quantidade de mods por vez.
local canConnect = false

addEventHandler("onResourceStart", resourceRoot,
    function()
        if not getElementData(root, "loadedAllRes") then
            setElementData(root, "loadedAllRes", true)
            for k, v in ipairs(importantResources) do
                local res = getResourceFromName(v)
                if res then
                    table.insert(threads, res)
                end
            end

            for k,v in pairs(getResources()) do
                if v ~= getThisResource() then
                    local subText = utfSub(getResourceName(v), 1, #subTag)
                    if subText == subTag and not excludeResources[getResourceName(v)] then 
                        table.insert(threads, v)
                    end
                end
            end

            threadTimer = setTimer(
                function()
                    local num = 0

                    for k,v in pairs(threads) do
                        num = num + 1

                        if num > load_speed_multipler then
                            break
                        end

                        startResource(v)

                        table.remove(threads, k)

                        outputDebugString(getResourceName(v).. " recurso iniciado!", 2)
                    end

                    if num == 0 then
                        killTimer(threadTimer)
                        outputDebugString("Todos recursos iniciados!", 3)
                        threadTimer = nil
                        canConnect = true
                    end
                end, load_speed, 0 
            )
        end
    end
)

addEventHandler("onPlayerConnect", root,
    function()
        if not canConnect then
            cancelEvent(true, "SEU SERVIDOR AQUI\nA O servidor está iniciando!")
        end
    end
)