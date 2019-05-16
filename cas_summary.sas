cas casauto;

caslib mycaslib datasource=(srctype="path")
   path="/opt/sas/data/EC/data/results/" sessref=casauto;

libname mycas cas caslib=mycaslib;

proc casutil;
   load data=sashelp.cars;
   contents casdata="cars";
quit;

proc mdsummary data=mycas.cars;/*3*/
   var MPG_City;
   groupby / out=mycas.carsmpgcityall; /*4*/
   groupby make type / out=mycas.carsmaketype; /*5*/
run;

*proc summary data=mycas.cars;/*3*/
   *var MPG_City;
   *groupby / out=mycas.carsmpgcityall (keep =_sum_); /*4*/
   *groupby make type / out=mycas.carsmaketype; /*5*/
*run;

proc summary data=mycas.cars;/*3*/
   var MPG_City;
   output out=  mycas.carsmpgcityall_(drop=_TYPE_ _FREQ_ ) sum=;
run;

proc summary data=mycas.cars;/*3*/
   class make type;
   var MPG_City;
   output out=  mycas.carsmaketype_;
run;


proc print data=mycas.carsmpgcityall;/*6*/
   title 'SAS CAS Mdsummary';
run;
proc print data=mycas.carsmpgcityall_;/*6*/
   title 'SAS BASE Summary';
run;


** Summery in CAS **;
proc cas;
   simple.summary result=r status=s /
      inputs={"MPG_City"}
      subSet={"SUM"}
      table={
         name="cars"
      }
      casout={
         name="cars_cas_summary",
         replace=True
      };
	*describe r;
	*val = findtable(r);
	*saveresult val dataout=work.cas2sas_summary_stat;
	*saveresult val["SubSet1.Summary"] dataout=work.cas2sas_summary_result;
run;
   if (s.severity == 0) then do;
      table.fetch /
         format=True,
         fetchVars={{name="_Sum_", format="5.2"}}
         table={name="cars_cas_summary"}
      ;
	  table.alterTable /
		columns={{name="_Column_", drop=TRUE}, {name="_Sum_", rename="MPG_City"}}
         name="cars_cas_summary"
	  ;
      table.save /
         table={name="cars_cas_summary"}
         name="cars_cas_summary.sashdat"
         replace=True
      ;
   end;
run;
quit;


proc print data=mycas.cars_cas_summary ;
   title 'SAS CAS Summary';
run;


proc cas;
  t1.name = 'cars';
  t1.groupBy = 'MPG_City';

  simple.summary /
	 table = t1
	 subSet = {"SUM"};
     casout={
         name="cars_summary",
         replace=True
      };
quit;


proc print data=mycas.cars_summary;
   title 'SAS CAS Summary Short';
run;

** CAS example of use with Summary and Sum= **;
proc cas;
	simple.summary result=r status=s /
		inputs= {&CAS_NUTZ_VARS.}
		subSet= {"SUM"}
		table= {
			name    = "CALC_BP_FILTER",
			groupBy = {&CAS_GROUP_BY.}
		}
      	casout= {
        	name    = "CALC_BP_FILTER",
         	replace = True
     	};
run;
	transpose.transpose /
		table={name="CALC_BP_FILTER", groupby={&CAS_GROUP_BY.}}
		transpose={"_Sum_"}
		id={"_Column_"}
		casOut={name="CALC_BP_SUMY", replace=true};
run;
quit;

** CAS summary with FED Sql Syntaxis **;
proc cas;
	fedSql.execDirect /
		query="SELECT put(a.EINHEITS_NR, best.) AS EINHEITS_NR
		 , put(a.AKT_JAHR, best.) AS AKT_JAHR
		 , put(a.BP_ID, best.) AS BP_ID
		 , kd.KDTYP_A AS KDTYP
		 , bt.BERTYP_AGGR AS BERTYP
		 , strip(put(oe.OE_ID_PARENT, 4.)) AS OE_ID
		 , sum(ERTRAG) AS ERTRAG
		 		 , sum(ERTRAG_ORIG) AS ERTRAG_ORIG
		 		 		 , sum(ANZAHL) AS ANZAHL
		 		 		 		 , sum(ANZAHL_ORIG) AS ANZAHL_ORIG
		 		 		 		 		 , sum(VOL) AS VOL
		 		 		 		 		 		 , sum(VOL_ORIG) AS VOL_ORIG
		FROM Aggr_ec AS a
		INNER JOIN kdtyp_aggr AS kd
			ON a.KDTYP_AGG = kd.KDTYP_AGG
		INNER JOIN bertyp_aggr AS bt
			ON a.BERTYP_AGG = bt.BERTYP_AGG
		INNER JOIN oe_aggr AS oe
			ON a.OE_ID = oe.OE_ID
		WHERE a.OE_ID <> -1
		GROUP BY a.EINHEITS_NR, a.AKT_JAHR, a.BP_ID, kd.KDTYP_A, bt.BERTYP_AGGR, oe.OE_ID_PARENT"
	;
run;
quit;


/** Ausgang im Permanent Library im CAS  **/
proc casutil incaslib="mycaslib" outcaslib="mycaslib";
   save casdata="cars_cas_summary" replace;
run;
quit;


cas casauto terminate;

