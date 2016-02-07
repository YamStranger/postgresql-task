DO $$
DECLARE 
BEGIN
	IF NOT EXISTS (
		SELECT
			 1
		FROM
			 pg_tables tables
		WHERE
			 tables.schemaname = 'courses'
		AND tables.tablename = 'test'
	) THEN 
			CREATE TABLE courses.test (
			ID numeric_id PRIMARY KEY,
			NAME varchar(500) NOT NULL);
			CREATE UNIQUE INDEX courses_test_index ON courses.test(ID);
	END IF; 
END;
$$ LANGUAGE plpgsql;
