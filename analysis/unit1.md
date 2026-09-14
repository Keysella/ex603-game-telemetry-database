# Unit 1 Analysis

## Modelling Justification

The database is designed to support a game telemetry platform that records players, matches, participation in matches, and game modes. The design separates these concepts into five relations so that each type of information has a clear purpose and unnecessary duplication is avoided. This approach follows database normalization principles to reduce redundancy and improve data integrity.

### Players

The Players relation uses `player_id` as its primary key. I chose a numeric identifier instead of `player_name` because player names may not be permanent or unique. Players may change their displayed name while their identifier should remain stable. The same principle is used for Matches and Game Modes, which use `match_id` and `mode_id` respectively. These surrogate numeric keys make relationships between tables simple and prevent descriptive values from being used as identifiers.

### Match Participants

Match Participants represents the event relation connecting players with matches. Its primary key is the combination of foreign keys `player_id` and `match_id`. This reflects the rule that a player can participate in a specific match only once. The relation also stores `joined_at`, which records when the participation occurred, and `score`, which is the numeric telemetry value that can later be aggregated for analysis (e.g., average score per player).

### Match Modes

Match Modes is a junction relation between Matches and Game Modes. Its composite primary key consists of foreign keys `match_id` and `mode_id`. This prevents the same mode from being associated with the same match more than once. Keeping game modes in a separate catalog also avoids storing repeated text values such as mode names in every match record.

### Deletion Behavior

Foreign-key deletion behavior was chosen based on whether dependent data has meaning independently of its parent.  

Match Participants and Match Modes use ON DELETE CASCADE when their referenced match is deleted - if a match is removed, its participation and mode assignments should also be removed, because participation and mode assignments describe a specific match and therefore should not remain if that match no longer exists.  

Deletion of a Player is restricted while participation records reference it, to protect historical telemetry from accidental deletion. Game Modes are also protected using ON DELETE RESTRICT because previously recorded matches may depend on those categories - removing a mode would break historical data integrity.

### Constraints

Several rules are enforced in the schema instead of being left to application code. Primary keys prevent duplicate entities, foreign keys prevent references to players, matches, or modes that do not exist, and NOT NULL constraints ensure required data is always present. The composite keys prevent duplicate match participation and duplicate match-mode associations.

### Duration Handling

The database also allows `duration_seconds` to be nullable. This is intentional because an active match may not yet have a final duration. Once the match finishes, the application can store the completed duration and mark the match as inactive. This design supports both ongoing and completed matches without requiring artificial placeholder values.

## Reflection

One design decision that another designer could reasonably make differently is the primary key of the Match Participants relation. I chose the composite key (`player_id`, `match_id`) because the platform treats participation as one record per player per match. This directly enforces an important business rule: the same player cannot accidentally be inserted into the same match twice - it would violate the primary key constraint.

An alternative design could introduce a separate `participation_id` or `event_id` as a surrogate primary key. That approach would make individual event records easier to reference and would allow multiple records for the same player and match. It could therefore be a better design for a system that records many low-level telemetry events during gameplay.

For this project, however, the expected read pattern is primarily match-oriented analysis, such as retrieving the players in a match or calculating scores across matches. The composite key matches these queries naturally and avoids introducing an identifier that currently has no additional meaning. Writes are also relatively simple because each player-match pair should be inserted only once. If the system later evolves into detailed event-by-event telemetry, adding a separate event relation with its own event identifier would be more appropriate than changing the meaning of Match Participants.
