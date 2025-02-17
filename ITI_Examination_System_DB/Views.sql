USE [ITI-Examination-System-DB];
GO

-- View List of Students in Each Course
create view vw_StudentCourseList
as 
select
    sc.StudentID, 
    s.Name, 
    sc.CourseID, 
    c.CourseName
from [dbo].[Student_Course] sc
join [dbo].[Student] s on sc.StudentID = s.ID
join [dbo].[Course] c on sc.CourseID = c.ID

-- vw_StudentCourseList			>> View List of Students in Each Course

GO
-- view Student Performance in assigned exams  
CREATE OR ALTER VIEW vw_ExamAssignments AS
SELECT 
    S.ID AS StudentID,
    S.Name AS StudentName,
    E.ID AS ExamID,
    E.Name AS ExamName,
    C.CourseName,
    R.Grade,
    
    -- Calculate Exam Status based on current time
    CASE 
        WHEN GETDATE() < E.EndTime THEN 'Pending'  -- Exam is still ongoing
        WHEN R.Grade IS NULL THEN 'Absent'        -- Exam ended, but no grade = absent
        ELSE 'Finished'                           -- Exam ended, and student has a grade
    END AS ExamStatus,

    -- Determine Exam Result only if the exam is finished
    CASE 
        WHEN GETDATE() < E.EndTime THEN NULL       -- Exam still ongoing
        WHEN R.Grade IS NULL THEN NULL            -- Student is absent
        WHEN R.Grade >= C.MinDegree THEN 'Pass'   -- Student passed
        ELSE 'Fail'                               -- Student failed
    END AS ExamResult

FROM Result R
JOIN Student S ON R.StudID = S.ID
JOIN Exam E ON R.ExamID = E.ID
JOIN Course C ON E.CourseID = C.ID;
GO


----------------------------------------------------------------

go 
-- view Student Assignments
CREATE OR ALTER VIEW vw_StudentAssignments AS
SELECT 
    s.ID AS StudentID,
    s.Name AS StudentName,
    b.BranchLocation,
    t.TrackName,
    i.Year AS IntakeYear,
    i.ProgramName
FROM Stud_branch_Track_Intake sbti
JOIN Student s ON sbti.StudID = s.ID
JOIN Branch b ON sbti.BranchID = b.ID
JOIN Track t ON sbti.TrackID = t.ID
JOIN Intake i ON sbti.IntakeID = i.ID;
GO

-----Training Manager view Report(studentID, StudentNAme,ExamID,ExamName,CourseName,CourseName,Grade,ExamStatus(pending,finished,Absent),ExamResult(pass, faild,null),TrackName,InTakeCode,BranchLocation)
GO
CREATE OR ALTER VIEW vw_TrainingManagerReport AS
SELECT 
    S.ID AS StudentID,
    S.Name AS StudentName,
    E.ID AS ExamID,
    E.Name AS ExamName,
    C.CourseName,
    R.Grade,
    R.Status AS ExamStatus,
    CASE 
        WHEN R.Status = 'Finished' AND R.Grade >= C.MinDegree THEN 'Pass'
        WHEN R.Status = 'Finished' AND R.Grade < C.MinDegree THEN 'Fail'
        ELSE NULL
    END AS ExamResult,
    T.TrackName,
    I.Code AS IntakeCode,
    B.BranchLocation
FROM Result R
JOIN Student S ON R.StudID = S.ID
JOIN Exam E ON R.ExamID = E.ID
JOIN Course C ON E.CourseID = C.ID
JOIN Stud_branch_Track_Intake ST ON S.ID = ST.StudID
JOIN Track T ON ST.TrackID = T.ID
JOIN Intake I ON ST.IntakeID = I.ID
JOIN Branch B ON ST.BranchID = B.ID;
GO
-- vw_ExamAssignments  >> view Student Performance in assigned exams
-- vw_StudentAssignments >> view Student Assignments  to branch, track and intake
-- vw_TrainingManagerReport >> Training Manager view Report(studentID, StudentNAme,ExamID,ExamName,CourseName,CourseName,Grade,ExamStatus(pending,finished,Absent),ExamResult(pass, faild,null),TrackName,InTakeCode,BranchLocation)


go

--  View Instructor course Details
create view ShowInstructorCourseDetails
as
	select
		I.ID,
		I.Name,
		C.CourseName,
		C.MinDegree,
		C.MaxDegree
	from Instructor_Course IC join 
	Instructor I on I.ID = IC.InsID
	join Course C on C.ID = IC.CourseID

-- ShowInstructorCourseDetails  >> View Instructor course Details
