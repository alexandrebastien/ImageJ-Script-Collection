/* 3D ANIMATOR 
 * ¯¯¯¯¯¯¯¯¯¯¯
 * 3D Animator is an ImageJ macro that creates a 3D animation and a maximum
 * intensity projection image from a microscopy fluorescence Z-Stack. The 
 * program runs in batch mode, asking for a folder, and doing all stacks in
 * that folder. It creates 2 sub-folders named 3D and MIP with the results.
 * The animation goes through the Z-Stack, then progressively creates an MIP,
 * then rotates the full projection 45° left and right before unfolding back
 * into the first Z-Stack image.
 * 
 * AUTHOR  : Alexandre Bastien, Copyright (c) 2018
 * EMAIL   : alexandre.bastien@fsaa.ulaval.ca 
 * LICENSE : Licensed under MIT License, see file LICENSE
 */

// Runs in Batch Mode
setBatchMode(false);

// User select folder and subfolder are created
dir = getDirectory("Choose input directory"); list = getFileList(dir);
File.makeDirectory(dir+"MIP");
File.makeDirectory(dir+"3D");

// Main loop for batch processing
for (ii=0; ii<list.length; ii++) {
	// Avoid other subdirectories
	if (!endsWith(list[ii], "/")) {
		
		// Print status, open file, get file name, rename window
		print("Analyzing "+ii+1+"/"+list.length);
		run("Bio-Formats Importer", "open=["+dir+list[ii]+"] autoscale color_mode=Composite "+
			"view=Hyperstack stack_order=XYCZT");
	    filename = File.nameWithoutExtension(); rename("St");
	
	    // Create MIP and save as JPG
		run("Z Project...", "projection=[Max Intensity]");
		save(dir+"MIP/"+filename+".jpg"); close;
	
		// Create the progressive MIP (StP)
		selectWindow("St"); getDimensions(w, h, nc, ns, nf); // Get dim, for later use
		run("Duplicate...", "title=StP duplicate slices=1");
		for (i=2; i<=ns; i++) {
			selectWindow("St");
			run("Z Project...", "stop="+i+" projection=[Max Intensity]");
			wait(300); rename("MAX"); // Wait seems to be needed to avoid a bug
			run("Concatenate...", "  title=StP image1=StP image2=MAX");
		}
	
		// Create left 3D animation
		selectWindow("St");
		if(nf>ns){run("Re-order Hyperstack ...", "channels=[Channels (c)] slices=[Frames (t)] frames=[Slices (z)]")};
		run("3D Project...", "projection=[Brightest Point] axis=Y-Axis slice=1 initial=0 "+
			"total=45 rotation=1 lower=1 upper=255 opacity=0 surface=100 interior=50 interpolate");
		wait(300);
		rename("3D-1"); makeRectangle(0, 0, w, h); run("Crop");
			// Crop is needed as animation is a bit larger

		// Create right 3D animation
		selectWindow("St");
		run("3D Project...", "projection=[Brightest Point] axis=Y-Axis slice=1 initial=315 "+
			"total=44 rotation=1 lower=1 upper=255 opacity=0 surface=100 interior=50 interpolate");
		wait(300);
		rename("3D-2"); makeRectangle(0, 0, w, h); run("Crop");

		// Convertion from slice to time frame of the main stack (St)
		// is needed for later concatenate
		selectWindow("St");
		run("Re-order Hyperstack ...", "channels=[Channels (c)] slices=[Frames (t)] frames=[Slices (z)]");

		// For all 4 opened images:
		//	Enhance contraste in a standardize way
		//	Convert to RGB type
		//	Interleave (doubles frames) to slow down (St and StP only)
		//	Create the reverse images for rewind effect
		imwin = getList("image.titles");
		for (i=0; i<lengthOf(imwin); i++) {
			selectWindow(imwin[i]);
			for (j=1; j<=nc; j++) {
				Stack.setChannel(j);
				for( k = 0; k < ns; k++) {
				    setSlice(k+1);
				    run("Enhance Contrast", "saturated=4 normalize");
				}
				//run("Enhance Contrast", "saturated=0.01");
			}
			run("RGB Color", "frames");
			if (startsWith(imwin[i],"St")) { // (Only St and StP)
				run("Interleave", "stack_1="+imwin[i]+" stack_2="+imwin[i]); rename(imwin[i]+"_tmp");
				close(imwin[i]); selectWindow(imwin[i]+"_tmp");	rename(imwin[i]);
			}
			run("Duplicate...", "title="+imwin[i]+"R duplicate"); wait(300);
			run("Reverse"); wait(300);
		}
		
		// Concatenate the full animation, save as AVI and close
		run("Concatenate...", "  title=[3D] image1=St image2=StR image3=StP "+
			"image4=3D-1 image5=3D-1R image6=3D-2R image7=3D-2 image8=StPR");
		run("AVI... ", "compression=JPEG frame=15 save=["+dir+"3D/"+filename+".avi]");
		close("*");
		
	}
}
print("Finished");
setBatchMode(false); // out of batch mode