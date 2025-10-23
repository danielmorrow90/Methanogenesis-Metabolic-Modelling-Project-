---
  title: "Example analysis"
output:
  html_document:
  toc: yes
df_print: paged
html_notebook:
  theme: spacelab
toc: yes
toc_float: yes
---
  This notebook provides example code and suggestions for analyzing microbiome sequence data. You can perform similar analysis in Python using the QIIME Artifact API, but I am much more comfortable and familiar with R for any kind of data analysis and plotting. This is just a personal preference, as both programming languages and external packages can perform the same tasks. I use R because I find data manipulation with the dplyr package and plotting with the ggplot2 package to be much more intuitive than doing the same thing in Python.

# Set up packages
```{r message=FALSE, warning=FALSE}
# required
library(openxlsx)
library(qiime2R)
library(phyloseq)
library(tidyverse)
library(readxl)
# optional
library(MetBrewer) # fun color palettes
```


# Read in data
I read in the QIIME artifacts as a phyloseq object. Phyloseq is an R package that has many convenient functions built in for manipulating and analyzing microbiome data. We will use the qiime2R package to import the QIIME data directly into a phyloseq object. 
```{r}

getwd() 

ps <- qiime2R::qza_to_phyloseq(
  features="C:/Users/danie/Downloads/model_seq/table_dada2_5.16.qza",
  tree="C:/Users/danie/Downloads/model_seq/rooted_tree_5.16.qza",
  taxonomy="C:/Users/danie/Downloads/model_seq/taxonomy_5.16.qza"
)

#metadata <- read_excel("C:/Users/danie/OneDrive/Desktop/GAME Sequencing/GAME_Metadata.xlsx")
# This command imports the metadata file, which is an excel file that specifies which sample corresponds to which day. 

#functionality <- read_excel("C:/Users/danie/OneDrive/Desktop/GAME Sequencing/Microbe_Functionality.xlsx")


#This imports the functionality table I created. This table contains metabolic information from the Bergley microbe manual. This table tells if each taxonomic group of archeae present is an obligate hydrogenotrophic methanogen, obligate acetoclastic methanogen, is both acetoclastic and hydrogenotrophic, or is hydrogenotrophic and also can consume formate. 

#acetogens <- read_excel("C:/Users/danie/OneDrive/Desktop/GAME Sequencing/acetogens.xlsx")
#head(metadata)

#acetogens2 <- read_excel("C:/Users/danie/OneDrive/Desktop/GAME Sequencing/acetogens2.xlsx")

# remove Mitochondria and Chloroplasts
ps_filt <- phyloseq::subset_taxa(ps, ! Family %in% c("Mitochondria", "Chloroplast"))

# remove unclassified sequences
ps_filt <- phyloseq::subset_taxa(ps, Kingdom != "Unassigned")

# relative abundance
ps_rel <- phyloseq::transform_sample_counts(ps_filt, function(x) x*100/sum(x))

# Basic filtering and parsing
#I will do a bit of manipulation using phyloseq functions, then we will use the suite of tidyverse packages to do more data manipulation. Let's start with getting relative abundance data.

taxonomy <- as.data.frame(as.matrix(ps_rel@tax_table)) %>% 
  rownames_to_column(var = "seq") # change the ASV ID to a column, not a row name



This chunk saves the taxonomy, metadata, and count tables as data frames. In these tables, each row is a unique ASV. The pipe operator %>% comes from the dplyr packages. 



taxonomy <- as.data.frame(as.matrix(ps_rel@tax_table)) %>% 
  rownames_to_column(var = "seq") # change the ASV ID to a column, not a row name

head(taxonomy)

table_rel <- as.data.frame(as.matrix(ps_rel@otu_table)) %>% 
  rownames_to_column(var = "seq")

head(table_rel)
write.xlsx(table_rel, "C:/Users/danie/Downloads/GAME Sequencing/ASV_abundance_5.16.xlsx")

head(table1)
write.xlsx(table_rel, "C:/Users/danie/Downloads/GAME Sequencing/ASV_sample_abundance_5.16.xlsx")
write.xlsx(table1, "C:/Users/danie/Downloads/GAME Sequencing/Shortform_Abundance_Table_5.16.xlsx")




This chunk manipulates the relative abundance table and combines it with the taxonomy table. We used the pivot_longer function to make this into a "long" dataframe, which is the desired format for using ggplot2. Read a bit more about long format here: http://eriqande.github.io/rep-res-web/lectures/ggplot_2_reshape_facets_stats.html. The long format will seem very chaotic, but I promise it will be extremely useful for plotting and data analysis tasks going forward.



table_rel_long <- table_rel %>% 
  pivot_longer(cols = !seq, names_to = "sample", values_to = "rel_ab") %>% # make a "long" dataframe
  left_join(taxonomy, join_by(seq)) %>% # join taxonomy by the sequence ID
  left_join(metadata, join_by(sample))


head(table_rel_long)


#This chunk isolates all strands from sample 1 and organizes them according to abundance

table1 <- table_rel_long %>%
  filter(sample=="1AB") %>%
  arrange(desc(rel_ab))





# Subsetting and plotting
The dplyr package has a lot of functions that can be used to filter and rearrange the data to make it easier to work with. Here some of these functions are applied to visualize how the abundance of each taxonomic unit changes for each samples. For the sake having a more concise table, we also visualize the data on only the Genus level. 

It is our goal to track how certain functional groups, like acetoclastic methanogens, change in prevalence over time. We need to identify a taxonomic classification level that is both manageable and useful for tracking these different traits. Unfortunately, many traits diverge for our samples at the sub-genus or even sub-species level. For example, the genus methanobacterium is known to contain both acetate and hydrogen consuming archeaea, (it is unclear to me if they contain species that are able to perform both, or if the genus contains species that are only able to perform each one, or if this a relevant distinction to make), and no information is available at the sub species level. 

For this analysis I have chosen to track the changes of archeae at the Genus level. Of the functionll traits that can be distinguished based on available data, they all diverge at at least the genus level. There is also a relatively low diversity of archaea Genuss in this sample. 




# This section creates a plot of each DNA strand present in each sample in order of abundance. It uses the factor() function within the arrange() function to prevent intermingling between the different samples after sorting by abundance. (I learned from Chat)

Table_abundance <- table_rel_long %>%
  arrange(factor(sample, levels = unique(sample)), desc(rel_ab)) %>%
  filter(rel_ab != 0)

#Creating a table that shows every genus present at each sample in order of relative abundacnce
Genus_table <- Table_abundance %>%
  group_by(Genus,sample,days) %>%
  summarise(sum_ab = sum(rel_ab)) %>%
  arrange(factor(sample,levels=unique(sample)),desc(sum_ab))

#Doing the same for only Archaea. 
Genus_table_Archaea <- table_rel_long %>%
  filter(Kingdom=="Archaea") %>%
  group_by(Genus,sample,days) %>%
  summarise(sum_ab = sum(rel_ab)) %>%
  arrange(factor(sample,levels=unique(sample)),desc(sum_ab))



#Creating an abundance chart that tracks only archaea 
Archaea_abundance <- Table_abundance %>%
  filter(Kingdom=="Archaea")

#Exporting the important tables to excel 

write.xlsx(Table_abundance, "output.xlsx")




```



# Tracking the most prevalent methanogen, archaea 


Graph <- Genus_table_Archaea %>% # perform some functions on table_long
 filter(Genus == "Methanobacterium") %>%
 ungroup() %>%
 # pipe the data into the next line
 ggplot(aes(x = days, y = sum_ab)) +  # the period denotes that we want to use the data we piped in
 geom_line() +
 labs(title = "Methanobacterium Genus", x= "Days", y="Relative Abundance %")
print(Graph)


# Create stacked bar graph of just archaea, then genus of everything
# Methanogens on the bottom

# Also, filter out 7ab from graphing 
plot in terms of sample number, not day

Then, create plot 


```{r}

# Here, ggplot is used to 

ArchaeaPlot <- Genus_table_Archaea %>%
  filter(sample!="7AB") %>%
  ggplot(aes(fill = Genus, x = sample, y = sum_ab)) +
  geom_bar(position = "stack", stat = "identity") +
  labs(title = "Archaea Genus Abundance", x="Sample", y="Relative Abundance")

print(ArchaeaPlot)

ArchaeaPlotDays <- Genus_table_Archaea %>%
  filter(sample!="7AB") %>%
  ggplot(aes(fill = Genus, x = days, y = sum_ab)) +
  geom_bar(position = "stack", stat = "identity") +
  labs(title = "Archaea Genus Abundance", x="Days", y="Relative Abundance")

print(ArchaeaPlotDays)

# Now doing the same but for All present Genuses, including bacteria

GenusPlot <- table_rel_long %>%
  filter(sample!="7AB") %>%
  arrange(Kingdom) %>%   # Places Archaea at the bottom of the stack in the graph to make viewing them easier
  group_by(Genus,sample,days) %>%
  summarise(sum_ab = sum(rel_ab)) %>%
  ggplot(aes(fill = Genus, x = sample, y = sum_ab)) +
  geom_bar(position = "stack", stat = "identity") +
  labs(title = "Archaea Genus Abundance", x="Sample", y="Relative Abundance")

print(GenusPlot)

Phylumplotsample <- table_rel_long %>%
  filter(sample!="7AB") %>%
  arrange(Kingdom) %>%   # Places Archaea at the bottom of the stack in the graph to make viewing them easier
  group_by(Phylum,sample,days) %>%
  summarise(sum_ab=sum(rel_ab))%>%
  ggplot(aes(fill = Phylum, x = sample, y = sum_ab)) +
  geom_bar(position = "stack", stat = "identity") +
  labs(title = "Phylum Abundance", x="Days", y="Relative Abundance")

Phylumplotdays <- table_rel_long %>%
  filter(sample!="7AB") %>%
  arrange(Kingdom) %>%   # Places Archaea at the bottom of the stack in the graph to make viewing them easier
  group_by(Phylum,sample,days) %>%
  summarise(sum_ab=sum(rel_ab))%>%
  ggplot(aes(fill = Phylum, x = days, y = sum_ab)) +
  geom_bar(position = "stack", stat = "identity") +
  labs(title = "Phylum Abundance", x="Days", y="Relative Abundance")


print(Phylumplotsample)
print(Phylumplotdays)
head(Phylumplotsample)
head(Phylumplotdays)

```

Here I will identify ASVs that are not defined at the Genus level. Many of the ASVs crouding the table are undefined. For the sake of simplification, we will group them together into one big"unkwon" grouping. For this to be done they first need to be identified. 

I do not know what the correct convention should be, but here when I say 'unspecified' at the genus level I am refering to two types of ASVs: Those for which the data reports an NA value for the Genus column, and those which have a genus that is only "midas_" with some identifying number. This second type is functionally unidentified because to my knowledge there is no information available about metabolism for genera such as these that don't have formal names. R automatically summarizes the NA samples together with the group_by() function. However, the midas_## types are not, so that must be done manually.


This code rearranges the abundacne tables to group all of the genera that fit these two criteria together with the intention of making the graph less cluttered. 

The Archaea Genus Abundance table shows us that there are no midas_## type unkowns that are archaea, so we can assume all of the midas_## type unknowns we summarize together are all not methanogens. In the future I will ammend this code to reference a a metadata file that contains the functional information for each taxa. 
```{r}
uk <- "midas_" #uk is defined as a string value equal to "midas_" a set of characters that only our unknowns will have. 

table_u_m <- table_rel_long %>%
  mutate(Genus = ifelse(grepl(uk, Genus), "Unknown, non-methanogen", Genus)) %>% # Checks each Genus to see if the name contains the string "midas_", and if so, replaces it with "UK"
  mutate(Genus = ifelse(is.na(Genus) & Kingdom == "Archaea", "Unknown, methanogen", Genus)) %>% #Inserts the name "Unknown, methanogen into the Genus column for all samples with have an NA in the Genus column and are archeaea. For our data so far, all of the archaea are methanogens, so we can make this assumption. 
  mutate(Genus = ifelse(is.na(Genus) & Kingdom == "Bacteria", "Unknown, non-methanogen", Genus)) # Similarly renames all the Bacteria that are NA for Genus as "unknown non methanogen


head(table_u)

```
Here I am recreating the charts from above with the new chart I just created that accounts for the unknowns.
```{r}

GenusPlot_U <- table_u %>%
  filter(sample!="7AB") %>%
  arrange(Kingdom) %>%   # Places Archaea at the bottom of the stack in the graph to make viewing them easier
  group_by(Genus,sample,days) %>%
  summarise(sum_ab = sum(rel_ab)) %>%
  ggplot(aes(fill = Genus, x = sample, y = sum_ab)) +
  geom_bar(position = "stack", stat = "identity") +
  labs(title = "Archaea Genus Abundance", x="Sample", y="Relative Abundance")

print(GenusPlot_U)
``` 



Here I will perform the same analysis but for functional group instead of taxonomic group. First, the functionality table is filtered to only include the Genus column. This makes the combined table less clutered, and this can be easily changed for the taxonomic level of interest. 

The functionality table is then combined with the abundance table, and all of the same analysis are applied. The functional groups are then graphed for abundance over time. 

```{r}

#First we need to change the functionality sheet so that it only contains the Genus column. This allows it to be joined to the Archaea Genus table

functio <- functionality %>%  
  select(-c("Kingdom", "Phylum", "Class", "Order", "Family", "Species")) %>%
  filter(!is.na(Genus)) # Removes rows that have nothing defined for Genus 

AGFw <- functio %>%
  mutate(Metabolism = "")  # Create an empty Metabolism column

# Loop through each row to find columns containing 'Y'
for (i in 1:nrow(AGFw)) {
  # Find column names that contain 'Y' for the current row
  columns_with_Y <- colnames(AGFw)[which(grepl("Y", AGFw[i, ]))]
  # Join column names into a single string and assign to Metabolism
  AGFw$Metabolism[i] <- paste(columns_with_Y, collapse = ", ")
}


#This new Genus/functionality table is joined to relative abundance table
func <- table_rel_long %>%
  left_join(AGFw, join_by(Genus))


#Grouping and filtering the table to show the change in genus abundance over time.
FunctionalityTable_Genus <- func %>%
  group_by(Genus, rel_ab, sample, days, Metabolism, seq) %>%
  summarise(sum_ab = sum(rel_ab), .groups = "drop") %>%
  arrange(factor(sample,levels=unique(sample)),desc(sum_ab)) %>%
  filter(!is.na(Metabolism)) %>% #Removing Genera with unknown metabolisms
  select(-c(rel_ab))

write.csv(FunctionalityTable_Genus, file = "C:/Users/danie/OneDrive/Desktop/GAME Sequencing/FunctionalityTable_Genus.csv", row.names = FALSE)


FunctionPlotDays <- FunctionalityTable_Genus %>%
  filter(sample!="7AB") %>%
  ggplot(aes(fill = Metabolism, x = days, y = sum_ab)) +
  geom_bar(position = "stack", stat = "identity") +
  labs(title = "Metabolic Group Relative Abundance", x="Days", y="Relative Abundance")

FunctionPlotSample <- FunctionalityTable_Genus %>%
  filter(sample!="7AB") %>%
  ggplot(aes(fill = Metabolism, x = sample, y = sum_ab)) +
  geom_bar(position = "stack", stat = "identity") +
  labs(title = "Metabolic Group Relative Abundance", x="Sample", y="Relative Abundance")

print(FunctionPlotDays)
print(FunctionPlotSample)

``` 

