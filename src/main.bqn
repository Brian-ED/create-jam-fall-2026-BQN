# Import raylib as r, and from r, take out color, window, and draw.
# from color take out red, white and black
⟨⟨red, white, black⟩⇐color, window, draw⟩←r←•Import "../rayed-bqn/rayed.bqn"

CheckCollisionRay2dCircle ← {direction𝕊center‿radius: c‿r←𝕩 # v2 𝕊 v2‿f
  𝕨×⍟(0⊸≠)¨˜-0⌊(0⊸<◶¯∞‿√r×˜⊸-·+´∘×˜c-𝕨×⊢)⌾((0⌈+´𝕨×c)⊸+)0
}

circle_height ← 10
radius ← 100

frame ← 0
screenSize ← 0‿0
hillDetail ← 100
lineCount ← 40
angleRandomness ← 20

lines ← {
    randomAngles ← (⌊÷⟜2 angleRandomness) -˜ lineCount •rand.Range angleRandomness
    followAngles ← ¯45+`randomAngles
    asMats ← r.math.MatrixRotate2D¨ r.math.deg2rad× followAngles
    linesAtAnglesFormHill ← r.math.MP⟜0‿hillDetail¨ asMats
    2↕ 0‿0∾0‿0+`>linesAtAnglesFormHill
}

PerFrame ← {𝕊:
    {frame ≡ 0?
      screenSize↩r.monitor.Size@
    }
    r.raylib.DrawCircleV ⟨ circle_height+2÷˜screenSize-radius ⋄ radius ⋄ red⟩
    {r.color.green⊸r.draw.Triangle 𝕩∾0∾1⊑screenSize}⎉2 lines
#    r.color.green draw.Triangle [0‿0 ⋄ 0∾⊑screenSize ⋄ screenSize]

}draw._withCanvas⟜r.color.lightblue

PerFrame•_While_(¬window.ShouldClose)window._openAs "Hello!!!"
