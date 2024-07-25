      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  ER350A    Populate work file.
     *  28 July, 1999
     *  Hemant Kapadia
     *
     *  NOTE: PTTRAN2 IS IN DESCENDING ORDER OF DATE AND TIME, AND
     *        HENCE WHEN WE READ THE FILE, THE LATEST RECORD WILL BE
     *        READ FIRST.
     *
     *        EXAMPLE: 12/30/98  09:00:00  ENDDAY
     *                 12/30/98  08:45:00  FIXED
     *                 12/30/98  08:30:00  BEGDAY
     *
     *  Revisions
     *  07/28/99  HNK  4.12
     *  - Created
     *
     *  09/18/09   GJA  5.30
     *   -Converted to RPGLE,Revamped to include suspended transaction
     *
     *----------------------------------------------------------------
     Fer350a    ip   e           k disk
     Fer3501    uf a e           k disk
     F                                     rename(errec:errec1)
     Ftask      if   e           k disk
     Fshift     if   e           k disk
     Fer350     o    e           k disk
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
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
     *  OTHER DATA STRUCTURE
     *
     D                 ds
     D  etime                  1      6  0
     D  ehhmm                  1      4  0
     D  ess                    5      6  0
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
     *  Variables
     *
     D $msgf           s             10
     D $pprg           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D begin           s              1
     D begtim          s              6  0
     D daylop          s              4
     D enddte          s              8  0
     D endtim          s              6  0
     D error           s              1
     D first           s              1
     D frmdte          s              8  0
     D msgk            s              4  0
     D sclear          s              1
     D svdisp          s                   like(lbdisp)
     D svdsp2          s                   like(lbdsp2)
     D svemp#          s              5  0
     D svidle          s                   like(ptdmin)
     D svitem          s                   like(lbitem)
     D svtask          s                   like(pttask)
     D svtrn#          s                   like(pttrn#)
     D w1whdp          s              5
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PFMDT - From date
     *      $PENDT - End date (To date + 1)
     *      $PBTIM - Shift begin time
     *      $PETIM - Shift end time
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pfmdt            8
     C                   parm                    $pendt            8
     C                   parm                    $pbtim            6
     C                   parm                    $petim            6
     *----------------------------------------------------------------
     *  Main line
     *
     C                   move      $pfmdt        frmdte
     C                   move      $pendt        enddte
     *
     C                   if        first = *on
     C                   eval      svemp# = ptemp#
     *
     * Begin and time passed in will be zero if this prog is run for
     * a crew.
     *
     C                   if        $pbtim = *blanks
     C                   eval      w1whdp = *blanks
     C     shkey         chain     shift                              79
     C                   if        not *in79
     C                   move      shstim        $pbtim
     C                   move      shetim        $petim
     C                   else
     C                   eval      $pbtim = *blanks
     C                   eval      $petim = *blanks
     C                   endif
     C                   endif
     *
     C                   move      $pbtim        begtim
     C                   move      $petim        endtim
     *
     * Time criteria overlaps two days.  Use overlap selection
     C                   if        endtim < begtim  and
     C                             endtim > 0
     C                   eval      daylop = '*YES'
     C                   else
     C                   eval      daylop = '*NO '
     C                   endif
     *
     C                   eval      first = *off
     C                   endif
     *
     * Note: we are reading file in reverse order of date and time.
     *
     *
     *   Ignore any task after ENDDAY Or ending of the shift time,
     *   if ENDDAY is missing in the transaction file.
     *
     C                   if        begin = *off  and
     C                             pttask <> 'ENDDAY'  and
     C                             ptstim > endtim
     C                   endif
     *
     C                   eval      begin = *on
     *
     *   Getout if we have gone past the begining shift time on begin
     *   day. If we get out from here, it means that BEGDAY task was
     *   not found for this employee for the date range.
     *
     C                   select
     C                   when      daylop = '*YES'
     *    Shift time criteria overlaps two days.
     *    Get out if date/time not in Shift range.
     *
     C                   select
     C                   when      ptsdte = frmdte  and
     C                             ptstim < begtim  or
     *
     C                             ptsdte > frmdte  and
     C                             ptsdte < enddte  and
     C                             ptstim < begtim  and
     C                             ptstim > endtim  or
     *
     C                             ptsdte = enddte  and
     C                             ptstim > endtim
     *
     C                   goto      skip
     *
     C                   endsl
     *
     C                   other
     *
     C                   select
     *
     *    Get out if the start time is not in the Shift date/time rang
     C                   when      begtim <> 0  or
     C                             endtim <> 0
     *
     C                   select
     C                   when      ptsdte >= frmdte  and
     C                             ptsdte <= enddte  and
     C                             ptstim < begtim  or
     *
     C                             ptsdte >= frmdte  and
     C                             ptsdte <= enddte  and
     C                             ptstim > endtim
     *
     C                   goto      skip
     *
     C                   endsl
     C                   endsl
     C                   endsl
     *
     C     pttask        chain     task                               79
     *
     C                   eval      ertrn# = pttrn#
     C                   eval      erstat = ptstat
     C                   eval      ertask = pttask
     C                   eval      ercat = ptcat
     C                   eval      ersub = ptsub
     C                   eval      erwhse = ptwhse
     C                   eval      erwhdp = lbwhdp
     C                   eval      erstyp = lbstyp
     C                   eval      ershft = ptshft
     C                   eval      ercrew = ptcrew
     C                   eval      eremp# = ptemp#
     C                   eval      ercube = ptcube
     C                   eval      erswgt = ptswgt
     C                   eval      erpcs = lbqpck
     C                   eval      eraisl = ptaisl
     C                   eval      erqty1 = ptqty1
     C                   eval      erqty2 = ptqty2
     C                   eval      erqty3 = ptqty3
     C                   eval      ergdte = ptgdte
     C                   eval      ergtim = ptgtim
     C                   eval      ersdte = ptsdte
     C                   eval      erstim = ptstim
     C                   eval      eredte = ptedte
     C                   eval      eretim = ptetim
     C                   eval      eretyp = ptetyp
     C                   eval      ercdte = ptcdte
     C                   eval      erctim = ptctim
     C                   eval      errdte = ptrdte
     C                   eval      erimin = ptimin
     C                   eval      errtpo = ptrtpo
     C                   eval      ergrp1 = ptgrp1
     C                   eval      ergrp2 = ptgrp2
     *
     C                   select
     * If this a REPLTF task and the item and from & to slots are the
     * as the last transaction, update pcs etc in ER350 for the first
     * transaction of the series, rather than writing a new record for
     * transaction, as it represents a scamming technique by the user
     * get credit for multiple trans when they should have only create
     C                   when      pttask = 'REPLTF'  and
     C                             svtask = 'REPLTF'  and
     C                             lbtrn# <> svtrn#  and
     C                             lbdisp = svdisp  and
     C                             lbdsp2 = svdsp2  and
     C                             lbitem = svitem
     C     svtrn#        chain     er3501                             79
     C                   if        not *in79
     C                   add       ptcube        ercube
     C                   add       ptswgt        erswgt
     C                   add       lbqpck        erpcs
     C                   add       ptqty1        erqty1
     C                   add       ptqty2        erqty2
     C                   add       ptqty3        erqty3
     C                   add       ptdmin        erdmin
     C                   update    errec1
     C                   endif
     * Idle task - Save the time to be added to the next direct task.
     C                   when      pttask = 'IDLE'
     C                   add       ptdmin        svidle
     C                   eval      erdmin = ptdmin
     C                   write     errec
     * Direct task other than 'IDLE' - Add idle time from the previous
     *                                 'IDLE' task to this task.
     C                   when      pttask <> 'IDLE'  and
     C                             tktype <> 'I'
     C                   add       svidle        ptdmin
     C                   eval      svidle = 0
     C                   eval      svtrn# = pttrn#
     C                   eval      erdmin = ptdmin
     C                   write     errec
     *
     * Indirect task - add the idle time to the previous direct task.
     C                   when      pttask <> 'IDLE'  and
     C                             tktype = 'I'
     C                   eval      erdmin = ptdmin
     C                   write     errec
     C     svtrn#        chain     er3501                             79
     C                   if        not *in79
     C                   add       svidle        erdmin
     C                   update    errec1
     C                   endif
     C                   endsl
     *
     *   Getout when you come to BEGDAY
     *
     C                   if        pttask = 'BEGDAY'  or
     C                             ptemp# <> svemp#
     C                   eval      svemp# = ptemp#
     C                   eval      begin = *off
     C                   endif
     *
     C                   eval      svtask = pttask
     C                   eval      svdisp = lbdisp
     C                   eval      svdsp2 = lbdsp2
     C                   eval      svitem = lbitem
     *
     C     skip          tag
     *
     CLr   svtrn#        chain     er3501                             79
     CLr                 if        not *in79
     CLr                 add       svidle        erdmin
     CLr                 update    errec1
     CLr                 endif
     CLr                 return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      error = *off
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   eval      msgk = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
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
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   eval      sclear = *on
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
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK  Select task
     *
     C     zzchk         begsr
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   eval      svidle = 0
     C                   eval      svtrn# = 0
     C                   eval      svdisp = *blanks
     C                   eval      svdsp2 = *blanks
     C                   eval      svitem = *blanks
     C                   eval      svtask = *blanks
     *
     C     shkey         klist
     C                   kfld                    ptwhse
     C                   kfld                    w1whdp
     C                   kfld                    ptshft
     *
     C                   eval      begin = *off
     C                   eval      first = *on
     C                   eval      $pprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     C     endupd        endsr
