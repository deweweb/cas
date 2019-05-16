** Article: http://www.sascommunity.org/planet/blog/category/data-management/                                         **;
** SAS CAS provides two types of supplied functions: built-in functions and common functions.                         **;
** Built-in functions contain functionality that is unique to CASL and can't be replaced with user-defined functions. **;

** Run the following code to see a list of built-in functions **;
proc cas;
	functionlist;
quit;

** Run the following code to see a list of common functions. **;
proc cas;
	fnc;
run;

** Create list of user-defined functions. **;
proc cas;
	** Function Multi **;
	function multi (a, b);
		c = a * b;
		return round(c);
	end func;
run;

** TEST functionality **;
proc cas;

	** Function Multi direct definition **;
	function multi (a, b);
		c = a * b;
		return round(c);
	end func;
	** Function Multi aus File !Schould be so! **;
	%*include "myfiles/code/FunctionStore.sas";

	x = 9;
	y = 3;

	result = multi(x, y);
	print put(x, best3.) " * " put(y, best3.)  "=" result ;

run;


data work.worior;

	x = 9;
	y = 3;

	** is impossible to execute in Data Step **;
	result = multi(x, y);

run;
