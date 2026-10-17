o ← ⟨⟩ •Import "../rayed-bqn/imports/BQNoise/options.bqn"
o.SetFreq 48e3 ⋄ o.SetFBytes •fbytes
wav ← o •Import "../rayed-bqn/imports/BQNoise/wav.bqn"
in‿sec ← 8‿16 × beat ← ⌊0.5+(60×48e3)÷4×110

rec ← ⌊‿sec ⥊ in↓ ⊏wav.Read "tiles_A.wav"
seq ← "ABAGACDECACFCCDG"

Sequence ← { 𝕊 arg:
  # Find sequence with fewest cuts, by dynamic programming
  # At each step, s contains the best sequence for each ending segment
  c ← ⋈0  # Cost (in cuts) relative to best sequence: always 0 or 1
  s‿·‿b ← ⟨⋈↕0, ⋈¯1, 0⟩ {𝕨𝕊s‿e‿b:  # sequences, endings, best index
    i ← (e+1)⊐𝕨     # Predecessor without a cut, if any
    l ← i=≠e
    p ← b¨⌾(l⊸/) i  # Predecessor to use
    c ↩ ∧´⊸< l∨p⊏c  # Where l=1, p=b⊑c which is 0, so l+p⊏c is l∨p⊏c
    ⟨(p⊏s) ∾¨ 𝕨, 𝕨, ⊑⍋c⟩
  }´⌽ 𝕩 ⊏⟜⊔○(-⟜'A') seq
  ⥊ (b⊑s) ⊏ rec
}
"/tmp/test.wav" wav.Write˜ Sequence "CCABADDECCFGACED"
