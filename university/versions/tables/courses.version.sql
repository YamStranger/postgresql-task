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
		AND tables.tablename = 'version'
	) THEN 
			CREATE TABLE courses.version (
			ID numeric_id PRIMARY KEY,
			TEST_ID BIGINT REFERENCES courses.test (ID) ON DELETE CASCADE,
			NAME varchar(500) NOT NULL);
			CREATE UNIQUE INDEX courses_version_index ON courses.version(ID);
	END IF; 
END;
$$ LANGUAGE plpgsql;
