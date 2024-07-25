      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  OSPROD   OPS *PROD Upd - Pgm for SQL procedure of same name
     *  12 May 2014
     *  Kenneth Elder
     *
     *  Revisions:
     *
640 A*    05/12/14  KDE  6.50
     *      - Created.
640 A*    03/26/15  KDE  6.50
     *      - Added option to Allow Breakdown Replen during Planning
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D oprec         E ds                  extname(options) inz(*EXTDFT)
     D  optionCode     s             10    inz('*PROD')

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
650aAD  pSessId        s             40
650aAD  pUser          s             10
650aAD  pPgm           s             20
     D  pObjLoc        s             10
     D  pSubCmd        s             10
     D  pData          s            117
     D  pWhse          s              3  0
	    d  prlbrp         s              1
	    d  prlbdl         s              1
	    d  prvarm         s              1
	    d  primpgtin      s              1
	    d  prgengtin      s              1
	    d  prprddte       s              1
	    d  prpckdte       s              1
	    d  prexpdte       s              1
	    d  prnetlbs       s              1
	    d  prlbsdec       s              1  0
	    d  prnetkg        s              1
	    d  prkgdec        s              1  0
	    d  prrepln        s              1
	    d  prtyprp        s              7
	    d  ppro           s              1
	    d  pgs1           s              1
	    d  pbrkr          s              1
	    d  pbxbu          s              1
	    d  pbxbp          s              1
	    d  pbxbs          s              1

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

650aAD logText         s            100

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

413bA*----------------------------------------------------------------
413bA*  *PROD  -  Production options.
413bA*----------------------------------------------------------------
413bA*
413bA* Fields
413bA*
413bA*    OPLBRP  -  Reprint Production labels
414dA*    OPLBDL  -  Delete previously printed Production Labels
416hA*    OPVARM  -  Variable Measurable (prints 9 in first position GTIN)
416hA*    OPIMPGTIN  Import GTIN's from Customer import file
417aA*    OPGENGTIN  Generate GTIN's on fly using customer inhouse item#
417aA*    OPPRDDTE   Include Production date in GS1 string
500nA*    OPRPCKDTE  Include Package date in GS1 String
500nA*    OPREXPDTE  Include expiration date in GS1 String if item configed
510aA*    OPNETLBS   Include Net pounds on GS1 String
640hA*    OPLBSDEC   Decimal places for Net pounds
510aA*    OPNETKG    Include Net KG on GS1 String
640hA*    OPKGDEC    Decimal places for Net kg
510aA*    OPREPLN    Perform Automated Replenishments
640hA*    OPTYPRP    Selected type of automated replenishments
640hA*    OPPRO      Produce Manufacturing Company versus Meat
640hA*    OPGS1      Force GS1 scans into production for Replenishments
640hA*    OPBRKR     Allows planning process to generate Breakdown Replen
640hA*    OPBXBU     Used Box Breaker App to breakdown case to eaches
640hA*    OPBXBP     Perform Box Breaker function at Pick Slot
640hA*    OPBXBS     Box Breaker will assign System Gen Licenses
413bA*
413bA* Data structure
413bA*
413bAD optionRec       ds
413bAD  oplbrp                 1      1
414dAD  oplbdl                 2      2
416hAD  opvarm                 3      3
416hAD  opimpgtin              4      4
417aAD  opgengtin              5      5
500nAD  opprddte               6      6
510aAD  oppckdte               7      7
640hAD  opexpdte               8      8
640hAD  opnetlbs               9      9
     D  oplbsdec              10     10  0
640hAD  opnetkg               11     11
     D  opkgdec               12     12  0
640hAD  oprepln               13     13
640hAD  optyprp               14     20
640hAD  oppro                 21     21
640hAD  opgs1                 22     22
640hAD  opbrkr                23     23
640hAD  opbxbu                24     24
640hAD  opbxbp                25     25
640hAD  opbxbs                26     26
414dAD  optend               117    117

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

650aA /copy qcopysrc,p.wrtsessl

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
650aA*      pSessId     Session Id
650aA*      pUser       GUI User
650aA*      pPgm        GUI dictionary.program
     *      pObjLoc     External object location
     *      pSubCmd     A=Add, U/C=Update, D=Delete
     *      pWhse       Warehouse
     *      option fields
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *      pData      OPTIONS data field
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
650aAC                   parm                    pSessId
650aAC                   parm                    pUser
650aAC                   parm                    pPgm
     C                   parm                    pObjLoc
     C                   parm                    pSubCmd
     C                   parm                    pData
     C                   parm                    pWhse
	    c                   parm                    prlbrp
	    c                   parm                    prlbdl
	    c                   parm                    prvarm
	    c                   parm                    primpgtin
	    c                   parm                    prgengtin
	    c                   parm                    prprddte
	    c                   parm                    prpckdte
	    c                   parm                    prexpdte
	    c                   parm                    prnetlbs
	    c                   parm                    prlbsdec
	    c                   parm                    prnetkg
	    c                   parm                    prkgdec
	    c                   parm                    prrepln
	    c                   parm                    prtyprp
	    c                   parm                    ppro
	    c                   parm                    pgs1
	    c                   parm                    pbrkr
	    c                   parm                    pbxbu
	    c                   parm                    pbxbp
	    c                   parm                    pbxbs

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
500sA
      /free

         *inlr = *on;
         pMessage = ' ';

650aA    // Write GLOSESSLOG record
650aA    logText = 'objloc:' + pObjLoc;
650aA    wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);

         select;
           when pObjLoc = 'FLDVALID';
             exsr FldValid;
           when pObjLoc = 'BEFOREACT';
             exsr BeforeAct;
           when pObjLoc = 'AFTERACT';
             exsr AfterAct;
           other;
             pMessage = 'Invalid object location sent: '
                      + %trim(pObjLoc)
                      + ' (' + %trim(#pgm) +')';
         endsl;

         return;
      /end-free

     *----------------------------------------------------------------
     *  AddRec    Add record
     *----------------------------------------------------------------

      /free
       begsr AddRec;

         error = *off;

         exsr FillRec;
         opdata = optionRec;

         exec sql insert into options values(:oprec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opcode) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AfterAct     After action update
     *----------------------------------------------------------------

      /free
       begsr AfterAct;

       error = *off;
       exsr errorCheck;
       if not error;

         exsr GetRec;

         select;
           when pSubCmd = 'A';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;
           when pSubCmd = 'U' or pSubCmd = 'C';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;
           when pSubCmd = 'D';
             if found;
               exsr DelRec;
             endif;
           other;
             pMessage = 'Invalid command sent: ' + pSubCmd
                      + %trim(pSubCmd)
                      + ' (' + %trim(#pgm) +')';
         endsl;
       endif;

       endsr;
      /end-free

500sA*----------------------------------------------------------------
500sA*  BeforeAct    Before action update
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr BeforeAct;

         optionRec = pData;
         exsr FillRec;
         pData = optionRec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DelRec    Delete record
     *----------------------------------------------------------------

      /free
       begsr DelRec;

         error = *off;

         exec sql delete from options
                  where opcode = :optionCode
                    and opwhse = :pWhse;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opcode) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  errorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

          // cannot select to import and generate gtin numbers
          if primpgtin = 'Y' and prgengtin = 'Y';
             pMessage = 'Cannot select both GTIN import and' +
                           ' generate GTIN';
             error = *on;
          endif;

          // cannot select Variable Measure unless GTIN are being imp
          if prvarm = 'Y' and prgengtin <> 'Y';
             pMessage = 'Variable Measure only valid with ' +
                           ' generate GTIN';
             error = *on;
          endif;

          if ppro <> 'Y';
          // only one date is valid
          if prprddte = 'Y';
            if prpckdte = 'Y' or prexpdte = 'Y';
                pMessage = 'Only one date may be selected';
                error = *on;
            endif;
          endif;

          // only one date is valid
          if prpckdte = 'Y';
            if prprddte = 'Y' or prexpdte = 'Y';
                pMessage = 'Only one date may be selected';
                error = *on;
            endif;
         endif;

          // only one date is valid
          if prexpdte = 'Y';
            if prprddte = 'Y' or prpckdte = 'Y';
                pMessage = 'Only one date may be selected';
                error = *on;
            endif;
          endif;

          // at least one date is required if not Produce Company
          if prexpdte = 'N' and prprddte='N' and prpckdte='N';
             pMessage = 'At least one date must be selected for GS1';
             error = *on;
          endif;

          // only one weight is valid
          if prnetlbs = 'Y' and prnetkg = 'Y';
             pMessage = 'Only one weight allowed';
             error = *on;
          endif;

          // decimals for weight cannot exceed 3
          if prlbsdec > 3 or prkgdec > 3;
             pMessage = 'Weight decimals cannot exceed 3';
             error = *on;
          endif;

          // at least one weight must be selected
          if prnetlbs <> 'Y' and prnetkg<>'Y';
             pMessage = 'At least one weight must be entered';
             error = *on;
          endif;

          // decimals not allowed unless weight selected
          if prlbsdec > 0 and prnetlbs <> 'Y';
             pMessage = 'LBS decimal invalid when Net LBS not selected';
             error = *on;
          endif;

          // decimals must exist when weight selected
          if prlbsdec <= 0 and prnetlbs = 'Y';
             pMessage = 'LBS decimal must be entered when LBS selected';
             error = *on;
          endif;

          // decimals must exist when KG weight selected
          if prkgdec <= 0 and prnetkg = 'Y';
             pMessage = 'KG decimal must be entered when KG selected';
             error = *on;
          endif;

          // decimals not allowed unless weight selected
          if prkgdec > 0 and prnetkg <> 'Y';
             pMessage = 'KG decimal invalid when Net KG not selected';
             error = *on;
          endif;

          else;
             // Dates not valid when Produce Company
             if prprddte = 'Y' or prpckdte='Y' or prexpdte='Y';
                pMessage = 'Dates not valid when Produce Company';
                error = *on;
             endif;
             // decimals not allowed unless weight selected
             if prlbsdec > 0 or prnetlbs = 'Y'
                or prkgdec > 0 or prnetkg = 'Y';
                pMessage = 'Weight not valid for Produce company';
                error = *on;
             endif;

          // decimals not allowed unless weight selected
          if prkgdec > 0 and prnetkg <> 'Y';
             pMessage = 'KG decimal invalid when Net KG not selected';
             error = *on;
          endif;
          endif;          // endif for OPPRO (Produce Company)

          // if automated replen is checked you must select a type
          if prrepln = 'Y' and prtyprp = '*NONE';
             pMessage = 'If automated replenh checked you must select' +
                        ' a method to replen';
             error = *on;
          endif;

          // if method selected you must click check box for replen.
          // since I have Java Script forcing this issue this should
          // never happen but check in case
          if prrepln = 'N' and prtyprp <> '*NONE';
             pMessage = 'If an automated replen method is choosen ' +
                        'you must check automated replen';
             error = *on;
          endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

         opcode = optionCode;
         opwhse = pWhse;

	        oplbrp = prlbrp;
	        oplbdl = prlbdl;
	        opvarm = prvarm;
	        opimpgtin = primpgtin;
	        opgengtin = prgengtin;
	        opprddte = prprddte;
	        oppckdte = prpckdte;
	        opexpdte = prexpdte;
	        opnetlbs = prnetlbs;
	        oplbsdec = prlbsdec;
	        opnetkg = prnetkg;
	        opkgdec = prkgdec;
	        oprepln = prrepln;
	        optyprp = prtyprp;
	        oppro = ppro;
	        opgs1 = pgs1;
	        opbxbu = pbxbu;
	        opbxbp = pbxbp;
	        opbxbs = pbxbs;
	        opbrkr = pbrkr;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FldValid   Validate fields
     *----------------------------------------------------------------

      /free
       begsr FldValid;

         if pSubCmd = 'D';
           leavesr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRec    Get record
     *----------------------------------------------------------------

      /free
       begsr GetRec;

         found = *off;

         exec sql select * into :oprec
                  from options
                  where opcode = :optionCode
                    and opwhse = :pWhse;

         if sqlstt = sqlSuccess;
           found = *on;
         endif;

       endsr;
      /end-free


     *----------------------------------------------------------------
     *  UpdRec    Update record
     *----------------------------------------------------------------

      /free
       begsr UpdRec;

         error = *off;
         exsr FillRec;
         opdata = optionRec;

         exec sql update options
                  set opdata = :opdata
                  where opcode = :opcode
                    and opwhse = :pWhse;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opcode) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free
