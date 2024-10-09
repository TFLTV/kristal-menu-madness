local preview = {}

preview.hide_background = false

local mod_path = nil
local sprite_path = nil

local function getFrames(name, frames, path, return_images)
    local path = (path ~= "" and path .. "/" or "") or sprite_path
	local images = {}

	if not sprite_path then
		Kristal.Console:warn("sprite_path is nil. Menu Madness function getFrames.")
		return
	end

	for i = 1, frames do
		local spr = love.filesystem.getInfo( path..name.."_"..i..".png" ) and love.graphics.newImage(path..name.."_"..i..".png")

        if return_images == false then
            spr = path..name.."_"..i
        end

		table.insert(images,spr)
	end

	return images
end

function preview:init(mod, button, menu)

    preview.button = button
    preview.mod_path = mod.path
    
    mod_path = mod.path
    sprite_path = mod.path .. "/assets/sprites"

    --print(Utils.dump(Kristal.Mods.getMods()))
    --MainMenu.mod_list.list:addMod({hidden = false, name = "The Button", subtitle = "subtitle"})
    if MainMenu and not Kristal.Menu_madness then -- Should i even capitalize the name of the variable
        Kristal.Menu_madness = {
            --enter_explode = Utils.random() < 1/20 and true or false
            enter_explode = false,
            the_button_on = true,
            where_the_hell_are_we = Utils.random()-- < 1/10 and true or false,
        }
        
        local orig = Kristal.loadMod
        function Kristal.loadMod(id, ...)
            if id == mod.id then
                Assets.stopSound("ui_select")
                local random = Utils.random()
                Assets.stopAndPlaySound(random < 1/50 and "badexplosion" or "error")
                if random < 1/50 then -- only works like half the time, for some reason
                    button.subtitle = "Explosion = Funny"
                end
                if Kristal.Menu_madness.eek_music then
                    local pitch = MainMenu.music:getPitch()
                    MainMenu.music:setPitch(pitch > 0.05 and pitch - 0.05 or pitch)

                    pitch = MainMenu.music:getPitch()
                    --print ( (tostring(pitch > 0.05)) .. " -> " .. pitch)

                    if pitch <= 0.05 then
                        Kristal.Menu_madness.eek_music_pitch_up = true
                    end
                end
            else
                orig(id, ...)
            end
        end
        
    end

    if Utils.random() < 1/35 and not Kristal.Menu_madness.eek_music then
        MainMenu.music:stop()
        MainMenu.music:playFile(mod.path .. "/assets/music/eek.ogg", 1.3)
    end
    
    button:setColor(1, 0.5, 0.5)
    button:setFavoritedColor(1, 0, 0)

    local orig = MainMenu.onKeyPressed
    MainMenu.onKeyPressed = function(menu, key, is_repeat)
        if Kristal.Menu_madness.enter_explode and Input.isConfirm(key) then
            local uhhh = Sprite("player/heart_menu")
            uhhh:setPosition(MainMenu.heart:getPosition())
            uhhh.layer = MainMenu.heart.layer + 1
            MainMenu.stage:addChild(uhhh)
            uhhh:explode()
        end
        orig(menu, key, is_repeat)
    end

    if Kristal.Menu_madness.where_the_hell_are_we < 1/3 then
        Kristal.Menu_madness.where_the_hell_are_we = 999
        local timer = Timer()
        MainMenu.stage:addChild(timer)

        local playful = Utils.random() < 1/2

        local kris = Sprite(getFrames("party/kris/dark/walk/right",4,"",false), -100,SCREEN_HEIGHT)
        local susie = Sprite(getFrames("party/susie/dark/walk/right",4,"",false), -50,SCREEN_HEIGHT)

        kris.layer = 999
        susie.layer = 999

        kris:play()
        susie:play()

        kris.anim_speed = 0.2
        susie.anim_speed = 0.2
        
        MainMenu.stage:addChild(kris)
        MainMenu.stage:addChild(susie)

        kris:setOrigin(0.5,0.5)
        susie:setOrigin(0.5,0.5)
        
        kris:setScale(2)
        susie:setScale(2)

        kris:setPosition(kris.x, SCREEN_HEIGHT - kris:getScaledHeight()/2)
        susie:setPosition(susie.x, SCREEN_HEIGHT - susie:getScaledHeight()/2)

        timer:script(function(wait)
            wait(1)

            kris:slideToSpeed(kris.x + 150, kris.y)
            susie:slideToSpeed(susie.x + 150 + (playful and 0 or 20), susie.y)

            wait(((150 + (playful and 20 or 0)) / 4) * DT)

            kris:set("party/kris/dark/walk/down_1")
            susie:set("party/susie/dark/walk/down_1")

            wait(1)

            if playful then susie:set("party/susie/dark/playful_punch_1") end

            local dialogue = DialogueText("[noskip][voice:susie]* Kris,[wait:5] where the [wait:10][func:s]HELL[wait:5] are we??",80,170)
            dialogue.functions = {s = function()
                if not playful then
                    susie:set("party/susie/dark/turn_around")
                    Assets.playSound("whip_crack_only")
                    return
                end
                susie:set("party/susie/dark/playful_punch_2")
                susie:shake(2,0)
                Assets.playSound("impact")

                kris:shake(2,0)
            end}
            MainMenu.stage:addChild(dialogue)

            wait(3)
            susie:set("party/susie/dark/walk/down_1")
            dialogue:remove()

            wait(1)

            kris:slideToSpeed(kris.x - 150, kris.y)
            susie:slideToSpeed(susie.x - 150 - (playful and 0 or 20), susie.y)

            kris:setSprite(getFrames("party/kris/dark/walk/left",4,"",false))
            susie:setSprite(getFrames("party/susie/dark/walk/left",4,"",false))

            kris:play()
            susie:play()

            wait(2) -- lazy

            kris:remove()
            susie:remove()
            timer:remove()
        end)
        --timer:remove()
    end
    
    Kristal.Menu_madness.enter_explode = false
    if not MainMenu then
        button.subtitle = "(kristal version outdated! cannot run)"
    elseif Utils.random() < 1/50 then
        button.subtitle = "And then it went all \"BOOOMMM!!\" Crazy right?!?"
        Kristal.Menu_madness.enter_explode = true
    elseif Utils.random() < 1/25 then
        button.subtitle = "Dark Place: Menu Edition"
    elseif Utils.random() < 1/15 then
        button.subtitle = "The Menu Has the Madness"
    else
        button.subtitle = "Dark Place? I think not."
    end
    
    Kristal.Menu_madness.started = true -- so you can do things that ONLY happen when the engine is first started up

    preview.version_timer = DT*10
    preview.title_num = 1
end

function preview:update()

    preview:updatename()

    if MainMenu then

        if MainMenu.state == "MODSELECT" then
            preview:buttonUpdate()
            
        else
            if Kristal.Menu_madness.the_button then
                Kristal.Menu_madness.the_button:remove()
                Kristal.Menu_madness.the_button = nil
    
                Kristal.hideCursor()
            end
        end

        if Kristal.Menu_madness.eek_music_pitch_up then
            MainMenu.music:setPitch( MainMenu.music:getPitch() + 0.01 )
            if MainMenu.music:getPitch() >= 1 then
                Kristal.Menu_madness.eek_music_pitch_up = false
                MainMenu.music:setPitch(1)
            end
        end
        if MainMenu.music.current == mod_path .. "/assets/music/eek.ogg" then
            Kristal.Menu_madness.eek_music = true
        else
            Kristal.Menu_madness.eek_music = false
        end
    end
end

function preview:draw()
end

local subfont = Assets.getFont("main", 16)
function preview:drawOverlay()
    if MainMenu and MainMenu.state == "MODSELECT" then

    end
end


function preview:updatename()

    local name = "Menu Madness Menu Madness " -- despite being commited by TFLTV this code was made by SadDiamondMan. they made the code, not me.
    local name_length = #name
    

    if preview.version_timer >= 1 then
        local x = string.sub(name, -preview.title_num + name_length/2, -preview.title_num + name_length)

        preview.button.name = x

        if preview.title_num == name_length/2 then
            preview.title_num = 0
        else
            preview.title_num = preview.title_num + 1
        end
        preview.version_timer = 0
    else
        preview.version_timer = preview.version_timer + DT*10
    end

    preview.button.rotation = math.random(6, -6)/500

    preview.button.x = 4 + math.random(2, -2)
end

function preview:buttonUpdate()
    if Kristal.Menu_madness.the_button_on and not Kristal.Menu_madness.the_button then

        local img = love.graphics.newImage(sprite_path .. "/the_button.png")
        Kristal.Menu_madness.the_button = Sprite(img,610,240)
        local spr = Kristal.Menu_madness.the_button
        spr:setScale(2)
        spr:setOrigin(0.5,0.5)
        local xy, wh = {spr:getPosition()},{spr:getSize()}
        spr.collider = Hitbox(spr, 0,0, wh[1], wh[2])

        MainMenu.stage:addChild(Kristal.Menu_madness.the_button)
        Kristal.showCursor()
    end
    if Kristal.Menu_madness.the_button then
        Kristal.Menu_madness.the_button:setScale(Utils.approach(Kristal.Menu_madness.the_button:getScale(), 2, 0.02))
        if Kristal.Menu_madness.the_button.collider:clicked() then
            local sound = Utils.pick({
                "badexplosion",
                "bell",
                "screenshake",
                "ui_select",
                "suslaugh",
                "alert",
                "awkward",
                "bageldefeat",
                "damage",
                "dtrans_flip",
                "egg",
                "grab",
                "icespell",
                "impact",
                "noise", -- generic lol
                "phone",
                "spare",
                "splat",

            })
            local funcs = {
                badexplosion = function() Kristal.Menu_madness.the_button:explode(); Kristal.Menu_madness.the_button = nil end,
                screenshake = function() Kristal.Menu_madness.the_button:shake(2) end,
                impact = function() Kristal.Menu_madness.the_button:shake(2) end,
                egg = function() MainMenu.music:stop() end,
                damage = function()
                    local timer = Timer();
                    MainMenu.stage:addChild(timer);
                    timer:script(function(wait)
                        local dialogue = DialogueText("[noskip][voice:".. (Utils.random() < 1/2 and "susie" or "ralsei") .."]* Ow!",20,10);
                        MainMenu.stage:addChild(dialogue);
                        wait(1);
                        dialogue:remove();
                    end)
                end,
            }
            Assets.stopAndPlaySound(sound)
            if funcs[sound] then
                funcs[sound]()
            end
            Kristal.Menu_madness.the_button:setScale(2.4)
        end
    end
end

return preview
