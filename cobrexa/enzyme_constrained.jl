# Following https://cobrexa.github.io/COBREXA.jl/dev/examples/05b-enzyme-constrained-models/

import JSONFBCModels
import HiGHS, Clarabel
import AbstractFBCModels.CanonicalModel as CM
import ConstraintTrees as C
using COBREXA
import AbstractFBCModels as A

println("############################################################")
println("# LOAD MODEL                                               #")
println("############################################################")

model = load_model("e_coli_core.json", CM.Model)

for reaction ∈ A.reactions(model)
    println(reaction)
end

println("############################################################")
println("# E. COLI KCATOME                                          #")
println("############################################################")

const ecoli_core_reaction_kcats = Dict(
    "ACALD" => 568.11,
    "PTAr" => 1171.97,
    "ALCD2x" => 75.95,
    "PDH" => 529.76,
    "MALt2_2" => 234.03,
    "CS" => 113.29,
    "PGM" => 681.4,
    "TKT1" => 311.16,
    "ACONTa" => 191.02,
    "GLNS" => 89.83,
    "ICL" => 17.45,
    "FBA" => 373.42,
    "FORt2" => 233.93,
    "G6PDH2r" => 589.37,
    "AKGDH" => 264.48,
    "TKT2" => 467.42,
    "FRD7" => 90.20,
    "SUCOAS" => 18.49,
    "ICDHyr" => 39.62,
    "AKGt2r" => 234.99,
    "GLUSy" => 33.26,
    "TPI" => 698.30,
    "FORt" => 234.38,
    "ACONTb" => 159.74,
    "GLNabc" => 233.80,
    "RPE" => 1772.485,
    "ACKr" => 554.61,
    "THD2" => 24.73,
    "PFL" => 96.56,
    "RPI" => 51.77,
    "D_LACt2" => 233.51,
    "TALA" => 109.05,
    "PPCK" => 218.42,
    "PGL" => 2120.42,
    "NADTRHD" => 186.99,
    "PGK" => 57.64,
    "LDH_D" => 31.11,
    "ME1" => 487.01,
    "PIt2r" => 233.86,
    "ATPS4r" => 71.42,
    "GLCpts" => 233.90,
    "GLUDy" => 105.32,
    "CYTBD" => 153.18,
    "FUMt2_2" => 234.37,
    "FRUpts2" => 234.19,
    "GAPD" => 128.76,
    "PPC" => 165.52,
    "NADH16" => 971.74,
    "PFK" => 1000.46,
    "MDH" => 25.93,
    "PGI" => 468.11,
    "ME2" => 443.09,
    "GND" => 240.12,
    "SUCCt2_2" => 234.18,
    "GLUN" => 44.76,
    "ADK1" => 111.64,
    "SUCDi" => 680.31,
    "ENO" => 209.35,
    "MALS" => 252.75,
    "GLUt2r" => 234.22,
    "PPS" => 706.14,
    "FUM" => 1576.83,
)

for (key, value) ∈ ecoli_core_reaction_kcats
    println(key, ", kcat = ", value)
end

println("############################################################")
println("# REACTION ISOZYMES                                        #")
println("############################################################")

reaction_isozymes = Dict{String,Dict{String,Isozyme}}() # a mapping from reaction IDs to isozyme IDs to isozyme structs.
for rid in A.reactions(model)
    grrs = A.reaction_gene_association_dnf(model, rid)
    isnothing(grrs) && continue # skip if no grr available
    haskey(ecoli_core_reaction_kcats, rid) || continue # skip if no kcat data available
    for (i, grr) in enumerate(grrs)
        d = get!(reaction_isozymes, rid, Dict{String,Isozyme}())
        d["isozyme_"*string(i)] = Isozyme( # each isozyme gets a unique name
            gene_product_stoichiometry = Dict(grr .=> fill(1.0, size(grr))), # assume subunit stoichiometry of 1 for all isozymes
            kcat_forward = ecoli_core_reaction_kcats[rid] * 3.6, # forward reaction turnover number units = 1/h
            kcat_reverse = ecoli_core_reaction_kcats[rid] * 3.6, # reverse reaction turnover number units = 1/h
        )
    end
end

for (reaction_name, isozymes_dict) ∈ reaction_isozymes
    for (isozyme_name, isozyme_struct) ∈ isozymes_dict
        println("Reaction id: ", reaction_name, ", Isozyme name: ", isozyme_name, ", Isozyme struct: ", isozyme_struct)
    end
end

println("############################################################")
println("# GENE PRODUCT MASSES                                      #")
println("############################################################")

const ecoli_core_gene_product_masses = Dict(
    "b4301" => 23.214,
    "b1602" => 48.723,
    "b4154" => 65.972,
    "b3236" => 32.337,
    "b1621" => 56.627,
    "b1779" => 35.532,
    "b3951" => 85.96,
    "b1676" => 50.729,
    "b3114" => 85.936,
    "b1241" => 96.127,
    "b2276" => 52.044,
    "b1761" => 48.581,
    "b3925" => 35.852,
    "b3493" => 53.389,
    "b3733" => 31.577,
    "b2926" => 41.118,
    "b0979" => 42.424,
    "b4015" => 47.522,
    "b2296" => 43.29,
    "b4232" => 36.834,
    "b3732" => 50.325,
    "b2282" => 36.219,
    "b2283" => 100.299,
    "b0451" => 44.515,
    "b2463" => 82.417,
    "b0734" => 42.453,
    "b3738" => 30.303,
    "b3386" => 24.554,
    "b3603" => 59.168,
    "b2416" => 63.562,
    "b0729" => 29.777,
    "b0767" => 36.308,
    "b3734" => 55.222,
    "b4122" => 60.105,
    "b2987" => 53.809,
    "b2579" => 14.284,
    "b0809" => 26.731,
    "b1524" => 33.516,
    "b3612" => 56.194,
    "b3735" => 19.332,
    "b3731" => 15.068,
    "b1817" => 35.048,
    "b1603" => 54.623,
    "b1773" => 30.81,
    "b4090" => 16.073,
    "b0114" => 99.668,
    "b3962" => 51.56,
    "b2464" => 35.659,
    "b2976" => 80.489,
    "b1818" => 27.636,
    "b2285" => 18.59,
    "b1702" => 87.435,
    "b1849" => 42.434,
    "b1812" => 50.97,
    "b0902" => 28.204,
    "b3403" => 59.643,
    "b1612" => 60.299,
    "b1854" => 51.357,
    "b0811" => 27.19,
    "b0721" => 14.299,
    "b2914" => 22.86,
    "b1297" => 53.177,
    "b0723" => 64.422,
    "b3919" => 26.972,
    "b3115" => 43.384,
    "b4077" => 47.159,
    "b3528" => 45.436,
    "b0351" => 33.442,
    "b2029" => 51.481,
    "b1819" => 30.955,
    "b0728" => 41.393,
    "b2935" => 72.212,
    "b2415" => 9.119,
    "b0727" => 44.011,
    "b0116" => 50.688,
    "b0485" => 32.903,
    "b3736" => 17.264,
    "b0008" => 35.219,
    "b3212" => 163.297,
    "b3870" => 51.904,
    "b4014" => 60.274,
    "b2280" => 19.875,
    "b2133" => 64.612,
    "b2278" => 66.438,
    "b0118" => 93.498,
    "b2288" => 16.457,
    "b3739" => 13.632,
    "b3916" => 34.842,
    "b3952" => 32.43,
    "b2925" => 39.147,
    "b2465" => 73.043,
    "b2297" => 77.172,
    "b2417" => 18.251,
    "b4395" => 24.065,
    "b3956" => 99.063,
    "b0722" => 12.868,
    "b2779" => 45.655,
    "b0115" => 66.096,
    "b0733" => 58.205,
    "b1478" => 35.38,
    "b2492" => 30.565,
    "b0724" => 26.77,
    "b0755" => 28.556,
    "b1136" => 45.757,
    "b2286" => 68.236,
    "b0978" => 57.92,
    "b1852" => 55.704,
    "b2281" => 20.538,
    "b2587" => 47.052,
    "b2458" => 36.067,
    "b0904" => 30.991,
    "b1101" => 50.677,
    "b0875" => 23.703,
    "b3213" => 52.015,
    "b2975" => 58.92,
    "b0720" => 48.015,
    "b0903" => 85.357,
    "b1723" => 32.456,
    "b2097" => 38.109,
    "b3737" => 8.256,
    "b0810" => 24.364,
    "b4025" => 61.53,
    "b1380" => 36.535,
    "b0356" => 39.359,
    "b2277" => 56.525,
    "b1276" => 97.677,
    "b4152" => 15.015,
    "b1479" => 63.197,
    "b4153" => 27.123,
    "b4151" => 13.107,
    "b2287" => 25.056,
    "b0474" => 23.586,
    "b2284" => 49.292,
    "b1611" => 50.489,
    "b0726" => 105.062,
    "b2279" => 10.845,
    "s0001" => 0.0,
)

for (gene_name, product_mass) ∈ ecoli_core_gene_product_masses
    println("Gene: ", gene_name, ", Product mass: ", product_mass)
end
