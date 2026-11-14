# Test 03 — Arduino serial parser (no motor)

Upload `SerialParserTest/SerialParserTest.ino` to Nano Every, **disconnect servo**, open Arduino Serial Monitor at **9600 baud**, line ending **Newline**. Send these commands in sequence: `stop`, `far`, `medium`, `near`, `banana`.

Expected target prints: **0, 10, 20, 30**, followed by `ERROR: Unknown command`. A missing output often indicates the wrong Serial Monitor line ending; unreadable output often indicates a baud mismatch. Use this unit test to isolate the parser from motors, Processing and Wekinator.
