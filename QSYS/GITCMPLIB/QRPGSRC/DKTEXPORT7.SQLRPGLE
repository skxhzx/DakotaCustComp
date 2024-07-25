417cA /copy *libl/qcopysrc,hspecs
650bAH DFTACTGRP(*NO) ACTGRP(*CALLER)
650aA*----------------------------------------------------------------
650aA* COMPILE WITH FOLLOWING OPTIONS:
650aA*
650aA*  Commitment control (COMMIT)  . . . *NONE
650aA*  Close SQL Cursor (CLOSQLCSR) . . . *ENDACTGRP
650aA*  Delay PREPARE (DLYPRP) . . . . . . *YES
650aA*
650aA*  *ENDACTGRP must be used in this program because *ENDMOD
650aa*  closes the cursors pointing to the returned result sets
650aA*  causing an error in the calling Stored Procedure.
650aA*
650aA*----------------------------------------------------------------

     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  DKTEXPORT   Dakota import
     *  21 January 2011
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
640 A*    01/21/11  DAS  6.40
     *      - Created.
     *
640aA*    01/21/11  DAS  6.40a
     *      - Added PO Export
     *
640bA*    01/21/11  DAS  6.40b
     *      - Added Item Qty export
     *
640cA*    02/20/11  DAS  6.40c
     *      - Added parms pMaxBatches, pSets, pProgram.
     *      - Added logic to pass back result sets when calling
     *        program is PDKTEXPRS.
     *
640dA*    04/27/11  MLB  6.40d
     *      - Enh: Added Item Whse Qty Ver 2 export - IT740S.
     *
640eA*    06/09/11  DAS  6.40e
     *      - Enh: Added EXPSLICLOG/EXPSLLCOMB exports.
     *
640fA*    12/04/12  MLB  6.40f
     *      - Enh: Added EXPSRTN export for customer returns.
     *      - Call to OR736S.
     *
650aA*    05/29/13  DAS  6.50a
     *      - Added compile comments at top of program.
     *
650bA*    06/07/13  DAS  6.50b
     *      - Rewrote MarkSTGBATCH routine to use setll/reade/update
     *        instead of SQL update.
     *      - Renamed original to MarkSTGBATCHx. See that routine
     *        for details.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *    When adding a new export type, scan for EXPADJUST and
     *    EXPSADJ, and use that code as a guide.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pType       Batch type
     *      pRunType    I = Interactive, J = Jobq
640cA*      pMax        Maximum batches returned
640cA*      pSets       Only used with calling program is PDKTEXPRS.
640cA*                  RTN - Returns only the return code, message
640cA*                        and bach count status array.
640cA*                  STG - Returns RTN and STGBATCH result set.
640cA*                  ALL - Returns RTN, STG, and all result sets
640cA*                        that correspond with the pType sent.
640cA*                        If pType *ALL sent, then all possible
640cA*                        result sets are returned.
640cA*      pProgram    Calling program
     *
     *    Returned Parameters
     *      pReturn     *OK
     *      pMessage    Error message
     *
     *----------------------------------------------------------------

650bA*----------------------------------------------------------------
650bA*  Binding Directories
650bA*----------------------------------------------------------------
650bA
650bAHbnddir('BFCBND')

650bA*----------------------------------------------------------------
650bA* File Specs
650bA*----------------------------------------------------------------
650bA
650bAFstgbatch1 uf   e           k disk

     D dktexport       pr                  extpgm('DKTEXPORT')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pRunType                     1    const
640cAD   pMaxBatches                  5p 0 const
640cAD   pSets                        3    const
640cAD   pProgram                    10    const
      * Output
     D   pReturn                     10
     D   pMessage                   200

     D dktexport       pi
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pRunType                     1    const
640cAD   pMaxBatches                  5p 0 const
640cAD   pSets                        3    const
640cAD   pProgram                    10    const
      * Output
     D   pReturn                     10
     D   pMessage                   200

     *----------------------------------------------------------------
     *  Client id's
     *----------------------------------------------------------------

      /copy qcopysrc,id#cheney

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

650bDD*sbrec         E ds                  extname(stgbatch) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D allTypes        s               n
     D alphaWhse       s              3
     D client          s             10
     D clientLoc       s             10
     D cmd             s           3000    varying
     D expRecIdA       s             11
     D logMessage      s            200
     D logReturn       s             10
     D recid           s             11p 0
     D temp3n          s              3p 0
     D uRunType        s              1
640cAD uSets           s              3
     D uType           s             10
     D whse3s          s              3s 0
     D wwMsgKey        s              4A

640cA*----------------------------------------------------------------
640cA*  Return parameter result set
640cA*----------------------------------------------------------------
640cA
640cAD pgmStatus       ds                  occurs(1)
640cAD  sReturn                      10
640cAD  sMessage                    200
640cAD  sBatches                      5s 0 inz(0)
640cAD  sSetsReturned               300

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     * Data structures for QMHRCVPM
     *----------------------------------------------------------------

     D dsM2            DS
     D  dsM2_BytRtn                  10I 0 inz(%size(dsM2))
     D  dsM2_BytAvl                  10I 0 inz(%size(dsM2))
     D  dsM2_MsgSev                  10I 0
     D  dsM2_MsgID                    7A
     D  dsM2_MsgType                  2A
     D  dsM2_MsgKey                   4A
     D  dsM2_MsgFileN                10A
     D  dsM2_MsgLibS                 10A
     D  dsM2_MsgLibU                 10A
     D  dsM2_SendJob                 10A
     D  dsM2_SendUser                10A
     D  dsM2_SendJobN                 6A
     D  dsM2_SendPgm                 12A
     D  dsM2_SendLine                 4A
     D  dsM2_SendDate                 7A
     D  dsM2_SendTime                 6A
     D  dsM2_RecvPgm                 10A
     D  dsM2_RecvLine                 4A
     D  dsM2_SendType                 1A
     D  dsM2_RecvType                 1A
     D  dsM2_Reserved                 1A
     D  dsM2_CCS_IndT                10I 0
     D  dsM2_CCS_IndD                10I 0
     D  dsM2_AlertOpt                 9A
     D  dsM2_CCS_Msg                 10I 0
     D  dsM2_CCS_Txt                 10I 0
     D  dsM2_DtaLen                  10I 0
     D  dsM2_DtaAvl                  10I 0
     D  dsM2_MsgLen                  10I 0
     D  dsM2_MsgAvl                  10I 0
     D  dsM2_HlpLen                  10I 0
     D  dsM2_HlpAvl                  10I 0
     D  dsM2_Dta                   4000A

     D dsEC            DS
     D  dsECBytesP             1      4I 0 INZ(%size(dsEC))
     D  dsECBytesA             5      8I 0 INZ(0)
     D  dsECMsgID              9     15
     D  dsECReserv            16     16
     D  dsECMsgDta            17    256

     *----------------------------------------------------------------
650bA*  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z

     D bfcoffset       s              3  0 inz(0)
     D ucOffset        s              3  0

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.qcmdexc
650bA /copy qcopysrc,p.bfcdteti

     D QMHRCVPM        PR                  ExtPgm('QMHRCVPM')
     D   MsgInfo                  32766A   options(*varsize)
     D   MsgInfoLen                  10I 0 const
     D   Format                       8A   const
     D   StackEntry                  10A   const
     D   StackCount                  10I 0 const
     D   MsgType                     10A   const
     D   MsgKey                       4A   const
     D   WaitTime                    10I 0 const
     D   MsgAction                   10A   const
     D   ErrorCode                32766A   options(*varsize)

     D SetJdLibl       pr                  extpgm('SETJDLIBL')
     D  pjobd                        10    const
     D  pReturn                      10
     D  pMessage                     60

     D GetClient       pr                  extpgm('GETCLIENT')
     D  pClient                      10
     D  pClientLoc                   10

     D GetRecId        pr                  extpgm('GETRECID')
     D  pWhse                         3s 0 const
     D  pFile                        10    const
     D  pRecId                       11p 0

     D it726s          pr                  extpgm('IT726S')
     D  pWhse                         3    const

640bAD it736s          pr                  extpgm('IT736S')
640bAD  pWhse                         3    const

640dAD it740s          pr                  extpgm('IT740S')
640dAD  pWhse                         3    const

640eAD ll726s          pr                  extpgm('LL726S')
640eAD  pWhse                         3    const

640fAD or736s          pr                  extpgm('OR736S')
640fAD  pWhse                         3    const

640aAD po726s          pr                  extpgm('PO726S')
640aAD  pWhse                         3    const

      /free

         *inlr = *on;

         pReturn = '*OK';
         pMessage = ' ';

         // Translate input into upper case.

         uType = %xlate(xlower: xupper: pType);
         uRunType = %xlate(xlower: xupper: pRunType);
640cA    uSets = %xlate(xlower: xupper: pSets);

         // Convert warehouse

         alphaWhse = %trim(%char(pWhse));
         whse3s = pWhse;

         // Verify pType parameter

         allTypes = *off;

         select;
           when uType = '*ALL';
             allTypes = *on;
CBIaA      when uType = '*CBI';
           when uType = 'EXPADJUST';
           when uType = 'EXPCLSRTE';
           when uType = 'EXPITEMQTY';
640dA      when uType = 'EXPITMQTY2';
640eA      when uType = 'EXPLICLOG';
640eA      when uType = 'EXPLLCOMBO';
           when uType = 'EXPPO';
640fA      when uType = 'EXPRETURN';
           when uType = 'EXPROUTE';
           when uType = 'EXPSELTRAN';
           when uType = 'EXPCBILOAD';
           when uType = 'EXPCBISHRT';
           when uType = 'EXPCBITIHI';
           when uType = 'EXPCBICASE';
640cA      other;
640cA        pReturn  = '*INVLDTYPE';
640cA        pMessage = 'Invalid type sent (' + uType + '). ';
640cA        uSets = 'RTN';
640cA        exsr SendSets;
640cA        return;
         endsl;

         // Verify run type

640cA    select;
640cM      when uRunType = 'I';
640cM      when uRunType = 'J';
640cA      other;
640cA        pReturn  = '*INVLDRTYP';
640cA        pMessage = 'Invalid run type sent (' + uRunType + '). '
640cA                 + 'Valid types are I=Interactive and J=Jobq. ';
640cA        uSets = 'RTN';
640cA        exsr SendSets;
640cA        return;
640cM    endsl;

         // Verify pSets parameter if returning result sets
640cA
640cA    if pProgram = 'PDKTEXPRS';
           select;
             when uSets = 'ALL';
             when uSets = 'RTN';
             when uSets = 'STG';
640cA        other;
640cA          pReturn  = '*INVLDSET';
640cA          pMessage = 'Invalid set type sent (' + uSets + '). '
640cA                   + 'Valid types are ALL, RTN, STG. ';
640cA          uSets = 'RTN';
640cA          exsr SendSets;
640cA          return;
           endsl;
640cA      if uRunType = 'J' and uSets <> 'RTN';
640cA          pReturn  = '*INVLDRSC';
640cA          pMessage = 'Invalid run type (' + uRunType + ') / '
640cA                   + 'set type (' + uSets + ') combination. '
640cA                   + 'Run type J can only be matched with '
640cA                   + 'set type RTN.';
640cA          uSets = 'RTN';
640cA          exsr SendSets;
640cA          return;
640cA      endif;
640cA    endif;

         // Run programs to export data to staging files

640cA    select;
640cM      when uRunType = 'I';
             exsr runInteractive;
640cM      when uRunType = 'J';
             exsr runJobq;
640cM    endsl;

640cA    // Get out if not return result sets.
640cA
640cA    if pProgram <> 'PDKTEXPRS';
640cA      return;
640cA    endif;

640cA    // Otherwise, return result sets
640cA
640cA    exsr CreateSets;

640cA    exsr SendSets;

         return;
      /end-free

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

      /free
       begsr *pssr;

         // Make sure we don't get caught in an infinite loop

         if pssrflag;
           *inlr = *on;
           return;
         endif;

         pssrflag = *on;

         //  Send message back to calling program

         dump(a);
         pReturn = 'U:' + #status;
         pMessage = 'U:'
                  + %trim(#pgm)
                  + '('
                  + %trim(%editc(#stmt:'Z'))
                  + ')-'
                  + #pgmmsg;
         *inlr = *on;
         return;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *inzsr;

         // Get client id

         getclient(client: clientLoc);

       endsr;
      /end-free

640cA*----------------------------------------------------------------
640cA*  CreateSets     Create result sets
640cA*----------------------------------------------------------------
640cA
640cA /free
640cA  begsr CreateSets;

         // Get batch id for this export.

         monitor;
           GetRecId(whse3s: 'DKTEXPORT': RecId);
         on-error;
           pReturn  = '*ERRGETID';
           pMessage = 'Error calling GetRecId '
                    + 'from DKTEXPORT ';
           dump(a);
           leavesr;
         endmon;

         expRecIdA = %trim(%char(recId));

         // Mark batches to return.

         exsr MarkSTGBATCH;
         if sBatches = 0 or pReturn <> '*OK';
           leavesr;
         endif;

         // Get out if only returning status array.

         if uSets = 'RTN';
           leavesr;
         endif;

         // Create STGBATCH result set.

         exsr SelectSTGBATCH;
         if pReturn <> '*OK';
           leavesr;
         endif;

         // Get out if only returning batch records.

         if uSets = 'STG';
           leavesr;
         endif;

         // Create EXPSADJ result set.

         if allTypes or uType = 'EXPADJUST';
           exsr SelectEXPSADJ;
         endif;

640eA    // Create EXPSLICLOG result set.
640eA
640eA    if allTypes or uType = 'EXPLICLOG';
640eA      exsr SelectEXPSLICLOG;
640eA    endif;

640eA    // Create EXPSLLCOMB result set.
640eA
640eA    if allTypes or uType = 'EXPLLCOMBO';
640eA      exsr SelectEXPSLLCOMB;
640eA    endif;

         // Create EXPSORDH result set.

         if allTypes
          or uType = 'EXPROUTE'
          or uType = 'EXPCLSRTE';
            exsr SelectEXPSORDH;
         endif;

         // Create EXPSORDD result set.

         if allTypes
          or uType = 'EXPROUTE'
          or uType = 'EXPCLSRTE';
            exsr SelectEXPSORDD;
         endif;

         // Create EXPSORDL result set.

         if allTypes
          or uType = 'EXPROUTE'
          or uType = 'EXPSELTRAN';
            exsr SelectEXPSORDL;
         endif;

         // Create EXPSORDC result set.

         if allTypes
          or uType = 'EXPROUTE'
          or uType = 'EXPSELTRAN';
            exsr SelectEXPSORDC;
         endif;

         // Create EXPSORDP result set.

         if allTypes
          or uType = 'EXPROUTE'
          or uType = 'EXPSELTRAN';
            exsr SelectEXPSORDP;
         endif;

         // Create EXPSORDT result set.

         if allTypes
          or uType = 'EXPROUTE'
          or uType = 'EXPSELTRAN';
            exsr SelectEXPSORDT;
         endif;

         // Create EXPSORDE result set.

         if allTypes
          or uType = 'EXPROUTE'
          or uType = 'EXPSELTRAN';
            if client <> cheney;
              exsr SelectEXPSORDE;
            endif;
         endif;

         // Create EXPSPOH result set.

         if uType = 'EXPPO'
            or (allTypes and client <> cheney);
              exsr SelectEXPSPOH;
         endif;

         // Create EXPSPOD result set.

         if uType = 'EXPPO'
            or (allTypes and client <> cheney);
              exsr SelectEXPSPOD;
         endif;

         // Create EXPSPOE result set.

         if uType = 'EXPPO'
            or (allTypes and client <> cheney);
              exsr SelectEXPSPOE;
         endif;

640fA    // Create EXPSRTN result set.

640fA    if uType = 'EXPRETURN'
640fA       or (allTypes and client <> cheney);
640fA         exsr SelectEXPSRTN;
640fA    endif;

         // Create EXPSQTY result set.
         // Note, we do not include this with *ALL types.

         if uType = 'EXPITEMQTY';
           exsr SelectEXPSQTY;
         endif;

CBIaA    // Create Cheney EXPSLDRFIL result set.
CBIaA
CBIaA    if allTypes
CBIaA       or uType = '*CBI'
CBIaA       or uType = 'EXPCBILOAD';
CBIaA         exsr SelectEXPSLDRFIL;
CBIaA    endif;

CBIaA    // Create Cheney EXPSHRMISP result set.
CBIaA
CBIaA    if allTypes
CBIaA       or uType = '*CBI'
CBIaA       or uType = 'EXPCBISHRT';
CBIaA         exsr SelectEXPSHRMISP;
CBIaA    endif;

CBIaA    // Create Chene EXPSTIHIGH result set.
CBIaA
CBIaA    if allTypes
CBIaA       or uType = '*CBI'
CBIaA       or uType = 'EXPCBITIHI';
CBIaA         exsr SelectEXPSTIHIGH;
CBIaA    endif;

CBIaA    // Create Chene EXPSCASEHR result set.
CBIaA
CBIaA    if allTypes
CBIaA       or uType = '*CBI'
CBIaA       or uType = 'EXPCBICASE';
CBIaA         exsr SelectEXPSCASEHR;
CBIaA    endif;

       endsr;
      /end-free

650bA*----------------------------------------------------------------
650bA*  MarkSTGBATCH   Mark STGBATCH records to return
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA  begsr MarkSTGBATCH;

         sBatches = 0;

         // Look for Export records with status 'R'

         setll (pWhse: 'R') stgbatch1;

         dow forever = forever;

           reade (pWhse: 'R') stgbatch1;

           if %eof(stgbatch1);
             leave;
           endif;

           if allTypes;
             if %subst(sbtype: 1: 3) <> 'EXP%';
               iter;
             endif;
           else;
             if sbtype <> uType;
               iter;
             endif;
           endif;

           getmicrotime(currstampuc:currstampsys);
           ucOffset = %diff(currstampuc: currstampsys: *HOURS);
           currstamploc = currstampsys + %hours(bfcoffset);

           sbstatus = 'P';
           sbststs = currstampsys;
           sbstsuc = currstampuc;
           sbexpid = expRecIdA;

           update sbrec;

           // See if we should look for more or get out.
           // If maximum not sent in, then limit to 100.

           sBatches += 1;
           if (pMaxBatches > 0 and sBatches = pMaxBatches)
              or (pMaxBatches <= 0 and sBatches = 100);
             leave;
           endif;

         enddo;

       endsr;
      /end-free

650bD*----------------------------------------------------------------
650bD*  MarkSTGBATCHx  Mark STGBATCH records to return
650bD*
650bD*  *** NO LONGER USED ****
650bD*
650bD*  This routine would not work correctly when the library list
650bD*  was changed in the calling PDKTEXPRS program. The first time
650bD*  through it would work correctly. But if the library list was
650bD*  changed on the second call, the update would fail. Through
650bD*  testing it was determined that the Fetch was working with
650bD*  the correct library. However, the update would error out
650bD*  saying that the cursor was still looking at the previous
650bD*  library. The end of the routine closes the cursor, so don't
650bD*  know why the cursor was still looking at previous library.
650bD*  It may have something to do with the program needing to be
650bD*  compiled with CLOSQLCSR(*ENDACTGRP). In the end, finally gave
650bD*  up and rewrote the routine using setll/reade/update.
650bD*
650bD*----------------------------------------------------------------
650bD
650bD /free
650bD  begsr MarkSTGBATCHx;

         sBatches = 0;

         SqlStmt = 'select * '
                 + 'from stgbatch '
                 + 'where sbwhse = ' + %char(pWhse) + ' '
                 +   'and sbstatus = ' + sq + 'R' + sq;

         select;
           when allTypes;
             sqlStmt = %trimr(sqlStmt) + ' '
                     + 'and sbtype like(' + sq + 'EXP%' + sq + ') ';
           other;
             sqlStmt = %trimr(sqlStmt) + ' '
                     + 'and sbtype = ' + sq + %trimr(uType) + sq;
         endsl;

         sqlStmt = %trimr(sqlStmt) + ' '
                 + 'order by sbwhse, sbaddts '
                 + 'for update of sbstatus, sbststs, sbstsuc, sbexpid';

         exec sql prepare sbUpdSel from :sqlStmt;
         if sqlstt <> sqlSuccess;
           pReturn = '*SBPREPERR';
           pMessage = 'SQL Prepare error occured in '
                    + 'DKTEXPORT/MarkSTGBATCH - '
                    + 'SQLSTT: ' + sqlstt + ', '
                    + 'SQLSTMT:' + %trimr(sqlStmt);
           dump(a);
           leavesr;
         endif;

         exec sql declare sbUpdCsr dynamic scroll cursor for sbUpdSel;
         if sqlstt <> sqlSuccess;
           pReturn = '*SBDCLERR1';
           pMessage = 'SQL Declare error occured in '
                    + 'DKTEXPORT/MarkSTGBATCH - '
                    + 'SQLSTT: ' + sqlstt + ', '
                    + 'SQLSTMT:' + %trimr(sqlStmt);
           dump(a);
           leavesr;
         endif;

         exec sql open sbUpdCsr;
         if sqlstt <> sqlSuccess;
           pReturn = '*SBOPENER1';
           pMessage = 'SQL Open error occured in '
                    + 'DKTEXPORT/MarkSTGBATCH - '
                    + 'SQLSTT: ' + sqlstt + ', '
                    + 'SQLSTMT:' + %trimr(sqlStmt);
           dump(a);
           leavesr;
         endif;

         dow forever = forever;

650bD   // Needed to comment these lines out so pgm would compile.
650bD   // exec sql fetch next from sbUpdCsr
650bD   //          into :sbrec;

           if sqlstt <> sqlSuccess;
             leave;
           endif;

           exec sql update stgbatch set
                      sbstatus = 'P',
                      sbststs = current_timestamp,
                      sbstsuc = current_timestamp - current_timezone,
                      sbexpid = :expRecIdA
                    where current of sbUpdCsr;

           // See if we should look for more or get out.
           // If maximum not sent in, then limit to 100.

           sBatches += 1;
           if (pMaxBatches > 0 and sBatches = pMaxBatches)
              or (pMaxBatches <= 0 and sBatches = 100);
             leave;
           endif;

         enddo;

         exec sql close sbUpdCsr;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  runInteractive  Run program interactively
     *----------------------------------------------------------------

      /free
       begsr runInteractive;

         // Adjustments

640cM    if allTypes or uType = 'EXPADJUST';
           monitor;
             it726s(alphaWhse);
           on-error;
             pReturn  = '*ERRIT726S';
             pMessage = 'Error calling IT726S';
             leavesr;
           endmon;
640cA    endif;

         // Purchase orders

640cM    if uType = 'EXPPO'
640cM       or (allTypes and client <> cheney);
640aA         monitor;
640aA           po726s(alphaWhse);
640aA         on-error;
640aA           pReturn  = '*ERRPO726S';
640aA           pMessage = 'Error calling PO726S';
640aA           leavesr;
640aA         endmon;
640cA    endif;

         // Customer routes

640cM    if allTypes or uType = 'EXPROUTE';
640cA    endif;

         // Closed customer routes
         // This is used when selection transactions are processed
         // separately. (This is done at Cheney with SAP interface).

640cM    if allTypes or uType = 'EXPCLSRTE';
640cA    endif;

         // Item quantity. Not include in *ALL types.

640cM    if uType = 'EXPITEMQTY';
640bA      monitor;
640bA        it736s(alphaWhse);
640bA      on-error;
640bA        pReturn  = '*ERRIT736S';
640bA        pMessage = 'Error calling IT736S';
640bA        leavesr;
640bA      endmon;
640cA    endif;

         // Item whse quantity Ver 2. Not include in *ALL types.

640dA    if uType = 'EXPITMQTY2';
640dA      monitor;
640dA        it740s(alphaWhse);
640dA      on-error;
640dA        pReturn  = '*ERRIT740S';
640dA        pMessage = 'Error calling IT740S';
640dA        leavesr;
640dA      endmon;
640dA    endif;

640eA    // License activity
640eA
640eA    if uType = 'EXPLICLOG'
640eA       or uType = 'EXPLLCOMBO'
640eA       or (allTypes and client <> cheney);
640eA         monitor;
640eA           ll726s(alphaWhse);
640eA         on-error;
640eA           pReturn  = '*ERRLL726S';
640eA           pMessage = 'Error calling LL726S';
640eA           leavesr;
640eA         endmon;
640eA    endif;

640fA    // Export Customer Returns
640fA
640fA    if uType = 'EXPRETURN'
640fA       or (allTypes and client <> cheney);
640fA         monitor;
640fA           or736s(alphaWhse);
640fA         on-error;
640fA           pReturn  = '*ERROR736S';
640fA           pMessage = 'Error calling OR736S';
640fA           leavesr;
640fA         endmon;
640fA    endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  runJobq  Submit program to jobq
     *----------------------------------------------------------------

      /free
       begsr runJobq;

         // Create command to submit

         // Adjustments

640cM    if allTypes or uType = 'EXPADJUST';
           cmd = 'call it726s ('
               +   sq + alphaWhse + sq + ' '
               + ')';
640cA      exsr  runJobqSubmit;
640cA      if pReturn = '*JOBQERR';
640cA        leavesr;
640cA      endif;
640cA    endif;

         // Purchase orders

640cM    if uType = 'EXPPO'
640cM       or (allTypes and client <> cheney);
640aA         cmd = 'call po726s ('
640aA             +   sq + alphaWhse + sq + ' '
640aA             + ')';
640cA         exsr  runJobqSubmit;
640cA         if pReturn = '*JOBQERR';
640cA           leavesr;
640cA         endif;
640cA    endif;

         // Customer routes

640cM    if allTypes or uType = 'EXPROUTE';
640cA    endif;

         // Closed customer routes
         // This is used when selection transactions are processed
         // separately. (This is done at Cheney with SAP interface).

640cM    if allTypes or uType = 'EXPCLSRTE';
640cA    endif;

         // Item quantity. Not include in *ALL types.

640cM    if uType = 'EXPITEMQTY';
640bA      cmd = 'call it736s ('
640bA          +   sq + alphaWhse + sq + ' '
640bA          + ')';
640cA      exsr  runJobqSubmit;
640cA      if pReturn = '*JOBQERR';
640cA        leavesr;
640cA      endif;
640cA    endif;

640dA    // Item whse quantity Ver 2. Not include in *ALL types.

640dA    if uType = 'EXPITMQTY2';
640dA      cmd = 'call it740s ('
640dA          +   sq + alphaWhse + sq + ' '
640dA          + ')';
640dA      exsr  runJobqSubmit;
640dA      if pReturn = '*JOBQERR';
640dA        leavesr;
640dA      endif;
640dA    endif;

640eA    // License activity
640eA
640eA    if uType = 'EXPLICLOG'
640eA       or uType = 'EXPLLCOMBO'
640eA       or (allTypes and client <> cheney);
640eA         cmd = 'call ll726s ('
640eA             +   sq + alphaWhse + sq + ' '
640eA             + ')';
640eA         exsr  runJobqSubmit;
640eA         if pReturn = '*JOBQERR';
640eA           leavesr;
640eA         endif;
640eA    endif;

640fA    // Export Customer Returns
640fA
640fA    if uType = 'EXPRETURN'
640fA       or (allTypes and client <> cheney);
640fA         cmd = 'call or736s ('
640fA             +   sq + alphaWhse + sq + ' '
640fA             + ')';
640fA         exsr  runJobqSubmit;
640fA         if pReturn = '*JOBQERR';
640fA           leavesr;
640fA         endif;
640fA    endif;

       endsr;
      /end-free

640Ac*----------------------------------------------------------------
640Ac*  runJobqSubmit  Submit program to jobq
640Ac*----------------------------------------------------------------
640Ac
640Ac /free
640Ac  begsr runJobqSubmit;

         cmd = 'sbmjob cmd(' + %trimr(cmd) + ') '
             + 'jobq(QSYSNOMAX) '
             + 'job(' + %trimr(uType) + ')';

         // Submit command

         monitor;
           qcmdexc(%trim(cmd): %len(%trim(cmd)));
         on-error;
           pReturn  = '*JOBQERR';
           dump(a);
         endmon;

         // Extract message

         wwMsgKey = *ALLx'00';
         QMHRCVPM(dsM2:
                  %size(dsM2):
                  'RCVM0200':
                  '*':
                  0:
                  '*NEXT':
                  wwMsgKey:
                  0:
                  '*OLD':
                  dsEC);
         wwMsgKey = dsM2_MsgKey;
         monitor;
           pMessage = %trim(%subst(dsm2_dta: dsm2_dtalen+1: dsm2_msglen));
         on-error *all;
           pMessage = ' ';
         endmon;

       endsr;
      /end-free

640cA*----------------------------------------------------------------
640cA*  SelectSTGBATCH   Select STGBATCH records to return
640cA*----------------------------------------------------------------
640cA
640cA /free
640cA  begsr SelectSTGBATCH;

         exec sql
           declare cursorSTGBATCH cursor for
             select * from stgbatch
             where sbwhse = :pWhse
               and sbexpid = :expRecIdA;

         if sqlstt <> sqlSuccess;
           logReturn = '*SBDECLAR2';
           logMessage = 'SQL Open error occured in '
                      + 'DKTEXPORT/SelectSTGBATCH - '
                      + 'SQLSTT: ' + sqlstt + ', '
                      + 'SQLSTMT:' + %trimr(sqlStmt);
           dump(a);
           //leavesr;
         endif;

         exec sql open cursorSTGBATCH;
         if sqlstt <> sqlSuccess;
           logReturn = '*SBOPEN2';
           logMessage = 'SQL Open error occured in '
                      + 'DKTEXPORT/SelectSTGBATCH - '
                      + 'SQLSTT: ' + sqlstt + ', '
                      + 'SQLSTMT:' + %trimr(sqlStmt);
           dump(a);
           //leavesr;
         endif;

       endsr;
      /end-free

640cA*----------------------------------------------------------------
640cA*  SelectEXPSADJ  Select EXPSADJ records to return
640cA*----------------------------------------------------------------
640cA
640cA /free
640cA  begsr SelectEXPSADJ;

         exec sql
           declare cursorEXPSADJ cursor for
             select * from expsadj
             where iewhse = :pwhse
               and iestatus = 'R'
               and iebatid in
                   (select sbbatid from stgbatch
                    where sbwhse = :pWhse
                      and sbexpid = :expRecIdA);

         if sqlstt <> sqlSuccess;
           logReturn = '*IEDECLARE';
           logMessage = 'SQL Declare error occured in '
                      + 'DKTEXPORT/SelectEXPSADJ - '
                      + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

         exec sql open cursorEXPSADJ;
         if sqlstt <> sqlSuccess;
           logReturn = '*IEOPEN';
           logMessage = 'SQL Open error occured in '
                      + 'DKTEXPORT/SelectEXPSADJ - '
                      + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

       endsr;
      /end-free

640eA*----------------------------------------------------------------
640eA*  SelectEXPSLICLOG  Select EXPSLICLOG records to return
640eA*----------------------------------------------------------------
640eA
640eA /free
640eA  begsr SelectEXPSLICLOG;

         exec sql
           declare cursorEXPSLICLOG cursor for
             select * from expsliclog
             where lewhse = :pwhse
               and lestatus = 'R'
               and lebatid in
                   (select sbbatid from stgbatch
                    where sbwhse = :pWhse
                      and sbexpid = :expRecIdA);

         if sqlstt <> sqlSuccess;
           logReturn = '*LEDECLARE';
           logMessage = 'SQL Declare error occured in '
                      + 'DKTEXPORT/SelectEXPSLICLOG - '
                      + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

         exec sql open cursorEXPSLICLOG;
         if sqlstt <> sqlSuccess;
           logReturn = '*LEOPEN';
           logMessage = 'SQL Open error occured in '
                      + 'DKTEXPORT/SelectEXPSLICLOG - '
                      + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

       endsr;
      /end-free

640eA*----------------------------------------------------------------
640eA*  SelectEXPSLLCOMB  Select EXPSLLCOMB records to return
640eA*----------------------------------------------------------------
640eA
640eA /free
640eA  begsr SelectEXPSLLCOMB;

         exec sql
           declare cursorEXPSLLCOMB cursor for
             select * from expsllcomb
             where lewhse = :pwhse
               and lestatus = 'R'
               and lebatid in
                   (select sbbatid from stgbatch
                    where sbwhse = :pWhse
                      and sbexpid = :expRecIdA);

         if sqlstt <> sqlSuccess;
           logReturn = '*LEDECLARE';
           logMessage = 'SQL Declare error occured in '
                      + 'DKTEXPORT/SelectEXPSLLCOMB - '
                      + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

         exec sql open cursorEXPSLLCOMB;
         if sqlstt <> sqlSuccess;
           logReturn = '*LEOPEN';
           logMessage = 'SQL Open error occured in '
                      + 'DKTEXPORT/SelectEXPSLLCOMB - '
                      + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

       endsr;
      /end-free

640cA*----------------------------------------------------------------
640cA*  SelectEXPSHRMISP   Select Cheney EXPSHRMISP records to return
640cA*----------------------------------------------------------------
640cA
640cA /free
640cA  begsr SelectEXPSHRMISP;

         exec sql
           declare cursorEXPSHRMISP cursor for
             select * from expshrmisp
             where sewhse = :pWhse
               and sestatus = 'R'
               and sebatid in
                   (select sbbatid from stgbatch
                    where sbwhse = :pWhse
                    and sbexpid = :expRecIdA);

         if sqlstt <> sqlSuccess;
           logReturn = '*SEDECLARE';
           logMessage = 'SQL Declare error occured in '
                    + 'DKTEXPORT/SelectEXPSHRMISP - '
                    + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

         exec sql open cursorEXPSHRMISP;
         if sqlstt <> sqlSuccess;
           logReturn = '*SEOPEN';
           logMessage = 'SQL Open error occured in '
                      + 'DKTEXPORT/SelectEXPSHRMISP - '
                      + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

       endsr;
      /end-free

640cA*----------------------------------------------------------------
640cA*  SelectEXPSLDRFIL   Select Cheney EXPSLDRFIL records to return
640cA*----------------------------------------------------------------
640cA
640cA /free
640cA  begsr SelectEXPSLDRFIL;

         exec sql
           declare cursorEXPSLDRFIL cursor for
             select * from expsldrfil
             where lefwhs = :pWhse
               and lestatus = 'R'
               and lebatid in
                   (select sbbatid from stgbatch
                    where sbwhse = :pWhse
                    and sbexpid = :expRecIdA);

         if sqlstt <> sqlSuccess;
           logReturn = '*LEFDECLAR';
           logMessage = 'SQL Declare error occured in '
                    + 'DKTEXPORT/SelectEXPSLDRFIL - '
                    + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

         exec sql open cursorEXPSLDRFIL;
         if sqlstt <> sqlSuccess;
           logReturn = '*LEFOPEN';
           logMessage = 'SQL Open error occured in '
                      + 'DKTEXPORT/SelectEXPSLDRFIL - '
                      + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

       endsr;
      /end-free

640cA*----------------------------------------------------------------
640cA*  SelectEXPSORDC  Select EXPSORDC records to return
640cA*----------------------------------------------------------------
640cA
640cA /free
640cA  begsr SelectEXPSORDC;

         exec sql
           declare cursorEXPSORDC cursor for
             select * from expsordc
             where oecwhs = :pWhse
               and oecstatus = 'R'
               and oecbatid in
                   (select sbbatid from stgbatch
                    where sbwhse = :pWhse
                    and sbexpid = :expRecIdA);

         if sqlstt <> sqlSuccess;
           logReturn = '*OECDECLAR';
           logMessage = 'SQL Declare error occured in '
                    + 'DKTEXPORT/SelectEXPSORDC - '
                    + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

         exec sql open cursorEXPSORDC;
         if sqlstt <> sqlSuccess;
           logReturn = '*OECOPEN';
           logMessage = 'SQL Open error occured in '
                      + 'DKTEXPORT/SelectEXPSORDC - '
                      + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

       endsr;
      /end-free

640cA*----------------------------------------------------------------
640cA*  SelectEXPSORDD  Select EXPSORDD records to return
640cA*----------------------------------------------------------------
640cA
640cA /free
640cA  begsr SelectEXPSORDD;

         exec sql
           declare cursorEXPSORDD cursor for
             select * from expsordd
             where oedwhs = :pWhse
               and oedstatus = 'R'
               and oedbatid in
                   (select sbbatid from stgbatch
                    where sbwhse = :pWhse
                    and sbexpid = :expRecIdA);

         if sqlstt <> sqlSuccess;
           logReturn = '*OEDDECLAR';
           logMessage = 'SQL Declare error occured in '
                    + 'DKTEXPORT/SelectEXPSORDD - '
                    + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

         exec sql open cursorEXPSORDD;
         if sqlstt <> sqlSuccess;
           logReturn = '*OEDOPEN';
           logMessage = 'SQL Open error occured in '
                      + 'DKTEXPORT/SelectEXPSORDD - '
                      + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

       endsr;
      /end-free

640cA*----------------------------------------------------------------
640cA*  SelectEXPSORDE  Select EXPSORDE records to return
640cA*----------------------------------------------------------------
640cA
640cA /free
640cA  begsr SelectEXPSORDE;

         exec sql
           declare cursorEXPSORDE cursor for
             select * from expsorde
             where oeewhs = :pWhse
               and oeestatus = 'R'
               and oeebatid in
                   (select sbbatid from stgbatch
                    where sbwhse = :pWhse
                    and sbexpid = :expRecIdA);

         if sqlstt <> sqlSuccess;
           logReturn = '*OEEDECLAR';
           logMessage = 'SQL Declare error occured in '
                    + 'DKTEXPORT/SelectEXPSORDE - '
                    + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

         exec sql open cursorEXPSORDE;
         if sqlstt <> sqlSuccess;
           logReturn = '*OEEOPEN';
           logMessage = 'SQL Open error occured in '
                      + 'DKTEXPORT/SelectEXPSORDE - '
                      + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

       endsr;
      /end-free

640cA*----------------------------------------------------------------
640cA*  SelectEXPSORDH  Select EXPSORDH records to return
640cA*----------------------------------------------------------------
640cA
640cA /free
640cA  begsr SelectEXPSORDH;

         exec sql
           declare cursorEXPSORDH cursor for
             select * from expsordh
             where oehwhs = :pWhse
               and oehstatus = 'R'
               and oehbatid in
                   (select sbbatid from stgbatch
                    where sbwhse = :pWhse
                    and sbexpid = :expRecIdA);

         if sqlstt <> sqlSuccess;
           logReturn = '*OEHDECLAR';
           logMessage = 'SQL Declare error occured in '
                    + 'DKTEXPORT/SelectEXPSORDH - '
                    + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

         exec sql open cursorEXPSORDH;
         if sqlstt <> sqlSuccess;
           logReturn = '*OEHOPEN';
           logMessage = 'SQL Open error occured in '
                      + 'DKTEXPORT/SelectEXPSORDH - '
                      + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

       endsr;
      /end-free

640cA*----------------------------------------------------------------
640cA*  SelectEXPSORDL  Select EXPSORDL records to return
640cA*----------------------------------------------------------------
640cA
640cA /free
640cA  begsr SelectEXPSORDL;

         exec sql
           declare cursorEXPSORDL cursor for
             select * from expsordl
             where oelwhs = :pWhse
               and oelstatus = 'R'
               and oelbatid in
                   (select sbbatid from stgbatch
                    where sbwhse = :pWhse
                    and sbexpid = :expRecIdA);

         if sqlstt <> sqlSuccess;
           logReturn = '*OELDECLAR';
           logMessage = 'SQL Declare error occured in '
                    + 'DKTEXPORT/SelectEXPSORDL - '
                    + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

         exec sql open cursorEXPSORDL;
         if sqlstt <> sqlSuccess;
           logReturn = '*OELOPEN';
           logMessage = 'SQL Open error occured in '
                      + 'DKTEXPORT/SelectEXPSORDL - '
                      + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

       endsr;
      /end-free

640cA*----------------------------------------------------------------
640cA*  SelectEXPSORDP  Select EXPSORDP records to return
640cA*----------------------------------------------------------------
640cA
640cA /free
640cA  begsr SelectEXPSORDP;

         exec sql
           declare cursorEXPSORDP cursor for
             select * from expsordp
             where oepwhs = :pWhse
               and oepstatus = 'R'
               and oepbatid in
                   (select sbbatid from stgbatch
                    where sbwhse = :pWhse
                    and sbexpid = :expRecIdA);

         if sqlstt <> sqlSuccess;
           logReturn = '*OEPDECLAR';
           logMessage = 'SQL Declare error occured in '
                    + 'DKTEXPORT/SelectEXPSORDP - '
                    + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

         exec sql open cursorEXPSORDP;
         if sqlstt <> sqlSuccess;
           logReturn = '*OEPOPEN';
           logMessage = 'SQL Open error occured in '
                      + 'DKTEXPORT/SelectEXPSORDP - '
                      + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

       endsr;
      /end-free

640cA*----------------------------------------------------------------
640cA*  SelectEXPSORDT  Select EXPSORDT records to return
640cA*----------------------------------------------------------------
640cA
640cA /free
640cA  begsr SelectEXPSORDT;

         exec sql
           declare cursorEXPSORDT cursor for
             select * from expsordt
             where oetwhs = :pWhse
               and oetstatus = 'R'
               and oetbatid in
                   (select sbbatid from stgbatch
                    where sbwhse = :pWhse
                    and sbexpid = :expRecIdA);

         if sqlstt <> sqlSuccess;
           logReturn = '*OETDECLAR';
           logMessage = 'SQL Declare error occured in '
                    + 'DKTEXPORT/SelectEXPSORDT - '
                    + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

         exec sql open cursorEXPSORDT;
         if sqlstt <> sqlSuccess;
           logReturn = '*OETOPEN';
           logMessage = 'SQL Open error occured in '
                      + 'DKTEXPORT/SelectEXPSORDT - '
                      + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

       endsr;
      /end-free

640cA*----------------------------------------------------------------
640cA*  SelectEXPSPOD  Select EXPSPOD records to return
640cA*----------------------------------------------------------------
640cA
640cA /free
640cA  begsr SelectEXPSPOD;

         exec sql
           declare cursorEXPSPOD cursor for
             select * from expspod
             where pedwhs = :pWhse
               and pedstatus = 'R'
               and pedbatid in
                   (select sbbatid from stgbatch
                    where sbwhse = :pWhse
                    and sbexpid = :expRecIdA);

         if sqlstt <> sqlSuccess;
           logReturn = '*PEDDECLAR';
           logMessage = 'SQL Declare error occured in '
                    + 'DKTEXPORT/SelectEXPSPOD - '
                    + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

         exec sql open cursorEXPSPOD;
         if sqlstt <> sqlSuccess;
           logReturn = '*PEDOPEN';
           logMessage = 'SQL Open error occured in '
                      + 'DKTEXPORT/SelectEXPSPOD - '
                      + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

       endsr;
      /end-free

640cA*----------------------------------------------------------------
640cA*  SelectEXPSPOE  Select EXPSPOE records to return
640cA*----------------------------------------------------------------
640cA
640cA /free
640cA  begsr SelectEXPSPOE;

         exec sql
           declare cursorEXPSPOE cursor for
             select * from expspoe
             where poewhs = :pWhse
               and poestatus = 'R'
               and poebatid in
                   (select sbbatid from stgbatch
                    where sbwhse = :pWhse
                    and sbexpid = :expRecIdA);

         if sqlstt <> sqlSuccess;
           logReturn = '*POEDECLAR';
           logMessage = 'SQL Declare error occured in '
                    + 'DKTEXPORT/SelectEXPSPOE - '
                    + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

         exec sql open cursorEXPSPOE;
         if sqlstt <> sqlSuccess;
           logReturn = '*POEOPEN';
           logMessage = 'SQL Open error occured in '
                      + 'DKTEXPORT/SelectEXPSPOE - '
                      + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

       endsr;
      /end-free

640cA*----------------------------------------------------------------
640cA*  SelectEXPSPOH  Select EXPSPOH records to return
640cA*----------------------------------------------------------------
640cA
640cA /free
640cA  begsr SelectEXPSPOH;

         exec sql
           declare cursorEXPSPOH cursor for
             select * from expspoh
             where pehwhs = :pWhse
               and pehstatus = 'R'
               and pehbatid in
                   (select sbbatid from stgbatch
                    where sbwhse = :pWhse
                    and sbexpid = :expRecIdA);

         if sqlstt <> sqlSuccess;
           logReturn = '*PEHDECLAR';
           logMessage = 'SQL Declare error occured in '
                    + 'DKTEXPORT/SelectEXPSPOH - '
                    + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

         exec sql open cursorEXPSPOH;
         if sqlstt <> sqlSuccess;
           logReturn = '*PEHOPEN';
           logMessage = 'SQL Open error occured in '
                      + 'DKTEXPORT/SelectEXPSPOH - '
                      + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

       endsr;
      /end-free

640fA*----------------------------------------------------------------
640fA*  SelectEXPSRTN   Select EXPSRTN records to return
640fA*----------------------------------------------------------------
640fA
640fA /free
640fA  begsr SelectEXPSRTN;

         exec sql
           declare cursorEXPSRTN cursor for
             select * from expsrtn
             where oewhse = :pWhse
               and oestatus = 'R'
               and oebatid in
                   (select sbbatid from stgbatch
                    where sbwhse = :pWhse
                    and sbexpid = :expRecIdA);

         if sqlstt <> sqlSuccess;
           logReturn = '*QEDECLARE';
           logMessage = 'SQL Declare error occured in '
                    + 'DKTEXPORT/SelectEXPSRTN - '
                    + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

         exec sql open cursorEXPSRTN;
         if sqlstt <> sqlSuccess;
           logReturn = '*QEOPEN';
           logMessage = 'SQL Open error occured in '
                      + 'DKTEXPORT/SelectEXPSRTN - '
                      + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

       endsr;
      /end-free

640cA*----------------------------------------------------------------
640cA*  SelectEXPSQTY   Select EXPSQTY records to return
640cA*----------------------------------------------------------------
640cA
640cA /free
640cA  begsr SelectEXPSQTY;

         exec sql
           declare cursorEXPSQTY cursor for
             select * from expsqty
             where qewhse = :pWhse
               and qestatus = 'R'
               and qebatid in
                   (select sbbatid from stgbatch
                    where sbwhse = :pWhse
                    and sbexpid = :expRecIdA);

         if sqlstt <> sqlSuccess;
           logReturn = '*QEDECLARE';
           logMessage = 'SQL Declare error occured in '
                    + 'DKTEXPORT/SelectEXPSQTY - '
                    + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

         exec sql open cursorEXPSQTY;
         if sqlstt <> sqlSuccess;
           logReturn = '*QEOPEN';
           logMessage = 'SQL Open error occured in '
                      + 'DKTEXPORT/SelectEXPSQTY - '
                      + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

       endsr;
      /end-free

640cA*----------------------------------------------------------------
640cA*  SelectEXPSTIHIGH  Select Cheney EXPSTIHIGH records to return
640cA*----------------------------------------------------------------
640cA
640cA /free
640cA  begsr SelectEXPSTIHIGH;

         exec sql
           declare cursorEXPSTIHIGH cursor for
             select * from expstihigh
             where tewhse = :pWhse
               and testatus = 'R'
               and tebatid in
                   (select sbbatid from stgbatch
                    where sbwhse = :pWhse
                    and sbexpid = :expRecIdA);

         if sqlstt <> sqlSuccess;
           logReturn = '*TEDECLARE';
           logMessage = 'SQL Declare error occured in '
                    + 'DKTEXPORT/SelectEXPSTIHIGH - '
                    + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

         exec sql open cursorEXPSTIHIGH;
         if sqlstt <> sqlSuccess;
           logReturn = '*TEOPEN';
           logMessage = 'SQL Open error occured in '
                      + 'DKTEXPORT/SelectEXPSTIHIGH - '
                      + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

       endsr;
      /end-free

640cA*----------------------------------------------------------------
640cA*  SelectEXPSCASEHR  Select Cheney EXPSCASEHR records to return
640cA*----------------------------------------------------------------
640cA
640cA /free
640cA  begsr SelectEXPSCASEHR;

         exec sql
           declare cursorEXPSCASEHR cursor for
             select * from expscasehr
             where cewhse = :pWhse
               and cestatus = 'R'
               and cebatid in
                   (select sbbatid from stgbatch
                    where sbwhse = :pWhse
                    and sbexpid = :expRecIdA);

         if sqlstt <> sqlSuccess;
           logReturn = '*CEDECLARE';
           logMessage = 'SQL Declare error occured in '
                    + 'DKTEXPORT/SelectEXPSCASEHR - '
                    + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

         exec sql open cursorEXPSCASEHR;
         if sqlstt <> sqlSuccess;
           logReturn = '*CEOPEN';
           logMessage = 'SQL Open error occured in '
                      + 'DKTEXPORT/SelectEXPSCASEHR - '
                      + 'SQLSTT: ' + sqlstt;
           dump(a);
           //leavesr;
         endif;

       endsr;
      /end-free

640cA*----------------------------------------------------------------
640cA*  SendSets   Send back result sets
640cA*----------------------------------------------------------------
640cA
640cA /free
640cA  begsr SendSets;

640cA    if pProgram <> 'PDKTEXPRS';
640cA      leavesr;
640cA    endif;

         sReturn = pReturn;
         sMessage = pMessage;
         sSetsReturned = ' ';

650bA    sMessage = %trim(pMessage) + ' '
650bA             + 'Exp Id: ' + expRecIdA;

         select;

           when uSets = 'RTN' or sBatches = 0 or pReturn <> '*OK';
             exec sql
               set result sets with return to client
                   array :pgmStatus for 1 rows;

           when uSets = 'STG';
             sSetsReturned = 'STGBATCH';
             exec sql
               set result sets with return to client
                   array :pgmStatus for 1 rows,
                   cursor cursorSTGBATCH;

           when uType = 'EXPADJUST';
             sSetsReturned = 'STGBATCH,EXPSADJ';
             exec sql
               set result sets with return to client
                   array :pgmStatus for 1 rows,
                   cursor cursorSTGBATCH,
                   cursor cursorEXPSADJ;

           when uType = 'EXPCLSRTE';
             sSetsReturned = 'STGBATCH,EXPSORDH,EXPSORDD';
             exec sql
               set result sets with return to client
                   array :pgmStatus for 1 rows,
                   cursor cursorSTGBATCH,
                   cursor cursorEXPSORDH,
640aA              cursor cursorEXPSORDD;

           when uType = 'EXPSELTRAN' and client = cheney;
             sSetsReturned = 'STGBATCH,EXPSORDL,EXPSORDC,'
                           + 'EXPSORDP';
             exec sql
               set result sets with return to client
                   array :pgmStatus for 1 rows,
                   cursor cursorSTGBATCH,
                   cursor cursorEXPSORDL,
                   cursor cursorEXPSORDC,
                   cursor cursorEXPSORDP;

           when uType = 'EXPSELTRAN';
             sSetsReturned = 'STGBATCH,EXPSORDL,EXPSORDC,'
                           + 'EXPSORDP,EXPSORDE,EXPSORDT';
             exec sql
               set result sets with return to client
                   array :pgmStatus for 1 rows,
                   cursor cursorSTGBATCH,
                   cursor cursorEXPSORDL,
                   cursor cursorEXPSORDC,
                   cursor cursorEXPSORDP,
                   cursor cursorEXPSORDE,
                   cursor cursorEXPSORDT;

           when uType = 'EXPROUTE' and client = cheney;
             sSetsReturned = 'STGBATCH,EXPSORDH,EXPSORDD,'
                           + 'EXPSORDL,EXPSORDC,'
                           + 'EXPSORDP';
             exec sql
               set result sets with return to client
                   array :pgmStatus for 1 rows,
                   cursor cursorSTGBATCH,
                   cursor cursorEXPSORDH,
640aA              cursor cursorEXPSORDD,
                   cursor cursorEXPSORDL,
                   cursor cursorEXPSORDC,
                   cursor cursorEXPSORDP;

           when uType = 'EXPROUTE';
             sSetsReturned = 'STGBATCH,EXPSORDH,EXPSORDD,'
                           + 'EXPSORDL,EXPSORDC,'
                           + 'EXPSORDP,EXPSORDE,EXPSORDT';
             exec sql
               set result sets with return to client
                   array :pgmStatus for 1 rows,
                   cursor cursorSTGBATCH,
                   cursor cursorEXPSORDH,
640aA              cursor cursorEXPSORDD,
                   cursor cursorEXPSORDL,
                   cursor cursorEXPSORDC,
                   cursor cursorEXPSORDP,
                   cursor cursorEXPSORDE,
                   cursor cursorEXPSORDT;

           when uType = 'EXPPO';
             sSetsReturned = 'STGBATCH,'
                           + 'EXPSPOH,EXPSPOD,EXPSPOE';
             exec sql
               set result sets with return to client
                   array :pgmStatus for 1 rows,
                   cursor cursorSTGBATCH,
                   cursor cursorEXPSPOH,
                   cursor cursorEXPSPOD,
                   cursor cursorEXPSPOE;

           when uType = 'EXPITEMQTY';
             sSetsReturned = 'STGBATCH,EXPSQTY';
             exec sql
               set result sets with return to client
                   array :pgmStatus for 1 rows,
                   cursor cursorSTGBATCH,
                   cursor cursorEXPSQTY;

640eA      when uType = 'EXPLICLOG';
640eA        sSetsReturned = 'STGBATCH,EXPSLICLOG';
640eA        exec sql
640eA          set result sets with return to client
640eA              array :pgmStatus for 1 rows,
640eA              cursor cursorSTGBATCH,
640eA              cursor cursorEXPSLICLOG;

640eA      when uType = 'EXPLLCOMBO';
640eA        sSetsReturned = 'STGBATCH,EXPSLLCOMB';
640eA        exec sql
640eA          set result sets with return to client
640eA              array :pgmStatus for 1 rows,
640eA              cursor cursorSTGBATCH,
640eA              cursor cursorEXPSLLCOMB;

640fA      when uType = 'EXPRETURN';
640fA        sSetsReturned = 'STGBATCH,EXPSRTN';
640fA        exec sql
640fA          set result sets with return to client
640fA              array :pgmStatus for 1 rows,
640fA              cursor cursorSTGBATCH,
640fA              cursor cursorEXPSRTN;

CBIaA      when uType = 'EXPCBILOAD';
CBIaA        sSetsReturned = 'STGBATCH,EXPSLDRFIL';
CBIaA        exec sql
CBIaA          set result sets with return to client
CBIaA              array :pgmStatus for 1 rows,
CBIaA              cursor cursorSTGBATCH,
CBIaA              cursor cursorEXPSLDRFIL;

CBIaA      when uType = 'EXPCBISHRT';
CBIaA        sSetsReturned = 'STGBATCH,EXPSHRMISP';
CBIaA        exec sql
CBIaA          set result sets with return to client
CBIaA              array :pgmStatus for 1 rows,
CBIaA              cursor cursorSTGBATCH,
CBIaA              cursor cursorEXPSHRMISP;

CBIaA      when uType = 'EXPCBITIHI';
CBIaA        sSetsReturned = 'STGBATCH,EXPSTIHIGH';
CBIaA        exec sql
CBIaA          set result sets with return to client
CBIaA              array :pgmStatus for 1 rows,
CBIaA              cursor cursorSTGBATCH,
CBIaA              cursor cursorEXPSTIHIGH;

CBIaA      when uType = 'EXPCBICASE';
CBIaA        sSetsReturned = 'STGBATCH,EXPSCASEHR';
CBIaA        exec sql
CBIaA          set result sets with return to client
CBIaA              array :pgmStatus for 1 rows,
CBIaA              cursor cursorSTGBATCH,
CBIaA              cursor cursorEXPSCASEHR;

CBIaA      when uType = '*ALL' and client = cheney;
CBIaA        sSetsReturned = 'STGBATCH,EXPSORDH,EXPSORDD,'
CBIaA                      + 'EXPSORDL,EXPSORDC,'
CBIaA                      + 'EXPSORDP,'
CBIaA                      + 'EXPSADJ,'
CBIaA                      + 'EXPSLDRFIL,EXPSHRMISP,EXPSTIHIGH,'
CBIaA                      + 'EXPSCASEHR';
CBIaA        exec sql
CBIaA          set result sets with return to client
CBIaA              array :pgmStatus for 1 rows,
CBIaA              cursor cursorSTGBATCH,
CBIaA              cursor cursorEXPSORDH,
CBIaA              cursor cursorEXPSORDD,
CBIaA              cursor cursorEXPSORDL,
CBIaA              cursor cursorEXPSORDC,
CBIaA              cursor cursorEXPSORDP,
CBIaA              cursor cursorEXPSADJ,
CBIaA              cursor cursorEXPSLDRFIL,
CBIaA              cursor cursorEXPSHRMISP,
CBIaA              cursor cursorEXPSTIHIGH,
CBIaA              cursor cursorEXPSCASEHR;

           when uType = '*ALL';
             sSetsReturned = 'STGBATCH,EXPSORDH,EXPSORDD,'
                           + 'EXPSORDL,EXPSORDC,'
                           + 'EXPSORDP,EXPSORDE,EXPSORDT,'
                           + 'EXPSPOH,EXPSPOD,EXPSPOE,'
                           + 'EXPSADJ';
             exec sql
               set result sets with return to client
                   array :pgmStatus for 1 rows,
                   cursor cursorSTGBATCH,
                   cursor cursorEXPSORDH,
640aA              cursor cursorEXPSORDD,
                   cursor cursorEXPSORDL,
                   cursor cursorEXPSORDC,
                   cursor cursorEXPSORDP,
                   cursor cursorEXPSORDE,
                   cursor cursorEXPSORDT,
                   cursor cursorEXPSPOH,
                   cursor cursorEXPSPOD,
                   cursor cursorEXPSPOE,
                   cursor cursorEXPSADJ;

CBIaA      when uType = '*CBI';
CBIaA        sSetsReturned = 'STGBATCH,'
CBIaA                      + 'EXPSLDRFIL,EXPSHRMISP,EXPSTIHIGH,'
CBIaA                      + 'EXPSCASEHR';
CBIaA        exec sql
CBIaA          set result sets with return to client
CBIaA              array :pgmStatus for 1 rows,
CBIaA              cursor cursorSTGBATCH,
CBIaA              cursor cursorEXPSLDRFIL,
CBIaA              cursor cursorEXPSHRMISP,
CBIaA              cursor cursorEXPSTIHIGH,
CBIaA              cursor cursorEXPSCASEHR;

         endsl;

       endsr;
      /end-free
