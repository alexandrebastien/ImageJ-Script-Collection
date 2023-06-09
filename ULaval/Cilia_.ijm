run("Action Bar","/plugins/ULaval/Cilia_.ijm");
exit();

<stickToImageJ>
<noGrid>

<startupAction>
call("ij.Prefs.set", "ma_config.pt",1);
call("ij.Prefs.set", "ma_config.zm",100);
</startupAction>

<line>
// === OPEN BUTTON ===
<button>
label=Open
arg=Open_Results();

// === BACK BUTTON ===
<button>
label=Prev
arg=back();

// === FORWARD BUTTON ===
<button>
label=Next
arg=forward();

<separator>
<text> Zoom
// === ZOOM IN BUTTON ===
<button>
label=+
arg=zoomIn();

// === ZOOM OUT BUTTON ===
<button>
label=-
arg=zoomOut();

<separator>
<text> Categories
// === B BUTTON ===
<button>
label=B
arg=basale();

// === M BUTTON ===
<button>
label=M
arg=musculaire();

// === X BUTTON ===
<button>
label=X
arg=deleteCilia();

<separator>
<text> 
<button>
label=Close
arg=<close>

</line>
// end of file

<codeLibrary>

// === OPEN BUTTON ===
function Open_Results() {
     requires("1.35r");
     lineseparator = "\n";
     cellseparator = ",\t";
     
	 // define array for points
	 var xpoints = newArray;
	 var ypoints = newArray; 

     // copies the whole RT to an array of lines
     lines=split(File.openAsString(""), lineseparator);

     // recreates the columns headers
     labels=split(lines[0], cellseparator);
     if (labels[0]==" "){
        k=1; // it is an ImageJ Results table, skip first column
     }
     else {
        k=0; // it is not a Results table, load all columns
     }
     for (j=k; j<labels.length; j++) {
        setResult(labels[j],0,0);
        if (matches(labels[j],"x") || matches(labels[j],"X"))
        	iX = j;
        if (matches(labels[j],"y") || matches(labels[j],"Y"))
        	iY = j;
     }
     // dispatches the data into the new RT
     run("Clear Results");
     for (i=1; i<lines.length; i++) {
        items=split(lines[i], cellseparator);
     	setOption("ExpandableArrays", true);   
   		xpoints[i-1] = parseInt(items[iX]);
   		ypoints[i-1] = parseInt(items[iY]);
        for (j=k; j<items.length; j++)
           setResult(labels[j],i-1,items[j]);
     }
     updateResults();
     // show the points in the image
	 makeSelection("point", xpoints, ypoints); 
}

// === BACK BUTTON ===
function back() {
	// Get pt and zm
	pt = parseInt(call("ij.Prefs.get", "ma_config.pt",1));
	zm = parseFloat(call("ij.Prefs.get", "ma_config.zm",100));
	
	// Make pt -1
	pt = pt - 1;
	if (pt==0) {pt = 1;}

	// Get ctg (category), and position x y
	ctg = getResultString("category",pt-1);
	x = getResult("x",pt-1); y = getResult("y",pt-1);	

	// Update status, zoom, position and label
	showText("Current cilium", "Cilium #: "+ pt + "\n" + "Cell type: " + ctg);
	run("Set... ", "zoom="+zm+" x="+x+" y="+y);
	run("Point Tool...", "type=Hybrid color=Magenta size=Large label");
	//makePoint(x, y);
	
	// Update pt and zm
	call("ij.Prefs.set", "ma_config.pt",pt);
	call("ij.Prefs.set", "ma_config.zm",zm);
}

// === FORWARD BUTTON ===
function forward() {
	// Get pt and zm
	pt = parseInt(call("ij.Prefs.get", "ma_config.pt",1));
	zm = parseFloat(call("ij.Prefs.get", "ma_config.zm",100));
	
	// Make pt +1
	pt = pt + 1;
	if (pt>=getValue("results.count")) {pt = getValue("results.count");}

	// Get ctg (category), and position x y
	ctg = getResultString("category",pt-1);
	x = getResult("x",pt-1); y = getResult("y",pt-1);	

	// Update status, zoom, position and label
	showText("Current cilium", "Cilium #: "+ pt + "\n" + "Cell type: " + ctg);
	run("Set... ", "zoom="+zm+" x="+x+" y="+y);
	run("Point Tool...", "type=Hybrid color=Magenta size=Large label");
	//makePoint(x, y);
	
	// Update pt and zm
	call("ij.Prefs.set", "ma_config.pt",pt);
	call("ij.Prefs.set", "ma_config.zm",zm);
}

// === ZOOM IN BUTTON ===
function zoomIn() {
	// Get pt and zm
	pt = parseInt(call("ij.Prefs.get", "ma_config.pt",1));
	zm = parseFloat(call("ij.Prefs.get", "ma_config.zm",100));
	
	// Make zm x 1.5
	zm = zm*1.5;

	// Get ctg (category), and position x y
	ctg = getResultString("category",pt-1);
	x = getResult("x",pt-1); y = getResult("y",pt-1);	

	// Update status, zoom, position and label
	showText("Current cilium", "Cilium #: "+ pt + "\n" + "Cell type: " + ctg);
	run("Set... ", "zoom="+zm+" x="+x+" y="+y);
	run("Point Tool...", "type=Hybrid color=Magenta size=Large label");
	//makePoint(x, y);

	//Make sure zoom is not too much
	zm = getZoom*100;
	
	// Update pt and zm
	call("ij.Prefs.set", "ma_config.pt",pt);
	call("ij.Prefs.set", "ma_config.zm",zm);
}

// === ZOOM OUT BUTTON ===
function zoomOut() {
	// Get pt and zm
	pt = parseInt(call("ij.Prefs.get", "ma_config.pt",1));
	zm = parseFloat(call("ij.Prefs.get", "ma_config.zm",100));
	
	// Make zm x 1.5
	zm = zm*0.75;

	// Get ctg (category), and position x y
	ctg = getResultString("category",pt-1);
	x = getResult("x",pt-1); y = getResult("y",pt-1);	

	// Update status, zoom, position and label
	showText("Current cilium", "Cilium #: "+ pt + "\n" + "Cell type: " + ctg);
	run("Set... ", "zoom="+zm+" x="+x+" y="+y);
	run("Point Tool...", "type=Hybrid color=Magenta size=Large label");
	//makePoint(x, y);

	//Make sure zoom is not too much
	zm = getZoom*100;
	
	// Update pt and zm
	call("ij.Prefs.set", "ma_config.pt",pt);
	call("ij.Prefs.set", "ma_config.zm",zm);
}

// === B BUTTON ===
function basale() {
	pt = parseInt(call("ij.Prefs.get", "ma_config.pt",1));
	ctg = "B";
	setResult("category", pt-1, ctg)
	showText("Current cilium", "Cilium #: "+ pt + "\n" + "Cell type: " + ctg);
}

// === M BUTTON ===
function musculaire() {
	pt = parseInt(call("ij.Prefs.get", "ma_config.pt",1));
	ctg = "M";
	setResult("category", pt-1, ctg)
	showText("Current cilium", "Cilium #: "+ pt + "\n" + "Cell type: " + ctg);
}

// === X BUTTON ===
function deleteCilia() {
	pt = parseInt(call("ij.Prefs.get", "ma_config.pt",1));
	ctg = "X";
	setResult("category", pt-1, ctg)
	showText("Current cilium", "Cilium #: "+ pt + "\n" + "Cell type: " + ctg);
}

</codeLibrary>
