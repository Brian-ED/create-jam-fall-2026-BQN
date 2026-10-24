# Import raylib as r, and from r, take out color, window, and draw.
# from color take out red, white and black
⟨⟨red, white, black⟩⇐color, window, draw⟩←r←•Import "../rayed-bqn/rayed.bqn"

#•Import⍟(¬•file.Exists∘"../sound/mix.wav") "../sound/mix.bqn"
#soundMixFile ← •file.Realpath "../sound/mix.wav"

GetHillVertices ← {𝕊:
    randomAngles ← (⌊÷⟜2 angleRandomness) -˜ hillLineCount •rand.Range angleRandomness
    followAngles ← ¯45(¯75⌈¯35⌊+)`randomAngles
    asMats ← r.math.MatrixRotate2D¨ r.math.deg2rad× followAngles
    linesAtAnglesFormHill ← r.math.MP⟜0‿hillDetail¨ asMats
    0‿0∾0‿0+`>linesAtAnglesFormHill
}

CheckCollision ← {𝕊:∨´{r.raylib.CheckCollisionCircleLine ⟨center⋄radius⋄𝕨⋄𝕩⟩}˝⎉2  𝕩⊸+⎉1 lines}

radius ← 100
hillDetail ← 100
hillLineCount ← 200  # hillLineCount × hillDetail = hillLength
angleRandomness ← 20
distanceBetweenObstacles ← 40
distanceBetweenPickups ← 40

hillVertices←GetHillVertices@
lines ← 2↕hillVertices

hillBottomLeft ← (⌊´)⊸∾⟜(⌈´)˝⍉hillVertices
hillAsTriangles ← ∾⟜hillBottomLeft⎉2 lines

# Runtime variables
nextObstacleIndex←0
center ← @ # Runtime because screen size changes midddle
screenSize ← @
frame ← 0
hillPosition ← 0‿0 # height ‿ rightMovement
speed ← 10
gravityAcceleration ← 0
gravitySpeed ← 0
timingHeadAngle ← 90
angle ← 0

obstacles ← (0=(50⥊1)»distanceBetweenObstacles|20+↕∘≠)⊸/hillVertices
pickups ← (0=(20⥊1)»distanceBetweenPickups|↕∘≠)⊸/hillVertices

# Stores mix.wav
soundMixWav ← @
soundMix ← @

# speedometer&Co.
# putting everything in the toplevel so my asset loading style and
# yours don't clash
font ← @
needle_texture ← @
speedometer_texture ← @
boulder_texture ← @
dirt_texture ← @
    

# scale at which to draw the boulder and speedometer textures
# initialized empty since computing them depends on the textures
# being loaded, which depends on the window having been started
# initialized in setup function after we load all assets
boulder_scale ← @
speedometer_scale ← @


# a texture id‿width‿height‿mipmaps‿format 
# to isolate width‿height we do
TexSize ← {2↑1↓𝕩}

# loads assets into global variables
# we can't initialize font&Co. in the toplevel since font loading&Co.
# need the raylib window to be active to work, so we'll have to load
# assets *after* opening the window, ie: not here
LoadAssets ← { 𝕊@:
    # texture.Load needs absolute paths
    # •file.At turns relative paths it receives into absolute
    # idk if that's a documented thing, but it works
    # so I'll depend on it, if it breaks on windows then whoops
    TL ← r.texture.Load∘•file.At
    font ↩ r.font.LoadBQN@
    needle_texture ↩ TL "../assets/speedometer_needle.png"
    speedometer_texture ↩ TL "../assets/speedometer.png"
    boulder_texture ↩ TL "../assets/boulder.png"
    dirt_texture ↩ TL "../assets/dirt.png"
}

# unload all loaded assets
# this is our teardown function
UnloadAssets ← { 𝕊@:
       r.font.Unload font
       r.texture.Unload speedometer_texture
       r.texture.Unload needle_texture
       r.texture.Unload boulder_texture
       r.texture.Unload dirt_texture
       #r.raylib.UnloadWave soundMixWav
       #r.raylib.UnloadSound soundMix
       r.raylib.CloseAudioDevice⟨⟩
}

Setup ← { 𝕊@:
    LoadAssets@
    # we should probably crop the boulder
    # texture width is currently not quite border display size
    # I'm adding a multiplication by 0.8 as a hack
    boulder_scale ↩ {
        # width and height of the texture
        bw‿bh ← TexSize boulder_texture
        # radius is half the rock's width
        br ← 0.8 × bw ÷ 2
        radius ÷ br
    }
    speedometer_scale ↩ {
        speedometer_radius ← 100 # to be parameterized better later
        sw‿sh ← TexSize speedometer_texture
        sr ← sw ÷ 2
        speedometer_radius ÷ sw
    }

}

Teardown ← {𝕊@:
    UnloadAssets@
}


# raylib rotates textures around their top left corner
# we want to rotate the texture around its center, so we need to
# translate the texture after the rotation
# function to compute the offset we need to translate by
# width height 𝕊 angle
Spin ← { w‿h𝕊a :
     ar ← π × a ÷ 180 # raylib angles are degrees, •math.Sin and •math.Cos want radians
     as‿ac ← ⟨•math.Sin ar, •math.Cos ar⟩
     dx ← (ac×w÷2) - (as×h÷2)
     dy ← (ac×h÷2) + (as×w÷2)  
     dx‿dy
}

DrawTextureCentered ← { x‿y‿angle‿scale 𝕊 tex :
    tw‿th ← scale × TexSize tex
    off ← tw‿th Spin angle
    r.color.white‿tex‿scale‿angle r.draw.Texture x‿y - off
}

DrawSpeedometer ← { x‿y 𝕊 speed :
    # turn tartget speed to display from speed into needle angle
    # for how we draw the speedometer
    # 0 is 180 degrees (raylib uses degrees)
    # 100 is 0 degrees
    # and plus the needle texture is already at 90 degrees
    needle_angle ← 90 + 180 × 100 ÷˜ speed - 100
    
    x‿y‿0‿speedometer_scale DrawTextureCentered speedometer_texture
    x‿y‿needle_angle‿speedometer_scale DrawTextureCentered needle_texture
}

DrawBoulder ← { x‿y𝕊angle : 10
    x‿y‿angle‿boulder_scale DrawTextureCentered boulder_texture
}

r.raylib.SetTraceLogLevel r.raylib.traceLogLevel.log_all
PerFrame ← {𝕊:
    # First frame does setup
    {frame ≡ 0?
        r.raylib.SetTraceLogLevel r.raylib.traceLogLevel.log_all
        screenSize ↩ r.monitor.Size@
        center ↩ 2÷˜screenSize-radius
        font↩r.font.LoadBQN@
        r.raylib.InitAudioDevice⟨⟩
        #soundMixWav ↩ r.raylib.LoadWave soundMixFile
        #soundMix ↩ r.raylib.LoadSoundFromWave soundMixWav
        #r.raylib.PlaySound soundMix
    ;@}
    #textWidth ← ⊑r.raylib.MeasureTextEx ⟨ font ⋄ •Repr speed ⋄ 20 ⋄ 0 ⟩
    #⟨r.color.black⋄font⋄20⟩ r.draw.Text ⟨(textWidth‿0÷2)-˜0‿30-˜0‿radius-˜center⋄•Repr speed⟩

    # Hill moves backwards for forward movement
    hillPosition {-⟜𝕨⌾⊑𝕩}˜↩ speed

    # Gravity and floor collision
    {CheckCollision hillPosition?
        gravityAcceleration ↩ 0
        gravitySpeed ↩ 0
    ;
        gravityAcceleration +↩ 0.02
        gravitySpeed +↩ 0.6×gravityAcceleration
        hillPosition -⟜gravitySpeed⌾(1⊸⊑)↩
        {CheckCollision hillPosition?
            gravityAcceleration ↩ 0
            gravitySpeed ↩ 0
            hillPosition (+⟜1⌾(1⊸⊑)•_while_ CheckCollision) ↩
        ;@}
    }

    # Hit obstacle
    {(radius+⊑center-hillPosition) > ⊑nextObstacleIndex⊏obstacles ?
        speed -↩ •rand.Range 10
        nextObstacleIndex((≠obstacles)|+)↩1
    ;@}

    # generate future hill
    {¬ (-1⊑hillPosition)>1⊑(⌊2÷˜≠)⊸⊏hillVertices? @;
        hillVertices↩((⌊2÷˜≠)⊸↓hillVertices)∾(⊢˝hillVertices)⊸+˘ (⌊2÷˜≠)⊸↑GetHillVertices@
        lines ↩ 2↕hillVertices

        hillBottomLeft ↩ (⌊´)⊸∾⟜(⌈´)˝⍉hillVertices
        hillAsTriangles ↩ ∾⟜hillBottomLeft⎉2 lines

        obstacles ← (0=distanceBetweenObstacles|↕∘≠)⊸/hillVertices
        pickups ← (0=distanceBetweenObstacles|5+↕∘≠)⊸/hillVertices
    }

    # Drawing boulder character
    center DrawBoulder angle
    # TODO: is this ok? should we sync this with timingHeadAngle?
    angle ↩ 360 | speed + angle


    # Drawing speedometer
    (10×speed) DrawSpeedometer˜ ⌊∘(÷⟜3)⌾(1⊸⊑)center

    # Drawing black sector for timing window
    r.raylib.DrawCircleSector ⟨center⋄radius×0.8⋄80⋄100⋄1⋄r.color.black⟩
    r.raylib.DrawCircleSector ⟨center⋄radius×0.7⋄80⋄100⋄1⋄r.color.red⟩

    # Drawing white clock hand for when to hit timing window
    scale ← 0.1
    ⟨4⥊255, 5⟩ r.draw.Line ≍⟜(+⟜(timingHeadAngle Spin˜ ∾˜radius)) center

    # Drawing hill and obstacles
    r.color.darkBrown r.draw.Rectangle ¯40‿¯400⊸+⊸≍˘ hillPosition⊸+˘obstacles
    r.color.green⊸r.draw.Triangle hillPosition⊸+⎉1 hillAsTriangles

    timingHeadAngle+↩2
    frame+↩1
}draw._withCanvas⟜r.color.lightblue

GameOver ← {𝕊:
    {𝕊:
        loseTitle ← "You Lose"‿"You're too slow to go on"
        {𝕊:
            textWidth ← ⊑r.raylib.MeasureTextEx ⟨ font ⋄ 𝕨 ⋄ 20 ⋄ 0 ⟩
            ⟨r.color.black⋄font⋄20⟩ r.draw.Text ⟨ 0‿(40×𝕩)+ (textWidth‿0÷2)-˜0‿30-˜0‿radius-˜center⋄𝕨⟩
        }¨⟜(↕≠) loseTitle
        r.raylib.EndDrawing⟨⟩
    }draw._withCanvas r.color.red

    # Reset when pressing anything
    0≡r.key.PressedKey⟨⟩?@;
        center ↩ @ # Runtime because screen size changes midddle
        screenSize ↩ @
        frame ↩ 0
        hillPosition ↩ 0‿0 # height ‿ rightMovement
        speed ↩ 10
        gravityAcceleration ↩ 10
        gravitySpeed ↩ 0
        timingHeadAngle ↩ 90
        angle ↩ 0

        obstacles ↩ (0=(50⥊1)»distanceBetweenObstacles|20+↕∘≠)⊸/hillVertices
        pickups ↩ (0=(20⥊1)»distanceBetweenPickups|↕∘≠)⊸/hillVertices
}

{𝕊:
    Setup@
    {𝕊:speed<5}◶PerFrame‿GameOver •_While_(¬window.ShouldClose) 0
    Teardown@
} window._openAs "Hello!!!"
