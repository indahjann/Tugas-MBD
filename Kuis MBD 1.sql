USE mbd_employee

-- Buatlah sebuah View bernama DepartmentProjectSummary yang menampilkan informasi berikut:
-- a. Nama departemen
-- b. Nama manajer departemen
-- c. Nama proyek
-- d. Lokasi proyek
-- e. Total jam kerja semua karyawan dalam proyek tersebut


CREATE VIEW DepartmentProjectSummary AS
SELECT
	d.Dname AS NamaDepartemen,
	CONCAT(e.Fname, ' ', e.Lname) AS NamaManajerDepartemen,
	p.Pname AS NamaProyek,
	p.Plocation AS LokasiProyek,
	SUM(w.Hours) AS TotalJamKerja
FROM department d
JOIN employee e ON d.Dnumber = e.Dno
JOIN project p ON d.Dnumber = p.Dnum
JOIN works_on w ON p.Pnumber = w.Pno
GROUP BY d.Dname, NamaManajerDepartemen, p.Pname, p.Plocation;

SELECT * FROM DepartmentProjectSummary;


-- Buatlah sebuah Trigger bernama CheckProjectHours yang akan dicek sebelum terjadi insert pada tabel works_on. 
-- Trigger ini harus memastikan bahwa nilai hours yang dimasukkan tidak boleh lebih dari 40 jam per proyek. 
-- Jika ada data yang melebihi 40 jam, sistem harus memberikan error. 
-- Bagaimana perintah SQL untuk membuat trigger tersebut?

DELIMITER $$

CREATE TRIGGER CheckProjectHours
BEFORE INSERT ON works_on
FOR EACH ROW
BEGIN
	DECLARE total_hours INT;
	
	SELECT COALESCE(SUM(Hours), 0) + NEW.Hours
	INTO total_hours
	FROM works_on
	WHERE Pno = NEW.Pno
	AND Essn = NEW.Essn;
	
	IF total_hours > 40 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Error: Total jam kerja proyek tidak boleh lebih dari 40 jam!';
	END IF;

END$$

DELIMITER ;

INSERT INTO works_on (Essn, Pno, Hours)
VALUES ('987987987', 1, 20);

INSERT INTO works_on (Essn, Pno, Hours)
VALUES ('987987987', 1, 40);


-- Buatlah sebuah Stored Procedure bernama AddDepartment yang digunakan 
-- untuk menambahkan data departemen baru ke dalam tabel department.
-- Jika sebuah departemen baru bernama Marketing dengan nomor departemen 7, 
-- manajer dengan SSN 999887777, dan tanggal mulai 1990-03-21,
-- bagaimana printah SQL untuk membuat dan memanggil stored procedure tersebut?

DELIMITER $$

CREATE PROCEDURE AddDepartment(
	IN Dname VARCHAR(15),
	IN Dnumber INT,
	IN Mgr_ssn CHAR(9),
	IN Mgr_start_date DATE
)
BEGIN
	INSERT INTO department (Dname, Dnumber, Mgr_ssn, Mgr_start_date)
	VALUES (Dname, Dnumber, Mgr_ssn, Mgr_start_date);
END$$

DELIMITER ;

CALL AddDepartment('Marketing', 7, '999887777', '1990-03-21');

SELECT * FROM department;

-- Buatlah sebuah Function bernama GetNetSalary yang menghitung
-- gaji bersih karyawan setelah pajak dengan ketentuan sebagai berikut:
-- a. Function ini menerima gaji karyawan (Salary) dan persentase pajak (TaxRate) sebagai parameter.
-- b. Function mengembalikan gaji bersih setelah dipotong pajak, yaitu dengan rumus sebagai berikut:
--    NetSalary=Salary−(Salary×TaxRate/100)
-- NetSalary adalah gaji bersih setelah dipotong pajak.
-- Setelah itu, tampilkan karyawan yang memiliki gaji bersih di bawah 30.000
-- setelah dipotong pajak 15% dengan menggunakan function yang telah dibuat.

DELIMITER $$

CREATE FUNCTION GetNetSalary(Salary DECIMAL(10,2), TaxRate DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	DECLARE NetSalary DECIMAL(10,2);
	SET NetSalary = Salary - (Salary * TaxRate / 100);
	RETURN NetSalary;
END$$

DELIMITER ;

SELECT Ssn, Fname, Lname, salary, GetNetSalary(salary, 15) AS net_salary
FROM employee
WHERE GetNetSalary(salary, 15) < 30000;











