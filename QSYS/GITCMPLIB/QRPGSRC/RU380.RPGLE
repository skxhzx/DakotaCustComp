     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RU380     Runner Flag - Change status
     *  15 March 2005
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    03/15/05  MLB  5.00
     *      - Created.
     *      - Client Custom support included.
500aA*    06/28/05  MLB  5.00a
     *      - Fix: Revised program to not update $PPRG. Any messages
     *        will be sent back to callling program.
500bA*    07/10/05  MLB  5.00b
     *      - Enh: Revised program to add new field to file key for
     *        RUNNER4. Added support to program for new flag type.
     *        When Normal Flag is Outed, status is set to U=Out and
     *        Closed datestamp is updated. The record is added to the
     *        Out type with status O=Open, runner tran# set to zero and
     *        printed, closed datestamp fields set to default.
     *      - Added file OPTIONS. Retrieve *GENPICK options record.
500cA*    08/05/05  MLB  5.00c
     *      - Enh: Revised program to add SLOTOUT file to program and
     *        remove logic to add/rmv records to file from IT276, LT105.
     *      - Removed $pnwst field. Status code will be set by this
     *        program instead of passed into the program.
500dA*    10/26/05  MLB  5.00d
     *      - Enh: Revised program to update Replenished Date/Time
     *        stamp for flagged items in RUNNER file.
     *
750aA*    08/06/21  RBD  7.50a
     *      - Fix: When this program was written *RUNNER option opclrf
     *        was a *GENPICK option.  When *RUNNER options were created
     *        it got moved to *RUNNER but this program didn't get changed.
     *        Found this problem at CBI/Stv.  It happened to be working
     *        at Riv simply because *GENPICK opdata pos 10, where opclrf
     *        in genpick used to live, was an N, and their *RUNNER opclrf
     *        was an N.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *            No indicators used in this program.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Flabel     uf   e           k disk
500bAFoptions   if   e           k disk
500bDF*runner4   uf   e           k disk
500bMFrunner4   uf a e           k disk
     F                                     rename(rurec:record)
500cAFslotout   uf a e           k disk
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')

500bA*----------------------------------------------------------------
500bA*  *GENPICK -  General picking.
500bA*----------------------------------------------------------------
500bA*
500bA* Fields
500bA*
500bA*    OPERPT  -  Print exception (short) error report (Y,N).
500bA*    OPELBL  -  Print exception (short) labels (Y,N).
500bA*    OPRFWC  -  Using RF will call (Y,N).
500bA*    OPNRSC  -  Number of pallet sections (1-9).
500bA*    OPHPWC  -  Host pick Will Call (Y/N).
500bA*    OPMRGA  -  Merge Add-on order(s) with Open Routes.
500bA*    OPPLSQ  -  Pallet number sequence. 1=Unload seq, 2=Load seq
500bA*    OPEADJ  -  Close short labels without adjustment (Y,N).
500bA*    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
500bA*    OPCLRF  -  Clear runner flags if qty still short/out? (Y/N)
500bA*
500bA* Data structure
500bA*
500bAD opdta1          DS
500bAD  OPERPT                 1      1
500bAD  OPELBL                 2      2
500bAD  OPRFWC                 3      3
500bAD  OPNRSC                 4      4  0
500bAD  OPHPWC                 5      5
500bAD  OPMRGA                 6      6
500bAD  OPPLSQ                 7      7
500bAD  OPEADJ                 8      8
500bAD  OPNOPK                 9      9
750aDD**OPCLRF                10     10
500bAD  OPTEND               117    117
     *----------------------------------------------------------------
750aA*  *RUNNER  -  PIR Runner Flag Options
750aA*----------------------------------------------------------------
750aA*
750aA* Fields
750aA*
750aA*    OPCRTM  -  Create Manual Runner entries for shorts/outs (Y/N)
750aA*    OPUPLR  -  Update Label with quantity shorted during manual
750aA*               flag entry (Y/N)
750aA*               NOTE: Any change to this field will cause OPUPLV
750aA*                     in the *VOICE options record to be updated.
750aA*    OPRPLF  -  Replenish flagged items before print report? (Y/N)
750aA*               & create Priority Replenishment if necessary.
750aA*    OPMRGF  -  Create Runner entries for Merge records? (Y/N)
750aA*    OPCLRF  -  Clear Runner flags if qty still short/out? (Y/N)
750aA*    OPRNRM  -  Send break message to user when new Runner
750aA*               task has been assigned. (Y/N)
750aA*    OPCLSF  -  Update Label quantity at flag close (Y/N).
750aA*    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
750aA*    OPRPCK  -  Print Runner pick list. (Y/N)
750aA*    OPRLBL  -  Print Runner pick labels. 0=No, 1=full size Zebra
750aA*               printer, 2=Belt printer
750aA*    OPRBDU  -  Allow shorts to be filled with breakdown units (Y/N).
750aA*    OPRSCN  -  Scan tran# or label# to start pick.
750aA*                 1=tran#, 2=label#.
750aA*    OPRVFS  -  Verify pick slot, Y/N.
750aA*    OPRVFQ  -  Verify qty found, Y/N.
750aA*    OPRLOA  -  Using loader module, Y/N.
750aA*    OPSCNL  -  Scan short to loader required before
750aA*               clearing runner flag, Y/N.
750aA*
750aA* Data structure
750aA*
750aAD opdta2          ds
750aAD  opcrtm                 1      1
750aAD  opuplr                 2      2
750aAD  oprplf                 3      3
750aAD  opmrgf                 4      4
750aAD  opclrf                 5      5
750aAD  oprnrm                 6      6
750aAD  opclsf                 7      7
750aAD  opoutf                 8      8
750aAD  oprpck                 9      9
750aAD  oprlbl                10     10
750aAD  oprbdu                11     11
750aAD  oprscn                12     12
750aAD  oprvfs                13     13
750aAD  oprvfq                14     14
750aAD  oprloa                15     15
750aAD  opscnl                16     16
750aAD  opten2               117    117
750aA*
     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $pwhdp                22     26
     D  $pdisp                27     38
500cAD  $pitem                39     53
500cDD* $pnwst                39     39
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $cvtdt          ds
     D  $cvdop                 1      8
     D  $cvdd6                 9     14  0
     D  $cvdd8                15     22  0
500bAD currstamp       s               z
500bAD dftstamp        s               z
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
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
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
500bM*      $PCMD   *CHG2OUT - Add Runner Flag entries with Type=U=Out.
     *              *CHG2RPL - Change status of Runner flag entries to
     *                         R=Replenished.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for everything but *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new unique key for *ADD.
     *              Unchanged for everything else.
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     *
     C                   exsr      zzinz2
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   select
500bA*
500bA*      Only create Flag Type U=Out when Clear flag option
500bA*      is N=No.
     C                   when      $pcmd = '*CHG2OUT'
500bAC                             and opclrf = 'N'
500cAC                   exsr      zzaddout
     C                   exsr      zzupdout
     *
     C                   when      $pcmd = '*CHG2RPL'
500cAC                   exsr      zzdltout
     C                   exsr      zzupdrpl
     *
     C                   endsl
     C
     C                   unlock    runner4
     C
     C
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
     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     *like         define    rustat        kystat
500bAC     *like         define    rutype        kytype
     C     keyruu        klist
     C                   kfld                    $pwhse
500bAC                   kfld                    kytype
     C                   kfld                    $pwhdp
     C                   kfld                    kystat
     C                   kfld                    $pdisp
500bA*
500bA*  Define key for OPTIONS file.
500bA*
500bAC     opkey         klist
500bAC                   kfld                    $pwhse
500bAC                   kfld                    opcode
     *
500bA*  Get *GENPICK picking options record.
500bAC                   exsr      zzgetop
500bA*
500aDC*                  eval      $pprg = #prog
500aDC*                  eval      $lprg = #prog
500aMC                   eval      $lprg = $pprg
500cA*
500cA*  Define key for SLOTOUT file.
500cA*
500cAC     keyso         klist
500cAC                   kfld                    $pwhse
500cAC                   kfld                    $pwhdp
500cAC                   kfld                    $pdisp
500cAC                   kfld                    $pitem
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *
     C                   endsr
500bA*
500bA*----------------------------------------------------------------
500bA*
500bA*  ZZGETOP  Get General Picking Options record.
500bA*
500bAC     zzgetop       begsr
500bA*
750aDC**                 MOVE      '*GENPICK'    opcode
750aMC                   MOVE      '*RUNNER '    opcode
500bA*
500bAC     opkey         chain     options
500bAC                   if        not %found(options)
500bAC                   eval      opclrf = 'Y'
500bAC                   else
750aDC**                 movel     opdata        opdta1
750aMC                   movel     opdata        opdta2
500bAC                   endif
500bA*
500bAC                   endsr
500bA*
500cAC*----------------------------------------------------------------
500cAC*
500cAC*  ZZADDOUT    Create record for slot having no available product
500cAC*              in overflow slots to replenish into pick slot.
500cAC*
500cAC     zzaddout      begsr
500cA*
500cAC     keyso         chain     slotout
500cAC                   if        not %found(slotout)
500cAC                   clear                   sorec
500cA*
500cAC                   eval      sowhse = $pwhse
500cAC                   eval      sowhdp = $pwhdp
500cAC                   eval      sodisp = $pdisp
500cAC                   eval      soitem = $pitem
500cA*
500cA* Update the datestamp field with the current time.
500cAC                   time                    currstamp
500cAC                   eval      soadts = currstamp
500cA*
500cAC                   write     sorec
500cAC                   if        %error
500cAC                   endif
500cAC*
500cAC                   else
500cAC                   unlock    slotout
500cA*
500cAC                   endif
500cA*
500cAC     endaddout     Endsr
500cA*
500cAC*----------------------------------------------------------------
500cAC*
500cAC*  ZZDLTOUT    Delete Out record for slot being replenished.
500cAC*
500cAC     zzdltout      begsr
500cA*
500cAC     keyso         chain     slotout
500cAC                   if        %found(slotout)
500cAC                   delete    sorec
500cAC                   endif
500cA*
500cAC     enddltout     Endsr
500cA*
     *----------------------------------------------------------------
     *
     *  ZZupdout  Update Runner Flag entries to status U=Out.
     *
     C     zzupdout      begsr
     *
     C                   eval      kystat = 'O'
500bAC                   eval      kytype = 'N'
     C     keyruu        setll     runner4
     C     keyruu        reade     runner4
     C                   dow       not %eof(runner4)
500cDC*                  eval      rustat = $pnwst
500cMC                   eval      rustat = 'C'
500bAC                   time                    currstamp
500bAC                   eval      rucdts = currstamp
     C                   update    record
500bA*
500bA*    Write Runner Flag record out as Type U=Out.
500bA*
500bAC                   eval      rutype = 'U'
500bAC                   eval      rutrn# = 0
500bAC                   eval      ruqyfd = 0
500bAC                   eval      rustat = 'O'
500bAC                   time                    currstamp
500bAC                   eval      ruodts = currstamp
500bAC                   eval      rupdts = dftstamp
500bAC                   eval      rucdts = dftstamp
500bA*
500bAC                   write     record
500bAC                   if        %error
500baC                   endif
     *
     *    Update Label record to status I for Out.
     *
     C     rulbl#        chain     label
     C                   if        %found
     C                   eval      lbvrfy = 'I'
     C                   update    lbrec
     C                   endif
     C
     C     keyruu        reade     runner4
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZupdrpl  Update Runner Flag entries to status R=Replenished.
     *
     C     zzupdrpl      begsr
     *
     *      Change Open entries to Replenished status.
     C                   eval      kystat = 'O'
500bAC                   eval      kytype = 'N'
     C     keyruu        setll     runner4
     C     keyruu        reade     runner4
     C                   dow       not %eof(runner4)
500cDC*                  eval      rustat = $pnwst
500cMC                   eval      rustat = 'R'
500dAC                   time                    currstamp
500dAC                   eval      rurdts = currstamp
     C                   update    record
     C
     C     keyruu        reade     runner4
     C                   enddo
     *
     C                   endsr
