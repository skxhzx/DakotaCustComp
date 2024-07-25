     H/copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PT785     Remove Misc. PIRTRAN/BATCTL records - Post
     *  21 April 2000
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
416 A*    04/08/02  MLB  4.16
     *      - Revised pgm to correct standard task code spelling.
416aA*    04/10/02  MLB  4.16a
     *      - Revised pgm to add VERIFY to cleanup
     *
510 A*    09/13/06  MLB  5.10
     *      - Enh: Revised pgm to add RUNNER to cleanup.
520aA*    10/10/07  LMC  5.20a P#00023
     *      - Enh: Added purging to history files instead of just
     *             deleting the records
     *             NOTE - if this is moved to client site, make sure
     *             positions 33-35 of opdata in options is initilized.
520bA*    05/14/08  GJA  5.20b P#00023
     *      - Enh: Added getting history option
520cA*    11/11/08  GJA  5.20c
     *      - Enh: Added PUTSTG transaction
520dA*    11/24/08  GJA  5.20d
     *      - Enh: Added LICENSE clean up to all selections
640aA*    01/11/12  LMC  6.40a
     *      - Enh: Added LICinfo clean up to the LICENSE logic
     *      - Fix: add check for active license before moving to history
640b *    01/18/12  LMC  6.40b
     *      - Fix: added logic to check to make sure liclog records
     *        don't exist before removing licinfo records
640c *    10/16/12  LMC  6.40c
     *      - NOTE: THIS MOD SHOULD ONLY BE APPLIED IF THE CLIENT HAS
     *        THE NEW LICINFO FILE. Key for licinfo1 has changed.
     *        LICINFO1 had lncode as a key field, and the field does not
     *        exist in the new file.
640dA*    06/12/12  LMC  6.40d
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
650aA*    03/18/13  LMC  6.50a
     *      - Enh: Added cleanup for TFRMOV.
700aA*    04/12/16  LMC  7.00a
     *      - Moved the move to populate $kwhse into the inzsr
     *        routine. If no records exist in the file, the cycle
     *        hits LR, and executes the wrttran log cleanup but sends
     *        warehouse 0. This causes a BFCWTD000 job to be started
     *        on the clients box.
710a *    07/10/17  LMC  7.10a
     *      - Enh: Added sending the transaction generated date to
     *        WRTTRAN1 in order to cleanup the correct transactions.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  78        - NRF for TASK
     *  79        - EOF for PIRTRAN
     *  79        - EOF for BATCTL3
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fpirtran   up   e             disk
     Fbatctl3   uf   e           k disk
     Ftask      if   e           k disk
520aAFpirtranh  o  a e             disk
     F                                     rename(ptrec:ptrech)
520bAFoptions   if   e           k disk
520cAFlicense1  uf   e           k disk
520cAFlicenseh  o  a e             disk
     F                                     rename(lirec:lirech)
640aAFlicactive if   e           k disk
640aAflicactive6if   e           k disk    rename(larec:lareco) prefix(b_)
640aAflicinfo1  if   e           k disk    rename(lnrec:lnrec1) prefix(a_)
640aAflicinfo2  uf   e           k disk
640bAFliclog    if   e           k disk
640bAFliclog1   if   e           k disk    rename(llrec:llrec1)
640aAFlicinfoh  o  a e             disk    rename(lnhrec:lnrech)
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
640dA*----------------------------------------------------------------
640dA*  Prototypes
640dA*----------------------------------------------------------------
640dA
640dAD wrttran1        pr                  extpgm('WRTTRAN1')
640dA * Input
640dAD   ppcmd                        8
640dAD   ppwait                       2  0
640dAD   ppwhse                       3  0
640dAD   pptran#                      7  0
640dAD   ppfromdate                   8  0
640dAD   pptodate                     8  0
640dAD   ppemp#                       5  0
520bA*----------------------------------------------------------------
520bA*  *SYSTEM  -  System options.
520bA*----------------------------------------------------------------
520bA*
520bA* Fields
520bA*
520bA*    OPEPM   -  Using EPM module (Y,N).
520bA*    OPRF    -  Using RF module (Y,N).
520bA*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
520bA*    OPLETD  -  Print letdown labels (Y,N).
520bA*    OPWRNC  -  Perform catch weight variance check (Y,N).
520bA*    OPRG1C  -  Catch weight low variance percentage.
520bA*    OPRG2C  -  Catch weight high variance percentage.
520bA*    OPIMPI  -  Import Item fields (Y,N).
520bA*    OPICW   -  Individual catch weight entry (Y,N).
520bA*    OPMPCK  -  Allow multiple pick slots for fixed items (Y/N).
520bA*    OPRCDY  -  Number of days to keep receiving logs.
520bA*    OPMPCK  -  Number of days to keep picking logs.
520bA*    OPRTHS  -  Number of weeks - exported routes to keep.
520bA*    OPCRHS  -  Number of weeks - exported customer rtns to keep.
520bA*    OPPOHS  -  Number of weeks - exported p/o's to keep.
520bA*    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
520bA*    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
520bA*    OPISHS  -  Number of weeks - extra history files to keep.
520bA*
520bA* Data structure
520bA*
520bAD opdata          ds
520bAD  opepm                  1      1
520bAD  oprf                   2      2
520bAD  opcapc                 3      3
520bAD  opletd                 4      4
520bAD  opwrnc                 5      5
520bAD  oprg1c                 6      8  1
520bAD  oprg2c                 9     11  1
520bAD  opimpi                12     12
520bAD  opicw                 13     13
520bAD  opmpck                14     14
520bAD  oprcdy                15     15  0
520bAD  oppkdy                16     16  0
520bAD  oprths                17     19  0
520bAD  opcrhs                20     22  0
520bAD  oppohs                23     25  0
520bAD  opiahs                26     28  0
520bAD  opmshs                29     31  0
520bAD  opishs                33     35  0
520bAD  optend               117    117
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *-----VARIABLES--------------------------------------------------
     D $kdate          s              8  0
     D $kwhse          s              3  0
     D $msgf           s             10
     D forevr          s              1
     D kytype          s                   like(bttype)
520bAd kycode          s                   like(opcode)
520bAd kywhse          s                   like(opwhse)
640cDd*kylicinfo1      s                   like(lncode)
640cDd*kylicinfotrn#   s                   like(lnvalue)
640aAd activelicense   s              1
640aAd foundlicense    s              1
640aAd keylcns         s                   like(lilcns)
640dAD wrtpcmd         s             10
640dAD wrtpwait        s              2  0
640dAD wrtpwhse        s              3  0
640dAD wrtptran#       s                   like(pttrn#)
640dAD wrtpfrmdate     s              8  0
640dAD wrtptodate      s              8  0
640dAd wrtpemp#        s                   like(ptemp#)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PPRG   - Program to send message back to.
     *      $PWHSE  - Warehouse
     *      $PDATE  - Export date
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
700aDC*                  move      $pwhse        $kwhse
     C                   move      $pdate        $kdate
     *----------------------------------------------------------------
     * Main line
     *
     *  Although the following conditions are tested by open query
     *  in the preceding CL program, this is tested here again for
     *  additional safety.
     *
     C                   if        ptwhse <> $kwhse  or
     C                             ptgdte >= $kdate
     C                   goto      bottom
     C                   endif
     *
     *    Delete STD EPM transaction records.
     *
     C                   select
     C                   when      pttask = 'IDLE    '  or
     C                             pttask = 'BIDLE   '  or
416 D*          PTTASK    OREQ 'BEDDAY  '
416 MC                             pttask = 'BEGDAY  '  or
     C                             pttask = 'ENDDAY  '  or
416aAC                             pttask = 'VERIFY  '  or
510 AC                             pttask = 'RUNNER  '
     C                   add       1             errecs
520bA* ONLY WRITE HISTORY IF ADDITIONAL HISTORY IS SET IN OPTIONS
520bAC                   if        opishs <> 0
520aAC                   write     ptrech
520bAC                   endif
     C                   delete    ptrec                                79
640dA * This is only executed if no extended history is kept
640dAc                   if        opishs = 0
640dAc                   exsr      zzwrttrand
640dAc                   endif
     *
520cAC                   when      pttask = 'PUTSTG'  and
520cAC                             ptrtpo = *blanks
640aA* Check for active license on PUTSTG before moving to history
640aAc                   eval      activelicense = *off
640aAc                   exsr      chkactlicense
640aA
640aAc                   if        activelicense  = *off
520cAC     keyli         chain     license1
520cAC                   if        %found(license1)

640bAc     keyln         chain     liclog
640bAc     keyln         chain     liclog1
640bAc                   if        not %found(liclog)  and
640bAc                             not %found(liclog1)
640aAC     keyln         setll     licinfo2
640aAc     *in74         doweq     *off
640aAc     keyln         reade     licinfo2                               74
640aAc                   if        not *in74
640aA * Only write history if additional history is set in options
640aAC                   if        opishs <> 0
640aAC                   write     lnrech
640aAC                   endif
640aAc                   delete    lnrec                                73
640aAc                   endif
640aAc                   enddo
640bAc                   endif

520bA* ONLY WRITE HISTORY IF ADDITIONAL HISTORY IS SET IN OPTIONS
520cAC                   if        opishs <> 0
520cAC                   write     lirech
520cAC                   endif
520cAC                   delete    lirec                                79
640aAc                   else
640aA* license not found check licinfo for orphans
640aA * if no license record is found check the licinfo1 file for
640aA * license info code *RCVTRN# move to history if license is no
640aA * longer active
640cDc*                  eval      kylicinfo1 = '*RCVTRN#'
640cDC*                  eval      kylicinfotrn# =   %char(pttrn#)
640aAc     keylcninfo1   chain     licinfo1
640aAc                   if        %found(licinfo1)
640aAc                   eval      *in76 = *off
640bAc     keylnorphan   chain     liclog
640bAc     keylnorphan   chain     liclog1
640bAc                   if        not %found(liclog) and
640bAc                             not %found(liclog1)
640aAc     keylnorphan   setll     licinfo2
640aAc     forevr        doweq     forevr
640aAc     keylnorphan   reade     licinfo2                               76
640aAc     *in76         ifeq      *on
640aAc                   leave
640aAc                   endif
640aAc     *in76         ifeq      *off
640aA * Only write history if additional history is set in options
640aAC                   if        opishs <> 0
640aAC                   write     lnrech
640aAC                   endif
640aAc                   delete    lnrec                                77
640aAc                   endif
640aAc                   enddo
640aAc                   endif
640aAc                   endif
520cAC                   endif

520cAC                   if        opishs <> 0
520cAC                   write     ptrech
520cAC                   endif
520cAC                   delete    ptrec                                79
640dA * This is only executed if no extended history is kept
640dAc                   if        opishs = 0
640dAc                   exsr      zzwrttrand
640dAc                   endif
640aAc                   endif
650aAC                   when      pttask = 'TFRMOV'
650aA* Check for active license on PUTSTG before moving to history
650aAc                   eval      activelicense = *off
650aAc                   exsr      chkactlicense
650aA
650aAc                   if        activelicense  = *off
650aAC     keyli         chain     license1
650aAC                   if        %found(license1)

650aAc     keyln         chain     liclog
650aAc     keyln         chain     liclog1
650aAc                   if        not %found(liclog)  and
650aAc                             not %found(liclog1)
650aAC     keyln         setll     licinfo2
650aAc     *in74         doweq     *off
650aAc     keyln         reade     licinfo2                               74
650aAc                   if        not *in74
650aA * Only write history if additional history is set in options
650aAC                   if        opishs <> 0
650aAC                   write     lnrech
650aAC                   endif
650aAc                   delete    lnrec                                73
650aAc                   endif
650aAc                   enddo
650aAc                   endif

650aA* ONLY WRITE HISTORY IF ADDITIONAL HISTORY IS SET IN OPTIONS
650aAC                   if        opishs <> 0
650aAC                   write     lirech
650aAC                   endif
650aAC                   delete    lirec                                79
650aAc                   else
650aA* license not found check licinfo for orphans
650aA * if no license record is found check the licinfo1 file for
650aA * license info code *RCVTRN# move to history if license is no
650aA * longer active
650aDc*                  eval      kylicinfo1 = '*RCVTRN#'
650aDC*                  eval      kylicinfotrn# =   %char(pttrn#)
650aAc     keylcninfo1   chain     licinfo1
650aAc                   if        %found(licinfo1)
650alc                   eval      *in76 = *off
650aAc     keylnorphan   chain     liclog
650aAc     keylnorphan   chain     liclog1
650aAc                   if        not %found(liclog) and
650aAc                             not %found(liclog1)
650aAc     keylnorphan   setll     licinfo2
650aAc     forevr        doweq     forevr
650aAc     keylnorphan   reade     licinfo2                               76
650aAc     *in76         ifeq      *on
650aAc                   leave
650aAc                   endif
650aAc     *in76         ifeq      *off
650aA * Only write history if additional history is set in options
650aAC                   if        opishs <> 0
650aAC                   write     lnrech
650aAC                   endif
650aAc                   delete    lnrec                                77
650aAc                   endif
650aAc                   enddo
650aAc                   endif
650aAc                   endif
650aAC                   endif

650aAC                   if        opishs <> 0
650aAC                   write     ptrech
650aAC                   endif
650aAC                   delete    ptrec                                79
650aA * This is only executed if no extended history is kept
650aAc                   if        opishs = 0
650aAc                   exsr      zzwrttrand
650aAc                   endif
650aAc                   endif
     *
     *    Remove any indirect tasks.
     *
     C                   other
     *
     C     pttask        chain     task                               78
     *
     *    If task master record not found or is a indirect
     *    task delete transaction from file or direct
     *    non-standard task, remove transaction from file.
     *
     C                   if        *in78  or
     *
     C                             not *in78  and
     C                             tktype = 'I'  or
     *
     C                             not *in78  and
     C                             tktype = 'D'  and
     C                             tkstd = 'N'
     *
     C                   add       1             errecs
520aA* ONLY WRITE HISTORY IF ADDITIONAL HISTORY IS SET IN OPTIONS
520bAC                   if        opishs <> 0
520aAC                   write     ptrech
520aAC                   endif
     C                   delete    ptrec                                79
640dA * This is only executed if no extended history is kept
640dAc                   if        opishs = 0
640dAc                   exsr      zzwrttrand
640dAC                   endif
     C                   endif
     *
     C                   endsl
     *
     C     bottom        tag
     *
     CLr                 exsr      zzrmbt
640dAclr                 exsr      zzwrttrandlog
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
     c* moved from mainline - if LR with no records $kwhse is 0
700aMC                   move      $pwhse        $kwhse
     C                   eval      forevr = *off
520cAC     keyli         klist
520cAC                   kfld                    ptwhse
520cAC                   kfld                    pttrn#
     C*
     C     keybt         klist
     C                   kfld                    $kwhse
     C                   kfld                    kytype
     C                   eval      kytype = '*REPLEN '
     *
     C                   eval      errecs = 0
     C                   movel     desc(1)       erdesc
     *
520bA*
520bA*    Define full key for file OPTIONS.
520bA*
520bAC                   eval      kywhse = *zeros
520bAC                   eval      kycode = '*SYSTEM '
520bAC     keyop         klist
520bAC                   kfld                    kywhse
520bAC                   kfld                    kycode
640aA*
640aAc     keylcninfo1   klist
640aAc                   kfld                    ptwhse
640cDc*                  kfld                    kylicinfo1
640cDc*                  kfld                    kylicinfotrn#
640cAc                   kfld                    pttrn#
640aA*   Define key for LICACTIVE file.
640aA*
640aAc     keylicactive  klist
640aAc                   kfld                    ptwhse
640aAc                   kfld                    keylcns
640aA*   Define key for LICINFO file orphaned in licinfo not license
640aA*
640aAc     keylnorphan   klist
640aAc                   kfld                    a_lnwhse
640aAc                   kfld                    a_lnlcns
640aA*
640aA*   Define key for LICINFO file.
640aA*
640aAc     keyln         klist
640aAc                   kfld                    liwhse
640aAc                   kfld                    lilcns
520bA*
520bA*    Retrieve System options.
520bA*
520bAC     keyop         chain     options                            79
520bAC                   if        *in79
520bAC                   eval      opishs = 0
520bAC                   endif
     C                   endsr
640aA*----------------------------------------------------------------
640aA*
640aA*  chkactlicense  check for active licenses.
640aA*
640aAC     chkactlicense begsr
640aA*  check to make sure license is not active
640aAc                   eval      foundlicense = *off
640aA*  get the license number for the pttrn# check license file first
640aA*  if not found in license file check licinfo file for orphans
640aAC     keyli         chain(n)  license1
640aAc                   if        %found(license1)
640aAc                   eval      foundlicense = *on
640aAc                   eval      keylcns = lilcns
640aAc                   endif
640aA
640aAc                   if        foundlicense = *off
640cDc*                  eval      kylicinfo1 = '*RCVTRN#'
640cDC*                  eval      kylicinfotrn# =   %char(pttrn#)
640aAc     keylcninfo1   chain     licinfo1
640aAc                   if        %found(licinfo1)
640aAc                   eval      foundlicense = *on
640aAc                   eval      keylcns = a_lnlcns
640aAc                   endif
640aAc                   endif
640aA
640aAc                   if        foundlicense = *on
640aAc     keylicactive  chain     licactive
640aAc                   if        %found(licactive)
640aac                   eval      activelicense = *on
640aAc                   endif
640aAc     keylicactive  chain     licactive6
640aAc                   if        %found(licactive6)
640aac                   eval      activelicense = *on
640aAc                   endif
640aAc                   endif
640aAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZRMBT  Remove old batch control records.
     *
     C     zzrmbt        begsr
     *
     *    Remove old batch control records for replenishment trans.
     *
     C     keybt         setll     batctl3
     C                   dow       forevr = forevr
     C     keybt         reade     batctl3                                79
     C                   select
     C                   when      *in79
     C                   leave
     *
     C                   when      btstrd < $kdate
     C                   delete    btrec
     C                   endsl
     C                   enddo
     *
     C                   endsr
640dA*----------------------------------------------------------------*********
640dA*
640dA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640dA*
640dA /free
640dA   begsr zzwrttrand;
640dA     wrtpcmd = '*CLEANUP';
640dA     wrtpwait = 0;
640dA     wrtpwhse = ptwhse;
640dA     wrtptran# = pttrn#;
710aD     //wrtpfrmdate = 0;
710aM     wrtpfrmdate = ptgdte;
640dA     wrtptodate = 0;
640dA     wrtpemp# = 0;
640dA
640dA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640dA               wrtpfrmdate: wrtptodate: wrtpemp#);
640dA   endsr;
640dA /end-free
640dA*----------------------------------------------------------------*********
640dA*
640dA*  ZZWRTTRANDLOG Execute new WRTTRAN1 program to cleanup LOGTRAND
640dA*
640dA /free
640dA   begsr zzwrttrandlog;
640dA     wrtpcmd = '*CLEANLOG';
640dA     wrtpwait = 0;
640dA     wrtpwhse = $Kwhse;
640dA     wrtptran# = 0;
640dA     wrtpfrmdate = 0;
640dA     wrtptodate = 0;
640dA     wrtpemp# = 0;
640dA
640dA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640dA               wrtpfrmdate: wrtptodate: wrtpemp#);
640dA   endsr;
640dA /end-free
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
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
Misc transaction records
