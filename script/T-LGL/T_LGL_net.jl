# build the ASSR for T-LGL network 

using MCT

# Boolean rules
f1(x, u) = x[2] & ~x[16]
f2(x, u) = ~(x[5] | x[3] | x[16])
f3(x, u) = (x[2] | x[3] ) & ~x[16]
f4(x, u) = x[15] & ~x[16]
f5(x, u) = x[4] & ~x[16] 
f6(x, u) = ~(x[7] | x[16])
f7(x, u) = x[15] & ~x[16] & u[1]
f8(x, u) = x[6] & ~(x[15] | x[16]) | u[2]
f9(x, u) = (x[8] | (x[6] & ~x[11])) & ~x[16]
f10(x, u) = ((x[12] & ~x[13]) | x[9]) & ~x[16]
f11(x, u) = ~(x[9] | x[16])
f12(x, u) = ~(x[14] | x[16])
f13(x, u) = ~(x[12] | x[16])
f14(x, u) = ~(x[9] | x[16]) & u[3]
f15(x, u) = ~(x[8] | x[16])
f16(x, u) = x[10] | x[16]


# compute the ASSR and store it into a JLD2 file
bcn = calculate_ASSR([f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14,f15, f16], 3; 
    jld2_file=joinpath(@__DIR__,  "T_LGL_net.jld2"))