o ← ⟨⟩ •Import "../rayed-bqn/imports/BQNoise/options.bqn"
o.SetFreq 48e3 ⋄ o.SetFBytes •fbytes
wav ← o •Import "../rayed-bqn/imports/BQNoise/wav.bqn"

RR ← •rand.Range
_similar ← {s←×˝˘(2«3¨𝕩)⊸⋆˘𝕩⊸=˘𝕨 ⋄ ⥊𝕩∾𝕨⊏˜(+`s)⍋(𝕗-1)RR+´s}

dat ← {
  name ⇐ "tiles_A.wav"
  seq ⇐ "ABAGACDECACFCCDG"
  Gen ⇐ {𝕊:
    gh ← "AB"∾(>⥊⋈⌜˜"AC")
    gx ← gh ∾ >⥊"ACE"⋈⌜"DFG"
    grp ← gh (∾˝∾⎉1⎉1‿∞) gx∾"DE"∾"DF"≍˘'G'
    base ← gx 2 _similar RR∘≠⊸⊏ gh
    grp 7 _similar base
  }
}‿{
  name ⇐ "tiles_B.wav"
  seq ⇐ "ABCDFBADEFEGFDEH"
  Gen ⇐ {𝕊:
    ga ← (∾˝∾⎉1⎉1‿∞)˜>⥊"ACF"⋈⌜"ABDH"
    ge ← >⥊(<"")∾⌜´"CEF"‿"DEF"‿"AEF"‿"DEFGH"
    grp ← ga∾ge
    grp 7 _similar RR∘≠⊸⊏ grp
  }
}
ind ← (≠dat) (RR∘⊣ ⊣´ >/⊢) dat {𝕩.name}¨⊸⊐ •args
name‿seq‿Gen ← ind⊑dat

in‿sec ← 8‿16 × beat ← ⌊0.5+(60×48e3)÷4×110
ov ← 500
rec ← (in-ov) ↓ ⊏wav.Read name
main ← <˘ ⌊‿sec ⥊ rec
over ← ov ↑¨ ⟨(+´≠¨main)↓rec⟩ « main  # ov samples after each section
Tile ← {
  ∾ (⟨ov⥊0⟩»𝕩⊏over) (⊣-(↕⊸÷ov)×-)⌾(ov⊸↑)¨ 𝕩⊏main
}
Sequence ← {
  # Find a sequence with the fewest cuts
  # Index and length of a longest-possible unbroken suffix at each position
  l ← 0¨𝕨
  [n,i] ← ⍉ {m←⌈´l↩𝕩×1+»l ⋄ ⟨m,⊑l⊐m⟩}˘ 𝕩=⌜𝕨
  # Remove overlaps, breaking ties towards later sequences
  i‿n /¨˜↩< ≥⟜« {𝕨(-+𝕩×=)1}`⌾⌽ n
  # Assemble the chosen sequences
  (⊒/n) + n/i¬n
}

"/tmp/test.wav" wav.Write˜ Tile seq Sequence •Show Gen@
