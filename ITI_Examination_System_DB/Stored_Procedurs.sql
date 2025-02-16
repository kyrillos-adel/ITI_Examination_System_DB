USE [ITI-Examination-System-DB];
GO

-- as a Training Manager, I can  Create new branches and tracks
----			Add new track to a department			----
CREATE OR ALTER PROCEDURE sp_AddNewTrackToDepartment
    @TrackName		VARCHAR(50),
    @DeptID			INT
AS
BEGIN
	IF (EXISTS(SELECT ID FROM Department WHERE ID = @DeptID))
	BEGIN
		IF NOT EXISTS(SELECT TrackName FROM Track WHERE TrackName = @TrackName)
		BEGIN
			INSERT INTO Track (TrackName, DeptID)
			VALUES (@TrackName, @DeptID);
			RETURN
		END
		ELSE
		BEGIN
			PRINT @TrackName + 'is Already Exists'
			RETURN
		END
	END
	ELSE
	BEGIN
		PRINT 'Department does not exist. Try to create it first'
		RETURN
	END
END;
GO

----			Edit track in a department			----
CREATE OR ALTER PROCEDURE sp_EditTrackInDepartment
	@OldTrackName		VARCHAR(50),
    @NewTrackName		VARCHAR(50),
    @DeptID				INT
AS
BEGIN
	IF EXISTS(SELECT TrackName FROM Track WHERE TrackName = @OldTrackName AND DeptID = @DeptID)
	BEGIN
		UPDATE Track
		SET TrackName = @NewTrackName
		WHERE TrackName = @OldTrackName AND DeptID = @DeptID
		RETURN
	END;
	ELSE
	BEGIN
		PRINT 'The specified track does not exist'
	END;
END;
GO
----			Add new Branch			----
CREATE  OR ALTER PROCEDURE sp_AddNewBranch
	@BM_ID			INT,
	@B_Location		VARCHAR(50),
	@B_Email		VARCHAR(40),
	@B_Phone		CHAR(11)
AS
BEGIN
	IF NOT EXISTS(SELECT ID FROM BRANCH WHERE Email = @B_Email)
	BEGIN
		IF EXISTS(SELECT ID FROM Instructor WHERE ID = @BM_ID)
		BEGIN
			INSERT INTO Branch(BranchManagerID, BranchLocation, Email)
			VALUES (@BM_ID, @B_Location, @B_Email);
			INSERT INTO Branch_phone
			SELECT ID, @B_Phone FROM Branch WHERE Email = @B_Email;
			RETURN
		END
		ELSE
		BEGIN
			PRINT 'Invalid Branch Manager ID. No such instructor exists'
			RETURN
		END
	END
	ELSE
	BEGIN
		PRINT 'Branch with the same email already exists'
		RETURN
	END
END;
GO

----			Edit Branch			----
CREATE OR ALTER PROCEDURE sp_EditBranchSet
	@New_BM_ID		INT,
	@B_Email		VARCHAR(40)
AS
BEGIN
	IF EXISTS(SELECT 1 FROM Branch WHERE Email = @B_Email)
	BEGIN
		IF EXISTS(SELECT 1 FROM Instructor WHERE ID = @New_BM_ID)
		BEGIN
			UPDATE Branch
			SET BranchManagerID = @New_BM_ID
			WHERE Email = @B_Email
			RETURN;
		END;
		ELSE
		BEGIN
			PRINT 'Invalid Manager ID'
			RETURN
		END;
	END
	ELSE
	BEGIN
		PRINT 'Invalid Branch'
		RETURN
	END;
END;
GO




----			Bind Track to Branch			----
CREATE OR ALTER PROCEDURE sp_BindTrackToBranch
	@B_ID			INT,
	@Track_ID		INT
AS
BEGIN
	IF (EXISTS(SELECT ID FROM Branch WHERE ID = @B_ID)
			AND
		EXISTS(SELECT ID FROM Track WHERE ID = @Track_ID))
	BEGIN
		IF EXISTS(SELECT 1 FROM branch_track WHERE BranchID = @B_ID AND TrackID = @Track_ID)
		BEGIN
			PRINT 'Track already exists in this branch'
			RETURN
		END
		ELSE
		BEGIN
			INSERT INTO branch_track
			VALUES (@B_ID, @Track_ID)
			RETURN
		END
	END
	ELSE
	BEGIN
		PRINT 'No such branch or track'
		RETURN
	END
END;
GO



----			Unbind Track from Branch			----
CREATE OR ALTER PROCEDURE sp_UnbindTrackFromBranch
	@B_ID			INT,
	@Track_ID		INT
AS
BEGIN
	IF EXISTS(SELECT 1 FROM branch_track WHERE BranchID = @B_ID AND TrackID = @Track_ID)
	BEGIN
		DELETE FROM branch_track
		WHERE BranchID = @B_ID AND TrackID = @Track_ID
		RETURN;
	END
	ELSE
	BEGIN
		PRINT 'Branch does not already have that track'
		RETURN;
	END
END;
GO

 --as a Student, I can View assigned exams
CREATE or alter PROCEDURE sp_StdAssignedExam
    @Std_Email VARCHAR(40), 
    @Std_Password VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS(SELECT 1 FROM UserLogin WHERE Email = @Std_Email AND Password = HASHBYTES('SHA2_256', @Std_Password))
    BEGIN
        SELECT 
            e.Name,
            e.StartTime,
            e.EndTime,
            e.Duration,
            CASE
                WHEN e.Type = 'N' THEN 'Normal'
                WHEN e.Type = 'C' THEN 'Corrective'
            END AS Type,
            r.Grade,
            r.Status
        FROM 
            Exam e 
                JOIN 
            Result r ON e.ID = r.ExamID
                JOIN
            Student s ON s.ID = r.StudID
                JOIN
            UserLogin u ON u.ID = s.UserID
        WHERE
            u.Email = @Std_Email;
    END
    ELSE
    BEGIN
        PRINT 'Wrong user email or password';
    END
END
GO

-- as a Student, I can Submit answers (MCQs, True/False, and Text Questions)
CREATE OR ALTER PROCEDURE sp_StudentSubmitAnswer
					@Std_ID			INT,
					@Std_Email		VARCHAR(40),
					@Std_Password	VARCHAR(50),
					@Exam_ID		INT,
					@Question_ID	INT,
					@Answer			varchar(max)
AS
BEGIN
	IF EXISTS(SELECT 1 FROM UserLogin WHERE Email = @Std_Email AND Password = HASHBYTES('SHA2_256', @Std_Password))
	BEGIN
		IF EXISTS(SELECT 1 FROM Exam_Question WHERE QuestionID = @Question_ID AND ExamID = @Exam_ID)
		BEGIN
			DECLARE @Ex_Start_Time	DATETIME
			DECLARE @Ex_End_Time	DATETIME
			DECLARE	@CurrentTime	DATETIME = GETDATE()

			SELECT @Ex_Start_Time = StartTime, @Ex_End_Time = EndTime
			FROM Exam
			WHERE ID = @Exam_ID

			IF (@CurrentTime BETWEEN @Ex_Start_Time AND @Ex_End_Time)
			BEGIN
				DECLARE @Ex_Status VARCHAR(8)
				DECLARE @StdExID INT
				SELECT @Ex_Status = Status, @StdExID = ID
				FROM Result WHERE StudID = @Std_ID AND ExamID = @Exam_ID
				IF (@Ex_Status = 'Pending')
				BEGIN
					IF EXISTS(SELECT 1 FROM Student_Answer WHERE StudentExamID = @StdExID AND QestionID = @Question_ID)
					BEGIN
						UPDATE Student_Answer
						SET Choice = @Answer
						WHERE StudentExamID = @StdExID AND QestionID = @Question_ID
						RETURN
					END;
					ELSE
					BEGIN
						INSERT INTO Student_Answer
						VALUES (@StdExID, @Question_ID, @Answer)
						RETURN
					END;
				END;
				ELSE IF (@Ex_Status = 'Absent')
				BEGIN
					PRINT 'You have missed this exam'
					RETURN
				END;
				ELSE IF (@Ex_Status = 'Finished')
				BEGIN
					PRINT 'You have finished this exam'
					RETURN
				END;
				ELSE
				BEGIN
					PRINT 'There is no such exam assigned for you'
					RETURN
				END;
			END;
			ELSE
			BEGIN
				PRINT 'This Exam is not available at the moment, try contacting your instructor'
				RETURN
			END;
		END;
		ELSE
		BEGIN
			PRINT 'Invalid Exam or question id'
			RETURN
		END;
	END;
	ELSE
	BEGIN
		PRINT 'Wrong Email or password'
		RETURN
	END;
END;
GO

-- Student Finishes the exam


-- as an Instructor, Review & manually grade text answers\
-- Assign grade for student txt answer
CREATE  OR ALTER PROCEDURE sp_AssignGradeForTxtQuestion
	@Ins_ID			INT,
	@Std_ID			INT,
	@Ex_ID			INT,
	@Q_ID			INT,
	@Grade			INT
AS
BEGIN
	IF EXISTS(
	select 1 from f_ShowExamStudentTextAnswers(@Ex_ID)
	)

	BEGIN
		DECLARE @MaxGrade INT
		SELECT @MaxGrade = Degree FROM Exam_Question WHERE QuestionID = @Q_ID AND ExamID = @Ex_ID
		
		IF(@Grade > @MaxGrade)
		BEGIN
			SET @Grade = @MaxGrade
		END;
		
		UPDATE Result
		SET Grade += @Grade
		WHERE ExamID = @Ex_ID AND StudID = @Std_ID
		RETURN
	END;
	ELSE
	BEGIN
		PRINT 'Invalid data'
		RETURN
	END;
END;

go
-- Student Finishes the exam
CREATE or alter PROCEDURE sp_FinishExam 
			@Std_ID			INT,
			@Std_Email		VARCHAR(40),
			@Std_Password	VARCHAR(50),
			@Exam_ID		INT
AS
BEGIN
	IF EXISTS(SELECT 1 FROM UserLogin WHERE Email = @Std_Email AND Password = HASHBYTES('SHA2_256', @Std_Password))
	BEGIN
		IF EXISTS(SELECT 1 FROM Result WHERE StudID = @Std_ID AND ExamID = @Exam_ID AND Status = 'Pending')
		BEGIN
			UPDATE Result
			SET Grade = 0, Status = 'Finished'
			WHERE StudID = @Std_ID AND ExamID = @Exam_ID

			-- cursor to put every question grade (MCQ, T&F)
			DECLARE c CURSOR
			FOR
				SELECT
					c.Content, sa.Choice, ex.Degree
				FROM
					Exam_Question ex
						JOIN
					Student_Answer sa ON ex.QuestionID = sa.QestionID
						JOIN
					Question q ON q.ID = sa.QestionID
						JOIN
					Choice c ON q.ID = c.QuestionID
				WHERE 
					ex.ExamID = @Exam_ID AND q.Type IN ('MCQ', 'T&F') AND c.IsCorrect = 1
 
			DECLARE @Correct_answer VARCHAR(MAX), @Std_answer VARCHAR(MAX), @Q_grade INT
 
			OPEN c
			FETCH c INTO @Correct_answer, @Std_answer, @Q_grade
			WHILE @@FETCH_STATUS = 0
				BEGIN
					IF(@Std_answer = @Correct_answer)
					BEGIN
						UPDATE Result
						SET Grade += @Q_grade
						WHERE StudID = @Std_ID AND ExamID = @Exam_ID
					END
					FETCH c INTO @Correct_answer, @Std_answer, @Q_grade
				END
 
			CLOSE c
			DEALLOCATE c
			RETURN
		END
		ELSE
		BEGIN
			PRINT 'Invalid exam'
			RETURN
		END
	END
	ELSE
	BEGIN
		PRINT 'Invalid email or password'
	END
END
GO
-- Open new Intake
CREATE or alter PROCEDURE sp_OpenNewIntake
    @Code VARCHAR(10),
    @Year DATE,
    @Duration INT,
    @ProgramName CHAR(3)
AS
BEGIN
    IF EXISTS(SELECT 1 FROM Intake WHERE Code = @Code)
    BEGIN
        PRINT 'Intake with this code already exists';
        RETURN;
    END
 
    IF (@ProgramName NOT IN('ICC', 'PTP'))
    BEGIN
        PRINT 'Invalid Program Name. Must be ICC or PTP';
        RETURN;
    END
    IF (@Duration < 1 OR @Duration > 12)
    BEGIN
        PRINT 'Invalid Duration. Must be between 1 and 12 months';
        RETURN;
    END
    IF TRY_CAST(@Year AS DATE) IS NULL
    BEGIN
        PRINT 'Invalid Year format. Must be a valid date';
        RETURN;
    END
    INSERT INTO Intake (Code, Year, Duration, ProgramName)
    VALUES (@Code, @Year, @Duration, @ProgramName);
    PRINT 'New intake opened';
END
GO




-- sp_AddNewTrackToDepartment >> Add new track to a department
-- sp_EditTrackInDepartment   >> Edit tracks in department
-- sp_AddNewBranch  >> Add new Branch
-- sp_EditBranchSet  >> Edit Branch	
-- sp_OpenNewIntake  >> add new intake
-- sp_BindTrackToBranch >> Bind Track to Branch
-- sp_UnbindTrackFromBranch >>Unbind Track from Branch
-- sp_StudentSubmitAnswer >> Student Submit answers (store answers)
-- f_StdAssignedExam  >> Student View assigned exams
-- f_ShowExamStudentTextAnswers  >> view text answers
-- sp_AssignGradeForTxtQuestion  >>Assign grade for student txt answer

