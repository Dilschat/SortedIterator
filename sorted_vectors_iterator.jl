using DataStructures
import Base.Order: Ordering, Forward, Reverse

"""
    SortedVectors(data, order)

Construct a new [`SortedVectors`](@ref), with vector of sorted vectors and order
of the sorting. If order is not given the vectors will be processed as min-ordered.
Moreover, if vectors is not sorted or sorted incorrectly [`ArgumentError`](@ref)
will be thrown.

A `SortedVectors` acts like any iterable collection
"""
struct SortedVectors{O<:Ordering}
    data::Vector{Vector{Int}}
    order::O
    function SortedVectors(data::Vector{Vector{Int}}, order::O = Forward) where {O<:Ordering}
        for vector in data
            if !issorted(vector, order=order)
                throw(ArgumentError("input should be sorted: $vector"))
            end
        end
        new{O}(data, order)
    end
end

"""
Represents state of iteration using [`PriorityQueue{K,V}`](@ref)
key of queue is presented by tuple of data_idx(idx of outer vector) and
element_idx(idx of inner vector), priority is presented by element of SortedVectors
that was extracted using data_idx and element_idx
"""
SortedIteratorState = PriorityQueue

function _enqueue!(state, vectors, data_idx, element_idx)
    if get(vectors.data[data_idx], element_idx, nothing) != nothing
        enqueue!(state, (data_idx, element_idx), vectors.data[data_idx][element_idx])
    end
end

"""
Represents result of each iteration step.
The result is presented by tuple of data_idx, element_idx, element, current_state.
In case of empty input or end of data returns object of type Nothing.
"""
SortedIteratorResult = Union{Tuple{Int, Int, Int, SortedIteratorState}, Nothing}

Base.iterate(vectors::SortedVectors)::SortedIteratorResult = iterate(vectors, _init_state(vectors))

function Base.iterate(vectors::SortedVectors, state::SortedIteratorState)::SortedIteratorResult
    if isempty(state) return nothing end
    return _get_next_iteration_step(vectors, state)
end

Base.iterate(vectors::SortedVectors, state::Nothing) = nothing

function _init_state(vectors::SortedVectors)::SortedIteratorState
    sorted_elements = PriorityQueue(vectors.order)
    for (i, vec) in enumerate(vectors.data)
        _enqueue!(sorted_elements, vectors, i, 1)
    end
    return sorted_elements
end

function _get_next_iteration_step(vectors::SortedVectors, state::SortedIteratorState)::SortedIteratorResult
    new_state::SortedIteratorState = copy(state)
    data_idx, element_idx = dequeue!(new_state)
    _enqueue!(new_state, vectors, data_idx, element_idx+1)
    return data_idx, element_idx, vectors.data[data_idx][element_idx], new_state
end
