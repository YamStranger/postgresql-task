/*
Unit test
*/
DROP FUNCTION
IF EXISTS unit_tests.courses_versions ();

CREATE FUNCTION unit_tests.courses_versions() RETURNS test_result AS $$
DECLARE 
	message test_result;
	test_id BIGINT;
BEGIN
	BEGIN
		SELECT
			 l. ID + 1 AS START INTO test_id
		FROM
			 courses.version AS l
		LEFT OUTER JOIN courses.version AS r ON l. ID + 1 = r. ID
		WHERE
			 r. ID IS NULL
		LIMIT 1;

		IF (test_id IS NULL) THEN
			 test_id = 0;
		END IF;

		INSERT INTO courses.version (ID, NAME)
		VALUES
				 (test_id, 'some value');

		SELECT
			 assert.ok (
					'structure correct'
			 ) INTO message;

	EXCEPTION 
	WHEN OTHERS THEN 
		SELECT
			 assert.fail (
					'some fields are absond'
			 ) INTO message;
	END;
RETURN message;
END;
$$ LANGUAGE plpgsql;