# the examples in the paper

using Revise
using MCT

# the Boolean functions in Example 1
f1(x, u) = x[2] | x[3]
f2(x, u) = x[1] & u[1]
f3(x, u) = (u[1] | x[2]) & ~x[1]

# compute the ASSR
bcn = calculate_ASSR([f1, f2, f3], 1)
# validate the correctness of the ASSR
@assert evolve(bcn, 2, 1) == 2
@assert evolve(bcn, LV(2, 8), LV(2, 2)) == LV(4, 8) 
println("The BCN is: ")
dump(bcn)

println("\nBuild STG: ")
stg = build_STG(bcn)
MCT.validate_STG(stg)
@show stg.S;
@show stg.U; 

x0 = 1
println("\nRun BFS from x0 = $x0")
R, d = run_BFS(stg, x0)
println("Reachable states and their distance: ")
@show R
@show d


println("\nRun Algorithm 3 to collect controls:")
U = collect_controls(stg, R, d)
@show U

xd = 3
println("\nRun Algorithm 4 to collect controls from x0=$x0 to xd=$xd:")
R, d = run_BFS(stg, x0; xd)
U = collect_controls(stg, d, xd)
@show U

xd = 8
println("\nCollect states that can reach xd = $xd and their distances by reusing Algorithm 2:")
R, d = run_BFS(stg, xd; transposed=true)
@show R
@show d
println("\nCollect controls for min-time control to xd = $xd by reusing a modified Algorithm 3:")
U = collect_controls(stg, R, d; fixed_desired=true)
@show U
;



