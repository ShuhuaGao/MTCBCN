# build the STG for a BCN

const Edge = Tuple{Int64, Int64}

"""
    struct STG

Represent a state transition graph. Each vertex (i.e., state) is denoted by an integer, and each edge
is a pair of integers.

Fields:
- `V::UnitRange{Int64}`: 1:N, where ``N`` is the number of states.
- `S`: successors
- `P`: predecessors
- `U`: controls associated with each edge

Note that the edge set `E` is not stored explicitly, because it can be easily retrieved with `S` or `P`.
"""
struct STG
    V::UnitRange{Int64}
    S::Vector{Vector{Int64}}
    P::Vector{Vector{Int64}}
    U::Dict{Edge, Vector{Int64}}
end


function build_STG(bcn::BCN)
    N = bcn.N
    V = 1:bcn.N
    S = [Int64[] for _ = 1:N]
    P = [Int64[] for _ = 1:N]
    U = Dict{Edge, Vector{Int64}}()
    for x = 1:bcn.N
        for u = 1:bcn.M
            x′ = evolve(bcn, x, u)
            # insert control for an edge
            e = (x, x′)
            if e in keys(U)
                push!(U[e], u)
            else
                U[e] = [u]
            end
            # insert edge implicitly
            push!(S[x], x′)
            push!(P[x′], x)
        end
    end
    return STG(V, S, P, U)
end

function count_edges(stg::STG)
    return sum(length(vs) for vs in stg.S)
end

count_vertices(stg::STG) = length(stg.V)

# perform basic checking to see whether `stg` is legal
function validate_STG(stg::STG)
    @assert count_vertices(stg) == length(stg.S) == length(stg.P)
    for e in keys(stg.U)
        x, x′ = e
        @assert x′ in stg.S[x]
        @assert x in stg.P[x′]
    end
    for x in stg.V
        for x′ in stg.S[x]
            @assert x in stg.P[x′]
        end
    end
    for x′ in stg.V
        for x in stg.P[x′]
            @assert x′ in stg.S[x]
        end
    end
    println("All validation checks passed.")
end

