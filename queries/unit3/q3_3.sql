-- ============================================================
-- EX 603 Assignment 3 - q3_3.sql
-- Task 3.3: Hand the team a corrected query
-- Database: ex603_data (gaming.sql reference dataset)
-- Author: Aleksei Glebov
-- ============================================================
--
-- The two-step question:
--   Which players were involved in the disputed events, i.e. had at least
--   one participation that ended in a network timeout?
--   Step 1: find the participations with disconnect_reason = 'Network timeout'.
--   Step 2: return each of those players once (player_id, player_name).
--
-- ============================================================

--
-- 3.3-1 Form 1: subquery with IN.
--

SELECT player_id, player_name
FROM players
WHERE player_id IN (
    SELECT player_id FROM match_participants
    WHERE disconnect_reason = 'Network timeout'
)
ORDER BY player_id;

-- Result: 10 players.

-- Output:
--  player_id | player_name
-- -----------+-------------
--          1 | Player_01
--          4 | Player_04
--          6 | Player_06
--          7 | Player_07
--         15 | Player_15
--         17 | Player_17
--         19 | Player_19
--         21 | Player_21
--         27 | Player_27
--         29 | Player_29
-- (10 rows)

--
-- 3.3-2 Form 2: Common Table Expression (WITH).
--

WITH timeouts AS (
    SELECT player_id FROM match_participants
    WHERE disconnect_reason = 'Network timeout'
)
SELECT player_id, player_name
FROM players
WHERE player_id IN (SELECT player_id FROM timeouts)
ORDER BY player_id;

-- Result: 10 players.

-- Output:
--  player_id | player_name
-- -----------+-------------
--          1 | Player_01
--          4 | Player_04
--          6 | Player_06
--          7 | Player_07
--         15 | Player_15
--         17 | Player_17
--         19 | Player_19
--         21 | Player_21
--         27 | Player_27
--         29 | Player_29
-- (10 rows)

--
-- 3.3-3 Form 3: a different construction - correlated subquery with EXISTS.
--

SELECT p.player_id, p.player_name
FROM players p
WHERE EXISTS (
    SELECT 1 FROM match_participants mp
    WHERE mp.player_id = p.player_id
      AND mp.disconnect_reason = 'Network timeout'
)
ORDER BY p.player_id;

-- Result: 10 players.

-- Output:
--  player_id | player_name
-- -----------+-------------
--          1 | Player_01
--          4 | Player_04
--          6 | Player_06
--          7 | Player_07
--         15 | Player_15
--         17 | Player_17
--         19 | Player_19
--         21 | Player_21
--         27 | Player_27
--         29 | Player_29
-- (10 rows)

--
-- 3.3-4 Proof that the three forms return the same rows.
--       A EXCEPT B returns rows that are in A but not in B.
--       If A EXCEPT B and B EXCEPT A are both empty, A and B hold exactly
--       the same rows - a stronger check than equal row counts.
--

(SELECT player_id, player_name FROM players
 WHERE player_id IN (SELECT player_id FROM match_participants
                     WHERE disconnect_reason = 'Network timeout'))
EXCEPT
(SELECT p.player_id, p.player_name FROM players p
 WHERE EXISTS (SELECT 1 FROM match_participants mp
               WHERE mp.player_id = p.player_id
                 AND mp.disconnect_reason = 'Network timeout'));

-- Output:
--  player_id | player_name
-- -----------+-------------
-- (0 rows)

(SELECT p.player_id, p.player_name FROM players p
 WHERE EXISTS (SELECT 1 FROM match_participants mp
               WHERE mp.player_id = p.player_id
                 AND mp.disconnect_reason = 'Network timeout'))
EXCEPT
(SELECT player_id, player_name FROM players
 WHERE player_id IN (SELECT player_id FROM match_participants
                     WHERE disconnect_reason = 'Network timeout'));

-- Output:
--  player_id | player_name
-- -----------+-------------
-- (0 rows)

WITH timeouts AS (
    SELECT player_id FROM match_participants
    WHERE disconnect_reason = 'Network timeout'
)
(SELECT player_id, player_name FROM players
 WHERE player_id IN (SELECT player_id FROM timeouts))
EXCEPT
(SELECT player_id, player_name FROM players
 WHERE player_id IN (SELECT player_id FROM match_participants
                     WHERE disconnect_reason = 'Network timeout'));

-- Output:
--  player_id | player_name
-- -----------+-------------
-- (0 rows)

WITH timeouts AS (
    SELECT player_id FROM match_participants
    WHERE disconnect_reason = 'Network timeout'
)
(SELECT player_id, player_name FROM players
 WHERE player_id IN (SELECT player_id FROM match_participants
                     WHERE disconnect_reason = 'Network timeout'))
EXCEPT
(SELECT player_id, player_name FROM players
 WHERE player_id IN (SELECT player_id FROM timeouts));

-- Output:
--  player_id | player_name
-- -----------+-------------
-- (0 rows)

-- Result: every EXCEPT returns 0 rows in both directions, so, all the three forms return the exact same 10 players.

--
-- 3.3-5 When the forms would NOT be equivalent.
--

SELECT p.player_id, p.player_name
FROM players p
JOIN match_participants mp ON mp.player_id = p.player_id
WHERE mp.disconnect_reason = 'Network timeout';

-- Result: 12 rows instead of 10. Players 1 and 21 had two timeouts each, so, JOIN returns them twice.
--         IN and EXISTS only asked "is there at least one entry?", so, they return each player once.
--         With duplicate events, JOIN without DISTINCT is not equivalent.

-- Condition: if the question is negated (NOT IN vs NOT EXISTS) and the
--            inner list contains a NULL, NOT IN returns no rows while NOT EXISTS
--            still returns the correct rows, so forms 1-2 and form 3 diverge.

-- Output:
--  player_id | player_name
-- -----------+-------------
--          1 | Player_01
--         19 | Player_19
--         29 | Player_29
--          1 | Player_01
--         21 | Player_21
--          6 | Player_06
--          7 | Player_07
--         27 | Player_27
--         17 | Player_17
--          4 | Player_04
--         21 | Player_21
--         15 | Player_15
-- (12 rows)
