-- ============================================================
-- EX 603 Assignment 3 - q3_2.sql
-- Task 3.2: Find the bug
-- Database: ex603_data (gaming.sql reference dataset)
-- Author: Aleksei Glebov
-- ============================================================
--
-- The dashboard's failure state is a network timeout:
--   match_participants.disconnect_reason = 'Network timeout'
-- disconnect_reason is nullable by design (see 3.1d-2: 166 of 200 rows are NULL).
--
-- ============================================================


-- ============================================================
-- Part A: The rows that vanished (three-valued logic)
-- ============================================================

--
-- 3.2A-0 Table total, for comparison.
--

SELECT count(*) FROM match_participants;

-- Output:
--  count
-- -------
--    200
-- (1 row)

--
-- 3.2A-1 The broken query: "everything that is NOT a network timeout".
--        Requirement: negation / inequality on a nullable column.
--

SELECT COUNT(*) FROM match_participants
WHERE disconnect_reason != 'Network timeout';

-- Output:
--  count
-- -------
--     22
-- (1 row)

--
-- 3.2A-2 The rows the broken query silently dropped.
--

SELECT COUNT(*) FROM match_participants
WHERE disconnect_reason = 'Network timeout';

-- Output:
--  count
-- -------
--     12
-- (1 row)

SELECT COUNT(*) FROM match_participants
WHERE disconnect_reason IS NULL;

-- Output:
--  count
-- -------
--    166
-- (1 row)

--
-- Result: 22 + 12 = 34, not 200, so, the != filter silently dropped 166 rows where disconnect_reason is NULL.
--

--
-- 3.2A-3 The repair.
--        Requirement: explicit IS NULL or COALESCE.
--

SELECT COUNT(*) FROM match_participants
WHERE disconnect_reason != 'Network timeout'
   OR disconnect_reason IS NULL;

-- Output:
--  count
-- -------
--    188
-- (1 row)

-- Result: 188 + 12 = 200. With IS NULL every row is accounted for.

-- ============================================================
-- Part B: The alias that did not exist yet (logical evaluation order)
-- ============================================================

--
-- 3.2B-1 The broken query: an alias from SELECT used in WHERE.

SELECT participation_id, score * xp_multiplier AS final_score
FROM match_participants
WHERE final_score > 50;

-- Output:
-- ERROR:  column "final_score" does not exist
-- LINE 3: WHERE final_score > 50;

--
-- 3.2B-2 Rewrite 1: repeat the expression in WHERE.

SELECT participation_id, score * xp_multiplier AS final_score
FROM match_participants
WHERE score * xp_multiplier > 50;

-- Output:
--  participation_id | final_score
-- ------------------+-------------
--                18 |     95.6200
--                43 |    141.7200
--                47 |     87.4400
--                54 |     56.3850
--                60 |     72.6150
--                67 |     84.0400
--                78 |     75.3750
--                94 |     80.9600
--                99 |     55.4600
--               100 |     60.5850
--               104 |    118.2800
--               105 |     80.3200
--               108 |     62.6600
--               116 |     60.2000
--               138 |     68.3600
--               148 |     69.0800
--               164 |     52.1850
--               177 |     54.0200
--               190 |     70.5300
--               200 |     97.6000
-- (20 rows)

--
-- 3.2B-3 Rewrite 2: wrap the query in a CTE (WITH ...) or a subquery,
--        so the alias becomes a real column.

WITH scored AS (
    SELECT participation_id, score * xp_multiplier AS final_score
    FROM match_participants
)
SELECT * FROM scored
WHERE final_score > 50;

-- Output: same as 3.2B-2. See above.
