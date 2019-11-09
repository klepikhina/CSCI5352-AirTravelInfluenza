%Josh Mellin
%CSCI 5352 Project

%This function reads in the network from the given file and creates the
%adjacency matrix full of the number of people who traveled from row to
%column.

function A = create_A(fname)
    [num, states, ~] = xlsread(fname);
    
    %convert the states to numbers
    states = string(states);
    states(1,:) = [];
    [new_states, new_num] = convert_states(states, num);
    
    %create the A matrix
    for k = 1:length(new_num)
        A(new_states(k,1),new_states(k,2)) = new_num(k);
    end
    
    
end