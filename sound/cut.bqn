o ← ⟨⟩ •Import "../rayed-bqn/imports/BQNoise/options.bqn"
o.SetFreq 48e3 ⋄ o.SetFBytes •fbytes
wav ← o •Import "../rayed-bqn/imports/BQNoise/wav.bqn"
in‿sec ← 8‿16 × beat ← ⌊0.5+(60×48e3)÷4×110

rec ← ⌊‿sec ⥊ in↓ ⊏wav.Read "tiles_A.wav"
seq ← "ABAGACDECACFCCDG"

Sequence ← {
  # Find sequence with fewest cuts, by dynamic programming
  # At each step we store one overall best sequence explicitly,
  # and one best for each specific ending e implicitly, with l
  e ← ⋈¯1  # Possible endings
  l ← ⋈0   # Length of suffixes that lead into them
  c ← ⋈0   # Cost (in cuts) relative to best sequence: always 0 or 1
  j ← (↕0) {
    i ← (e+1) ⊐ 𝕨
    e ↩ 𝕨
    l ↩ 1 + i ⊏ l∾0
    c ↩ ∧´⊸< i ⊏ c∾1  # ∧´⊸< so best stays at 0 (otherwise need c∾1+⌊´c)
    b ← ⊑⍋c           # Index of best
    s ← (b⊑e) -⌽↕ b⊑l # Corresponding suffix
    ((1-≠s)↓𝕩) ∾ s
  }´⌽ 𝕩 ⊏⟜⊔○(-⟜'A') seq
  ⥊ j ⊏ rec
}
"/tmp/test.wav" wav.Write˜ Sequence "CCABADDECCFGACED"
