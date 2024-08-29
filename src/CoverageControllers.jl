module CoverageControllers

using FFTW, LinearAlgebra
using RecipesBase, ForwardDiff

include("types.jl")
include("utils.jl")
include("grids.jl")
include("robots.jl")
include("ergodic.jl")
include("boundary_avoidance.jl")

export Grid
export center, lengths, axes, pos2ind, ind2pos, fill, fill!, default_boundaries
export SingleIntegrator, DoubleIntegrator, position, dynamics
export ergodic_controller

end
