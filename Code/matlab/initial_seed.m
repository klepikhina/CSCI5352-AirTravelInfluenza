%Josh Mellin
%CSCI 5352

%This function creates the initial seed for the proportion of people in
%each state who are infected.  Takes the filename for the death data, the
%matrix of population data we have, and the year and quarter we are
%starting from.

function infected = initial_seed(death_data, pop_data, year, quarter)
pop_ind = find(pop_data(1,:) == year);
infected = zeros(1,50);

for k = 1:50 %for each state
    %find where the year and quarter data start
    index = find(death_data(:,1) == k);
    ind = find(death_data(index(1):end,3) == year);
    ind2 = find(death_data(index(1)+ind(1)-1:end,5) == quarter);
    j = index(1) + ind(1)-1 + ind2(1)-1;

    %Find the total number of deaths
    deaths_per_quarter = 0;
    while(death_data(j,5) == quarter)
        deaths_per_quarter = deaths_per_quarter + death_data(j,2);
        j = j+1;
    end
    
    %compute the ratio of deaths/population for each state
    infected(k) = deaths_per_quarter / pop_data(k+1, pop_ind(1));



end

%multiply the proportion of those who died by some constant to get the
%proportion of people who are sick in the state.  (1/c people  who are sick
%die
c = 1000;
infected = infected * c;



end




