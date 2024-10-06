# https://docs.makie.org/stable/explanations/animation

using GLMakie
using Makie.Colors

fig, ax, lineplot = lines(0..10, sin; linewidth=10)
nframes = 30
framerate = 30
hue_iterator = range(0, 360, length=nframes)

record(fig, "color_animation.mp4", hue_iterator; framerate=framerate) do hue
    lineplot.color = HSV(hue, 1, 0.75)
end
