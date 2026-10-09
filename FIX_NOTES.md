# Fix notes

## 2026-10-09

Fixed the MATLAB error:

`在不同结构体之间进行下标赋值`

The cause was initializing the benchmark array as `struct([])` and then
assigning a populated dataset structure into it. MATLAB requires compatible
structure fields for indexed assignment.

The benchmark list is now initialized directly with the first dataset
structure.

The synthetic demo was also changed to 2400 samples x 50 dimensions so that
the smoke test exercises the shared graph, PPS, granular-ball compression,
SUDE embedding, and final clustering rather than bypassing compression.
