      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  AUTOCLS   Auto close selection transaction
     *  10 March 2011
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    03/10/11  DAS  6.40
     *      - Created.
     *
650aA*    09/03/13  DAS  6.50a
     *      - Added logic to get client.
     *      - Added BFCLOG logic
     *
700 A*    10/09/15  MLB  7.00
     *      - Fix: Revised pgm to pass $llbl#, $lqpck and $lwarn to
     *        PT132 via $LPARM.
     *
710aA*    01/19/17  DAS  7.10
     *      - Revised to RCLRSC after calling IT132. Re: This program
     *        is called from VOSELECT, which is called from BFCVOCOP,
     *        which is compiled with an activation group. VOSELECT is
     *        called with *CALLER, but this program is not, so it is
     *        run in the default activation group. Although this program
     *        turns on LR, PT132 and other programs that are called
     *        do not. Therefore, files are being left open, which would
     *        normally be closed via RCLRSC. By calling RCLRSC from
     *        this program, we should close down all of the files that
     *        were opened by calling PT132.
     *
730aA*    10/02/19  LMC  7.30a
     *      - Revised to treat OPFTP flag 'R' same as 'S'. OPFTP = 'R'
     *        is for real time staging exports.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions - Cheney
     *
CBIaA*    09/03/13  DAS  CBIa
     *      - Revised to NOT try and auto close for the following
     *        trucks: MEAT-INSP, PRE-PICK, CONTAINER, SUD-SVC.
     *      - Revised to try and auto Close & Export for WILL-CALL truck.
     *      - Added bfcdebug to record time of Close&Export to see
     *        if it needs to be sent to jobq because this is being
     *        called from voice.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File definitions
     *----------------------------------------------------------------

     Flabel90   if   e           k disk
     Fmultran1  if   e           k disk
     Fpirtran   if   e           k disk
CBIaAFpirtran4  if   e           k disk    rename(ptrec:ptrec4)
CBIaAF                                     prefix(p4_)
     Foptions   if   e           k disk
CBIaAFrtehed    uf   e           k disk
650aAFbfclog    o    e           k disk

     *----------------------------------------------------------------
     *  Client id's
     *----------------------------------------------------------------

CBIaA /copy qcopysrc,id#cheney

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

650aAD client          s             10
650aAD clientLoc       s             10
CBIaAD close           s               n
CBIaAD logging         s               n
710aAD cmd             s           3000    varying
     D error           s               n
650aAD expMsg          s            100
     D forever         s               n
CBIaAD forevr          s               n
CBIaAD seconds2        s              5  0
650aAD start2          s               z

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

CBIaAD @MEAT           C                   CONST('MEAT-INSP')
CBIaAD @PPICK          C                   CONST('PRE-PICK')
CBIaAD @CNTNR          C                   CONST('CONTAINER')
CBIaAD @WLCLL          C                   CONST('WILL-CALL')
CBIaAD @SDSVC          C                   CONST('SUD-SVC')
CBIaAD @DMGES          C                   CONST('DAMAGES')
CBIaAD @ADDON          C                   CONST('ADD-ONS')
CBIaAD @BREKR          C                   CONST('BREAKERS')


640aA*----------------------------------------------------------------
640aA*  *FTP      -  FTP options
640aA*----------------------------------------------------------------
     *
     * Fields
     *
     *    OPFTP   -  Use FTP for exporting (Y,N)
     *    OPSRVR  -  FTP Server name
     *    OPUSER  -  FTP User id
     *    OPPWD   -  FTP Password
     *
     * Data structure
     *
     D opdata          ds
     D  opftp                  1      1
     D  opsrvr                 2     33
     D  opuser                34     48
     D  oppwd                 49     63
     D  ftpend               117    117

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D $lparms         ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     D  $ltype                81     88
     D  $lmput                89     89
700 AD  $llbl#                90     96  0
700 AD  $lqpck                97    101  0
700 AD  $lwarn               102    102

     *   Redefine key

     D  $lwhse                19     21  0
     D  $lrte                 22     26
     D  $lpo                  27     35
     D  $ltrn#                36     42  0

650aAD $cvtdt          ds
650aAD  $cvcmd                 1      8
650aAD  $cvprg                 9     18
650aAD  $cvd6i                19     24
650aAD  $cvd8i                25     32
650aAD  $cvd6o                33     38  0
650aAD  $cvd8o                39     46  0
650aAD  $cvsto                47     64
650aAD  $cvrtn                65     72
650aAD  $cverm                73    132
650aAD  $cvmsg                73     76
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

650aA /copy qcopysrc,p.getclien

710aA /copy qcopysrc,p.qcmdexc

     D pt132           pr                  extpgm('PT132')
     D  parms                        89

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input parameters
     *      $pWhse   Warehouse
     *      $pTrn#   Transaction number
     *
     *    Output parameters
     *      none
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pTrn#            7 0

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         error = *off;

650aA    logging = *on;
650aA    blgstrts = %timestamp();

650aA    // Get client id
650aA
650aA    getclient(client: clientLoc);

         // Only do auto close for Staging export.

         exsr CheckExportType;
         if error;
           return;
         endif;

         // Transaction must be at status 3=Ended
         // and must be a selection transaction.

         exsr CheckTran;
         if error;
           return;
         endif;

CBIaA    // For Cheney, don't auto close for certain trucks.
CBIaA
CBIaA    if client = cheney;
CBIaA      exsr CheckTruck;
CBIaA      if error;
CBIaA        return;
CBIaA      endif;
CBIaA    endif;

         // Transaction cannot be a part of an open group
         // of multiple transactions

         exsr CheckMult;
         if error;
           return;
         endif;

         // Transaction cannot have any open flags

         exsr CheckFlags;
         if error;
           return;
         endif;

         // Transaction passed the test, so try and close it
         // We are not concerned if it actually gets closed.
         // If it doesn't, it will show up during normal closing.

         clear $lparms;
         $lwhse = ptwhse;
         $ltrn# = $pTrn#;
700 A    $llbl# = 0;
700 A    $lqpck = 0;
700 A    $lwarn = '0';
         $lprg = #pgm;
         $lcmd = '*CLOSEV';
         pt132($lparms);

710aA    // Call RCLRSC to close files opened by PT132.
710aA
710aA    cmd = 'RCLRSC LVL(*)';
710aA    monitor;
710aA      qcmdexc(%trim(cmd): %len(%trim(cmd)));
710aA    on-error *all;
710aA    endmon;

CBIaA    // For Cheney WILL-CALL truck, try to Close&Export route.
CBIaA
650aA    expMsg = ' ';
CBIaA    if client = cheney and rhtruk = 'WILL-CALL';
CBIaA      start2 = %timestamp();
CBIaA      exsr CBIWillCallTrk;
CBIaA    endif;

650aA    exsr WrtLogComp;

         // Bye, bye

         return;

      /end-free

     *----------------------------------------------------------------
     *  CheckExportType   Check that export type is Staging
     *----------------------------------------------------------------

      /free
       begsr CheckExportType;

         chain (0: '*FTP') options;

730aD    //if not %found or opftp <> 'S';
730aD      //error = *on;
730aD    //endif;
730aA    Select;
730aA      when not %found;
730aA        error = *on;
730aA      when opftp = 'S' or opftp = 'R';
730aA      other;
730aA      error = *on;
730aA    endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  CheckFlags  Check if transaction has open flags
     *----------------------------------------------------------------

      /free
       begsr CheckFlags;

         setll (ptwhse: $pTrn#) label90;

         dow forever = forever;

           reade (ptwhse: $pTrn#) label90;

           if %eof(label90);
             leave;
           endif;

650aA      blglbl# = lblbl#;

           if lbvrfy = 'F' or lbvrfy = 'I';
             error = *on;
650aA        blgtext = 'Flag (' + lbvrfy + ') exists.';
650aA        exsr WrtLogSkip;
             leave;
           endif;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  CheckMult  Check if transaction is a multiple scan transaction.
     *----------------------------------------------------------------

      /free
       begsr CheckMult;

         chain ($pTrn#) multran1;

         if %found and mustat = '1';
           error = *on;
650aA      blgtext = 'Tran part of multiple scanned tranactions';
650aA      exsr WrtLogSkip;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  CheckTran  Check if transaction is 3=Ended
     *             and must be a selection transaction.
     *----------------------------------------------------------------

      /free
       begsr CheckTran;

         chain ($pTrn#) pirtran;

650aD    //if not %found
650aD    //  or ptstat <> '3';
650aD    //  or (pttask <> 'BULKF'

650aA    select;
650aM      when not %found;
650aA        error = *on;
650aA        blgtext = 'Tran not found.';
650aA        exsr WrtLogSkip;

650aM      when (pttask <> 'BULKF'
             and pttask <> 'BULKP'
             and pttask <> 'FIXED'
             and pttask <> 'PIR');
               error = *on;
650aA          blgtext = 'Not Selection tran. '
650aA                  + 'PTTASK=' + pttask;
650aA          exsr WrtLogSkip;

650aM      when ptstat <> '3';
650aA        error = *on;
650aA        blgtext = 'Tran not ended. Stat is ' + ptstat;
650aA        exsr WrtLogSkip;

650aD    //endif;
650aM    endsl;

       endsr;
      /end-free

CBIaA*----------------------------------------------------------------
CBIaA*  CheckTruck  For Cheney, don't auto close for certain trucks.
CBIaA*----------------------------------------------------------------
CBIaA
CBIaA /free
CBIaA  begsr CheckTruck;

         rhwhse = ptwhse;
         rhrtid = ptrtpo;
         chain(n) (rhwhse: rhrtid) rtehed;

         if not %found;
           error = *on;
650aA      blgtext = 'RTEHED not found for '
650aA              + %char(ptwhse) + '/' + ptrtpo;
650aA      exsr WrtLogSkip;
         else;
           if rhtruk = @MEAT
             or rhtruk = @PPICK
             or rhtruk = @CNTNR
             or rhtruk = @SDSVC;
               error = *on;
650aA          blgtext = 'Skipped because truck is ' + rhtruk;
650aA          exsr WrtLogSkip;
           endif;
         endif;

       endsr;
      /end-free

CBIaA*----------------------------------------------------------------
CBIaA*  CBIWillCallTrk  Try to Close&Export route for WILL-CALL truck.
CBIaA*
CBIaA*           Based on routine zzstat in PT645.
CBIaA*           Did not include code that wasn't for WILL-CALL truck.
CBIaA*           When all transactions have been closed export route
CBIaA*           and changed RTEHED status to '6'.
CBIaA*----------------------------------------------------------------
CBIaA
CBIaA /free
CBIaA  begsr CBIWillCallTrk;
      /end-free
     *
     *  Define partial key for RTEHED file.
     *
     C     keyrh         klist
     C                   kfld                    rhwhse
     C                   kfld                    rhrtid
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    ptwhse
     C                   kfld                    ptgrp2
     C                   kfld                    ptrtpo

520 A*
520 A*  Exit program if route no longer at 4=Printed status.
520 AC     keyrh         chain(n)  rtehed                             79
520 AC                   if        not *in79  and
520 AC                             rhstat <> '4'
650aAC                   eval      expMsg = 'ClsExp not attempted '
650aAC                                    + 'because RHSTAT is '
650aAC                                    + rhstat + ' not 4.'
520 AC                   goto      endsta
520 AC                   endif
416aA*
416aA*  Check in to make sure FTP process isn't running.
416aA*
416aAC                   call      'CHKINOUT'                           49
416aAC                   parm      '*IN'         $xtype            5
416aAC                   parm      'EXPORD'      $xdara           10
416aAC                   if        *in49
650aAC                   eval      expMsg = 'ClsExp not attempted '
650aAC                                    + 'because CHKINOUT could '
650aAC                                    + 'not get lock on EXPORD.'
416aAC                   goto      endsta
416aAC                   endif
     *
     *  Loop through all the transaction for route.
     *
     C                   eval      close = *on
     C     partky        setll     pirtran4
     C                   dow       forevr = forevr
     C     partky        reade     pirtran4                               79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *     If not a selection or letdown record then loop.
     *
     C                   if        p4_ptgrp1 <> 'S'  and
     C                             p4_ptgrp1 <> 'L'
     C                   iter
     C                   endif
     *
     *     If transaction is not closed, we're done.
     *
     C                   if        p4_ptstat < '4'  or
510 AC                             p4_ptstat > '4'
     C                   eval      close = *off
650aAC                   eval      expMsg = 'ClsExp not attempted '
650aAC                                    + 'because tran '
650aAC                                    + %char(p4_pttrn#) + ' '
650aAC                                    + 'is stat ' + p4_ptstat + ' '
650aAC                                    + 'not 4.'
     C                   leave
     C                   endif
     *
     C                   enddo
     *
     *  If all transaction were closed, export and update status.
     *
     C                   if        close = *on
     *
520aA*    Update unique piece number recs' scan qty, file ORDP.
520aA*
520aA*
520aAC                   call      'OR633'
520bMC                   parm      rhwhse        $brwhs
520aAC                   parm                    rhrtid
     *
411 A*  4.11 Notes
     *
     *    The call to RH151 has been left alone, except to include
     *    it in the new select statement. Notice, that RH151 will
     *    never display an error because it does not use $PRTN.
     *
640aAC                   eval      $bcmd = '*HDRDTL'
640aAC                   call      'RH155S'
640aAC                   parm                    $bcmd             8
640aAC                   parm      rhwhse        $brwhs            3 0
640aAC                   parm      rhrtid        $brtid            5
640aAC                   parm      rhrte         $btrte            5
640aAC                   parm      ' '           $brtn             8
     *
     C     keyrh         chain     rtehed                             79
     C                   if        not *in79
     C                   eval      rhstat = '6'
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      'CVTDTE'
     C                   parm                    $cvtdt
     C                   eval      rhstsd = $cvd8o
     C                   time                    rhstst
     C                   update    rhrec
416 A*  Update picked qty, wt, and cube.
416 AC                   call      'CALPCKRTE'
416 AC                   parm                    rhwhse
416 AC                   parm                    rhrtid
     C                   endif
     C                   endif
416aA*
416aA*  Check out so FTP process can run.
416aA*
416aAC                   call      'CHKINOUT'                           49
416aAC                   parm      '*OUT'        $xtype
416aAC                   parm      'EXPORD'      $xdara

650aAC                   eval      expMsg = 'Route closed and exported'
     *
416aAC     endsta        tag
     C                   endsr

650aA*----------------------------------------------------------------
650aA*  wrtLogComp     Write out completion log record
650aA*----------------------------------------------------------------
650aA
650aA /free
650aA  begsr wrtLogComp;

         if not logging;
           leavesr;
         endif;

         blgaddpgm = #pgm;
         blgtype = 'COMP';
         blgcallpgm = '';
         blgcallcmd = '';
         blgwhse = ptwhse;
         blgtrn# = $ptrn#;
         //blglbl# set in CheckFlags routine
         blgrtid = ptrtpo;

         blgaddts = %timestamp();
         blgsec = %diff(blgaddts:blgstrts:*SECONDS);

         blgtext = 'trk:' + %trimr(rhtruk);

         if expMsg <> ' ';
           seconds2 = %diff(blgaddts:start2:*SECONDS);
           blgtext = %trim(blgtext) + ', '
                   +  'expStr:' + %char(start2) + ', '
                   +  'expSec:' + %char(seconds2) + ', '
                   +  'expMsg:' + %trim(expMsg);
         endif;

         blgaddcusr = #curruser;
         blgaddjusr = #user;
         blgaddjob = #job;
         blgaddnbr = #jobnbr;

         write(e) blgrec;

       endsr;
      /end-free

650aA*----------------------------------------------------------------
650aA*  wrtLogSkip    Write out skip log record
650aA*----------------------------------------------------------------
650aA
650aA /free
650aA  begsr wrtLogSkip;

         if not logging;
           leavesr;
         endif;

         blgaddpgm = #pgm;
         blgtype = 'SKIP';
         blgcallpgm = '';
         blgcallcmd = '';
         blgwhse = ptwhse;
         blgtrn# = $ptrn#;
         //blglbl# set in CheckFlags routine
         blgrtid = ptrtpo;

         blgaddts = %timestamp();
         blgsec = %diff(blgaddts:blgstrts:*SECONDS);

         blgtext = 'msg:' + blgtext;

         blgaddcusr = #curruser;
         blgaddjusr = #user;
         blgaddjob = #job;
         blgaddnbr = #jobnbr;

         write(e) blgrec;

       endsr;
      /end-free
