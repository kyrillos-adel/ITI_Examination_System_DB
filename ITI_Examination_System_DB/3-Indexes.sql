USE [ITI-Examination-System-DB];
GO

-- UserLogin Table
-- Index on Email for fast authentication
CREATE NONCLUSTERED INDEX IDX_UserLogin_Email 
ON UserLogin (Email);
GO

-- Index on Role for authorization checks
CREATE NONCLUSTERED INDEX IDX_UserLogin_Role 
ON UserLogin (Role);
GO

-- Student Table
-- Index on NationalID for fast lookups and uniqueness checks
CREATE NONCLUSTERED INDEX IDX_Student_NationalID 
ON Student (NationalID);
GO

-- Index on UserID for joining with UserLogin
CREATE NONCLUSTERED INDEX IDX_Student_UserID 
ON Student (UserID);
GO

-- Instructor Table
-- Index on NationalID for fast lookups and uniqueness checks
CREATE NONCLUSTERED INDEX IDX_Instructor_NationalID 
ON Instructor (NationalID);
GO

-- Index on UserID for joining with UserLogin
CREATE NONCLUSTERED INDEX IDX_Instructor_UserID 
ON Instructor (UserID);
GO

-- Course Table
-- Index on CourseName for fast search by name
CREATE NONCLUSTERED INDEX IDX_Course_CourseName 
ON Course (CourseName);
GO

-- Exam Table
-- Index on CourseID for joining with Course
CREATE NONCLUSTERED INDEX IDX_Exam_CourseID 
ON Exam (CourseID);
GO


-- Question Table
-- Index on CourseID for joining with Course
CREATE NONCLUSTERED INDEX IDX_Question_CourseID 
ON Question (CourseID);
GO

-- Index on Type for filtering by question type
CREATE NONCLUSTERED INDEX IDX_Question_Type 
ON Question (Type);
GO

-- Student_Answer Table
-- Index on StudentExamID and QuestionID for faster answer retrieval
CREATE NONCLUSTERED INDEX IDX_StudentAnswer_Exam_Question 
ON Student_Answer (StudentExamID, QestionID);
GO
