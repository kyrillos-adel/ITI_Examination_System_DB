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


USE [ITI-Examination-System-DB];
GO
--====== 1. Assign Student to a Course ======================================
create or alter proc sp_AssignStudentCourse @StudentID int, @CourseID int
as
begin
	-- check studentId exist
	if not exists(select ID from Student where ID=@StudentID) 
	begin
		print('Student is Not Exist')
		return
	end

	-- check courseID exist
	if not exists(select ID from Course where ID=@CourseID) 
	begin
		print('Course is Not Exist')
		return
	end

	-- check student is not exist before insert
	if exists(select 1 from Student_Course where StudentID=@studentID and CourseID=@CourseID) 
	begin
		print('Student already assigned to this course')
		return
	end

	insert into [dbo].[Student_Course]
	values(@studentID , @CourseID) 

	print ('Student assigned successfully.')
end;
go
---============================================================================
---============================================================================

--=============== 2. Get Enrolled Courses for student ===========================
create or alter proc sp_GetStudentEnrolledCourses @StudentID int
as
begin
	-- check if studentId exist
	if not exists(select ID from Student where ID=@StudentID) 
	begin
		print('No Student with the specified ID')
		return
	end

	select StudentID,Name, CourseName 
	from vw_StudentCourseList 
	where StudentID=@StudentID
end;

go
--===============================================================
--=================================================================================


--=========== 3. As an instructor, create exam (Manual or random) =====================================
-- Exam creation (helper proccedure):
-----------------------------------
create or alter proc sp_createExam 
				@ExamName varchar(50), @StartDate DATETIME, @Duration INT,
	    		@Type CHAR(1), @CourseID INT, @TotalGrade INT = NULL
as
begin
	begin try
		-- check courseID exist
		if not exists(select ID from Course where ID=@CourseID) 
			throw 50000, 'Course does not exist.', 1; 

		declare @CourseTotalGrade int
		select @CourseTotalGrade = [MaxDegree] from Course where ID = @CourseID
		if(@TotalGrade>@CourseTotalGrade)
			throw 50000, 'Exam Grade must be lower than total course grade.', 1;
	
		insert into Exam
		values(@ExamName, @StartDate,@Duration, @Type, @TotalGrade,@courseID)

		declare @ExamID int
		set @ExamID = SCOPE_IDENTITY()
		return @ExamID
	end try
    begin catch
        print 'Error in exam creation: ' + ERROR_MESSAGE();
        throw;
    end catch
end;

go
--------------------------------------------------------------------
-- Question insert:
------------------
--=========> Create Random Questions Exam: <=================

-- stored procedure to create Random Questions 
create or alter proc sp_CreateRandomQuestions @examID int, @CourseID int,@QuestionNum INT,@TotalGrade INT OUTPUT
as
begin
	begin try
        -- Validate if enough questions exist for the course
        declare @TotalQuestions INT;
        select @TotalQuestions = COUNT(*) from Question where CourseID = @CourseID;
        if(@TotalQuestions < @QuestionNum)
			throw 50000, 'Not enough questions available in the course to create the exam', 1;
        
		insert into [dbo].[Exam_Question] 
		select top(@QuestionNum) ID, @examID, 1 from Question
		where CourseID=@CourseID
		order by NEWID()

		set @TotalGrade = @QuestionNum * 1
	end try
    begin catch
        print('Error in creating random questions: ' + ERROR_MESSAGE());
        THROW;
    end catch
end;

go

-- stored procedure to create Random Questions Exam
create or alter proc sp_CreateRandomQuestionsExam
    @CourseID INT,
    @ExamName NVARCHAR(255),
    @ExamDate DATETIME,
	@Duration INT,
    @Type CHAR(1), 
    @QuestionNum INT,
	@TotalGrade INT = NULL 
as
begin
	begin try
		begin transaction
			-- 1. Exam Creation
			declare @ExamID INT;  
			exec  @ExamID  = sp_createExam @ExamName, @ExamDate , @Duration , @Type, @CourseID, @TotalGrade

			-- 2. Add Random Questions
			declare @TotalExamGrade INT;
			exec @TotalGrade = sp_CreateRandomQuestions @ExamID , @CourseID, @QuestionNum,@TotalGrade = @TotalExamGrade OUTPUT;

			-- 3. check if the total grade is valid
			declare @CourseTotalGrade int
			select @CourseTotalGrade = [MaxDegree] from Course where ID = @CourseID
		
			if(@TotalGrade>@CourseTotalGrade)
				throw 50000, 'Exam Grade must be lower than total course grade', 1;

			-- 4. update Exam with the total grade
			update Exam
			set TotalGrade = @TotalExamGrade
			where ID = @ExamID
			
			commit transaction;
			
			print('Exam and random questions added successfully.');
		end try
		begin catch
			rollback transaction;

			print('An error occurred: ' + ERROR_MESSAGE());
			throw;
		end catch
end;

go

--------------------------------------------------------------
--=========> Create Manual Questions Exam: <=================

-- Creat Questions Manually:
Create or alter proc sp_AddQuestionsToExam @ExamID INT, @CourseID INT,
				@QuestionIDs NVARCHAR(MAX),  -- Comma-separated list of Question IDs
				@QuestionDegrees NVARCHAR(MAX) -- Comma-separated list of Question Degrees
as
begin
	begin try

		declare @QuestionTable table(QuestionID INT , QuestionDegree INT);
   
		select CAST(value AS INT) as QuestionID,
				ROW_NUMBER() over(order by (SELECT NULL)) AS RowNum
		into #QuestionIDList
		from STRING_SPLIT(@QuestionIDs, ',')

		select CAST(value AS INT) as QuestionDegree,
				ROW_NUMBER() over(order by (SELECT NULL)) AS RowNum
		into #QuestionDegreeList
		from STRING_SPLIT(@QuestionDegrees, ',')
		
		insert into @QuestionTable 
		select QID.QuestionID , QDegree.QuestionDegree
		from #QuestionIDList as QID join #QuestionDegreeList as QDegree
		on QID.RowNum = QDegree.RowNum

		declare @RowNum INT = 1 , @QID INT, @QuestionCourseID INT;
		WHILE EXISTS (SELECT 1 FROM #QuestionIDList WHERE RowNum = @RowNum)
        begin
			select @QID = QuestionID from #QuestionIDList where RowNum= @RowNum
			if not exists(select 1 from Question where ID = @QID and CourseID=@CourseID)
			begin
			    PRINT 'Question ' + CAST(@QID AS VARCHAR) + ' does not belong to the specified course.';
				throw 50000, 'Not all questions belong to the specified course', 1;
			end
			
			set @RowNum =@RowNum + 1;
		end
		-- Add the questions to the exam
		insert into Exam_Question
		select QuestionID,@ExamID,QuestionDegree from @QuestionTable 

		declare @CourseTotalGrade int, @CalculatedTotalGrade INT
		select @CourseTotalGrade = [MaxDegree] from Course where ID = @CourseID
		set @CalculatedTotalGrade = (select sum(QuestionDegree) from @QuestionTable)
		if(@CalculatedTotalGrade > @CourseTotalGrade)
			throw 50000, 'Exam Grade must be lower than total course grade.', 1;
		
		update Exam
		set [TotalGrade] = @CalculatedTotalGrade
		where ID = @ExamID
	end try
	begin catch
		print ('Error in adding questions to exam: ' + ERROR_MESSAGE());
		throw; 
	end catch
end;

go
-- Create Manual Exam:
create or alter proc sp_CreateExamWithQuestions
    @CourseID INT,
    @ExamName NVARCHAR(20),
    @ExamDate DATETIME,
	@Duration INT,
    @Type CHAR(1), 
    @QuestionIDs NVARCHAR(MAX) = NULL,  -- Comma-separated Question IDs
	@QuestionDegrees NVARCHAR(MAX)= NULL, -- Comma-separated list of Question Degrees
    @TotalGrade INT = NULL 
as
begin
	begin try
		begin transaction

		-- 1. Exam Creation
		declare @ExamID INT;  
		exec  @ExamID  = sp_createExam @ExamName, @ExamDate , @Duration , @Type,@CourseID, @TotalGrade 

		-- 2. Add Questions
		exec sp_AddQuestionsToExam @ExamID,@CourseID, @QuestionIDs, @QuestionDegrees; 

		commit transaction
		print('Exam and questions added successfully.')
	end try
	begin catch
		rollback transaction
		print('An error occurred: ' + ERROR_MESSAGE())
	end catch
end
GO


-- sp_AssignStudentToCourse     >> procedure to Assign Student to a Course
-- sp_GetStudentEnrolledCourses >> Get Enrolled Courses for student
-- sp_CreateRandomQuestionsExam >> procedure to create random Exam.
-- sp_CreateExamWithQuestions   >> procedure to create Exam with specific question.


USE [ITI-Examination-System-DB];
GO
-- SP: Assign student to exam
GO
CREATE OR ALTER PROCEDURE proc_AssignStudentsToExam
    @ExamID INT,
    @TrackID INT,
    @IntakeID INT
AS
BEGIN
    -- Insert students into the Result table only if they haven't been assigned before
    INSERT INTO Result (StudID, ExamID, Grade, Status)
    SELECT 
        S.ID AS StudID,
        @ExamID AS ExamID,
        0 AS Grade,  -- Initial grade
        'Pending' AS Status  -- Default status before taking the exam
    FROM Student S
    JOIN Stud_branch_Track_Intake ST ON S.ID = ST.StudID
    WHERE ST.TrackID = @TrackID AND ST.IntakeID = @IntakeID
    AND NOT EXISTS (
        SELECT 1 FROM Result R WHERE R.StudID = S.ID AND R.ExamID = @ExamID
    ); -- Prevent duplicate assignment

    PRINT 'Students assigned successfully to exam.';
END;
GO


CREATE OR ALTER PROCEDURE proc_AddAndAssignStudent 
    @StudentName NVARCHAR(50),
    @NationalID CHAR(14),
    @DateOfBirth DATE,
    @GraduationYear DATE,
    @BranchID INT,
    @TrackID INT,
    @IntakeID INT,
    @Email NVARCHAR(40),  
    @Password VARCHAR(64) = NULL 
AS
BEGIN
    DECLARE @StudentID INT, @UserID INT;
 
    -- Check if student already exists
    SELECT @StudentID = ID FROM Student WHERE NationalID = @NationalID;
 
    IF @StudentID IS NULL
    BEGIN
        -- Ensure an email is provided for user creation
        IF @Email IS NULL
        BEGIN
            RAISERROR('Email is required to create a new user.', 16, 1);
            RETURN;
        END;
 
        -- Insert into UserLogin to create a user account
        INSERT INTO UserLogin (Email, Password, Role)
        VALUES (@Email,  HASHBYTES('SHA2_256', @Password), 'Student');
 
        -- Get the new User ID 
        SET @UserID = SCOPE_IDENTITY();
 
        -- Insert new student with the generated UserID
        INSERT INTO Student (UserID, Name, NationalID, DateOfBirth, GraduationYear)
        VALUES (@UserID, @StudentName, @NationalID, @DateOfBirth, @GraduationYear);
 
        -- Get the new Student ID
        SET @StudentID = SCOPE_IDENTITY();
    END
 
    -- Check if the student is already assigned
    IF NOT EXISTS (
        SELECT 1 FROM Stud_branch_Track_Intake 
        WHERE StudID = @StudentID AND BranchID = @BranchID AND TrackID = @TrackID AND IntakeID = @IntakeID
    )
    BEGIN
        -- Assign student to branch, track, and intake
        INSERT INTO Stud_branch_Track_Intake (StudID, BranchID, TrackID, IntakeID)
        VALUES (@StudentID, @BranchID, @TrackID, @IntakeID);
    END
    ELSE
    BEGIN
        PRINT 'Student is already assigned to this branch, track, and intake before.';
    END
END;
GO



-------------------------


----------------------------------------




----------------------------------------------------------------
----------------------------------------------------------------



-- Report student performance detailed
GO
CREATE OR ALTER PROCEDURE proc_StudentPerformanceReport
    @ExamID INT ,     -- Optional: View results for a specific exam
    @TrackID INT ,    -- Optional: Filter by track
    @IntakeID INT ,   -- Optional: Filter by intake
    @StudentID INT    -- Optional: View performance of a specific student
AS
BEGIN
    SET NOCOUNT ON;

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
        END AS ExamResult
    FROM Result R
    JOIN Student S ON R.StudID = S.ID
    JOIN Exam E ON R.ExamID = E.ID
    JOIN Course C ON E.CourseID = C.ID
    JOIN Stud_branch_Track_Intake ST ON S.ID = ST.StudID
    WHERE 
        (@ExamID IS NULL OR E.ID = @ExamID) AND
        (@TrackID IS NULL OR ST.TrackID = @TrackID) AND
        (@IntakeID IS NULL OR ST.IntakeID = @IntakeID) AND
        (@StudentID IS NULL OR S.ID = @StudentID)
    ORDER BY E.ID, S.Name;
    
    PRINT 'Student performance report generated successfully.';
END;
GO


---------------------------------------------------------------------------


---------------------------------------------------------------

-- proc_AssignStudentsToExam  >> Assign student to exam
-- proc_AddAndAssignStudent  >> Add And Assign Student to branch, track and intake
-- proc_StudentPerformanceReport >> Report student performance detailed


USE [ITI-Examination-System-DB];
GO

----------------------------as a Training Manager, I can Assign instructors to courses----------------
create or alter proc sp_AssignInstructorToCourse @insID int ,@CourseID int 
as 
begin 
	IF  (USER_NAME() = 'TrainingManager')
	begin
		IF EXISTS (SELECT 1 FROM Instructor)  and EXISTS( SELECT 1 FROM Instructor_Course) and USER_NAME() = 'TrainingManager'
		begin
			insert into Instructor_Course values(@insID,@CourseID);
			print'you assign a instractor to teach a course';

		end
		ELSE 
		begin
			print'you can not assign a instractor  ';
		end
	end
	else 
		print'you can not assign a instractor (not your permation) '
end;
go

--------------------as a Training Manager, I can see instructors who teach courses ------------
-- get the courses assigned to instructor
create or alter proc sp_GetInstructorCourses  
as
begin
IF  (USER_NAME() = 'TrainingManager')
begin
    SELECT 
            ic.InsID,
            ic.CourseID,
            i.Name AS InstructorName,
            c.CourseName
            FROM Instructor_Course ic
            INNER JOIN Instructor i ON ic.InsID = i.ID
            INNER JOIN Course c ON ic.CourseID = c.ID 
end
ELSE 
begin 
    print 'you can not see this table '
end
end

go



-----------------as a Training Manager, I can Create student accounts--------------------

-- to Create Student Account
create or alter proc sp_CreateStudentAccount 
    @email varchar(max), 
    @pass int, 
    @role varchar(max)
as
begin

    if (user_name() != 'TrainingManager') 
    begin
        print 'you cannot insert in this table';
        return;
    end;

    if @email not like '%@%._%' and @role !='Student'
    begin
        print 'invalid email format. please enter a valid email address/or invalid ROLE.';
        return;
    end;

    begin try
        insert into UserLogin values (@email, @pass, @role);
        print 'inserted done';
    end try
    begin catch
        print 'cannot insert this row';
    end catch;
end;

go



------------- as a Student, I can take exams at the defined time ------------
-- student take exams at the defined time
CREATE OR ALTER PROCEDURE sp_TakeExam 
    @ExamID INT 
AS
BEGIN
    -- Check if the Exam exists
    IF NOT EXISTS (SELECT 1 FROM Exam WHERE ID = @ExamID) 
    BEGIN
        PRINT('Exam does not exist');
        RETURN;
    END
    ELSE
    BEGIN
        -- Declare variables for the StartTime and EndTime of the exam
        DECLARE @StartTimeOfExam DATETIME = (SELECT StartTime FROM Exam WHERE ID = @ExamID);
        DECLARE @EndTimeOfExam DATETIME = (SELECT EndTime FROM Exam WHERE ID = @ExamID);
        
        -- Check if the current date and time is within the exam window
        IF (GETDATE() BETWEEN @StartTimeOfExam AND @EndTimeOfExam)
        BEGIN 
            -- If within the exam window, select the questions and choices
            SELECT 
				q.ID,
                q.Content AS QuestionContent,
                q.Type AS QuestionType, 
                CASE 
                    WHEN q.Type = 'MCQ' THEN STRING_AGG(CONCAT('(', ch.Content, ')'), ', ')
                    WHEN q.Type = 'T&F' THEN STRING_AGG(CONCAT(ch.Content, ''), ', ')
                    ELSE NULL 
                END AS Choices
            FROM 
                [dbo].[Exam_Question] EQ 
                JOIN Question q ON EQ.[QuestionID] = q.ID
                LEFT JOIN Choice ch ON q.ID = ch.QuestionID
            WHERE 
                EQ.ExamID = @ExamID
            GROUP BY 
			q.ID,
                q.Content, 
                q.Type
				;
        END 
        ELSE 
        BEGIN
            PRINT('Cannot enter this exam now.');
        END
    END
END;
GO
-- sp_AssignInstructorToCourse  >>   Assign instructors to courses
-- sp_GetInstructorCourses  >> get the courses assigned to instructor
-- sp_CreateStudentAccount >> to Create Student Account
-- sp_TakeExam >> take exams at the defined time



USE [ITI-Examination-System-DB];
GO

-- stored procedure to  get final result of student
CREATE OR ALTER PROCEDURE GetFinalResults_Proc
    @StudentID INT,
	@ExamID int
AS
BEGIN
    -- Check if the user has the 'Student' role
    
	/*IF EXISTS (
        SELECT 1 FROM UserLogin 
        WHERE ID =  @StudentID AND SUSER_NAME() = 'ITIStudent'
    )*/
    BEGIN
        -- Select from the function only if the user is a student
        SELECT * FROM GetFinalResults(@StudentID,@ExamID);
    END
    
END;

go

--------------------------------------------------------------------
---------------------------------------------------------

--as a Training Manager, I can Add/Edit/Delete courses
-- Procedure to Add a Course
CREATE OR ALTER PROCEDURE AddCourse
    @CourseName VARCHAR(40),
    @Description VARCHAR(MAX),
    @MaxDegree INT,
    @MinDegree INT
AS
BEGIN
    -- Check if the given UserID belongs to a Training Manager
    IF (SUSER_NAME() != 'TrainingManager')
    BEGIN
        PRINT 'Access denied. Only Training Managers can execute this procedure.';
        RETURN;
    END
	IF NOT EXISTS (SELECT 1 FROM Course WHERE [CourseName] = @CourseName)
    BEGIN
    -- Insert the new course
    INSERT INTO Course (CourseName, Description, MaxDegree, MinDegree)
    VALUES (@CourseName, @Description, @MaxDegree, @MinDegree);

    PRINT 'Course added successfully.';
	end
	 ELSE
    BEGIN
        print 'The course ' + @CourseName + ' is already exist in the database'
    END
END

go

-- Procedure to Edit a Course
CREATE OR ALTER PROCEDURE EditCourse
    @CourseID INT,
    @CourseName VARCHAR(40),
    @Description VARCHAR(MAX),
    @MaxDegree INT,
    @MinDegree INT
AS
BEGIN
    -- Check if the current user has the 'Training Manager' role
       IF (SUSER_NAME() != 'TrainingManager')
    BEGIN
        PRINT 'Access denied. Only users with the Training Manager role can execute this procedure.';
        RETURN;
    END

    -- Check if the course exists
    IF NOT EXISTS (SELECT 1 FROM Course WHERE ID = @CourseID)
    BEGIN
        PRINT 'Course does not exist.';
        RETURN;
    END

    -- Update the course details
    UPDATE Course
    SET CourseName = @CourseName,
        Description = @Description,
        MaxDegree = @MaxDegree,
        MinDegree = @MinDegree
    WHERE ID = @CourseID;

    PRINT 'Course updated successfully.';
END;
go


-- Procedure to Delete a Course
CREATE OR ALTER PROCEDURE DeleteCourse
    @CourseID INT
AS
BEGIN
    -- Check if the current user has the 'Training Manager' role
    IF (SUSER_NAME() != 'TrainingManager')
    BEGIN
        PRINT 'Access denied. Only users with the Training Manager role can execute this procedure.';
        RETURN;
    END

    -- Check if the course exists
    IF NOT EXISTS (SELECT 1 FROM Course WHERE ID = @CourseID)
    BEGIN
        PRINT 'Course does not exist.';
        RETURN;
    END

    -- Delete the course
    DELETE FROM Course
    WHERE ID = @CourseID;

    PRINT 'Course deleted successfully.';
END;

go


-------------------------------------------------------
-- sp to add instructor 
 CREATE OR ALTER PROCEDURE AddInstructorAccount
    @InstEmail VARCHAR(40),
    @INSTPassword VARCHAR(100),
    @CheckRole varchar(20)
AS
BEGIN
    IF (SUSER_NAME() != 'TrainingManager')
    BEGIN
        PRINT 'Access denied. Only Training Managers can execute this procedure.';
        RETURN;
    END
	ELSE IF (@CheckRole != 'Instructor')
	 BEGIN
        PRINT 'you can not insert account in this role.';
        RETURN;
    END

    -- Insert the new course
    INSERT INTO UserLogin(Email,  Password, role)
    VALUES (@InstEmail, HASHBYTES('SHA2_256', CONVERT(VARCHAR, @INSTPassword)), @CheckRole);
 

    PRINT 'the instructor account inserted successfully';
END

-- GetFinalResults_Proc >> stored procedure to  get final result of studen
-- AddInstructorAccount >> sp to add Instructor to course
-- AddCourse >> Add Course
-- EditCourse >> Edit Course
-- DeleteCourse >> Delete Course
