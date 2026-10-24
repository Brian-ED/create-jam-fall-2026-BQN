⟨color,window,draw⟩←r←•Import "../rayed-bqn/rayed.bqn"
⟨Button⟩←•Import "ui.bqn"
fontSize←50

txt ← "Button"
PerFrame ← {𝕊font1‿font2‿font3:
  
  b ← Button ⟨ 150‿150 ⋄ 200‿200 ⋄ txt ⋄ font2 ⋄ 25 ⋄ color.red ⟩
  b.Update@
  b.Draw@
  
  𝕩
}draw._withCanvas⟜color.darkgreen

App ← {𝕊:
  fonts ← ⟨
    (⍷txt) r.font.Load ⟨100⋄".ttf"⋄•FBytes "../rayed-bqn/imports/BQN386/BQN386.ttf"⟩
    r.font.LoadBQN@
    r.font.LoadRaylib@
  ⟩ 
  PerFrame •_While_(¬window.ShouldClose) fonts
}
App window._openAs "test"
