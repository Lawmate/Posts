# Lorro Precision CNC Post Processors

Fusion 360 post processor files for Lorro Precision Ltd.

## Files

- **CMZ TA25YS v2.cps** - Post processor for CMZ TA-25-YS-640 lathe with Fanuc 32i-B control, sub-spindle and live tooling. Handles most of the basic functions including rigid tapping, oscillation turning, bar feeder communication (To Hydrafeed servo bar feeder)
- **Lorro Hurco mill turn.cps** - Post processor for Hurco VM10i machining centre to make turned parts in the spindle with tools attached to the table, using the lathe setup in Fusion
- **hurco Lorro v4.cps** - Standard 3 axis post for Hurco VM10i with various extras.

## Language

These files use the `.cps` extension as required by Fusion 360 but are written in JavaScript.

## Machine Details

- CMZ TA-25-YS-640 — Fanuc 32i-B control, sub-spindle, live tooling, Y-axis lathe
- Hurco VM10i — WinMax control, 3 axis mill