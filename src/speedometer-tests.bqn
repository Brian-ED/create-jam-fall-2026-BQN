# test/scratchpad file for me to figure out "how fuck to do speedometer"
# partially copied from the Texture+shapes.bqn example

# Import raylib as r, and from r, take out color, window, and draw.
# from color take out red, white and black
⟨m⇐mouse,
 c⇐color,
 ⟨red, white, black⟩⇐color,
 w⇐window,
 d⇐draw,
 ⟩←r←•Import "../rayed-bqn/rayed.bqn"

# texture spins around its left right corner
# how can I make it spin around its center?
# Spin function takes width and height of texture, and angle by which you want it to
# rotate around its center
# returns delta x and delta y by which to translate it to make the
# rotated texture look like it was from the center
Spin ← { w‿h𝕊a :
     # ie the distance between the center of the image and the topleft
     # corner of the image, rotated by angle a
     # a is in degrees so
     ar ← π × a ÷ 180 
     as‿ac ← ⟨•math.Sin ar, •math.Cos ar⟩
     dx ← (ac×w÷2) - (as×h÷2)
     dy ← (ac×h÷2) + (as×w÷2)  
     dx‿dy
}

# texture as an array is represented as
# id‿width‿height‿mipmaps‿format
# (see `typedef struct Texture` in raylib.h, that's its fileds in order)
# to isolate width and height we 2↑ 1↓ tex
TexSize ← {2↑1↓𝕩}

# - draw texture tex
# - centered at x‿y
# - rotated by angle a (in degrees)
# - with scale s
#   - s←1 = full scale
#   - s←0 = nothing
#   - everything else = interpolate linearly in between
DrawTextureCentered ← { x‿y‿a‿s 𝕊 tex :
    # and then we scale it by texture scale
    tw‿th ← s× TexSize tex

    # compute rotated delta between
    # texture center and
    # texture topright corner
    # the raylib function rotates texture around topright corner
    # so to make it appear as if it were rotated around its center
    # we add that delta to the coordinates before spinning so 
    # that it cancels out later
    # we have the spin function for that so
    dl ← tw‿th Spin a

    c.white‿tex‿s‿a d.Texture x‿y - dl
}

# here begins the logic proper, and not just general utilities  to make it work
# load all assets
# if you add have any extra assets
# put their loading here and their unloading in UnloadAll
LoadAll ← { 𝕊@:
    Tl ← r.texture.Load∘•file.At
    {
        font ⇐ r.font.LoadBQN@
        needle_texture ⇐ Tl "../assets/speedometer_needle.png"
        speedometer_texture ⇐ Tl "../assets/speedometer.png"
        boulder_texture ⇐ Tl "../assets/boulder.png"
    }
}

# unload all loaded assets form an asset namespace
UnloadAll ← { 𝕊a :
       r.font.Unload a.font
       r.texture.Unload a.speedometer_texture
       r.texture.Unload a.needle_texture
       r.texture.Unload a.boulder_texture
}

# x and y to draw the speedometer at (center)
# speedometer texture
# needle texture
# scale to draw the speedometer at (shall we parameterize it outside?)
# speed we want the speedometer to display
DrawSpeedometer ← { ⟨x, y, scale,
                     speedometer_texture, needle_texture⟩ 𝕊 speed :
    # turn speed into angle at which to draw the needle
    # for how we draw the speedometer 0 is 180 and 100 is 0 (raylib uses degrees)
    # but the needle texture is at π÷2 degrees, so we must remove those first
    needle_angle ← 90 + 180 × 100 ÷˜ speed - 100
    
    x‿y‿0‿scale DrawTextureCentered speedometer_texture
    x‿y‿needle_angle‿scale DrawTextureCentered needle_texture
}

PerFrame ← {𝕊s‿a :
    ⟨f⇐font,
     nt⇐needle_texture,
     st⇐speedometer_texture,
     bt⇐boulder_texture,
    ⟩←a
    scale ← 1
    mx‿my ← m.GetPos@
    speed ← 100|s.seq # TODO: this is a dummy speed value
    mx‿my‿scale‿st‿nt DrawSpeedometer speed
    c.blue‿f‿100‿0 d.Text 30‿30⋈(•Repr speed)
    s.Update@
    s‿a
}d._withCanvas⟜r.color.black

{𝕤
    state ← {
        seq ⇐ 0
        Update ⇐ { 𝕊@: seq 1⊸+↩ }
    }
    assets ← LoadAll@
    PerFrame•_while_(¬w.ShouldClose) state‿assets
    UnloadAll assets
} w._openAs "test"
