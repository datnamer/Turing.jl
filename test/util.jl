using Turing: @VarName, invlogit, logit, randcat, kl, align
using Distributions: Normal
using Base.Test

i = 1
@test @VarName(s)[1:end-1] == (:s,)
@test @VarName(x[1,2][1+5][45][3][i])[1:end-1] == (:x,([1,2],[6],[45],[3],[1]))
@test invlogit(1.1) == 1.0 / (exp(-1.1) + 1.0)
@test logit(0.3) == log(0.3 / (1.0 - 0.3))
randcat([0.1, 0.9])
@test kl(Normal(0, 1), Normal(0, 1)) == 0
@test align([1, 2, 3], [1]) == ([1,2,3],[1,0,0])
@test align([1], [1, 2, 3]) == ([1,0,0],[1,2,3])
