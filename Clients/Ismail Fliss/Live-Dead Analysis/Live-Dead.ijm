// Set batchmode for faster calculation
setBatchMode(true);
getDimensions(w, h, cc, s, ff);
labels = newArray(ff);
for (f = 1; f <= ff; f++) {
	Stack.setPosition(1, 1, f);
	labels[f-1] = getInfo("slice.label");
}

// Get prom value
url = "https://github.com/alexandrebastien/ImageJ-Script-Collection/tree/master/Clients/Ismail%20Fliss/Live-Dead%20Analysis";
Dialog.create("Peak proeminence");
Dialog.addMessage("Enter the proeminence value for peaks detection.");
Dialog.addNumber("Proeminence:", 1000);
Dialog.addHelp(url);
Dialog.show();
prom = Dialog.getNumber();

title = getTitle();
run("Duplicate...", "title=im-c1 duplicate channels=1");
selectWindow(title);
run("Duplicate...", "title=im-c2 duplicate channels=2");
imageCalculator("Max create stack", "im-c1","im-c2"); rename("max");
run("Merge Channels...", "c1=im-c1 c2=im-c2 c3=max create");
rename("im"); run("Gaussian Blur...", "sigma=1 stack");


sum1 = newArray(); sum2 = newArray();
sumR = newArray(); sumL = newArray();
for (f = 1; f <= ff; f++) {
	selectWindow("im");
	Stack.setPosition(3, 1, f);
	run("Find Maxima...", "prominence="+prom+
	    " strict exclude output=[Point Selection]");
	Roi.getCoordinates(x, y);
	
	Stack.setPosition(1, 1, f);
	lx = lengthOf(x); ch1 = newArray(lx);
	for (i = 0; i < lx; i++) {ch1[i] = getValue(x[i], y[i]);}

	Stack.setPosition(2, 1, f);
	lx = lengthOf(x); ch2 = newArray(lx);
	for (i = 0; i < lx; i++) {ch2[i] = getValue(x[i], y[i]);}	

	ratio = newArray(lx);
	for (i = 0; i < lx; i++) {ratio[i] = ch2[i]/ch1[i];}
	
	L = Array.fill(newArray(lx), f);
	
	sumL = Array.concat(sumL,L);
	sum1 = Array.concat(sum1,ch1);
	sum2 = Array.concat(sum2,ch2);
	sumR = Array.concat(sumR,ratio);

	// Create a plot of ch1 vs ch2
	Plot.create(labels[f-1], "ch1", "ch2");
	Plot.add("Dot", ch1, ch2);
	Plot.setStyle(0, "blue,#a0a0ff,1.0,Dot");
	Plot.show();
}
close("im");

Table.create("Data");
Table.setColumn("Label", sumL);
Table.setColumn("ch1", sum1);
Table.setColumn("ch2", sum2);
Table.setColumn("ratio", sumR);


setBatchMode("exit and display");
