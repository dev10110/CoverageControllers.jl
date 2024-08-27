module CoverageControllers

using FFTW, LinearAlgebra
using RecipesBase, ForwardDiff

include("types.jl")
include("grids.jl")
include("ergodic.jl")

export Grid
export center, lengths, axes, pos2ind, ind2pos, fill, fill!

end
