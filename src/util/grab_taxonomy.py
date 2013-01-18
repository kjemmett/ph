import pandas as pd
from Bio import Entrez
from Bio import SeqIO
import urllib2
import BeautifulSoup
import os

Entrez.email = "kjemmett@gmail.com"

proj_dir = '/Users/kje/work/proj/phage'

os.chdir(proj_dir)

# load initial annotations
phage_df = pd.read_csv('./data/phage.metadata.csv'
df = pd.read_csv('./data/phage.s277.labels.txt', index_col=0)

# build up dictionary of taxonomy ids
taxid = dict()
for acc_id in df.index:
    print acc_id
    # get ids for failed seqs
    handle = Entrez.esearch(db='nuccore', term=acc_id+'[Accession]')
    record = Entrez.read(handle)

    # cross search ncbi using obtained id
    search_url = 'http://www.ncbi.nlm.nih.gov/taxonomy?LinkName=nuccore_taxonomy&from_uid='+record['IdList'][0]
    request = urllib2.Request(search_url)
    response = urllib2.urlopen(request)
    soup = BeautifulSoup.BeautifulSoup(response)
    for link in soup.findAll('a'):
        if 'Taxonomy/Browser/wwwtax.cgi?id=' in link['href']:
            taxid[id] = link['href'].split('=')[1]
            print taxid[id]
