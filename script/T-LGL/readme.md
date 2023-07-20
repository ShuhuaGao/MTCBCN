# Minimum-time control of the T-LGL network

## Network data

The ASSR of the T-LGL network is presented in *T_LGL.txt*, which has three lines:
1. Number of state variables (16)
2. Number of control input variables (3)
3. State transition matrix `L` of length $2^{m+n}$. If the `k`-th element is `i`, then the `k`-th column of 
   `L` is $\delta_N^i$.

The same data is also stored as a JLD2 file that is more convenient in Julia: see *T_LGL_net.jld2*.

## Time-optimal control

Please check *T_LGL.jl*.
For the supplementary documentation regarding T-LGL, check [sm.pdf](./sm.pdf).