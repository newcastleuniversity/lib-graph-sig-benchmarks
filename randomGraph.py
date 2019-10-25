import networkx as nx
try:
    from StringIO import StringIO
except ImportError:
    from io import BytesIO 
    #StringIO

G=nx.path_graph(4)
cities = {0:"Toronto",1:"London",2:"Berlin",3:"New York"}

H=nx.relabel_nodes(G,cities)
 
print("Nodes of graph: ")
print(H.nodes())
print("Edges of graph: ")
print(H.edges())
#nx.draw(H)

# File-like object - use StringIO for python 2.7
output = BytesIO()

nx.write_graphml(H, output)

# And here's your string
gstr = output.getvalue()
print(gstr)
output.close()
