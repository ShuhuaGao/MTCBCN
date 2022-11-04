# algorithms for min-time control 

"""
    run_BFS(G::STG, x0::eltype(stg.V); transposed::Bool=false, xd::Integer=-1) -> Tuple{Set, Dict}

Run BFS on the graph `G` from vertex `x0`.
The reachable set of vertices `R` and the distance dict `d` is returned, where `d[x]` gives the distance
of vertex `x`. Note that, if `x` is not in `d`, then `x` is not reachable and we treat `d[x] = ∞`.

Algorithm 2 in the paper.

If `transposed` is true (`false` by default), then the direction of each edge in `G` is reversed. It is used to solve the
fixed desired state problem, and `x0` is treated as the desired state in this case.

If `xd` is set (default value: `-1`), then only states that may contribute to the minimum-time control from 
`x0` to `xd` are considered. Note that at most one of `transposed` and `xd` can be set.
"""
function run_BFS(G::STG, x0::Integer; transposed::Bool=false, xd::Integer=-1)
    if transposed
        xd >= 0 && error("at most one of `transposed` and `xd` can be set")
    end
    Q = Queue{typeof(x0)}()
    enqueue!(Q, x0)
    R = Set([x0])
    d = Dict(x0=>0)  # the distance attribute

    neighbors = transposed ? G.P : G.S
    while !isempty(Q)
        x = dequeue!(Q)
        if x == xd  # early stopping to further save time if `xd` is specified 
            break
        end
        for x′ in neighbors[x]
            if x′ ∉ R
                d[x′] = d[x] + 1
                enqueue!(Q, x′)
                push!(R, x′)
            end
        end
    end
    return R, d
end


"""
    collect_controls(G::STG, R::AbstractSet, d::AbstractDict; fixed_desired::Bool=false) -> Dict{Int64, Set{Int64}}

Collect the controls for minimum-time control. `R` is the reachable set from the initial state, 
and `d` records the distance of each reachable vertex. See [`run_BFS`](@ref).
    
A dict `U` is returned, where `U[x]` contains control inputs that should be applied to `x`. 
If `x` does not exist in `U`, then its controls are not relevant, i.e., `U[x] = ΔM`.

It implements Algorithm 3 in the paper. If `fixed_desired` is `true`, 
then it solves the fixed desired state problem.
"""
function collect_controls(G::STG, R::AbstractSet, d::AbstractDict; fixed_desired::Bool=false)
    U = Dict{Int64, Set{Int64}}()
    meet_condition(dx, dx′) = dx == dx′ + (fixed_desired ? 1 : -1)
    for x′ in R
        for x in G.P[x′]
            if x in keys(d) && meet_condition(d[x], d[x′])
                if x ∉ keys(U)
                    # create an empty array first 
                    U[x] = Set{Int64}()
                    sizehint!(U[x], 16)
                end
                union!(U[x], G.U[(x, x′)])
            end
        end
    end
    return U
end


"""
    collect_controls(G::STG,  d::AbstractDict, xd::Integer) -> Dict{Int64, Set{Int64}}

Collect the controls for minimum-time control from a given initial state to a given desired state `xd`. 
`d` records the distance of each reachable vertex from the initial state. See [`run_BFS`](@ref).
    
A dict `U` is returned, where `U[x]` contains control inputs that should be applied to `x`. 
If `x` does not exist in `U`, then its controls are not relevant, i.e., `U[x] = ΔM`.

Algorithm 4 in the paper.
"""
function collect_controls(G::STG, d::AbstractDict, xd::Integer)
    U = Dict{Int64, Set{Int64}}()
    Q = Queue{Int64}()
    enqueue!(Q, xd)
    Q_set = Set(Q)  # for quick check about whether x is in Q
    while !isempty(Q)
        x′ = dequeue!(Q)
        delete!(Q_set, x′)
        for x in G.P[x′]
            if x in keys(d) && d[x] == d[x′] - 1
                if x ∉ keys(U)
                    # create an empty array first 
                    U[x] = Set{Int64}()
                    sizehint!(U[x], 16)
                end
                union!(U[x], G.U[(x, x′)])
                if x ∉ Q_set
                    enqueue!(Q, x)
                    push!(Q_set, x)
                end
            end

        end
    end
    return U
end


# """
#     transpose(G::STG) -> STG

# Transpose a state transition graph `G`. This is not a strictly tranpose in graph theory, but we only
# """
# function transpose(G::STG)

# end