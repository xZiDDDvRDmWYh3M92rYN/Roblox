local timeout = tick()
local desync = false
local bring_status = false
local bring_timeout = 5
local ragebot_default = {}
local ragebot_weapons = {}

local ragebot_bring = {
    ['shift prediction'] = true,
    ['show desync'] = true,
    ['stay out of void'] = true
}

for i, v in pairs(Options.ragebot_settings.Value) do
    ragebot_default[i] = v
end

for i, v in pairs(Options.ragebot_weapon.Value) do
    ragebot_weapons[i] = v
end

api:GetTab('misc'):GetGroupbox('player'):AddButton({
    Text = 'bring',
    Func = function()
        local target = Options.selected_player_dropdown.Value
        local character = game.Players[target].Character

        api:set_ragebot(true)
        api:notify('Attempting to bring: ' .. tostring(target))

        if bring_status then
            api:notify('Already bringing.')
            return
        end

        bring_status = true

        Options.ragebot_settings:SetValue(ragebot_bring)
        Options.ragebot_targets:SetValue({})
        Options.ragebot_targets:SetValue(target)
        Options.ragebot_weapon:SetValue('[AUG]')

        timeout = tick()
        repeat 
            task.wait()
        until character.BodyEffects['K.O'].Value == true or tick() - timeout > bring_timeout

        if tick() - timeout > bring_timeout then
            api:notify('Bring failed: took too long to knock target.')
            Options.ragebot_settings:SetValue(ragebot_default)
            Options.ragebot_weapon:SetValue(ragebot_weapons)
            Options.ragebot_targets:SetValue({})
            api:set_ragebot(false)
            bring_status = false
            desync = false
            return
        end

        api:set_ragebot(false)
        Options.ragebot_targets:SetValue({})
        Options.ragebot_settings:SetValue(ragebot_default)
        Options.ragebot_weapon:SetValue(ragebot_weapons)

        desync = true
        
        if desync then
            task.spawn(function()
                while desync do
                    local position = character.LowerTorso.Position + Vector3.new(0, 3, 0)
                    api:set_desync_cframe(CFrame.new(position))
                    task.wait()
                end
            end)
        end

        function grab_target()
            game:GetService('ReplicatedStorage'):WaitForChild('MainEvent', 9e9):FireServer('Grabbing', false)
            task.wait(0.2)
        end

        timeout = tick()
        repeat 
            grab_target()
        until character:FindFirstChild('GRABBING_CONSTRAINT') or tick() - timeout > bring_timeout

        if tick() - timeout > bring_timeout then
            api:notify('Bring failed: took too long to grab target.')
            Options.ragebot_settings:SetValue(ragebot_default)
            Options.ragebot_weapon:SetValue(ragebot_weapons)
            Options.ragebot_targets:SetValue({})
            api:set_ragebot(false)
            bring_status = false
            desync = false
            return
        end

        bring_status = false
        desync = false
    end
})