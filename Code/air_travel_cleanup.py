import os
import pandas as pd

verbose = True

dir_path = "../Data/Raw/Airline/" # This directory no longer exists
out_path = "../Data/Raw/Airline"

raw_files = [fname for fname in os.listdir(dir_path) if not os.path.isdir(dir_path + fname)]
if verbose:
    print("Found {} raw data files.".format(len(raw_files)))

for file in raw_files:
    
    if verbose:
        print("Processing file {}...".format(file))
    
    df = pd.read_csv(dir_path + file).drop(columns=["Unnamed: 3"])
    df = df.groupby(['ORIGIN_STATE_NM', 'DEST_STATE_NM']).sum()
    df.to_csv(out_path + file)

if verbose:
    print("Done processing all files.")