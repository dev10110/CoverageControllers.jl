


function position(robot::SingleIntegrator, robot_state)
    return tuple(robot_state...)
end

function position(robot::DoubleIntegrator, robot_state)
    N = length(robot_state)
    Np = Int(N/2)
    return tuple( (robot_state[1:Np])...)
end


function dynamics(robot::SingleIntegrator, state, control, dt)

    return state .+ control .* dt
end

function dynamics(robot::DoubleIntegrator, state, control, dt)

    N = Int(length(state) / 2)

    pos = state[1:N]
    vel = state[(N+1):(2N)]

    new_vel = vel .+ control .* dt
    new_pos = pos + vel .* dt + 0.5 .* control .* (dt^2)

    return tuple(new_pos..., new_vel...)
end


