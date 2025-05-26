# I2C-Master-Controller
Designed an RTL-level I2C Master Controller using a finite state machine (FSM) to control SDA/SCL line transitions. Developed a Verilog testbench for stimulus generation and validated protocol behavior using GTKWave. Analyzed waveform outputs (i2c.vcd, sim.out) to verify correct I2C timing and communication.





Here's the waveform generated from your i2c.vcd file, showing transitions for the following signals over time:

clk: Clock signal used to synchronize the I2C communication.

rst: Reset signal, typically active-high to reset the state machine or registers.

scl: Serial Clock Line for I2C — controlled by the master to coordinate data bits.

sda: Serial Data Line for I2C — used for sending/receiving bits during communication.

Waveform Explanation:
clk:

Alternates between 0 and 1 consistently — the heartbeat of communication.

Data bits are usually sampled on rising or falling edges.

rst:

Starts high (1) then drops low (0), indicating the system is coming out of reset.

scl:

Remains low initially (possibly while waiting for data), then toggles to simulate bit-level timing.

sda:

Changes state when scl is low and typically held steady when scl is high.

This behavior is essential to prevent race conditions in I2C.

You can analyze key events like:

START condition: sda goes from high to low while scl is high.

STOP condition: sda goes from low to high while scl is high.

Data bit transmission: occurs while scl is toggling and sda is stable.
