/*
Unit test
*/
DROP FUNCTION
IF EXISTS unit_tests.courses_tests ();

CREATE FUNCTION unit_tests.courses_tests() RETURNS test_result AS $$
DECLARE 
	message test_result;
	test_id BIGINT;
BEGIN
	BEGIN
		SELECT
			 l. ID + 1 AS START INTO test_id
		FROM
			 courses.test AS l
		LEFT OUTER JOIN courses.test AS r ON l. ID + 1 = r. ID
		WHERE
			 r. ID IS NULL
		LIMIT 1;

		IF (test_id IS NULL) THEN
			 test_id = 0;
		END IF;

		INSERT INTO courses.test (ID, NAME)
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