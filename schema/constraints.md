# Integrity Constraints

## Players

- `player_id` is the primary key and must uniquely identify each player.
- `player_name` must not be NULL.

## Matches

- `match_id` is the primary key and must uniquely identify each match.
- `match_name` must not be NULL.
- `is_active` must not be NULL.
- `duration_seconds`, when present, must be greater than or equal to 0.

## Match Participants

- (`player_id`, `match_id`) is a composite primary key.
- `player_id` is a foreign key referencing `Players(player_id)`.
- `match_id` is a foreign key referencing `Matches(match_id)`.
- `joined_at` must not be NULL.
- `score` must not be NULL.
- A player may appear at most once in a particular match.

### ON DELETE

`player_id` uses ON DELETE RESTRICT.

A player cannot be deleted while match participation records still reference that player. This protects historical telemetry from being removed accidentally.

`match_id` uses ON DELETE CASCADE.

If a match is deleted, its participant records no longer have meaning by themselves, so they should be removed together with the match.

## Game Modes

- `mode_id` is the primary key and uniquely identifies a game mode.
- `mode_name` must not be NULL.

## Match Modes

- (`match_id`, `mode_id`) is a composite primary key.
- `match_id` references `Matches(match_id)`.
- `mode_id` references `Game_Modes(mode_id)`.
- The same game mode cannot be assigned to the same match more than once.

### ON DELETE

`match_id` uses ON DELETE CASCADE.

If a match is deleted, its game-mode associations should also be deleted because they have no independent meaning.

`mode_id` uses ON DELETE RESTRICT.

A game mode that is already referenced by historical matches should not be deleted. It may instead be renamed or made inactive if necessary.
