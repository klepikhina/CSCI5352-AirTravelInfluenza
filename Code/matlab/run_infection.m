%Josh Mellin
%CSCI 5352 Project

%This function takes the adjacency matrix (populated with number of people
%who travel from row to column, a vector of infected proportion of people,
%and a vector of the total population of each state.  The probability of a
%person spreading an infection, and the probability of a person recovering
%from an infection.

%It returns a vector of the final infected proportion of people for each
%state

function infected = run_infection(A, inf_prop, pop, ps, pr)

infected = floor(pop .* inf_prop');
for k = 1:length(A)
    for j = 1:length(A)
        num_sims = floor(A(k,j)*inf_prop(k));
        
        %now each person that was sick tries to infect people in col state
        for i = 1:num_sims
            num_healthy = pop(j) - infected(j); %number of healthy people
            infected(j) = infected(j) + binornd(floor(num_healthy*.1), ps);
        end
        
        %and then add in some random people that get sick not from
        %travelers.  Comment this out for the spreading centrality
        %infected(j) = infected(j) + binornd(floor(pop(j)-infected(j)*.1), 0.001);
    end
end

%Now compute how many people in each state recover
for k = 1:length(infected)
    infected(k) = infected(k) - binornd(infected(k), pr);
end

%And divide the number infected by the population of the states
infected = infected ./ pop;


end



