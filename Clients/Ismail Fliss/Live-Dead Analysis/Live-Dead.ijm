// Set batchmode for faster calculation
setBatchMode(true);

// Get prom value
Dialog.create("Peak proeminence");
Dialog.addMessage("Enter the proeminence value for peaks detection.")
Dialog.addNumber("Proeminence:", 1000);
Dialog.show();
prom = Dialog.getNumber();

// Average channel 1 and 2, detect and add to ROIManager
run("Duplicate...", "title=im duplicate"); run("Split Channels");
imageCalculator("Average create", "C1-im","C1-im"); rename("avg");
run("Find Maxima...", "prominence="+prom+" strict exclude output=[Point Selection]");
roiManager("Add"); close("avg");

// Get intensities values in ch1/2 variables
run("Set Measurements...", "mean redirect=None decimal=3");
selectWindow("C1-im"); roiManager("Select", 0);
run("Measure"); ch1 = Table.getColumn("Mean");
run("Clear Results");
selectWindow("C2-im"); roiManager("Select", 0);
run("Measure"); ch2 = Table.getColumn("Mean");
run("Clear Results");
close("C1-im"); close("C2-im");
close("RoiManager");

// Set data in table
Table.setColumn("ch1", ch1);
Table.setColumn("ch2", ch2);

// Calculate the ratio
ratio = newArray(nResults);
for (i = 0; i < nResults; i++) {
	ratio[i] = ch2[i]/ch1[i];
}
Table.setColumn("ratio", ratio);

// Create a plot of ch1 vs ch2
Plot.create("Plot of Results", "ch1", "ch2");
Plot.add("Dot", Table.getColumn("ch1", "Results"), Table.getColumn("ch2", "Results"));
Plot.setStyle(0, "blue,#a0a0ff,1.0,Dot");

// Output basic stats in another table
Table.create("Summary");
Array.getStatistics(ch1, min1, max1, mean1, sd1);
Array.getStatistics(ch2, min2, max2, mean2, sd2);
Array.getStatistics(ratio, minr, maxr, meanr, sdr)
Table.setColumn("Label", newArray("min","max","mean","sd"));
Table.setColumn("ch1", newArray(min1,max1,mean1,sd1));
Table.setColumn("ch2", newArray(min2,max2,mean2,sd2));
Table.setColumn("ratio", newArray(minr,maxr,meanr,sdr));

// End
setBatchMode("exit and display");
