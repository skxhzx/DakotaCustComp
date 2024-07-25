      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
      *----------------------------------------------------------
      *   Copyright (C) 2014 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

720aAH*bnddir('QC2LE':'QUSAPIBD':'PIRSQLPGM':'BFCBND')
720aMH bnddir('QC2LE':'QUSAPIBD':'BFCBND')

     *----------------------------------------------------------
     *
     *  CHKTRANS   Check status of transactions and runner
     *             transactions for route and send back error if
     *             if any of the following conditions are true:
     *
     *             1. There are no runner transactions for the route.
     *             2. All runner transactions are not closed.
     *             3. All PIRTRAN trans are not ended or closed.
     *
     *  07 Aug 2014
     *  Retha Davis
     *
     *  Revisions:
     *
     *    08/07/14  RBD  6.50
     *      - Created.
     *
720aA*    01/09/19  DAS  7.20a
     *      - Removed BNDDIR PIRSQLPGM. BFCBND contains programs.
     *
     *----------------------------------------------------------
      * File Specs
      *----------------------------------------------------------
     Fpirtran3  if   e           k disk
     Frunner5   if   e           k disk
     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

      *----------------------------------------------------------
      *  Program information data structure
      *----------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,c#stdvar

      *----------------------------------------------------------

     D pssrflag        s               n

     D                sds
     D  #pgm                   1     10
     D  #prog                  1     10
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #routine              29     36
     D  #parms                37     39
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobnbr              264    269
     D  #jobn                264    269
     D  #jobdate             276    281  0
     D  #jobtime             282    287  0
     D  #curruser            358    367

      *----------------------------------------------------------
      *  Prototypes
      *----------------------------------------------------------
      /copy qcopysrc,p.wrtsessl

     D usleep          pr            10u 0 extproc('usleep')
     D  Interval                     10u 0 value

      *----------------------------------------------------------
      *  Input Parms
      *----------------------------------------------------------

     D  pWhse          s              3p 0
     D  pRtId          s              5
     D  pCmd           s              1
     D  ploc           s             10

      *----------------------------------------------------------
      *  Variables
      *----------------------------------------------------------

     D cntRunnerTrn    s              3  0
     D whse            s              3  0
     D kygrp1          S              1    Inz('S')
     D kygrp2          S              1    Inz(' ')
     D logText         s            100
     D Numbers         S             11    Inz(' 0123456789')
     D Non_Num_Posn    S              2  0 Inz(*Zero)
     D dbgflgExists    s               n
     D debug           s               n
     D err             s               n
     d TodayJul        s              5
     d wrkMfgno        s              2  0
     d bugstate        s              5  0
     d jultoDay        s             12
     d newnrm          s              5  0
     d remqty          s              5  0
     d totalqty        s              5  0
     d totaladj        s              5  0
     d pNewQty         s             12
     d prdSlot         s             12
     d wkError         s               n
     d wkRerr2         s             50
     d wkCrtProdErr    s             15

      *----------------------------------------------------------------
      *  Data structure for error message parameters
      *------------------------------------------------------------------
     D $MDT            DS
     D  ERRMSG                 1     50
     D                 DS
     D  $EC                    1      2P 0

     *----------------------------------------------------------------

     * Parameters
     *
     *    Input Parameters
     *      pErrMsg      Returned Error Message
     *      pSessId      Session Id of caller
     *      pUser        User making call
     *      pPgm         Dictionary and Program calling
     *      pWhse        Warehouse hard wired to user
     *      pRtId        Route Id
     *      pCmd         Function to perform
     *      pLoc         Tells whether to just do edits or not
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pErrMsg          99
     c                   parm                    pSessId          40
     c                   parm                    pUser            10
     c                   parm                    pPgm             20
     c                   parm                    pWhse
     c                   parm                    pRtId
     c                   parm                    pCmd
     c                   parm                    pLoc

      /free

         exsr init;
         exsr chkTrans;

         *inlr = *on;

       //---------------------------------------------------------
       // Init  -  Do some one time things
       //---------------------------------------------------------

         begsr Init;

           open(e) bfcdbgflg;
           if %error;
             dbgflgExists = *off;
           else;
             dbgflgExists = *on;
           endif;

           if dbgflgExists;
             chain(e) (#pgm) bfcdbgflg;
             if %found(bfcdbgflg);
               debug = (bdfflag = 1);
             else;
               debug = *off;
             endif;
           endif;

           #curruser = pUser;

      /end-free
     *
     *   Get default values for the user.
     *

     C                   call      'GETUSER'
     C                   parm                    #curruser
     C                   parm      0             #whse             3 0
     C                   parm      0             #emp#             5 0
     C                   parm                    #fnam            15
     C                   parm                    #init             1
     C                   parm                    #lnam            20
     C                   parm                    #whdp             5
     C                   parm                    #styp             1
     C                   parm                    #shft             6
     C                   parm                    #crew             6
     C                   parm      0             #nhrs             3 1
     C                   parm                    #rtn              8
      /free
          endsr;

       //---------------------------------------------------------
       // chkTrans - Check status of transactions
       //---------------------------------------------------------

       begsr chkTrans;

         err = *off;

         // Loop through PIRTRAN3 and return an error if there are any
         // transactions that are not ended. Note, closed transactions
         // are omitted from PIRTRAN3.

         setll (pWhse:kygrp1:kygrp2:pRtId) pirtran3;
         dow forever = forever;
           reade (pWhse:kygrp1:kygrp2:pRtId) pirtran3;

           if %eof(pirtran3);
             leave;
           endif;

           if ptstat <= '2';
             err = *on;
             pErrMsg = 'Transaction ' +
                        %editc(pttrn#:'X') +
                        ' not closed';
             leave;
           endif;

           exsr chkRunner;

           if err = *on;
             leave;
           endif;

         enddo;

         if err = *off and cntRunnerTrn = 0;
           err = *on;
           pErrMsg = 'No runner transactions for route id ' +
                      %trim(pRtId);
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  chkRunner -  Check to see if the transaction is a runner, if
     *               so and it's not closed, return an error.  Also
     *               keep a count of runner transactions, and if at
     *               *inlr there are none, return an error.
     *----------------------------------------------------------------

     C     chkRunner     begsr
      /free

         chain (ptwhse:pttrn#) runner5;

         if %found(runner5);

           if rustat <> 'C' and rustat <> 'D';
             err = *on;
             pErrMsg = 'Runner trans ' +
                        %editc(pttrn#:'X') +
                        ' not closed';
           else;
             cntRunnerTrn = cntRunnerTrn + 1;

           endif;

         endif;

      /end-free

     c                   endsr

