
@inline nomrsq(x) = mapreduce(abs2, sum, x)
