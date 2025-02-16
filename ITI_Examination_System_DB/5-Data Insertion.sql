GO
USE [ITI-Examination-System-DB];
GO

INSERT INTO Department (DeptName) VALUES ('Computer Science'), ('Information Technology');
 
INSERT INTO Track (TrackName, DeptID) VALUES 
    ('Web Development', 1),
    ('Data Science', 1),
    ('Cyber Security', 2);
 
INSERT INTO Intake (Code, Year, Duration, ProgramName) VALUES
    ('INTK2024', '2024-01-01', 6, 'ICC'),
    ('INTK2025', '2025-01-01', 12, 'PTP');
 
 
INSERT INTO UserLogin (Email, Password, role) VALUES
    ('admin@example.com', HASHBYTES('SHA2_256', 'AdminPass'), 'Admin'),
    ('manager@example.com', HASHBYTES('SHA2_256', 'ManagerPass'), 'Training Manager'),
    ('SaraSalah@example.com', HASHBYTES('SHA2_256', 'InstructorPass'), 'Instructor'),
    ('Kyrillos@example.com', HASHBYTES('SHA2_256', 'StudentPass'), 'Student'),
    ('Ali@example.com', HASHBYTES('SHA2_256', 'StudentPass'), 'Student');
 
INSERT INTO Instructor (UserID, Name, NationalID, TrainingManagerID) VALUES
    (3, 'Sara Salah', '11112222333344', NULL)

INSERT INTO Student (UserID, Name, NationalID, DateOfBirth, GraduationYear) VALUES
    (4, 'Kyrillos Adel', '12345678901234', '2000-01-01', '2022-06-01'),
    (5, 'Ali Khaled', '23456789012345', '2001-02-02', '2023-06-01');
 
 
 
 
INSERT INTO Course (CourseName, Description, MaxDegree, MinDegree) VALUES
    ('Database Systems', 'Advanced database concepts', 100, 50),
    ('Machine Learning', 'Introduction to ML', 100, 50);
 

--------------------------------------------------

-- Question 1: 'What is the capital of France?'
INSERT INTO Question (Content, Type, CourseID)
VALUES ('What is the capital of France?', 'MCQ', 1);

-- Question 2: 'Is 2 + 2 equal to 4?'
INSERT INTO Question (Content, Type, CourseID)
VALUES ('Is 2 + 2 equal to 4?', 'T&F', 1);

-- Question 3: 'Explain the concept of Polymorphism in object-oriented programming.'
INSERT INTO Question (Content, Type, CourseID)
VALUES ('Explain the concept of Polymorphism in object-oriented programming.', 'TXT', 1);

-- Question 4: 'Which of the following is a programming language?'
INSERT INTO Question (Content, Type, CourseID)
VALUES ('Which of the following is a programming language?', 'MCQ', 1);

-- Question 5: 'Which of these is an operating system?'
INSERT INTO Question (Content, Type, CourseID)
VALUES ('Which of these is an operating system?', 'MCQ', 1);

-- Question 6: 'What is the full form of CPU?'
INSERT INTO Question (Content, Type, CourseID)
VALUES ('What is the full form of CPU?', 'MCQ', 1);

-- Question 7: 'The Earth is flat.'
INSERT INTO Question (Content, Type, CourseID)
VALUES ('The Earth is flat.', 'T&F', 1);

-- Question 8: 'Python is a compiled language.'
INSERT INTO Question (Content, Type, CourseID)
VALUES ('Python is a compiled language.', 'T&F', 1);

-- Question 9: 'The speed of light is constant in a vacuum.'
INSERT INTO Question (Content, Type, CourseID)
VALUES ('The speed of light is constant in a vacuum.', 'T&F', 1);

-- Question 10: 'What does HTTP stand for?'
INSERT INTO Question (Content, Type, CourseID)
VALUES ('What does HTTP stand for?', 'MCQ', 1);

-- Question 11: 'Which programming paradigm is associated with Java?'
INSERT INTO Question (Content, Type, CourseID)
VALUES ('Which programming paradigm is associated with Java?', 'MCQ', 1);

-- Question 12: 'HTML is a programming language.'
INSERT INTO Question (Content, Type, CourseID)
VALUES ('HTML is a programming language.', 'T&F', 1);

-- Question 13: 'C++ supports both procedural and object-oriented programming.'
INSERT INTO Question (Content, Type, CourseID)
VALUES ('C++ supports both procedural and object-oriented programming.', 'T&F', 1);

-- Question 14: 'Explain how the binary search algorithm works.'
INSERT INTO Question (Content, Type, CourseID)
VALUES ('Explain how the binary search algorithm works.', 'TXT', 1);

-- Question 15: 'What are the advantages of using version control systems like Git?'
INSERT INTO Question (Content, Type, CourseID)
VALUES ('What are the advantages of using version control systems like Git?', 'TXT', 1);


-- Inserting Choices for the Questions

-- For Question 1: 'What is the capital of France?'
INSERT INTO Choice (Content, QuestionID, IsCorrect)
VALUES
('Paris', 1, 1),  -- Correct Answer
('London', 1, 0),
('Berlin', 1, 0),
('Rome', 1, 0);

-- For Question 2: 'Is 2 + 2 equal to 4?'
INSERT INTO Choice (Content, QuestionID, IsCorrect)
VALUES
('True', 2, 1),   -- Correct Answer
('False', 2, 0);

-- For Question 4: 'Which of the following is a programming language?'
INSERT INTO Choice (Content, QuestionID, IsCorrect)
VALUES
('Python', 4, 1),  -- Correct Answer
('HTML', 4, 0),
('CSS', 4, 0),
('Excel', 4, 0);

-- For Question 5: 'Which of these is an operating system?'
INSERT INTO Choice (Content, QuestionID, IsCorrect)
VALUES
('Windows', 5, 1),  -- Correct Answer
('Linux', 5, 1),    -- Correct Answer
('Java', 5, 0),
('MacOS', 5, 1);    -- Correct Answer

-- For Question 6: 'What is the full form of CPU?'
INSERT INTO Choice (Content, QuestionID, IsCorrect)
VALUES
('Central Processing Unit', 6, 1),  -- Correct Answer
('Central Program Unit', 6, 0),
('Central Processing Unit Operations', 6, 0),
('Central Processor Unit', 6, 0);

-- For Question 7: 'The Earth is flat.'
INSERT INTO Choice (Content, QuestionID, IsCorrect)
VALUES
('True', 7, 0),   -- Incorrect Answer
('False', 7, 1);   -- Correct Answer

-- For Question 8: 'Python is a compiled language.'
INSERT INTO Choice (Content, QuestionID, IsCorrect)
VALUES
('True', 8, 0),   -- Incorrect Answer
('False', 8, 1);   -- Correct Answer

-- For Question 9: 'The speed of light is constant in a vacuum.'
INSERT INTO Choice (Content, QuestionID, IsCorrect)
VALUES
('True', 9, 1),   -- Correct Answer
('False', 9, 0);

-- For Question 10: 'What does HTTP stand for?'
INSERT INTO Choice (Content, QuestionID, IsCorrect)
VALUES
('HyperText Transfer Protocol', 10, 1),  -- Correct Answer
('HyperText Transmission Protocol', 10, 0),
('HyperText Transport Protocol', 10, 0),
('Hyper Transfer Text Protocol', 10, 0);

-- For Question 11: 'Which programming paradigm is associated with Java?'
INSERT INTO Choice (Content, QuestionID, IsCorrect)
VALUES
('Object-Oriented Programming', 11, 1),  -- Correct Answer
('Functional Programming', 11, 0),
('Procedural Programming', 11, 0),
('Logic Programming', 11, 0);

-- For Question 12: 'HTML is a programming language.'
INSERT INTO Choice (Content, QuestionID, IsCorrect)
VALUES
('True', 12, 0),  -- Incorrect Answer
('False', 12, 1);  -- Correct Answer

-- For Question 13: 'C++ supports both procedural and object-oriented programming.'
INSERT INTO Choice (Content, QuestionID, IsCorrect)
VALUES
('True', 13, 1),   -- Correct Answer
('False', 13, 0);

-- For Question 3: 'Explain the concept of Polymorphism in object-oriented programming.'
-- Model Answer for TXT question
INSERT INTO Choice (Content, QuestionID, IsCorrect)
VALUES
('Polymorphism is the ability of different classes to respond to the same method call in different ways, depending on the object that invokes it. It allows for method overriding and dynamic method dispatch, where the method that gets executed is determined at runtime based on the object type.', 3, 1);

-- For Question 14: 'Explain how the binary search algorithm works.'
-- Model Answer for TXT question
INSERT INTO Choice (Content, QuestionID, IsCorrect)
VALUES
('Binary search is a divide-and-conquer algorithm used to find the position of a target value within a sorted array or list. It works by repeatedly dividing the search interval in half. If the value of the target is less than the value in the middle of the interval, the search continues in the lower half, or in the upper half if the target is greater.', 14, 1);

-- For Question 15: 'What are the advantages of using version control systems like Git?'
-- Model Answer for TXT question
INSERT INTO Choice (Content, QuestionID, IsCorrect)
VALUES
('Version control systems like Git allow multiple developers to work on the same project simultaneously without overwriting each other s work. Git provides a history of changes, making it easier to track and revert to previous versions of code. It also supports branching, allowing developers to work on features independently without affecting the main codebase.', 15, 1);


-----------------------------------------------------------------------


