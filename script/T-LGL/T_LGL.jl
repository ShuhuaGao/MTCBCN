# Min-time control of the T-LGL network
using JLD2
using BenchmarkTools
using MCT


# 1. read the network data
bcn = load(joinpath(@__DIR__,  "T_LGL_net.jld2"), "bcn")


# 2. get the fixed points of this network
function find_fixed_points(G::STG)
    # get vertices with self-loops
    fps = Int64[]
    for v in G.V
        ss = G.S[v]
        if v in ss
            push!(fps, v)
        end
    end
    return fps
end

G = build_STG(bcn)  # STG
fps = find_fixed_points(G)
@show length(fps) 
println()

# 3. minimum-time stabilization to a fixed point, i.e., Case 3
# try all fixed point
for fp in fps 
    R, d = run_BFS(G, fp; transposed=true)
    @show fp length(R) findmax(d)
    println()
end

# we see that if the fixed point is 65279, all states can reach it, and this corresponds to the
# worst case of runtime. Let's measure it. This is also a time-optimal stabilization problem.
fp = 65535
@btime run_BFS($G, $fp; transposed=true)


