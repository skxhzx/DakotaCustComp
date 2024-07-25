     H/copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PT785H    Remove hstory Misc. PIRTRANH       records - Post
     *  13 January 2012
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    01/13/12  LMC  6.40
     *      - Create - copied from PT785 to process history files instead
     *        original files
640aA*    01/11/12  LMC  6.40a
     *      - Enh: Added LICinfo clean up to the LICENSE logic
     *      - Fix: add check for active license before moving to history
640b *    01/20/12  LMC  6.40b
     *      - Fix: added logic to check to make sure liclogh records
     *        don't exist before removing licinfoh records
640c *    10/16/12  LMC  6.40c
     *      - NOTE: THIS MOD SHOULD ONLY BE APPLIED IF THE CLIENT HAS
     *        THE NEW LICINFOH FILE. Key for licinfo1 has changed.
     *        LICINFOH1 had lncode as a key field, and the field does
     *        not exist in the new file.
640dA*    06/18/12  LMC  6.40d
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
650aA*    06/13/14  LMC  6.50a
     *      - Enh: Added cleanup for TFRMOV.
710a *    07/10/17  LMC  7.10a
     *      - Enh: Added sending the transaction generated date to
     *        WRTTRAN1 in order to cleanup the correct transactions.
710b *    10/03/17  LMC  7.10b
     *      - Enh: If errecs reaches 99999, we won't try to add 1, we
     *        will just let the count stay at 99999. This is just
     *        informational, and isn't used for anything at this point.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF for PIRTRAN
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fpirtranh  up   e             disk
     Foptions   if   e           k disk
     Flicenseh1 uf   e           k disk
640aAflicinfoh1 if   e           k disk    rename(lnhrec:lnrec1) prefix(a_)
640aAflicinfoh2 uf   e           k disk
640bAFliclogh   if   e           k disk
640bAFliclogh1  if   e           k disk    rename(llhrec:llrec1)
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
     *----------------------------------------------------------------
     *  *SYSTEM  -  System options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Perform catch weight variance check (Y,N).
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import Item fields (Y,N).
     *    OPICW   -  Individual catch weight entry (Y,N).
     *    OPMPCK  -  Allow multiple pick slots for fixed items (Y/N).
     *    OPRCDY  -  Number of days to keep receiving logs.
     *    OPMPCK  -  Number of days to keep picking logs.
     *    OPRTHS  -  Number of weeks - exported routes to keep.
     *    OPCRHS  -  Number of weeks - exported customer rtns to keep.
     *    OPPOHS  -  Number of weeks - exported p/o's to keep.
     *    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
     *    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
     *    OPISHS  -  Number of weeks - extra history files to keep.
     *
     * Data structure
     *
     D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
     D  opmpck                14     14
     D  oprcdy                15     15  0
     D  oppkdy                16     16  0
     D  oprths                17     19  0
     D  opcrhs                20     22  0
     D  oppohs                23     25  0
     D  opiahs                26     28  0
     D  opmshs                29     31  0
     D  opishs                33     35  0
     D  optend               117    117
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
     D kytype          s              8
     d kycode          s                   like(opcode)
     d kywhse          s                   like(opwhse)
640cDd*kylicinfo1      s                   like(a_lncode)
640cDd*kylicinfotrn#   s                   like(a_lnvalue)
640aAd foundlicense    s              1
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
     C                   move      $pwhse        $kwhse
     C                   move      $pdate        $kdate
     *----------------------------------------------------------------
     * Main line
     *
     * history is not used, don't execute the program.
     c                   if        opishs = 0
     c                   eval      *inlr = *on
     c                   goto      bottom
     c                   endif
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
     C                             pttask = 'BEGDAY  '  or
     C                             pttask = 'ENDDAY  '  or
     C                             pttask = 'VERIFY  '  or
     C                             pttask = 'RUNNER  '
710bAc                   if        errecs < 99999
     C                   add       1             errecs
710bAc                   endif
     * ONLY DELETE HISTORY IF ADDITIONAL HISTORY IS SET IN OPTIONS
     C                   if        opishs <> 0
     C                   delete    ptrec                                79
640dAc                   exsr      zzwrttrand
     C                   endif
     *
     C                   when      pttask = 'PUTSTG'  and
     C                             ptrtpo = *blanks
640aA
     C     keyli         chain     licenseh1
     C                   if        %found(licenseh1)

640bAc     keyln         chain     liclogh
640bAc     keyln         chain     liclogh1
640bAc                   if        not %found(liclogh)  and
640bAc                             not %found(liclogh1)
     C     keyln         setll     licinfoh2
     c     *in74         doweq     *off
     c     keyln         reade     licinfoh2                              74
     c                   if        not *in74
      * Only write history if additional history is set in options
     C                   if        opishs <> 0
     c                   delete    lnhrec                               73
     C                   endif
     c                   endif
     c                   enddo
640bAc                   endif

     * ONLY WRITE HISTORY IF ADDITIONAL HISTORY IS SET IN OPTIONS
     C                   if        opishs <> 0
     C                   delete    lirec                                79
     C                   endif
     c                   else
     * license not found check licinfo for orphans
640aA * if no license record is found check the licinfo1 file for
640aA * license info code *RCVTRN# move to history if license is no
640aA * longer active
640cDc*                  eval      kylicinfo1 = '*RCVTRN#'
640cDC*                  eval      kylicinfotrn# =   %char(pttrn#)
640aAc     keylcninfo1   chain     licinfoh1
640aAc                   if        %found(licinfoh1)
640aAc                   eval      *in76 = *off
640bAc     keylnorphan   chain     liclogh
640bAc     keylnorphan   chain     liclogh1
640bAc                   if        not %found(liclogh) and
640bAc                             not %found(liclogh1)
640aAc     keylnorphan   setll     licinfoh2
640aAc     forevr        doweq     forevr
640aAc     keylnorphan   reade     licinfoh2                              76
640aAc     *in76         ifeq      *on
640aAc                   leave
640aAc                   endif
640aAc     *in76         ifeq      *off
640aA * Only write history if additional history is set in options
640aAC                   if        opishs <> 0
640aAc                   delete    lnhrec                               77
640aAC                   endif
640aAc                   endif
640aAc                   enddo
640bAc                   endif
640aAc                   endif
     C                   endif

     C                   if        opishs <> 0
     C                   delete    ptrec                                79
640dAc                   exsr      zzwrttrand
     C                   endif
650aAC                   when      pttask = 'TFRMOV'
650aA
650aAC     keyli         chain     licenseh1
650aAC                   if        %found(licenseh1)

650aAc     keyln         chain     liclogh
650aAc     keyln         chain     liclogh1
650aAc                   if        not %found(liclogh)  and
650aAc                             not %found(liclogh1)
650aAC     keyln         setll     licinfoh2
650aAc     *in74         doweq     *off
650aAc     keyln         reade     licinfoh2                              74
650aAc                   if        not *in74
650aAc                   delete    lnhrec                               73
650aAc                   endif
650aAc                   enddo
650aAc                   endif

650aAC                   delete    lirec                                79
650aAc                   else
650aA* license not found check licinfo for orphans
650aA * if no license record is found check the licinfo1 file for
650aA * license info code *RCVTRN# move to history if license is no
650aA * longer active
650aAc     keylcninfo1   chain     licinfoh1
650aAc                   if        %found(licinfoh1)
650aAc                   eval      *in76 = *off
650aAc     keylnorphan   chain     liclogh
650aAc     keylnorphan   chain     liclogh1
650aAc                   if        not %found(liclogh) and
650aAc                             not %found(liclogh1)
650aAc     keylnorphan   setll     licinfoh2
650aAc     forevr        doweq     forevr
650aAc     keylnorphan   reade     licinfoh2                              76
650aAc     *in76         ifeq      *on
650aAc                   leave
650aAc                   endif
650aAc     *in76         ifeq      *off
650aAc                   delete    lnhrec                               77
650aAc                   endif
650aAc                   enddo
650aAc                   endif
650aAc                   endif

650aAC                   delete    ptrec                                79
650aA * This is only executed if extended history is kept
650aAc                   if        opishs <> 0
650aAc                   exsr      zzwrttrand
650aAc                   endif
650aAc                   endif
     *
     *    Remove any indirect tasks.
     *
     C                   other
     *
     *    if indirect task delete transaction from file or direct
     *    non-standard task, remove transaction from file.
     *
     *
     *
710bAc                   if        errecs < 99999
     C                   add       1             errecs
710bAc                   endif
     * ONLY WRITE HISTORY IF ADDITIONAL HISTORY IS SET IN OPTIONS
     C                   if        opishs <> 0
     C                   delete    ptrec                                79
640dAc                   exsr      zzwrttrand
     C                   endif
     *
     C                   endsl
     *
     C     bottom        tag
     *
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
     C                   eval      forevr = *off
     C     keyli         klist
     C                   kfld                    ptwhse
     C                   kfld                    pttrn#
     C*
     C     keybt         klist
     C                   kfld                    $kwhse
     C                   kfld                    kytype
     C                   eval      kytype = '*REPLEN '
     *
     C                   eval      errecs = 0
     C                   movel     desc(1)       erdesc
     *
     *
     *    Define full key for file OPTIONS.
     *
     C                   eval      kywhse = *zeros
     C                   eval      kycode = '*SYSTEM '
     C     keyop         klist
     C                   kfld                    kywhse
     C                   kfld                    kycode
640aA*
640aAc     keylcninfo1   klist
640aAc                   kfld                    ptwhse
640cDc*                  kfld                    kylicinfo1
640cDc*                  kfld                    kylicinfotrn#
640cAc                   kfld                    pttrn#
640aA*   Define key for LICINFO file orphaned in licinfo not license
640aA*
640aAc     keylnorphan   klist
640aAc                   kfld                    a_lnwhse
640aAc                   kfld                    a_lnlcns
     *
     *   Define key for LICINFO file.
     *
     c     keyln         klist
     c                   kfld                    liwhse
     c                   kfld                    lilcns
     *
     *    Retrieve System options.
     *
     C     keyop         chain     options                            79
     C                   if        *in79
     C                   eval      opishs = 0
     C                   endif
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
