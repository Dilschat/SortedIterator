using Test
using BenchmarkTools
using Random

include("sorted_vectors_iterator.jl")

generate_random_input(num_of_vectors::UnitRange, order::Ordering)::SortedVectors =
    SortedVectors([sort(rand(Int, i), order = order) for i in num_of_vectors], order)

function sort_test(iter::SortedVectors)
    result = []
    next = iterate(iter)
    while next !== nothing
        append!(result, next[3])
        next = iterate(iter, next[end])
    end
    return result
end

@testset "sorted iterator of min-sorted data property based test" begin
    #imitating property-based testing
    for i = 1:100
        vectors = generate_random_input(0:10, Forward)
        sorted_vectors = sort_test(vectors)
        @test issorted(sorted_vectors) &&
              sum(map(length, vectors.data)) == length(sorted_vectors)
    end
end

@testset "sorted iterator of max-sorted data property based test" begin
    #imitating property-based testing
    for i = 1:100
        vectors = generate_random_input(0:10, Reverse)
        sorted_vectors = sort_test(vectors)
        @test issorted(sorted_vectors, order = Reverse) &&
              sum(map(length, vectors.data)) == length(sorted_vectors)
    end
end

@testset "sorted iterator of sorted data" begin
    @test sort_test(SortedVectors([[1, 2, 3, 5], [3, 4], [4, 10]])) ==
          [1, 2, 3, 3, 4, 4, 5, 10]
    @test sort_test(SortedVectors([[5, 3, 2, 1], [4, 3], [10, 4]], Reverse)) ==
          [10, 5, 4, 4, 3, 3, 2, 1]
    @test sort_test(SortedVectors([[1, 2, 3, 5], [0, 3, 4], [4, 10]])) ==
          [0, 1, 2, 3, 3, 4, 4, 5, 10]
    @test sort_test(SortedVectors([[1, 1, 1], [1, 1]])) == [1, 1, 1, 1, 1]
end

@testset "sorted iterator of empty data" begin
    @test isnothing(iterate(SortedVectors(Vector{Vector{Int}}(Vector{Int}()))))
    @test isnothing(iterate(SortedVectors(Vector{Vector{Int}}())))
    @test isnothing(iterate(SortedVectors(Vector{Vector{Int}}()), nothing))
end
