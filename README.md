# WSAO Project STFC Placement
This is a project assigned to me during my placement at the Central Laser facility (STFC RAL).

The goal is to perform Adaptive Optics without the use of a wavefront sensor. Removing the need for a sensor is not just
a way to lower the cost of the AO setup, but also frees up space for more optics on the optical table.

Normally, the wavefront sensor measures the influence of every actuator on the deformable mirror and the influence matrix is constructed.
By getting a modal description of the influences, a command matrix is computed that returns the requred voltages to flatten a given
wavefront.

To perform sensoreless correction means that you have to get some information about the quality of the wavefront indirectly. The farfield
is probably the best way to do that. It is also a diagnostic that all laser labs use, so no new equipment is added to the setup.
When the wavefront is highly aberrated, the resulting focal spot will be of low quality. This means that a high quality spot, corresponds
to a high quality (or flat) wavefront.

By using an optimisation algorithm with the objective function being the farfield quality, sensorless phase optimisation is possible.

In this repository I have included an adaptive optics simulation and numerical optimisation alorithms which I used during my placement to
show as a proof of consept that WSAO is possible. All code is written in MATLAB. Enjoy :)
