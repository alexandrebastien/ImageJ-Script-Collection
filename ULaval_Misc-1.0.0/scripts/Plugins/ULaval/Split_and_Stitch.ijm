// Choose a directory where the images are
dir = getDirectory("Choose a Directory");
list = getFileList(dir); imList = newArray("none");
// Remove subdir and list CZI and Tiff images
for (i=0; i<list.length; i++) {
	if (!endsWith(list[i], "/")&&(endsWith(list[i], "czi")||endsWith(list[i], "tif")))
		imList = Array.concat(imList,list[i]);
}

// Choose which images are C1, C2 and C3...
Dialog.create("Select images..."); ch = 4;
for (i=1; i<=ch; i++) {
	Dialog.addChoice("C"+i, imList)}
Dialog.addChoice("Ref",newArray("1","2","3","4"));
Dialog.addCheckbox("Split", true);
Dialog.addCheckbox("Stitch", true);
Dialog.addCheckbox("Merge", true);
Dialog.show(); C = newArray(ch);
for (i=1; i<=ch; i++) {
	C[i-1] = Dialog.getChoice();}
ref = parseInt(Dialog.getChoice);
spl = Dialog.getCheckbox();
stc = Dialog.getCheckbox();
mrg = Dialog.getCheckbox();

// Set path array and get the proper number of channels (ch)
setBatchMode(true);
path = newArray;
for (i=1; i<=ch; i++) {
	if (!matches(C[i-1], "none")) {
  		path = Array.concat(path,dir + C[i-1]);}
}
ch = path.length;

// Set correct dir for temp files
splitted_dir = dir+"splitted";
stitched_dir = dir+"stitched";

// If ask for splitting
if (spl) {
	// Find best focus on ref image
	i = ref;
	run("Bio-Formats Importer",
		"open=["+path[i-1]+"] color_mode=Default concatenate_series "+
		"open_all_series rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	imID = getImageID;
	ID = findBestFocus(ref, imID);
	close("*");

	// Open the files and split them as tiffs
	File.makeDirectory(splitted_dir);
	for  (i=1; i<=ch; i++) {
		run("Bio-Formats Importer",
			"open=["+path[i-1]+"] color_mode=Default concatenate_series "+
			"open_all_series rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		imID = getImageID;
		indexZStack(ID, imID);	selectWindow("new");
		run("Image Sequence... ", "format=TIFF digits=3 name=c"+i+"_t save=["+splitted_dir+"]");
		close("*");
	}
}

// Stitch with MIST
showStatus("Stitching..."); showProgress(0.5);
if (stc) {
	XY = findTilesXY(path[0]);
	run("MIST", MISTcfg(XY,splitted_dir,stitched_dir,ref,-1));
	for  (i=1; i<=ch; i++) {
		if (i!=ref) {
			run("MIST", MISTcfg(XY,splitted_dir,stitched_dir,i,ref));}
}

// Merge stitched
showStatus("Merging..."); showProgress(0.8);
if (mrg) {
	str = "";
	for  (i=1; i<=ch; i++) {
		open(stitched_dir+"/c"+i+"-stitched-0.tif");
		rename("C"+i);
		str = str+"c"+i+"=C"+i+" ";}
	run("Merge Channels...", str+"create");
	rename(C[0]);
}
showStatus("Done"); showProgress(1);
setBatchMode(false);

////////////////////////////////////////////////////////////////////////////////////////////////////
// findTilesXY is a function that try to infer the tiles organisation in XY from a CZI tiles      //
// serie acquired with Zeiss ZEN Black 2.3. 													  //
////////////////////////////////////////////////////////////////////////////////////////////////////
function findTilesXY(path) {
	// start Bio-Formats Macro Extensions and get number of images in serie
	run("Bio-Formats Macro Extensions");
	Ext.setId(path);
	Ext.getSeriesCount(seriesCount);
	// initialize plane position pX, PY
	pX = newArray(seriesCount-1);
	pY = newArray(seriesCount-1);
	// get plane position
	for (s=1; s<seriesCount; s++) {
		Ext.setSeries(s);
		Ext.getPlanePositionX(pX[s-1],0);
		Ext.getPlanePositionY(pY[s-1],0);
	}
	// get image Size in X and Y (number of pixels)
	Ext.getSizeX(sizeX);
	Ext.getSizeY(sizeY);
	// get physical dimensions
	Ext.getPixelsPhysicalSizeX(phyX);
	Ext.getPixelsPhysicalSizeY(phyY);
	// find min/max from plane positions
	Array.getStatistics(pX, minX, maxX, mean, stdDev);
	Array.getStatistics(pY, minY, maxY, mean, stdDev);
	// get tiles overlap (t)
	field  = "Experiment|AcquisitionBlock|TilesSetup|PositionGroup|TileAcquisitionOverlap #1";
	Ext.getMetadataValue(field, t);
	// tiles serie size in Y (positions are taken in a corner)
	L = (maxY-minY)*phyY;
	// image size in Y
	l = sizeY*phyY;
	// Formula to guess tiles in Y
	Y = round((L+l-t*l)/(l-t*l)); //  <-- THIS IS THE FORMULA
	// Tiles in X are guess from total counts
	X = seriesCount/Y;
	// Export X and Y as a 2-values array
	XY = newArray(X,Y);
	return XY;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// findBestFocus is a function that try to infer the best focus out of an hyperstack. It uses an  //
// edge and a variance filter. Best Z is the highest mean filtered intensity.                     //
////////////////////////////////////////////////////////////////////////////////////////////////////
function findBestFocus(ref,imID) {
	// Get image ID, dimension info and initalize variable ID
	getDimensions(width, height, channels, slices, frames);
	ID = newArray(frames);
	// Main loop
	for (j=1; j<=frames; j++) {
		// Only duplicate channel ch, best focus will be chosen on this ref channel
		run("Duplicate...", "duplicate channels="+ref+" frames="+j);
		rename("temp");
		run("32-bit");
		// Apply the two filters
		run("Find Edges", "stack");
		run("Variance...", "radius=10 stack");
		// Get mean intensity of the filtered image
		mean = newArray(slices);
		selectImage("temp");
		for (k=1; k<=slices; k++) {
			Stack.setPosition(1, k, 1);
			getStatistics(area, mean[k-1]);
		}
		close("temp");
		meanID = Array.rankPositions(mean);
		ID[j-1] = meanID[9]+1;
		showProgress(j/frames);
	}
	wait(50);
	return ID;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// indexZStack is a function that select the array ID out of a ZStack imID image. It will make a  //
// copy of the image, do the indexing and close the original.                                     //
////////////////////////////////////////////////////////////////////////////////////////////////////
function indexZStack(ID, imID) {
	selectImage(imID);
	getDimensions(width, height, channels, slices, frames);
	// Main loop
	for (j=1; j<=frames; j++) {
		selectImage(imID);
		// Duplicate only the selected ID
		run("Duplicate...", "duplicate slices="+ID[j-1]+" frames="+j);
		// If it's not the first, concatenate with the other ones
		if (j==1) {rename("new");}
		else {
			rename("temp2");
			run("Concatenate...", "  title=new open image1=new image2=temp2");
		}
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Set default config for MIST stitching plugin with some input parameters                        //
////////////////////////////////////////////////////////////////////////////////////////////////////
function MISTcfg(XY,splitted,stitched,ch,ref) {
	// If ref is negative, it means the actual channel is the reference 
	// (we will re-use the global position files from this one.
	if (ref<0) {
		AFM = "false";
		pos = "";}
	else {
		AFM = "true";
		pos = stitched+"\\c"+d2s(ref,0)+"-global-positions-0.txt";}
				
	MISTstr = "gridwidth="+XY[0]+" gridheight="+XY[1]+" starttile=0 "+
 "imagedir=["+splitted+"] filenamepattern=c"+ch+"_t{ppp}.tif filenamepatterntype=SEQUENTIAL "+
 "gridorigin=UL assemblefrommetadata="+AFM+" globalpositionsfile=["+pos+"] "+
 "numberingpattern=HORIZONTALCOMBING startrow=0 startcol=0 extentwidth="+XY[0]+" "+
 "extentheight="+XY[1]+" timeslices=0 istimeslicesenabled=false "+
 "issuppresssubgridwarningenabled=false outputpath=["+stitched+"] displaystitching=false "+
 "outputfullimage=true outputmeta=true outputimgpyramid=false blendingmode=LINEAR blendingalpha=5.0 "+
 "outfileprefix=c"+ch+"- programtype=AUTO numcputhreads=8 loadfftwplan=true savefftwplan=true "+
 "fftwplantype=MEASURE fftwlibraryname=libfftw3 fftwlibraryfilename=libfftw3.dll "+
 "planpath=C:\\Fiji\\lib\\fftw\\fftPlans fftwlibrarypath=C:\\Fiji\\lib\\fftw stagerepeatability=0 "+
 "horizontaloverlap=NaN verticaloverlap=NaN numfftpeaks=0 overlapuncertainty=NaN "+
 "isusedoubleprecision=false isusebioformats=false isenablecudaexceptions=false "+
 "translationrefinementmethod=SINGLE_HILL_CLIMB numtranslationrefinementstartpoints=16 "+
 "headless=true loglevel=NONE debuglevel=NONE";
	return MISTstr;
}