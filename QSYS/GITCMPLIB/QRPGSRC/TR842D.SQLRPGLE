      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   24 Washington Ave North #203
     *   Batavia IL  60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TR842D  Delete or update route in Trax files before upload.
     *          Based TR844. Created to create separation from Trax 1
     *
     *          Recs in TTRTE and TTSTP will be updated.
740aA*          Call EXTTRTE to update fields in TTRTEEXA.
740aA*          Call EXTTSTP to update fields in TTSTPEXA.
     *          Recs in TTITM and TTTRX will be deleted.
740bA*          Recs in TTIVC will be deleted.
710bD***        Recs in TTEXCP will also be deleted.
     *          This is necessary because if a route gets uploaded
     *          more than once we must first reset the qty buckets.
     *
710aA*          Note: TTRTN records DO NOT GET DELETED by this pgm. If a
710aA*          route is uploaded multiple times the user will have to
710aA*          decide which, if any, of the previously created TTRTN
710aA*          records should be deleted, and which, if any, of the
710aA*          duplicated records should be deleted. The user may have
710aA*          already processed some or all of the TTRTN records thus
710aA*          the user must determine how to handle duplicated TTRTN
710aA*          recs. The Trax returns pgm allows the user to delete recs.
     *
710dA*          Now deleting TTRTN recs under certain conditions.
     *
     *  11 November 2011
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    11/11/11  RBD  6.40
     *      - Created.
     *
640aA*    03/05/12  RBD  6.40a
     *      - Recompiled, TTRTE & TTSTP files changed.
     *
710aA*    06/26/17  RBD  7.10a
     *      - Added delete of recs in TTEXCP.
     *
710bA*    07/12/17  RBD  7.10b
     *      - Reverse 710a mod, it was deleting TTEXCP records AFTER
     *        they were being written.  Instead, the handheld will
     *        have to handle the cleanup before it writes the records.
     *
710cA*    09/19/17  DAS  7.10c
     *      - Added optional parameters Version, Command and Stop.
     *      - Revised to limit cleanup for a Stop if Stop passed in.
     *
710dA*    12/29/17  DAS  7.10d
     *      - Revised to delete TTRTN records if status is 1 and
     *        processed qty is zero.
     *
710eA*    01/04/18  DAS  7.10e
     *      - Reinstated deleting TTEXCP records for Trax 2.0
     *        when a Stop is sent in.
     *
720aA*    01/15/18  DAS  7.20a
     *     - Revised to always clear TTRTE totals. They will always
     *       be recalculated in TR842U.
     *
720bA*    02/18/18  DAS  7.20b
     *     - Added ttpics.
     *     - Cleared start/finish and sig fields in ttstp.
     *
720cA*    03/26/18  DAS  7.20c
     *     - Revised delExcp to use '20' instead of '020'.
     *
720dA*    12/14/18  RBD  7.20d
     *     - Revised delExcp to delete exception recs whether processing
     *       a single stop or the entire route.
     *
720eA*    12/21/18  RBD 7.20e
     *      - Added bfcdebug logic.
     *      - Reversed 720c, bfcdebug showed version passed in is 020.
     *
730aA*    09/13/19  RBD 7.30a
     *      - Delete all returns records, regardless of status, which
     *        have had no qty processed.
     *
740aA*    04/23/20  RBD 7.40a
     *      - Call EXTTRTE to update fields in TTRTEEXA.
     *      - Call EXTTSTP to update fields in TTSTPEXA.
     *
740bA*    12/11/20  RBD 7.40b
     *      - Delete Trax invoice records.
     *
740cA*   12/11/20  RBD  7.40c
     *     - Fix: Enlarged size of rtnMsg from 60 to 120 because
     *       #pgmmsg, which is 80 long, was being returned as part
     *       of the msg in EXTTRTE *PSSR and could potentially cause
     *       it to blow up.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions -
     *
     *
     *----------------------------------------------------------------
     * File Specs

     Ftttrx     uf   e           k disk
     Fttrte     uf   e           k disk
     fttstp     uf   e           k disk
     fttitm     uf   e           k disk
710dAfttrtn3    uf   e           k disk
710eAfttexcp    uf   e           k disk
720bAfttpics    uf   e           k disk
740bAfttivc     uf   e           k disk
720eAfbfcdbgflg if   e           k disk    usropn
720eAfbfcdebug  o    e           k disk    usropn

     *----------------------------------------------------------------
     *  Table and array definitions

     *----------------------------------------------------------------
     *  Customer id

     *----------------------------------------------------------------
     *  Working variables

710cAD byStop          s               n
720eAd dbgflgExists    s               n
720eAd debug           s               n
720eAd debugAfter      s               n
720eAd debugBefore     s               n
720eAd debugLoc        s              1
     D first           s              1
     D lastStop        s              2  0
710cAD pVer            s              5
710cAD pcmd            s             30
710cAD pStop2          s              2  0
740aAD rtnCode         s             10
740cDD*rtnMsg          s             60
740cMD rtnMsg          s            120
740aAD dspid           s             30
740aAD serial#         s             30
740aAD netid           s             30
740aAD blueid          s             30
740aAD simid           s             30
740aAD phone           s             30
740aAD appver          s             20
740aAD pss             s              3p 0 inz(0)
740aAD psc             s              3p 0 inz(0)
740aAD pal             s              3p 0 inz(0)
740aAD iss             s              3p 0 inz(0)
740aAD isc             s              3p 0 inz(0)
740aAD ist             s              3p 0 inz(0)
740aAD retsh           s              4p 0 inz(0)
740aAD ret             s              4p 0 inz(0)
     D
     *----------------------------------------------------------------
     *  Date/time variables

     D bfcoffset       s              3  0 inz(0)
     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D currtimestamp   s               z
     D datestamp       s               d
     D editdate        s               d
     D edittime        s               t   timfmt(*hms:)
     D micro           s             26
     D micro4          s              4
     D timestamp       s               t   timfmt(*hms:)

     *----------------------------------------------------------------
     *  Program info data structure

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Constants

     D forevr          c                   const('1')

720eA*----------------------------------------------------------------
720eA*  Sub-Procedure Prototypes
720eA*----------------------------------------------------------------

720eAd WrtDebugLibl    pr

720eAd WrtDebugParms   pr

720eAd WrtDebug        pr

720eA*----------------------------------------------------------------
720eA*  Prototypes
720eA*----------------------------------------------------------------

720eAd GetLiblCL       pr                  extpgm('GETLIBLCL')
720eAd  libList                    1024

740aA*----------------------------------------------------------------
740aA*  Called Programs Prototypes
740aA*----------------------------------------------------------------

740aAd/copy qcopysrc,p.exttrte
740aAd/copy qcopysrc,p.exttstp

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route ID
710cA*      $PVER   Trax Version
710cA*      $PCMD   Command passed into TRCMPRTE2, TR842
710cA*      $PSTOP2 2-digit Stop
     *
     *    Returned Parameters
     *      $PRTN   *OK      - Route was processed.
     *              *CANCEL  - Route was not processed.
     *      $PERM            - Error message.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $prtn             8
     C                   parm                    $perm            60
710cAC                   parm                    $pver             5
710cAC                   parm                    $pcmd            30
710cAC                   parm                    $pStop2           2 0

     * Main line

     C                   eval      $prtn = '*OK    '

720eA /free

720eA    // See if debug is turned on

720eA   debug = *off;
720eA   if dbgflgExists;
720eA     chain(e) (#pgm) bfcdbgflg;
720eA     if %found(bfcdbgflg);
720eA       select;
720eA         when bdfflag > 0;
720eA           debug = *on;
720eA       endsl;
720eA     endif;
720eA   endif;

720eA   if debug;
720eA     WrtDebugLibl();
720eA     WrtDebugParms();
720eA   endif;

720eA /end-free

710cA* See if we are processing a single Stop
710cA
710cAC                   eval      byStop = *off
710aCC                   eval      pVer = ''
710aCC                   eval      pCmd = ''
710aCC                   eval      pStop2 = 0

710cAC                   if        %parms >= 7
710aCC                   eval      pVer = $pver
710aCC                   eval      pCmd = $pcmd
710aCC                   eval      pStop2 = $pStop2
710cAC                   if        $pcmd = 'postCompletedStop'
710cAC                   eval      byStop = *on
710cAC                   endif
710cAC                   endif

     *  Loop through Trax pieces file and delete all recs for this route.

710cAC                   if        byStop
710cAC     keyTrxStp     setll     tttrx
710cAC                   else
     C     keyTrx        setll     tttrx
710cAC                   endif
     C                   dou       forevr <> forevr
710cAC                   if        byStop
710cAC     keyTrxStp     reade     tttrx
710cAC                   else
     C     keyTrx        reade     tttrx
710cAC                   endif
     C                   if        %eof(tttrx)
     C                   leave
     C                   endif
     C                   delete    ttxrec
     C                   enddo

     *  Loop through Trax item file and delete all recs for this route.

710cAC                   if        byStop
710cAC     keyTrxStp     setll     ttitm
710cAC                   else
     C     keyTrx        setll     ttitm
710cAC                   endif
     C                   dou       forevr <> forevr
710cAC                   if        byStop
710cAC     keyTrxStp     reade     ttitm
710cAC                   else
     C     keyTrx        reade     ttitm
710cAC                   endif
     C                   if        %eof(ttitm)
     C                   leave
     C                   endif
     C                   delete    ttirec
     C                   enddo

     *  Loop through Trax stop file and reset qty buckets.

710cAC                   if        byStop
710cAC     keyTrxStp     setll     ttstp
710cAC                   else
     C     keyTrx        setll     ttstp
710cAC                   endif
     C                   dou       forevr <> forevr
710cAC                   if        byStop
710cAC     keyTrxStp     reade     ttstp
710cAC                   else
     C     keyTrx        reade     ttstp
710cAC                   endif
     C                   if        %eof(ttstp)
     C                   leave
     C                   endif
     C                   eval      ttpdlv = ' '
     C                   eval      ttpscn = ' '
     C                   eval      ttpqs1 = 0
     C                   eval      ttpqs2 = 0
     C                   eval      ttpqs3 = 0
     C                   eval      ttpqn1 = 0
     C                   eval      ttpqn2 = 0
     C                   eval      ttpqn3 = 0
     C                   eval      ttpqc1 = 0
     C                   eval      ttpqc2 = 0
     C                   eval      ttpqc3 = 0
     C                   eval      ttpqp1 = 0
     C                   eval      ttpqp2 = 0
     C                   eval      ttpqp3 = 0
720bAC                   eval      ttpsrd = 0
720bAC                   eval      ttpsrt = 0
720bAC                   eval      ttpfid = 0
720bAC                   eval      ttpfit = 0
720bAC                   eval      ttpgna = ''
720bAC                   eval      ttpgfn = ''
720bAC                   eval      ttpguc = ''
720bAC                   eval      ttpgsn = ''
720bAC                   eval      ttpgdt = 0
720bAC                   eval      ttpgtm = 0
     C                   update    ttprec

740aA /free
740aA        ttpawhs = $pwhse;
740aA        ttpastp = ttpstp;
740aA        exttstp ('*CHANGE': rtnCode: rtnMsg: ttpawhs: $prtid:
740aA                 ttpastp: pss: '1': psc: '1':
740aA                 pal: '1': iss: '1':  isc: '1':
740aA                 ist: '1': retsh: '1':  ret: '1');
740aA /end-free

     C                   enddo

710dA*  Loop through Trax returns file and delete all recs for this route.
710dA
710dAC     keyTrx        setll     ttrtn3
710dAC                   dou       forevr <> forevr
710dAC     keyTrx        reade     ttrtn3
710dAC                   if        %eof(ttrtn3)
710dAC                   leave
710dAC                   endif
710dA
710dA*    Skip if not correct Stop
710dA
710dAC
710dAC                   if        byStop and ttstop <> pStop2
710dAC                   iter
710dAC                   endif
710dA
730aD**** Skip if not status 1 or processed qty is not zero
730aM*    Skip if processed qty is not zero REGARDLESS OF STATUS
710dA
730aDC**                 if        ttstat <> '1' or ttpqty <> 0
730aMC                   if        ttpqty <> 0
710dAC                   iter
710dAC                   endif
710dA
710dAC                   delete    ttrec
710dAC                   enddo

720bA*  Loop through Trax pics file and delete all recs for this route.
720bA
720bAC     keyTrx        setll     ttpics
720bAC                   dou       forevr <> forevr
720bAC     keyTrx        reade     ttpics
720bAC                   if        %eof(ttpics)
720bAC                   leave
720bAC                   endif
720bA
720bA*    Skip if not correct Stop
720bA
720bAC
720bAC                   if        byStop and ttpcstp <> pStop2
720bAC                   iter
720bAC                   endif
720bA
720bAC                   delete    ttpcrec
720bAC                   enddo

     *  Loop through Trax route file and reset qty buckets.
710cA*  Do not do this if working with a Stop

720aDC**                 if        not byStop
     C     keyTrx        setll     ttrte
     C                   dou       forevr <> forevr
     C     keyTrx        reade     ttrte
     C                   if        %eof(ttrte)
     C                   leave
     C                   endif
     C                   eval      ttrscn = ' '
     C                   eval      ttrs   = 0
     C                   eval      ttrsd  = 0
     C                   eval      ttrqs1 = 0
     C                   eval      ttrqs2 = 0
     C                   eval      ttrqs3 = 0
     C                   eval      ttrqn1 = 0
     C                   eval      ttrqn2 = 0
     C                   eval      ttrqn3 = 0
     C                   eval      ttrqc1 = 0
     C                   eval      ttrqc2 = 0
     C                   eval      ttrqc3 = 0
     C                   eval      ttrqp1 = 0
     C                   eval      ttrqp2 = 0
     C                   eval      ttrqp3 = 0
     C                   update    ttrrec

740aA /free
740aA        trawhse = $pwhse;
740aA        exttrte ('*CHANGE': rtnCode: rtnMsg: trawhse: $prtid:
740aA                 dspid: '0': serial#: '0': netid: '0':
740aA                 blueid: '0': simid: '0':  phone: '0': appver: '0':
740aA                 pss: '1': psc: '1':
740aA                 pal: '1': iss: '1':  isc: '1':
740aA                 ist: '1': retsh: '1':  ret: '1');
740aA /end-free

     C                   enddo
720aDC**                 endif

740bA /free
740bA     // delete route from Trax invoice file
740bA     exec sql delete from ttivc
                   where :$pwhse = ttvwhs
                     and :$prtid = ttvrti;
740bA /end-free

710eAC                   exsr      delExcp

     C     bottom        tag

     C                   eval      *inlr = *on
     *----------------------------------------------------------------

     *          SUBROUTINES IN ALPHABETICAL ORDER

     *----------------------------------------------------------------

     *  *INZSR  Initialization subroutine

     C     *inzsr        begsr

720eA /free

720eA    open(e) bfcdbgflg;
720eA    if %error;
720eA      dbgflgExists = *off;
720eA    else;
720eA      dbgflgExists = *on;
720eA    endif;

720eA /end-free

     *   Define partial key for TTTRX file

     C     keyTrx        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

710cA*   Define partial key for TTTRX file with Stop
710cA
710cAC     keyTrxStp     klist
710cAC                   kfld                    $pwhse
710cAC                   kfld                    $prtid
710cAC                   kfld                    pStop2

     C                   endsr
710eA*-------------------------------------------------------------------------
710eA*  Loop through Trax exception file and delete all recs for this route.
710eA*-------------------------------------------------------------------------
710eA
710eA /free
710eA  begsr delExcp;

         // Only do for Trax 2.0

720eA    if debug;
720eA      bdtype='delExcp_1';
720eA      wrtDebug();
720eA    endif;

720eD    // if pVer <> '20';
720eM    if pVer <> '020';

720eA    if debug;
720eA      bdtype='delExcp_2';
720eA      wrtDebug();
720eA    endif;

           leavesr;
         endif;

720dD    // Only do when working with single Stop

720dD    //if not byStop;
720dD    //  leavesr;
720dD    //endif;

         // Delete records for Stop
720dA    // or for route if not working with single stop

         setll (%char($pWhse): $pRtid) ttexcp;

         dou forevr <> forevr;

           reade (%char($pWhse): $pRtid) ttexcp;

           if %eof(ttexcp);

720eA        if debug;
720eA          bdtype='delExcp_3';
720eA          wrtDebug();
720eA        endif;

             leave;
           endif;

720dD      //if ttestp <> %char(pStop2);
720dM      if bystop and ttestp <> %char(pStop2);

720eA        if debug;
720eA          bdtype='delExcp_4';
720eA          wrtDebug();
720eA        endif;

             iter;
           endif;

           delete tterec;

720eA      if debug;
720eA        bdtype='delExcp_5';
720eA        wrtDebug();
720eA      endif;

         enddo;

       endsr;
      /end-free

720eA*----------------------------------------------------------------
720eA*  wrtDebugLibl   Write out debug parm record
720eA*----------------------------------------------------------------
720eA
     p WrtDebugLibl    b
     d WrtDebugLibl    pi

      /free

        if not %open(bfcdebug);
          open bfcdebug;
        endif;

        bdtype = 'LIBL';

        GetLiblCL(bdvalues);

        bdaddts = %timestamp();
        bdaddpgm = #pgm;
        bdaddcusr = #curruser;
        bdaddjusr = #user;
        bdaddjob = #job;
        bdaddnbr = #jobnbr;

        write bdrec;

      /end-free
     p                 e

720eA*----------------------------------------------------------------
720eA*  wrtDebugParms  Write out debug parm record
720eA*----------------------------------------------------------------
720eA
     p WrtDebugParms   b
     d WrtDebugParms   pi

      /free

        if not %open(bfcdebug);
          open bfcdebug;
        endif;

        bdtype = 'PARMS';

        bdvalues = '$pWhse=' + %trim(%char($pWhse)) + ', '
                 + '$pRtid=' + $pRtid + ', '
                 + '$pVer=' + $pVer + ', '
                 + '$pCmd=' + $pCmd + ', '
                 + '$pStop2=' + %trim(%char($pStop2));

        bdaddts = %timestamp();
        bdaddpgm = #pgm;
        bdaddcusr = #curruser;
        bdaddjusr = #user;
        bdaddjob = #job;
        bdaddnbr = #jobnbr;

        write(e) bdrec;

      /end-free

     p                 e

720eA*----------------------------------------------------------------
720eA*  wrtDebug  Write out debug record
720eA*----------------------------------------------------------------
720eA
     p WrtDebug        b
     d WrtDebug        pi

      /free

        if not %open(bfcdebug);
          open bfcdebug;
        endif;

        bdvalues = 'pVer=' + pVer + ', '
                 + 'byStop=' + byStop + ', '
                 + '$pWhse=' + %trim(%char($pWhse)) + ', '
                 + '$pRtid=' + $pRtid + ', '
                 + 'ttestp=' + ttestp + ', '
                 + 'pStop2=' + %trim(%char(pStop2)) + ', '
                 + 'ttestp=' + ttestp;

        bdaddts = %timestamp();
        bdaddpgm = #pgm;
        bdaddcusr = #curruser;
        bdaddjusr = #user;
        bdaddjob = #job;
        bdaddnbr = #jobnbr;

        write(e) bdrec;

      /end-free

     p                 e

     *----------------------------------------------------------------

