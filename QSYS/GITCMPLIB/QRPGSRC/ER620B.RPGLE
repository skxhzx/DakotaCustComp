      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  ER620B    Populate work file.
     *  08 October 2009
     *  Ginger Andrews
     *
     *  Revisions
     *  10/07/09   GJA  5.30
     *  - Created
     *
640a *  05/06/11   GJA  6.40a
     *  - Fix:  Was allowing LBTYPE='A'
     *
     *
     *----------------------------------------------------------------
     Fer620a    ip   e           k disk
     Fer6201    uf a e           k disk
     F                                     rename(wkrec:wkrec1)
     Ftask      if   e           k disk
     Fshift     if   e           k disk
     Fer620     uf a e           k disk
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
     C     erkey         chain     er620                              78
     C                   if        *in78
     *
     C                   eval      wktrn# = pttrn#
     C                   eval      wkstat = ptstat
     C                   eval      wktask = pttask
     C                   eval      wkcat = ptcat
     C                   eval      wksub = ptsub
     C                   eval      wkwhse = ptwhse
     C                   eval      wkwhdp = lbwhdp
     C                   eval      wkstyp = lbstyp
     C                   eval      wkshft = ptshft
     C                   eval      wkcrew = ptcrew
     C                   eval      wkemp# = ptemp#
     C                   If        wktask = 'RUNNER' or wktask = 'VERIFY'
     C                   eval      wkpcs = ptpcs
     C                   eval      wkcube = ptcube
     C                   eval      wkswgt = ptswgt
     C                   else
640aAC                   if        lbtype <> 'A'
     C                   eval      wkpcs = lbqpck
     C                   eval      wkcube = lbcube
     C                   eval      wkswgt = lbswgt
640aAC                   endif
     C                   endif
     C                   eval      wkaisl = ptaisl
     C                   eval      wkqty1 = ptqty1
     C                   eval      wkqty2 = ptqty2
     C                   eval      wkqty3 = ptqty3
     C                   eval      wkgdte = ptgdte
     C                   eval      wkgtim = ptgtim
     C                   eval      wksdte = ptsdte
     C                   eval      wkstim = ptstim
     C                   eval      wkedte = ptedte
     C                   eval      wketim = ptetim
     C                   eval      wketyp = ptetyp
     C                   eval      wkcdte = ptcdte
     C                   eval      wkctim = ptctim
     C                   eval      wkrdte = ptrdte
     C                   eval      wkimin = ptimin
     C                   eval      wkrtpo = ptrtpo
     C                   eval      wkgrp1 = ptgrp1
     C                   eval      wkgrp2 = ptgrp2
     C                   else
     C                   If        wktask <>'RUNNER' and wktask <> 'VERIFY'
640aAC                             and lbtype <> 'A'
     C                   eval      wkcube += lbcube
     C                   eval      wkswgt += lbswgt
     C                   eval      wkpcs  += lbqpck
     C                   endif
     C                   eval      wkqty1 += ptqty1
     C                   eval      wkqty2 += ptqty2
     C                   eval      wkqty3 += ptqty3
     C                   update    wkrec
     C                   goto      skip
     C                   endif
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
     C     svtrn#        chain     er6201                             79
     C                   if        not *in79
     C                   add       ptcube        wkcube
     C                   add       ptswgt        wkswgt
     C                   add       lbqpck        wkpcs
     C                   add       ptqty1        wkqty1
     C                   add       ptqty2        wkqty2
     C                   add       ptqty3        wkqty3
     C                   add       ptdmin        wkdmin
     C                   update    wkrec1
     C                   endif
     * Idle task - Save the time to be added to the next direct task.
     C                   when      pttask = 'IDLE'
     C                   add       ptdmin        svidle
     C                   eval      wkdmin = ptdmin
     C                   write     wkrec
     * Direct task other than 'IDLE' - Add idle time from the previous
     *                                 'IDLE' task to this task.
     C                   when      pttask <> 'IDLE'  and
     C                             tktype <> 'I'
     C                   add       svidle        ptdmin
     C                   eval      svidle = 0
     C                   eval      svtrn# = pttrn#
     C                   eval      wkdmin = ptdmin
     C                   write     wkrec
     *
     * Indirect task - add the idle time to the previous direct task.
     C                   when      pttask <> 'IDLE'  and
     C                             tktype = 'I'
     C                   eval      wkdmin = ptdmin
     C                   write     wkrec
     C*    svtrn#        chain     er6201                             79
     C*                  if        not *in79
     C*                  add       svidle        wkdmin
     C*                  update    wkrec1
     C*                  endif
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
     C*Lr   svtrn#        chain     er6201                             79
     C*Lr                 if        not *in79
     C*Lr                 add       svidle        wkdmin
     C*Lr                 update    wkrec1
     C*Lr                 endif
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
     C     erkey         klist
     C                   kfld                    ptemp#
     C                   kfld                    ptsdte
     C                   kfld                    ptstim
     C                   kfld                    pttrn#
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
