     *----------------------------------------------------------------
     *   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PCK815    Auto entry of inventory count sheets - Create
     *  03 March 2000
     *  Dave Sommerville
     *
     *  Revisions
414aA*    05/15/00  RH   4.14a
     *      - Recompiled, file INVSLOT changed.
416 A*  09/25/01  RH   4.16
     *    - Recompile - INVSLOT file changed.
700aA*  08/18/16  MR   7.00a
     *    - Update ICDCNTD history file when INVSLOT is updated
     *      for history purposes.
700bA*  09/14/16  LMC  7.00b
     *    - Enh: New history files names changed.
     *    - Enh: Dept added to invinuse file to ensure unique # is
     *           by whse/department.
710aA*  03/23/17  LMC  7.10a
     *    - Enh: Database change to INVHSTD. Recompile only.
710bA*  12/22/17  LMC  7.10b
     *    - Enh: Database change to INVHSTD. Recompile only.
     *
     *
     *----------------------------------------------------------------
     *
     *  Notes
     *
     *    - The screen for this program must be compiled with
     *      defer write equal to *NO.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (reverse display)
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpck815fm  cf   e             workstn usropn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Finvpage   uf   e           k disk
     Finvslot1  uf   e           k disk
700aAFinvinuse  if   e           k disk
700bDF*icdcntd   uf   e           k disk
700bAFinvhstd   uf   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     *----------------------------------------------------------------
     D $msgf           s             10
     D $pmsg           s              4
     D $pprg           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D curdte          s              8  0
     D curtme          s              6  0
     D dummy           s              1
     D error           s              1
     D forevr          s              1
     D kywhse          s                   like(ivpwhs)
     D msgk            s              4  0
     D sclear          s              1
700bAD savdpt          s              5
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  eritem                 1     15
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
     *  Workstation exception data structure
     *
     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PJTYP  0 - Batch
     *              1 - Interactive
     *      $PFROM  From quantity
     *      $PTO    To quantity
     *
     *    Returned Parameters
     *      None
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pjtyp            1
     C                   parm                    $pfrom           15 5
     C                   parm                    $pto             15 5
     *----------------------------------------------------------------
     *  Main line
     *
     *  Only work with warehouse 900.
     *
     C                   eval      kywhse = 900
     * Get Inventory In Use #
700bD * moved below need whse first
700bDC*    ikey          chain     invinuse
700bDc*                  if        %found
700bDc*                  eval      icduid = inuuid
700bDc*                  endif
     *
     *  Whip through inventory pages.
     *
     C     keyivp        setll     invpage
     C                   dow       forevr = forevr
     C     keyivp        reade     invpage                                79
     C                   if        *in79
     C                   leave
     C                   endif
700bAC* need to get the invinuse when the department changes
700bA /free
700bA   if savdpt <> ivpwhd;
700bA     chain (kywhse: ivpwhd) invinuse;
700bA     if %found(invinuse);
700bA       icduid = inuuid;
700bA     endif;
700bA     savdpt = ivpwhd;
700bA   endif;
700bA /end-free
     *
     *     Keep user informed.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1page = ivppag
     C                   write     screen1
     C                   endif
     *
     *     Ignore page if alread entered.
     *
     C                   if        ivpsta <> 'P'
     C                   iter
     C                   endif
     *
     *     Update page record.
     *
     C                   eval      ivpsta = 'E'
     C                   eval      ivpedt = curdte
     C                   eval      ivpetm = curtme
     C                   eval      ivpeby = #prog
     C                   update    ivprec
     *
     *     Update corresponding slot records.
     *
     C     keyivs        setll     invslot1
     C                   dow       forevr = forevr
     C     keyivs        reade     invslot1                               79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   eval      ivsqt1 = 0
     C                   eval      ivsqt2 = 0
     C                   eval      ivsqt3 = 0
     *
     *        Generate random quantity if item exists.
     *
     C                   if        ivsitm <> *blanks
     *
     *          Normal quantity.
     *
     C                   call      'RANDOM2'
     C                   parm                    $rseed            9 9
     C                   parm      $pfrom        $rmin             6 0
     C                   parm      $pto          $rmax             6 0
     C                   parm                    $rnum             6 0
     C                   z-add     $rnum         ivsqt1
     *
     *          If item has corresponding SSB . . .
     *            Generate random quantity for breakdown 1 qty.
     *
     C                   call      'CHKSSB'
     C                   parm      ivswhs        $gwhse            3 0
     C                   parm      ivsitm        $gitem           15
     C                   parm                    $gexst            1
     C                   if        $gexst = 'Y'
     C                   call      'RANDOM2'
     C                   parm                    $rseed
     C                   parm      $pfrom        $rmin
     C                   parm      $pto          $rmax
     C                   parm                    $rnum
     C                   z-add     $rnum         ivsqt2
     C                   endif
     C                   endif
     *
     *        Update slot record.
     *
     C                   eval      ivsedt = curdte
     C                   eval      ivsetm = curtme
     C                   eval      ivseby = #prog
     C                   update    ivsrec
     *
700bDC*    dkey          chain     icdcntd
700bMC     dkey          chain     invhstd
700aAC                   if        %found
700aAC                   eval      icdaqty1 = ivsqt1
700aAC                   eval      icdaqty2 = ivsqt2
700aAC                   eval      icdaqty3 = ivsqt3
700aAc                   if        ivsedt > 0
700aAc                   eval      icdslcnt= 'Y'
700aAc                   eval      icdsltts= %timestamp
700aAc                   endif
700aAC                   update    icdrec
700aAc                   endif
     *
     C                   enddo
     *
     C                   enddo
     *
     C                   eval      *inlr = *on
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
     *  Initialize variables
     *
     C                   eval      forevr = *on
     C                   eval      error = *off
     *
     *   Define keys
     *
     C     keyivp        klist
     C                   kfld                    kywhse
     *
     C     keyivs        klist
     C                   kfld                    kywhse
     C                   kfld                    ivppag
700aA*    Cycle Count History Detail
700aAC     dkey          klist
700aAc                   kfld                    icduid
700bAc                   kfld                    ivswhs
700bAc                   kfld                    ivswhd
     c                   kfld                    ivsdsp
700aA*    Inventory In Use
700aAC     ikey          klist
700aAc                   kfld                    kywhse
     *
     *   Open display file if this program is being run interactively.
     *
     C                   if        $pjtyp = *on
     C                   open      pck815fm
     C                   endif
     *
     *   Initialize message handling
     *
     C                   if        $pjtyp = *on
     C                   exsr      zmimsg
     C                   endif
     *
     *   Fool the compiler.
     *
     C                   eval      dummy = *blanks
     C                   if        dummy <> *blanks
     C                   read      pck815fm                               50
     C                   endif
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdte = $cvd8o
     C                   time                    curtme
     *
     C                   eval      $pprg = #prog
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMCPMQ  Clear program message queue.
     *
     C     zmcpmq        begsr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMCSBF  Clear message subfile.
     *
     C     zmcsbf        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr
     *
     *    ZMPMSG  Add message record to subfile
     *
     C     zmpmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   UT81201  Item recalculated successfully.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'UT81201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   UT81221  Item not recalculated - No ITEMQTY record.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'UT81221'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   UT81222  Item not recalculated - Item does not exist.
     *
     C     zm22          begsr
     C                   eval      #msgid = 'UT81222'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   UT81223  Item not recalculated - Error updating ITEMQTY.
     *
     C     zm23          begsr
     C                   eval      #msgid = 'UT81223'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
