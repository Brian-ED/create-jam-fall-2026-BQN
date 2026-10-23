#!/usr/bin/env bqn

IsUpcase   ← (≥⟜'A'∧≤⟜'Z')
IsDowncase ← (≥⟜'a'∧≤⟜'z')
Upcase     ← (⊢-32×IsDowncase)
Downcase   ← (⊢+32×IsUpcase)

bonkmsgs ← ⟨
    "you bonked against a wall"
    "the wall is sadly still there"
    "the wall does not appear to be moving"
    "have you tried going right? it's all the rage these days"
    "you bonked against a wall (please go right)"
    "you bonked against a wall (please go right)"
    "you bonked against a wall (...)"
⟩

state ← { 
    pos  ⇐ 1
    bonk ⇐ 0
    succ ⇐ 0
    SetP ⇐ {pos ↩𝕩}
    SetB ⇐ {bonk↩𝕩}
    SetS ⇐ {succ↩𝕩}
}

Tick ← {𝕊state :
     •Out "do you want to go left or right?"
     •term.OutRaw "> "
     action ← •GetLine@
     l   ← ∨´"left" ⍷action
     r   ← ∨´"right"⍷action
     state Act l‿r
}

Act ← {
    state𝕊l‿r : l ∧ r ?
    •Out "you cannot go left and right at the same time"
    state
    ;

    state𝕊l‿r : ¬ l ∨ r ?
    •Out "that is not a direction you can go in"
    state
    ;

    state𝕊l‿r : l ?
    {𝕊pos‿bonk : pos = 0 ? # going left with pos = 0 causes a bonk
               •Out bonkmsgs ⊑˜ bonk⌊1-˜≠bonkmsgs
               𝕩.SetB 1+bonk ⋄ 𝕩 ;
     𝕊pos‿bonk :
               •Out "you succesfully went left, great work!"
               𝕩.SetP pos-1 ⋄ 𝕩
    } state
    ;
    state𝕊l‿r : r ?
    {𝕊pos‿bonk : pos ≥ 5 ?
               •Out "you have found a thing!"
               𝕩.SetS 1 ⋄ 𝕩;
     𝕊pos‿bonk :
               •Out "you succesfully went right, great work!"
               𝕩.SetP 1+pos ⋄ 𝕩
    } state
    ;
    state𝕊l‿r : !"what the fuck bro"
}

Tick•_while_{𝕊⟨succ⟩ : ¬succ} State@
