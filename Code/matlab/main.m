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
init_infected = initial_seed(death_data, pop_data, starting_year, starting_quarter);

%set our probability of spreading infection and recovery
ps = (1:10)/10000;
pr = 0.2;

%Now run through as many times as we have networks
files = dir('../../Data/Clean');

results = struct;
tic
for ctr = 1:length(ps)
year = starting_year;
scale = 100; %number to divide population numbers by
infected(1,:) = init_infected;
for k = 4:length(files)-3 %don't read 2019, we don't have pop data
    year = year+0.25;
    fname = strcat(files(k).folder, '/', files(k).name);
    A = create_A(fname);
    populations = get_populations(pop_data, floor(year));
    A = A / scale;
    populations = floor(populations / scale);
    infected(k-2,:) = run_infection(A, infected(k-3,:), populations, ps(ctr), pr);
end

results(ctr).infected = infected;
results(ctr).ps = ps(ctr);
end
toc


%% plot stuff
for k = 1:length(results)
    new_results(k,:) = results(k).infected(end,:);
end
x = 1:50;
figure();
surf(ps, x, new_results');
title('Proportion of State Infected with P(heal) = 0.5');
xlabel('Probability of Spreading');
ylabel('State');
zlabel('Proportion Infected');












