# Neo4j Admin Import Commands

This file contains the commands used to import large CSV files into Neo4j and create relationships for the MIMIC-IV knowledge graph.

## Admin import for large files

Run from terminal.

### Example: importing pharmacy file only

```bash
"/Users/fariham/Library/Application Support/neo4j-desktop/Application/Data/dbmss/dbms-6d140be5-81b6-4f36-b044-da9371a8bc2c/bin/neo4j-admin" database import full mimic-iv \
  --nodes=PharmacyOrder="/Users/fariham/Library/Application Support/neo4j-desktop/Application/Data/dbmss/dbms-6d140be5-81b6-4f36-b044-da9371a8bc2c/import/pharmacy.csv" \
  --delimiter="," \
  --array-delimiter=";" \
  --skip-bad-relationships=true \
  --skip-duplicate-nodes=true \
  --ignore-empty-strings=true \
  --verbose \
  --overwrite-destination
```

## Creating relationships between Admission and PharmacyOrder

Run in Neo4j Browser.

```cypher
CREATE INDEX admission_hadm_id IF NOT EXISTS FOR (a:Admission) ON (a.hadm_id);
CREATE INDEX pharmacy_hadm_id IF NOT EXISTS FOR (p:PharmacyOrder) ON (p.hadm_id);

MATCH (a:Admission), (p:PharmacyOrder)
WHERE a.hadm_id = p.hadm_id
MERGE (a)-[:HAS_PHARMACY_ORDER]->(p);
```

## Admin import for multiple large files

Go to the Neo4j import directory first.

```bash
cd "/Users/fariham/Library/Application Support/neo4j-desktop/Application/Data/dbmss/dbms-6d140be5-81b6-4f36-b044-da9371a8bc2c/import"
```

Then run:

```bash
"/Users/fariham/Library/Application Support/neo4j-desktop/Application/Data/dbmss/dbms-6d140be5-81b6-4f36-b044-da9371a8bc2c/bin/neo4j-admin" database import full mimic-build \
  --overwrite-destination=true \
  --verbose \
  --ignore-empty-strings=true \
  --skip-duplicate-nodes=true \
  --bad-tolerance=10000 \
  --nodes=Patient="patients_dedup.csv" \
  --nodes=Admission="admissions_nodes.csv" \
  --nodes=Diagnosis="diagnoses_nodes.csv" \
  --nodes=Drug="drug_nodes.csv" \
  --nodes=LabItem="labitem_nodes.csv" \
  --relationships=HAS_ADMISSION="has_admission.csv" \
  --relationships=HAS_DIAGNOSIS="has_diagnosis.csv" \
  --relationships=HAS_LAB="admission_has_lab_rels.csv" \
  --relationships=ADMINISTERED="administered_from_pharmacy.csv" \
  --relationships=PRESCRIBED="prescribed_from_prescriptions.csv"
```

## Creating HAS_ADMISSION relationship after import

If needed, this relationship can also be created in Neo4j Browser after node import.

```cypher
MATCH (p:Patient)
MATCH (a:Admission)
WHERE p.subject_id = a.subject_id
MERGE (p)-[:HAS_ADMISSION]->(a);
```

## Notes

- These commands were used for large-file import into Neo4j Desktop.
- File names assume the CSV files are already placed in the Neo4j `import` directory.
- The database name used here is `mimic-build`.
- Some relationships were created during admin import, while others were created later in Neo4j using Cypher.
- Paths may need to be changed depending on the local Neo4j installation.
