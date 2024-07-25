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
     *  TSTKEN2   Test for open files using GUI
     *  20 August 2013
     *  Kenneth Elder
     *
     *  Revisions:
     *
640 A*    08/20/13  DAS  6.50
     *      - Created.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fwarehs    if   e           k disk

     *----------------------------------------------------------------
     *  Parameters
     *
     *      pErrmsg
     *
     *----------------------------------------------------------------

     D tstken2         pr                  extpgm('TSTKEN2')
     D   pErrMsg                     99

     D tstken2         pi
     D   pErrMsg                     99
     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

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
     D pReturn         s             10
     D clientLoc       s             10
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

      /free

         *inlr = *on;

         pReturn = '*OK';
         pErrMsg = ' ';

       // Read record from Warehs and return description field

         setll (*loval) warehs;
         read warehs;

         if %eof(warehs);
            pErrMsg = 'Read Failed in TSTKEN2';
         else;
            pErrMsg = %trim(whdesc);
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
         pErrMsg  = 'U:'
                  + %trim(#pgm)
                  + '('
                  + %trim(%editc(#stmt:'Z'))
                  + ')-'
                  + #pgmmsg;
         *inlr = *on;
         return;

       endsr;
      /end-free
