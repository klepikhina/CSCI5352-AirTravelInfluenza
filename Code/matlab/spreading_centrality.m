 %Josh Mellin
%CSCI 5352

%This function runs the main program.  It starts by creating the initial
%infected proportions based off of the first dataset for flu deaths, and
%then loops through the simulation from all the air travel networks.

%housekeeping
clear all; close all; clc

%read in the population data only once
[pop_data, ~, ~] = xlsread('../../Data/Clean/population.csv');
pop_data = [(0:50)' pop_data];

%Read in the initial flu death data once
fname = '../../Data/Clean/deaths_NCHS_processed.csv';
[death_data, state_deaths, ~] = xlsread(fname);
state_deaths = string(state_deaths);
state_deaths(1,:) = [];
state_deaths(:,2:end) = [];
state_deaths = convert_abbreviations(state_deaths);
death_data = [state_deaths death_data];
starting_year = 2009;
starting_quarter = 4;

%clean the death data for some reason
for k = 1:length(death_data)
    if(isnan(death_data(k,2)))
        death_data(k,2) = 0;
    end
end

%set our probability of spreading infection and recovery
ps = 0.097138;
pr = 0.9301301;

%Now run through as many times as we have networks
files = dir('../../Data/Clean');

results = struct;
N = 50; %number of simulations for each state
tic
for states = 1:50
    for ctr = 1:N
    year = starting_year;
    scale = 100; %number to divide population numbers by
    infected(1,:) = initial_seed_spreading(death_data, pop_data, year, starting_quarter, states);
    for k = 4:length(files)-5 %don't read 2019, we don't have pop data
        year = year+0.25;
        fname = strcat(files(k).folder, '/', files(k).name);
        A = create_A(fname);
        populations = get_populations(pop_data, floor(year));
        A = A / scale;
        populations = floor(populations / scale);
        infected(k-2,:) = run_infection(A, infected(k-3,:), populations, ps, pr);
    end

    results(ctr).infected = infected;
    end
    
    %now store the centrality score for that state
    final_infected = zeros(1,50);
    for k = 1:length(results)
        final_infected = final_infected + sum(results(k).infected);
    end
    final_infected = final_infected / N;
    centrality(states) = sum(final_infected .* pop_data(2:end,end)');
    
end
toc

%get the number of deaths, not just infected
centrality = centrality / 1000;

%% plot centrality scores
x = 1:50;
figure();
plot(x, centrality);
title('Centrality of Each State');
xlabel('State Number');
ylabel('Number of Deaths in 2019');

%write the results
ref = {'Alabama' 'Alaska' 'Arizona' 'Arkansas' 'California' 'Colorado' 'Connecticut' 'Delaware' ... 
        'Florida' 'Georgia' 'Hawaii' 'Idaho' 'Illinois' 'Indiana' 'Iowa' 'Kansas' ... 
        'Kentucky' 'Louisiana' 'Maine' 'Maryland' 'Massachusetts' 'Michigan' 'Minnesota' ... 
        'Mississippi' 'Missouri' 'Montana' 'Nebraska' 'Nevada' 'New Hampshire' ... 
        'New Jersey' 'New Mexico' 'New York' 'North Carolina' 'North Dakota' 'Ohio' ... 
        'Oklahoma' 'Oregon' 'Pennsylvania' 'Rhode Island' 'South Carolina' 'South Dakota' ...
        'Tennessee' 'Texas' 'Utah' 'Vermont' 'Virginia' 'Washington' 'West Virginia' ...
        'Wisconsin' 'Wyoming'};
ref = string(ref);
x = string(x);

fout = 'spreading_results.csv';
xlswrite(fout, [ref' x' centrality']);







