r←•Import "../rayed-bqn/rayed.bqn"

⟨Button⟩ ⇐

Button ← {
    pos‿size‿title‿col ⇐ 𝕩
    {
        # Error handling
        "Position must have 2 argument"!2¬≠pos,
        "Size must have 2 argument"!2¬≠size
    }

    isHovered ⇐ 0

    Draw ⇐ {𝕊:
        # Draw rectangle with text 
        color ← { isHovered ? ⌊(col × 0.8‿0.8‿0.8‿1) ; col}
        
        color r.draw.Rectangle pos⊸+⊸≍size
    }
    Update ⇐ {𝕊: {
            r.raylib.CheckCollisionPointRec ⟨ r.mouse.GetPos@ ⋄ pos∾size ⟩  ? isHovered ↩ 1 ; isHovered ↩ 0
        }  

    }

}
# b ← Button ⟨20‿2 ⋄ 10‿4 ⋄ "Button"⟩ example on how to make