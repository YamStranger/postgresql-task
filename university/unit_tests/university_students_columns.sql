/*
Unit test
*/
DROP FUNCTION
IF EXISTS unit_tests.university_students_columns();

CREATE FUNCTION unit_tests.university_students_columns() RETURNS test_result AS $$
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
				 (test_id, 'some value');

		SELECT
			 assert.ok (
					'Insertion of simple unique student is successful'
			 ) INTO message;

	EXCEPTION 
	WHEN OTHERS THEN 
		SELECT
			 assert.fail (
					'Insertion of simple student is failed'
			 ) INTO message;
	END;
RETURN message;
END;
$$ LANGUAGE plpgsql;