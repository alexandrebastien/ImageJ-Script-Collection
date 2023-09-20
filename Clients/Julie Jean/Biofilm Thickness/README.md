# Biofilm Thickness Analysis

## Purpose
This script was developed by Alexandre Bastien (IBIS Microscopy Platform) for Professor Julie Jean and Nissa Niboucha from Université Laval (Québec, Québec, Canada), and is being used for a paper in publication. The credits will be updated when available. Please cite accordingly.

## Summary
This simple script determines the thickness of a biofilm from a confocal z-stack image while generating a thickness map and showing basic statistics about the generated map. Briefly, it turns the z-stack into a binary image (1 & 0) using Otsu's automatic thresholding. The local thickness is calculated by summing the ones along the z axis and using the voxel calibration. A map of the thickness is then generated. Regions with some biofilms are again selected using Otsu and analyzed for statistics. This script is intended to be used with biofilms stained with the ThermoFisher Live-Dead kit for bacteria. Thus, it merges the two channels (red and green) to measure the entire thickness of live and dead bacteria.

## Protocol
1. Follow the Live-Dead kit indications from the manufacturer.
2. Avoid biofilm thickness over 50 µm, especially when imaging in water.
3. One should empirically assess the maximal thickness as the fluorescence will fade when imaging deeper, and the pixels might not get picked properly by Otsu's thresholding.
