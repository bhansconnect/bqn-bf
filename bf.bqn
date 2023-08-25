# BF: BrainFuck Interpreter
⟨
  Parse
  Fold
  FlattenOffsets
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

  tt↩k/tt
  td↩k/td

  p↩(/r)(⊢-⍋)k/p
  an←(/r)(⊢-⍋)td×m←+˝"[]"=⌜tt
  td↩an+td×¬m

  ⟨p, tt, td⟩
}

# switch to only having + and no >.
# + will also store the offset to increment at.
# [ and ] will store increment for the entire block.
FlattenOffsets ← {
  p‿tt‿td←𝕩

  # this has ungroup which is probably slow.
  # probably can do it some other way?
  k←¬r←'>'=tt
  o←g⊔⁼+`¨(r×td)⊔˜g←0»+`tt∊"[]"

  tt↩k/tt
  td↩k/td
  o↩k/o

  p↩(/r)(⊢-⍋)k/p
  # when we remove a jump target this has issues
  # maybe add 1 if the jump target is a value being removed?
  # so if 5 is in r and a > make it 6? or the next non > character
  # This +0.1 is a hack that I assume really hurts perf.
  an←(0.1+/r)(⊢-⍋)td×m←+˝"[]"=⌜tt
  td↩an+td×¬m

  ⟨p, tt, td, o⟩
}

Init ← {
  d←0⥊˜𝕨⊣30000
  ip←0
  dp←0
  ⟨ip, dp, d⟩‿𝕩
}

Step ← {
  ⟨ip, dp, d⟩‿⟨p, tt, td, o⟩←𝕩

  id←ip⊑td
  io←ip⊑o
  do←dp+io
  s←{
    '+': ⟨ip+1, dp, (256|id⊸+)⌾(do⊸⊑)d⟩;
    '[': j←0=do⊑d ⋄ ⟨(j×id)+(¬j)×ip+1, do, d⟩;
    ']': j←0≠do⊑d ⋄ ⟨(j×id)+(¬j)×ip+1, do, d⟩;
    '.': •term.OutRaw <@+do⊑d ⋄ ⟨ip+1, dp, d⟩;
    ',': c←•term.CharB@ ⋄ ⟨ip+1, dp, c⌾(do⊸⊑)d⟩
  }ip⊑tt
  s‿⟨p, tt, td, o⟩

  # below is an attempt at being more "array" style
  # less branching and more masking
  # it also works, but is about 4x slower
  # od‿cd‿dd‿pd‿in‿out←(ip⊑td)×it←"[]+>,."=ip⊑tt

  # ot←0⊑it
  # ct←1⊑it
  
  # d↩(256|dd⊸+)⌾(dp⊸⊑)d
  # d↩{in ? •term.CharB@; 𝕩}⌾(dp⊸⊑)d
  # # {out ? •term.OutRaw <@+dp⊑d; 0}

  # nz←¬z←0=dp⊑d
  # # ip↩(od×z)+(cd×nz)+((z∧¬ot)∨nz∧¬ct)×ip+1
  # ip↩ip+1
  # ip↩(cd×nz)+(z∨¬ct)×ip
  # ip↩(od×z)+(nz∨¬ot)×ip
  # dp↩dp+pd

  # ⟨ip, dp, d⟩‿⟨p, tt, td⟩
}
