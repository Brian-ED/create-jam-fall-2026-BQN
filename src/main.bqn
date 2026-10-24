# Import raylib as r, and from r, take out color, window, and draw.
# from color take out red, white and black
⟨⟨red, white, black⟩⇐color, window, draw⟩←r←•Import "../rayed-bqn/rayed.bqn"

CheckCollisionRay2dCircle ← {direction𝕊center‿radius: c‿r←𝕩 # v2 𝕊 v2‿f
  𝕨×⍟(0⊸≠)¨˜-0⌊(0⊸<◶¯∞‿√r×˜⊸-·+´∘×˜c-𝕨×⊢)⌾((0⌈+´𝕨×c)⊸+)0
}

radius ← 100
hillDetail ← 100
hillLineCount ← 100  # hillLineCount × hillDetail = hillLength
angleRandomness ← 20

hillVertices ← {
    randomAngles ← (⌊÷⟜2 angleRandomness) -˜ hillLineCount •rand.Range angleRandomness
    followAngles ← ¯45(¯75⌈¯35⌊+)`randomAngles
    asMats ← r.math.MatrixRotate2D¨ r.math.deg2rad× followAngles
    linesAtAnglesFormHill ← r.math.MP⟜0‿hillDetail¨ asMats
    0‿0∾0‿0+`>linesAtAnglesFormHill
}

lines ← 2↕hillVertices

hillBottomLeft ← (⌊´)⊸∾⟜(⌈´)˝⍉hillVertices
hillAsTriangles ← ∾⟜hillBottomLeft⎉2 lines

# Runtime variables
center ← @ # Runtime because screen size changes midddle
screenSize ← @
frame ← 0
hillPosition ← 0‿0 # height ‿ rightMovement
speed ← 10

PerFrame ← {𝕊:
    {frame ≡ 0?
      screenSize ↩ r.monitor.Size@
      center ↩ 2÷˜screenSize-radius
    }
    hillPosition {-⟜𝕨⌾⊑𝕩}˜↩ speed×r.key.IsDown r.key.right

    # If not collides with mountain
    {¬∨´{r.raylib.CheckCollisionCircleLine ⟨center⋄radius⋄𝕨⋄𝕩⟩}˝⎉2  hillPosition⊸+⎉1 lines?
        # Gravity
        hillPosition -⟜10⌾(1⊸⊑)↩
    ;@}

    r.raylib.DrawCircleV ⟨ center ⋄ radius ⋄ red⟩
    r.color.green⊸r.draw.Triangle hillPosition⊸+⎉1 hillAsTriangles
}draw._withCanvas⟜r.color.lightblue

PerFrame•_While_(¬window.ShouldClose)window._openAs "Hello!!!"
