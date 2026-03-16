**Preprocessing Files**

This folder contains the preprocessing files used to prepare the MIMIC-IV dataset before building the Neo4j knowledge graph.

The raw MIMIC tables are first cleaned and transformed into node and relationship files that can be imported into Neo4j. During this step duplicates are removed, column names are standardized, and identifiers are formatted so they can be used consistently across the graph.

The goal of this step is simply to convert the relational EHR tables into graph-ready files.

**Data Source**

The data comes from the MIMIC-IV dataset. Only the tables needed for the knowledge graph were processed. Examples include:

patients

admissions

diagnoses_icd

procedures_icd

prescriptions

labevents

d_labitems

Output

The preprocessing scripts generate CSV files that represent nodes and relationships in the graph.

Examples of node files:

patients_nodes.csv

admissions_nodes.csv

diagnoses_nodes.csv

procedures_nodes.csv

drugs_nodes.csv

labitems_nodes.csv

Relationship files are created to connect these entities, for example:

patient → admission

admission → diagnosis

admission → procedure

admission → lab event

admission → drug

These files are later imported into Neo4j using bulk import or Cypher queries.
