-- ============================================================
-- EX 603 Assignment 5 - q5_2.sql
-- Task 5.2: Find records that joins may exclude
-- Database: ex603_data (gaming.sql reference dataset)
-- Author: Aleksei Glebov
-- ============================================================
--
-- Producer = matches, event = match_participants.
-- Events are counted with COUNT(mp.participation_id), not COUNT(*):
-- for a match with no events the LEFT JOIN row has NULLs, and COUNT(*) would count it as 1.
--
-- ============================================================

--
-- ============================================================
-- Part A
-- ============================================================
--

--
-- 5.2A-1 LEFT JOIN: every match with its number of events, including matches with none.
--

SELECT m.match_id, m.match_label, COUNT(mp.participation_id) AS events
FROM matches m
LEFT JOIN match_participants mp ON mp.match_id = m.match_id
GROUP BY m.match_id, m.match_label
ORDER BY m.match_id;

-- Result: 15 matches; matches 14 and 15 appear with 0 events.

-- Output:
--  match_id | match_label | events
-- ----------+-------------+--------
--         1 | Match_01    |     11
--         2 | Match_02    |     16
--         3 | Match_03    |     13
--         4 | Match_04    |      6
--         5 | Match_05    |     18
--         6 | Match_06    |     21
--         7 | Match_07    |     18
--         8 | Match_08    |     20
--         9 | Match_09    |     14
--        10 | Match_10    |     19
--        11 | Match_11    |     16
--        12 | Match_12    |     17
--        13 | Match_13    |     11
--        14 | Match_14    |      0
--        15 | Match_15    |      0
-- (15 rows)

--
-- 5.2A-2 INNER JOIN: the same query, but only matches that have events.
--

SELECT m.match_id, m.match_label, COUNT(mp.participation_id) AS events
FROM matches m
INNER JOIN match_participants mp ON mp.match_id = m.match_id
GROUP BY m.match_id, m.match_label
ORDER BY m.match_id;

-- Result: 13 matches; matches 14 and 15 disappear because they have no matching events.

-- Output:
--  match_id | match_label | events
-- ----------+-------------+--------
--         1 | Match_01    |     11
--         2 | Match_02    |     16
--         3 | Match_03    |     13
--         4 | Match_04    |      6
--         5 | Match_05    |     18
--         6 | Match_06    |     21
--         7 | Match_07    |     18
--         8 | Match_08    |     20
--         9 | Match_09    |     14
--        10 | Match_10    |     19
--        11 | Match_11    |     16
--        12 | Match_12    |     17
--        13 | Match_13    |     11
-- (13 rows)

--
-- 5.2A-3 How many matches does the INNER JOIN exclude? (distinct match_id)
--

SELECT
    (SELECT COUNT(DISTINCT m.match_id) FROM matches m LEFT JOIN match_participants mp ON mp.match_id = m.match_id) AS left_join_matches,
    (SELECT COUNT(DISTINCT m.match_id) FROM matches m INNER JOIN match_participants mp ON mp.match_id = m.match_id) AS inner_join_matches,
    (SELECT COUNT(DISTINCT m.match_id) FROM matches m LEFT JOIN match_participants mp ON mp.match_id = m.match_id)
  - (SELECT COUNT(DISTINCT m.match_id) FROM matches m INNER JOIN match_participants mp ON mp.match_id = m.match_id) AS excluded_by_inner_join;

-- Result: The inner join excludes 2 matches (15 - 13).

-- Output:
--  left_join_matches | inner_join_matches | excluded_by_inner_join
-- -------------------+--------------------+------------------------
--                 15 |                 13 |                      2
-- (1 row)

--
-- ============================================================
-- Part B
-- ============================================================
--

--
-- 5.2B-1 RIGHT JOIN: the same records as the LEFT JOIN, with the tables swapped.
--

SELECT m.match_id, m.match_label, COUNT(mp.participation_id) AS events
FROM match_participants mp
RIGHT JOIN matches m ON mp.match_id = m.match_id
GROUP BY m.match_id, m.match_label
ORDER BY m.match_id;

-- Result: Same 15 rows as the LEFT JOIN in 5.2A-1.

-- Output:
--  match_id | match_label | events
-- ----------+-------------+--------
--         1 | Match_01    |     11
--         2 | Match_02    |     16
--         3 | Match_03    |     13
--         4 | Match_04    |      6
--         5 | Match_05    |     18
--         6 | Match_06    |     21
--         7 | Match_07    |     18
--         8 | Match_08    |     20
--         9 | Match_09    |     14
--        10 | Match_10    |     19
--        11 | Match_11    |     16
--        12 | Match_12    |     17
--        13 | Match_13    |     11
--        14 | Match_14    |      0
--        15 | Match_15    |      0
-- (15 rows)

--
-- 5.2B-2 Verification: do the LEFT JOIN and RIGHT JOIN results differ? (EXCEPT both ways)
--

SELECT COUNT(*) AS rows_that_differ
FROM (
    (SELECT m.match_id, COUNT(mp.participation_id) AS events
     FROM matches m LEFT JOIN match_participants mp ON mp.match_id = m.match_id
     GROUP BY m.match_id
     EXCEPT
     SELECT m.match_id, COUNT(mp.participation_id)
     FROM match_participants mp RIGHT JOIN matches m ON mp.match_id = m.match_id
     GROUP BY m.match_id)
    UNION ALL
    (SELECT m.match_id, COUNT(mp.participation_id)
     FROM match_participants mp RIGHT JOIN matches m ON mp.match_id = m.match_id
     GROUP BY m.match_id
     EXCEPT
     SELECT m.match_id, COUNT(mp.participation_id)
     FROM matches m LEFT JOIN match_participants mp ON mp.match_id = m.match_id
     GROUP BY m.match_id)
) AS diff;

-- Result: 0 rows differ in both directions, so, the LEFT JOIN and the RIGHT JOIN return exactly the same records.

-- Output:
--  rows_that_differ
-- ------------------
--                 0
-- (1 row)

--
-- 5.2B-3 FULL OUTER JOIN: matched and unmatched rows from both tables.
--

SELECT CASE
         WHEN mp.match_id IS NULL THEN 'match with no events'
         WHEN m.match_id IS NULL THEN 'event with no match'
         ELSE 'matched'
       END AS join_status,
       COUNT(*) AS result_rows,
       COUNT(DISTINCT COALESCE(m.match_id, mp.match_id)) AS distinct_matches
FROM matches m
FULL OUTER JOIN match_participants mp ON mp.match_id = m.match_id
GROUP BY 1
ORDER BY 1;

-- Result: 200 matched rows from 13 matches and 2 matches with no events; there are no events without a match, because the foreign key on match_participants.match_id prevents them.

-- Output:
--      join_status      | result_rows | distinct_matches
-- ----------------------+-------------+------------------
--  match with no events |           2 |                2
--  matched              |         200 |               13
-- (2 rows)

--
-- ============================================================
-- Part C
-- ============================================================
--

--
-- 5.2C-1 Matches with no events: NOT EXISTS.
--

SELECT m.match_id, m.match_label
FROM matches m
WHERE NOT EXISTS (SELECT 1 FROM match_participants mp WHERE mp.match_id = m.match_id)
ORDER BY m.match_id;

-- Result: Matches 14 and 15 have no events.

-- Output:
--  match_id | match_label
-- ----------+-------------
--        14 | Match_14
--        15 | Match_15
-- (2 rows)

--
-- 5.2C-2 Matches with no events: EXCEPT.
--

SELECT match_id FROM matches
EXCEPT
SELECT match_id FROM match_participants
ORDER BY match_id;

-- Result: Same two matches (14 and 15). NOT EXISTS checks each match for at least one event, while EXCEPT subtracts the set of match IDs with events from the set of all match IDs.

-- Output:
--  match_id
-- ----------
--        14
--        15
-- (2 rows)
