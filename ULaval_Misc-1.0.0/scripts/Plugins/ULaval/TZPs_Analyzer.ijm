/* TZPs ANALYZER
   ¯¯¯¯¯¯¯¯¯¯¯¯¯
   TZPs Analyzer is a macro/plugin that compute basic morphological measurements
   on a batch of region of interest (ROI) zip files and associated images. The 
   images should be Tiffs with the same name as the corresponding zip file. The
   zip files contain ROIs for every transzonal projection (TZP). Some measurements
   are also done on the zona pelucida (ZP) itself and the ooplasm. TZPs must be
   freeline type while ZP and ooplasm are freehand type. It's possible to have
   0, 1, 2 or 3 freehand elements.

   Biological knowledge: TZPs are structure in the oocyte zona pellucia that form
   channels linking the oocyte to the surrounding cumulus cells. They are generally
   stained with an actin marker.

   TO DO:
   Entire oocyte (area, roundness, center)
   Zona Pellucida (area, roundness, intensity, mean thickness)
   Ooplasm (area, roundness, intensity)
   Transzonal Projections (angle with center, distance inner, distance outter)

   AUTHOR  : Alexandre Bastien, Copyright (c) 2020
   EMAIL   : alexandre.bastien@fsaa.ulaval.ca 
   LICENSE : Licensed under MIT License, see file LICENSE
*/


dir = getDirectory("Choose input directory");
filelist = getFileList(dir);
setBatchMode(true);

names = newArray(0);
for (jj=0; jj<filelist.length; jj++) {
	if (endsWith(filelist[jj], ".zip")) {
		names = Array.concat(names,newArray(replace(filelist[jj],".zip","")));
	}
}

L  = newArray(names.length); Ls  = newArray(names.length);
R  = newArray(names.length); Rs  = newArray(names.length);
TZPsCount = newArray(names.length);
Table.create("RAW data")

for (jj=0; jj<names.length; jj++) {
	open(dir+names[jj]+".tif");
	roiManager("reset");
	roiManager("Open", dir+names[jj]+".zip");
	run("Set Measurements...", "length mean redirect=None decimal=4");
	// Do per measurements per TZP
	len  = newArray(roiManager("count"));
	R2   = newArray(roiManager("count"));
	kk = 0;
	for (ii=0; ii<roiManager("count"); ii++) {
		roiManager("Select", ii);
		if (matches(Roi.getType,"freeline")) {
			Roi.getCoordinates(x,y);
			Fit.doFit("Straight Line", x, y);
			roiManager("measure");
			R2[kk]   = Fit.rSquared;
			len[kk]  = getResult("Length", nResults-1);
			kk++;
		}
		Array.getStatistics(len, min, max, L[jj], Ls[jj]);
		Array.getStatistics(R2, min, max, R[jj], Rs[jj]);
		TZPsCount[jj] = kk;
	}
	close();
	selectWindow("RAW data");
	Table.setColumn("Len:"+names[jj], len);
	Table.setColumn("Str:"+names[jj], R2);
}

setBatchMode(false);
selectWindow("Results");
Table.reset("Results");
Table.setColumn("Name",names);
Table.setColumn("TZPsCount", TZPsCount);
Table.setColumn("TZPsLength", L);
Table.setColumn("TZPsLengthSTD", Ls);
Table.setColumn("TZPsStraightness", R);
Table.setColumn("TZPsStraightnessSTD", Rs);
Table.update;