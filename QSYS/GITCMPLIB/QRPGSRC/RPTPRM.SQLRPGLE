      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
      *----------------------------------------------------------
      *   Copyright (C) 2014 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  RPTPRM      Write parms from user to schedule MRC Report
      *  18 July 2018
      *  Kenneth Elder
      *
      *  Revisions:
      *
650 A *    07/18/18  KDE  7.20
      *      - Created.
      *
720aA *    01/08/19  RBD  7.20a
      *      - When status changed to Inactive delete unprocessed
      *        scheduled records for the report.
      *
730aA *    01/31/19  RBD  7.30a
      *      - Remove bfcmrcrse file spec, not necessary.
      *
730bA *    09/12/19  KDE  7.30b
      *      - No longer use warehouse in BFCMRCRCFG updates.  This
      *        is a global file for ALL warehouses
      *
      *----------------------------------------------------------

      *----------------------------------------------------------
      * File Specs
      *----------------------------------------------------------
     Fbfcmrcrprmuf a e           k disk
     fbfcmrcrcfgif   e           k disk
     fglorptq1  if   e           k disk
730aDF*bfcmrcrse uf   e           k disk

      *----------------------------------------------------------
      *  Program information data structure
      *----------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D psession        s             40
     D pwhse           s              3p 0
     D puser           s             10
     D ppgm            s             20
     D prptpgm         s             20
     D ptbl            s              1
     D pAction         s              1
     D pprmnam         s             12
     D pvalue          s            300
     D pSchseq         s              3  0
     D pOutStr         s            512    varying

710 A*----------------------------------------------------------------
710 A*  Sub-procedure prototypes
710 A*----------------------------------------------------------------
710 A***    Used to pause RPG cycle                        ***
     D sleep           pr            10u 0 extproc('sleep')
     D  Interval                     10u 0 value

     *----------------------------------------------------------
     *  Variables
     *----------------------------------------------------------

     D  pos            s              3  0
     D  stat           s             20
     d  qseq#          s              5  0
     d  nxtseq         s              3  0
     d  rtndata        s            400
     d  rtnAnsTyp      s              1
     d  rtnValue       s            300

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    psession
     c                   parm                    puser
     c                   parm                    ppgm
     c                   parm                    pwhse
     c                   parm                    pAction
     c                   parm                    prptpgm
     c                   parm                    ptbl
     c                   parm                    pprmnam
     c                   parm                    pvalue
     c                   parm                    pSchSeq
     c                   parm                    poutstr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        pOutStr = ' ';

        // replace _ with . in Report Program Name
        pos = %scan('_':pRptPgm);
        if pos <>0;
           %subst(pRptPgm:pos:1) = '.';
        endif;

         if %len(%trim(pPrmNam)) >= 6;
            if %subst(%trim(pPrmNam):1:6)='STATUS';
               pPrmNam = 'STATUS';
            endif;
         endif;

        select;
          when pAction='W'                    // Write parm values
            and pPrmNam <> 'BFORIENT';
            exsr updateData;
          when pAction='R'                    // Read and Return parm values
            and pPrmNam <> 'BFORIENT';
            exsr getvalue;
          when pAction='W'                    // Write parm values
            and pPrmNam = 'BFORIENT';
            exsr UpdateOrient;
          when pAction='R'                    // Read and Return parm values
            and pPrmNam = 'BFORIENT';
            exsr getOrient;
          when pAction='N' and pSchSeq=999;   // get next schedule sequence
            exsr getNxtSeq;
          when pAction='D';                   // Delete Schedule Sequence
            exsr DeleteSeq;
          when pAction='Y';                   // Update Last
            exsr updateLast;
          when pAction='C';                   // Return Schedule Seq Count
            exsr CountSeq;
        endsl;

         // Put together JSON string

         if %trim(pPrmNam)='BSSEQNAME';
            rtnAnstyp = '1';
         endif;

         if %trim(pPrmNam)='SUN' or %trim(pPrmNam)='MON' or %trim(pPrmNam)='TUE'
            or %trim(pPrmNam)='WED' or %trim(pPrmNam)='THU'
            or %trim(pPrmNam)='FRI' or %trim(pPrmNam)='SAT';
            rtnAnstyp = '2';
         endif;

         if pAction = 'N';      // Next Schedule Sequence
           rtnValue = %char(nxtSeq);
           pPrmNam = 'NXTSEQ';
         endif;

         if %trim(pPrmNam)='STATUS';
            pPrmNam = 'STATUS' + %trim(%char(bsschseq));
         endif;

         rtnData = %trim(pPrmNam) + '|' + rtnAnsTyp + '|' + %trim(rtnValue);
         pOutStr = '{'
                +  '"stat":"'  + %trim(stat) + '",'
                +  '"rtnData":"'  + %trim(rtnData) + ' ' + '"';

         // Close off the JSON string
         pOutStr += '}';
        *inlr = *on;

      /end-free

      *----------------------------------------------------------
      *  updateOrient - Update all report lines with Orientation
      *----------------------------------------------------------

      /free
        begsr updateOrient;
          sleep(3);
          exec sql update bfcmrcrcfg set bforient=:pValue
730bD              // where bfwhse=:pwhse and bfrptpgm=:prptpgm;
730bM              where bfrptpgm=:prptpgm;
          rtnValue = pValue;
          rtnAnsTyp = ' ';
          rtnAnsTyp = 'WriteOK';
        endsr;
      /end-free

      *----------------------------------------------------------
      *  getOrient  - Get value from one of current records
      *----------------------------------------------------------

      /free
        begsr getOrient;
          rtnValue = *blanks;
          exec sql select bforient into :rtnValue
                     from bfcmrcrcfg
730bD              //where bfwhse=:pwhse and bfrptpgm=:prptpgm
730bM              where bfrptpgm=:prptpgm
                      and bforient<>' '
                      fetch first row only;
          rtnAnsTyp = ' ';
          rtnAnsTyp = 'GetOK';
        endsr;
      /end-free

      *----------------------------------------------------------
      *  updateData - Update User defined Report Parms with their values
      *----------------------------------------------------------

      /free
        begsr updateData;

           stat = 'WriteOK';
           // CALCULA999 get sent with q to prevent matching
           // to same CALCULA999 in R29800 report call
           if %subst(pPrmNam:1:8)='qCALCULA';
              pPrmNam = %subst(pPrmNam:2:10);
           endif;

           pValue  = %xlate(xlower: xupper: pValue);

           // Confirm that Printer is valid if entered
           if %trim(pPrmNam) = 'PRINTER';
             if %trim(pValue) <> *blanks;
      /end-free
     c                   call      'CHKFOROUTQ'
     c                   parm                    pValue
     c                   parm                    prtError         10
      /free
             endif;
             if prterror = 'INVALID' and %trim(pValue)<>*blanks;
                rtnAnsTyp = ' ';
                rtnValue = 'PRTERROR';
                stat = 'PRTERROR';
                leavesr;
             else;
                rtnValue = pValue;
                rtnAnstyp = ' ';
             endif;
           endif;

           // Return sent status for Status update
           if pPrmNam='STATUS' and %trim(pValue)='X';
              // when updating Status record we get current status
              // and flip between Active and Inactive when coming from
              // M27600 grid.  Do not do this from M27500
              chain (pWhse:pRptPgm:pSchSeq:pTbl:pPrmNam) bfcmrcrprm;
              if %found(bfcmrcrprm);
                 if %trim(bsValue) = 'A';
                    pValue = 'I';
720aA
720aA               // Report now inactive so delete schedule entries
720aA               exec sql delete from BFCMRCRSE
720aA                        where sewhse   = :bswhse
720aA                          and serptpgm = :bsrptpgm
720aA                          and seschseq = :bsschseq
720aA                          and sestat   = 'U';
720aA
                 else;
                    pValue = 'A';
                 endif;
              else;
                 pValue = 'A';
              endif;
              rtnValue = %trim(pValue);
           endif;

           // write or update parm data records
           chain (pWhse:pRptPgm:pSchSeq:pTbl:pPrmNam) bfcmrcrprm;
           if %found(bfcmrcrprm);
              bsvalue = %trim(pValue);
              update bsprmr;
           else;
              bswhse = pwhse;
              bsrptpgm = prptpgm;
              bsmrctbl = pTbl;
              bsmrcprm = pPrmNam;
              bsValue = pValue;
              bsschseq = pSchSeq;
              write bsprmr;
           endif;

        endsr;
      /end-free

      *----------------------------------------------------------
      *  deleteSeq - Delete Schedule Sequence
      *----------------------------------------------------------

      /free
        begsr deleteSeq;

           stat = 'Delete';
           // Delete passed Schedule Sequence from User Defined File
           exec sql delete from bfcmrcrprm
                      where bsrptpgm=:pRptPgm and
                            bsschseq=:pSchSeq;
           // Delete passed Schedule Sequence from Schedule Entry File
           exec sql delete from bfcmrcrse
                      where serptpgm=:pRptPgm and
                            seschseq=:pSchSeq;

           rtnAnstyp = ' ';
           rtnValue = %trim(pRptPgm);
           pPrmNam = 'DELETE';

        endsr;
      /end-free

      *----------------------------------------------------------
      *  updateLast - Return Update Last indicator for Ajax to forward
      *----------------------------------------------------------

      /free
        begsr updateLast;

           stat = 'Update';

           rtnAnstyp = ' ';
           rtnValue = %trim(pRptPgm);
           pPrmNam = 'UPDDONE';

        endsr;
      /end-free

      *----------------------------------------------------------
      *  CountSeq - Get Current Schedule Sequence count
      *----------------------------------------------------------

      /free
        begsr CountSeq;

           stat = 'SEQCNT';
           // Get current number of unique Schedule Sequences
           exec sql select count (distinct bsschseq)
                      into :nxtseq
                     from bfcmrcrprm
                      where bsrptpgm=:prptpgm and bsmrcprm<>'PRINTER';

           rtnAnstyp = ' ';
           rtnValue = %char(nxtseq);
           pPrmNam = 'SEQCNT';

        endsr;
      /end-free

      *----------------------------------------------------------
      *  getNxtSeq - Get next Schedule entry sequence number
      *----------------------------------------------------------

      /free
        begsr getNxtSeq;

           stat = 'NxtSeq';
           // find next schedule entry sequence number
           exec sql select max(bsschseq)
                   into :NxtSeq
                  from bfcmrcrprm;

           nxtSeq = nxtSeq + 1;

        endsr;
      /end-free

      *----------------------------------------------------------
      *  getValue - Read value(s) for parm sent and return via json
      *----------------------------------------------------------

      /free
        begsr getValue;

           stat = 'ReadOK';
           if %subst(pPrmNam:1:8)='qCALCULA';
              pPrmNam = %subst(pPrmNam:2:10);
           endif;
           // read value(s) for request parm
           chain(n) (pWhse:pRptPgm:pSchSeq:pTbl:pPrmNam) bfcmrcrprm;
           if %found(bfcmrcrprm);
              // get Answer Type for request Parm
730bD         // setll (pWhse:pRptPGm:pTbl) bfcmrcrcfg;
730bD         // reade (pWhse:pRptPGm:pTbl) bfcmrcrcfg;
730bM         setll (pRptPGm:pTbl) bfcmrcrcfg;
730bM         reade (pRptPGm:pTbl) bfcmrcrcfg;
              rtnAnsTyp = *blanks;
              dow not %eof(bfcmrcrcfg);
                 if %scan(%trim(%subst(pPrmNam:1:%len(pPrmNam)))
                         :bftpdata) <> 0;
                    // when parm found in BFTPDATA it must be either
                    // dynamic Dropdown or PCM Question Type
                    if bflinetp = 'DD';
                       // If Dynamic Dropdown must determine if requires
                       // list as output or single value
                       if %subst(bftpdata:21:1)='Y' or
                          %subst(bftpdata:22:1)='Y';
                          // if list then return type L
                          rtnAnsTyp = 'L';
                       else;
                          // otherwise type 4
                          rtnAnsTyp = '4';
                       endif;
                       leave;
                    else;
                      // Must be non date PCM question
                      monitor;
                        qseq# = %dec(%subst(bftpdata:27:5):5:0);
                      on-error;
                        qseq# = *zeros;
                        iter;
                      endmon;
                      // locate PCM question sequence to get type associated
                      chain (qseq#) glorptq1;
                      if %found(glorptq1);
                         rtnAnsTyp = hiatyp;
                         rtnValue = %trim(bsValue);
                         leave;
                      endif;
                    endif;
                 endif;

                 // if subtotal return type 2 for checkbox
                 if bfmrctbl = 'T';
                    rtnValue = %trim(bsValue);
                    rtnAnsTyp = '2';
                    leave;
                 endif;

                 // if day to schedule then 2 for checkbox
                 if pTbl = 'D';
                    rtnValue = %trim(bsValue);
                    rtnAnsTyp = '2';
                    leave;
                 endif;

                 // return previously saved report option
                 if pPrmNam = 'OUTFMT';
                    rtnValue = %trim(bsValue);
                    rtnAnsTyp = 'O';
                    leave;
                 endif;

                 // if not found in BFTPDATA we look in Date field
                 if %scan(%trim(%subst(pPrmNam:1:%len(pPrmNam)))
                         :bfdtarry) <> 0;
                    // if found within date data structure we will
                    // pass back type 7.  For user schedule screen
                    // they are only presented with a dropdown with
                    // generic date values like *YESTERDAY
                    rtnAnsTyp = '7';
                 endif;

730bD            // reade (pWhse:pRptPGm:pTbl) bfcmrcrcfg;
730bM            reade (pRptPGm:pTbl) bfcmrcrcfg;
              enddo;

              rtnValue = %trim(bsValue);
           else;
              rtnAnsTyp = *blanks;
              rtnValue = *blanks;
           endif;

        endsr;

      /end-free

      *----------------------------------------------------------
      *  *INZSR   Initialization subroutine
      *----------------------------------------------------------

      /free
        begsr *INZSR;

        endsr;

      /end-free

