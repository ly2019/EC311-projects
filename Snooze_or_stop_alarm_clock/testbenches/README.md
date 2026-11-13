# Lab 3 alarm-clock sequential testbenches

| Simulation top | Coverage | Simulation length |
| --- | --- | --- |
| `ticker_testbench` | Initial high tick, four-cycle tick spacing/width, divide by one | 210 ns |
| `clock_testbench` | No-tick hold, seconds/minutes/hour carries, midnight, reset with nonzero seconds and tick asserted | 613,630 ns |
| `timer_testbench` | 300/180-second loads, enable over tick priority, hold, both complete countdowns, decimal carries, final-second timeout, zero saturation, clearing/invalid snooze count | 4,950 ns |
| `alarm_fsm_testbench` | All eight states and outputs, both snoozes, waiting/buzz holds, stop priority, ignored third snooze, one-cycle load states, reset from every state | 1,030 ns |
| `display_testbench` | Actual counter scan through all eight digits, stable digit before transition, active-low outputs, decimal points, wrap, live digit change | 10,485,770 ns |
| `top_testbench` | Button mapping, LED buzzer, actual timer/FSM handshake, both full countdowns and timeouts, final buzz, stop, re-arm, reset | 19,400 ns |

The ticker and top benches override existing ticker parameters for fast
simulation. In top, a simulated second is 40 ns. The clock and timer unit benches
drive `tick` directly; each high-tick rising edge counts as one second.
The display bench uses the original 20-bit scan counter, so use **Run All**.
No internal register is forced or overwritten; some checks read internal state
to make failures easier to diagnose.


In `clock`, the reset branch assigns `hour` and `minute` but never `second`.
If reset is intended to restart at 06:58:00, add `second <= 6'd0;` to that
branch. This change has not been applied to the design. The test asserts that
interpretation of reset; revise the expectation if preserving seconds is
intentional.

Other current behavior captured by the tests: `timer_en` means **load/reload**,
not count-enable; timeout is high only when one second remains and tick is high;
stop in a snooze-load state takes effect after the automatic waiting-state
transition. Top uses the trigger button to start the alarm; the displayed clock
does not automatically trigger it at a particular time.
