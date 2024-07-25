      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  UT758     Remove rec for old routes left behind
     *  08 October, 1999
     *  Roxanne Harrison
     *
     *----------------------------------------------------------------
     *  Notes:
     *    **** Important ****
     *    This program and the programs it calls were developed for
     *    a specific customer and a specific situation.
     *    Please review THIS program to make sure it is suitable
     *    for the customer's needs and situation.
     *
     *  This program doesn't remove PIRTRAN or LABEL records,
     *  Orphaned records have no RTEHED record, RTEHED was previously
     *  cleared in error.
     *  UT758 was created for North Farm, can be customized to
     *  clear any necessary files for a orphaned routes.
416aA*    03/12/02  RH   4.16a
    A*      - File ORDSLCT changed, Re-compile only.
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
710b *    07/27/17  LMC  7.10b
     *      - Converted to RPGLE
     *
740 A*    07/09/20  MLB  7.40
     *      - Fix: Revised routine ZZORDH to set EOF flag off after
     *        each cleanup routine is executed.
740aA*    07/09/20  MLB  7.40a
     *      - Fix: Revised pgm to add file RTECSUM to cleanup.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF for FILES
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Frtehed    if   e           k disk
     Frtesum    uf   e           k disk
740aAFrtecsum   uf   e           k disk
     Fpltsum1   uf   e           k disk
     Fpltstp1   uf   e           k disk
     Fbatctl2   uf   e           k disk
     Fworkzon1  uf   e           k disk
     Fworklbl7  uf   e           k disk
     FLabel     uf   e           k disk
     FLabel8    if   e           k disk
     Fpirtran   uf   e           k disk
     Fordh3     uf   e           k disk
     Fordd      uf   e           k disk
     Fordc      uf   e           k disk
     Fordt      uf   e           k disk
     Fordslct3  uf   e           k disk
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
     *  variables
     *
     D $kdate          s              8  0
     D $kwhse          s              3  0
     D $msgf           s             10
     D eflag           s              1
     D eof             s              1
     D kyrtid          s                   like(rsrtid)
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
     *  Although the following conditions are tested by open query
     *  in the preceding CL program, this is tested here again for
     *  additional safety.
     *
    D*          RHWHSE    IFNE $KWHSE
    D*          RHEXPD    ORGE $KDATE
    D*                    GOTO BOTTOM
    D*                    ENDIF
     *  Delete orphaned Route summary records.
     C                   exsr      zzrsum
740aA*  Delete orphaned Route Comp summary records.
740aAC                   exsr      zzrcsum
     *  Delete orphaned BATCTL records.
     C                   exsr      zzbctl
     *  Delete orphaned Pallet stop records.
     C                   exsr      zzpstp
     *  Delete orphaned Pallet summary records.
     C                   exsr      zzpsum
     *  Delete orphaned WORKZON records.
     C                   exsr      zzwzon
     *  Delete orphaned WORKLBL records.
     C                   exsr      zzwlbl
     *  Delete exported LABEL PIRTRAN records.
413AD*                    EXSR ZZLBL
     *  Delete orphaned ORDH order head records
     C                   exsr      zzordh
     *
     C                   add       1             errecs
     *
     C     bottom        tag
     C                   exsr      zm0750
     C                   return
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
     *   Define partial key for RTESUM, PLTSUM,PLTSTP file.
     *
     C     keyrs         klist
     C                   kfld                    $kwhse
    D*R                   KFLD           KYRTID
     *
     *   Define key for RTEHED file.
     *
     C     keyrh         klist
     C                   kfld                    $kwhse
     C                   kfld                    kyrtid
     *
     *   Define partial key for ORDD file.
     *
     C     keyod         klist
     C                   kfld                    ohwhse
     C                   kfld                    ohord
     *
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
     *    ZZBCTL  Delete exported BATCTL records for route id.
     *
     C     zzbctl        begsr
     *
     *  Delete exported BATCTL records.
     *
     C     keyrs         setll     batctl2                            79
     C                   move      *in79         eof
     C                   dow       eof = *off
     C     keyrs         reade     batctl2                                79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   eval      kyrtid = btrte
     C     keyrh         chain     rtehed                             77
     C                   if        *in77
     C                   delete    btrec                                78
     C                   endif
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZLBL   Delete exported LABEL/PIRTRAN records for route id.
     *
     C     zzlbl         begsr
     *
     *  Delete dependent LABEL and PIRTRAN records.
     *
     C     keyrs         setll     label8                             79
     C                   move      *in79         eof
     C                   dow       eof = *off
     C     keyrs         reade     label8                                 79
     C                   move      *in79         eof
     C                   if        not *in79
     C     l8lbl#        chain     label                              77
     C                   if        not *in77
     C                   delete    lbrec                                77
     C                   endif
     C     l8trn#        chain     pirtran                            77
     C                   if        not *in77
     C                   delete    ptrec                                77
640aAC                   exsr      zzwrtt
     C                   endif
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
     C     keyod         setll     ordc                               79
     C                   move      *in79         eof
     C                   dow       eof = *off
     C     keyod         reade     ordc                                   79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    ocrec                                78
     C                   move      *in78         eflag
650aAC                   if        eflag = '0'
650aAC                   movel     '*DELETE '    $cwcmd
650aAC                   exsr      pcwlog
650aAC                   endif
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZORDD  Delete orphaned ORDD Order detail records for route id.
     *
     C     zzordd        begsr
     *
     *  Delete exported customer order detail records.
     *
     C     keyod         setll     ordd                               79
     C                   move      *in79         eof
     C                   dow       eof = *off
     C     keyod         reade     ordd                                   79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    odrec                                78
     C                   move      *in78         eflag
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZORDH  Delete orphaned ORDH Order head records for route id.
     *
     C     zzordh        begsr
     *
     *  Delete exported Order head records.
     *
     C     keyrs         setll     ordh3                              79
     C                   move      *in79         eof
     C                   dow       eof = *off
     C     keyrs         reade     ordh3                                  79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   eval      eflag = *off
     C                   eval      kyrtid = ohrte
     C     keyrh         chain     rtehed                             77
     C                   if        *in77
     C                   exsr      zzordd
740 AC                   eval      eof = *off
     C                   exsr      zzordc
740 AC                   eval      eof = *off
     C                   exsr      zzordt
740 AC                   eval      eof = *off
410 AC                   exsr      zzords
740 AC                   eval      eof = *off
     C                   if        eflag = *off
     C                   delete    ohrec                                78
     C                   endif
     C                   endif
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZORDS  Delete orphaned ORDSLCT order selection records for order.
     *
     C     zzords        begsr
     *
     *  Delete exported order selection records.
     *
     C     keyod         setll     ordslct3                           79
     C                   move      *in79         eof
     C                   dow       eof = *off
     C     keyod         reade     ordslct3                               79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    osrec                                78
     C                   move      *in78         eflag
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZORDT  Delete orphaned ORDT Order detail trans records for order.
     *
     C     zzordt        begsr
     *
     *  Delete exported customer order detail transaction records.
     *
     C     keyod         setll     ordt                               79
     C                   move      *in79         eof
     C                   dow       eof = *off
     C     keyod         reade     ordt                                   79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    otrec                                78
     C                   move      *in78         eflag
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZPSTP  Delete orphaned Pallet stop records for route id.
     *
     C     zzpstp        begsr
     *
     *  Delete orphaned Pallet stop records.
     *
     C     keyrs         setll     pltstp1                            79
     C                   move      *in79         eof
     C                   dow       eof = *off
     C     keyrs         reade     pltstp1                                79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   eval      kyrtid = pssrid
     C     keyrh         chain     rtehed                             77
     C                   if        *in77
     C                   delete    pssrec                               78
     C                   endif
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZPSUM  Delete orphaned Pallet summary records for route id.
     *
     C     zzpsum        begsr
     *
     *  Delete orphaned Pallet summary records.
     *
     C     keyrs         setll     pltsum1                            79
     C                   move      *in79         eof
     C                   dow       eof = *off
     C     keyrs         reade     pltsum1                                79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   eval      kyrtid = psrtid
     C     keyrh         chain     rtehed                             77
     C                   if        *in77
     C                   delete    psrec                                78
     C                   endif
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZRSUM  Delete Route summary records if no record in RTEHED.
     *
     C     zzrsum        begsr
     *
     *  Delete orphaned Route summary records.
     *
     C     keyrs         setll     rtesum                             79
     C                   move      *in79         eof
     C                   dow       eof = *off
     C     keyrs         reade     rtesum                                 79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   eval      kyrtid = rsrtid
     C     keyrh         chain     rtehed                             77
     C                   if        *in77
     C                   delete    rsrec                                78
     C                   endif
     C                   endif
     C                   enddo
     C                   endsr
740Aa*
740aA*---------------------------------------------------------------
740aA*
740aA*    ZZRCSUM  Delete Route Comp summary records if no rcd in RTEHED.
740aA*
740aAC     zzrcsum       begsr
740aA*
740aA*  Delete orphaned Route summary records.
740aA*
740aAC     keyrs         setll     rtecsum                            79
740aAC                   move      *in79         eof
740aAC                   dow       eof = *off
740aAC     keyrs         reade     rtecsum                                79
740aAC                   move      *in79         eof
740aAC                   if        not *in79
740aAC                   eval      kyrtid = rcrtid
740aAC     keyrh         chain     rtehed                             77
740aAC                   if        *in77
740aAC                   delete    rcrec                                78
740aAC                   endif
740aAC                   endif
740aAC                   enddo
740Aa*
740aAC                   endsr
740Aa*
     *---------------------------------------------------------------
     *
     *    ZZWLBL  Delete orphaned WORKLBL records for route id.
     *
     C     zzwlbl        begsr
     *
     *  Delete orphaned WORKLBL records.
     *
     C     keyrs         setll     worklbl7                           79
     C                   move      *in79         eof
     C                   dow       eof = *off
     C     keyrs         reade     worklbl7                               79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   eval      kyrtid = lwrte
     C     keyrh         chain     rtehed                             77
     C                   if        *in77
     C                   delete    lwrec                                78
     C                   endif
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
     *    ZZWZON  Delete orphaned WORKZON records for route id.
     *
     C     zzwzon        begsr
     *
     *  Delete exported WORKZON records.
     *
     C     keyrs         setll     workzon1                           79
     C                   move      *in79         eof
     C                   dow       eof = *off
     C     keyrs         reade     workzon1                               79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   eval      kyrtid = zwrtid
     C     keyrh         chain     rtehed                             77
     C                   if        *in77
     C                   delete    zwrec                                78
     C                   endif
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
orphaned route records
