700aA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IT501     FS-WMS Number of orders / Quantity shipped - Update
     *  20 December 1999
     *  Max Blacknik
     *
     *  SK112 - 1.01
     *
     *----------------------------------------------------------------
     *  Revisions
640 A*    07/13/11  MLB  6.40
     *      - Fix: Revised program to use import date for cutoff date
     *        test for type S=Single Order Selection orders. Built, Printed
     *        date/time are not populted for SOS orders.
     *
700aA*    06/09/16  DAS  7.00a
     *      - Added *EACH logic.
     *      - Revised brk3 calculation to divide by uom2 * uom3, which
     *        will give the number of cases. Before it would only
     *        calculate the number of brk1's.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        CHAIN INDICATOR
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
700aA*  *EACH Notes
     *
     *     Instead of changing the files to include breakdown qtys, it
     *     was decided to create an extra record where '*EACH' is
     *     appended to the item number, like '123456*EACH'.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *
     Fitemlnk   if   e           k disk
     Fitemsls   uf a e           k disk
     Fordh2     if   e           k disk
     Fordd2     if   e           k disk
     Foptions   uf   e           k disk
     Fpiritem   if   e           k disk
     Frtehed4   uf   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a40             s              1    dim(40)
     *                   MSG     1   5 40
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  File/array field overlays
     *
     D                 ds
     D  ihtqs1                 1      7  2
     D  ihtqs2                 8     14  2
     D  ihtqs3                15     21  2
     D  ihtqs4                22     28  2
     D  ihtqs5                29     35  2
     D  ihtqs6                36     42  2
     D  ihtqs7                43     49  2
     D  ihtqsw                50     56  2
     D  iqty                   1     56  2
     D                                     DIM(8)                               Itm quantity sold
     D                 ds
     D  ihord1                 1      5  0
     D  ihord2                 6     10  0
     D  ihord3                11     15  0
     D  ihord4                16     20  0
     D  ihord5                21     25  0
     D  ihord6                26     30  0
     D  ihord7                31     35  0
     D  ihtord                36     40  0
     D  iord                   1     40  0
     D                                     DIM(8)                               Itm number orders
     *----------------------------------------------------------------
     *  *DAYEND  -  Day end processing options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPSTR1  -  Sunday - Warehouse start time
     *    OPSTR2  -  Monday - Warehouse start time
     *    OPSTR3  -  Tuesday - Warehouse start time
     *    OPSTR4  -  Wednesday - Warehouse start time
     *    OPSTR5  -  Thursday - Warehouse start time
     *    OPSTR6  -  Friday - Warehouse start time
     *    OPSTR7  -  Saturday - Warehouse start time
     *    OPLTDT  -  Last transaction processed date
     *    OPLTTM  -  Last transaction processed time
     *    OPLODT  -  Last order processed date
     *    OPLOTM  -  Last order processed time
     *    OPWEEK  -  Current week number
     *    OPWKAV  -  Number of weeks for average
     *    OPDYAV  -  Day to compute averages  (1=Sun - 7=Sat)
     *
     * Data structure
     *
     D opdata          ds
     D  opstr1                 1      6  0
     D  opstr2                 7     12  0
     D  opstr3                13     18  0
     D  opstr4                19     24  0
     D  opstr5                25     30  0
     D  opstr6                31     36  0
     D  opstr7                37     42  0
     D  wtim                   1     42  0
     D                                     DIM(7)                               W/H start time
     D  opltdt                43     50  0
     D  oplttm                51     56  0
     D  oplodt                57     64  0
     D  oplotm                65     70  0
     D  opweek                71     72  0
     D  opwkav                73     75  0
     D  opdyav                76     76  0
     D  optend               117    117
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @clcdr          c                   const('CLCDUR')
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
     D  $cvdr1               133    140
     D  $cvvl1               141    145  0
     D  $cvdr2               146    153
     D  $cvvl2               154    158  0
     D  $cvdr3               159    166
     D  $cvvl3               167    171  0
     D  $cvdr4               172    179
     D  $cvvl4               180    184  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
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
     *  Variables
     *
     D $kstat          s              1
     D $msgf           s             10
     D $pwhse          s              3  0
     D brkqty          s                   like(ihtqs1)
700aAD brk3PerCase     s              7  0
     D cutoff          s              8  0
     D eofod           s              1
     D eofoh           s              1
     D forevr          s              1
700aAD hasEachSlot     s               n
     D hlditm          s                   like(oditem)
     D kyitem          s                   like(oditem)
     D kyshpt          s                   like(rhshpt)
     D kystat          s              1
     D odflag          s              1
700aAD pass            s              1  0
     D satdte          s                   like(rhbldd)
700aAD saveItem        s                   like(oditem)
700aAD saveOrd1        s                   like(odqor1)
700aAD saveOrd2        s                   like(odqor2)
700aAD saveOrd3        s                   like(odqor3)
     D sundte          s                   like(rhbldd)
     D svbldd          s                   like(rhbldd)
     D svbldt          s                   like(rhbldt)
     D svtype          s                   like(ittype)
     D t               s              1  0
     D today           s              8  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   Not used at this time.
     *      $PPRG   Program to send messages back to.
     *      $WHSE   Warehouse
     *
     *    Returned Parameters
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message sent to pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pprg            10
     C                   parm                    $whse             3
     C                   parm                    $prtn             8
     C                   parm                    $pmsg             4
     *----------------------------------------------------------------
     *  Main line
     *
     *
     * Loop through orders for the batch.
     *
     C                   eval      eofoh = *off
     C                   dow       forevr = forevr
     C     keyrha        reade     rtehed4                                79
     C                   select
     C                   when      *in79
     C                   leave                                                  Exit loop
     *
     C                   when      rhtype = 'T'  or
640 A*
     C                             rhbldd < cutoff  and
640 AC                             rhtype <> 'S'  or
640 A*
640 AC                             rhimpd < cutoff  and
640 AC                             rhtype = 'S'
640 A*
640 AC                   if        rhtype = 'S'
640 AC                   eval      svbldd = rhimpd
640 AC                   eval      svbldt = rhimpt
640 AC                   else
640 A*
     C                   eval      svbldd = rhbldd
     C                   eval      svbldt = rhbldt
640 AC                   endif
640 A*
     C                   exsr      zzupdr
     C                   iter                                                   Next route
     *
     C                   other
     *
     C                   exsr      zzupdr
640 A*
640 A*     Use Import date/time for Single Order Selection.
640 A*     Build & Print date/time are not populated for SOS orders.
640 AC                   if        rhtype = 'S'
640 AC                   eval      svbldd = rhimpd
640 AC                   eval      svbldt = rhimpt
640 AC                   else
640 A*
     C                   eval      svbldd = rhbldd
     C                   eval      svbldt = rhbldt
640 AC                   endif
640 A*
     C                   eval      eofoh = *off
     C     keyoh2        setll     ordh2
     *
     C                   dou       eofoh = *on
     C                   exsr      getoh
     C                   if        eofoh = *on
     C                   leave
     C                   endif
     *
     *    Bypass all orders not at Closed status.
     *
     C                   if        ohstat <> 'C'
     C                   iter
     C                   endif
     *
     *    Setup posting day pointer.
     *
     C                   exsr      zzcldy
     *
     *    Loop through detail records for order.
     *
     C                   move      *loval        hlditm
     C                   eval      eofod = *off
     C     keyod2        setll     ordd2
     C                   dou       eofod = *on
     C                   exsr      getod
     *
     C                   if        eofod = *on
     C                   leave                                                  Exit loop.
     C                   endif
     *
     C                   if        oditem <> hlditm
     C                   eval      odflag = *on
     *
     C                   eval      hlditm = oditem
     C                   eval      kyitem = oditem
     C                   exsr      getit
     *
     C                   eval      svtype = ittype
     *
     C                   select
     C                   when      ittype = 'A'  or
     C                             ittype = 'S'  or
     C                             ittype = 'C'
     *
     C                   exsr      getbas
     C                   other
     C                   eval      kyitem = oditem
     C                   endsl
     C                   endif
     *
     C                   exsr      zzupdq
     *
     C                   enddo                                                  End OD loop
     C                   enddo                                                  End OH loop
     C                   endsl                                                  End Select stmt
     C                   enddo                                                  End RH loop.
     *
     * Close up shop and return home.
     *
     *
     *    Update last build date/time transaction processed.
     *
     C                   eval      opcode = '*DAYEND '
     C     keyop         chain     options                            79
     C                   if        not *in79
     C                   eval      oplodt = svbldd
     C                   eval      oplotm = svbldt
     C                   update    oprec
     C                   endif
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
     C                   eval      $prtn = *blanks
     C                   move      $whse         $pwhse
     C                   eval      kystat = '6'
     C                   eval      $kstat = 'C'
     C                   eval      forevr = *on
     C                   eval      odflag = *off
     *
     *  Define partial key for ITEMSLS file.
     *
     C     keyih         klist
     C                   kfld                    $pwhse
     C                   kfld                    kyitem
     C                   kfld                    sundte
     *
     *  Define partial key for OPTIONS file.
     *
     C     keyop         klist
     C                   kfld                    $pwhse
     C                   kfld                    opcode
     *
     *  Define partial key for ORDD2 file.
     *
     C     keyod2        klist
     C                   kfld                    $pwhse
     C                   kfld                    ohord
     *
     *  Define partial key for ORDH2 file.
     *
     C     keyoh2        klist
     C                   kfld                    $pwhse
     C                   kfld                    $kstat
     C                   kfld                    rhtype
     C                   kfld                    rhrtid
     *
     *  Define partial key for PIRITEM file.
     *
     C     keyit         klist
     C                   kfld                    $pwhse
     C                   kfld                    kyitem
     *
     *  Define partial key for RTEHED4 file.
     *
     C                   eval      kyshpt = *zeros
     C     keyrha        klist
     C                   kfld                    $pwhse
     C                   kfld                    kystat
     C                   kfld                    kyshpt
     *
     *    Retrieve Day end processing options.
     *
     C                   eval      opcode = '*DAYEND '
     C     keyop         chain(n)  options                            79
     C                   if        *in79
     C                   move      *all'0'       wtim
     C                   endif
     *
     *    Retrieve today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *    Convert Current date to day number.
     *
     C                   eval      $cvcmd = '*CMDNBR '
     C                   move      today         $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   z-add     $cvd6o        t
     *
     *   Compute Sunday date for current week.
     *
     C                   eval      $cvcmd = '*CMDCMD '
     C                   move      today         $cvd8i
     C                   eval      $cvdr1 = '*SUBDAYS'
     C                   eval      $cvvl1 = t - 1
     C                   call      @clcdr
     C                   parm                    $cvtdt
     C                   eval      cutoff = $cvd8o
     *
     *   Compute cutoff date.
     *
     C                   eval      $cvcmd = '*CMDCMD '
     C                   move      cutoff        $cvd8i
     C                   eval      $cvdr1 = '*SUBDAYS'
     C                   eval      $cvvl1 = opwkav * 7
     C                   call      @clcdr
     C                   parm                    $cvtdt
     C                   eval      cutoff = $cvd8o
     *
     *    Setup Route Header file key for processing.
     *
     C     keyrha        setll     rtehed4
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETBAS  Get BASE item number.
     *
     C     getbas        begsr
     *
     C     keyit         chain     itemlnk                            79
     C                   select
     C                   when      *in79
     C                   eval      kyitem = oditem
     C                   when      not *in79
     C                   eval      kyitem = ilitm2
     C                   exsr      getit
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETIT   Get PIRITEM record.
     *
     C     getit         begsr
     *
     C     keyit         chain     piritem                            79
     C                   if        *in79
     C                   eval      itumq2 = *zeros
     C                   eval      itumq3 = *zeros
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETOD   Get order detail record.
     *
     C     getod         begsr
     *
     *   Try to get a 'Closed' detail record for order.
     *
     C     keyod2        reade     ordd2                                  79
     *
     *   Set flag if there are no more detail records.
     *
     C                   if        *in79
     C                   eval      eofod = *on
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETOH   Get order header record.
     *
     C     getoh         begsr
     *
     *   Try to get a 'Closed' header record.
     *
     C     keyoh2        reade     ordh2                                  79
     *
     *   Set flag if there are no more header records.
     *
     C                   if        *in79
     C                   eval      eofoh = *on
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
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
     C                   parm      $pprg         #pgmq            10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *
     *  ZZCLTM  Calculate posting day
     *
     C     zzcldy        begsr
     *
     *    Convert date to day number.
     *
     C                   eval      $cvcmd = '*CMDNBR '
640 A*
640 AC                   if        rhtype = 'S'
640 AC                   move      rhimpd        $cvd8i
640 AC                   else
640 A*
     C                   move      rhbldd        $cvd8i
640 AC                   endif
640 A*
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   z-add     $cvd6o        t
     *
     C                   if        rhbldd < sundte  and
640 AC                             rhtype <> 'S'  or
640 A*
     C                             rhbldd > satdte  and
640 AC                             rhtype <> 'S'  or
640 A*
640 AC                             rhimpd < sundte  and
640 AC                             rhtype = 'S'  or
640 A*
640 AC                             rhimpd > satdte  and
640 AC                             rhtype = 'S'
     *
     *    Calculate first day of week if day greater than Sunday.
     *    This is done because Sundays date is used as sequencing
     *    key in the file.
     *
     C                   if        t > 1
     C                   eval      $cvcmd = '*CMDCMD '
640 A*
640 AC                   if        rhtype = 'S'
640 AC                   move      rhimpd        $cvd8i
640 AC                   else
640 A*
     C                   move      rhbldd        $cvd8i
640 AC                   endif
640 A*
     C                   eval      $cvdr1 = '*SUBDAYS'
     C                   eval      $cvvl1 = t - 1
     C                   call      @clcdr
     C                   parm                    $cvtdt
     C                   eval      sundte = $cvd8o
     *
     C                   else
640 A*
640 AC                   if        rhtype = 'S'
640 AC                   eval      sundte = rhimpd
640 AC                   eval      $cvd8o = rhimpd
640 AC                   else
640 A*
     C                   eval      sundte = rhbldd
     C                   eval      $cvd8o = rhbldd
640 AC                   endif
640 A*
     C                   endif
     *
     *    Calculate last day of week.
     *
     C                   move      $cvd8o        $cvd8i
     C                   eval      $cvdr1 = '*ADDDAYS'
     C                   eval      $cvvl1 = 6
     C                   call      @clcdr
     C                   parm                    $cvtdt
     C                   eval      satdte = $cvd8o
     *
     C                   endif
     *
     C                   select
     *
     *    If time of order is less than starting time for day of
     *    transaction, subtract one from pointer to post trans-
     *    action to previous day.
     *
     C                   when      rhbldt < wtim(t)  and
640 AC                             rhtype <> 'S'  or
640 A*
640 AC                             rhimpt < wtim(t)  and
640 AC                             rhtype = 'S'
640 A*
     C                   eval      t = t - 1
     C                   if        t = 0
     C                   eval      t = 7
     C                   endif
     *
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPDQ  Update number of orders / Quantity sold
     *
     C     zzupdq        begsr
700aA*
700aA*    Save Order Detail info
700aA*
700aAC                   eval      saveitem = kyitem
700aAC                   eval      saveord1 = odqor1
700aAC                   eval      saveord2 = odqor2
700aAC                   eval      saveord3 = odqor3
700aA*
700aA*    See if item has an *EACH slot
700aA*
700aAC                   call      'CHKEACH'
700aAC                   parm                    odwhse
700aAC                   parm                    kyitem
700aAC                   parm                    hasEachSlot
700aA*
700aA*    Loop through logic twice,
700aA*      Once for main item, once for *EACH.
700aA*
700aAC                   for       pass = 1 to 2
700aA*
700aA*      When a item has a *EACH ...
700aA*        On first pass, only work with Normal qty.
700aA*
700aAC                   if        hasEachSlot  and pass = 1
700aAC                   if        odqor1 = 0
700aAC                   iter
700aAC                   endif
700aAC                   eval      odqor2 = 0
700aAC                   eval      odqor3 = 0
700aAC                   endif
700aA*
700aA*      When a item has a *EACH ...
700aA*        On second pass, work with brk1/2 qtys.
700aA*
700aAC                   if        hasEachSlot  and pass = 2
700aAC                   if        saveOrd2 = 0 and saveOrd3 = 0
700aAC                   iter
700aAC                   endif
700aAC                   eval      kyitem = %trim(kyitem) + '*EACH'
700aAC                   eval      odqor1 = saveOrd2
700aAC                   eval      odqor2 = saveOrd3
700aAC                   endif
700aA*
700aA*      On with the show ...
     *
     C     keyih         chain     itemsls                            79
     *
     C                   select
     C                   when      *in79
     C     *nokey        clear                   ihrec
     C                   eval      ihwhse = odwhse
     C                   eval      ihitem = kyitem
     C                   eval      ihstrd = sundte
     C                   endsl
     *
     C                   select
     *
     *    Process "Same Slot Breakdown" item.
     *
     C                   when      svtype = 'S'
     *
     C                   eval      odqor3 = odqor2
     C                   eval      odqor2 = odqor1
     C                   eval      odqor1 = *zeros
     *
     C                   if        odqor2 <> 0  and
     C                             itumq2 > 0
     C     odqor2        div(h)    itumq2        brkqty
     C                   add       brkqty        iqty(t)
     C                   add       brkqty        iqty(8)
     C                   endif
     *
     C                   if        odqor3 <> 0  and
     C                             itumq3 > 0
700aAC                   eval      brk3PerCase = itumq2 * itumq3
700aDC**   odqor3        div(h)    itumq3        brkqty
700aMC     odqor3        div(h)    brk3PerCase   brkqty
     C                   add       brkqty        iqty(t)
     C                   add       brkqty        iqty(8)
     C                   endif
     *
     *    Process all "Other" item types.
     *
     C                   other
     *
     C                   if        odqor1 <> 0
     C                   add       odqor1        iqty(t)
     C                   add       odqor1        iqty(8)                        Total qty
     C                   endif
     *
     C                   if        odqor2 <> 0  and
     C                             itumq2 > 0
     C     odqor2        div(h)    itumq2        brkqty
     C                   add       brkqty        iqty(t)
     C                   add       brkqty        iqty(8)
     C                   endif
     *
     C                   if        odqor3 <> 0  and
     C                             itumq3 > 0
700aAC                   eval      brk3PerCase = itumq2 * itumq3
700aDC**   odqor3        div(h)    itumq3        brkqty
700aMC     odqor3        div(h)    brk3PerCase   brkqty
     C                   add       brkqty        iqty(t)
     C                   add       brkqty        iqty(8)
     C                   endif
     C                   endsl
     *
     *    Count number of times item was ordered. If item occurs
     *    more than once in an order it counts as 1 for number of
     *    times ordered.
     *
     C                   if        odflag = *on
     C                   add       1             iord(t)
     C                   add       1             iord(8)
     C                   eval      odflag = *off
     C                   endif
     *
     C                   if        *in79
     C                   write     ihrec
     *
     C                   else
     C                   update    ihrec
     *
     C                   endif
700aA*
700aA*      Get out if item doesn't have a *EACH slot
700aA*
700aAC                   if        not hasEachSlot
700aAC                   leave
700aAC                   endif
700aA*
700aA*      End FOR loop
700aA*
700aAC                   endfor
700aA*
700aA*    Put things back the way they were
700aA*
700aAC                   eval      kyitem = saveItem
700aAC                   eval      odqor1 = saveOrd1
700aAC                   eval      odqor2 = saveOrd2
700aAC                   eval      odqor3 = saveOrd3
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPDR  Update RTEHED ship time to mark route processed.
     *
     C     zzupdr        begsr
     *
     C                   eval      rhshpt = 1
     C                   update    rhrec
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
