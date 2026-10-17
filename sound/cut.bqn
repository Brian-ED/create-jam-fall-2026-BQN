o ← ⟨⟩ •Import "../rayed-bqn/imports/BQNoise/options.bqn"
o.SetFreq 48e3 ⋄ o.SetFBytes •fbytes
wav ← o •Import "../rayed-bqn/imports/BQNoise/wav.bqn"
in‿sec ← 8‿16 × beat ← ⌊0.5+(60×48e3)÷4×110

ov ← 500
rec ← (in-ov) ↓ ⊏wav.Read "tiles_A.wav"
main ← <˘ ⌊‿sec ⥊ rec
over ← ov ↑¨ ⟨(+´≠¨main)↓rec⟩ « main  # ov samples after each section
seq ← "ABAGACDECACFCCDG"

Sequence ← {
  # Find a sequence with the fewest cuts
  # Index and length of a longest-possible unbroken suffix at each position
  l ← 0¨seq
  [n,i] ← ⍉ {m←⌈´l↩𝕩×1+»l ⋄ ⟨m,⊑l⊐m⟩}˘ 𝕩=⌜seq
  # Remove overlaps, breaking ties towards later sequences
  i‿n /¨˜↩< ≥⟜« {𝕨(-+𝕩×=)1}`⌾⌽ n
  # Assemble the chosen sequences
  j ← (⊒/n) + n/i¬n

  ∾ (⟨ov⥊0⟩»j⊏over) (⊣-(↕⊸÷ov)×-)⌾(ov⊸↑)¨ j⊏main
}

gh ← "AB"∾(>⥊⋈⌜˜"AC")
gx ← gh ∾ >⥊"ACE"⋈⌜"DFG"
grp ← gh (∾˝∾⎉1⎉1‿∞) gx∾"DE"∾"DF"≍˘'G'
_similar ← {s←×˝˘(2«3¨𝕩)⊸⋆˘𝕩⊸=˘𝕨 ⋄ ⥊𝕩∾𝕨⊏˜(+`s)⍋(𝕗-1)•rand.Range+´s}
base ← gx 2 _similar •rand.Range∘≠⊸⊏ gh
"/tmp/test.wav" wav.Write˜ Sequence •Show grp 7 _similar base
