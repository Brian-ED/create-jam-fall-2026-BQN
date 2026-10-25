o ← ⟨⟩ •Import "../rayed-bqn/imports/BQNoise/options.bqn"
o.SetFreq 48e3 ⋄ o.SetFBytes •fbytes
wav ← o •Import "../rayed-bqn/imports/BQNoise/wav.bqn"

beat ← ⌊0.5+(60×48e3)÷6×90  # 90 BPM

[pat,lvl] ← "a0" -˜ ⍉∘‿2⥊⟨
  "b.....a.....a.......a...b.....a.....a.......a..." # ride
  "0     1     1       0   0     1     1       0   "

  "......a.......................a................." # tom
  "      0                       0                 "

  "...e.c...e.....d..bacf.....e.....e...c.dccab.d.." # snare
  "   4 5   3     4  5773     4     3   5 47766 3  "

  "b..........b..b..b...a..b.......b..b.........b.." # kick
  "0          0  1  1   0  0       0  0         0  "
⟩

# Read samples
pre ← ("drum_sample/"∾∾⟜"_")¨ "ride"‿"tom"‿"snare"‿"kick"
sample ← pre <⊸((wav.Read∾∾".wav"˙)¨)¨ 'a'+↕¨1+⌈´¨pat

# Construct drum sequence
pattern ← lvl {{¯1¨⌾(𝕨⊸/)𝕩}⟜𝕩˘ (↕8)<⌜0⌈𝕨}¨ pat

# Assemble drums
PinkDiff ← {𝕩 ↑ ⥊∘⍉∘≍´⌽ -⟜«∘(-⟜¬o.RandFloats)¨ (1⌈↕∘⌈)⌾(2⋆⁼⊢)2⌈𝕩}
n ← ≠⊑pat ⋄ len ⇐ n×beat
bl ← {⌊0.5+len×÷⟜(⊢´)𝕩}⌾(+`) beat × 1 + 100 ÷˜ PinkDiff n
! len = +´bl
Seq ← { m ← 0≤𝕩 ⋄ ∾≍ (+´¨ m+`⊸⊔bl) ↑⎉1¨ ⟨2‿0⥊0⟩∾𝕨⊏˜m/𝕩 }
d ← 0.75 × +´ sample Seq⎉1¨ pattern

# Read guitars
rot ← ¯2e3  # rotate to avoid guitar.wav popping
off ← rot + 12×beat
Tanh8 ← •math.Tanh⌾(÷⟜(8×2⋆15))
Pan ← 2⊸(⊢⋈-)⊸(×⌜)
g ← 1.07 Pan             off ↓ ⊏wav.Read "guitar.wav"
b ← {(0.75×𝕩)+Tanh8 4×𝕩} off ↓ ⊏wav.Read "bass.wav"
r ← 0.88 Pan 2 × Tanh8   off ↓ ⊏wav.Read "rhythm.wav"

Sl ← len⊸×⊸{o‿l𝕊𝕩: (l↑o↓⊢)⎉1𝕩; o𝕊𝕩:o‿len𝕊𝕩}
# Generate a segment: 𝕩 is density, 0 to 7
Gen ⇐ { +⎉1´ ⟨rot⌽⎉1𝕩⊏d⟩∾ (𝕨⊢⊘×⊢)⌾(¯1⊸⊑) 𝕩⊸Sl⎉1¨ g‿b‿r }
# Ending segment: constant but double length
End ⇐ {𝕊: (⥊˘1⍉2↑d) + (1 Sl g) ∾⟜(0¨)⊸+⎉1 4‿2 Sl b }
