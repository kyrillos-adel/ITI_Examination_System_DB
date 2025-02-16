GO
USE [ITI-Examination-System-DB];
GO

CREATE LOGIN itiadmin
WITH PASSWORD = 'itiadmin' ,
DEFAULT_DATABASE = [ITI-Examination-System-DB]
GO
 
Use [ITI-Examination-System-DB]
CREATE USER itiadmin 
FOR LOGIN itiadmin
GO
 
--Training Manager Account--
 
CREATE LOGIN TrainingManager 
WITH PASSWORD = 'TrainingManager' ,
DEFAULT_DATABASE = [ITI-Examination-System-DB]
GO
 
CREATE USER TrainingManager 
FOR LOGIN TrainingManager
GO

-- student account
CREATE LOGIN ITIStudent 
WITH PASSWORD = 'Student',
DEFAULT_DATABASE = [ITI-Examination-System-DB]
GO
 
CREATE USER ITIStudent 
FOR LOGIN ITIStudent
GO

-- instructor account
CREATE LOGIN Instructor
WITH PASSWORD = 'Instructor' ,
DEFAULT_DATABASE = [ITI-Examination-System-DB]
GO

CREATE USER Instructor
FOR LOGIN Instructor
GO
 