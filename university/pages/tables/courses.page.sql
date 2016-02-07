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
		AND tables.tablename = 'page'
	) THEN 
			CREATE TABLE courses.page (
			ID numeric_id PRIMARY KEY,
			VERSION_ID BIGINT REFERENCES courses.version (ID) ON DELETE CASCADE,
			INDEX INTEGER NOT NULL);
			CREATE UNIQUE INDEX courses_page_numbers_index ON courses.page(VERSION_ID, INDEX);
			CREATE UNIQUE INDEX courses_page_index ON courses.page(ID);
	END IF; 
END;
$$ LANGUAGE plpgsql;
