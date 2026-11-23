-- ============================================================
-- EX 603 Assignment 5 - q5_1.sql
-- Task 5.1: Connect producers to their data
-- Database: ex603_data (gaming.sql reference dataset)
-- Author: Aleksei Glebov
-- ============================================================
--
-- Roles: actor = players, producer = matches, event = match_participants,
--        catalog = game_modes, junction = match_modes
-- Matches flagged in Assignment 4: 2, 3 (high timeout rate) and 4 (low volume).
--
-- ============================================================

--
-- 5.1-1 Three-table join: who played in the flagged matches, and when?
--

SELECT p.player_id, p.player_name, m.match_id, m.match_label, mp.joined_at
FROM match_participants mp
JOIN players p ON p.player_id = mp.player_id
JOIN matches m ON m.match_id = mp.match_id
WHERE m.match_id IN (2, 3, 4)
ORDER BY m.match_id, mp.joined_at;

-- Result: 35 events in the flagged matches (16 in match 2, 13 in match 3, 6 in match 4), now shown with player names and match labels instead of bare IDs.

-- Output (truncated):
--  player_id | player_name | match_id | match_label |      joined_at
-- -----------+-------------+----------+-------------+---------------------
--         19 | Player_19   |        2 | Match_02    | 2023-01-20 08:07:00
--         30 | Player_30   |        2 | Match_02    | 2023-01-20 11:49:00
--         16 | Player_16   |        2 | Match_02    | 2023-01-27 17:06:00
--         29 | Player_29   |        2 | Match_02    | 2023-03-10 18:52:00
--         22 | Player_22   |        2 | Match_02    | 2023-04-12 22:27:00
--         ...
-- (35 rows)

--
-- 5.1-2 Junction traversal: which game modes do the flagged matches use?
--

SELECT m.match_id, m.match_label, g.mode_name
FROM matches m
JOIN match_modes mm ON mm.match_id = m.match_id
JOIN game_modes g ON g.mode_id = mm.mode_id
WHERE m.match_id IN (2, 3, 4)
ORDER BY m.match_id, g.mode_name;

-- Result: No game mode is shared by all three flagged matches (Survival is in 2 and 3, Capture the Flag in 2 and 4, Deathmatch in 3 and 4),
--         so, game mode alone does not explain their timeout rates.

-- Output:
--  match_id | match_label |    mode_name
-- ----------+-------------+------------------
--         2 | Match_02    | Capture the Flag
--         2 | Match_02    | Ranked Duel
--         2 | Match_02    | Survival
--         3 | Match_03    | Deathmatch
--         3 | Match_03    | Survival
--         4 | Match_04    | Capture the Flag
--         4 | Match_04    | Deathmatch
--         4 | Match_04    | Time Trial
-- (8 rows)

--
-- 5.1-3 Self join: how do the flagged matches compare with other matches in the same region?
--

SELECT a.match_id, a.server_region, a.is_ranked, a.player_count,
       b.match_id AS other_match, b.is_ranked AS other_ranked, b.player_count AS other_player_count
FROM matches a
JOIN matches b ON b.server_region = a.server_region AND b.match_id <> a.match_id
WHERE a.match_id IN (2, 3, 4)
ORDER BY a.match_id, b.match_id;

-- Result: Matches 2, 3 and 4 all have 16 player slots, while most other matches in their regions are smaller (4-10 slots). Match 5 in OCE also has 16 slots but had no timeouts,
--         so, match size alone does not explain the problem; match 3 is the only unranked match in OCE.

-- Output:
--  match_id | server_region | is_ranked | player_count | other_match | other_ranked | other_player_count
-- ----------+---------------+-----------+--------------+-------------+--------------+--------------------
--         2 | APAC          | t         |           16 |           6 | t            |                  4
--         2 | APAC          | t         |           16 |          11 | t            |                 10
--         3 | OCE           | f         |           16 |           5 | t            |                 16
--         3 | OCE           | f         |           16 |          12 | t            |                  5
--         3 | OCE           | f         |           16 |          13 | t            |                  8
--         4 | EU            | t         |           16 |           9 | f            |                 15
-- (6 rows)
