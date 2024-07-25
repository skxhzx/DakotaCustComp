      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  UT756     Remove Label/Pirtran rec if no rec exists in WORKLBL
     *            Only for type S, M, or B
     *  01 September, 1999
     *  Roxanne Harrison
     *
     *  Revisions
640aA*    06/12/12  LMC  6.40a
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
710a *    07/10/17  LMC  7.10a
     *      - Enh: Added sending the transaction generated date to
     *        WRTTRAN1 in order to cleanup the correct transactions.
710b *    07/27/17  LMC  7.10b
     *      - Converted to RPGLE
     *
     *
     *----------------------------------------------------------------
     *
     *  Notes:
     *      - Removes records from files LABEL, PIRTRAN for           L,
     *        LBTYPE = S,M, or B and status = C
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF for FILES
     *
     *----------------------------------------------------------------
     * File Specs
     *
     FLabel     up   e           k disk
     Fpirtran   uf   e           k disk
     Fworklbl   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *                   DESC    1   1 50
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
     D $msgf           s             10
     D $pprg           s             10
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
     *          *ENTRY    PLIST
     *                    PARM           $PPRG  10
     *                    PARM           $PWHSE  3
     *                    PARM           $PDATE  8
     *                    MOVE $PWHSE    $KWHSE  30
     *                    MOVE $PDATE    $KDATE  80
     *----------------------------------------------------------------
     * Main line
     *
     *  Read LABEL file, if no matching record exists in WORKLBL,
     *  Chain to PIRTTAN, if a record is found, delete it, then
     *  delete the LABEL record.
     *
     *  LABEL status must = Closed.
412aAC     lbstat        cabne     'C'           bottom
     *  Process only type S, M or B.
412aAC                   if        lbtype = 'S'  or
412aAC                             lbtype = 'M'  or
412aAC                             lbtype = 'B'
     C     lblbl#        chain     worklbl                            78
     C                   if        *in78
     C     lbtrn#        chain     pirtran                            77
     C                   if        not *in77
     C                   delete    ptrec                                77
640aAC                   exsr      zzwrtt
     C                   endif
     C                   delete    lbrec                                78
     C                   endif
412aAC                   endif
     *
     *
     C     bottom        tag
     *
     CLr                 exsr      zm0750
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
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
     C                   movel     'UT756'       $pprg
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
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
