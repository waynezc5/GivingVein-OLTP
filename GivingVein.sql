--Create database

USE master;

IF DB_ID(N'GivingVein') IS NOT NULL DROP DATABASE GivingVein;

CREATE DATABASE GivingVein;
GO

USE GivingVein;
GO

--Create schemas
CREATE SCHEMA Donors;
GO
CREATE SCHEMA Medical_History;
GO
CREATE SCHEMA Lab;
GO

--Create Tables, Constraints, and Indexes
-------------------------------------------------------------------------------------
CREATE TABLE Donors.Phone
(
    phone_id            INT         NOT NULL IDENTITY(1,1),
    phone_number        VARCHAR(10) NOT NULL,
    CONSTRAINT PK_Phone PRIMARY KEY(phone_id)
);

CREATE NONCLUSTERED INDEX idx_nc_phone_phone_number ON Donors.Phone(phone_number);

-------------------------------------------------------------------------------------
CREATE TABLE Donors.Address
(
    address_id          INT      NOT NULL IDENTITY(1,1),
    address             VARCHAR(50) NOT NULL,
    city                VARCHAR(50) NOT NULL,
    state               VARCHAR(2)  NOT NULL,
    zip                 VARCHAR(5)  NOT NULL,
    CONSTRAINT PK_Address PRIMARY KEY(address_id)
);

CREATE NONCLUSTERED INDEX idx_nc_address_city   ON Donors.Address(city);

-------------------------------------------------------------------------------------
CREATE TABLE Donors.Blood_Type
(
    blood_type_id       INT         NOT NULL IDENTITY(1,1),
    blood_type_desc     VARCHAR(50) NOT NULL,
    rh_type             VARCHAR(50) NULL,
    CONSTRAINT PK_Blood_Type PRIMARY KEY(blood_type_id)
);

-------------------------------------------------------------------------------------
CREATE TABLE Donors.Provider_Type
(
    provider_type_id            INT         NOT NULL IDENTITY(1,1),
    provider_type               VARCHAR(50) NOT NULL,
    CONSTRAINT PK_Provider_Type PRIMARY KEY(provider_type_id) 
);


-------------------------------------------------------------------------------------
CREATE TABLE Donors.Healthcare_Provider
(
    provider_id                  INT         NOT NULL IDENTITY(1,1),
    provider_first_name          VARCHAR(50) NOT NULL,
    provider_last_name           VARCHAR(50) NOT NULL,
    provider_type_id             INT         NOT NULL,
    CONSTRAINT PK_Healthcare_Provider PRIMARY KEY(provider_id),
    CONSTRAINT FK_Provider_Type FOREIGN KEY(provider_type_id)
        REFERENCES Donors.Provider_Type(provider_type_id)
);

CREATE NONCLUSTERED INDEX idx_nc_healthcare_provider_provider_type_id ON Donors.Healthcare_Provider(provider_type_id);

-------------------------------------------------------------------------------------
CREATE TABLE Donors.Emergency_Contact
(
    emergency_contact_id          INT         NOT NULL IDENTITY(1,1),
    emergency_contact_first_name  VARCHAR(50) NOT NULL,
    emergency_contact_last_name   VARCHAR(50) NOT NULL,
    emergency_contact_phone       VARCHAR(10) NOT NULL,
    CONSTRAINT PK_Emergency_Contact PRIMARY KEY(emergency_contact_id)
    
);

CREATE NONCLUSTERED INDEX idx_nc_emergency_contact_contact_last_name ON Donors.Emergency_Contact(emergency_contact_last_name);
CREATE NONCLUSTERED INDEX idx_nc_emegency_contact_contact_phone      ON Donors.Emergency_Contact(emergency_contact_phone);

-------------------------------------------------------------------------------------
CREATE TABLE Donors.Medical_History
(
    medical_history_id          INT         NOT NULL IDENTITY(1,1),
    sexually_active_ind         BIT         NOT NULL,
    exercise_ind                BIT         NOT NULL,
    height_inches               INT         NOT NULL,
    CONSTRAINT PK_Donors_Medical_History PRIMARY KEY(medical_history_id)
);

-------------------------------------------------------------------------------------
CREATE TABLE Donors.Donor
(
    donor_id                INT         NOT NULL IDENTITY(1,1),
    first_name              VARCHAR(50) NOT NULL,
    middle_initial          VARCHAR(1)  NULL,
    last_name               VARCHAR(50) NOT NULL,
    birthdate               DATE        NOT NULL,
    age                     INT         NOT NULL,
    gender                  VARCHAR(10) NOT NULL,
    email                   VARCHAR(50) NOT NULL,
    phone_id                INT         NOT NULL,
    address_id              INT         NOT NULL,
    blood_type_id           INT         NULL,
    primary_provider_id     INT         NULL,
    emergency_contact_id    INT         NOT NULL,
    medical_history_id      INT         NOT NULL,
    CONSTRAINT PK_Donor PRIMARY KEY(donor_id),
    CONSTRAINT FK_Donors_Phone FOREIGN KEY(phone_id)
        REFERENCES Donors.Phone(phone_id),
    CONSTRAINT FK_Donors_Address FOREIGN KEY(address_id)
        REFERENCES Donors.Address(address_id),
    CONSTRAINT FK_Donors_Blood_Type FOREIGN KEY(blood_type_id)
        REFERENCES Donors.Blood_Type(blood_type_id),
    CONSTRAINT FK_Donors_Primary_Provider FOREIGN KEY(primary_provider_id)
        REFERENCES Donors.Healthcare_Provider(provider_id),
    CONSTRAINT FK_Donors_Emergency_Contact FOREIGN KEY(emergency_contact_id)
        REFERENCES Donors.Emergency_Contact(emergency_contact_id),
    CONSTRAINT FK_Donors_Medical_History FOREIGN KEY(medical_history_id)
        REFERENCES Donors.Medical_History(medical_history_id),
    CONSTRAINT CHK_birthdate CHECK(birthdate <= CAST(SYSDATETIME() AS DATE))
);

CREATE NONCLUSTERED INDEX idx_nc_donor_lastname               ON Donors.Donor(last_name);
CREATE NONCLUSTERED INDEX idx_nc_donor_birthdate              ON Donors.Donor(birthdate);
CREATE NONCLUSTERED INDEX idx_nc_donor_phone_id               ON Donors.Donor(phone_id);
CREATE NONCLUSTERED INDEX idx_nc_donor_address_id             ON Donors.Donor(address_id);
CREATE NONCLUSTERED INDEX idx_nc_donor_blood_type_id          ON Donors.Donor(blood_type_id);
CREATE NONCLUSTERED INDEX idx_nc_donor_primary_provider_id    ON Donors.Donor(primary_provider_id);
CREATE NONCLUSTERED INDEX idx_nc_donor_emergency_contact_id   ON Donors.Donor(emergency_contact_id);
CREATE NONCLUSTERED INDEX idx_nc_donor_medical_history_id     ON Donors.Donor(medical_history_id);

-------------------------------------------------------------------------------------
CREATE TABLE Medical_History.Medications
(
    medication_id           INT         NOT NULL IDENTITY(1,1),
    medication              VARCHAR(50) NOT NULL,
    CONSTRAINT PK_Medical_History_Medications PRIMARY KEY(medication_id)
);

-------------------------------------------------------------------------------------
CREATE TABLE Donors.Medications
(
    medical_history_id      INT     NOT NULL,
    medication_id           INT     NOT NULL,
    CONSTRAINT PK_Donors_Medications PRIMARY KEY(medical_history_id, medication_id),
    CONSTRAINT FK_Donors_Medical_History_Donors_Medications FOREIGN KEY(medical_history_id)
        REFERENCES Donors.Medical_History(medical_history_id),
    CONSTRAINT FK_Medical_History_Medications_Donors_Medications FOREIGN KEY(medication_id)
        REFERENCES Medical_History.Medications(medication_id)
);

-------------------------------------------------------------------------------------
CREATE TABLE Medical_History.Allergies
(
    allergy_id              INT         NOT NULL IDENTITY(1,1),
    allergy                 VARCHAR(50) NOT NULL,
    CONSTRAINT PK_Medical_History_Allergies PRIMARY KEY(allergy_id)
);

-------------------------------------------------------------------------------------
CREATE TABLE Donors.Allergies
(
    medical_history_id      INT         NOT NULL,
    allergy_id              INT         NOT NULL,
    CONSTRAINT PK_Donors_Allergies PRIMARY KEY(medical_history_id, allergy_id),
    CONSTRAINT FK_Donors_Medical_History_Donors_Allergies FOREIGN KEY(medical_history_id)
        REFERENCES Donors.Medical_History(medical_history_id),
    CONSTRAINT FK_Medical_History_Allergies_Donors_Allergies FOREIGN KEY(allergy_id)
        REFERENCES Medical_History.Allergies(allergy_id)
);

-------------------------------------------------------------------------------------
CREATE TABLE Medical_History.Immunizations
(
    immunization_id         INT         NOT NULL IDENTITY(1,1),
    immunization            VARCHAR(50) NOT NULL,
    CONSTRAINT PK_Medical_History_Immunizations PRIMARY KEY(immunization_id)
);

-------------------------------------------------------------------------------------
CREATE TABLE Donors.Immunizations
(
    medical_history_id      INT         NOT NULL,
    immunization_id         INT         NOT NULL,
    immunization_date       DATE        NULL,
    CONSTRAINT PK_Donors_Immunizations PRIMARY KEY(medical_history_id, immunization_id),
    CONSTRAINT FK_Donors_Medical_History_Donors_Immunizations FOREIGN KEY(medical_history_id)
        REFERENCES Donors.Medical_History(medical_history_id),
    CONSTRAINT FK_Medical_History_Immunizations_Donors_Immunizations FOREIGN KEY(immunization_id)
        REFERENCES Medical_History.Immunizations(immunization_id)
);

-------------------------------------------------------------------------------------
CREATE TABLE Medical_History.Surgical_Procedures
(
    surgical_procedure_id           INT             NOT NULL IDENTITY(1,1),
    surgical_procedure              VARCHAR(100)    NOT NULL,
    CONSTRAINT PK_Medical_History_Surgical_Procedures PRIMARY KEY(surgical_procedure_id)    
);

-------------------------------------------------------------------------------------
CREATE TABLE Donors.Surgical_Procedures
(
    medical_history_id          INT             NOT NULL,
    surgical_procedure_id       INT             NOT NULL,
    surgical_procedure_date     DATE            NULL,
    CONSTRAINT PK_Donors_Surgical_Procedure PRIMARY KEY(medical_history_id, surgical_procedure_id),
    CONSTRAINT FK_Donors_Medical_History_Donors_Surgical_Procedure FOREIGN KEY(medical_history_id)
        REFERENCES Donors.Medical_History(medical_history_id),
    CONSTRAINT FK_Medical_History_Surgical_Procedure_Donors_Surgical_Procedure FOREIGN KEY(surgical_procedure_id)
        REFERENCES Medical_History.Surgical_Procedures(surgical_procedure_id)
);
-------------------------------------------------------------------------------------
CREATE TABLE Medical_History.Family_History
(
    family_history_id           INT             NOT NULL IDENTITY(1,1),
    family_history_condition     VARCHAR(200)    NOT NULL,
    CONSTRAINT PK_Medical_History_Family_History PRIMARY KEY(family_history_id)
);

-------------------------------------------------------------------------------------
CREATE TABLE Donors.Family_History
(
    medical_history_id          INT             NOT NULL,
    family_history_id           INT             NOT NULL,
    CONSTRAINT PK_Donors_Family_History PRIMARY KEY(medical_history_id, family_history_id),
    CONSTRAINT FK_Donors_Medical_History_Donors_Family_History FOREIGN KEY(medical_history_id)
        REFERENCES Donors.Medical_History(medical_history_id),
    CONSTRAINT FK_Medical_History_Family_History_Donors_Family_History FOREIGN KEY(family_history_id)
        REFERENCES Medical_History.Family_History(family_history_id)
);

-------------------------------------------------------------------------------------
CREATE TABLE Medical_History.Health_Issues
(
    health_issue_id             INT             NOT NULL IDENTITY(1,1),
    health_issue                VARCHAR(200)    NOT NULL,
    CONSTRAINT PK_Medical_History_Health_Issues PRIMARY KEY(health_issue_id)
);

-------------------------------------------------------------------------------------
CREATE TABLE Donors.Health_Issues
(
    medical_history_id          INT             NOT NULL,
    health_issue_id             INT             NOT NULL,
    date_issue_began            DATE            NULL,
    CONSTRAINT PK_Donors_Health_Issues PRIMARY KEY(medical_history_id, health_issue_id),
    CONSTRAINT FK_Donors_Medical_History_Donors_Health_Issues FOREIGN KEY(medical_history_id)
        REFERENCES Donors.Medical_History(medical_history_id),
    CONSTRAINT FK_Medical_History_Health_Issues_Donors_Health_Issues FOREIGN KEY(health_issue_id)
        REFERENCES Medical_History.Health_Issues(health_issue_id)
);

-------------------------------------------------------------------------------------
CREATE TABLE Medical_History.Countries_Visited
(
    country_id              INT             NOT NULL IDENTITY(1,1),
    country_name            VARCHAR(100)    NOT NULL,
    CONSTRAINT PK_Medical_History_Countries_Visited PRIMARY KEY(country_id)
);

-------------------------------------------------------------------------------------
CREATE TABLE Donors.Countries_Visited
(
    medical_history_id      INT             NOT NULL,
    country_id              INT             NOT NULL,
    date_visited            DATE            NOT NULL,
    date_returned           DATE            NOT NULL,
    total_days_visited      INT             NOT NULL,
    CONSTRAINT PK_Donors_Countries_Visited PRIMARY KEY(medical_history_id, country_id),
    CONSTRAINT FK_Donors_Medical_History_Donors_Countries_Visited FOREIGN KEY(medical_history_id)
        REFERENCES Donors.Medical_History(medical_history_id),
    CONSTRAINT FK_Medical_History_Countries_Visited_Donors_Countries_Visited FOREIGN KEY(country_id)
        REFERENCES Medical_History.Countries_Visited(country_id)
);

-------------------------------------------------------------------------------------
CREATE TABLE Donors.Location
(
    location_id             INT             NOT NULL IDENTITY(1,1),
    location_name           VARCHAR(50)     NOT NULL,
    location_contact_name   VARCHAR(50)     NULL,
    location_contact_title  VARCHAR(50)     NULL,
    location_address        VARCHAR(50)     NOT NULL,
    location_city           VARCHAR(50)     NOT NULL,
    location_state          VARCHAR(2)      NOT NULL,
    location_zip            VARCHAR(5)      NOT NULL,
    CONSTRAINT PK_Blood_Drive_Donation PRIMARY KEY(location_id)        
);

-------------------------------------------------------------------------------------
CREATE TABLE Donors.Appointments
(
    appointment_id                      INT             NOT NULL IDENTITY(1,1),
    appointment_datetime                DATETIME        NOT NULL,
    appointment_cancelation_ind         BIT             NOT NULL,
    appointment_cancelation_datetime    DATETIME        NULL,
    location_id                         INT             NOT NULL,
    donor_id                            INT             NOT NULL,
    CONSTRAINT PK_Donors_Appointments PRIMARY KEY(appointment_id),
    CONSTRAINT FK_Donors_Location FOREIGN KEY(location_id)
        REFERENCES Donors.Location(location_id),
    CONSTRAINT FK_Donors_Donor_Donors_Appointments FOREIGN KEY(donor_id)
        REFERENCES Donors.Donor(donor_id)
);

CREATE NONCLUSTERED INDEX idx_nc_appointments_appointment_datetime      ON Donors.Appointments(appointment_datetime);
CREATE NONCLUSTERED INDEX idx_nc_appointments_cancelation_datetime      ON Donors.Appointments(appointment_cancelation_datetime);
CREATE NONCLUSTERED INDEX idx_nc_appointments_location_id               ON Donors.Appointments(location_id);
CREATE NONCLUSTERED INDEX idx_nc_appointments_donor_id                  ON Donors.Appointments(donor_id);

-------------------------------------------------------------------------------------
CREATE TABLE Donors.Donation
(
    donation_id                         INT             NOT NULL IDENTITY(1,1),
    donation_date                       DATE            NOT NULL,
    donation_amount                     INT             NOT NULL,
    donation_type                       VARCHAR(50)     NOT NULL,
    walk_in_ind                         BIT             NULL,
    donor_id                            INT             NOT NULL,
    appointment_id                      INT             NULL,
    location_id                         INT             NOT NULL,
    CONSTRAINT PK_Donors_Donation PRIMARY KEY(donation_id),
    CONSTRAINT FK_Donors_Donor_Donors_Donation FOREIGN KEY(donor_id)
        REFERENCES Donors.Donor(donor_id),
    CONSTRAINT FK_Donors_Appointments_Donors_Donations FOREIGN KEY(appointment_id)
        REFERENCES Donors.Appointments(appointment_id),
    CONSTRAINT FK_Donors_Location_Donors_Donation FOREIGN KEY(location_id)
        REFERENCES Donors.Location(location_id)
);

CREATE NONCLUSTERED INDEX idx_nc_donation_donor_id               ON Donors.Donation(donor_id);
CREATE NONCLUSTERED INDEX idx_nc_donation_appointment_id         ON Donors.Donation(appointment_id);
CREATE NONCLUSTERED INDEX idx_nc_donation_location_id            ON Donors.Donation(location_id);
CREATE NONCLUSTERED INDEX idx_nc_donation_donation_date          ON Donors.Donation(donation_date);

-------------------------------------------------------------------------------------
CREATE TABLE Lab.Location
(
    lab_id              INT NOT NULL IDENTITY(1,1),
    lab_name            VARCHAR(50) NOT NULL,
    lab_contact_name    VARCHAR(50) NULL,
    lab_contact_title   VARCHAR(50) NULL,
    lab_address         VARCHAR(50) NOT NULL,
    lab_city            VARCHAR(50) NOT NULL,
    lab_state           VARCHAR(2)  NOT NULL,
    lab_zip             VARCHAR(5)  NOT NULL,
    CONSTRAINT PK_Lab_Location PRIMARY KEY(lab_id)
);

-------------------------------------------------------------------------------------
CREATE TABLE Lab.Tests
(
    test_id         INT             NOT NULL IDENTITY(1,1),
    test_desc       VARCHAR(100)    NOT NULL,
    test_price      SMALLMONEY      NOT NULL,
    CONSTRAINT PK_Lab_Tests PRIMARY KEY(test_id),
);

CREATE NONCLUSTERED INDEX idx_nc_lab_tests_test_desc ON Lab.Tests(test_desc);

-------------------------------------------------------------------------------------
CREATE TABLE Lab.Orders
(
    order_id        INT             NOT NULL IDENTITY(1,1),
    order_date      DATETIME        NOT NULL,
    freight         SMALLMONEY      NOT NULL,
    ship_date       DATETIME        NOT NULL,
    donor_id        INT             NOT NULL,
    lab_id          INT             NOT NULL,
    CONSTRAINT PK_Lab_Orders PRIMARY KEY(order_id),
    CONSTRAINT FK_Donors_Donor_Lab_Orders FOREIGN KEY(donor_id)
        REFERENCES Donors.Donor(donor_id),
    CONSTRAINT FK_Lab_Location_Lab_Orders FOREIGN KEY(lab_id)
		REFERENCES Lab.Location(lab_id)
);

CREATE NONCLUSTERED INDEX idx_nc_orders_donor_id    ON Lab.Orders(donor_id);
CREATE NONCLUSTERED INDEX idx_nc_orders_lab_id      ON Lab.Orders(lab_id);
CREATE NONCLUSTERED INDEX idx_orders_order_date     ON Lab.Orders(order_date);
CREATE NONCLUSTERED INDEX idx_orders_ship_date      ON Lab.Orders(ship_date);

-------------------------------------------------------------------------------------
CREATE TABLE Lab.Order_Details
(
    order_id        INT         NOT NULL,
    test_id         INT         NOT NULL,
    test_price      SMALLMONEY  NOT NULL,
    test_date       DATETIME    NOT NULL,
    test_results    VARCHAR(50) NOT NULL,
    CONSTRAINT PK_Lab_Order_Details PRIMARY KEY(order_id, test_id),
    CONSTRAINT FK_Lab_Orders_Lab_Order_Details FOREIGN KEY(order_id)
        REFERENCES Lab.Orders(order_id),
    CONSTRAINT FK_Lab_Tests_Lab_Order_Details FOREIGN KEY(test_id)
        REFERENCES Lab.Tests(test_id)
);

CREATE NONCLUSTERED INDEX idx_nc_order_details_test_date    ON Lab.Order_Details(test_date);
CREATE NONCLUSTERED INDEX idx_nc_order_details_test_results ON Lab.Order_Details(test_results);






/* INSERT DATA */
-------------------------------------------------------------------------------------

USE GivingVein;
GO

INSERT INTO Donors.Provider_Type (provider_type)
VALUES
    ('MD'),
    ('DO'),
    ('Nurse-Practitioner'),
    ('Physician-Assistant'),
    ('Midwife')

INSERT INTO Donors.Blood_Type(blood_type_desc, rh_type)
    VALUES
        ('A RhD Positive', 'A+'),
        ('A RhD Negative', 'A-'),
        ('B RhD Positive', 'B+'),
        ('B RhD Negative', 'B-'),
        ('O RhD Positive', 'O+'),
        ('O RhD Negative', 'O-'),
        ('AB RhD Positive', 'AB+'),
        ('AB Rhd Negative', 'AB-');
    
INSERT INTO Medical_History.Medications (medication)
VALUES
    ('Atorvastatin'),
    ('Levothyroxine'),
    ('Metformin'),
    ('Lisinopril'),
    ('Amlodipine'),
    ('Metoprolol'),
    ('Albuterol'),
    ('Omeprazole'),
    ('Losartan'),
    ('Gabapentin'),
    ('Hydrochlorothiazide'),
    ('Sertraline'),
    ('Simvastatin'),
    ('Montelukast'),
    ('Hydrocodone'),
    ('Acetaminophen'),
    ('Trazodone'),
    ('Fluoxetine'),
    ('Ibuprofen'),
    ('Citalopram');

INSERT INTO Medical_History.Immunizations (immunization)
VALUES
    ('HepB'),
    ('Rotavirus'),
    ('DTaP'),
    ('Hib'),
    ('PCV13'),
    ('IPV'),
    ('Influenza'),
    ('MMR'),
    ('VAR'),
    ('HepA'),
    ('Tdap'),
    ('HPV'),
    ('Meningococcal'),
    ('Meningococcal B'),
    ('Pneumococcal Polysaccharide'),
    ('Dengue'),
    ('Varicella'),
    ('Rabies');


INSERT INTO Medical_History.Allergies (allergy)
VALUES
    ('Milk'),
    ('Egg'),
    ('Peanut'),
    ('Soy'),
    ('Wheat'),
    ('Tree Nut'),
    ('Shellfish'),
    ('Fish'),
    ('Sesame'),
    ('Gluten'),
    ('Corn'),
    ('Latex');

INSERT INTO Medical_History.Family_History (family_history_condition)
VALUES
    ('Lung cancer'),
    ('Colon cancer/rectal cancer'),
    ('Colon polyp'),
    ('Breast cancer'),
    ('Prostate cancer'),
    ('Ovarian cancer'),
    ('Pancreatic cancer'),
    ('Other cancer'),
    ('Heart disease'),
    ('Diabetes'),
    ('Asthma'),
    ('Eczema'),
    ('Migrane headache'),
    ('Seizure disorder'),
    ('Stroke'),
    ('High cholesterol'),
    ('Abnormal bleeding'),
    ('High or low white count'),
    ('High blood pressure'),
    ('Anemia'),
    ('Liver disease'),
    ('Hepatitis'),
    ('Arthritis'),
    ('Osteoporosis'),
    ('Alcohol abuse'),
    ('Recreational/street drug use'),
    ('Sexually transmitted disease'),
    ('Depression'),
    ('Tuberculosis'),
    ('Thyroid disease'),
    ('Kidney disease'),
    ('Bladder cancer'),
    ('Melanoma'),
    ('Rheumatoid arthritis'),
    ('Crohns disease'),
    ('Ulcerative colitis'),
    ('Gout');

            
INSERT INTO Medical_History.Health_Issues
VALUES
    ('Lung cancer'),
    ('Colon cancer/rectal cancer'),
    ('Colon polyp'),
    ('Breast cancer'),
    ('Prostate cancer'),
    ('Ovarian cancer'),
    ('Pancreatic cancer'),
    ('Other cancer'),
    ('Heart disease'),
    ('Diabetes'),
    ('Asthma'),
    ('Eczema'),
    ('Migrane headache'),
    ('Seizure disorder'),
    ('Stroke'),
    ('High cholesterol'),
    ('Abnormal bleeding'),
    ('High or low white count'),
    ('High blood pressure'),
    ('Anemia'),
    ('Liver disease'),
    ('Hepatitis'),
    ('Arthritis'),
    ('Osteoporosis'),
    ('Alcohol abuse'),
    ('Recreational/street drug use'),
    ('Sexually transmitted disease'),
    ('Depression'),
    ('Tuberculosis'),
    ('Anesthesia complications'),
    ('Genetic disorder'),
    ('COPD'),
    ('Thyroid disease'),
    ('Kidney disease'),
    ('Bladder cancer'),
    ('Melanoma'),
    ('Rheumatoid arthritis'),
    ('Crohns disease'),
    ('Ulcerative colitis'),
    ('Gout');

INSERT INTO Medical_History.Surgical_Procedures(surgical_procedure)
VALUES
    ('Appendectomy'),
    ('Breast biopsy'),
    ('Carotid endarterectomy'),
    ('Cataract surgery'),
    ('Cesarean section'),
    ('Cholecystectomy'),
    ('Coronary artery bypass'),
    ('Dilation and curettage (D & C)'),
    ('Free skin graft'),
    ('Hemorrhoidectomy'),
    ('Hysterectomy'),
    ('Hysteroscopy'),
    ('Inguinal hernia repair'),
    ('Low back pain surgery'),
    ('Mastectomy'),
    ('Partial colectomy'),
    ('Prostatectomy'),
    ('Tonsillectomy'),
    ('Appendix removal'),
    ('Gallbladder removal'),
    ('Hip replacement surgery'),
    ('Knee replacement surgery'),
    ('Laminectomy'),
    ('Laparoscopic hernia repair'),
    ('Lung resection'),
    ('Myomectomy'),
    ('Pancreas transplant'),
    ('Rhinoplasty'),
    ('Spinal fusion'),
    ('Thyroidectomy'),
    ('Transurethral resection of the prostate (TURP)'),
    ('Wisdom tooth extraction');


INSERT INTO Medical_History.Countries_Visited(country_name)
VALUES
    ('China'),
    ('Italy'),
    ('Turkey'),
    ('Mexico'),
    ('Thailand'),
    ('Germany'),
    ('United Kingdom'),
    ('France'),
    ('Spain'),
    ('Canada'),
    ('Australia'),
    ('Japan'),
    ('Brazil'),
    ('India'),
    ('South Africa'),
    ('Russia'),
    ('Egypt'),
    ('Greece'),
    ('Netherlands');

INSERT INTO Donors.Location(location_name, location_contact_name, location_contact_title, location_address, location_city, location_state, location_zip)
VALUES
    ('Madison High School', 'John Smith', 'Principal', '456 High Rd', 'Madison', 'MA', '01845'),
    ('St Luke Catholic Church', 'Mary Johnson', 'Pastor', '34 Street St', 'Hillsboro', 'MA', '01846'),
    ('YMCA', 'David Anderson', 'Manager', '332 Loc Ave', 'Madison', 'VA', '23412'),
    ('Hillside Park', 'Sarah Thompson', 'Park Manager', '789 Park Rd', 'Madison', 'FL', '32340'),
    ('Sunset Beach Resort', 'Michael Davis', 'General Manager', '10 Ocean Blvd', 'Madison', 'CA', '90210'),
    ('Greenwood Mall', 'Jennifer Wilson', 'Mall Manager', '456 Mall Dr', 'Madison', 'MS', '39110'),
    ('Riverside Elementary School', 'Robert Martinez', 'Principal', '234 School Ln', 'Madison', 'TX', '77864'),
    ('City Hall', 'Karen Adams', 'City Manager', '789 Civic Center', 'Madison', 'NY', '10001'),
    ('Madison Sports Complex', 'Steven Brown', 'Facility Manager', '123 Sports Ave', 'Madison', 'OH', '43074'),
    ('Lakeview Park', 'Amy Miller', 'Park Manager', '456 Lakeview Rd', 'Madison', 'IL', '62060'),
    ('Central Library', 'Thomas Wilson', 'Library Director', '789 Library St', 'Madison', 'WI', '53703'),
    ('Mountainside Resort', 'Michelle Thompson', 'General Manager', '234 Mountain Rd', 'Madison', 'CO', '80444'),
    ('Valley Medical Center', 'Andrew Johnson', 'Hospital Administrator', '789 Health Way', 'Madison', 'WA', '98002'),
    ('Northside Elementary School', 'Jessica Davis', 'Principal', '123 School Dr', 'Madison', 'KY', '40356'),
    ('Sunrise Senior Living', 'Daniel Brown', 'Community Manager', '456 Senior Ave', 'Madison', 'AZ', '85003'),
    ('Madison College', 'Emily Wilson', 'College President', '789 College Blvd', 'Madison', 'NC', '27025'),
    ('Pine Ridge Campground', 'Kevin Thompson', 'Campground Manager', '234 Campground Rd', 'Madison', 'TN', '37115'),
    ('Oceanfront Hotel', 'Jennifer Adams', 'Hotel Manager', '789 Ocean View', 'Madison', 'OR', '97402'),
    ('Madison Convention Center', 'Michael Smith', 'Event Coordinator', '123 Convention Dr', 'Madison', 'MN', '56256');



INSERT INTO Donors.Phone(phone_number)
VALUES
    ('1234567890'),
    ('2345678901'),
    ('3456789012'),
    ('4567890123'),
    ('5678901234'),
    ('6789012345'),
    ('7890123456'),
    ('8901234567'),
    ('9012345678'),
    ('0123456789'),
    ('1029384756'),
    ('9876543210'),
    ('8765432109'),
    ('7654321098'),
    ('6543210987'),
    ('5432109876'),
    ('4321098765'),
    ('3210987654'),
    ('2109876543'),
    ('1098765432'),
    ('0192837465'),
    ('8765123498'),
    ('7654231987'),
    ('6543120876'),
    ('5432019765'),
    ('4321908654'),
    ('3210897543'),
    ('2109786432'),
    ('1098675321'),
    ('0128765493'),
    ('9876534120'),
    ('8765423019'),
    ('7654312908'),
    ('6543201797'),
    ('5432190686'),
    ('4321089575'),
    ('3210978464'),
    ('2109867353'),
    ('1098756242'),
    ('0187655321'),
    ('9876544310'),
    ('8765433209'),
    ('7654322198'),
    ('6543211087'),
    ('5432109976'),
    ('4321098865'),
    ('3210987754'),
    ('2109876643'),
    ('1098765532'),
    ('0187654421'),
    ('9876543310'),
    ('8765432209'),
    ('7654321198'),
    ('6543210087');


INSERT INTO Donors.Address(address, city, state, zip)
VALUES
    ('48 Rosewood Lane', 'Methuen', 'MA', '01844'),
    ('123 Oak Street', 'Madison', 'VA', '23456'),
    ('456 Maple Avenue', 'Hillsboro', 'MA', '01846'),
    ('789 Pine Road', 'Methuen', 'MA', '01844'),
    ('321 Elm Court', 'Madison', 'VA', '23456'),
    ('654 Cedar Lane', 'Hillsboro', 'MA', '01846'),
    ('987 Birch Drive', 'Methuen', 'MA', '01844'),
    ('210 Walnut Street', 'Madison', 'VA', '23456'),
    ('543 Willow Avenue', 'Hillsboro', 'MA', '01846'),
    ('876 Spruce Road', 'Methuen', 'MA', '01844'),
    ('109 Cherry Court', 'Madison', 'VA', '23456'),
    ('018 Ivy Lane', 'Hillsboro', 'MA', '01846'),
    ('987 Pinecone Boulevard', 'Methuen', 'MA', '01844'),
    ('876 Acorn Avenue', 'Madison', 'VA', '23456'),
    ('765 Leaf Street', 'Hillsboro', 'MA', '01846'),
    ('654 Blossom Court', 'Methuen', 'MA', '01844'),
    ('543 Meadow Lane', 'Madison', 'VA', '23456'),
    ('432 Sunrise Avenue', 'Hillsboro', 'MA', '01846'),
    ('321 Sunset Road', 'Methuen', 'MA', '01844'),
    ('210 Lakeview Street', 'Madison', 'VA', '23456'),
    ('109 Mountain Drive', 'Hillsboro', 'MA', '01846'),
    ('018 River Court', 'Methuen', 'MA', '01844'),
    ('987 Beach Avenue', 'Madison', 'VA', '23456'),
    ('876 Ocean Road', 'Hillsboro', 'MA', '01846'),
    ('765 Seashell Lane', 'Methuen', 'MA', '01844'),
    ('654 Sandcastle Street', 'Madison', 'VA', '23456'),
    ('543 Lighthouse Court', 'Hillsboro', 'MA', '01846'),
    ('432 Harbor View Avenue', 'Methuen', 'MA', '01844'),
    ('321 Sailboat Lane', 'Madison', 'VA', '23456'),
    ('210 Anchor Drive', 'Hillsboro', 'MA', '01846'),
    ('109 Pier Road', 'Methuen', 'MA', '01844'),
    ('018 Marina Street', 'Madison', 'VA', '23456'),
    ('987 Yacht Avenue', 'Hillsboro', 'MA', '01846'),
    ('876 Seagull Road', 'Methuen', 'MA', '01844'),
    ('765 Dolphin Court', 'Madison', 'VA', '23456'),
    ('654 Whale Lane', 'Hillsboro', 'MA', '01846'),
    ('543 Coral Avenue', 'Methuen', 'MA', '01844'),
    ('432 Shellfish Street', 'Madison', 'VA', '23456'),
    ('321 Mermaid Lane', 'Hillsboro', 'MA', '01846'),
    ('210 Neptune Road', 'Methuen', 'MA', '01844'),
    ('109 Starfish Street', 'Madison', 'VA', '23456'),
    ('018 Seashore Lane', 'Hillsboro', 'MA', '01846'),
    ('987 Beachcomber Avenue', 'Methuen', 'MA', '01844'),
    ('876 Sanddollar Court', 'Madison', 'VA', '23456'),
    ('765 Wave Street', 'Hillsboro', 'MA', '01846'),
    ('654 Tide Lane', 'Methuen', 'MA', '01844'),
    ('543 Surfside Avenue', 'Madison', 'VA', '23456');


INSERT INTO Donors.Emergency_Contact(emergency_contact_first_name, emergency_contact_last_name, emergency_contact_phone)
VALUES
    ('John', 'Doe', '1234567890'),
    ('Jane', 'Smith', '9876543210'),
    ('Michael', 'Johnson', '5551234567'),
    ('Emily', 'Williams', '7778889999'),
    ('Daniel', 'Brown', '4445556666'),
    ('Olivia', 'Jones', '1112223333'),
    ('David', 'Miller', '9998887777'),
    ('Sophia', 'Davis', '3334445555'),
    ('James', 'Anderson', '6667778888'),
    ('Ava', 'Wilson', '2223334444'),
    ('Joseph', 'Taylor', '8889990000'),
    ('Mia', 'Thomas', '5556667777'),
    ('William', 'Martinez', '2223334444'),
    ('Isabella', 'Hernandez', '7778889999'),
    ('Benjamin', 'Lopez', '1112223333'),
    ('Emma', 'Gonzalez', '8889990000'),
    ('Alexander', 'Nelson', '3334445555'),
    ('Elizabeth', 'Moore', '6667778888'),
    ('Daniel', 'Taylor', '1112223333'),
    ('Sofia', 'Johnson', '4445556666'),
    ('Matthew', 'Lewis', '7778889999'),
    ('Chloe', 'Walker', '3334445555'),
    ('Andrew', 'Hall', '2223334444'),
    ('Ella', 'Young', '5556667777'),
    ('William', 'Lee', '1112223333'),
    ('Grace', 'Allen', '8889990000'),
    ('James', 'King', '2223334444'),
    ('Victoria', 'Wright', '6667778888'),
    ('Henry', 'Turner', '4445556666'),
    ('Lily', 'Scott', '3334445555'),
    ('Joseph', 'Adams', '5556667777'),
    ('Sophia', 'Green', '7778889999'),
    ('Daniel', 'Baker', '1112223333'),
    ('Olivia', 'Hill', '6667778888'),
    ('Matthew', 'Phillips', '5556667777'),
    ('Emily', 'Ross', '8889990000'),
    ('Jacob', 'Morris', '3334445555'),
    ('Ava', 'Peterson', '2223334444'),
    ('William', 'Rogers', '7778889999'),
    ('Sophia', 'Butler', '1112223333'),
    ('Daniel', 'Barnes', '4445556666'),
    ('Evelyn', 'Coleman', '6667778888'),
    ('Alexander', 'Simmons', '3334445555'),
    ('Olivia', 'Foster', '5556667777'),
    ('James', 'Gomez', '7778889999'),
    ('Charlotte', 'Perry', '8889990000'),
    ('Henry', 'Bell', '1112223333'),
    ('Mia', 'Powell', '4445556666'),
    ('Amelia', 'Long', '3334445555');


INSERT INTO Donors.Healthcare_Provider(provider_first_name, provider_last_name, provider_type_id)
VALUES
    ('John', 'Doe', 1),
    ('Jane', 'Smith', 2),
    ('Michael', 'Johnson', 3),
    ('Emily', 'Williams', 4),
    ('Daniel', 'Brown', 1),
    ('Olivia', 'Jones', 2),
    ('David', 'Miller', 3),
    ('Sophia', 'Davis', 4),
    ('James', 'Anderson', 1),
    ('Ava', 'Wilson', 2),
    ('Joseph', 'Taylor', 3),
    ('Mia', 'Thomas', 4),
    ('William', 'Martinez', 1),
    ('Isabella', 'Hernandez', 2),
    ('Benjamin', 'Lopez', 3),
    ('Emma', 'Gonzalez', 4),
    ('Alexander', 'Nelson', 1),
    ('Elizabeth', 'Moore', 2),
    ('Daniel', 'Taylor', 3),
    ('Sofia', 'Johnson', 4),
    ('Matthew', 'Lewis', 1),
    ('Chloe', 'Walker', 2),
    ('Andrew', 'Hall', 3),
    ('Ella', 'Young', 4),
    ('William', 'Lee', 1),
    ('Grace', 'Allen', 2),
    ('James', 'King', 3),
    ('Victoria', 'Wright', 4),
    ('Henry', 'Turner', 1),
    ('Lily', 'Scott', 2),
    ('Joseph', 'Adams', 3),
    ('Sophia', 'Green', 4),
    ('Daniel', 'Baker', 1),
    ('Olivia', 'Hill', 2),
    ('Matthew', 'Phillips', 3),
    ('Emily', 'Ross', 4),
    ('Jacob', 'Morris', 1),
    ('Ava', 'Peterson', 2),
    ('William', 'Rogers', 3),
    ('Sophia', 'Butler', 4);

INSERT INTO Donors.Medical_History(sexually_active_ind, exercise_ind, height_inches)
VALUES
    (1, 1, 65),
    (0, 1, 68),
    (1, 0, 72),
    (1, 1, 64),
    (0, 0, 70),
    (1, 1, 66),
    (0, 1, 69),
    (1, 0, 71),
    (1, 1, 67),
    (0, 0, 73),
    (1, 1, 63),
    (0, 1, 68),
    (1, 0, 70),
    (1, 1, 65),
    (0, 0, 72),
    (1, 1, 67),
    (0, 1, 69),
    (1, 0, 71),
    (1, 1, 66),
    (0, 0, 73),
    (1, 1, 64),
    (0, 1, 68),
    (1, 0, 70),
    (1, 1, 65),
    (0, 0, 72),
    (1, 1, 66),
    (0, 1, 69),
    (1, 0, 71),
    (1, 1, 67),
    (0, 0, 73),
    (1, 1, 63),
    (0, 1, 68),
    (1, 0, 70),
    (1, 1, 65),
    (0, 0, 72),
    (1, 1, 66),
    (0, 1, 69),
    (1, 0, 71),
    (1, 1, 67),
    (0, 0, 73),
    (1, 1, 64),
    (0, 1, 68),
    (1, 0, 70),
    (1, 1, 65),
    (0, 0, 72),
    (1, 1, 66),
    (0, 1, 69),
    (1, 0, 71),
    (1, 1, 67),
    (0, 0, 73);


INSERT INTO Donors.Donor(first_name, middle_initial, last_name, birthdate, age, gender, email, phone_id, address_id, blood_type_id, primary_provider_id, emergency_contact_id, medical_history_id)
VALUES
    ('Katie', 'A', 'McFly', '19860521', 36, 'f', 'katie.a.mcfly@yahoo.com', 1, 1, 6, 1, 1, 1),
    ('Johnathon', 'B', 'McFly', '19850302', 37, 'm', 'John.McFly@hotmail.com', 1, 1, 7, 1, 1, 2),
    ('Jane', 'C', 'Doe', '19901215', 31, 'f', 'jane.doe@gmail.com', 2, 2, 5, 2, 2, 3),
    ('Michael', 'D', 'Smith', '19780427', 44, 'm', 'michael.smith@gmail.com', 3, 3, 4, 3, 3, 4),
    ('Emily', 'E', 'Johnson', '19951010', 28, 'f', 'emily.johnson@gmail.com', 4, 4, 3, 4, 4, 5),
    ('David', 'F', 'Williams', '19821207', 39, 'm', 'david.williams@yahoo.com', 5, 5, 2, 5, 5, 6),
    ('Olivia', 'G', 'Brown', '19920819', 33, 'f', 'olivia.brown@hotmail.com', 6, 6, 1, 6, 6, 7),
    ('Daniel', 'H', 'Jones', '19891203', 32, 'm', 'daniel.jones@gmail.com', 7, 7, 7, 7, 7, 8),
    ('Sophia', 'I', 'Miller', '19930728', 29, 'f', 'sophia.miller@yahoo.com', 8, 8, 6, 8, 8, 9),
    ('James', 'J', 'Davis', '19871005', 34, 'm', 'james.davis@hotmail.com', 9, 9, 5, 9, 9, 10),
    ('Ava', 'K', 'Wilson', '19900415', 31, 'f', 'ava.wilson@gmail.com', 10, 10, 4, 10, 10, 11),
	('Benjamin', 'L', 'Thompson', '19831018', 38, 'm', 'benjamin.thompson@gmail.com', 11, 11, 3, 11, 11, 12),
    ('Charlotte', 'M', 'Clark', '19960907', 26, 'f', 'charlotte.clark@yahoo.com', 12, 12, 2, 12, 12, 13),
    ('Ethan', 'N', 'Lee', '19911025', 30, 'm', 'ethan.lee@hotmail.com', 13, 13, 1, 13, 13, 14),
    ('Amelia', 'O', 'Walker', '19940403', 29, 'f', 'amelia.walker@gmail.com', 14, 14, 7, 14, 14, 15),
    ('Alexander', 'P', 'Hall', '19881211', 33, 'm', 'alexander.hall@yahoo.com', 15, 15, 6, 15, 15, 16),
    ('Mia', 'Q', 'Gonzalez', '19930720', 28, 'f', 'mia.gonzalez@hotmail.com', 16, 16, 5, 16, 16, 17),
    ('Henry', 'R', 'White', '19870729', 34, 'm', 'henry.white@gmail.com', 17, 17, 4, 17, 17, 18),
    ('Harper', 'S', 'Robinson', '19910312', 31, 'f', 'harper.robinson@yahoo.com', 18, 18, 3, 18, 18, 19),
    ('Sebastian', 'T', 'Young', '19851124', 36, 'm', 'sebastian.young@gmail.com', 19, 19, 2, 19, 19, 20),
    ('Scarlett', 'U', 'Lewis', '19950609', 27, 'f', 'scarlett.lewis@hotmail.com', 20, 20, 1, 20, 20, 21),
	('Oliver', 'V', 'Wright', '19870415', 34, 'm', 'oliver.wright@gmail.com', 21, 21, 7, 21, 21, 22),
    ('Ava', 'W', 'Harris', '19950928', 27, 'f', 'ava.harris@yahoo.com', 22, 22, 6, 22, 22, 23),
    ('William', 'X', 'King', '19921103', 30, 'm', 'william.king@hotmail.com', 23, 23, 5, 23, 23, 24),
    ('Sophia', 'Y', 'Turner', '19931010', 28, 'f', 'sophia.turner@gmail.com', 24, 24, 4, 24, 24, 25),
    ('James', 'Z', 'Parker', '19890217', 32, 'm', 'james.parker@yahoo.com', 25, 25, 3, 25, 25, 26),
    ('Isabella', 'A', 'Collins', '19940904', 29, 'f', 'isabella.collins@hotmail.com', 26, 26, 2, 26, 26, 27),
    ('Benjamin', 'B', 'Scott', '19860621', 36, 'm', 'benjamin.scott@gmail.com', 27, 27, 1, 27, 27, 28),
    ('Emma', 'C', 'Bennett', '19921201', 30, 'f', 'emma.bennett@yahoo.com', 28, 28, 7, 28, 28, 29),
    ('Daniel', 'D', 'Bell', '19880406', 33, 'm', 'daniel.bell@hotmail.com', 29, 29, 6, 29, 29, 30),
    ('Mia', 'E', 'Reed', '19950913', 27, 'f', 'mia.reed@gmail.com', 30, 30, 5, 30, 30, 31)


INSERT INTO Donors.Medications(medical_history_id, medication_id)
VALUES
    (1, 3),
    (1, 2),
    (2, 6),
    (2, 4),
    (2, 3),
    (2, 8),
    (3, 5),
    (3, 2),
    (4, 1),
    (4, 7),
    (5, 6),
    (6, 4),
    (6, 9),
    (7, 3),
    (8, 10),
    (9, 8),
    (10, 6),
    (10, 5),
    (11, 2),
    (11, 9),
    (12, 7),
    (12, 4),
    (13, 3),
    (14, 6),
    (15, 10),
    (16, 8),
    (17, 5),
    (17, 9),
    (18, 1),
    (19, 6),
    (20, 2),
    (20, 4),
    (21, 3),
    (22, 8),
    (22, 7),
    (23, 5),
    (24, 9),
    (25, 6),
    (26, 4),
    (27, 3),
    (28, 10),
    (28, 8),
    (29, 5),
    (30, 9),
    (31, 6),
    (31, 2),
    (32, 4),
    (33, 3),
    (34, 8),
    (35, 7),
    (36, 5),
    (37, 9),
    (38, 6),
    (38, 2),
    (39, 4),
    (40, 3),
    (41, 8),
    (42, 7),
    (43, 5),
    (44, 9),
    (45, 6),
    (45, 2),
    (46, 4),
    (47, 3),
    (48, 8),
    (49, 7),
    (50, 5),
    (50, 9)

INSERT INTO Donors.Allergies(medical_history_id, allergy_id)
VALUES
    (1, 4),
    (1, 2),
    (2, 1),
    (2, 3),
    (3, 2),
    (3, 5),
    (4, 3),
    (4, 4),
    (5, 5),
    (5, 2),
    (6, 4),
    (6, 1),
    (7, 2),
    (7, 3),
    (8, 1),
    (8, 5),
    (9, 3),
    (9, 4),
    (10, 5),
    (10, 2),
    (11, 4),
    (11, 1),
    (12, 2),
    (12, 3),
    (13, 1),
    (13, 5),
    (14, 3),
    (14, 4),
    (15, 5),
    (15, 2),
    (16, 4),
    (16, 1),
    (17, 2),
    (17, 3),
    (18, 1),
    (18, 5),
    (19, 3),
    (19, 4),
    (20, 5),
    (20, 2),
    (21, 4),
    (21, 1),
    (22, 2),
    (22, 3),
    (23, 1),
    (23, 5),
    (24, 3),
    (24, 4),
    (25, 5),
    (25, 2)
 

INSERT INTO Donors.Immunizations(medical_history_id, immunization_id, immunization_date)
VALUES
    (1, 1, '09/01/1986'),
    (1, 2, NULL),
    (1, 3, '12/05/1986'),
    (1, 4, NULL),
    (1, 5, NULL),
    (2, 1, NULL),
    (2, 2, NULL),
    (2, 3, NULL),
    (2, 4, NULL),
    (2, 5, NULL),
    (2, 6, NULL),
    (3, 1, NULL),
    (3, 2, '01/10/1990'),
    (3, 3, NULL),
    (3, 4, NULL),
    (3, 5, '05/20/1991'),
    (4, 1, NULL),
    (4, 2, NULL),
    (4, 3, '03/15/1992'),
    (4, 4, NULL),
    (4, 5, NULL),
    (5, 1, '06/30/1993'),
    (5, 2, NULL),
    (5, 3, NULL),
    (5, 4, '09/25/1994'),
    (5, 5, NULL),
    (6, 1, NULL),
    (6, 2, '07/12/1995'),
    (6, 3, NULL),
    (6, 4, NULL),
    (6, 5, NULL),
    (7, 1, NULL),
    (7, 2, NULL),
    (7, 3, NULL),
    (7, 4, '02/05/1997'),
    (7, 5, NULL),
    (8, 1, '11/18/1998'),
    (8, 2, NULL),
    (8, 3, NULL),
    (8, 4, NULL),
    (8, 5, NULL),
    (9, 1, NULL),
    (9, 2, NULL),
    (9, 3, NULL),
    (9, 4, NULL),
    (9, 5, '08/22/2000'),
    (10, 1, '04/10/2001'),
    (10, 2, NULL),
    (10, 3, NULL),
    (10, 4, '12/30/2001'),
    (10, 5, NULL)

INSERT INTO Donors.Surgical_Procedures(medical_history_id, surgical_procedure_id, surgical_procedure_date)
VALUES
    (1, 3, '04/02/2015'),
    (2, 5, '08/10/2016'),
    (3, 2, '11/25/2017'),
    (4, 1, '06/15/2018'),
    (5, 4, '09/30/2019'),
    (6, 3, '02/17/2020'),
    (7, 6, '07/22/2021'),
	(16, 9, '01/08/2021'),
    (17, 10, '04/25/2022'),
    (18, 11, '08/05/2022'),
    (19, 12, '12/22/2013'),
    (20, 13, '03/16/2014')


INSERT INTO Donors.Family_History(medical_history_id, family_history_id)
VALUES
    (1, 2),
    (1, 4),
    (1, 6),
    (2, 5),
    (3, 1),
    (3, 3),
    (3, 6),
    (4, 2),
    (5, 2),
    (5, 6),
    (6, 3),
    (6, 4),
    (6, 5),
    (7, 1),
    (7, 2),
    (7, 6),
    (8, 2),
    (8, 3),
    (8, 4),
    (9, 1),
    (9, 3),
    (9, 5),
    (10, 2),
    (10, 4),
    (10, 6),
    (10, 1),
    (10, 3),
    (10, 5),
    (9, 2),
    (9, 4),
    (8, 1),
    (8, 5),
    (7, 3),
    (7, 4),
    (6, 2),
    (6, 6),
    (5, 1),
    (5, 3),
    (4, 4),
    (4, 5),
    (3, 2),
    (3, 4),
    (2, 1),
    (2, 3),
    (1, 5)

INSERT INTO Donors.Health_Issues(medical_history_id, health_issue_id)
VALUES
    (1, 3),
    (2, 7),
    (2, 4),
    (3, 5),
    (4, 2),
    (5, 3),
    (6, 10),
    (8, 6),
    (9, 5),
    (9, 7),
    (10, 9),
    (11, 2),
    (12, 4),
    (13, 3),
    (14, 10),
    (16, 5),
    (17, 9),
    (18, 6),
    (18, 2),
    (17, 4),
    (16, 3),
    (15, 8),
    (14, 7),
    (13, 5),
    (12, 9),
    (10, 2),
    (9, 4),
    (8, 3),
    (7, 8),
    (6, 7),
    (5, 5),
    (4, 9),
    (3, 6),
    (2, 2),
    (1, 4),
    (1, 6),
    (2, 1),
    (3, 3),
    (4, 5),
    (5, 7),
    (6, 4),
    (7, 6),
    (8, 8),
    (9, 10),
    (10, 4),
    (11, 6);


INSERT INTO Donors.Countries_Visited(medical_history_id, country_id, date_visited, date_returned, total_days_visited)
VALUES
    (1, 1, '07/08/2018', '07/22/2018', 14),
    (2, 3, '05/15/2019', '05/25/2019', 10),
    (3, 2, '09/03/2020', '09/10/2020', 7),
    (4, 1, '11/12/2017', '11/26/2017', 14),
    (5, 4, '03/05/2019', '03/10/2019', 5),
    (6, 3, '08/18/2020', '08/30/2020', 12),
    (7, 1, '06/22/2016', '07/05/2016', 14),
    (8, 2, '09/08/2019', '09/20/2019', 12),
    (9, 4, '04/16/2018', '04/25/2018', 9),
    (10, 3, '10/07/2020', '10/17/2020', 10);


INSERT INTO Donors.Appointments(appointment_datetime, appointment_cancelation_ind, appointment_cancelation_datetime, location_id, donor_id)
VALUES
    ('1/20/2023', 0, NULL, 1, 1),
    ('01/20/2023', 0, NULL, 1, 2),
    ('02/10/2023', 0, NULL, 2, 3),
    ('02/15/2023', 0, NULL, 3, 4),
    ('03/05/2023', 1, '02/28/2023', 4, 5),
    ('03/10/2023', 0, NULL, 1, 6),
    ('04/02/2023', 0, NULL, 2, 7),
    ('04/15/2023', 0, NULL, 3, 8),
    ('05/01/2023', 0, NULL, 4, 9),
    ('05/15/2023', 0, NULL, 1, 10),
    ('06/10/2023', 0, NULL, 2, 11),
    ('06/20/2023', 0, NULL, 3, 12),
    ('07/05/2023', 0, NULL, 4, 13),
    ('07/15/2023', 0, NULL, 1, 14),
    ('08/02/2023', 0, NULL, 2, 15),
    ('08/20/2023', 0, NULL, 3, 16),
    ('09/05/2023', 0, NULL, 4, 17),
    ('09/15/2023', 0, NULL, 1, 18),
    ('10/10/2023', 1, '10/08/2023', 2, 19),
    ('10/15/2023', 0, NULL, 3, 20),
    ('11/02/2023', 0, NULL, 4, 21),
    ('11/15/2023', 0, NULL, 1, 22),
    ('12/05/2023', 0, NULL, 2, 23),
    ('12/20/2023', 0, NULL, 3, 24),
    ('01/05/2024', 0, NULL, 4, 25),
    ('01/15/2024', 0, NULL, 1, 26),
    ('02/10/2024', 0, NULL, 2, 27),
    ('02/15/2024', 0, NULL, 3, 28),
    ('03/05/2024', 0, NULL, 4, 29),
    ('03/10/2024', 0, NULL, 1, 30);

INSERT INTO Donors.Donation(donation_date, donation_amount, donation_type, walk_in_ind, donor_id, appointment_id, location_id)
VALUES
    ('1/20/2023', 500, 'blood', 0, 1, 1, 1),
    ('1/20/2023', 500, 'blood', 0, 2, 2, 1),
    ('2/10/2023', 250, 'plasma', 1, 3, 3, 2),
    ('2/15/2023', 350, 'platelets', 0, 4, 4, 3),
    ('3/05/2023', 200, 'blood', 0, 5, 5, 4),
    ('3/10/2023', 300, 'plasma', 0, 6, 6, 1),
    ('4/02/2023', 400, 'blood', 0, 7, 7, 2),
    ('4/15/2023', 350, 'platelets', 0, 8, 8, 3),
    ('5/01/2023', 250, 'plasma', 0, 9, 9, 4),
    ('5/15/2023', 300, 'blood', 0, 10, 10, 1),
    ('6/10/2023', 400, 'plasma', 0, 11, 11, 2),
    ('6/20/2023', 350, 'platelets', 0, 12, 12, 3),
    ('7/05/2023', 250, 'plasma', 0, 13, 13, 4),
    ('7/15/2023', 300, 'blood', 0, 14, 14, 1),
    ('8/02/2023', 400, 'plasma', 0, 15, 15, 2),
    ('8/20/2023', 350, 'platelets', 0, 16, 16, 3),
    ('9/05/2023', 250, 'plasma', 0, 17, 17, 4),
    ('9/15/2023', 300, 'blood', 0, 18, 18, 1),
    ('10/10/2023', 400, 'plasma', 0, 19, 19, 2),
    ('10/15/2023', 350, 'platelets', 0, 20, 20, 3)


INSERT INTO Lab.Location(lab_name, lab_address, lab_city, lab_state, lab_zip)
VALUES
    ('Test R Us', '99 Test St', 'Needleville', 'PA', '46325'),
    ('Lab Co', '123 Lab Rd', 'Labville', 'CA', '90210'),
    ('MediLab', '456 Medical Ave', 'Healthtown', 'NY', '10001'),
    ('LabCorp', '789 Diagnostic Blvd', 'Diagnosisville', 'TX', '75001'),
    ('Precision Lab', '555 Accuracy St', 'Precisecity', 'FL', '33101');


INSERT INTO Lab.Tests(test_desc, test_price)
VALUES
    ('ABO Group', 20.00),
    ('Rh Type', 15.00),
    ('Trypanosoma cruzi', 34.00),
    ('Hep B', 42.00),
    ('Hep C', 36.00),
    ('HIV', 15.00),
    ('HTLV', 50.00),
    ('Syphilis', 36.00),
    ('Zika', 12.00),
    ('West Nile Virus', 10.00),
    ('Influenza A', 25.00),
    ('Influenza B', 25.00),
    ('Chlamydia', 30.00),
    ('Gonorrhea', 30.00),
    ('Herpes Simplex Virus', 18.00),
    ('Human Papillomavirus', 40.00),
    ('Cytomegalovirus', 22.00),
    ('Epstein-Barr Virus', 24.00),
    ('Lyme Disease', 28.00),
    ('Malaria', 32.00),
    ('Measles', 15.00),
    ('Mumps', 15.00),
    ('Rubella', 15.00),
    ('Varicella', 20.00),
    ('H. pylori', 28.00),
    ('Tuberculosis', 35.00),
    ('Streptococcus', 18.00),
    ('Salmonella', 20.00),
    ('E. coli', 20.00),
    ('C. difficile', 32.00),
    ('MRSA', 30.00),
    ('Cancer Marker Panel', 75.00),
    ('Thyroid Function', 28.00),
    ('Lipid Profile', 30.00),
    ('Complete Blood Count', 15.00),
    ('Basic Metabolic Panel', 40.00),
    ('Liver Function Tests', 35.00),
    ('Kidney Function Tests', 32.00),
    ('Coagulation Panel', 28.00),
    ('Diabetes Screening', 18.00),
    ('Urinalysis', 10.00),
    ('Fecal Occult Blood Test', 15.00),
    ('Pregnancy Test', 12.00),
    ('Allergy Panel', 50.00),
    ('Cardiac Enzymes', 24.00),
    ('Electrolyte Panel', 30.00),
    ('Thyroid Stimulating Hormone', 18.00),
    ('Vitamin D', 28.00),
    ('C-reactive Protein', 20.00),
    ('Prostate-Specific Antigen', 36.00),
    ('Iron Studies', 32.00),
    ('Rheumatoid Factor', 24.00);

INSERT INTO Lab.Orders(order_date, freight, ship_date, donor_id, lab_id)
VALUES
    ('01/22/2023', 35.12, '01/23/2023', 1, 1),
    ('01/21/2023', 30.23, '02/23/2023', 2, 1),
    ('03/15/2023', 22.50, '03/16/2023', 3, 1),
    ('04/02/2023', 18.75, '04/03/2023', 4, 1),
    ('05/12/2023', 40.00, '05/15/2023', 5, 1),
    ('06/08/2023', 27.80, '06/09/2023', 6, 1),
    ('07/01/2023', 15.40, '07/02/2023', 7, 1),
    ('08/19/2023', 32.90, '08/20/2023', 8, 1),
    ('09/25/2023', 12.60, '09/26/2023', 9, 1),
    ('10/14/2023', 28.75, '10/15/2023', 10, 1),
    ('11/27/2023', 20.50, '11/28/2023', 11, 1),
    ('12/05/2023', 36.80, '12/06/2023', 12, 1),
    ('02/10/2023', 25.30, '02/11/2023', 13, 1),
    ('03/03/2023', 17.90, '03/04/2023', 14, 1),
    ('04/18/2023', 42.50, '04/19/2023', 15, 1),
    ('05/29/2023', 23.70, '05/30/2023', 16, 1),
    ('06/14/2023', 38.20, '06/15/2023', 17, 1),
    ('07/27/2023', 16.80, '07/28/2023', 18, 1),
    ('08/08/2023', 30.10, '08/09/2023', 19, 1),
    ('09/17/2023', 14.50, '09/18/2023', 20, 1);


INSERT INTO Lab.Order_Details(order_id, test_id, test_price, test_date, test_results)
VALUES
    (1, 1, 20.00, '01/25/2023', 'O'),
    (1, 2, 15.00, '01/25/2023', 'O-'),
    (1, 4, 42.00, '01/25/2023', 'negative'),
    (1, 5, 36.00, '01/25/2023', 'negative'),
    (1, 6, 15.00, '01/25/2023', 'negative'),
    (2, 1, 20.00, '01/26/2023', 'AB'),
    (2, 2, 15.00, '01/26/2023', 'AB+'),
    (2, 3, 34.00, '01/26/2023', 'negative'),
    (2, 4, 42.00, '01/26/2023', 'negative'),
    (2, 5, 36.00, '01/26/2023', 'negative'),
    (2, 6, 15.00, '01/26/2023', 'negative'),
    (2, 7, 50.00, '01/26/2023', 'negative'),
    (2, 8, 36.00, '01/26/2023', 'negative'),
    (3, 1, 20.00, '01/27/2023', 'A+'),
    (3, 2, 15.00, '01/27/2023', 'A-'),
    (3, 3, 34.00, '01/27/2023', 'negative'),
    (3, 4, 42.00, '01/27/2023', 'negative'),
    (3, 5, 36.00, '01/27/2023', 'negative'),
    (3, 6, 15.00, '01/27/2023', 'negative'),
    (3, 7, 50.00, '01/27/2023', 'negative'),
    (3, 8, 36.00, '01/27/2023', 'negative'),
    (4, 1, 20.00, '01/28/2023', 'B-'),
    (4, 2, 15.00, '01/28/2023', 'B+'),
    (4, 3, 34.00, '01/28/2023', 'negative'),
    (4, 4, 42.00, '01/28/2023', 'negative'),
    (4, 5, 36.00, '01/28/2023', 'negative'),
    (4, 6, 15.00, '01/28/2023', 'negative'),
    (4, 7, 50.00, '01/28/2023', 'negative'),
    (4, 8, 36.00, '01/28/2023', 'negative'),
    (5, 1, 20.00, '01/29/2023', 'O+'),
    (5, 2, 15.00, '01/29/2023', 'O-'),
    (5, 3, 34.00, '01/29/2023', 'negative'),
    (5, 4, 42.00, '01/29/2023', 'negative'),
    (5, 5, 36.00, '01/29/2023', 'negative'),
    (5, 6, 15.00, '01/29/2023', 'negative'),
    (5, 7, 50.00, '01/29/2023', 'negative'),
    (5, 8, 36.00, '01/29/2023', 'negative'),
    (6, 1, 20.00, '01/30/2023', 'AB+'),
    (6, 2, 15.00, '01/30/2023', 'AB-'),
    (6, 3, 34.00, '01/30/2023', 'negative'),
    (6, 4, 42.00, '01/30/2023', 'negative'),
    (6, 5, 36.00, '01/30/2023', 'negative'),
    (6, 6, 15.00, '01/30/2023', 'negative'),
    (6, 7, 50.00, '01/30/2023', 'negative'),
    (6, 8, 36.00, '01/30/2023', 'negative'),
    (7, 1, 20.00, '01/31/2023', 'A-'),
    (7, 2, 15.00, '01/31/2023', 'A+'),
    (7, 3, 34.00, '01/31/2023', 'negative'),
    (7, 4, 42.00, '01/31/2023', 'negative'),
    (7, 5, 36.00, '01/31/2023', 'negative'),
    (7, 6, 15.00, '01/31/2023', 'negative'),
    (7, 7, 50.00, '01/31/2023', 'negative'),
    (7, 8, 36.00, '01/31/2023', 'negative'),
    (8, 21, 15.00, '01/31/2023', 'positive'),
    (8, 24, 20.00, '01/31/2023', 'negative'),
    (8, 6, 15.00, '01/30/2023', 'negative'),
    (8, 7, 50.00, '01/30/2023', 'negative'),
    (9, 5, 36.00, '01/28/2023', 'negative'),
    (9, 6, 15.00, '01/28/2023', 'negative'),
    (9, 7, 50.00, '01/28/2023', 'negative'),
    (9, 8, 36.00, '01/28/2023', 'negative'),
    (10, 1, 20.00, '01/29/2023', 'O+'),
    (10, 2, 15.00, '01/29/2023', 'O-'),
    (10, 3, 34.00, '01/29/2023', 'negative'),
    (10, 4, 42.00, '01/29/2023', 'negative'),
    (11, 1, 20.00, '02/05/2023', 'AB+'),
    (12, 2, 15.00, '02/05/2023', 'AB-'),
    (13, 3, 34.00, '02/05/2023', 'negative'),
    (13, 4, 42.00, '02/05/2023', 'negative'),
    (13, 5, 36.00, '02/05/2023', 'negative'),
    (14, 6, 15.00, '02/05/2023', 'negative'),
    (14, 7, 50.00, '02/05/2023', 'negative'),
    (14, 8, 36.00, '02/05/2023', 'negative'),
    (14, 1, 20.00, '02/05/2023', 'A-'),
    (15, 2, 15.00, '02/11/2023', 'A+'),
    (15, 3, 34.00, '02/11/2023', 'negative'),
    (15, 4, 42.00, '02/11/2023', 'negative'),
    (15, 5, 36.00, '02/11/2023', 'negative'),
    (15, 6, 15.00, '02/11/2023', 'negative'),
    (15, 7, 50.00, '02/11/2023', 'negative'),
    (15, 8, 36.00, '02/11/2023', 'negative'),
    (16, 1, 20.00, '02/18/2023', 'B-'),
    (16, 2, 15.00, '02/18/2023', 'B+'),
    (16, 3, 34.00, '02/18/2023', 'negative'),
    (17, 4, 42.00, '02/18/2023', 'negative'),
    (17, 1, 20.00, '03/04/2023', 'A-'),
    (18, 2, 15.00, '03/04/2023', 'A+'),
    (18, 3, 34.00, '03/04/2023', 'negative'),
    (18, 4, 42.00, '03/04/2023', 'negative'),
    (18, 5, 36.00, '03/04/2023', 'negative'),
    (18, 6, 15.00, '03/04/2023', 'negative'),
    (18, 7, 50.00, '03/04/2023', 'negative'),
    (18, 8, 36.00, '03/04/2023', 'negative'),
    (19, 6, 15.00, '02/11/2023', 'negative'),
    (19, 7, 50.00, '02/11/2023', 'negative'),
    (19, 8, 36.00, '02/11/2023', 'negative'),
    (19, 1, 20.00, '02/18/2023', 'B-'),
    (20, 2, 15.00, '02/18/2023', 'B+'),
    (20, 3, 34.00, '02/18/2023', 'negative'),
    (20, 4, 42.00, '02/18/2023', 'negative');




