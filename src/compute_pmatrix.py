import numpy as np
import pandas as pd

def compute_pmatrix(X):
    from scipy.stats import hypergeom
    (N, n) = X.shape
    P = np.zeros((N, N))
    
    for i in range(N):
        a = sum(X[i, :])
        for j in range(i,N):
            b = sum(X[j, :])
            c = np.dot(X[i, :], X[j, :])
            C = min(a, b)
            P(i, j) = sum(hygepdf(range(c, C+1), n, a, b))
            P(j, i) = P(i, j)

    return P


def compute_sigmatrix(P):
    N = P.shape[0]
    S = np.zeros((N, N))

    return S


def parse_betti_info(fid):
    # this function parses betti_info.txt and returns a dict
