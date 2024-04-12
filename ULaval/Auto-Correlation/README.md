# Auto-Correlation
<img src="https://github.com/alexandrebastien/ImageJ-Script-Collection/assets/699288/9f1e6b2a-2cfc-4556-bb33-d3d42be68167" width="600">

This tool creates an auto-correlation plot from a linear selection in ImageJ.

Briefly, the script extract an intensity profile from the selection and translate this profile over itself with a sum of products. If there's a repeating pattern in the selection, it will creates peaks in the resulting plot even when a lot of noise is present in the image.

## Config
Tolerance: The minimum amplitude needed to find a peak.
Missing: Will try to divide by 2 peaks distances. If the value is with some % [0-1] of the median it will keep the division. This is to account for missing peaks. (enter -1 to skip)
Outliers: Will remove outliers distances if the value is over x times a standard deviation, normally 3. (enter -1 to skip)
