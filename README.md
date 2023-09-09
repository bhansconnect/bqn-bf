# BQN BF

A BF interpreter in BQN.
It actually does parsing and then a number of tree optimization and node folding.
This is overkill for a BF interpreter but makes it way faster.
That said, it is still not super fast cause it is running in an interpreted array language.
This is probably one of the worst kind of languages for scalar code in tight loops (like a bf interpreter).
Overall, I am quite happy with the perf and crushing some basic python impls.
