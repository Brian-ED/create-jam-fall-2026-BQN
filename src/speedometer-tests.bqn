# test/scratchpad file for me to figure out "how fuck to do speedometer"
# it is currently concerned with how to make a texture rotate around its
# center, since it doesn't do that by default :|
# I shall later add the logic for this to actually use the speedometer
# assets and rotate the needle by an appropriate amount wrt the actual
# speedometer frame

# once the speedometer is done and then this file can safely be deleted
# (or turned into a more proper speedometer module)

# partially copied from the Texture+shapes.bqn example

# Import raylib as r, and from r, take out color, window, and draw.
# from color take out red, white and black
⟨m⇐mouse,
 c⇐color,
 ⟨red, white, black⟩⇐color,
 w⇐window,
 d⇐draw,
 ⟩←r←•Import "../rayed-bqn/rayed.bqn"

angle ← 0

# texture spins around its left right corner
# how can I make it spin around its center?

# takes width and height of texture, and angle by which you want it to
# rotate around its center
# returns delta x and delta y by which to translate it to make the
# rotation look like it was from the center
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
# (see `typedef struct Texture` in raylib.h)
# to isolate width and height we 2↑ 1↓ tex
TexSize ← {2↑1↓𝕩}

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

PerFrame ← {𝕊tex‿font :
    scale ← 0.1
    mx‿my ← m.GetPos@
    mx‿my‿angle‿scale DrawTextureCentered tex
    # uncomment to show what is the Spin function actually doing
    ⟨4⥊255, 5⟩ d.Line ≍⟜(+⟜(angle Spin˜ scale × TexSize tex)) mx‿my
    angle 1⊸+↩
}d._withCanvas⟜r.color.black

# copied straight from the example code
{𝕤
  font ← r.font.LoadBQN@
  {
    𝕩‿font PerFrame•_while_(¬w.ShouldClose) 0
  } r.texture._withFile •file.At "test.png"
  r.font.Unload font
} w._openAs "test"
