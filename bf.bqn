# BF: BrainFuck Interpreter
⟨
  Parse
  Fold
  Init
  Step
⟩⇐

Parse ← {
  m←𝕩∊"[]+-><,."
  tt←m/𝕩

  # TODO: add asserts around bad brackets
  # TODO: add pretty error formating like https://github.com/mlochbaum/bqn-libs/blob/a30673b4797dbd6bf0a2c46982530a489b542e8d/json.bqn#L87C1-L87C8
  # TODO: use token index for error reporting
  # ti←m/↕≠𝕩

  tm←"[]+-><,."=⌜tt
  d←+`-○»˝0‿1⊏tm
  p⊣{p↩(𝕨⊏˜1-˜𝕨⍋𝕩)⌾(𝕩⊸⊏)p}´˘2↕⊔d⊣p←↕≠d

  # TODO: measure perf and optimize
  # td stores different data depending on node type
  rm←(⊑1↑⌽)¨⊔p               # rightmost children
  td←0⥊˜≠p
  n←(1+⊏⟜rm)s←(/⟜p)»0⊏tm     # `[` jump past children
  td↩n⌾(s⊸⊏)td
  td↩td+(1+p)×1⊏tm           # `]` jump just past parent into loop again

  td↩td+(2‿3⊸⊏+○(-˝)4‿5⊸⊏)tm # For `+-><` store the inc/dec amount +1/-1
  td↩td+∨˝(6‿7)⊏tm

  # update `-` to `+` and and `<` to `>`
  tt↩tt+('+'-'-')×3⊏tm
  tt↩tt+('>'-'<')×5⊏tm
  ⟨p, tt, td⟩
}

# folds chains of + or > into a single single node 
Fold ← {
  p‿tt‿td←𝕩

  tm←"+>"=⌜tt
  (+×0⊸≠)`⌾⌽td×0⊏tm
  di←(»⊸<dt)×(+×0⊸≠)`⌾⌽td×dt←0⊏tm
  pi←(»⊸<pt)×(+×0⊸≠)`⌾⌽td×pt←1⊏tm
  td↩i+td×i0←0=i←di+pi

  k←¬r←(dt+pt)×i0

  p↩(/r)(⊢-⍋)k/p
  tt↩k/tt
  td↩k/td
  an←(/r)(⊢-⍋)td×+˝"[]"=⌜tt
  td↩an+td×0=an

  ⟨p, tt, td⟩
}

Init ← {
  p‿tt‿td←𝕩
  
  d←0⥊˜𝕨⊣30000
  ip←0
  dp←0
  ⟨ip, dp, d⟩‿⟨p, tt, td⟩
}

Step ← {
  ⟨ip, dp, d⟩‿⟨p, tt, td⟩←𝕩

  id←ip⊑td
  s←{
    '+': ⟨ip+1, dp, (256|id⊸+)⌾(dp⊸⊑)d⟩;
    '>': ⟨ip+1, dp+id, d⟩;
    '[': j←0=dp⊑d ⋄ ⟨(j×id)+(¬j)×ip+1, dp, d⟩;
    ']': j←0≠dp⊑d ⋄ ⟨(j×id)+(¬j)×ip+1, dp, d⟩;
    '.': •term.OutRaw <@+dp⊑d ⋄ ⟨ip+1, dp, d⟩;
    ',': c←•term.CharB ⟨⟩ ⋄ ⟨ip+1, dp, c⌾(dp⊸⊑)d⟩
  }ip⊑tt
  s‿⟨p, tt, td⟩

  # below is an attempt at being more "array" style
  # less branching and more masking
  # it also works, but is about 4x slower
  # od‿cd‿dd‿pd‿in‿out←(ip⊑td)×it←"[]+>,."=ip⊑tt

  # ot←0⊑it
  # ct←1⊑it
  
  # d↩(256|dd⊸+)⌾(dp⊸⊑)d
  # d↩{in ? •term.CharB ⟨⟩; 𝕩}⌾(dp⊸⊑)d
  # # {out ? •term.OutRaw <@+dp⊑d; 0}

  # nz←¬z←0=dp⊑d
  # # ip↩(od×z)+(cd×nz)+((z∧¬ot)∨nz∧¬ct)×ip+1
  # ip↩ip+1
  # ip↩(cd×nz)+(z∨¬ct)×ip
  # ip↩(od×z)+(nz∨¬ot)×ip
  # dp↩dp+pd

  # ⟨ip, dp, d⟩‿⟨p, tt, td⟩
}
