     H/copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------
     *
     *  OR765     Remove exported customer returns - Post
     *  11 November, 1994
     *  Dave Sommerville
     *  Hemant Kapadia
     *
     *  Revisions
     *
530  *    10/22/09  GJA  5.30
     *      - Cleaned up and converted to RPGLE.
     *
650a *    05/29/13  LMC  6.50a
     *      - added cleanup for new RCVRTN transaction.
710a *    07/10/17  LMC  7.10a
     *      - Enh: Added sending the transaction generated date to
     *        WRTTRAN1 in order to cleanup the correct transactions.
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF for ORRTN
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Forrtn     up   e           k disk
650aAFpirtran5  uf   e           k disk    rename(ptrec:ptrec5)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             50    dim(1) ctdata perrcd(1)
650aA*----------------------------------------------------------------
650aA*  Prototypes
650aA*----------------------------------------------------------------
650aA
650aAD wrttran1        pr                  extpgm('WRTTRAN1')
650aA * Input
650aAD   ppcmd                        8
650aAD   ppwait                       2  0
650aAD   ppwhse                       3  0
650aAD   pptran#                      7  0
650aAD   ppfromdate                   8  0
650aAD   pptodate                     8  0
650aAD   ppemp#                       5  0
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
650aAD wrtpcmd         s             10
650aAD wrtpwait        s              2  0
650aAD wrtpwhse        s              3  0
650aAD wrtptran#       s                   like(pttrn#)
650aAD wrtpfrmdate     s              8  0
650aAD wrtptodate      s              8  0
650aAd wrtpemp#        s                   like(ptemp#)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PPRG    - Program to send message back to.
     *      &PWHSE   - Warehouse
     *      &PDATE   - Export date
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
     C                   if        orwhse <> $kwhse  or
     C                             orudte >= $kdate  and
     C                             orudte > *zeros
     C                   goto      bottom
     C                   endif
     *
     *  Delete exported item adjustments records.
     *
     C                   add       1             errecs
     C                   delete    orrec                                79
     *
     C     bottom        tag
     *
     CLr                 exsr      zm0750
650aA *  Delete RCVRTN transactions.
650aAClr                 move      $pwhse        $kwhse
650aAClr                 move      $pdate        $kdate
650aAClr                 exsr      zzrcvrtn
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
     C                   eval      errecs = 0
     C                   movel     desc(1)       erdesc
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
650aAC*---------------------------------------------------------------
650aAC*
650aAC*    ZZRCVRTN Delete RCVRTN transactions.
650aAC*
650aA /free
650aA    begsr zzrcvrtn;
650aA      setll ($kwhse) pirtran5;
650aA      dow not %eof(pirtran5);
650aA        reade ($kwhse) pirtran5;
650aA        if %eof(pirtran5);
650aA          leave;
650aA        endif;
650aA        if ptgdte >= $kdate;
650aA          leave;
650aA        endif;
650aA        if ptgrp1 <> 'R';
650aA          iter;
650aA        endif;
650aA        if pttask <> 'RCVRTN';
650aA          iter;
650aA        endif;
650aA        delete ptrec5;
650aA        exsr zzwrttrand;
650aA      enddo;
650aA    endsr;
650aA /end-free
650aA
650aA*----------------------------------------------------------------*********
650aA*
650aA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
650aA*
650aA /free
650aA   begsr zzwrttrand;
650aA     wrtpcmd = '*CLEANUP';
650aA     wrtpwait = 0;
650aA     wrtpwhse = ptwhse;
650aA     wrtptran# = pttrn#;
710aD     //wrtpfrmdate = 0;
710aM     wrtpfrmdate = ptgdte;
650aA     wrtptodate = 0;
650aA     wrtpemp# = 0;
650aA
650aA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
650aA               wrtpfrmdate: wrtptodate: wrtpemp#);
650aA   endsr;
650aA /end-free
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
exported order returns
