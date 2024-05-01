# Auto-Correlation
<img src="https://github.com/alexandrebastien/ImageJ-Script-Collection/assets/699288/9f1e6b2a-2cfc-4556-bb33-d3d42be68167" width="600">

This tool creates an auto-correlation plot from a linear selection in ImageJ.

Briefly, the script extract an intensity profile from the selection and translate this profile over itself with a sum of products. If there's a repeating pattern in the selection, it will creates peaks in the resulting plot even when a lot of noise is present in the image.

## Config
- Tolerance: The minimum amplitude needed to find a peak (%).
- Outliers: Will remove outliers distances if the value is over x times a standard deviation, normally 3. (enter -1 to skip)

## Tips
- Double click on the line tool and select a larger with if this fits your needs. It will create a smoother plot.
- If the image is really noisy, try a small gaussian filter before.
- You can use straight, segmented (bezier) or curved lines. If you are using a larger line, high curvature can generate artifacts.
- Try to catch most of the peaks without the small ones or noise using the tolerance option. Use the other two options (missing and outliers) if the result is still poor.
