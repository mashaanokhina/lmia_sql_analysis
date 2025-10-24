import pandas as pd
import glob
import re

# Get all CSV files
csv_files = glob.glob("D:/Analytics/Glocal/SQL_LMIA_project/csv/*.csv")
csv_files.sort()

dfs = []

# Loop through each file
for i, file in enumerate(csv_files):
    # Extract year and quarter from filename
    match = re.search(r'(\d{4})q(\d)', file, re.IGNORECASE)
    year, quarter = match.groups() if match else (None, None)

    # Read the first file with header, the rest without
    if i == 0:
        df = pd.read_csv(file)
    else:
        df = pd.read_csv(file, header=0)  # Skip headers to avoid duplicates
        df.columns = dfs[0].columns       # Force same column names

    # Add Year and Quarter
    df["Year"] = year
    df["Quarter"] = quarter

    dfs.append(df)

# Merge everything
merged_df = pd.concat(dfs, ignore_index=True)

# Save final merged CSV
merged_df.to_csv("D:/Analytics/Glocal/SQL_LMIA_project/csv/merged_lmia.csv", index=False)

print("✅ Merge complete. Shape:", merged_df.shape)
