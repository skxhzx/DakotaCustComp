417cA /copy *libl/qcopysrc,hspecs
650aA*----------------------------------------------------------------
650aA* COMPILE WITH FOLLOWING OPTIONS:
650aA*
650aA*  Commitment control (COMMIT)  . . . *NONE
650aA*  Close SQL Cursor (CLOSQLCSR) . . . *ENDACTGRP
650aA*  Delay PREPARE (DLYPRP) . . . . . . *YES
650aA*
650aA*  *ENDACTGRP must be used in this program because *ENDMOD
650aA*  closes the cursors pointing to the returned result sets
650aA*  causing an error in the calling Stored Procedure.
650aA*
650aA*----------------------------------------------------------------

     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  DKTIMPORT   Dakota import
     *  11 January 2011
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
640 A*    01/11/11  DAS  6.40
     *      - Created.
     *
640aA*    02/12/11  DAS  6.40a
     *      - Added PO Import.
     *
640bA*    02/24/11  DAS  6.40b
     *      - Added pProgram parm
     *      - Added logic to pass back result sets when calling
     *        program is PDKTIMPRS.
     *
640cA*    03/04/11  DAS  6.40c
     *      - Added StuffIt
     *      - Added Total Qty Ordered
     *
640dA*    03/05/11  DAS  6.40d
     *      - Removed unnecessary parms to OI255S/OI285S
     *
640eA*    05/06/11  DAS  6.40e
     *      - Changed IMPORDQTY to IMPQTYORD.
     *
650aA*    05/29/13  DAS  6.50a
     *      - Added compile comments at top of program.
     *
650b *    09/03/14  RTR  6.50b
     *      - Added Host Customer Returns.
     *
710a *    02/28/17  RTR  7.10a
     *      - Added IMPROUTENS for NetSuite route import.
720a *    10/11/18  RTR  7.20a
     *      - Added IMPPCKDEM2 for decimal qty and UOMs.
730a *    01/29/19  RTR  7.30a
     *      - Added IMPUCIPRD for UCI Production Import. Originally for
     *        Chef's Warehouse
     *
730b *    01/07/20  LMC  7.30b
     *      - Recompile only.                                         r
     *
740 A*    12/02/20  MLB  7.40
     *      - Enh: Added new import type, IMPINVCE import invoice order
     *        details for Trax.
     *
750 A*    08/25/15  RTR  7.50  Was 7.00a at Sunrise.
     *      - Added Comparison Report.
     *
770aA*    05/05/23  KDE  7.70a
     *      - Enh: Add code to support status 9.  PO Import will
     *        handle processing an error email from there when
     *        this occurs
780aA*    03/01/24  LMC  7.80a
     *      - Added Host Lot Comparison
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Custom Revisions - Cheney Brothers
     *
CBIaA*    01/27/11  DAS  CBIa
     *      - Added type IMPSMHITEM.
     *
     *----------------------------------------------------------------
     * Custom Revisions - Eastland Foods
     *
EFCaA*    05/23/13  RTR  EFCa
     *      - Added call to OI286S for RMS Import.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pType       Batch type
     *      pBatId      Batch id
     *      pRunType    I = Interactive, J = Jobq
640bA*      pProgram    Calling program
     *
     *    Returned Parameters
     *      pReturn     *OK
     *      pMessage    Error message
     *
     *----------------------------------------------------------------

     D dktimport       pr                  extpgm('DKTIMPORT')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pBatId                      11    const
     D   pRunType                     1    const
640bAD   pProgram                    10    const
      * Output
     D   pReturn                     10
     D   pMessage                   200

     D dktimport       pi
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pBatId                      11    const
     D   pRunType                     1    const
640bAD   pProgram                    10    const
      * Output
     D   pReturn                     10
     D   pMessage                   200

     *----------------------------------------------------------------
     *  Client id's
     *----------------------------------------------------------------

      /copy qcopysrc,id#cheney
EFCaA /copy qcopysrc,id#eastlan

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D sbrec         E ds                  extname(stgbatch) inz(*EXTDFT)

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

     D alphaWhse       s              3
     D cmd             s           3000    varying
     D client          s             10
     D clientLoc       s             10
650bAD reccnt          s             10i 0
     D temp3n          s              3p 0
     D uRunType        s              1
     D uType           s             10
     D wwMsgKey        s              4A

640bA*----------------------------------------------------------------
640bA*  Return parameter result set
640bA*----------------------------------------------------------------
640bA
640bAD pgmStatus       ds                  occurs(1)
640bAD  sReturn                      10
640bAD  sMessage                    200

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
     *  Prototypes
     *----------------------------------------------------------------

530aA /copy qcopysrc,p.qcmdexc

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

640cAD hq121s          pr                  extpgm('HQ121S')
640cAD  pWhse                         3    const
640cAD  pBatid                       11    const
640cAD  pReturn                      10
640cAD  pMessage                    200

640cAD hq245s          pr                  extpgm('HQ245S')
640cAD  pWhse                         3    const
640cAD  pBatid                       11    const
640cAD  pType                        10    const
640cAD  pReturn                      10
640cAD  pMessage                    200

720aAD hq247s          pr                  extpgm('HQ247S')
720aAD  pWhse                         3    const
720aAD  pBatid                       11    const
720aAD  pType                        10    const
720aAD  pReturn                      10
720aAD  pMessage                    200

640cAD ii255s          pr                  extpgm('II255S')
640cAD  pWhse                         3    const
640cAD  pBatid                       11    const
640cAD  pReturn                      10
640cAD  pMessage                    200

     D ii265s          pr                  extpgm('II265S')
     D  pWhse                         3    const
     D  pBatid                       11    const
     D  pReturn                      10
     D  pMessage                    200

     D ii295s          pr                  extpgm('II295S')
     D  pWhse                         3    const
     D  pBatid                       11    const
     D  pReturn                      10
     D  pMessage                    200

780aAD it961s          pr                  extpgm('IT961S')
780aAD  pWhse                         3    const
780aAD  pBatid                       11    const
780aAD  pReturn                      10
780aAD  pMessage                    200

750 AD it971s          pr                  extpgm('IT971S')
750 AD  pWhse                         3    const
750 AD  pBatid                       11    const
750 AD  pReturn                      10
750 AD  pMessage                    200

640cAD oi255s          pr                  extpgm('OI255S')
640cAD  pWhse                         3    const
640cAD  pBatid                       11    const
640cAD  pReturn                      10
640cAD  pMessage                    200

640cAD oi285s          pr                  extpgm('OI285S')
640cAD  pWhse                         3    const
640cAD  pBatid                       11    const
640cAD  pReturn                      10
640cAD  pMessage                    200

EFCaAD oi286s          pr                  extpgm('OI286S')
EFCaAD  pWhse                         3    const
EFCaAD  pBatid                       11    const
EFCaAD  pReturn                      10
EFCaAD  pMessage                    200

710aAD oi405s          pr                  extpgm('OI405S')
710aAD  pWhse                         3    const
710aAD  pBatid                       11    const
710aAD  pReturn                      10
710aAD  pMessage                    200

640aAD pi265s          pr                  extpgm('PI265S')
640aAD  pWhse                         3    const
640aAD  pBatid                       11    const
640aAD  pReturn                      10
640aAD  pMessage                    200

640cAD po236s          pr                  extpgm('PO236S')
640cAD  pWhse                         3    const
640cAD  pBatid                       11    const
640cAD  pReturn                      10
640cAD  pMessage                    200

650bAD rn235s          pr                  extpgm('RN235S')
650bAD  pWhse                         3    const
650bAD  pBatid                       11    const
650bAD  pReturn                      10
650bAD  pMessage                    200

640cAD si255s          pr                  extpgm('SI255S')
640cAD  pWhse                         3    const
640cAD  pBatid                       11    const
640cAD  pReturn                      10
640cAD  pMessage                    200

730aAD ui250s          pr                  extpgm('UI250S')
730aAD  pWhse                         3    const
730aAD  pBatid                       11    const
730aAD  pReturn                      10
730aAD  pMessage                    200

740 AD vc255s          pr                  extpgm('VC255S')
740 AD  pWhse                         3    const
740 AD  pBatid                       11    const
740 AD  pReturn                      10
740 AD  pMessage                    200

CBIaAD manhatns        pr                  extpgm('MANHATNS')
     D  pWhse                         3    const
     D  pBatid                       11    const
     D  pReturn                      10
     D  pMessage                    200

      /free

         *inlr = *on;

         pReturn = '*OK';
         pMessage = ' ';

         // Translate input into upper case.

         uType = %xlate(xlower: xupper: pType);
         uRunType = %xlate(xlower: xupper: pRunType);

         // Convert warehouse to alpha

         alphaWhse = %trim(%char(pWhse));

         // Verify run type

         if uRunType <> 'I' and uRunType <> 'J';
           pReturn  = '*INVLDRTYP';
           pMessage = 'Invalid run type sent (' + uRunType + '). '
                    + 'Valid types are I=Interactive and J=Jobq. ';
640bA      exsr SendSet;
           return;
         endif;

         // Batch id must exist in STGBATCH file

         exsr ChkStgBatch;
         if error;
640bA      exsr SendSet;
           return;
         endif;

         // Check for records in import file

         exsr ChkFile;
         if error;
640bA      exsr SendSet;
           return;
         endif;

         // Check for records in import file

         if uRunType = 'I';
           exsr runInteractive;
         else;
           exsr runJobq;
         endif;

640bA    exsr SendSet;
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

     *----------------------------------------------------------------
     *  ChkStgBatch  Check for stgbatch record
     *----------------------------------------------------------------

      /free
       begsr ChkStgBatch;

         error = *off;

         // Get stgbatch record for batch id.

         exec sql select sbtype, sbstatus, sbststs
                    into :sbtype, :sbstatus, :sbststs
                  from stgbatch
                  where sbwhse = :pwhse
                    and sbbatid = :pbatid
                  fetch first 1 rows only;

         if sqlstt <> sqlSuccess;
           error = *on;
           pReturn  = '*NOTFOUND';
           pMessage = 'Whse/Batch id ' + %char(pWhse) + '/'
                    + %trim(pBatId) + ' '
                    + 'not found in file STGBATCH - '
                    + 'SQLSTT ' + sqlstt;
           leavesr;
         endif;

         // Batch type must match type sent in.

         if sbtype <> uType;
           error = *on;
           pReturn  = '*WRONGTYPE';
           pMessage = 'Import type sent (' + %trim(uType) + ') '
                    + 'does not match batch type '
                    + 'in STGBATCH record '
                    + '(' + %trim(sbtype) + ')';
           leavesr;
         endif;

         // Status must be 'R' to process batch.

         select;

           when sbstatus = 'R';

770aA      when sbstatus = '9';    // only sent by certain po imports

           when sbstatus = 'S';
             error = *on;
             pReturn  = '*INVLDSTAT';
             pMessage = 'Batch already processed. '
                      + 'Status code (' + sbstatus + ') '
                      + 'indicates it was successfully '
                      + 'processed on ' + %char(sbststs);
             leavesr;

           when sbstatus = 'J';
             error = *on;
             pReturn  = '*INVLDSTAT';
             pMessage = 'Batch already processed. '
                      + 'Status code (' + sbstatus + ') '
                      + 'indicates it was sent to the '
                      + 'jobq on ' + %char(sbststs);
             leavesr;

           when sbstatus = 'E';
             error = *on;
             pReturn  = '*INVLDSTAT';
             pMessage = 'Batch already processed. '
                      + 'Status code (' + sbstatus + ') '
                      + 'indicates it had an error on '
                      + %char(sbststs);
             leavesr;

           when sbstatus = 'W';
             error = *on;
             pReturn  = '*INVLDSTAT';
             pMessage = 'Batch not ready for processing. '
                      + 'Status code (' + sbstatus + ') '
                      + 'indicates records are being written '
                      + 'to the appropriate staging file(s). '
                      + 'Status was set at '
                      + %char(sbststs);
             leavesr;

           other;
             error = *on;
             pReturn  = '*INVLDSTAT';
             pMessage = 'Batch already processed. '
                      + 'Status code (' + sbstatus + ') '
                      + 'was set on '
                      + %char(sbststs);
             leavesr;

         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChkFile  Check for records in import file
     *----------------------------------------------------------------

      /free
       begsr ChkFile;

         error = *off;

         select;

           when uType = 'IMPITEM';
             exsr ChkFileIMPSITMN;

640eM      when uType = 'IMPQTYORD';
             exsr ChkFileIMPSITMO;

640aA      when uType = 'IMPPO';
640aA        exsr ChkFileIMPSPOH;

           when uType = 'IMPROUTE';
             exsr ChkFileIMPSORDH;

710aA      when uType = 'IMPROUTENS';
710aA        exsr ChkFileIMPSORDHNS;

           when uType = 'IMPWILCAL';
             exsr ChkFileIMPSORDH;

           when uType = 'IMPHSTQTY';
             exsr ChkFileIMPSPQTY;

750 A      when uType = 'IMPCOMPQTY';
750 A      //exsr ChkFileIMPSCQTY;

780aA      when uType = 'IMPCOMPQT3';
780aA        exsr ChkFileIMPSCQTY3;

650bA      when uType = 'IMPCUSTRTN';
650bA        exsr ChkFileIMPSRTN;

           when uType = 'IMPRCVPLT';
             exsr ChkFileIMPSRCVP;

           when uType = 'IMPRTNPLT';
             exsr ChkFileIMPSRTNP;

           when uType = 'IMPSTUFIT';
             exsr ChkFileIMPSSTUF;

CBIaA      when uType = 'IMPSMHITEM';
CBIaA        exsr ChkFileIMPSMHITEM;

730aA      when uType = 'IMPUCIPRD ';
730aA        exsr ChkFileIMPSUPRD;

740 A      when uType = 'IMPINVCE';
740 A        exsr ChkFileIMPSIVCH;

         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChkFileIMPSITMN  Check for records in the IMPSITMN file
     *----------------------------------------------------------------

      /free
       begsr ChkFileIMPSITMN;

         exec sql select iuwhse into :temp3n
                  from impsitmn
                  where iuwhse = :pwhse
                    and iubatid = :pbatid
                  fetch first 1 rows only;

         if sqlstt <> sqlSuccess;
           error = *on;
           pReturn  = '*NORECORDS';
           pMessage = 'No records found in file IMPSITMN '
                    + 'for warehouse ' + %char(pwhse) + ', '
                    + 'batch id ' + pBatId + ' - '
                    + 'SQLSTT ' + sqlstt;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChkFileIMPSITMO  Check for records in the IMPSITMO file
     *----------------------------------------------------------------

      /free
       begsr ChkFileIMPSITMO;

         exec sql select ijwhse into :temp3n
                  from impsitmo
                  where ijwhse = :pwhse
                    and ijbatid = :pbatid
                  fetch first 1 rows only;

         if sqlstt <> sqlSuccess;
           error = *on;
           pReturn  = '*NORECORDS';
           pMessage = 'No records found in file IMPSITMO '
                    + 'for warehouse ' + %char(pwhse) + ', '
                    + 'batch id ' + pBatId + ' - '
                    + 'SQLSTT ' + sqlstt;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChkFileIMPSORDH  Check for records in the IMPSORDH/D files
     *----------------------------------------------------------------

      /free
       begsr ChkFileIMPSORDH;

         exec sql select oihwhs into :temp3n
                  from impsordh
                  where oihwhs = :pwhse
                    and oihbatid = :pbatid
                  fetch first 1 rows only;

         if sqlstt <> sqlSuccess;
           error = *on;
           pReturn  = '*NORECORDS';
           pMessage = 'No records found in file IMPSORDH '
                    + 'for warehouse ' + %char(pwhse) + ', '
                    + 'batch id ' + pBatId + ' - '
                    + 'SQLSTT ' + sqlstt;
           leavesr;
         endif;

         exec sql select oidwhs into :temp3n
                  from impsordd
                  where oidwhs = :pwhse
                    and oidbatid = :pbatid
                  fetch first 1 rows only;

         if sqlstt <> sqlSuccess;
           error = *on;
           pReturn  = '*NORECORDS';
           pMessage = 'No records found in file IMPSORDD '
                    + 'for warehouse ' + %char(pwhse) + ', '
                    + 'batch id ' + pBatId + ' - '
                    + 'SQLSTT ' + sqlstt;
           leavesr;
         endif;

       endsr;
      /end-free

710aA*----------------------------------------------------------------
710aA*  ChkFileIMPSORDHNS  Check for records in the IMPSORDH/D files
710aA*----------------------------------------------------------------
710aA
710aA /free
710aA  begsr ChkFileIMPSORDHNS;
710aA
710aA    exec sql select nihwhs into :temp3n
710aA             from impsordhns
710aA             where nihwhs = :pwhse
710aA               and nihbatid = :pbatid
710aA             fetch first 1 rows only;
710aA
710aA    if sqlstt <> sqlSuccess;
710aA      error = *on;
710aA      pReturn  = '*NORECORDS';
710aA      pMessage = 'No records found in file IMPSORDHNS '
710aA               + 'for warehouse ' + %char(pwhse) + ', '
710aA               + 'batch id ' + pBatId + ' - '
710aA               + 'SQLSTT ' + sqlstt;
710aA      leavesr;
710aA    endif;
710aA
710aA  endsr; // ChkFileIMPSORDHNS
710aA /end-free

640aA*----------------------------------------------------------------
640aA*  ChkFileIMPSPOH   Check for records in the IMPSPOH/D files
640aA*----------------------------------------------------------------
640aA
640aA /free
640aA  begsr ChkFileIMPSPOH;

         exec sql select pihwhs into :temp3n
                  from impspoh
                  where pihwhs = :pwhse
                    and pihbatid = :pbatid
                  fetch first 1 rows only;

         if sqlstt <> sqlSuccess;
           error = *on;
           pReturn  = '*NORECORDS';
           pMessage = 'No records found in file IMPSPOH '
                    + 'for warehouse ' + %char(pwhse) + ', '
                    + 'batch id ' + pBatId + ' - '
                    + 'SQLSTT ' + sqlstt;
           leavesr;
         endif;

         // Note, we do not check for detail records like we
         // do for routes because there are times when it is
         // acceptable to have no detail records.

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChkFileIMPSPQTY  Check for records in the IMPSPQTY file
     *----------------------------------------------------------------

      /free
       begsr ChkFileIMPSPQTY;

         exec sql select ijwhse into :temp3n
                  from impspqty
                  where ijwhse = :pwhse
                    and ijbatid = :pbatid
                  fetch first 1 rows only;

         if sqlstt <> sqlSuccess;
           error = *on;
           pReturn  = '*NORECORDS';
           pMessage = 'No records found in file IMPSPQTY '
                    + 'for warehouse ' + %char(pwhse) + ', '
                    + 'batch id ' + pBatId + ' - '
                    + 'SQLSTT ' + sqlstt;
         endif;

       endsr;
      /end-free
750 A
750 A*----------------------------------------------------------------
750 A*  ChkFileIMPSCQTY  Check for records in the IMPSCQTY file
750 A*----------------------------------------------------------------
750 A
750 A /free
750 A  begsr ChkFileIMPSCQTY;
750 A
750 A    exec sql select count(*) into :reccnt
750 A             from impscqty
750 A             where icwhse = :pwhse
750 A               and icbatid = :pbatid;
750 A
750 A    if sqlstt <> sqlSuccess
750 A     or reccnt <= 0;
750 A      error = *on;
750 A      pReturn  = '*NORECORDS';
750 A      pMessage = 'No records found in file IMPSCQTY '
750 A               + 'for warehouse ' + %char(pwhse) + ', '
750 A               + 'batch id ' + pBatId + ' - '
750 A               + 'SQLSTT ' + sqlstt;
750 A    endif;
750 A
750 A  endsr;
750 A /end-free

780aA
780aA*----------------------------------------------------------------
780aA*  ChkFileIMPSCQTY3 Check for records in the IMPSCQTY3 file
780aA*----------------------------------------------------------------
780aA
780aA /free
780aA  begsr ChkFileIMPSCQTY3;
780aA
780aA    exec sql select count(*) into :reccnt
780aA             from impscqty3
780aA             where ic3whse = :pwhse
780aA               and ic3batid = :pbatid;
780aA
780aA    if sqlstt <> sqlSuccess
780aA     or reccnt <= 0;
780aA      error = *on;
780aA      pReturn  = '*NORECORDS';
780aA      pMessage = 'No records found in file IMPSCQTY3 '
780aA               + 'for warehouse ' + %char(pwhse) + ', '
780aA               + 'batch id ' + pBatId + ' - '
780aA               + 'SQLSTT ' + sqlstt;
780aA    endif;
780aA
780aA  endsr;
780aA /end-free

     *----------------------------------------------------------------
     *  ChkFileIMPSrtn   Check for records in the IMPSRTN file
     *----------------------------------------------------------------

650bA /free
       begsr ChkFileIMPSRTN;

         exec sql select count(*) into :reccnt
                  from impsrtn
                  where oirwhs = :pwhse
                    and oirbatid = :pbatid;

         if sqlstt <> sqlSuccess
          or reccnt <= 0;
           error = *on;
           pReturn  = '*NORECORDS';
           pMessage = 'No records found in file IMPSRTN '
                    + 'for warehouse ' + %char(pwhse) + ', '
                    + 'batch id ' + pBatId + ' - '
                    + 'SQLSTT ' + sqlstt;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChkFileIMPSRCVP  Check for records in the IMPSRCVP file
     *----------------------------------------------------------------

      /free
       begsr ChkFileIMPSRCVP;

         exec sql select rcpwhse into :temp3n
                  from impsrcvp
                  where rcpwhse = :pwhse
                    and rcpbatid = :pbatid
                  fetch first 1 rows only;

         if sqlstt <> sqlSuccess;
           error = *on;
           pReturn  = '*NORECORDS';
           pMessage = 'No records found in file IMPSRCVP '
                    + 'for warehouse ' + %char(pwhse) + ', '
                    + 'batch id ' + pBatId + ' - '
                    + 'SQLSTT ' + sqlstt;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChkFileIMPSRTNP  Check for records in the IMPSRTNP file
     *----------------------------------------------------------------

      /free
       begsr ChkFileIMPSRTNP;

         exec sql select rtpwhse into :temp3n
                  from impsrtnp
                  where rtpwhse = :pwhse
                    and rtpbatid = :pbatid
                  fetch first 1 rows only;

         if sqlstt <> sqlSuccess;
           error = *on;
           pReturn  = '*NORECORDS';
           pMessage = 'No records found in file IMPSRTNP '
                    + 'for warehouse ' + %char(pwhse) + ', '
                    + 'batch id ' + pBatId + ' - '
                    + 'SQLSTT ' + sqlstt;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChkFileIMPSSTUF  Check for records in the IMPSSTUF file
     *----------------------------------------------------------------

      /free
       begsr ChkFileIMPSSTUF;

         exec sql select siwhse into :temp3n
                  from impsstuf
                  where siwhse = :pwhse
                    and sibatid = :pbatid
                  fetch first 1 rows only;

         if sqlstt <> sqlSuccess;
           error = *on;
           pReturn  = '*NORECORDS';
           pMessage = 'No records found in file IMPSSTUF '
                    + 'for warehouse ' + %char(pwhse) + ', '
                    + 'batch id ' + pBatId + ' - '
                    + 'SQLSTT ' + sqlstt;
         endif;

       endsr;
      /end-free

CBIaA*----------------------------------------------------------------
CBIaA*  ChkFileIMPSMHITEM  Check for records in the IMPSMHITEM file
CBIaA*----------------------------------------------------------------
CBIaA
CBIaA /free
CBIaA  begsr ChkFileIMPSMHITEM;

         exec sql select miwhse into :temp3n
                  from impsmhitem
                  where miwhse = :pwhse
                    and mibatid = :pbatid
                  fetch first 1 rows only;

         if sqlstt <> sqlSuccess;
           error = *on;
           pReturn  = '*NORECORDS';
           pMessage = 'No records found in file IMPSMHITEM '
                    + 'for warehouse ' + %char(pwhse) + ', '
                    + 'batch id ' + pBatId + ' - '
                    + 'SQLSTT ' + sqlstt;
         endif;

       endsr;
      /end-free

730aA*----------------------------------------------------------------
730aA*  ChkFileIMPSUPRD    Check for records in the IMPSUPRD file
730aA*----------------------------------------------------------------
730aA
730aA /free
730aA  begsr ChkFileIMPSUPRD;
730aA
730aA    exec sql select ipuwhs into :temp3n
730aA             from impsuprd
730aA             where ipuwhs = :pwhse
730aA               and ipubatid = :pbatid
730aA             fetch first 1 rows only;
730aA
730aA    if sqlstt <> sqlSuccess;
730aA      error = *on;
730aA      pReturn  = '*NORECORDS';
730aA      pMessage = 'No records found in file IMPSUPRD '
730aA               + 'for warehouse ' + %char(pwhse) + ', '
730aA               + 'batch id ' + pBatId + ' - '
730aA               + 'SQLSTT ' + sqlstt;
730aA    endif;
730aA
730aA  endsr;
730aA /end-free

740 A*----------------------------------------------------------------
740 A*  ChkFileIMPSIVCH  Check for records in the IMPSIVCH/D files
740 A*----------------------------------------------------------------
740 A
740 A /free
740 A  begsr ChkFileIMPSIVCH;
740 A
740 A    exec sql select ivhwhs into :temp3n
740 A             from impsivch
740 A             where ivhwhs = :pwhse
740 A               and ivhbatid = :pbatid
740 A             fetch first 1 rows only;
740 A
740 A    if sqlstt <> sqlSuccess;
740 A      error = *on;
740 A      pReturn  = '*NORECORDS';
740 A      pMessage = 'No records found in file IMPSIVCH '
740 A               + 'for warehouse ' + %char(pwhse) + ', '
740 A               + 'batch id ' + pBatId + ' - '
740 A               + 'SQLSTT ' + sqlstt;
740 A      leavesr;
740 A    endif;
740 A
740 A    exec sql select ivdwhs into :temp3n
740 A             from impsivcd
740 A             where ivdwhs = :pwhse
740 A               and ivdbatid = :pbatid
740 A             fetch first 1 rows only;
740 A
740 A    if sqlstt <> sqlSuccess;
740 A      error = *on;
740 A      pReturn  = '*NORECORDS';
740 A      pMessage = 'No records found in file IMPSIVCD '
740 A               + 'for warehouse ' + %char(pwhse) + ', '
740 A               + 'batch id ' + pBatId + ' - '
740 A               + 'SQLSTT ' + sqlstt;
740 A      leavesr;
740 A    endif;
740 A
740 A  endsr;
740 A /end-free

     *----------------------------------------------------------------
     *  runInteractive  Run program interactively
     *----------------------------------------------------------------

      /free
       begsr runInteractive;

         select;

           when uType = 'IMPHSTQTY';
640cA        monitor;
640cA          hq121s(alphaWhse: pBatId: pReturn: pMessage);
640cA        on-error;
640cA          pReturn  = '*ERRHQ121S';
640cA          pMessage = 'Error calling HQ121S';
640cA          leavesr;
640cA        endmon;

750 A      when uType = 'IMPCOMPQTY';
750 A        monitor;
750 A          it971s(alphaWhse: pBatId: pReturn: pMessage);
750 A        on-error;
750 A          pReturn  = '*ERRIT971S';
750 A          pMessage = 'Error calling IT971S';
750 A          leavesr;
750 A        endmon;

650bA      when uType = 'IMPCUSTRTN';
650bA        monitor;
650bA          rn235s(alphaWhse: pBatId: pReturn: pMessage);
650bA        on-error;
650bA          pReturn  = '*ERRRN235S';
650bA          pMessage = 'Error calling RN235S';
650bA          leavesr;
650bA        endmon;

           when uType = 'IMPITEM';
             monitor;
               if client = cheney;
                 ii265s(alphaWhse: pBatId: pReturn: pMessage);
               else;
                 ii295s(alphaWhse: pBatId: pReturn: pMessage);
               endif;
             on-error;
               if client = cheney;
                 pReturn  = '*ERRII265S';
                 pMessage = 'Error calling II265S';
               else;
                 pReturn  = '*ERRII295S';
                 pMessage = 'Error calling II295S';
               endif;
               leavesr;
             endmon;

780aA      when uType = 'IMPCOMPQT3';
780aA        monitor;
780aA          it961s(alphaWhse: pBatId: pReturn: pMessage);
780aA        on-error;
780aA          pReturn  = '*ERRIT961S';
780aA          pMessage = 'Error calling IT961S';
780aA          leavesr;
780aA        endmon;

640eM      when uType = 'IMPQTYORD';
640cA        monitor;
640cA          ii255s(alphaWhse: pBatId: pReturn: pMessage);
640cA        on-error;
640cA          pReturn  = '*ERRII255S';
640cA          pMessage = 'Error calling II255S';
640cA          leavesr;
640cA        endmon;

640cA      when uType = 'IMPPICKED'
640cA           or uType = 'IMPDEMAND'
640cA           or uType = 'IMPPCKDEM';
640cA             monitor;
640cA               hq245s(alphaWhse: pBatId: uType:
640cA                      pReturn: pMessage);
640cA             on-error;
640cA               pReturn  = '*ERRHQ245S';
640cA               pMessage = 'Error calling HQ245S';
640cA               leavesr;
640cA             endmon;

720aA      when uType = 'IMPPCKDEM2';
720aA             monitor;
720aA               hq247s(alphaWhse: pBatId: uType:
720aA                      pReturn: pMessage);
720aA             on-error;
720aA               pReturn  = '*ERRHQ247S';
720aA               pMessage = 'Error calling HQ247S';
720aA               leavesr;
720aA             endmon;

640aA      when uType = 'IMPPO';
             monitor;
               pi265s(alphaWhse: pBatId: pReturn: pMessage);
             on-error;
               pReturn  = '*ERRPI265S';
               pMessage = 'Error calling PI265S';
               leavesr;
             endmon;

           when uType = 'IMPRCVPLT';
640cA        monitor;
640cA          po236s(alphaWhse: pBatId: pReturn: pMessage);
640cA        on-error;
640cA          pReturn  = '*ERRPO236S';
640cA          pMessage = 'Error calling PO236S';
640cA          leavesr;
640cA        endmon;

           when uType = 'IMPROUTE';
640cA        monitor;
EFCaD        //if client = cheney;
EFCaA          select;
EFCaA          when client = cheney;
640dM            oi255s(alphaWhse: pBatId: pReturn: pMessage);
EFCaA          when client = eastland;
EFCaA            oi286s(alphaWhse: pBatId: pReturn: pMessage);
EFCaD        //else;
EFCaA          other;
640dM            oi285s(alphaWhse: pBatId: pReturn: pMessage);
EFCaA          endsl;
EFCaD        //endif;
640cA        on-error;
EFCaD        //if client = cheney;
EFCaA          select;
EFCaA          when client = cheney;
640cA            pReturn  = '*ERROI255S';
640cA            pMessage = 'Error calling OI255S';
EFCaA          when client = eastland;
EFCaA            pReturn  = '*ERROI286S';
EFCaA            pMessage = 'Error calling OI286S';
EFCaD        //else;
EFCaA          other;
640cA            pReturn  = '*ERROI285S';
640cA            pMessage = 'Error calling OI285S';
EFCaA          endsl;
EFCaD        //endif;
640cA          leavesr;
640cA        endmon;

710aA      when uType = 'IMPROUTENS';
710aA        monitor;
710aA          oi405s(alphaWhse: pBatId: pReturn: pMessage);
710aA        on-error;
710aA          pReturn  = '*ERROI405S';
710aA          pMessage = 'Error calling OI405S';
710aA          leavesr;
710aA        endmon;

           when uType = 'IMPRTNPLT';
640cA        monitor;
640cA          po236s(alphaWhse: pBatId: pReturn: pMessage);
640cA        on-error;
640cA          pReturn  = '*ERRPO236S';
640cA          pMessage = 'Error calling PO236S';
640cA          leavesr;
640cA        endmon;

CBIaA      when uType = 'IMPSMHITEM';
             monitor;
               manhatns(alphaWhse: pBatId: pReturn: pMessage);
             on-error;
               pReturn  = '*ERRMANHAT';
               pMessage = 'Error calling MANHATNS';
               leavesr;
             endmon;

           when uType = 'IMPSTUFIT';
640cA        monitor;
640cA          si255s(alphaWhse: pBatId: pReturn: pMessage);
640cA        on-error;
640cA          pReturn  = '*ERRSI255S';
640cA          pMessage = 'Error calling SI255S';
640cA          leavesr;
640cA        endmon;

           when uType = 'IMPWILCAL';
640cA        monitor;
640cA          if client = cheney;
640dM            oi255s(alphaWhse: pBatId: pReturn: pMessage);
640cA          else;
640dM            oi285s(alphaWhse: pBatId: pReturn: pMessage);
640cA          endif;
640cA        on-error;
640cA          if client = cheney;
640cA            pReturn  = '*ERROI255S';
640cA            pMessage = 'Error calling OI255S';
640cA          else;
640cA            pReturn  = '*ERROI285S';
640cA            pMessage = 'Error calling OI285S';
640cA          endif;
640cA          leavesr;
640cA        endmon;

730aA      when uType = 'IMPUCIPRD';
730aA        monitor;
730aA          ui250s(alphaWhse: pBatId: pReturn: pMessage);
730aA        on-error;
730aA            pReturn  = '*ERRui250S';
730aA            pMessage = 'Error calling UI250S';
730aA          leavesr;
730aA        endmon;

740 A      when uType = 'IMPINVCE';
740 A        monitor;
740 A          select;
740 A          other;
740 A            vc255s(alphaWhse: pBatId: pReturn: pMessage);
740 A          endsl;
740 A        on-error;
740 A          select;
740 A          other;
740 A            pReturn  = '*ERRVC255S';
740 A            pMessage = 'Error calling VC255S';
740 A          endsl;
740 A          leavesr;
740 A        endmon;

           other;
             pReturn  = '*NOPROGRAM';
             pMessage = 'No processing program has been '
                      + 'defined for type ' + uType;
             leavesr;

         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  runJobq  Submit program to jobq
     *----------------------------------------------------------------

      /free
       begsr runJobq;

         // Create command to submit

         select;

           when uType = 'IMPHSTQTY';
640cA        cmd = 'call hq151s ('
640cA            +   sq + alphaWhse + sq + ' '
640cA            +   sq + %trim(pBatId) + sq + ' '
640cA            +   sq + sq + ' '
640cA            +   sq + sq + ' '
640cA            + ')';

750 A      when uType = 'IMPCOMPQTY';
750 A        cmd = 'call it971s ('
750 A            +   sq + alphaWhse + sq + ' '
750 A            +   sq + %trim(pBatId) + sq + ' '
750 A            +   sq + sq + ' '
750 A            +   sq + sq + ' '
750 A            + ')';

           when uType = 'IMPITEM';
             if client = cheney;
               cmd = 'call ii265s (';
             else;
               cmd = 'call ii295s (';
             endif;
             cmd = %trimr(cmd)
                 +   sq + alphaWhse + sq + ' '
                 +   sq + %trim(pBatId) + sq + ' '
                 +   sq + sq + ' '
                 +   sq + sq + ' '
                 + ')';

780aA      when uType = 'IMPCOMPQT3';
780aA        cmd = 'call it961s ('
780aA            +   sq + alphaWhse + sq + ' '
780aA            +   sq + %trim(pBatId) + sq + ' '
780aA            +   sq + sq + ' '
780aA            +   sq + sq + ' '
780aA            + ')';

640eM      when uType = 'IMPQTYORD';
640cA        cmd = 'call ii255s ('
640cA            +   sq + alphaWhse + sq + ' '
640cA            +   sq + %trim(pBatId) + sq + ' '
640cA            +   sq + sq + ' '
640cA            +   sq + sq + ' '
640cA            + ')';

640cA      when uType = 'IMPPICKED'
640cA           or uType = 'IMPDEMAND'
640cA           or uType = 'IMPPCKDEM';
640cA             cmd = 'call hq245s ('
640cA                 +   sq + alphaWhse + sq + ' '
640cA                 +   sq + %trim(pBatId) + sq + ' '
640cA                 +   sq + %trim(uType) + sq + ' '
640cA                 +   sq + sq + ' '
640cA                 +   sq + sq + ' '
640cA                 + ')';

720aA      when uType = 'IMPPCKDEM2';
720aA             cmd = 'call hq247s ('
720aA                 +   sq + alphaWhse + sq + ' '
720aA                 +   sq + %trim(pBatId) + sq + ' '
720aA                 +   sq + %trim(uType) + sq + ' '
720aA                 +   sq + sq + ' '
720aA                 +   sq + sq + ' '
720aA                 + ')';

640aA      when uType = 'IMPPO';
             cmd = 'call pi265s ('
                 +   sq + alphaWhse + sq + ' '
                 +   sq + %trim(pBatId) + sq + ' '
                 +   sq + sq + ' '
                 +   sq + sq + ' '
                 + ')';

           when uType = 'IMPRCVPLT';
640cA        cmd = 'call PO236s ('
640cA            +   sq + alphaWhse + sq + ' '
640cA            +   sq + %trim(pBatId) + sq + ' '
640cA            +   sq + sq + ' '
640cA            +   sq + sq + ' '
640cA            + ')';

           when uType = 'IMPROUTE';
640cA        if client = cheney;
640cA          cmd = 'call oi255s (';
640cA        else;
640cA          cmd = 'call oi285s (';
640cA        endif;
640cA        cmd = %trimr(cmd)
640cA            +   sq + alphaWhse + sq + ' '
640cA            +   sq + %trim(pBatId) + sq + ' '
640cA            +   sq + sq + ' '
640cA            +   sq + sq + ' '
640cA            + ')';

710aA      when uType = 'IMPROUTENS';
710aA        cmd = 'call oi405s (';
710aA        cmd = %trimr(cmd)
710aA            +   sq + alphaWhse + sq + ' '
710aA            +   sq + %trim(pBatId) + sq + ' '
710aA            +   sq + sq + ' '
710aA            +   sq + sq + ' '
710aA            + ')';

           when uType = 'IMPRTNPLT';
640cA        cmd = 'call PO236s ('
640cA            +   sq + alphaWhse + sq + ' '
640cA            +   sq + %trim(pBatId) + sq + ' '
640cA            +   sq + sq + ' '
640cA            +   sq + sq + ' '
640cA            + ')';

CBIaA      when uType = 'IMPSMHITEM';
             cmd = 'call manhatns ('
                 +   sq + alphaWhse + sq + ' '
                 +   sq + %trim(pBatId) + sq + ' '
                 +   sq + sq + ' '
                 +   sq + sq + ' '
                 + ')';

           when uType = 'IMPSTUFIT';
640cA        cmd = 'call si255s ('
640cA            +   sq + alphaWhse + sq + ' '
640cA            +   sq + %trim(pBatId) + sq + ' '
640cA            +   sq + sq + ' '
640cA            +   sq + sq + ' '
640cA            + ')';

           when uType = 'IMPWILCAL';
640cA        if client = cheney;
640cA          cmd = 'call oi255s (';
640cA        else;
640cA          cmd = 'call oi285s (';
640cA        endif;
640cA        cmd = %trimr(cmd)
640cA            +   sq + alphaWhse + sq + ' '
640cA            +   sq + %trim(pBatId) + sq + ' '
640cA            +   sq + sq + ' '
640cA            +   sq + sq + ' '
640cA            + ')';

730aA      when uType = 'IMPUCIPRD';
730aA        cmd = 'call ui250s ('
730aA            +   sq + alphaWhse + sq + ' '
730aA            +   sq + %trim(pBatId) + sq + ' '
730aA            +   sq + sq + ' '
730aA            +   sq + sq + ' '
730aA            + ')';

           other;
             pReturn  = '*NOPROGRAM';
             pMessage = 'No processing program has been '
                      + 'defined for type ' + uType;
             leavesr;

         endsl;

         cmd = 'sbmjob cmd(' + %trimr(cmd) + ') '
             + 'jobq(QSYSNOMAX) '
             + 'job(' + %trimr(uType) + ')';

         // Submit command

         monitor;
           qcmdexc(%trim(cmd): %len(%trim(cmd)));
         on-error;
           pReturn  = '*JOBQERR';
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

         // Updtate STGBATCH record

         exec sql
           update stgbatch
           set sbstatus = 'J',
               sbtext   = :pMessage,
               sbststs  = current_timestamp,
               sbstsuc  = current_timestamp - current_timezone
           where sbwhse = :pWhse
             and sbbatid = :pBatId;

         if sqlstt <> sqlSuccess;
         endif;

       endsr;
      /end-free

640bA*----------------------------------------------------------------
640bA*  SendSets   Send back result sets
640bA*----------------------------------------------------------------
640bA
640bA /free
640bA  begsr SendSet;

         if pProgram <> 'PDKTIMPRS';
           leavesr;
         endif;

         sReturn = pReturn;
         sMessage = pMessage;

         exec sql
           set result sets with return to client
               array :pgmStatus for 1 rows;

       endsr;
      /end-free
