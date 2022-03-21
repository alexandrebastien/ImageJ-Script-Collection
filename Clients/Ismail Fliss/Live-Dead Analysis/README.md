# Live-Dead Analysis

## Summary
This simple script ask for a proeminence value for peak detection and outputs peaks intensities on a 2 channels image, the ratio (ch2/ch1), a plot (ch1 vs ch2) and some basic statistics. It is intended to be used for Live-Dead kit analysis on bacteria or biofilm. It used ImageJ's "find maxima" 2D peak detection on a combination of the 2 channels.

## Protcol
1. Follow the Live-Dead kit indications from the manufacturer.
2. Acquire images on CLSM with a single 488 nm laser line, and both PMTs set with the same gain.
3. Make sure to avoid any staturation. Gain could be adjusted as long as it's the same on both PMTs.
4.  Analyse data with the script.
