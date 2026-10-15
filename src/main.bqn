⟨⟨red, white, black⟩⇐color, window, draw⟩ ← r← •Import "../rayed-bqn/rayed.bqn"

# sets window size to half the monitor size
window.SetSize 0.5

textSize ← 200

PerFrame ← {⟨bqn⟩𝕊𝕩:
    textSize +↩ -´r.key.IsPressed¨ "+-"
    middle← ⌈r.window.GetSize∘@⊸÷2
    text ← "Hello"
    pos ← r.raylib.MeasureTextCodepoints ⟨bqn⋄@-˜•ToUTF8 text⋄≠•ToUTF8 text⋄textSize⋄1⟩
    ⟨white⋄bqn⋄textSize⟩ r.draw.Text (middle-pos÷2)⋈text
}

{𝕊:
    ⟨r.font.LoadBQN@
    ⟩⊸PerFrame draw._withCanvas⟜r.color.darkGreen •_While_ (¬window.ShouldClose)⟨⟩
} window._openAs "Hello!!!"
