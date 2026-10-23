# Import raylib as r, and from r, take out color, window, and draw.
# from color take out red, white and black
⟨⟨red, white, black⟩⇐color, window, draw⟩←r←•Import "../rayed-bqn/rayed.bqn"

CheckCollisionRay2dCircle ← {direction𝕊center‿radius: c‿r←𝕩 # v2 𝕊 v2‿f
  𝕨×⍟(0⊸≠)¨˜-0⌊(0⊸<◶¯∞‿√r×˜⊸-·+´∘×˜c-𝕨×⊢)⌾((0⌈+´𝕨×c)⊸+)0
}

pos ← 100‿100
radius ← 100

PerFrame ← {𝕤
    screenSize←r.monitor.Size@
    r.raylib.DrawCircleV ⟨ pos ⋄ radius ⋄ red⟩
    r.color.green draw.Triangle [0‿0 ⋄ 0∾⊑screenSize ⋄ screenSize]

}draw._withCanvas⟜r.color.lightblue

PerFrame•_While_(¬window.ShouldClose)window._openAs "Hello!!!"
