USE [ITI-Examination-System-DB];
GO

-------------------------------------------------------------------
-- trigger to prevevnt dublicate Exam Assignment
GO

CREATE OR ALTER TRIGGER trg_PreventDuplicateExamAssignment
ON Result
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT StudID, ExamID
        FROM Result
        GROUP BY StudID, ExamID
        HAVING COUNT(*) > 1
    )
    BEGIN
        RAISERROR ('Error: A student cannot be assigned the same exam twice!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
-----------------------------------------------------------------

-- trg_PreventDuplicateExamAssignment  >> trigger to prevevnt dublicate Exam Assignment
