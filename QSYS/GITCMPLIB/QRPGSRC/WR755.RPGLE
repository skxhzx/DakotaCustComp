     H/copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  WR755     Remove closed Repack work orders
     *  09 April, 2013
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650aA*    04/09/13  LMC  6.50a
     *      - Created.
700aA*    04/11/16  LMC  7.00a
     *      - Moved the move to populate $kwhse into the inzsr
     *        routine. If no records exist in the file, the cycle
     *        hits LR, and executes the wrttran log cleanup but sends
     *        warehouse 0. This causes a BFCWTD000 job to be started
     *        on the clients box.
710a *    07/10/17  LMC  7.10a
     *      - Enh: Added sending the transaction generated date to
     *        WRTTRAN1 in order to cleanup the correct transactions.
     *----------------------------------------------------------------
     *  Client Custom Revisions
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF for POH
     *  79        - EOF for kitordh
     *
     *----------------------------------------------------------------
     * File Specs
     *
     fkitordh   up   e           k disk
     fkitordd   uf   e           k disk
     flabel93   uf   e           k disk
     fpirtran   uf   e           k disk
     flicense1  uf   e           k disk
     Foptions   if   e           k disk
     flicinfo2  uf   e           k disk
     flicinfo1  if   e           k disk    rename(lnrec:lnrec1) prefix(a_)
     flicactive if   e           k disk
     flicactive6if   e           k disk    rename(larec:lareco) prefix(b_)
     fliclog    if   e           k disk
     fliclog1   if   e           k disk    rename(llrec:llrec1)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     d desc            s             50    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D wrttran1        pr                  extpgm('WRTTRAN1')
      * Input
     D   ppcmd                        8
     D   ppwait                       2  0
     D   ppwhse                       3  0
     D   pptran#                      7  0
     D   ppfromdate                   8  0
     D   pptodate                     8  0
     D   ppemp#                       5  0
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
     *    OPTBJQ  -  Run Truck builder on Job Que (Y/N)
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
     D  optbjq                32     32
     D  opishs                33     35  0
     D  optend               117    117
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     d $mdt            ds
     d  errmsg                 1     50
     *
     d  errecs                 1      3p 0
     d  erdesc                 4     48
     d                 ds
     d  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     d #msgf           c                   const('PIRMSGF   ')
     *
     d                 ds
     d  #msgdt                 1    128
     d  $md                    1    128
     d                                     dim(128)
     d kycode          s                   like(opcode)
     d kywhse          s                   like(opwhse)
     d*kylicinfo1      s                   like(lncode)
     d*kylicinfotrn#   s                   like(lnvalue)
     d keylcns         s                   like(lilcns)
     D wrtpcmd         s             10
     D wrtpwait        s              2  0
     D wrtpwhse        s              3  0
     D wrtptran#       s                   like(pttrn#)
     D wrtpfrmdate     s              8  0
     D wrtptodate      s              8  0
     d wrtpemp#        s                   like(ptemp#)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PPRG   - Program to send message back to.
     *      &PWHSE  - Warehouse
     *      &PDATE  - close date
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *
     c     *entry        plist
     c                   parm                    $pprg            10
     c                   parm                    $pwhse            3
     c                   parm                    $pdate            8
700aDc*                  move      $pwhse        $kwhse            3 0
     c                   move      $pdate        $kdate            8 0
     *----------------------------------------------------------------
     * Main line
     *
     *  Although the following conditions are tested by open query
     *  in the preceding CL program, this is tested here again for
     *  additional safety.
     *
     c     kohwhs        ifne      $kwhse
     c     kohcdt        orge      $kdate
     c                   goto      bottom
     c                   endif
     *  Delete closed repack work order detail records.
     c                   exsr      zzrpdt
     c     eflag         cabeq     *on           bottom
     *  Delete closed label records and transactions.
     c     kohord        ifne      0
     c                   exsr      zzlabl
     c                   endif
     c     eflag         cabeq     *on           bottom
     *
     *  Delete closed Repack Work order header record.
     *
     c                   add       1             errecs
     c                   delete    kohrec                               79
     *
     *
     c     bottom        tag
     *
     clr                 exsr      ZZWRTTRANDLOG
     clr                 exsr      zm0750
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     c     *inzsr        begsr
     c* moved from mainline - if LR with no records $kwhse is 0
700aMc                   move      $pwhse        $kwhse            3 0
     c                   z-add     0             errecs
     c                   movel     desc(1)       erdesc
     c                   move      *off          eflag             1
     c                   move      *off          forevr            1
     *
     *   Define partial key for POD file.
     *   Define partial key for kitordd file.
     *
     c     keyod         klist
     c                   kfld                    kohwhs
     c                   kfld                    kohord
     *
     *
     *   Define key for LICENSE file.
     *
     c     keylcn        klist
     c                   kfld                    lbwhse
     c                   kfld                    lbtrn#
     *
     *
     *   Define key for LICENSE file.
     *
     c     keystgl       klist
     c                   kfld                    ptwhse
     c                   kfld                    pttrn#
     *
     *   Define key for LICINFO file.
     *
     c     keyln         klist
     c                   kfld                    liwhse
     c                   kfld                    lilcns
     *   Define key for LICINFO file orphaned in licinfo not license
     *
     c     keylnorphan   klist
     c                   kfld                    a_lnwhse
     c                   kfld                    a_lnlcns
     *
     *   Define key for LICINFO1 file.
     *
     c     keylcninfo1   klist
     c                   kfld                    lbwhse
     c*                  kfld                    kylicinfo1
     c*                  kfld                    kylicinfotrn#
     c                   kfld                    lbtrn#
     *   Define key for LICACTIVE file.
     *
     c     keylicactive  klist
     c                   kfld                    lbwhse
     c                   kfld                    keylcns
     *
     *
     *    Define full key for file OPTIONS.
     *
     C                   eval      kywhse = *zeros
     C                   eval      kycode = '*SYSTEM '
     C     keyop         klist
     C                   kfld                    kywhse
     C                   kfld                    kycode
     *
     *    Retrieve System options.
     *
     C     keyop         chain     options                            79
     C                   if        *in79
     C                   eval      opishs = 0
     C                   endif
     c                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     c     zmsmsg        begsr
     c     $msgf         ifeq      *blanks
     c                   move      #msgf         $msgf            10
     c                   end
     c                   call      'PUTMSG'
     c                   parm                    $msgf
     c                   parm                    #msgid            7
     c                   parm                    #msgtp            7
     c                   parm                    #msgdt
     c                   parm      $pprg         #pgmq2           10
     c                   parm                    #msgk             4
     c                   move      *blanks       #msgdt
     c                   move      *blanks       $msgf
     c                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *     PIR0750  Records removed.
     *
     c     zm0750        begsr
     c                   move      'PIR0750'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmsmsg
     c                   endsr
     *---------------------------------------------------------------
     *
     *    ZZLABL  Delete closed Label records for closed repack wo.
     *            Delete dependent PIRTRAN and LICENSE records for label.
     *
     c     zzlabl        begsr
     *
     c                   move      *off          eflag
     c     keyod         setll     label93
     c                   move      *off          eof
     c     eof           doweq     *off
     c     keyod         reade     label93                                79
     c                   move      *in79         eof
     c     *in79         ifeq      *off
      * check the report date, make sure it is <= the repack wo close date
     c                   if        lbrdte > kohcdt
     c                   iter
     c                   endif
     c                   if        lbgrp1 <> 'K'
     c                   iter
     c                   endif
     c     keylcn        chain     license1                           77
     c     *in77         ifeq      *off
      * check to make sure license is not active before continuing
     c                   eval      keylcns = lilcns
     c     keylicactive  chain     licactive
     c                   if        %found(licactive)
     c                   eval      eflag = *on
     c                   leave
     c                   endif
     c     keylicactive  chain     licactive6
     c                   if        %found(licactive6)
     c                   eval      eflag = *on
     c                   leave
     c                   endif
      * if records exist in liclog, for either original or current license
      * don't remove licinfo at this time.
      * licinfo will be cleaned up when liclog file is ready to be removed.
     c     keylicactive  chain     liclog
     c     keylicactive  chain     liclog1
     c                   if        not %found(liclog ) and
     c                             not %found(liclog1)
     c     keyln         setll     licinfo2
     c     forevr        doweq     forevr
     c     keyln         reade     licinfo2                               78
     c     *in78         ifeq      *off
     c                   delete    lnrec                                77
     c     *in77         ifeq      *on
     c                   move      *in77         eflag
     c                   endif
     c                   else
     c                   leave
     c                   endif
     c                   enddo
     c                   endif
     c                   delete    lirec                                77
     c     *in77         ifeq      *on
     c                   move      *in77         eflag
     c                   endif
     c                   else
      * if no license record is found check the licinfo1 file for
      * license info code *RCVTRN# move to history if license is no
      * longer active
     c*                  eval      kylicinfo1 = '*RCVTRN#'
     C*                  eval      kylicinfotrn# =   %char(lbtrn#)
     c     keylcninfo1   chain     licinfo1
     c                   if        %found(licinfo1)
      * check for active license - if active don't delete
     c                   eval      keylcns = a_lnlcns
     c     keylicactive  chain     licactive
     c     keylicactive  chain     licactive6
     c                   if        not %found(licactive)   and
     c                             not %found(licactive6)
     c                   eval      *in76 = *off
     C     keylicactive  chain     liclog
     C     keylicactive  chain     liclog1
     c                   if        not %found(liclog)  and
     c                             not %found(liclog1)
     c     keylnorphan   setll     licinfo2
     c     forevr        doweq     forevr
     c     keylnorphan   reade     licinfo2                               76
     c     *in76         ifeq      *on
     c                   leave
     c                   endif
     c     *in76         ifeq      *off
     c                   delete    lnrec                                77
     c     *in77         ifeq      *on
     c                   move      *in77         eflag
     c                   endif
     c                   endif
     c                   enddo
     c                   endif
     c                   else
     c                   eval      eflag = *on
     c                   endif
     c                   endif
     c                   endif
     c     eflag         cabeq     *on           endlb
     c     lbtrn#        setll     pirtran
     c     forevr        doweq     forevr
     c     lbtrn#        reade     pirtran                                77
     c     *in77         ifeq      *off
     c                   delete    ptrec                                77
      * This is only executed if no extended history is kept
     c                   if        opishs = 0
     c                   exsr      zzwrttrand
     c                   endif
     c     *in77         ifeq      *on
     c                   move      *in77         eflag
     c                   endif
     c                   else
     c                   leave
     c                   endif
     c                   enddo
     c     eflag         cabeq     *on           endlb
     *
     c                   delete    lbrec                                78
     c     *in78         ifeq      *on
     c                   move      *in78         eflag
     c                   endif
     c                   endif
     c                   enddo
     c     endlb         endsr
     *
     *---------------------------------------------------------------
     *
     *    ZZrpDT  Delete closed Repack Work order detail records.
     *
     c     zzrpdt        begsr
     *
     *  Delete closed Repack Work order detail records.
     *
     c                   move      *off          eflag
     c     keyod         setll     kitordd
     c                   move      *off          eof               1
     c     eof           doweq     *off
     c     keyod         reade     kitordd                                79
     c                   move      *in79         eof
     c     *in79         ifeq      *off
     c                   delete    kodrec                               78
     c     *in78         ifeq      *on
     c                   move      *in78         eflag
     c                   endif
     c                   endif
     c                   enddo
     c                   endsr
     *
     *----------------------------------------------------------------*********
     *
     *  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
     *
      /free
        begsr zzwrttrand;
          wrtpcmd = '*CLEANUP';
          wrtpwait = 0;
          wrtpwhse = ptwhse;
          wrtptran# = pttrn#;
710aD     //wrtpfrmdate = 0;
710aM     wrtpfrmdate = ptgdte;
          wrtptodate = 0;
          wrtpemp# = 0;

          wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
                    wrtpfrmdate: wrtptodate: wrtpemp#);
        endsr;
      /end-free
     *----------------------------------------------------------------*********
     *
     *  ZZWRTTRANDLOG Execute new WRTTRAN1 program to cleanup LOGTRAND
     *
      /free
        begsr zzwrttrandlog;
          wrtpcmd = '*CLEANLOG';
          wrtpwait = 0;
          wrtpwhse = $Kwhse;
          wrtptran# = 0;
          wrtpfrmdate = 0;
          wrtptodate = 0;
          wrtpemp# = 0;

          wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
                    wrtpfrmdate: wrtptodate: wrtpemp#);
        endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
Closed Repack Work orders
