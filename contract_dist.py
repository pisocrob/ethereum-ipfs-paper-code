import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np

file="size_list.txt"

with open(file) as f:
 results = f.readlines()
f.close()

results = list(map(lambda x: int(x), results))
results = sorted(results)

binned, edges = np.histogram(results, bins=10)

binned = sorted(binned)
edges = sorted(edges, reverse=True)

print(binned)


ax = sns.barplot(edges[:-1], binned, alpha=0.3, color='red')
xticks = ax.get_xticklabels()
ax.set_xticklabels(xticks, rotation=75)
ax.legend()
sns.set(rc={'figure.figsize':(11.7,8.27)}
    
plt.xlabel("Size of contract (bytes)")
plt.ylabel("Number of contracts")
#plt.savefig('contract_size_dist.png')
plt.show()