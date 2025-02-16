--CREATE DATABASE [ITI-Examination-System-DB];
GO
USE [ITI-Examination-System-DB];
GO

-- Department Table
CREATE TABLE Department 
(
    ID INT IDENTITY PRIMARY KEY,
    DeptName VARCHAR(50) NOT NULL
) ON [DataGroup];

-- Track Table
CREATE TABLE Track
(
    ID INT IDENTITY PRIMARY KEY,
    TrackName VARCHAR(50) NOT NULL,
    DeptID INT,
    FOREIGN KEY (DeptID) REFERENCES Department(ID) ON DELETE SET NULL ON UPDATE CASCADE
) ON [DataGroup];

-- Intake Table
CREATE TABLE Intake
(
    ID INT IDENTITY PRIMARY KEY,
	Code VARCHAR(10) UNIQUE, -- Debated
    Year DATE NOT NULL,
	Duration INT,
    ProgramName CHAR(3) NOT NULL CHECK (ProgramName IN('ICC', 'PTP'))
) ON [DataGroup];

-- Intake_Track Table
CREATE TABLE Intake_Track
(
    IntakeID INT NOT NULL,
    TrackID INT NOT NULL,
    PRIMARY KEY (IntakeID, TrackID),
    FOREIGN KEY (IntakeID) REFERENCES Intake(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (TrackID) REFERENCES Track(ID) ON DELETE CASCADE ON UPDATE CASCADE
) ON [DataGroup];


-- Identity Table 
CREATE TABLE UserLogin
(
	ID INT Identity PRIMARY KEY,
	Email VARCHAR(40) UNIQUE NOT NULL CHECK(Email LIKE '_%@_%._%'),
	Password VARBINARY(64) NOT NULL,
    role varchar(20) NOT NULL CHECK(role IN('Admin','Training Manager', 'Instructor' ,'Student'))
) ON [DataGroup];

-- Instructor Table
CREATE TABLE Instructor
(
    ID INT IDENTITY PRIMARY KEY,
	UserID INT NOT NULL,
    Name VARCHAR(50) NOT NULL,
    NationalID CHAR(14) UNIQUE NOT NULL,
    TrainingManagerID INT,
	FOREIGN KEY (TrainingManagerID) REFERENCES Instructor(ID) ON DELETE NO ACTION ON UPDATE NO ACTION,
	FOREIGN KEY (UserID) REFERENCES UserLogin(ID) ON DELETE CASCADE ON UPDATE CASCADE
) ON [DataGroup];

-- Instructor Phone Numbers Table
CREATE TABLE Instructor_Phone 
(
    InsID INT NOT NULL,
    PhoneNumber CHAR(11) NOT NULL CHECK(PhoneNumber LIKE '01[0125][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    PRIMARY KEY (InsID, PhoneNumber),
    FOREIGN KEY (InsID) REFERENCES Instructor(ID) ON DELETE CASCADE ON UPDATE CASCADE
) ON [DataGroup];

-- Student Table
CREATE TABLE Student
(
    ID INT IDENTITY PRIMARY KEY,
	UserID INT NOT NULL,
    Name VARCHAR(50) NOT NULL,
    NationalID CHAR(14) UNIQUE NOT NULL,
    DateOfBirth DATE NOT NULL,
    GraduationYear DATE NOT NULL,
    FOREIGN KEY (UserID) REFERENCES UserLogin(ID) ON DELETE CASCADE ON UPDATE CASCADE

) ON [DataGroup];

-- Student Phone Numbers Table
CREATE TABLE Student_phone
(
    StudID INT NOT NULL,
    PhoneNumber CHAR(11) NOT NULL CHECK(PhoneNumber LIKE '01[0125][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    PRIMARY KEY (StudID, PhoneNumber),
    FOREIGN KEY (StudID) REFERENCES Student(ID) ON DELETE CASCADE ON UPDATE CASCADE
) ON [DataGroup];

-- Branch Table
CREATE TABLE Branch 
(
    ID INT IDENTITY PRIMARY KEY,
    BranchManagerID INT,
    BranchLocation VARCHAR(50) NOT NULL,
	Email VARCHAR(40) CHECK(Email LIKE '_%@_%._%'),
	FOREIGN KEY (BranchManagerID) REFERENCES Instructor(ID) ON DELETE SET NULL ON UPDATE CASCADE
) ON [DataGroup];

-- Branch Phone Numbers Table
CREATE TABLE Branch_phone
(
    BranchID INT NOT NULL,
    PhoneNumber CHAR(11) NOT NULL CHECK(PhoneNumber LIKE '01[0125][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    PRIMARY KEY (BranchID, PhoneNumber),
    FOREIGN KEY (BranchID) REFERENCES Branch(ID) ON DELETE CASCADE ON UPDATE CASCADE
) ON [DataGroup];

-- Branch Track Table
CREATE TABLE branch_track 
(
    BranchID INT NOT NULL,
    TrackID INT NOT NULL,
    PRIMARY KEY (BranchID, TrackID),
    FOREIGN KEY (BranchID) REFERENCES Branch(ID) ON DELETE CASCADE,
    FOREIGN KEY (TrackID) REFERENCES Track(ID) ON DELETE CASCADE
) ON [DataGroup];

-- Student Branch Track Intake Table
CREATE TABLE Stud_branch_Track_Intake 
(
    StudID INT NOT NULL,
    BranchID INT NOT NULL,
    TrackID INT NOT NULL,
    IntakeID INT NOT NULL,
    PRIMARY KEY (StudID, BranchID, TrackID, IntakeID),
    FOREIGN KEY (StudID) REFERENCES Student(ID) ,
    FOREIGN KEY (BranchID) REFERENCES Branch(ID),
    FOREIGN KEY (TrackID) REFERENCES Track(ID),
    FOREIGN KEY (IntakeID) REFERENCES Intake(ID)
) ON [DataGroup];

-- Course Table
CREATE TABLE Course 
(
    ID INT IDENTITY PRIMARY KEY,
    CourseName VARCHAR(40) NOT NULL,
    Description VARCHAR(MAX),
    MaxDegree INT NOT NULL,
    MinDegree INT NOT NULL
) ON [DataGroup];

-- Course Track Table
CREATE TABLE Course_Track 
(
    CourseID INT,
    TrackID INT,
    PRIMARY KEY (CourseID, TrackID),
    FOREIGN KEY (CourseID) REFERENCES Course(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (TrackID) REFERENCES Track(ID) ON DELETE CASCADE ON UPDATE CASCADE
) ON [DataGroup];

-- Instructor Course Table
CREATE TABLE Instructor_Course
(
    InsID INT,
    CourseID INT,
    PRIMARY KEY (InsID, CourseID),
    FOREIGN KEY (InsID) REFERENCES Instructor(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (CourseID) REFERENCES Course(ID) ON DELETE CASCADE ON UPDATE CASCADE
) ON [DataGroup];

-- Exam Table
CREATE TABLE Exam 
(
    ID INT IDENTITY PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    StartTime DATETIME NOT NULL,
    EndTime AS DATEADD(MINUTE, Duration, StartTime),
    Duration INT NOT NULL,
    Type CHAR(1) NOT NULL CHECK(Type IN ('N', 'C')), -- N for Normal, C for Corrective
	TotalGrade INT,
    CourseID INT NOT NULL,
    FOREIGN KEY (CourseID) REFERENCES Course(ID) ON DELETE CASCADE
) ON [DataGroup];

-- Question Table
CREATE TABLE Question 
(
    ID INT IDENTITY PRIMARY KEY,
    Content VARCHAR(MAX) NOT NULL,
    Type CHAR(3) NOT NULL CHECK(Type IN ('MCQ', 'T&F', 'TXT')),
    CourseID INT NOT NULL,
    FOREIGN KEY (CourseID) REFERENCES Course(ID) ON DELETE CASCADE
) ON [DataGroup];

-- Exam Question Table
CREATE TABLE Exam_Question (
    QuestionID INT,
    ExamID INT,
    Degree INT NOT NULL CHECK (Degree > 0),
    PRIMARY KEY (QuestionID, ExamID),
    FOREIGN KEY (QuestionID) REFERENCES Question(ID),
    FOREIGN KEY (ExamID) REFERENCES Exam(ID) ON DELETE CASCADE
) ON [DataGroup];

-- Choice Table
CREATE TABLE Choice
(
    ID INT IDENTITY PRIMARY KEY,   
    Content VARCHAR(MAX) NOT NULL,  
    QuestionID INT NOT NULL,       
    IsCorrect BIT NOT NULL DEFAULT 0,      
    FOREIGN KEY (QuestionID) REFERENCES Question(ID) ON DELETE CASCADE ON UPDATE CASCADE,
) ON [DataGroup];

-- Student Exam Table
CREATE TABLE Result
(
	ID INT IDENTITY PRIMARY KEY, 
    StudID INT NOT NULL, 
    ExamID INT NOT NULL,
    Grade INT,
	Status VARCHAR(8) default 'Pending' CHECK(status in('Pending','Finished','Absent')),
    FOREIGN KEY (StudID) REFERENCES Student(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ExamID) REFERENCES Exam(ID) ON DELETE CASCADE ON UPDATE CASCADE
) ON [DataGroup];

-- Student Exam Answer Table
CREATE TABLE Student_Answer
(
    StudentExamID INT NOT NULL,
    QestionID INT NOT NULL,
    Choice VARCHAR(MAX) NOT NULL,
    PRIMARY KEY (StudentExamID, QestionID),
    FOREIGN KEY (StudentExamID) REFERENCES RESULT(ID) ON DELETE No ACTION ON UPDATE CASCADE,
    FOREIGN KEY (QestionID) REFERENCES Question(ID) ON DELETE CASCADE ON UPDATE CASCADE
) ON [DataGroup];


-- Student Course Table
CREATE TABLE Student_Course
(
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    PRIMARY KEY (StudentID, CourseID),
    FOREIGN KEY (StudentID) REFERENCES Student(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (CourseID) REFERENCES Course(ID) ON DELETE CASCADE ON UPDATE CASCADE,
) ON [DataGroup];


-- Instructor Exam Table
CREATE TABLE Instructor_Exam
(
    InstructorID INT NOT NULL,
    ExamID INT NOT NULL,
    PRIMARY KEY (InstructorID, ExamID),
    FOREIGN KEY (InstructorID) REFERENCES Instructor(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ExamID) REFERENCES Exam(ID) ON DELETE CASCADE ON UPDATE CASCADE
) ON [DataGroup];

