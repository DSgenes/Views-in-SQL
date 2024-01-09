/*

Views - View is a database object which is created based on a Sql query. 
        Its like giving a name to the results returned from a sql query and storing it in the database 
		as a view.

*/
drop table tb_customer_data;
create table tb_customer_data
            (cust_id varchar(10) Primary Key, cust_name varchar(50), phone bigint, email varchar(100), address varchar(250));
			
insert into tb_customer_data
values      ('C1', 'Mohan Kumar', '9900807090', 'mohan@demo.com', 'Bangalore'),
            ('C2', 'James Xavier', '8800905544', 'james@demo.com', 'Mumbai'),
			('C3', 'Priyanka Verma', '9900223333', 'priyanka@demo.com', 'Chennai'),
			('C4', 'Eshal Maryam', '9900822111','eshal@demo.com', 'Delhi');

drop table tb_product_info;
create table tb_product_info
            (prod_id varchar(10) Primary Key, prod_name varchar(50), brand varchar(50), price int); 

insert into tb_product_info
values      ('P1', 'Samsung S22', 'Samsung', 800),
			('P2', 'Google Pixel 6 Pro', 'Google', 900),
			('P3', 'Sony Bravia TV', 'Sony', 600),
			('P4', 'Dell XPS 17', 'Dell', 2000),
			('P5', 'iPhone 13', 'Apple', 800),
			('P6', 'MacBook Pro 16', 'Apple', 5000);

create table tb_order_details
            (ord_id bigint Primary Key, prod_id varchar(10), quantity int, cust_id varchar(10), disc_percent int, date date);

insert into tb_order_details
values      (1, 'P1', 2, 'C1', 10, '2020-01-01'),
            (2, 'P2', 1, 'C2', 0, '2020-01-01'),
			(3, 'P2', 3, 'C3', 20, '2020-02-01'),
			(4, 'P3', 1, 'C1', 0, '2020-02-01'),
			(5, 'P3', 1, 'C1', 0, '2020-03-01'),
			(6, 'P3', 4, 'C1', 25, '2020-04-01'),
			(7, 'P3', 1, 'C1', 0, '2020-05-01'),
			(8, 'P5', 1, 'C2', 0, '2020-02-01');

--Generate a report to gather the order summary. (to be given to client/vendor)
select o.ord_id, o.date, p.prod_name, c.cust_name, (p.price * o.quantity) - ((p.price * o.quantity) * disc_percent::float/100) as cost 
from tb_customer_data c
join tb_order_details o on o.cust_id = c.cust_id
join tb_product_info p on p.prod_id = o.prod_id;

--Creating a View
create view order_summary
as
select o.or_id, o.date, p.prod_name, c.cust_name, (p.price * o.quantity) * disc_percent::float/100) as cost 
from tb_customer_data c
join tb_customer_details o on o.cust_id = c.cust_id
join tb_product_info p on p.prod_id = o.prod_id;

-----------------------------------------------------------------------------------------------------------
--Rules when using CREATE or REPLACE and modifying a view
--1. Cannot change column name
--2. Cannot change column datatype
--3. Cannot change order of columns

create or replace view order_summary
as
select o.ord_id, o.date, p.prod_name, c.cust_name, (p.price * o.quantity) - ((p.price * o.quantity) * disc_percent::float/100) as cost
from tb_customer_data c
join tb_order_details o on o.cust_id = c.cust_id
join tb_product_info p on p.prod_id = o.prod_id;

select * from order_summary;
 
--1. Cannot change column name
create or replace view order_summary
as
select o.ord_id, o.date, p.prod_name, c.cust_name, c.cust_id
from tb_customer_data c
join tb_order_details o on o.cust_id = c.cust_id
join tb_product_info p on p.prod_id = o.prod_id;

--2. Cannot change column datatype
create or replace view order_summary
as
select o.ord_id::varchar, o.date, p.prod_name, c.cust_name, (p.price * o.quantity) - ((p.price * o.quantity) * disc_percent::float/100) as cost
from tb_customer_data c
join tb_order_details o on o.cust_id = c.cust_id
join tb_product_info p on p.prod_id = o.prod_id;

--3. Cannot change order of columns
--i cannot add a new columns in between but i can add new column to the end 
create or replace view order_summary
as
select o.ord_id, o.date, p.prod_name, c.cust_name, (p.price * o.quantity) - ((p.price * o.quantity) * disc_percent::float/100) as cost,
       c.cust_id
from tb_customer_data c
join tb_order_details o on o.cust_id = c.cust_id
join tb_product_info p on p.prod_id = o.prod_id;

--in order to change the structure of view i just need to use the command like alter view
--after executing the query the view getting the new column name that is order date 
--altered view only altered the column name of the view but not of the underlying table

alter view order_summary rename column date to order_date;

--Renaming a view by using alter commnad
alter view order_summary rename to order_summary_2;

--Dropping a view
drop view order_summary_2;

--Now i wanted to create a view where i want to only capture the most expensive products 
select * from tb_product_info 
where price > 1000;

create view expensive_products
as
select * from tb_product_info 
where price > 1000;

select * from expensive_products;

--Let me change the structure of this underlying table by adding a new coloumn
alter table tb_product_info add column prod_config varchar(100)

select * from tb_product_info;

--now if i wanted to change the structure of that view in order to recreate/refresh that view
create or replace view expensive_products
as
select * from tb_product_info 
where price > 1000;

select * from expensive_products;

--Inserting a new record
insert into tb_product_info
values      ('P10', 'TEST', 'TEST', 1200, null);
---------------------------------------------------------------------------------------------------------
--Updatable Views
--1. Views should be created using 1 table/view only
--2. View query cannot have DISTINCT clause
--3. View query cannot have GROUP BY clause 
--4. If query contains WITH clause then cannot update such views
--5. If query contains WINDOW functions then cannot update such views.

--1. Views should be created using 1 table/view only
update expensive_products
set prod_name = 'AirPods Pro', brand = 'Apple'
where prod_id = 'P10';

select * from expensive_products;

--Cannot update view using different tables
create or replace view order_summary
as
select o.ord_id, o.date, p.prod_name, c.cust_name, (p.price * o.quantity) - ((p.price * o.quantity) * disc_percent::float/100) as cost,
       c.cust_id
from tb_customer_data c
join tb_order_details o on o.cust_id = c.cust_id
join tb_product_info p on p.prod_id = o.prod_id;

update order_summary
set cost = 10
where ord_id = 1;

--View query cannot have DISTINCT clause
create or replace view expensive_products
as
select distinct * from tb_product_info where price > 1000;

select * from expensive_products;

update expensive_products
set prod_name = 'AirPods Pro 2', brand = 'Apple'
where prod_id = 'P10';

--3. View query cannot have GROUP BY clause 
select date, count(1) as no_of_order
from tb_order_details
group by date;

create view order_count
as
select date, count(1) as no_of_order
from tb_order_details
group by date;

select * from order_count;

--if i want to update this view
update order_count
set no_of_order = 0
where date = '2020-06-01';

--4. If query contains WITH CHECK clause then cannot update such views
--what WITH CHECK option do is whenever someone is trying to do an insert into this view it'll check
--whatever data is getting inserted it's satisfying this where condition
create view apple_products
as
select * from tb_product_info where brand = 'Apple';

insert into apple_products
valuues    ('P20', 'Note 20', 'Samsung', 2500, null);

select * from tb_product_info;
select * from apple_products;

--It works fine only when you're inserting values which satisfying the where conditions
insert into apple_products
valuues    ('P22', 'MacBook Air', 'Apple', 2500, null);

--------------------------------------------------------------------------------------------------------