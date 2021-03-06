using Turing, Distributions
using Base.Test

@model gdemo() begin
  s ~ InverseGamma(2,3)
  m ~ Normal(0,sqrt(s))
  1.5 ~ Normal(m, sqrt(s))
  2.0 ~ Normal(m, sqrt(s))
  return s, m
end

s1 = Gibbs(1000, HMC(10, 0.1, 5, :s, :m))
s2 = Gibbs(1000, PG(10, 10, :s, :m))
s3 = Gibbs(1000, PG(10, 2, :s), HMC(1, 0.4, 8, :m))


c1 = sample(gdemo, s1)
c2 = sample(gdemo, s2)
c3 = sample(gdemo, s3)

# Very loose bound, only for testing constructor.
@test_approx_eq_eps mean(c1[:s]) 49/24 1
@test_approx_eq_eps mean(c1[:m]) 7/6 1
@test_approx_eq_eps mean(c2[:s]) 49/24 1
@test_approx_eq_eps mean(c2[:m]) 7/6 1
@test_approx_eq_eps mean(c3[:s]) 49/24 1
@test_approx_eq_eps mean(c3[:m]) 7/6 1
