import numpy as np
import matplotlib.pyplot as plt
import networkx as nx

from numpy import linalg as LA
from copy import deepcopy as copy

class State:
    def __init__(self, pop):
        self.num_total = pop
        self.num_infected = 0
        self.num_deceased = 0
    
    def infected_fraction(self):
        return self.num_infected / self.num_total

def travel_and_infect_kernel(A, states, p_transfer, touch_fraction=0.5):
    N = A.shape[0]
    new_states = copy(states)
    
    infected_fraction = np.zeros((N,))
    for i in range(N):
        infected_fraction[i] = states[i].infected_fraction()
    
    for dest_id in range(N):
        
        # Let X be number of successful infections.
        # X is Binomial(n, p_transfer) where n is number of travelers.
        # We want X >= 1 for each person at destination i.e.,
        # at least one successful infection for each person at destination.
        # So, calculate p' = P(X >= 1) = 1 - P(X = 0) = 1 - (1-p_transfer)^n.
        # p' is the probability a person at destination gets infected.
        # This reduces problem to calculate a new r.v. Y.
        # Y is Binomial(m, p'), where m is the uninfected population of destination
        
        num_immigrants = A[:, i]
        num_infected_immigrants = np.matmul(num_immigrants, infected_fraction.T)
        # in expectation:
        # num_infected_immigrants = np.sum(A[:, i]) * p_inf
        ccdf = 1 - (1 - p_transfer)**num_infected_immigrants
        dest = states[dest_id]
        if dest.num_total - dest.num_infected > 0:
            if np.isnan(ccdf):
                ccdf = 1
            new_states[dest_id].num_infected += np.random.binomial(
                touch_fraction*(dest.num_total - dest.num_infected), ccdf)
#             # in expectation:
#             new_states[dest_id].num_infected += (dest.num_total - dest.num_infected) * ccdf
        
    return new_states

def recover_kernel(states, SIR_params):
    SIR_params = np.abs(SIR_params) / np.sum(np.abs(SIR_params))
    for i, state in enumerate(states):
        x = np.random.multinomial(states[i].num_infected, SIR_params)
        recovered = x[0]
        dead = x[2]
        state.num_total = max(state.num_total - dead, 0)
        states[i].num_infected -= (dead + recovered)
        states[i].num_deceased += dead
    return states

def local_infection_kernel(states, p_transfer):
    for i, state in enumerate(states):
        states[i].num_infected = np.random.binomial(state.num_total - state.num_infected, p_transfer)
    return states

def remove_deceased_kernel(states):
    num_deceased = []
    for i, state in enumerate(states):
        num_deceased.append(state.num_deceased)
        state.num_deceased = 0
        states[i] = state
    return states, num_deceased
    
def inject_population_kernel(states, new_population):
    # new_population is somehow ordered
    for i, state in enumerate(states):
        current_pop = state.num_total
        nextgen_pop = new_population[i]
        extra_peeps = nextgen_pop - current_pop
        if extra_peeps > 0:
            state.num_total += extra_peeps
        elif extra_peeps < 0:
            # population actually decreased... remove infected and susceptible at same rate
            extra_peeps = -extra_peeps
            if extra_peeps // 2 >= state.num_infected:
                state.num_total = state.num_total - (extra_peeps - state.num_infected)
                state.num_infected = 0
            else:
                state.num_infected -= (extra_peeps - extra_peeps//2)
                state.num_total -= extra_peeps
        states[i] = state
    return states

def random_infection_kernel(states, p_inf):
    for i, state in enumerate(states):
        if state.num_total < state.num_infected:
            continue
        infected = np.random.binomial(state.num_total - state.num_infected, p_inf)
        state.num_infected += infected
        states[i] = state
    return states


def run_full_simulation(x, A_dict, all_population, years, sim_quarter=-1, touch_fraction=0.5):
    p_inf = x[0]
    p_transfer = x[1]
    if p_inf < 0 or p_inf > 1 or p_transfer < 0 or p_transfer > 1:
        return 10
    p_rec = x[2]
    p_die = 7.540044190323758e-05
    p_stay = 1 - p_rec - p_die
    SIR = [p_rec, p_stay, p_die]
    
    states = []
    year_0 = 2009
    for state_id in range(50):
        state = State(all_population[year_0][state_id])
        state.num_infected += np.random.binomial(state.num_total, p_inf)
        states.append(state)

    # Propagate infection
    num_deceased = {}

    # For each year:
    for year in years:
        num_deceased[year] = {}
        # For each quarter:
        for quarter in range(1, 5):
            if year == 2009 and quarter != 4:
                continue
            if year == 2019 and quarter != 1:
                continue
            if sim_quarter != -1 and quarter != sim_quarter:
                continue
            # 1. travel and infect
            # 2. Recover
            # 3. Remove deceased and store it
            # 4. Randomly infect
            states = travel_and_infect_kernel(A_dict[year][quarter], states, p_transfer, touch_fraction=touch_fraction)
            states = recover_kernel(states, SIR)
            
            for i in range(8):
                states = local_infection_kernel(states, p_transfer)
                states = recover_kernel(states, SIR)
            
            states, dead_peeps = remove_deceased_kernel(states)
            num_deceased[year][quarter] = dead_peeps
            states = random_infection_kernel(states, p_inf)

        # Inject population
        try:
            pop_vec = inject_population_kernel(states, all_population[year+1])
        except KeyError:
            # We are at the end of our data
            pass
    
    sim_deaths_matrix = []

    for year, quarterly_deaths in num_deceased.items():
        for quarter, deaths_vector in quarterly_deaths.items():
            sim_deaths_matrix.append(deaths_vector)

    sim_deaths_matrix = np.array(sim_deaths_matrix).T
    
    return sim_deaths_matrix

def get_cost(Y_true, Y_est):
    norm_coeff = Y_true.shape[0] * Y_true.shape[1] * LA.norm(Y_true, ord='fro')
    return LA.norm(Y_true - Y_est, ord='fro') / norm_coeff