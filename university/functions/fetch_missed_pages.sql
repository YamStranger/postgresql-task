DROP FUNCTION
IF EXISTS courses.fetch_missed_pages (BIGINT,VARCHAR);

CREATE FUNCTION courses.fetch_missed_pages(input_test_id BIGINT, version_name VARCHAR(500) DEFAULT '') 
    RETURNS TABLE(student_name VARCHAR,
									version_name_val VARCHAR,
									index INTEGER)
   AS
$$
BEGIN
    RETURN QUERY
				WITH filtered_pages AS (
					 SELECT
							cour.name AS version_name,
							pg.version_id AS version_id,
							pg.index,
							stdp.page_id,
							stdp.id AS student_page_id,
							std.name AS student_name
					 FROM
							courses.student_page stdp
					 INNER JOIN courses.page pg ON pg.id = stdp.page_id
					 INNER JOIN courses.version cour ON cour.id = pg.version_id
					 INNER JOIN university.student std ON std.id = stdp.student_id
					 WHERE
							cour.test_id = input_test_id
					 AND CASE
									WHEN CHAR_LENGTH (version_name) > 1 THEN
										CASE
											WHEN cour. NAME = version_name THEN
													1
										ELSE
													2
										END
									ELSE
										1
									END = 1
				) SELECT
					 fil.student_name,
					 fil.version_name,
					 fil.index
				FROM
					 courses.page pg_all
				INNER JOIN filtered_pages fil ON fil.version_id = pg_all.version_id
				LEFT JOIN filtered_pages once_more ON once_more.page_id = pg_all. ID
				WHERE
					 once_more.page_id IS NULL;
END;
$$ LANGUAGE plpgsql;
