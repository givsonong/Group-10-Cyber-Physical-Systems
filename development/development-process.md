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

However, the speaker component did not arrive in time for the final demonstration. We used a standalone vibrator instead and placed it inside the plywood enclosure, beneath the metal water basin. It created ripples in the water independently of the Arduino-controlled servo and LED ring. This allowed us to retain the ripple effect, although we could not implement the original sound-responsive interaction.

## 3. CADding the kinetic structure

In order to create the kinetic structure, we started by CADding in Fusion360 and mating components to see how the linkages move in relation to each other. The linkage structure was created based on the mechanism behind a Louvre window.

| Closed Shell Assembly | Open Shell Assembly | Explode view |
|:---:|:---:|:---:|
| ![Closed Shell](../media/development/NautilusShellClosed.png) | ![Open Shell](../media/development/NautilusShellOpen.png) | ![Open Shell](../media/development/NautilusShellExplode.png) |

At the CAD stage, we initially intended to fabricate the kinetic structure from laser-cut clear acrylic to allow light to pass through the shell. We also planned to add wire scaffolding, informed by our earlier physical experiments, to develop a fuller three-dimensional nautilus form. The CAD assembly was designed around 14 M3×12 screws and 14 nyloc nuts.

During prototyping, we instead 3D-printed the kinetic mechanism and experimented with wire and paper coverings. These additions were eventually removed for the final demonstration because the additional weight and friction made movement difficult for the SG90 servo, as discussed in Section 4.

The full STEP file can be found **here** [CAD Assembly](../media/development/Nautilus-Shell-Mechanism-CAD.step)

## 4. Building the kinetic structure and enclosure

| 3D printed Kinetic structure | Kinetic structure with wire frame | Kinetic Structure with paper scaffolding |
|:---:|:---:|:---:|
| ![3D printed structure](../media/development/NautilusOpen.jpg) | ![wire frame structure](../media/development/kinetic-assembly.jpg) | ![paper structure](../media/development/NautilusPaper.jpg) |

After 3D-printing the kinetic structure, we experimented with attaching hand-shaped wire scaffolding to the individual fins to develop a fuller three-dimensional form. Paper was then added over the wire structure to explore how the shell could diffuse light as it opened and closed.

Although these experiments helped us develop the intended nautilus form, the additional materials increased the load on the mechanism. We therefore removed the wire and paper coverings for the final demonstration, retaining the exposed 3D-printed kinetic structure to allow more reliable servo movement.

Apart from the kinetic mechanism designed in Fusion 360, we designed two mounting brackets in Onshape: one to secure the SG90 servo and another to hold the LED ring. We 3D-printed both brackets and kept them as separate parts for mounting the electronics. We also used Onshape to put the different components together into the final CAD assembly of the installation.

### Plywood enclosure design and fabrication

We made a plywood box to support the metal water basin, with space inside for the electronics and the standalone vibrator. Before cutting the pieces, we drew out the panels to work out their sizes and where the openings would go. The plywood was 13 mm thick. The top panel measured 205 × 205 mm, with a 160 mm diameter opening for the basin. The side panels were 100 mm high, and one of the shorter panels had a 31 mm opening for the support pipe.

The metal water basin was supported by its outer rim, which rested on the top plywood panel around the circular opening. This allowed the basin to sit securely within the enclosure while keeping the water contained in a separate vessel.

The Arduino, breadboard and power board were housed inside the wooden enclosure, beneath the basin, while the servo and LED ring were mounted above it. Wiring to these components was routed through the support tube. This arrangement helped keep the water physically separated from the control electronics during normal operation.

| Top panel | Side panel | Side panel with pipe opening |
|:---:|:---:|:---:|
| [![Top panel dimensions, showing a 205 by 205 mm panel and 160 mm circular opening](../media/development/enclosure-top-panel-dimensions.jpg)](../media/development/enclosure-top-panel-dimensions.jpg) | [![Side panel dimensions, showing a 205 by 100 mm plywood panel](../media/development/enclosure-side-panel-dimensions.jpg)](../media/development/enclosure-side-panel-dimensions.jpg) | [![Shorter side panel dimensions, showing a 180 by 100 mm panel and 31 mm opening](../media/development/enclosure-panel-opening-dimensions.jpg)](../media/development/enclosure-panel-opening-dimensions.jpg) |

*Panel drawings, with dimensions in millimetres.*

We sourced a 30 mm clear acrylic tube from the RCA store to support the kinetic structure above the water basin and give us a route for the wiring. We later spray-painted the tube black. The photos below show the clear tubes before painting. We made the 31 mm opening in the side panel to fit the tube.

| Acrylic tubes at the RCA store | Clear acrylic tubes we selected |
|:---:|:---:|
| [![Clear acrylic tube selection at the RCA store](../media/development/rca-store-acrylic-tube-selection.jpg)](../media/development/rca-store-acrylic-tube-selection.jpg) | [![Clear acrylic tubes selected for the installation](../media/development/clear-acrylic-support-tubes.jpg)](../media/development/clear-acrylic-support-tubes.jpg) |

We also put together CAD views to see how the panels would fit. We kept some triangular offcuts from the plywood and used them as supports inside the box. They gave us material to drill into when fastening the side panels together, rather than throwing the pieces away.

| Exploded view, including the triangular supports | Assembled CAD view |
|:---:|:---:|
| [![Exploded plywood enclosure assembly showing side panels, top panel and triangular supports](../media/development/enclosure-exploded-cad.jpg)](../media/development/enclosure-exploded-cad.jpg) | [![Assembled plywood enclosure model with circular top opening](../media/development/enclosure-assembled-cad.jpg)](../media/development/enclosure-assembled-cad.jpg) |

After cutting the panels, we assembled the sides and base before fitting the top panel. The photos below show the box taking shape and the fabricated enclosure before the rest of the installation was added.

| Side panels and base during construction | Fabricated plywood enclosure |
|:---:|:---:|
| [![Open plywood enclosure after assembling the cut side panels and base](../media/development/enclosure-side-panel-construction.jpg)](../media/development/enclosure-side-panel-construction.jpg) | [![Fabricated plywood box before final assembly](../media/development/fabricated-enclosure.jpg)](../media/development/fabricated-enclosure.jpg) |

**Development clips:** [Shell assembly test](../media/videos/mechanical-shell-assembly-0590.mp4) · [Mechanical shell close-up](../media/videos/mechanical-shell-closeup-0601.mp4) · [Earlier mechanism handling](../media/videos/mechanism-assembly-test.mp4) · [Digital motion study](../media/videos/digital-motion-study.mp4)

The servo moved the 3D printed structure during our standalone checks, but struggled once the wire scaffolding and paper were attached, due to increased weight and friction between linkages. The assembled mechanism also needed more support to stay stable. We adjusted the movement ranges and speeds as we worked through those constraints. The footage shows the assembly being handled; it does not measure the load or torque involved. [We discuss this in the testing notes.](../tests/README.md#3-how-the-tests-developed-with-the-project)

## 5. Electronics and lighting tests

| Servo and Arduino on a breadboard | LED ring during a colour test |
|:---:|:---:|
| ![Servo wired to microcontroller and breadboard](../media/development/servo-breadboard.jpg) | ![LED ring showing individual coloured lights](../media/development/led-prototype-test.jpg) |

The images show isolated electronics and light tests. The multicolour LED image represents an earlier experiment; the final integrated program uses blue illumination at four brightness levels. These photographs illustrate the setup but do not substitute for recorded electrical measurements or complete test results. We kept the [servo position test](../tests/01-servo-position/README.md) and [LED ring test sketch](../tests/07-led-ring/RingLEDLight/RingLEDLight.ino) with the other debugging files.

The planned sound-responsive speaker interaction was not implemented. We used a standalone vibrator for the water-ripple effect instead, as explained in [Section 2](#2-testing-the-visual-effect-of-the-speaker-on-water).

## 6. Integration and final demonstration

| Wiring inside the open enclosure | Assembled prototype in use |
|:---:|:---:|
| ![Wiring placed inside the open enclosure](../media/development/enclosure-wiring.jpg) | ![Assembled prototype demonstrated in person](../media/development/final-assembly-presentation.jpg) |

The assembled installation combined the kinetic structure, servo, LED ring, plywood enclosure, webcam, Processing interface, and Wekinator classification model. The standalone vibrator sat inside the plywood enclosure beneath the water basin and operated separately from the proximity-controlled electronics.

- [Watch the final demonstration](../media/videos/final-demonstration.mp4)
- [Read the test procedures](../tests/README.md)
- [Read the test observations](../tests/TEST_RESULTS.md)

**Note:** These are selected development photographs and clips, rather than a complete chronological build log. Any claims about performance should be supported by the corresponding tests and observations.
