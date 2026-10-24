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

CheckCollision ← {𝕊:∨´{r.raylib.CheckCollisionCircleLine ⟨center⋄radius⋄𝕨⋄𝕩⟩}˝⎉2  𝕩⊸+⎉1 lines}

obstacles ← (0=distanceBetweenObstacles|↕∘≠)⊸/hillVertices

PerFrame ← {𝕊:
    {frame ≡ 0?
      screenSize ↩ r.monitor.Size@
      center ↩ 2÷˜screenSize-radius
    }
    hillPosition {-⟜𝕨⌾⊑𝕩}˜↩ speed×r.key.IsDown r.key.right
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
    }

    r.raylib.DrawCircleV ⟨ center ⋄ radius ⋄ red⟩

    r.color.darkBrown r.draw.Rectangle ¯40‿¯400⊸+⊸≍˘ hillPosition⊸+˘obstacles
    r.color.green⊸r.draw.Triangle hillPosition⊸+⎉1 hillAsTriangles

}draw._withCanvas⟜r.color.lightblue

PerFrame•_While_(¬window.ShouldClose)window._openAs "Hello!!!"
