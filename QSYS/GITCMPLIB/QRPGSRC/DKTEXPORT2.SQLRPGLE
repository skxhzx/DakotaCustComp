417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  DKTIMPORT   Dakota import
     *  21 January 2011
     *  Dave Sommerville
     *
     *  Revisions:
     *
640 A*    01/21/11  DAS  6.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pType       Batch type
     *                  *ALL - Only used for Result Sets
     *      pRunType    I = Interactive, J = Jobq, S = Result Sets
     *
     *    Returned Parameters
     *      pReturn     *OK
     *      pMessage    Error message
     *
     *----------------------------------------------------------------

     D dktexport       pr                  extpgm('DKTEXPORT')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pRunType                     1    const
      * Output
     D   pReturn                     10
     D   pMessage                   200

     D dktexport       pi
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pRunType                     1    const
      * Output
     D   pReturn                     10
     D   pMessage                   200

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

     D cmd             s           3000    varying
     D whse3s          s              3s 0
     D alphaWhse       s              3
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

     D GetRecId        pr                  extpgm('GETRECID')
     D  pWhse                         3s 0 const
     D  pFile                        10    const
     D  pRecId                       11p 0

     D it726s          pr                  extpgm('IT726S')
     D  pWhse                         3    const

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

         if uRunType <> 'I'
            and uRunType <> 'J'
            and uRunType <> 'S';
              pReturn  = '*INVLDRTYP';
              pMessage = 'Invalid run type sent (' + uRunType + '). '
                       + 'Valid types are I=Interactive, J=Jobq, '
                       + 'and S=Result Set. ';
              return;
         endif;

         // Run program

         select;
           when uRunType = 'I';
             exsr runInteractive;
           when uRunType = 'J';
             exsr runJobq;
           when uRunType = 'S';
             exsr runInteractiveSets;
         endsl;

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
     *  runInteractive  Run program interactively
     *----------------------------------------------------------------

      /free
       begsr runInteractive;

        found = *off;

        if uType = 'EXPADJUST' or uType = '*ALL';
          monitor;
            it726s(alphaWhse);
          on-error;
            pReturn  = '*ERRIT726S';
            pMessage = 'Error calling IT726S';
            leavesr;
          endmon;
          found = *on;
        endif;

        if uType = 'CBITIEHIGH' or uType = '*ALL';
          found = *on;
        endif;

        if uType = 'CBICASESHR' or uType = '*ALL';
          found = *on;
        endif;

        if uType = 'CBICOUNT' or uType = '*ALL';
          found = *on;
        endif;

        if uType = 'CBISHRTMIS' or uType = '*ALL';
          found = *on;
        endif;

        if uType = 'CBILDRFILE' or uType = '*ALL';
          found = *on;
        endif;

        if uType <> '*ALL' and not found;
          pReturn  = '*NOPROGRAM';
          pMessage = 'No processing program has been '
                   + 'defined for type ' + uType;
        endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  runInteractiveSets  Run program interactively returning sets
     *----------------------------------------------------------------

      /free
       begsr runInteractiveSets;

         // First execute export programs

         exsr runInteractive;
         if pReturn <> '*OK';
           leavesr;
         endif;

         // Now mark all batch records that are Ready for export.

           whse3S = pWhse;

           monitor;
             GetRecId(whse3S: 'DKTEXPORT': recId);
           on-error;
             return;
           endmon;

           recIdA = %trim(%char(recId));

         sqlstmt = 'update stgbatch '
                 + 'set sbexpid=' + sq + recIdA + sq + ', '
                 +     'sbstatus=' + sq + 'P' + sq + ' '
                 + 'where sbstatus=' + sq + 'R' + sq;

         select;
           when uType = '*ALL';


         endsl;

         exec sql
           update stgbatch
           set sbexpid = :recIdA, sbstatus='P'
           where sbstatus = 'R';



         select;

           when uType = 'EXPADJUST';
             monitor;
               it726s(alphaWhse);
             on-error;
               pReturn  = '*ERRIT726S';
               pMessage = 'Error calling IT726S';
               leavesr;
             endmon;

           when uType = 'CBITIEHIGH';

           when uType = 'CBICASESHR';

           when uType = 'CBICOUNT';

           when uType = 'CBISHRTMIS';

           when uType = 'CBILDRFILE';

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

           when uType = 'EXPADJUST';
             cmd = 'call it726s ('
                 +   sq + alphaWhse + sq + ' '
                 + ')';

           when uType = 'CBITIEHIGH';

           when uType = 'CBICASESHR';

           when uType = 'CBICOUNT';

           when uType = 'CBISHRTMIS';

           when uType = 'CBILDRFILE';

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

       endsr;
      /end-free
