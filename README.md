# Hospital Management System (MySQL)

A sample relational database project for a hospital. It demonstrates table design, primary and foreign keys, CRUD operations, filtering, grouping, aggregate functions, joins, subqueries, date/string functions, window functions, and `CASE` expressions.

## Requirements

- MySQL 8.0 or later (window functions and common table expressions are used).
- MySQL Workbench or another MySQL client.

## Files

- `hospital_management.sql` — creates the database and tables, inserts sample data, and contains commented/labelled queries for all 12 task groups.
- `README.md` — this guide.

## Database schema

| Table | Purpose | Primary key | Main relationships |
|---|---|---|---|
| `Patients` | Patient details and registration date | `patient_id` | One patient can have many appointments, medical records, and invoices |
| `Doctors` | Doctor details, speciality, fee, experience | `doctor_id` | One doctor can have many appointments and medical records |
| `Appointments` | Patient-doctor appointment, status, optional admission/discharge dates | `appointment_id` | References `Patients` and `Doctors` |
| `Medical_Records` | Diagnosis, prescription, treatment date | `record_id` | References `Patients` and `Doctors` |
| `Billing` | Invoice amount and payment status/date | `invoice_id` | References `Patients` and `Appointments`; one invoice per appointment in this sample schema |
| `Departments` | Department list | `department_id` | Linked to doctors through `Doctor_Department` |
| `Doctor_Department` | Many-to-many doctor/department mapping | `(doctor_id, department_id)` | References `Doctors` and `Departments` |

### Design notes

- `Doctors.experience_years` was added because the assignment asks for experience-based categories.
- `Appointments.admission_date` and `Appointments.discharge_date` were added because the assignment asks for hospital stay duration.
- `Doctor_Department` uses a composite primary key to prevent duplicate doctor-department mappings.
- `Billing.appointment_id` is `UNIQUE` in this sample design, meaning each appointment can have at most one invoice. Remove that constraint if your requirements allow multiple invoices per appointment.
- Foreign keys protect referential integrity. Parent records cannot be deleted while dependent rows exist, except doctor/department mappings which cascade on deletion.
- Revenue reports count only invoices with `payment_status = 'Paid'`. The “highest-paying patients” report excludes cancelled invoices and sums the remaining invoice amounts.
- The data is fictional and intended for learning only. Do not use it as real patient data.

## How to run in MySQL Workbench

1. Open MySQL Workbench and connect to your local MySQL server.
2. Choose **File → Open SQL Script** and open `hospital_management.sql`.
3. Run the full script using the lightning-bolt **Execute** button.
4. Refresh the **Schemas** panel. You should see `hospital_management`.
5. To inspect tables, expand **Schemas → hospital_management → Tables**.
6. Run a query section at a time to view its result grid. The script includes comments and section headings for each assignment task.

> The script drops and recreates the project tables at the start so that it can be rerun consistently. Do not run it against a database containing data you need to keep.

## Assignment task map

1. **CRUD operations:** sample `INSERT`, `SELECT`, `UPDATE`, and a preview plus optional `DELETE` for old cancelled appointments. Destructive examples are commented out.
2. **WHERE, HAVING, LIMIT:** patients registered in the last year, top five patients by non-cancelled invoice totals, doctors charging more than ₹1,000.
3. **AND, OR, NOT:** scheduled appointments for doctor 3, Cardiology/Neurology doctors, patients without a completed visit in the last year.
4. **ORDER BY, GROUP BY:** doctors sorted by speciality, appointment count per doctor, paid revenue by department.
5. **Aggregate functions:** total collected revenue, most-visited doctor, average/minimum/maximum consultation fees, doctor count.
6. **Keys and relationships:** checks for orphan medical records and invoices, plus a query listing declared foreign keys.
7. **Joins:** `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, and a `UNION`-based emulation of `FULL OUTER JOIN`.
8. **Subqueries:** doctors with more than 50 distinct patients, patient(s) with the highest non-cancelled invoice total, Dermatology appointments.
9. **Date/time functions:** monthly appointment counts, length of stay using `DATEDIFF`, formatted treatment dates.
10. **String functions:** `UPPER`, `TRIM`, and `COALESCE`/`NULLIF` for missing phone numbers.
11. **Window functions:** doctor patient-count ranking, cumulative monthly paid revenue, running appointment count.
12. **CASE expressions:** patient risk level based on medical-record count and doctor seniority based on experience.

## Important interpretation details

- The assignment says “top 5 highest-paying patients.” This project interprets that as patients with the largest total invoice amounts excluding cancelled invoices, regardless of whether the invoice is paid or pending. For only money actually received, filter to `payment_status = 'Paid'`.
- The assignment says “most visited doctor.” This project counts completed appointments.
- The “more than 50 patients” subquery is expected to return no rows with the included small sample dataset. It is still a valid query; add more appointment data to test a positive result.
- MySQL does not implement `FULL OUTER JOIN` directly. The script uses two `LEFT JOIN` queries combined with `UNION` to emulate it.
- The department revenue report can count a doctor’s revenue in multiple departments if that doctor is assigned to more than one department. This is expected for the many-to-many mapping in this sample.
- The “patients who have NOT visited in the past year” query uses completed appointments as the definition of a visit.

## Quick verification queries

```sql
USE hospital_management;

SELECT COUNT(*) AS patients FROM Patients;
SELECT COUNT(*) AS doctors FROM Doctors;
SELECT COUNT(*) AS appointments FROM Appointments;
SELECT COUNT(*) AS medical_records FROM Medical_Records;
SELECT COUNT(*) AS invoices FROM Billing;
SELECT COUNT(*) AS departments FROM Departments;
SELECT COUNT(*) AS doctor_department_links FROM Doctor_Department;
```

Expected sample row counts:

- Patients: 12
- Doctors: 8
- Appointments: 20
- Medical records: 23
- Billing invoices: 16
- Departments: 7
- Doctor-department links: 10
