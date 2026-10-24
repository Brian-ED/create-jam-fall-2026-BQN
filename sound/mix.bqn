o ← ⟨⟩ •Import "../rayed-bqn/imports/BQNoise/options.bqn"
o.SetFreq 48e3 ⋄ o.SetFBytes •fbytes
wav ← o •Import "../rayed-bqn/imports/BQNoise/wav.bqn"

beat ← ⌊0.5+(60×48e3)÷6×90  # 90 BPM

[pat,lvl] ← "a0" -˜ ⍉∘‿2⥊⟨
  "b.....a.....a.......a...b.....a.....a.......a..." # ride
  "0     1     1       0   0     1     1       0   "

  "......a.......................a................." # tom
  "      0                       0                 "

  "...e.c...e.....d..b..f.....e.....e...c.d.b.a.d.." # snare
  "   4 5   3     4  5  3     4     3   5 4 7 6 3  "

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
off ← 12×beat
g ←                                          off ↓ ⊏wav.Read "guitar.wav"
b ← {(0.75×𝕩)+8÷˜•math.Tanh 32×𝕩}⌾(÷⟜(2⋆15)) off ↓ ⊏wav.Read "bass.wav"

# Generate a segment: 𝕩 is density, 0 to 7
Gen ⇐ { (𝕩⊏d) +⎉1 g +○(len↑(𝕩×len)↓⊢) b }
