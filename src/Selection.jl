# Copyright (c) Guillaume Fraux 2015
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
export evaluate, selection_string

function Selection(selection::AbstractString)
    handle = lib.chfl_selection(pointer(selection))
    return Selection(handle)
end

function selection_string(selection::Selection)
    result = " " ^ 64
    check(
        lib.chfl_selection_string(selection.handle, pointer(result), UInt64(length(result)))
    )
    return strip_null(result)
end

function Base.size(selection::Selection)
    result = Ref{UInt64}(0)
    check(
        lib.chfl_selection_size(selection.handle, result)
    )
    return result[]
end

function evaluate(selection::Selection, frame::Frame)
    matching = Ref{UInt64}(0)
    check(
        lib.chfl_selection_evaluate(selection.handle, frame.handle, matching)
    )
    matching = matching[]
    matches = Array{lib.chfl_match_t}(matching)
    check(
        lib.chfl_selection_matches(selection.handle, pointer(matches), matching)
    )
    result = []
    selection_size = size(selection)
    for match in matches
        assert(match.size == selection_size)
        if selection_size == 1
            push!(result, match.atoms_1)
        elseif selection_size == 2
            push!(result, (match.atoms_1, match.atoms_2))
        elseif selection_size == 3
            push!(result, (match.atoms_1, match.atoms_2, match.atoms_3))
        elseif selection_size == 4
            push!(result, (match.atoms_1, match.atoms_2, match.atoms_3, match.atoms_4))
        end
    end
    return result
end

function free(selection::Selection)
    lib.chfl_selection_free(selection.handle)
end
