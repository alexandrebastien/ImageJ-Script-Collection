/* INSTALL ULAVAL MENU 
   ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
   Install ULaval Menu is a script to easoly modify StartupMacros.fiji.ijm
   in order to add ULaval menu toolbar at startup.
   
   AUTHOR  : Alexandre Bastien, Copyright (c) 2018
   EMAIL   : alexandre.bastien@fsaa.ulaval.ca 
   LICENSE : Licensed under MIT License, see file LICENSE
*/

ok = false;
path1 = getDirectory("macros") + "StartupMacros.fiji.ijm";
path2 = getDirectory("macros") + "StartupMacros.ijm";

if (File.exists(path1)) {
	ok = File.rename(path1, path2);
	path = path2;
} else {
	if (File.exists(path2)) {
		ok = true;
		path = path2;
	}
}

if (ok) {
	str = File.openAsString(path);
	start = indexOf(str, "// START ULAVAL MENU");
	end = indexOf(str, "// END ULAVAL MENU");
	
	menu = "\"Cilia\","+
		   "\"3D Animator\","+
		   "\"Stitch CZI\"";
	
	new = "\n// START ULAVAL MENU\n"+
	"var sCmds = newMenu(\"ULaval Menu Tool\", newArray("+menu+"));\n"+
	"macro \"ULaval Menu Tool - Cf00D21D22D23D24D25D26D29D2aD2bD2cD2dD31D32D34D36D39D3aD3cD3eD41D42D43D44D45D46D49D4aD4bD4cD4dD4eD51D52D54D56D59D5aD5cD5eD61D62D63D64D65D66D69D6aD6bD6cD6dD6eD91D92D93D94D95D96D99D9aD9bD9cD9dD9eDa1Da2Da4Da6Da9DaaDacDaeDb1Db2Db3Db4Db5Db6Db9DbaDbbDbcDbdDbeDc1Dc2Dc4Dc6Dc9DcaDccDceDd1Dd2Dd3Dd4Dd5Dd6Dd9DdaDdbDdcDddC037D10D11D12D13D14D15D16D17D18D19D1aD1bD1cD1dD20D2eD30D3fD40D4fD50D5fD60D6fD70D7fD80D8fD90D9fDa0DafDb0DbfDc0DcfDd0DdeDe0De1De2De3De4De5De6De7De8De9DeaDebDecDedCff0D27D28D37D38D47D48D57D58D67D68D71D72D73D74D75D76D77D78D79D7aD7bD7cD7dD7eD81D82D83D84D85D86D87D88D89D8aD8bD8cD8dD8eD97D98Da7Da8Db7Db8Dc7Dc8Dd7Dd8CfffD33D35D3bD3dD53D55D5bD5dDa3Da5DabDadDc3Dc5DcbDcdCeeeD00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD1eD1fD2fDdfDeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDff\" {\n"+
	"	cmd = getArgument();\n"+
	"	if (cmd!=\"-\") run(cmd);\n"+
	"}\n"+
	"// END ULAVAL MENU\n";
	
	if (start==-1) {
		str = str + new;
	} else {
		str = substring(str, 0, start) + new + substring(str, end+18, lengthOf(str)-1);
	}
	
	File.saveString(str, path);
	showMessage("Please restart Fiji");
} else {
	showMessage("File: "+path+" not found.");
}
