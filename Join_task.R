library(readr)
library(vroom)
library(readxl)
library(openxlsx)
library(tidyverse)
library(tidyr)

# File paths.
facility_list_path <- "data/dhis2/Current_Facility_List.csv"
data_elements_path <- "data/dhis2/dataElements.csv"
data_path <- "data/dhis2/Priorty1_2017_2022.xlsx"

# read files
facility_list <- vroom::vroom(facility_list_path)
data_elements <- vroom::vroom(data_elements_path)

# read excel
sheets <- openxlsx::getSheetNames(data_path)
data_frame <- lapply(sheets, openxlsx::read.xlsx, xlsxFile=data_path)
data <- do.call(rbind.data.frame, data_frame)

# Join datasets
master <- dplyr::left_join(data, facility_list, by = join_by(Organisation.unit==facility_uid))
master <- dplyr::left_join(master, data_elements, by = join_by(Data==uid))

# select relevant fields
master_less <- master %>% 
    select(
        -c(
            "Data","Organisation.unit", "stateuid", "lgauid", "warduid",
            "code.x", "dhis_orgunitid", "shortname", 
            "code.y", "valuetype", "dataelementid"
        )
    ) %>%
    rename(period=Period, value=Value, data_element=name)

# write data to file
write_csv(master, "data/output/master_all.csv")
write_csv(master_less, "data/output/master_less.csv")
