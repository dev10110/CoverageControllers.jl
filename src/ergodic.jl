# main functions related to ergodic smc methods 

@inline hk(k) = k == 0 ? 1.0 : 1.0 / sqrt(2)
@inline hk(k1, k2) = hk(k1) * hk(k2)
@inline Λ(k; d = length(k), s = (1 + d) / 2) = (1 + normsq(k))^(-s)
@inline Λ2D(k1, k2) = (1 + k1^2 + k2^2)^(-1.5)

function normalize_pdf!(data::M) where {M <: AbstractArray}

    # ensure non-negative
    map!( x-> max(0, x), data, data)

    # get the sum
    s = sum(data)
    @assert s > 0

    # normalize
    map!( x -> x / s, data, data)

end


function dct_map(grid::Grid{2}, data::M; normalize=true) where {F, M <: AbstractArray{F, 2}}

    # check dimensions
    @assert size(data) == grid.N

    if normalize
        normalize_pdf!(data)
    end

    N1, N2 = grid.N
    L1, L2 = lengths(grid)

    # do an un-normalized DCT
    Y = grid.dct_plan * data

    # normalize
    δ = (L1 / N1) * (L2 / N2) / (2^2)
    for i in 1:N1, j in 1:N2
        k1 = i - 1
        k2 = j - 1
        Y[i, j] *= δ
        if (k1 == 0 || k2 == 0)
            Y[i, j] = Y[i, j] / hk(k1, k2)
        end
    end

    return Y
end

"""
    dct_trajectory(grid, traj)
converts a list of visited points to a spatial distribution, and then returns the dct of the spatial distribution
"""
function dct_trajectory(grid::Grid{2}, traj; normalize=true)

    spatial_dist = trajectory_map(grid, traj)

    return dct_map(grid, spatial_dist; normalize=normalize)
end

"""
    trajectory_map(grid, traj)

convert a list of visited points to a spatial distribution
"""
function trajectory_map(grid::Grid, traj)

    data = zeros(grid.N)

    for p in traj
        ind = pos2ind(grid, p)
        data[ind] += 1
    end

    return data

end

function grad_fk(grid::Grid{2}, p::NTuple{2}, k::NTuple{2}) 
    L1, L2 = lengths(grid)
    p1, p2 = p .- grid.o
    k1, k2 = k

    δ = 1 / (hk(k1, k2) * prod(grid.dx))

    return δ .* (
        -k1 * sin(π * k1 * p1 / L1) * cos(π * k2 * p2 / L2),
        -k2 * cos(π * k1 * p1 / L1) * sin(π * k2 * p2 / L2)
    )
end

function ergodic_descent_direction(grid::Grid{2}, pos, target_spatial_dist, past_trajectory)

    # run the dct on the arguments
    ck = dct_trajectory(grid, past_trajectory)
    Mk = dct_map(grid, target_spatial_dist)

    @assert size(ck) == size(Mk)

    # compute the difference
    diff_k = ck - Mk

    # get the ergodic descent direction
    return ergodic_descent_direction_dct(grid, pos, diff_k)
end

function ergodic_descent_direction_dct(grid::Grid{2}, pos, coeffs)

    # check that the sizes are compatible
    @assert size(coeffs) == grid.N

    N1, N2 = grid.N

    bx = zero(Float64)
    by = zero(Float64)

    for i in 1:N1, j in 1:N2
        k1 = i - 1
        k2 = j - 1

        k = (k1, k2)

        bk1, bk2 = (Λ2D(k1, k2) * coeffs[i, j]) .* grad_fk(grid, pos, k)

        bx += bk1
        by += bk2
    end

    return (bx, by)
end


abstract type Robot end

struct SingleIntegrator{F} <: Robot
    umax::F
end

function ergodic_controller(grid::Grid{2}, robot::SingleIntegrator, robot_state, tsd, past_traj)

    # for a single integrator, the state is the position

    b = ergodic_descent_direction(grid, robot_state, tsd, past_traj)

    u = - robot.umax * b / norm(b)

    return u

end


