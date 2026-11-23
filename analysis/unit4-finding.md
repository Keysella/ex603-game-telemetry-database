# Unit 4 Finding: Network timeouts by match

## True failure rate?

Across the whole platform, 12 out of 200 match participations ended with a network timeout, so, the true failure rate is 6.0%. This replaces the "about half" figure from the old dashboard, which only counted rows that already had a disconnect reason.

## How it varies across matches?

The rate is not spread evenly: four matches (5, 8, 10, 13) had no timeouts at all, while most of the others had one. For matches with enough activity to be meaningful (at least 15 participations), the normal rate is 4.8%. By region, EU (10.0%) and APAC (9.4%) are above the platform rate, while NA had no timeouts.

## Matches to investigate?

- Match 2: 3 timeouts in 16 participations (18.8%), about four times the normal rate. This is a strong one.
- Match 3: 2 timeouts in 13 participations (15.4%), also clearly above the normal rate.
- Match 4 shows 16.7%, but that is a single timeout in only 6 participations, so, it is worth a quick look rather than a full investigation.
