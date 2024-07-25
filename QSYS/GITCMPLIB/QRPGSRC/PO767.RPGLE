      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PO767     Remove orphaned records left by clear exported PO.
     *  12 April, 2002
     *  Roxanne Harrison
     *
     *  Note:
     *      - Warehouse # is hard coded.  This is a utilitiy program.
     *  Revisions
640aA*    06/12/12  LMC  6.40a
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
710a *    07/10/17  LMC  7.10a
     *      - Enh: Added sending the transaction generated date to
     *        WRTTRAN1 in order to cleanup the correct transactions.
     *
710b *    07/27/17  LMC  7.10b
     *      - Converted to RPGLE
     *
     *
     *----------------------------------------------------------------
     * Indicators
     *
218 M*  79        - EOF for POHHDR
     *
     *----------------------------------------------------------------
     * File Specs
     *
     FLabel10   uf   e           k disk
     Fpirtran   uf   e           k disk
     FLicense1  uf   e           k disk
     Fpomfr     uf   e           k disk
     Fporcv     uf   e           k disk
     Fpohhdr    if   e           k disk
     Fpohdr     if   e           k disk
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
     *----------------------------------------------------------------
     *  variables
     *
     *----------------------------------------------------------------
     D $msgf           s             10
     D $pprg           s             10
     D eflag           s              1
     D eof             s              1
     D forevr          s              1
     D kypo            s                   like(lbpo)
     D kywhse          s              3  0
     D wpcmd           s             10
     D wpemp#          s              5  0
     D wpfrdt          s              8  0
     D wptodt          s              8  0
     D wptrn#          s              7  0
     D wpwait          s              2  0
     D wpwhse          s              3  0
     D wrk1            s              6
     D wrk2            s              4
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
     *          *ENTRY    PLIST
     *                    PARM           $PPRG  10
     *                    PARM           $PWHSE  3
     *                    PARM           $PDATE  8
     *                    MOVE $PWHSE    $KWHSE  30
     *----------------------------------------------------------------
     * Main line
     *
     *  Read label to get PO #.
     *
     C     nxtpo         tag
     C     keypo         setll     label10
     C     nxt1          tag
     C                   read      label10                                76
     C     *in76         cabeq     *on           bottom
     C                   if        lbwhse <> kywhse  or
     C                             lbtype <> 'P'  or
     C                             lbpo = ' '  or
     C                             lbpo = '*NOSTOCK'
     C                   goto      nxt1
     C                   endif
     C                   eval      kypo = lbpo
     C     keypo         setll     pohhdr
     C     keypo         reade     pohhdr                                 75
     C                   if        not *in75
     C                   goto      nxt1
     C                   endif
     C     keypo         setll     pohdr
     C     keypo         reade     pohdr                                  74
     C                   if        not *in74
     C                   goto      nxt1
     C                   endif
     **                   MOVE LBPO      KYPO
     *
     *  Delete exported label records and transactions.
     C                   exsr      zzlabl
     C     eflag         cabeq     *on           bottom
     *
     *  Delete P/O Mfr date information records.
     C                   exsr      zzmfr
     C     eflag         cabeq     *on           bottom
     *
     *  Delete P/O Receiving information records.
     C                   exsr      zzrcv
     C     eflag         cabeq     *on           bottom
     *
     *
     *  Loop to read next po#
     *
     C                   goto      nxtpo
     *
     C     bottom        tag
     *
     *                    EXSR ZM0750
640aAC                   exsr      zzwrtl
     C                   return
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
     C                   eval      eflag = *off
     C                   eval      forevr = *off
     *
     *   Define partial key for LABEL file.
     *
     C     keypo         klist
     C                   kfld                    kywhse
     C                   kfld                    kypo
     *
     *   Define key for LICENSE file.
     *
     C     keylcn        klist
     C                   kfld                    lbwhse
     C                   kfld                    lbtrn#
     *
     C                   eval      kywhse = 900
     C                   eval      kypo = *blanks
     *
     C                   endsr
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
     C                   movel     'PO767'       $pprg
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
     *    ZZLABL  Delete exported Label records for PO.
     *            Delete dependent PIRTRAN and LICENSE records for label.
     *
     C     zzlabl        begsr
     *
     C                   eval      eflag = *off
     C     keypo         setll     label10
     C                   eval      eof = *off
     C                   dow       eof = *off
     C     keypo         reade     label10                                79
     C                   move      *in79         eof
     C                   if        not *in79
     C     keylcn        chain     license1                           77
     C                   if        not *in77
     C                   delete    lirec                                77
     C                   if        *in77
     C                   move      *in77         eflag
     C                   endif
     C                   endif
     C     eflag         cabeq     *on           endlb
     C     lbtrn#        setll     pirtran
     C                   dow       forevr = forevr
     C     lbtrn#        reade     pirtran                                77
     C                   if        not *in77
     C                   delete    ptrec                                77
640aAC                   exsr      zzwrtt
     C                   if        *in77
     C                   move      *in77         eflag
     C                   endif
     C                   else
     C                   leave                                                  Exit loop.
     C                   endif
     C                   enddo
     C     eflag         cabeq     *on           endlb
     C                   delete    lbrec                                78
     C                   if        *in78
     C                   move      *in78         eflag
     C                   endif
     C                   endif
     C                   enddo
     C     endlb         endsr
     *
     *---------------------------------------------------------------
     *
     *    ZZMFR   Delete P/O Mfr date information records.
     *
     C     zzmfr         begsr
     *
     *  Delete P/O Mfr date information records.
     *
     C     keypo         setll     pomfr
     C                   eval      eof = *off
     C                   dow       eof = *off
     C     keypo         reade     pomfr                                  79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   delete    pmrec                                78
     C                   if        *in78
     C                   move      *in78         eflag
     C                   endif
     C                   endif
     C                   enddo
     C                   endsr
     *---------------------------------------------------------------
     *
     *    ZZRCV   Delete P/O Receiving information records.
     *
     C     zzrcv         begsr
     *
     *  Delete P/O Mfr date information records.
     *
     C     keypo         setll     porcv
     C                   eval      eof = *off
     C                   dow       eof = *off
     C     keypo         reade     porcv                                  79
     C                   move      *in79         eof
     C                   if        not *in79
     **         PORDTE    ANDLT$KDATE
     C                   delete    porrec                               78
     C                   if        *in78
     C                   move      *in78         eflag
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
640aA*----------------------------------------------------------------*********
640aA*
640aA*  ZZWRTL     Execute new WRTTRAN1 program to clean LOGTRAND     n
640aA*
640aAC     zzwrtl        begsr
640aAC                   eval      wrk1 = '*CLEAN'
640aAC                   eval      wrk2 = 'LOG '
640aAC                   move      wrk2          wpcmd
640aAC                   movel     wrk1          wpcmd
640aAC                   eval      wpwait = 0
640aAC                   eval      wpwhse = kywhse
640aAC                   movel     0             wptrn#
640aAC                   eval      wpfrdt = 0
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
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
exported purchase orders
