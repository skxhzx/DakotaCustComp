417cA /copy *libl/qcopysrc,hspecs
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
     *  Revisions:
     *
640 A*    01/11/11  DAS  6.40
     *      - Created.
     *
640aA*    02/12/11  DAS  6.40a
     *      - Added PO Import.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Custom Revisions - Cheney Brothers
     *
CBIaA*    01/27/11  DAS  CBIa
     *      - Added type IMPSMHITEM.
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
      * Output
     D   pReturn                     10
     D   pMessage                   200

     D dktimport       pi
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pBatId                      11    const
     D   pRunType                     1    const
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
     D temp3n          s              3p 0
     D uRunType        s              1
     D uType           s             10
     D wwMsgKey        s              4A

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

640aAD pi265s          pr                  extpgm('PI265S')
640aAD  pWhse                         3    const
640aAD  pBatid                       11    const
640aAD  pReturn                      10
640aAD  pMessage                    200

CBIaAD xxxxxx          pr                  extpgm('XXXXXX')
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
           return;
         endif;

         // Batch id must exist in STGBATCH file

         exsr ChkStgBatch;
         if error;
           return;
         endif;

         // Check for records in import file

         exsr ChkFile;
         if error;
           return;
         endif;

         // Check for records in import file

         if uRunType = 'I';
           exsr runInteractive;
         else;
           exsr runJobq;
         endif;

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
           pMessage = 'Batch id ' + %trim(pBatId) + ' '
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

           when uType = 'IMPORDQTY';
             exsr ChkFileIMPSITMO;

640aA      when uType = 'IMPPO';
640aA        exsr ChkFileIMPSPOH;

           when uType = 'IMPROUTE';
             exsr ChkFileIMPSORDH;

           when uType = 'IMPWILCAL';
             exsr ChkFileIMPSORDH;

           when uType = 'IMPHSTQTY';
             exsr ChkFileIMPSPQTY;

           when uType = 'IMPRCVPLT';
             exsr ChkFileIMPSRCVP;

           when uType = 'IMPRTNPLT';
             exsr ChkFileIMPSRTNP;

           when uType = 'IMPSTUFIT';
             exsr ChkFileIMPSSTUF;

CBIaA      when uType = 'IMPSMHITEM';
CBIaA        exsr ChkFileIMPSMHITEM;

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
                    + 'for batch id ' + pBatId + ' - '
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
                    + 'for batch id ' + pBatId + ' - '
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
                    + 'for batch id ' + pBatId + ' - '
                    + 'SQLSTT ' + sqlstt;
           leavesr;
         endif;

       endsr;
      /end-free

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
                    + 'for batch id ' + pBatId + ' - '
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
                    + 'for batch id ' + pBatId + ' - '
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
                    + 'for batch id ' + pBatId + ' - '
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
                    + 'for batch id ' + pBatId + ' - '
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
                    + 'for batch id ' + pBatId + ' - '
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

         exec sql select mwhse into :temp3n
                  from impsmhitem
                  where mwhse = :pwhse
                    and mbatid = :pbatid
                  fetch first 1 rows only;

         if sqlstt <> sqlSuccess;
           error = *on;
           pReturn  = '*NORECORDS';
           pMessage = 'No records found in file IMPSMHITEM '
                    + 'for batch id ' + pBatId + ' - '
                    + 'SQLSTT ' + sqlstt;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  runInteractive  Run program interactively
     *----------------------------------------------------------------

      /free
       begsr runInteractive;

         select;

           when uType = 'IMPITEM';
             monitor;
               if client = 'CHENEY';
                 ii265s(alphaWhse: pBatId: pReturn: pMessage);
               else;
                 ii295s(alphaWhse: pBatId: pReturn: pMessage);
               endif;
             on-error;
               if client = 'CHENEY';
                 pReturn  = '*ERRII265S';
                 pMessage = 'Error calling II265S';
               else;
                 pReturn  = '*ERRII295S';
                 pMessage = 'Error calling II295S';
               endif;
               leavesr;
             endmon;

           when uType = 'IMPORDQTY';

640aA      when uType = 'IMPPO';
             monitor;
               pi265s(alphaWhse: pBatId: pReturn: pMessage);
             on-error;
               pReturn  = '*ERRPI265S';
               pMessage = 'Error calling PI265S';
               leavesr;
             endmon;

           when uType = 'IMPROUTE';

           when uType = 'IMPWILCAL';

           when uType = 'IMPHSTQTY';

           when uType = 'IMPRCVPLT';

           when uType = 'IMPRTNPLT';

           when uType = 'IMPSTUFIT';

CBIaA      when uType = 'IMPSMHITEM';
             monitor;
               xxxxxx(alphaWhse: pBatId: pReturn: pMessage);
             on-error;
               pReturn  = '*ERRxxxxxx';
               pMessage = 'Error calling xxxxxx';
               leavesr;
             endmon;

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

           when uType = 'IMPITEM';
             if client = 'CHENEY';
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

           when uType = 'IMPORDQTY';

640aA      when uType = 'IMPPO';
             cmd = 'call pi265s ('
                 +   sq + alphaWhse + sq + ' '
                 +   sq + %trim(pBatId) + sq + ' '
                 +   sq + sq + ' '
                 +   sq + sq + ' '
                 + ')';

           when uType = 'IMPROUTE';

           when uType = 'IMPWILCAL';

           when uType = 'IMPHSTQTY';

           when uType = 'IMPRCVPLT';

           when uType = 'IMPRTNPLT';

           when uType = 'IMPSTUFIT';

CBIaA      when uType = 'IMPSMHITEM';
             cmd = 'call xxxxxx ('
                 +   sq + alphaWhse + sq + ' '
                 +   sq + %trim(pBatId) + sq + ' '
                 +   sq + sq + ' '
                 +   sq + sq + ' '
                 + ')';

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
