# Schema Export, Import, and Data Loading into SCOTT Schema

## Definition
Export your schema without procedures, import it into the `SCOTT` schema, and load data from a sequential file into the `SCOTT` schema.

## Overview
This project demonstrates:
1. **Exporting a schema** while excluding procedures.
2. **Importing the exported schema** into the `SCOTT` schema.
3. **Loading external data** from a sequential file and dumping it into the `SCOTT` schema.

## Sections
1. **Schema Export (without procedures)**
   - Use Data Pump Export with the `EXCLUDE` parameter to exclude stored procedures.
   - Example configuration and command usage.

2. **Schema Import (into SCOTT)**
   - Use Data Pump Import with the `REMAP_SCHEMA` parameter to import into the `SCOTT` schema.
   - Example configuration and command usage.

3. **Load Data from Sequential File**
   - Demonstrates how to load external data into `SCOTT` schema using:
     - SQL*Loader
     - External Tables
     - Data Pump with flat files

## Usage
- Clone this repository.  
- Review the provided export, import, and load-data scripts.  
- Run the steps in order:
  1. Export schema excluding procedures.  
  2. Import schema into `SCOTT`.  
  3. Load data from the sequential file into `SCOTT`.  
