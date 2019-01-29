#!/usr/bin/env python3
''' Generates random graphs according to a number of vertices and randomly assigns countries as labels in vertices.
    Creates a graphml file for each number of nodes.
    Dendendencies: networkx '''

import random
import networkx as nx

nodes_options = [50, 500, 5000]

# G = nx.waxman_graph(num_nodes, 0.4, 0.15, seed=secure_random)

# list of countries that are included in the graph
countries = ['UK', 'DE', 'ES', 'FI']

for num_nodes in nodes_options:
    secure_random = random.SystemRandom()

    # Creates a random graph according to the Barabási–Albert preferential attachment model.
    G = nx.barabasi_albert_graph(num_nodes, 2, seed=secure_random)
    for node, data in G.nodes(data=True):
        secure_random = random.SystemRandom()
        country = secure_random.choice(countries)
        data['Country'] = country
        # del data['pos'] #used when creating a random graph using waxman model

    s = '\n'.join(nx.generate_graphml(G))
    print (s)
    filename = "signer-infra-"+str(num_nodes)+".graphml"
    nx.write_graphml_xml(G, filename)
