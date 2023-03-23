--Find all CD accounts with balance above 1000
--and all CHK accounts with balance above 2000 dollars
SELECT ACCOUNT_ID, AVAIL_BALANCE, OPEN_DATE
FROM ACCOUNT
WHERE PRODUCT_CD LIKE 'CD' AND AVAIL_BALANCE > 1000
or PRODUCT_CD LIKE 'CHK' AND AVAIL_BALANCE > 2000
;

--How many checking accounts opened at branch 2 with balance above 1000?
SELECT COUNT(*)
FROM ACCOUNT
WHERE OPEN_BRANCH_ID = 2
AND avail_balance > 1000
AND product_cd LIKE 'CHK'
;

--Join BRANCH and PRODUCT tables 
SELECT A.ACCOUNT_ID, P.NAME AS PRODUCT_NAME, P.PRODUCT_TYPE_CD, B.NAME AS BRANCH_NAME
FROM BRANCH B JOIN (ACCOUNT A JOIN PRODUCT P
ON A.PRODUCT_CD = P.PRODUCT_CD)
ON B.BRANCH_ID = A.OPEN_BRANCH_ID
;

--Join BRANCH, ACCOUNT, and INDIVIDUAL tables
SELECT A.ACCOUNT_ID, I.FNAME, I.LNAME, B.NAME AS Name_of_Branch, B.STATE
FROM BRANCH B JOIN (ACCOUNT A LEFT JOIN INDIVIDUAL I
ON A.CUST_ID = I.CUST_ID)
ON B.BRANCH_ID = A.OPEN_BRANCH_ID
ORDER BY A.ACCOUNT_ID
;

--Join E<PLOYEE and ACCOUNT tables and find out MAX/MIN of available balance
SELECT A.PRODUCT_CD, MAX(A.AVAIL_BALANCE), MIN(A.AVAIL_BALANCE), COUNT(A.ACCOUNT_ID), E.LNAME
FROM EMPLOYEE E JOIN ACCOUNT A
ON A.OPEN_EMP_ID = E.EMP_ID
GROUP BY A.PRODUCT_CD, E.LNAME
ORDER BY COUNT(A.ACCOUNT_ID) DESC
;

--Use 'LIKE' and 'NOT LIKE' syntax to filter out teller works in 2001, 2002, and 2004
SELECT LNAME, DEPT_ID, SUPERIOR_EMP_ID, START_DATE, TITLE
FROM EMPLOYEE
WHERE TITLE LIKE '%Teller' AND START_DATE NOT LIKE '%03' AND START_DATE NOT LIKE '%00'
ORDER BY START_DATE DESC
;

--Join BRANCH, DEPARTMENT, and EMPLYEE tables to find out who is managing others
SELECT DISTINCT E.emp_id, E.fname, E.lname, D.NAME, B.NAME
FROM branch B JOIN
        (
        department D JOIN
            (
            employee E JOIN ACCOUNT A
            ON E.emp_id = A.open_emp_id
            )
        ON D.dept_id = E.dept_id
        )
    ON B.branch_id = E.assigned_branch_id
WHERE emp_id IN (SELECT superior_emp_id FROM employee)
;

--Use 'COUNT' to show how many managers there are
SELECT COUNT(DISTINCT E.emp_id) AS emp_count
FROM branch B JOIN
        (
        department D JOIN
            (
            employee E JOIN ACCOUNT A
            ON E.emp_id = A.open_emp_id
            )
        ON D.dept_id = E.dept_id
        )
    ON B.branch_id = E.assigned_branch_id
WHERE emp_id IN (SELECT superior_emp_id FROM employee)
;

--Right outer join
SELECT M.lname, 
A.open_emp_id, 
SUM(A.avail_balance) AS total_balance, 
COUNT(A.account_id) AS num_of_account
FROM ACCOUNT A JOIN employee E
ON A.open_emp_id = E.emp_id
LEFT OUTER JOIN employee M ON E.superior_emp_id = M.emp_id
GROUP BY M.lname, A.open_emp_id
;

--Create a view with checking accounts with balance above 1000
CREATE VIEW V AS
SELECT account_id, product_cd, avail_balance
FROM ACCOUNT
WHERE avail_balance > 1000
;

--Subquery
SELECT account_id, avail_balance
FROM ACCOUNT
WHERE product_cd LIKE 'CHK'
AND cust_id IN
    (
    SELECT cust_id
    FROM customer
    WHERE STATE LIKE 'MA'
    )
AND open_emp_id IN
    (
    SELECT emp_id
    FROM employee
    WHERE assigned_branch_id IN
        (
        SELECT branch_id
        FROM branch
        WHERE NAME LIKE 'Headquarters'
        )
    )
;
