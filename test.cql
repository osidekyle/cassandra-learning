DESCRIBE keyspaces;

CREATE KEYSPACE learn_cassandra
  WITH REPLICATION = { 
   'class' : 'NetworkTopologyStrategy',
   'datacenter1' : 3 
  };

  CREATE TABLE learn_cassandra.users_by_country (
    country text,
    user_email text,
    first_name text,
    last_name text,
    age smallint,
    PRIMARY KEY ((country), user_email)
);

INSERT INTO learn_cassandra.users_by_country (country,user_email,first_name,last_name,age)
  VALUES('US', 'john@email.com', 'John','Wick',55);

INSERT INTO learn_cassandra.users_by_country (country,user_email,first_name,last_name,age)
  VALUES('UK', 'peter@email.com', 'Peter','Clark',65);

INSERT INTO learn_cassandra.users_by_country (country,user_email,first_name,last_name,age)
  VALUES('UK', 'bob@email.com', 'Bob','Sandler',23);

INSERT INTO learn_cassandra.users_by_country (country,user_email,first_name,last_name,age)
  VALUES('UK', 'alice@email.com', 'Alice','Brown',26);

SELECT * FROM learn_cassandra.users_by_country WHERE country='US';

CREATE TABLE learn_cassandra.users_by_email (
    user_email text,
    country text,
    first_name text,
    last_name text,
    age smallint,
    PRIMARY KEY (user_email)
);

INSERT INTO learn_cassandra.users_by_email (user_email, country,first_name,last_name,age)
  VALUES('john@email.com', 'US', 'John','Wick',55);

INSERT INTO learn_cassandra.users_by_email (user_email,country,first_name,last_name,age)
  VALUES('peter@email.com', 'UK', 'Peter','Clark',65); 

INSERT INTO learn_cassandra.users_by_email (user_email,country,first_name,last_name,age)
  VALUES('bob@email.com', 'UK', 'Bob','Sandler',23);

INSERT INTO learn_cassandra.users_by_email (user_email,country,first_name,last_name,age)
  VALUES('alice@email.com', 'UK', 'Alice','Brown',26);

SELECT * FROM learn_cassandra.users_by_email WHERE user_email='alice@email.com';

SELECT * FROM learn_cassandra.users_by_email WHERE age=26 ALLOW FILTERING;

CREATE TABLE learn_cassandra.users_by_country_with_leveled_compaction (
    country text,
    user_email text,
    first_name text,
    last_name text,
    age smallint,
    PRIMARY KEY ((country), user_email)
) WITH
  compaction = { 'class' :  'LeveledCompactionStrategy'  };


  CREATE TABLE learn_cassandra.todo_by_user_email (
    user_email text,
    name text,
    creation_date timestamp,
    PRIMARY KEY ((user_email), creation_date)
) WITH CLUSTERING ORDER BY (creation_date DESC)
AND compaction = { 'class' :  'LeveledCompactionStrategy'  };


BEGIN BATCH
  INSERT INTO learn_cassandra.todo_by_user_email (user_email,creation_date,name) VALUES('alice@email.com', toTimestamp(now()), 'My first todo entry')

  INSERT INTO learn_cassandra.todos_shared_by_target_user_email (target_user_email, source_user_email,creation_date,name) VALUES('bob@email.com', 'alice@email.com',toTimestamp(now()), 'My first todo entry')

  INSERT INTO learn_cassandra.todos_shared_by_source_user_email (target_user_email, source_user_email,creation_date,name) VALUES('alice@email.com', 'bob@email.com', toTimestamp(now()), 'My first todo entry')

APPLY BATCH;

  INSERT INTO learn_cassandra.todo_by_user_email (user_email,creation_date,name) VALUES('john@email.com', toTimestamp(now()), 'This entry should be removed soon') USING TTL 60;
