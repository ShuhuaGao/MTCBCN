module MCT

using JLD2, Dates
using Base.Iterators: product, repeated
using DataStructures: Queue, enqueue!, dequeue!
import LinearAlgebra

include("logical.jl")
include("boolean_network.jl")
include("stg.jl")
include("min_time_control.jl")

export calculate_ASSR, LogicalMatrix, LogicalVector, LM, LV, evolve, 
    STG, build_STG, count_edges, count_vertices, run_BFS, collect_controls
end # module MCT
