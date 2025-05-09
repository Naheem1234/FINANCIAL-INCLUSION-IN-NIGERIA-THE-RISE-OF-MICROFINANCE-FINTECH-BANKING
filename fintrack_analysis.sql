USE fintrack;

SELECT * 
FROM branch;


SELECT *
FROM customer;

SELECT *
FROM transaction;

-- 1. What regions have the highest number of fintech bank users vs. traditional bank users? --
SELECT b.Region AS Region,
	COUNT(DISTINCT CASE WHEN b.Bank_Type = 'Fintech MFB' THEN t.Customer_ID END) AS Fintech_Users,
    COUNT(DISTINCT CASE WHEN b.Bank_Type = 'Traditional Bank' THEN t.Customer_ID END) AS Traditional_Bank_Users
FROM transaction AS t
INNER JOIN branch AS B
ON t.Branch_ID = b.Branch_ID
GROUP BY Region
ORDER BY Fintech_Users DESC, Traditional_Bank_Users DESC;
                
-- 2.  What is the average number of transactions per user by bank type? --
SELECT Bank_Type, AVG(Transaction_per_User) AS Average_User
FROM (SELECT DISTINCT t.Customer_ID, b.Bank_Type AS Bank_Type, COUNT(t.Transaction_ID) AS Transaction_per_User
FROM transaction AS t
INNER JOIN branch AS b
ON t.Branch_ID = b.Branch_ID
GROUP BY t.Customer_ID, Bank_Type) AS u
GROUP BY Bank_Type
ORDER BY Average_User;

-- 3. Which bank types are processing more low-value high-frequency transactions? --
ALTER TABLE transaction
ADD COLUMN Transaction_Value VARCHAR(20);
SET SQL_SAFE_UPDATES = 0;
UPDATE transaction
SET Transaction_Value = CASE
WHEN Amount > 50000 THEN 'High_Value'
ELSE 'Low_Value'
END;
SET SQL_SAFE_UPDATES = 1;

SELECT b.Bank_Type AS Bank_Type, COUNT(DISTINCT t.Transaction_ID) AS Low_Value_Transactions
FROM transaction AS t
INNER JOIN branch AS b
ON t.Branch_ID = b.Branch_ID
WHERE Transaction_Value = "Low_Value"
GROUP BY Bank_Type
ORDER BY Low_Value_Transactions DESC;

-- 4. Are fintech banks more used for transfers, while traditional banks focus on deposits/withdrawals? --
SELECT t.Transaction_Type AS Transaction_Type,
COUNT(CASE WHEN b.Bank_Type = 'Fintech MFB' THEN t.Transaction_ID END) AS Fintech_MFB,
COUNT(CASE WHEN b.Bank_Type = 'Traditional Bank' THEN t.Transaction_ID END) AS Traditional_Bank,
COUNT(CASE WHEN b.Bank_Type = 'Legacy MFB' THEN t.Transaction_ID END) AS Legacy_MFB
FROM transaction AS t
INNER JOIN branch AS B
ON t.Branch_ID = b.Branch_ID
WHERE Transaction_Type IN ("Deposit", "Withdrawal","Transfer")
GROUP BY Transaction_Type
ORDER BY Transaction_Type;

-- 5. Do younger customers (18–25) prefer fintech banks? --
SELECT c.Age AS Age,
COUNT(DISTINCT CASE WHEN b.Bank_Type = 'Fintech MFB' THEN t.Customer_ID END) AS Fintech_Users,
COUNT(DISTINCT CASE WHEN b.Bank_Type = 'Traditional Bank' THEN t.Customer_ID END) AS Traditional_Bank_Users,
COUNT(DISTINCT CASE WHEN b.Bank_Type = 'Legacy MFB' THEN t.Customer_ID END) AS Legacy_Users
FROM transaction AS t
INNER JOIN customer AS c
ON t.Customer_ID = c.Customer_ID
INNER JOIN branch AS b
ON t.Branch_ID = b.Branch_ID
GROUP BY Age
ORDER BY Age;

-- 6. What’s the loan repayment rate among fintech MFBs compared to traditional banks? --
SELECT b.Bank_Type AS Bank_Type,
COUNT(DISTINCT CASE WHEN Transaction_Type = 'Loan Disbursement' THEN t.Transaction_ID END) AS Total_Disbursed_Loan,
COUNT(DISTINCT CASE WHEN Transaction_Type = 'Loan Payment' THEN t.Transaction_ID END) AS Total_Repaid_Loan,
((COUNT(DISTINCT CASE WHEN Transaction_Type = 'Loan Payment' THEN t.Transaction_ID END) * 100)/(COUNT(DISTINCT CASE WHEN Transaction_Type = 'Loan Disbursement' THEN t.Transaction_ID END))) AS Loan_Repayment_Rate
FROM transaction AS t
INNER JOIN branch AS b
ON t.Branch_ID = b.Branch_ID
GROUP BY Bank_Type
ORDER BY Bank_Type;

-- 7. What is the average disbursement size and frequency across segments? --
SELECT b.Bank_Type AS Bank_Type, AVG(Amount) AS Average_Disbursement_Size
FROM transaction AS t
INNER JOIN branch AS b
ON t.Branch_ID = b.Branch_ID
WHERE Transaction_Type = 'Loan Disbursement'
GROUP BY Bank_Type;

SELECT Bank_Type, AVG(Transaction_per_Customer) AS Average_Disbursement_Frequency
FROM (SELECT DISTINCT t.Customer_ID, b.Bank_Type AS Bank_Type, COUNT(t.Transaction_ID) AS Transaction_per_Customer
FROM transaction AS t
INNER JOIN branch AS b
ON t.Branch_ID = b.Branch_ID
WHERE Transaction_Type = 'Loan Disbursement'
GROUP BY t.Customer_ID, Bank_Type) AS u
GROUP BY Bank_Type
ORDER BY Average_Disbursement_Frequency;

-- 8. Which bank type brings higher cumulative transaction value? --
SELECT b.Bank_Type AS Bank_Type, SUM(t.Amount) AS Cumulative_Transaction_Value
FROM transaction AS t
INNER JOIN branch AS b
ON t.Branch_ID = b.Branch_ID
GROUP BY Bank_Type
ORDER BY Cumulative_Transaction_Value DESC;


