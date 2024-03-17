##ISIC4 ACTIVITIES ALPHABETICAL INDEX FROM ISIC3

#Set working directory
setwd("C:\\Users\\Habibur.Khan\\OneDrive - United Nations\\Telecommute\\Classification\\ISIC3-ISIC4")
library(dplyr)
library(tidyverse)

#Read ISIC3 Activities
ISIC3_act = read.csv("ISIC3_desc.txt", sep = "\t", colClasses = c("character"))
colnames(ISIC3_act) = c('ISIC3code', 'ISIC3_Activities')

#Read file with extended explanation for ISIC4
ISIC4 = read.csv("ISIC4_FullDesc.csv", colClasses = c("character"))

#Add leading zeroes to code with length 3 (CSV problem) and change column names
#ISIC4$Code = sprintf("%04d", ISIC4$Code)
colnames(ISIC4) = c("ISIC4code", "Detail_ISIC4", "ExtendedDetail_ISIC4", "Exclusion_ISIC4")

#Read ISIC 4 to 3.1 and 3.1 to 3 correspondence
ISIC40_31 = read.csv("ISIC4_to_3_1.txt", colClasses = c("character"))
ISIC31_30 = read.csv("ISIC3_1_to_3.txt", colClasses = c("character"))

#Rename columns in ISIC31_30 and ISIC40_31 to make them consistent
colnames(ISIC31_30) = c("ISIC31code", "partialISIC31", "ISIC3code", "partialISIC3", "Detail_ISIC31_to3")
colnames(ISIC40_31)[colnames(ISIC40_31) == "Detail"] = "Detail_ISIC4_to31"

#Merge ISIC4 with ISIC40_31
df = merge(ISIC4, ISIC40_31, by = "ISIC4code", all.x = TRUE)

#Merge df with ISIC31_30
df = merge(df, ISIC31_30, by = "ISIC31code", all.x = TRUE)

#Merge df with ISIC3_act
df = merge(df, ISIC3_act, by = "ISIC3code", all.x = TRUE)

#Reorder columns
df = df %>% select("ISIC3_Activities", "Detail_ISIC4", "ExtendedDetail_ISIC4",
                   "Exclusion_ISIC4", "ISIC4code", "ISIC31code", "ISIC3code",
                   "partialISIC4", "partialISIC31.x", "partialISIC31.y",
                   "partialISIC3", "Detail_ISIC4_to31", "Detail_ISIC31_to3")

#Keep only ISIC4code, Detail_ISIC4, ExtendedDetail_ISIC4 and ISIC3_Activities, remove duplicates
df_final = df %>% select("ISIC3_Activities", "Detail_ISIC4", "ExtendedDetail_ISIC4", "ISIC4code")

df_final = df_final[!duplicated(df_final), ]

#Remove new lines ("\n") and "*"
df_final$ExtendedDetail_ISIC4 = gsub("\n", "", df_final$ExtendedDetail_ISIC4)
df_final$ExtendedDetail_ISIC4 = gsub("\\*", ",", df_final$ExtendedDetail_ISIC4)

#Separate Activities that appear only once. These have 1-to-1 correspondence
Freq_Activities = as.data.frame(table(df_final$ISIC3_Activities))
colnames(Freq_Activities) = c("Activity", "Associated_#_of_codes")
Freq_Activities = Freq_Activities[order(-Freq_Activities$`Associated_#_of_codes`), ]

write.table(Freq_Activities, "Frequency of ISIC3 activities mapped to ISIC4.txt", sep = "\t", quote = TRUE, row.names = FALSE)

Act_once = Freq_Activities[Freq_Activities$`Associated_#_of_codes` == 1, ]$Activity

df_one2one = df_final[df_final$ISIC3_Activities %in% Act_once, ]
df_final = setdiff(df_final, df_one2one)

write.table(df_one2one, "ISIC3 Activities associated with only one ISIC4 code.txt",
            sep = "\t", row.names = FALSE, quote = TRUE)

##FIND MATCHED WORDS BETWEEN ISIC3 Activity & ISIC4 DESCRIPTION & EXTENDED DESCRIPTION
#Create columns to store words matched and their count
df_final$WordMatch_withDesc = ""
df_final$WordMatch_withFullDesc = ""
df_final$count_WordMatch_withDesc = ""
df_final$count_WordMatch_withFullDesc = ""
#to store negations such as "lorem ipsum EXEPT this or that"
df_final$negative_withDesc = 0
df_final$negative_withFullDesc = 0

excld = c("and", "or", "the", "in", "of", "for", "from", "ie", "eg", "on", "to", "a", 
          "with", "like", "growing", "farming", "crop", "crops", "service", "services",
          "manufacture", "manufacturing")
signs = "[,;(){}.:-]"

for (i in  1:nrow(df_final))
{
  #Remove special characters like () or ;
  act = str_remove_all(df_final$ISIC3_Activities[i], signs)
  act = unlist(strsplit(act, " "))
  act = tolower(act)
  #Remove words not useful for matching like "and", "on", "services"
  act = setdiff(act, excld)
  
  des = str_remove_all(df_final$Detail_ISIC4[i], signs)
  des = unlist(strsplit(des, " "))
  des = tolower(des)
  des = setdiff(des, excld)
  
  fdes = gsub("This class includes", "", df_final$ExtendedDetail_ISIC4[i]) #to remove this string preceeding all descriptions
  fdes = str_remove_all(fdes, signs)
  fdes = unlist(strsplit(fdes, " "))
  fdes = tolower(fdes)
  fdes = setdiff(fdes, excld)
  
  common = intersect(act, des)
  common_words = paste(common, collapse = ", ")
  ncommon = length(common)
  df_final$WordMatch_withDesc[i] = common_words
  df_final$count_WordMatch_withDesc[i] = ncommon
  
  fcommon = intersect(act, fdes)
  fcommon_words = paste(fcommon, collapse = ", ")
  nfcommon = length(fcommon)
  df_final$WordMatch_withFullDesc[i] = fcommon_words
  df_final$count_WordMatch_withFullDesc[i] = nfcommon
  
  act2 = c(paste("except", act, sep = " "), paste("not", act, sep = " "))
  act2 = paste(act2,collapse="|")
  
  des2 = c(paste("except", des, sep = " "), paste("not", des, sep = " "))
  des2 = paste(des2,collapse="|")
  
  fdes2 = c(paste("except", fdes, sep = " "), paste("not", fdes, sep = " "))
  fdes2 = paste(fdes2,collapse="|")
  
  if (grepl(act2, df_final$Detail_ISIC4[i]) == TRUE | grepl(des2, df_final$ISIC3_Activities[i]) == TRUE)
  {
    df_final$negative_withDesc[i] = -1
  } else {}
  
  if (grepl(act2, df_final$ExtendedDetail_ISIC4[i]) == TRUE | grepl(fdes2, df_final$ISIC3_Activities[i]) == TRUE)
  {
    df_final$negative_withFullDesc[i] = -1
  } else {}
  
}

##CALCULATE LEVINSHTEIN DISTANCE
df_final$Proximity = 0

for (i in 1:nrow(df_final))
{
  act = str_remove_all(df_final$ISIC3_Activities[i], signs)
  act = unlist(strsplit(act, " "))
  act = tolower(act)
  act = setdiff(act, excld)
  
  fdes = gsub("This class includes", "", df_final$ExtendedDetail_ISIC4[i]) #to remove this string preceeding all descriptions
  fdes = str_remove_all(fdes, signs)
  fdes = unlist(strsplit(fdes, " "))
  fdes = tolower(fdes)
  fdes = setdiff(fdes, excld)
  
  Dist = adist(act, fdes, partial = TRUE)
  Ind_Proximity = sum(nchar(act))/sum(rowMeans(Dist))
  df_final$Proximity[i] = Ind_Proximity
}

#Order by Activity and Proximity
df_final = df_final[order(df_final$ISIC3_Activities, -df_final$Proximity), ]

write.table(df_final, "ISIC4_activitis_20200226.txt", sep = "\t", quote = TRUE, row.names = FALSE)
write.csv(df_final, "ISIC4_activitis_20200226.csv", row.names = FALSE, quote = TRUE)

write.table(df, "ISIC4_to_31_to_3.txt", sep = "\t", quote = TRUE, row.names = FALSE)

#rm(list = ls())