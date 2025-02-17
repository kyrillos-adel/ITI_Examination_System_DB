USE [ITI-Examination-System-DB];
GO

-- as an Instructor, Review & manually grade text answers\
-- View Student answers for text questions
CREATE OR ALTER FUNCTION f_ShowExamStudentTextAnswers(@Ex_ID INT)
RETURNS @T TABLE (Std_ID INT, Q_Content VARCHAR(MAX), Std_Answer VARCHAR(MAX),
		QID int,ExamID INT)
AS
BEGIN
	IF EXISTS(SELECT 1 FROM Exam WHERE ID = @Ex_ID)
	BEGIN
		INSERT INTO @T
		SELECT r.StudID, q.Content, sa.Choice,q.ID,eq.ExamID
		FROM
			Exam e
				JOIN
			Exam_Question eq ON e.ID = eq.ExamID
				JOIN
			Question q ON q.ID = eq.QuestionID
				JOIN
			Student_Answer sa ON q.ID = sa.QestionID
				JOIN
			Result r ON r.ID = sa.StudentExamID
		WHERE
			r.Status = 'Finished' AND q.Type = 'TXT'
	END;
	RETURN
END;

-- f_ShowExamStudentTextAnswers  >> view text answers


GO
-- function to get final result of student
CREATE OR ALTER FUNCTION GetFinalResults(@StudentID INT, @ExamID int)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        R.StudID,
        S.Name AS StudentName,
        E.Name,
        C.CourseName,
        R.Grade AS Grade,
        CASE 
            WHEN R.Grade  >= C.MinDegree THEN 'Passed'
            ELSE 'Failed'
        END AS Result
    FROM Result R
    JOIN Exam E ON R.ExamID = E.ID
    JOIN Course C ON E.CourseID = C.ID
    JOIN Student S ON R.StudID = S.ID
    WHERE R.StudID = @StudentID and R.[ExamID]=@ExamID
);

-- GetFinalResults  >> function to get final result of student
