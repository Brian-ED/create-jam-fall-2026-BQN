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
pattern ← lvl {⥊ {¯1¨⌾(𝕨⊸/)𝕩}⟜𝕩˘ (↕8)<⌜0⌈𝕨}¨ pat

# Assemble drums
PinkDiff ← {𝕩 ↑ ⥊∘⍉∘≍´⌽ -⟜«∘(-⟜¬o.RandFloats)¨ (1⌈↕∘⌈)⌾(2⋆⁼⊢)2⌈𝕩}
bl ← ⌊0.5+ beat × 1 + 100 ÷˜ PinkDiff ≠⊑pattern
len ← (12×beat)+´bl
Seq ← { m ← 0≤𝕩 ⋄ ∾≍ (+´¨ m+`⊸⊔bl) ↑⎉1¨ ⟨2‿0⥊0⟩∾𝕨⊏˜m/𝕩 }
d ← (0⥊˜12×beat)⊸∾˘ 0.75 × +´ sample Seq¨ pattern

# Read guitars and mix
g ←                               len ↑ ⊏wav.Read "guitar.wav"
b ← {(0.75×𝕩)+8÷˜•math.Tanh 32×𝕩} len ↑ ⊏wav.Read "bass.wav"
"mix.wav" wav.Write˜ d +⎉1 g + b
