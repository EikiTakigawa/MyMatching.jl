
module MyMatching

export my_deferred_acceptance, my_Boston_school_match

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
    
    while -1 in prop_matched
        for i in 1:p
            k = 1
            while prop_matched[i] == -1 && k <= length(prop_prefs[i])
                if i in resp_prefs[prop_prefs[i][k]]
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
                                if findfirst(resp_prefs[prop_matched[i]], i) < findfirst(resp_prefs[prop_matched[i]], resp_matched[indptr[prop_prefs[i][k]+1]-1-l])
                                    resp_matched[indptr[prop_prefs[i][k]+1]-l] = resp_matched[indptr[prop_prefs[i][k]+1]-1-l]
                                    resp_matched[indptr[prop_prefs[i][k]+1]-1-l] = i
                                else
                                    l = Inf
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

function my_Boston_school_match(prop_prefs::Vector{Vector{Int}}, resp_prefs::Vector{Vector{Int}}, caps::Vector{Int})
    p = length(prop_prefs)
    r = length(resp_prefs)
    prop_matched = zeros(Int, p)
    resp_matched = zeros(Int, sum(caps))
    indptr = Array{Int}(r+1)
    indptr[1] = 1
    c = copy(caps)
    for i in 1:r
        indptr[i+1] = indptr[i] + c[i]
    end
    
    for i in 1:maximum(length.(prop_prefs))
        for j in 1:p
            if prop_matched[j] == 0 && length(prop_prefs[j]) >= i
                if j in resp_prefs[prop_prefs[j][i]] && c[prop_prefs[j][i]] != 0
                    if resp_matched[indptr[prop_prefs[j][i]+1]-1] == 0
                        resp_matched[indptr[prop_prefs[j][i]+1]-1] = j
                        prop_matched[j] = prop_prefs[j][i]
                        l = 1
                        while l < c[prop_matched[j]]
                            if resp_matched[indptr[prop_prefs[j][i]+1]-1-l] == 0
                                resp_matched[indptr[prop_prefs[j][i]+1]-1-l] = j
                                resp_matched[indptr[prop_prefs[j][i]+1]-l] = 0
                            else
                                if findfirst(resp_prefs[prop_matched[j]], j) < findfirst(resp_prefs[prop_matched[j]], resp_matched[indptr[prop_prefs[j][i]+1]-1-l])
                                    resp_matched[indptr[prop_prefs[j][i]+1]-l] = resp_matched[indptr[prop_prefs[j][i]+1]-1-l]
                                    resp_matched[indptr[prop_prefs[j][i]+1]-1-l] = j
                                else
                                    l = Inf
                                end
                            end
                            l += 1
                        end
                    else
                        if findfirst(resp_prefs[prop_prefs[j][i]], j) < findfirst(resp_prefs[prop_prefs[j][i]], resp_matched[indptr[prop_prefs[j][i]+1]-1])
                            prop_matched[resp_matched[indptr[prop_prefs[j][i]+1]-1]] = 0
                            resp_matched[indptr[prop_prefs[j][i]+1]-1] = j
                            prop_matched[j] = prop_prefs[j][i]
                            l = 1
                            while l < c[prop_matched[j]]
                                if findfirst(resp_prefs[prop_matched[j]], j) < findfirst(resp_prefs[prop_matched[j]], resp_matched[indptr[prop_prefs[j][i]+1]-1-l])
                                    resp_matched[indptr[prop_prefs[j][i]+1]-l] = resp_matched[indptr[prop_prefs[j][i]+1]-1-l]
                                    resp_matched[indptr[prop_prefs[j][i]+1]-1-l] = j
                                else
                                    l = Inf
                                end
                                l += 1
                            end
                        end
                    end
                end
            end 
        end
        for k in 1:r
            c[k] = c[k] - sum(resp_matched[indptr[k]:indptr[k+1]-1] .!= 0)
        end
    end
    return prop_matched, resp_matched, indptr
end

end


