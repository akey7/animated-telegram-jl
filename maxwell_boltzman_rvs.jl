using Plots
using Distributions

scale = 1.0
dist = scale * Chi(3)
random_values = rand(dist, 1000)

display(histogram(random_values, bins=100))
readline()