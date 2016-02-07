DO $$
DECLARE 
BEGIN
	IF NOT EXISTS (
		SELECT
			 1
		FROM
			 pg_tables tables
		WHERE
			 tables.schemaname = 'university'
		AND tables.tablename = 'student'
	) THEN 
			CREATE TABLE university.student(
			id  numeric_id PRIMARY KEY,
			NAME varchar(500) NOT NULL);

			CREATE UNIQUE INDEX university_student_index ON university.student (ID);
	END IF; 
END;
$$ LANGUAGE plpgsql;
