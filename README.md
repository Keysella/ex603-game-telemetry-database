# EX603 Game Telemetry Database

This is a Boston University EX 603 project, maintained by `Aleksei [Keysella] Glebov`.

A relational database design for storing and analyzing player participation and performance across game matches.

**Theme:** Game Telemetry

## Domain

This project models a telemetry platform for a multiplayer game. The platform records players, matches, player participation in those matches, game modes, and numerical performance data. The design is inspired by match-based games such as Teamfight Tactics, although the schema is intentionally general enough to represent similar multiplayer games.

The database should support questions such as which players participated in a particular match, what score a player achieved, which game mode was associated with a match, and how player scores compare across multiple matches. It should also preserve relationships between historical matches, players, and game modes while preventing invalid references or duplicate participation records.

The relational design separates players, matches, participation events, game-mode categories, and match-mode associations so that each fact is stored in one appropriate location.

## Schema

The full DDL is in [schema/schema.sql](schema/schema.sql) (PostgreSQL 14+).
Run it in PostgreSQL Shell:
```
\i schema/schema.sql
```
It runs without errors twice in a row (see [screenshots](<screenshots/Project Assignment 2/>)).

| Table | What it stores |
|---|---|
| players | one row per player; `referred_by` points to the player who invited them |
| game_modes | list of modes (Ranked, Double Up…), names are unique |
| matches | one row per match; active flag and duration |
| match_participants | which player played in which match, when they joined, their score |
| match_modes | which modes a match was played in |

**Design decisions worth noting**
- Junction tables use composite primary keys (player_id, match_id) and (match_id, mode_id) instead of a new id.
- Deleting a match cascades to its participants and modes; deleting a player or a mode that is in use is blocked (RESTRICT).
- `referred_by` is a self-referencing FK; if the referrer is deleted it becomes NULL.
- CHECK constraints: no self-referral, no negative duration, a finished match must have a duration, an active one must not.

Full reasoning: [analysis/unit2.md](analysis/unit2.md).

## Query catalogue

All queries run against the `ex603_data` database loaded from [queries/gaming.sql](queries/gaming.sql).

### Unit 3

| File | Business question |
|---|---|
| [queries/unit3/q3_1.sql](queries/unit3/q3_1.sql) | What does the data actually contain: statuses, ranges, patterns and missing values? |
| [queries/unit3/q3_2.sql](queries/unit3/q3_2.sql) | Why does the dashboard report the wrong failure rate, and how is it fixed? |
| [queries/unit3/q3_3.sql](queries/unit3/q3_3.sql) | Which players had at least one network timeout? |

Finding: [analysis/unit3-finding.md](analysis/unit3-finding.md).

### Unit 4

| Query | File | Business question |
|---|---|---|
| 4.1-1 | [q4_1.sql](queries/unit4/q4_1.sql) | What are the overall platform numbers: events, score statistics and distinct players? |
| 4.1-2 | [q4_1.sql](queries/unit4/q4_1.sql) | How many events and what average score does each match have? |
| 4.1-3 | [q4_1.sql](queries/unit4/q4_1.sql) | Which matches have enough events (15 or more) for their numbers to be meaningful? |
| 4.1-4 | [q4_1.sql](queries/unit4/q4_1.sql) | How do events and average score differ by server region and ranked status? |
| 4.2-A | [q4_2.sql](queries/unit4/q4_2.sql) | How many events and how many network timeouts does each match have? |
| 4.2-B | [q4_2.sql](queries/unit4/q4_2.sql) | What is the timeout rate per region, and for the platform as a whole? |
| 4.2-C | [q4_2.sql](queries/unit4/q4_2.sql) | What is the normal timeout rate for high-volume matches, and which matches are above it? |

Analysis: [analysis/unit4.md](analysis/unit4.md). Finding: [analysis/unit4-finding.md](analysis/unit4-finding.md).

## Entity Relationship Diagram

![Game Telemetry ERD](schema/erd.png)
