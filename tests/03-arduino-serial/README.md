# Test 03 — Arduino serial parser

**Aim:** Validate the text-to-angle protocol **without any servo connected**. Upload [SerialParserTest.ino](SerialParserTest/SerialParserTest.ino), select **9600 baud** and **Newline** in Arduino IDE Serial Monitor.

Send the words: stop, far, medium, near, and an invalid word such as hello. The expected target angles are 0, 10, 20, 30, and an error for hello. Mixed upper/lowercase and surrounding whitespace should be tolerated.

If messages do not appear, check the selected Nano Every port and 9600 baud. If a command is not recognised, verify Newline is selected. Only a **received, parsed** message counts as a passing observation; do not connect the servo for this test.