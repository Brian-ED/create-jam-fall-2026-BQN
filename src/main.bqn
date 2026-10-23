# Import raylib as r, and from r, take out color, window, and draw.
# from color take out red, white and black
⟨⟨red, white, black⟩⇐color, window, draw⟩←r←•Import "../rayed-bqn/rayed.bqn"

PerFrame ← {𝕤
    screenSize←r.monitor.Size@
    red draw.Ellipse [ 100-˜2÷˜screenSize ⋄ 100+2÷˜screenSize ]
    r.color.green draw.Triangle [0‿0 ⋄ 0∾⊑screenSize ⋄ screenSize]
}draw._withCanvas⟜r.color.lightblue

PerFrame•_While_(¬window.ShouldClose)window._openAs "Hello!!!"
# run PerFrame while condition is true, and run this with the window opened as "Hello!!!"
# if window should close, close it
