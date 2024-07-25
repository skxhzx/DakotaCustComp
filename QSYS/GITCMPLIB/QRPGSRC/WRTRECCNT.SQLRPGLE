      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
710  *  Compile instructions
      *             CRTSQLRPGI PGM(XXX/SQL003RG) SRCFILE(XXX/QRPGLESRC)
      *
      *
      * COMPILING. In order to compile this program you will need
      *            to use options which allow it to work correctly
      *            between machines. These options are---
      *
      *               COMMIT = *NONE
      *               RDB    = Machine name that you will connect to.
      *               DLYPRP = *YES
710   *               CLOSQLCSR = *ENDMOD
      *               SQLPKG = The name & library that you want to
      *                        use for the package. This will put the
      *                        package on the RDB machine that you
      *                        specify.
     *
OLD  *    CRTRPGMOD MODULE(*) SRCFILE(*) TGTRLS(V5R2M0)    OLD
     *
OLD  *    CRTPGM PGM(*) MODULE(*) ACTGRP(*CALLER)          OLD
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  WRTRECCNT   Write RECCNT record
     *  26 May 2010
     *  Dave Sommerville
     *
     *  Revisions
     *
530 A*    05/26/10  DAS  5.30
     *      - Created
     *
530aA*    07/13/10  DAS  5.30a
     *      - Add message logic.
     *
650aA*    06/06/14  RTR  6.50a
     *      - Added fields for PIRCLIENT/PIRCLIENT2.
     *      - Added fields for library/file.
     *      - Added year to week key.
     *      - Added delete for records older than 2 years.
     *
650bA*    01/02/15  DAS  6.50b
     *      - Added files LABELH, PIRTRANH, LICLOGH.
     *      - Revised 650a change for setting default toMsgQ value
     *
700aA*    09/30/16  LMC  7.00a
     *      - Removed the Sendmessage for LICLOG.
     *
720aA*    01/19/18  DAS  7.20a
     *      - Removed the Sendmessage for PIRTRAND because
     *        it doesn't have a unique key.
720b *    08/22/18  LMC  7.20b
     *      - Recompile only - Databases changes.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

530aA /copy qcopysrc,p.getclient
      /copy qcopysrc,p.getreccnt
      /copy qcopysrc,p.getweek
530aA /copy qcopysrc,p.qcmdexc
650aA /copy qcopysrc,p.getoptio

     *----------------------------------------------------------------
     * Customer id's
     *----------------------------------------------------------------

      /copy qcopysrc,id#cheney
      /copy qcopysrc,id#cheneyo
      /copy qcopysrc,id#cheneyr

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D gDate           s              6  0
     D gTime           s              6  0
     D gwStamp         s               z
     D gwWeek          s              2  0
650aMD gwWeek2         s              6  0
     D gwDOW           s              1  0
     D gwSunday        s              6  0
     D gClient         s             10
     D gClientLoc      s             10
650aAD gOptStr         s            117a

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

530aAd CheckThreshold  pr
530aAd  file                         10a   const
530aAd  recCount                     10  0 const

530aAd SendMessage     pr
530aAd  file                         10a   const
530aAd  recCount                     10  0 const

     d UpdRecCount     pr
     D  file                         10a   const

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pCode      Identification code (A -Z)
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pCode             1

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;

530aA   // Get client info
530aA
530aA   getclient(gClient: gClientLoc);

530aA   // Special case for code 'X'
530aA   // Just send a test message and get out
530aA
530aA   if pCode = 'X';
530aA     SendMessage('': 0);
530aA     return;
530aA   endif;

        // Get Date/Time information

        exec sql values (current timestamp) into :gwStamp;

        gDate = %dec(%date(gwStamp):*ymd);
        gTime = %dec(%time(gwStamp));

        getWeek(gwStamp: gwWeek: gwDOW: gwSunday);
650aA   gwWeek2 = gwWeek + ( %dec( %char( %subdt( %date():*y )) :4:0) * 100);

650aA   // Delete records older than 2 years
650aA   exec sql delete from reccnt
650aA             where rcweek < (:gwWeek2 - 200);

        // Record file record counts

        UpdRecCount('LABEL');
650bA   UpdRecCount('LABELH');
        UpdRecCount('PIRTRAN');
650bA   UpdRecCount('PIRTRANH');
        UpdRecCount('WORKLBL');
        UpdRecCount('LICENSE');
        UpdRecCount('BATCTL');
        UpdRecCount('ORDP');
        UpdRecCount('RTEHED');
        UpdRecCount('ORDH');
650aA   UpdRecCount('LICLOG');
650aA   UpdRecCount('LICLOGH');
650aA   UpdRecCount('PIRTRAND');
650aA   UpdRecCount('POHDR');
650aA   UpdRecCount('PODTL');
650aA   UpdRecCount('HACCPLOG');
650aA   UpdRecCount('HACCPQTH');
650aA   UpdRecCount('HACCPS');
650aA   UpdRecCount('HACCPXRF');

         return;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Sub Procedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------

530aA*----------------------------------------------------------------
530aA*  CheckThreshold   Check record count thresholds
530aA*----------------------------------------------------------------
530aA
530aAp CheckThreshold  b
     d CheckThreshold  pi
     D  file                         10a   const
     D  recCount                     10  0 const

     *  Local Variables

     D threshold       s              7  0

      /free
        select;
          when file = 'LABEL' and recCount > 9000000;
            SendMessage(file: recCount);
          when file = 'WORKLBL' and recCount > 9000000;
            SendMessage(file: recCount);
          when file = 'PIRTRAN' and recCount > 9000000;
            SendMessage(file: recCount);
          when file = 'ORDH' and recCount > 9000000;
            SendMessage(file: recCount);
700aD     //when file = 'LICLOG' and recCount > 9000000;
700aD     //SendMessage(file: recCount);
720aD     //when file = 'PIRTRAND' and recCount > 9000000;
720aD     //  SendMessage(file: recCount);
650aA     when file = 'POHDR' and recCount > 9000000;
650aA       SendMessage(file: recCount);
650aA     when file = 'PODTL' and recCount > 9000000;
650aA       SendMessage(file: recCount);
650aA     when file = 'HACCPLOG' and recCount > 9000000;
650aA       SendMessage(file: recCount);
650aA     when file = 'HACCPQTH' and recCount > 9000000;
650aA       SendMessage(file: recCount);
650aA     when file = 'HACCPS' and recCount > 9000000;
650aA       SendMessage(file: recCount);
650aA     when file = 'HACCPXRF' and recCount > 9000000;
650aA       SendMessage(file: recCount);
          when file = 'BATCTL' and recCount > 4000000;
            SendMessage(file: recCount);
          when file = 'RTEHED' and recCount > 90000;
            SendMessage(file: recCount);
         endsl;

         return;
      /end-free

     p CheckThreshold  e

530aA*----------------------------------------------------------------
530aA*  SendMessage  Send message to specific users
530aA*----------------------------------------------------------------
530aA
530aAp SendMessage     b
     d SendMessage     pi
     D  file                         10a   const
     D  recCount                     10  0 const

     *  Local Variables

     D cmd             s           3000    varying
     D contact         s             30
     D message         s            512
     D toMsgQ          s            512

      /free

650aA    getOptions('000':'*RECCNT':'001':'117':toMsgQ);

         select;
           when pCode = 'X';
             select;
               when gClient = cheney;
                 contact = 'Jose Duque';
               other;
                 contact = 'BFC';
             endsl;
             message = 'This is a test BFC Dakota file threshold message. '
                     + 'Please inform ' + %trimr(contact) + ' '
                     + 'that you received this message. In the event that '
                     + 'a BFC Dakota file is getting close to its maximum '
                     + 'threshold you will receive a message that starts '
                     + 'with BFC WARNING.';
           other;
             message = 'BFC WARNING: The record count threshold has been '
                     + 'exceeded for file ' + %trim(file) + '. '
                     + 'Record count is ' + %trim(%editc(recCount:'P')) + '. '
                     + 'Please contact BFC.';
         endsl;

650bA    if toMsgQ = *blanks
650bA     or toMsgQ = '*ERROR';
            select;
              when gClient = cheney and gClientLoc = cheneyriviera;
                toMsgQ = 'BFC QSYSOPR QUSRSYS/JOSED QUSRSYS/KEITHS '
                       + 'QUSRSYS/MARKE QUSRSYS/TAML';
              when gClient = cheney and gClientLoc = cheneyocala;
                toMsgQ = 'BFC QSYSOPR QUSRSYS/JOSED QUSRSYS/GUSC '
                       + 'QUSRSYS/IGNACIOE QUSRSYS/NICHOLASE';
              other;
                toMsgQ = 'BFC QSYSOPR';
            endsl;
650bA    endif;

         cmd = 'sndmsg '
             + 'msg(' + sq + %trimr(message) + sq + ') '
             + 'tomsgq(' + %trimr(toMsgQ) + ')';

         monitor;
           qcmdexc(%trim(cmd): %len(%trim(cmd)));
         on-error *all;
         endmon;

         return;
      /end-free

     p SendMessage     e

     *----------------------------------------------------------------
     *  UpdRecCount  Update record count
     *----------------------------------------------------------------

     p UpdRecCount     b
     d UpdRecCount     pi
     D  iFile                        10a   const

     *  Local Variables

     D file            s             10
     D curRecFound     s               n
     D curRcd          s             10  0
     D dltRcd          s             10  0
     D prvRecFound     s               n
650aDD*prvWeek         s              2  0
650aMD prvWeek         s              6  0

     *  File data data structure

     D curRecCnt     E ds                  extname(reccnt)
     D prvRecCnt     E ds                  extname(reccnt)
     D                                     prefix(prv_)

      /free

        file = iFile;
650aD   //prvWeek = gwWeek - 1;
650aA   prvWeek = gwWeek2 - 1;

        // Get record count of file

        getRecCnt(file: curRcd: dltRcd);

        // Get previous week's record

        exec sql select * into :prvRecCnt
                 from reccnt
                 where rcfile = :file
                   and rccode = :pCode
                   and rcweek = :prvWeek;

        If sqlstt = sqlSuccess;
          prvRecFound = *on;
        else;
          prvRecFound = *off;
          clear prvRecCnt;
        endif;

        // Get current week's record

        exec sql select * into :curRecCnt
                 from reccnt
                 where rcfile = :file
                   and rccode = :pCode
650aM              and rcweek = :gwWeek2;
650aD            //and rcweek = :gwWeek;

        If sqlstt = sqlSuccess;
          curRecFound = *on;
        else;
          curRecFound = *off;
          clear curRecCnt;
        endif;

        select;
          when gwDOW = 1;
            rcdte1 = gDate;
            rctim1 = gTime;
            rccnt1 = curRcd;
            rcday1 = rccnt1 - prv_rccnt7;
            rcweek1 = rccnt1 - prv_rccnt1;
          when gwDOW = 2;
            rcdte2 = gDate;
            rctim2 = gTime;
            rccnt2 = curRcd;
            rcday2 = rccnt2 - rccnt1;
            rcweek2 = rccnt2 - prv_rccnt2;
          when gwDOW = 3;
            rcdte3 = gDate;
            rctim3 = gTime;
            rccnt3 = curRcd;
            rcday3 = rccnt3 - rccnt2;
            rcweek3 = rccnt3 - prv_rccnt3;
          when gwDOW = 4;
            rcdte4 = gDate;
            rctim4 = gTime;
            rccnt4 = curRcd;
            rcday4 = rccnt4 - rccnt3;
            rcweek4 = rccnt4 - prv_rccnt4;
          when gwDOW = 5;
            rcdte5 = gDate;
            rctim5 = gTime;
            rccnt5 = curRcd;
            rcday5 = rccnt5 - rccnt4;
            rcweek5 = rccnt5 - prv_rccnt5;
          when gwDOW = 6;
            rcdte6 = gDate;
            rctim6 = gTime;
            rccnt6 = curRcd;
            rcday5 = rccnt6 - rccnt5;
            rcweek6 = rccnt6 - prv_rccnt6;
          when gwDOW = 7;
            rcdte7 = gDate;
            rctim7 = gTime;
            rccnt7 = curRcd;
            rcday7 = rccnt7 - rccnt6;
            rcweek7 = rccnt7 - prv_rccnt7;
        endsl;

        If curRecFound;
          exec sql update reccnt
                 set rcdte1 = :rcdte1,
                     rctim1 = :rctim1,
                     rccnt1 = :rccnt1,
                     rcday1 = :rcday1,
                     rcweek1 = :rcweek1,
                     rcdte2 = :rcdte2,
                     rctim2 = :rctim2,
                     rccnt2 = :rccnt2,
                     rcday2 = :rcday2,
                     rcweek2 = :rcweek2,
                     rcdte3 = :rcdte3,
                     rctim3 = :rctim3,
                     rccnt3 = :rccnt3,
                     rcday3 = :rcday3,
                     rcweek3 = :rcweek3,
                     rcdte4 = :rcdte4,
                     rctim4 = :rctim4,
                     rccnt4 = :rccnt4,
                     rcday4 = :rcday4,
                     rcweek4 = :rcweek4,
                     rcdte5 = :rcdte5,
                     rctim5 = :rctim5,
                     rccnt5 = :rccnt5,
                     rcday5 = :rcday5,
                     rcweek5 = :rcweek5,
                     rcdte6 = :rcdte6,
                     rctim6 = :rctim6,
                     rccnt6 = :rccnt6,
                     rcday6 = :rcday6,
                     rcweek6 = :rcweek6,
                     rcdte7 = :rcdte7,
                     rctim7 = :rctim7,
                     rccnt7 = :rccnt7,
                     rcday7 = :rcday7,
                     rcweek7 = :rcweek7
                 where rcfile = :file
                   and rccode = :pCode
650aM              and rcweek = :gwWeek2;
650aD            //and rcweek = :gwWeek;
        else;
          exec sql insert into reccnt
650aM            values(:gclient,
650aM                   :gclientloc,
                        :file,
                        :pCode,
650aM                   :gwWeek2,
650aD                // :gwWeek2,
                        :rcdte1,
                        :rctim1,
                        :rccnt1,
                        :rcday1,
                        :rcweek1,
                        :rcdte2,
                        :rctim2,
                        :rccnt2,
                        :rcday2,
                        :rcweek2,
                        :rcdte3,
                        :rctim3,
                        :rccnt3,
                        :rcday3,
                        :rcweek3,
                        :rcdte4,
                        :rctim4,
                        :rccnt4,
                        :rcday4,
                        :rcweek4,
                        :rcdte5,
                        :rctim5,
                        :rccnt5,
                        :rcday5,
                        :rcweek5,
                        :rcdte6,
                        :rctim6,
                        :rccnt6,
                        :rcday6,
                        :rcweek6,
                        :rcdte7,
                        :rctim7,
                        :rccnt7,
                        :rcday7,
                        :rcweek7);
        endif;

530aA   // Last of all, check threshold
530aA
530aA   CheckThreshold(iFile: curRcd);

         return;
      /end-free

     p UpdRecCount     e
