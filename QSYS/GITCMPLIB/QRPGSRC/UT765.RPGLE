     *----------------------------------------------------------------
     *   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------
     *
     *  UT765     Remove records from ALL Transaction files - Post
     *  02 May 2000
     *  Max Blacknik
     *
     *  Notes:
     *    **** Important ****
     *    This program and the programs it calls were developed for
     *    a specific situation.
     *    Please review THIS program to make sure it is suitable
     *    for the customer's needs and situation.
     *    This program uses the Start date, status date or generated
     *    date where possible.  All others warehouse is the only key.
416aA*    03/12/02  RH   4.16a
    A*      - File ORDSLCT changed, Re-compile only.
416bA*    05/24/02  RH   4.16a
    A*      - File LICENSE changed, Re-compile only.
417aA*    07/08/03  RH   4.17a
    A*      - ORDT file changed, Re-compile only.
640aA*    06/12/12  LMC  6.40a
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
650aA*    06/14/13  LMC  6.50a
     *      - ENH: Added CWLOG. This adds a CALL to a new program
     *        CW800 and new file CWLOG.
710a *    07/10/17  LMC  7.10a
     *      - Enh: Added sending the transaction generated date to
     *        WRTTRAN1 in order to cleanup the correct transactions.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF for FILES
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Frtehed    uf   e           k disk
     Frtesum    uf   e           k disk
     Fpltsum1   uf   e           k disk
     Fpltstp1   uf   e           k disk
     Fbatctl2   uf   e           k disk
     FLabel13   uf   e           k disk
     Fworkzon1  uf   e           k disk
     Fworklbl7  uf   e           k disk
     Fpirtran   uf   e           k disk
     Fordh      uf   e           k disk
     Fordd      uf   e           k disk
     Fordc      uf   e           k disk
     Fordt      uf   e           k disk
     Fordslct3  uf   e           k disk
     *
     Fpohdr     uf   e           k disk
     Fpohhdr    uf   e           k disk
     Fpodtl     uf   e           k disk
     Fpohdtl    uf   e           k disk
     FLicense   uf   e           k disk
     Fpomfr     uf   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             50    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  errecs                 1      3p 0
     D  erdesc                 4     48
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
650aA*----------------------------------------------------------------
650aA*  Program info data structure
650aA*
650aAD                sds
650aAD  #prog            *proc
650aAD  #job                 244    253
650aAD  #user                254    263
650aAD  #jobn                264    269
650aAD  #jobdt               276    281  0
650aAD  #jobtm               282    287  0
650aA*----------------------------------------------------------------
650aA*  Called program parameters
650aA*
650aAD $cw800          ds
650aAD  $cwwhs                 1      3  0
650aAD  $cword                 4     10  0
650aAD  $cwseq                11     15  0
650aAD  $cwitm                16     30
650aAD  $cwlbl                31     37  0
650aAD  $cwtrn                38     44  0
650aAD  $cwcsq                45     47  0
650aAD  $cwscn                48    147
650aAD  $cwflg               148    150  0
650aAD  $cwlbs               151    161  3
650aAD  $cwsts               162    162
650aA*----------------------------------------------------------------
650aA*  Called programs
650aA*
     D @cw800          c                   const('CW800 ')
     *----------------------------------------------------------------
     *  Variables
     *
     D $kdate          s              8  0
     D $kwhse          s              3  0
     D $msgf           s             10
     D eof             s              1
     D wpcmd           s             10
     D wpemp#          s              5  0
     D wpfrdt          s              8  0
     D wptodt          s              8  0
     D wptrn#          s              7  0
     D wpwait          s              2  0
     D wpwhse          s              3  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PPRG   - Program to send message back to.
     *      &PWHSE  - Warehouse
     *      &PDATE  - Export date
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *
     C     *entry        plist
     C                   parm                    $pprg            10
     C                   parm                    $pwhse            3
     C                   parm                    $pdate            8
     C                   move      $pwhse        $kwhse
     C                   move      $pdate        $kdate
     *----------------------------------------------------------------
     * Main line
     *
     *  Delete RTEHED Route header records.
     C                   exsr      zzrhed
     *  Delete RTESUM Route summary records.
     C                   exsr      zzrsum
     *  Delete BATCTL records.
     C                   exsr      zzbctl
     *  Delete PLTSTP Pallet stop records.
     C                   exsr      zzpstp
     *  Delete PLTSUM Pallet summary records.
     C                   exsr      zzpsum
     *  Delete WORKZON records.
     C                   exsr      zzwzon
     *  Delete WORKLBL records.
     C                   exsr      zzwlbl
     *  Delete LABEL, PIRTRAN records.
     C                   exsr      zzlbl
     *  Delete ORDH order head records
     C                   exsr      zzordh
     *  Delete ORDD order detail records
     C                   exsr      zzordd
     *  Delete ORDC order catchweight records
     C                   exsr      zzordc
     *  Delete ORDT order transaction detail records
     C                   exsr      zzordt
     *  Delete ORDSLCT order selection detail records
     C                   exsr      zzords
     *  Delete POHDR Purchase order header records
     C                   exsr      zzpoh
     *  Delete PODTL Purchase order detail records
     C                   exsr      zzpod
     *  Delete POHHDR Purchase order history header records
     C                   exsr      zzpohh
     *  Delete POHDTL Purchase order history detail records
     C                   exsr      zzpohd
     *  Delete P/O Mfr date information records.
     C                   exsr      zzmfr
     *  Delete LICENSE Pallet license records.
     C                   exsr      zzlic
     *
     C     bottom        tag
     C                   exsr      zm0750
     C                   eval      *inlr = *on
     *
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      errecs = 0
     C                   movel     desc(1)       erdesc
     *
     C                   endsr
650aA*----------------------------------------------------------------
650aA*  PCWLOG        PROCESS THE CWLOG FILE ADD/UPDATE/DELETE
650aA*----------------------------------------------------------------
650aA*
650aAC     pcwlog        begsr
650aAC                   eval      $cwprg = #prog
650aAC                   eval      $cwwhs = ocwhse
650aAC                   eval      $cwitm = ocitem
650aAC                   eval      $cwtrn = octran
650aAC                   eval      $cwlbl = oclbl#
650aAC                   eval      $cword = ocord
650aAC                   eval      $cwseq = ocseq#
650aAC                   eval      $cwcsq = ocseq
650aAC                   eval      $cwlbs = occwgt
650aAC                   eval      $cwflg = 3
650aA*
650aAC                   call      @cw800
650aAC                   parm                    $cwcmd           10
650aAC                   parm                    $cwprg           10
650aAC                   parm                    $cwrtn           10
650aAC                   parm                    $cwmsg           60
650aAC                   parm                    $cw800
650aAC                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid            7
     C                   parm                    #msgtp            7
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *     PIR0750  Records removed.
     *
     C     zm0750        begsr
     C                   eval      #msgid = 'PIR0750'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZBCTL  Delete BATCTL records.
     *
     C     zzbctl        begsr
     *
     C     $kwhse        setll     batctl2
     C                   eval      eof = *off
     C                   dow       eof = *off
     C     $kwhse        reade     batctl2                                79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    btrec                                78
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZLBL   Delete LABEL/PIRTRAN records.
     *
     C     zzlbl         begsr
     *
     C     $kwhse        setll     label13
     C                   eval      eof = *off
     C                   dow       eof = *off
     C     $kwhse        reade     label13                                79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    lbrec                                78
     C                   endif
     C                   enddo
     *
     C     *loval        setll     pirtran
     C                   eval      eof = *off
     C                   dow       eof = *off
     C                   read      pirtran                                79
     C                   move      *in79         eof
     C                   if        not *in79  and
     C                             ptwhse = $kwhse
     C                   delete    ptrec                                78
640aAC                   exsr      zzwrtt
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZLIC   Delete LICENSE records.
     *
     C     zzlic         begsr
     *
     C     $kwhse        setll     license
     C                   eval      eof = *off
     C                   dow       eof = *off
     C     $kwhse        reade     license                                79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    lirec                                78
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZMFR   Delete P/O Mfr date information records.
     *
     C     zzmfr         begsr
     *
     C     $kwhse        setll     pomfr
     C                   eval      eof = *off
     C                   dow       eof = *off
     C     $kwhse        reade     pomfr                                  79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    pmrec                                78
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZORDC  Delete orphaned ORDC Order catch wt records for order.
     *
     C     zzordc        begsr
     *
     *  Delete exported customer order detail catch weight records.
     *
     C     $kwhse        setll     ordc
     C                   eval      eof = *off
     C                   dow       eof = *off
     C     $kwhse        reade     ordc                                   79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    ocrec                                78
650aAC                   if        not *in78
650aAC                   movel     '*DELETE '    $cwcmd
650aAC                   exsr      pcwlog
650aAC                   endif
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZORDD  Delete ORDD Order detail records.
     *
     C     zzordd        begsr
     *
     C     $kwhse        setll     ordd
     C                   eval      eof = *off
     C                   dow       eof = *off
     C     $kwhse        reade     ordd                                   79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    odrec                                78
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZORDH  Delete ORDH Order head records.
     *
     C     zzordh        begsr
     *
     C     $kwhse        setll     ordh
     C                   eval      eof = *off
     C                   dow       eof = *off
     C     $kwhse        reade     ordh                                   79
     C                   move      *in79         eof
     C                   if        not *in79
     *R         OHSDTE    ANDLT$KDATE
     C                   delete    ohrec                                78
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZORDS  Delete ORDSLCT order selection records.
     *
     C     zzords        begsr
     *
     C     $kwhse        setll     ordslct3
     C                   eval      eof = *off
     C                   dow       eof = *off
     C     $kwhse        reade     ordslct3                               79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    osrec                                78
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZORDT  Delete ORDT Order detail trans records.
     *
     C     zzordt        begsr
     *
     C     $kwhse        setll     ordt
     C                   eval      eof = *off
     C                   dow       eof = *off
     C     $kwhse        reade     ordt                                   79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    otrec                                78
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZPOD   Delete purchase order detail records.
     *
     C     zzpod         begsr
     *
     C     $kwhse        setll     podtl
     C                   eval      eof = *off
     C                   dow       eof = *off
     C     $kwhse        reade     podtl                                  79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    pdrec                                78
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZPOHD  Delete purchase order history detail records.
     *
     C     zzpohd        begsr
     *
     C     $kwhse        setll     pohdtl
     C                   eval      eof = *off
     C                   dow       eof = *off
     C     $kwhse        reade     pohdtl                                 79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    phdrec                               78
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZPOH  Delete purchase order header records.
     *
     C     zzpoh         begsr
     *
     C     $kwhse        setll     pohdr
     C                   eval      eof = *off
     C                   dow       eof = *off
     C     $kwhse        reade     pohdr                                  79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    phrec                                78
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZPOHH  Delete purchase order history header records.
     *
     C     zzpohh        begsr
     *
     C     $kwhse        setll     pohhdr
     C                   eval      eof = *off
     C                   dow       eof = *off
     C     $kwhse        reade     pohhdr                                 79
     C                   move      *in79         eof
     C                   if        not *in79
     *R         PHHEDT    ANDLT$KDATE
     C                   delete    phhrec                               78
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZPSTP  Delete Pallet stop records.
     *
     C     zzpstp        begsr
     *
     C     $kwhse        setll     pltstp1
     C                   eval      eof = *off
     C                   dow       eof = *off
     C     $kwhse        reade     pltstp1                                79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    pssrec                               78
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZPSUM  Delete Pallet summary records.
     *
     C     zzpsum        begsr
     *
     *  Delete Pallet summary records.
     *
     C     $kwhse        setll     pltsum1
     C                   eval      eof = *off
     C                   dow       eof = *off
     C     $kwhse        reade     pltsum1                                79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    psrec                                78
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZRHED  Delete Route header records
     *
     C     zzrhed        begsr
     *
     C     $kwhse        setll     rtehed
     C                   eval      eof = *off
     C                   dow       eof = *off
     C     $kwhse        reade     rtehed                                 79
     C                   move      *in79         eof
     C                   if        not *in79
     *R         RHIMPD    ANDLT$KDATE
     C                   delete    rhrec                                78
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZRSUM  Delete Route summary records.
     *
     C     zzrsum        begsr
     *
     C     $kwhse        setll     rtesum
     C                   eval      eof = *off
     C                   dow       eof = *off
     C     $kwhse        reade     rtesum                                 79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    rsrec                                78
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZWLBL  Delete WORKLBL records.
     *
     C     zzwlbl        begsr
     *
     C     $kwhse        setll     worklbl7
     C                   eval      eof = *off
     C                   dow       eof = *off
     C     $kwhse        reade     worklbl7                               79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    lwrec                                78
     C                   endif
     C                   enddo
     C                   endsr
640aA*----------------------------------------------------------------*********
640aA*
640aA*  ZZWRTT     Execute new WRTTRAN1 program to add/update PIRTRANDn
640aA*
640aAC     zzwrtt        begsr
640aAC                   movel     '*CLEANUP'    wpcmd
640aAC                   eval      wpwait = 0
640aAC                   movel     ptwhse        wpwhse
640aAC                   eval      wptrn# = pttrn#
710aD*                    Z-ADD0         WPFRDT  80
710aMC                   eval      wpfrdt = ptgdte
640aAC                   eval      wptodt = 0
640aAC                   eval      wpemp# = 0
640aAC                   call      'WRTTRAN1'
640aAC                   parm                    wpcmd
640aAC                   parm                    wpwait
640aAC                   parm                    wpwhse
640aAC                   parm                    wptrn#
640aAC                   parm                    wpfrdt
640aAC                   parm                    wptodt
640aAC                   parm                    wpemp#
640aAC                   endsr
     *---------------------------------------------------------------
     *
     *    ZZWZON  Delete WORKZON records
     *
     C     zzwzon        begsr
     *
     C     $kwhse        setll     workzon1
     C                   eval      eof = *off
     C                   dow       eof = *off
     C     $kwhse        reade     workzon1                               79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    zwrec                                78
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
Remove records from ALL Transaction files.
