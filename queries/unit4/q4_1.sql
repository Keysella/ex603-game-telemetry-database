-- ============================================================
-- EX 603 Assignment 4 - q4_1.sql
-- Task 4.1: Measure the platform
-- Database: ex603_data (gaming.sql reference dataset)
-- Author: Aleksei Glebov
-- ============================================================
--
-- Roles in this dataset:
--   event    = match_participants (one player playing one match)
--   producer = matches            (identified by match_id)
--   actor    = players
--   metric   = match_participants.score
--   failure  = disconnect_reason = 'Network timeout'
--
-- ============================================================

--
-- 4.1-1 Platform baseline: how big is the event table and what does
--       the score look like overall?
--       Requirement: COUNT, SUM, AVG, MIN, MAX, COUNT(DISTINCT).
--

SELECT COUNT(*)                  AS events,
       SUM(score)                AS total_score,
       ROUND(AVG(score), 2)      AS avg_score,
       MIN(score)                AS min_score,
       MAX(score)                AS max_score,
       COUNT(DISTINCT player_id) AS distinct_players
FROM match_participants;

-- Result: 200 events from 30 distinct players; average score 18.14, range 0.00-70.86 (the 0.00 minimum comes from abandoned rows, which all have score 0).

-- Output:
--  events | total_score | avg_score | min_score | max_score | distinct_players
-- --------+-------------+-----------+-----------+-----------+------------------
--     200 |     3628.19 |     18.14 |      0.00 |     70.86 |               30
-- (1 row)

--
-- 4.1-2 How active is each match and how well do its players score?
--       Requirement: GROUP BY producer, ORDER BY event count DESC.
--

SELECT match_id,
       COUNT(*)             AS events,
       ROUND(AVG(score), 2) AS avg_score
FROM match_participants
GROUP BY match_id
ORDER BY events DESC;

-- Result: 13 matches have events; volume ranges from 21 (match 6) down to 6 (match 4), so the per-match averages are not equally reliable.

-- Output:
--  match_id | events | avg_score
-- ----------+--------+-----------
--         6 |     21 |     17.84
--         8 |     20 |     22.63
--        10 |     19 |     20.97
--         5 |     18 |     23.06
--         7 |     18 |     18.33
--        12 |     17 |     18.27
--         2 |     16 |     17.02
--        11 |     16 |     11.94
--         9 |     14 |     14.17
--         3 |     13 |     13.36
--        13 |     11 |     19.86
--         1 |     11 |     16.03
--         4 |      6 |     19.49
-- (13 rows)

--
-- 4.1-3 Which matches have enough events for their numbers to mean anything?
--       Requirement: HAVING with a minimum event-count threshold.
--

SELECT match_id,
       COUNT(*)             AS events,
       ROUND(AVG(score), 2) AS avg_score
FROM match_participants
GROUP BY match_id
HAVING COUNT(*) >= 15
ORDER BY events DESC;

-- Result: 8 of 13 matches have at least 15 events. The threshold 15 is close to the average volume per match (200 / 13 = 15.4),
--         so it keeps matches whose average rests on enough rows and drops small ones like match 4 (6 events).

-- Output:
--  match_id | events | avg_score
-- ----------+--------+-----------
--         6 |     21 |     17.84
--         8 |     20 |     22.63
--        10 |     19 |     20.97
--         7 |     18 |     18.33
--         5 |     18 |     23.06
--        12 |     17 |     18.27
--        11 |     16 |     11.94
--         2 |     16 |     17.02
-- (8 rows)

--
-- 4.1-4 How do results differ by server region and ranked / unranked?
--       Requirement: GROUP BY two dimensions, including region.
--

SELECT m.server_region,
       m.is_ranked,
       COUNT(*)             AS events,
       ROUND(AVG(mp.score), 2) AS avg_score
FROM match_participants mp
JOIN matches m ON m.match_id = mp.match_id
GROUP BY m.server_region, m.is_ranked
ORDER BY m.server_region, m.is_ranked;

-- Result: 7 region x ranked groups; APAC ranked has the most events (53), and the two unranked groups (EU, OCE) have the lowest average scores (14.17 and 13.36).

-- Output:
--  server_region | is_ranked | events | avg_score
-- ---------------+-----------+--------+-----------
--  APAC          | t         |     53 |     15.81
--  EU            | f         |     14 |     14.17
--  EU            | t         |      6 |     19.49
--  NA            | t         |     19 |     20.97
--  OCE           | f         |     13 |     13.36
--  OCE           | t         |     46 |     20.52
--  SA            | t         |     49 |     19.57
-- (7 rows)
