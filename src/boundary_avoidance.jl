"""
  PolygonBoundary(points)
returns a Vector{LineBounary} representing a polygonal boundary
"""
function PolygonBoundary(points::VP; closed=true) where {D, F,  P <: NTuple{D, F}, VP <: AbstractVector{P} }

  bs = LineBoundary{D, F}[]
  N = length(points)
  L = closed ? N : N - 1

  for i=1:L
      j = 1 + (i-1) % N
      k = 1 + i % N
      l = LineBoundary(points[j], points[k])
      push!(bs, l)
  end
  return bs
  
end

function GridBoundary(grid::Grid{2})
  ox, oy = grid.o
  lx, ly = lengths(grid)

  # create the boundaries
  return PolygonBoundary([
      (ox, oy),
      (ox + lx, oy),
      (ox + lx, oy + ly),
      (ox, oy + ly)
  ])
end

function get_normal(boundary::LineBoundary{2})

  # extract variables
  bx1, by1 = boundary.p1
  bx2, by2 = boundary.p2

  # normal vector pointed to the interior of the domain
  nx = by1 - by2
  ny = bx2 - bx1

  # normalize
  s = sqrt(nx^2 + ny^2)
  return (nx / s, ny / s)
end

function nearest_point(position, boundary::LineBoundary{2}; clip_segment = true)
  # extract
  x1, y1 = boundary.p1
  x2, y2 = boundary.p2
  x3, y3 = position

  # get the direction vector along line
  px = x2-x1
  py = y2-y1
  n = px^2 + py^2
  u =  ((x3 - x1) * px + (y3 - y1) * py) / n

  # clamp it to be on the segment
  if clip_segment
      u = clamp(u, 0, 1)
  end
  
  # get the nearest point that is on the line
  x = x1 + u * px
  y = y1 + u * py

  return (x, y)
end


function signed_distance_to_boundary(position, boundary::LineBoundary{2})

  n = get_normal(boundary)

  p = nearest_point(position, boundary; clip_segment = false)

  # relative vector
  r = position .- p
  
  d = dot(r, n)

  return d
end

function is_influenced(x, boundary::LineBoundary{2}, max_dist)

  # closest point
  c = nearest_point(x, boundary)

  # check if in max distance
  return norm(x .- c) < max_dist
  
end


function avoid_boundaries(robot::SingleIntegrator, state, control, boundaries::VB; max_dist) where {F, B <: LineBoundary{2, F}, VB<:AbstractVector{B}}

  max_speed = robot.umax
  pos = position(robot, state)
  vel = control
  
  # loop through and reduce the speed in the appropriate directions
  for b in boundaries

      # check if we should do anything
      if is_influenced(pos, b, max_dist)
          # get the signed distance
          d = signed_distance_to_boundary(pos, b)

          # get normal
          n = get_normal(b)

          # compute the max normal speed
          max_normal_speed = max_speed * (d / max_dist)

          # get the correction amount x = αn
          α = -max_normal_speed - dot(vel, n)
          # only if i need to do a correction will i do a correction
          if α > 0
              vel = vel .+ (α .* n)
              if (norm(vel) > max_speed)
                  vel = (max_speed / norm(vel)) .* vel
              end
          end 
      end
  end
  return vel
end

@recipe function f(boundary::LineBoundary{2}; dist=0.0, dist_percent = 0.05) 
    x1, y1 = boundary.p1
    x2, y2 = boundary.p2
    xs = [x1, x2]
    ys = [y1, y2]

    n = get_normal(boundary)
    l = norm(boundary.p2 .- boundary.p1) # length of the line

    d = (dist == 0 ? dist_percent * l : dist)
    p1_inner = boundary.p1 .+ d .* n
    p2_inner = boundary.p2 .+ d .* n

    @series begin
        seriestype --> :line
        label --> false
        xs, ys
    end

    xs_inner = [p1_inner[1], p2_inner[1]]
    ys_inner = [p1_inner[2], p2_inner[2]]
    @series begin
        seriestype --> :line
        linestyle --> :dash
        label --> false 
        xs_inner, ys_inner
    end
end

@recipe function f(boundaries::VB) where {F, VB <: AbstractVector{LineBoundary{2, F}}}
    xs = F[]
    ys = F[]
    for b in boundaries
        x1, y1 = b.p1
        x2, y2 = b.p2
        push!(xs, x1)
        push!(xs, x2)
        push!(xs, NaN)
        push!(ys, y1)
        push!(ys, y2)
        push!(ys, NaN)
    end
    @series begin
        seriestype --> :line
        xs, ys
    end
end