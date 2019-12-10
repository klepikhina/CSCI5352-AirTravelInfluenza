%Josh Mellin
%CSCI 5352 Project
%This function computes the closeness centrality for each state for each
%quarter.  It then averages the results and writes the output to a file.
%This centrality is computed just as the number of people leaving the
%state.


%housekeeping
clear all; close all; clc;

%Now run through as many times as we have networks
files = dir('../../Data/Clean');

%compute everything
year = 2009;
quarter = 4;
N = length(files)-5-3;
for k = 4:length(files)-5 %don't read 2019, we don't have pop data
    year = year+0.25;
    fname = strcat(files(k).folder, '/', files(k).name);
    A = create_A(fname);
    closeness(k-3,:) = sum(A');
end

%%
avg = sum(closeness) / N;

%create all the state names
ref = {'Alabama' 'Alaska' 'Arizona' 'Arkansas' 'California' 'Colorado' 'Connecticut' 'Delaware' ... 
        'Florida' 'Georgia' 'Hawaii' 'Idaho' 'Illinois' 'Indiana' 'Iowa' 'Kansas' ... 
        'Kentucky' 'Louisiana' 'Maine' 'Maryland' 'Massachusetts' 'Michigan' 'Minnesota' ... 
        'Mississippi' 'Missouri' 'Montana' 'Nebraska' 'Nevada' 'New Hampshire' ... 
        'New Jersey' 'New Mexico' 'New York' 'North Carolina' 'North Dakota' 'Ohio' ... 
        'Oklahoma' 'Oregon' 'Pennsylvania' 'Rhode Island' 'South Carolina' 'South Dakota' ...
        'Tennessee' 'Texas' 'Utah' 'Vermont' 'Virginia' 'Washington' 'West Virginia' ...
        'Wisconsin' 'Wyoming'};
ref = string(ref);
avg = string(avg);
fout = 'closeness_results.csv';
xlswrite(fout, [ref' (1:50)' avg']);



