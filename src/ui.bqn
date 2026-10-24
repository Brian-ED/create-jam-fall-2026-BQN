r←•Import "../rayed-bqn/rayed.bqn"

⟨Button⟩ ⇐

Button ← {
    pos‿size‿title‿font‿fontSize‿col ⇐ 𝕩
    {
        # Error handling
        "Position must have 2 argument"!2¬≠pos,
        "Size must have 2 argument"!2¬≠size
    }

    isHovered ⇐ 0

    Draw ⇐ {𝕊:
        # Draw rectangle with text 
        color ← { isHovered ? ⌊(col × 0.8‿0.8‿0.8‿1) ; col}

        spacing ← 0

        textSize ← r.raylib.MeasureTextEx ⟨ font ⋄ title ⋄ fontSize ⋄ spacing ⟩
        textX ← ⌊(0⊑pos + (0⊑size - 0⊑textSize) ÷ 2)
        textY ← ⌊(1⊑pos + (1⊑size - 1⊑textSize) ÷ 2)

        color r.draw.Rectangle pos⊸+⊸≍size
        r.color.black‿font‿fontSize r.draw.Text textX‿textY⋈title 
    }
    Update ⇐ {𝕊: {
            r.raylib.CheckCollisionPointRec ⟨ r.mouse.GetPos@ ⋄ pos∾size ⟩  ? isHovered ↩ 1 ; isHovered ↩ 0
        }  

    }

}
# b ← Button ⟨20‿2 ⋄ 10‿4 ⋄ "Button" ⋄ font ⋄ fontsize ⋄ red⟩ example on how to make