run("Action Bar","/plugins/ULaval/Auto-Correlation_.ijm");
exit();

<stickToImageJ>
<noGrid>

<line>
<text>AUTO-CORRELATION 
<separator>
<button>
label=Analyze
arg=autoCorrelation();
<button>
label=Config
arg=config();
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
	msg2 = "Missing: Will try to divide by 2 peaks distances. If the"+
		   "\nvalue is with some % [0-1] of the median it will keep the"+
		   "\ndivision. This is to account for missing peaks."+
		   "\n(enter -1 to skip)";
	msg3 = "Outliers: Will remove outliers distances if the value is over "+
	       "\nx times a standard deviation, normally 3. (enter -1 to skip)"
	tol = call("ij.Prefs.get", "UL.Auto-Correlation.tol", 15);
	div2pct = call("ij.Prefs.get", "UL.Auto-Correlation.div2pct", 0.1);
	cutsig = call("ij.Prefs.get", "UL.Auto-Correlation.cutsig", 3);
	Dialog.create("Auto-correlation config");
	Dialog.addNumber("Tolerance", tol);
	Dialog.addNumber("Missing", div2pct);
	Dialog.addNumber("Outliers", cutsig);
	Dialog.setInsets(5, 14, 0);
	Dialog.addMessage(msg1);
	Dialog.setInsets(0, 10, 0);
	Dialog.addMessage(msg2);
	Dialog.setInsets(0, 10, 0);
	Dialog.addMessage(msg3);
	Dialog.addHelp("https://github.com/alexandrebastien/ImageJ-Script-Collection/tree/master/ULaval/Auto-Correlation");
	Dialog.show();
	tol = Dialog.getNumber();
	div2pct = Dialog.getNumber();
	cutsig = Dialog.getNumber();
	tol = call("ij.Prefs.set", "UL.Auto-Correlation.tol", tol);
	div2pct = call("ij.Prefs.set", "UL.Auto-Correlation.div2pct", div2pct);
	cutsig = call("ij.Prefs.set", "UL.Auto-Correlation.cutsig", cutsig);
}


// Auto-Correlation main function 
function autoCorrelation() {
	
	// Check image and selection
	if (nImages == 0) exit("Please open an image first");
	selectImage(getImageID());
	if (selectionType < 5 || selectionType > 7) exit("Please make a linear selection");

	// Load config settings (peaks tolerance, find missing, remove outliers)
	tol = call("ij.Prefs.get", "UL.Auto-Correlation.tol", 25);
	div2pct = call("ij.Prefs.get", "UL.Auto-Correlation.div2pct", 0.1);
	cutsig = call("ij.Prefs.get", "UL.Auto-Correlation.cutsig", 3);
	
	// Get line profile
	p = getProfile();
	N = lengthOf(p);
	len = getValue("Length");

	// Fit linear to remove a base line
	X = Array.getSequence(N);
	Fit.doFit("y = (a*x) + b", X, p);
	a = Fit.p(0); b = Fit.p(1);
	for (i = 0; i < N; i++) p[i] = p[i] - a*X[i] - b;
	Array.getStatistics(p, min, max, mean, stdDev);
	for (i = 0; i < N; i++) p[i] = p[i]/stdDev/2;
	Plot.create("Title", "X-axis Label", "Y-axis Label", X, p);
	
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
	spacing = cutOutliers(spacing, div2pct, cutsig);
	Array.getStatistics(spacing, smin, smax, smean, sstdDev);
	
	// Get the median spacing (to avoid outliers), write to Results
	med = median(spacing);
	setResult("Image", nResults, getTitle());
	setResult("Period", nResults-1, med);
	setResult("Error", nResults-1, sstdDev);
	
	// Create the auto-correlation plot
	mu = fromCharCode(956); delta = fromCharCode(916); plusminus = fromCharCode(177);
	Plot.create("", "Lag ("+mu+"m)", "Auto-correlation (%)", lags, corr);
	Plot.add("box", peaksX, peaksCorr);
	Plot.setStyle(1, "red,red,1.0,Box");
	strmed = d2s(med,3)+" "+plusminus+" "+d2s(sstdDev,3);
	Plot.addLegend("Auto-correlation\n"+delta+" = "+strmed+" "+mu+"m", "Top-Right");
	Plot.show();
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
	x = Array.copy(y);
	x = Array.sort(x);
	if (x.length%2>0.5) m=x[floor(x.length/2)];
	else m=(x[x.length/2]+x[x.length/2-1])/2;
	return m
}

function cutOutliers(x,div2pct,cutsig) {
	// Divide by 2 large values to account for missing peaks
	if (div2pct > 0) {
		div2pct = 0.1; cutsig = 3;
		xmed = median(x); low = xmed - xmed*div2pct; high = xmed + xmed*div2pct;
		y = newArray;
		for (i = 0; i < lengthOf(x); i++) {
			if ((x[i]/2 > low) && (x[i]/2 < high)) y[i] = x[i]/2;
			else y[i] = x[i];
		}
	} else {y = Array.copy(x);}
	
	// Remove remaining outliers
	if (cutsig > 0) {
		Array.getStatistics(y, ymin, ymax, ymean, ystd);
		z = newArray; j = 0;
		for (i = 0; i < lengthOf(y); i++) {
			if ((y[i] < (ymean + cutsig*ystd)) && (y[i] > (ymean - cutsig*ystd))) {
				z[j] = y[i]; j = j + 1;
			}
		}
	} else {z = Array.copy(y);}
	return z;
}
</codeLibrary>