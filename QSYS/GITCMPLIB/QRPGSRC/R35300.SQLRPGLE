      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  R35300 -  Calls UPDSUM011 to build work file for Selector Accuracy Report
     *  25 Mar 2020
     *  Kenneth Elder
     *
     *  Revisions:
     *
740 A*    03/25/20  KDE  7.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk
     fpiruser1  if   e           k disk
     flabel     if   e           k disk
     fordd      if   e           k disk
     forrtn6    if   e           k disk
     frunner6   if   e           k disk
     fpirtran   if   e           k disk
     frtncode   if   e           k disk
     fr35300wf  o    e           k disk

      /copy qcopysrc,c#stdvar
      *copy qcopysrc,c#stdsql

     *----------------------------------------------------------
     *  SQL record layouts referenced
     *----------------------------------------------------------

     D smrec         E Ds                  Extname(sum011)

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d dbgflgExists    s               n
     d debug           s               n
     d debugAfter      s               n
     d debugBefore     s               n
     d debugLoc        s              1

     D cmd             s              3
     d errMsg          s             99
     d dpCombo         s             20    varying
     d lu              s              5  0
     d ne              s              5  0
     d rc              s              5  0
     d tl              s              5  0
     d whse            s              3  0
     d trannum         s              7  0
     d rteid           s              5
     d pallid          s              7  0
     d emplist         s            500
     d rtnlist         s            196
     d fdatetime       s             14
     D sqlSuccess      c                   '00000'
     D SqlStmt         s           2000    inz(' ')
     d tdatetime       s             14
     d frtndate        s              8
     d trtndate        s              8
     d frtndaten       s              8  0
     d trtndaten       s              8  0
     d rfvoice         s              1
     d upcexists       s              1
     d voerrors        s              1
     d item            s             15
     d sessid          s             40
     d wkemp           s              8
     d hdcount         s              2  0
     d sectionDesc     s             40
     d wkrqty1         s                    like(smqpck)
     d wkrqty          s                    like(smqpck)
     d wklboe          s                    like(smlboe)
     d wkqpck          s                    like(smqpck)
     d wkqty           s                    like(smqpck)
     d wkqyfd          s                    like(smqyfd)
     d wksection       s              3
     d wktotreturns    s              5  0
     d wkrtnpct        s              5  2
     d wktype          s              1

720 A *----------------------------------------------------------------
720 A *  Section/Employee Array with Pick Quantities
720 A *----------------------------------------------------------------
720 AD                 ds
720 Ad secEmp                               dim(2500)
720 AD  empSection                    3     overlay(secEmp:*next)
720 AD  empNumA                       8     overlay(secEmp:*next)
720 Ad  empName                      40     overlay(secEmp:*next)
720 Ad  empQtyP                       5  0  overlay(secEmp:*next)
720 Ad  empQtyB                       5  0  overlay(secEmp:*next)
720 Ad  empQtyS                       5  0  overlay(secEmp:*next)
720 Ad  empQtyR                       5  0  overlay(secEmp:*next)

720 A *----------------------------------------------------------------
720 A *  Return Code Array
720 A *----------------------------------------------------------------
720 AD                 ds
720 Ad rtnCdAry                             dim(52)
720 AD  rtnCde                        2     overlay(rtnCdAry:*next)
720 AD  rtnDesc                      30     overlay(rtnCdAry:*next)

720 A *----------------------------------------------------------------
720 A *  Return Code Quantities Array
720 A *----------------------------------------------------------------
720 AD                 ds
720 Ad rtnCdQty                             dim(2500)
720 AD  rtn1Qty                       5  0  overlay(rtnCdQty:*next)
720 AD  rtn2Qty                       5  0  overlay(rtnCdQty:*next)
720 AD  rtn3Qty                       5  0  overlay(rtnCdQty:*next)
720 AD  rtn4Qty                       5  0  overlay(rtnCdQty:*next)
720 AD  rtn5Qty                       5  0  overlay(rtnCdQty:*next)
720 AD  rtn6Qty                       5  0  overlay(rtnCdQty:*next)
720 AD  rtn7Qty                       5  0  overlay(rtnCdQty:*next)
720 AD  rtn8Qty                       5  0  overlay(rtnCdQty:*next)
720 AD  rtn9Qty                       5  0  overlay(rtnCdQty:*next)
720 AD  rtn10Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn11Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn12Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn13Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn14Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn15Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn16Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn17Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn18Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn19Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn20Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn21Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn22Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn23Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn24Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn25Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn26Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn27Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn28Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn29Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn30Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn31Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn32Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn33Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn34Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn35Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn36Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn37Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn38Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn39Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn40Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn41Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn42Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn43Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn44Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn45Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn46Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn47Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn48Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn49Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn50Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn51Qty                      5  0  overlay(rtnCdQty:*next)
720 AD  rtn52Qty                      5  0  overlay(rtnCdQty:*next)

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d DeleteRecs      pr

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pParmStr    String of '|' delimited parameters
     *
     *    Returned Parameters
     *      pOutStr     Return string in JSON format
     *
     *----------------------------------------------------------------

     D r35300          pr                  extpgm('R35300')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D r35300          pi
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

     d ExtractParms    pr

     d ExtractParmStr  pr

     d WrtBeforeDebug  pr
     d WrtAfterDebug   pr
     d WrtDebugError   pr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         errMsg = ' ';

         debug = *off;
         debugBefore = *off;
         debugAfter = *off;
         if dbgflgExists;
           chain(e) (#pgm) bfcdbgflg;
           if %found(bfcdbgflg);
             select;
               when bdfflag = 1;
                 debug = *on;
                 debugAfter = *on;
               when bdfflag = 2;
                 debug = *on;
                 debugBefore = *on;
               when bdfflag = 3;
                 debug = *on;
                 debugBefore = *on;
                 debugAfter = *on;
             endsl;
           endif;
         endif;

         // **** FOR TESTING ****
         debugAfter = *on;

         // Combine dictionary/program

         dpCombo = %trim(pDict) + '.' + pPgm;

         // Write out 'Before' Debug info

         if debugBefore;
           debugLoc = 'B';
           wrtBeforeDebug();
         endif;

         // Extract parameters from delimited string

         ExtractParms();

         pOutStr = '{'
                 +    '"errMsg":"' + errMsg + '"'
                 + '}';

         // Get out if error

         if errMsg <> '';
           pOutStr = '{"errMsg":"' + errMsg + '"}';
           WrtDebugError();
           return;
         endif;

         sessid = pSessid;
         // call UPDSUM011 to Build SUM010 work file to retrieve
         // picking information required from Daily Picking Selection Report
      /end-free
     c                   if        cmd<>'PHL'
     c                   call      'UPDSUM011'
     c                   parm                    errMsg
     c                   parm                    SessId
     c                   parm                    whse
     c                   parm      0             trannum
     c                   parm      ' '           rteid
     c                   parm      0             pallid
     c                   parm      ' '           emplistx        500
     c                   parm                    rtnlist
     c                   parm                    fdatetime
     c                   parm                    tdatetime
     c                   parm      'B'           rfvoice
     c                   parm      'B'           upcexists
     c                   parm      'B'           voerrors
     c                   parm      ' '           item
     c                   endif
      /free
         // get count of return codes
         exec sql select count(*) into :hdcount
               from rtncode;
         hdcount=hdcount+6;
         select;
           when cmd='PHL';
             // Format Heading and return to caller in poutstr
             exsr hdrJson;
           other;
             // now create all data to generate work file for actual report
             DeleteRecs();
             exsr zzinz;
             exsr crtArrays;
             exsr wrtWf;
             pOutStr = '{'
                     +    '"hdcount":"' + %editc(hdcount:'X') + '",'
                     +    '"errMsg":"' + errMsg + '"'
                     + '}';
         endsl;

         // Write out 'After' Debug info

         if debugAfter;
           debugLoc = 'A';
           wrtAfterDebug();
         endif;

         return;

      /end-free

730aA*----------------------------------------------------------------
730aA*  zzInz - Initialize arrays
730aA*----------------------------------------------------------------

      /free
       begsr zzInz;

         // Load Retursn Code Control table in an Array
         lu=1;
         setll *loval rtncode;
         dow forever=forever;
           read rtncode;
           if %eof(rtncode);
             leave;
           endif;
           if lu<1 or lu>49;
             leave;
           endif;
           rtnCde(lu) = rncode;
           rtnDesc(lu) = rndesc;
           lu = lu +1;
         enddo;
         // If it made it to 50 we use 50 as catch all beyond 50
         if lu = 50;
           rtnDesc(lu) = 'Others';
         endif;

         // Initialize zero arrays
         lu=1;
         dow lu < 2501;
           empQtyp(lu)=0;
           empQtyB(lu)=0;
           empQtyS(lu)=0;
           empQtyR(lu)=0;
           rtn1Qty(lu)=0;
           rtn2Qty(lu)=0;
           rtn3Qty(lu)=0;
           rtn4Qty(lu)=0;
           rtn5Qty(lu)=0;
           rtn6Qty(lu)=0;
           rtn7Qty(lu)=0;
           rtn8Qty(lu)=0;
           rtn9Qty(lu)=0;
           rtn10Qty(lu)=0;
           rtn11Qty(lu)=0;
           rtn12Qty(lu)=0;
           rtn13Qty(lu)=0;
           rtn14Qty(lu)=0;
           rtn15Qty(lu)=0;
           rtn16Qty(lu)=0;
           rtn17Qty(lu)=0;
           rtn18Qty(lu)=0;
           rtn19Qty(lu)=0;
           rtn20Qty(lu)=0;
           rtn21Qty(lu)=0;
           rtn22Qty(lu)=0;
           rtn23Qty(lu)=0;
           rtn24Qty(lu)=0;
           rtn25Qty(lu)=0;
           rtn26Qty(lu)=0;
           rtn27Qty(lu)=0;
           rtn28Qty(lu)=0;
           rtn29Qty(lu)=0;
           rtn30Qty(lu)=0;
           rtn31Qty(lu)=0;
           rtn32Qty(lu)=0;
           rtn33Qty(lu)=0;
           rtn34Qty(lu)=0;
           rtn35Qty(lu)=0;
           rtn36Qty(lu)=0;
           rtn37Qty(lu)=0;
           rtn38Qty(lu)=0;
           rtn39Qty(lu)=0;
           rtn40Qty(lu)=0;
           rtn41Qty(lu)=0;
           rtn42Qty(lu)=0;
           rtn43Qty(lu)=0;
           rtn44Qty(lu)=0;
           rtn45Qty(lu)=0;
           rtn46Qty(lu)=0;
           rtn47Qty(lu)=0;
           rtn48Qty(lu)=0;
           rtn49Qty(lu)=0;
           rtn50Qty(lu)=0;
           rtn51Qty(lu)=0;
           rtn52Qty(lu)=0;
           lu=lu+1;
         enddo;

       endsr;
      /end-free

730aA*----------------------------------------------------------------
730aA*  AddRtns   Add returns.  If original label entered then update
730aA*            existing record in SUM011
730aA*----------------------------------------------------------------

      /free
       begsr addRtns;
730aA
730aA   // Loop thru Returns for passed in Return Date range
730aA   setll (Whse:frtndaten) orrtn6;
730aA   dow forever=forever;
730aA
730aA     read orrtn6;
730aA     if %eof(orrtn6);
730aA       leave;
730aA     endif;

          // if outside of date range then leave
          if orrdte<fRtnDaten or orrdte>tRtnDaten;
            leave;
          endif;
730aA
730aA     // if Return codes were selected only show them
730aA     if RtnList<>*blanks and %trim(RtnList)<>'NULL';
730aA       if %scan(%trim(orrcod):RtnList) = 0;
730aA         iter;
730aA       endif;
730aA     else;
730aA     endif;
730aA
730aA     // setup return quantity based on case and breakdowns
730aA     wkrqty=orqty1;
730aA
730aA     // if original label is populated then
730aA     // add to either current picker totals if
730aA     // in current pick data range, otherwise add
          // record in section six of array
730aA     if orolb#<>0;
            // see if in current pick date data
            exec sql select smlboe,smlboq,smqyfd into
                           :wklboe,:wkqpck,:wkqyfd
                  from sum011
                   where smsessid=:sessid and smlbl#=:orolb#;
            if sqlstt = '00000';
              exsr getlabel;
              wkemp=*blanks;
              select;
                when wklboe<>0;
                  wkemp = 'S1D' + %editc(wklboe:'X');
                when wkqyfd<>0;
                  chain (lbwhse:lblbl#) runner6;
                  if %found(runner6);
730aA               chain (rutrn#) pirtran;
730aA               if %found(pirtran);
                      wkemp = 'S1D' + %editc(ptemp#:'X');
                    endif;
                  endif;
              endsl;
              // skip if employees selected and not in list
              if (empList<>*blanks and %scan(%editc(ptemp#:'X'):empList)=0);
                iter;
              endif;
              // lookup in employee
              lu=%lookup(wkemp:empNumA);
              if lu=0;
                ne=ne+1;
                lu=ne;
              endif;
              // now go add totals to the appropriate returns bucket for employee
              exsr rtnqty;
            else;
              // Now create record for returns that have labels but outside of
              // the current pick date range
              exsr getlabel;
              // skip if employees selected and not in list
              if (empList<>*blanks and %scan(%editc(ptemp#:'X'):empList)=0);
                iter;
              endif;
              wksection='S1D';
              wkemp='S1D' + %editc(ptemp#:'X');
              lu=%lookup(wkemp:empNumA);
              if lu=0;
                if ptemp#=0 and empList=*blanks;
                  // add to S4 No Label Return if employee is zero
                  wksection='S4D';
                  wkemp='S4D';
                  lu=%lookup(wkemp:empNumA);
                  if lu=0;
                    ne=ne+1;
                    lu=ne;
                  endif;
                else;
                  if (empList<>*blanks and
                          %scan(%editc(ptemp#:'X'):empList)<>0)
                      or empList=*blanks;
                    wksection='S6D';
                    wkemp='S6D' + %editc(ptemp#:'X');
                    lu=%lookup(wkemp:empNumA);
                    if lu=0;
                      ne=ne+1;
                      lu=ne;
                    endif;
                  endif;
                endif;
              endif;
              monitor;
                empSection(lu)=wksection;
              on-error;
                iter;
              endmon;
              empNumA(lu) = wkemp;
              chain ptemp# piruser1;
              if %found(piruser1);
                empName(lu) = %trim(usfnam) + ' ' + %trim(uslnam);
              else;
                empName(lu) = *blanks;
              endif;
              if wksection='S6D' or wksection='S4D';
                empQtyB(lu)=0;
                empQtyS(lu)=0;
                empQtyP(lu)=0;
                empQtyR(lu)=0;
              endif;
              exsr rtnQty;
            endif;
          else;
            if empList=*blanks;
              // Accumulate No Label Returns - Section 4
              wkemp='S4D';
              lu=%lookup(wkemp:empNumA);
              if lu=0;
                ne=ne+1;
                lu=ne;
              endif;
              empSection(lu)='S4D';
              empNumA(lu)='S4D';
              empName(lu)=*blanks;
              empQtyB(lu)=0;
              empQtyS(lu)=0;
              empQtyP(lu)=0;
              empQtyR(lu)=0;
              exsr rtnQty;
            endif;
730aA     endif;
730aA
730aA   enddo;
730aA
730aA  endsr;
730aA
730aA /end-free
730aA
     *----------------------------------------------------------------
     *  crtArrays  -  Create Arrays used to generate final work file
     *----------------------------------------------------------------

      /free
       begsr crtArrays;

         // First loop through data just generated with date range pick data
         // This represents section one "Date Range Picks"
         ne=0;          // Next Array Element available
         lu=0;          // Lookup element
         sqlstmt = 'select * from sum011 where smsessid=' + sq +
                   %trim(sessid) + sq + ' and (smlboq<>0 or smqyfd<>0 or' +
                                           ' smqpck<>0)';
         exec sql PREPARE em FROM :SqlStmt;
         exec sql DECLARE emp SCROLL CURSOR FOR em;
         exec sql OPEN emp;

         dow forever = forever;
           exec sql fetch next from emp into :smrec;

           if sqlstt <> '00000';
             leave;
           endif;

           // get label and order detail information
           chain smlbl# label;
           if not %found(label);
             lbtype='O';
             odoitm=*blanks;
           else;
             chain (lbwhse:lbord:lbseq:lbitem) ordd;
             if not %found(ordd);
               odoitm=*blanks;
             endif;
           endif;
           // add Quantitiy record to Array
             wkemp=*blanks;
             if smlboq<>0 or smqpck<>0;
               wktype='P';     // Type "P" for Pick Quantity
               wkemp='S1D' + %editc(smlboe:'X');
               ptemp# = smlboe;
               if smlboq=0;
                 wkqty=smqpck-smqyfd;
               else;
                 wkqty=smlboq;
               endif;
               wksection='S1D';
               exsr crtQtyEntry;
             endif;
             if smqyfd<>0;
               wktype='R';     // Type "R" for Runner Quantity
               chain (lbwhse:smlbl#) runner6;
               if %found(runner6);
                 if rutrn#=0;
730aA              chain (ruotrn) pirtran;
                 else;
730aA              chain (rutrn#) pirtran;
                 endif;
730aA            if %found(pirtran);
                   wkemp = 'S1D' + %editc(ptemp#:'X');
                 else;
                   wkemp = 'S1D' + '00000';
                 endif;
               else;
                 chain (smtrn#) pirtran;
730aA            if %found(pirtran);
                   wkemp = 'S1D' + %editc(ptemp#:'X');
                 else;
                   wkemp = 'S1D' + '00000';
                 endif;
               endif;
               wkqty=smqyfd;
               wksection='S1D';
               exsr crtQtyEntry;
             endif;
         enddo;
         exec sql close emp;

         // Now add data from Returns
         exsr AddRtns;

       endsr;

      /end-free

     *----------------------------------------------------------------
     *  crtQtyEntry  -  Create Qty record entry
     *----------------------------------------------------------------

      /free
       begsr crtQtyEntry;
         if wkemp=*blanks or %subst(wkemp:3:5)='00000';
           if (smlboq<>0 or smqyfd<>0);
              wkemp = 'S5D';
              // lookup in employee
              lu=%lookup(wkemp:empNuma);
              if lu=0;
                ne=ne+1;
                lu=ne;
              endif;
             wksection = 'S5D';
             empNuma(lu) = 'S5D';
             empName(lu) = *blanks;
           endif;
         else;
           lu=%lookup(wkemp:empNuma);
           if lu=0;
             ne=ne+1;
             lu=ne;
             empNumA(lu) = wkemp;
             chain ptemp# piruser1;
             if %found(piruser1);
               empName(lu) = %trim(usfnam) + ' ' + %trim(uslnam);
             else;
               empName(lu) = *blanks;
             endif;
           endif;
         endif;
         // determine if normal quantity, bulk or sub item
         select;
           when wktype='R';   // Runner Qty Picked
             if empList=*blanks or
                empList<>*blanks and %scan(%editc(ptemp#:'X'):empList)<>0;
               monitor;
                 empQtyR(lu) = empQtyR(lu) + wkqty;
               on-error;
               endmon;
             endif;
           when lbtype='B';   // Bulk Pick
             monitor;
               empQtyb(lu) = empQtyb(lu) + wkqty;
             on-error;
             endmon;
           when odoitm <> *blanks;  // Sub Item Pick
             monitor;
               empQtyS(lu) = empQtyS(lu) + wkqty;
             on-error;
             endmon;
           other;
             monitor;
               empQtyP(lu) = empQtyP(lu) + wkqty;
             on-error;
             endmon;
         endsl;
         empSection(lu) = wksection;
       endsr;
730aA /end-free

730aA*----------------------------------------------------------------
730aA*  getlabel   Get label record as required
730aA*             outside of date range
730aA*----------------------------------------------------------------
730aA
730aA /free
730aA
730aA  begsr getlabel;
730aA
730aA    chain (orolb#) label;
730aA    if not %found(label);
730aA      clear lbrec;
730aA    endif;

         chain (lbtrn#) pirtran;
         if not %found(pirtran);
           clear ptrec;
         endif;
730aA
730aA  endsr;
730aA /end-free
730aA
     *----------------------------------------------------------------
     *  rtnQty  -  Add return quantities to correct bucket
     *----------------------------------------------------------------

      /free
       begsr rtnQty;

          rc = %lookup(orrcod:rtnCde);
          select;
            when rc = 1;
              rtn1Qty(lu) = rtn1Qty(lu) + wkrqty;
            when rc = 2;
              rtn2Qty(lu) = rtn2Qty(lu) + wkrqty;
            when rc = 3;
              rtn3Qty(lu) = rtn3Qty(lu) + wkrqty;
            when rc = 4;
              rtn4Qty(lu) = rtn4Qty(lu) + wkrqty;
            when rc = 5;
              rtn5Qty(lu) = rtn5Qty(lu) + wkrqty;
            when rc = 6;
              rtn6Qty(lu) = rtn6Qty(lu) + wkrqty;
            when rc = 7;
              rtn7Qty(lu) = rtn7Qty(lu) + wkrqty;
            when rc = 8;
              rtn8Qty(lu) = rtn8Qty(lu) + wkrqty;
            when rc = 9;
              rtn9Qty(lu) = rtn9Qty(lu) + wkrqty;
            when rc = 10;
              rtn10Qty(lu) = rtn10Qty(lu) + wkrqty;
            when rc = 11;
              rtn11Qty(lu) = rtn11Qty(lu) + wkrqty;
            when rc = 12;
              rtn12Qty(lu) = rtn12Qty(lu) + wkrqty;
            when rc = 13;
              rtn13Qty(lu) = rtn13Qty(lu) + wkrqty;
            when rc = 14;
              rtn14Qty(lu) = rtn14Qty(lu) + wkrqty;
            when rc = 15;
              rtn15Qty(lu) = rtn15Qty(lu) + wkrqty;
            when rc = 16;
              rtn16Qty(lu) = rtn16Qty(lu) + wkrqty;
            when rc = 17;
              rtn17Qty(lu) = rtn17Qty(lu) + wkrqty;
            when rc = 18;
              rtn18Qty(lu) = rtn18Qty(lu) + wkrqty;
            when rc = 19;
              rtn19Qty(lu) = rtn19Qty(lu) + wkrqty;
            when rc = 20;
              rtn20Qty(lu) = rtn20Qty(lu) + wkrqty;
            when rc = 21;
              rtn21Qty(lu) = rtn21Qty(lu) + wkrqty;
            when rc = 22;
              rtn22Qty(lu) = rtn22Qty(lu) + wkrqty;
            when rc = 23;
              rtn23Qty(lu) = rtn23Qty(lu) + wkrqty;
            when rc = 24;
              rtn24Qty(lu) = rtn24Qty(lu) + wkrqty;
            when rc = 25;
              rtn25Qty(lu) = rtn25Qty(lu) + wkrqty;
            when rc = 26;
              rtn26Qty(lu) = rtn26Qty(lu) + wkrqty;
            when rc = 27;
              rtn27Qty(lu) = rtn27Qty(lu) + wkrqty;
            when rc = 28;
              rtn28Qty(lu) = rtn28Qty(lu) + wkrqty;
            when rc = 29;
              rtn29Qty(lu) = rtn29Qty(lu) + wkrqty;
            when rc = 30;
              rtn30Qty(lu) = rtn30Qty(lu) + wkrqty;
            when rc = 31;
              rtn31Qty(lu) = rtn31Qty(lu) + wkrqty;
            when rc = 32;
              rtn32Qty(lu) = rtn32Qty(lu) + wkrqty;
            when rc = 33;
              rtn33Qty(lu) = rtn33Qty(lu) + wkrqty;
            when rc = 34;
              rtn34Qty(lu) = rtn34Qty(lu) + wkrqty;
            when rc = 35;
              rtn35Qty(lu) = rtn35Qty(lu) + wkrqty;
            when rc = 36;
              rtn36Qty(lu) = rtn36Qty(lu) + wkrqty;
            when rc = 37;
              rtn37Qty(lu) = rtn37Qty(lu) + wkrqty;
            when rc = 38;
              rtn38Qty(lu) = rtn38Qty(lu) + wkrqty;
            when rc = 39;
              rtn39Qty(lu) = rtn39Qty(lu) + wkrqty;
            when rc = 40;
              rtn40Qty(lu) = rtn40Qty(lu) + wkrqty;
            when rc = 41;
              rtn41Qty(lu) = rtn41Qty(lu) + wkrqty;
            when rc = 42;
              rtn42Qty(lu) = rtn42Qty(lu) + wkrqty;
            when rc = 43;
              rtn43Qty(lu) = rtn43Qty(lu) + wkrqty;
            when rc = 44;
              rtn44Qty(lu) = rtn44Qty(lu) + wkrqty;
            when rc = 45;
              rtn45Qty(lu) = rtn45Qty(lu) + wkrqty;
            when rc = 46;
              rtn46Qty(lu) = rtn46Qty(lu) + wkrqty;
            when rc = 47;
              rtn47Qty(lu) = rtn47Qty(lu) + wkrqty;
            when rc = 48;
              rtn48Qty(lu) = rtn48Qty(lu) + wkrqty;
            when rc = 49;
              rtn49Qty(lu) = rtn49Qty(lu) + wkrqty;
            other;
              // if returns exceed count of 49 all other placed in element 50
              rtn50Qty(lu) = rtn50Qty(lu) + wkrqty;
          endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  hdrJson - Return json formatted Header
     *----------------------------------------------------------------

      /free
       begsr hdrJson;
         // Loop through Returns Control file for Return Codes
         setll *loval rtncode;
         pOutStr = '{"h1":"Section","h2":"Number","h3":"Name",'
                + '"h4":"Normal","h5":"Bulk","h6":"Sub","h6a":"Runner"';
         lu=1;
         dow forever = forever;
           read rtncode;
           if %eof(rtncode);
             leave;
           endif;
           pOutStr = %trim(pOutStr) + ',"h' + %char(lu+6) + '":"' +
                    rncode + '"';
           lu=lu+1;
           // only defined for up to 50 return codes.  Handles 49 separate codes
           // and puts all other in element 50
           if lu > 49;
             leave;
           endif;
         enddo;
         // If count at 50 then add Other heading as catch all
         if lu=50;
           pOutStr = %trim(pOutStr) + ',"h' + %char(lu+6) + '":"' +
                    'Others' + '"';
           lu=lu+1;
         endif;
         // if below 52 then add Total returns column and accuracy % column
         if lu<52;
           pOutStr = %trim(pOutStr) + ',"h' + %char(lu+6) + '":"' +
                    'Returns' + '"';
           lu=lu+1;
           pOutStr = %trim(pOutStr) + ',"h' + %char(lu+6) + '":"' +
                    'Accuracy' + '"';
         endif;
         pOutStr=%trim(pOutStr) + ',"hdcount":"' + %editc(hdcount+2:'X') + '"';
         pOutStr = %trim(pOutStr) + '}';
         return;
       endsr;
       /end-free

     *----------------------------------------------------------------
     *  crtTotLine - Generate Grand Total and section total lines
     *----------------------------------------------------------------

      /free
       begsr crtTotLine;

        // Since everything is managed manually outside of MRC normal
        // flow this creates the Section total for Selector Totals and
        // the Grand Total line that is processed as part of the Detail
        // in BFCREPORTS.R353xx.  There is freemarker code that determines
        // whether it should print ased on whether user clicked for Grand
        // Total and/or Section Totals

        // Grand Total Line
         wkemp = 'Z1T';
         lu=%lookup(wkemp:empNuma);
         if lu=0;
           ne=ne+1;
           lu=ne;
         endif;
         empNumA(lu)='Z1T';
         empSection(lu)='Z1T';
         empName(lu)=*blanks;
         tl=1;
         dow tl < 2501;
           if ((empList=*blanks and empNumA(tl)<>'S1T' and empNumA(tl)<>'Z1T')
              or (empList<>*blanks and
                 %scan(%subst(empNumA(tl):4:5):empList)<>0)
               and empNumA(tl)<>'S1T' and empNumA(tl)<>'Z1T');
             empQtyP(lu) = empQtyP(lu) + empQtyP(tl);
             empQtyB(lu) = empQtyB(lu) + empQtyB(tl);
             empQtyS(lu) = empQtyS(lu) + empQtyS(tl);
             empQtyR(lu) = empQtyR(lu) + empQtyR(tl);
             rtn1Qty(lu) = rtn1Qty(lu) + rtn1Qty(tl);
             rtn2Qty(lu) = rtn2Qty(lu) + rtn2Qty(tl);
             rtn3Qty(lu) = rtn3Qty(lu) + rtn3Qty(tl);
             rtn4Qty(lu) = rtn4Qty(lu) + rtn4Qty(tl);
             rtn5Qty(lu) = rtn5Qty(lu) + rtn5Qty(tl);
             rtn6Qty(lu) = rtn6Qty(lu) + rtn6Qty(tl);
             rtn7Qty(lu) = rtn7Qty(lu) + rtn7Qty(tl);
             rtn8Qty(lu) = rtn8Qty(lu) + rtn8Qty(tl);
             rtn9Qty(lu) = rtn9Qty(lu) + rtn9Qty(tl);
             rtn10Qty(lu) = rtn10Qty(lu) + rtn10Qty(tl);
             rtn11Qty(lu) = rtn11Qty(lu) + rtn11Qty(tl);
             rtn12Qty(lu) = rtn12Qty(lu) + rtn12Qty(tl);
             rtn13Qty(lu) = rtn13Qty(lu) + rtn13Qty(tl);
             rtn14Qty(lu) = rtn14Qty(lu) + rtn14Qty(tl);
             rtn15Qty(lu) = rtn15Qty(lu) + rtn15Qty(tl);
             rtn16Qty(lu) = rtn16Qty(lu) + rtn16Qty(tl);
             rtn17Qty(lu) = rtn17Qty(lu) + rtn17Qty(tl);
             rtn18Qty(lu) = rtn18Qty(lu) + rtn18Qty(tl);
             rtn19Qty(lu) = rtn19Qty(lu) + rtn19Qty(tl);
             rtn20Qty(lu) = rtn20Qty(lu) + rtn20Qty(tl);
             rtn21Qty(lu) = rtn21Qty(lu) + rtn21Qty(tl);
             rtn22Qty(lu) = rtn22Qty(lu) + rtn22Qty(tl);
             rtn23Qty(lu) = rtn23Qty(lu) + rtn23Qty(tl);
             rtn24Qty(lu) = rtn24Qty(lu) + rtn24Qty(tl);
             rtn25Qty(lu) = rtn25Qty(lu) + rtn25Qty(tl);
             rtn26Qty(lu) = rtn26Qty(lu) + rtn26Qty(tl);
             rtn27Qty(lu) = rtn27Qty(lu) + rtn27Qty(tl);
             rtn28Qty(lu) = rtn28Qty(lu) + rtn28Qty(tl);
             rtn29Qty(lu) = rtn29Qty(lu) + rtn29Qty(tl);
             rtn30Qty(lu) = rtn30Qty(lu) + rtn30Qty(tl);
             rtn31Qty(lu) = rtn31Qty(lu) + rtn31Qty(tl);
             rtn32Qty(lu) = rtn32Qty(lu) + rtn32Qty(tl);
             rtn33Qty(lu) = rtn33Qty(lu) + rtn33Qty(tl);
             rtn34Qty(lu) = rtn34Qty(lu) + rtn34Qty(tl);
             rtn35Qty(lu) = rtn35Qty(lu) + rtn35Qty(tl);
             rtn36Qty(lu) = rtn36Qty(lu) + rtn36Qty(tl);
             rtn37Qty(lu) = rtn37Qty(lu) + rtn37Qty(tl);
             rtn38Qty(lu) = rtn38Qty(lu) + rtn38Qty(tl);
             rtn39Qty(lu) = rtn39Qty(lu) + rtn39Qty(tl);
             rtn40Qty(lu) = rtn40Qty(lu) + rtn40Qty(tl);
             rtn41Qty(lu) = rtn41Qty(lu) + rtn41Qty(tl);
             rtn42Qty(lu) = rtn42Qty(lu) + rtn42Qty(tl);
             rtn43Qty(lu) = rtn43Qty(lu) + rtn43Qty(tl);
             rtn44Qty(lu) = rtn44Qty(lu) + rtn44Qty(tl);
             rtn45Qty(lu) = rtn45Qty(lu) + rtn45Qty(tl);
             rtn46Qty(lu) = rtn46Qty(lu) + rtn46Qty(tl);
             rtn47Qty(lu) = rtn47Qty(lu) + rtn47Qty(tl);
             rtn48Qty(lu) = rtn48Qty(lu) + rtn48Qty(tl);
             rtn49Qty(lu) = rtn49Qty(lu) + rtn49Qty(tl);
             rtn50Qty(lu) = rtn50Qty(lu) + rtn50Qty(tl);
           endif;
           tl=tl+1;
         enddo;

        // S1 Section Total Line
         wkemp = 'S1T';
         lu=%lookup(wkemp:empNuma);
         if lu=0;
           ne=ne+1;
           lu=ne;
         endif;
         tl=1;
         dow tl < 2501;
           if empSection(tl) = 'S1D' and  (empList=*blanks or
              (empList<>*blanks and %scan(%subst(empNumA(tl):4:5):empList)<>0));
             empNumA(lu)='S1T';
             empSection(lu)='S1T';
             empName(lu)=*blanks;
             empQtyP(lu) = empQtyP(lu) + empQtyP(tl);
             empQtyB(lu) = empQtyB(lu) + empQtyB(tl);
             empQtyS(lu) = empQtyS(lu) + empQtyS(tl);
             empQtyR(lu) = empQtyR(lu) + empQtyR(tl);
             rtn1Qty(lu) = rtn1Qty(lu) + rtn1Qty(tl);
             rtn2Qty(lu) = rtn2Qty(lu) + rtn2Qty(tl);
             rtn3Qty(lu) = rtn3Qty(lu) + rtn3Qty(tl);
             rtn4Qty(lu) = rtn4Qty(lu) + rtn4Qty(tl);
             rtn5Qty(lu) = rtn5Qty(lu) + rtn5Qty(tl);
             rtn6Qty(lu) = rtn6Qty(lu) + rtn6Qty(tl);
             rtn7Qty(lu) = rtn7Qty(lu) + rtn7Qty(tl);
             rtn8Qty(lu) = rtn8Qty(lu) + rtn8Qty(tl);
             rtn9Qty(lu) = rtn9Qty(lu) + rtn9Qty(tl);
             rtn10Qty(lu) = rtn10Qty(lu) + rtn10Qty(tl);
             rtn11Qty(lu) = rtn11Qty(lu) + rtn11Qty(tl);
             rtn12Qty(lu) = rtn12Qty(lu) + rtn12Qty(tl);
             rtn13Qty(lu) = rtn13Qty(lu) + rtn13Qty(tl);
             rtn14Qty(lu) = rtn14Qty(lu) + rtn14Qty(tl);
             rtn15Qty(lu) = rtn15Qty(lu) + rtn15Qty(tl);
             rtn16Qty(lu) = rtn16Qty(lu) + rtn16Qty(tl);
             rtn17Qty(lu) = rtn17Qty(lu) + rtn17Qty(tl);
             rtn18Qty(lu) = rtn18Qty(lu) + rtn18Qty(tl);
             rtn19Qty(lu) = rtn19Qty(lu) + rtn19Qty(tl);
             rtn20Qty(lu) = rtn20Qty(lu) + rtn20Qty(tl);
             rtn21Qty(lu) = rtn21Qty(lu) + rtn21Qty(tl);
             rtn22Qty(lu) = rtn22Qty(lu) + rtn22Qty(tl);
             rtn23Qty(lu) = rtn23Qty(lu) + rtn23Qty(tl);
             rtn24Qty(lu) = rtn24Qty(lu) + rtn24Qty(tl);
             rtn25Qty(lu) = rtn25Qty(lu) + rtn25Qty(tl);
             rtn26Qty(lu) = rtn26Qty(lu) + rtn26Qty(tl);
             rtn27Qty(lu) = rtn27Qty(lu) + rtn27Qty(tl);
             rtn28Qty(lu) = rtn28Qty(lu) + rtn28Qty(tl);
             rtn29Qty(lu) = rtn29Qty(lu) + rtn29Qty(tl);
             rtn30Qty(lu) = rtn30Qty(lu) + rtn30Qty(tl);
             rtn31Qty(lu) = rtn31Qty(lu) + rtn31Qty(tl);
             rtn32Qty(lu) = rtn32Qty(lu) + rtn32Qty(tl);
             rtn33Qty(lu) = rtn33Qty(lu) + rtn33Qty(tl);
             rtn34Qty(lu) = rtn34Qty(lu) + rtn34Qty(tl);
             rtn35Qty(lu) = rtn35Qty(lu) + rtn35Qty(tl);
             rtn36Qty(lu) = rtn36Qty(lu) + rtn36Qty(tl);
             rtn37Qty(lu) = rtn37Qty(lu) + rtn37Qty(tl);
             rtn38Qty(lu) = rtn38Qty(lu) + rtn38Qty(tl);
             rtn39Qty(lu) = rtn39Qty(lu) + rtn39Qty(tl);
             rtn40Qty(lu) = rtn40Qty(lu) + rtn40Qty(tl);
             rtn41Qty(lu) = rtn41Qty(lu) + rtn41Qty(tl);
             rtn42Qty(lu) = rtn42Qty(lu) + rtn42Qty(tl);
             rtn43Qty(lu) = rtn43Qty(lu) + rtn43Qty(tl);
             rtn44Qty(lu) = rtn44Qty(lu) + rtn44Qty(tl);
             rtn45Qty(lu) = rtn45Qty(lu) + rtn45Qty(tl);
             rtn46Qty(lu) = rtn46Qty(lu) + rtn46Qty(tl);
             rtn47Qty(lu) = rtn47Qty(lu) + rtn47Qty(tl);
             rtn48Qty(lu) = rtn48Qty(lu) + rtn48Qty(tl);
             rtn49Qty(lu) = rtn49Qty(lu) + rtn49Qty(tl);
             rtn50Qty(lu) = rtn50Qty(lu) + rtn50Qty(tl);
           endif;
           tl=tl+1;
         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtWf -  Write Work File for report
     *----------------------------------------------------------------

      /free
       begsr wrtwf;
         // first we need to write Grand Ttoal Line to Arrays
         exsr crtTotLine;

         txsess = pSessid;
         txaddts=%timestamp();
         // Loop through arrays for Employees and Quantities
         // quantities to build report work file
         lu = 0;
         dow lu <2501;
           lu=lu+1;
           // Exit when hitting blank employee
           if empNuma(lu)=*blanks;
             leave;
           endif;
           // skip employee if not in list
           if empList <> *blanks and %scan(%subst(empNuma(lu):4:5):emplist)=0
               and empSection(lu)='S1D';
             iter;
           endif;
           // Build bar separated text string with Employee Information
           select;
             when empSection(lu) = 'S1D';
               sectionDesc = 'S1DSelector Pick Totals';
             when empSection(lu) = 'S4D';
               sectionDesc = 'S4DNo Label Return';
             when empSection(lu) = 'S5D';
               sectionDesc = 'S5DPicked without Scan';
             when empSection(lu) = 'S6D';
               sectionDesc = 'S6DRtns by picker with no current Picks';
             when empSection(lu) = 'Z1T';
               sectionDesc = 'Z1TGrand Total';
             when empSection(lu) = 'S1T';
               sectionDesc = 'S1TSelector Totals';
             other;
               sectionDesc = empSection(lu);
           endsl;
           txdata = '{"psec":"' + %trim(sectionDesc) + '",' +
                    '"pNum":"' + %trim(empNumA(lu)) + '",' +
                    '"pNam":"' + %trim(empName(lu)) + '",';
           if empQtyP(lu) <> *zeros;
             txdata = %trim(txdata) +
                      '"pQp":"' + %char(empQtyP(lu)) + '",';
           else;
             txdata = %trim(txdata) + '"pQp":"",';
           endif;
           if empQtyB(lu) <> *zeros;
             txdata = %trim(txdata) +
                      '"pQb":"' + %char(empQtyB(lu)) + '",';
           else;
             txdata = %trim(txdata) + '"pQb":"",';
           endif;
           if empQtyS(lu) <> *zeros;
             txdata = %trim(txdata) +
                      '"pQs":"' + %char(empQtyS(lu)) + '",';
           else;
             txdata = %trim(txdata) + '"pQs":"",';
           endif;
           if empQtyR(lu) <> *zeros;
             txdata = %trim(txdata) +
                      '"pQr":"' + %char(empQtyR(lu)) + '"';
           else;
             txdata = %trim(txdata) + '"pQr":""';
           endif;
           // now add return quantity information
           //loop all 50 return code arrays
           wktotreturns=0;
           rc=1;
           dow rc<51;
             select;
               when rc=1;
                 if rtn1Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR1":"' + %char(rtn1Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR1":""';
                 endif;
                 wktotreturns=wktotreturns+rtn1Qty(lu);
               when rc=2;
                 if rtn2Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR2":"' + %char(rtn2Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR2":""';
                 endif;
                 wktotreturns=wktotreturns+rtn2Qty(lu);
               when rc=3;
                 if rtn3Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR3":"' + %char(rtn3Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR3":""';
                 endif;
                 wktotreturns=wktotreturns+rtn3Qty(lu);
               when rc=4;
                 if rtn4Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR4":"' + %char(rtn4Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR4":""';
                 endif;
                 wktotreturns=wktotreturns+rtn4Qty(lu);
               when rc=5;
                 if rtn5Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR5":"' + %char(rtn5Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR5":""';
                 endif;
                 wktotreturns=wktotreturns+rtn5Qty(lu);
               when rc=6;
                 if rtn6Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR6":"' + %char(rtn6Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR6":""';
                 endif;
                 wktotreturns=wktotreturns+rtn6Qty(lu);
               when rc=7;
                 if rtn7Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR7":"' + %char(rtn7Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR7":""';
                 endif;
                 wktotreturns=wktotreturns+rtn7Qty(lu);
               when rc=8;
                 if rtn8Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR8":"' + %char(rtn8Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR8":""';
                 endif;
                 wktotreturns=wktotreturns+rtn8Qty(lu);
               when rc=9;
                 if rtn9Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR9":"' + %char(rtn9Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR9":""';
                 endif;
                 wktotreturns=wktotreturns+rtn9Qty(lu);
               when rc=10;
                 if rtn10Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR10":"' + %char(rtn10Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR10":""';
                 endif;
                 wktotreturns=wktotreturns+rtn10Qty(lu);
               when rc=11;
                 if rtn11Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR11":"' + %char(rtn11Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR11":""';
                 endif;
                 wktotreturns=wktotreturns+rtn11Qty(lu);
               when rc=12;
                 if rtn12Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR12":"' + %char(rtn12Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR12":""';
                 endif;
                 wktotreturns=wktotreturns+rtn12Qty(lu);
               when rc=13;
                 if rtn13Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR13":"' + %char(rtn13Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR13":""';
                 endif;
                 wktotreturns=wktotreturns+rtn13Qty(lu);
               when rc=14;
                 if rtn14Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR14":"' + %char(rtn14Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR14":""';
                 endif;
                 wktotreturns=wktotreturns+rtn14Qty(lu);
               when rc=15;
                 if rtn15Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR15":"' + %char(rtn15Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR15":""';
                 endif;
                 wktotreturns=wktotreturns+rtn15Qty(lu);
               when rc=16;
                 if rtn16Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR16":"' + %char(rtn16Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR16":""';
                 endif;
                 wktotreturns=wktotreturns+rtn16Qty(lu);
               when rc=17;
                 if rtn17Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR17":"' + %char(rtn17Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR17":""';
                 endif;
               when rc=18;
                 if rtn18Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR18":"' + %char(rtn18Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR18":""';
                 endif;
                 wktotreturns=wktotreturns+rtn18Qty(lu);
               when rc=19;
                 if rtn19Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR19":"' + %char(rtn19Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR19":""';
                 endif;
                 wktotreturns=wktotreturns+rtn19Qty(lu);
               when rc=20;
                 if rtn20Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR20":"' + %char(rtn20Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR20":""';
                 endif;
                 wktotreturns=wktotreturns+rtn20Qty(lu);
               when rc=21;
                 if rtn21Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR21":"' + %char(rtn21Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR21":""';
                 endif;
                 wktotreturns=wktotreturns+rtn21Qty(lu);
               when rc=22;
                 if rtn22Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR22":"' + %char(rtn22Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR22":""';
                 endif;
                 wktotreturns=wktotreturns+rtn22Qty(lu);
               when rc=23;
                 if rtn23Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR23":"' + %char(rtn23Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR23":""';
                 endif;
                 wktotreturns=wktotreturns+rtn23Qty(lu);
               when rc=24;
                 if rtn24Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR24":"' + %char(rtn24Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR24":""';
                 endif;
                 wktotreturns=wktotreturns+rtn24Qty(lu);
               when rc=25;
                 if rtn25Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR25":"' + %char(rtn25Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR25":""';
                 endif;
                 wktotreturns=wktotreturns+rtn25Qty(lu);
               when rc=26;
                 if rtn26Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR26":"' + %char(rtn26Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR26":""';
                 endif;
                 wktotreturns=wktotreturns+rtn26Qty(lu);
               when rc=27;
                 if rtn27Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR27":"' + %char(rtn27Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR27":""';
                 endif;
                 wktotreturns=wktotreturns+rtn27Qty(lu);
               when rc=28;
                 if rtn28Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR28":"' + %char(rtn28Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR28":""';
                 endif;
                 wktotreturns=wktotreturns+rtn28Qty(lu);
               when rc=29;
                 if rtn29Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR29":"' + %char(rtn29Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR29":""';
                 endif;
                 wktotreturns=wktotreturns+rtn29Qty(lu);
               when rc=30;
                 if rtn30Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR30":"' + %char(rtn30Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR30":""';
                 endif;
                 wktotreturns=wktotreturns+rtn30Qty(lu);
               when rc=31;
                 txdata = %trim(txdata) +
                          ',"pR31":"' + %char(rtn31Qty(lu)) + '"';
                 wktotreturns=wktotreturns+rtn31Qty(lu);
               when rc=32;
                 if rtn32Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR32":"' + %char(rtn32Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR32":""';
                 endif;
                 wktotreturns=wktotreturns+rtn32Qty(lu);
               when rc=33;
                 if rtn33Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR33":"' + %char(rtn33Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR33":""';
                 endif;
                 wktotreturns=wktotreturns+rtn33Qty(lu);
               when rc=34;
                 if rtn34Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR34":"' + %char(rtn34Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR34":""';
                 endif;
                 wktotreturns=wktotreturns+rtn34Qty(lu);
               when rc=35;
                 if rtn35Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR35":"' + %char(rtn35Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR35":""';
                 endif;
                 wktotreturns=wktotreturns+rtn35Qty(lu);
               when rc=36;
                 if rtn36Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR36":"' + %char(rtn36Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR36":""';
                 endif;
                 wktotreturns=wktotreturns+rtn36Qty(lu);
               when rc=37;
                 if rtn37Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR37":"' + %char(rtn37Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR37":""';
                 endif;
                 wktotreturns=wktotreturns+rtn37Qty(lu);
               when rc=38;
                 if rtn38Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR38":"' + %char(rtn38Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR38":""';
                 endif;
                 wktotreturns=wktotreturns+rtn38Qty(lu);
               when rc=39;
                 if rtn39Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR39":"' + %char(rtn39Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR39":""';
                 endif;
                 wktotreturns=wktotreturns+rtn39Qty(lu);
               when rc=40;
                 if rtn40Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR40":"' + %char(rtn40Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR40":""';
                 endif;
                 wktotreturns=wktotreturns+rtn40Qty(lu);
               when rc=41;
                 if rtn41Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR41":"' + %char(rtn41Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR41":""';
                 endif;
                 wktotreturns=wktotreturns+rtn41Qty(lu);
               when rc=42;
                 if rtn42Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR42":"' + %char(rtn42Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR42":""';
                 endif;
                 wktotreturns=wktotreturns+rtn42Qty(lu);
               when rc=43;
                 if rtn43Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR43":"' + %char(rtn43Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR43":""';
                 endif;
                 wktotreturns=wktotreturns+rtn43Qty(lu);
               when rc=44;
                 if rtn44Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR44":"' + %char(rtn44Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR44":""';
                 endif;
                 wktotreturns=wktotreturns+rtn44Qty(lu);
               when rc=45;
                 if rtn45Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR45":"' + %char(rtn45Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR45":""';
                 endif;
                 wktotreturns=wktotreturns+rtn45Qty(lu);
               when rc=46;
                 if rtn46Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR46":"' + %char(rtn46Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR46":""';
                 endif;
                 wktotreturns=wktotreturns+rtn46Qty(lu);
               when rc=47;
                 if rtn47Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR47":"' + %char(rtn47Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR47":""';
                 endif;
                 wktotreturns=wktotreturns+rtn47Qty(lu);
               when rc=48;
                 if rtn48Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR48":"' + %char(rtn48Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR48":""';
                 endif;
                 wktotreturns=wktotreturns+rtn48Qty(lu);
               when rc=49;
                 if rtn49Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR49":"' + %char(rtn49Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR49":""';
                 endif;
                 wktotreturns=wktotreturns+rtn49Qty(lu);
               when rc=50;
                 if rtn50Qty(lu) <> *zeros;
                   txdata = %trim(txdata) +
                            ',"pR50":"' + %char(rtn50Qty(lu)) + '"';
                 else;
                   txdata = %trim(txdata) + ',"pR50":""';
                 endif;
                 wktotreturns=wktotreturns+rtn50Qty(lu);
             endsl;
             rc=rc+1;
           enddo;
           // sum and percent in two columns after last return code
           if hdcount < 51;
             // setup columns for returns
             if wktotreturns <> *zeros;
               txdata = %trim(txdata) +
                        ',"pR51":"' + %char(wktotreturns) + '"';
             else;
               txdata = %trim(txdata) + ',"pR51":""';
             endif;
             if (empQtyP(lu)+empQtyB(lu)+empQtyS(lu)+empQtyR(lu)) = 0;
               wkrtnpct=0;
             else;
               wkrtnpct = ((empQtyP(lu)+empQtyB(lu)+empQtyS(lu)+empQtyR(lu))
                              -wktotreturns)/
                           (empQtyP(lu)+empQtyB(lu)+empQtyS(lu)+empQtyR(lu))
                              *100;
             endif;
             if wkrtnpct <> *zeros;
               txdata = %trim(txdata) +
                        ',"pR52":"' + %char(wkrtnpct) + '"';
             else;
               txdata = %trim(txdata) + ',"pR52":""';
             endif;
           endif;
           txdata=%trim(txdata) + '}';
           txpsts=' ';     // Print status blank for unprinted
           txpseq='d' + %editc(lu:'X');
           // if employee include list sent then only include those employees
           if empList=*blanks or (empList<>*blanks and
              %scan(%subst(empNumA(lu):4:5):empList)<>0);
             write txrec;
           endif;
         enddo;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         open(e) bfcdbgflg;
         if %error;
           dbgflgExists = *off;
         else;
           dbgflgExists = *on;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DeleteRecs    Delete records for session id
     *----------------------------------------------------------------

     p DeleteRecs      b
     d DeleteRecs      pi

      /free

        exec sql delete from r35300wf
                 where txsess = :SessId or
                       txaddts < current timestamp - 360 MINUTES;

      /end-free

     p DeleteRecs      e

     *----------------------------------------------------------------
     *  ConvertField   Convert incoming field to DRI field
     *----------------------------------------------------------------

     p ConvertField    b
     d ConvertField    pi
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

      /free

       monitor;

         select;

           when parmName = 'whse';
             if parmValue = '';
               parmValue = '0';
             endif;
             whse =  %dec(parmValue: 3: 0);

           when parmName = 'cmd';
             cmd = parmValue;
             cmd = %xlate(xlower: xupper: cmd);

           when parmName = 'emplist';
             emplist = parmValue;
             emplist = %xlate(xlower: xupper: emplist);

           when parmName = 'rtnlist';
             rtnlist = parmValue;
             rtnlist = %xlate(xlower: xupper: rtnlist);

           when parmName = 'fdatetime';
             fdatetime = parmValue;
             fdatetime = %xlate(xlower: xupper: fdatetime);

           when parmName = 'tdatetime';
             tdatetime = parmValue;
             tdatetime = %xlate(xlower: xupper: tdatetime);

           when parmName = 'frtndate';
             frtndate = parmValue;
             frtndate = %xlate(xlower: xupper: frtndate);
             monitor;
               frtndaten = %dec(frtndate:8:0);
             on-error;
               frtndaten=0;
             endmon;

           when parmName = 'trtndate';
             trtndate = parmValue;
             trtndate = %xlate(xlower: xupper: trtndate);
             monitor;
               trtndaten = %dec(trtndate:8:0);
             on-error;
               trtndaten=0;
             endmon;

         endsl;

       on-error;

         errMsg = 'Error extracting parameter '
                + %char(parmCount) + ' '
                + parmName + ' '
                + '(' + parmValue + ')'
                + '('
                + %trimr(#Job) + '/'
                + %trimr(#JobNbr) + '/'
                + %trimr(#user)
                + ')';

       endmon;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ExtractParms   Extract parms from parameter string
     *----------------------------------------------------------------

     p ExtractParms    b
     d ExtractParms    pi

      /free

         // Error if parameter string is blank

         if pParmStr = '';
           errMsg = 'Error: Parameter string is empty '
                  + '('
                  + %trimr(#Job) + '/'
                  + %trimr(#JobNbr) + '/'
                  + %trimr(#user)
                  + ')';
           return;
         endif;

         // Extract parms for string 1

         ExtractParmStr();

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ExtractParmStr   Extract parms from single parameter string
     *----------------------------------------------------------------

     p ExtractParmStr  b
     d ExtractParmStr  pi

     * Local Variables

     D parmCount       s              3  0
     D parmGroup       s            200    varying
     D parmLen         s              5  0
     D parmName        s             10    varying
     D parmStrLen      s              5  0
     D parmValue       s            100    varying
     D pos             s              5  0
     D start           s              5  0

      /free

       // Parameters are separated by '|'

       start = 1;
       parmStrLen = %len(pParmStr);
       parmCount = 0;

       dow start <= parmStrLen;

         // Extract parameter ('fldname=value')

         pos = %scan('|': pParmStr: start);

         parmCount += 1;

         if pos = 0;
           parmGroup = %subst(pParmStr: start);
           start = parmStrLen + 1;
         else;
           parmLen = pos - start;
           parmGroup = %subst(pParmStr: start: parmLen);
           start = pos + 1;
         endif;

         // Extract parameter name

         pos = %scan('=': parmGroup: 1);

         // If no '=' found, invalid group.

         if pos = 0;
           errMsg = 'Error: Invalid parameter group '
                   + %char(parmCount) + ' '
                   + '(' + parmGroup + ')'
                   + '('
                   + %trimr(#Job) + '/'
                   + %trimr(#JobNbr) + '/'
                   + %trimr(#user)
                   + ')';
           leave;
         endif;

         parmName = %subst(parmGroup: 1: pos - 1);

         // Extract parameter value

         parmLen = %len(parmGroup);

         if parmLen = pos;
           parmValue = '';
         else;
           parmValue = %subst(parmGroup: pos + 1);
         endif;

         // Convert extracted value and put into DRI field

         ConvertField(parmCount: parmName: parmValue);
         if errMsg <> '';
           leave;
         endif;

       enddo;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  wrtBeforeDebug  Write out 'Before' debug info
     *----------------------------------------------------------------

     p WrtBeforeDebug  b
     d WrtBeforeDebug  pi

      /free

         bdtype = 'PARMS';

         bdvalues = 'pSessId:' + %trimr(pSessId) + ', '
                  + 'dbgloc:' + %trimr(debugLoc) + ', '
                  + 'pUser:' + %trimr(pUser) + ', '
                  + 'pDict:' + %trimr(pDict) + ', '
                  + 'pPgm:' + %trimr(pPgm) + ', '
                  + 'pOutStr:' + %trimr(pOutStr) + ', '
                  + 'pParm:' + pParmStr;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

         return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  wrtAfterDebug  Write out 'After' debug info
     *----------------------------------------------------------------

     p WrtAfterDebug   b
     d WrtAfterDebug   pi

      /free

         bdtype = 'PARMS';

         bdvalues = 'pSessId:' + %trimr(pSessId) + ', '
                  + 'dbgloc:' + %trimr(debugLoc) + ', '
                  + 'pUser:' + %trimr(pUser) + ', '
                  + 'pDict:' + %trimr(pDict) + ', '
                  + 'pPgm:' + %trimr(pPgm) + ', '
                  + 'pOutStr:' + %trimr(pOutStr) + ', '
                  + 'pParm:' + pParmStr;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

         return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  wrtDebugError  Write out debug error
     *----------------------------------------------------------------

     p WrtDebugError   b
     d WrtDebugError   pi

      /free

         bdtype = 'ERROR';

         bdvalues = errMsg;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

         return;

      /end-free

     p                 e
