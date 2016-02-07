DROP FUNCTION
IF EXISTS get_missing_pages (int,text);

CREATE FUNCTION get_missing_pages(_test_id  int, _version_name text default null) 
    RETURNS TABLE(student_name text,
									version_name char,
									lost_page_indices text)
   AS
$$
BEGIN
    RETURN QUERY
			SELECT cast(student_n as text), cast(version_n as char(500)), 
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
				where t.id = _test_id
								 AND CASE
												WHEN _version_name is not null THEN
													CASE
														WHEN v.name = _version_name THEN
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
