-- ============================================================
-- EX 603 Assignment 5 - q5_3.sql
-- Task 5.3: Understand join performance and execution plans
-- Database: ex603_data (gaming.sql reference dataset)
-- Author: Aleksei Glebov
-- ============================================================

--
-- ============================================================
-- Part A
-- ============================================================
--

--
-- 5.3A-1 CROSS JOIN: every match paired with every game mode.
--

SELECT (SELECT COUNT(*) FROM matches) AS matches_rows,
       (SELECT COUNT(*) FROM game_modes) AS game_modes_rows,
       (SELECT COUNT(*) FROM matches CROSS JOIN game_modes) AS cross_join_rows;

-- Result: matches has 15 rows and game_modes has 5 rows; the CROSS JOIN returns 75 rows, which is exactly 15 * 5, because every match is paired with every game mode.

-- Output:
--  matches_rows | game_modes_rows | cross_join_rows
-- --------------+-----------------+-----------------
--            15 |               5 |              75
-- (1 row)

--
-- ============================================================
-- Part B
-- ============================================================
--

--
-- 5.3B-1 EXPLAIN ANALYZE on the three-table join from 5.1-1.
--

EXPLAIN ANALYZE
SELECT p.player_id, p.player_name, m.match_id, m.match_label, mp.joined_at
FROM match_participants mp
JOIN players p ON p.player_id = mp.player_id
JOIN matches m ON m.match_id = mp.match_id
WHERE m.match_id IN (2, 3, 4)
ORDER BY m.match_id, mp.joined_at;

-- Result: PostgreSQL chose two Nested Loop joins (no Hash Join or Merge Join). match_participants is read with a Seq Scan (all 200 rows, no index on match_id);
--         for each row the match is found through the matches_pkey index (Memoize caches it: 13 lookups, 187 cache hits),
--         and then each of the 35 matching rows looks up its player through the players_pkey index.
--         Execution time: 0.233 ms.

-- Output:
--                                                                       QUERY PLAN
-- ------------------------------------------------------------------------------------------------------------------------------------------------------
--  Sort  (cost=17.67..17.68 rows=5 width=532) (actual time=0.193..0.195 rows=35.00 loops=1)
--    Sort Key: m.match_id, mp.joined_at
--    Sort Method: quicksort  Memory: 26kB
--    Buffers: shared hit=79
--    ->  Nested Loop  (cost=0.30..17.61 rows=5 width=532) (actual time=0.068..0.171 rows=35.00 loops=1)
--          Buffers: shared hit=79
--          ->  Nested Loop  (cost=0.15..15.61 rows=5 width=274) (actual time=0.062..0.134 rows=35.00 loops=1)
--                Buffers: shared hit=9
--                ->  Seq Scan on match_participants mp  (cost=0.00..5.00 rows=200 width=16) (actual time=0.028..0.044 rows=200.00 loops=1)
--                      Buffers: shared hit=3
--                ->  Memoize  (cost=0.15..0.42 rows=1 width=262) (actual time=0.000..0.000 rows=0.17 loops=200)
--                      Cache Key: mp.match_id
--                      Cache Mode: logical
--                      Hits: 187  Misses: 13  Evictions: 0  Overflows: 0  Memory Usage: 1kB
--                      Buffers: shared hit=6
--                      ->  Index Scan using matches_pkey on matches m  (cost=0.14..0.41 rows=1 width=262) (actual time=0.002..0.002 rows=0.23 loops=13)
--                            Index Cond: ((match_id = mp.match_id) AND (match_id = ANY ('{2,3,4}'::integer[])))
--                            Index Searches: 3
--                            Buffers: shared hit=6
--          ->  Index Scan using players_pkey on players p  (cost=0.14..0.40 rows=1 width=262) (actual time=0.001..0.001 rows=1.00 loops=35)
--                Index Cond: (player_id = mp.player_id)
--                Index Searches: 35
--                Buffers: shared hit=70
--  Planning Time: 0.310 ms
--  Execution Time: 0.233 ms
-- (25 rows)
