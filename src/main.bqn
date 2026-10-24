# Import raylib as r, and from r, take out color, window, and draw.
# from color take out red, white and black
⟨⟨red, white, black⟩⇐color, window, draw⟩←r←•Import "../rayed-bqn/rayed.bqn"

GetHillVertices ← {𝕊:
    randomAngles ← (⌊÷⟜2 angleRandomness) -˜ hillLineCount •rand.Range angleRandomness
    followAngles ← ¯45(¯75⌈¯35⌊+)`randomAngles
    asMats ← r.math.MatrixRotate2D¨ r.math.deg2rad× followAngles
    linesAtAnglesFormHill ← r.math.MP⟜0‿hillDetail¨ asMats
    0‿0∾0‿0+`>linesAtAnglesFormHill
}

CheckCollision ← {𝕊:∨´{r.raylib.CheckCollisionCircleLine ⟨center⋄radius⋄𝕨⋄𝕩⟩}˝⎉2  𝕩⊸+⎉1 lines}

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

radius ← 100
hillDetail ← 100
hillLineCount ← 200  # hillLineCount × hillDetail = hillLength
angleRandomness ← 20
distanceBetweenObstacles ← 40

hillVertices←GetHillVertices@
lines ← 2↕hillVertices

hillBottomLeft ← (⌊´)⊸∾⟜(⌈´)˝⍉hillVertices
hillAsTriangles ← ∾⟜hillBottomLeft⎉2 lines

# Runtime variables
center ← @ # Runtime because screen size changes midddle
screenSize ← @
frame ← 0
hillPosition ← 0‿0 # height ‿ rightMovement
speed ← 10
gravityAcceleration ← 10
gravitySpeed ← 0
timingHeadAngle ← 90

obstacles ← (0=distanceBetweenObstacles|↕∘≠)⊸/hillVertices
pickups ← (0=distanceBetweenObstacles|5+↕∘≠)⊸/hillVertices

PerFrame ← {𝕊:
    {frame ≡ 0?
      screenSize ↩ r.monitor.Size@
      center ↩ 2÷˜screenSize-radius
    }
    hillPosition {-⟜𝕨⌾⊑𝕩}˜↩ speed
    {CheckCollision hillPosition?
        gravityAcceleration ↩ 0
        gravitySpeed ↩ 0
    ;
        # Gravity
        gravityAcceleration +↩ 0.02
        gravitySpeed +↩ 0.6×gravityAcceleration
        hillPosition -⟜gravitySpeed⌾(1⊸⊑)↩
        {CheckCollision hillPosition?
            gravityAcceleration ↩ 0
            gravitySpeed ↩ 0
            hillPosition (+⟜1⌾(1⊸⊑)•_while_ CheckCollision) ↩
        ;@}
    }

    # generate future hill
    {¬ (-1⊑hillPosition)>1⊑(⌊2÷˜≠)⊸⊏hillVertices? @;
        hillVertices↩((⌊2÷˜≠)⊸↓hillVertices)∾(•Show ⊢˝hillVertices)⊸+˘ (⌊2÷˜≠)⊸↑GetHillVertices@
        lines ↩ 2↕hillVertices

        hillBottomLeft ↩ (⌊´)⊸∾⟜(⌈´)˝⍉hillVertices
        hillAsTriangles ↩ ∾⟜hillBottomLeft⎉2 lines

        obstacles ← (0=distanceBetweenObstacles|↕∘≠)⊸/hillVertices
        pickups ← (0=distanceBetweenObstacles|5+↕∘≠)⊸/hillVertices
    }

    r.raylib.DrawCircleV ⟨ center ⋄ radius ⋄ red⟩

    r.raylib.DrawCircleSector ⟨center⋄radius×0.8⋄80⋄100⋄1⋄r.color.black⟩
    r.raylib.DrawCircleSector ⟨center⋄radius×0.7⋄80⋄100⋄1⋄r.color.red⟩

    scale ← 0.1
    ⟨4⥊255, 5⟩ r.draw.Line ≍⟜(+⟜(timingHeadAngle Spin˜ ∾˜radius)) center

    r.color.darkBrown r.draw.Rectangle ¯40‿¯400⊸+⊸≍˘ hillPosition⊸+˘obstacles
    r.color.green⊸r.draw.Triangle hillPosition⊸+⎉1 hillAsTriangles

    timingHeadAngle+↩2
}draw._withCanvas⟜r.color.lightblue

PerFrame•_While_(¬window.ShouldClose)window._openAs "Hello!!!"
