import sys
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import statistics
import numpy as np
import scipy.stats as stats
import pandas as pd
# 66, 1053, 19014, 1000000
batch = [66, 1053, 19014, 1000000]
colour = {66: 'red', 1053: 'green', 19014: 'blue', 1000000: 'black'}
x_range = [.1,.8]
bins = 20
results = []

for each in batch:

    file="results_"+str(each)+"x100_external.txt"
    temp = []
    with open(file) as f:
     temp = f.readlines()
    f.close()
    temp = temp[:-1]
    temp = list(map(lambda x: float(x), temp))
    results.append(temp)

def histograms(results):
    hist_66, edges = np.histogram(results[0], bins=bins, range=x_range)
    hist_1053, edges = np.histogram(results[1], bins=bins, range=x_range)
    hist_19014, edges = np.histogram(results[2], bins=bins, range=x_range)
    hist_1000000, edges = np.histogram(results[3], bins=bins, range=x_range)

    #print(hist_19014, edges)

    intersection = []
    minima = np.minimum(hist_66, hist_1053)
    print(minima)
    intersection.insert(0, np.true_divide(np.sum(minima), np.sum(hist_1053)))
    print("66 vs 1053: "+str(intersection[0]))

    minima = np.minimum(hist_66, hist_19014)
    intersection.insert(0, np.true_divide(np.sum(minima), np.sum(hist_1053)))
    print("66 vs 19014: "+str(intersection[0]))

    minima = np.minimum(hist_1053, hist_19014)
    intersection.insert(0, np.true_divide(np.sum(minima), np.sum(hist_1053)))
    print("1053 vs 19014: "+str(intersection[0]))

    minima = np.minimum(hist_66, hist_1000000)
    intersection.insert(0, np.true_divide(np.sum(minima), np.sum(hist_1053)))
    print("66 vs 1000000: "+str(intersection[0]))

    minima = np.minimum(hist_1053, hist_1000000)
    intersection.insert(0, np.true_divide(np.sum(minima), np.sum(hist_1053)))
    print("1053 vs 1000000: "+str(intersection[0]))

    minima = np.minimum(hist_19014, hist_1000000)
    intersection.insert(0, np.true_divide(np.sum(minima), np.sum(hist_1053)))
    print("19014 vs 1000000: "+str(intersection[0]))


    mean_itersec = sum(intersection)/len(intersection)

    print("Mean intersection: "+str(mean_itersec))



    sns.set(rc={'figure.figsize':(11.7,8.27)})
    sns.set_style("whitegrid")
    sns.barplot(edges[:-1], hist_66, color=colour[66], alpha=0.3, label="66")
    sns.barplot(edges[:-1], hist_1053, color=colour[1053], alpha=0.3, label="1053")
    ax = sns.barplot(edges[:-1], hist_19014, color=colour[19014], alpha=0.3, label="19014")

    xticks = ax.get_xticklabels()
    ax.set_xticklabels(xticks, rotation=75)
    ax.legend(frameon=True)


    plt.ylim(0, 100)
    plt.xlabel("Retreival time in seconds")
    plt.ylabel("Amount")
    plt.show()
    #plt.savefig('intersection_hist.png')


    plt.clf()
    sns.set(rc={'figure.figsize':(11.7,8.27)})
    sns.set_style("whitegrid")
    for i, each in enumerate(batch):
        plt.ylim(0, 140)
        plt.xlabel("Retrieval time in seconds")
        plt.ylabel("Amount")
        hist, edges = np.histogram(results[i], bins=bins, range=x_range)
        ax = sns.barplot(edges[:-1], hist, color=colour[each], alpha=0.3)
        xticks = ax.get_xticklabels()
        ax.set_xticklabels(xticks, rotation=75)
        #plt.savefig('latency_distribution_unnormalised_'+str(each)+'.png')
        plt.show()
        plt.clf()

    file = "latency_all_external.txt"
    with open(file) as f:
     results = f.readlines()
    f.close()
    results = list(map(lambda x: float(x), results))
    print("Overall average:")
    #print(sum(results)/len(results))
    print(statistics.median(results))


def box_plot():
    results[1].append(statistics.median(results[1]))


    data = {}
    for i, each in enumerate(results):
        data[batch[i]] = each
        print(batch[i])

    df_data = pd.DataFrame.from_dict(data)
    ax = sns.boxplot(data = df_data, palette=colour)
    plt.xlabel("Retrieval times grouped by file size")
    plt.ylabel("Time in seconds")

    # Add transparency to colors
    for patch in ax.artists:
        r, g, b, a = patch.get_facecolor()
        patch.set_facecolor((r, g, b, .3))

    plt.savefig('latency_box_plot.png')


def chisquare_comparisons():
    hists_normed = []
    for each in results:
        hist = []
        hist, e = np.histogram(each, bins=bins, range=x_range)
        total = sum(hist)
        normed = list(map(lambda x: x/total, hist))
        hists_normed.append(normed)

    c, p = stats.chisquare(f_obs=hists_normed[0],f_exp=hists_normed[1])
    print(c, " ", p)

#box_plot()
#histograms(results)
chisquare_comparisons()

print("66 mean: "+str(sum(results[0])/len(results[0])))
print("1053 mean: "+str(sum(results[1])/len(results[1])))
print("19014 mean: "+str(sum(results[2])/len(results[2])))

