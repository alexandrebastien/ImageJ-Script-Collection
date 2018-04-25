path=File.openDialog("Select a File");
name = File.getName(path);
spDir = File.getParent(path)+File.separator+name+"_splitted";
stDir = File.getParent(path)+File.separator+name+"_stitched";
File.makeDirectory(spDir); File.makeDirectory(stDir);

Dialog.create("Config");
Dialog.addNumber("X", 10) 
Dialog.addNumber("Y", 10) 
Dialog.show();
X = Dialog.getNumber();
Y = Dialog.getNumber();

setBatchMode(true);

run("Bio-Formats Importer", "open=["+path+"] color_mode=Default view=Hyperstack stack_order=XYCZT series_"+600);

// Get M
infoString=getMetadata("Info");
strPos=indexOf(infoString,"Information|Image|SizeM #1");
str=substring(infoString,strPos,strPos+100);
retPos=indexOf(str,"\n");
equalPos=indexOf(str,"=");
str=substring(infoString,strPos+equalPos+2,strPos+retPos);
M = str;
close("*");

for (i=1; i<=M; i++) {
	run("Bio-Formats Importer", "open=["+path+"] color_mode=Default view=Hyperstack stack_order=XYCZT series_"+i); wait(10);
	rename("im");
	showProgress(-i/M);
	run("Split Channels");
	selectWindow("C1-im");
	run("Z Project...", "projection=[Max Intensity]");
	selectWindow("C2-im");
	run("Z Project...", "projection=[Max Intensity]");
	selectWindow("C3-im");
	run("Z Project...", "projection=[Max Intensity]");
	selectWindow("MAX_C1-im");
	saveAs("Tiff", spDir+"/im_T"+IJ.pad(i-1, 3)+"_ch00.tif");
	selectWindow("MAX_C2-im");
	saveAs("Tiff", spDir+"/im_T"+IJ.pad(i-1, 3)+"_ch01.tif");
	selectWindow("MAX_C3-im");
	saveAs("Tiff", spDir+"/im_T"+IJ.pad(i-1, 3)+"_ch02.tif");
	close("*");
}

run("MIST", "gridwidth="+X+" gridheight="+Y+" starttile=0 imagedir="+spDir+" filenamepattern=im_T{ppp}_ch00.tif filenamepatterntype=SEQUENTIAL gridorigin=UL assemblefrommetadata=false globalpositionsfile=[] numberingpattern=HORIZONTALCOMBING startrow=0 startcol=0 extentwidth="+X+" extentheight="+Y+" timeslices=0 istimeslicesenabled=false issuppresssubgridwarningenabled=false outputpath="+stDir+" displaystitching=false outputfullimage=true outputmeta=true outputimgpyramid=false blendingmode=LINEAR blendingalpha=5.0 outfileprefix=ch00- programtype=AUTO numcputhreads=8 loadfftwplan=true savefftwplan=true fftwplantype=MEASURE fftwlibraryname=libfftw3 fftwlibraryfilename=libfftw3.dll planpath=C:\\Fiji\\lib\\fftw\\fftPlans fftwlibrarypath=C:\\Fiji\\lib\\fftw stagerepeatability=0 horizontaloverlap=NaN verticaloverlap=NaN numfftpeaks=0 overlapuncertainty=NaN isusedoubleprecision=false isusebioformats=false isenablecudaexceptions=false translationrefinementmethod=SINGLE_HILL_CLIMB numtranslationrefinementstartpoints=16 headless=false loglevel=MANDATORY debuglevel=NONE");
run("MIST", "gridwidth="+X+" gridheight="+Y+" starttile=0 imagedir="+spDir+" filenamepattern=im_T{ppp}_ch01.tif filenamepatterntype=SEQUENTIAL gridorigin=UL assemblefrommetadata=true globalpositionsfile="+stDir+"\\ch00-global-positions-0.txt numberingpattern=HORIZONTALCOMBING startrow=0 startcol=0 extentwidth="+X+" extentheight="+Y+" timeslices=0 istimeslicesenabled=false issuppresssubgridwarningenabled=false outputpath="+stDir+" displaystitching=false outputfullimage=true outputmeta=true outputimgpyramid=false blendingmode=LINEAR blendingalpha=5.0 outfileprefix=ch01- programtype=AUTO numcputhreads=8 loadfftwplan=true savefftwplan=true fftwplantype=MEASURE fftwlibraryname=libfftw3 fftwlibraryfilename=libfftw3.dll planpath=C:\\Fiji\\lib\\fftw\\fftPlans fftwlibrarypath=C:\\Fiji\\lib\\fftw stagerepeatability=0 horizontaloverlap=NaN verticaloverlap=NaN numfftpeaks=0 overlapuncertainty=NaN isusedoubleprecision=false isusebioformats=false isenablecudaexceptions=false translationrefinementmethod=SINGLE_HILL_CLIMB numtranslationrefinementstartpoints=16 headless=false loglevel=MANDATORY debuglevel=NONE");
run("MIST", "gridwidth="+X+" gridheight="+Y+" starttile=0 imagedir="+spDir+" filenamepattern=im_T{ppp}_ch02.tif filenamepatterntype=SEQUENTIAL gridorigin=UL assemblefrommetadata=true globalpositionsfile="+stDir+"\\ch00-global-positions-0.txt numberingpattern=HORIZONTALCOMBING startrow=0 startcol=0 extentwidth="+X+" extentheight="+Y+" timeslices=0 istimeslicesenabled=false issuppresssubgridwarningenabled=false outputpath="+stDir+" displaystitching=false outputfullimage=true outputmeta=true outputimgpyramid=false blendingmode=LINEAR blendingalpha=5.0 outfileprefix=ch02- programtype=AUTO numcputhreads=8 loadfftwplan=true savefftwplan=true fftwplantype=MEASURE fftwlibraryname=libfftw3 fftwlibraryfilename=libfftw3.dll planpath=C:\\Fiji\\lib\\fftw\\fftPlans fftwlibrarypath=C:\\Fiji\\lib\\fftw stagerepeatability=0 horizontaloverlap=NaN verticaloverlap=NaN numfftpeaks=0 overlapuncertainty=NaN isusedoubleprecision=false isusebioformats=false isenablecudaexceptions=false translationrefinementmethod=SINGLE_HILL_CLIMB numtranslationrefinementstartpoints=16 headless=false loglevel=MANDATORY debuglevel=NONE");

open(stDir+"/ch00-stitched-0.tif");
open(stDir+"/ch01-stitched-0.tif");
open(stDir+"/ch02-stitched-0.tif");
run("Merge Channels...", "c1=ch01-stitched-0.tif c2=ch02-stitched-0.tif c3=ch00-stitched-0.tif create");
saveAs("Tiff", replace(path, ".czi", ".tif"));

setBatchMode(false);