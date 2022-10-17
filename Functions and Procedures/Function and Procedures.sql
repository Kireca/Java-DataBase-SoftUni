-- 01. Employees with Salary Above 35000

CREATE PROCEDURE usp_get_employees_salary_above_35000()
BEGIN
    SELECT `first_name`, last_name
    FROM employees
    WHERE salary > 35000
    ORDER BY first_name, last_name, employee_id;
end;

-- 02. Employees with Salary Above Number

CREATE PROCEDURE usp_get_employees_salary_above(target_salary DECIMAL(19, 4))
BEGIN
    SELECT `first_name`, last_name
    FROM employees
    WHERE salary >= target_salary
    ORDER BY first_name, last_name, employee_id;
end;

-- 03. Town Names Starting With

CREATE PROCEDURE usp_get_towns_starting_with(starting_text VARCHAR(50))
BEGIN
    SELECT name
    FROM towns
    WHERE name LIKE CONCAT(starting_text, '%')
    ORDER BY name;
end;

-- 04. Employees from Town

CREATE PROCEDURE usp_get_employees_from_town(searched_town VARCHAR(50))
BEGIN
    SELECT `first_name`, `last_name`
    FROM employees e
             JOIN addresses as a USING (`address_id`)
             JOIN towns as t USING (`town_id`)
    WHERE t.name = searched_town
    ORDER BY first_name, last_name;

END;

-- 05. Salary Level Function
CREATE FUNCTION ufn_get_salary_level(salary DECIMAL(19, 4))
    RETURNS VARCHAR(10)
    DETERMINISTIC
BEGIN
    DECLARE salary_level VARCHAR(10);
    IF salary < 30000 THEN
        SET salary_level := 'Low';
    ELSEIF salary >= 30000 AND salary <= 50000 THEN
        SET salary_level := 'Average';
    ELSE
        SET salary_level := 'High';
    END IF;
    RETURN salary_level;

end;

-- 06. Employees by Salary Level
CREATE PROCEDURE usp_get_employees_by_salary_level(salary_level VARCHAR(10))
BEGIN

    SELECT first_name, last_name
    FROM employees
    WHERE ufn_get_salary_level(`salary`) = salary_level
    ORDER BY first_name DESC, last_name DESC;


END;

-- 07. Define Function
CREATE FUNCTION ufn_is_word_comprised(set_of_letters VARCHAR(50), word VARCHAR(50))
    RETURNS INT
    DETERMINISTIC
BEGIN

    RETURN word REGEXP (CONCAT('^[', set_of_letters, ']+$'));

end;

-- 08. Find Full Name
CREATE PROCEDURE usp_get_holders_full_name()
BEGIN
    SELECT concat(first_name, ' ', last_name) AS 'full_name'
    FROM account_holders
    ORDER BY full_name, id;
end;

-- 9. People with Balance Higher Than

CREATE PROCEDURE usp_get_holders_with_balance_higher_than(money DECIMAL(19, 4))
BEGIN

    SELECT ah.`first_name`, ah.`last_name`
    FROM account_holders AS ah
             LEFT JOIN accounts AS a ON ah.id = a.`account_holder_id`
    GROUP BY ah.`first_name`, ah.`last_name`
    HAVING SUM(a.`balance`) > money;

end;

-- 10. Future Value Function

CREATE FUNCTION ufn_calculate_future_value(sum DECIMAL(19, 4), yearly_rate DOUBLE, years INT)
    RETURNS DECIMAL(19, 4)
    DETERMINISTIC
BEGIN

    DECLARE future_sum DECIMAL(19, 4);
    SET future_sum := sum * POW(1 + yearly_rate, years);

    RETURN future_sum;

end;
-- 11. Calculating Interest
CREATE PROCEDURE usp_calculate_future_value_for_account(id_input INT, rate DECIMAL(19, 4))
BEGIN

    SELECT a.id                                           as 'account_id',
           ah.first_name,
           ah.last_name,
           balance                                        as 'current_balance',
           ufn_calculate_future_value(a.balance, rate, 5) AS 'balance_in_5_years'
    FROM account_holders AS ah
             JOIN `accounts` AS a ON ah.id = a.account_holder_id
    WHERE a.id = id_input;

end;

-- 12. Deposit Money
CREATE PROCEDURE usp_deposit_money(account_id INT, money_amount DECIMAL(19, 4))
BEGIN

    START TRANSACTION ;
    IF (money_amount <= 0) THEN
        ROLLBACK ;
    ELSE
        UPDATE `accounts`
        SET `balance` = `balance` + money_amount
        WHERE `id` = account_id;
    END IF;

end;


-- 13. Withdraw Money
CREATE PROCEDURE usp_withdraw_money(account_id INT, money_amount DECIMAL(19, 4))
BEGIN

    START TRANSACTION ;

    IF (money_amount <= 0 OR (SELECT `balance` FROM `accounts` WHERE `id` = account_id) < money_amount) THEN
        ROLLBACK ;
    ELSE
        UPDATE `accounts`
        SET `balance` = `balance` - money_amount
        WHERE `id` = account_id;
        COMMIT ;
    END IF;

end;

-- 14. Money Transfer



















