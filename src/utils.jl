
@inline normsq(x) = mapreduce(abs2, sum, x)

function LinearAlgebra.normalize(x::NTuple{D, T}) where {T, D}

    s = norm(x)

    return x ./ s
end
