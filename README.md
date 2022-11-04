# Minimum-Time Control of Boolean Control Networks

Code for the paper "Minimum-Time Control of Boolean Control Networks: A Fast Graphical Approach"

## File organization

- The source code of our algorithms is provided as a [Julia](https://julialang.org/) package in *./code/MCT*.
- The examples in the paper are presented in *./script/example*.

## How to run the examples

0. Launch Julia [REPL](https://docs.julialang.org/en/v1/stdlib/REPL/) and change into the *./script* folder.
1. Activate the Julia environment in the folder *./script* in Julia REPL pkg mode by `activate .`.
2. Install required dependencies by `instantiate` in Julia REPL pkg mode.
3. Return to REPL normal mode, change into the *example* folder in Julia REPL, and run

   ```julia
   include("example.jl")
   ```
