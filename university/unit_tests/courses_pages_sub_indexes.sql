/*
Unit test
*/
DROP FUNCTION
IF EXISTS unit_tests.courses_pages_sub_indexes ();

CREATE FUNCTION unit_tests.courses_pages_sub_indexes() RETURNS test_result AS $$
DECLARE 
	message test_result;
	test_id BIGINT;
	ver_id BIGINT;

BEGIN
	BEGIN
		SELECT
			 l. ID + 1 AS START INTO test_id
		FROM
			 courses.page AS l
		LEFT OUTER JOIN courses.page AS r ON l. ID + 1 = r. ID
		WHERE
			 r. ID IS NULL
		LIMIT 1;

		IF (test_id IS NULL) THEN
			 test_id = 0;
		END IF;

		SELECT
			 l. ID + 1 AS START INTO ver_id
		FROM
			 courses.version AS l
		LEFT OUTER JOIN courses.version AS r ON l. ID + 1 = r. ID
		WHERE
			 r. ID IS NULL
		LIMIT 1;


		IF (ver_id IS NULL) THEN
			 ver_id = 0;
		END IF;

		INSERT INTO courses.version (ID, NAME)
		VALUES
				 (ver_id, 'some version');


		INSERT INTO courses.page (ID, version_id, index)
		VALUES
				 (test_id, ver_id, 1);

		SELECT
			 l. ID + 1 AS START INTO ver_id
		FROM
			 courses.version AS l
		LEFT OUTER JOIN courses.version AS r ON l. ID + 1 = r. ID
		WHERE
			 r. ID IS NULL
		LIMIT 1;

		INSERT INTO courses.page (ID, version_id, index)
		VALUES
				 (test_id, ver_id, 1);

		SELECT
			 assert.fail (
					'Index for id is not configured'
			 ) INTO message;

	EXCEPTION 
	WHEN unique_violation THEN 
		SELECT
			 assert.ok (
					'version_id and index will be unique'
			 ) INTO message;
	END;
RETURN message;
END;
$$ LANGUAGE plpgsql;