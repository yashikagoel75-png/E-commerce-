CREATE DATABASE job_portal;
USE job_portal;
CREATE TABLE companies (
    company_id INT PRIMARY KEY AUTO_INCREMENT,
    company_name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    industry VARCHAR(100)
);
CREATE TABLE applicants (
    applicant_id INT PRIMARY KEY AUTO_INCREMENT,
    applicant_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    qualification VARCHAR(100)
);
CREATE TABLE job_postings (
    job_id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT,
    job_title VARCHAR(100) NOT NULL,
    job_description VARCHAR(255),
    salary DECIMAL(10,2),
    location VARCHAR(100),
    posted_date DATE,
    FOREIGN KEY (company_id) REFERENCES companies(company_id)
);
CREATE TABLE skills (
    skill_id INT PRIMARY KEY AUTO_INCREMENT,
    skill_name VARCHAR(100) UNIQUE NOT NULL
);
CREATE TABLE applications (
    application_id INT PRIMARY KEY AUTO_INCREMENT,
    applicant_id INT,
    job_id INT,
    application_date DATE,
    status VARCHAR(30),
    FOREIGN KEY (applicant_id) REFERENCES applicants(applicant_id),
    FOREIGN KEY (job_id) REFERENCES job_postings(job_id)
);
CREATE TABLE applicant_skills (
    applicant_id INT,
    skill_id INT,
    PRIMARY KEY (applicant_id, skill_id),
    FOREIGN KEY (applicant_id) REFERENCES applicants(applicant_id),
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id)
);
CREATE TABLE job_skills (
    job_id INT,
    skill_id INT,
    PRIMARY KEY (job_id, skill_id),
    FOREIGN KEY (job_id) REFERENCES job_postings(job_id),
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id)
);
INSERT INTO companies (company_name, location, industry) VALUES
('TCS','Noida','IT'),
('Infosys','Bangalore','IT'),
('Wipro','Delhi','IT'),
('HCL Technologies','Noida','IT'),
('Accenture','Gurgaon','Consulting'),
('Deloitte','Gurgaon','Consulting'),
('IBM','Bangalore','Technology'),
('Microsoft','Hyderabad','Technology'),
('Google','Bangalore','Technology'),
('Amazon','Hyderabad','E-Commerce'),
('Flipkart','Bangalore','E-Commerce'),
('Paytm','Noida','FinTech'),
('Cognizant','Pune','IT'),
('Tech Mahindra','Pune','IT'),
('Capgemini','Mumbai','IT'),
('Oracle','Hyderabad','Technology'),
('Adobe','Noida','Software'),
('Zoho','Chennai','Software'),
('Genpact','Gurgaon','BPO'),
('Deloitte India','Mumbai','Consulting');

INSERT INTO applicants (applicant_name,email,phone,qualification) VALUES
('Aarav Sharma','aarav@gmail.com','9876500001','BCA'),
('Ananya Gupta','ananya@gmail.com','9876500002','B.Tech'),
('Rohan Verma','rohan@gmail.com','9876500003','BCA'),
('Priya Singh','priya@gmail.com','9876500004','MCA'),
('Aditya Kumar','aditya@gmail.com','9876500005','B.Tech'),
('Sneha Agarwal','sneha@gmail.com','9876500006','BCA'),
('Rahul Mehta','rahul@gmail.com','9876500007','BCA'),
('Simran Kaur','simran@gmail.com','9876500008','B.Tech'),
('Karan Malhotra','karan@gmail.com','9876500009','MCA'),
('Neha Jain','neha@gmail.com','9876500010','BCA'),
('Arjun Kapoor','arjun@gmail.com','9876500011','B.Tech'),
('Isha Verma','isha@gmail.com','9876500012','BCA'),
('Vansh Gupta','vansh@gmail.com','9876500013','BCA'),
('Kavya Sharma','kavya@gmail.com','9876500014','MCA'),
('Mohit Yadav','mohit@gmail.com','9876500015','B.Tech'),
('Nidhi Singh','nidhi@gmail.com','9876500016','BCA'),
('Yash Raj','yash@gmail.com','9876500017','B.Tech'),
('Tanya Kapoor','tanya@gmail.com','9876500018','BCA'),
('Varun Jain','varun@gmail.com','9876500019','MCA'),
('Muskan Gupta','muskan@gmail.com','9876500020','BCA');

INSERT INTO job_postings
(company_id,job_title,job_description,salary,location,posted_date) VALUES
(1,'Software Developer','Develop web applications',50000,'Noida','2026-08-01'),
(2,'Java Developer','Java application development',55000,'Bangalore','2026-08-02'),
(3,'Web Developer','Frontend web development',45000,'Delhi','2026-08-03'),
(4,'Database Administrator','Manage company databases',60000,'Noida','2026-08-04'),
(5,'Data Analyst','Analyze business data',55000,'Gurgaon','2026-08-05'),
(6,'Business Analyst','Business process analysis',65000,'Gurgaon','2026-08-06'),
(7,'Python Developer','Python software development',60000,'Bangalore','2026-08-07'),
(8,'Cloud Engineer','Cloud infrastructure management',75000,'Hyderabad','2026-08-08'),
(9,'Software Engineer','Software development',80000,'Bangalore','2026-08-09'),
(10,'Data Scientist','Machine learning and analytics',90000,'Hyderabad','2026-08-10'),
(11,'Frontend Developer','React based development',50000,'Bangalore','2026-08-11'),
(12,'Backend Developer','Server-side development',60000,'Noida','2026-08-12'),
(13,'SQL Developer','Database and SQL development',55000,'Pune','2026-08-13'),
(14,'Network Engineer','Network administration',50000,'Pune','2026-08-14'),
(15,'Software Tester','Software testing',45000,'Mumbai','2026-08-15'),
(16,'Oracle Developer','Oracle database development',65000,'Hyderabad','2026-08-16'),
(17,'UI Developer','User interface development',50000,'Noida','2026-08-17'),
(18,'Full Stack Developer','Full stack web development',70000,'Chennai','2026-08-18'),
(19,'HR Analyst','HR data analysis',45000,'Gurgaon','2026-08-19'),
(20,'Project Manager','Manage software projects',85000,'Mumbai','2026-08-20');

INSERT INTO skills (skill_name) VALUES
('C'),
('C++'),
('Java'),
('Python'),
('SQL'),
('MySQL'),
('HTML'),
('CSS'),
('JavaScript'),
('React'),
('Node.js'),
('PHP'),
('Excel'),
('Power BI'),
('Machine Learning'),
('AWS'),
('Oracle'),
('Testing'),
('Communication'),
('Data Analysis');

INSERT INTO applicant_skills VALUES
(1,5),(1,6),(1,7),
(2,3),(2,5),(2,9),
(3,1),(3,2),(3,5),
(4,3),(4,4),(4,15),
(5,4),(5,5),(5,16),
(6,7),(6,8),(6,9),
(7,5),(7,6),(7,13),
(8,3),(8,9),(8,10),
(9,3),(9,5),(9,11),
(10,4),(10,5),(10,20),
(11,7),(11,8),(11,9),
(12,4),(12,5),(12,10),
(13,5),(13,6),(13,14),
(14,3),(14,5),(14,17),
(15,4),(15,16),(15,19),
(16,5),(16,17),(16,18),
(17,4),(17,5),(17,15),
(18,7),(18,8),(18,9),
(19,13),(19,14),(19,20),
(20,3),(20,5),(20,19);

INSERT INTO job_skills VALUES
(1,3),(1,5),(1,9),
(2,3),(2,5),
(3,7),(3,8),(3,9),
(4,5),(4,6),
(5,5),(5,13),(5,20),
(6,13),(6,14),(6,20),
(7,4),(7,5),
(8,4),(8,16),
(9,3),(9,5),
(10,4),(10,15),(10,20),
(11,7),(11,8),(11,10),
(12,4),(12,5),(12,11),
(13,5),(13,6),
(14,5),(14,19),
(15,18),(15,19),
(16,5),(16,17),
(17,7),(17,8),(17,10),
(18,4),(18,9),(18,11),
(19,13),(19,14),(19,20),
(20,13),(20,19),(20,20);

INSERT INTO applications
(applicant_id,job_id,application_date,status) VALUES
(1,1,'2026-08-10','Applied'),
(2,2,'2026-08-10','Shortlisted'),
(3,3,'2026-08-11','Applied'),
(4,10,'2026-08-11','Shortlisted'),
(5,7,'2026-08-12','Applied'),
(6,11,'2026-08-12','Rejected'),
(7,4,'2026-08-13','Selected'),
(8,9,'2026-08-13','Applied'),
(9,12,'2026-08-14','Shortlisted'),
(10,5,'2026-08-14','Applied'),
(11,3,'2026-08-15','Applied'),
(12,10,'2026-08-15','Shortlisted'),
(13,13,'2026-08-16','Selected'),
(14,16,'2026-08-16','Applied'),
(15,8,'2026-08-17','Shortlisted'),
(16,15,'2026-08-17','Rejected'),
(17,10,'2026-08-18','Applied'),
(18,18,'2026-08-18','Shortlisted'),
(19,19,'2026-08-19','Applied'),
(20,6,'2026-08-20','Selected'),
(1,13,'2026-08-20','Applied'),
(3,1,'2026-08-21','Shortlisted'),
(5,5,'2026-08-21','Applied'),
(8,18,'2026-08-22','Applied');

SELECT 
    a.applicant_name,
    j.job_title,
    ap.application_date,
    ap.status
FROM applications ap
JOIN applicants a 
    ON ap.applicant_id = a.applicant_id
JOIN job_postings j 
    ON ap.job_id = j.job_id;
    
    SELECT 
    c.company_name,
    COUNT(j.job_id) AS total_jobs
FROM companies c
JOIN job_postings j 
    ON c.company_id = j.company_id
GROUP BY c.company_id, c.company_name
HAVING COUNT(j.job_id) > 1;

SELECT applicant_name
FROM applicants
WHERE applicant_id IN
(
    SELECT applicant_id
    FROM applications
    WHERE job_id IN
    (
        SELECT job_id
        FROM job_postings
        WHERE salary > 70000
    )
);

CREATE VIEW job_details AS
SELECT
    j.job_id,
    j.job_title,
    c.company_name,
    j.location,
    j.salary,
    j.posted_date
FROM job_postings j
JOIN companies c
ON j.company_id = c.company_id;
SELECT * FROM job_details;

DELIMITER //

CREATE TRIGGER before_application_insert
BEFORE INSERT ON applications
FOR EACH ROW
BEGIN
    IF NEW.status IS NULL OR NEW.status = '' THEN
        SET NEW.status = 'Applied';
    END IF;
END //

DELIMITER ;

SELECT 
    a.applicant_name,
    s.skill_name
FROM applicant_skills aps
JOIN applicants a
    ON aps.applicant_id = a.applicant_id
JOIN skills s
    ON aps.skill_id = s.skill_id
WHERE aps.skill_id IN
(
    SELECT skill_id
    FROM job_skills
    WHERE job_id = 1
);

SELECT a.applicant_id, a.applicant_name
FROM applicants a
JOIN applicant_skills aps
    ON a.applicant_id = aps.applicant_id
WHERE aps.skill_id IN
(
    SELECT skill_id
    FROM job_skills
    WHERE job_id = 1
)
GROUP BY a.applicant_id, a.applicant_name
HAVING COUNT(DISTINCT aps.skill_id) =
(
    SELECT COUNT(*)
    FROM job_skills
    WHERE job_id = 1
);
