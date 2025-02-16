--========= Teset scenario ===================

USE [ITI-Examination-System-DB];
GO
-- training manager:
------- Add Branches, tracks in each department, and add new intake.     (Kerlos)---
exec sp_OpenNewIntake 'ICC2022','2022',4,'ICC'
exec sp_AddNewBranch 1, 'Benisuif', 'benisuif@email.com', '010123456789' 
exec sp_AddNewTrackToDepartment 'SW', 1

------- add students, and define their personal data, intake, branch, and track  (rahil)
exec proc_AddAndAssignStudent 'Ayman','11122233344466','2000-11-30','2024',1,1,1,'Ayman@gmail.com','ASD123'
select * from vw_StudentAssignments



-- Instructor:
------- create exam for course(random, or  manually)     (mina) 
exec sp_CreateRandomQuestionsExam 1,'Database','2025-02-13 09:00:00.000',120,'N',6
------- show exam details (type (exam or corrective), intake, branch, track, course, start time, End time, total time and allowance options)  
exec sp_TakeExam 1
------- select students that can do specific exam   (Rahil)
------- 
----------------------------examID  trackID   IntakeID
exec proc_AssignStudentsToExam 1,      1,         1

-- view students assigned to exams
select * from vw_ExamAssignments


--Students:   
-------- view assigned exam
exec sp_StdAssignedExam 'Ayman@gmail.com','ASD123'
------ take exam (only on the specified time)     (omnia) 
exec sp_TakeExam 1
------ submit exam (calculate the correct answer for MCQ and T&F) (Kerlos)
------------------------ store students answer for the exam   (kerlos)
--				        @Std_ID  @Std_Email	       @Std_Password  @Exam_ID	@Question_ID @Answer
exec sp_StudentSubmitAnswer 3,  'Ayman@gmail.com',   'ASD123',       1,         1,        'Paris'
exec sp_StudentSubmitAnswer 3,  'Ayman@gmail.com',   'ASD123',       1,         3,        'Ay 7aga'
exec sp_StudentSubmitAnswer 3,  'Ayman@gmail.com',   'ASD123',       1,         5,        'Windows'
exec sp_StudentSubmitAnswer 3,  'Ayman@gmail.com',   'ASD123',       1,         7,        'False'
exec sp_StudentSubmitAnswer 3,  'Ayman@gmail.com',   'ASD123',       1,         11,        'asdasd'
exec sp_StudentSubmitAnswer 3,  'Ayman@gmail.com',   'ASD123',       1,         13,			'True'

--------         @Std_ID	@Std_Email	   @Std_Password  @Exam_ID	
exec sp_FinishExam 3,    'Ayman@gmail.com',   'ASD123',       1

------ view final result                    (Rawan)--<
exec GetFinalResults_Proc 3,1

-- Instructor:
------ review the txt questions answers(enter the marks manually)  (Kerlos)
select * from f_ShowExamStudentTextAnswers(1)
------                          @Ins_ID		@Std_ID	  @Ex_ID  @Q_ID   @Grade
exec sp_AssignGradeForTxtQuestion 1,         3,         1,     3,      10
exec sp_AssignGradeForTxtQuestion 1,         3,         1,     15,      0
--- show total grade for the student in exam  (rawan)
select * from vw_TrainingManagerReport















--rawan:
--------
-- GetFinalResults_Proc >> stored procedure to  get final result of studen
-- AddInstructorAccount >> sp to add Instructor to course
-- AddCourse >> Add Course
-- EditCourse >> Edit Course
-- DeleteCourse >> Delete Course

-- GetFinalResults  >> function to get final result of student

-- ShowInstructorCourseDetails  >> View Instructor course Details
--------------------------------------------------------------------
-- Omnia:
---------
-- sp_AssignInstructorToCourse  >>   Assign instructors to courses
-- sp_GetInstructorCourses  >> get the courses assigned to instructor
-- sp_CreateStudentAccount >> to Create Student Account
-- sp_TakeExam >> take exams at the defined time
-----------------------------------------------------------------
-- Rahil:
---------
-- proc_AssignStudentsToExam  >> Assign student to exam
-- proc_AddAndAssignStudent  >> Add And Assign Student to branch, track and intake
-- proc_StudentPerformanceReport >> Report student performance detailed

-- trg_PreventDuplicateExamAssignment  >> trigger to prevevnt dublicate Exam Assignment
-- trg_PreventDuplicateStudentAssignment >> prevevnt Dublicate Student Assignment  to branch, track and intake

-- vw_ExamAssignments  >> view Student Performance in assigned exams
-- vw_StudentAssignments >> view Student Assignments  to branch, track and intake
-- vw_TrainingManagerReport >> Training Manager view Report(studentID, StudentNAme,ExamID,ExamName,CourseName,CourseName,Grade,ExamStatus(pending,finished,Absent),ExamResult(pass, faild,null),TrackName,InTakeCode,BranchLocation)
-----------------------------------------------------------------
--kyrillos:
----------  
-- sp_AddNewTrackToDepartment >> Add new track to a department
-- sp_EditTrackInDepartment   >> Edit tracks in department
-- sp_AddNewBranch  >> Add new Branch
-- sp_EditBranchSet  >> Edit Branch	
-- sp_BindTrackToBranch >> Bind Track to Branch
-- sp_UnbindTrackFromBranch >> Unbind Track from Branch
-- sp_StudentSubmitAnswer >> Student Submit answers (store answers)
-- sp_AssignGradeForTxtQuestion  >>Assign grade for student txt answer

-- f_StdAssignedExam  >> Student View assigned exams
-- f_ShowExamStudentTextAnswers  >> view students text answers in exams
---------------------------------------------------------------------------
--Mina:
-------
-- sp_AssignStudentToCourse     >> procedure to Assign Student to a Course
-- sp_GetStudentEnrolledCourses >> Get Enrolled Courses for student
-- sp_CreateRandomQuestionsExam >> procedure to create random Exam.
-- sp_CreateExamWithQuestions   >> procedure to create Exam with specific question.




