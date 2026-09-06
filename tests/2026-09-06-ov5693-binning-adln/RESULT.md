# Surface Go 4 OV5693 2x2-binning / Alder Lake-N validation result

Status: **PENDING**  
Date: TBD  
Device: Microsoft Surface Go 4  
Kernel: TBD  
IPU6 PCI ID: expected `8086:462e` (`PCI_DEVICE_ID_INTEL_IPU6EP_ADLN`)  
Front camera: expected `INT33BE` / CAMF / OV5693

## Patch stack

Fernando Rimoli upstream clock-lane series revision: TBD  
D. Manresa binning patch: `ov5693-binned-no-mipictrl.patch`  
Patch header commit: `548281df0983aa0b4e15c923e97d122419787078`

Exact kernel/source commit: TBD

## Test conditions

Lighting / scene: TBD  
Camera orientation: TBD  
`binned_y_offset`: expected default `2`, verify  
Relevant exposure/AGC controls: TBD

## Full-resolution control — 2592x1944

Capture command: TBD

```text
requested_frames=300
exit_code=TBD
frame_count=TBD
fps=TBD
```

Analogue gain in comparison scene: TBD

Relevant kernel messages:

```text
TBD
```

Evidence: `01-fullres/`

## 2x2-binned mode — 1296x972

Sensor format command expected by the requester:

```bash
v4l2-ctl -d /dev/v4l-subdevN \
  --set-subdev-fmt pad=0,width=1296,height=972,code=0x3001
```

Use the actual OV5693 subdevice path identified during preflight.

Capture command: TBD

```text
requested_frames=300
exit_code=TBD
frame_count=TBD
fps=TBD
```

Analogue gain in the same comparison scene: TBD

Relevant kernel messages:

```text
TBD
```

Explicit checks:

```text
Frame sync error: TBD
Transfer FIFO overflow: TBD
```

Evidence: `02-binned/`

## Raw Bayer-phase check

Raw file: TBD  
Resolution: expected 1296x972  
`binned_y_offset`: TBD  
Observed Bayer phase: TBD  
Expected with offset 2: BGGR

Evidence: `03-raw-bayer/`

## Gain comparison

```text
full-resolution analogue gain: TBD
2x2-binned analogue gain:       TBD
ratio (full / binned):          TBD
```

The Surface Pro 7+ result (~10x drop) is context only and must not be copied as the Surface Go 4 result.

Evidence: `04-gain/`

## ADL-N bit-5 + binning result

```text
Fernando conditional MIPI bit-5 fix active: TBD
unconditional MIPI_CTRL00=0x2d absent:       TBD
2x2 binning streams on ADL-N:                TBD
```

## Conclusion

TBD after evidence is collected.

Do not add a `Tested-by:` statement here until the tested patch/revision and observed behavior are unambiguous.
