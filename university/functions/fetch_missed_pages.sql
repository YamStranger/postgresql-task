DROP FUNCTION
IF EXISTS courses.fetch_missed_pages (BIGINT,VARCHAR);

CREATE FUNCTION courses.fetch_missed_pages(input_test_id BIGINT, version_name VARCHAR(500) DEFAULT NULL) 
    RETURNS TABLE(student_name VARCHAR,
									version_name_val VARCHAR,
									indexes text)
   AS
$$
BEGIN
    RETURN QUERY
			SELECT student_n, version_n, 
					array_to_string(array_agg(page_index ORDER BY page_index), ' ') As indexes
			FROM (select 
				stud.name as student_n, 
				v.name as version_n, 
				pg_r.INDEX as page_index,
				stud.id as student_id,  
				v.id as version_id
			 from  courses.student_page st
				inner join courses.page pg 
					on pg.id=st.page_id
				inner join courses.version v
					on v.id=pg.version_id
				inner join courses.test t 
					ON t.id=v.test_id
				inner join university.student stud
					on stud.id=st.student_id
				right join courses.page pg_r
					on pg_r.version_id=v.id
				where t.id = input_test_id
								 AND CASE
												WHEN version_name is not null THEN
													CASE
														WHEN v.name = version_name THEN
																1
													ELSE
																2
													END
												ELSE
													1
										 END = 1
				and pg_r.id <> pg.id
			) subquery
			GROUP BY (student_id, version_id, student_n,version_n)
			ORDER BY student_n;
END;
$$ LANGUAGE plpgsql;
