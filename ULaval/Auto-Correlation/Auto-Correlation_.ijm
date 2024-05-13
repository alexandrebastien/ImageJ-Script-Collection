run("Action Bar","/plugins/ULaval/Auto-Correlation_.ijm");
exit();

<stickToImageJ>
<noGrid>

<line>
<text>AUTO-CORRELATION 
<separator>
<button>
label=Analyze
arg=autoCorrelation("","");
<button>
label=Config
arg=config();
<button>
label=batch
arg=batchAutoCorr();
<button>
label=Help
arg=exec("open", "https://github.com/alexandrebastien/ImageJ-Script-Collection/tree/master/ULaval/Auto-Correlation");;
<button>
label=x
arg=<close>
</line>

<codeLibrary>
// === MOVE THIS LINE TO 103 FOR DEBUGGING (+100 on calls) ===
// Set options for the session
setOption("ExpandableArrays", true);

function config() {	
	// Dialog window for the options
	msg1 = "Tolerance: The minimum amplitude needed to find a peak.";
	msg2 = "Outliers: Will remove outliers distances if the value is over "+
	       "\nx times the median absolute deviation, normally 3. (enter -1 to skip)"
	tol = call("ij.Prefs.get", "UL.Auto-Correlation.tol", 15);
	cutsig = call("ij.Prefs.get", "UL.Auto-Correlation.cutsig", 3);
	Dialog.create("Auto-correlation config");
	Dialog.addNumber("Tolerance", tol);
	Dialog.addNumber("Outliers", cutsig);
	Dialog.setInsets(5, 14, 0);
	Dialog.addMessage(msg1);
	Dialog.setInsets(0, 10, 0);
	Dialog.addMessage(msg2);
	Dialog.addHelp("https://github.com/alexandrebastien/ImageJ-Script-Collection/tree/master/ULaval/Auto-Correlation");
	Dialog.show();
	tol = Dialog.getNumber();
	cutsig = Dialog.getNumber();
	tol = call("ij.Prefs.set", "UL.Auto-Correlation.tol", tol);
	cutsig = call("ij.Prefs.set", "UL.Auto-Correlation.cutsig", cutsig);
}


function batchAutoCorr() {
	ID = getImageID();
	path = "C:\\autocorr";
	n = roiManager("count");
	for (i = 0; i < n; i++) {
		selectImage(ID);
	    roiManager("select", i);
	    name = Roi.getName();
	    nameAR = split(name, ",");
	    num = nameAR[0];
	    tol = nameAR[1];
	    cutsig = nameAR[2];
	    autoCorrelation(tol,cutsig);
	    saveAs("tiff", path+"\\"+num); close();
	}
}

// Auto-Correlation main function 
function autoCorrelation(tol,cutsig) {
	
	// Check image and selection
	if (nImages == 0) exit("Please open an image first");
	selectImage(getImageID()); getPixelSize(unit, w, h);
	if (selectionType < 5 || selectionType > 7)
		exit("Please make a linear selection");

	// Load config settings (peaks tolerance, remove outliers)
	if(tol == "")
		tol = call("ij.Prefs.get", "UL.Auto-Correlation.tol", 25);
	if(cutsig == "")
		cutsig = call("ij.Prefs.get", "UL.Auto-Correlation.cutsig", 3);
	
	// Get line profile
	p = getProfile(); N = lengthOf(p);
	len = getValue("Length");

	// Fit linear to remove a base line
	X = Array.getSequence(N);
	Fit.doFit("y = (a*x) + b", X, p);
	a = Fit.p(0); b = Fit.p(1);
	for (i = 0; i < N; i++) p[i] = p[i] - a*X[i] - b;
	Array.getStatistics(p, min, max, mean, stdDev);
	for (i = 0; i < N; i++) p[i] = p[i]/stdDev/2;
	
	// Auto-correlation
	corr = newArray(2*N-1); lags = newArray(2*N-1); i = 0;
	for (lag = -1*N+1; lag <= N-1; lag++) {
		n = N - abs(lag); lags[i] = lag/(N-1)*len; i++;
		if(lag  < 0) corr[i] = sumProd(abs(lag),0,n,p);
		if(lag >= 0) corr[i] = sumProd(0,abs(lag),n,p);
	}
	
	// Normalize correlation at 100%
	Array.getStatistics(corr, minCorr, maxCorr, meanCorr, stdDevCorr);
	for (i = 0; i < 2*N-1; i++) corr[i] = corr[i]/maxCorr*100;
	
	// Finds peaks and their positions
	peaks = Array.findMaxima(corr, tol);
	peaksCorr = newArray(lengthOf(peaks));
	peaksX = newArray(lengthOf(peaks));
	for (i = 0; i < lengthOf(peaks); i++) {
		peaksCorr[i] = corr[peaks[i]];
		peaksX[i] = lags[peaks[i]];
	}
	
	// Sort peaks by X (not Y) and get the spacing between them
	sortedpeaksX = Array.sort(Array.copy(peaksX));
	spacing = newArray(lengthOf(sortedpeaksX)-1);
	for (i = 0; i < lengthOf(sortedpeaksX)-1; i++) {
		spacing[i] = sortedpeaksX[i+1]-sortedpeaksX[i];
	}

	// Remove outlier and fix missing peaks
	y = Array.copy(spacing); ymed = median(y); ymad = MAD(y);
	if (cutsig > 0)
		for (i = 0; i < lengthOf(y); i++)
			if (!((y[i] < (ymed + cutsig*ymad)) &&
				  (y[i] > (ymed - cutsig*ymad))))
				y[i] = NaN;
				
	// Remove NaNs for stats
	z = Array.deleteValue(y, NaN);
	Array.getStatistics(z, smin, smax, smean, sstdDev);
	Array.getStatistics(corr, cmin, cmax, cmean, cstd);
	
	// Get the median spacing (to avoid outliers), write to Results
	med = median(spacing);
	setResult("Image", nResults, getTitle());
	setResult("Period", nResults-1, smean);
	setResult("Error", nResults-1, sstdDev);
	setResult("Tolerance", nResults-1, tol);
	setResult("Outliers", nResults-1, cutsig);

	// Get weird characters
	mu = fromCharCode(956);
	delta = fromCharCode(916);
	plusminus = fromCharCode(177);
	if (unit == "microns") {unit = ""+mu+"m";}
	
	// Create the auto-correlation plot
	Plot.create("Auto-Correlation", "Lag ("+unit+")", "Auto-correlation (%)", lags, corr);
	Plot.add("box", peaksX, peaksCorr);
	Plot.setStyle(1, "red,red,1.0,Box");
	Plot.add("cross", peaksX, Array.fill(newArray(lengthOf(peaksX)), cmin));
	for (i = 0; i < lengthOf(y); i++)
		if(!isNaN(y[i]))
			Plot.drawLine(sortedpeaksX[i], cmin, sortedpeaksX[i+1], cmin);
	Plot.addLegend("Auto-correlation\n"+
				   delta+" = "+d2s(smean,3)+" "+plusminus+" "+
				   d2s(sstdDev,3)+" "+unit, "Top-Right");
	Plot.show();
	
	// Hi-Res
	Plot.makeHighResolution("HIRES",4.0);
	run("Scale...", "x=0.5 y=0.5 interpolation=Bilinear average create");
	rename("HIRES2"); close("Auto-Correlation"); close("HIRES");
	//close(); close("Auto-Correlation");
}

// Partial sum of product for auto-correlation
//   a,b: starting index for array 1,2
//   n: length of sub-array
//   p: array used for the sum prod 
function sumProd(a,b,n,p) {
	sum = 0;
	for (i = 0; i < n; i++) sum = sum + p[i+a]*p[i+b];
	return sum;
}

// Median calculation of an array
function median(y) {
	if(lengthOf(y)==0) return "";
	x = Array.copy(y); x = Array.sort(x);
	if (x.length%2>0.5) m=x[floor(x.length/2)];
	else m=(x[x.length/2]+x[x.length/2-1])/2;
	return m
}

// Median absolute deviation
function MAD(x) {
	med = median(x); dev = newArray(lengthOf(x));
	for (i = 0; i < lengthOf(x); i++) dev[i] = abs(x[i]-med);
	madval = median(dev); return madval;
}
</codeLibrary>
