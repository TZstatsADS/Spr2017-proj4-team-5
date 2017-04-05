#Set working directory to lib folder of your repository
#setwd("C:/Users/Vikas/OneDrive/Cloud Workspace/Documents/Columbia/Senior/Applied Data Science/Project 4/Spr2017-proj4-team-5/lib")

returnCleanData = function()
{
  paper_df = as.data.frame(matrix(ncol = 6))
  colnames(paper_df) = c("AuthorID", "ClusterID", "CitationID", "AuthorList", "Title", "Journal")
  filenames = list.files("../data/nameset")[-13] #Returns list of all files and removes README file
  for(i in 1:length(filenames))
  {
    filename = paste("../data/nameset/", filenames[i], sep = "")
    file_df = read.delim2(file = filename, header = FALSE, sep = "\n")
    for(j in 1:nrow(file_df))
    {
      temp_row = as.data.frame(matrix(ncol = ncol(paper_df)))
      temp_number = strsplit(as.character(file_df[j,1]), split = " ")[[1]][1]
      cluster_id = strsplit(temp_number, split = "_")[[1]][1]
      citation_id = strsplit(temp_number, split = "_")[[1]][2]
      author_id = paste(i, ".", cluster_id, sep = "")
      temp_split = strsplit(as.character(file_df[j,1]), split = "[<>]")
      temp_split = temp_split[[1]]
      author_string = gsub("[[:digit:]]", "", as.character(temp_split[1]))
      author_string = gsub("[_]", "", as.character(author_string))
      author_string = trimws(author_string)
      author_list = strsplit(author_string, split = ";")
      for(k in 1:length(author_list))
      {
        author_list[[1]][k] = trimws(author_list[k])
      }
      temp_split = temp_split[temp_split != ""]
      journal = temp_split[length(temp_split)]
      title = temp_split[length(temp_split) - 1]
      temp_row[1,1] = author_id
      temp_row[1,2] = cluster_id
      temp_row[1,3] = citation_id
      temp_row[1,4] = author_list
      temp_row[1,5] = title
      temp_row[1,6] = journal
      colnames(temp_row) = c("AuthorID", "ClusterID", "CitationID", "AuthorList", "Title", "Journal")
      paper_df = rbind(paper_df, temp_row, make.row.names = FALSE)
    }
    
  }
  colnames(paper_df) = c("AuthorID", "ClusterID", "CitationID", "AuthorList", "Title", "Journal")
  save(paper_df, file = "../output/CleanData.RData")
  return(paper_df)
}
