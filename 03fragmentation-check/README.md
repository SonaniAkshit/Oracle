# Database Fragmentation Check

## Definition
Write minimum three queries to find out fragmentation in the database and derive conclusions for the results.

## Overview
This project demonstrates how to identify different types of fragmentation inside an Oracle database:
1. **Tablespace-level fragmentation** – free space divided into many small extents.
2. **Row-level fragmentation** – chained or migrated rows that slow down queries.
3. **Segment-level fragmentation** – unused space inside allocated segments.

## Sections
1. **Free Space Fragmentation in Tablespaces**
   - Helps detect if free space is split into too many small extents.
   - Conclusion: If total free blocks are large but the largest extent is small, the tablespace is fragmented.

2. **Row Chaining and Migration**
   - Detects tables with chained or migrated rows.
   - Conclusion: High chain count indicates row-level fragmentation, which leads to performance issues.

3. **Segment-Level Fragmentation**
   - Finds unused empty blocks in allocated segments.
   - Conclusion: Many empty blocks show wasted space, requiring segment reorganization.

## Usage
- Clone this repository.  
- Navigate through the documentation for each section.  
- Run the example queries on your Oracle database.  
- Review conclusions to understand fragmentation at different levels.  
