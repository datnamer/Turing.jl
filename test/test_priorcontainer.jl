using Turing, Base.Test

# pa = PriorArray()
# add(pa, 1)
# add(pa, 2)
# @test get(pa) == 1
# @test get(pa) == 2
# @test get(pa) == 1
# set(pa, 3)
# set(pa, 4)
# set(pa, 5)
# @test get(pa) == 4
# @test get(pa) == 5


pc = PriorContainer()
p1 = Prior(gensym())
p2 = Prior(gensym())

addPrior(pc, p1, 1)
addPrior(pc, p1, 2)
addPrior(pc, p1, 3)
addPrior(pc, p2, 4)

@test pc[p1] == 1
@test pc[p1] == 2
@test pc[p1] == 3
@test pc[p1] == 1
@test pc[p1] == 2
@test pc[p1] == 3

@test pc[p2] == 4

pc[p1] = 5
pc[p1] = 6
pc[p1] = 7

@test pc[p1] == 5
@test pc[p1] == 6
@test pc[p1] == 7

keys(pc)