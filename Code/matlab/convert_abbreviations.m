%Josh Mellin
%CSCI 5352

%This function converts the abbreviations of states into numbers
%corresponding to the same as thhe convert_states.m function.  It takes a
%vector of state abbreviations and returns a vector of numbers for each
%state.


function rv = convert_abbreviations(x)
ref = {'AL' 'AK' 'AZ' 'AR' 'CA' 'CO' 'CT' 'DE' ... 
        'FL' 'GA' 'HI' 'ID' 'IL' 'IN' 'IA' 'KS' ... 
        'KY' 'LA' 'ME' 'MD' 'MA' 'MI' 'MN' ... 
        'MS' 'MO' 'MT' 'NE' 'NV' 'NH' ... 
        'NJ' 'NM' 'NY' 'NC' 'ND' 'OH' ... 
        'OK' 'OR' 'PA' 'RI' 'SC' 'SD' ...
        'TN' 'TX' 'UT' 'VT' 'VA' 'WA' 'WV' ...
        'WI' 'WY'};

ref = string(ref);
rv = zeros(length(x),1);
j = 1;
for k = 1:length(x)
    if(x(k) == "DC")
        rv(j) = 51;
        j = j+1;
        continue;
    end
    ind = find(ref == x(k));
    rv(j) = ind;
    j = j+1;
end







end