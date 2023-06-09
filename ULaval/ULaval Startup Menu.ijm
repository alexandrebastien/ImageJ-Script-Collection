// START ULAVAL MENU
var ULpath = getDirectory("plugins") + File.separator + "ULaval";
var ulmenu = getFolderToList(ULpath);
var ulCmds = newMenu("ULaval Menu Tool", ulmenu);
macro "ULaval Menu Tool - Cf00D21D22D23D24D25D26D29D2aD2bD2cD2dD31D32D34D36D39D3aD3cD3eD41D42D43D44D45D46D49D4aD4bD4cD4dD4eD51D52D54D56D59D5aD5cD5eD61D62D63D64D65D66D69D6aD6bD6cD6dD6eD91D92D93D94D95D96D99D9aD9bD9cD9dD9eDa1Da2Da4Da6Da9DaaDacDaeDb1Db2Db3Db4Db5Db6Db9DbaDbbDbcDbdDbeDc1Dc2Dc4Dc6Dc9DcaDccDceDd1Dd2Dd3Dd4Dd5Dd6Dd9DdaDdbDdcDddC037D10D11D12D13D14D15D16D17D18D19D1aD1bD1cD1dD20D2eD30D3fD40D4fD50D5fD60D6fD70D7fD80D8fD90D9fDa0DafDb0DbfDc0DcfDd0DdeDe0De1De2De3De4De5De6De7De8De9DeaDebDecDedCff0D27D28D37D38D47D48D57D58D67D68D71D72D73D74D75D76D77D78D79D7aD7bD7cD7dD7eD81D82D83D84D85D86D87D88D89D8aD8bD8cD8dD8eD97D98Da7Da8Db7Db8Dc7Dc8Dd7Dd8CfffD33D35D3bD3dD53D55D5bD5dDa3Da5DabDadDc3Dc5DcbDcdCeeeD00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD1eD1fD2fDdfDeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDff" {
	cmd = getArgument();
	if (cmd!="-") run(cmd);
}

function getFolderToList(path) {	
	list = newArray();
	if (!File.exists(path))	return list;
	rawlist = getFileList(path);
	if (rawlist.length==0) return list;
	count = 0;
	for (i=0; i< rawlist.length; i++)
		if ((endsWith(rawlist[i], ".ijm") || 
			endsWith(rawlist[i], ".py") ||
			endsWith(rawlist[i], ".js") ||
			endsWith(rawlist[i], ".bsh") ||
			endsWith(rawlist[i], ".jar")) &&
			rawlist[i].contains("_")) {
				name = File.getNameWithoutExtension(path + File.separator + rawlist[i]);
				name = replace(name, "_", " ");
				list[count] = name;
				count++;
		}
	return list;
}
// END ULAVAL MENU
