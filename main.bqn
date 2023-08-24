⟨Parse, Fold, Init, Step⟩ ← •Import "bf.bqn"

Log ← {
	•Out (16 ↑ 14 ↑ •Fmt •MonoTime ⟨⟩) ∾ 𝕩
}

n←⊑•args
# Log "Starting BF interpreter for " ∾ n
f←•Fchars n
# Log "Starting Parsing"
ast←Parse f
# Log "Completed Parsing"

# Log "Starting Optimizations"
ast↩Fold ast
# Log "Completed Optimizations"

# Log "Starting Program"
# •Show 10000 {Step⍟100_000_000⎊1 10 Init𝕩}•_timed ast
Step⍟100_000_000⎊1 Init ast
# Log "Completed Program or ran out of steps"
