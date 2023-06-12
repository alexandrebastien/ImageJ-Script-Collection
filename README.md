# ImageJ Script Collection
This is a collection of scripts for [ImageJ](https://imagej.nih.gov/ij/index.html)/[Fiji](https://fiji.sc/). Some client's specific projets will be in the "Clients" directory, while scripts of general use or larger project will be in the ULaval directory. Everything in ULaval directory will be mirrored on [Abastien](https://sites.imagej.net/Abastien/)'s Fiji update site.

## Install Fiji and Update Site
Most of these scripts need an up-to-date version of Fiji installed. Fiji is a version of ImageJ2 with a curated collection of plugins. Some scripts might work with plain ImageJ, but it is recommended to us Fiji's version. To follow the Abastien's update site, go in *Help > Update > Manage Update Sites* put the name ULaval and URL https://sites.imagej.net/Abastien/, make sure the box is checked and close. After Fiji restart, you will have a *ULaval* folder in *Plugins* menu. If you want, you can install the ULaval icon in the toolbar to access this menu quickly. Just go in *Plugins > ULaval > Install ULaval Toolbar* and restart Fiji. This modifies *Fiji*Macros/StartupMacros.ijm*.

## Scripts
* 3D Animator → From a confocal z-stack, will build a maximum intensity projection and tilt left and right
* Cilia → Used to find and sort cilia in this [publication](https://doi.org/10.1093/humrep/dey276) by Agathe Bernet
* Min Max Gamma → Non-destructive gamma curve by altering the look-up table interactively, doc [here](https://github.com/alexandrebastien/ImageJ-Script-Collection/blob/master/ULaval/Min_Max_Gamma.md)
* Oligo Banding → Tool to find broken chromosomes, see details [here](https://github.com/alexandrebastien/Oligo-Banding).
* Stitch CZI → Stitch CZI files from Zeiss confocal
* TZP Analyzer → Analyze oocytes transzonal projection shapes, used in many publications by [Claude Robert](https://www.ulaval.ca/la-recherche/repertoire-corps-professoral/claude-robert)
