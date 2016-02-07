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
		AND tables.tablename = 'student_page'
	) THEN 
			CREATE TABLE courses.student_page (
			ID numeric_id PRIMARY KEY,
			STUDENT_ID BIGINT REFERENCES university.student (ID) ON DELETE CASCADE,
			PAGE_ID BIGINT REFERENCES courses.page (ID) ON DELETE CASCADE,
			STATUS INTEGER);
			CREATE UNIQUE INDEX student_page_numbers_index ON courses.student_page(PAGE_ID, STUDENT_ID);
			CREATE UNIQUE INDEX student_page_index ON courses.student_page(ID);
	END IF; 
END;
$$ LANGUAGE plpgsql;
