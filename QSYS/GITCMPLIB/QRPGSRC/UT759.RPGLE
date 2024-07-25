      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  UT759     Remove LABEL & TRANS. rec for old routes left behind
     *  04 April, 2000
     *  Roxanne Harrison
     *
640aA*    06/12/12  LMC  6.40a
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
710a *    07/10/17  LMC  7.10a
     *      - Enh: Added sending the transaction generated date to
     *        WRTTRAN1 in order to cleanup the correct transactions.
710b *    07/27/17  LMC  7.10b
     *      - Converted to RPGLE
     *----------------------------------------------------------------
     *  Notes:
     *    **** Important ****
     *    This program and the programs it calls were developed for
     *    a specific customer and a specific situation.
     *    Please review THIS program to make sure it is suitable
     *    for the customer's needs and situation.
     *
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF for FILES
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fpirtran   up   e           k disk
     FLabel     uf   e           k disk
     FLabel90   if   e           k disk
     F                                     rename(lbrec:record)
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
     *  Variables
     *
     D $kdate          s              8  0
     D $kwhse          s              3  0
     D $msgf           s             10
     D $pprg           s             10
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
     *          *ENTRY    PLIST
     *                    PARM           $PPRG  10
     *                    PARM           $PWHSE  3
     *                    PARM           $PDATE  8
     *                    MOVE $PWHSE    $KWHSE  30
     *                    MOVE $PDATE    $KDATE  80
     *----------------------------------------------------------------
     * Main line
     *
     *  Delete exported LABEL PIRTRAN records.
     C                   exsr      zzlbl
     *
     C                   add       1             errecs
     *
     C     bottom        tag
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
     C                   movel     'UT759'       $pprg
     C                   eval      $kwhse = 1
     C                   eval      $kdate = 20000101
     C                   eval      errecs = 0
     C                   movel     desc(1)       erdesc
     *
     *   Define partial key for LABEL file.
     *
     C     keylb         klist
     C                   kfld                    ptwhse
     C                   kfld                    pttrn#
    D*R                   KFLD           KYRTID
     *
     *
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
     *    ZZLBL   Delete  LABEL/PIRTRAN records.
     *
     C     zzlbl         begsr
     *
     *  Delete dependent LABEL and PIRTRAN records.
     *
     C                   if        ptwhse = $kwhse
     C                   if        ptgdte < $kdate  and
     C                             ptgrp1 = 'S'
     C     keylb         setll     label90                            79
     C                   move      *in79         eof
     C                   dow       eof = *off
     C     keylb         reade     label90                                79
     C                   move      *in79         eof
     C                   if        not *in79
     C     lblbl#        chain     label                              77
     C                   if        not *in77
     C                   delete    lbrec                                77
     C                   endif
     C                   endif
     C                   enddo
     C                   delete    ptrec                                77
640aAC                   exsr      zzwrtt
     C                   endif
     C                   endif
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
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
orphaned route records
