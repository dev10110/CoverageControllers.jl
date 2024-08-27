
## Grid Constructors
"""
    Grid(o, dx, N)
construct a grid with with origin `o` spacing `dx` and `N` elements along each axis. 
"""
function Grid(o::NTuple{D, T}, dx::NTuple{D, T}, N::NTuple{D, Int}) where {D, T}
    M = zeros(N)
    dct_plan = FFTW.plan_r2r(M, FFTW.REDFT10)
    return Grid(o, dx, N, dct_plan)
end

"""
    Grid(origin, dx, lengths)
construct a grid with origin `o` spacing `dx` and lengths `lengths` along each axis.
"""
function Grid(o::NTuple{D, T}, dx::NTuple{D, T}, L::NTuple{D, T}) where {D, T}
    N = ntuple(i -> Int(ceil(1 + L[i] / dx[i])), D)
    return Grid(o, dx, N)
end

## Grid show method
function Base.show(io::IO, grid::Grid{D, T, F}) where {D, T, F}
    return println(io, "Grid(origin=$(grid.o), spacing=$(grid.dx), N=$(grid.N))")
end

## Grid properties

"""
    lengths(grid)
returns the length of each axis of the grid
"""
function lengths(g::Grid{D}) where {D}
    return ntuple(i -> (g.N[i] - 1) * g.dx[i], D)
end

"""
    center(grid)
returns the center of the grid
"""
function center(g::Grid{D}) where {D}
    ls = lengths(g)
    return ntuple(i -> g.o[i] + 0.5 * ls[i], D)
end

"""
    axes(grid, dim)
returns the axes for the grid at the specified dim
"""
function Base.axes(g::Grid{D}, dim) where {D}
    return g.o[dim] .+ (0:(g.N[dim] - 1)) * g.dx[dim]
end

"""
    axes(grid)
returns an `ntuple` of the axes along each dimension of the grid
"""
function Base.axes(g::Grid{D}) where {D}
    return ntuple(i -> axes(g, i), D)
end

## pos2ind and ind2pos
function pos2ind(grid::Grid{D, T}, pos::NTuple{D, T}) where {D, T}
    ind = ntuple(i -> 1 + Int(floor((pos[i] - grid.o[i]) / grid.dx[i])), D)
    return CartesianIndex(ind...)
end

function ind2pos(grid::Grid{D}, ind) where {D}
    return ntuple(i -> grid.o[i] + (ind[i] - 1) * grid.dx[i], D)
end

## Fill methods
"""
    fill!(func, grid, data)
fills the `data` matrix by applying `func` to each pos. `func` should be a function that takes in a position (as an n-tuple) and return a scalar. 
"""
function fill!(func, grid::Grid{D}, data::Array{F, D}) where {D, F}
    for ind in CartesianIndices(data)
        pos = ind2pos(grid, ind)
        data[ind] = func(pos)
    end
    return data
end

function Base.fill(func, grid::Grid{D}) where {D}
    data = zeros(grid.N)
    fill!(func, grid, data)
    return data
end

## Plotting methods
@recipe function f(grid::Grid{2}, griddata::M) where {T, M <: AbstractMatrix{T}}
    xs = axes(grid, 1)
    ys = axes(grid, 2)

    m = maximum(griddata)

    @series begin
        seriestype --> :heatmap
        xlabel --> "x"
        ylabel --> "y"
        aspect_ratio --> :equal
        clims --> (0, m)
        xs, ys, griddata'
    end
end
