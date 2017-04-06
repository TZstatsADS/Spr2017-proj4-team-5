
# Project4: Who Is Who -- Entity Resolution

### Output folder

The output directory contains analysis output, processed datasets, logs, or other processed things.

CleanData.RData contains 6 columns: (1) AuthorID which is a unique author ID (2) Cluster ID, not super useful (3) Citation ID, which indicates each individual article for an authory (4) AuthorList which just has the list of authors on the paper (5) Title, which is the article title and (6) Journal, which indicates where the article was published.

TZCleanData.RData contains a list, one element for each of the author files provided. Each element is a list containing five things: (1) ClusterID (unique Author ID, but only unique within each file), (2) Citation ID (a doc ID for each paper an author has written. Unique only when considered in combination with author). (3) Author List, (4) Title, (5) Journal

