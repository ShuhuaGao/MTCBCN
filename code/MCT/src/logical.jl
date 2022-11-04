# STP related data structures and operations


"""
    struct LogicalVector

Represent a logical vector typically denoted by ``δₙⁱ``.
Two fields:
- `id`: the position at which the entry is 1
- `n`: length of the vector
"""
struct LogicalVector
    id::Int64
    n::Int64

    function LogicalVector(id::Integer, n::Integer)
        @assert 1 <= id <= n
        new(id, n)
    end
end

# true: [1, 0], false: [0, 1]
LogicalVector(b::Bool) = b ? LogicalVector(1, 2) : LogicalVector(2, 2)

function LogicalVector(bv::BitVector)
    r = LogicalVector(1, 1)
    for b in bv
        r = r * LogicalVector(b)
    end
    return r
end

LogicalVector(bv::AbstractVector{<:Integer}) = LogicalVector(BitVector(bv))

Base.length(lv::LogicalVector) = lv.n
Base.size(lv::LogicalVector) = (length(lv), )
id(lv::LogicalVector) = lv.id

# O(1)
function Base.:*(lv1::LogicalVector, lv2::LogicalVector)
    n0 = (id(lv1) - 1) * length(lv2)
    pos1 = n0 + id(lv2)
    return LogicalVector(pos1, length(lv1) * length(lv2))
end


function Base.isvalid(lv::LogicalVector)
    return 1 <= id(lv) <= length(lv) 
end


"""
    struct LogicalMatrix

Represent a logical matrix of size ``m \times n``. 
Each column is a logical vector of length `m`.

Fields:
- `m` and `n`
- `id::Vector{Int64}`: the ``j``-th element denotes the non-zero position of the ``j`` column.
"""
struct LogicalMatrix
    id::Vector{Int64}    # store the id of each column 
    m::Int64
    n::Int64

    function LogicalMatrix(i::AbstractVector{<:Integer}, m::Integer, n::Integer)
        @assert all(x -> 1 <= x <= m, i)
        @assert length(i) == n
        new(Int64.(i), m, n)
    end
end

Base.size(lm::LogicalMatrix) = (lm.m, lm.n)

id(lm::LogicalMatrix) = lm.id
Base.ndims(lm::LogicalMatrix) = 2
function Base.size(lm::LogicalMatrix, dim::Integer)
    @assert dim == 1 || dim == 2
    return dim == 1 ? lm.m : lm.n
end


function Base.:*(lm::LogicalMatrix, lv::LogicalVector)
    @assert size(lm, 2) == length(lv)
    # pick the corresponding column
    i = id(lv)
    return LogicalVector(id(lm)[i], size(lm, 1))
end

function Base.isvalid(lm::LogicalMatrix)
    m, n = size(lm)
    return length(id(lm)) == n && all(x->1 <= x <= m, id(lm))
end

function Base.BitMatrix(lm::LogicalMatrix)
    bm = BitMatrix(undef, size(lm))
    fill!(bm, 0)
    j = 1
    for i in id(lm) # (i, j) is 1 in the j-th column (a logical vector)
        bm[i, j] = 1
        j += 1
    end
    return bm
end

const LM = LogicalMatrix
const LV = LogicalVector
