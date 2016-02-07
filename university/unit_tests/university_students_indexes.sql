/*
Unit test
*/
DROP FUNCTION
IF EXISTS unit_tests.university_students_indexes ();

CREATE FUNCTION unit_tests.university_students_indexes() RETURNS test_result AS $$
DECLARE 
	message test_result;
	test_id BIGINT;
BEGIN
	BEGIN
		SELECT
			 l. ID + 1 AS START INTO test_id
		FROM
			 university.student AS l
		LEFT OUTER JOIN university.student AS r ON l. ID + 1 = r. ID
		WHERE
			 r. ID IS NULL
		LIMIT 1;

		IF (test_id IS NULL) THEN
			 test_id = 0;
		END IF;

		INSERT INTO university.student (ID, NAME)
		VALUES
				 (test_id, 'same value');

		INSERT INTO university.student (ID, NAME)
		VALUES
				 (test_id, 'same value');

		SELECT
			 assert.fail (
					'Index for id is not configured'
			 ) INTO message;

	EXCEPTION 
	WHEN unique_violation THEN 
		SELECT
			 assert.ok (
					'id will be unique'
			 ) INTO message;
	END;
RETURN message;
END;
$$ LANGUAGE plpgsql;