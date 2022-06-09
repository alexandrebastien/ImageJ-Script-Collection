// Set batchmode for faster calculation
run("ROI Manager...");
setBatchMode(true);

// Get prom value
url = "https://github.com/alexandrebastien/ImageJ-Script-Collection/tree/master/Clients/Ismail%20Fliss/Live-Dead%20Analysis";
Dialog.create("Peak proeminence");
Dialog.addMessage("Enter the proeminence value for peaks detection.");
Dialog.addNumber("Proeminence:", 5000);
Dialog.addNumber("Saturation:", 0.05);
Dialog.addNumber("Blur:", 4);
Dialog.addCheckbox("Data", true);
Dialog.addCheckbox("Plots", true);
Dialog.addHelp(url);
Dialog.show();

prom = Dialog.getNumber();
satu = Dialog.getNumber(); 
blur = Dialog.getNumber(); 
data = Dialog.getCheckbox();
plot = Dialog.getCheckbox();

// Get dimension and labels
getDimensions(w, h, cc, s, ff);
labels = newArray(ff);
for (f = 1; f <= ff; f++) {
	Stack.setPosition(1, 1, f);
	labels[f-1] = getInfo("slice.label");
}

// Create duplicate and merge channel to find maxima
title = getTitle();
c1str = ""; c2str = ""; c3str = "";
for (f = 1; f <= ff; f++) {
	selectWindow(title);
	run("Duplicate...", "title=c1f"+f+" duplicate channels=1 frames="+f);
	run("Enhance Contrast...", "saturated="+satu);
	run("Apply LUT");
	
	selectWindow(title);
	run("Duplicate...", "title=c2f"+f+" duplicate channels=2 frames="+f);
	run("Enhance Contrast...", "saturated="+satu);
	run("Apply LUT");
	
	imageCalculator("Max create", "c1f"+f,"c2f"+f); rename("c3f"+f);
	
	c1str = c1str+" image"+f+"=["+"c1f"+f+"]";
	c2str = c2str+" image"+f+"=["+"c2f"+f+"]";
	c3str = c3str+" image"+f+"=["+"c3f"+f+"]";
}
run("Concatenate...", "title=c4 "+c1str);
run("Concatenate...", "title=c5 "+c2str);
run("Concatenate...", "title=c3 "+c3str);
selectWindow(title); run("Duplicate...", "title=c1 duplicate channels=1");
selectWindow(title); run("Duplicate...", "title=c2 duplicate channels=2");


run("Merge Channels...", "c1=c4 c2=c5 create keep");
run("RGB Color", "slices");
for (f = 1; f <= ff; f++) {
	Stack.setPosition(1, f, 1);
	run("Set Label...", "label=["+labels[f-1]+"]");	
}
rename("enhanced");

run("Merge Channels...", "c1=c1 c2=c2 c3=c3 c4=c4 c5=c5 create");
run("Gaussian Blur...", "sigma="+blur+" stack");
rename("im");


sum1 = newArray(); sum2 = newArray();
sumR = newArray(); sumL = newArray();

max1 = 0; max2 = 0; min1 = 65535; min2 = 65535;
for (f = 1; f <= ff; f++) {
	Stack.setPosition(1, 1, f);
	getRawStatistics(nPixels, mean, min, max, std, histogram);
	if (max > max1) {max1 = max;}
	if (min < min1) {min1 = min;}
	Stack.setPosition(2, 1, f);
	getRawStatistics(nPixels, mean, min, max, std, histogram);
	if (max > max2) {max2 = max;}
	if (min < min2) {min2 = min;}
}

catstr = "";
dead = Array.fill(newArray(ff),0);
edead = Array.fill(newArray(ff),0);
count = Array.fill(newArray(ff),0);


roiManager("reset");
for (f = 1; f <= ff; f++) {
	selectWindow("im");
	Stack.setPosition(3, 1, f);
	run("Find Maxima...", "prominence="+prom+
	    " strict exclude output=[Point Selection]");
	Roi.getCoordinates(x, y);
	roiManager("add");
	
	Stack.setPosition(1, 1, f);
	lx = lengthOf(x); ch1 = newArray(lx);
	for (i = 0; i < lx; i++) {ch1[i] = getValue(x[i], y[i]);}

	Stack.setPosition(2, 1, f);
	lx = lengthOf(x); ch2 = newArray(lx);
	for (i = 0; i < lx; i++) {ch2[i] = getValue(x[i], y[i]);}	

	Stack.setPosition(4, 1, f);
	lx = lengthOf(x); ch4 = newArray(lx);
	for (i = 0; i < lx; i++) {ch4[i] = getValue(x[i], y[i]);}	
	
	Stack.setPosition(5, 1, f);
	lx = lengthOf(x); ch5 = newArray(lx);
	for (i = 0; i < lx; i++) {ch5[i] = getValue(x[i], y[i]);}

	ratio = newArray(lx);
	for (i = 0; i < lx; i++) {ratio[i] = ch2[i]/ch1[i];}
	
	dead[f-1] = 0; edead[f-1] = 0; count[f-1] = lx;
	for (i = 0; i < lx; i++) {
		if(ch1[i] < ch2[i]) {dead[f-1] = dead[f-1] + 1;}
		if(ch4[i] < ch5[i]) {edead[f-1] = edead[f-1] + 1;}
	}
	
	L = Array.fill(newArray(lx), f);
	
	sumL = Array.concat(sumL,L);
	sum1 = Array.concat(sum1,ch1);
	sum2 = Array.concat(sum2,ch2);
	sumR = Array.concat(sumR,ratio);

	// Create a plot of ch1 vs ch2
	if(plot) {
		Plot.create(labels[f-1], "ch1", "ch2");
		Plot.add("Dot", ch1, ch2);
		Plot.setStyle(0, "blue,#a0a0ff,1.0,Dot");
		Plot.setLimits(min1, max1, min2, max2)
		Plot.show(); Plot.makeHighResolution(labels[f-1],4.0);
		catstr = catstr+" image"+f+"=["+labels[f-1]+"]";
	}
}

if(plot) {
	run("Concatenate...", "title=tmp "+catstr);
	rename("plots");
	for (f = 1; f <= ff; f++) {
		Stack.setPosition(1, f, 1);
		run("Set Label...", "label=["+labels[f-1]+"]");	
	}
}

for (f = 1; f <= ff; f++) {close(labels[f-1]);}
close("im");

if(data) {
	Table.create("Data");
	Table.setColumn("Label", sumL);
	Table.setColumn("ch1", sum1);
	Table.setColumn("ch2", sum2);
	Table.setColumn("ratio", sumR);
}

	Table.create("Summary")
	Table.setColumn("label", labels);
	Table.setColumn("count", count);
	Table.setColumn("edead", edead);
	Table.setColumn("dead", dead);

setBatchMode("exit and display");
