     *----------------------------------------------------------------
     *   Copyright (C) 1999 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PCK145    Initialize slots for whse 900 rcv test - Init
     *  10 June 1999
     *  Dave Sommerville
     *
     *  Revisions
     *
413 A*    02/10/00  DAS  4.13
     *      - Added logic to delete virtual slots.
     *      - Added logic to initialize dates, times and priority.
     *
520aA*    02/27/09  DAS  5.20
     *      - Revised to update Entered date.
     *
730aA*    09/03/19  DAS  7.30
     *      - Converted to ILE
     *      - Added warehouse.
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
     Fpck145fm  cf   e             workstn usropn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fslot1     uf   e           k disk
     Fitemqty   uf   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
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
     *  Variables
     *
     D $msgf           s             10
     D $pmsg           s              4
     D $pprg           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D dummy           s              1
     D error           s              1
     D forevr          s              1
     D kywhse          s                   like(slwhse)
     D lstasl          s              3
     D msgk            s              4  0
520aAD offset          s              3  0
     D runtim          s              6  0
     D savitm          s             15
     D sclear          s              1
     D temp3a          s              3
     D today           s              8  0
730aAD i               s              3  0

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D today2          s               d
     D tmpDate         s               d

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PJTYP  0 - Batch
     *              1 - Interactive
     *      $POPT   Quantity Option
     *                1 = Init all slot to zero
     *                2 = Fill all home slots
     *                3 = Partially fill home slots
730aA*      $PWHSEA Warehouse
     *
     *    Returned Parameters
     *      None
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pjtyp            1
     C                   parm                    $popt             1
730aAC                   parm                    $pwhsea           3
     *----------------------------------------------------------------
     *  Main line
     *
520aAC                   eval      today2 = %date()
     *
     *  Only work with warehouse 900.
730aA*  Now use sent warehouse
     *
730aDC**                 eval      kywhse = 900
      /free
730aM    kywhse = %dec($pwhsea: 3: 0);
730aA    if kywhse < 900;
730aA      dsply 'Whse must be 900+';
730aA      return;
730aA     endif;
      /end-free
     *
     *  Clear all item warehouse totals.
     *
     C                   exsr      clrttl
     *
     *  Create initialize slots.
     *
     C                   eval      lstasl = *blanks
     C     keywh         setll     slot1
     C                   dou       forevr <> forevr
     C     keywh         reade     slot1                                  79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *      Keep user informed if running interactively.
     *
     C                   if        $pjtyp = *on  and
     C                             slaisl <> lstasl
     C                   eval      w1aisl = slaisl
     C                   write     screen1
     C                   eval      lstasl = slaisl
     C                   endif
     *
     *      Initialize slot record.
     *
     *        Delete crossdock slots.
     *
     C                   select
     C                   when      slaisl = 'XDK'
     C                   delete    slrec
520aAC                   iter
413 A*
413 A*        Delete virtual slots.
413 A*
413 AC                   when      slrsrv = 'V'
413 AC                   delete    slrec
520aAC                   iter
     *
     *        Special handling for breakdown slots.
     *
     C                   when      sldisp = 'DC-101-1'  or
     C                             sldisp = 'DC-102-1'  or
     C                             sldisp = 'FC-101-1'  or
     C                             sldisp = 'FC-102-1'  or
     C                             sldisp = 'PC-101-1'  or
     C                             sldisp = 'PC-102-1'  or
     C                             sldisp = 'RC-101-1'  or
     C                             sldisp = 'RC-102-1'
     C                   exsr      initbk
     C                   other
     C                   exsr      initsl
411 AC                   endsl
520aAC                   exsr      setentd
     C                   update    slrec                                78
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
     C     keywh         klist
     C                   kfld                    kywhse
     *
     *   Open display file if this program is being run interactively.
     *
     C                   if        $pjtyp = *on
     C                   open      pck145fm
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
     C                   read      pck145fm                               50
     C                   endif
     *
413 A*  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     C                   time                    runtim
     *
     C                   eval      $pprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CLRTTL  Clear warehouse totals.
     *
     C     clrttl        begsr
     *
     *   Keep user informed if running interactively.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1aisl = 'CLR'
     C                   write     screen1
     C                   eval      lstasl = slaisl
     C                   endif
     *
     *   Clear quantities in ITEMQTY records.
     *
     C     keywh         setll     itemqty
     C                   dou       forevr <> forevr
     C     keywh         reade     itemqty                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   eval      savitm = iqitem
     C                   clear                   iqrec
     C                   eval      iqwhse = kywhse
     C                   eval      iqitem = savitm
     C                   update    iqrec                                78
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  INITBK  Initialize breakdown item slot.
     *
     C     initbk        begsr
     *
     *   Item number.
     *
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd             8
     C                   parm      slaisl        $cstr            30
     C                   movel(p)  $cstr         slitem
     C                   move      slloc         temp3a
     C     slitem        cat       temp3a:0      slitem
     C     slitem        cat       'B':0         slitem
     *
     *   Reserved.
     *
     C                   if        slstyp = 'F'  and
     C                             slpick = 'Y'
     C                   eval      slrsrv = 'Y'
     C                   endif
     *
     *   Quantities.
     *
     C                   eval      slstk1 = 0
     C                   eval      slstk2 = 0
     C                   eval      slstk3 = 0
     C                   eval      slalc1 = 0
     C                   eval      slalc2 = 0
     C                   eval      slalc3 = 0
     C                   eval      sltfr1 = 0
     C                   eval      sltfr2 = 0
     C                   eval      sltfr3 = 0
     C                   eval      slpck1 = 0
     C                   eval      slpck2 = 0
     C                   eval      slpck3 = 0
     C                   eval      slrcv1 = 0
     C                   eval      slrcv2 = 0
     C                   eval      slrcv3 = 0
     *
     *   Init Stat and Qty according to user option.
     *
     C                   select
     C                   when      $popt = '1'
     C                   if        slstyp = 'F'  and
     C                             slpick = 'Y'
     C                   eval      slstat = 'A '
     C                   else
     C                   eval      slitem = *blanks
     C                   eval      slstat = 'V '
     C                   endif
     C                   when      $popt = '2'
     C                   if        slstyp = 'F'  and
     C                             slpick = 'Y'
     C                   eval      slstat = 'A '
     C                   eval      slstk1 = 4
     C                   else
     C                   eval      slitem = *blanks
     C                   eval      slstat = 'V '
     C                   endif
     C                   when      $popt = '3'
     C                   if        slstyp = 'F'  and
     C                             slpick = 'Y'
     C                   eval      slstat = 'A '
     C                   eval      slstk1 = 3
     C                   else
     C                   eval      slitem = *blanks
     C                   eval      slstat = 'V '
     C                   endif
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  INITSL  Initialize slot fields.
     *
     C     initsl        begsr
     *
     *   Item number.
     *
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd
     C                   parm      slaisl        $cstr
     C                   movel(p)  $cstr         slitem
     C                   move      slloc         temp3a
     C     slitem        cat       temp3a:0      slitem
     *
     *   Reserved.
     *
     C                   if        slstyp = 'F'  and
     C                             slpick = 'Y'
     C                   eval      slrsrv = 'Y'
     C                   endif
     *
     *   Quantities.
     *
     C                   eval      slstk1 = 0
     C                   eval      slstk2 = 0
     C                   eval      slstk3 = 0
     C                   eval      slalc1 = 0
     C                   eval      slalc2 = 0
     C                   eval      slalc3 = 0
     C                   eval      sltfr1 = 0
     C                   eval      sltfr2 = 0
     C                   eval      sltfr3 = 0
     C                   eval      slpck1 = 0
     C                   eval      slpck2 = 0
     C                   eval      slpck3 = 0
     C                   eval      slrcv1 = 0
     C                   eval      slrcv2 = 0
     C                   eval      slrcv3 = 0
     *
413 A*   Dates
     *
     C                   eval      slsdte = today
     C                   eval      slstim = runtim
     C                   eval      slentd = 0
     C                   eval      slexpd = 0
     C                   eval      slslfd = 0
     C                   eval      slprty = 0
     *
     *   Init Stat and Qty according to user option.
     *
     C                   select
     C                   when      $popt = '1'
     C                   if        slstyp = 'F'  and
     C                             slpick = 'Y'
     C                   eval      slstat = 'A '
     C                   else
     C                   eval      slitem = *blanks
     C                   eval      slstat = 'V '
     C                   endif
     C                   when      $popt = '2'
     C                   if        slstyp = 'F'  and
     C                             slpick = 'Y'
     C                   eval      slstat = 'A '
     C                   eval      slstk1 = 50
     C                   else
     C                   eval      slitem = *blanks
     C                   eval      slstat = 'V '
     C                   endif
     C                   when      $popt = '3'
     C                   if        slstyp = 'F'  and
     C                             slpick = 'Y'
     C                   eval      slstat = 'A '
     C                   eval      slstk1 = 30
     C                   else
     C                   eval      slitem = *blanks
     C                   eval      slstat = 'V '
     C                   endif
     C                   endsl
     *
     C                   endsr
520aA*----------------------------------------------------------------
520aA*
520aA*  SETENTD   Set Entered date.
520aA*
520aAC     setentd       begsr

     *

     C                   if        slpick = 'Y'

     C                   eval      offset = 20

     C                   else

     C                   call      'RANDOM2'
413aAC                   parm                    $rseed            9 9
413aAC                   parm      1             $rmin             6 0
413aAC                   parm      19            $rmax             6 0
413aAC                   parm                    $rnum             6 0
     C                   eval      offset = 20 - $rnum

     C                   endif

     C                   eval      tmpDate = today2 - %days(offset)
     C                   eval      slentd = %dec(
     C                                      %char(tmpDate:*iso0)
     C                                      :8:0)

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
