# Surface Go 4 OV5693 2x2-binning / Alder Lake-N validation

This directory records validation of D. Manresa's OV5693 2x2-binning patch on a Microsoft Surface Go 4 (Alder Lake-N / IPU6, PCI ID `8086:462e`).

The experiment is intentionally separated from the earlier clock-lane A/B test in `tests/2026-09-01-ov5693-v4-adln/`.

## Goal

Validate the currently untested combination of:

- Surface Go 4 / Alder Lake-N (`IPU6EP_ADLN`)
- OV5693 front camera (`INT33BE` / CAMF)
- Fernando Rimoli's upstream `clock-noncontinuous` / MIPI bit-5 fix
- D. Manresa's OV5693 2x2-binning changes, **without** the overlapping `MIPI_CTRL00` hunks

The binning patch under test was provided specifically for this A/B test:

- Source: https://github.com/dmanresa-saes/surface-ipu6-cameras/blob/master/patches/ov5693-binned-no-mipictrl.patch
- Patch header commit: `548281df0983aa0b4e15c923e97d122419787078`
- PR discussion: https://github.com/linux-surface/linux-surface/pull/2252#issuecomment-5554821687

## Requested checks

D. Manresa requested the following evidence from an ADL-N machine:

1. Select the OV5693 binned mode (`1296x972`, SBGGR10) and confirm that it streams.
2. Run a 300-frame comparison between full resolution (`2592x1944`) and binned (`1296x972`). Preserve complete capture output and check kernel logs for `Frame sync error` and `Transfer FIFO overflow`.
3. Save at least one raw binned frame and verify the Bayer phase. With the default `binned_y_offset=2`, the expected phase is BGGR.
4. Compare analogue gain in the same scene between full-resolution and binned operation. On Surface Pro 7+, the required gain dropped by roughly 10x; the Go 4 result must be measured independently.
5. Confirm whether the combination "MIPI bit 5 only + 2x2 binning" works correctly on Alder Lake-N.

## Evidence layout

The test should preserve evidence in the following structure:

- `00-preflight/` — kernel, modules, PCI/ACPI enumeration, media topology and tool versions before changes
- `01-fullres/` — full-resolution 2592x1944 control run
- `02-binned/` — 1296x972 2x2-binning run
- `03-raw-bayer/` — raw binned frame(s) and Bayer-phase notes
- `04-gain/` — comparable full-res/binned exposure and analogue-gain evidence
- `05-summary/` — concise derived values or extra notes, if needed
- `RESULT.md` — final human-readable result suitable for linking from GitHub/lore

Directories are created as evidence is collected; Git does not preserve empty directories.

## Logging policy

Preserve raw command output whenever practical. Do not remove warnings simply because they appear unrelated. Record exact commands, kernel version, source/patch revisions, module paths and relevant `dmesg` for each run.

For a meaningful A/B comparison, keep the physical scene, lighting, camera orientation and relevant controls unchanged between the full-resolution and binned runs.

## Test order

1. Run `collect-preflight.sh` before replacing or rebuilding modules.
2. Record the exact Fernando-series revision / kernel source used.
3. Apply the no-MIPI_CTRL binning patch on top of the clock-lane fix and rebuild the required modules together so MODVERSIONS stay consistent.
4. Cold boot if the module/kernel change warrants it.
5. Capture the full-resolution control run first.
6. Capture the binned run.
7. Preserve a raw binned frame and determine Bayer phase.
8. Record analogue gain for both modes in the same scene.
9. Complete `RESULT.md` only from collected evidence.

## Important isolation rule

Do not add an unconditional `MIPI_CTRL00 = 0x2d` write for this test. The purpose of this variant is to keep Fernando's conditional bit-5 clock-lane fix separate from the binning/PLL/readout-geometry changes, so success or failure can be attributed correctly.

## Status

**Pending hardware test.** No result should be inferred from this directory until `RESULT.md` is completed with captured evidence.
