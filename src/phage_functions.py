import numpy as np
import pandas as pd


def compute_pmatrix(X):
    """Computes the p-matrix of input binary matrix `X` using 
    hypergeometric pmf. See Lima-Mendez 2008.
    NOTE: Much slower than MATLAB. Investigate"""
    from scipy.stats import hypergeom
    (N, n) = X.shape
    P = np.zeros((N, N))
    
    for i in range(N):
        print "%d / %d" % (i + 1, N)
        a = sum(X[i, :])
        for j in range(i + 1, N):
            b = sum(X[j, :])
            c = np.dot(X[i, :], X[j, :])
            C = min(a, b)
            if C is not 0:
                P[i, j] = sum(hypergeom.pmf(range(c, C + 1), n, a, b))
            else:
                # C==0 will yield a nan in hypergeom formula
                P[i, j] = 1
    P = P + P.T
    return P


def compute_sigmatrix(P):
    """Compute significance matrix as log transform of input 
    p-matrix. Add noise proportional to magnitude of smallest element
    NOTE: Unimplemented"""
    N = P.shape[0]
    S = np.zeros((N, N))

    return S


def build_dendrogram(D):
    """Given an input distance matrix, generate the 
    hierarchical clustering"""
    from scipy.spatial.distance import squareform
    from scipy.cluster.hierarchy import linkage

    y = squareform(D)
    Z = linkage(y)

    return Z


def find_cluster_members(Z, filt):
    """Returns a list of indices in each flat cluster of input
    linkage `Z` at filtration `filt`""" 
    from scipy.cluster.hierarchy import fcluster

    membership = fcluster(Z, filt, criterion='distance')

    return membership


def parse_barcode_txt(fid):
    """Parse the output of an unannotated betti_info.txt
    generated during a MATLAB run of javaplex. Return a dict
    containing the barcode information
    NOTE: For some reason, do not need to reindex by 1"""
    import re

    # compile regexp to match generator elements
    p1 = re.compile('\[\S+\]')

    # compile regexp to match indices within cycles
    p2 = re.compile('\d+')

    # parse barcode output
    f = open(fid, 'r')
    barcodes = []
    for line in f:
        if 'Dimension' in line:
            # add new dimension
            dim = int(line.strip().split(':')[1])
            barcodes.append({'dim' : dim, 'barcodes' : []})
        else:
            # parse barcode line
            (range_str, gen_str) = line.split(': ')
            start = float(range_str.split(', ')[0][1:])
            stop = float(range_str.split(', ')[1][0:-1])
            generators = []
            for elem_str in gen_str.split(' + '):
                # keep track of p/m sign
                if '-' in elem_str:
                    sign = '-'
                else:
                    sign = '+'
                # map indices of generator vertices
                elem = map(lambda x: int(x), p2.findall(elem_str))
                generators.append([sign, elem])
            bar = {'start' : start, 'stop' : stop, 'generators' : generators}
            barcodes[dim]['barcodes'].append(bar)

    return barcodes


def parse_component_vertices_txt(fid):
    """Parse the output of clustering file generated
    using verticesInEachComponent.m. Input file location,
    output is a dictionary containing cluster indices.
    NOTE: Input file is 1-based, so we reindex down to 0
    when bringing into python
    NOTE: This is redundant, we can do this inside python
    using find_cluster_members"""

    f = open(fid, 'r')

    clust_dict = {}
    clust_dict['data'] = f.readline()
    clust_dict['filtration'] = f.readlines()
    clust_dict['clusters'] = []
    for line in f:
        clust = map(lambda x: int(x) - 1, line.split(','))
        clust_dict['clusters'].append(clust)

    return clust_dict


def annotate_barcodes(barcodes, mddf, savefile):
    """Take input list of barcodes and a metadata dataframe
    and annotate the elements of the generators. output as
    textfile"""

    f = open(savefile, 'w')

    max_dim = len(barcodes)
    for dim in range(max_dim):
        for barcode in barcodes[dim]['barcodes']:
            start = barcode['start']
            stop = barcode['stop']
            generators = barcode['generators']
            generator_string = ' '.join(
                    [str(a) for b in generators for a in b])
            range_string = ''.join(['[', str(start), ', ', str(stop), '): '])
            header_string = ''.join([range_string, generator_string,'\n'])
            f.write(header_string)
            g_list = [g[1] for g in generators]
            g_uniq = set([item for sublist in g_list for item in sublist])
            for g in g_uniq:
                virus_id = mddf.ix[g]['ncbi_id']
                virus_name = mddf.ix[g]['virusname']
                virus_type = mddf.ix[g]['virustype']
                gen_str = '\t[%d] %s: %s (%s)\n' % (
                        g, virus_id, virus_name, virus_type)
                f.write(gen_str)
    f.close()
