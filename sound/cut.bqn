o ← ⟨⟩ •Import "../rayed-bqn/imports/BQNoise/options.bqn"
o.SetFreq 48e3 ⋄ o.SetFBytes •fbytes
wav ← o •Import "../rayed-bqn/imports/BQNoise/wav.bqn"
in‿sec ← 8‿16 × beat ← ⌊0.5+(60×48e3)÷4×110

rec ← ⌊‿sec ⥊ in↓ ⊏wav.Read "tiles_A.wav"
seq ← "ABAGACDECACFCCDG"

Sequence ← { 𝕊 arg:
  n ← ≠ p ← 2↕seq
  j ← {R w:
    n ← ≠s ← w↕seq
    i ← s ⊐ w↕arg
    {∧´i=n? i ;
      a ← n-1
      t ← a ∾˜ R w+1
      d ← t-(t-1+¯1⌽t)×<`t<a
      i+(d-i)×d<a
    }
  } 1
  ⥊ j ⊏ rec
}
"/tmp/test.wav" wav.Write˜ Sequence "CCABADDECCFGACED"
