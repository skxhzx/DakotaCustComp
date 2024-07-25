     H/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QDSGC001  Q&D SGC Stuff missing items into new slots.
     *  19 May 2009
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    06/27/05  MLB  5.00
     *      - Created
     *----------------------------------------------------------------
     *  Client Custom Revisions: Springfield Grocery Co.
     *
SGC A*    04/29/07  MLB  SGC
     *      - Revised program to add new routine CRTSLOT5 to create
     *        slots based on SGC's format.
SGC1A*    05/02/07  MLB  SGC1
     *      - Revised program to not run routine ZZCKDGT. Added to
     *        GSC1 mod.
SGCaA*    05/31/07  MLB  SGCa
     *      - Revised program to handle all character slots.
     *      - Add 1 to rack level for all slots.
SGCbA*    05/12/09  MLB  SGCb
     *      - Revised program to load SLEXPD from SIFIFO for date
     *        sensitive items.
SGCcA*    05/18/09  DAS  SGCc
     *      - Revised to create Willow/Kansas slots using DRISLOT.
     *
     *----------------------------------------------------------------
     * Indicators
     *
IFDbA*  68        - invalid digits in string
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Ffixslot   if   e           k disk
     Fimpfstuf31if   e           k disk
     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
     Foptiond   if   e           k disk
     Fslot2     uf a e           k disk
     Fvslot2    uf a e           k disk
     Fsi275pr   o    e             printer oflind(*in91)

500bA*----------------------------------------------------------------
500bA*  Client id's for custom mods.
500bA*----------------------------------------------------------------

SGC AD/copy qcopysrc,id#sgc

500bAD client          s             10
500bAD clientloc       s             10

500iA*----------------------------------------------------------------
500iA*  DRI parameters
500iA*----------------------------------------------------------------
500iA
500iA /COPY *libl/qcopysrc,C#DRIPARMS
500iA /COPY *libl/qcopysrc,C#DRIPARMP
500iAD savesubcmd      s                   like($psubcmd)
500iAD savesubcmd2     s                   like($psubcmd)
500iA
500iA*----------------------------------------------------------------
500iA*  Data Formats
500iA*----------------------------------------------------------------
500iA
500iA /COPY *libl/qcopysrc,C#ITEM
500iA /COPY *libl/qcopysrc,C#SLOT
500iAD saveVer#        s                   like($slver#)
500iAD driitem         s               n   inz(*off)
500iAD drislot         s               n   inz(*off)
500iA
500iA*----------------------------------------------------------------
500iA*  Standard variables
500iA*----------------------------------------------------------------
500iA
500iA /COPY *libl/qcopysrc,c#stdvar
500iA
     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a2              s              1    dim(2)
     D a2n             s              1    dim(2)
SGCcMD desc            s             20    dim(13) ctdata perrcd(1)
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
600bAD ck4err          s              1
     D crtbaseslot     s              1    inz('0')
     D count           s              3  0
     D dftlocation     s              3  0 inz(600)
     D digits          c                   const('0123456789')
     D dummy           s                   like(slloc)
600bAD  errmsg         s             50
     D exist           s              1
     D flaghs          s              1
     D forevr          s              1
     D good1           s              1
     D handstack       s              1     inz('0')
     D impdte          s              8  0
     D imptim          s              6  0
500iDD*j               s              2  0
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
500gAD validdept       s              4    inz('*YES')
     D wkchar          s              2
     D work3a          s              3
     D temp6a          s              6

     D dashpos         s              2  0
     D loca            s              3
     D lvla            s              1
     D locnotnum       s               n
     D lvlnotnum       s               n
     D notcreated      s               n

SGCcAD #rcvarea        s              6
SGCcAD sgcKansas       s               n
SGCcAD sgcWillow       s               n
SGCcAD wkWhse          s              3s 0
SGCcAD wkStgLoc        s              1
SGCcAD wkLcns          s             15

     *----------------------------------------------------------------
     *  Date fields
     *----------------------------------------------------------------

     D datefld         s               d

     D                 ds
     D  fifodate               1      8  0 inz(0)
     D  fifoyear               1      4  0 inz(0)
     D  fifomonth              5      6  0 inz(0)
     D  fifoday                7      8  0 inz(0)

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
500gAD  $ltype                81     88
500gA*
500gA*   Redefine key
500gA*
500gAD  $lwhse                19     21  0
500gAD  $lwhdp                22     26

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

600bA /COPY *libl/qcopysrc,C#PGMINFDS
600bDD*               sds
600bDD* #prog            *proc
600bDD* #job                 244    253
600bDD* #user                254    263
600bDD* #jobn                264    269
600bDD* #jobdt               276    281  0
600bDD* #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
600bA
600bA*    Get User's employee number to be written to PORCV file
600bA*    if any records are flagged as touched.
600bA
600bAC                   call      'GETUSER'
600bAC                   parm      #curruser     $code            10
600bAC                   parm      0             $whse             3 0
600bAC                   parm      0             $emp#             5 0
600bAC                   parm      *blanks       $fnam            15
600bAC                   parm      *blanks       $init             1
600bAC                   parm      *blanks       $lnam            20
600bAC                   parm      *blanks       $whdp             5
600bAC                   parm      *blanks       $styp             1
600bAC                   parm      *blanks       $shft             6
600bAC                   parm      *blanks       $crew             6
600bAC                   parm      0             $nhrs             3 1
600bAC                   parm      *blanks       $rtn              8

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
     C                   read      fixslot
     C                   if        %eof(fixslot)
     C                   leave
     C                   endif
     *
     C                   add       1             grdlin

     *
     *  Create warehouse heading if necessary.
     *
     C                   if        lstwhs <> fxwhse
     *
     C                   eval      whcode = fxwhse
     C     whcode        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     C                   move      fxwhse        work3a
     C     ' 0'          check     work3a        pos
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      40            $clen             3 0
     C                   movel     $cstr         whhead
     C                   eval      lstwhs = fxwhse
     C                   eval      count = 999
     C                   endif
     *
     *  Get options when department changes
     *
     C                   if        lstwhd <> fxwhdp
500gA*
500ga*  Validate warehouse deptartment sent with slot.
500gAC                   eval      $lwhse = fxwhse
500gAC                   eval      $lwhdp = fxwhdp
500gAC                   eval      $lcmd = '*VERIFYB'
500gAC                   call      'WD900'
500gAC                   parm                    $lparm
500gAC                   if        $lrtn = '*OK'
500gAC                   eval      validdept = '*YES'
500gAC                   else
500gAC                   eval      validdept = '*NO '
500gAC                   endif
500gA*
     C                   eval      kycode = '*PICK   '
     C     keyop         chain     optiond                            79
     C                   if        *in79
     C                   eval      opmput = 'N'
     C                   endif
     C                   eval      lstwhd = fxwhdp
     C                   endif
     *
     C                   eval      itdesc = *blanks
     C                   eval      ittype = *blanks
     C                   eval      detmsg = *blanks
     *
     *
     *  Compute number of records to read from IMPFSTUF31 file.
     *  This will be the number of entries not stuff'd on 1st run.
     C                   eval      fxcntr = fxcntr - 1
     C                   move      *zeros        cntr              3 0
     C     keysl2c       setll     impfstuf31
     C                   dow       cntr < fxcntr
     C     keysl2c       reade     impfstuf31
     C                   if        %eof(impfstuf31)
     C                   leave
     C                   endif
     *
     *  If item doesn't exist write error message.
     *
500aAC                   eval      ittype = *blanks
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
510aA*  and not type 'R' write error message.
     *
     C                   if        ittype <> ' '  and
     C                             ittype <> 'B'
510 AC                             and ittype <> 'R'
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
     C                   goto      prndtl
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
     *  Print detail and update subtotals
     *
     C     prndtl        tag
     C                   if        detmsg <> *blanks
     C                   exsr      zrhead
     C                   write     detail
     C                   add       1             count
     C                   endif
     *
     C                   eval      cntr = cntr + 1
     *
     C                   enddo
     *
     C                   enddo
     *
     *  Print order grand totals
     *
     C                   exsr      zrhead
     C                   write     grndttl
     *
     *  We are finished so get out
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
500bA
500bA*  Get client id
500bA
500bAC                   call      'GETCLIENT'
500bAC                   parm                    client
500bAC                   parm                    clientloc
500bA
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
     C     keysl2c       klist
     C                   kfld                    fxwhse
     C                   kfld                    fxwhdp
     C                   kfld                    fxdisp
     C                   kfld                    fxitem
500iA*
     *
     *  OPTIOND file
     *
     C     keyop         klist
     C                   kfld                    kycode
     C                   kfld                    fxwhse
     C                   kfld                    fxwhdp
     *
     *  VSLOT file
     *
     C     keyvs         klist
     C                   kfld                    fxwhse
     C                   kfld                    fxwhdp
     C                   kfld                    vsdisp
     *
     C     ckkey         klist
     C                   kfld                    fxwhse
     C                   kfld                    fxwhdp
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
500iA
500iA*----------------------------------------------------------------
500iA*  getslot  Get slot info.
500iA*----------------------------------------------------------------
500iA
500iAC     getslot       begsr
500iA
600bDC**                 eval      savever# = $slver#
600bDC**                 clear                   $slot
600bDC**                 eval      $slver# = savever#
600bA
600bMC                   exsr      clr$slot
500iA
600bAC                   eval      $slwhseu = *on
500iAC                   eval      $slwhse = siwhse
600bAC                   eval      $slwhdpu = *on
500iAC                   eval      $slwhdp = siwhdp
600bAC                   eval      $sldispu = *on
500iAC                   eval      $sldisp = sidisp
600bA
600bAC                   eval      $dricommand = '*SLOT'
600bAC                   eval      $drisubcmd  = '%GET'
600bAC                   eval      $drisys2upd = 'D'
600bAC                   eval      ck4err = *on
600bAC                   exsr      zzzdricop
600bAC                   if        error
600bAC                   endif
500iA
600bDC**                 eval      drislot = *on
600bDC**                 call(e)   'DRISLOT'
600bDC**                 parm      '*GET      '  $drisubcmd
600bDC**                 parm      $pprogram     $driprogram
600bDC**                 parm      ' '           $drireturn
600bDC**                 parm      ' '           $drimessage
600bDC**   $slot         parm      $slot         $dridata
500iA
500iAC     endgetslot    endsr
500iA
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
     ***
     C                   eval      $vpseq = slpseq
     C                   eval      $vdisp = *blanks
     C                   eval      k = 0
     *
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
500fMC     ckkey         setll     slot2                                  79
500fMC                   if        not *in79
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
SGC AC                             and client <> SGC
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
SGC AC                             and client <> SGC
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
500eA*
500eA*    SSB item found attached to item being imported. Allow
500eA*    Qty 2,3 fields to be updated.
500eAC                   if        #brtn = '*FOUND'
500eAC                   eval      ssbflg = *on
500eAC                   endif
500eA*
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
500cA*
500cAC                   select
500cA*    Set picking priority based on import.
500cA*      0=Lowest priority to -9=Highest priority.
500cAC                   when      siprty >= 1
500cAC                   eval      slprty = siprty * -1
500cAC                   when      siprty < 0
500cAC                   eval      slprty = siprty
500cAC                   other
500cAC                   eval      slprty = 0
500cAC                   endsl
500cAC
     C                   eval      slslfd = 0
     C                   eval      slrsrv = 'V'
     C                   eval      slexpd = svexpd
500cDC*                  eval      slprty = 0
500aAC
500aAC                   if        siitem > ' '
500aAC
     C                   if        sififo > 0
     C                   eval      slentd = fifodate
SGCbAC*
SGCbAC                   if        client = SGC
SGCbAC*      Load expiration date for date sensitive items.
SGCbAC                   if        itflgd = 'Y'
SGCbAC                   eval      slexpd = fifodate
SGCbAC                   endif
SGCbAC                   endif
SGCbAC*
     C                   else
     C                   eval      slentd = impdte
     C                   endif
500aAC                   endif
500aAC
     C                   eval      slsdte = impdte
     C                   eval      slstim = imptim
     C                   eval      slitem = siitem
     C                   eval      slstk1 = siqty1
     C                   if        itflg1 = 'Y'
500eAC                             or ssbflg = *on
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
     C                   endif
     ***
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
500aAC
500aAC                   if        siitem > ' '
500aAC
     C                   eval      slstat = 'A '
500aAC                   endif
500aAC
     C                   endif
500cA*
500cAC                   select
500cA*    Set picking priority based on import.
500cA*      0=Lowest priority to -9=Highest priority.
500cAC                   when      siprty >= 1
500cAC                   eval      slprty = siprty * -1
500cAC                   when      siprty < 0
500cAC                   eval      slprty = siprty
500cAC                   other
500cAC                   eval      slprty = 0
500cAC                   endsl
500cAC
     C                   eval      slstk1 = siqty1
     C                   if        itflg1 = 'Y'
500eAC                             or ssbflg = *on
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
500aAC                   if        siitem > ' '
500aAC
     C                   if        sififo > 0
     C                   eval      slentd = fifodate
SGCbAC*
SGCbAC                   if        client = SGC
SGCbAC*      Load expiration date for date sensitive items.
SGCbAC                   if        itflgd = 'Y'
SGCbAC                   eval      slexpd = fifodate
SGCbAC                   endif
SGCbAC                   endif
SGCbAC*
     C                   else
     C                   eval      slentd = impdte
     C                   endif
500aAC                   else
500aAC                   eval      slentd = 0
500aAC                   endif
500aAC
     C                   eval      slsdte = impdte
     C                   eval      slstim = imptim
     C                   update    slrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      detmsg = desc(6)
     C                   add       1             notupd
     C                   endif
     C                   add       1             sltupd
     C                   endif
     C                   endif
     *
     C     endupd        endsr
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

600bA*----------------------------------------------------------------
600bA*----------------------------------------------------------------
600bA*                     DRI SUBROUTINES
600bA*----------------------------------------------------------------
600bA*----------------------------------------------------------------

600bA*----------------------------------------------------------------
600bA*  clr$item  Clear $item data structure fields
600bA*----------------------------------------------------------------
600bA
600bAC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

600bA*----------------------------------------------------------------
600bA*  clr$slot  Clear $slot data structure fields
600bA*----------------------------------------------------------------
600bA
600bAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = $emp#
     C                   endsr

600bA*----------------------------------------------------------------
600bA*  zzzdricop  Call DRICOP
600bA*----------------------------------------------------------------
600bA
600bAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
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
*CAN'T CREATE OSS*
**
FTP StuffIt Import
**
 ABCDEFGHIJKLMNOPQRSTUVWXYZ
