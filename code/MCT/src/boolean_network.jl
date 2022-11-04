# represent a BCN under disturbances
"""
    struct BCN

Represent a Boolean control network with `m` control inputs and `n` state variables.
Properties:
- `m`, `n`, and the corresponding `M` and `N`
- `L`: the transition matrix
"""
struct BCN
    m::Int32
    n::Int32
    L::LogicalMatrix

    function BCN(L::LogicalMatrix)
        N = size(L, 1)
        M = size(L, 2) / N
        n = round(Int32, log2(N))
        @assert 1 << n == N
        m = round(Int32, log2(M))
        @assert 1 << m == M
        return new(m, n, L)
    end
end

function BCN(m::Integer, n::Integer, L::AbstractVector{<:Integer})
    N = 2^n 
    M = 2^m
    lm = LogicalMatrix(L, N, M * N)
    return BCN(lm)
end

function Base.getproperty(bcn::BCN, p::Symbol)
    if p == :M
        return 2^bcn.m
    elseif p == :N
        return 2^bcn.n
    else
        return getfield(bcn, p)
    end
end

"""
    evolve(bcn::BCN, x::Integer, u::Integer) -> Integer

Transit `bcn` from state `x` to the next state by applying `u`. 
"""
function evolve(bcn::BCN, x::Integer, u::Integer)
    M, N = bcn.M, bcn.N
    blk_u = @view bcn.L.id[(u-1)*N+1:u*N]
    return blk_u[x]  # an integer
end

"""
    evolve(bcn::BCN, x::LogicalVector, u::LogicalVector) -> LogicalVector

Transit `bcn` from state `x` to the next state by applying `u`. 
"""
function evolve(bcn::BCN, x::LogicalVector, u::LogicalVector)
    i = evolve(bcn, id(x), id(u))
    return LogicalVector(i, bcn.N)
end


"""
    calculate_ASSR(fs, m; jld2_file::String="") -> BCN

Given a list of Boolean functions `fs`, number of controls `m`, and number of disturbances `q`, 
build the algebraic form of the BCN.
If `jld2_file` is specified, then the BCN model is written into that JLD2 file with key "bcn".
"""
function calculate_ASSR(fs::AbstractVector{<:Function}, m::Integer; jld2_file::String="")::BCN
    n = length(fs)
    M = 2^m
    N = 2^n
    idx = Vector{Int64}(undef, M * N) # id vector in L
    for xb in product(repeated([true, false], n)...)
        for ub in product(repeated([true, false], m)...)
            # turn each boolean tuple into a logical vector, and multiply the RHS
            x = LogicalVector(collect(xb))
            u = LogicalVector(collect(ub))
            s = u * x
            # calculate the LHS with raw Boolean operators
            xb′ = BitVector()
            for fi in fs
                push!(xb′, fi(xb, ub))
            end
            x′ = LogicalVector(xb′)
            # set the logical matrix
            idx[id(s)] = id(x′)
        end
    end

    bcn = BCN(m, n, idx)
    if !isempty(jld2_file)
        jldsave(jld2_file; bcn)
    end
    return bcn
end