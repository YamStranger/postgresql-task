DO $$
DECLARE 
	domain_name varchar(500);
BEGIN
   SELECT
      conname 
	 INTO domain_name
   FROM
      pg_constraint
   WHERE
      contypid = 'numeric_id'::regtype ;

	IF domain_name IS NULL THEN
	CREATE DOMAIN numeric_id AS BIGINT CHECK (VALUE >= 0);
	END IF;
END;
$$ LANGUAGE plpgsql;
