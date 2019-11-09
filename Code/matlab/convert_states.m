%Josh Mellin
%CSCI 5352

%This function converts the names of states into numbers.  Organized
%alphabetically.  It takes a string of pairs of states and returns a 2xn
%matrix of the corresponding numerical values for the states.  It also
%takes the vector of flights between two places and eliminates numbers from
%flights not within the 50 US states


function [states, num] = convert_states(x, y)
ref = {'Alabama' 'Alaska' 'Arizona' 'Arkansas' 'California' 'Colorado' 'Connecticut' 'Deleware' ... 
        'Florida' 'Georgia' 'Hawaii' 'Idaho' 'Illinois' 'Indiana' 'Iowa' 'Kansas' ... 
        'Kentucky' 'Louisiana' 'Maine' 'Maryland' 'Massachusetts' 'Michigan' 'Minnesota' ... 
        'Mississippi' 'Missouri' 'Montana' 'Nebraska' 'Nevada' 'New Hampshire' ... 
        'New Jersey' 'New Mexico' 'New York' 'North Carolina' 'North Dakota' 'Ohio' ... 
        'Oklahoma' 'Oregon' 'Pennsylvania' 'Rhode Island' 'South Carolina' 'South Dakota' ...
        'Tennessee' 'Texas' 'Utah' 'Vermont' 'Virginia' 'Washington' 'West Virginia' ...
        'Wisconsin' 'Wyoming'};
      
ref = string(ref);
j = 1;
for k = 1:length(x)
    if(x(k,1) == 'Puerto Rico' || x(k,1) == 'U.S. Pacific Trust Territories and Possessions' ...
            || x(k,1) == 'U.S. Virgin Islands' || x(k,2) == 'Puerto Rico' || ... 
            x(k,2) == 'U.S. Pacific Trust Territories and Possessions' ...
            || x(k,2) == 'U.S. Virgin Islands')
        continue;
    end
    ind1 = find(ref == x(k,1));
    ind2 = find(ref == x(k,2));
    states(j,:) = [ind1 ind2];
    num(j) = y(k);
    j = j+1;
end


end













