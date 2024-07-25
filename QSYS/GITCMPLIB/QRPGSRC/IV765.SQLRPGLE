     *----------------------------------------------------------------
     *   Copyright (C) 1996 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IV765     Clear Slot files for SI255 Host count - Traffic cop
     *  26 January 2006
     *  Roxanne Harrison
     *
     *  Revisions
     *    01/26/06  RH   5.00
     *      - Created using IV505
     *    06/30/03  RH   5.10A
     *      - Fix - Was not clearing SLOT file for dept *ALL.
     *
     *----------------------------------------------------------------
     *
     *  Notes
     *
     *    - The screen for this program must be compiled with
     *      defer write equal to *NO and share equal to *YES.
     *    - Program process *INVSLOT batch from status 1 thru 9.
     *      For *CLEARF cmd, will create batch at status 4 so IV765
     *      will start at phase 4. If *CLEARF batch fails, can be
     *      restarted in IV760 and will start at phase 4 again.
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
     Fiv765fm   cf   e             workstn usropn
     Fbatctl    uf a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D a90             s              1    dim(90)
     D cmline          s             73    dim(2) ctdata perrcd(1)
     D*cmline          s             90    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
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
     * VARIABLES
     *----------------------------------------------------------------
     D $cpyf           s             10
     D $cpyt           s             10
     D $msgf           s             10
     D $retrn          s              8
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D bflag           s              1
     D error           s              1
     D msgk            s              4  0
     D stat            s              1
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
     *      $PCMD   *INVSLOT - Process files for host count.
     *              *RESTART - Restart abnormally ended batch.
     *              *CLEARF  - Restart at phase4 to retry FTP.
     *      $PWHSE  Warehouse
416  *      $PWHDP  Department
     *      $PBAT   Batch number for *RESTART.
     *      $PSTAT  Status for *RESTART.
     *      $PJOBQ  Placed on jobq (Y,N).
     *
     *    Returned Parameters
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pwhse            3 0
416a C                   parm                    $pwhdp            5
     C                   parm                    $pbat             7 0
     C                   parm                    $pstat            1
     C                   parm                    $pjobq            1
     C                   parm                    $prtn             8
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     *
     * Get out if a valid command wasn't sent to us.
     *
     C                   if        $pcmd <> '*INVSLOT'  and
     C                             $pcmd <> '*RESTART'  and
     C                             $pcmd <> '*CLEARF '
     C                   eval      $prtn = '*ERROR  '
     C                   goto      endpgm
     C                   endif
     *
     * Go and pick the orders.
     *
     C                   exsr      post
     C                   eval      $prtn = $retrn
     *
     * If error occured during picking display error screen.
     *
     C                   if        $retrn = '*ERROR  '
     ******               MOVE $MSGID    #MSGK
     C                   exsr      zmqmsg
     C                   exsr      zmdmsg
     C                   eval      *in98 = *on
     C                   if        $pjobq <> 'Y'
     C                   exfmt     screen2
     C                   endif
     C                   endif
     *
     * End of the picking process.
     *
     C     endpgm        tag
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
     C                   eval      #pgmq = #prog
     C                   eval      $cpyf = *blanks
     C                   eval      $cpyt = *blanks
     *
     *  Initialize variables
     *
     C                   eval      $retrn = *blanks
     C                   eval      error = *off
     *
408 A*  Define keys.
408 A*
408 A*    INVSLOT file (Partial key)
     *
408 AC     keyivs        klist
408 AC                   kfld                    $pwhse
     *
     *  Open workstation file if not on JOBQ.
     *
     C                   if        $pjobq <> 'Y'
     C                   open      iv765fm
     C                   exsr      zmcpmq
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  POST    Post inventory counts.
     *
     C     post          begsr
     *
     C                   eval      bflag = *off
     C                   eval      $retrn = *blanks
     *
     *      Display informational screen.
     *
     C                   if        $pjobq <> 'Y'
     C                   write     screen1
     C                   endif
     *
     *
     *      If this is not a restart or fTPclear then start at phase 1.
     *
     C     $pcmd         cabne     '*RESTART'    phase1
     *
     *      Otherwise, skip to the phase where the restarted batch
     *      left off.
     *
     C     $pstat        cabeq     '1'           phase1
     C     $pstat        cabeq     '2'           phase2
     C     $pstat        cabeq     '3'           phase3
     C     $pstat        cabeq     '4'           phase4
     **         $PSTAT    CABEQ'5'       PHASE5
     *
     *     Phase 1 - Copy SLOT to SLOT99 and VSLOT to VSLOT99
     *
     C     phase1        tag
     C                   eval      stat = *on
     C                   exsr      updctl
     **                   EXSR ZM21
     *    If this is a fTPclear then start at phase 4 after creating batch
     C     $pcmd         cabeq     '*CLEARF '    phase4
     C/EXEC SQL
     C+  delete from slot99
     C/END-EXEC
     *
     C/EXEC SQL
     C+  delete from vslot99
     C/END-EXEC
     *
     *          CPYF FROFILE(SLOT) TOFILE(SLOT99) CRTFILE(*NO)
     *                  FMTOPT(*NOCHK)
     *
     C                   movel     '        '    $cpyf
     C                   movel     '        '    $cpyt
     C                   movel     'SLOT   '     $cpyf
     C                   movel     'SLOT99 '     $cpyt
     C                   movea     cmline(1)     a90
     C                   movea     cmline(2)     a90(74)
     C                   movea     $cpyf         a90(15)
     C                   movea     $cpyt         a90(34)
     C                   movea     a90           qcmd
     *
     C                   call      'QCMDEXC'                            78
     C                   parm                    qcmd             90
     C                   parm      90            qlen             15 5
     C*                  parm      80            qlen             15 5
     *     CHECK FOR ERROR
     C                   if        *in78
     C                   eval      $retrn = '*ERROR  '
     C                   endif
     C     *in78         cabeq     *on           skip1
     *
     *          CPYF FROFILE(VSLOT) TOFILE(VSLOT99) CRTFILE(*NO)
     *                  FMTOPT(*NOCHK)
     *
     C                   movel     '        '    $cpyf
     C                   movel     '        '    $cpyt
     C                   movel     'VSLOT   '    $cpyf
     C                   movel     'VSLOT99 '    $cpyt
     C                   movea     cmline(1)     a90
     C                   movea     $cpyf         a90(15)
     C                   movea     $cpyt         a90(34)
     C                   movea     a90           qcmd
     *
     C                   call      'QCMDEXC'                            78
     C                   parm                    qcmd
     C                   parm      90            qlen
     *     CHECK FOR ERROR
     C                   if        *in78
     C                   eval      $retrn = '*ERROR  '
     C                   endif
     C     *in78         cabeq     *on           skip1
     *
     *     Phase 2 - Copy SSLOT to SSLOT99 and SVSLOT to SVSLOT99
     *
     C     phase2        tag
     C                   eval      stat = '2'
     C                   exsr      updctl
     **                   EXSR ZM22
     C/EXEC SQL
     C+  delete from sslot99
     C/END-EXEC
     *
     C/EXEC SQL
     C+  delete from svslot99
     C/END-EXEC
     *
     *          CPYF FROFILE(SSLOT) TOFILE(SSLOT99) CRTFILE(*NO)
     *                  FMTOPT(*NOCHK)
     *
     C                   movel     '        '    $cpyf
     C                   movel     '        '    $cpyt
     C                   movel     'SSLOT  '     $cpyf
     C                   movel     'SSLOT99'     $cpyt
     C                   movea     cmline(1)     a90
     C                   movea     $cpyf         a90(15)
     C                   movea     $cpyt         a90(34)
     C                   movea     a90           qcmd
     *
     C                   call      'QCMDEXC'                            78
     C                   parm                    qcmd
     C                   parm      90            qlen
     *     CHECK FOR ERROR
     C                   if        *in78
     C                   eval      $retrn = '*ERROR  '
     C                   endif
     C     *in78         cabeq     *on           skip1
     *
     *          CPYF FROFILE(SVSLOT) TOFILE(SVSLOT99) CRTFILE(*NO)
     *                  FMTOPT(*NOCHK)
     *
     C                   movel     '        '    $cpyf
     C                   movel     '        '    $cpyt
     C                   movel     'SVSLOT '     $cpyf
     C                   movel     'SVSLOT99'    $cpyt
     C                   movea     cmline(1)     a90
     C                   movea     $cpyf         a90(15)
     C                   movea     $cpyt         a90(34)
     C                   movea     a90           qcmd
     *
     C                   call      'QCMDEXC'                            78
     C                   parm                    qcmd
     C                   parm      90            qlen
     *     CHECK FOR ERROR
     C                   if        *in78
     C                   eval      $retrn = '*ERROR  '
     C                   endif
     C     *in78         cabeq     *on           skip1
     *
     *     Phase 3 - Clear SSLOT and SVSLOT
     *             - Copy SLOT to SSLOT and VSLOT to SVSLOT
     *
     C     phase3        tag
     C                   eval      stat = '3'
     C                   exsr      updctl
     C                   exsr      zm21
     *
     C/EXEC SQL
     C+  delete from sslot
     C/END-EXEC
     *
     C/EXEC SQL
     C+  delete from svslot
     C/END-EXEC
     *
     *      Copy SLOT and VSLOT files
     *          CPYF FROFILE(SLOT) TOFILE(SSLOT) CRTFILE(*NO)
     *                  FMTOPT(*NOCHK)
     *
     C                   movel     '        '    $cpyf
     C                   movel     '        '    $cpyt
     C                   movel     'SLOT   '     $cpyf
     C                   movel     'SSLOT  '     $cpyt
     C                   movea     cmline(1)     a90
     C                   movea     $cpyf         a90(15)
     C                   movea     $cpyt         a90(34)
     C                   movea     a90           qcmd
     *
     C                   call      'QCMDEXC'                            78
     C                   parm                    qcmd
     C                   parm      90            qlen
     *     CHECK FOR ERROR
     C                   if        *in78
     C                   eval      $retrn = '*ERROR  '
     C                   endif
     C     *in78         cabeq     *on           skip1
     *          CPYF FROFILE(VSLOT) TOFILE(SVSLOT) CRTFILE(*NO)
     *                  FMTOPT(*NOCHK)
     *
     C                   movel     '        '    $cpyf
     C                   movel     '        '    $cpyt
     C                   movel     'VSLOT  '     $cpyf
     C                   movel     'SVSLOT '     $cpyt
     C                   movea     cmline(1)     a90
     C                   movea     $cpyf         a90(15)
     C                   movea     $cpyt         a90(34)
     C                   movea     a90           qcmd
     *
     C                   call      'QCMDEXC'                            78
     C                   parm                    qcmd
     C                   parm      90            qlen
     *     CHECK FOR ERROR
     C                   if        *in78
     C                   eval      $retrn = '*ERROR  '
     C                   endif
     C     *in78         cabeq     *on           skip1
     *
     *
     *     Phase 4 - REMOVE VIRTUAL SLOTS FROM VSLOT AND SLOT FILES
     *
     C     phase4        tag
     C                   eval      stat = '4'
     C                   if        $pcmd <> '*CLEARF '
     C                   exsr      updctl
     C                   exsr      zm22
     C                   endif
     *     For whole warehouse.
510A C*                  if        $pwhdp = *blanks
510A C                   if        $pwhdp = '*ALL'
     C/EXEC SQL
     C+  delete from vslot
     C+  where  (vswhse = :$pwhse)
     C/END-EXEC
     *
     C/EXEC SQL
     C+  delete from slot
     C+  where  (slwhse = :$pwhse and slrsrv = 'V')
     C/END-EXEC
     *
     C/EXEC SQL
     C+  update slot
     C+  set slstk1=0, slstk2=0, slstk3=0,
     C+  slalc1=0, slalc2=0, slalc3=0,
     C+  sltfr1=0, sltfr2=0, sltfr3=0,
     C+  slpck1=0, slpck2=0, slpck3=0,
     C+  slrcv1=0, slrcv2=0, slrcv3=0
510A C+  where  (slwhse = :$pwhse)
510A C** where  (slwhse = :$pwhse and slrsrv = 'V')
     C/END-EXEC
     *
     C/EXEC SQL
     C+  update slot
     C+  set slitem = ' ', slstat = 'V '
     C+  where  (slwhse = :$pwhse and slpick = 'N')
     C/END-EXEC
     *
     *     For ONE department.
     C                   else
     C/EXEC SQL
     C+  delete from vslot
     C+  where  (vswhse = :$pwhse and vswhdp = :$pwhdp)
     C/END-EXEC
     *
     C/EXEC SQL
     C+  delete from slot
     C+  where  (slwhse = :$pwhse and slwhdp = :$pwhdp and slrsrv = 'V')
     C/END-EXEC
     *
     C/EXEC SQL
     C+  update slot
     C+  set slstk1=0, slstk2=0, slstk3=0,
     C+  slalc1=0, slalc2=0, slalc3=0,
     C+  sltfr1=0, sltfr2=0, sltfr3=0,
     C+  slpck1=0, slpck2=0, slpck3=0,
     C+  slrcv1=0, slrcv2=0, slrcv3=0
     C+  where  (slwhse = :$pwhse and slwhdp = :$pwhdp)
     C/END-EXEC
     *
     C/EXEC SQL
     C+  update slot
     C+  set slitem = ' ', slstat = 'V '
     C+  where  (slwhse = :$pwhse and slwhdp = :$pwhdp and slpick = 'N')
     C/END-EXEC
     *
     C                   endif
     *****      $RETRN    CABEQ'*ERROR  'SKIP1
     *
     *
     C     skip1         tag
     *
     *  Mark batch as finished if no error occured.
213 A*  Clear inventory work files if no error occured.
     *
     C                   if        $retrn <> '*ERROR  '  and
     C                             bflag = *on
     C                   eval      stat = '9'
     C                   exsr      updctl
     C                   endif
     *
     C     endpst        endsr
     *----------------------------------------------------------------
     *
     *  UPDCTL  Update batch control record. Lock it if necessary.
     *
     C     updctl        begsr
     *
     C**   $pcmd         cabeq     '*CLEARF '    endctl
     *   If this is for phase1 and a new batch ...
     *
     C                   if        stat = '1'  and
     C                             bflag = *off
     *
     *     - Get new batch number.
     *
     C                   call      'PIRBAT#'
     C                   parm                    $pbat
     *
     *     - Create batch control record.
     *
     *  For *CLEARF retry FTP create with status = 4 so batch can be
     *  restarted if does not complete.
     C                   if        $pcmd = '*CLEARF'
     C                   eval      stat = '4'
     C                   endif
     C                   eval      btbat# = $pbat
     C                   eval      btwhse = $pwhse
     C                   eval      btstat = stat
     C                   eval      bttype = '*INVSLOT'
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      btstrd = $cvd8o
     C                   time                    btstrt
     C                   eval      btstrb = #user
     C                   write     btrec
     C                   else
     *
     *   Otherwise, update control record with current phase.
     *     - If finished then mark with time stamp.
     *
     C     $pbat         chain     btrec                              79
     C                   eval      btstat = stat
     C                   if        stat = '9'
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      btendd = $cvd8o
     C                   time                    btendt
     C                   endif
     C                   update    btrec
     C                   endif
     *
     *   Grab control record to let others know a batch is being
     *   processed unless, of course, we are finished.
     *
     C                   if        stat <> '9'
     C     $pbat         chain     btrec                              79
     C                   endif
     C                   eval      bflag = *on
     *
     C     endctl        endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCPMQ  Clear program message queue.
     *
     C     zmcpmq        begsr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   if        $pjobq <> 'Y'
     C                   eval      *in97 = *on
     C                   write     msgctl
     C                   endif
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
413 D**                   WRITEMSGREC
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
413 D**                   WRITEMSGREC
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   IV50021  Updating slot quantities and item numbers
     *
     C     zm21          begsr
     C                   eval      #msgid = 'IV50021'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     *blanks       $md
     C                   exsr      zmpmsg
     C                   exsr      zmdmsg
     C                   exsr      zmcpmq
     C                   endsr
     *----------------------------------------------------------------
     *   IV50022  Updating slot status codes.
     *
     C     zm22          begsr
     C                   eval      #msgid = 'IV50022'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     *blanks       $md
     C                   exsr      zmpmsg
     C                   exsr      zmdmsg
     C                   exsr      zmcpmq
     C                   endsr
     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**   CPYF    statment
CPYF FROMFILE(XXXXXXXXXX) TOFILE(XXXXXXXXXX) CRTFILE(*NO) FMTOPT(*NOCHK)
MBROPT(*REPLACE)
