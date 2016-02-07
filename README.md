## Here you can find test task with postgresql
To test in on your invironment you should: 
1) install ubuntu ro use linux
2) install docker 
3) install postgres
4) install plpgunit in postgres 

or 

1) you can provide some remote postgres


I like when code well tested, and plsql should be tested too. So lets begin: 

###Installing docker on Ubuntu 15:
```
 sudo su
 apt-get update
 apt-get install apt-transport-https ca-certificates
 apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
 echo 'deb https://apt.dockerproject.org/repo ubuntu-wily main' >> /etc/apt/sources.list.d/docker.list
 apt-get update
 apt-cache policy docker-engine
 apt-get install linux-image-extra-$(uname -r)
 apt-get install docker-engine
 service docker start
 docker run hello-world
 reboot
```

###Configuring your_user to run docker without user 
```
sudo usermod -aG docker your_user
reboot
docker run hello-world
```
 
###Configuring docker run on boot
```
sudo systemctl enable docker
reboot
docker info
```

###installing and running postgresql in docker
(docker_name: postgres, postgres_user=postgres, postgres_password=postgres, postgres_db=task, port 5432)
docker run --name postgres -p 127.0.0.1:5432:5432 -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=task -e POSTGRES_USER=postgres -d postgres
docker ps

result should be something like this: 
```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
b8afdffd35c4        postgres            "/docker-entrypoint.s"   52 seconds ago      Up 51 seconds       5432/tcp            9.5.0
```

to stop docker you should run (where postgres is docker container name)
```
docker stop postgres
```

to run docker
```
docker run -d postgres
```

###installing postgreSQL on Ubuntu 
```
sudo apt-get install postgresql-client
```

###get access to postgres
```
export PGPASSWORD=postgres
psql -h localhost -U postgres -d task
```

###install plpguint
```
git clone https://github.com/mixerp/plpgunit.git
cd plpgunit/install
\i 0.uninstall-unit-test.sql
\i 1.install-unit-test.sql
```


### install database schema, tables, so on
```
\i university/schemas/courses.sql
\i university/schemas/university.sql
\i university/domains/numeric_id.sql
\i university/students/tables/university.student.sql
\i university/tests/tables/courses.test.sql
\i university/versions/tables/courses.version.sql
\i university/pages/tables/courses.page.sql
\i university/pages/tables/courses.student_page.sql
\i university/funcitons/fetch_missed_pages.sql
```

### to run unit tests to check table structure and function:
```
\i university/unit_tests/university_students.sql
\i university/unit_tests/university_students_indexes.sql
\i university/unit_tests/courses_tests.sql
\i university/unit_tests/courses_tests_indexes.sql
\i university/unit_tests/courses_versions_indexes.sql
\i university/unit_tests/courses_versions.sql
\i university/unit_tests/courses_pages_indexes.sql
\i university/unit_tests/courses_pages_primary_key_indexes.sql
\i university/unit_tests/courses_pages.sql
\i university/unit_tests/courses_pages_sub_indexes.sql
\i university/unit_tests/unit_tests.sql
```

task implemented in ```courses.fetch_missed_pages (BIGINT,VARCHAR)``` function

###after all executed you can run this commands to insert test data:

```
--- find 10 not used test ids
drop table IF EXISTS  tests_id_test; 
create TEMPORARY table tests_id_test  as 		
		SELECT numbers.value as ID,
    concat('test name ', numbers.value) as NAME,
		row_number() over() as num
    from generate_series(0, 100000) as numbers(value) WHERE
    NOT EXISTS (
        SELECT st.id FROM courses.test st WHERE st.id = numbers.value
    ) limit 10;

--- find 30 not used versions ids and map them to tests
drop table IF EXISTS  versions_ids_test; 
create TEMPORARY table versions_ids_test  as 		
		SELECT numbers.value as ID, 
    concat('test version name ', numbers.value) as NAME,
		mod(row_number() over(),10) as test_id, 
		row_number() over() as version_row
 from generate_series(0, 100000) as numbers(value) WHERE
    NOT EXISTS (
        SELECT st.id FROM courses.version st WHERE st.id = numbers.value
    ) limit 30;


--- find 55 not used pages ids and set them to some versions
drop table IF EXISTS pages_ids_test; 
create TEMPORARY table pages_ids_test  as 		
		SELECT numbers.value as ID,
    concat('test page name ', numbers.value) as NAME,
    mod(row_number() over(),30) as version_id,
    row_number() over() as student_id,   
		0 as index_id
    from generate_series(0, 100000) as numbers(value) WHERE
    NOT EXISTS (
        SELECT st.id FROM courses.page st WHERE st.id = numbers.value
    ) limit 55;

update  pages_ids_test set 
     index_id = ids_test_prepared.index_id_updated
     from(
          select sub.id, (rank() OVER (PARTITION BY sub.version_id ORDER BY sub.ID DESC)) as index_id_updated
          from pages_ids_test sub) as  ids_test_prepared where
       ids_test_prepared.id=pages_ids_test.id;

update  pages_ids_test set 
     version_id = ids_test_prepared.version_id
     from(
          select sub.id, version_number.id as version_id
          from pages_ids_test sub 
						inner join 
								(select vit.id, (row_number() over()) as num 
										from versions_ids_test vit) as version_number on version_number.num=sub.version_id ) as  ids_test_prepared where
       ids_test_prepared.id=pages_ids_test.id;



--- find 10 not used student ids
drop table IF EXISTS students_ids_test; 
create TEMPORARY table students_ids_test  as 		
		SELECT numbers.value as ID,
    concat('test student name ', numbers.value) as NAME,
		row_number() over() as num
    from generate_series(0, 100000) as numbers(value) WHERE
    NOT EXISTS (
        SELECT st.id FROM university.student st WHERE st.id = numbers.value
    ) limit 10;

--- find all combinations for student_pages
drop table IF EXISTS student_pages_ids_test; 
create TEMPORARY table student_pages_ids_test  as 	
select ids.id, pages_id.id as page_id, stdt.id as student_id
    from versions_ids_test as versions_ids  
			inner join pages_ids_test pages_id
				on versions_ids.id=pages_id.version_id
    inner join (SELECT numbers.value as ID, row_number() over() as num
    from generate_series(0, 10000) as numbers(value) WHERE
    NOT EXISTS (
        SELECT st.id FROM courses.student_pages st WHERE st.id = numbers.value
    ) limit 200)  ids on ids.num=pages_id.student_id
inner join students_ids_test stdt on stdt.num=ids.num;

--now we have all data in 

insert into university.student (id, name) select st.id, st.name from students_ids_test st ;
insert into courses.test (id, name) select tst.id, tst.name from tests_id_test tst ;
insert into courses.version (id,test_id, name) select vrs.id,vrs.test_id, vrs.name from versions_ids_test vrs ;
insert into courses.page (id,index,version_id) select pgs.id,pgs.index_id, pgs.version_id from pages_ids_test pgs ;
insert into courses.student_page (id,page_id, student_id, status) 
			select stdp.id,stdp.page_id, stdp.student_id, 1 as value from student_pages_ids_test stdp;

-- now we have all data

```




 
