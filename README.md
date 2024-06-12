# Project: Analysis of Election Results Data (2014 & 2019)

## Overview

This project aims to analyze the election results data from 2014 and 2019 to provide insights into voter turnout, winning margins, changes in vote shares, and other electoral patterns. The insights derived from this analysis will help identify trends and areas of interest in the electoral landscape.

## Data Preparation

### Steps Taken

1. Year Column Addition:
   - Added a 'Year' column to both the 2014 and 2019 datasets to distinguish the data from different years.

2. Data Consolidation:
   - Appended the two datasets (2014 and 2019) to create a unified dataset for analysis.

3. Data Normalization:
   - Removed unnecessary symbols and signs from the `pc_name`, `state`, `candidates`, and `party_symbol` columns.
   - Converted text in these columns to proper case to ensure consistency.

4. State Reassignment:
   - Reassigned constituencies from Andhra Pradesh (2014 data) to Telangana as required since Telangana was formed in 2014 and certain constituencies now belong to Telangana.

5. Data Completion:
   - Added missing data for Odisha and Chhattisgarh in the 2014 dataset using information from the ECI portal.

## Data Sources

- Election Results Dataset: Contains data from the years 2014 and 2019, including details about constituencies, candidates, parties, votes, and electors.
- ECI Portal: Used to fill in the missing data for Odisha and Chhattisgarh in the 2014 dataset.

## Methodology

The analysis included the following steps:

1. Data Cleaning: Ensured data consistency and completeness by normalizing text and filling missing values.
2. Exploratory Data Analysis (EDA): Analyzed the dataset to understand voter turnout, vote shares, and other patterns.
3. Deriving Insights: Identified patterns and trends to provide data-driven recommendations.

## Tools Utilized

- MS Excel: Used for initial data cleaning and consolidation.
- SQL: Employed for querying and analyzing the data.

## Conclusion

The analysis of election results data from 2014 and 2019 provides valuable insights into voter behavior, party performance, and electoral trends. These insights can help stakeholders understand the dynamics of electoral processes and make informed decisions for future elections. The use of MS Excel and SQL facilitated comprehensive analysis and effective visualization of the data, making it easier to identify and communicate key findings.
