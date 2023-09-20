// Get info about the image
getDimensions(w, h, c, s, f);
getVoxelSize(pw, ph, pz, unit);
title = getTitle();

// If there's 2 channels, threshold twice and merge
if (c == 2){
	run("Split Channels");
	selectWindow("C1-"+title);
	run("Convert to Mask", "method=Otsu background=Dark calculate black");
	selectWindow("C2-"+title);
	run("Convert to Mask", "method=Otsu background=Dark calculate black");
	imageCalculator("OR create stack", "C1-"+title,"C2-"+title);
	close("C1-"+title); close("C2-"+title); 
	rename(title);
}

// If there's 1 channel, just threshold once
if (c == 1) {run("Convert to Mask", "method=Otsu background=Dark calculate black");}

// Otherwise, generate error
if (c > 2) {exit("This function only handle 1 or 2 channels images.");}

// Convert masks from threshold to 0-1 values in 32-bits
run("32-bit"); run("Divide...", "value=255 stack");

// Add all slices in z direction
run("Z Project...", "projection=[Sum Slices]");

// Get statistics on parts where the biofilm is (above Otsu's)
setAutoThreshold("Otsu dark");
min = getValue("Min limit"); max = getValue("Max limit");
mean = getValue("Mean limit"); std = getValue("StdDev limit");
msg = "Min: " +min+ "  Max: " +max+ "  Mean: " +mean+ "  StdDev: " +std;

// Apply a color lookup table (fire) and place a calibration bar for thickness
resetThreshold();
run("Fire");
run("Calibrate...", "function=None unit=µm");
run("Calibration Bar...", "location=[Upper Right] fill=None label=[Light Gray] number=5 decimal=0 font=12 zoom=2 bold show");
run("Scale Bar...", "width=50 height=4 thickness=10 font=30 bold");

// Print the statistics in an overlay message
Overlay.drawString(msg, floor(w/25), 24/25*h, 0.0); Overlay.show();
close(title); close("SUM_"+title); rename(title);

// Print the statistics in an table
i = nResults;
setResult("Image", i, title);
setResult("min", i, min);
setResult("max", i, max);
setResult("mean", i, mean);
setResult("stdDev", i, std);