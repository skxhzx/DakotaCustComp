     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  SI295     FTP StuffIt Import 5 - Post
     *  11 August 2011
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  NOTES:
     *      - Must compile at V5R4 or greater
     *      - Pgm is copy of SI285 08/11/11 thru mod 6.10e.
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    08/11/11  MLB  6.40
     *      - Created
     *      - Includes client custom code support.
640aA*    08/17/11  MLB  6.40a
     *      - Fix: Revised routine ZZCKDGT to turn off error flag.
     *        Error flag was being turned on in custom license processing
     *        and was causing the check digits to not be updated.
640bA*    08/17/11  MLB  6.40b
     *      - Fix: Revised routine ZZZDRICOP to add support for *LICINFO.
     *        Needed for updating data to LICINFO file.
     *
650 A*    03/08/13  MLB  6.50
     *      - Fix: Revised pgm to set Action parm to SI from FIX
     *        on call to LT001.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval Foods
     *
SVLaA*    02/03/09  MLB  SVLa
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
SVLbA*    03/10/09  MLB  SVLb
     *      - Createed new routine, CRTSLOT1 to proces Saval slots,
SVLcA*    08/11/09  MLB  SVLc
     *      - *Temp Mod* Chg'd pgm to allow "Dept Mis-Match" error to
     *         be ignored for items in dept 3.
SVLdA*    08/11/09  MLB  SVLd
     *      - Enh: Revised program to load dept 3 when SIWHDP=2 and
     *        1st character of SIDISP=C.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: European Imports
     *
EI  A*    01/25/06  MLB  EI
     *      - Revised program to add new routine CRTSLOT2 to create
     *        slots based on European Import's format.
EI1 A*    02/06/06  MLB  EI1
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
EI6 A*    08/03/11  MLB  EI6
     *      - Revised program to call routine ZZRCAL before exiting
     *        the program to recalc warehouse qty.
EI7 A*    08/15/11  MLB  EI7  P#01048
     *      - Revised program to create p/o history header record to
     *        link to license plate lot code info written into LICINFO
     *        file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cash WA Distribution
     *
CWD A*    10/29/08  MLB  CWD
     *      - Revised program to create slots based on Cash WA format.
CWDaA*    12/06/08  MLB  CWDa
     *      - Revised program to add support to map slots sent to TB
     *        with dashes in the slot format.
CWDbA*    01/26/09  MLB  CWDb
     *      - Revised program to correct problems with how slots with
     *        handstack characters are created. Changed them to be
     *        created as permanent slots, not virtual slots.
     *      - Revised program to add support for creating slots with
     *        rack levels greater than 9.
CWDcA*    03/30/09  MLB  CWDc
     *      - Revised CRTSLOT13 to check LOCA and LVLA fields to ensure
     *        that they contain numeric values before moving them into
     *        SLLOC and SLRLVL.
CWDdA*    03/30/09  MLB  CWDd
     *      - Enhanced CWDb mod for dealing with double digit levels.
CWDeA*    12/10/09  MLB  CWDe
     *      - Enhanced CWDb mod for dealing with slots that do not have
     *        numeric location or rack levels.
     *      - Note: Changed CWD's routine to CRTSLOT13 from CRTSLOT9
     *              in order to add CWD's mods.
CWDfA*    05/05/10  MLB  CWDf
     *      - Revised program to correctly map slots with single
     *        character aisles.  For ex: E-200-2.
CWDgA*    12/20/11  MLB  CWDg
     *      - Revised routine ZZBKDN to set Good1 = Y so that check
     *        digits can be updated for the pick slots.
CWDhA*    04/22/13  MLB  CWDh
     *      - Revised program to create virtual slots when an item has
     *        2 or more license plates for the same overflow slot.
     *      - Added CWDh to EI3 mod.
CWDiA*    04/22/13  MLB  CWDi
     *      - Revised program to update the slot qty for pick slots
     *        instead of replacing the existing qty.
     *      - Added CWDi to EI4 mod.
CWDjA*    04/23/13  MLB  CWDj
     *      - Revised program to no longer run LT001 when importing
     *        slots to Dakota.
     *      - Revised program to no longer update slot check digits.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Sunrise Foods
     *
SUNa *    08/18/20  RTR  SUNa
     *      - Added Sunrise Foods to use CRTSLOTSUN.
     *      - Sample slot: AA-015-1A
     *              where: AA=Aisle, 015=Location and 1=Rack level.
     *      - Sample slot: P-015-1B
     *              where: P=Aisle, 015=Location and 1=Rack level.
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

     Fimpfstuf5 if   e           k disk
     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
     Foptiond   if   e           k disk
     Fslotdgt   uf a e           k disk
     Fslot2     uf a e           k disk
     Fvslot2    uf a e           k disk
EI7 AFpohhdr    uf a e           k disk    usropn
EI7 AFlicinfo   uf a e           k disk    usropn
     Fsi295pr   o    e             printer oflind(*in91)

     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------

SVL AD/copy qcopysrc,id#saval
EI  AD/copy qcopysrc,id#ei
CWD AD/copy qcopysrc,id#cashwa
SUNaAd/copy qcopysrc,id#sun

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
EI7 A /COPY *libl/qcopysrc,C#LICINFO
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
     D desc            s             20    dim(14) ctdata perrcd(1)
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
     D ck4err          s              1
     D crtbaseslot     s              1    inz('0')
     D count           s              3  0
     D dftlocation     s              3  0 inz(600)
     D digits          c                   const('0123456789')
     D dummy           s                   like(slloc)
     D errmsg          s             50
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
     D temp10a         s             10

     D dashpos         s              2  0
     D loca            s              3
     D lvla            s              1
CWDcAD lvlaa           s              2
     D locnotnum       s               n
     D lvlnotnum       s               n
     D notcreated      s               n
     D slotcreated     s               n

     *----------------------------------------------------------------
     *  Date fields
     *----------------------------------------------------------------

     D datefld         s               d

     D                 ds
     D  fifodate               1      8  0 inz(0)
     D  fifoyear               1      4  0 inz(0)
     D  fifomonth              5      6  0 inz(0)
     D  fifoday                7      8  0 inz(0)
     D                 ds
     D  rcvdate                1      8  0 inz(0)
     D  rcvdyear               1      4  0 inz(0)
     D  rcvdmonth              5      6  0 inz(0)
     D  rcvdday                7      8  0 inz(0)

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

      /COPY *libl/qcopysrc,C#PGMINFDS

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

     *    Get User's employee number to be written to PORCV file
     *    if any records are flagged as touched.

     C                   call      'GETUSER'
     C                   parm      #curruser     $code            10
     C                   parm      0             $whse             3 0
     C                   parm      0             $emp#             5 0
     C                   parm      *blanks       $fnam            15
     C                   parm      *blanks       $init             1
     C                   parm      *blanks       $lnam            20
     C                   parm      *blanks       $whdp             5
     C                   parm      *blanks       $styp             1
     C                   parm      *blanks       $shft             6
     C                   parm      *blanks       $crew             6
     C                   parm      0             $nhrs             3 1
     C                   parm      *blanks       $rtn              8

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
     *
     C                   dow       forevr = forevr
     *
     C                   read      impfstuf5
     C                   if        %eof(impfstuf5)
     C                   leave
     C                   endif
     *
     C                   add       1             grdlin
SVLdA*
SVLdAC                   if        client = Savalfoods
SVLdA
SVLdAC                   select
SVLdA*  Force combined dept 2 to be split into 2=Dry, 3=Clr.
SVLdAC                   when      siwhdp = '2    '
SVLdAC                             and %subst(sidisp:1:1) = 'C'
SVLdAC                   eval      siwhdp = '3    '
SVLdAC                   endsl
SVLdAC
SVLdAC                   endif
     *
     *  Create warehouse heading if necessary.
     *
     C                   if        lstwhs <> siwhse
     *
     C                   if        lstwhs > 0
     C                   exsr      zzrcal
     C                   endif
     *
     C                   eval      whcode = siwhse
     C     whcode        chain     warehs
     C                   if        not %found(warehs)
     C                   eval      whdesc = *blanks
     C                   endif
     *
     C                   move      siwhse        work3a
     C     ' 0'          check     work3a        pos
     C                   if        pos = 0
     C                   eval      pos = 1
     C                   endif
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
EI  A*
CWD AC                   when      client = Cashwa
CWD A*
CWD AC                   if        siwhdp <> svwhdp
CWD AC                   eval      dftlocation = 600
CWD AC                   eval      svwhdp      = siwhdp
CWD AC                   endif
CWD A*
CWD AC                   exsr      crtslot13
CWD A*
     C                   Other

     C                   exsr      crtslot
     C                   endsl

     C                   if        notcreated
     C                   eval      detmsg = desc(1)
     C                   add       1             noslot
     C                   goto      prndtl
     C                   endif
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
     C**                           or itstyp <> sistyp
     C                   eval      detmsg = desc(10)
     C                   move      itwhdp        detmsg
     C                   add       1             baddpt
SVLcAC                   if        client = Savalfoods
SVLcAC                             and siwhdp = '3'
SVLcA*          Ignore dept mis-match for Dept 3 slots.
SVLcAC                   else
SVLcA*
SVLcAC                   goto      prndtl
SVLcAC                   endif
     C                   endif
     C                   endif
     *
     *  If invalid mmddyy FIFO date write error message.
     *
     C                   if        sififo > 0
     C                   move      sififo        temp10a
650aAC                   eval      temp10a = %subst(temp10a:3:4)
650aAC                                       + '-'
650aAC                                       + %subst(temp10a:7:2)
650aAC                                       + '-'
650aAC                                       + %subst(temp10a:9:2)
     C     *iso          test(de)                temp10a
     C                   if        %error
     C                   eval      detmsg = desc(9)
     C                   add       1             baddte
     C                   goto      prndtl
     C                   endif
     C     *iso          move      temp10a       datefld
     C                   extrct    datefld:*y    fifoyear
     C                   extrct    datefld:*m    fifomonth
     C                   extrct    datefld:*d    fifoday
     C                   endif
     *
     *  If invalid yyyymmdd RcvD date, write error message.
     *
     C                   if        sircvd > 0
     C                   move      sircvd        temp10a
650aAC                   eval      temp10a = %subst(temp10a:3:4)
650aAC                                       + '-'
650aAC                                       + %subst(temp10a:7:2)
650aAC                                       + '-'
650aAC                                       + %subst(temp10a:9:2)
     C     *iso          test(de)                temp10a
     C                   if        %error
     C                   eval      detmsg = desc(14)
     C                   add       1             baddte
     C                   goto      prndtl
     C                   endif
     *
     C     *iso          move      temp10a       datefld
     C                   extrct    datefld:*y    rcvdyear
     C                   extrct    datefld:*m    rcvdmonth
     C                   extrct    datefld:*d    rcvdday
     C                   endif
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
CWDjAC                             and client <> Cashwa
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
CWD AC                             or client = Cashwa
EI6 AC                   exsr      zzrcal
EI6 AC                   endif
EI6 A*
     C                   endif

     *  Synchronize license qtys with slot qtys
     *    This will make sure the LP's match the slot qty for every slot.
     *    This is done to clean up an problems, such as duplicate
     *    LP's being sent.

CWDjAC                   if        client = Cashwa
SUNaAc                             or client = Sunrise
CWDjA*      Cashwa is full system. Can't run LT001 for entire whse.
CWDjA*      Causes unpredictable results when run with normal sys ops.
CWDjAC                   else
CWDjA*
     C                   call(e)   'LT001'
650 DC*                  parm      'FIX'         lpAction          3
650 MC                   parm      'SI '         lpAction          3
     C                   parm      siwhse        lpWhse            3 0
     C                   parm      ' '           lpWhdp            5
     C                   parm      ' '           lpDisp           12
     C                   parm      ' '           lpDummy           1
CWDjA*
CWDjAC                   endif
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
EI7 AC                   if        client = EI
SUNaAc                             or client = Sunrise
EI7 AC
EI7 AC                   if        not %open(pohhdr)
EI7 AC                   open      pohhdr
EI7 AC                   endif
EI7 AC
EI7 AC                   if        not %open(licinfo)
EI7 AC                   open      licinfo
EI7 AC                   endif
EI7 AC
EI7 AC                   endif
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
EI7 A*
EI7 A*  POHHDR file
EI7 A*
EI7 AC     keyphh        klist
EI7 AC                   kfld                    siwhse
EI7 AC                   kfld                    sipo
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

     C                   exsr      clr$slot

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse = siwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp = siwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp = sidisp

     C                   eval      drislot = *on
     C                   call(e)   'DRISLOT'
     C                   parm      '%GET      '  $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $slot         parm      $slot         $dridata
     C     $slot2        parm      $slot2        $dridata2

     C     endgetslot    endsr

     *----------------------------------------------------------------
     *
     *  ZZBKDN  Check breakdown quanties.
     *
     C     zzbkdn        begsr
     *
     C                   if        siqty1 = 0  and
     C                             siqty2 = 0  and
     C                             siqty3 = 0
530 AC                             and siitem > ' '
CWDgAC                             or  client = Cashwa
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
640aA*
640aAC                   eval      error = '0'
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
     C                   eval      detmsg = ' '
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
CWDhAC                             or client = Cashwa
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
     C                   if        sircvd > 0
     C                   eval      slentd = rcvdate
     C                   else
     C                   eval      slentd = impdte
     C                   endif
     C
     C                   if        itflgd = 'Y'
     C                   if        sififo > 0
     C                   eval      slexpd = fifodate
     C                   else
     C                   eval      slexpd = 0
     C                   endif
     C                   else
     C                   eval      slexpd = 0
     C                   endif
     C
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
     C                   else
     C                   exsr      zzupdlcns
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
CWDhAC                             or client = Cashwa
SUNaAc                             or client = Sunrise
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
     C                   if        sircvd > 0
     C                   eval      slentd = rcvdate
     C                   else
     C                   eval      slentd = impdte
     C                   endif
     C                   else
     C                   eval      slentd = 0
     C                   endif
     C
     C                   if        itflgd = 'Y'
     C                   if        sififo > 0
     C                   eval      slexpd = fifodate
     C                   else
     C                   eval      slexpd = 0
     C                   endif
     C                   else
     C                   eval      slexpd = 0
     C                   endif
     C
     C
     C                   eval      slsdte = impdte
     C                   eval      slstim = imptim
     *
     C                   update    slrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      detmsg = desc(6)
     C                   add       1             notupd
     C                   else
     C                   exsr      zzupdlcns
     C                   endif
     C                   add       1             sltupd
     C                   endif
     C                   endif
     *
     C     endupd        endsr

     *----------------------------------------------------------------
     *  ZZUPDLCNS   Update license
     *----------------------------------------------------------------
     C     zzupdlcns     begsr

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
SUNaAc                             or client = Sunrise
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
SUNaAc                             or client = Sunrise
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
EI7 A*
EI7 AC                   else
EI7 A*
EI7 AC                   if        client = EI
SUNaAc                             or client = Sunrise
EI7 A*      Create Lot Code records for imported licenses.
EI7 AC                   exsr      zzlotcode
EI7 AC                   endif
EI7 a*
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
EI  AC                   endif                                                  End - Baseslot=on
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
CWD A*
CWD A*----------------------------------------------------------------
CWD A*  crtslot13  Try and create physical slot.
CWD A*----------------------------------------------------------------
CWD A
CWD AC     crtslot13     begsr
CWD AC                   eval      notcreated = *off
CWD A
CWD A*  Turn on SlotCreated flag even if slot isn't created
CWD A*  so ZZUPD routine doesn't get executed.
CWD AC                   eval      slotcreated= *on
CWD AC                   eval      handstack  = *off
CWD AC                   clear                   slrec
CWD A
CWD A*  Extract location and level. Test if they are numeric.
CWD A
CWD AC                   eval      locnotnum = *off
CWD AC                   eval      lvlnotnum = *off
CWD AC                   eval      dashpos = 0
CWD AC                   eval      loca  = ' '
CWD AC                   eval      lvla  = ' '
CWDbAC                   eval      lvlaa = '  '
CWD A
CWD A*  Check for all alpha slot. If no digits, default slot location
CWD A*  will be assigned.
CWD AC                   If            %subst(sidisp:2:3) >= '000'
CWD AC                             and %subst(sidisp:2:3) <= '999'
CWDeAC                             and %subst(sidisp:6:1)  = ' '
CWD AC                             or  %subst(sidisp:3:3) >= '000'
CWD AC                             and %subst(sidisp:3:3) <= '999'
CWDeAC                             and %subst(sidisp:7:1)  = ' '
CWDaAC                             or  %subst(sidisp:4:3) >= '000'
CWDaAC                             and %subst(sidisp:4:3) <= '999'
CWDfAC                             or  %subst(sidisp:2:1)  = '-'
CWDfAC                             and %subst(sidisp:3:3) >= '000'
CWDfAC                             and %subst(sidisp:3:3) <= '999'
CWD AC                   eval      allchrslot = *off
CWD AC                   else
CWD AC                   eval      allchrslot = *on
CWD AC                   endif
CWD A
CWD AC                   select
CWD A
CWD A*  No Dashes specified. Single character aisle
CWD AC                   when          %subst(sidisp:2:3) >= '000'
CWD AC                             and %subst(sidisp:2:3) <= '999'
CWDaAC                             and %subst(sidisp:6:1)  = ' '
CWD AC                   eval      dashpos = -1
CWDaMC                   eval      slaisl = '  ' + %subst(sidisp:1:1)
CWD AC                   eval      loca  = %subst(sidisp:2:3)
CWDcAC                   testn                   loca                 5050
CWDcAC                   if        *in50 = *on
CWD AC                   move      loca          slloc
CWDcAC                   endif
CWD AC                   eval      lvla  = %subst(sidisp:5:1)
CWDeA*
CWDeAC                   if        lvla >= 'A' and lvla <= 'Z'
CWDeAC                   evalr     wkchar = %trimr(lvla)
CWDeAC                   exsr      zzcvt2nbr
CWDeAC                   evalr     lvla   = %trimr(nwchar)
CWDeAC                   endif
CWDeA*
CWDcAC                   testn                   lvla                 50
CWDcAC                   if        *in50 = *on
CWD AC                   move      lvla          slrlvl
CWDcAC                   endif
CWD AC                   eval      slhand  = ' ' + %subst(sidisp:6:1)
CWD AC                   if        slhand > ' '
CWDbDC**                 eval      handstack = *on
CWD AC                   endif
CWD A
CWD A*  No Dashes specified. Double character aisle
CWD AC                   when          %subst(sidisp:3:3) >= '000'
CWD AC                             and %subst(sidisp:3:3) <= '999'
CWDaAC                             and %subst(sidisp:7:1)  = ' '
CWD AC                   eval      dashpos = -1
CWD AC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
CWD AC                   eval      loca  = %subst(sidisp:3:3)
CWDcAC                   testn                   loca                 5050
CWDcAC                   if        *in50 = *on
CWD AC                   move      loca          slloc
CWDcAC                   endif
CWD AC                   eval      lvla  = %subst(sidisp:6:1)
CWDeA*
CWDeAC                   if        lvla >= 'A' and lvla <= 'Z'
CWDeAC                   evalr     wkchar = %trimr(lvla)
CWDeAC                   exsr      zzcvt2nbr
CWDeAC                   evalr     lvla   = %trimr(nwchar)
CWDeAC                   endif
CWDeA*
CWDcAC                   testn                   lvla                 50
CWDcAC                   if        *in50 = *on
CWD AC                   move      lvla          slrlvl
CWDcAC                   endif
CWD AC                   eval      slhand  = ' ' + %subst(sidisp:7:1)
CWD AC                   if        slhand > ' '
CWDbDC**                 eval      handstack = *on
CWD AC                   endif
CWDaA
CWDaA*  Dashes specified. Single character aisle
CWDaAC                   when      %subst(sidisp:2:1) = '-'
CWDaAC                             and %subst(sidisp:6:1) = '-'
CWDeAC                             and allchrslot = '0'
CWDaAC                   eval      dashpos = 2
CWDaAC                   eval      slaisl = '  ' + %subst(sidisp:1:1)
CWDaAC                   eval      loca  = %subst(sidisp:3:3)
CWDcAC                   testn                   loca                 5050
CWDcAC                   if        *in50 = *on
CWDaAC                   move      loca          slloc
CWDcAC                   endif
CWDaAC                   eval      lvla  = %subst(sidisp:7:1)
CWDeA*
CWDeAC                   if        lvla >= 'A' and lvla <= 'Z'
CWDeAC                   evalr     wkchar = %trimr(lvla)
CWDeAC                   exsr      zzcvt2nbr
CWDeAC                   evalr     lvla   = %trimr(nwchar)
CWDeAC                   endif
CWDeA*
CWDcAC                   testn                   lvla                 50
CWDcAC                   if        *in50 = *on
CWDaAC                   move      lvla          slrlvl
CWDcAC                   endif
CWDaAC                   eval      slhand  = ' ' + %subst(sidisp:8:1)
CWDaAC                   if        slhand > ' '
CWDbDC*                  eval      handstack = *on
CWDaAC                   endif
CWDaA
CWDaA*  Dashes specified. Double character aisle
CWDaAC                   when      %subst(sidisp:3:1) = '-'
CWDaAC                             and %subst(sidisp:7:1) = '-'
CWDeAC                             and allchrslot = '0'
CWDaAC                   eval      dashpos = 3
CWDaAC                   eval      slaisl = ' ' + %subst(sidisp:1:2)
CWDaAC                   eval      loca  = %subst(sidisp:4:3)
CWDcAC                   testn                   loca                 5050
CWDcAC                   if        *in50 = *on
CWDaAC                   move      loca          slloc
CWDcAC                   endif
CWDdAC                   if            %subst(sidisp:8:1) >= '0'
CWDdAC                             and %subst(sidisp:8:1) <= '9'
CWDdAC                             and %subst(sidisp:9:1) >= '0'
CWDdAC                             and %subst(sidisp:9:1) <= '9'
CWDdAC                   eval      lvlaa = %subst(sidisp:8:2)
CWDcAC                   testn                   lvlaa                5050
CWDcAC                   if        *in50 = *on
CWDaAC                   move      lvlaa         slrlvl
CWDcAC                   endif
CWDdAC                   eval      slhand  = ' ' + %subst(sidisp:10:1)
CWDdAC                   else
CWDaAC                   eval      lvla  = %subst(sidisp:8:1)
CWDeA*
CWDeAC                   if        lvla >= 'A' and lvla <= 'Z'
CWDeAC                   evalr     wkchar = %trimr(lvla)
CWDeAC                   exsr      zzcvt2nbr
CWDeAC                   evalr     lvla   = %trimr(nwchar)
CWDeAC                   endif
CWDeA*
CWDcAC                   testn                   lvla                 50
CWDcAC                   if        *in50 = *on
CWDaAC                   move      lvla          slrlvl
CWDcAC                   endif
CWDdAC                   eval      slhand  = ' ' + %subst(sidisp:9:1)
CWDdAC                   endif
CWDdDC*                  eval      slhand  = ' ' + %subst(sidisp:9:1)
CWDaAC                   if        slhand > ' '
CWDbDC**                 eval      handstack = *on
CWDaAC                   endif
CWD A
CWD A*  No dashes specified. All character slot.
CWD AC                   when      allchrslot = *on
CWD AC
CWD AC                   eval      kydisp = sidisp
CWD AC                   evalr     slaisl = %trimr(%subst(sidisp:1:2))
CWD AC
CWD AC                   eval      dftlocation = dftlocation + 1
CWD AC                   eval      loca   = %char(dftlocation)
CWD AC                   eval      slloc  = dftlocation
CWD AC
CWDeAC                   select
CWDeA*        Single digit level defined with no handstack defined.
CWDeAC                   when          %subst(sidisp:8:1) >= '0'
CWDeAC                             and %subst(sidisp:8:1) <= '9'
CWDeAC                             and %subst(sidisp:9:1) = ' '
CWDeA*        Single digit level defined with handstack defined.
CWDeAC                             or  %subst(sidisp:8:1) >= '0'
CWDeAC                             and %subst(sidisp:8:1) <= '9'
CWDeAC                             and %subst(sidisp:9:1) >= 'A'
CWDeAC                             and %subst(sidisp:9:1) <= 'Z'
CWDeAC                   eval      lvla = %subst(sidisp:8:1)
CWDeA*
CWDeAC                   if        lvla >= 'A' and lvla <= 'Z'
CWDeAC                   evalr     wkchar = %trimr(lvla)
CWDeAC                   exsr      zzcvt2nbr
CWDeAC                   evalr     lvla   = %trimr(nwchar)
CWDeAC                   endif
CWDeA*
CWDeAC                   testn                   lvla                 50
CWDeAC                   if        *in50 = *on
CWDeAC                   move      lvla          slrlvl
CWDeAC                   endif
CWDeAC                   eval      slhand  = ' ' + %subst(sidisp:9:1)
CWDeA*        Double digit level defined.
CWDeAC                   when          %subst(sidisp:8:1) >= '0'
CWDeAC                             and %subst(sidisp:8:1) <= '9'
CWDeAC                             and %subst(sidisp:9:1) >= '0'
CWDeAC                             and %subst(sidisp:9:1) <= '9'
CWDeAC                   eval      lvlaa = %subst(sidisp:8:2)
CWDeAC                   testn                   lvlaa                5050
CWDeAC                   if        *in50 = *on
CWDeAC                   move      lvlaa         slrlvl
CWDeAC                   endif
CWDeAC                   eval      slhand  = ' ' + %subst(sidisp:10:1)
CWDeAC                   other
CWD AC                   eval      slrlvl = 1
CWD AC                   eval      lvla   = '1'
CWD AC
CWD AC                   eval      slhand  = '  '
CWDeAC                   endsl
CWD AC                   eval      dashpos = -1
CWD A
CWD AC                   endsl
CWD A
CWD A*  Begin testing parts for ALL slots.
CWD AC                   testn                   loca                 5050
CWD AC                   if        *in50 = *off
CWD AC                   eval      locnotnum = *on
CWD A
CWD AC                   else
CWD AC                   select
CWD AC                   when      slloc  = 0
CWD AC                   eval      slloc = slloc + 100
CWD AC                   when      slloc < 0
CWD AC                   eval      slloc = slloc * -1
CWD AC                   endsl
CWD AC                   endif
CWD A
CWDdAC                   if        lvlaa > ' '
CWDdAC                   testn                   lvlaa                5050
CWDdAC                   else
CWD AC                   testn                   lvla                 50
CWDdAC                   endif
CWDdA
CWD AC                   if        *in50 = *off
CWD AC                   eval      lvlnotnum = *on
CWD AC                   else
CWD AC                   select
CWD AC                   when      slrlvl = 0
CWDdDC*                  eval      slrlvl = slrlvl + 10
CWDdMC                   eval      slrlvl = slrlvl + 1
CWD AC                   when      slrlvl < 0
CWD AC                   eval      slrlvl = slrlvl * -1
CWDdAC***                when      slrlvl > 0
CWDdAC***                          and slrlvl < 99
CWDdAC***                eval      slrlvl = slrlvl + 1
CWD AC                   endsl
CWD AC                   endif
CWD A
CWD A*    Convert numeric handstack to alpha character.
CWD A
CWD AC                   if            slhand >= ' 0'
CWD AC                             and slhand <= '99'
CWD AC                   eval      wkchar = slhand
CWD AC                   exsr      zzcvt2ltr
CWD AC                   eval      slhand = nwchar
CWD AC                   endif
CWD A
CWD AC     slloc         div       2             dummy
CWD AC                   mvr                     oddeven
CWD AC                   if        oddeven <> 0
CWD AC                   eval      slside = 1
CWD AC                   else
CWD AC                   eval      slside = 0
CWD AC                   endif
CWD A*
CWD A*    Check if base slot exists for imported slot with handstacks.
CWD A*
CWD AC                   eval      crtbaseslot = *off
CWD AC                   if        handstack = *on
CWD AC     keysl2b       setll     slot2
CWD AC                   if        not %equal(slot2)
CWD AC                   eval      crtbaseslot = *on
CWD AC                   endif
CWD AC                   endif
CWD A
CWD A*    See if slot meets criteria for allowing it to be created.
CWD A
CWD AC                   select
CWD A
CWD A*    If non-special slot doesn't have hypens, then don't add it.
CWD A
CWD AC                   when      dashpos = 0
CWD AC                   eval      notcreated = *on
CWD AC                   goto      endcreate13
CWD A
CWD A*    Don't allow creation if department is unknown.
CWD A
CWD AC                   when      validdept = '*NO '
CWD AC                   eval      notcreated = *on
CWD AC                   goto      endcreate13
CWD A
CWD A*    If location or level is not numeric, then don't add.
CWD A
CWD AC                   when      locnotnum or lvlnotnum
CWD AC                   eval      notcreated = *on
CWD AC                   goto      endcreate13
CWD A
CWD A*    Otherwise, slot is ok to be created.
CWD A
CWD AC                   other
CWD AC                   eval      slwhdp = siwhdp
CWD AC                   eval      sldisp = sidisp
CWD AC                   eval      slstyp = sistyp
CWD A
CWD AC                   endsl
CWD A
CWD A*    Try and create the Base slot.
CWD A
CWD AC                   if        crtbaseslot = *on
CWD A*    Save handstack for virtual slot.
CWD AC                   eval      svhand = slhand
CWD A
CWD AC                   eval      slwhse = siwhse
CWD AC                   eval      sldisp = kydisp
CWD AC                   eval      slpseq = sipseq
CWD AC                   select
CWD AC                   when      slpseq = 0
CWD AC                   eval      slpseq = slloc
CWD AC                   when      slpseq < 0
CWD AC                   eval      slpseq = slpseq * -1
CWD AC                   endsl
CWD AC                   eval      slstat = 'V '
CWD AC                   eval      slhand = '  '
CWD AC                   eval      slrsrv = sirsrv
CWD AC                   eval      slsdef = 'XX'
CWD AC                   eval      slpick = sipick
CWD A
CWD AC                   write (e) slrec
CWD AC                   if        %error
CWD AC                   eval      notcreated = *on
CWD AC                   endif
CWD A*
CWD AC                   endif
CWD A
CWD A*    Try and create the imported slot.
CWD A
CWD AC                   eval      slwhse = siwhse
CWD A*
CWD A*    Replace base slot display, handstack w/ imported fields.
CWD AC                   if        crtbaseslot = *on
CWD AC                   eval      slhand = svhand
CWD AC                   eval      sldisp = sidisp
CWD AC                   endif
CWD A*
CWD AC                   eval      slpseq = sipseq
CWD AC                   select
CWD AC                   when      slpseq = 0
CWD AC                   eval      slpseq = slloc
CWD AC                   when      slpseq < 0
CWD AC                   eval      slpseq = slpseq * -1
CWD AC                   endsl
CWD AC                   if        slitem > ' '
CWD AC                   eval      slstat = 'A'
CWD AC                   else
CWD AC                   eval      slstat = 'V'
CWD AC                   endif
CWD A*
CWD A*    Slot has handstack, create as virtual slot.
CWD AC                   if        handstack = *on
CWD AC                   eval      slrsrv = 'V'
CWD AC                   else
CWD AC                   eval      slrsrv = sirsrv
CWD AC                   endif
CWD AC                   eval      slsdef = 'XX'
CWD AC                   eval      slpick = sipick
CWD A
CWD AC                   write (e) slrec
CWD AC                   if        %error
CWD AC                   eval      notcreated = *on
CWD AC                   endif
CWD A
CWD A*    Create Virtual slot record.
CWD A
CWD AC                   if        handstack = *on
CWD AC                   eval      vswhse = slwhse
CWD AC                   eval      vswhdp = slwhdp
CWD AC                   eval      vsaisl = slaisl
CWD AC                   eval      vsloc  = slloc
CWD AC                   eval      vsrlvl = slrlvl
CWD AC                   eval      vshand = slhand
CWD AC                   eval      vsdisp = sldisp
CWD AC                   eval      vspdis = kydisp
CWD AC                   eval      vscdte = impdte
CWD AC                   eval      vsctim = imptim
CWD AC                   add       1             vsctim
CWD AC                   write (e) vsrec
CWD AC                   if        %error
CWD AC                   eval      error  = *on
CWD AC                   eval      detmsg = desc(8)
CWD AC                   add       1             notcrt
CWD AC                   goto      endcreate13
CWD AC                   endif
CWD A
CWD AC                   endif
CWD A
CWD A
CWD AC     endcreate13   endsr
     *
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
EI7 A*
EI7 A*----------------------------------------------------------------
EI7 A*  zzlotcode   Create lot code records for license just created.
EI7 A*----------------------------------------------------------------
EI7 A
EI7 AC     zzlotcode     begsr
EI7 A
EI7 A
EI7 A*  Write out standard license information.
EI7 A
EI7 AC                   exsr      clr$licinfo
EI7 A
EI7 AC                   eval      $lnpgm    = #pgm
EI7 AC                   eval      $lnjob    = #job
EI7 AC                   eval      $lnjobnbr = #jobnbr
EI7 A
EI7 AC                   eval      $lnwhse  = siwhse
EI7 AC                   eval      $lntype  = 'P'
EI7 AC                   eval      $lnlcns  = silcns
EI7 A
EI7 AC                   eval      $lncodeu(1) = *on
EI7 AC                   eval      $lncode(1) = '*PO'
EI7 AC                   eval      $lncseq(1) = 1
EI7 AC                   eval      $lnvaltyp(1) = 'A'
EI7 AC                   eval      $lnvalchr(1) = sipo
EI7 AC                   eval      $lnvalnum(1) = 0
EI7 A
EI7 AC                   eval      $lncodeu(2) = *on
EI7 AC                   eval      $lncode(2) = '*POSEQ'
EI7 AC                   eval      $lncseq(2) = 1
EI7 AC                   eval      $lnvaltyp(2) = 'N'
EI7 AC                   eval      $lnvalchr(2) = ' '
EI7 AC                   eval      $lnvalnum(2) = siposq
EI7 A
EI7 AC                   eval      $lncodeu(3) = *on
EI7 AC                   eval      $lncode(3) = '*ITEM'
EI7 AC                   eval      $lncseq(3) = 1
EI7 AC                   eval      $lnvaltyp(3) = 'A'
EI7 AC                   eval      $lnvalchr(3) = slitem
EI7 AC                   eval      $lnvalnum(3) = 0
EI7 A
EI7 AC                   eval      $dricommand = '*LICINFO'
EI7 AC                   eval      $drisubcmd  = '%ADD'
EI7 AC                   eval      $drisys2upd = 'D'
EI7 AC                   eval      ck4err = *on
EI7 AC                   exsr      zzzdricop
EI7 AC                   if        error
EI7 AC                   else
EI7 A
EI7 A*  Create p/o history header record to link to license info data.
EI7 AC     keyphh        setll     pohhdr
EI7 AC                   if        not %equal(pohhdr)
EI7 AC                   eval      phhwhs = siwhse
EI7 AC                   eval      phhpo  = sipo
EI7 AC                   eval      phhvna = 'Auto-created for Dakota WMS Startu'
EI7 AC                                       + 'p'
EI7 AC                   eval      phhva1 = 'No purchase order detail imported'
EI7 AC                   eval      phhedt = impdte
EI7 AC                   eval      phheti = imptim
EI7 AC                   eval      phhsta = '4'
EI7 AC                   write     phhrec
EI7 AC                   endif
EI7 AC                   endif
EI7 A
EI7 A*  Write out more standard and optional license information.
EI7 A
EI7 AC                   if        silotc <> ' '
EI7 AC                   exsr      clr$licinfo
EI7 A
EI7 AC                   eval      $lnpgm    = #pgm
EI7 AC                   eval      $lnjob    = #job
EI7 AC                   eval      $lnjobnbr = #jobnbr
EI7 A
EI7 AC                   eval      $lnwhse  = siwhse
EI7 AC                   eval      $lntype  = 'P'
EI7 AC                   eval      $lnlcns  = silcns
EI7 A
EI7 AC                   eval      $lncodeu(1) = *on
EI7 AC                   eval      $lncode(1) = '*LOT'
EI7 AC                   eval      $lncseq(1) = 1
EI7 AC                   eval      $lnvaltyp(1) = 'A'
EI7 AC                   eval      $lnvalchr(1) = silotc
EI7 AC                   eval      $lnvalnum(1) = 0
EI7 A
EI7 AC                   eval      $dricommand = '*LICINFO'
EI7 AC                   eval      $drisubcmd  = '%ADD'
EI7 AC                   eval      $drisys2upd = 'D'
EI7 AC                   eval      ck4err = *on
EI7 AC                   exsr      zzzdricop
EI7 AC                   if        error
EI7 AC                   endif
EI7 A
EI7 AC                   endif
EI7 A
EI7 AC     endlotcode    endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$license  Clear $license data structure fields
     *----------------------------------------------------------------

     C     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liemp# = $emp#
     C                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   endsr

EI7 A
EI7 A*----------------------------------------------------------------
EI7 A*  clr$licinfo  Clear $licinfo data structure fields
EI7 A*----------------------------------------------------------------
EI7 A
EI7 AC     clr$licinfo   begsr
EI7 AC                   eval      savever#  = $lnver#
EI7 AC                   clear                   $licinfo
EI7 AC                   eval      $lnver#   = savever#
EI7 A
EI7 AC                   eval      $lnuser   = #curruser
EI7 AC                   eval      $lnemp#   = $emp#
EI7 AC                   eval      $lnpgm    = #pgm
EI7 AC                   eval      $lnjob    = #job
EI7 AC                   eval      $lnjobnbr = #jobnbr
EI7 A
EI7 AC                   endsr

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = $emp#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
640bAC                   when      $dricommand = '*LICINFO'
640bAC                   eval      $dridata = $licinfo
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

     C                   when      $drireturn <> '*OK' and ck4err = *on
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $license = $dridata
     C                   eval      $license2 = $dridata2
640bAC                   when      $dricommand = '*LICINFO'
640bAC                   eval      $licinfo = $dridata
     C                   endsl

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
**
FTP StuffIt Import 5
**
 ABCDEFGHIJKLMNOPQRSTUVWXYZ
