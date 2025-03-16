USE mbd_employee


-- Buat Stored Procedure bernama GetEmployeeDetails yang menerima EmployeeID
-- sebagai input dan mengembalikan:
-- a. Nama karyawan melalui parameter OUT name_out.
-- b. Nama departemen tempat karyawan bekerja melalui parameter OUT dept_out.
-- c. Jika karyawan tidak ditemukan, tampilkan pesan error.

DELIMITER $$

CREATE PROCEDURE GetEmployeeDetails(
	IN EmployeeID CHAR(9),
	OUT name_out VARCHAR(20),
	OUT dept_out VARCHAR(15)
)
BEGIN
	SELECT CONCAT(e.fname, ' ', e.lname), d.Dname INTO name_out, dept_out
	FROM employee e
	JOIN department d ON e.Dno = d.Dnumber
	WHERE e.Ssn = EmployeeID;
	
	IF name_out IS NULL THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Karyawan tidak ditemukan';
	END IF;

END$$

DELIMITER;
	
CALL GetEmployeeDetails(888665555, @nama, @dept);
SELECT @nama AS EmployeeName, @dept AS departmentName

CALL GetEmployeeDetails(888664445, @nama, @dept);
SELECT @nama AS EmployeeName, @dept AS departmentName


-- Buat Trigger bernama PreventDeptDeletion yang mencegah penghapusan departemen
-- dari tabel department jika masih ada karyawan (employee) yang bekerja di departemen
-- tersebut.

DROP TRIGGER IF EXISTS PreventDeptDeletion;

DELIMITER $$

CREATE TRIGGER PreventDeptDeletion
BEFORE DELETE ON department
FOR EACH ROW
BEGIN
	IF EXISTS (SELECT 1 FROM employee e 
					JOIN department d
					ON e.Dno = d.Dnumber
					WHERE e.Dno = d.Dnumber
	) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tidak dapat menghapus departemen yang masih memiliki karyawan';
   END IF;
END$$

DELIMITER ;

DELETE FROM department WHERE Dname = 'Administration';

-- Buat View bernama ProjectEmployeeSummary yang menampilkan ringkasan proyek
-- dan karyawan yang bekerja di setiap proyek. View ini menampilkan:
-- a. Id project
-- b. Nama project
-- c. Id employee
-- d. Nama employee
-- e. Nama departemen

DROP VIEW IF EXISTS ProjectEmployeeSummary;

CREATE VIEW ProjectEmployeeSummary AS 
SELECT 
	p.Pnumber AS ProjectID,
	p.Pname AS ProjectName,
	e.Ssn AS EmployeeID,
	CONCAT (e.fname, ' ', e.lname) AS EmployeeName,
	d.Dname AS DepartmentName
FROM project p
JOIN works_on w ON p.Pnumber = w.Pno
JOIN employee e ON w.Essn = e.Ssn
JOIN department d ON e.Dno = d.Dnumber;

SELECT * FROM ProjectEmployeeSummary;


