-- 1
create database sprint_4_v2; use sprint_4_v2;

CREATE TABLE transactions (
    id varchar (200)PRIMARY KEY,
    card_id varchar (100) not null,
    business_id varchar (100),
    timestamp varchar (100),
    amount double,
    declined int,
    product_ids varchar (100),
    user_id varchar(100),
    lat double,
    longitude double,
    index company_key (business_id),    index card_key (card_id),    index product_ids_key (product_ids),
    index timestamp_key (timestamp),    index user_key(user_id),    index declined_key(declined));

CREATE TABLE companies (
    company_id varchar (200) PRIMARY KEY,
    company_name varchar (100),
    phone varchar (100),
    email varchar (100),
    country varchar (100),
    website varchar (100),
    INDEX id_key (company_id));

CREATE TABLE credit_cards (
    id varchar (100) PRIMARY KEY,
    user_id varchar (100),
    iban varchar (100),
    pan varchar (100),
    pin int,
    cvv varchar (100),
    track1 varchar (100),
    track2 varchar (100),
    expiring_date varchar (100),
    INDEX id_key (id));

CREATE TABLE products (
    id varchar (100) PRIMARY KEY,
    product_name varchar (100),
    price varchar (100),
    colour varchar (100),
    weight double,
    warehouse_id varchar (100),
    index id_key(id));


CREATE TABLE users (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(100),
    email VARCHAR(100),
    birth_date VARCHAR(100),
    country VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(100),
    address VARCHAR(100),
    index id_key(id));


LOAD DATA INFILE 'transactions.csv'INTO TABLE transactions FIELDS TERMINATED BY ';'  LINES TERMINATED BY '\n'  IGNORE 1 LINES; 

LOAD DATA INFILE 'companies.csv' INTO TABLE companies FIELDS TERMINATED BY ','  LINES TERMINATED BY '\n'  IGNORE 1 LINES;

LOAD DATA INFILE 'credit_cards.csv' INTO TABLE credit_cards FIELDS TERMINATED BY ','  LINES TERMINATED BY '\n'  IGNORE 1 LINES;

LOAD DATA INFILE 'products.csv' INTO TABLE products FIELDS TERMINATED BY ','  LINES TERMINATED BY '\n'  IGNORE 1 LINES;

LOAD DATA INFILE 'users_ca.csv' INTO TABLE users FIELDS TERMINATED BY ','  OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r'  IGNORE 1 LINES;

LOAD DATA INFILE 'users_usa.csv' INTO TABLE users FIELDS TERMINATED BY ','  OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r'  IGNORE 1 LINES;

LOAD DATA INFILE 'users_uk.csv' INTO TABLE users FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r' IGNORE 1 LINES;

UPDATE users SET id = REPLACE(id, '\n', '');

ALTER TABLE credit_cards ADD CONSTRAINT fk_credit_card_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE transactions ADD CONSTRAINT fk_transaction_user FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE transactions ADD CONSTRAINT fk_transaction_card FOREIGN KEY (card_id) REFERENCES credit_cards(id);

ALTER TABLE transactions ADD CONSTRAINT fk_transaction_business FOREIGN KEY (business_id) REFERENCES companies(company_id);


-- 1.1
select distinct users.id, users.name, users.surname
from users
join credit_cards on users.id = credit_cards.user_id
join transactions on transactions.card_id = credit_cards.id
where credit_cards.id in (
    select card_id 
    from transactions 
    where declined = 0 
    group by card_id 
    having count(*) > 30
)
order by users.id;


-- 1.2 
select credit_cards.iban 'iban Donec Ltd',avg(transactions.amount)'mitjana d´amount' from credit_cards
join transactions on transactions.card_id=credit_cards.id
join companies on transactions.business_id=companies.company_id
where transactions.declined = 0 and companies.company_name='Donec Ltd'
group by credit_cards.iban;

-- 2
alter table transactions 
add activa varchar(10) default 'si' after card_id;

with 	
	recent_transactions as (
select card_id,declined,
row_number()over(partition by card_id order by timestamp desc)as rn	
from transactions), 
    	declined_cards as (
select card_id from recent_transactions		
where rn <= 3	
group by card_id	
having sum(declined) > 2)

update transactions set activa = case
    when card_id in (select card_id from declined_cards) then 'no'
    else 'si'
	end;

select count(*) 'targetes actives' from (select distinct card_id from transactions where activa='si')x;


-- 3
WITH RECURSIVE cte_count (n) AS (
	SELECT 1 UNION ALL SELECT n + 1 
    FROM cte_count 
    WHERE n < 10)
    
select x.idprod 'id', count(*) 'num ventas',products.product_name'producte'
 from(
SELECT TRIM( BOTH FROM SUBSTRING_INDEX( SUBSTRING_INDEX(product_ids, ',', n) ,',',-1) )AS idprod
    	FROM transactions     
  	JOIN cte_count cnt WHERE cnt.n <= LENGTH(product_ids)-LENGTH(REPLACE(product_ids,',','')) +1) x
JOIN products ON x.idprod = products.id
group by idprod
order by idprod;
