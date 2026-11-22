# Unit 3 Analysis Findings

## What the dashboard reported

Dashboard reported that about half of matches ended with a "network timeout" error, and because of that ranked rewards were frozen. From 200 player entries, only 12 ended with a "network timeout" error, meaning 6% of player sessions. In ranked matches only 9 out of 173 had a "network timeout" error, meaning 5.2%. If we also count unfinished matches, it will be 44 out of 200, meaning 22% which is still much lower than the 50% reported by the dashboard. So, it was not a half.

## Where does the error come from

Most entries (166 out of 200) did not have a disconnection reason, and this can be because players may have finished their matches normally and just never disconnected. Dashboard's request dropped all the entries silently while selecting everything except for the "network timeout" error. In the end, only 34 entries remained, which had a finishing reason, rather than 200. For example, 12 network timeouts for the rest of 22 entries is 54.5% of these entries, which likely explains "about half" in the report. Their request did not give an error and the number looked fine, so thats why nobody checked it.

## What should be done

Network timeout is a real, but not a common issue here, only 5-6% player entries had this issue. Thats why there is no reason to hold the rewards frozen for such a small percentage. A new query is lying under queries/unit3/. For the next times - it is better to check the number of entries in the report with the real number of entries in tables. Also, there were like 10 "contested" entries, which dashboard did not even have.
