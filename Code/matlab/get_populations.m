%Josh Mellin
%CSCI 5352 Project

%This function returns the population for each state for a given year

function population = get_populations(pop_data, year)
ind = find(pop_data(1,:) == year);
population = pop_data(2:end,ind(1));
end

