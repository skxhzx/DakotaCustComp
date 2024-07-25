710 AH*dftactgrp( *NO )
     H*  actgrp( *NEW )
     H*bnddir( 'QC2LE' )
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  PCOMPONTWO - Production Component/WO validation
     *  26 December  2018
     *  Mike Rooker
     *
     *    -PARMS
     *       pWhse = Warehouse
     *       pComponent = Component
     *       pRmItem   = Raw Material Item
     *       pcmd      = Command value
     *       arr       = Component Array
     *       arr2      = Component Recursive Check Array
     *       pCntr1    = Component Array  Counter
     *       pCntr2    = Component Recursive Array  Counter
     *       pLevel    = Program level in Recursive process
     *       pRtnMsg   = Error message for Recursive Level
     *
     *  CMD Codes - BA = BOM Add
     *              BD = BOM Delete
     *              BI = BOM Inquiry
     *              BR = BOM Rebuild
     *              WI = Work Order Inquiry
     *              WB = Work Order Inquiry (Fin Goods and Components)
     *              WR = Work Order Inquiry (Raw Mat and Components)
     *----------------------------------------------------------------
     *  Revisions:
     *
520 A*  12/26/18  MR   7.30
     *    - Created.
     *----------------------------------------------------------------
     *
     p pCompontWo      b
     fpbom      uf   e           k disk
     fitemprd   if   e           k disk
     fpiritem   if   e           k disk
     fpwrkordr  if   e           k disk
     fpbomlvl   o  a e             disk
     *
     d PCompontWo      pi           100
     d  pwhse                         3
     d  pFinGood                    100
     d  pRmItem                      15
     d  pcmd                          2
     d  arr                          15    dim(100)
     d  arr2                         15    dim(100)
     d  arr3w                        15    dim(500)
     d  arr3c                       500    dim(100)
     d  pcntr                         3
     d  pcntr1                        3
     d  pLevel                        3
     d  pRtnMsg                     100
     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------
     d arr4w           s             15    dim(500)
     D cmpValues       s            100
     D compString      s           5000
     D orgFinGood      s            100
     D finGood2        s            100
     D whse            s              3s 0
     D cntr            s              3s 0
     D cntr1           s              3s 0
     D cntr3w          s              3s 0
     D cntr3c          s              3s 0
     D datacntr        s              3s 0
     D wcntr           s              3s 0
     D wcntr1          s              3s 0
     D wocntr          s              2s 0
     D workWO          s             15
     D workComp        s             15
     D length          s              5s 0
     D forever         s              1
     D position        s              3s 0
     D pgmLevel        s              3s 0
     D item            s               n
     D workOrder       s               n
     D variables       s               n
     D sqlstmt         s           5000
     D wcmd            s              2
     *
     D  bomdata        ds                  dim(1000) qualified
     D  toplevel                     15
     D  level1                       15
     D  level2                       15
     D  level3                       15
     D  level4                       15
     D  level5                       15
     D  level6                       15
     D  level7                       15
     D  level8                       15
     D  level9                       15
     D  level10                      15
      *
     D  wrkdata        ds
     D  wtoplevel                    15
     D  wlevel1                      15
     D  wlevel2                      15
     D  wlevel3                      15
     D  wlevel4                      15
     D  wlevel5                      15
     D  wlevel6                      15
     D  wlevel7                      15
     D  wlevel8                      15
     D  wlevel9                      15
     D  wlevel10                     15
      *
     D  bom            ds                  LikeRec(bmrec: *input) inz
     D  itmprd         ds                  LikeRec(iprec: *input) inz
     D  iritem         ds                  LikeRec(itrec: *input) inz
     D  pwrkor         ds                  LikeRec(wrrec: *input) inz
     D  bmlvl          ds                  LikeRec(bmlrec: *output) inz
     *
      /free
          //******************************
          // Validate Commands
          //******************************
          if pcmd <> 'BA'
             and pcmd <> 'BD'
             and pcmd <> 'BI'
             and pcmd <> 'BR'
             and pcmd <> 'WI'
             and pcmd <> 'WB'
             and pcmd <> 'WR';
          eval cmpValues = *blanks;
          cmpValues = '*ERROR - Invalid Command';
          endif;
          //******************************
          // Determine process by command
          //******************************
          eval whse = %dec(pwhse:3:0);
          if pcmd = 'BA'
             or pcmd = 'BD'
             or pcmd = 'BI'
             or pcmd = 'BR';
          exsr doBOM;
          endif;
          if pcmd = 'WI';
          exsr woInquiry;
          endif;
          if pcmd = 'WB';
          exsr woInquiryFC;
          endif;
          if pcmd = 'WR';
          exsr woInquiryRC;
          endif;
          return cmpValues;
          //eval *inlr = *on;
          //******************************
          // Read Finished Good/Component
          //******************************
          begsr doBOM;
          pgmlevel = %dec(plevel:3:0);
          //if pgmlevel = 0
          //   and pcmd = 'BA';
         //exec sql insert into pbom values(:whse,:pFinGood, 9999, :pRmItem,
        //     0,0,0,0,0,'X','X','X', 19500101, 19500101, 'N');
        //endif;
          //
          //eval cmpValues = pRtnValues;
          eval pgmLevel = %dec(plevel:3:0) + 1;
          eval plevel = %char(pgmlevel);
          cntr = %dec(pcntr:3:0);
          cntr1= %dec(pcntr1:3:0);
          setll (whse: pFinGood) pbom;
          doW not %eof(pbom);
          reade(N) (whse: pFinGood) pbom bom;
          if %eof(pbom);
          leave;
          endif;
          //
          chain(N) (whse:bom.bmrmi) itemprd itmprd;
          if %found;

          // if component check if it already exist and if so
          // build error message and get out else go through
          // component levels.
            if itmprd.ipprdflg = 'C';
              if %lookup(bom.bmrmi : arr2) = 0;
                 cntr = cntr + 1;
                 arr(cntr) = bom.bmrmi;
                 arr3w(cntr) = 'L'+%char(pgmLevel);
                 cntr1 = cntr1 + 1;
                 arr2(cntr1) = bom.bmrmi;
               //eval cmpValues = %trim(cmpValues) + %trim(bom.bmrmi) + '|';
              else;
                 eval cmpValues = *blanks;
                 cmpValues = '*ERROR - '+%trim(bom.bmrmi) + ' is '+
                       'recursive in '+%trim(pFinGood)+ ', please'+
                       ' use another component.';
                 leave;
              endif;
              eval pcntr = %Char(cntr);
              eval pcntr1 = %Char(cntr1);
              //eval plevel= %Char(pgmLevel);
              eval fingood2 = bom.bmrmi;
              eval cmpValues = pCompontWO(pWhse:fingood2:pRmItem:pcmd:
                       arr:arr2:arr3w:arr3c:pcntr:pcntr1:plevel
                       :pRtnMsg);

720aA         if %subst(cmpValues:1:6) = '*ERROR';
                 leave;
              endif;

              eval pgmLevel = %dec(plevel:3:0) - 1;
              eval plevel= %Char(pgmLevel);
              eval cntr  = %dec(pcntr:3:0);
              eval cntr1 = %dec(pcntr1:3:0);
            else;
              //if raw material then added to array/string
              cntr = cntr + 1;
              arr(cntr) = bom.bmrmi;
              arr3w(cntr) = 'L'+%char(pgmLevel);
              //eval cmpValues = %trim(cmpValues) + %trim(bom.bmrmi) + '|';
              eval pcntr = %Char(cntr);
          endif;
          endif;
          //
          //if pgmLevel = 1;
             cntr = cntr + 1;
             arr(cntr) = 'X';
          //   pcntr = %Char(cntr);
             //arr2 = *blanks;
             //eval cntr1=0;
        // endif;
          //
          enddo;
          //
          //if pgmlevel = 1;
          // exec sql delete from pbom where bmeffd = 19500101;
          //endif;
          //If no errors, then write record
          position = %Scan('*ERROR': cmpValues);
          if position = 0
             and pgmLevel = 1
             and pcmd <> 'BI';
          exsr   writeRec;
          endif;
          //
          endsr;
          //***********************************************
          // Write breakdown to PBOMLVL
          //***********************************************
          begsr writeRec;
          //eval cntr = 1;
          //eval cmpValues = *blanks;
          //dou cntr = 100;
          //    if arr(cntr) <> 'X';
              //eval cmpValues = %trim(cmpValues) + %trim(arr(cntr)) + '|';
          //    endif;
          //    cntr = cntr+1;
          //    if arr(cntr) = *blanks;
          //  leave;
          //  endif;
          //enddo;
          // Delete existing records
          exec sql
            delete from pbomlvl where bmlwhs = :whse
            and bmlfg = :pFinGood;
          //
          eval bmlvl.bmlwhs = whse;
          eval bmlvl.bmlfg =  pFinGood;
          dow forever = forever;
             eval wCntr = wcntr + 1;    //Loop control
             if wcntr > 100;
             leave;
             endif;
            //val wCntr1 = wcntr1 + 1;  //Field postion control
             if arr(wcntr) = 'X';     //if X then write record and clear
               write bmlrec bmlvl;   //fields
               //eval bmlvl.bmllvl1 = '';
               //eval bmlvl.bmllvl2 = '';
               //eval bmlvl.bmllvl3 = '';
               //eval bmlvl.bmllvl4 = '';
               //eval bmlvl.bmllvl5 = '';
               //eval bmlvl.bmllvl6 = '';
               //eval bmlvl.bmllvl7 = '';
               //eval bmlvl.bmllvl8 = '';
               //eval bmlvl.bmllvl9 = '';
               //eval bmlvl.bmllvl10 = '';
             //wcntr1 = 0;
               iter;
             endif;
             if arr(wcntr) = '';
               leave;
             endif;
             select;
             when arr3w(wcntr) = 'L1';
               eval bmlvl.bmllvl1 = arr(wcntr);
               eval bmlvl.bmllvl2 = '';
               eval bmlvl.bmllvl3 = '';
               eval bmlvl.bmllvl4 = '';
               eval bmlvl.bmllvl5 = '';
               eval bmlvl.bmllvl6 = '';
               eval bmlvl.bmllvl7 = '';
               eval bmlvl.bmllvl8 = '';
               eval bmlvl.bmllvl9 = '';
               eval bmlvl.bmllvl10 = '';
             when arr3w(wcntr) = 'L2';
               eval bmlvl.bmllvl2 = arr(wcntr);
               eval bmlvl.bmllvl3 = '';
               eval bmlvl.bmllvl4 = '';
               eval bmlvl.bmllvl5 = '';
               eval bmlvl.bmllvl6 = '';
               eval bmlvl.bmllvl7 = '';
               eval bmlvl.bmllvl8 = '';
               eval bmlvl.bmllvl9 = '';
               eval bmlvl.bmllvl10 = '';
             when arr3w(wcntr) = 'L3';
               eval bmlvl.bmllvl3 = arr(wcntr);
               eval bmlvl.bmllvl4 = '';
               eval bmlvl.bmllvl5 = '';
               eval bmlvl.bmllvl6 = '';
               eval bmlvl.bmllvl7 = '';
               eval bmlvl.bmllvl8 = '';
               eval bmlvl.bmllvl9 = '';
               eval bmlvl.bmllvl10 = '';
             when arr3w(wcntr) = 'L4';
               eval bmlvl.bmllvl4 = arr(wcntr);
               eval bmlvl.bmllvl5 = '';
               eval bmlvl.bmllvl6 = '';
               eval bmlvl.bmllvl7 = '';
               eval bmlvl.bmllvl8 = '';
               eval bmlvl.bmllvl9 = '';
               eval bmlvl.bmllvl10 = '';
             when arr3w(wcntr) = 'L5';
               eval bmlvl.bmllvl5 = arr(wcntr);
               eval bmlvl.bmllvl6 = '';
               eval bmlvl.bmllvl7 = '';
               eval bmlvl.bmllvl8 = '';
               eval bmlvl.bmllvl9 = '';
               eval bmlvl.bmllvl10 = '';
             when arr3w(wcntr) = 'L6';
               eval bmlvl.bmllvl6 = arr(wcntr);
               eval bmlvl.bmllvl7 = '';
               eval bmlvl.bmllvl8 = '';
               eval bmlvl.bmllvl9 = '';
               eval bmlvl.bmllvl10 = '';
             when arr3w(wcntr) = 'L7';
               eval bmlvl.bmllvl7 = arr(wcntr);
               eval bmlvl.bmllvl8 = '';
               eval bmlvl.bmllvl9 = '';
               eval bmlvl.bmllvl10 = '';
             when arr3w(wcntr) = 'L8';
               eval bmlvl.bmllvl8 = arr(wcntr);
               eval bmlvl.bmllvl9 = '';
               eval bmlvl.bmllvl10 = '';
             when arr3w(wcntr) = 'L9';
               eval bmlvl.bmllvl9 = arr(wcntr);
               eval bmlvl.bmllvl10 = '';
             when arr3w(wcntr) = 'L10';
               eval bmlvl.bmllvl10 = arr(wcntr);
             endsl;
          enddo;
          endsr;

          //***********************************************
          // Work Order Inquiry
          //***********************************************
          begsr woInquiry;
          // determing if value is an item
          orgFinGood = pFinGood;
          workorder = *off;
          chain(N) (whse:pFinGood) pwrkordr pwrkor;
          if %found;
             workorder = *on;
             eval pFinGood = pwrkor.wrfgi;
          endif;
          chain(N)(whse:%trim(pFinGood)) itemprd itmprd;
          if %found;
              eval item = *on;
          else;
              eval item = *off;
          endif;
          eval wocntr = 0;
          //
          // Build SQL Statement
          dou wocntr = 11;
          eval wocntr = wocntr + 1;
          eval sqlstmt =  %trim(sqlstmt)+ ' select distinct wrwo# +
                from pbomlvl ';
          select;
          when wocntr = 1;
          eval sqlstmt = %trim(sqlstmt)+' join pwrkordr on wrfgi=bmlfg';
          when wocntr = 2;
          eval sqlstmt = %trim(sqlstmt)+' join pwrkordr on writem=bmllvl1';
          when wocntr = 3;
          eval sqlstmt = %trim(sqlstmt)+' join pwrkordr on writem=bmllvl2';
          when wocntr = 4;
          eval sqlstmt = %trim(sqlstmt)+' join pwrkordr on writem=bmllvl3';
          when wocntr = 5;
          eval sqlstmt = %trim(sqlstmt)+' join pwrkordr on writem=bmllvl4';
          when wocntr = 6;
          eval sqlstmt = %trim(sqlstmt)+' join pwrkordr on writem=bmllvl5';
          when wocntr = 7;
          eval sqlstmt = %trim(sqlstmt)+' join pwrkordr on writem=bmllvl6';
          when wocntr = 8;
          eval sqlstmt = %trim(sqlstmt)+' join pwrkordr on writem=bmllvl7';
          when wocntr = 9;
          eval sqlstmt = %trim(sqlstmt)+' join pwrkordr on writem=bmllvl8';
          when wocntr = 10;
          eval sqlstmt = %trim(sqlstmt)+' join pwrkordr on writem=bmllvl9';
          when wocntr = 11;
          eval sqlstmt = %trim(sqlstmt)+' join pwrkordr on writem=bmllvl10';
          endsl;
          //eval sqlstmt = %trim(sqlstmt)+' join pwrkord on wowo# = wrwo#';
          if item = *off;
          select;
          when wocntr = 1;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on wfrig = ititem';
          when wocntr = 2;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl1 = ititem';
          when wocntr = 3;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl2 = ititem';
          when wocntr = 4;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl3 = ititem';
          when wocntr = 5;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl4 = ititem';
          when wocntr = 6;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl5 = ititem';
          when wocntr = 7;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl6 = ititem';
          when wocntr = 8;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl7 = ititem';
          when wocntr = 9;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl8 = ititem';
          when wocntr = 10;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl9 = ititem';
          when wocntr = 11;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl11 = +
                                   ititem';
          endsl;
          endif;
          eval sqlstmt = %trim(sqlstmt) + ' where wrstat not in +
                 (''C'',''D'')';
         if item = *off;
           eval sqlstmt = %trim(sqlstmt) + ' and itdesc like';
           eval sqlstmt = %trim(sqlstmt) + ' '''+'%';
           eval sqlstmt = %trim(sqlstmt) + %trim(pFinGood);
           eval sqlstmt = %trim(sqlstmt) + '%'+'''';
         else;
           select;
           when wocntr = 1;
             eval sqlstmt = %trim(sqlstmt) + ' and bmlfg = ';
           when wocntr = 2;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl1 = ';
           when wocntr = 3;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl2 = ';
           when wocntr = 4;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl3 = ';
           when wocntr = 5;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl4 = ';
           when wocntr = 6;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl5 = ';
           when wocntr = 7;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl6 = ';
           when wocntr = 8;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl7 = ';
           when wocntr = 9;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl8 = ';
           when wocntr = 10;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl9 = ';
           when wocntr = 11;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl10 = ';
           endsl;
           eval sqlstmt = %trim(sqlstmt) + '''';
           eval sqlstmt = %trim(sqlstmt) + %trim(pFinGood);
           eval sqlstmt = %trim(sqlstmt) + '''';
         endif;
         if wocntr < 11;
         eval sqlstmt = %trim(sqlstmt) + ' union ';
         endif;
         enddo;

         //eval sqlstmt = %trim(sqlstmt) + ' order by wrmfgno, writem';
         //eval length = %len(%trim(sqlstmt));
         //execute sql
         exsr GetWOs;
         pFinGood = orgFinGood;
         endsr;
          //***********************************************
          //
         begsr GetWOs;
            cntr3w = 0;
            exec sql Close cursor1;
            exec sql Declare cursor1 scroll cursor for mainStmt2;
            exec sql Prepare mainStmt2 from :Sqlstmt;
            exec sql Open cursor1;
            dow sqlcod <> 100;
               exec sql fetch next from cursor1 into :workwo;
               if sqlcode=100;
                 leave;
               endif;
         //
              // eval      cmpValues = %trim(cmpValues)+
              //                 %trim(workwo)+'|';
                 cntr3w = cntr3w + 1;
                 eval arr3w(cntr3w) = %trim(workwo);
                 chain(N) (whse:workwo) pwrkordr pwrkor;
                 pcmd = 'BI';
                 pRmItem = '';
                 arr = '';
                 arr2 = '';
                 pcntr = '000';
                 pcntr1= '000';
                 plevel = '000';
                 pRtnMsg = '';
                 fingood2 = pwrkor.wrfgi;
                 cmpValues = pCompontWO(pWhse:fingood2:pRmItem:pcmd:
                       arr:arr2:arr3w:arr3c:pcntr:pcntr1:plevel
                       :pRtnMsg);
                 cntr3c = 0;
                 dow forever = forever;
                    cntr3c = cntr3c + 1;
                    if arr(cntr3c) = *blanks;
                       leave;
                    endif;
                    if arr(cntr3c) <> 'X';
                       if workorder = *on;
                          compString = %trim(pFinGood)+'|';
                          workorder = *off;
                       endif;
                       compString = %trim(compString) +
                                %trim(arr(cntr3c))+'|';
                    endif;
                 enddo;
                 arr3c(cntr3w) = compString;
            enddo;
            exec sql Close cursor1;
         endsr;

          //***********************************************
          // Work Order Inquiry (Fin Good and Components)
          //***********************************************
         begsr woInquiryFC;
          // determing if value is an item
          orgFinGood = pFinGood;
          workorder = *off;
          chain(N)(whse:%trim(pFinGood)) itemprd itmprd;
          if %found;
              eval item = *on;
          else;
              eval item = *off;
          endif;
          eval wocntr = 0;
          //
          // Build SQL Statement
          dou wocntr = 11;
          eval wocntr = wocntr + 1;
          eval sqlstmt =  %trim(sqlstmt)+ ' select distinct bmlfg,+
                bmllvl1, bmllvl2, bmllvl3, bmllvl4, bmllvl5, bmllvl6,+
                bmllvl7, bmllvl8, bmllvl9, bmllvl10 +
                from pbomlvl ';
          select;
          when wocntr = 1;
          eval sqlstmt = %trim(sqlstmt)+' join itemprd on bmlfg = ipitem';
          when wocntr = 2;
          eval sqlstmt = %trim(sqlstmt)+' join itemprd on bmllvl1 = ipitem';
          when wocntr = 3;
          eval sqlstmt = %trim(sqlstmt)+' join itemprd on bmllvl2 = ipitem';
          when wocntr = 4;
          eval sqlstmt = %trim(sqlstmt)+' join itemprd on bmllvl3 = ipitem';
          when wocntr = 5;
          eval sqlstmt = %trim(sqlstmt)+' join itemprd on bmllvl4 = ipitem';
          when wocntr = 6;
          eval sqlstmt = %trim(sqlstmt)+' join itemprd on bmllvl5 = ipitem';
          when wocntr = 7;
          eval sqlstmt = %trim(sqlstmt)+' join itemprd on bmllvl6 = ipitem';
          when wocntr = 8;
          eval sqlstmt = %trim(sqlstmt)+' join itemprd on bmllvl7 = ipitem';
          when wocntr = 9;
          eval sqlstmt = %trim(sqlstmt)+' join itemprd on bmllvl8 = ipitem';
          when wocntr = 10;
          eval sqlstmt = %trim(sqlstmt)+' join itemprd on bmllvl9 = ipitem';
          when wocntr = 11;
          eval sqlstmt = %trim(sqlstmt)+' join itemprd on bmllvl10 = +
                                                     ipitem';
          endsl;
          if item = *off;
          select;
          when wocntr = 1;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmlfg = ititem';
          when wocntr = 2;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl1 = ititem';
          when wocntr = 3;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl2 = ititem';
          when wocntr = 4;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl3 = ititem';
          when wocntr = 5;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl4 = ititem';
          when wocntr = 6;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl5 = ititem';
          when wocntr = 7;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl6 = ititem';
          when wocntr = 8;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl7 = ititem';
          when wocntr = 9;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl8 = ititem';
          when wocntr = 10;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl9 = ititem';
          when wocntr = 11;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl10 = +
                                   ititem';
          endsl;
          endif;
          // *************************************************************
             eval sqlstmt = %trim(sqlstmt) + ' where ipprdflg in  +
                 (''F'',''C'')';
          // *************************************************************
         if item = *off;
           eval sqlstmt = %trim(sqlstmt) + ' and ucase(itdesc) like';
           eval sqlstmt = %trim(sqlstmt) + ' '''+'%';
           eval sqlstmt = %trim(sqlstmt) + %trim(pFinGood);
           eval sqlstmt = %trim(sqlstmt) + '%'+'''';
         else;
           select;
           when wocntr = 1;
             eval sqlstmt = %trim(sqlstmt) + ' and bmlfg = ';
           when wocntr = 2;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl1 = ';
           when wocntr = 3;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl2 = ';
           when wocntr = 4;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl3 = ';
           when wocntr = 5;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl4 = ';
           when wocntr = 6;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl5 = ';
           when wocntr = 7;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl6 = ';
           when wocntr = 8;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl7 = ';
           when wocntr = 9;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl8 = ';
           when wocntr = 10;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl9 = ';
           when wocntr = 11;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl10 = ';
           endsl;
           eval sqlstmt = %trim(sqlstmt) + '''';
           eval sqlstmt = %trim(sqlstmt) + %trim(pFinGood);
           eval sqlstmt = %trim(sqlstmt) + '''';
         endif;
         if wocntr < 11;
         eval sqlstmt = %trim(sqlstmt) + ' union ';
         endif;
         enddo;

         //eval sqlstmt = %trim(sqlstmt) + ' order by wrmfgno, writem';
         //eval length = %len(%trim(sqlstmt));
         //execute sql
         exsr GetWOBOM;
         pFinGood = orgFinGood;
         endsr;
         //
         begsr GetWOBOM;
            cntr3w = 0;
            cntr3c = 0;
            wcmd = pcmd;
            whse = %dec(pwhse:3:0);
            exec sql Close cursor3;
            exec sql Declare cursor3 scroll cursor for mainStmt3;
            exec sql Prepare mainStmt3 from :Sqlstmt;
            exec sql Open cursor3;
            //dow sqlcod <> 100;
               exec sql fetch next from cursor3 for 1000 rows into :bomdata;
               //if sqlcode=100;
               //  leave;
               //endif;
         //
          //enddo;
            exec sql Close cursor3;
            datacntr = 0;
            dou datacntr = 1000;
               datacntr = datacntr + 1;
               wrkdata = bomdata(datacntr);
               if wtoplevel = *blanks;
                  leave;
               endif;
               chain(N) (whse:wtoplevel) itemprd itmprd;
               if itmprd.ipprdflg = 'F';
                 if %lookup(wtoplevel: arr4w)= 0;
                    cntr3c = cntr3c+1;
                    arr4w(cntr3c)= wtoplevel;
                 endif;
                 pcmd = 'BI';
                 arr = *blanks;  // main array
                 arr2 = *blanks; // component array
                 arr3w = *blanks; // workOrder array
                 arr3c = *blanks; // components in workorder array
                 acntr = '000';  // main array counter
                 acntr2 = '000'; // component array coutner
                 lvlcntr = '000';  // level counter
                 exsr doBOM;
                 dow forever = forever;
                    cntr3w = cntr3w + 1;
                    if arr2(cntr3w) = *blanks;
                      leave;
                    endif;
                    if %lookup(arr2(cntr3w): arr4w)= 0;
                       cntr3c = cntr3c+1;
                       arr4w(cntr3c)= arr2(cntr3w);
                    endif;
                 enddo;
               else;
                 cntr = 0;
                 dou cntr = 11;
                    cntr = cntr + 1;
                    select;
                    when cntr = 1;
                         workcomp = wtoplevel;
                    when cntr = 2;
                         workcomp = wlevel1;
                    when cntr = 3;
                         workcomp = wlevel2;
                    when cntr = 4;
                         workcomp = wlevel3;
                    when cntr = 5;
                         workcomp = wlevel4;
                    when cntr = 6;
                         workcomp = wlevel5;
                    when cntr = 7;
                         workcomp = wlevel6;
                    when cntr = 8;
                         workcomp = wlevel7;
                    when cntr = 9;
                         workcomp = wlevel8;
                    when cntr = 10;
                         workcomp = wlevel9;
                    when cntr = 11;
                         workcomp = wlevel10;
                    endsl;
                    if workcomp = *blanks;
                      leave;
                    endif;
                    chain(N) (whse:workcomp) itemprd itmprd;
                    if itmprd.ipprdflg = 'C';
                       if %lookup(workcomp: arr4w)= 0;
                          cntr3c = cntr3c+1;
                          arr4w(cntr3c) = workcomp;
                       endif;
                    endif;
                    enddo;
               endif;
            enddo;
            arr3w = arr4w;
         endsr;
        //
          //***********************************************
          // Work Order Inquiry (Raw Materials and Components)
          // Look through finished good, raw materials and
          // components associated to value passed in and
          // return raw materials and components.
          //***********************************************
         begsr woInquiryRC;
          // determing if value is an item
          orgFinGood = pFinGood;
          workorder = *off;
          chain(N)(whse:%trim(pFinGood)) itemprd itmprd;
          if %found;
              eval item = *on;
          else;
              eval item = *off;
          endif;
          eval wocntr = 0;
          //
          // Build SQL Statement
          dou wocntr = 11;
          eval wocntr = wocntr + 1;
          eval sqlstmt =  %trim(sqlstmt)+ ' select distinct bmlfg,+
                bmllvl1, bmllvl2, bmllvl3, bmllvl4, bmllvl5, bmllvl6,+
                bmllvl7, bmllvl8, bmllvl9, bmllvl10 +
                from pbomlvl ';
          select;
          when wocntr = 1;
          eval sqlstmt = %trim(sqlstmt)+' join itemprd on bmlfg = ipitem';
          when wocntr = 2;
          eval sqlstmt = %trim(sqlstmt)+' join itemprd on bmllvl1 = ipitem';
          when wocntr = 3;
          eval sqlstmt = %trim(sqlstmt)+' join itemprd on bmllvl2 = ipitem';
          when wocntr = 4;
          eval sqlstmt = %trim(sqlstmt)+' join itemprd on bmllvl3 = ipitem';
          when wocntr = 5;
          eval sqlstmt = %trim(sqlstmt)+' join itemprd on bmllvl4 = ipitem';
          when wocntr = 6;
          eval sqlstmt = %trim(sqlstmt)+' join itemprd on bmllvl5 = ipitem';
          when wocntr = 7;
          eval sqlstmt = %trim(sqlstmt)+' join itemprd on bmllvl6 = ipitem';
          when wocntr = 8;
          eval sqlstmt = %trim(sqlstmt)+' join itemprd on bmllvl7 = ipitem';
          when wocntr = 9;
          eval sqlstmt = %trim(sqlstmt)+' join itemprd on bmllvl8 = ipitem';
          when wocntr = 10;
          eval sqlstmt = %trim(sqlstmt)+' join itemprd on bmllvl9 = ipitem';
          when wocntr = 11;
          eval sqlstmt = %trim(sqlstmt)+' join itemprd on bmllvl10 = +
                                                     ipitem';
          endsl;
          if item = *off;
          select;
          when wocntr = 1;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmlfg = ititem';
          when wocntr = 2;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl1 = ititem';
          when wocntr = 3;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl2 = ititem';
          when wocntr = 4;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl3 = ititem';
          when wocntr = 5;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl4 = ititem';
          when wocntr = 6;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl5 = ititem';
          when wocntr = 7;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl6 = ititem';
          when wocntr = 8;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl7 = ititem';
          when wocntr = 9;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl8 = ititem';
          when wocntr = 10;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl9 = ititem';
          when wocntr = 11;
          eval sqlstmt = %trim(sqlstmt)+' join piritem on bmllvl10 = +
                                   ititem';
          endsl;
          endif;
          // *************************************************************
             eval sqlstmt = %trim(sqlstmt) + ' where ipprdflg in  +
                 (''F'',''R'',''C'')';
          // *************************************************************
         if item = *off;
           eval sqlstmt = %trim(sqlstmt) + ' and ucase(itdesc) like';
           eval sqlstmt = %trim(sqlstmt) + ' '''+'%';
           eval sqlstmt = %trim(sqlstmt) + %trim(pFinGood);
           eval sqlstmt = %trim(sqlstmt) + '%'+'''';
         else;
           select;
           when wocntr = 1;
             eval sqlstmt = %trim(sqlstmt) + ' and bmlfg = ';
           when wocntr = 2;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl1 = ';
           when wocntr = 3;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl2 = ';
           when wocntr = 4;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl3 = ';
           when wocntr = 5;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl4 = ';
           when wocntr = 6;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl5 = ';
           when wocntr = 7;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl6 = ';
           when wocntr = 8;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl7 = ';
           when wocntr = 9;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl8 = ';
           when wocntr = 10;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl9 = ';
           when wocntr = 11;
             eval sqlstmt = %trim(sqlstmt) + ' and bmllvl10 = ';
           endsl;
           eval sqlstmt = %trim(sqlstmt) + '''';
           eval sqlstmt = %trim(sqlstmt) + %trim(pFinGood);
           eval sqlstmt = %trim(sqlstmt) + '''';
         endif;
         if wocntr < 11;
         eval sqlstmt = %trim(sqlstmt) + ' union ';
         endif;
         enddo;

         //eval sqlstmt = %trim(sqlstmt) + ' order by wrmfgno, writem';
         //eval length = %len(%trim(sqlstmt));
         //execute sql
         exsr GetWOBOMR;
         pFinGood = orgFinGood;
         endsr;
         //
         begsr GetWOBOMR;
            cntr3c = 0;
            wcmd = pcmd;
            whse = %dec(pwhse:3:0);
            exec sql Close cursor4;
            exec sql Declare cursor4 scroll cursor for mainStmt4;
            exec sql Prepare mainStmt4 from :Sqlstmt;
            exec sql Open cursor4;
            exec sql fetch next from cursor4 for 1000 rows into :bomdata;
         //
          //enddo;
            exec sql Close cursor4;
            datacntr = 0;
            dou datacntr = 1000;
               datacntr = datacntr + 1;
               wrkdata = bomdata(datacntr);
               if wtoplevel = *blanks;
                  leave;
               endif;
               chain(N) (whse:wtoplevel) itemprd itmprd;
               if itmprd.ipprdflg = 'F';
                 pcmd = 'BI';
                 arr = *blanks;  // main array
                 arr2 = *blanks; // component array
                 arr3w = *blanks; // workOrder array
                 arr3c = *blanks; // components in workorder array
                 acntr = '000';  // main array counter
                 acntr2 = '000'; // component array coutner
                 lvlcntr = '000';  // level counter
                 pFinGood = wtoplevel;
                 exsr doBOM;
                 cntr3w = 0;
                 dow forever = forever;
                    cntr3w = cntr3w + 1;
                    if arr(cntr3w) = *blanks;
                      leave;
                    endif;
                    if arr(cntr3w) = 'X';
                      iter;
                    endif;
                    if %lookup(arr(cntr3w): arr4w)= 0;
                       cntr3c = cntr3c+1;
                       arr4w(cntr3c)= arr(cntr3w);
                    endif;
                 enddo;
            //   leave;
               else;
                 cntr = 0;
                 dou cntr = 11;
                    cntr = cntr + 1;
                    select;
                    when cntr = 1;
                         workcomp = wtoplevel;
                    when cntr = 2;
                         workcomp = wlevel1;
                    when cntr = 3;
                         workcomp = wlevel2;
                    when cntr = 4;
                         workcomp = wlevel3;
                    when cntr = 5;
                         workcomp = wlevel4;
                    when cntr = 6;
                         workcomp = wlevel5;
                    when cntr = 7;
                         workcomp = wlevel6;
                    when cntr = 8;
                         workcomp = wlevel7;
                    when cntr = 9;
                         workcomp = wlevel8;
                    when cntr = 10;
                         workcomp = wlevel9;
                    when cntr = 11;
                         workcomp = wlevel10;
                    endsl;
                    if workcomp = *blanks;
                      leave;
                    endif;
                    chain(N) (whse:workcomp) itemprd itmprd;
                    if itmprd.ipprdflg = 'C';
                       if %lookup(workcomp: arr4w)= 0;
                          cntr3c = cntr3c+1;
                          arr4w(cntr3c) = workcomp;
                       endif;
                    endif;
                    if itmprd.ipprdflg = 'R';
                       if %lookup(workcomp: arr4w)= 0;
                          cntr3c = cntr3c+1;
                          arr4w(cntr3c) = workcomp;
                       endif;
                    endif;
                    enddo;
               endif;
            enddo;
            arr3w = arr4w;
         endsr;
      /end-free
       //
     p pCompontWo      e
