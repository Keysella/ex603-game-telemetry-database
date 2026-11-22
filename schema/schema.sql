-- ============================================================
-- EX 603 Assignment 2 - schema.sql
-- Theme:  Game Telemetry
-- Author: Aleksei Glebov
-- Target: PostgreSQL 14+
-- ============================================================
--
-- Creation order (a table must exist before another table can
-- reference it with a foreign key):
--
--   1. Players            - no foreign keys to other tables
--                           (self-reference referred_by -> players
--                           - it does not change the order)
--   2. Game_Modes         - no foreign keys to other tables
--   3. Matches            - no foreign keys to other tables
--   4. Match_Participants - references Players, Matches
--   5. Match_Modes        - references Matches, Game_Modes
--
-- Tables are dropped in the reverse order (5 -> 1), so that no
-- table is removed while another table still references it.
--
-- ============================================================
--
-- Reset. Reverse creation order, so no dependency blocks a drop.

DROP TABLE IF EXISTS match_modes CASCADE;
DROP TABLE IF EXISTS match_participants CASCADE;
DROP TABLE IF EXISTS matches CASCADE;
DROP TABLE IF EXISTS game_modes CASCADE;
DROP TABLE IF EXISTS players CASCADE;

--
-- ============================================================
--
-- 1. players: first, references no other tables (only itself for referred_by)
--

CREATE TABLE players (
    player_id INTEGER GENERATED ALWAYS AS IDENTITY,
    player_name VARCHAR(32) NOT NULL,
    referred_by INTEGER,
    CONSTRAINT pk_players PRIMARY KEY (player_id),
    CONSTRAINT fk_players_referred_by
        FOREIGN KEY (referred_by) REFERENCES players(player_id)
        ON DELETE SET NULL,
    CONSTRAINT chk_players_no_self_referral
        CHECK (referred_by IS DISTINCT FROM player_id)
);

--
-- ============================================================
--
-- 2. game_modes: second, no foreign keys to other tables
--

CREATE TABLE game_modes (
    mode_id INTEGER GENERATED ALWAYS AS IDENTITY,
    mode_name VARCHAR(50) NOT NULL,
    CONSTRAINT pk_game_modes PRIMARY KEY (mode_id),
    CONSTRAINT uq_game_modes_mode_name UNIQUE (mode_name)
);

--
-- ============================================================
--
-- 3. matches: third, no foreign keys to other tables
--

CREATE TABLE matches (
    match_id INTEGER GENERATED ALWAYS AS IDENTITY,
    match_name VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    duration_seconds INTEGER,
    CONSTRAINT pk_matches PRIMARY KEY (match_id),
    CONSTRAINT chk_matches_duration_non_negative
        CHECK (duration_seconds IS NULL OR duration_seconds >= 0),
    CONSTRAINT chk_matches_active_no_duration
        CHECK (NOT is_active OR duration_seconds IS NULL),
    CONSTRAINT chk_matches_inactive_with_duration
        CHECK (is_active OR duration_seconds IS NOT NULL)
);

--
-- ============================================================
--
-- 4. match_participants: fourth, references players, matches
--

CREATE TABLE match_participants (
    player_id INTEGER NOT NULL,
    match_id INTEGER NOT NULL,
    joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    score INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT pk_match_participants PRIMARY KEY (player_id, match_id),
    CONSTRAINT fk_match_participants_player
        FOREIGN KEY (player_id) REFERENCES players(player_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_match_participants_match
        FOREIGN KEY (match_id) REFERENCES matches(match_id)
        ON DELETE CASCADE
);

--
-- ============================================================
--
-- 5. match_modes: fifth, references matches, game_modes
--

CREATE TABLE match_modes (
    match_id INTEGER NOT NULL,
    mode_id INTEGER NOT NULL,
    CONSTRAINT pk_match_modes PRIMARY KEY (match_id, mode_id),
    CONSTRAINT fk_match_modes_match
        FOREIGN KEY (match_id) REFERENCES matches(match_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_match_modes_mode
        FOREIGN KEY (mode_id) REFERENCES game_modes(mode_id)
        ON DELETE RESTRICT
);
