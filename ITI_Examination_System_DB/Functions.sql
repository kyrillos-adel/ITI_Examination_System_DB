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
