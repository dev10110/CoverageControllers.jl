## Grids

abstract type AbstractGrid{D, T} end
"""
    Grid{D, T, F}
Represents a `D`-dimensional grid, with origin `o`, spacing along each axis of `dx` and `N` grid points along each axis. 
The `dct_plan` is computed since it is used so frequently
"""
struct Grid{D, T, F} <: AbstractGrid{D, T}
    o::NTuple{D, T}
    dx::NTuple{D, T}
    N::NTuple{D, Int}
    dct_plan::F
end


## robot types
abstract type AbstractRobot end

struct SingleIntegrator{F} <: AbstractRobot
    umax::F
end

struct DoubleIntegrator{F} <: AbstractRobot
    umax::F
end

## boundary avoidance
abstract type AbstractBoundary{D} end

struct LineBoundary{D, F} <: AbstractBoundary{D}
    p1::NTuple{D, F}
    p2::NTuple{D, F}
end

