# EX603 Game Telemetry Database

This is a Boston University EX 603 project, maintained by `Aleksei [Keysella] Glebov`.

A relational database design for storing and analyzing player participation and performance across game matches.

**Theme:** Game Telemetry

## Domain

This project models a telemetry platform for a multiplayer game. The platform records players, matches, player participation in those matches, game modes, and numerical performance data. The design is inspired by match-based games such as Teamfight Tactics, although the schema is intentionally general enough to represent similar multiplayer games.

The database should support questions such as which players participated in a particular match, what score a player achieved, which game mode was associated with a match, and how player scores compare across multiple matches. It should also preserve relationships between historical matches, players, and game modes while preventing invalid references or duplicate participation records.

The relational design separates players, matches, participation events, game-mode categories, and match-mode associations so that each fact is stored in one appropriate location.

## Entity Relationship Diagram

![Game Telemetry ERD](schema/erd.png)
