-- ============================================================
-- EX 603 Assignment 3 - q3_1.sql
-- Task 3.1: Establish what the data contains
-- Database: ex603_data (gaming.sql reference dataset)
-- Author: Aleksei Glebov
-- ============================================================
--
-- Tables in this dataset:
--   players            (actor)    player_id, player_name, region, recruited_by, is_active
--   matches            (producer) match_id, match_label, player_count, is_ranked, server_region
--   match_participants (event)    participation_id, player_id, match_id, joined_at, left_at,
--                                 score, duration_min, participation_status, disconnect_reason
--   game_modes         (catalog)  mode_id, mode_name, mode_description
--   match_modes        (junction) match_id, mode_id, enabled_on
--
-- Booleans: write is_ranked = TRUE, not = 1.
--
-- ============================================================

--
-- 3.1a Ranked, well-populated matches - the producers whose records
--      anchor the audit. Requirement: SELECT, WHERE, ORDER BY, LIMIT.
--

SELECT * FROM matches
WHERE is_ranked = TRUE AND player_count >= 8
ORDER BY player_count DESC
LIMIT 10;

-- Result: 9 ranked matches with 8+ players.
-- Output:
--  match_id | match_label | scheduled_on | server_region | match_code | player_count | is_ranked
-- ----------+-------------+--------------+---------------+------------+--------------+-----------
--         1 | Match_01    | 2022-07-15   | SA            | UQ-1001    |           16 | t
--         2 | Match_02    | 2022-01-20   | APAC          | UQ-1002    |           16 | t
--         4 | Match_04    | 2022-07-25   | EU            | UQ-1004    |           16 | t
--         5 | Match_05    | 2022-04-18   | OCE           | UQ-1005    |           16 | t
--         8 | Match_08    | 2022-04-17   | SA            | UQ-1008    |           14 | t
--        10 | Match_10    | 2022-05-02   | NA            | UQ-1010    |           14 | t
--        11 | Match_11    | 2022-05-08   | APAC          | UQ-1011    |           10 | t
--        13 | Match_13    | 2022-10-17   | OCE           | UQ-1013    |            8 | t
--        14 | Match_14    | 2022-08-24   | NA            | UQ-1014    |            8 | t
-- (9 rows)

--
-- 3.1b Which participation statuses exist at all?
--      Requirement: DISTINCT.
--

SELECT DISTINCT participation_status FROM match_participants;

-- Result: 3 pariticpation statuses: finished, abandoned, contested. "contested" status was not expected, because the dashboard only knows success/failure.
-- Output:
--  participation_status
-- ----------------------
--  contested
--  finished
--  abandoned
-- (3 rows)

--
-- 3.1c-1 Events in a numeric range.
--        Requirement: WHERE with a range (BETWEEN or >= / <=).
--

SELECT * FROM match_participants
WHERE score BETWEEN 10 AND 30;

-- Result: 103 of 200 participations scored between 10 and 30.
-- Output (truncated):
--  participation_id | player_id | match_id |      joined_at      |       left_at       | client_region | score | duration_min | xp_multiplier | participation_status | disconnect_reason
-- ------------------+-----------+----------+---------------------+---------------------+---------------+-------+--------------+---------------+----------------------+-------------------
--                 1 |        14 |        1 | 2023-06-06 21:55:00 | 2023-06-06 22:15:00 | OCE           | 19.74 |        20.88 |          1.00 | finished             |
--                 3 |        20 |        1 | 2023-08-19 19:03:00 | 2023-08-19 19:44:00 | EU            | 22.43 |        12.89 |          1.25 | finished             |
--                 6 |        25 |        1 | 2023-02-08 00:47:00 | 2023-02-08 01:19:00 | OCE           | 21.89 |        18.60 |          1.25 | finished             |
--                 7 |         4 |        1 | 2023-02-23 10:07:00 | 2023-02-23 11:02:00 | OCE           | 26.17 |        19.29 |          1.00 | finished             |
--                 9 |        15 |        1 | 2023-03-26 10:22:00 | 2023-03-26 11:02:00 | SA            | 20.06 |        19.69 |          1.00 | finished             |
--                ...
-- (103 rows)

--
-- 3.1c-2 Events matching an explicit list of values.
--        Requirement: WHERE ... IN (...).
--

SELECT * FROM match_participants
WHERE participation_status IN ('abandoned', 'contested');

-- Result: 44 participations are abandoned or contested (34 + 10).
-- Output (truncated):
--  participation_id | player_id | match_id |      joined_at      |       left_at       | client_region | score | duration_min | xp_multiplier | participation_status | disconnect_reason
-- ------------------+-----------+----------+---------------------+---------------------+---------------+-------+--------------+---------------+----------------------+-------------------
--                 4 |         1 |        1 | 2023-01-01 15:48:00 |                     | SA            |  0.00 |        10.65 |          1.25 | abandoned            | Network timeout
--                 5 |        25 |        1 | 2023-06-27 21:17:00 | 2023-06-27 21:43:00 | NA            |  7.07 |         3.93 |          1.25 | contested            |
--                 8 |         4 |        1 | 2023-01-16 21:46:00 |                     | SA            |  0.00 |         2.55 |          1.25 | abandoned            | Player quit
--                11 |         5 |        1 | 2023-11-14 09:05:00 | 2023-11-14 09:54:00 | EU            | 22.46 |        15.89 |          1.00 | contested            |
--                12 |        19 |        2 | 2023-01-20 08:07:00 |                     | SA            |  0.00 |         5.54 |          1.00 | abandoned            | Network timeout
--                ...
-- (44 rows)

--
-- 3.1d-1 Producers whose name matches a text pattern.
--        Requirement: LIKE.
--

SELECT * FROM matches
WHERE match_label LIKE 'Match_1%';

-- Result: 6 matches match 'Match_1%' (Match_10 to Match_15).
-- Output:
--  match_id | match_label | scheduled_on | server_region | match_code | player_count | is_ranked
-- ----------+-------------+--------------+---------------+------------+--------------+-----------
--        10 | Match_10    | 2022-05-02   | NA            | UQ-1010    |           14 | t
--        11 | Match_11    | 2022-05-08   | APAC          | UQ-1011    |           10 | t
--        12 | Match_12    | 2022-01-17   | OCE           | UQ-1012    |            5 | t
--        13 | Match_13    | 2022-10-17   | OCE           | UQ-1013    |            8 | t
--        14 | Match_14    | 2022-08-24   | NA            | UQ-1014    |            8 | t
--        15 | Match_15    | 2022-02-21   | SA            | UQ-1015    |            6 | t
-- (6 rows)

--
-- 3.1d-2 Events with a missing reason, shown with a readable label.
--        Requirement: IS NULL, COALESCE.
--

SELECT * FROM match_participants
WHERE disconnect_reason IS NULL;

SELECT participation_id, participation_status, COALESCE(disconnect_reason, 'No reason provided') AS disconnect_reason
FROM match_participants;

-- Result: 166 of 200 rows have no disconnect_reason (NULL). Only abandoned rows carry a reason; COALESCE labels the rest.
-- Output (truncated):
--  participation_id | player_id | match_id |      joined_at      |       left_at       | client_region | score | duration_min | xp_multiplier | participation_status | disconnect_reason
-- ------------------+-----------+----------+---------------------+---------------------+---------------+-------+--------------+---------------+----------------------+-------------------
--                 1 |        14 |        1 | 2023-06-06 21:55:00 | 2023-06-06 22:15:00 | OCE           | 19.74 |        20.88 |          1.00 | finished             |
--                 2 |        28 |        1 | 2023-06-09 08:54:00 | 2023-06-09 09:37:00 | APAC          |  7.40 |         3.12 |          1.25 | finished             |
--                 3 |        20 |        1 | 2023-08-19 19:03:00 | 2023-08-19 19:44:00 | EU            | 22.43 |        12.89 |          1.25 | finished             |
--                 5 |        25 |        1 | 2023-06-27 21:17:00 | 2023-06-27 21:43:00 | NA            |  7.07 |         3.93 |          1.25 | contested            |
--                 6 |        25 |        1 | 2023-02-08 00:47:00 | 2023-02-08 01:19:00 | OCE           | 21.89 |        18.60 |          1.25 | finished             |
--                 ...

--
-- 3.1e Results a non-SQL reader can understand.
--      Requirement: computed columns, CASE.
--

SELECT 
    participation_id,
    score,
    duration_min,
    CASE 
        WHEN duration_min < 10 THEN 'Short'
        WHEN duration_min < 20 THEN 'Medium'
        ELSE 'Long'
    END AS session_length_category,
    CASE 
        WHEN score < 20 THEN 'Low'
        WHEN score < 40 THEN 'Medium'
        ELSE 'High'
    END AS score_category
FROM match_participants;

-- Result: 200 rows labeled; scores: 111 Low, 76 Medium, 13 High.
-- Output (truncated):
--  participation_id | score | duration_min | session_length_category | score_category
-- ------------------+-------+--------------+-------------------------+----------------
--                 1 | 19.74 |        20.88 | Long                    | Low
--                 2 |  7.40 |         3.12 | Short                   | Low
--                 3 | 22.43 |        12.89 | Medium                  | Medium
--                 4 |  0.00 |        10.65 | Medium                  | Low
--                 5 |  7.07 |         3.93 | Short                   | Low
--                 ...
-- (200 rows)
