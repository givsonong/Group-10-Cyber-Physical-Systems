# Test execution log

**Statuses:** PENDING (not verified), PASS (observed expected result), FAIL (observed failure), BLOCKED (unsafe or unavailable prerequisite).

| Test | Status | Expected | Observation to date / evidence | Next action |
|---|---|---|---|---|
| 01 — positional servo | PENDING | Reaches 60°, 90°, 120° and holds | Prior experiments reportedly showed unexpected continuous movement. A stable positional hold has not been confirmed. | Verify independent regulated power and physical motion. |
| 02 — pulse-width servo diagnostic | PENDING | Distinct small positional moves at 1400, 1500, 1600 microseconds | Serial Monitor displayed all test messages; no visible rotation was reported. This is inconclusive. | Recheck wiring and observe small position changes. |
| 03 — Arduino serial parser | PENDING | stop→0, far→10, medium→20, near→30 | Not yet recorded. | Run parser sketch without servo. |
| 04 — Processing / Arduino communication | PENDING | Keys 0–3 produce correct outputs | Not yet recorded. | Verify port and serial messages, then motion if safe. |
| 05 — Wekinator classifier | PENDING | Empty/far/medium/near → 1/2/3/4 | Not yet recorded. | Test each class five times. |
| 06 — end-to-end | PENDING | Classified proximity controls intended servo position | Not yet recorded. | Attempt only after earlier tests pass. |

## Test record template

- Date / operator:
- Exact commit SHA:
- Board model and USB serial port:
- Servo label/model, external supply voltage/current rating, wiring:
- Sketch and libraries/versions:
- Steps and conditions (lighting, camera distance, mechanical load):
- Expected observation:
- Actual observation:
- Evidence: photo, screenshot, video or log filename:
- Result (PASS / FAIL / BLOCKED / PENDING):
- Next action:

## Machine-learning classification trial table

Use the same camera position and labelled training distances, hold the scene steady, and record the *latest raw class* after it settles. Repeat with varied clothing/lighting if possible.

| Actual scene | Trial 1 | Trial 2 | Trial 3 | Trial 4 | Trial 5 | Correct / 5 |
|---|---|---|---|---|---|---|
| Empty (class 1) | | | | | | |
| Far (class 2) | | | | | | |
| Medium (class 3) | | | | | | |
| Near (class 4) | | | | | | |

**Limitations:** The 16 × 9 greyscale model does not explicitly measure depth or track individual people. Document mixed-person scenes and false classifications rather than claiming nearest-person detection without evidence.