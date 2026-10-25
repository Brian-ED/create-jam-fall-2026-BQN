⟨color,window,draw, sound⟩←r←•Import "../rayed-bqn/rayed.bqn"
⟨Button⟩←•Import "ui.bqn"
fontSize←50

txt ← "Button"
PerFrame ← {𝕊font1‿font2‿font3‿soundButton:
  
  b ← Button ⟨ 150‿150 ⋄ 200‿200 ⋄ txt ⋄ font2 ⋄ 25 ⋄ color.red ⋄ soundButton⟩
  b.Update@
  b.Draw@
  
  𝕩
}draw._withCanvas⟜color.darkgreen

App ← {𝕊:
  soundButton ← r.raylib.LoadSound •file.Realpath "../sound/button/select.wav"
  fonts ← ⟨
    (⍷txt) r.font.Load ⟨100⋄".ttf"⋄•FBytes "../rayed-bqn/imports/BQN386/BQN386.ttf"⟩
    r.font.LoadBQN@
    r.font.LoadRaylib@
  ⟩ 
  PerFrame •_While_(¬window.ShouldClose) fonts∾<soundButton
}sound._withDevice
App window._openAs "test"
