-- ============================================================
-- Hospital Management System
-- ============================================================

CREATE DATABASE IF NOT EXISTS hospital_management;
USE hospital_management;

-- Drop child tables
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Billing;
DROP TABLE IF EXISTS Medical_Records;
DROP TABLE IF EXISTS Appointments;
DROP TABLE IF EXISTS Doctor_Department;
DROP TABLE IF EXISTS Departments;
DROP TABLE IF EXISTS Doctors;
DROP TABLE IF EXISTS Patients;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. TABLES / DATABASE SCHEMA

CREATE TABLE Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    dob DATE NOT NULL,
    gender ENUM('Female', 'Male', 'Other') NOT NULL,
    phone_number VARCHAR(20) NULL,
    email VARCHAR(120) UNIQUE NULL,
    address VARCHAR(255),
    registration_date DATE NOT NULL DEFAULT (CURRENT_DATE)
);

CREATE TABLE Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NULL,
    email VARCHAR(120) UNIQUE NULL,
    available_days VARCHAR(100),
    consultation_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    experience_years INT NOT NULL DEFAULT 0,
    CHECK (consultation_fee >= 0),
    CHECK (experience_years >= 0)
);

CREATE TABLE Departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Doctor_Department (
    doctor_id INT NOT NULL,
    department_id INT NOT NULL,
    PRIMARY KEY (doctor_id, department_id),
    CONSTRAINT fk_doctor_department_doctor
        FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_doctor_department_department
        FOREIGN KEY (department_id) REFERENCES Departments(department_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status ENUM('Scheduled', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Scheduled',
    admission_date DATE NULL,
    discharge_date DATE NULL,
    CONSTRAINT fk_appointments_patient
        FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_appointments_doctor
        FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (discharge_date IS NULL OR admission_date IS NULL OR discharge_date >= admission_date)
);

CREATE TABLE Medical_Records (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    diagnosis VARCHAR(255) NOT NULL,
    prescription TEXT,
    treatment_date DATE NOT NULL,
    CONSTRAINT fk_records_patient
        FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_records_doctor
        FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Billing (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    appointment_id INT NOT NULL UNIQUE,
    amount DECIMAL(10,2) NOT NULL,
    payment_status ENUM('Paid', 'Pending', 'Cancelled') NOT NULL DEFAULT 'Pending',
    payment_date DATE NULL,
    CONSTRAINT fk_billing_patient
        FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_billing_appointment
        FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (amount >= 0)
);

CREATE INDEX idx_appointments_date ON Appointments(appointment_date);
CREATE INDEX idx_appointments_status ON Appointments(status);
CREATE INDEX idx_medical_records_treatment_date ON Medical_Records(treatment_date);
CREATE INDEX idx_billing_payment_status ON Billing(payment_status);

-- 2. SAMPLE DATA

INSERT INTO Patients
(patient_id, name, dob, gender, phone_number, email, address, registration_date)
VALUES
(1, 'Aarav Shah',     '1990-04-12', 'Male',   '9876501001', 'aarav.shah@example.com',     'Adajan, Surat',       '2025-01-15'),
(2, 'Diya Patel',     '1985-09-23', 'Female', '9876501002', 'diya.patel@example.com',     'Vesu, Surat',         '2025-03-10'),
(3, 'Kabir Mehta',    '2001-02-08', 'Male',   '9876501003', 'kabir.mehta@example.com',    'City Light, Surat',   '2024-06-20'),
(4, 'Anaya Desai',    '1978-12-01', 'Female', '9876501004', 'anaya.desai@example.com',    'Piplod, Surat',       '2025-07-05'),
(5, 'Ishaan Joshi',   '1995-06-17', 'Male',   NULL,         'ishaan.joshi@example.com',   'Pal, Surat',          '2023-11-18'),
(6, 'Meera Trivedi',  '1969-03-29', 'Female', '9876501006', 'meera.trivedi@example.com',  'Athwa, Surat',        '2026-02-11'),
(7, 'Rohan Shah',     '2004-08-14', 'Male',   '9876501007', 'rohan.shah@example.com',     'Udhna, Surat',        '2026-04-22'),
(8, 'Sara Khan',      '1992-10-30', 'Female', '9876501008', 'sara.khan@example.com',      'Dumas Road, Surat',   '2024-12-03'),
(9, 'Vivaan Kapoor',  '1988-01-19', 'Male',   '9876501009', 'vivaan.kapoor@example.com',  'Varachha, Surat',     '2025-09-12'),
(10,'Nisha Rao',      '1999-07-07', 'Female', '9876501010', 'nisha.rao@example.com',      'Katargam, Surat',     '2026-06-01'),
(11,'Arjun Nair',     '1972-05-25', 'Male',   '9876501011', 'arjun.nair@example.com',     'Pal, Surat',          '2023-05-14'),
(12,'Tara Shah',      '2003-11-11', 'Other',  '9876501012', 'tara.shah@example.com',      'Vesu, Surat',         '2026-08-02');

INSERT INTO Doctors
(doctor_id, name, specialization, phone_number, email, available_days, consultation_fee, experience_years)
VALUES
(1, 'Dr. Neel Shah',       'Cardiology',   '9123400001', 'neel.shah@hospital.example',       'Mon, Wed, Fri', 1500.00, 18),
(2, 'Dr. Riya Patel',      'Neurology',    '9123400002', 'riya.patel@hospital.example',      'Tue, Thu, Sat', 1800.00, 12),
(3, 'Dr. Karan Mehta',     'Dermatology',  '9123400003', 'karan.mehta@hospital.example',     'Mon, Tue, Thu', 1000.00, 7),
(4, 'Dr. Sana Desai',      'Pediatrics',   NULL,         'sana.desai@hospital.example',      'Wed, Fri, Sat', 900.00, 4),
(5, 'Dr. Arjun Rao',       'Orthopedics',  '9123400005', 'arjun.rao@hospital.example',       'Mon, Wed, Sat', 1300.00, 16),
(6, 'Dr. Priya Nair',      'Cardiology',   '9123400006', 'priya.nair@hospital.example',      'Tue, Thu, Fri', 1600.00, 21),
(7, 'Dr. Dev Malhotra',    'Neurology',    '9123400007', 'dev.malhotra@hospital.example',    'Mon, Thu, Sat', 1250.00, 2),
(8, 'Dr. Maya Iyer',       'General Medicine','9123400008','maya.iyer@hospital.example',     'Mon-Fri',       750.00, 9);

INSERT INTO Departments (department_id, department_name) VALUES
(1, 'Cardiology'),
(2, 'Neurology'),
(3, 'Dermatology'),
(4, 'Pediatrics'),
(5, 'Orthopedics'),
(6, 'General Medicine'),
(7, 'Emergency');

INSERT INTO Doctor_Department (doctor_id, department_id) VALUES
(1,1),(2,2),(3,3),(4,4),(5,5),(6,1),(7,2),(8,6),
(1,7),(4,7);

INSERT INTO Appointments
(appointment_id, patient_id, doctor_id, appointment_date, status, admission_date, discharge_date)
VALUES
(1, 1, 1, '2025-01-20 09:00:00', 'Completed', '2025-01-20', '2025-01-22'),
(2, 2, 2, '2025-03-15 10:30:00', 'Completed', NULL, NULL),
(3, 3, 3, '2025-04-10 11:00:00', 'Completed', NULL, NULL),
(4, 1, 1, '2025-06-02 09:30:00', 'Completed', NULL, NULL),
(5, 4, 5, '2025-07-10 12:00:00', 'Completed', '2025-07-10', '2025-07-14'),
(6, 5, 2, '2025-08-01 14:00:00', 'Cancelled', NULL, NULL),
(7, 6, 6, '2026-02-15 09:00:00', 'Completed', NULL, NULL),
(8, 7, 4, '2026-04-25 10:00:00', 'Scheduled', NULL, NULL),
(9, 8, 3, '2025-12-12 15:00:00', 'Completed', NULL, NULL),
(10,9, 7, '2025-10-01 13:00:00', 'Completed', NULL, NULL),
(11,10, 8, '2026-06-05 08:30:00', 'Scheduled', NULL, NULL),
(12,11, 5, '2024-05-18 11:30:00', 'Completed', '2024-05-18', '2024-05-20'),
(13,12, 3, '2026-08-10 16:00:00', 'Scheduled', NULL, NULL),
(14, 2, 6, '2025-11-20 09:30:00', 'Completed', NULL, NULL),
(15, 3, 1, '2024-09-09 10:00:00', 'Completed', NULL, NULL),
(16, 4, 2, '2025-09-21 14:30:00', 'Completed', NULL, NULL),
(17, 6, 1, '2026-03-01 09:00:00', 'Completed', NULL, NULL),
(18, 8, 5, '2025-02-22 12:00:00', 'Completed', NULL, NULL),
(19, 9, 3, '2026-01-12 10:30:00', 'Cancelled', NULL, NULL),
(20, 1, 2, '2026-09-02 11:00:00', 'Scheduled', NULL, NULL);

INSERT INTO Medical_Records
(record_id, patient_id, doctor_id, diagnosis, prescription, treatment_date)
VALUES
(1, 1, 1, 'Hypertension', 'Lifestyle changes; follow-up in 30 days', '2025-01-20'),
(2, 1, 1, 'High cholesterol', 'Diet plan and prescribed medication', '2025-06-02'),
(3, 1, 2, 'Migraine', 'Keep symptom diary; follow-up if needed', '2026-09-02'),
(4, 2, 2, 'Migraine', 'Rest and follow-up', '2025-03-15'),
(5, 2, 6, 'Routine cardiac review', 'Annual review recommended', '2025-11-20'),
(6, 3, 3, 'Acne', 'Topical treatment', '2025-04-10'),
(7, 3, 1, 'Routine cardiac screening', 'Review lifestyle', '2024-09-09'),
(8, 4, 5, 'Knee pain', 'Physiotherapy plan', '2025-07-10'),
(9, 4, 2, 'Headache', 'Hydration and observation', '2025-09-21'),
(10,5, 2, 'Neurological assessment', 'Follow-up advised', '2025-08-01'),
(11,6, 6, 'Blood pressure review', 'Continue monitoring', '2026-02-15'),
(12,6, 1, 'Cardiac follow-up', 'Routine follow-up', '2026-03-01'),
(13,7, 4, 'Child wellness visit', 'Routine advice', '2026-04-25'),
(14,8, 3, 'Eczema', 'Skin care plan', '2025-12-12'),
(15,8, 5, 'Foot pain', 'Rest and review', '2025-02-22'),
(16,9, 7, 'Migraine', 'Hydration and review', '2025-10-01'),
(17,9, 3, 'Skin irritation', 'Topical treatment', '2026-01-12'),
(18,10,8, 'Seasonal infection', 'Fluids and rest', '2026-06-05'),
(19,11,5, 'Shoulder pain', 'Physiotherapy', '2024-05-18'),
(20,12,3, 'Dermatitis', 'Skin care plan', '2026-08-10'),
(21,1, 6, 'Preventive check-up', 'Annual check-up', '2026-05-05'),
(22,1, 1, 'Follow-up consultation', 'Continue prescribed plan', '2026-06-10'),
(23,1, 2, 'Sleep-related headache', 'Review sleep routine', '2026-07-10');

INSERT INTO Billing
(invoice_id, patient_id, appointment_id, amount, payment_status, payment_date)
VALUES
(1, 1, 1, 1500.00, 'Paid', '2025-01-20'),
(2, 2, 2, 1800.00, 'Paid', '2025-03-15'),
(3, 3, 3, 1000.00, 'Paid', '2025-04-10'),
(4, 1, 4, 1500.00, 'Paid', '2025-06-02'),
(5, 4, 5, 1300.00, 'Paid', '2025-07-10'),
(6, 5, 6, 1800.00, 'Cancelled', NULL),
(7, 6, 7, 1600.00, 'Paid', '2026-02-15'),
(8, 8, 9, 1000.00, 'Paid', '2025-12-12'),
(9, 9, 10, 1250.00, 'Pending', NULL),
(10,11,12, 1300.00, 'Paid', '2024-05-18'),
(11,2,14, 1600.00, 'Paid', '2025-11-20'),
(12,3,15, 1500.00, 'Paid', '2024-09-09'),
(13,4,16, 1800.00, 'Pending', NULL),
(14,6,17, 1500.00, 'Paid', '2026-03-01'),
(15,8,18, 1300.00, 'Paid', '2025-02-22'),
(16,9,19, 1000.00, 'Cancelled', NULL);

-- 1. CRUD OPERATIONS

-- READ: list patients
SELECT patient_id, name, dob, gender, phone_number, email, address, registration_date
FROM Patients
ORDER BY patient_id;


SELECT appointment_id, patient_id, appointment_date, status
FROM Appointments
WHERE status = 'Cancelled'
  AND appointment_date < DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH);


-- TASK 2. WHERE, HAVING, LIMIT

-- Patients registered during the last year.
SELECT patient_id, name, registration_date
FROM Patients
WHERE registration_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR)
ORDER BY registration_date DESC;

-- Top 5 highest-paying patients (based on total non-cancelled invoices).
SELECT p.patient_id, p.name, SUM(b.amount) AS total_billed
FROM Patients p
JOIN Billing b ON b.patient_id = p.patient_id
WHERE b.payment_status <> 'Cancelled'
GROUP BY p.patient_id, p.name
HAVING SUM(b.amount) > 0
ORDER BY total_billed DESC
LIMIT 5;

-- Doctors charging more than ₹1,000.
SELECT doctor_id, name, specialization, consultation_fee
FROM Doctors
WHERE consultation_fee > 1000
ORDER BY consultation_fee DESC;

-- 3. AND, OR, NOT

-- Scheduled appointments assigned to doctor 3.
SELECT *
FROM Appointments
WHERE status = 'Scheduled' AND doctor_id = 3;

-- Doctors specializing in Cardiology or Neurology.
SELECT doctor_id, name, specialization
FROM Doctors
WHERE specialization = 'Cardiology' OR specialization = 'Neurology'
ORDER BY specialization, name;

SELECT p.patient_id, p.name
FROM Patients p
WHERE NOT EXISTS (
    SELECT 1
    FROM Appointments a
    WHERE a.patient_id = p.patient_id
      AND a.status = 'Completed'
      AND a.appointment_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR)
);

-- 4. ORDER BY, GROUP BY

-- Doctors sorted by specialization.
SELECT doctor_id, name, specialization
FROM Doctors
ORDER BY specialization ASC, name ASC;

-- Number of appointments assigned to each doctor.
SELECT d.doctor_id, d.name, COUNT(a.appointment_id) AS appointment_count
FROM Doctors d
LEFT JOIN Appointments a ON a.doctor_id = d.doctor_id
GROUP BY d.doctor_id, d.name
ORDER BY appointment_count DESC, d.name;

SELECT dep.department_name, COALESCE(SUM(
    CASE WHEN b.payment_status = 'Paid' THEN b.amount ELSE 0 END
), 0) AS paid_revenue
FROM Departments dep
LEFT JOIN Doctor_Department dd ON dd.department_id = dep.department_id
LEFT JOIN Doctors d ON d.doctor_id = dd.doctor_id
LEFT JOIN Appointments a ON a.doctor_id = d.doctor_id
LEFT JOIN Billing b ON b.appointment_id = a.appointment_id
GROUP BY dep.department_id, dep.department_name
ORDER BY paid_revenue DESC, dep.department_name;

-- 5. AGGREGATE FUNCTIONS: SUM, AVG, MAX, MIN, COUNT

-- Total revenue collected (paid invoices only).
SELECT COALESCE(SUM(amount), 0) AS total_revenue_collected
FROM Billing
WHERE payment_status = 'Paid';

-- Most visited doctor (based on completed appointments).
SELECT d.doctor_id, d.name, COUNT(a.appointment_id) AS completed_visits
FROM Doctors d
JOIN Appointments a ON a.doctor_id = d.doctor_id
WHERE a.status = 'Completed'
GROUP BY d.doctor_id, d.name
ORDER BY completed_visits DESC
LIMIT 1;

-- Average consultation fee.
SELECT ROUND(AVG(consultation_fee), 2) AS average_consultation_fee
FROM Doctors;

-- Extra aggregate summary.
SELECT COUNT(*) AS doctor_count,
       MIN(consultation_fee) AS lowest_fee,
       MAX(consultation_fee) AS highest_fee,
       ROUND(AVG(consultation_fee), 2) AS average_fee
FROM Doctors;

-- 6. PRIMARY KEY / FOREIGN KEY RELATIONSHIPS

SELECT mr.record_id, mr.patient_id, mr.doctor_id
FROM Medical_Records mr
LEFT JOIN Patients p ON p.patient_id = mr.patient_id
LEFT JOIN Doctors d ON d.doctor_id = mr.doctor_id
WHERE p.patient_id IS NULL OR d.doctor_id IS NULL;

SELECT b.invoice_id, b.patient_id, b.appointment_id
FROM Billing b
LEFT JOIN Patients p ON p.patient_id = b.patient_id
LEFT JOIN Appointments a ON a.appointment_id = b.appointment_id
WHERE p.patient_id IS NULL OR a.appointment_id IS NULL;

-- Display declared foreign keys for this database.
SELECT TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME,
       REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = DATABASE()
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

-- 7. JOINS: INNER, LEFT, RIGHT, FULL OUTER equivalent

-- INNER JOIN: doctors and department names.
SELECT d.doctor_id, d.name AS doctor_name, dep.department_name
FROM Doctors d
INNER JOIN Doctor_Department dd ON dd.doctor_id = d.doctor_id
INNER JOIN Departments dep ON dep.department_id = dd.department_id
ORDER BY d.name, dep.department_name;

-- LEFT JOIN: patients who have completed appointments.
SELECT DISTINCT p.patient_id, p.name
FROM Patients p
LEFT JOIN Appointments a
    ON a.patient_id = p.patient_id AND a.status = 'Completed'
WHERE a.appointment_id IS NOT NULL
ORDER BY p.name;

SELECT a.appointment_id, a.patient_id, a.doctor_id, a.status
FROM Billing b
RIGHT JOIN Appointments a ON a.appointment_id = b.appointment_id
WHERE b.invoice_id IS NULL
ORDER BY a.appointment_id;

SELECT p.patient_id, p.name, a.appointment_id, a.status
FROM Patients p
LEFT JOIN Appointments a ON a.patient_id = p.patient_id
UNION
SELECT p.patient_id, p.name, a.appointment_id, a.status
FROM Appointments a
LEFT JOIN Patients p ON p.patient_id = a.patient_id
ORDER BY patient_id, appointment_id;

-- 8. SUBQUERIES

-- Doctors who have handled more than 50 patients.
-- "Handled" is interpreted as 50+ distinct patients across appointments.
SELECT d.doctor_id, d.name
FROM Doctors d
WHERE (
    SELECT COUNT(DISTINCT a.patient_id)
    FROM Appointments a
    WHERE a.doctor_id = d.doctor_id
) > 50;

-- Patient(s) who spent the most on non-cancelled invoices.
SELECT p.patient_id, p.name, totals.total_spent
FROM Patients p
JOIN (
    SELECT patient_id, SUM(amount) AS total_spent
    FROM Billing
    WHERE payment_status <> 'Cancelled'
    GROUP BY patient_id
) totals ON totals.patient_id = p.patient_id
WHERE totals.total_spent = (
    SELECT MAX(patient_total)
    FROM (
        SELECT SUM(amount) AS patient_total
        FROM Billing
        WHERE payment_status <> 'Cancelled'
        GROUP BY patient_id
    ) x
);

-- Appointments where the doctor's specialization is Dermatology.
SELECT a.appointment_id, p.name AS patient_name, d.name AS doctor_name,
       d.specialization, a.appointment_date, a.status
FROM Appointments a
JOIN Doctors d ON d.doctor_id = a.doctor_id
JOIN Patients p ON p.patient_id = a.patient_id
WHERE d.specialization = 'Dermatology'
ORDER BY a.appointment_date;


-- 9. DATE & TIME FUNCTIONS

-- Appointment counts by month.
SELECT DATE_FORMAT(appointment_date, '%Y-%m') AS appointment_month,
       COUNT(*) AS appointment_count
FROM Appointments
GROUP BY DATE_FORMAT(appointment_date, '%Y-%m')
ORDER BY appointment_month;

-- Hospital stay duration in days for appointments with admission
-- and discharge dates.
SELECT appointment_id, patient_id, admission_date, discharge_date,
       DATEDIFF(discharge_date, admission_date) AS stay_duration_days
FROM Appointments
WHERE admission_date IS NOT NULL AND discharge_date IS NOT NULL
ORDER BY admission_date;

-- Format treatment_date as DD-MM-YYYY.
SELECT record_id, patient_id, diagnosis,
       DATE_FORMAT(treatment_date, '%d-%m-%Y') AS treatment_date_formatted
FROM Medical_Records
ORDER BY treatment_date;

-- 10. STRING FUNCTIONS

-- Convert patient names to uppercase (display only; no stored data changes).
SELECT patient_id, UPPER(name) AS patient_name_uppercase
FROM Patients
ORDER BY patient_id;

-- Trim whitespace from doctor names (display only).
SELECT doctor_id, TRIM(name) AS trimmed_doctor_name
FROM Doctors
ORDER BY doctor_id;

-- Replace missing/blank phone numbers with "Not Available".
SELECT patient_id, name,
       COALESCE(NULLIF(TRIM(phone_number), ''), 'Not Available') AS phone_display
FROM Patients
UNION ALL
SELECT doctor_id + 1000 AS patient_id, name,
       COALESCE(NULLIF(TRIM(phone_number), ''), 'Not Available') AS phone_display
FROM Doctors;


-- 11. WINDOW FUNCTIONS

-- Rank doctors by number of distinct patients treated.
WITH doctor_patient_counts AS (
    SELECT d.doctor_id, d.name,
           COUNT(DISTINCT CASE WHEN a.status = 'Completed' THEN a.patient_id END) AS patients_treated
    FROM Doctors d
    LEFT JOIN Appointments a ON a.doctor_id = d.doctor_id
    GROUP BY d.doctor_id, d.name
)
SELECT doctor_id, name, patients_treated,
       RANK() OVER (ORDER BY patients_treated DESC) AS patient_rank
FROM doctor_patient_counts
ORDER BY patient_rank, name;

-- Cumulative revenue per month (paid invoices only).
WITH monthly_revenue AS (
    SELECT DATE_FORMAT(payment_date, '%Y-%m') AS revenue_month,
           SUM(amount) AS revenue
    FROM Billing
    WHERE payment_status = 'Paid' AND payment_date IS NOT NULL
    GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
)
SELECT revenue_month, revenue,
       SUM(revenue) OVER (ORDER BY revenue_month
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue
FROM monthly_revenue
ORDER BY revenue_month;

-- Running total of appointments made, ordered by appointment date.
SELECT appointment_id, appointment_date, patient_id, doctor_id,
       COUNT(*) OVER (
           ORDER BY appointment_date, appointment_id
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_appointment_total
FROM Appointments
ORDER BY appointment_date, appointment_id;

-- 12. CASE EXPRESSIONS

-- Patient risk level based on number of medical records.
SELECT p.patient_id, p.name, COUNT(mr.record_id) AS medical_record_count,
       CASE
           WHEN COUNT(mr.record_id) > 5 THEN 'High'
           WHEN COUNT(mr.record_id) BETWEEN 3 AND 5 THEN 'Medium'
           ELSE 'Low'
       END AS patient_risk_level
FROM Patients p
LEFT JOIN Medical_Records mr ON mr.patient_id = p.patient_id
GROUP BY p.patient_id, p.name
ORDER BY medical_record_count DESC, p.name;

-- Doctor experience category.
SELECT doctor_id, name, experience_years,
       CASE
           WHEN experience_years > 15 THEN 'Senior'
           WHEN experience_years BETWEEN 5 AND 15 THEN 'Mid-Level'
           ELSE 'Junior'
       END AS experience_category
FROM Doctors
ORDER BY experience_years DESC, name;

-- Payment status summary.
SELECT payment_status, COUNT(*) AS invoice_count, SUM(amount) AS invoice_amount
FROM Billing
GROUP BY payment_status
ORDER BY payment_status;

-- Patient appointment history.
SELECT p.patient_id, p.name, a.appointment_id, a.appointment_date,
       d.name AS doctor_name, a.status
FROM Patients p
LEFT JOIN Appointments a ON a.patient_id = p.patient_id
LEFT JOIN Doctors d ON d.doctor_id = a.doctor_id
ORDER BY p.patient_id, a.appointment_date;
