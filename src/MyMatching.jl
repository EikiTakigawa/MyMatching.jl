module MyMatching

export my_deferred_acceptance

function my_deferred_acceptance(m_prefs::Vector{Vector{Int}}, f_prefs::Vector{Vector{Int}})
    m = length(m_prefs)
    n = length(f_prefs)
    m_matched = Vector{Int}(m)
    m_matched[1:end] = -1  #-1はmatchしておらず、unmatchedと決まった状態でもないことを示します
    f_matched = zeros(Int, n)
    
    while sum(m_matched .== -1) != 0
       for i in 1:m
            k = 1
            while m_matched[i] == -1 && k <= length(m_prefs[i])
                if findfirst(f_prefs[m_prefs[i][k]] ,i) != 0
                    if f_matched[m_prefs[i][k]] == 0
                        f_matched[m_prefs[i][k]] = i
                        m_matched[i] = m_prefs[i][k]
                    else
                        if findfirst(f_prefs[m_prefs[i][k]] ,i) < findfirst(f_prefs[m_prefs[i][k]], f_matched[m_prefs[i][k]])
                            m_matched[f_matched[m_prefs[i][k]]] = -1
                            f_matched[m_prefs[i][k]] = i
                            m_matched[i] = m_prefs[i][k]
                        end
                    end
                end 
                k += 1
            end
            if m_matched[i] == -1
                m_matched[i] = 0
            end
        end
    end
    
    return m_matched, f_matched
end

end