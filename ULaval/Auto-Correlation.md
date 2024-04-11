# Auto-Correlation

This tool creates an auto-correlation plot from a linear selection in ImageJ.

Briefly, the script extract an intensity profile from the selection and translate this profile over itself with a sum of products. If there's a repeating pattern in the selection, it will creates peaks in the resulting plot even when a lot of noise is present in the image.
