#!/usr/bin/env python3
''' Generates reproducible graphs according to a number of vertices and  assigns country codes as labels in vertices. A random graph with random country labels can be produced by using cryptographically secure random numbers.  
    Creates a graphml file for each number of nodes.
    Dendendencies: networkx '''

import random
import networkx as nx

nodes_options = [500,1000,2000,3000,4000,5000,6000,7000,8000,9000,10000]

# list of countries that are included in the graph
countries = ['AR', 'BE', 'CH', 'ES', 'FR', 'GE', 'GB', 'DE', 'IT', 'FI', 'LU']

# create reproducible graphs according to a seed 
seed = 500 

for num_nodes in nodes_options:
    # enable the following code line to produce random graphs
    # seed = random.SystemRandom() 

    # Creates a random graph according to the Barabási–Albert preferential attachment model.
    G = nx.barabasi_albert_graph(num_nodes, 2, seed=seed)

    i = 0

    for node, data in G.nodes(data=True):
        # select a random country label from the countries list 
        # secure_random = random.SystemRandom()
        # country = secure_random.choice(countries)

        # the selection of country labels is predetermined 
        country = countries[i] 
        i = i + 1
        if (i >= 11): 
            i = 0

        data['Country'] = country

    s = '\n'.join(nx.generate_graphml(G))
    print (s)
    filename = "signer-infra-"+str(num_nodes)+".graphml"
    nx.write_graphml_xml(G, filename)