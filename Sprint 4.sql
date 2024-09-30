-- 1.1
select distinct credit_cards.user_id 'usuaris amb més de 30 transaccions' from credit_cards
join transactions on transactions.card_id=credit_cards.id
where card_id in(
	SELECT card_id FROM sprint4.transactions where declined=0 group by card_id having count(*) >30
);

-- 1.2 

select credit_cards.iban 'iban Donec Ltd',avg(transactions.amount)'mitjana d´amount' from credit_cards
join transactions on transactions.card_id=credit_cards.id
join companies on transactions.business_id=companies.company_id
where transactions.declined = 0 and companies.company_name='Donec Ltd'
group by credit_cards.iban
;

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
