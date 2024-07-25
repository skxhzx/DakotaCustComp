     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  SI285     FTP StuffIt Import 4 - Post
     *  20 July 2009
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  NOTES:
     *      - Must compile at V5R3 or greater
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    07/20/09  MLB  5.20
     *      - Created
     *      - Includes client custom code support.
     *
610aA*    03/01/09  DAS  6.00a  P#00065
     *     - Enh: Revised to call LT001 at the end of the program to
     *       to sychronize licsense plate qty's with slot qtys.
     *
610bA*    07/22/09  DAS  6.10b
     *     - Fix: Revised getslot to set 'U' field flags and
     *       to send data parameter.
     *
610cA*    07/22/09  DAS  6.10c
     *     - Enh: Revised to call *LICENSE with %SETLCNS after
     *        slot is created or updated in zzupd.
     *
610dA*    07/22/09  DAS  6.10d
     *     - Fix: Revised zzckdgt to clear detmsg.
610eA*    08/10/09  MLB  6.10e
     *     - Enh: Revised program to edit SIRCVD before processing into
     *        Entered Date (SLENTD).
     *     - Added new message to array DESC.
     *
650 A*    01/09/13  MLB  6.50
     *     - Fix: Revised program to pass SU to LT001 instead of FIX.
     *
710 A*    02/05/17  MLB  7.10
     *     - Fix: Revised pgm to check for slot with qty, but no item
     *        and flag error.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval Foods
     *
SVLaA*    02/03/09  MLB  SVLa
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
SVLbA*    03/10/09  MLB  SVLb
     *      - Createed new routine, CRTSLOT1 to proces Saval slots,
SVLcA*    08/11/09  MLB  SVLc  * Mod disabled 09/05/09.
     *      - *Temp Mod* Chg'd pgm to allow "Dept Mis-Match" error to
     *         be ignored for items in dept 3.
SVLdA*    08/11/09  MLB  SVLd  * Mod disabled 09/05/09.
     *      - Enh: Revised program to load dept 3 when SIWHDP=2 and
     *        1st character of SIDISP=C.
SVLeA*    08/27/09  MLB  SVLe
     *     - Fix: Revised program to run routine ZRRCAL after processing
     *        slots.
     *     - Added SVLe to EI6 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: European Imports
     *
EI  A*    01/25/06  MLB  EI
     *      - Revised program to add new routine CRTSLOT2 to create
     *        slots based on European Import's format.
 I1 A*    02/06/06  MLB  EI1
     *      - Revised program to not add 1 to rack level unless rack
     *        level is zero.
EI2 A*    08/02/11  MLB  EI2  * Do Not Include in Base Code **
     *      - Revised program to create slot in department assigned
     *        to item when SIWHDP does not match ITWHDP.
     *        This is only for going live with Inbound/Outbound. Certain
     *        items are in Candy dept, but physically reside in the REF
     *        dept.
EI3 A*    08/02/11  MLB  EI3
     *      - Revised program to create virtual slots when an item has
     *        2 or more license plates for the same overflow slot.
EI4 A*    08/03/11  MLB  EI4
     *      - Revised program to update the slot qty for pick slots
     *        instead of replacing the existing qty.
EI5 A*    08/03/11  MLB  EI5
     *      - Revised program to load SIRCVD in YYYYMMDD format instead
     *        of MMDDYY format.
EI6 A*    08/03/11  MLB  EI6
     *      - Revised program to call routine ZZRCAL before exiting
     *        the program to recalc warehouse qty.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Get Fresh Sales.
     *
GFS A*    01/09/13  MLB  GFS
     *      - Revised program to add new routine CRTSLOT3 to create
     *        slots based on Get Fresh's format.
     *        Sample slot: 10-101-1A where 10=Aisle, 101=Location, 1
     *        rack level and A=Handstack.
GFS1A*    01/09/13  MLB  GFS1
     *      - Revised program to not run routine ZZCKDGT.
     *      - Added GFS1 to SVLa mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Halsey Foodservice
     *
HAL A*    08/19/09  MLB  HAL
     *      - Revised program to create slots based on HAL format.
HALaA*    08/19/09  MLB  HALa
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
HALbA*    09/14/09  MLB  HALb
     *      - Revised program to call ZZRCAL routine before exiting
     *        program to update warehouse qty's.
     *      - Added HALb to FRFd mod.
HALcA*    07/14/17  MLB  HALc
     *      - Revised program to load SIRCVD in YYYYMMDD format instead
     *        of MMDDYY format.
     *      - Added HALc to EI5 mod.
HALdA*    07/14/17  MLB  HALd
     *      - Revised program to create virtual slots when an item has
     *        2 or more license plates for the same overflow slot.
     *      - Added HALd to EI3 mod.
HALeA*    07/17/17  MLB  HALe
     *      - Revised HALc mod to default rcv'd date to today's date
     *        in YYYYMMDD format. Pick slot entries do not have a
     *        valid date.
HALfA*    07/20/17  MLB  HALf
     *      - Revised program to update the slot qty for pick slots
     *        instead of replacing the existing qty.
     *      - Added HALf to EI4 mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers - Pate Dawson
     *
CBIaA*    01/11/17  MLB  CBIa
     *      - Revised program to not run routine ZZCKDGT.
     *        Added CBIa to GSC1 mod.
CBIbA*    02/03/17  MLB  CBIb
     *      - Revised program to load slots for Pate Dawson whses
     *        in their custom format. Added routine, CRTSLOT4
     *        Sample slot: AC-64-B4 where AC=Aisle, 64=Location and
     *        B=Rack level (converted to 2) and 4=Handstack (converted
     *        to D).
     *        Sample slot: MA-00-12 where MA=Aisle, 00=Location and
     *        1=Rack level and 2=Handstack (converted to B)
CBIcA*    02/05/17  MLB  CBIc
     *      - Revised program to call routine ZZRCAL before exiting
     *        the program to recalc warehouse qty.
     *        Added CBId to EI6 mod.
CBIdA*    02/07/17  MLB  CBId
     *      - Revised program to disable call to CRTSLOT4. This pgm
     *        will update slot with item/qty only.
     *        Change to CBIb mod.
CBIeA*    02/11/17  MLB  CBIe
     *      - Revised program to run through IMPFSTUF4 and update dept
     *        and section type from PIRITEM for all rcds where item
     *        is greater than blanks. Data problems on Target.
CBIfA*    03/29/17  MLB  CBIf
     *      - Revised program to check if pick slot already has item
     *        assigned. If yes, then print on exception report and
     *        skip update. Only for pick slots.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jake's Finer Foods
     *
JFF A*    02/27/18  MLB  JFF
     *      - Revised program to not run routine ZZCKDGT.
     *        Added JFF to GSC1 mod.
JFFaA*    02/27/18  MLB  JFFa
     *      - Revised program to load slots for Jakes whse
     *        in their custom format. Added routine, CRTSLOT5
     *        Sample slot: UH116-02A where UH=Aisle, 116=Location and
     *        02=Rack level and A=Handstack
JFFbA*    02/27/18  MLB  JFFb
     *      - Revised program to bypass run of LT001 since outbound only.
JFFcA*    06/10/21  MLB  JFFc
     *      - Revised program to bypass run of ZZUPDLCNS from ZZUPD since
     *        Jake's is Outbound Only.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: A&D Foods
     *
ADFa *    08/15/16  RTR  ADFa
     *      - Revised program to add new routine CRTSLOT33 to create
     *        slots based on ADF's format.
     *      - Sample slot: 5B107-3
     *              where: 5B=Aisle, 107=Location and 3=Rack level.
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

CBIeDF*impfstuf4 if   e           k disk
CBIeMFimpfstuf4 uf   e           k disk
     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
     Foptiond   if   e           k disk
     Fslotdgt   uf a e           k disk
     Fslot2     uf a e           k disk
     Fvslot2    uf a e           k disk
     Fsi285pr   o    e             printer oflind(*in91)

     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------

SVL AD/copy qcopysrc,id#saval
EI  AD/copy qcopysrc,id#ei
GFS AD/copy qcopysrc,id#gfs
HAL AD/copy qcopysrc,id#halsey
CBIaAD/copy qcopysrc,id#cheney
JFF AD/copy qcopysrc,id#jff
ADFaAD/copy qcopysrc,id#adf

     D client          s             10
     D clientloc       s             10

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
      /COPY *libl/qcopysrc,C#DRIPARMP
     D savesubcmd      s                   like($psubcmd)
     D savesubcmd2     s                   like($psubcmd)

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
610cA /COPY *libl/qcopysrc,C#LICENSE
     D saveVer#        s                   like($slver#)
     D driitem         s               n   inz(*off)
     D drislot         s               n   inz(*off)

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a2              s              1    dim(2)
     D a2n             s              1    dim(2)
610cDD*desc            s             20    dim(12) ctdata perrcd(1)
610eDD*desc            s             20    dim(13) ctdata perrcd(1)
710 DD*desc            s             20    dim(14) ctdata perrcd(1)
710 MD desc            s             20    dim(15) ctdata perrcd(1)
     D rdsc            s             50    dim(1) ctdata perrcd(1)
     D hnd             s              2    dim(702)
     D ltr             s              1    dim(27) ctdata perrcd(27)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $jobq           s              1
     D $pwhs           s             15  5
     D $vaisl          s              3
     D $vloc           s              3  0
     D $vpick          s              1
     D $vpseq          s              5  0
     D $vrlvl          s              2  0
     D $vstyp          s              1
     D $vwhdp          s              5
     D $vwhse          s              3  0
     D allchrslot      s              1    inz('0')
610bAD ck4err          s              1
     D crtbaseslot     s              1    inz('0')
     D count           s              3  0
     D dftlocation     s              3  0 inz(600)
     D digits          c                   const('0123456789')
     D dummy           s                   like(slloc)
610bAD  errmsg         s             50
     D exist           s              1
     D flaghs          s              1
     D forevr          s              1
     D good1           s              1
     D handstack       s              1     inz('0')
     D impdte          s              8  0
     D imptim          s              6  0
     D k               s              3  0
     D kycode          s                   like(opdcod)
     D kydisp          s                   like(sldisp)
     D len             s              1  0
     D linppg          s              3  0
     D lstwhd          s              5
     D lstwhs          s              3  0
     D newvs           s              1
     D nwchar          s              2
     D oddeven         s                   like(slloc)
     D odisp           s                   like(sldisp)
     D pflag           s              1
     D phactv          s                   like(slactv)
     D phaisl          s                   like(slaisl)
     D phbld           s                   like(slbld)
     D phdesg          s                   like(sldesg)
     D phdisp          s                   like(sldisp)
     D phhand          s                   like(slhand)
     D phloc           s                   like(slloc)
     D phpseq          s                   like(slpseq)
     D phrlvl          s                   like(slrlvl)
     D phsdef          s                   like(slsdef)
     D phside          s                   like(slside)
     D phslfd          s                   like(slslfd)
     D phstyp          s                   like(slstyp)
     D phwhdp          s                   like(slwhdp)
     D phwhse          s                   like(slwhse)
     D pos             s              1  0
     D ssbflg          s              1
     D svexpd          s                   like(slexpd)
     D svhand          s                   like(slhand)
EI2 AD svwhdp          s                   like(siwhdp)
     D validdept       s              4    inz('*YES')
     D wkchar          s              2
     D work3a          s              3
     D temp6a          s              6

     D dashpos         s              2  0
     D loca            s              3
     D lvla            s              1
JFFaAD lvlaa           s              2
JFF2AD lvla2           s              2
     D locnotnum       s               n
     D lvlnotnum       s               n
     D notcreated      s               n
     D slotcreated     s               n
CBIbAD lower           c                   'abcdefghijklmnopqrstuvwxyz'
CBIbAD UPPER           c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

     *----------------------------------------------------------------
     *  Date fields
     *----------------------------------------------------------------

     D datefld         s               d

     D                 ds
     D  fifodate               1      8  0 inz(0)
     D  fifoyear               1      4  0 inz(0)
     D  fifomonth              5      6  0 inz(0)
     D  fifoday                7      8  0 inz(0)
610eAD                 ds
610eAD  rcvdate                1      8  0 inz(0)
610eAD  rcvdyear               1      4  0 inz(0)
610eAD  rcvdmonth              5      6  0 inz(0)
610eAD  rcvdday                7      8  0 inz(0)

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

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
     *  *PICK  -  Picking options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPNXTP  -  Next pallet number.
     *    OPBPCK  -  Bulk pick definition.
     *    OPPCUB  -  Maximum cube for PIR.
     *    OPFPAL  -  Pallets on fixed fork lift.
     *    OPFCUB  -  Maximum cube per fixed pallet.
     *    OPFSTP  -  Maximum stops per fixed pallet.
     *    OPINCL  -  Include PIR in fixed cube.
     *    OPSRCH  -  Number of previous pallets to search for space.
     *    OPFBLD  -  Fixed pallet building method.
     *                1 = By piece without concern for splitting stop.
     *                2 = By stop without splitting stop between plts.
     *    OPPBRK  -  Break pallets by aisle (Y,N).
     *    OPMPUT  -  Manual Put away (Y,N).
     *
     * Data structure
     *
     D opddta          ds
     D  opnxtp                 1      7  0 inz(0)
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
     D  opfbld                27     27  0 inz(0)
     D  opbpck                28     30  0 inz(0)
     D  oppbrk                31     33
     D  opmput                34     34
     D  opdend               117    117

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     D  $ltype                81     88
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

610bA /COPY *libl/qcopysrc,C#PGMINFDS
610bDD*               sds
610bDD* #prog            *proc
610bDD* #job                 244    253
610bDD* #user                254    263
610bDD* #jobn                264    269
610bDD* #jobdt               276    281  0
610bDD* #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *CLEAR   - Clear slot file before import.
     *              *NOCLR   - Process records in import file.
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *
     C     *entry        plist
     C                   parm                    $pcmd             8

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
610bA
610bA*    Get User's employee number to be written to PORCV file
610bA*    if any records are flagged as touched.
610bA
610bAC                   call      'GETUSER'
610bAC                   parm      #curruser     $code            10
610bAC                   parm      0             $whse             3 0
610bAC                   parm      0             $emp#             5 0
610bAC                   parm      *blanks       $fnam            15
610bAC                   parm      *blanks       $init             1
610bAC                   parm      *blanks       $lnam            20
610bAC                   parm      *blanks       $whdp             5
610bAC                   parm      *blanks       $styp             1
610bAC                   parm      *blanks       $shft             6
610bAC                   parm      *blanks       $crew             6
610bAC                   parm      0             $nhrs             3 1
610bAC                   parm      *blanks       $rtn              8

     * Get import date/time.

     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      impdte = $cvd8o
     C                   time                    imptim

     * Get report date.

     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      rdate  = $cvd6o
     *
     * Get report heading.
     *
     C                   eval      w1head = *blanks
     C                   movel     rdsc(1)       $pstr
     C                   eval      $plen = 50
     *
     C                   call      'CENTER'
     C                   parm                    $pstr            60
     C                   parm                    $plen             3 0
     C                   movel     $pstr         w1head
     *
     * Initialize grand total fields
     *
     C                   eval      grdlin = 0
     C                   eval      noslot = 0
     C                   eval      noitem = 0
     C                   eval      badbrk = 0
     C                   eval      badtyp = 0
     C                   eval      baddte = 0
     C                   eval      notcrt = 0
     C                   eval      notupd = 0
     *
     * Whip through all the download records
     *
     C                   eval      pflag = *off
     C                   eval      forevr = *on
     C                   eval      linppg = 55
     C                   eval      count = 999
     C                   eval      lstwhs = -(1)
     C                   eval      lstwhd = '@@@@@'
CBIeA*
CBIeAC                   exsr      zzfixcbi
CBIeAC     *loval        setll     impfstuf4
     *
     C                   dow       forevr = forevr
     *
CBIeDC*                  read      impfstuf4
CBIeMC                   read (n)  impfstuf4
     C                   if        %eof(impfstuf4)
     C                   leave
     C                   endif
     *
     C                   add       1             grdlin
SVLdA*
SVLdDC*                  if        client = Savalfoods
SVLdA
SVLdDC*                  select
SVLdA*  Force combined dept 2 to be split into 2=Dry, 3=Clr.
SVLdDC*                  when      siwhdp = '2    '
SVLdDC*                            and %subst(sidisp:1:1) = 'C'
SVLdDC*                  eval      siwhdp = '3    '
SVLdDC*                  endsl
SVLdAC
SVLdDC*                  endif
CBIbA*
CBIbAC                   if        client = Cheney
CBIbAC                   eval      sidisp = %xlate(lower:UPPER:sidisp)
CBIbAC                   endif
     *
     *  Create warehouse heading if necessary.
     *
     C                   if        lstwhs <> siwhse
     *
     C                   if        lstwhs > 0
JFFbAC                   if        client = Jakes
JFFbA*      Outbound only. No qty/licenses to sync.
JFFbAC                   else
JFFbA*
     C                   exsr      zzrcal
JFFbAC                   endif
JFFbA*
     C                   endif
     *
     C                   eval      whcode = siwhse
     C     whcode        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     C                   move      siwhse        work3a
     C     ' 0'          check     work3a        pos
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      40            $clen             3 0
     C                   movel     $cstr         whhead
     C                   eval      lstwhs = siwhse
     C                   eval      count = 999
     C                   endif
     *
     *  Get options when department changes
     *
     C                   if        lstwhd <> siwhdp
     *
     *  Validate warehouse deptartment sent with slot.
     C                   eval      $lwhse = siwhse
     C                   eval      $lwhdp = siwhdp
     C                   eval      $lcmd = '*VERIFYB'
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*OK'
     C                   eval      validdept = '*YES'
     C                   else
     C                   eval      validdept = '*NO '
     C                   endif
     *
     C                   eval      kycode = '*PICK   '
     C     keyop         chain     optiond                            79
     C                   if        *in79
     C                   eval      opmput = 'N'
     C                   endif
     C                   eval      lstwhd = siwhdp
     C                   endif
     *
     C                   eval      itdesc = *blanks
     C                   eval      ittype = *blanks
     C                   eval      detmsg = *blanks
     *
     *  If not slot sent, write error message.
     *
     C                   if        sidisp = ' '
     C                   eval      detmsg = desc(11)
     C                   add       1             noslot
     C                   goto      prndtl
     C                   endif
710 A*
710 A*  If slot sent, qty sent, but no item, write error message.
710 A*
710 AC                   if             sidisp > ' '
710 AC                             and (siqty1 <> 0
710 AC                               or siqty2 <> 0
710 AC                               or siqty3 <> 0)
710 AC                             and  siitem = ' '
710 AC                   eval      detmsg = desc(15)
710 AC                   add       1             noitem
710 AC                   goto      prndtl
710 AC                   endif
     *
     *  If slot doesn't exist write error message.
     *
EI2 AC                   if        client = EI
EI2 A*
EI2 AC                   if        siitem > ' '
EI2 AC     keyit         chain     piritem
EI2 AC                   if        %found(piritem)
EI2 AC                             and siwhdp <> itwhdp
EI2 A*      Replace slot dept with item dept to get mis-matched slots
EI2 A*      created in the correct departments.
EI2 AC                   eval      svwhdp = siwhdp
EI2 AC                   eval      siwhdp = itwhdp
EI2 AC                   else
EI2 AC                   eval      svwhdp = siwhdp
EI2 AC                   endif
EI2 A*
EI2 AC                   else
EI2 AC                   eval      svwhdp = siwhdp
EI2 AC                   endif
EI2 A*
EI2 AC                   endif
EI2 A*
     C     keysl2        chain(n)  slot2
     C                   if        not %found(slot2)

     C                   select
     C                   when      client = SavalFoods
     C                   exsr      crtslot1
EI  A*
EI  AC                   when      client = EI
EI  AC                   exsr      crtslot2
GFS A*
GFS A*
GFS AC                   when      client = Getfresh
GFS A*
GFS AC                   if        siwhdp <> svwhdp
GFS AC                   eval      dftlocation = 600
GFS AC                   eval      svwhdp      = siwhdp
GRS AC                   endif
GFS AC                   exsr      crtslot3

HAL AC                   when      client = Halsey
HAL AC                   exsr      crtslot14
GFS A*
CBIbAC                   when      client = Cheney
CBIbA*
CBIbAC                   if        siwhdp <> svwhdp
CBIbAC                   eval      dftlocation = 600
CBIbAC                   eval      svwhdp      = siwhdp
CBIbAC                   endif
CBIdDC**                 exsr      crtslot4
JFFaA*
JFFaAC                   when      client = Jakes
JFFaA*
JFFaAC                   if        siwhdp <> svwhdp
JFFaAC                   eval      dftlocation = 600
JFFaAC                   eval      svwhdp      = siwhdp
JFFaAC                   endif
JFFaAC                   exsr      crtslot5

ADFaAC                   when      client = AandDFoods
ADFaA*
ADFaAC                   if        siwhdp <> svwhdp
ADFaAC                   eval      dftlocation = 600
ADFaAC                   eval      svwhdp      = siwhdp
ADFaAC                   endif
ADFaAC                   exsr      crtslot33

     C                   Other

     C                   exsr      crtslot
     C                   endsl

     C                   if        notcreated
     C                   eval      detmsg = desc(1)
     C                   add       1             noslot
     C                   goto      prndtl
     C                   endif
     C
     C                   else
CBIfA*
CBIfAC                   select
CBIfAC                   when          client = Cheney
CBIfAC                             and (clientloc = cbigo
CBIfAC                               or clientloc =cbigr
CBIfAC                               or clientloc =cbist)
CBIfAC                             and slitem = siitem
CBIfAC                             and slitem > ' '
CBIfAC                             and siitem > ' '
CBIfAC                   iter
CBIfA*
CBIfAC                   when          client = Cheney
CBIfAC                             and (clientloc = cbigo
CBIfAC                               or clientloc =cbigr
CBIfAC                               or clientloc =cbist)
CBIfAC                             and slitem > ' '
CBIfAC                   eval      detmsg = 'Slot already has item'
CBIfAC                   goto      prndtl
CBIfA*
CBIfAC                   when          client = Cheney
CBIfAC                             and (clientloc = cbigo
CBIfAC                               or clientloc =cbigr
CBIfAC                               or clientloc =cbist)
CBIfAC                             and slpick <> 'Y'
CBIfAC                   eval      detmsg = 'Slot is overflow slot'
CBIfAC                   goto      prndtl
CBIfAC                   endsl
CBIfA*
     C                   endif
     *
     *  If item doesn't exist write error message.
     *
     C                   eval      ittype = *blanks
     C                   if        siitem > ' '
     C     keyit         chain     piritem
     C                   if        not %found(piritem)
     C                   eval      detmsg = desc(2)
     C                   add       1             noitem
     C                   eval      ittype = *blanks
     C                   eval      itdesc = *blanks
     C                   movel     '*****'       itdesc
     C                   goto      prndtl
CBIeA*
CBIeAC                   else
CBIeA*
CBIeA*       Use dept/section type from item. Slot info not valid.
CBIeAC**                 if        client = Cheney
CBIeAC**                 eval      siwhdp = itwhdp
CBIeAC**                 eval      sistyp = itstyp
CBIeAC**                 endif
CBIeA*
     C                   endif
     *
     *  If item type not ' ' or 'B' write error message.
     *  and not type 'R' write error message.
     *
     C                   if        ittype <> ' '  and
     C                             ittype <> 'B'
     C                             and ittype <> 'R'
     C                   eval      detmsg = desc(4)
     C                   add       1             badtyp
     C                   goto      prndtl
     C                   endif
     *
     *  If item dept/section not same as slot dept write error message.
     *
     C                   if        itwhdp <> siwhdp
     C                             or itstyp <> sistyp
     C                   eval      detmsg = desc(10)
     C                   move      itwhdp        detmsg
     C                   add       1             baddpt
SVLcDC*                  if        client = Saval
SVLcDC*                  if        siwhdp = '3'
SVLcA*          Ignore dept mis-match for Dept 3 slots.
SVLcDC*                  else
SVLcAC                   goto      prndtl
SVLcDC*                  endif
SVLcDC*                  endif
     C                   endif
     C                   endif
     *
     *  If invalid mmddyy FIFO date write error message.
     *
     C                   if        sififo > 0
     C                   move      sififo        temp6a
     C     *mdy0         test(de)                temp6a
     C                   if        %error
     C                   eval      detmsg = desc(9)
     C                   add       1             baddte
     C                   goto      prndtl
     C                   endif
     C     *mdy0         move      temp6a        datefld
     C                   extrct    datefld:*y    fifoyear
     C                   extrct    datefld:*m    fifomonth
     C                   extrct    datefld:*d    fifoday
     C                   endif
610eA*
610eA*  If invalid mmddyy RcvD date write error message.
610eA*
     C                   if        sircvd > 0
EI5 A*
EI5 AC                   if        client = EI
HALcAC                             or client = Halsey
HALeAC*
HALeAC                   if        client = Halsey
HALeAC                             and (sircvd = 0
HALeAC                               or sircvd = 19000100)
HALeAC                   eval      sircvd = impdte
HALeAC                   endif
HALeAC*
EI5 AC     *iso          test(de)                sircvd
EI5 AC                   if        %error
EI5 AC                   eval      detmsg = desc(14)
EI5 AC                   add       1             baddte
EI5 AC                   goto      prndtl
EI5 AC                   endif
EI5 AC                   else
EI5 A*
     C                   move      sircvd        temp6a
     C     *mdy0         test(de)                temp6a
     C                   if        %error
     C                   eval      detmsg = desc(14)
     C                   add       1             baddte
     C                   goto      prndtl
     C                   endif
EI5 A*
EI5 AC                   endif
 I5 A*
EI5 AC                   if        client = EI
HALcAC                             or client = Halsey
EI5 AC     *ISO          move      sircvd        datefld
EI5 AC                   extrct    datefld:*y    rcvdyear
EI5 AC                   extrct    datefld:*m    rcvdmonth
EI5 AC                   extrct    datefld:*d    rcvdday
EI5 AC                   else
EI5 A*
     C     *mdy0         move      temp6a        datefld
     C                   extrct    datefld:*y    rcvdyear
     C                   extrct    datefld:*m    rcvdmonth
610eAC                   extrct    datefld:*d    rcvdday
EI5 AC                   endif
EI5 A*
610eAC                   endif
     *
     *  Add rec if qty1, brk qty2 or brk qty3 has good qty.
     *  Check if breakdown qty is allowed using piritem file.
     *  Add rec if qty1, brk qty2 or brk qty3 has good qty.
     *
     C                   eval      good1 = 'N'
     C                   exsr      zzbkdn
     C     good1         cabeq     'N'           prndtl
     *
     *  If doing manual putaway,
     *   Then get actual slot to use for the putaway.
     *
     C                   eval      newvs = *off
     C                   if        opmput = 'Y'
     C                   exsr      zzman
     C     error         cabeq     *on           prndtl
     C                   endif
     *
     *  Update slot record.
     *
     C                   exsr      zzupd
     *
     *  Update Slot Check Digit
     C                   if        client <> SavalFoods
GFS AC                             and client <> Getfresh
HALaAC                             and client <> Halsey
CBIaAC                             and client <> Cheney
JFF AC                             and client <> Jakes
     C                   exsr      zzckdgt
     C                   endif
     *
     *  Print detail and update subtotals
     *
     C     prndtl        tag
     C                   if        detmsg <> *blanks
     C                   exsr      zrhead
     C                   write     detail
     *
     C                   add       1             count
     C                   endif
     *
     C                   enddo
     *
     *  Print order grand totals
     *
     C                   exsr      zrhead
     C                   write     grndttl
     *
     *  Update ItemQty totals
     *
     C                   if        lstwhs > 0
EI6 A*
EI6 AC                   if        client = EI
HALbAC                             or client = Halsey
CBIcAC                             or client = Cheney
SVLeAC                             or client = SavalFoods
EI6 AC                   exsr      zzrcal
EI6 AC                   endif
EI6 A*
     C                   endif
610aA
610aA*  Synchronize license qtys with slot qtys
610aA*    This will make sure the LP's match the slot qty for every slot.
610aA*    This is done to clean up an problems, such as duplicate
610aA*    LP's being sent.
610aA
JFFbAC                   if        client = Jakes
JFFbA*      Outbound only. No qty/licenses to sync.
JFFbAC                   else
JFFbA*
610aAC                   call(e)   'LT001'
650 DC*                  parm      'FIX'         lpAction          3
650 MC                   parm      'SU '         lpAction          3
610aAC                   parm      siwhse        lpWhse            3 0
610aAC                   parm      ' '           lpWhdp            5
610aAC                   parm      ' '           lpDisp           12
610aAC                   parm      ' '           lpDummy           1
JFFbAC                   endif
     *
     *  We are finished so get out
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr

     *  Get client id

     C                   call      'GETCLIENT'
     C                   parm                    client
     C                   parm                    clientloc

     C                   eval      error = *off
     C                   eval      exist = *off
     C                   eval      newvs = *off
     *
     * Key definitions
     *
     * Item file
     *
     C     keyit         klist
     C                   kfld                    siwhse
     C                   kfld                    siitem
     *
     * Slot2 file
     *
     C     keysl2        klist
     C                   kfld                    siwhse
     C                   kfld                    siwhdp
     C                   kfld                    sidisp
     C     keysl2b       klist
     C                   kfld                    siwhse
     C                   kfld                    siwhdp
     C                   kfld                    kydisp
     *
     * Slotdgt file
     *
     C     *like         define    slwhse        kywhse
     C     *like         define    slwhdp        kywhdp
     C     keyscd        klist
     C                   kfld                    kywhse
     C                   kfld                    kywhdp
     C                   kfld                    kydisp
     *
     *  OPTIOND file
     *
     C     keyop         klist
     C                   kfld                    kycode
     C                   kfld                    siwhse
     C                   kfld                    siwhdp
     *
     *  VSLOT file
     *
     C     keyvs         klist
     C                   kfld                    siwhse
     C                   kfld                    siwhdp
     C                   kfld                    vsdisp
     *
     C     ckkey         klist
     C                   kfld                    siwhse
     C                   kfld                    siwhdp
     C                   kfld                    $vdisp
     *
     *  Define variables
     *
     *
     *   Load handstack array with codes (A..Z, AA..AZ, ...)
     *
     C                   eval      k = 0
     C     1             do        27            i
     C     2             do        27            j
     C                   add       1             k
     C     ltr(i)        cat       ltr(j)        hnd(k)
     C                   enddo
     C                   enddo
     *
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILLSL  Fill order detail fields.
     *
     C     fillsl        begsr
     *
     *  Move fields from download file to purchase order header fields
     *
     C                   eval      slitem = siitem
     C                   eval      slstk1 = siqty1
     C                   if        itflg1 = 'Y'
     C                   z-add     siqty2        slstk2
     C                   else
     C                   eval      slstk2 = 0
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   z-add     siqty3        slstk3
     C                   else
     C                   eval      slstk3 = 0
     C                   endif
     *
     C                   endsr

     *----------------------------------------------------------------
     *  getslot  Get slot info.
     *
     *    Note, calling DRISLOT directly to keep the %GET's from
     *    being put into the LOGDRI file.
     *
     *----------------------------------------------------------------

     C     getslot       begsr

610bDC**                 eval      savever# = $slver#
610bDC**                 clear                   $slot
610bDC**                 eval      $slver# = savever#
610bA
610bMC                   exsr      clr$slot

610bAC                   eval      $slwhseu = *on
     C                   eval      $slwhse = siwhse
610bAC                   eval      $slwhdpu = *on
     C                   eval      $slwhdp = siwhdp
610bAC                   eval      $sldispu = *on
     C                   eval      $sldisp = sidisp

     C                   eval      drislot = *on
     C                   call(e)   'DRISLOT'
     C                   parm      '%GET      '  $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $slot         parm      $slot         $dridata
610bAC     $slot2        parm      $slot2        $dridata2

     C     endgetslot    endsr
CBIeA
CBIeA*----------------------------------------------------------------
CBIeA*
CBIeA*  ZZFIXCBI  Update Dept/Section for rcds with Item#
CBIeA*
CBIeAC     zzfixcbi      begsr
CBIeA*
CBIeAC     *loval        setll     IMPFSTUF4
CBIeAC                   dow       forevr = forevr
CBIeAC                   read      impfstuf4
CBIeAC                   if        %eof(impfstuf4)
CBIeAC                   leave
CBIeAC                   endif
CBIeAC
CBIeAC                   if        siitem > ' '
CBIeAC     keyit         chain     piritem
CBIeAC                   if        %found(piritem)
CBIeAC                             and siwhdp <> itwhdp
CBIeAC                   eval      siwhdp = itwhdp
CBIeAC                   eval      sistyp = itstyp
CBIeAC                   eval      sibld  = 'FX'
CBIEAC                   update    sirec
CBIeAC                   endif
CBIeAC                   endif
CBIeAC                   enddo
CBIeAC                   unlock    impfstuf4
CBIeA*
CBIeAC                   endsr

     *----------------------------------------------------------------
     *
     *  ZZBKDN  Check breakdown quanties.
     *
     C     zzbkdn        begsr
     *
     C                   if        siqty1 = 0  and
     C                             siqty2 = 0  and
     C                             siqty3 = 0
     C                   eval      good1 = 'Y'
     C                   goto      endbkd
     C                   endif
     *
     C                   exsr      zzssb
     *
     C                   if        siqty2 <> 0  and
     C                             itflg1 <> 'Y'  and
     C                             ssbflg = *off
     C                   eval      detmsg = desc(3)
     C                   add       1             badbrk
     C                   endif
     *
     C                   if        siqty3 <> 0  and
     C                             itflg2 <> 'Y'  and
     C                             ssbflg = *off
     C                   eval      detmsg = desc(3)
     C                   add       1             badbrk
     C                   endif
     *
     C                   if        siqty1 <> 0
     C                   eval      good1 = 'Y'
     C                   else
     C                   if        siqty2 <> 0  and
     C                             itflg1 = 'Y'  or
     C                             siqty2 <> 0  and
     C                             ssbflg = *on
     C                   eval      good1 = 'Y'
     C                   else
     C                   if        siqty3 <> 0  and
     C                             itflg2 = 'Y'  or
     C                             siqty3 <> 0  and
     C                             ssbflg = *on
     C                   eval      good1 = 'Y'
     C                   endif
     C                   endif
     C                   endif
     *
     C     endbkd        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCKDGT   Update Slot Check Digit.
     *
     C     zzckdgt       begsr
     *
     C                   eval      kywhse = siwhse
     C                   eval      kywhdp = siwhdp
     C                   eval      kydisp = sidisp
     *    Get base slot for slot being imported.
     C                   exsr      getslot
     *    Base slot not found. Print error line on report.
     C                   if        error
     C                   eval      error   = *off
     C                   eval      detmsg = desc(12)
     C                   exsr      zrhead
     C                   write     detail
     C                   eval      count = count + 1
610dAC                   eval      detmsg = ' '
     *
     *    Base slot was found. Update slot check digit.
     C                   else
     *
     *    Retrieve Slot Check Digit record.
     C                   eval      kydisp = $sacdsp
     C     keyscd        chain     slotdgt
     C                   if        not %found(slotdgt)
     C                   clear                   scdrec
     C                   eval      scdwhs = kywhse
     C                   eval      scdwhd = kywhdp
     C                   eval      scddsp = kydisp
     C                   eval      scddgt = sidgt
     C                   eval      scdadt = impdte
     C                   eval      scdatm = imptim
     C                   eval      scdaby = #user
     C                   write     scdrec
     C
     C                   else
     C                   eval      scddgt = sidgt
     C                   eval      scdadt = impdte
     C                   eval      scdatm = imptim
     C                   eval      scdaby = #user
     C                   update    scdrec
     C                   endif
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCKNS   Use reg slot or get new Vslot.
     *
     C     zzckns        begsr
     C                   eval      newvs = *off
     C                   eval      error = *on
     C     keysl2        chain(n)  slot2                              79
     C                   if        not *in79
     C                   if        slitem = *blanks
     C                   eval      error = *off
     C                   goto      endckn
     C                   else
     *
     *   Get out if physical slot already uses both
     *   positions of handstack field.
     *
     C                   movea     slhand        a2
     C                   if        a2(1) <> ' '
     C                   goto      endckn
     C                   endif
     *
     *   Set handstack flag for later use.
     *
     C                   if        slhand <> ' '
     C                   eval      flaghs = *on
     C                   else
     C                   eval      flaghs = *off
     C                   endif
     *
     * SAVE PHYSICAL SLOT FIELDS
     *
     C                   eval      phwhse = slwhse
     C                   eval      phwhdp = slwhdp
     C                   eval      phaisl = slaisl
     C                   eval      phloc = slloc
     C                   eval      phrlvl = slrlvl
     C                   eval      phhand = slhand
     C                   eval      phside = slside
     C                   eval      phstyp = slstyp
     C                   eval      phdisp = sldisp
     C                   eval      phsdef = slsdef
     C                   eval      phdesg = sldesg
     C                   eval      phpseq = slpseq
     C                   eval      phactv = slactv
     C                   eval      phbld = slbld
     C                   eval      phslfd = slslfd
     *
     C                   eval      $vpseq = slpseq
     C                   eval      $vdisp = *blanks
     C                   eval      k = 0
     C                   eval      $vwhse = slwhse
     C                   eval      $vwhdp = slwhdp
     C                   eval      $vaisl = slaisl
     C                   eval      $vloc = slloc
     C                   eval      $vrlvl = slrlvl
     C                   eval      $vhand = *blanks
     C                   eval      $vstyp = slstyp
     C                   eval      $vpseq = slpseq
     C                   eval      $vdisp = *blanks
     C                   eval      $vpick = slpick
     *
     *** Loop & increment handstack to find new v-slot to create.
     *
     C                   dow       k < 702
     C                   add       1             k
     *
     *     If physical slot had handstack then limit hs we can use.
     *
     C                   if        flaghs = *on
     C                   movea     hnd(k)        a2n
     C                   if        a2n(1) <> a2(2)
     C                   iter
     C                   endif
     C                   endif
     C                   eval      $vhand = hnd(k)
     C                   call      'FRMTVS'
     C                   parm                    phdisp
     C                   parm                    flaghs
     C                   parm                    $vhand            2
     C                   parm                    $vdisp           12
     *
     C     ckkey         setll     slot2                                  79
     C                   if        not *in79
     C                   eval      newvs = *on
     C                   eval      error = *off
     C                   eval      sidisp = $vdisp
     C                   leave
     C                   else
     C                   iter
     C                   endif
     C                   enddo
     C                   endif
     C                   endif
     *
     C     endckn        endsr
     *----------------------------------------------------------------
     *
     *  ZZCKSL   Check if item exists in reg or V slot
     *
     C     zzcksl        begsr
     C     keysl2        chain(n)  slot2                              79
     C                   if        not *in79  and
     C                             slitem = siitem
     C                   eval      exist = *on
     C                   goto      endcks
     C                   else
     C     keysl2        setll     vslot2
     C     nxt1          tag
     C     keysl2        reade     vslot2                                 78
     C                   if        not *in78
     C     keyvs         chain(n)  slot2                              79
     C                   if        not *in79  and
     C                             slitem = siitem
HALdAC                             and sipick = 'Y'
HALdAC                             and client = Halsey
     C                   eval      exist = *on
     C                   eval      sidisp = sldisp
     C                   goto      endcks
     C                   else
     C                   goto      nxt1
     C                   endif
     C                   endif
     C                   endif
     *
     C     endcks        endsr
     *----------------------------------------------------------------
     *
     *  ZZMAN    Get slot to use for manual putaway.
     *
     C     zzman         begsr
     C                   eval      error = *off
     C                   eval      exist = *off
     *
     *  Check if item already exists in the base slot
     *    or in a corresponding virtual slot.
     *
     C                   exsr      zzcksl
EI3 A*
EI3 AC                   if        client = EI
HALdAC                             or client = Halsey
EI3 A*
EI3 A*      Force Exist flag off so new slot is created each time.
EI3 AC                   if        sipick = 'N'
EI3 AC                   eval      exist = '0'
EI3 AC                   endif
EI3 A*
EI3 AC                   endif
     *
     *  If item doesn't already exist in the slot,
     *    Then try to get a new virtual slot number for it.
     *
     C                   if        exist = *off
     C                   exsr      zzckns
     C                   if        error = *on
     C                   eval      detmsg = desc(5)
     C                   add       1             notcrt
     C                   goto      endman
     C                   endif
     C                   endif
     C     endman        endsr
     *----------------------------------------------------------------
     *
     *  ZZRCAL   Recalculate item quantity from slots.
     *
     C     zzrcal        begsr
     C                   eval      error = *off
     *
     * Recalculate item qty.
     C                   eval      $pwhs = lstwhs
     C                   eval      $jobq = 'Y'
     C                   call      'UT812'
     C                   parm                    $pwhs
     C                   parm      '*ALL    '    $itemo           15
     C                   parm                    $jobq
     C                   parm                    $lprg
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     *
     C     endcal        endsr
     *----------------------------------------------------------------
     *
     *  ZZSSB   Check for SSB item.
     *
     C     zzssb         begsr
     *
     *   Get SSB item, if one exists
     *
     C                   eval      ssbflg = *off
     C                   if        ittype = ' '
     C                   call      'GETSSB'
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
     C                   parm      ' '           #bitem           15
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum              2
     C                   parm                    #bum2             2
     C                   parm                    #bumq2            3 0
     C                   parm                    #bum3             2
     C                   parm                    #bumq3            3 0
     C                   parm                    #brtn             8
     *
     *    SSB item found attached to item being imported. Allow
     *    Qty 2,3 fields to be updated.
     C                   if        #brtn = '*FOUND'
     C                   eval      ssbflg = *on
     C                   endif
     *
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update slot file
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     *   Update record.
     *
     *  Create new slot record
     *  $V = from Physical slot when virtual was checked
     *  PH = from saved from physical slot when virtual was checked
     *  SV = saved from 'FROM' slot.
     *  SL = saved from 'FROM' slot.
     C                   if        newvs = *on
     *
     C                   clear                   slrec
     *
     C                   eval      slwhse = $vwhse
     C                   eval      slwhdp = $vwhdp
     C                   eval      slstat = 'A '
     C                   eval      slaisl = $vaisl
     C                   eval      slloc = $vloc
     C                   eval      slrlvl = $vrlvl
     C                   eval      slhand = $vhand
     C                   eval      slside = phside
     C                   eval      slstyp = $vstyp
     C                   eval      sldisp = $vdisp
     C                   eval      slsdef = phsdef
     C                   eval      sldesg = phdesg
     C                   eval      slactv = phactv
     C                   eval      slbld  = phbld
     C                   eval      slpseq = $vpseq
     *
     C                   select
     *    Set picking priority based on import.
     *      0=Lowest priority to -9=Highest priority.
     C                   when      siprty >= 1
     C                   eval      slprty = siprty * -1
     C                   when      siprty < 0
     C                   eval      slprty = siprty
     C                   other
     C                   eval      slprty = 0
     C                   endsl
     C
     C                   eval      slslfd = 0
     C                   eval      slpick = $vpick
     C                   eval      slrsrv = 'V'
     C                   eval      slexpd = svexpd
     C
     C                   if        siitem > ' '
     C
610eDC*                  if        sififo > 0
610eMC                   if        sircvd > 0
610eDC*                  eval      slentd = fifodate
610eMC                   eval      slentd = rcvdate
     C                   else
     C                   eval      slentd = impdte
     C                   endif
610eAC
610eAC                   if        itflgd = 'Y'
610eAC                   if        sififo > 0
610eAC                   eval      slexpd = fifodate
610eAC                   else
610eAC                   eval      slexpd = 0
610eAC                   endif
610eAC                   else
610eAC                   eval      slexpd = 0
610eAC                   endif
610eAC
     C                   endif
     C
     C                   eval      slsdte = impdte
     C                   eval      slstim = imptim
     C                   eval      slitem = siitem
     C                   eval      slstk1 = siqty1
     C                   if        itflg1 = 'Y'
     C                             or ssbflg = *on
     C                   z-add     siqty2        slstk2
     C                   else
     C                   eval      slstk2 = 0
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   z-add     siqty3        slstk3
     C                   else
     C                   eval      slstk3 = 0
     C                   endif
     *
     C                   write     slrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      detmsg = desc(7)
     C                   add       1             notcrt
     C                   goto      endupd
     C                   endif
     C                   add       1             sltcrt
     *
     *  create vslot record.
     *
     C                   eval      vswhse = $vwhse
     C                   eval      vswhdp = $vwhdp
     C                   eval      vsaisl = $vaisl
     C                   eval      vsloc = $vloc
     C                   eval      vsrlvl = $vrlvl
     C                   eval      vshand = $vhand
     C                   eval      vsdisp = $vdisp
     C                   eval      vspdis = phdisp
     C                   eval      vscdte = impdte
     C                   eval      vsctim = imptim
     C                   add       1             vsctim
     C                   write     vsrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      detmsg = desc(8)
     C                   add       1             notcrt
     C                   goto      endupd
610cAC                   else
JFFca*
JFFcAC                   if        client = Jakes
JFFcA*    Bypass running of license update. Outbound only.
JFFcAC                   else
JFFca*
610cAC                   exsr      zzupdlcns
JFFcAC                   endif
JFFca*
     C                   endif
     *
     C                   else
     *
     *** Update slot record
     *
     C     keysl2        chain     slot2                              79
     *
     C                   if        not *in79
     *
     C                   eval      slitem = siitem
     C                   if        slstat = 'V '  or
     C                             slstat = 'Z '
     C
     C                   if        siitem > ' '
     C
     C                   eval      slstat = 'A '
     C                   endif
     C
     C                   endif
     *
     C                   select
     *    Set picking priority based on import.
     *      0=Lowest priority to -9=Highest priority.
     *
     C                   when      siprty >= 1
     C                   eval      slprty = siprty * -1
     C                   when      siprty < 0
     C                   eval      slprty = siprty
     C                   other
     C                   eval      slprty = 0
     C                   endsl
     C
EI4 AC                   if        client = EI
HALfAC                             or client = Halsey
EI4 A*
EI4 AC                   eval      slstk1 = slstk1 + siqty1
EI4 AC                   if        itflg1 = 'Y'
EI4 AC                             or ssbflg = *on
EI4 AC                   eval      slstk2 = slstk2 + siqty2
EI4 AC                   else
EI4 AC                   eval      slstk2 = 0
EI4 AC                   endif
EI4 AC                   if        itflg2 = 'Y'
EI4 AC                   eval      slstk3 = slstk3 + siqty3
EI4 AC                   else
EI4 AC                   eval      slstk3 = 0
EI4 AC                   endif
EI4 A*
EI4 AC                   else
EI4 A*      All other clients. Replace existing item qty.
EI4 A*
     C                   eval      slstk1 = siqty1
     C                   if        itflg1 = 'Y'
     C                             or ssbflg = *on
     C                   z-add     siqty2        slstk2
     C                   else
     C                   eval      slstk2 = 0
     C                   endif
     C                   if        itflg2 = 'Y'
     C                   z-add     siqty3        slstk3
     C                   else
     C                   eval      slstk3 = 0
     C                   endif
     *
EI4 AC                   endif
EI4 A*
     C                   if        siitem > ' '
     C
610eDC*                  if        sififo > 0
610eMC                   if        sircvd > 0
610eDC*                  eval      slentd = fifodate
610eMC                   eval      slentd = rcvdate
     C                   else
     C                   eval      slentd = impdte
     C                   endif
     C                   else
     C                   eval      slentd = 0
     C                   endif
610eAC
610eAC                   if        itflgd = 'Y'
610eAC                   if        sififo > 0
610eAC                   eval      slexpd = fifodate
610eAC                   else
610eAC                   eval      slexpd = 0
610eAC                   endif
610eAC                   else
610eAC                   eval      slexpd = 0
610eAC                   endif
610eAC
     C
     C                   eval      slsdte = impdte
     C                   eval      slstim = imptim
     *
     C                   update    slrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      detmsg = desc(6)
     C                   add       1             notupd
610cAC                   else
JFFca*
JFFcAC                   if        client = Jakes
JFFcA*    Bypass running of license update. Outbound only.
JFFcAC                   else
JFFca*
610cAC                   exsr      zzupdlcns
JFFcAC                   endif
JFFca*
     C                   endif
     C                   add       1             sltupd
     C                   endif
     C                   endif
     *
     C     endupd        endsr
610cA
610cA*----------------------------------------------------------------
610cA*  ZZUPDLCNS   Update license
610cA*----------------------------------------------------------------
610cAC     zzupdlcns     begsr

     C                   exsr      clr$license
     C                   eval      $liActionU = *on
     C                   eval      $liAction  = 'IMP'
     C                   eval      $liToWhseU = *on
     C                   eval      $litoWhse  = slwhse
     C                   eval      $liToWhdpU = *on
     C                   eval      $litoWhdp  = slwhdp
     C                   eval      $liToDispU = *on
     C                   eval      $litoDisp  = sldisp
     C                   eval      $liToBaseU = *on
     C                   eval      $litoBase  = sldisp
     C                   eval      $liToItemU = *on
     C                   eval      $litoItem  = slitem
     C                   eval      $liToITypeU = *on
     C                   eval      $litoItype = ittype
     C                   eval      $liToSItemU = *on
     C                   eval      $litosItem = slitem
     C                   eval      $liToSITypeU = *on
     C                   eval      $litoSitype = ittype
     C                   eval      $liToAislu = *on
     C                   eval      $litoAisl  = slaisl
     C                   eval      $liToLocU = *on
     C                   eval      $litoLoc   = slloc
     C                   eval      $liToRlvlU = *on
     C                   eval      $litorlvl  = slrlvl
     C                   eval      $liToHandU = *on
     C                   eval      $litoHand  = slhand
     C                   eval      $liToEntDU = *on
     C                   eval      $litoEntd  = slentd
     C                   eval      $liToExpDU = *on
     C                   eval      $litoExpd  = slexpd
     C                   eval      $liToPrtyU = *on
     C                   eval      $litoPrty = slprty
     C                   eval      $liToCodeu = *on
     C                   eval      $litoCode  = 'S'
     C                   eval      $liToAreaU = *on
     C                   eval      $litoArea  = 'Slot'
     C                   eval      $liToPosU = *on
     C                   eval      $litoPos   = 1
     C                   eval      $liToOrdU = *on
     C                   eval      $litoOrd   = 0
     C                   eval      $liToSeqU = *on
     C                   eval      $litoSeq   = 0
     C*
     C                   eval      $liAQty1U = *on
EI4 AC*
EI4 AC                   if        client = EI
HALfAC                             or client = Halsey
EI4 AC                   eval      $liaQty1  = siqty1
EI4 AC                   eval      $liaQty2  = siqty2
EI4 AC                   eval      $liaQty3  = siqty3
EI4 AC                   else
EI4 AC*
     C                   eval      $liaQty1  = slstk1
     C                   eval      $liaQty2  = slstk2
     C                   eval      $liaQty3  = slstk3
EI4 AC                   endif
EI4 AC*
     C                   eval      $liToRQty1U = *on
EI4 AC*
EI4 AC                   if        client = EI
HALfAC                             or client = Halsey
EI4 AC                   eval      $liToRQty1  = siqty1
EI4 AC                   eval      $liToRQty2  = siqty2
EI4 AC                   eval      $liToRQty3  = siqty3
EI4 AC                   else
EI4 AC*
     C                   eval      $liToRQty1  = slstk1
     C                   eval      $liToRQty2  = slstk2
     C                   eval      $liToRQty3  = slstk3
EI4 AC                   endif
EI4 AC*
     C                   eval      $liToLcnsU = *on
     C                   if        silcns <> ' '
     C                   eval      $litoLcns = silcns
     C                   else
     C                   eval      $litoLcns = '*SI'
     C                   endif

     C                   eval      $dricommand = '*LICENSE'
     C                   eval      $drisubcmd  = '%SETLCNS'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      error   = *off
     C                   eval      detmsg = desc(13)
     C                   exsr      zrhead
     C                   write     detail
     C                   eval      count = count + 1
     C                   eval      detmsg = ' '
     C                   endif

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZRHEAD   Print report headings.
     *
     C     zrhead        begsr
     *
     C                   if        count >= linppg
     C                   seton                                        81
     C                   eval      count = 0
     C                   write     head1
     C                   add       2             count
     C                   setoff                                       81
     C                   endif
     *
     C                   endsr

     *----------------------------------------------------------------
     *  crtslot  Try and create physical slot.
     *----------------------------------------------------------------

     C     crtslot       begsr
     C                   eval      notcreated = *off
     C                   eval      handstack  = *off
     C                   clear                   slrec

     *  Extract location and level. Test if they are numeric.

     C                   eval      locnotnum = *off
     C                   eval      lvlnotnum = *off
     C                   eval      dashpos = 0
     C                   eval      loca  = ' '
     C                   eval      lvla  = ' '

     *  Check for all alpha slot. If no digits, default slot location
     *  will be assigned.
     C                   If            %subst(sidisp:2:2) >= '00'
     C                             and %subst(sidisp:2:2) <= '99'
     C                             or  %subst(sidisp:3:2) >= '00'
     C                             and %subst(sidisp:3:2) <= '99'
     C                   eval      allchrslot = *off
     C                   else
     C                   eval      allchrslot = *on
     C                   endif

     C                   select

     *  Dashes specified. Single character aisle
     C                   when      %subst(sidisp:2:1) = '-'
     C                             and %subst(sidisp:6:1) = '-'
     C                   eval      dashpos = 2
     C                   eval      slaisl = '  ' + %subst(sidisp:1:1)
     C                   eval      loca  = %subst(sidisp:3:3)
     C                   move      loca          slloc
     C                   eval      lvla  = %subst(sidisp:7:1)
     C                   move      lvla          slrlvl
     C                   eval      slhand  = ' ' + %subst(sidisp:8:1)
     C                   if        slhand > ' '
     C                   eval      handstack = *on
     C                   endif

     *  Dashes specified. Double character aisle
     C                   when      %subst(sidisp:3:1) = '-'
     C                             and %subst(sidisp:7:1) = '-'
     C                   eval      slaisl = ' ' + %subst(sidisp:1:2)
     C                   eval      loca  = %subst(sidisp:4:3)
     C                   move      loca          slloc
     C                   eval      lvla  = %subst(sidisp:8:1)
     C                   move      lvla          slrlvl
     C                   eval      slhand  = ' ' + %subst(sidisp:9:1)
     C                   if        slhand > ' '
     C                   eval      handstack = *on
     C                   endif
     C                   eval      dashpos = 3

     *  No dashes specified. All character slot.
     C                   when      allchrslot = *on
     C
     C                   eval      kydisp = sidisp
     C                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
     C
     C                   eval      dftlocation = dftlocation + 1
     C                   eval      loca   = %char(dftlocation)
     C                   eval      slloc  = dftlocation
     C
     C                   eval      slrlvl = 1
     C                   eval      lvla   = '1'
     C
     C                   eval      slhand  = '  '
     C                   eval      dashpos = -1

     *  No dashes specified. Double character aisle, numeric rack level.
     C                   when           %subst(sidisp:2:1) >= 'A'
     C                             and  %subst(sidisp:2:1) <= 'Z'
     C                             and (%subst(sidisp:5:1) >= '0'
     C                             and  %subst(sidisp:5:1) <= '9'
     C                             or   %subst(sidisp:5:1)  = ' ')
     C
     C                   eval      kydisp = %subst(sidisp:1:5)
     C                   evalr     slaisl  = %trimr(%subst(sidisp:1:2))

     C                   evalr     loca    = %trimr(%subst(sidisp:3:2))
     C                   move (p)  loca          slloc

     C                   eval      lvla    = %subst(sidisp:5:1)
     C                   move (p)  lvla          slrlvl
     C                   eval      slrlvl  = slrlvl + 1

     *   Special reserved slot. Don't break out handstack characters.
     C                   if        %subst(sidisp:6:3) = 'OVR'
     C                   eval      slhand  = '  '
     C                   else
     C                   evalr     slhand  = %trimr(%subst(sidisp:6:2))
     C                   endif
     C                   if        slhand > ' '
     C                   eval      handstack = *on
     C                   endif
     C                   eval      dashpos = -1

     *  No dashes specified. Double character aisle, alpha rack level,
     C                   when          %subst(sidisp:2:1) >= 'A'
     C                             and %subst(sidisp:2:1) <= 'Z'
     C                             and %subst(sidisp:5:1) >= 'A'
     C                             and %subst(sidisp:5:1) <= 'Z'
     C
     C                   eval      kydisp = %subst(sidisp:1:5)
     C                   evalr     slaisl  = %trimr(%subst(sidisp:1:2))
     C                   evalr     loca    = %trimr(%subst(sidisp:3:2))
     C                   move (p)  loca          slloc
     C
     C                   eval      lvla    = %subst(sidisp:5:1)
     C                   evalr     wkchar = %trimr(lvla)
     C                   exsr      zzcvt2nbr
     C                   evalr     lvla   = %trimr(nwchar)
     C                   eval      slrlvl = %dec(nwchar:2:0)
     C                   eval      slrlvl = slrlvl + 10
     C
     *   Special reserved slot. Don't break out handstack characters.
     C                   if        %subst(sidisp:6:3) = 'OVR'
     C                   eval      slhand  = '  '
     C                   else
     C                   evalr     slhand  = %trimr(%subst(sidisp:6:2))
     C                   endif
     C                   if        slhand > ' '
     C                   eval      handstack = *on
     C                   endif
     C                   eval      dashpos = -1

     *  No dashes specified. Single character aisle, numeric rack level.
     C                   when           %subst(sidisp:2:1) >= '0'
     C                             and  %subst(sidisp:2:1) <= '9'
     C                             and (%subst(sidisp:4:1) >= '0'
     C                             and  %subst(sidisp:4:1) <= '9'
     C                             or   %subst(sidisp:4:1)  = ' ')
     C
     C                   eval      kydisp = %subst(sidisp:1:4)
     C                   evalr     slaisl  = %trimr(%subst(sidisp:1:1))
     C
     C                   evalr     loca    = %trimr(%subst(sidisp:2:2))
     C                   move (p)  loca          slloc
     C
     C                   eval      lvla    = %subst(sidisp:4:1)
     C                   move (p)  lvla          slrlvl
     C                   eval      slrlvl  = slrlvl + 1
     C
     *   Special reserved slot. Don't break out handstack characters.
     C                   if        %subst(sidisp:6:3) = 'OVR'
     C                   eval      slhand  = '  '
     C                   else
     C                   evalr     slhand  = %trimr(%subst(sidisp:5:2))
     C                   endif
     C                   if        slhand > ' '
     C                   eval      handstack = *on
     C                   endif
     C                   eval      dashpos = -1

     *  No dashes specified. Single character aisle, alpha rack level.
     C                   when          %subst(sidisp:2:1) >= '0'
     C                             and %subst(sidisp:2:1) <= '9'
     C                             and %subst(sidisp:4:1) >= 'A'
     C                             and %subst(sidisp:4:1) <= 'Z'
     C
     C                   eval      kydisp = %subst(sidisp:1:4)
     C                   evalr     slaisl  = %trimr(%subst(sidisp:1:1))
     C
     C                   evalr     loca    = %trimr(%subst(sidisp:2:2))
     C                   move (p)  loca          slloc

     C                   eval      lvla    = %subst(sidisp:4:1)
     C                   evalr     wkchar = %trimr(lvla)
     C                   exsr      zzcvt2nbr
     C                   evalr     lvla   = %trimr(nwchar)
     C                   eval      slrlvl = %dec(nwchar:2:0)
     C                   eval      slrlvl = slrlvl + 10

     *   Special reserved slot. Don't break out handstack characters.
     C                   if        %subst(sidisp:6:3) = 'OVR'
     C                   eval      slhand  = '  '
     C                   else
     C                   evalr     slhand  = %trimr(%subst(sidisp:5:2))
     C                   endif
     C                   if        slhand > ' '
     C                   eval      handstack = *on
     C                   endif
     C                   eval      dashpos = -1

     *  No dashes specified. Extract out slot breakdown.
     C                   other
     C
     C                   eval      kydisp = %subst(sidisp:1:4)
     C                   eval      slaisl  = ' ' + %subst(sidisp:1:2)

     C                   evalr     loca    = %trimr(%subst(sidisp:3:2))
     C                   move      loca          slloc

     C                   eval      lvla    = %subst(sidisp:5:1)
     C                   move      lvla          slrlvl
     C                   eval      slrlvl  = slrlvl + 1

     *   Special reserved slot. Don't break out handstack characters.
     C                   if        %subst(sidisp:6:3) = 'OVR'
     C                   eval      slhand  = '  '
     C                   else
     C                   evalr     slhand  = %trimr(%subst(sidisp:6:2))
     C                   endif
     C                   if        slhand > ' '
     C                   eval      handstack = *on
     C                   endif
     C                   eval      dashpos = -1

     C                   endsl


     *  Begin testing parts for ALL slots.
     C                   testn                   loca                 5050
     C                   if        *in50 = *off
     C                   eval      locnotnum = *on

     C                   else

     C                   if        %subst(sidisp:6:3) = 'OVR'
     C                   eval      slloc = slloc + 200
     C                   else
     C                   eval      slloc = slloc + 100
     C                   endif

     C                   endif

     C                   testn                   lvla                 50
     C                   if        *in50 = *off
     C                   eval      lvlnotnum = *on
     C                   else
     C                   select
     C                   when      slrlvl = 0
     C                   eval      slrlvl = slrlvl + 11
     C                   when      slrlvl < 0
     C                   eval      slrlvl = slrlvl * -1
     C                   endsl
     C                   endif

     *    Convert numeric handstack to alpha character.

     C                   if            slhand >= ' 0'
     C                             and slhand <= '99'
     C                   eval      wkchar = slhand
     C                   exsr      zzcvt2ltr
     C                   eval      slhand = nwchar
     C                   endif

     C     slloc         div       2             dummy
     C                   mvr                     oddeven
     C                   if        oddeven <> 0
     C                   eval      slside = 1
     C                   else
     C                   eval      slside = 0
     C                   endif
     *
     *    Check if base slot exists for imported slot with handstacks.
     *
     C                   eval      crtbaseslot = *off
     C                   if        handstack = *on
     C     keysl2b       setll     slot2
     C                   if        not %equal(slot2)
     C                   eval      crtbaseslot = *on
     C                   endif
     C                   endif

     *    See if slot meets criteria for allowing it to be created.

     C                   select

     *    If non-special slot doesn't have hypens, then don't add it.

     C                   when      dashpos = 0
     C                   eval      notcreated = *on
     C                   goto      endcreate

     *    Don't allow creation if department is unknown.

     C                   when      validdept = '*NO '
     C                   eval      notcreated = *on
     C                   goto      endcreate

     *    If location or level is not numeric, then don't add.

     C                   when      locnotnum or lvlnotnum
     C                   eval      notcreated = *on
     C                   goto      endcreate

     *    Otherwise, slot is ok to be created.

     C                   other
     C                   eval      slwhdp = siwhdp
     C                   eval      sldisp = sidisp
     C                   eval      slstyp = sistyp

     C                   endsl

     *    Try and create the Base slot.

     C                   if        crtbaseslot = *on
     *    Save handstack for virtual slot.
     C                   eval      svhand = slhand

     C                   eval      slwhse = siwhse
     C                   eval      sldisp = kydisp
     C                   eval      slpseq = sipseq
     C                   select
     C                   when      slpseq = 0
     C                   eval      slpseq = slloc
     C                   when      slpseq < 0
     C                   eval      slpseq = slpseq * -1
     C                   endsl
     C                   eval      slstat = 'V '
     C                   eval      slhand = '  '
     C                   eval      slrsrv = sirsrv
     C                   if        sisdef > ' '
     C                   eval      slsdef = sisdef
     C                   else
     C                   eval      slsdef = 'XX'
     C                   endif
     C                   eval      slpick = sipick

     C                   eval      sldesg = sidesg
     C                   eval      slbld  = sibld
     C                   eval      slactv = siactv

     C                   write (e) slrec
     C                   if        %error
     C                   eval      notcreated = *on
     C                   endif
     *
     C                   endif

     *    Try and create the imported slot.

     C                   eval      slwhse = siwhse
     *
     *    Replace base slot display, handstack w/ imported fields.
     C                   if        crtbaseslot = *on
     C                   eval      slhand = svhand
     C                   eval      sldisp = sidisp
     C                   endif
     *
     C                   eval      slpseq = sipseq
     C                   select
     C                   when      slpseq = 0
     C                   eval      slpseq = slloc
     C                   when      slpseq < 0
     C                   eval      slpseq = slpseq * -1
     C                   endsl
     C                   if        slitem > ' '
     C                   eval      slstat = 'A'
     C                   else
     C                   eval      slstat = 'V'
     C                   endif
     *
     *    Slot has handstack, create as virtual slot.
     C                   if        handstack = *on
     C                   eval      slrsrv = 'V'
     C                   else
     C                   eval      slrsrv = sirsrv
     C                   endif
     *
     C                   if        sisdef > ' '
     C                   eval      slsdef = sisdef
     C                   else
     C                   eval      slsdef = 'XX'
     C                   endif
     *
     C                   if        sidesg > ' '
     C                   eval      sldesg = sidesg
     C                   endif
     *
     C                   if        sibld  > ' '
     C                   eval      slbld  = sibld
     C                   endif
     *
     C                   if        siactv > ' '
     C                   eval      slactv = siactv
     C                   endif
     *
     C                   eval      slpick = sipick

     C                   write (e) slrec
     C                   if        %error
     C                   eval      notcreated = *on
     C                   endif

     *    Create Virtual slot record.

     C                   if        handstack = *on
     C                   eval      vswhse = slwhse
     C                   eval      vswhdp = slwhdp
     C                   eval      vsaisl = slaisl
     C                   eval      vsloc  = slloc
     C                   eval      vsrlvl = slrlvl
     C                   eval      vshand = slhand
     C                   eval      vsdisp = sldisp
     C                   eval      vspdis = kydisp
     C                   eval      vscdte = impdte
     C                   eval      vsctim = imptim
     C                   add       1             vsctim
     C                   write (e) vsrec
     C                   if        %error
     C                   eval      error  = *on
     C                   eval      detmsg = desc(8)
     C                   add       1             notcrt
     C                   goto      endcreate
     C                   endif

     C                   endif


     C     endcreate     endsr
SVLbA*
SVLbA*----------------------------------------------------------------
SVLbA*  crtslot1  Try and create physical slot.
SVLbA*----------------------------------------------------------------
SVLbA
SVLbAC     crtslot1      begsr
SVLbAC                   eval      notcreated = *off
SVLbA
SVLbA*  Turn on SlotCreated flag even if slot isn't created
SVLbA*  so ZZUPD routine doesn't get executed.
SVLbAC                   eval      slotcreated= *on
SVLbAC                   eval      handstack  = *off
SVLbAC                   clear                   slrec
SVLbA
SVLbA*  Extract location and level. Test if they are numeric.
SVLbA
SVLbAC                   eval      locnotnum = *off
SVLbAC                   eval      lvlnotnum = *off
SVLbAC                   eval      dashpos = 0
SVLbAC                   eval      loca  = ' '
SVLbAC                   eval      lvla  = ' '
SVLbA
SVLbA*  Check for all alpha slot. If no digits, default slot location
SVLbA*  will be assigned.
SVLbAC                   If            %subst(sidisp:2:3) >= '000'
SVLbAC                             and %subst(sidisp:2:3) <= '999'
SVLbAC                             or  %subst(sidisp:3:3) >= '000'
SVLbAC                             and %subst(sidisp:3:3) <= '999'
SVLbAC                   eval      allchrslot = *off
SVLbAC                   else
SVLbAC                   eval      allchrslot = *on
SVLbAC                   endif
SVLbA
SVLbAC                   select
SVLbA
SVLbA*  No Dashes specified. Single character aisle
SVLbAC                   when          %subst(sidisp:2:3) >= '000'
SVLbAC                             and %subst(sidisp:2:3) <= '999'
SVLbAC                   eval      dashpos = -1
SVLbAC                   eval      slaisl = '  ' + %subst(sidisp:1:1)
SVLbAC                   eval      loca  = '0' + %subst(sidisp:2:2)
SVLbAC                   move      loca          slloc
SVLbAC                   eval      lvla  = %subst(sidisp:3:1)
SVLbAC                   move      lvla          slrlvl
SVLbAC                   eval      slhand  = ' ' + %subst(sidisp:5:1)
SVLbA
SVLbA*  No Dashes specified. Double character aisle
SVLbAC                   when          %subst(sidisp:3:3) >= '000'
SVLbAC                             and %subst(sidisp:3:3) <= '999'
SVLbAC                   eval      dashpos = -1
SVLbAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
SVLbAC                   eval      loca  = '0' + %subst(sidisp:3:2)
SVLbAC                   move      loca          slloc
SVLbAC                   eval      lvla  = %subst(sidisp:5:1)
SVLbAC                   move      lvla          slrlvl
SVLbAC                   eval      slhand  = ' ' + %subst(sidisp:6:1)
SVLbA
SVLbA*  No dashes specified. All character slot.
SVLbAC                   when      allchrslot = *on
SVLbAC
SVLbAC                   eval      kydisp = sidisp
SVLbAC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
SVLbAC
SVLbAC                   eval      dftlocation = dftlocation + 1
SVLbAC                   eval      loca   = %char(dftlocation)
SVLbAC                   eval      slloc  = dftlocation
SVLbAC
SVLbAC                   eval      slrlvl = 1
SVLbAC                   eval      lvla   = '1'
SVLbAC
SVLbAC                   eval      slhand  = '  '
SVLbAC                   eval      dashpos = -1
SVLbA
SVLbAC                   endsl
SVLbA
SVLbA*  Begin testing parts for ALL slots.
SVLbAC                   testn                   loca                 5050
SVLbAC                   if        *in50 = *off
SVLbAC                   eval      locnotnum = *on
SVLbA
SVLbAC                   else
SVLbAC                   select
SVLbAC                   when      slloc  = 0
SVLbAC                   eval      slloc = slloc + 100
SVLbAC                   when      slloc < 0
SVLbAC                   eval      slloc = slloc * -1
SVLbAC                   endsl
SVLbAC                   endif
SVLbA
SVLbAC                   testn                   lvla                 50
SVLbAC                   if        *in50 = *off
SVLbAC                   eval      lvlnotnum = *on
SVLbAC                   else
SVLbAC                   select
SVLbAC                   when      slrlvl = 0
SVLbAC                   eval      slrlvl = slrlvl + 1
SVLbAC                   when      slrlvl < 0
SVLbAC                   eval      slrlvl = slrlvl * -1
SVLbAC                   endsl
SVLbAC                   endif
SVLbA
SVLbA*    Convert numeric handstack to alpha character.
SVLbA
SVLbAC                   if            slhand >= ' 0'
SVLbAC                             and slhand <= '99'
SVLbAC                   eval      wkchar = slhand
SVLbAC                   exsr      zzcvt2ltr
SVLbAC                   eval      slhand = nwchar
SVLbAC                   endif
SVLbA
SVLbAC     slloc         div       2             dummy
SVLbAC                   mvr                     oddeven
SVLbAC                   if        oddeven <> 0
SVLbAC                   eval      slside = 1
SVLbAC                   else
SVLbAC                   eval      slside = 0
SVLbAC                   endif
SVLbA
SVLbA*    See if slot meets criteria for allowing it to be created.
SVLbA
SVLbAC                   select
SVLbA
SVLbA*    If non-special slot doesn't have hypens, then don't add it.
SVLbA
SVLbAC                   when      dashpos = 0
SVLbAC                   eval      notcreated = *on
SVLbAC                   goto      endcreate1
SVLbA
SVLbA*    Don't allow creation if department is unknown.
SVLbA
SVLbAC                   when      validdept = '*NO '
SVLbAC                   eval      notcreated = *on
SVLbAC                   goto      endcreate1
SVLbA
SVLbA*    If location or level is not numeric, then don't add.
SVLbA
SVLbAC                   when      locnotnum or lvlnotnum
SVLbAC                   eval      notcreated = *on
SVLbAC                   goto      endcreate1
SVLbA
SVLbA*    Otherwise, slot is ok to be created.
SVLbA
SVLbAC                   other
SVLbAC                   eval      slwhdp = siwhdp
SVLbAC                   eval      sldisp = sidisp
SVLbAC                   eval      slstyp = sistyp
SVLbA
SVLbAC                   endsl
SVLbA
SVLbA*    Try and create the imported slot.
SVLbA
SVLbAC                   eval      slwhse = siwhse
SVLbAC                   eval      slpseq = sipseq
SVLbAC*
SVLbAC                   select
SVLbAC                   when      slpseq = 0
SVLbAC                   eval      slpseq = slloc
SVLbAC                   when      slpseq < 0
SVLbAC                   eval      slpseq = slpseq * -1
SVLbAC                   endsl
SVLbAC                   if        slitem > ' '
SVLbAC                   eval      slstat = 'A'
SVLbAC                   else
SVLbAC                   eval      slstat = 'V'
SVLbAC                   endif
SVLbA*
SVLbAC                   eval      slrsrv = sirsrv
SVLbA*
SVLbAC                   if        sisdef > ' '
SVLbAC                   eval      slsdef = sisdef
SVLbAC                   else
SVLbAC                   eval      slsdef = 'XX'
SVLbAC                   endif
SVLbA*
SVLbAC                   if        sidesg > ' '
SVLbAC                   eval      sldesg = sidesg
SVLbAC                   endif
SVLbA*
SVLbAC                   if        sibld  > ' '
SVLbAC                   eval      slbld  = sibld
SVLbAC                   endif
SVLbA*
SVLbAC                   if        siactv > ' '
SVLbAC                   eval      slactv = siactv
SVLbAC                   endif
SVLbA*
SVLbAC                   eval      slpick = sipick
SVLbA
SVLbAC                   write (e) slrec
SVLbAC                   if        %error
SVLbAC                   eval      notcreated = *on
SVLbAC                   endif
SVLbA
SVLbA
SVLbAC     endcreate1    endsr

EI  A*----------------------------------------------------------------
EI  A*  crtslot2  Try and create physical slot.
EI  A*----------------------------------------------------------------
EI  A
EI  AC     crtslot2      begsr
EI  AC                   eval      notcreated = *off
EI  AC                   eval      handstack  = *off
EI  AC                   clear                   slrec
EI  A
EI  A*  Extract location and level. Test if they are numeric.
EI  A
EI  AC                   eval      locnotnum = *off
EI  AC                   eval      lvlnotnum = *off
EI  AC                   eval      dashpos = 0
EI  AC                   eval      loca  = ' '
EI  AC                   eval      lvla  = ' '
EI  A
EI  AC                   select
EI  A
EI  A*  Dashes specified. Single character aisle
EI  AC                   when      %subst(sidisp:2:1) = '-'
EI  AC                             and %subst(sidisp:6:1) = '-'
EI  AC                   eval      dashpos = 2
EI  AC                   eval      slaisl = '  ' + %subst(sidisp:1:1)
EI  AC                   eval      loca  = %subst(sidisp:3:3)
EI  AC                   move      loca          slloc
EI  AC                   eval      lvla  = %subst(sidisp:7:1)
EI  AC                   move      lvla          slrlvl
EI  AC                   eval      slhand  = ' ' + %subst(sidisp:8:1)
EI  AC                   if        slhand > ' '
EI  AC                   eval      handstack = *on
EI  AC                   endif
EI  A
EI  A*  Dashes specified. Double character aisle
EI  AC                   when      %subst(sidisp:3:1) = '-'
EI  AC                             and %subst(sidisp:7:1) = '-'
EI  AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
EI  AC                   eval      loca  = %subst(sidisp:4:3)
EI  AC                   move      loca          slloc
EI  AC                   eval      lvla  = %subst(sidisp:8:1)
EI  AC                   move      lvla          slrlvl
EI  AC                   eval      slhand  = ' ' + %subst(sidisp:9:1)
EI  AC                   if        slhand > ' '
EI  AC                   eval      handstack = *on
EI  AC                   endif
EI  AC                   eval      dashpos = 3
EI  A
EI  A*  No dashes specified. Double character aisle, numeric rack level.
EI  AC                   when          (%subst(sidisp:2:1) >= 'A'
EI  AC                             and  %subst(sidisp:2:1) <= 'Z'
EI1 MC                             and  %subst(sidisp:3:1)  > ' ')
EI  AC                             or  (%subst(sidisp:2:1) >= '0'
EI  AC                             and  %subst(sidisp:2:1) <= '9'
EI1 MC                             and  %subst(sidisp:3:1)  > ' ')
EI  AC
EI  AC                   eval      kydisp = %subst(sidisp:1:12)
EI  AC                   evalr     slaisl  = %trimr(%subst(sidisp:1:2))
EI  A
EI  AC                   evalr     loca    = %trimr(%subst(sidisp:3:3))
EI  AC                   move (p)  loca          slloc
EI  AC                   if        slloc <= 0
EI  AC                   eval      slloc = slloc + 100
EI  AC                   endif
EI  A
EI  AC                   eval      lvla    = %subst(sidisp:6:1)
EI  AC                   move (p)  lvla          slrlvl
EI1 AC                   if        slrlvl <= 0
EI  AC                   eval      slrlvl = slrlvl + 1
EI1 AC                   endif
EI  A
EI  A*   Special reserved slot. Don't break out handstack characters.
EI  AC                   if        %subst(sidisp:7:3) = 'OVR'
EI  AC                   eval      slhand  = '  '
EI  AC                   else
EI  AC*                  evalr     slhand  = %trimr(%subst(sidisp:8:2))
EI  AC                   endif
EI  AC                   if        slhand > ' '
EI  AC                   eval      handstack = *on
EI  AC                   endif
EI  AC                   eval      dashpos = -1
EI  A
EI  A*  No dashes specified. Triple character aisle, numeric rack level.
EI1 MC                   when          (%subst(sidisp:3:1) >= 'A'
EI1 MC                             and  %subst(sidisp:3:1) <= 'Z'
EI  AC                             and  %subst(sidisp:3:1)  > ' ')
EI  AC                             or  (%subst(sidisp:2:1) >= '0'
EI  AC                             and  %subst(sidisp:2:1) <= '9'
EI  AC                             and  %subst(sidisp:3:1)  > ' ')
EI  AC
EI  AC                   eval      kydisp = %subst(sidisp:1:12)
EI  AC                   evalr     slaisl  = %trimr(%subst(sidisp:1:3))
EI  A
EI  AC                   evalr     loca    = %trimr(%subst(sidisp:4:3))
EI  AC                   move (p)  loca          slloc
EI  AC                   if        slloc <= 0
EI  AC                   eval      slloc = slloc + 100
EI  AC                   endif
EI  A
EI  AC                   eval      lvla    = %subst(sidisp:7:1)
EI  AC                   move (p)  lvla          slrlvl
EI1 AC                   if        slrlvl <= 0
EI  AC                   eval      slrlvl = slrlvl + 1
EI1 AC                   endif
EI  A
EI  A*   Special reserved slot. Don't break out handstack characters.
EI  AC                   if        %subst(sidisp:7:3) = 'OVR'
EI  AC                   eval      slhand  = '  '
EI  AC                   else
EI  AC*                  evalr     slhand  = %trimr(%subst(sidisp:8:2))
EI  AC                   endif
EI  AC                   if        slhand > ' '
EI  AC                   eval      handstack = *on
EI  AC                   endif
EI  AC                   eval      dashpos = -1
EI  A
EI  A*  No dashes specified. Extract out slot breakdown.
EI  AC                   other
EI  AC
EI  AC                   eval      kydisp = %subst(sidisp:1:12)
EI  AC                   eval      slaisl  = ' ' + %subst(sidisp:1:2)
EI  A
EI  AC                   evalr     loca    = %trimr(%subst(sidisp:4:3))
EI  AC                   move      loca          slloc
EI1 AC                   if        slrlvl <= 0
EI  AC                   eval      slrlvl  = slrlvl + 1
EI1 AC                   endif
EI  A
EI  AC                   eval      lvla    = %subst(sidisp:7:1)
EI  AC                   move      lvla          slrlvl
EI  AC                   eval      slrlvl  = slrlvl + 1
EI  A
EI  A*   Special reserved slot. Don't break out handstack characters.
EI  AC                   if        %subst(sidisp:7:3) = 'OVR'
EI  AC                   eval      slhand  = '  '
EI  AC                   else
EI  AC                   evalr     slhand  = %trimr(%subst(sidisp:8:2))
EI  AC                   endif
EI  AC                   if        slhand > ' '
EI  AC                   eval      handstack = *on
EI  AC                   endif
EI  AC                   eval      dashpos = -1
EI  A
EI  AC                   endsl
EI  A
EI  A
EI  A*  Begin testing parts for ALL slots.
EI  AC                   testn                   loca                 5050
EI  AC                   if        *in50 = *off
EI  AC                   eval      locnotnum = *on
EI  A
EI  AC                   else
EI  A
EI  AC                   if        %subst(sidisp:8:3) = 'OVR'
EI  AC                   eval      slloc = slloc + 200
EI  AC                   endif
EI  A
EI  AC                   endif
EI  A
EI  AC                   testn                   lvla                 50
EI  AC                   if        *in50 = *off
EI  AC                   eval      lvlnotnum = *on
EI  AC                   else
EI  AC                   select
EI  AC                   when      slrlvl = 0
EI  AC                   eval      slrlvl = slrlvl + 1
EI  AC                   when      slrlvl < 0
EI  AC                   eval      slrlvl = slrlvl * -1
EI  AC                   endsl
EI  AC                   endif
EI  A
EI  A*    Convert numeric handstack to alpha character.
EI  A
EI  AC                   if            slhand >= ' 0'
EI  AC                             and slhand <= '99'
EI  AC                   eval      wkchar = slhand
EI  AC                   exsr      zzcvt2ltr
EI  AC                   eval      slhand = nwchar
EI  AC                   endif
EI  A
EI  AC     slloc         div       2             dummy
EI  AC                   mvr                     oddeven
EI  AC                   if        oddeven <> 0
EI  AC                   eval      slside = 1
EI  AC                   else
EI  AC                   eval      slside = 0
EI  AC                   endif
EI  A*
EI  A*    Check if base slot exists for imported slot with handstacks.
EI  A*
EI  AC                   eval      crtbaseslot = *off
EI  AC                   if        handstack = *on
EI  AC     keysl2b       setll     slot2
EI  AC                   if        not %equal(slot2)
EI  AC                   eval      crtbaseslot = *on
EI  AC                   endif
EI  AC                   endif
EI  A
EI  A*    See if slot meets criteria for allowing it to be created.
EI  A
EI  AC                   select
EI  A
EI  A*    If non-special slot doesn't have hypens, then don't add it.
EI  A
EI  AC                   when      dashpos = 0
EI  AC                   eval      notcreated = *on
EI  AC                   goto      endcreate2
EI  A
EI  A*    Don't allow creation if department is unknown.
EI  A
EI  AC                   when      validdept = '*NO '
EI  AC                   eval      notcreated = *on
EI  AC                   goto      endcreate2
EI  A
EI  A*    If location or level is not numeric, then don't add.
EI  A
EI  AC                   when      locnotnum or lvlnotnum
EI  AC                   eval      notcreated = *on
EI  AC                   goto      endcreate2
EI  A
EI  A*    Otherwise, slot is ok to be created.
EI  A
EI  AC                   other
EI  AC                   eval      slwhdp = siwhdp
EI  AC                   eval      sldisp = sidisp
EI  AC                   eval      slstyp = sistyp
EI  A
EI  AC                   endsl
EI  A
EI  A*    Try and create the Base slot.
EI  A
EI  AC                   if        crtbaseslot = *on
EI  A*    Save handstack for virtual slot.
EI  AC                   eval      svhand = slhand
EI  A
EI  AC                   eval      slwhse = siwhse
EI  AC                   eval      sldisp = kydisp
EI  AC                   eval      slpseq = sipseq
EI  AC                   select
EI  AC                   when      slpseq = 0
EI  AC                   eval      slpseq = slloc
EI  AC                   when      slpseq < 0
EI  AC                   eval      slpseq = slpseq * -1
EI  AC                   endsl
EI  AC                   eval      slstat = 'V '
EI  AC                   eval      slhand = '  '
EI  AC                   eval      slrsrv = sirsrv
EI  AC                   eval      slsdef = 'XX'
EI  AC                   eval      slpick = sipick
EI  A
EI  AC                   write     slrec
EI  AC                   if        %error
EI  AC                   eval      notcreated = *on
EI  AC                   endif
EI  A*
EI  AC                   endif
EI  A
EI  A*    Try and create the imported slot.
EI  A
EI  AC                   eval      slwhse = siwhse
EI  A*
EI  A*    Replace base slot display, handstack w/ imported fields.
EI  AC                   if        crtbaseslot = *on
EI  AC                   eval      slhand = svhand
EI  AC                   eval      sldisp = sidisp
EI  AC                   endif
EI  A*
EI  AC                   eval      slpseq = sipseq
EI  AC                   select
EI  AC                   when      slpseq = 0
EI  AC                   eval      slpseq = slloc
EI  AC                   when      slpseq < 0
EI  AC                   eval      slpseq = slpseq * -1
EI  AC                   endsl
EI  AC                   eval      slstat = 'V'
EI  A*
EI  A*    Slot has handstack, create as virtual slot.
EI  AC                   if        handstack = *on
EI  AC                   eval      slrsrv = 'V'
EI  AC                   else
EI  AC                   eval      slrsrv = sirsrv
EI  AC                   endif
EI  AC                   eval      slsdef = 'XX'
EI  AC                   eval      slpick = sipick
EI  A
EI  AC                   write     slrec
EI  AC                   if        %error
EI  AC                   eval      notcreated = *on
EI  AC                   endif
EI  A
EI  A*    Create Virtual slot record.
EI  A
EI  AC                   if        handstack = *on
EI  AC                   eval      vswhse = slwhse
EI  AC                   eval      vswhdp = slwhdp
EI  AC                   eval      vsaisl = slaisl
EI  AC                   eval      vsloc  = slloc
EI  AC                   eval      vsrlvl = slrlvl
EI  AC                   eval      vshand = slhand
EI  AC                   eval      vsdisp = sldisp
EI  AC                   eval      vspdis = kydisp
EI  AC                   eval      vscdte = impdte
EI  AC                   eval      vsctim = imptim
EI  AC                   add       1             vsctim
EI  AC                   write     vsrec
EI  AC                   if        %error
EI  AC                   eval      error  = *on
EI  AC                   eval      detmsg = desc(8)
EI  AC                   add       1             notcrt
EI  AC                   goto      endcreate2
EI  AC                   endif
EI  A
EI  AC                   endif
EI  A
EI  A
EI  AC     endcreate2    endsr

GFS A*----------------------------------------------------------------
GFS A*  crtslot3   Try and create physical slot.  Get Fresh Sales
GFS A*----------------------------------------------------------------
GFS A
GFS AC     crtslot3      begsr
GFS AC                   eval      notcreated = *off
GFS A
GFS A*  Turn on SlotCreated flag even if slot isn't created
GFS A*  so ZZUPD routine doesn't get executed.
GFS AC                   eval      slotcreated= *on
GFS AC                   eval      handstack  = *off
GFS AC                   clear                   slrec
GFS A
GFS A*  Extract location and level. Test if they are numeric.
GFS A
GFS AC                   eval      locnotnum = *off
GFS AC                   eval      lvlnotnum = *off
GFS AC                   eval      dashpos = 0
GFS AC                   eval      loca  = ' '
GFS AC                   eval      lvla  = ' '
GFS A
GFS A*  Check for all alpha slot. If no digits, default slot location
GFS A*  will be assigned.
GFS AC                   If            %subst(sidisp:4:3) >= '000'
GFS AC                             and %subst(sidisp:4:3) <= '999'
GFS AC                             and %subst(sidisp:8:1) >= '0'
GFS AC                             and %subst(sidisp:8:1) <= '9'
GFS A
GFS AC                             or  %subst(sidisp:4:3) >= '000'
GFS AC                             and %subst(sidisp:4:3) <= '999'
GFS AC                             and %subst(sidisp:8:2) >= '00'
GFS AC                             and %subst(sidisp:8:2) <= '99'
GFS A
GFS AC                   eval      allchrslot = *off
GFS AC                   else
GFS AC                   eval      allchrslot = *on
GFS AC                   endif
GFS A
GFS A
GFS AC                   select
GFS A
GFS A*  No dashes specified. All character slot.
GFS AC                   when      allchrslot = *on
GFS AC
GFS AC                   eval      kydisp = sidisp
GFS AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
GFS AC
GFS AC                   eval      dftlocation = dftlocation + 1
GFS AC                   eval      loca   = %char(dftlocation)
GFS AC                   eval      slloc  = dftlocation
GFS AC
GFS AC                   eval      slrlvl = 1
GFS AC                   eval      lvla   = '1'
GFS AC
GFS AC                   eval      slhand  = '  '
GFS AC                   eval      dashpos = -1
GFS A
GFS A*  Dashes specified. Double character aisle (Ex 10-101-1)
GFS AC                   when          %subst(sidisp:3:1) = '-'
GFS AC                             and %subst(sidisp:4:3) >= '000'
GFS AC                             and %subst(sidisp:4:3) <= '999'
GFS AC                             and %subst(sidisp:8:1) >= '0'
GFS AC                             and %subst(sidisp:8:1) <= '9'
GFS AC                   eval      dashpos = -1
GFS A*
GFS AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
GFS A*
GFS AC                   eval      loca  = %subst(sidisp:4:3)
GFS AC                   move      loca          slloc
GFS A*
GFS AC                   evalr     lvla  = %subst(sidisp:8:1)
GFS AC                   move      lvla          slrlvl
GFS A*
GFS AC                   eval      slhand  = ' ' + %subst(sidisp:9:1)
GFS A
GFS A*  Dashes specified. Double character aisle,dbl rack level
GFS A*                                                       EX 10-101-10
GFS AC                   when          %subst(sidisp:3:1) = '-'
GFS AC                             and %subst(sidisp:4:3) >= '000'
GFS AC                             and %subst(sidisp:4:3) <= '999'
GFS AC                             and %subst(sidisp:8:2) >= '00'
GFS AC                             and %subst(sidisp:8:2) <= '99'
GFS AC                   eval      dashpos = -1
GFS A*
GFS AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
GFS A*
GFS AC                   eval      loca  = %subst(sidisp:4:3)
GFS AC                   move      loca          slloc
GFS A*
GFS AC                   evalr     lvla  = %subst(sidisp:8:2)
GFS AC                   move      lvla          slrlvl
GFS A*
GFS AC                   eval      slhand  = ' ' + %subst(sidisp:10:1)
GFS A
GFS AC                   endsl
GFS A
GFS A*  Begin testing parts for ALL slots.
GFS AC                   testn                   loca                 5050
GFS AC                   if        *in50 = *off
GFS AC                   eval      locnotnum = *on
GFS A
GFS AC                   else
GFS AC                   select
GFS AC                   when      slloc  = 0
GFS AC                   eval      slloc = slloc + 100
GFS AC                   when      slloc < 0
GFS AC                   eval      slloc = slloc * -1
GFS AC                   endsl
GFS AC                   endif
GFS A
GFS AC                   testn                   lvla                 50
GFS AC                   if        *in50 = *off
GFS AC                   eval      lvlnotnum = *on
GFS AC                   else
GFS AC                   select
GFS AC                   when      slrlvl = 0
GFS AC                   eval      slrlvl = slrlvl + 1
GFS AC                   when      slrlvl < 0
GFS AC                   eval      slrlvl = slrlvl * -1
GFS AC                   endsl
GFS AC                   endif
GFS A
GFS A*    Convert numeric handstack to alpha character.
GFS A
GFS AC                   if            slhand >= ' 0'
GFS AC                             and slhand <= '99'
GFS AC                   eval      wkchar = slhand
GFS AC                   exsr      zzcvt2ltr
GFS AC                   eval      slhand = nwchar
GFS AC                   endif
GFS A
GFS AC     slloc         div       2             dummy
GFS AC                   mvr                     oddeven
GFS AC                   if        oddeven <> 0
GFS AC                   eval      slside = 1
GFS AC                   else
GFS AC                   eval      slside = 0
GFS AC                   endif
GFS A
GFS A*    See if slot meets criteria for allowing it to be created.
GFS A
GFS AC                   select
GFS A
GFS A*    If non-special slot doesn't have hypens, then don't add it.
GFS A
GFS AC                   when      dashpos = 0
GFS AC                   eval      notcreated = *on
GFS AC                   goto      endcreate3
GFS A
GFS A*    Don't allow creation if department is unknown.
GFS A
GFS AC                   when      validdept = '*NO '
GFS AC                   eval      notcreated = *on
GFS AC                   goto      endcreate3
GFS A
GFS A*    If location or level is not numeric, then don't add.
GFS A
GFS AC                   when      locnotnum or lvlnotnum
GFS AC                   eval      notcreated = *on
GFS AC                   goto      endcreate3
GFS A
GFS A*    Otherwise, slot is ok to be created.
GFS A
GFS AC                   other
GFS AC                   eval      slwhdp = siwhdp
GFS AC                   eval      sldisp = sidisp
GFS AC                   eval      slstyp = sistyp
GFS A
GFS AC                   endsl
GFS A
GFS A*    Try and create the imported slot.
GFS A
GFS AC                   eval      slwhse = siwhse
GFS AC                   eval      slpseq = sipseq
GFS AC*
GFS AC                   select
GFS AC                   when      slpseq = 0
GFS AC                   eval      slpseq = slloc
GFS AC                   when      slpseq < 0
GFS AC                   eval      slpseq = slpseq * -1
GFS AC                   endsl
GFS AC                   if        slitem > ' '
GFS AC                   eval      slstat = 'A'
GFS AC                   else
GFS AC                   eval      slstat = 'V'
GFS AC                   endif
GFS A*
GFS AC                   eval      slpick = sipick
GFS AC                   eval      slrsrv = sirsrv
GFS AC                   if        sisdef > ' '
GFS AC                   eval      slsdef = sisdef
GFS AC                   else
GFS AC                   eval      slsdef = 'XX'
GFS AC                   endif
GFS AC                   if        sibld > ' '
GFS AC                   eval      slbld = sibld
GFS AC                   endif
GFS AC                   if        siactv > ' '
GFS AC                   eval      slactv = siactv
GFS AC                   endif
GFS AC                   if        sidesg > ' '
GFS AC                   eval      sldesg = sidesg
GFS AC                   endif
GFS A
GFS AC                   write (e) slrec
GFS AC                   if        %error
GFS AC                   eval      notcreated = *on
GFS AC                   endif
GFS A
GFS AC     endcreate3    endsr
CBIb
CBIbA*----------------------------------------------------------------
CBIbA*  crtslot4   Try and create physical slot. Cheney Pate Dawson.
CBIbA*----------------------------------------------------------------
CBIbA
CBIbAC     crtslot4      begsr
CBIbAC                   eval      notcreated = *off
CBIbAC                   eval      sidisp = %xlate(lower:UPPER:sidisp)
CBIbA
CBIbA*  Turn on SlotCreated flag even if slot isn't created
CBIbA*  so ZZUPD routine doesn't get executed.
CBIbAC                   eval      slotcreated= *on
CBIbAC                   eval      handstack  = *off
CBIbAC                   clear                   slrec
CBIbA
CBIbA*  Extract location and level. Test if they are numeric.
CBIbA
CBIbAC                   eval      locnotnum = *off
CBIbAC                   eval      lvlnotnum = *off
CBIbAC                   eval      dashpos = 0
CBIbAC                   eval      loca  = ' '
CBIbAC                   eval      lvla  = ' '
CBIbA
CBIbA*  Check for all alpha slot. If no digits, default slot location
CBIbA*  will be assigned.
CBIbAC                   If            %subst(sidisp:4:2) >= '00'
CBIbAC                             and %subst(sidisp:4:2) <= '99'
CBIbAC                             and %subst(sidisp:7:1) >= '0'
CBIbAC                             and %subst(sidisp:7:1) <= '9'
CBIbAC                             and %subst(sidisp:8:1) >= '0'
CBIbAC                             and %subst(sidisp:8:1) <= '9'
CBIbA*
CBIbAC                             or  %subst(sidisp:4:2) >= '00'
CBIbAC                             and %subst(sidisp:4:2) <= '99'
CBIbAC                             and %subst(sidisp:7:1) >= 'A'
CBIbAC                             and %subst(sidisp:7:1) <= 'Z'
CBIbAC                             and %subst(sidisp:8:1) >= '0'
CBIbAC                             and %subst(sidisp:8:1) <= '9'
CBIbA*
CBIbAC                   eval      allchrslot = *off
CBIbAC                   else
CBIbAC                   eval      allchrslot = *on
CBIbAC                   endif
CBIbA
CBIbA
CBIbAC                   select
CBIbA
CBIbA*  No dashes specified. All character slot.
CBIbAC                   when      allchrslot = *on
CBIbAC
CBIbAC                   eval      kydisp = sidisp
CBIbAC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
CBIbAC
CBIbAC                   eval      dftlocation = dftlocation + 1
CBIbAC                   eval      loca   = %char(dftlocation)
CBIbAC                   eval      slloc  = dftlocation
CBIbAC
CBIbAC                   eval      slrlvl = 1
CBIbAC                   eval      lvla   = '1'
CBIbAC
CBIbAC                   eval      slhand  = '  '
CBIbAC                   eval      dashpos = -1
CBIbA
CBIbA*  Dashes specified. Double character aisle (Ex AC-64-B4)
CBIbAC                   when          %subst(sidisp:3:1)  = '-'
CBIbAC                             and %subst(sidisp:4:2) >= '00'
CBIbAC                             and %subst(sidisp:4:2) <= '99'
CBIbAC                             and %subst(sidisp:6:1)  = '-'
CBIbAC                             and (%subst(sidisp:7:1) >= '0'
CBIbAC                              and %subst(sidisp:7:1) <= '9'
CBIbAC                              or  %subst(sidisp:7:1) >= 'A'
CBIbAC                              and %subst(sidisp:7:1) <= 'Z')
CBIbAC                   eval      dashpos = -1
CBIbAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
CBIbA*
CBIbAC                   eval      loca  = '0' + %subst(sidisp:4:2)
CBIbAC                   move      loca          slloc
CBIbA*
CBIbA*      Convert alpha level into numeric value.
CBIbAC                   eval      lvla    = %subst(sidisp:7:1)
CBIbAC                   evalr     wkchar = %trimr(lvla)
CBIbAC                   exsr      zzcvt2nbr
CBIbAC                   if        nwchar > ' '
CBIbAC                   evalr     lvla   = %trimr(nwchar)
CBIbAC                   eval      slrlvl = %dec(nwchar:2:0)
CBIbAC                   else
CBIbAC                   evalr     lvla  = %subst(sidisp:7:1)
CBIbAC                   move      lvla          slrlvl
CBIbAC                   endif
CBIbAC                   eval      slhand  = ' ' + %subst(sidisp:8:1)
CBIbA
CBIbAC                   endsl
CBIbA
CBIbA*  Begin testing parts for ALL slots.
CBIbAC                   testn                   loca                 5050
CBIbAC                   if        *in50 = *off
CBIbAC                   eval      locnotnum = *on
CBIbA
CBIbAC                   else
CBIbAC                   select
CBIbAC                   when      slloc  = 0
CBIbAC**                 eval      slloc = slloc + 100
CBIbAC                   when      slloc < 0
CBIbAC                   eval      slloc = slloc * -1
CBIbAC                   endsl
CBIbAC                   endif
CBIbA
CBIbAC                   testn                   lvla                 50
CBIbAC                   if        *in50 = *off
CBIbAC                   eval      lvlnotnum = *on
CBIbAC                   else
CBIbAC                   select
CBIbAC                   when      slrlvl = 0
CBIbAC*                  eval      slrlvl = slrlvl + 1
CBIbAC                   when      slrlvl < 0
CBIbAC                   eval      slrlvl = slrlvl * -1
CBIbAC                   endsl
CBIbAC                   endif
CBIbA
CBIbA*    Convert numeric handstack to alpha character.
CBIbA
CBIbAC                   if            slhand >= ' 0'
CBIbAC                             and slhand <= '99'
CBIbAC                   eval      wkchar = slhand
CBIbAC                   exsr      zzcvt2ltr
CBIbAC                   eval      slhand = nwchar
CBIbAC                   endif
CBIbA*
CBIbAC     slloc         div       2             dummy
CBIbAC                   mvr                     oddeven
CBIbAC                   if        oddeven <> 0
CBIbAC                   eval      slside = 1
CBIbAC                   else
CBIbAC                   eval      slside = 0
CBIbAC                   endif
CBIbA
CBIbA*    See if slot meets criteria for allowing it to be created.
CBIbA
CBIbAC                   select
CBIbA
CBIbA*    If non-special slot doesn't have hypens, then don't add it.
CBIbA
CBIbAC                   when      dashpos = 0
CBIbAC                   eval      notcreated = *on
CBIbAC                   goto      endcreate4
CBIbA
CBIbA*    Don't allow creation if department is unknown.
CBIbA
CBIbAC                   when      validdept = '*NO '
CBIbAC                   eval      notcreated = *on
CBIbAC                   goto      endcreate4
CBIbA
CBIbA*    If location or level is not numeric, then don't add.
CBIbA
CBIbAC                   when      locnotnum or lvlnotnum
CBIbAC                   eval      notcreated = *on
CBIbAC                   goto      endcreate4
CBIbA
CBIbA*    Otherwise, slot is ok to be created.
CBIbA
CBIbAC                   other
CBIbAC                   eval      slwhdp = siwhdp
CBIbAC                   eval      sldisp = sidisp
CBIbAC                   eval      slstyp = sistyp
CBIbA
CBIbAC                   endsl
CBIbA
CBIbA*    Try and create the imported slot.
CBIbA
CBIbAC                   eval      slwhse = siwhse
CBIbAC                   eval      slpseq = sipseq
CBIbAC*
CBIbAC                   select
CBIbAC                   when      slpseq = 0
CBIbAC                   eval      slpseq = slloc
CBIbAC                   when      slpseq < 0
CBIbAC                   eval      slpseq = slpseq * -1
CBIbAC                   endsl
CBIbAC                   if        slitem > ' '
CBIbAC                   eval      slstat = 'A'
CBIbAC                   else
CBIbAC                   eval      slstat = 'V'
CBIbAC                   endif
CBIbA*
CBIbAC                   eval      slrsrv = sirsrv
CBIbA*
CBIbAC                   if        %subst(sidgtp:2:1) > ' '
CBIbAC                   eval      slsdef = %subst(sidgtp:2:1) + ' '
CBIbAC                   else
CBIbA*
CBIbAC                   eval      slsdef = 'XX'
CBIbAC                   endif
CBIbA*
CBIbAC                   eval      slpick = sipick
CBIbA
CBIbAC                   write (e) slrec
CBIbAC                   if        %error
CBIbAC                   eval      notcreated = *on
CBIbAC                   endif
CBIbA
CBIbAC     endcreate4    endsr
JFFaA
JFFaA*----------------------------------------------------------------
JFFaA*  crtslot5   Try and create physical slot. Jake's Finer Foods.
JFFaA*----------------------------------------------------------------
JFFaA
JFFaAC     crtslot5      begsr
JFFaAC                   eval      notcreated = *off
JFFaA
JFFaA*  Turn on SlotCreated flag even if slot isn't created
JFFaA*  so ZZUPD routine doesn't get executed.
JFFaAC                   eval      slotcreated= *on
JFFaAC                   eval      handstack  = *off
JFFaA
JFFaAC                   clear                   slrec
JFFaA
JFFaA*  Extract location and level. Test if they are numeric.
JFFaA
JFFaAC                   eval      locnotnum = *off
JFFaAC                   eval      lvlnotnum = *off
JFFaAC                   eval      dashpos = 0
JFFaAC                   eval      loca  = ' '
JFFaAC                   eval      lvla  = ' '
JFFaAC                   eval      lvlaa = ' '
JFFaA
JFFaA*  Check for all alpha slot. If no digits, default slot location
JFFaA*  will be assigned.
JFFaA*  Slot Format: DC-110-02A
JFFaAC                   If            %subst(sidisp:3:3) >= '000'
JFFaAC                             and %subst(sidisp:3:3) <= '999'
JFFaAC                             and %subst(sidisp:7:2) >= '00'
JFFaAC                             and %subst(sidisp:7:2) <= '99'
JFFaA*  Slot Format: 62-84A1
JFFaAC                             or  %subst(sidisp:4:2) >= '00'
JFFaAC                             and %subst(sidisp:4:2) <= '99'
JFFaA*  Slot Format: INT-101-01
JFFaAC                             or  %subst(sidisp:5:3) >= '000'
JFFaAC                             and %subst(sidisp:5:3) <= '999'
JFFaAC                             and %subst(sidisp:9:1) >= '0'
JFFaAC                             and %subst(sidisp:9:1) <= '9'
JFFaAC                             and %subst(sidisp:10:1) >= '0'
JFFaAC                             and %subst(sidisp:10:1) <= '9'
JFFaA*  Slot Format: CL1-01-12A1
JFFaAC                             or  %subst(sidisp:5:2) >= '00'
JFFaAC                             and %subst(sidisp:5:2) <= '99'
JFFaAC                             and %subst(sidisp:8:2) >= '00'
JFFaAC                             and %subst(sidisp:8:2) <= '99'
JFFaA*  Slot Format: RH2-02-2-03
JFFaAC                             or  %subst(sidisp:5:2) >= '00'
JFFaAC                             and %subst(sidisp:5:2) <= '99'
JFFaAC                             and %subst(sidisp:8:1) >= '0'
JFFaAC                             and %subst(sidisp:8:1) <= '9'
JFFaAC                             and %subst(sidisp:10:2) >= '00'
JFFaAC                             and %subst(sidisp:10:2) <= '99'
JFFaA*  Slot Format: EX-097-1-1
JFFaAC                             or  %subst(sidisp:4:3) >= '000'
JFFaAC                             and %subst(sidisp:4:3) <= '999'
JFFaAC                             and %subst(sidisp:8:1) >= '0'
JFFaAC                             and %subst(sidisp:8:1) <= '9'
JFFaAC                             and %subst(sidisp:10:1) >= '0'
JFFaAC                             and %subst(sidisp:10:1) <= '9'
JFFaA*
JFFaAC                   eval      allchrslot = *off
JFFaAC                   else
JFFaAC                   eval      allchrslot = *on
JFFaAC                   endif
JFFaA
JFFaA
JFFaAC                   select
JFFaA
JFFaA*  No dashes specified. All character slot.
JFFaAC                   when      allchrslot = *on
JFF AC                   select
JFF A*      Extract 3-char aisle.
JFF AC                   when      %subst(sidisp:4:1) = '-'
JFF AC                   evalr     slaisl = %trimr(%subst(sidisp:1:3))
JFF A*      Extract 2-char aisle.
JFF AC                   when      %subst(sidisp:3:1) = '-'
JFF AC                   evalr     slaisl = ' ' + %trimr(%subst(sidisp:1:2))
JFF AC                   other
JFF A*      Extract 1-char aisle.
JFF AC                   evalr     slaisl = '  ' + %trimr(%subst(sidisp:1:1))
JFF AC                   endsl
JFFaAC
JFFaAC                   eval      dftlocation = dftlocation + 1
JFFaAC                   eval      loca   = %char(dftlocation)
JFFaAC                   eval      slloc  = dftlocation
JFFaAC
JFFaAC                   eval      slrlvl = 1
JFFaAC                   eval      lvla   = '1'
JFFaAC
JFFaAC                   eval      slhand  = '  '
JFFaAC                   eval      dashpos = -1
JFFaA
JFFaA*  Dashes specified. Triple character aisle (Ex CL1-01-12A1)
JFFaAC                   when          %subst(sidisp:4:1)  = '-'
JFFaAC                             and %subst(sidisp:7:1)  = '-'
JFFaAC                             and %subst(sidisp:5:2) >= '00'
JFFaAC                             and %subst(sidisp:5:2) <= '99'
JFFaAC                             and %subst(sidisp:8:1) >= '0'
JFFaAC                             and %subst(sidisp:8:1) <= '9'
JFFaAC                             and %subst(sidisp:9:1) >= '0'
JFFaAC                             and %subst(sidisp:9:1) <= '9'
JFFaAC                   eval      dashpos = -1
JFFaAC                   eval      slaisl = %subst(sidisp:1:3)
JFFaA*
JFFaAC                   eval      loca  = '0' + %subst(sidisp:5:2)
JFFaAC                   move      loca          slloc
JFFaA*
JFFaAC                   eval      lvlaa   = %subst(sidisp:8:2)
JFFaAC                   move      lvlaa         slrlvl
JFFaAC                   eval      slhand  = %subst(sidisp:10:2)
JFFaA
JFFaA*  Dashes specified. Triple character aisle (Ex INT-101-01)
JFFaAC                   when          %subst(sidisp:4:1)  = '-'
JFFaAC                             and %subst(sidisp:8:1)  = '-'
JFFaAC                             and %subst(sidisp:5:3) >= '000'
JFFaAC                             and %subst(sidisp:5:3) <= '999'
JFFaAC                             and %subst(sidisp:9:1) >= '0'
JFFaAC                             and %subst(sidisp:9:1) <= '9'
JFFaAC                             and %subst(sidisp:10:1) >= '0'
JFFaAC                             and %subst(sidisp:10:1) <= '9'
JFFaAC                   eval      dashpos = -1
JFFaAC                   eval      slaisl = %subst(sidisp:1:3)
JFFaA*
JFFaAC                   eval      loca  = %subst(sidisp:5:3)
JFFaAC                   move      loca          slloc
JFFaA*
JFFaAC                   eval      lvlaa   = %subst(sidisp:9:2)
JFFaAC                   move      lvlaa         slrlvl
JFFaAC                   evalr     slhand  = %trimr(%subst(sidisp:11:2))
JFFaA
JFFaA
JFFaA*  Dashes specified. Triple character aisle (Ex RH2-02-2-03)
JFFaAC                   when          %subst(sidisp:4:1)  = '-'
JFFaAC                             and %subst(sidisp:7:1)  = '-'
JFFaAC                             and %subst(sidisp:9:1)  = '-'
JFFaAC                             and %subst(sidisp:5:2) >= '00'
JFFaAC                             and %subst(sidisp:5:2) <= '99'
JFFaAC                             and %subst(sidisp:8:1) >= '0'
JFFaAC                             and %subst(sidisp:8:1) <= '9'
JFFaAC                   eval      dashpos = -1
JFFaAC                   eval      slaisl = %subst(sidisp:1:3)
JFFaA*
JFFaAC                   eval      loca  = '0' + %subst(sidisp:5:2)
JFFaAC                   move      loca          slloc
JFFaA*
JFFaAC                   eval      lvla   = %subst(sidisp:8:1)
JFFaAC                   move      lvla          slrlvl
JFFaAC                   eval      slhand  = ' ' + %subst(sidisp:11:1)
JFFaA
JFFaA
JFFaA*  Dashes specified. Double character aisle (Ex EX-097-1-1)
JFFaAC                   when          %subst(sidisp:3:1)  = '-'
JFFaAC                             and %subst(sidisp:7:1)  = '-'
JFFaAC                             and %subst(sidisp:9:1)  = '-'
JFFaAC                             and %subst(sidisp:4:3) >= '000'
JFFaAC                             and %subst(sidisp:4:3) <= '999'
JFFaAC                             and %subst(sidisp:8:1) >= '0'
JFFaAC                             and %subst(sidisp:8:1) <= '9'
JFFaAC                   eval      dashpos = -1
JFFaAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
JFFaA*
JFFaAC                   eval      loca  = %subst(sidisp:4:3)
JFFaAC                   move      loca          slloc
JFFaA*
JFFaAC                   eval      lvla   = %subst(sidisp:8:1)
JFFaAC                   move      lvla          slrlvl
JFFaAC                   eval      slhand  = ' ' + %subst(sidisp:10:1)
JFFaA
JFFaA
JFFaA*  Dashes specified. Double character aisle (Ex UH-116-02A)
JFFaAC                   when          %subst(sidisp:3:1)  = '-'
JFFaAC                             and %subst(sidisp:7:1)  = '-'
JFFaAC                             and %subst(sidisp:4:3) >= '000'
JFFaAC                             and %subst(sidisp:4:3) <= '999'
JFFaAC                             and %subst(sidisp:8:2) >= '00'
JFFaAC                             and %subst(sidisp:8:2) <= '99'
JFFaAC                   eval      dashpos = -1
JFFaAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
JFFaA*
JFFaAC                   eval      loca  = %subst(sidisp:4:3)
JFFaAC                   move      loca          slloc
JFFaA*
JFFaAC                   eval      lvlaa   = %subst(sidisp:8:2)
JFFaAC                   move      lvlaa         slrlvl
JFFaAC                   eval      slhand  = ' ' + %subst(sidisp:10:1)
JFFaA
JFFaA
JFFaA*  Dashes specified. Double character aisle (Ex 62-84A1)
JFFaAC                   when          %subst(sidisp:3:1)  = '-'
JFFaAC                             and %subst(sidisp:4:2) >= '00'
JFFaAC                             and %subst(sidisp:4:2) <= '99'
JFFaAC                             and %subst(sidisp:7:1) >= '0'
JFFaAC                             and %subst(sidisp:7:1) <= '9'
JFFaAC                   eval      dashpos = -1
JFFaAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
JFFaA*
JFFaAC                   eval      loca  = '0' + %subst(sidisp:4:2)
JFFaAC                   move      loca          slloc
JFFaA*
JFFaA*      Convert alpha level into numeric value.
JFFaAC                   eval      lvla    = %subst(sidisp:6:1)
JFFaAC                   evalr     wkchar = %trimr(lvla)
JFFaAC                   exsr      zzcvt2nbr
JFFaAC                   if        nwchar > ' '
JFFaAC                   evalr     lvla   = %trimr(nwchar)
JFFaAC                   eval      slrlvl = %dec(nwchar:2:0)
JFFaAC                   else
JFFaAC                   evalr     lvla  = %subst(sidisp:6:1)
JFFaAC                   move      lvla          slrlvl
JFFaAC                   endif
JFFaAC                   eval      slhand  = ' ' + %subst(sidisp:7:1)
JFFaA
JFFaAC                   endsl
JFFaA
JFFaA*  Begin testing parts for ALL slots.
JFFaAC                   testn                   loca                 5050
JFFaAC                   if        *in50 = *off
JFFaAC                   eval      locnotnum = *on
JFFaA
JFFaAC                   else
JFFaAC                   select
JFFaAC                   when      slloc  = 0
JFFaAC**                 eval      slloc = slloc + 100
JFFaAC                   when      slloc < 0
JFFaAC                   eval      slloc = slloc * -1
JFFaAC                   endsl
JFFaAC                   endif
JFFaA
JFFaAC                   if        lvlaa > ' '
JFFaAC                   testn                   lvlaa                5050
JFFaAC                   else
JFFaA*
JFFaAC                   testn                   lvla                 50
JFfaAC                   endif
JFFaAC                   if        *in50 = *off
JFFaAC                   eval      lvlnotnum = *on
JFFaAC                   else
JFFaAC                   select
JFFaAC                   when      slrlvl = 0
JFFaAC*                  eval      slrlvl = slrlvl + 1
JFFaAC                   when      slrlvl < 0
JFFaAC                   eval      slrlvl = slrlvl * -1
JFFaAC                   endsl
JFFaAC                   endif
JFFaA
JFFaA*    Convert numeric handstack to alpha character.
JFFaA
JFFaAC                   if            slhand >= ' 0'
JFFaAC                             and slhand <= '99'
JFFaAC                   eval      wkchar = slhand
JFFaAC                   exsr      zzcvt2ltr
JFFaAC                   if        nwchar = ' '
JFFaAC                   eval      nwchar = slhand
JFFaAC                   endif
JFFaAC                   eval      slhand = nwchar
JFFaAC                   endif
JFFaA*
JFFaAC                   eval      slside = siprty
JFFaA
JFFaA*    See if slot meets criteria for allowing it to be created.
JFFaA
JFFaAC                   select
JFFaA
JFFaA*    If non-special slot doesn't have hypens, then don't add it.
JFFaA
JFFaAC                   when      dashpos = 0
JFFaAC                   eval      notcreated = *on
JFFaAC                   goto      endcreate5
JFFaA
JFFaA*    Don't allow creation if department is unknown.
JFFaA
JFFaAC                   when      validdept = '*NO '
JFFaAC                   eval      notcreated = *on
JFFaAC                   goto      endcreate5
JFFaA
JFFaA*    If location or level is not numeric, then don't add.
JFFaA
JFFaAC                   when      locnotnum or lvlnotnum
JFFaAC                   eval      notcreated = *on
JFFaAC                   goto      endcreate5
JFFaA
JFFaA*    Otherwise, slot is ok to be created.
JFFaA
JFFaAC                   other
JFFaAC                   eval      slwhdp = siwhdp
JFFaAC                   eval      sldisp = sidisp
JFFaAC                   eval      slstyp = sistyp
JFFaA
JFFaAC                   endsl
JFFaA
JFFaA*    Try and create the imported slot.
JFFaA
JFFaAC                   eval      slwhse = siwhse
JFFaAC                   eval      slpseq = sipseq
JFFaAC*
JFFaAC                   select
JFFaAC                   when      slpseq = 0
JFFaAC                   eval      slpseq = slloc
JFFaAC                   when      slpseq < 0
JFFaAC                   eval      slpseq = slpseq * -1
JFFaAC                   endsl
JFFaAC                   if        slitem > ' '
JFFaAC                   eval      slstat = 'A'
JFFaAC                   else
JFFaAC                   eval      slstat = 'V'
JFFaAC                   endif
JFFaA*
JFFaAC                   eval      slrsrv = sirsrv
JFFaA*
JFFaAC                   eval      slsdef = sisdef
JFFaA*
JFFaAC                   eval      slpick = sipick
JFFaA*
JFFaA
JFFaAC                   write (e) slrec
JFFaAC                   if        %error
JFFaAC                   eval      notcreated = *on
JFFaAC                   endif
JFFaA
JFFaAC     endcreate5    endsr
HAL A
HAL A*----------------------------------------------------------------
HAL A*  crtslot14  Try and create physical slot.
HAL A*----------------------------------------------------------------
HAL A
HAL AC     crtslot14     begsr
HAL AC                   eval      notcreated = *off
HAL A
HAL A*  Turn on SlotCreated flag even if slot isn't created
HAL A*  so ZZUPD routine doesn't get executed.
HAL AC                   eval      slotcreated= *on
HAL AC                   eval      handstack  = *off
HAL AC                   clear                   slrec
HAL A
HAL A*  Extract location and level. Test if they are numeric.
HAL A
HAL AC                   eval      locnotnum = *off
HAL AC                   eval      lvlnotnum = *off
HAL AC                   eval      dashpos = 0
HAL AC                   eval      loca  = ' '
HAL AC                   eval      lvla  = ' '
HAL A
HAL A*  Check for all alpha slot. If no digits, default slot location
HAL A*  will be assigned.
HAL AC                   If            %subst(sidisp:3:3) >= '000'
HAL AC                             and %subst(sidisp:3:3) <= '999'
HAL AC                             and %subst(sidisp:7:1) >= '0'
HAL AC                             and %subst(sidisp:7:1) <= '9'
HAL AC                   eval      allchrslot = *off
HAL AC                   else
HAL AC                   eval      allchrslot = *on
HAL AC                   endif
HAL A
HAL AC                   select
HAL A
HAL A*  Dash specified. Single character aisle
HAL AC                   when          %subst(sidisp:2:3) >= '000'
HAL AC                             and %subst(sidisp:2:3) <= '999'
HAL AC                             and %subst(sidisp:5:1) = '-'
HAL AC                   eval      dashpos = -1
HAL AC                   eval      slaisl = ' ' + %subst(sidisp:1:1)
HAL AC                   eval      loca  = %subst(sidisp:3:3)
HAL AC                   move      loca          slloc
HAL AC                   eval      lvla  = %subst(sidisp:6:1)
HAL AC                   move      lvla          slrlvl
HAL AC                   eval      slhand  = ' ' + %subst(sidisp:7:1)
HAL A
HAL A*  Dash specified. Double character aisle
HAL AC                   when          %subst(sidisp:3:3) >= '000'
HAL AC                             and %subst(sidisp:3:3) <= '999'
HAL AC                             and %subst(sidisp:6:1) = '-'
HAL AC                   eval      dashpos = -1
HAL AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
HAL AC                   eval      loca  = %subst(sidisp:3:3)
HAL AC                   move      loca          slloc
HAL AC                   eval      lvla  = %subst(sidisp:7:1)
HAL AC                   move      lvla          slrlvl
HAL AC                   eval      slhand  = ' ' + %subst(sidisp:8:1)
HAL A
HAL A*  No dashes specified. All character slot.
HAL AC                   when      allchrslot = *on
HAL AC
HAL AC                   eval      kydisp = sidisp
HAL AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
HAL AC
HAL AC                   eval      dftlocation = dftlocation + 1
HAL AC                   eval      loca   = %char(dftlocation)
HAL AC                   eval      slloc  = dftlocation
HAL AC
HAL AC                   eval      slrlvl = 1
HAL AC                   eval      lvla   = '1'
HAL AC
HAL AC                   eval      slhand  = '  '
HAL AC                   eval      dashpos = -1
HAL A
HAL AC                   endsl
HAL A
HAL A*  Begin testing parts for ALL slots.
HAL AC                   testn                   loca                 5050
HAL AC                   if        *in50 = *off
HAL AC                   eval      locnotnum = *on
HAL A
HAL AC                   else
HAL AC                   select
HAL AC                   when      slloc  = 0
HAL AC                   eval      slloc = slloc + 100
HAL AC                   when      slloc < 0
HAL AC                   eval      slloc = slloc * -1
HAL AC                   endsl
HAL AC                   endif
HAL A
HAL AC                   testn                   lvla                 50
HAL AC                   if        *in50 = *off
HAL AC                   eval      lvlnotnum = *on
HAL AC                   else
HAL AC                   select
HAL AC                   when      slrlvl = 0
HAL AC                   eval      slrlvl = slrlvl + 1
HAL AC                   when      slrlvl < 0
HAL AC                   eval      slrlvl = slrlvl * -1
HAL AC                   endsl
HAL AC                   endif
HAL A
HAL A*    Convert numeric handstack to alpha character.
HAL A
HAL AC                   if            slhand >= ' 0'
HAL AC                             and slhand <= '99'
HAL AC                   eval      wkchar = slhand
HAL AC                   exsr      zzcvt2ltr
HAL AC                   eval      slhand = nwchar
HAL AC                   endif
HAL A
HAL AC     slloc         div       2             dummy
HAL AC                   mvr                     oddeven
HAL AC                   if        oddeven <> 0
HAL AC                   eval      slside = 1
HAL AC                   else
HAL AC                   eval      slside = 0
HAL AC                   endif
HAL A
HAL A*    See if slot meets criteria for allowing it to be created.
HAL A
HAL AC                   select
HAL A
HAL A*    If non-special slot doesn't have hypens, then don't add it.
HAL A
HAL AC                   when      dashpos = 0
HAL AC                   eval      notcreated = *on
HAL AC                   goto      endcreate14
HAL A
HAL A*    Don't allow creation if department is unknown.
HAL A
HAL AC                   when      validdept = '*NO '
HAL AC                   eval      notcreated = *on
HAL AC                   goto      endcreate14
HAL A
HAL A*    If location or level is not numeric, then don't add.
HAL A
HAL AC                   when      locnotnum or lvlnotnum
HAL AC                   eval      notcreated = *on
HAL AC                   goto      endcreate14
HAL A
HAL A*    Otherwise, slot is ok to be created.
HAL A
HAL AC                   other
HAL AC                   eval      slwhdp = siwhdp
HAL AC                   eval      sldisp = sidisp
HAL AC                   eval      slstyp = sistyp
HAL A
HAL AC                   endsl
HAL A
HAL A*    Try and create the imported slot.
HAL A
HAL AC                   eval      slwhse = siwhse
HAL AC                   eval      slpseq = sipseq
HAL AC*
HAL AC                   select
HAL AC                   when      slpseq = 0
HAL AC                   eval      slpseq = slloc
HAL AC                   when      slpseq < 0
HAL AC                   eval      slpseq = slpseq * -1
HAL AC                   endsl
HAL AC                   if        slitem > ' '
HAL AC                   eval      slstat = 'A'
HAL AC                   else
HAL AC                   eval      slstat = 'V'
HAL AC                   endif
HAL A*
HAL AC                   eval      slrsrv = sirsrv
HAL AC                   if        sidgtp > ' '
HAL AC                   eval      slsdef = sidgtp
HAL AC                   else
HAL AC                   eval      slsdef = 'XX'
HAL AC                   endif
HAL AC                   eval      slpick = sipick
HAL A
HAL AC                   write (e) slrec
HAL AC                   if        %error
HAL AC                   eval      notcreated = *on
HAL AC                   endif
HAL A
HAL AC     endcreate14   endsr
     *
ADFaA
ADFaA*----------------------------------------------------------------
ADFaA*  crtslot33  Try and create physical slot. 5B107-3
ADFaA*----------------------------------------------------------------
ADFaA
ADFaAC     crtslot33     begsr
ADFaAC                   eval      notcreated = *off
ADFaA
ADFaA*  Turn on SlotCreated flag even if slot isn't created
ADFaA*  so ZZUPD routine doesn't get executed.
ADFaAC                   eval      slotcreated= *on
ADFaAC                   eval      handstack  = *off
ADFaAC                   clear                   slrec
ADFaA
ADFaA*  Extract location and level. Test if they are numeric.
ADFaA
ADFaAC                   eval      locnotnum = *off
ADFaAC                   eval      lvlnotnum = *off
ADFaAC                   eval      dashpos = 0
ADFaAC                   eval      loca  = ' '
ADFaAC                   eval      lvla  = ' '
ADFaA
ADFaA*  Check for all alpha slot. If no digits, default slot location
ADFaA*  will be assigned.
ADFaAC                   If            %subst(sidisp:3:3) >= '000'
ADFaAC                             and %subst(sidisp:3:3) <= '999'
ADFaAC                             and %subst(sidisp:6:1)  = '-'
ADFaAC                   eval      allchrslot = *off
ADFaAC                   else
ADFaAC                   eval      allchrslot = *on
ADFaAC                   endif
ADFaA
ADFaAC                   select
ADFaA
ADFaA*  No dashes specified. All character slot.
ADFaAC                   when      allchrslot = *on
ADFaAC
ADFaAC                   eval      kydisp = sidisp
ADFaAC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
ADFaAC
ADFaAC                   eval      dftlocation = dftlocation + 1
ADFaAC                   eval      loca   = %char(dftlocation)
ADFaAC                   eval      slloc  = dftlocation
ADFaAC
ADFaAC                   eval      slrlvl = 1
ADFaAC                   eval      lvla   = '1'
ADFaAC
ADFaAC                   eval      slhand  = '  '
ADFaAC                   eval      dashpos = -1
ADFaA
ADFaA*  Dashes specified. Double character aisle (Ex 5B107-3)
ADFaAC                   when          %subst(sidisp:6:1) = '-'
ADFaAC                             and %subst(sidisp:3:3) >= '000'
ADFaAC                             and %subst(sidisp:3:3) <= '999'
ADFaAC                             and %subst(sidisp:7:1) >= '0'
ADFaAC                             and %subst(sidisp:7:1) <= '9'
ADFaAC                   eval      dashpos = -1
ADFaAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
ADFaAC                   eval      loca  = %subst(sidisp:3:3)
ADFaAC                   move      loca          slloc
ADFaA*
ADFaAC                   evalr     lvla  = %subst(sidisp:7:1)
ADFaAC                   move      lvla          slrlvl
ADFaAC                   eval      slhand  = ' ' + %subst(sidisp:8:1)
ADFaA
ADFaAC                   endsl
ADFaA
ADFaA*  Begin testing parts for ALL slots.
ADFaAC                   testn                   loca                 5050
ADFaAC                   if        *in50 = *off
ADFaAC                   eval      locnotnum = *on
ADFaA
ADFaAC                   else
ADFaAC                   select
ADFaAC                   when      slloc  = 0
ADFaAC                   eval      slloc = slloc + 100
ADFaAC                   when      slloc < 0
ADFaAC                   eval      slloc = slloc * -1
ADFaAC                   endsl
ADFaAC                   endif
ADFaA
ADFaAC                   testn                   lvla                 50
ADFaAC                   if        *in50 = *off
ADFaAC                   eval      lvlnotnum = *on
ADFaAC                   else
ADFaAC                   select
ADFaAC                   when      slrlvl = 0
ADFaAC                   eval      slrlvl = slrlvl + 1
ADFaAC                   when      slrlvl < 0
ADFaAC                   eval      slrlvl = slrlvl * -1
ADFaAC                   endsl
ADFaAC                   endif
ADFaA
ADFaA*    Convert numeric handstack to alpha character.
ADFaA
ADFaAC                   if            slhand >= ' 0'
ADFaAC                             and slhand <= '99'
ADFaAC                   eval      wkchar = slhand
ADFaAC                   exsr      zzcvt2ltr
ADFaAC                   eval      slhand = nwchar
ADFaAC                   endif
ADFaA
ADFaAC     slloc         div       2             dummy
ADFaAC                   mvr                     oddeven
ADFaAC                   if        oddeven <> 0
ADFaAC                   eval      slside = 1
ADFaAC                   else
ADFaAC                   eval      slside = 0
ADFaAC                   endif
ADFaA
ADFaA*    See if slot meets criteria for allowing it to be created.
ADFaA
ADFaAC                   select
ADFaA
ADFaA*    If non-special slot doesn't have hypens, then don't add it.
ADFaA
ADFaAC                   when      dashpos = 0
ADFaAC                   eval      notcreated = *on
ADFaAC                   goto      endcreate33
ADFaA
ADFaA*    Don't allow creation if department is unknown.
ADFaA
ADFaAC                   when      validdept = '*NO '
ADFaAC                   eval      notcreated = *on
ADFaAC                   goto      endcreate33
ADFaA
ADFaA*    If location or level is not numeric, then don't add.
ADFaA
ADFaAC                   when      locnotnum or lvlnotnum
ADFaAC                   eval      notcreated = *on
ADFaAC                   goto      endcreate33
ADFaA
ADFaA*    Otherwise, slot is ok to be created.
ADFaA
ADFaAC                   other
ADFaAC                   eval      slwhdp = siwhdp
ADFaAC                   eval      sldisp = sidisp
ADFaAC                   eval      slstyp = sistyp
ADFaA
ADFaAC                   endsl
ADFaA
ADFaA*    Try and create the imported slot.
ADFaA
ADFaAC                   eval      slwhse = siwhse
ADFaAC                   eval      slpseq = sipseq
ADFaAC*
ADFaAC                   select
ADFaAC                   when      slpseq = 0
ADFaAC                   eval      slpseq = slloc
ADFaAC                   when      slpseq < 0
ADFaAC                   eval      slpseq = slpseq * -1
ADFaAC                   endsl
ADFaAC                   if        slitem > ' '
ADFaAC                   eval      slstat = 'A'
ADFaAC                   else
ADFaAC                   eval      slstat = 'V'
ADFaAC                   endif
ADFaA*
ADFaAC                   eval      slrsrv = sirsrv
ADFaAC                   eval      slsdef = sisdef
ADFaAC                   eval      slpick = sipick
ADFaA
ADFaAC                   write (e) slrec
ADFaAC                   if        %error
ADFaAC                   eval      notcreated = *on
ADFaAC                   endif
ADFaA
ADFaAC     endcreate33   endsr
ADFa

     *----------------------------------------------------------------
     *  zzcvt2ltr   Convert numeric handstack to alpha character.
     *----------------------------------------------------------------

     C     zzcvt2ltr     begsr

     C                   eval      nwchar = '  '

     C                   select
     C                   when         wkchar = ' 0'
     C                             or wkchar = '  '
     C                   eval      nwchar = ' A'
     C
     C                   when      wkchar = ' 1'
     C                   eval      nwchar = ' B'
     C
     C                   when      wkchar = ' 2'
     C                   eval      nwchar = ' C'
     C
     C                   when      wkchar = ' 3'
     C                   eval      nwchar = ' D'
     C
     C                   when      wkchar = ' 4'
     C                   eval      nwchar = ' E'
     C
     C                   when      wkchar = ' 5'
     C                   eval      nwchar = ' F'
     C
     C                   when      wkchar = ' 6'
     C                   eval      nwchar = ' G'
     C
     C                   when      wkchar = ' 7'
     C                   eval      nwchar = ' H'
     C
     C                   when      wkchar = ' 8'
     C                   eval      nwchar = ' I'
     C
     C                   when      wkchar = ' 9'
     C                   eval      nwchar = ' J'
     C
     C                   endsl

     C     endcvt2ltr    endsr
     *
     *----------------------------------------------------------------
     *  zzcvt2nbr   Convert alpha character to numeric character.
     *----------------------------------------------------------------

     C     zzcvt2nbr     begsr

     C                   eval      nwchar = '  '

     C                   select
     C                   when         wkchar = ' A'
     C                             or wkchar = '  '
     C                   eval      nwchar = '01'
     C
     C                   when      wkchar = ' B'
     C                   eval      nwchar = '02'
     C
     C                   when      wkchar = ' C'
     C                   eval      nwchar = '03'
     C
     C                   when      wkchar = ' D'
     C                   eval      nwchar = '04'
     C
     C                   when      wkchar = ' E'
     C                   eval      nwchar = '05'
     C
     C                   when      wkchar = ' F'
     C                   eval      nwchar = '06'
     C
     C                   when      wkchar = ' G'
     C                   eval      nwchar = '07'
     C
     C                   when      wkchar = ' H'
     C                   eval      nwchar = '08'
     C
     C                   when      wkchar = ' I'
     C                   eval      nwchar = '09'
     C
     C                   when      wkchar = ' J'
     C                   eval      nwchar = '10'
     C
     C                   when      wkchar = ' K'
     C                   eval      nwchar = '11'
     C
     C                   when      wkchar = ' L'
     C                   eval      nwchar = '12'
     C
     C                   when      wkchar = ' M'
     C                   eval      nwchar = '13'
     C
     C                   when      wkchar = ' N'
     C                   eval      nwchar = '14'
     C
     C                   when      wkchar = ' O'
     C                   eval      nwchar = '15'
     C
     C                   when      wkchar = ' P'
     C                   eval      nwchar = '16'
     C
     C                   when      wkchar = ' Q'
     C                   eval      nwchar = '17'
     C
     C                   when      wkchar = ' R'
     C                   eval      nwchar = '18'
     C
     C                   when      wkchar = ' S'
     C                   eval      nwchar = '19'
     C
     C                   when      wkchar = ' T'
     C                   eval      nwchar = '20'
     C
     C                   when      wkchar = ' U'
     C                   eval      nwchar = '21'
     C
     C                   when      wkchar = ' V'
     C                   eval      nwchar = '22'
     C
     C                   when      wkchar = ' W'
     C                   eval      nwchar = '23'
     C
     C                   when      wkchar = ' X'
     C                   eval      nwchar = '24'
     C
     C                   when      wkchar = ' Y'
     C                   eval      nwchar = '25'
     C
     C                   when      wkchar = ' Z'
     C                   eval      nwchar = '26'
     C
     C                   endsl

     C     endcvt2nbr    endsr

610bA*----------------------------------------------------------------
610bA*----------------------------------------------------------------
610bA*                     DRI SUBROUTINES
610bA*----------------------------------------------------------------
610bA*----------------------------------------------------------------

610bA*----------------------------------------------------------------
610bA*  clr$item  Clear $item data structure fields
610bA*----------------------------------------------------------------
610bA
610bAC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

610cA*----------------------------------------------------------------
610cA*  clr$license  Clear $license data structure fields
610cA*----------------------------------------------------------------
610cA
610cAC     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liemp# = $emp#
     C                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   endsr

610bA*----------------------------------------------------------------
610bA*  clr$slot  Clear $slot data structure fields
610bA*----------------------------------------------------------------
610bA
610bAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = $emp#
     C                   endsr

610bA*----------------------------------------------------------------
610bA*  zzzdricop  Call DRICOP
610bA*----------------------------------------------------------------
610bA
610bAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
610cAC                   when      $dricommand = '*LICENSE'
610cAC                   eval      $dridata = $license
610cAC                   eval      $dridata2 = $license2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*LICENSE'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      %error and ck4err = *on
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #pgm
     C*                  select
     C*                  when      zmsflag
     C*                  exsr      zm0105s
     C*                  when      zmflag
     C*                  exsr      zm0105
     C*                  endsl

     C                   when      $drireturn <> '*OK' and ck4err = *on
     C                   eval      error = *on
     C*                  select
     C*                  when      zmsflag
     C*                  exsr      zm0001s
     C*                  when      zmflag
     C*                  exsr      zm0001
     C*                  exsr      zzerrind
     C*                  endsl

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
610cAC                   when      $dricommand = '*LICENSE'
610cAC                   eval      $license = $dridata
610cAC                   eval      $license2 = $dridata2
     C                   endsl

     C*                  eval      zmflag = *off
     C*                  eval      zmsflag = *off
     C                   eval      ck4err = *off
     C     enddricop     endsr
     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**
*INVALID SLOT*
*INVALID ITEM*
*BREAKDOWN INVALID*
*INVALID ITEM TYPE*
*CAN'T CREATE VS/1*
*SLOT NOT UPDATED*
*CAN'T CREATE VS/2*
*CAN'T CREATE VS/3*
*INVALID FIFO DATE*
*DEPT/SECT MISMATCH*
*NO SLOT SENT*
*CK DIGIT NOT UPD*
*LICENSE NOT UPD*
*INVALID RCVD DATE*
*NO ITEM SENT*
**
FTP StuffIt Import 4
**
 ABCDEFGHIJKLMNOPQRSTUVWXYZ
