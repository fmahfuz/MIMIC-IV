
// ======================================================
// MIMIC-IV Clinical Knowledge Graph Exploration Queries
// Author: Fariha Mahfuz
// Description:
// These queries are used to explore and validate the
// Neo4j clinical knowledge graph built from MIMIC-IV.
//
// Graph Entities
// - Patient
// - Admission
// - Diagnosis
// - Procedure
// - LabItem
// - Drug
//
// Key Relationships
// - HAS_ADMISSION
// - HAS_DIAGNOSIS
// - HAS_PROCEDURE
// - HAS_LAB_EVENT
// - PRESCRIBED / ADMINISTERED
//
// Tested with Neo4j 5.x
// ======================================================



// ======================================================
// 1. BASIC NODE INSPECTION
// ======================================================

// Preview patient nodes
MATCH (p:Patient)
RETURN p
LIMIT 25;


// Preview admissions
MATCH (a:Admission)
RETURN a
LIMIT 25;


// Preview drugs
MATCH (d:Drug)
RETURN d
LIMIT 25;



// ======================================================
// 2. SCHEMA INSPECTION
// ======================================================

// Visualize graph schema
CALL db.schema.visualization();


// List node labels
CALL db.labels();


// List relationship types
CALL db.relationshipTypes();



// ======================================================
// 3. GRAPH STRUCTURE EXPLORATION
// ======================================================

// Preview random relationships
MATCH p=()-[]->()
RETURN p
LIMIT 25;


// Inspect structured triples (head-relation-tail)
MATCH (h)-[r]->(t)
RETURN

CASE
WHEN 'Patient' IN labels(h) THEN 'patient_' + h.subject_id
WHEN 'Admission' IN labels(h) THEN 'admission_' + h.hadm_id
WHEN 'Diagnosis' IN labels(h) THEN 'diagnosis_' + h.diag_id
WHEN 'Procedure' IN labels(h) THEN 'procedure_' + h.icd_code + '_' + h.icd_version
WHEN 'LabItem' IN labels(h) THEN 'lab_' + h.itemid
WHEN 'Drug' IN labels(h) THEN 'drug_' + h.ndc
END AS head,

type(r) AS relation,

CASE
WHEN 'Patient' IN labels(t) THEN 'patient_' + t.subject_id
WHEN 'Admission' IN labels(t) THEN 'admission_' + t.hadm_id
WHEN 'Diagnosis' IN labels(t) THEN 'diagnosis_' + t.diag_id
WHEN 'Procedure' IN labels(t) THEN 'procedure_' + t.icd_code + '_' + t.icd_version
WHEN 'LabItem' IN labels(t) THEN 'lab_' + t.itemid
WHEN 'Drug' IN labels(t) THEN 'drug_' + t.ndc
END AS tail

LIMIT 50;



// ======================================================
// 4. GRAPH VALIDATION QUERIES
// ======================================================

// Count patients
MATCH (p:Patient)
RETURN count(p) AS total_patients;


// Count admissions
MATCH (a:Admission)
RETURN count(a) AS total_admissions;


// Count diagnoses
MATCH (d:Diagnosis)
RETURN count(d) AS total_diagnoses;


// Count drugs
MATCH (d:Drug)
RETURN count(d) AS total_drugs;


// Count lab items
MATCH (l:LabItem)
RETURN count(l) AS total_lab_items;



// ======================================================
// 5. RELATIONSHIP COUNTS
// ======================================================

// Patients → Admissions
MATCH (:Patient)-[r:HAS_ADMISSION]->(:Admission)
RETURN count(r) AS patient_admissions;


// Admissions → Diagnoses
MATCH (:Admission)-[r:HAS_DIAGNOSIS]->(:Diagnosis)
RETURN count(r) AS admission_diagnoses;


// Admissions → Lab events
MATCH (:Admission)-[r:HAS_LAB_EVENT]->(:LabItem)
RETURN count(r) AS lab_events;


// Admissions → Drug prescriptions
MATCH (:Admission)-[r:PRESCRIBED]->(:Drug)
RETURN count(r) AS prescriptions;



// ======================================================
// 6. PATIENT SUBGRAPH EXPLORATION
// ======================================================

// Explore a single patient's clinical neighborhood
MATCH (p:Patient)-[:HAS_ADMISSION]->(a)
OPTIONAL MATCH (a)-[:HAS_DIAGNOSIS]->(d)
OPTIONAL MATCH (a)-[:HAS_LAB_EVENT]->(l)
OPTIONAL MATCH (a)-[:PRESCRIBED]->(dr)
RETURN p,a,d,l,dr
LIMIT 50;



// ======================================================
// 7. TOP DIAGNOSES
// ======================================================

MATCH (:Admission)-[:HAS_DIAGNOSIS]->(d:Diagnosis)
RETURN d.long_title AS diagnosis,
count(*) AS frequency
ORDER BY frequency DESC
LIMIT 20;



// ======================================================
// 8. DIAGNOSIS CO-OCCURRENCE
// ======================================================

MATCH (a:Admission)-[:HAS_DIAGNOSIS]->(d1:Diagnosis),
      (a)-[:HAS_DIAGNOSIS]->(d2:Diagnosis)
WHERE d1 <> d2

RETURN d1.long_title AS diagnosis_1,
       d2.long_title AS diagnosis_2,
       count(*) AS co_occurrence

ORDER BY co_occurrence DESC
LIMIT 20;



// ======================================================
// 9. DRUG USAGE BY DIAGNOSIS
// ======================================================

MATCH (a:Admission)-[:HAS_DIAGNOSIS]->(d:Diagnosis)
MATCH (a)-[:PRESCRIBED]->(dr:Drug)

RETURN d.long_title AS diagnosis,
       dr.drug AS medication,
       count(*) AS usage

ORDER BY usage DESC
LIMIT 20;



// ======================================================
// 10. GRAPH PATH EXAMPLE
// ======================================================

// Patient → Admission → Diagnosis path
MATCH path =
(p:Patient)-[:HAS_ADMISSION]->(a:Admission)-[:HAS_DIAGNOSIS]->(d:Diagnosis)

RETURN path
LIMIT 25;
