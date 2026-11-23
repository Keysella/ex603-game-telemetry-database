-- ============================================================
-- EX 603 Assignment 4 - q4_2.sql
-- Task 4.2: Find the failure pattern
-- Database: ex603_data (gaming.sql reference dataset)
-- Author: Aleksei Glebov
-- ============================================================
--
-- Roles: event = match_participants, producer = matches (match_id), actor = players,
--        metric = match_participants.score, failure = disconnect_reason = 'Network timeout'
--
-- ============================================================

--
-- Part A: Failure rate per match (conditional aggregation, no WHERE)
--

SELECT match_id,
       COUNT(*) AS events,
       SUM(CASE WHEN disconnect_reason = 'Network timeout' THEN 1 ELSE 0 END) AS timeouts,
       ROUND(100.0 * SUM(CASE WHEN disconnect_reason = 'Network timeout' THEN 1 ELSE 0 END) / COUNT(*), 1) AS timeout_pct
FROM match_participants
GROUP BY match_id
ORDER BY timeout_pct DESC;

-- Result: Match 2 has the highest timeout rate (3 of 16, 18.8%), followed by match 4(16.7%, but only 6 events) and match 3 (2 of 13, 15.4%), and four matches have no timeouts.

-- Output:
--  match_id | events | timeouts | timeout_pct
-- ----------+--------+----------+-------------
--         2 |     16 |        3 |        18.8
--         4 |      6 |        1 |        16.7
--         3 |     13 |        2 |        15.4
--         1 |     11 |        1 |         9.1
--         9 |     14 |        1 |         7.1
--        11 |     16 |        1 |         6.3
--        12 |     17 |        1 |         5.9
--         7 |     18 |        1 |         5.6
--         6 |     21 |        1 |         4.8
--        10 |     19 |        0 |         0.0
--         5 |     18 |        0 |         0.0
--        13 |     11 |        0 |         0.0
--         8 |     20 |        0 |         0.0
-- (13 rows)

--
-- Part B: Subtotals per server region plus a grand total (ROLLUP)
--

SELECT CASE WHEN GROUPING(m.server_region) = 1 THEN 'ALL' ELSE m.server_region END AS server_region,
       COUNT(*) AS events,
       SUM(CASE WHEN mp.disconnect_reason = 'Network timeout' THEN 1 ELSE 0 END) AS timeouts,
       ROUND(100.0 * SUM(CASE WHEN mp.disconnect_reason = 'Network timeout' THEN 1 ELSE 0 END) / COUNT(*), 1) AS timeout_pct
FROM match_participants mp
JOIN matches m ON m.match_id = mp.match_id
GROUP BY ROLLUP(m.server_region)
ORDER BY GROUPING(m.server_region), m.server_region;

-- Result: The last row (ALL) is the grand total: 12 timeouts in 200 events (6.0%). The other rows are per-region subtotals; EU (10.0%) and APAC (9.4%) are above the overall rate,
--         but NA has no timeouts.

-- Output:
--  server_region | events | timeouts | timeout_pct
-- ---------------+--------+----------+-------------
--  APAC          |     53 |        5 |         9.4
--  EU            |     20 |        2 |        10.0
--  NA            |     19 |        0 |         0.0
--  OCE           |     59 |        3 |         5.1
--  SA            |     49 |        2 |         4.1
--  ALL           |    200 |       12 |         6.0
-- (6 rows)

--
-- Part C: Each match compared with the high-volume baseline (CTE pipeline)
--

WITH per_match AS (
    SELECT match_id,
           COUNT(*) AS events,
           SUM(CASE WHEN disconnect_reason = 'Network timeout' THEN 1 ELSE 0 END) AS timeouts
    FROM match_participants
    GROUP BY match_id
),
baseline AS (
    SELECT ROUND(100.0 * SUM(timeouts) / SUM(events), 1) AS baseline_pct
    FROM per_match
    WHERE events >= 15
)
SELECT p.match_id, p.events, p.timeouts,
       ROUND(100.0 * p.timeouts / p.events, 1) AS timeout_pct,
       b.baseline_pct
FROM per_match p
CROSS JOIN baseline b
ORDER BY timeout_pct DESC;

-- Result: The baseline for high-volume matches (>= 15 events) is 4.8%. Match 2 is about four times above it (18.8%); match 3 is also clearly above,
--         while match 4 is high only because one timeout in 6 events is already 16.7%.

-- Output:
--  match_id | events | timeouts | timeout_pct | baseline_pct
-- ----------+--------+----------+-------------+--------------
--         2 |     16 |        3 |        18.8 |          4.8
--         4 |      6 |        1 |        16.7 |          4.8
--         3 |     13 |        2 |        15.4 |          4.8
--         1 |     11 |        1 |         9.1 |          4.8
--         9 |     14 |        1 |         7.1 |          4.8
--        11 |     16 |        1 |         6.3 |          4.8
--        12 |     17 |        1 |         5.9 |          4.8
--         7 |     18 |        1 |         5.6 |          4.8
--         6 |     21 |        1 |         4.8 |          4.8
--        10 |     19 |        0 |         0.0 |          4.8
--         5 |     18 |        0 |         0.0 |          4.8
--        13 |     11 |        0 |         0.0 |          4.8
--         8 |     20 |        0 |         0.0 |          4.8
-- (13 rows)
