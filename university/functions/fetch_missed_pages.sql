/*
courses.fetch_missed_pages
*/
DROP FUNCTION
IF EXISTS courses.fetch_missed_pages ();

CREATE FUNCTION courses.fetch_missed_pages() RETURNS refcursor AS $$
DECLARE
    ref_cursor refcursor;
BEGIN
    OPEN ref_cursor FOR 
with filtered_pages as (select cour.name as version_name, pg.version_id as version_id, pg.index, stdp.page_id, stdp.id as student_page_id, std.name as student_name from courses.student_page stdp
	inner join courses.page pg on pg.id=stdp.page_id
	inner join courses.version cour on cour.id=pg.version_id
	inner join university.student std on std.id=stdp.student_id
) 
select fil.student_name,fil.version_name, fil.index from courses.page pg_all 
		inner join filtered_pages fil 
			on fil.version_id= pg_all.version_id
		left join filtered_pages once_more 
			on once_more.page_id=pg_all.id
		where once_more.page_id is null; 
    RETURN ref_cursor;
END;
$$ LANGUAGE plpgsql;

--to call
-- need to be in a transaction to use cursors.
/**BEGIN;
SELECT courses.fetch_missed_pages();

      reffunc2
--------------------
 <unnamed cursor 1>
(1 row)

FETCH ALL IN "<unnamed portal 2>";
COMMIT;
*/
