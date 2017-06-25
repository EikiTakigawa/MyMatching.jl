
module MyMatching

export my_deferred_acceptance

# for many-to-one matching
function my_deferred_acceptance(prop_prefs::Vector{Vector{Int}}, resp_prefs::Vector{Vector{Int}}, caps::Vector{Int})
    p = length(prop_prefs)
    r = length(resp_prefs)
    prop_matched = fill(-1, p)
    resp_matched = zeros(Int, sum(caps))
    indptr = Array{Int}(r+1)
    indptr[1] = 1
    for i in 1:r
        indptr[i+1] = indptr[i] + caps[i]
    end
    
    while sum(prop_matched .== -1) != 0
        for i in 1:p
            k = 1
            while prop_matched[i] == -1 && k <= length(prop_prefs[i])
                if findfirst(resp_prefs[prop_prefs[i][k]] ,i) != 0
                    if resp_matched[indptr[prop_prefs[i][k]+1]-1] == 0
                        resp_matched[indptr[prop_prefs[i][k]+1]-1] = i
                        prop_matched[i] = prop_prefs[i][k]
                        l = 1
                        while l < caps[prop_matched[i]]
                            if resp_matched[indptr[prop_prefs[i][k]+1]-1-l] == 0
                                resp_matched[indptr[prop_prefs[i][k]+1]-1-l] = i
                                resp_matched[indptr[prop_prefs[i][k]+1]-l] = 0
                            else
                                if findfirst(resp_prefs[prop_matched[i]], i) < findfirst(resp_prefs[prop_matched[i]], resp_matched[indptr[prop_prefs[i][k]+1]-1-l])
                                    resp_matched[indptr[prop_prefs[i][k]+1]-l] = resp_matched[indptr[prop_prefs[i][k]+1]-1-l]
                                    resp_matched[indptr[prop_prefs[i][k]+1]-1-l] = i
                                else
                                    l = Inf
                                end
                            end
                            l += 1
                        end
                    else
                        if findfirst(resp_prefs[prop_prefs[i][k]], i) < findfirst(resp_prefs[prop_prefs[i][k]], resp_matched[indptr[prop_prefs[i][k]+1]-1])
                            prop_matched[resp_matched[indptr[prop_prefs[i][k]+1]-1]] = -1
                            resp_matched[indptr[prop_prefs[i][k]+1]-1] = i
                            prop_matched[i] = prop_prefs[i][k]
                            l = 1
                            while l < caps[prop_matched[i]]
                                if resp_matched[indptr[prop_prefs[i][k]+1]-1-l] == 0
                                    resp_matched[indptr[prop_prefs[i][k]+1]-1-l] = i
                                    resp_matched[indptr[prop_prefs[i][k]+1]-l] = 0
                                else
                                    if findfirst(resp_prefs[prop_matched[i]], i) < findfirst(resp_prefs[prop_matched[i]], resp_matched[indptr[prop_prefs[i][k]+1]-1-l])
                                        resp_matched[indptr[prop_prefs[i][k]+1]-l] = resp_matched[indptr[prop_prefs[i][k]+1]-1-l]
                                        resp_matched[indptr[prop_prefs[i][k]+1]-1-l] = i
                                    else
                                        l = Inf
                                    end
                                end
                                l += 1
                            end
                        end
                    end
                end
                k += 1
            end
            if prop_matched[i] == -1
                prop_matched[i] = 0
            end
        end
    end
    return prop_matched, resp_matched, indptr
end

# for one-to-one matching
function my_deferred_acceptance(prop_prefs::Vector{Vector{Int}},resp_prefs::Vector{Vector{Int}})
    caps = ones(Int, length(resp_prefs))
    prop_matched, resp_matched, indptr = my_deferred_acceptance(prop_prefs, resp_prefs, caps)
    return prop_matched, resp_matched
end

end
