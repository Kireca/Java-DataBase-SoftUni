
-- 1
CREATE TABLE `waiters`(

                          `id`         int PRIMARY KEY AUTO_INCREMENT,
                          `first_name` VARCHAR(50) NOT NULL,
                          `last_name`  VARCHAR(50) NOT NULL,
                          `email`      VARCHAR(50) not null,
                          `phone`      VARCHAR(50),
                          `salary`     DECIMAL(10, 2)

);
CREATE TABLE `tables`(

                         id       int primary key auto_increment,
                         floor    int not null,
                         reserved TINYINT(1),
                         capacity int NOT NULL


);

CREATE TABLE `clients`(

                          `id`         INT PRIMARY KEY AUTO_INCREMENT,
                          `first_name` VARCHAR(50) not null,
                          `last_name`  VARCHAR(50) not null,
                          `birthdate`  DATE        NOT NULL,
                          `card`       VARCHAR(50),
                          `review`     TEXT


);

CREATE TABLE `products`(
                           `id`    int primary key auto_increment,
                           `name`  VARCHAR(30)    not null UNIQUE,
                           `type`  VARCHAR(30)    not null,
                           `price` DECIMAL(10, 2) NOT NULL

);

CREATE TABLE `orders`(
                         `id`           int primary key auto_increment,
                         `table_id`     int  not null,
                         `waiter_id`    int  not null,
                         `order_time`   TIME NOT NULL,
                         `payed_status` TINYINT(1),
                         CONSTRAINT fk_table_id
                             FOREIGN KEY (table_id) REFERENCES tables (id),
                         CONSTRAINT fk_waiter_id FOREIGN KEY (waiter_id) REFERENCES waiters (id)


);



CREATE TABLE `orders_products`(

                                  `order_id`   INT,
                                  `product_id` INT,
                                  CONSTRAINT `fk_order_mapping`
                                      FOREIGN KEY (order_id) REFERENCES orders (id),
                                  CONSTRAINT FOREIGN KEY (product_id) REFERENCES products (id)


);



CREATE TABLE `orders_clients`(
                                 `order_id`  INT,
                                 `client_id` INT,
                                 CONSTRAINT `fk_order_clients` FOREIGN KEY (order_id) REFERENCES orders (id),
                                 CONSTRAINT `fk_clients` FOREIGN KEY (client_id) REFERENCES clients (id)

);


-- 2

INSERT INTO `products` (`name`, type, price)(SELECT CONCAT(last_name, ' ', 'specialty'),
                                                    'Cocktail',
                                                    CEIL(salary * 0.01)
                                             FROM waiters
                                             WHERE id > 6);

SELECT *
FROM products p
Where p.id >= 200;


-- 3


UPDATE orders
SET `table_id` = table_id - 1
WHERE id BETWEEN 12 and 23;

-- 4
DELETE w
FROM waiters as w
         LEFT JOIN orders o on w.id = o.waiter_id
WHERE waiter_id IS NULL;

-- 5

SELECT *
FROM clients
ORDER BY birthdate desc, id desc;


-- 6

SELECT first_name, last_name, birthdate, review
FROM clients
WHERE card IS NULL
    AND YEAR(birthdate) BETWEEN 1978 AND 1993
ORDER BY last_name DESC, id
    LIMIT 5;


-- 7
SELECT concat(w.last_name, w.first_name, length(w.first_name), 'Restaurant') as 'username',
        REVERSE(SUBSTR(email, 2, 12))                                         as 'password'
FROM waiters as w
WHERE salary IS NOT NULL
ORDER BY password desc;
-- asd

-- 8
SELECT p.id, p.name, COUNT(product_id) AS 'count'
FROM products AS p
         JOIN orders_products op on p.id = op.product_id
GROUP BY p.id, p.name
HAVING count >= 5
ORDER BY count desc, p.name;


-- 9
SELECT t.id,
       t.capacity,
       COUNT(oc.client_id) as 'count_clients',
        (SELECT CASE
                    WHEN t.capacity = COUNT(oc.client_id) THEN 'Full'
                    WHEN t.capacity > COUNT(oc.client_id) THEN 'Free seats'
                    WHEN t.capacity < COUNT(oc.client_id) THEN 'Extra seats'
                    END)    as 'availability'
FROM tables as t

         JOIN orders o on t.id = o.table_id
         JOIN orders_clients oc on o.id = oc.order_id
where t.floor = 1
GROUP BY t.id
ORDER BY t.id desc;

-- 10
DELIMITER $$
CREATE FUNCTION udf_client_bill(full_name VARCHAR(50))
    RETURNS DECIMAL(10, 2)
    DETERMINISTIC
BEGIN
    DECLARE bill DECIMAL(19, 2);

    SET bill := (SELECT sum(p.price) as 'current_name'
                 FROM clients as c
                          JOIN orders_clients oc on c.id = oc.client_id
                          JOIN orders_products op on oc.order_id = op.order_id
                          JOIN products p on p.id = op.product_id
                 WHERE concat(c.first_name, ' ', c.last_name) = full_name);


RETURN bill;
end;


DELIMITER ;


-- 11

CREATE PROCEDURE udp_happy_hour(given_type VARCHAR(50))
BEGIN

UPDATE products as p
SET price = price * 0.80
WHERE price >= 10
  AND p.type = given_type;


end;


-- TEST
CALL udp_happy_hour('Cognac');


