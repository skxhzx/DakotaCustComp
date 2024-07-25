417cA /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
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
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pType       Batch type
     *      pBatId      Batch id
     *      pLiblJobd   Job description for library list
     *                  *CURRENT  - Use current library list
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
     D   pLiblJobd                   10    const
     D   pRunType                     1    const
      * Output
     D   pReturn                     10
     D   pMessage                   200

     D dktimport       pi
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pBatId                      11    const
     D   pLiblJobd                   10    const
     D   pRunType                     1    const
      * Output
     D   pReturn                     10
     D   pMessage                   200

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D sirec         E ds                  extname(stgimport) inz(*EXTDFT)

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

     D cmd             s           3000    varying
     D temp3n          s              3p 0
     D alphaWhse       s              3
     D wwMsgKey        s              4A

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

     D GetRecId        pr                  extpgm('GETRECID')
     D  pWhse                         3s 0 const
     D  pFile                        10    const
     D  pRecId                       11p 0

     D ii265s          pr                  extpgm('II265S')
     D  pWhse                         3  0 const
     D  pBatid                       11    const
     D  pReturn                      10
     D  pMessage                    200

      /free

         *inlr = *on;

         pReturn = '*OK';
         pMessage = ' ';

         // Verify run type

         if pRunType <> 'I' and pRunType <> 'J';
           pReturn  = '*INVLDRTYP';
           pMessage = 'Invalid run type sent (' + pRunType + '). '
                    + 'Valid types are I=Interactive and J=Jobq. ';
           return;
         endif;

         // Batch id must exist in STGIMPORT file

         exsr ChkStgImport;
         if error;
           return;
         endif;

         // Check for records in import file

         exsr ChkFile;
         if error;
           return;
         endif;

         // Check for records in import file

         if pRunType = 'I';
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
     *  ChkStgImport  Check for stgimport record
     *----------------------------------------------------------------

      /free
       begsr ChkStgImport;

         error = *off;

         // Get stgimport record for batch id.

         exec sql select sitype, sistatus, siststs
                    into :sitype, :sistatus, :siststs
                  from stgimport
                  where siwhse = :pwhse
                    and sibatid = :pbatid
                  fetch first 1 rows only;

         if sqlstt <> sqlSuccess;
           error = *on;
           pReturn  = '*NOTFOUND';
           pMessage = 'Batch id ' + %trim(pBatId) + ' '
                    + 'not found in file STGIMPORT - '
                    + 'SQLSTT ' + sqlstt;
           leavesr;
         endif;

         // Batch type must match type sent in.

         if sitype <> pType;
           error = *on;
           pReturn  = '*WRONGTYPE';
           pMessage = 'Import type sent (' + %trim(pType) + ') '
                    + 'does not match batch type '
                    + 'in STGIMPORT record '
                    + '(' + %trim(sitype) + ')';
           leavesr;
         endif;

         // Status must be 'I' to process batch.

         select;

           when sistatus = 'I';

           when sistatus = 'S';
             error = *on;
             pReturn  = '*INVLDSTAT';
             pMessage = 'Batch already processed. '
                      + 'Status code (' + sistatus + ') '
                      + 'indicates it was successfully '
                      + 'processed on ' + %char(siststs);
             leavesr;

           when sistatus = 'J';
             error = *on;
             pReturn  = '*INVLDSTAT';
             pMessage = 'Batch already processed. '
                      + 'Status code (' + sistatus + ') '
                      + 'indicates it was sent to the '
                      + 'jobq on ' + %char(siststs);
             leavesr;

           when sistatus = 'E';
             error = *on;
             pReturn  = '*INVLDSTAT';
             pMessage = 'Batch already processed. '
                      + 'Status code (' + sistatus + ') '
                      + 'indicates it had an error on '
                      + %char(siststs);
             leavesr;

           when sistatus = 'W';
             error = *on;
             pReturn  = '*INVLDSTAT';
             pMessage = 'Batch not ready for processing. '
                      + 'Status code (' + sistatus + ') '
                      + 'indicates records are being written '
                      + 'to the appropriate staging file(s). '
                      + 'Status was set at '
                      + %char(siststs);
             leavesr;

           other;
             error = *on;
             pReturn  = '*INVLDSTAT';
             pMessage = 'Batch already processed. '
                      + 'Status code (' + sistatus + ') '
                      + 'was set on '
                      + %char(siststs);
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

           when sitype = 'IMPITEM';
             exsr ChkFileIMPSITMN;

           when sitype = 'IMPORDQTY';
             exsr ChkFileIMPSITMO;

           when sitype = 'IMPROUTE';
             exsr ChkFileIMPSORDH;

           when sitype = 'IMPWILCAL';
             exsr ChkFileIMPSORDH;

           when sitype = 'IMPHSTQTY';
             exsr ChkFileIMPSPQTY;

           when sitype = 'IMPRCVPLT';
             exsr ChkFileIMPSRCVP;

           when sitype = 'IMPRTNPLT';
             exsr ChkFileIMPSRTNP;

           when sitype = 'IMPSTUFIT';
             exsr ChkFileIMPSSTUF;

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
                    + 'for batch id ' + pBatId + ' - '
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

         exec sql select rtnwhse into :temp3n
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

     *----------------------------------------------------------------
     *  runInteractive  Run program interactively
     *----------------------------------------------------------------

      /free
       begsr runInteractive;

         select;

           when sitype = 'IMPITEM';
             monitor;
               ii265s(pWhse: pBatId: pReturn: pMessage);
             on-error;
               pReturn  = '*ERRII265S';
               pMessage = 'Error calling II265S';
               leavesr;
             endmon;

           when sitype = 'IMPORDQTY';

           when sitype = 'IMPROUTE';

           when sitype = 'IMPWILCAL';

           when sitype = 'IMPHSTQTY';

           when sitype = 'IMPRCVPLT';

           when sitype = 'IMPRTNPLT';

           when sitype = 'IMPSTUFIT';

           other;
             pReturn  = '*NOPROGRAM';
             pMessage = 'No processing program has been '
                      + 'defined for type ' + sitype;
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

           when sitype = 'IMPITEM';
             cmd = 'call ii265s ('
                 +   sq + %char(pWhse) + sq + ' '
                 +   sq + %trim(pBatId) + sq + ' '
                 +   sq + sq + ' '
                 +   sq + sq + ' '
                 + ')';

           when sitype = 'IMPORDQTY';

           when sitype = 'IMPROUTE';

           when sitype = 'IMPWILCAL';

           when sitype = 'IMPHSTQTY';

           when sitype = 'IMPRCVPLT';

           when sitype = 'IMPRTNPLT';

           when sitype = 'IMPSTUFIT';

           other;
             pReturn  = '*NOPROGRAM';
             pMessage = 'No processing program has been '
                      + 'defined for type ' + sitype;
             leavesr;

         endsl;

         cmd = 'sbmjob cmd(' + %trimr(cmd) + ') '
             + 'jobq(QSYSNOMAX) '
             + 'job(' + %trimr(pType) + ')';

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

         // Updtate STGIMPORT record

         exec sql
           update stgimport
           set sistatus = 'J',
               sitext   = :pMessage,
               siststs  = current_timestamp,
               sistsuc  = current_timestamp - current_timezone
           where siwhse = :pWhse
             and sibatid = :pBatId;

         if sqlstt <> sqlSuccess;
         endif;

       endsr;
      /end-free
