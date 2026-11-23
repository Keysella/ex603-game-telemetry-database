# Unit 5 Analysis

## Task 5.1: Connect producers to their data

**What feature or report could use the three-table join from Question 1, and what would it display?**
- The aftermatch report could use it to show which players participated in which matches, when it was played, what was the outcome, and other statistics.
- Maybe a support instrument, for example, player performance analysis, match statistics, etc. For example, there are many different analysis websites for TFT (or even regular chess.com - another game that also performs such analysis).

**Why is the junction table important for Question 2, and what would be harder without it?**
- The main reason is because of many-to-many relationships between matches and game modes - one match can have multiple game modes, and one game mode can be played in multiple matches.
- Without match_modes we would need to store game modes right in matches table, which would be either a list or separate columns, making it harder to query and maintain data integrity. So, junction table makes it a regular JOIN, and every pair (match, game mode) is stored as one row.

## Task 5.2: Find records that joins may exclude

**Part B: What can a full outer join reveal that a left or right join alone may not show?**
- It can show unmatched records from both tables: both matches with no events (like LEFT JOIN) and events with no matches (which would be shown in RIGHT JOIN). We don't have events without matches in our dataset because of the foreign key, so the result was the same with LEFT JOIN. However, if data comes without such checks (like log import), FULL JOIN would catch both problems in one query.

**Part C: How do NOT EXISTS and EXCEPT differ, and do they find the same matches?**
- NOT EXISTS checks every match separately and can return any column, for example match_label. EXCEPT compares two sets of match_ids: all the matches - matches with events. Except works only with similar columns and deletes duplicates. Both found matches 14 and 15 for this assignment.

**Which producers were excluded by the inner join?**
- Matches 14 and 15 were excluded by the inner join.

**What does it mean when a producer has no events? What are possible explanations?**
- It means, in our case, that match was created, but no player was in it. We can see it in data: match 14 (NA, ranked, 8 slots) and match 15 (SA, ranked, 6 slots) were scheduled in 2022, but all the events we have are starting with year 2023.
- Additionally, matches 14 and 15 don't have any game mode in match_modes. Maybe, these matches were cancelled or nobody just joined them.

**How could a report based only on an inner join give leadership an incomplete picture?**
- INNER JOIN silently excludes matches with no events. For example, leadership will see only 13 out of 15 matches, and will not know that 2 matches have no recorded events.

**Why might leadership want to identify producers that have never been active?**
- They occupy space in the catalogue and in server resources, can potentially point to a settings error or telemetry error.

**What action could leadership take based on these findings?**
- Check matches 14 and 15: are they fully setup? Were they cancelled? Are there any logs in the system to confirm? If they are not active, they can be removed from the catalogue. If events were lost, telemetry needs a fix.

## Task 5.3: Understand join performance and execution plans

**When could a Cartesian product be useful on this platform, or why would it not be needed?**
- CROSS JOIN is useful to find all possible combinations of two tables, in our example - all matches * all game modes. Without it, we can't see empty combinations.

**Which join algorithms did PostgreSQL choose for the query?**
- Two Nested Loops.

**What information in the execution plan helps explain those choices?**
- Index Scan using matches_pkey and Index Scan using players_pkey: there are indices on primary keys to find pairs, making one query almost for free.
- Small numbers: 200 events, only 35 rows after filter.
- Memoize with Hits: 187 Misses: 13: there are 13 different matches, so most searches are taken from cache.
- Seq Scan on match_participants: there is no index on match_id, but the table has only 3 pages, so it is faster to read it.

**Why is it useful to understand the selected join algorithms?**
- To predict where query becomes slow and how to optimize it: add indices, rewrite the query, refresh statistics. It took me 0.233ms now, but with millions of events as stated before the same plan can become very slow.

**What changes to the data or database might make another join algorithm more appropriate?**
- If match_participants table grows larger and there are many rows in the result, Nested Loop becomes more expensive, and PostgreSQL might switch to Hash Join.
- If both sides are sorted by key (for example, there are indices both on match_participants.match_id and matches.match_id), there can be a Merge Join.
- An index on match_participants(match_id) would remove the Seq Scan.

## Reflection

Right now tables are relatively small, so Nested Loop with indices is the cheapest option. However, with millions of events every query will cost a lot more than that, so it may be better to create a hash table using Hash Join. Seq Scan works because there are no match_participants.match_id index, but if there was one, database would find rows faster. And if we remove indices from matches and players, Nested Loop would become slower.

Our filter leaves about 35 rows out of 200, and if this filter was less selective, Hash Join may be more efficient. Planner was waiting for 5 rows, but got 35 - if estimates are incorrect, it can choose wrong algorithm, and ANALYZE refreshes statistics to make better decisions.

For example, with an index on match_participants(match_id), PostgreSQL would not need to read all events to find the 35 rows for matches 2, 3 and 4. At 200 rows the difference is invisible, but with millions of events this one index could turn a full table scan into a few index lookups, and the query would stay fast as the platform grows.