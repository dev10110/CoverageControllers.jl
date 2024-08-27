
using FFTW

function testgrid(dim)
    o = tuple(randn(dim)...)
    dx = tuple(rand(dim)...)
    N = ntuple(i -> rand(3:20), dim)

    grid = Grid(o, dx, N)
    return grid
end

@testset "CoverageControllers.jl - Grid Create" begin
    o = (0.0, 0.0)
    N = (10, 10)
    dx = (1.0, 2.0)

    grid = Grid(o, dx, N)

    @test grid.o == (0.0, 0.0)
    @test grid.dct_plan isa AbstractFFTs.Plan
end

@testset "CoverageControllers.jl - Grid pos2ind and ind2pos are inverses" begin
    grid = testgrid(2)
    griddata = zeros(grid.N)

    for ind in CartesianIndices(griddata)
        p = ind2pos(grid, ind)
        i = pos2ind(grid, p)
        @test i == ind
    end
end
