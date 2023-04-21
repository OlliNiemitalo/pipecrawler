# Pipecrawler
Crawler for helical scanning of pipes. Work in progress.

The idea is to build a robot that rotates inside a straight pipe of roughly 12 cm diameter and slowly moves along the pipe. Attaching a camera to the robot allows to image the pipe or to image whatever is outside a transparent pipe, such as plant roots. The camera looks at a helical track that overlaps itself by some amount on successive turns. The overlap allows stitching the images or video together. Light sources can be attached to the robot.

## First prototype 2023-04-21

First we try to build the upper crawler unit that carries the camera. This should be rotated with respect to a lower crawler unit, by a slow motor.

![image description](crawler1.png)

![image description](crawler2.png)

The wheels use "608" roller blade bearings with a Fiberlogy Fiberflex 40D (thermoplastic polyurethane filament) tire. It is a bit slippery but perhaps not as slippery as TPU. Layer changes in printing give small bumps; vase mode printing could be investigated, but it would require g-code editing.

![image](https://user-images.githubusercontent.com/60920087/233575127-6ddb9166-6b72-4d2e-974e-c1c463e9f9bc.png)

The upper unit was 3d-printed in PETG in two halves ("top" and "bottom"). The flexure springs feel a bit too tight, likely demanding too much power from a motor.
