      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  HQ121S    Stage - Update pick slot qty derived from host
     *  18 Feb 2011
     *  Retha Davis
     *  Cloned from HQ121
     *
     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTSQLRPGI OBJ(*) SRCFILE(*) TGTRLS(V5R3M0)
     *               COMMMIT(*NONE) DLYPRP(*YES)
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
     *  04/17/02  HNK
     *   - Created - custom for CBI
     *
     *  07/18/03 HNK CBI
     *   - Update pick slot expiration date if date sensitive item
     *     in the slot.  Set to today's date.
     *
CBIaA*  08/01/03 HNK CBIa
     *   - Update ITEMQTY for each item.
     *
CBIbA*  08/20/03 DAS CBIb
     *   - Revised to set slot expiration date to Today + 1.
     *     Re: Slots were expiring after midnight, thus sending
     *     selectors to overflow slots.
CBIcA*  09/02/03  MLB  CBIc
     *   - Revised to only update slot expiration date when it
     *     is less than new date.
CBIdA*  09/15/03  MLB  CBId
     *   - Revised to not allow pick slot stock quantity to go
     *     negative. Set quantity to zero if new pick slot qty
     *     less than zero.
CBIeA*  01/05/04  RH   CBIe
     *   - Revised to not allow pick slot stock quantity to be less
     *     than (allocated plus pick quantity).
CBIfA*  05/04/05  RH   CBIf
     *   - Revised to allow pick slot stock quantity to go negative.
     *   - Reverse CBId and CBIe changes. CCLDN was changed also.
CBIgA*  05/07/07  RH   CBIg
     *   - Revised to set special designation code pick slot status to
     *     'Z' when empty.
640aA*  02/18/11  RBD  6.40a
     *   - Copied from HQ121.  Converted to ILE.
     *   - Revised to use staging file impspqty in place of
     *     file impfpqty.
     *   - Fix: revised to only update pick slots.
     *     'Z' when empty.
650aA*  08/15/13  DAS  6.50a
     *   - Revised to call UT812 with *CLOSE at end of program.
     *   - Revised to skip overflow slots and pick slots with no item.
     *
710 A*  03/26/17  MLB  7.10
     *   - Enh: Revised pgm to add custom client code support to pgm.
710aA*  12/28/17  MLB  7.10a
     *   - Enh: Revised pgm to move setof of FIRST and *in 91. If only
     *     1 item or less and no exceptions, pgm failed with page#
     *     variable too small to hold result error.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers
     *
CBIhA*  03/26/17  MLB  CBIh
     *   - Enh: Revised pgm for Pate Dawson, Greensboro whse. Create
     *     virtual pick slot, MT-84-09 when buyer: 150 or 160. Create
     *     virtual pick slot, FI-00-11 when buyer: 155. Allow pgm to
     *     update item as necessary.
     *   - Added file ITEMMSC to pgm.
     *   - Added file SLOT2 to pgm.
CBIjA*  06/22/17  MLB  CBIj
     *   - Enh: Revised pgm to add call to LT001 when item has existing
     *     pick slot and licenses need to be updated due to change in
     *     qty in pick slot.
CBIkA*  08/04/17  MLB  CBIk
     *   - Enh: Revised pgm to call DRILICENSE with *SETFIFO to update
     *     expiration date when pick slot, SLSTK1, SLSTK2, SLSTK3 are
     *     zero and item is date sensitive. If pick slot is empty, exp.
     *     date was not being properly updated.
     *   - Added LICACTIVE1 to pgm.
CBIlA*  10/18/17  MLB  CBIl
     *   - Enh: Revised pgm to update slot entered date during *SETFIFO
     *     processing in routine, ZZUPD1 to set Slot Entered Date to
     *     Today's Date. Was leaving slot entered date at old value.
CBImA*  12/28/17  MLB  CBIm      P# 2017218
     *   - Enh: Revised CBIj mod. If computed pick slot qty equals new
     *     pick slot qty, set adj qty to zero. No adjustment necessary.
CBInA*  12/29/17  MLB  CBIn      P# 2017218
     *   - Enh: Revised CBIh mod. Corrected field names referenced on keysl2.
     *     Caused dde error on chain to slot2.
CBIpA*  02/07/18  MLB  CBIp      P# 2017218
     *   - Enh: Revised CBIj mod. Program was not adjusting pick slot
     *     qty when SAP whse qty and overflow qty matched and computed
     *     pick slot qty was zero.
CBIrA*  04/25/18  MLB  CBIr      P# 2018063
     *   - Enh: Added Cheney Crazy Fish Riviera to mod to create
     *     pick slots for 3 buyer numbers for weighed meat/fish.
     *   - Added CBIq to CBIh mod.
CBIqA*  04/25/18  MLB  CBIq      P# 2018063
     *   - Enh: Revised CBIh mod to change slot locations associated
     *     with each of the buyer numbers. New Meat slot: MT-101-1 and
     *     new Fish slot: FS-100-1.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Not on file/End of file indicator
     *  90        Overflow Indicator
     *  9X        Top of page and level X continues.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
CBIjDF*slot1     up   e           k disk
CBIjMFslot1     ip   e           k disk
     Fslot3     if   e           k disk
     F                                     rename(slrec:record)
CBIhAFslot2     uf   e           k disk
CBIhAF                                     rename(slrec:slrec2)
640aDF*impfpqty  if   e           k disk
640aMFimpspqty  uf   e           k disk
CBIkAFlicactive1if   e           k disk
     Fpiritem   if   e           k disk
CBIhAFitemmsc   if   e           k disk
     Fwarehs    if   e           k disk
CBIg Fdesigsp   if   e           k disk
     Fhq121pr   o    e             printer oflind(*in90)
710 A*----------------------------------------------------------------
710 A*  Client ID
710 A*
710 AD @getcl          c                   const('GETCLIENT')
710 A*
CBIhA /copy qcopysrc,id#cheney

CBIhA*----------------------------------------------------------------
CBIhA*  DRI parameters
CBIhA*----------------------------------------------------------------
CBIhA
CBIhA /COPY *libl/qcopysrc,c#driparms
CBIhA
CBIhA*----------------------------------------------------------------
CBIhA*  Data Formats
CBIhA*----------------------------------------------------------------
CBIhA
CBIjA /COPY *libl/qcopysrc,C#ITEM
CBIhA /COPY *libl/qcopysrc,C#SLOT
CBIhAD saveVer#        s                   like($slver#)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     D reck            s              7  0 dim(3)
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *
CBI AD $cvtdt          ds
CBI AD  $cvcmd                 1      8
CBI AD  $cvprg                 9     18
CBI AD  $cvd6i                19     24
CBI AD  $cvd8i                25     32
CBI AD  $cvd6o                33     38  0
CBI AD  $cvd8o                39     46  0
CBI AD  $cvsto                47     64
CBI AD  $cvrtn                65     72
CBI AD  $cverm                73    132
CBI AD  $cvmsg                73     76
     *----------------------------------------------------------------
     *
     D $perm           ds
     D  xxerm                  1     60
     D  $pmsg                  1      4
     *----------------------------------------------------------------
     *  Program info data structure
     *
640aA /copy qcopysrc,c#pgminfds
640aDD*               sds
640aDD* #prog            *proc
640aDD* #job                 244    253
640aDD* #user                254    263
640aDD* #jobn                264    269
640aDD* #jobdt               276    281  0
640aDD* #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Variables
     *
CBIjDD*$item           s             15
CBIjMD $uitem          s             15
     D $jtyp           s              1
     D $llen           s              3  0
     D $lmsg           s              4
     D $lprg           s             10
     D $lrtn           s              8
     D $lstr           s             60
     D $plen           s              3  0
     D $pstr           s             60
     D $pwhs           s             15  5
CBIhAD chk4err         s               n
     D ckqty1          s              5  0
     D ckqty2          s              3  0
640aAD error           s               n
     D first           s              1
     D forevr          s              1
640aAD importError     s               n
     D l               s              1  0
     D m               s                   like(l)
CBIkAd SetFifo         s               n   inz('0')
640aAD stamp           s               z
640aAD stampUC         s               z
     D today           s              8  0
     D type            s              5
CBIjAD usrfound        s              1    inz('0')
CBIjAd wkError         s               n   inz('0')
CBIjAd wkStkQty        s              7  0 inz
CBIjAd wkNewQty        s              7  0 inz
CBIjAd wkAdjQty        s              7  0 inz
CBIjAd wkTtlQty        s              7  0 inz
CBIjAd wkQty1          s                   like($saqty1)
CBIjAd wkQty2          s                   like($saqty2)
CBIjAd wkQty3          s                   like($saqty3)
     *----------------------------------------------------------------
640aA*  Parameters
640aA*----------------------------------------------------------------
640aA
640aAD $pWhse          s              3p 0
640aAD $pWhse3A        s              3
640aAD $pBatId         s             11
640aAD $pReturn        s             10
640aAD $pMessage       s            200
640aA
     *----------------------------------------------------------------
640aA*  Standard SQL variables and constants
640aA*----------------------------------------------------------------
640aA
640aA /copy qcopysrc,c#stdsql
CBIhA
CBIhA*----------------------------------------------------------------
CBIhA*  Data structure for error message parameters
CBIhA*----------------------------------------------------------------
CBIhA
CBIhAD $mdt            ds
CBIhAD  errmsg                 1     50
CBIhA*

640aA*----------------------------------------------------------------
640aA*  File data data structure
640aA*----------------------------------------------------------------
640aA
640aAD sbrec         E ds                  extname(stgbatch) inz(*EXTDFT)

     *----------------------------------------------------------------
     Islrec
     I                                          slwhse        l1
     I                                          slwhdp        l1
     I                                          slaisl        l1
     Irecord
     I              slwhse                      s3whse
     I              slwhdp                      s3whdp
     I              slaisl                      s3aisl
     I              slloc                       s3loc
     I              slrlvl                      s3rlvl
     I              slhand                      s3hand
     I              slside                      s3side
     I              slstyp                      s3styp
     I              sldisp                      s3disp
     I              slstat                      s3stat
     I              slsdte                      s3sdte
     I              slstim                      s3stim
     I              slsdef                      s3sdef
     I              sldesg                      s3desg
     I              slactv                      s3actv
     I              slbld                       s3bld
     I              slpick                      s3pick
     I              slpseq                      s3pseq
     I              slprty                      s3prty
     I              slentd                      s3entd
     I              slexpd                      s3expd
     I              slslfd                      s3slfd
     I              slrsrv                      s3rsrv
     I              slitem                      s3item
     I              slstk1                      s3stk1
     I              slstk2                      s3stk2
     I              slstk3                      s3stk3
     I              slalc1                      s3alc1
     I              slalc2                      s3alc2
     I              slalc3                      s3alc3
     I              sltfr1                      s3tfr1
     I              sltfr2                      s3tfr2
     I              sltfr3                      s3tfr3
     I              slpck1                      s3pck1
     I              slpck2                      s3pck2
     I              slpck3                      s3pck3
     I              slrcv1                      s3rcv1
     I              slrcv2                      s3rcv2
     I              slrcv3                      s3rcv3
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
640aA*      $pWhse  - Warehouse
640aA*      $pBatId - Batch id
     *
     *    Returned Parameters
640aA*      $pReturn  - Return code
640aA*      $pMessage - Return message
     *
     *----------------------------------------------------------------

     c     *entry        plist
640aDC**                 parm                    $whdp             5
640aDC**                 parm                    $aisl             3
640aAc                   parm                    $pWhse3A
640aAc                   parm                    $pBatId
640aAc                   parm                    $pReturn
640aAc                   parm                    $pMessage

     *----------------------------------------------------------------
     *
     *  Report Heading
     *
     *  Start new page if one of following happened.
     *     - Page overflow.
     *
     *  PAGE OVERFLOW
     *
     C                   if        first = *on  or
     C                             *in90  or
     C                             *inl1
     C                   exsr      zrhead
     C                   endif
     *
     *  Init total levels
     *
     *  Level 1 break - Whse/Dept/Aisle
     *
     C                   if        *inl1
     C                   eval      l = 1
     C                   exsr      zrzero
     C                   endif
     *
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *
650aA*  Skip Oveflow slots and Pick slots with no item
650aA*
650aAC                   if        slpick<>'Y' or slitem=' '
650aAC                   goto      bottom
650aAC                   endif
     *
     C                   eval      t#disp = sldisp
     C                   eval      t#item = slitem
CBIkAC                   eval      setfifo = '0'
     *
     *  Get item description.
     *
     C     keyit         chain     piritem                            79
     C                   if        *in79
     C                   eval      itdesc = *blanks
CBIjAC                   eval      itumq2 = 0
CBIjAC                   eval      itum2  = ' '
CBIjAC                   eval      itumq3 = 0
CBIjAC                   eval      itum3  = ' '
CBIkAC                   eval      itflgd = 'N'
     C                   endif
CBIjA*
CBIjA*    Set Brkdwn 1 qty for conversion calcs below.
CBIjAC                   if        itumq2 <= 0
CBIjAC                             or ittype = 'S'
CBIjAC                   eval      itumq2 = 1
CBIjAC                   endif
CBIjA
CBIjA*    Set Brkdwn 2 qty for conversion calcs below.
CBIjAC                   if        itumq3 <= 0
CBIjAC                             or ittype = 'S'
CBIjAC                   eval      itumq3 = 1
CBIjAC                   endif
     *
     C                   exsr      oflqty
CBIhDC***                eval      ijstatus = ' '
640aDC**   keyij         chain     impfpqty                           79
640aMC     keyij         chain     impspqty                           79
     C                   if        *in79
     C                   eval      ijtqh1 = 0
     C                   eval      ijtqh2 = 0
CBIjAC                   eval      ijstatus = 'S'
     C                   endif
CBIjA*
CBIjA*  Bypass import records already processed.
CBIjAC                   if        ijstatus = 'S'
CBIjAC                   goto      bottom
CBIjAC                   endif
     *
     C                   eval      pckqt1 = ijtqh1 - ofqty1
     C                   eval      pckqt2 = ijtqh2 - ofqty2
     *
     *  Write detail line.
     *
     C                   write     detail1
     *
     *  Update pick slot.
     *
640aAC                   if        slpick = 'Y'
     *
CBI AC                   if        itflgd = 'Y'  and
CBIcAC                             slexpd < today
CBIjDC*                  eval      slexpd = today1
CBI AC                   endif
CBIe *  Total allocate and pick qty.
CBIeAC                   eval      ckqty1 = 0
CBIeAC                   eval      ckqty2 = 0
CBIeAC     slalc1        add       slpck1        ckqty1
CBIeAC     slalc2        add       slpck2        ckqty2
CBIjDC*                  z-add     pckqt1        slstk1
CBIjDC*                  z-add     pckqt2        slstk2
CBIj *
CBIjAC                   if        client = Cheney
CBIjAC                   if           pckqt1 <> 0
CBIjAC                             or pckqt2 <> 0
CBKkA*
CBKkA*     Host has zero qty onhand. Adjust any remaining qty out of pick slot
CBIkAC                             or  ijtqh1 = 0
CBIkAC                             and ijtqh2 = 0
CBIkAC                             and pckqt1 = 0
CBIkAC                             and pckqt2 = 0
CBIpA*
CBIpA*     Host qty matches overflow. Adjust any remaining qty out of pick slot
CBIpAC                             or  ijtqh1 = ofqty1
CBIpAC                             and ijtqh2 = ofqty2
CBIpAC                             and pckqt1 = 0
CBIpAC                             and pckqt2 = 0
CBKkA*
CBIjAC                   exsr      zzclcpick
CBIjAC                   if           wkqty1 <> 0
CBIjAC                             or wkqty2 <> 0
CBIjAC                             or wkqty3 <> 0
CBIjAC                   exsr      zzFill$adj
CBIjAC                   exsr      zzupdpick
CBIjA*
CBIjAC                   endif
CBIjA*
CBIjAC                   endif
CBIjA*
CBIjAC                   endif
CBIjA*
CBIg *  Check if special designation slot, set status = Z if empty.
CBIgAC                   if        sldesg <> ' '
CBIjAC     keysl2        chain     slot2
CBIjAC*                  if        %found(slot2)
CBIgAC     sldesg        chain     desigsp                            79
CBIgAC                   if        not *in79  and
CBIgAC                             slstk1 = 0  and
CBIgAC                             slstk2 = 0  and
CBIgAC                             slstk3 = 0  and
CBIgAC                             slrcv1 = 0  and
CBIgAC                             slrcv2 = 0  and
CBIgAC                             slrcv3 = 0  and
CBIgAC                             sltfr1 = 0  and
CBIgAC                             sltfr2 = 0  and
CBIgAC                             sltfr3 = 0  and
CBIgAC                             slpck1 = 0  and
CBIgAC                             slpck2 = 0  and
CBIgAC                             slpck3 = 0
CBIgAC                   eval      slstat = 'Z '
CBIjAC                   update    slrec2
CBIgAC                   endif
CBIjAC                   unlock    slot2
CBIgAC                   endif
CBIjDC*                  update    slrec
     * Recalculate item qty for slot item
CBIjDC*                  eval      $item = slitem
CBIjDC*                  exsr      zzrcal
     *
640aAC                   endif
     *
     *  Increment record counters
     *
     C                   add       1             reck(1)
710aD*
710aD*  Set off top-of-page indicators
710aD*
710aDC*                  eval      first = *off
710aDC*                  eval      *in91 = *off
     *
640aA*  Update import record
640aA*
640aAC                   if        ijstatus = 'R'
640aAC                   eval      ijstatus = 'S'
640aAC                   eval      ijtext = ' '
640aAC                   exsr      zzzGetStamps
640aAC                   eval      ijststs = stamp
640aAC                   eval      ijstsuc = stampuc
640aAC                   update    ijrec
640aAC                   endif
640aA*
650aAC     bottom        tag
710aA*
710aA*  Set off top-of-page indicators
710aA*
710aAC                   eval      first = *off
710aAC                   eval      *in91 = *off
650aA*
     *----------------------------------------------------------------
     *
     * Whse/Dept/Aisle totals
     *
     CL1                 eval      l = 1
     CL1                 exsr      zrroll
     *
     *----------------------------------------------------------------
     *
     * REPORT TOTALS
     *
CBIhAClr                 if        client = Cheney
CBIrMC                             and (clientloc = cbigr
CBIrAC                               or %subst(whdesc:13:3) = 'CFR')
CBIhAClr                 exsr      zzassignpk
CBIhAClr                 endif
CBIhA*
     CLr                 eval      l = 2
     *
CBIhAClr                 if        *in90 = '1'
CBIhAClr                 exsr      zrhead
CBIhAClr                 endif
CBIhA*
     CLr                 if        reck(l) > 0
     CLr                 write     skip1
     CLr                 write     foot1
     CLr                 endif
     *
650aACLr                 exsr      zzzcls812
640aACLr                 exsr      zzzEnd
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
710 A*
710 A* Get client id.
710 A*
710 AC                   call      @getcl
710 AC                   parm                    client           10
710 AC                   parm                    clientloc        10
     *
     *  Define key for main file.
     *
     C     keyit         klist
     C                   kfld                    slwhse
     C                   kfld                    slitem
CBIhA*
CBIhAC     keyit2        klist
CBIhAC                   kfld                    ijwhse
CBIhAC                   kfld                    ijitem
CBIkA*
CBIkA*  Define partial key for LICACTIVE1 file.
CBIkA*
CBIkAC     keyla1        klist
CBIkAC                   kfld                    slwhse
CBIkAC                   kfld                    slwhdp
CBIkAC                   kfld                    sldisp
CBIkAC                   kfld                    slitem
CBIhA*
CBIhA*  Define full key for SLOT2 file.
CBIhA*
CBIhAC     keysl2        klist
CBInMC                   kfld                    slwhse
CBInMC                   kfld                    slwhdp
CBInMC                   kfld                    sldisp
     *
     *  Define partial key for SLOT3 file.
     *
     C     keysl3        klist
     C                   kfld                    slwhse
     C                   kfld                    slitem
CBIhA*
CBIhAC     *like         define    slstat        kystat
CBIhAC     *like         define    slpick        kypick
CBIhAC     keysl3pk      klist
CBIhAC                   kfld                    ijwhse
CBIhAC                   kfld                    ijitem
CBIhAC                   kfld                    kystat
CBIhAC                   kfld                    kypick
     *
     *  Define key for IMPFPQTY FILE.
     *
     C     keyij         klist
     C                   kfld                    slwhse
640aAC                   kfld                    $pBatId
     C                   kfld                    t#item
CBIhA*
CBIhA*  Partial key for IMPSPQTY.
CBIhAC     keyij2        klist
CBIhAC                   kfld                    slwhse
CBIhAC                   kfld                    $pBatId
     *
     *  Convert today's date into century format.
     *
CBI AC                   eval      $cvcmd = '*CURCMD '
CBI AC                   call      @cvtdt
CBI AC                   parm                    $cvtdt
CBI AC                   eval      today = $cvd8o
     C                   time                    time
CBIbA*
CBIbA*  Add 1 to today's date.
CBIbA*
     C                   call      'CLCDUR2'
     C                   parm      '*ADD'        $cmd              8
     C                   parm      today         $datei            8 0
     C                   parm      0             $timei            6 0
     C                   parm      0             $years            3 0
     C                   parm      0             $month            3 0
     C                   parm      1             $days             3 0
     C                   parm      0             $hours            3 0
     C                   parm      0             $min              3 0
     C                   parm      0             $sec              3 0
     C                   parm      0             today1            8 0
     C                   parm      0             $timeo            6 0
     *
640aAc                   eval      $pWhse = %dec($pWhse3A: 3: 0)
640aAc                   eval      $pReturn = '*OK'
640aAc                   eval      $pMessage = ' '
     C                   eval      first = *on
     C                   eval      forevr = *on
     C                   eval      l = 2
     C                   exsr      zrzero
CBIjA*
CBIjA*   Get default values for the user.
CBIjA*
CBIjAC                   call      'GETUSER'
CBIjAC                   parm                    #user
CBIjAC                   parm      0             #whse             3 0
CBIjAC                   parm      0             #emp#             5 0
CBIjAC                   parm                    #fnam            15
CBIjAC                   parm                    #init             1
CBIjAC                   parm                    #lnam            20
CBIjAC                   parm                    #whdp             5
CBIjAC                   parm                    #styp             1
CBIjAC                   parm                    #shft             6
CBIjAC                   parm                    #crew             6
CBIjAC                   parm      0             #nhrs             3 1
CBIjAC                   parm                    #rtn              8
CBIjAC                   if        #rtn = '*OK'
CBIjAC                   eval      usrfound = '1'
CBIjAC                   else
CBIjAC                   eval      usrfound = '0'
CBIjAC                   endif
     *
640aA* Update stgbatch record to start process
640aA*
640aAC                   exsr      zzzStart
640aAC                   if        $pReturn <> '*OK'
640aAC                   return
640aAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     oflqty        begsr
     *
     C                   eval      ofqty1 = 0
     C                   eval      ofqty2 = 0
     C     keysl3        setll     slot3
     C                   dow       forevr = *on
     C     keysl3        reade     slot3                                  79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   if        s3pick = 'Y'
     C                   iter
     C                   endif
     *
     C                   add       s3stk1        ofqty1
     C                   add       s3stk2        ofqty2
     *
     C                   enddo
     *
     C                   endsr
CBIjA*
CBIjA*----------------------------------------------------------------
CBIjA*  Compute quantity in pick slot to be adjusted.
CBIjAC     zzclcpick     begsr
CBIjA*
CBIjAC                   eval      wkTtlQty = 0
CBIjAC                   eval      wkqty1   = 0
CBIjAC                   eval      wkqty2   = 0
CBIjAC                   eval      wkqty3   = 0
CBIjA*
CBIjAC                   exsr      zzavail
CBIjA*
CBIjA*    Convert pick slot available quantity to lowest form.
CBIjAC                   eval      wkStkQty = (avail1 * itumq2 * itumq3)
CBIjAC                                      + (avail2 * itumq3)
CBIjAC                                      +  avail3
CBIjA*
CBIjA*    Convert new pick slot quantity to lowest form.
CBIjAC                   eval      wkNewQty = (pckqt1 * itumq2 * itumq3)
CBIjAC                                      + (pckqt2 * itumq3)
CBImAC                   select
CBImA*
CBImA*    When available pick slot qty and new pick slot qty are
CBImA*    negative, set adjust qty to pick slot available qty.
CBImAC**                 when          wkStkQty < 0
CBImAC**                           and wkNewQty < 0
CBImAC**                 eval      wkAdjQty = wkStkQty
CBImA*
CBImA*    When available pick slot qty equals new pick slot qty,
CBImA*    set qty to adjust to zero.
CBImAC                   when          wkStkQty = wkNewQty
CBImAC                   eval      wkAdjQty = 0
CBImA*
CBImA*    When available pick slot qty is zero and new pick slot qty is
CBImA*    negative, set qty to lot qty and new pick slot qty are negative
CBImAC**                 when          wkStkQty = 0
CBImAC**                           and wkNewQty < 0
CBImAC**                 eval      wkAdjQty = 0
CBImAC                   other
CBIjA*
CBIjA*    Compute qty to adjust from pick slot.
CBIjAC                   eval      wkAdjQty = wkStkQty - wkNewQty
CBImAC                   endsl
CBIjA*
CBIjA*    Compute adjust qty back to qty1, qty2 and qty3.
CBIjAC                   eval      wkQty3    = %rem(wkAdjQty : itumq3)
CBIjAc                   eval      wkQty3    = wkQty3 * -1
CBIjAC                   eval      wkTtlQty  = %div(wkAdjQty : itumq3)
CBIjA*
CBIjAC                   eval      wkQty2    = %rem(wkTtlQty : itumq2)
CBIjAc                   eval      wkQty2    = wkQty2 * -1
CBIjAC                   eval      wkTtlQty  = %div(wkTtlQty : itumq2)
CBIjA*
CBIjAC                   eval      wkQty1    = wkTtlQty
CBIjAc                   eval      wkQty1    = wkQty1 * -1
CBIjA*
CBIjAC                   endsr
CBIjA*
CBIjA*----------------------------------------------------------------
CBIjA*
CBIjA*  ZZAVAIL   Calculate available quantities for slot.
CBIjA*
CBIjAC     zzavail       begsr
CBIjA*
CBIjA*  Call program to calculate availabe slot quantities.
CBIjA*
CBIjAC                   call      'SLOTQTY'
CBIjAC                   parm                    slstk1
CBIjAC                   parm                    slstk2
CBIjAC                   parm                    slstk3
CBIjA*
CBIjAC                   parm                    slalc1
CBIjAC                   parm                    slalc2
CBIjAC                   parm                    slalc3
CBIjA*
CBIjAC                   parm                    sltfr1
CBIjAC                   parm                    sltfr2
CBIjAC                   parm                    sltfr3
CBIjA*
CBIjAC                   parm                    slpck1
CBIjAC                   parm                    slpck2
CBIjAC                   parm                    slpck3
CBIjA*
CBIjAC                   parm                    slrcv1
CBIjAC                   parm                    slrcv2
CBIjAC                   parm                    slrcv3
CBIjA*
CBIjAC                   parm                    stock1            5 0
CBIjAC                   parm                    stock2            3 0
CBIjAC                   parm                    stock3            3 0
CBIjA*
CBIjAC                   parm                    avail1            5 0
CBIjAC                   parm                    avail2            3 0
CBIjAC                   parm                    avail3            3 0
CBIjA
CBIjA*  Call program to get open Directed Putaway quantity.
CBIjA
CBIjAC                   call      'CHKOPNDP'
CBIjAC                   parm      slwhse        dWhse             3 0
CBIjAC                   parm      slwhdp        dWhdp             5
CBIjAC                   parm      sldisp        dDisp            12
CBIjAC                   parm      slitem        dItem            15
CBIjAC                   parm                    dTotal            3 0
CBIjAC                   parm                    dItmTtl           3 0
CBIjAC                   parm                    dQty1             5 0
CBIjAC                   parm                    dQty2             5 0
CBIjAC                   parm                    dQty3             5 0
CBIjA
CBIjAC                   eval      avail1 += dQty1
CBIjAC                   eval      avail2 += dQty2
CBIjAC                   eval      avail3 += dQty3
CBIjA
CBIjA*  Set negative quantities to zero
CBIjA
CBIjAC                   if        avail1 < 0
CBImDC*                  eval      avail1 = 0
CBIjAC                   endif
CBIjAC                   if        avail2 < 0
CBImDC*                  eval      avail2 = 0
CBIjAC                   endif
CBIjAC                   if        avail3 < 0
CBImDC*                  eval      avail3 = 0
CBIjAC                   endif
CBIjA*
CBIjAC                   endsr
CBIjA*
CBIjA*----------------------------------------------------------------
CBIjA*  Fill $DRI fields for slot adjustment
CBIjAC     zzFill$Adj    begsr
CBIjA*
CBIjA
CBIjA*  Initialize data structure
CBIjA
CBIjAc                   eval      savever# = $slver#
CBIjAc                   clear                   $slot
CBIjAc                   clear                   $slot2
CBIjAc                   eval      $slver# = savever#
CBIjAc                   eval      $dricommand = '*SLOT'
CBIjAc                   eval      $drisubcmd  = '%ADJUSTORD'
CBIjAc                   eval      $drisys2upd = 'D'
CBIjA
CBIjA*  Move fields from record to data structure.
CBIjA
CBIjAc                   eval      $slwhseu = *on
CBIjAc                   eval      $slwhse  = ijwhse
CBIjA
CBIjAc                   eval      $slwhdpu = *on
CBIjAc                   eval      $slwhdp  = itwhdp
CBIjA
CBIjAc                   eval      $sldispu = *on
CBIjAc                   eval      $sldisp  = sldisp
CBIkA*
CBIkA*       If slot is empty and no expiration date, set fifo flag on.
CBIkA*       After qty update is complete, then setfifo routine is run.
CBIkAC                   if            slstk1 = 0
CBIkAC                             and slstk2 = 0
CBIkAC                             and slstk3 = 0
CBIkAC                             and slexpd >= 0
CBIkAC                             and itflgd = 'Y'
CBIkAC                   eval      setfifo = '1'
CBIkAC                   endif
CBIjA
CBIjAc                   eval      $saitemu = *on
CBIjA*
CBIjAc                   eval      $saitem  = slitem
CBIjA*
CBIjAc                   eval      $saqtyu  = *on
CBIkA
CBIjAc                   eval      $saqty1  = wkQty1
CBIjAc                   eval      $saqty2  = wkQty2
CBIjAc                   eval      $saqty3  = wkQty3
CBIjA
CBIjAc                   eval      $sacwtau = *off
CBIjAc                   eval      $sacwta  = 0
CBIjA
CBIjAc                   eval      $sacodeu = *on
CBIjAc                   eval      $sacode  = 'HQ'
CBIjA
CBIjAc                   eval      $samemou = *on
CBIjAc                   eval      $samemo  = ijbatid
CBIjA
CBIjAc                   eval      $sabyu   = *on
CBIjAc                   eval      $saby    = #user
CBIjAC                   eval      $saActionU = *on
CBIjAC                   eval      $saAction = 'ADJ'
CBIjA
CBIjAC                   if        usrfound = '1'
CBIjAC                   eval      $saemp#U = *on
CBIjAC                   eval      $saemp#  = #emp#
CBIjAC                   else
CBIjAC                   eval      $saemp#U = *off
CBIjAC                   eval      $saemp#  = 0
CBIjAC                   endif
CBIjA*
CBIjAC                   endsr
CBIjA*
CBIjA*----------------------------------------------------------------
CBIjA*
CBIjA*  ZZUPDPICK - Update pick slot quantity
CBIjA*
CBIjAC     zzupdpick     begsr
CBIjA*
CBIjAc                   eval      wkError = *off
CBIjA
CBIjA*   Call interface to do update.
CBIjA
CBIjAc                   eval      $dricommand = '*SLOT'
CBIjAc                   eval      $drisubcmd  = '%ADJUSTORD'
CBIjAc                   eval      $drisys2upd = 'D'
CBIjA*
CBIjAc                   exsr      ZzzDriCop
CBIkA*
CBIkA*       If slot is empty and no expiration date, set default exp date.
CBIkAC                   if        setfifo = '1'
CBIkAC                   exsr      zzupdl
CBIkAC                   endif
CBIjA*
CBIjAC                   endsr
CBIkA
CBIkA*----------------------------------------------------------------
CBIkA*
CBIkA*  ZZUPDl   Update slot and licactive records
CBIkA*
CBIkAC     zzupdl        begsr
CBIkA*
CBIkAC                   move      *off          error
CBIkA*
CBIkA*   Lookup license for FIFO date update.
CBIkAC     keyla1        setll     licactive1
CBIkAC     keyla1        reade     licactive1
CBIkAC                   if        %eof(licactive1)
CBIkAC                   eval      lalcns  = ' '
CBIkAC                   eval      laolcns = ' '
CBIkAC                   endif
CBIkA
CBIkA*   Load Interface Fields
CBIkA
CBIkAC                   exsr      clr$slot
CBIkA
CBIkAC                   eval      $slwhseu = *on
CBIkAC                   eval      $slwhse  = ijwhse
CBIkAC                   eval      $slwhdpu = *on
CBIkAC                   eval      $slwhdp  = slwhdp
CBIkAC                   eval      $sldispu = *on
CBIkAC                   eval      $sldisp  = sldisp
CBIkAC                   eval      $slitemu = *on
CBIkAC                   eval      $slitem  = slitem
CBIkAC                   if        itflgd = 'Y'
CBIkAC                   eval      $slexpdu = *on
CBIkAC                   eval      $slexpd  = today1
CBIkAC                   else
CBIkAC                   eval      $slexpdu = '0'
CBIkAC                   eval      $slexpd = 0
CBIkAC                   endif
CBIkAC                   eval      $slentdu = *on
CBIlDC*                  eval      $slentd  = slentd
CBIlMC                   eval      $slentd  = today
CBIlDC*                  if        $slentd = 0
CBIlDC*                  eval      $slentd = today
CBIlDC*                  endif
CBIkAC                   eval      $slprtyu = *on
CBIkAC                   eval      $slprty  = slprty
CBIkAC                   eval      $saToLcnsu = *on
CBIkAC                   eval      $saToLcns  = lalcns
CBIkAC                   eval      $saActionu = *on
CBIkAC                   eval      $saAction  = 'FIF'
CBIkAC                   eval      $saOLcnsu  = *on
CBIkAC                   eval      $saOLcns   = laolcns
CBIkA
CBIkAC                   if        usrfound = '1'
CBIkAC                   eval      $saemp#U = *on
CBIkAC                   eval      $saemp#  = #emp#
CBIkAC                   else
CBIkAC                   eval      $saEmp#u   = *off
CBIkAC                   eval      $saEmp#    = 0
CBIkAC                   endif
CBIkA*
CBIkAC                   eval      $satrn#u = *on
CBIkAC                   eval      $satrn#  = 0
CBIkA
CBIkAC                   eval      $dricommand = '*SLOT   '
CBIkAC                   eval      $drisubcmd  = '%SETFIFO'
CBIkAC                   eval      $drisys2upd = 'D'
CBIkAC                   eval      chk4err = *on
CBIkAC                   exsr      zzzdricop
CBIkAC*
CBIkAC                   if        error
CBIkA*
CBIkAC                   endif
CBIkAC*
CBIkAC     endupdl       endsr
CBIhA*
CBIhA*----------------------------------------------------------------
CBIhA*  Assign pick slots to Production items.
CBIhAC     zzassignpk    begsr
CBIhA*
     C     keyij2        setll     impspqty
     C                   dow       forevr = forevr
     C     keyij2        reade     impspqty
     C                   if        %eof(impspqty)
     C                   leave
     C                   endif
     *
     *   Process rcds still open in import file w/qty.
     C                   if           ijstatus = 'R'
     C                             and (ijtqh1 <> 0
     C                               or ijtqh2 <> 0)
     *
     C                   if        *inl1 = '1'
     C                   write     head1
     C                   write     head2
     C                   write     columns
     C                   eval      *inl1 = '0'
     C                   endif
     *
     C     keyit2        chain     piritem
     C                   if        not %found(piritem)
     C                   eval      itdesc = *blanks
CBIjAC                   eval      itumq2 = 0
CBIjAC                   eval      itum2  = ' '
CBIjAC                   eval      itumq3 = 0
CBIjAC                   eval      itum3  = ' '
     C                   endif
CBIjA*
CBIjA*    Set Brkdwn 1 qty for conversion calcs below.
CBIjAC                   if        itumq2 <= 0
CBIjAC                             or ittype = 'S'
CBIjAC                   eval      itumq2 = 1
CBIjAC                   endif
CBIjA
CBIjA*    Set Brkdwn 2 qty for conversion calcs below.
CBIjAC                   if        itumq3 <= 0
CBIjAC                             or ittype = 'S'
CBIjAC                   eval      itumq3 = 1
CBIjAC                   endif
     *
CBIhAC     keyit2        chain     itemmsc
CBIhAC                   if        not %found(itemmsc)
CBIhAC                   eval      imbnbr = 0
CBIhAC                   eval      imbnam = ' '
CBIhAC                   endif
     *
     C                   if            itwhdp = 'CLR'
     C                             and (imbnbr = 150
     C                               or imbnbr = 155
     C                               or imbnbr = 160)
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'Y'
     C     keysl3pk      setll     slot3
     C     keysl3pk      reade (n) slot3
     C                   if        %eof(slot3)
     *
     *       Create virtual pick slots for buyer items below.
     C                   exsr      zzcrtpk
     *       Unable to create pick slot for item.
     C                   select
     C                   when          Error = '1'
     C                             and $drireturn <> 'VRTPCKCRT'
CBIhAC                   eval      ijstatus = 'E'
CBIhAC                   eval      ijtext = $drimessage
CBIhAC                   exsr      zzzGetStamps
CBIhAC                   eval      ijststs = stamp
CBIhAC                   eval      ijstsuc = stampuc
CBIhAC                   update    ijrec
CBIhA*
CBIhAC                   iter
CBIhA*
CBIhAC                   when          Error = '1'
CBIhAC                             and $drireturn = 'VRTPCKCRT'
CBIhA*       Load virtual slot created msg details.
CBIhAC                   eval      ijtext = $drimessage
CBIqA*       Populate key fields with new virtual slot.
CBIqAC                   eval      slwhdp = $slwhdp
CBIqAC                   eval      sldisp = $sldisp
CBIhAC                   endsl
CBIhA*
CBIhAC                   endif
     *
CBIjD*      Lock slot record for update at this point.
CBIjD*      Lock on slot rcd no longer needed. Qty updated via adjustment.
CBIjDC*    keysl2        chain     slot2
CBIjMC     keysl2        chain (n) slot2
     C                   if        not %found(slot2)
     C                   iter
     C                   endif
     *
     *       Compute overflow qty for item.
     C                   exsr      oflqty
     *
     C                   eval      pckqt1 = ijtqh1 - ofqty1
     C                   eval      pckqt2 = ijtqh2 - ofqty2
     *
     *  Write detail line.
     *
     C                   eval      t#disp = sldisp
     C                   eval      t#item = slitem
     C                   write     detail1
     *
     *  Update pick slot.
     *
CBIhAC                   if            itflgd = 'Y'
CBIhAC                             and slexpd < today
CBIjDC*                  eval      slexpd = today1
CBIhAC                   endif
     *
CBIe *  Total allocate and pick qty.
CBIeAC                   eval      ckqty1 = 0
CBIeAC                   eval      ckqty2 = 0
CBIeAC     slalc1        add       slpck1        ckqty1
CBIeAC     slalc2        add       slpck2        ckqty2
CBIjDC*                  z-add     pckqt1        slstk1
CBIjDC*                  z-add     pckqt2        slstk2
CBIj *
CBIjAC                   if        client = Cheney
CBIjAC                   if           pckqt1 <> 0
CBIjAC                             or pckqt2 <> 0
CBIjAC                   exsr      zzclcpick
CBIjAC                   if           wkqty1 <> 0
CBIjAC                             or wkqty2 <> 0
CBIjAC                             or wkqty3 <> 0
CBIjAC                   exsr      zzFill$adj
CBIjAC                   exsr      zzupdpick
CBIjA*
CBIjAC                   endif
CBIjA*
CBIjAC                   endif
CBIjA*
CBIjAC                   endif
CBIg *
CBIg *  Check if special designation slot, set status = Z if empty.
CBIgAC                   if        sldesg <> ' '
CBIjAC     keysl2        chain     slot2
CBIgAC     sldesg        chain     desigsp
CBIgAC                   if        %found(desigsp) and
CBIgAC                             slstk1 = 0  and
CBIgAC                             slstk2 = 0  and
CBIgAC                             slstk3 = 0  and
CBIgAC                             slrcv1 = 0  and
CBIgAC                             slrcv2 = 0  and
CBIgAC                             slrcv3 = 0  and
CBIgAC                             sltfr1 = 0  and
CBIgAC                             sltfr2 = 0  and
CBIgAC                             sltfr3 = 0  and
CBIgAC                             slpck1 = 0  and
CBIgAC                             slpck2 = 0  and
CBIgAC                             slpck3 = 0
CBIgAC                   eval      slstat = 'Z '
CBIjAC                   update    slrec2
CBIgAC                   endif
CBIjAC                   unlock    slot2
CBIgAC                   endif
     *
CBIjDC*                  update    slrec2
     *
     * Recalculate item qty for slot item
CBIjDC*                  eval      $item = slitem
CBIjDC*                  exsr      zzrcal
     *
     * Update License Information for item.
CBIjDC*                  call      'LT001CL'
CBIjDC*                  parm      'SI '         $lAction          3
CBIjDC*                  parm      slwhse        $lwhse            3 0
CBIjDC*                  parm      slwhdp        $lwhdp            5
CBIjDC*                  parm      sldisp        $ldisp           12
CBIhA*
CBIhA*       Mark import record update complete.
CBIhAC                   if        ijstatus = 'R'
CBIhAC                   eval      ijstatus = 'S'
CBIhAC                   exsr      zzzGetStamps
CBIhAC                   eval      ijststs = stamp
CBIhAC                   eval      ijstsuc = stampuc
CBIhAC                   update    ijrec
CBIhAC                   endif
CBIhA*
CBIhAC******             endif
CBIhA*
CBIhAC                   endif
CBIhA*
CBIhAC                   endif
CBIhA*
CBIhAC                   enddo
CBIhA*
CBIhA*   Do some clean up before leaving.
CBIhAC                   exsr      zzzdriclose
CBIhA*
CBIhAC                   endsr
CBIhA*
CBIhA*----------------------------------------------------------------
CBIhA*  Create pick slots based on buyer number.
CBIhAC     zzcrtpk       begsr
CBIhA*
CBIhA
CBIhA*  Use DRI interface to do everything, including creating VSlot.
CBIhA
500dAC                   exsr      clr$slot
416fAC                   eval      $slwhseu = *on
416fAC                   eval      $slwhse  = itwhse
416fAC                   eval      $slwhdpu = *on
416fAC                   eval      $slwhdp  = itwhdp
416fAC                   eval      $sldispu = *on
CBIhAC                   select
CBIhAC                   when      clientloc = cbigr
CBIrAC                             or %subst(whdesc:13:3) = 'CFR'
CBIhAC                   select
CBIhAC                   when         imbnbr = 150
CBIhAC                             or imbnbr = 160
CBIqAC                   eval      $slaisl  = ' MT'
CBIqAC                   eval      $slaislu = *on
CBIqAC                   eval      $slloc   = 101
CBIqAC                   eval      $sllocu  = *on
CBIqAC                   eval      $slrlvl  = 1
CBIqAC                   eval      $slrlvlu = *on
CBIqAC                   eval      $slhand  = ' '
CBIqAC                   eval      $slhandu = *on
CBIqDC*                  eval      $sldisp  = 'MT-84-09'
CBIqMC                   eval      $sldisp  = 'MT-101-1'
CBIhA*
CBIhAC                   when         imbnbr = 155
CBIqAC                   eval      $slaisl  = ' FS'
CBIqAC                   eval      $slaislu = *on
CBIqAC                   eval      $slloc   = 100
CBIqAC                   eval      $sllocu  = *on
CBIqAC                   eval      $slrlvl  = 1
CBIqAC                   eval      $slrlvlu = *on
CBIqAC                   eval      $slhand  = ' '
CBIqAC                   eval      $slhandu = *on
CBIqDC*                  eval      $sldisp  = 'FI-00-11'
CBIqMC                   eval      $sldisp  = 'FS-100-1'
CBIhAC                   endsl
CBIhA*
CBIhAC                   endsl
CBIhA*
CBIhAC                   eval      $slitemu = *on
CBIhAC                   eval      $slitem  = ititem
CBIhAC                   eval      $dricommand = '*SLOT'
CBIhAC                   eval      $drisubcmd = '%CRTVPICK'
CBIhAC                   eval      $drisys2upd = 'D'
CBIhAC                   eval      chk4err = *on
CBIhAC                   exsr      zzzdricop
CBIhAC                   if        error
CBIhAC                   endif
CBIhA*
CBIhAC                   endsr
CBIhA*
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     *   Get warehouse description.
     *
     C                   eval      whse = *blanks
     C                   eval      $pstr = *blanks
     C     slwhse        chain     warehs                             79
     C                   if        not *in79
     C                   movel     whdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 30
     *
     *   Center warehouse description.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         whse
     *
     *  Format Dept/Section/Aisle
     *
     C                   if        slstyp = 'P'
     C                   eval      type = 'PIR  '
     C                   else
     C                   if        slstyp = 'F'
     C                   eval      type = 'Fixed'
     C                   else
     C                   eval      type = '*None'
     C                   endif
     C                   endif
     C                   eval      p#desc = *blanks
     C     'Type:'       cat       type:1        p#desc
     C     p#desc        cat       'Dept:':2     p#desc
     C     p#desc        cat       slwhdp:1      p#desc
     C     p#desc        cat       'Aisle':2     p#desc
     C     p#desc        cat       ':':0         p#desc
     C                   if        slaisl = *blanks
     C     p#desc        cat       '*NONE':1     p#desc
     C                   else
     C     p#desc        cat       slaisl:1      p#desc
     C                   endif
     C                   movel     p#desc        $lstr
     C                   eval      $llen = 40
     C                   call      'CENTER'
     C                   parm                    $lstr
     C                   parm                    $llen
     C                   movel     $lstr         p#desc
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     C                   if        *inl1
     C                   exsr      zrfrmt
     C                   else
     C                   eval      *in91 = *on
     C                   endif
     *
     C                   eval      *in90 = *off
     *
     C                   write     head1
     C                   write     head2
     C                   write     columns
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrroll        begsr
     *
     C     l             add       1             m
     C                   add       reck(l)       reck(m)
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrzero        begsr
     *
     C                   eval      reck(l) = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
CBIaA*  ZZRCAL   Recalculate item quantity from slots.
     *
CBIaAC     zzrcal        begsr
     *
     * Recalculate item qty.
     C                   eval      $pwhs = slwhse
     C                   eval      $jtyp = *off
     C                   eval      $lprg = #prog
     C                   eval      $lrtn = *blanks
     C                   eval      $lmsg = *blanks
     C                   call      'UT812'
     C                   parm                    $pwhs
CBIjDC*                  parm                    $item
CBIjMC                   parm                    $uitem
     C                   parm                    $jtyp
     C                   parm                    $lprg
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     *
CBIaAC     endcal        endsr
CBIhA
CBIhA*----------------------------------------------------------------
CBIhA*----------------------------------------------------------------
CBIhA*                     DRI Subroutines
CBIhA*----------------------------------------------------------------
CBIhA*----------------------------------------------------------------

CBIhA*----------------------------------------------------------------
CBIhA*  clr$slot  Clear $slot data structure fields
CBIhA*----------------------------------------------------------------
CBIhA
CBIhAC     clr$slot      begsr
CBIhAC                   eval      savever# = $slver#
CBIhAC                   clear                   $slot
CBIhAC                   clear                   $slot2
CBIhAC                   eval      $slver# = savever#
CBIhAC                   endsr
CBIhA
CBIhA*----------------------------------------------------------------
CBIhA*  zzzdriclose   Close any open files or programs.
CBIhA*----------------------------------------------------------------
CBIhA
CBIhAC     zzzdriclose   begsr
CBIhA
CBIhA*  Close interfaces
CBIhA
CBIhAC                   eval      $dricommand = '*SLOT'
CBIhAC                   eval      $drisubcmd  = '%CLOSE'
CBIhAC                   eval      $drisys2upd = 'D'
CBIhAC                   eval      chk4err = *off
CBIhAC                   exsr      zzzdricop
CBIhA
CBIhAC                   endsr
CBIhA
CBIhA*----------------------------------------------------------------
CBIhA*  zzzdricop  Call DRICOP
CBIhA*----------------------------------------------------------------
CBIhA
CBIhAC     zzzdricop     begsr
CBIhAC                   eval      error = *off
CBIhA
CBIkAC                   select
CBIkAC                   when      $dricommand = '*SLOT   '
CBIhAC                   eval      $dridata = $slot
CBIhAc                   eval      $dridata2 = $slot2
CBIkAC                   endsl
CBIhA
CBIkAC                   if        $dricommand = '*SLOT   '
CBIhAC                   call(e)   'DRICOP'
CBIhAC                   parm                    $dricommand
CBIhAC                   parm                    $drisubcmd
CBIhAC                   parm                    $drisys2upd
CBIhAC                   parm      #pgm          $driprogram
CBIhAC                   parm      ' '           $drireturn
CBIhAC                   parm      ' '           $drimessage
CBIhAC                   parm                    $dridata
CBIjAc                   parm                    $dridata2
CBIkA
CBIkAC                   else
CBIkA
CBIkAC                   call(e)   'DRICOP'
CBIkAC                   parm                    $dricommand
CBIkAC                   parm                    $drisubcmd
CBIkAC                   parm                    $drisys2upd
CBIkAC                   parm      #pgm          $driprogram
CBIkAC                   parm      ' '           $drireturn
CBIkAC                   parm      ' '           $drimessage
CBIkAC                   parm                    $dridata
CBIkAC                   endif
CBIhA
CBIhAC                   select
CBIhA
CBIhAC                   when      chk4err and %error
CBIhAC                   eval      error = *on
CBIhAC***                eval      errmsg    = 'Error occured on call to '
CBIhAC***                                    + 'DRICOP'
CBIhAC***                                    + '/' + %trim($drisubcmd)
CBIhAC***                                    + ' from ' + #prog
CBIhAC***                exsr      zm0105
CBIhA
CBIhAC                   when      chk4err and $drireturn <> '*OK'
CBIhAC                   eval      error = *on
CBIhAC***                exsr      zm0001
CBIhAC***                exsr      zzerrind
CBIhA
CBIhAC                   endsl
CBIhA
CBIkAC                   select
CBIkAC                   when      $dricommand = '*SLOT   '
CBIhAC                   eval      $slot = $dridata
CBIhAc                   eval      $slot2 = $dridata2
CBIkAC                   endsl
CBIhA
CBIhAC                   eval      chk4err = *off
CBIhAC     enddricop     endsr
CBIhA*
650aA*----------------------------------------------------------------
650aA*
650aA*  ZZZCLS812   Close UT812
650aA*
650aAC     zzzcls812     begsr
     C                   call      'UT812'
     C                   parm                    $pwhs
     C                   parm      '*CLOSE'      $item
     C                   parm                    $jtyp
     C                   parm                    $lprg
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     C                   endsr
640aA*----------------------------------------------------------------
640aA*  zzzEnd     End processing
640aA*----------------------------------------------------------------
640aA
640aAc     zzzEnd        begsr
      /free

        if importError;
          sbstatus = 'E';
          sbtext   = 'Import completed with error(s). See impsstuf file.';
        else;
          sbstatus = 'S';
          sbtext   = 'Import completed successfully';
        endif;

        exec sql
          update stgbatch
          set sbstatus = :sbstatus,
              sbtext   = :sbtext,
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbendts  = current_timestamp,
              sbenduc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :$pBatId;

        if sqlstt <> sqlSuccess;
          $pReturn = '*SIUPDERR';
          $pMessage = %trimr(sbtext) + ' - '
                    + 'Error updating STGBATCH file for '
                    + 'batch id ' + %trim($pBatId) + ' '
                    + '- SQLSTT ' + sqlstt + ' '
                    + '- hq121s/zzzend';
          leavesr;
        endif;

      /end-free
     c                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzGetStamps   Get timestamps
640aA*----------------------------------------------------------------
640aA
640aAc     zzzGetStamps  begsr
      /free

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

      /end-free
     c                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzStart   Start processing
640aA*----------------------------------------------------------------
640aA
640aAc     zzzStart      begsr
      /free

        exec sql
          update stgbatch
          set sbstatus = 'P',
              sbtext   = 'Import started',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbstrts  = current_timestamp,
              sbstruc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :$pBatId;

        if sqlstt <> sqlSuccess;
          $pReturn = '*SIUPDERR';
          $pMessage = 'Error updating STGBATCH file for '
                    + 'batch id ' + %trim($pBatId) + ' '
                    + '- SQLSTT ' + sqlstt + ' '
                    + '- hq121s/zzzstart';
          leavesr;
        endif;

        importError = *off;

      /end-free
     c                   endsr

     *----------------------------------------------------------------
     *
     * Compile time tables
     *
