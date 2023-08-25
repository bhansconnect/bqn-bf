⟨Parse, Fold, FlattenOffsets, Init, Step⟩ ← •Import "bf.bqn"

Log ← {
	•Out (16 ↑ 14 ↑ •Fmt •MonoTime@) ∾ 𝕩
}

While ← {𝕩•_while_𝕨@}´

n←⊑•args
# Log "Starting BF interpreter for " ∾ n
f←•Fchars n
# Log "Starting Parsing"
ast←Parse f
# Log "Completed Parsing"

# Log "Starting Optimizations"
ast↩Fold ast
# Log "Completed Fold"
ast↩FlattenOffsets ast
# Log "Completed FlattenOffsets"
# Log "Completed Optimizations"

# Log "Starting Program"
# •Show 10000 {Step⍟100_000_000⎊1 10 Init𝕩}•_timed ast
s←Init ast
While⎊@ 1‿{𝕤
	s↩Step s
}
# Log "Completed Program or ran out of steps"
