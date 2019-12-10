import numpy as np
import pandas as pd

from copy import deepcopy as copy

# Note: We are keeping only the 50 states. DC not included. Self loops not included

def read_US_states(fname):
    states_abb_dict = {}
    states_abb_rev_dict = {}
    states_abb_ord_list = []
    with open(fname, "r") as f:
        for line in f:
            line = line.strip().split(",")
            name = line[0]
            abbr = line[1]
            states_abb_dict[name] = (abbr, len(states_abb_ord_list))
            states_abb_rev_dict[abbr] = name
            states_abb_ord_list.append(abbr)
    
    return states_abb_dict, states_abb_rev_dict, states_abb_ord_list

def read_travel_network(fname, states_abb_dict, states_abb_rev_dict, normalization=1):
    num_states = 50

    adjacency_list = {}
    A = np.zeros((num_states, num_states))

    for abb in states_abb_rev_dict:
        adjacency_list[abb] = []

    with open(fname, "r") as f:
        for idx, line in enumerate(f):
            if idx == 0:
                continue
            line = line.strip().split(",")
            orig = line[0]
            dest = line[1]
            weight = float(line[2])*10 / normalization
            if orig == dest:
                continue
            try:
                orig_abb, orig_idx = states_abb_dict[orig]
                dest_abb, dest_idx = states_abb_dict[dest]
                adjacency_list[orig_abb].append((dest_abb, weight))
                A[orig_idx][dest_idx] = weight
            except KeyError:
                pass
    
    return adjacency_list, A

def read_deaths_data(fname):
    df = pd.read_csv(fname)
    sum_df_d = df.groupby(['State', 'Year', 'Quarter'])[['DeathsFromPneumoniaAndInfluenza']].sum().T.to_dict()
    deaths_dict = {}
    for key, deaths in sum_df_d.items():
        state, year, quarter = key
        if state == "DC":
            continue
        if state not in deaths_dict:
            deaths_dict[state] = {}
        if year not in deaths_dict[state]:
            deaths_dict[state][year] = {}
        deaths_dict[state][year][quarter] = deaths["DeathsFromPneumoniaAndInfluenza"]
    return deaths_dict

def read_population_dict(fname):
    population_dict = {}
    with open(fname, "r") as f:
        for idx, line in enumerate(f):
            if idx == 0:
                continue
            line = line.strip().split(",")
            state = line[1]
            population_dict[state] = {}
            year = 2009
            for idx, pop in enumerate(line[2:]):
                population_dict[state][year + idx] = int(pop)
    return population_dict