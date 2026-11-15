# Development process

[← Back to project overview](../README.md)

This page brings together photographs and short clips from the development of our proximity-responsive kinetic installation. They show how we explored the form, assembled the mechanism, built the enclosure, and checked the electronics before the final demonstration.

## 1. Early design and shell studies

| Enclosure design sketches | Nautilus-inspired shell prototype |
|:---:|:---:|
| ![Sketchbook drawings exploring a potential design](../media/development/ConceptSketch.jpg) | ![Early physical prototype of the nautilus-inspired kinetic shell](../media/development/form-study.jpg) |

The sketches on the left explore the design and arrangement of the overall form of the kinetic installation. On the right is an early physical prototype of our kinetic shell lamp, inspired by the curved chambers and spiral geometry of the nautilus shell. These studies represent two related parts of the development process: designing the housing for the installation and exploring the form of its moving structure. 

Our initial idea was a light- and sound-based installation built around a nautilus-inspired kinetic lamp. We planned for the shell to shine down onto a bowl of water, with a speaker underneath creating ripples. The shell would respond to visitors' proximity, while the speaker output would change with nearby sound levels. We later revised the speaker-based interaction, as described in the water experiments below.

**Nautilus form references:** [Chambered nautilus shell — Science Photo Library (via Pixels)](https://pixels.com/featured/chambered-nautilus-shell-gilles-mermet.html) · [Chambered nautilus shell detail — UK Posters](https://www.ukposters.co.uk/art-photo/seashell-chambered-nautilus-shell-detail-v137938)

### Wire-frame proof of concept

To explore the nautilus-inspired spiral before constructing the final mechanism, we shaped wire into a lightweight framework and adjusted its curves and connections by hand. This early proof of concept helped us explore the overall spiral form and how its supporting ribs could be arranged.

| Initial spiral wire frame | Shaping and joining the wire |
|:---:|:---:|
| ![Early hand-shaped wire frame forming a spiral on a wooden surface](../media/development/shell-wire-spiral-frame.jpg) | ![Using pliers to adjust and secure connections in the spiral wire frame](../media/development/shell-wire-joining.jpg) |

We then experimented with attaching fabric panels to the curved framework. Covering portions of the wire structure helped us explore how an open skeletal form could develop into the shell's three-dimensional surfaces, whilst allowing light to pass through.

| Attaching fabric panels | Fabric-covered shell study |
|:---:|:---:|
| ![Fabric pieces attached to sections of the curved wire framework](../media/development/shell-fabric-panel-experiment.jpg) | ![Hand-held fabric-covered spiral shell prototype](../media/development/shell-fabric-covered-study.jpg) |

These photographs document exploratory form-making and construction, rather than measured tests of structural strength or servo performance.

## 2. Testing the visual effect of the speaker on water

| Setup | Visual effect on water |
|:---:|:---:|
| ![Bass setup](../media/development/WaterSetup.jpg) | ![Effect on water](../media/development/water1.jpg) ![Effect on water](../media/development/water2.jpg) ![Effect on water](../media/development/water3.jpg) |

In order to test the effect that a speaker has on water, we created the above test setup using a bass guitar, bass amp, and a metal bowl with water sitting directly atop the speaker horn. The testing was carried out in a dark room, with a flashlight as the light source. We found that frequencies of 40.2Hz and 55Hz created the best visual effects, pictured above. Based on our tests, we predict that changing the frequency of the speaker output as well as changing the way the light hits the water based on user interaction should result in a fairly interesting visual effect.

Our initial plan was to use a speaker beneath the water basin to generate ripples and patterns through sound vibrations. We experimented with different frequencies to explore how the moving water would interact with light from the kinetic shell.

However, the speaker components did not arrive in time for the final assembly. We therefore used a small vibration motor instead to create movement in the water. Although this meant we could no longer implement the original sound-based interaction as planned, it allowed us to retain the ripple effect as part of the installation.

## 3. CADding the kinetic structure

In order to create the kinetic structure, we started by CADding in Fusion360 and mating components to see how the linkages move in relation to each other. The linkage structure was created based on the mechanism behind a Louvre window.

| Closed Shell Assembly | Open Shell Assembly | Explode view |
|:---:|:---:|:---:|
| ![Closed Shell](../media/development/NautilusShellClosed.png) | ![Open Shell](../media/development/NautilusShellOpen.png) | ![Open Shell](../media/development/NautilusShellExplode.png) |

The form is just a baseline structure which, ideally, would be laser cut from clear acrylic in order to allow light to shine through. Additional wire scaffolding will be built on top of this model, based on the preliminary physical testing done. The structure is to be held together using 14 M3x12 screws and 14 nyloc nuts.

The full STEP file can be found **here** [CAD Assembly](../media/development/Nautilus-Shell-Mechanism-CAD.step)

## 4. Building the kinetic structure and enclosure

| 3D printed Kinetic structure | Kinetic structure with wire frame | Kinetic Structure with paper scaffolding |
|:---:|:---:|:---:|
| ![3D printed structure](../media/development/NautilusOpen.jpg) | ![wire frame structure](../media/development/kinetic-assembly.jpg) | ![paper structure](../media/development/NautilusPaper.jpg) |

After 3D printing the kinetic structure for testing, a wire structure was shaped by hand and added onto the individual fins, to give it a 3D shape. Paper was then added on top of this in order to create the 3D nautilus shell shape. With lights mounted inside, the amount of light let out should increase or decrease based on how open or closed the kinetic structure is, whilst still letting a baseline level of light to shine through the paper.

The enclosure was built separately to house the illuminated basin and electronics.

|Plywood box|
|:---:|
| ![Fabricated plywood box before final assembly](../media/development/fabricated-enclosure.jpg) |

**Development clips:** [Shell assembly test](../media/videos/mechanical-shell-assembly-0590.mp4) · [Mechanical shell close-up](../media/videos/mechanical-shell-closeup-0601.mp4) · [Earlier mechanism handling](../media/videos/mechanism-assembly-test.mp4) · [Digital motion study](../media/videos/digital-motion-study.mp4)

The servo moved the 3D printed structure during our standalone checks, but struggled once the wire scaffolding and paper were attached, due to increased weight and friction between linkages. The assembled mechanism also needed more support to stay stable. We adjusted the movement ranges and speeds as we worked through those constraints. The footage shows the assembly being handled; it does not measure the load or torque involved. [We discuss this in the testing notes.](../tests/README.md#3-how-the-tests-developed-with-the-project)

## 5. Electronics and lighting tests

| Servo and Arduino on a breadboard | LED ring during a colour test |
|:---:|:---:|
| ![Servo wired to microcontroller and breadboard](../media/development/servo-breadboard.jpg) | ![LED ring showing individual coloured lights](../media/development/led-prototype-test.jpg) |

The images show isolated electronics and light tests. The multicolour LED image represents an earlier experiment; the final integrated program uses blue illumination at four brightness levels. These photographs illustrate the setup but do not substitute for recorded electrical measurements or complete test results. We kept the [servo position test](../tests/01-servo-position/README.md) and [LED ring test sketch](../tests/07-led-ring/RingLEDLight/RingLEDLight.ino) with the other debugging files.

The planned sound-responsive interaction was not implemented, as the speaker components did not arrive in time. We used a vibration motor for the water-ripple effect instead, as explained in [Section 2](#2-testing-the-visual-effect-of-the-speaker-on-water).

## 6. Integration and final demonstration

| Wiring inside the open enclosure | Assembled prototype in use |
|:---:|:---:|
| ![Wiring placed inside the open enclosure](../media/development/enclosure-wiring.jpg) | ![Assembled prototype demonstrated in person](../media/development/final-assembly-presentation.jpg) |

The assembled installation combined the kinetic structure, servo, LED ring, plywood enclosure, webcam, Processing interface, and Wekinator classification model.

- [Watch the final demonstration](../media/videos/final-demonstration.mp4)
- [Read the test procedures](../tests/README.md)
- [Read the test observations](../tests/TEST_RESULTS.md)

**Note:** These are selected development photographs and clips, rather than a complete chronological build log. Any claims about performance should be supported by the corresponding tests and observations.
