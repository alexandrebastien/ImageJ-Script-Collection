/* 3D ANIMATOR 
   ¯¯¯¯¯¯¯¯¯¯¯
   3D Animator is an ImageJ macro that creates a 3D animation and a maximum
   intensity projection image from a microscopy fluorescence Z-Stack. The 
   program runs in batch mode, asking for a folder, and doing all stacks in
   that folder. It creates 2 sub-folders named 3D and MIP with the results.
   The animation goes through the Z-Stack, then progressively creates an MIP,
   then rotates the full projection 45° left and right before unfolding back
   into the first Z-Stack image.
   
   AUTHOR  : Alexandre Bastien, Copyright (c) 2022
   EMAIL   : alexandre.bastien@ibis.ulaval.ca
   LICENSE : Licensed under MIT License, see file LICENSE
*/

main();

function main() {
	// Runs in Batch Mode
	setBatchMode("hide");
	
	// User select folder and subfolder are created
	dir = getDirectory("Choose input directory"); listtmp = getFileList(dir); 
	File.makeDirectory(dir+"MIP");
	File.makeDirectory(dir+"3D");
	
	// Keep only czi files
	list = newArray();
	for (ii=0; ii<listtmp.length; ii++) {
		if (endsWith(listtmp[ii], "czi")) {
			list = Array.concat(list,listtmp[ii]);
		}
	}
	
	// Main loop for batch processing
	for (ii=0; ii<list.length; ii++) {
		// Print status, open file, get file name, rename window
		run("Bio-Formats Importer", "open=["+dir+list[ii]+"] autoscale color_mode=Composite "+
			"view=Hyperstack stack_order=XYCZT");
	    filename = File.nameWithoutExtension(); rename("St");
	    createAVI(dir,filename); 
	}
	setBatchMode("exit and display"); // out of batch mode
}

function createMIP(path) {		
    // Create MIP and save as JPG
	getDimensions(w, h, nc, nc, nf);
	getPixelSize(unit, pixelWidth, pixelHeight);
	run("Z Project...", "projection=[Max Intensity]");
	run("RGB Color", " "); rename("MIP"); close("MAX_St");
	applyScaleBar(w,h,pixelWidth, unit);
	save(path);
}

function findBestScaleBar(w,p) {
	pt = 0.15;
	ts = w*p*pt;
	scaleAr = newArray(1,2,5,10,20,25,50,100,150,200,500,1000);
	scalediff = newArray();
	for (i = 0; i < scaleAr.length; i++) {
		scalediff[i] = abs(scaleAr[i] - ts);
	}
	idx = Array.rankPositions(scalediff);
	return scaleAr[idx[0]];
}

function createAVI(dir,filename) {
	selectWindow("St");
	getDimensions(w, h, nc, ns, nf);
	getPixelSize(unit, pixelWidth, pixelHeight);
	
	showStatus("!"+filename+" : MIP");
	createMIP(dir+"MIP/"+filename+".jpg");
	
	// Create progressive stack
	showStatus("!"+filename+" : Progressive stack");
	createProgSt();

	// Create left 3D animation
	showStatus("!"+filename+" : Left 3D");
	view3D(0,45,1,"L3D");

	// Create right 3D animation
	showStatus("!"+filename+" : Right 3D");
	view3D(315,44,1,"R3D");

	// Convertion from slice to time frame of the main stack (St)
	// is needed for later concatenate
	selectWindow("St");
	run("Re-order Hyperstack ...", "channels=[Channels (c)] "+
		"slices=[Frames (t)] frames=[Slices (z)]");

	// Create reverses
	showStatus("!"+filename+" : Reversed animations");
	imwin = newArray("L3D","R3D","St","StP");
	createReverse(imwin);

	// Concatenate the full animation, save as AVI and close
	showStatus("!"+filename+" : Saving");
	run("Concatenate...", "  title=[3D] image1=St image2=StR image3=StP "+
		"image4=L3D image5=L3DR image6=R3DR image7=R3D image8=StPR");
	applyScaleBar(w,h,pixelWidth, unit);
	run("AVI... ", "compression=JPEG frame=15 save=["+dir+"3D/"+filename+".avi"+"]");
	close("*");

}

function createReverse(imwin) {
	// For all 4 opened images:
	//	Enhance contraste in a standardize way
	//	Convert to RGB type
	//	Interleave (doubles frames) to slow down (St and StP only)
	//	Create the reverse images for rewind effect
	
	getDimensions(w, h, nc, ns, nf);
	getPixelSize(unit, pixelWidth, pixelHeight);

	for (i=0; i<lengthOf(imwin); i++) {
		selectWindow(imwin[i]);
		// Make sure loop finishes at channel 1, there a bug otherwise
		for (j=nc; j>0; j--) {
			Stack.setChannel(j);
			run("Enhance Contrast", "saturated=0.001");
		}
		run("RGB Color", "frames slices");
		if (startsWith(imwin[i],"St")) { // (Only St and StP)
			run("Interleave", "stack_1="+imwin[i]+" stack_2="+imwin[i]); rename(imwin[i]+"_tmp");
			close(imwin[i]); selectWindow(imwin[i]+"_tmp");	rename(imwin[i]);
		}
		run("Duplicate...", " duplicate"); rename(imwin[i]+"R");
		run("Reverse");
	}
}

function applyScaleBar(w,h,pixelWidth, unit) {
	scalebar = findBestScaleBar(w,pixelWidth);
	thickness = round(0.012*h);
	font = round(0.047*h);
	run("Set Scale...", "distance="+1/pixelWidth+" known=1 unit="+unit);
	run("Scale Bar...", "width="+scalebar+" thickness="+thickness+" font="+font+" "+
						"color=White background=None location=[Lower Right] "+
						"horizontal bold label");
}

function view3D(init, tot, rot,title) {
	selectWindow("St");
	run("Duplicate...", "title=3D-tmp duplicate");
	getDimensions(w, h, nc, ns, nf);
	run("Split Channels"); mergeSTR = "";
	for (i = 1; i <= nc; i++) {
		selectImage("C"+i+"-3D-tmp");
		run("3D Project...",
			"projection=[Brightest Point] "+
			"axis=Y-Axis slice=1 "+
			"initial="+init+" total="+tot+" rotation="+rot+" "+
			"lower=1 upper=255 opacity=0 "+
			"surface=100 interior=50 interpolate");
			rename("C"+i+"-3D");
			mergeSTR = mergeSTR + "c"+i+"=C"+i+"-3D ";
	}
	run("Merge Channels...", mergeSTR+" create");
	makeRectangle(1, 0, w, h); run("Crop"); close("*tmp");
	rename(title);
}

function createProgSt() {
	// Create the progressive MIP (StP)
	selectWindow("St");
	getDimensions(w, h, nc, ns, nf);
	getPixelSize(unit, pixelWidth, pixelHeight);
	run("Duplicate...", "title=StP duplicate slices=1");
	for (i=2; i<=ns; i++) {
		selectWindow("St");
		run("Z Project...", "stop="+i+" projection=[Max Intensity]");
		wait(100); rename("MAX"); // Wait seems to be needed to avoid a bug
		run("Concatenate...", "  title=StP image1=StP image2=MAX");
	}
}
