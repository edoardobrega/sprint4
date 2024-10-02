--1
create database sprint_4_visual; use sprint_4_visual;

CREATE TABLE transactions (id varchar (200),card_id varchar (100) not null,business_id varchar (100),timestamp varchar (100),amount double,declined int,
product_ids varchar (100),user_id varchar (100),lat double,longitude double,index company_key (business_id),index card_key (card_id),
index product_ids_key (product_ids),index user_key(user_id),PRIMARY KEY id (id));

CREATE TABLE companies (company_id varchar (200) not null,company_name varchar (100),phone varchar (100),email varchar (100),country varchar (100),
website varchar (100),PRIMARY KEY company_id (company_id),INDEX id_key (company_id),FOREIGN KEY (company_id) REFERENCES transactions(business_id));

CREATE TABLE credit_cards (id varchar (100) not null,user_id varchar (100),iban varchar (100),pan varchar (100),pin int,cvv varchar (100),track1 varchar (100),
track2 varchar (100),expiring_date varchar (100),PRIMARY KEY (id),INDEX id_key (id),FOREIGN KEY (id) REFERENCES transactions(card_id));

CREATE TABLE products (id varchar (100) not null,product_name varchar (100),price varchar (100),colour varchar (100),weight double,warehouse_id varchar (100),
PRIMARY KEY (id),index id_key(id));

CREATE TABLE user_ca (id varchar (100) not null,name varchar (100),surname varchar (100),phone varchar (100),email varchar (100),birth_date varchar (100),
country varchar (100),city varchar (100),postal_code varchar(100),address varchar (100),PRIMARY KEY (id),index id_key(id));

CREATE TABLE user_usa (id varchar (100) not null,name varchar (100),surname varchar (100),phone varchar (100),email varchar (100),birth_date varchar (100),
country varchar (100),city varchar (100),postal_code varchar(100),address varchar (100),PRIMARY KEY (id),index id_key(id));

CREATE TABLE user_uk (id varchar (100) not null,name varchar (100),surname varchar (100),phone varchar (100),email varchar (100),birth_date varchar (100),
country varchar (100),city varchar (100),postal_code varchar(100),address varchar (100),PRIMARY KEY (id),index id_key(id));

LOAD DATA INFILE 'transactions.csv'INTO TABLE transactions FIELDS TERMINATED BY ';'  LINES TERMINATED BY '\n'  IGNORE 1 LINES; 

LOAD DATA INFILE 'companies.csv' INTO TABLE companies FIELDS TERMINATED BY ','  LINES TERMINATED BY '\n'  IGNORE 1 LINES;

LOAD DATA INFILE 'credit_cards.csv' INTO TABLE credit_cards FIELDS TERMINATED BY ','  LINES TERMINATED BY '\n'  IGNORE 1 LINES;

LOAD DATA INFILE 'products.csv' INTO TABLE products FIELDS TERMINATED BY ','  LINES TERMINATED BY '\n'  IGNORE 1 LINES;

LOAD DATA INFILE 'users_ca.csv' INTO TABLE user_ca FIELDS TERMINATED BY ','  OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r'  IGNORE 1 LINES;

LOAD DATA INFILE 'users_usa.csv' INTO TABLE user_usa FIELDS TERMINATED BY ','  OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r'  IGNORE 1 LINES;

LOAD DATA INFILE 'users_uk.csv' INTO TABLE user_uk FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r' IGNORE 1 LINES;

SET FOREIGN_KEY_CHECKS=0;

ALTER TABLE products ADD CONSTRAINT fkproducts FOREIGN KEY (id)REFERENCES transactions(product_ids);

ALTER TABLE user_ca ADD CONSTRAINT fk_user_ca FOREIGN KEY (id)REFERENCES transactions(user_id);

ALTER TABLE user_usa ADD CONSTRAINT fk_user_usa FOREIGN KEY (id)REFERENCES transactions(user_id);

ALTER TABLE user_uk ADD CONSTRAINT fk_user_uk FOREIGN KEY (id)REFERENCES transactions(user_id);

-- 1.1
select distinct credit_cards.user_id 'usuaris amb més de 30 transaccions' from credit_cards
join transactions on transactions.card_id=credit_cards.id
where card_id in(SELECT card_id FROM sprint4.transactions where declined=0 group by card_id having count(*) >30);

-- 1.2 
select credit_cards.iban 'iban Donec Ltd',avg(transactions.amount)'mitjana d´amount' from credit_cards
join transactions on transactions.card_id=credit_cards.id
join companies on transactions.business_id=companies.company_id
where transactions.declined = 0 and companies.company_name='Donec Ltd'
group by credit_cards.iban;

-- 2
ALTER TABLE transactions ADD  attiva varchar (10) default 'si' AFTER card_id;
UPDATE transactions SET attiva = CASE
WHEN card_id in (
 select card_id from(
 select * from(
 select card_id,timestamp,declined,ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp desc) AS rn FROM transactions
 ) x
 where rn<4
 ) y
 group by card_id having sum(declined)>2
) THEN REPLACE(attiva, 'si', 'no')
else 'si'
END;
select count(*) 'targetes actives' from (select distinct card_id from transactions where attiva=’si’)x;

-- 3
WITH RECURSIVE cte_count (n) AS (
	SELECT 1 UNION ALL SELECT n + 1 
    FROM cte_count 
    WHERE n < 1000)
    
select idprod 'producte', count(*) 'nombre de vegades que s´ha venut' from(
	SELECT TRIM( BOTH FROM SUBSTRING_INDEX( SUBSTRING_INDEX(product_ids, ',', n) ,',',-1) )AS idprod
    FROM transactions 
    JOIN cte_count cnt WHERE cnt.n <= LENGTH(product_ids) -LENGTH(REPLACE(product_ids,',','')) +1) x
group by idprod
order by idprod;
