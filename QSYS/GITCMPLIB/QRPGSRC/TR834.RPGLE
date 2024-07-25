     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TR834   Tracker - Returns - Delete or close by item, stop,
     *                              breakdown flag, and return code.
     *  17 February 2010
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    02/17/10  RBD  5.30
     *      - Created
     *
640aA*    09/20/11  RBD  6.40a
     *      - Recompiled because of change to TTRTN file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        CHAIN INDICATOR
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fttrtn2    uf   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D msg             s             50    dim(2) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
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
     D  $pstat                22     22
     D  $prte                 23     27
     D  $prtid                28     32
     D  $pitem                33     47
     D  $pstop                48     49  0
     D  $pbflg                50     50
     D  $p$bflg               51     51
     D  $prcod                52     53
     D  $plbl                 54     60  0
     D  $pqty                 61     65  0
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
     D  ertnum                 1      4p 0
     D  erdesc                 5     24
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     D $msgf           s             10
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  Working variables
     *
     D error           s              1
     D forevr          s              1
     D kystat          s              1
     D qtyCountDown    s              5  0
     D qtyOpen         s              5  0
     D rte_id_itm      s             35
     D today           s              8  0
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
     *      $PCMD   *CLOSE   - Change status to 5 = Closed.
     *              *DELETE  - Change status to 9 = Deleted.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for delete.
     *
     *    Returned Parameters
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *              *OK      - Record deleted successfully.
     *                         Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     *----------------------------------------------------------------
     *  Main line
     *
     C                   exsr      zzinz2
     *
     *   Delete Tracker return records.
     *
     C                   eval      qtyCountDown = $pqty
     *
     C     fileky        setll     ttrtn2
     C                   dow       forevr = forevr
     C     fileky        reade     ttrtn2                               7879
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *     If record is locked then send message back and abort.
     *
     C                   if        *in78
     C                   exsr      zm75
     C                   eval      $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   leave
     C                   endif
     *
     *   Trax returns are processed at the item/stop/brkdwn flag/rtn code/label
     *   level.  Be aware that the label value may not be uploaded, thus the need
     *   for all of these fields.  The UCI value may not be uploaded either.
     *   So a Trax return displayed with a qty of 10, could correspond
     *   to 10 Trax return records or 1, depending on how many ORDP records
     *   were created & returned for the line item.  So the logic to upd and close
     *   Trax return recs must upd and close the appropriate number of recs.
     *
     *   For example : if a qty of 10 is returned on a single Trax record, there
     *   will only be 1 record to update and/or close.  Update the ttpqty with
     *   qty returned in RN250.  Once the ttpqty is >= ttoqty the status should
     *   be closed.
     *
     *   If 10 Trax returns records exist for the same item/stop/
     *   brkdwn flag/rtn code/label they would each have a different UCI and
     *   would be displayed in TR830 as 1 line with a qty of 10.  Then, let's
     *   say the user only returns 8 in RN250 ... 8 of those Trax return recs
     *   will need to have ttpqty updated and status closed ... 2 recs would
     *   remain at open status.
     *
     C                   select
     *
     C                   when      $pcmd = '*DELETE '
     C                   eval      ttstat = '9'
     *
     C                   when      $pcmd = '*CLOSE  '
     C                   eval      qtyOpen = ttoqty - ttpqty
     C                   select
     *
     *  qtyOpen at this point should never be 0, if it were, the
     *  status should be 9, not 1.  So if this happens, there's
     *  nothing more to do with this record.
     C                   when      qtyOpen = 0
     *
     *  If there's still qty open after this return, update the
     *  qty processed, leave the status open, and you're done.
     C                   when      qtyOpen > qtyCountDown
     C                   eval      ttpqty = ttpqty + qtyCountDown
     C                   eval      qtyCountDown = 0
     C
     *  If the open qty <= the qty countdown, update the qty processed,
     *  change the status to closed, and reduce the qty countdown.
     C                   other
     C                   eval      ttpqty = ttpqty + qtyOpen
     C                   eval      qtyCountDown = qtyCountDown - qtyOpen
     C                   eval      ttstat = '5'
     *
     C                   endsl
     *
     C                   endsl
     *
     C                   eval      ttstsd = today
     C                   time                    ttstst
     C                   update    ttrec
     *
     C                   if        qtyCountDown = 0
     C                   leave
     C                   endif
     *
     C                   enddo
     *
     C                   if        error = *off
     C                   exsr      zzok
     C                   endif
     *
     C                   return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     C                   parm                    cliloc           10
     *
     C                   eval      forevr = *off
     *
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
     *     PIR7975  Error while deleting record.
     *
     C     zm75          begsr
     C                   eval      #msgid = 'PIR7975'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR9803  Deleted record successfully.
     *
     C     zm9803        begsr
     C                   eval      #msgid = 'PIR9803'
     C                   eval      #msgtp = '*DIAG  '
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR9999  Generic msg.
     *
     C     zm9999        begsr
     C                   eval      #msgid = 'PIR9999'
     C                   eval      #msgtp = '*DIAG  '
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization called from mainline.
     *
     C     zzinz2        begsr
     *
     *  Define key for main file.
     *
     C                   eval      kystat = '1'
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    kystat
     C                   kfld                    $prte
     C                   kfld                    $prtid
     C                   kfld                    $pitem
     C                   kfld                    $pstop
     C                   kfld                    $pbflg
     C                   kfld                    $prcod
     C                   kfld                    $plbl
     *
     C                   eval      error  = *off
     *
     C                   eval      rte_id_itm = %Trim($prte)
     C                                + '/'
     C                                + $prtid
     C                                + '/'
     C                                +  $pitem
     C                                + '/'
     C                                +  %TrimL(%editc($pstop:'P'))
     C                                + '/'
     C                                +  $pbflg
     C                                + '/'
     C                                +  $prcod
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOK     Send back "successful" message.
     *
     C     zzok          begsr
     C                   select

     C                   when      $pcmd = '*DELETE '
     C                   eval      $md = *blanks
     C                   movea     msg(1)        $md(1)
     C                   movea     rte_id_itm    $md(30)
     C                   exsr      zm9803
     C                   eval      $prtn = '*OK     '

     C                   when      $pcmd = '*CLOSE  '
     C                   eval      $md = *blanks
     C                   movea     msg(1)        $md(1)
     C                   movea     rte_id_itm    $md(30)
     C                   movea     msg(2)        errmsg
     C                   movea     errmsg        $md(50)
     C                   exsr      zm9999
     C                   eval      $prtn = '*OK     '

     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
Route/RtId/Item/Stop/Flg/Rtn
successfully returned
