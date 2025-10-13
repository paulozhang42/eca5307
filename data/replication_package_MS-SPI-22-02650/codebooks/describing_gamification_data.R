# R code for making codebooks
# 
library(pacman)
p_load(codebook, labelled, purrr, tidyverse, glue, dataMaid)

# taking the sheet with var descriptions from google drive (or locally - later)
p_load(googlesheets4)
gs4_auth()
sheet_url <- "https://docs.google.com/spreadsheets/d/1z0MoktR3kSl79BC9W0LFDwQdRfah7XvKuE3kVs_qeF8/"

# Reading the first sheet
description_data <- read_sheet(sheet_url)

# attempt to build codebooks automatically
description_data %>% group_by(filename) %>% group_split()->grouped_tibbles

# we write file descripitons in csv separately for each file
for (tibble in grouped_tibbles) {
  # Perform operations on each tibble
  fn<-tibble %>% dplyr::slice(1) %>% pull(filename)
  print(fn)
  tibble %>% select(variable_name, description) %>% write_csv(file=glue('codebook_{fn}'))
}
# change it to the right path
path = '/Users/chapkovski/Documents/gamification_investor_behavior/raw_data_dump/'

# we have to generate files one by one not in the loop, because (a) memory limits in TEX, and (b) some files are a bit different (no column names etc)
 
# [1] "post_experimental_2023-04-13.csv"                                                 
fn<-"post_experimental_2023-04-13.csv"                                                 
df<-read_csv(glue('{path}{fn}'), col_names=col_names)
varinfo<- description_data %>% filter(filename==fn)
var_labels <- setNames(varinfo$description, varinfo$variable_name)
makeCodebook(df, glue('{fn}'))

# [1] "post_experimental_2023-04-13_custom.csv"                                             
fn<-"post_experimental_2023-04-13_custom.csv"                                           

blocked_fn_cols<-c("Question Label", "Answer", "Participant Code", "Session Code", "Session Display Name", "Player Age", "Player Gender", "Player Education")

df<-read_csv(glue('{path}{fn}'), col_names=blocked_fn_cols)

varinfo<- description_data %>% filter(filename==fn)
var_labels <- setNames(varinfo$description, varinfo$variable_name)
makeCodebook(df, glue('{fn}'))



# [1] "pretrade_2023-04-13.csv"                                                           
# 
fn<-"pretrade_2023-04-13.csv"                                               
df<-read_csv(glue('{path}{fn}'), col_names=col_names)
varinfo<- description_data %>% filter(filename==fn)
var_labels <- setNames(varinfo$description, varinfo$variable_name)
makeCodebook(df, glue('{fn}'))  


# [1] "prolific_export_demographic_uk.csv"                                                  
fn<-"prolific_export_demographic_uk.csv"   
df<-read_csv(glue('{path}{fn}'), col_names=col_names)
varinfo<- description_data %>% filter(filename==fn)
var_labels <- setNames(varinfo$description, varinfo$variable_name)
makeCodebook(df, glue('{fn}')) 


# [1] "prolific_export_demographic_us.csv"                                                  
fn<-"prolific_export_demographic_us.csv"    
df<-read_csv(glue('{path}{fn}'), col_names=col_names)
varinfo<- description_data %>% filter(filename==fn)
var_labels <- setNames(varinfo$description, varinfo$variable_name)
makeCodebook(df, glue('{fn}')) 


# [1] "trader_wrapper_2023-04-13.csv"
fn<-"trader_wrapper_2023-04-13.csv"     
df<-read_csv(glue('{path}{fn}'), col_names=col_names) %>% select(-body, -owner, -participant_code)

varinfo<- description_data %>% filter(filename==fn)
var_labels <- setNames(varinfo$description, varinfo$variable_name)
makeCodebook(df, glue('{fn}'))   




# 
# [1] "trader_wrapper_2023-04-13_simple.csv" 
 
fn<-"trader_wrapper_2023-04-13_simple.csv"  
df<-read_csv(glue('{path}{fn}'), col_names=col_names) %>% select(everything(), -participant.label, participant.label, -participant.code, participant.code)

varinfo<- description_data %>% filter(filename==fn)
var_labels <- setNames(varinfo$description, varinfo$variable_name)
makeCodebook(df, glue('{fn}'), reportTitle = fn, replace=T) 




# NOW DATA_PROLIFIC FILES
prolific_fn<-'/Users/chapkovski/Documents/gamification_investor_behavior/codebooks/codebook_data_prolific.csv'
# Reading the first sheet
description_data <- read_csv(prolific_fn)

# attempt to build codebooks automatically
description_data %>% group_by(filename) %>% group_split()->grouped_tibbles

# we write file descripitons in csv separately for each file
for (tibble in grouped_tibbles) {
  # Perform operations on each tibble
  fn<-tibble %>% dplyr::slice(1) %>% pull(filename)
  print(fn)
  tibble %>% select(variable_name, description) %>% write_csv(file=glue('codebook_{fn}'))
}
# change it to the right path
path = '/Users/chapkovski/Documents/gamification_investor_behavior/data_prolific/'

 
produce_codebook <- function(fn){
  unnessary_columns = c('...1', 'participant.label', 'participant.code', 'body')
  df<-read_csv(glue('{path}{fn}'), col_names=T) %>%  select(-any_of(unnessary_columns))
  varinfo<- description_data %>% filter(filename==fn)%>% 
    filter(variable_name%in%(df %>% names))
  var_labels <- setNames(varinfo$description, varinfo$variable_name)
  df<-df %>% set_variable_labels(.labels=var_labels)
  makeCodebook(df, file = glue('{fn}'), reportTitle = fn, replace=T, openResult=F) 
  
}

for (tibble in grouped_tibbles) {
  # Perform operations on each tibble
  fn<-tibble %>% dplyr::slice(1) %>% pull(filename)
  print(fn)
  produce_codebook(fn)
}


# Now let's do the same with data_processed:
# 
fn<-'/Users/chapkovski/Documents/gamification_investor_behavior/codebooks/codebook_data_processed.csv'

description_data <- read_csv(fn)

# attempt to build codebooks automatically
description_data %>% group_by(filename) %>% group_split()->grouped_tibbles

# we write file descripitons in csv separately for each file
for (tibble in grouped_tibbles) {
  # Perform operations on each tibble
  fn<-tibble %>% dplyr::slice(1) %>% pull(filename)
  print(fn)
  tibble %>% select(variable_name, description) %>% write_csv(file=glue('codebook_{fn}'))
}
path<-'/Users/chapkovski/Documents/gamification_investor_behavior/data_processed/'
df<-read_csv(glue('{path}jackknife_finquiz.csv'))
df %>% names
produce_codebook('jackknife_finquiz.csv')
for (tibble in grouped_tibbles) {
  # Perform operations on each tibble
  fn<-tibble %>% dplyr::slice(1) %>% pull(filename)
  print(fn)
  produce_codebook(fn)
}
