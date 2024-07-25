      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  IT506S2   Staging Import - Item Daily Demand V2
     *  December 3, 2018
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    10/13/04  MLB  5.00
     *      - Created.
     *
530 A*    10/25/09  MLB  5.30
     *      - Enh: Revised program to use new import file, IMPFPCKQ
     *        instead of IMPFDEMD.
     *
640aA*    03/08/11  DAS  6.40a
     *      - Revised to used staging file impspckq in place of
     *        file impfpckq.
     *
700aA*    06/09/16  DAS  7.00a
     *      - Added *EACH logic. Program will now create a record with
     *        the item number set to the main item number plus '*EACH',
     *        like 123456*EACH.
     *
720a *    12/03/18  RTR  7.20a
     *      - Copied from IT506S with all mods. Changing to use
     *        IMPSPCKQ2.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Earl's Organic
     *
EOPa *    01/17/19  RTR  EOPa
     *      - Handle breakdowns.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  74        NRF on chain to ITEMSLS
     *  75        NRF on chain to OPTIONS
     *  76        NRF on chain to PIRITEM
     *  77        NRF on chain to ITEMLNK
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
530 DF*impfdemd  if   e           k disk
640aDF*mpfpckq  if   e           k disk
720aDF*mpspckq  if   e           k disk
720aMFimpspckq2 if   e           k disk
     Fitemlnk   if   e           k disk
     Fitemsls   uf a e           k disk
     Foptions   if   e           k disk
     Fpiritem   if   e           k disk
     *----------------------------------------------------------------
     *  Customer id
     *
      /copy qcopysrc,id#eop
     *
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
     *  Working variables
     *
     D brkqty          s                   like(ihtqs1)
     D eofoh           s              1
     D first           s              1
     D forevr          s              1
700aAD hasEachSlot     s               n
530 MD hlditm          s                   like(ipqitm)
530 MD kyitem          s                   like(ipqitm)
700aAD pass            s              1  0
     D satdte          s                   like(today)
700aAD saveItem        s                   like(ipqitm)
700aAD saveOrd1        s                   like(ipqqp1)
700aAD saveOrd2        s                   like(ipqqp2)
700aAD saveOrd3        s                   like(ipqqp3)
     D strtm           s              6  0
     D sundte          s                   like(today)
     D svbldd          s                   like(today)
     D svbldt          s                   like(today)
     D svtype          s                   like(ittype)
     D t               s              1  0
     D today           s              8  0

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
     D                                     DIM(8)
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
     D                                     DIM(8)
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
     D                                     DIM(7)
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
     *  Parameters
     *
     *    Input Parameters
640aA*      $pWhse  - Warehouse
640aA*      $pBatId - Batch id
     *      $PCMD   *TODAY   - Post daily demand to today's field.
     *              *YESTRDY - Post daily demand to yesterday's field.
     *              *SUN     - Post daily demand to Sunday's field.
     *              *MON     - Post daily demand to Monday's field.
     *              *TUE     - Post daily demand to Tuesday's field.
     *              *WED     - Post daily demand to Wednesday's field.
     *              *THU     - Post daily demand to Thursday's field.
     *              *FRI     - Post daily demand to Friday's field.
     *              *SAT     - Post daily demand to Saturday's field.
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
640aAc                   parm                    $pWhse            3 0
640aAc                   parm                    $pBatId          11
     C                   parm                    $pcmd             8
     C                   parm                    $prtn             8
     C                   parm                    $pmsg             4
     *----------------------------------------------------------------
     *  Main line
     *
     *  Setup posting day pointer.
     *
     C                   exsr      zzcldy
     *
     *  Loop through daily demand for items.
     *
     C                   eval      eofoh = *off
530 DC*    *loval        setll     impfdemd
640aDC**   *loval        setll     impfpckq
640aDC**   keyipq        setll     impspckq
720aMC     keyipq        setll     impspckq2
     C                   dow       forevr = forevr
530 DC*                  read      impfdemd                               79
640aDC**                 read      impfpckq                               79
720aDC**   keyipq        reade     impspckq                               79
720aMC     keyipq        reade     impspckq2                              79
     C                   select
     C                   when      *in79
     C                   leave
     *
     C                   other
     *
     *    First time in, get day-end options.
     C                   if        first = *off
     C                   exsr      getopt
     C                   eval      first = *on
     C                   endif
     *
720aAC                   if        ipqtext <> *blanks
720aAC                   iter
720aAC                   endif
     *
530 DC*                  eval      kyitem = deitem
530 MC                   eval      kyitem = ipqitm
     C                   exsr      getit
     *
     C                   eval      svtype = ittype
     *
     C                   select
     *
     *    If item is Alias, SSB or Contract, get base item record.
     C                   when      ittype = 'A'  or
     C                             ittype = 'S'  or
     C                             ittype = 'C'
     *
     C                   exsr      getbas
     *
     *    If item being processed is Alias item linked to SSB item,
     *    get base item for SSB item.
     C                   if        svtype = 'A'  and
     C                             ittype = 'S'
     C                   exsr      getbas
     C                   endif
     *
     C                   other
530 DC*                  eval      kyitem = deitem
530 MC                   eval      kyitem = ipqitm
     C                   endsl
     C                   exsr      zzupdq
     C                   endsl
     C                   enddo
     *
     * Close up shop and return home.
     *
     C                   eval      *inlr = *on
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
     C                   eval      $prtn = *blanks
     C                   eval      forevr = *on
     C                   eval      first = *off
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
640aA*
640aA* Define partial key fpr IMPSPCKQ
640aA*
640aAc     keyipq        klist
640aAc                   kfld                    $pWhse
640aAc                   kfld                    $pBatId
     *
     *  Define partial key for ITEMSLS file.
     *
     C     keyih         klist
530 MC                   kfld                    ipqwhs
     C                   kfld                    kyitem
     C                   kfld                    sundte
     *
     *  Define partial key for OPTIONS file.
     *
     C     keyop         klist
530 MC                   kfld                    ipqwhs
     C                   kfld                    opcode
     *
     *  Define partial key for PIRITEM file.
     *
     C     keyit         klist
530 MC                   kfld                    ipqwhs
     C                   kfld                    kyitem
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETBAS  Get BASE item number.
     *
     C     getbas        begsr
     *
     C     keyit         chain     itemlnk                            77
     C                   select
     C                   when      *in77
530 DC*                  eval      kyitem = deitem
530 MC                   eval      kyitem = ipqitm
     C                   when      not *in77
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
     C     keyit         chain     piritem                            76
     C                   if        *in76
     C                   eval      itumq2 = *zeros
     C                   eval      itumq3 = *zeros
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETOPT  Get OPTIONS file record.
     *
     C     getopt        begsr
     *
     *
     *    Retrieve Day end processing options.
     *
     C                   eval      opcode = '*DAYEND '
     C     keyop         chain     options                            75
     C                   if        *in75
     C                   move      *all'0'       wtim
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCLTM  Calculate posting day
     *
     C     zzcldy        begsr
     *
     *    Retrieve today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     C                   time                    strtm
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
     C                   eval      sundte = $cvd8o
     *
     *    Calculate last day of week.
     *
     C                   move      sundte        $cvd8i
     C                   eval      $cvdr1 = '*ADDDAYS'
     C                   eval      $cvvl1 = 6
     C                   call      @clcdr
     C                   parm                    $cvtdt
     C                   eval      satdte = $cvd8o
     *
     C                   select
     C                   when      $pcmd = '*TODAY  '
     *
     C                   when      $pcmd = '*YESTRDY'
     C                   eval      t = t - 1
     C                   if        t = 0
     C                   eval      t = 7
     C                   endif
     *
     C                   when      $pcmd = '*SUN    '
     C                   eval      t = 1
     *
     C                   when      $pcmd = '*MON    '
     C                   eval      t = 2
     *
     C                   when      $pcmd = '*TUE    '
     C                   eval      t = 3
     *
     C                   when      $pcmd = '*WED    '
     C                   eval      t = 4
     *
     C                   when      $pcmd = '*THU    '
     C                   eval      t = 5
     *
     C                   when      $pcmd = '*FRI    '
     C                   eval      t = 6
     *
     C                   when      $pcmd = '*SAT    '
     C                   eval      t = 7
     *
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPDQ  Update quantity sold for item.
     *
     C     zzupdq        begsr
700aA*
700aA*    Save Order Detail info
700aA*
700aAC                   eval      saveitem = kyitem
700aAC                   eval      saveord1 = ipqqp1
700aAC                   eval      saveord2 = ipqqp2
700aAC                   eval      saveord3 = ipqqp3
EOPaA*
EOPaAc                   if        client = EarlsOrganic
EOPaAc                   if        itum2 <> *blanks
EOPaAc                             and itumq2 <> 0
EOPaAc                   eval      ipqqp1 = ipqqp1 / itumq2
EOPaAc                   endif
EOPaAc                   endif
700aA*
700aA*    See if item has an *EACH slot
700aA*
700aAC                   call      'CHKEACH'
700aAC                   parm                    ipqwhs
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
700aAC                   if        ipqqp1 = 0
700aAC                   iter
700aAC                   endif
700aAC                   eval      ipqqp2 = 0
700aAC                   eval      ipqqp3 = 0
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
700aAC                   eval      ipqqp1 = saveOrd2
700aAC                   eval      ipqqp2 = saveOrd3
700aAC                   endif
700aA*
700aA*      On with the show ...
     *
     C     keyih         chain     itemsls                            74
     *
     C                   select
     C                   when      *in74
     C     *nokey        clear                   ihrec
530 DC*                  eval      ihwhse = dewhse
530 MC                   eval      ihwhse = ipqwhs
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
530 DC*                  if        detqh2 <> 0  and
530 MC                   if        ipqqp2 <> 0  and
     C                             itumq2 > 0
530 DC*    detqh2        div(h)    itumq2        brkqty
530 MC     ipqqp2        div(h)    itumq2        brkqty
     C                   add       brkqty        iqty(t)
     C                   add       brkqty        iqty(8)
     C                   endif
     *
     *    Process all "Other" item types.
     *
     C                   other
     *
530 DC*                  if        detqh1 <> 0  or
530 MC                   if        ipqqp1 <> 0  or
530 DC*                            detqh2 <> 0  and
530 MC                             ipqqp2 <> 0  and
     C                             svtype = 'B'
530 DC*                  add       detqh1        iqty(t)
530 MC                   add       ipqqp1        iqty(t)
530 DC*                  add       detqh1        iqty(8)
530 MC                   add       ipqqp1        iqty(8)
     *    Treat Breakdown demand same as full units. No
     *    conversion necessary.
     C                   if        svtype = 'B'
530 DC*                  add       detqh2        iqty(t)
530 MC                   add       ipqqp2        iqty(t)
530 DC*                  add       detqh2        iqty(8)
530 MC                   add       ipqqp2        iqty(8)
     C                   endif
     C                   endif
     *
530 DC*                  if        detqh2 <> 0  and
530 MC                   if        ipqqp2 <> 0  and
     C                             itumq2 > 0  and
     C                             svtype <> 'B'
530 DC*    detqh2        div(h)    itumq2        brkqty
530 MC     ipqqp2        div(h)    itumq2        brkqty
     C                   add       brkqty        iqty(t)
     C                   add       brkqty        iqty(8)
     C                   endif
     *
     C                   endsl
     *
     *    Item not found in file for this date. Add record.
     C                   if        *in74
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
700aAC                   eval      ipqqp1 = saveOrd1
700aAC                   eval      ipqqp2 = saveOrd2
700aAC                   eval      ipqqp3 = saveOrd3
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
