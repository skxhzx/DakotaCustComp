      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR615     Truck build - Assign zones
     *  12 June 1997
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    06/12/97  DAS  4.00
     *      -  New program.
     *
402 A*    07/28/97  DAS  4.02
     *      -  Removed moving 'ZZZZZZ' into parent zone (LWPZON).
     *
402 A*    07/29/97  DAS  4.02
     *      -  Revised routine GETBLK to get zone for the actual bulk
     *         pick slot when a zone doesn't exist for home slot.
     *
403 A*    07/30/97  DAS  4.03
     *      -  Set STPFLG and ASLFLG to *HIVAL when department changes.
     *      -  Set ASLFLG to *HIVAL when section changes.
     *
404  *    08/28/97  RH   4.04
     *      -  Revised to work with cross dock label record. Cross dock items
     *         have an 'X' in LWSTYP field, an 'XDK' in LWAISL and an 'O' in
     *         LWTYPE.  Set the Slot zone = Truck zone, Parent zone = blank and
     *         Generation = 1.
     *
404  *    09/05/97  DS   4.04
     *      -  Revised to process section type 'X' (cross dock) as 'F'.
409  *    04/20/98  RH   4.09
     *      -  Fix set BRKFLG if aisle breakdown records exist.       .
     *
500 A*    03/29/06  DAS  5.00
     *      - Enh: Revised program to add support for Client id
     *
500aA*    04/11/06  DAS  5.00a
     *      - Revised logic to get general zones for dept, sect, aisle.
     *        RE: Needed loop in order to deal with Tote zones.
     *      - Revised to clear zone information from all records.
     *      - Revised to delete Merge records.
     *      - Revised update LWTRUK field.
510aA*    07/17/07  DAS  5.10a
     *      - Revised to setll before doing keyas2 read for brkflg.
520 A*    05/06/08  JCJ  5.20
     *      - Enh: Converted to RPG4.
520aA*    02/28/09  DAS  5.20a  P#00150
     *      - Enh: Revised to call GETZONE.
     *      - Old zone look up code removed for readability.
520aA*    03/09/09  DAS  5.20b
     *      - Enh: Revised how Bulk pick records are handled.
520bA*    08/18/09  JCJ  5.20b
     *      -  Add Batch pick processing
     *
620aA*    12/08/10  DAS  6.20a
     *      -  Added new file worklbl10
     *      -  When an 'S' (prepick) zone is assigned, revised to
     *         promote that zone to all records on the same prepick
     *         pallet (same aisle/location/level).
     *
700aA*    05/20/16  JCJ  7.00a
     *      - Fix: Load the zone template into the label file instead
     *        of the truck template.
     *
700bA*    08/19/15  DAS  7.00b
     *      -  Added order number to GETZONE call
720aA*    10/25/18  DAS  7.20a
     *      - Enh: Add fields to GETZONE call.
     *
     *----------------------------------------------------------------
     * Harbor Custom Revisions
     *
HAR A*    04/11/06  DAS  HAR
     *      - Revised to do special handling of Tote zone.
     *      - Added ORDDM file and data structures
     *      - Added OPTIONZ file.
     *
HARaA*    04/27/06  DAS  HARa
     *      - Revised to force all dept T items as tote items.
     *
530 A*    11/09/09  JCJ  530
     *      - Enh: Added file Truckh to retrieve Truck Template.
     *
     *----------------------------------------------------------------
     * Isupply Custom Revisions
     *
ISYa *    06/06/07  RH   ISYa          (added GJA 10/7/08)
     *      -  Enh:  Force zone for CHEM items
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: AJ Silberman
     *
SLBaA*    08/21/11  JCJ  SLBa
     *      - Fix: Load the zone template into the label file instead
     *        of the truck template.
     *----------------------------------------------------------------
     *  Client Custom Revisions: AJ Silberman
     *
CWDaA*    02/27/12  JCJ  CWDa
     *      - Fix: Load the zone template into the label file instead
     *        of the truck template.
     *----------------------------------------------------------------
     *  Client Custom Revisions: AJ Silberman
     *
CTWaA*    02/27/12  JCJ  CTWa
     *      - Fix: Load the zone template into the label file instead
     *        of the truck template.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        CHAIN INDICATOR
     *  90        OVERFLOW INDICATOR FOR EXCEPTION REPORT
     *  91        OVERFLOW INDICATOR FOR CATCH WEIGHT REPORT
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fworklbl1  uf   e           k disk
HAR AForddm     if   e           k disk
JORaAFslot2     if   e           k disk
530 AFtruckh    if   e           k disk
620aAFworklbl10 uf   e           k disk    rename(lwrec:lwrec10)
620aAF                                     prefix(w10_)
ISYaAFworkzon1  if   e           k disk
     *
500 A*----------------------------------------------------------------
500 A*  Customer id
500 A*
     D @getcl          c                   const('GETCLIENT')
500 A*
500 A /COPY QCOPYSRC,ID#ALLEN
HAR A /COPY QCOPYSRC,ID#HARBOR
TPCaA /COPY QCOPYSRC,ID#TPC
JORaA /COPY QCOPYSRC,ID#JORDANO
JPFaA /COPY QCOPYSRC,ID#PALMER
ISYaA /COPY QCOPYSRC,ID#ISUPPLY
SLBaA /copy qcopysrc,id#silberm
CWDaA /copy qcopysrc,id#cashwa
CTWaA /copy qcopysrc,id#citywho
     *
ISYa *----------------------------------------------------------------
ISYa *  Define ZCHEM Build code and zone
ISYa *
ISYaAD @CHZON          c                   const('ZCHEM')
HAR A*----------------------------------------------------------------
HAR A*  *PICK  -  Picking options
HAR A*
     *     11/28/94  DAS
     *       - Changed OPFSTP to 2 digits from 1.
     *
     *     02/16/95  DAS   2.09
     *       - Moved option from OPTIONS to OPTIOND in order to have
     *         the options by department.
     *       - Added option OPFBLD for identifying the method to use
     *         for building a fixed pallet.
     *
213 A*     06/11/96  DAS   2.13
     *       - Redefined OPBPCK to 3.0 from 2.0.
     *       - Added option OPPBRK.
     *
214 A*     07/01/96  DAS
     *       - Redefined OPPBRK to 3 from 1 and to contain aisle
     *         instead of Y/N.
     *
300 A*     06/11/97  DAS
     *       - Moved into OPTIONZ from OPTIOND file.
     *       - OPPBRK is not used with zones.
     *
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
214 D**** OPPBRK  -  Break pallets by aisle (Y,N).
214 M*    OPPBRK  -  Aisle to start new pallet.
400 A*    OPPBLD  -  Pallet building method.
400 A*                1 = By stop then slot location.
400 A*                2 = By slot location then stop.
416 A*                3 = By descening stop, then slot location.
400 A*    OPSELM  -  Selection method.
400 A*                1 = Single pass (By location).
400 A*                2 = Multiple pass (By stop).
400 A*    OPSPLT  -  Allow stop to be split across pallets (Y/N).
400 A*    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
416aA*    OPNWPL  -  Start new pallet when aisle changes if build method
416aA*               is 2=Location.
500cM*    OPPTYP  -  Pallet type (P=Pallet, T=Tote).
500 A*    OPTCUB  -  Outside cube of Tote.
500bA*    OPFPCS  -  Maximum pieces per fixed pallet.
500cA*    OPNWOR  -  Start new pallet when order changes.
     *
     * Data structure
     *
     D opzdta          ds
     D  opnxtp                 1      7  0 inz(0)
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
209 AD  opfbld                27     27  0 inz(0)
213 AD  opbpck                28     30  0 inz(0)
214 AD  oppbrk                31     33
400 AD  oppbld                34     34
400 AD  opselm                35     35
400 AD  opsplt                36     36
500 MD  opbmrg                37     37
500 MD  opnwpl                38     38
500dAD  opford                39     40  0
500cMD  opptyp                41     41
500dAD  opftot                42     43  0
500dAD  optecb                44     48  2
500dAD  opticb                49     53  2
500dAD  optstp                54     55  0
500dAD  optord                56     57  0
500dAD  optpcs                58     60  0
     D  opend1               117    117
HAR A*----------------------------------------------------------------
HAR A*  ORDDM data structures
HAR A*----------------------------------------------------------------
HAR AD                 ds
HAR AD  dsmsc1                 1     40
HAR AD  dssrp                  1      7
HAR AD  dsmarg                 8     14
HAR AD  dsmfgc                15     20
HAR AD  dsmitm                21     30
HAR AD  dsmt1                 33     33
HAR AD  dsmt2                 34     34
HAR AD  dsmt3                 35     35
HAR A*----------------------------------------------------------------
HAR AD                 ds
HAR AD  dsmsc2                 1     40
HAR A*----------------------------------------------------------------
HAR AD                 ds
HAR AD  dsmsc3                 1     40
HAR A*----------------------------------------------------------------
HAR AD                 ds
HAR AD  dsmsc4                 1     40
HAR A*----------------------------------------------------------------
HAR AD                 ds
HAR AD  dsmsc5                 1     40
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
     * Variables
     *----------------------------------------------------------------
ISYaAD ctzone          s                   like(zwtzon)
ISYaAD cpzone          s                   like(zwpzon)
ISYaAD ccomp           s                   like(zwcomp)
ISYaAD cgen            s                   like(zwgen)
ISYaAD kyzone          s                   like(zwszon)
530 AD $ptmpl          s             10
     D dsmtot          s              1
     D forevr          s               n
620aAD forever         s               n
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PBAT   Batch number
     *      $PWHSE  Warehouse
     *      $PTRUK  Truck
     *      $POTYP  Order type.
     *      $PRTID  Route id
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pbat             7 0
     C                   parm                    $pwhse            3 0
     C                   parm                    $ptruk           10
     C                   parm                    $potyp            1
     C                   parm                    $prtid            5
     *----------------------------------------------------------------
     *  Main line
500aA*
500aA* Loop through labels for route and clear zones.
500aA*
500aAC     keylw1        setll     worklbl1
500aAC                   dow       forevr = forevr
500aAC     keylw1        reade     worklbl1                               79
500aAC                   if        *in79
500aAC                   leave
500aAC                   endif
500aA*
500aA*    Ignore letdowns.
500aA*
500aAC                   if        lwtype = 'R'
500aAC                   iter
500aAC                   endif
520bA*
520bA*    Ignore batch picks.
520bA*
520bAC                   if        %subst(lwpo:6:3) <> *blanks
520bAC                   iter
520bAC                   endif
500aA*
500aA*    Delete Merge records.
500aA*
500aAC                   if        lwtype = 'M'
500aAC                   delete    lwrec
500aAC                   iter
500aAC                   endif
500aA*
500aA*    Update truck and clear zone information.
500aA*
700aDC***                select
700aDC***                when      client = silberman
CWDaDC***                          or client = cashwa
CTWaDC***                          or client = citywho
SLBaAC                   eval      lwtruk = $ptmpl
700aDC***                other
700aDC***                eval      lwtruk = $ptruk
700aDC***                endsl
500aAC                   eval      lwszon = *blanks
500aAC                   eval      lwtzon = *blanks
500aAC                   eval      lwpzon = *blanks
500aAC                   eval      lwcomp = *blanks
500aAC                   eval      lwgen = 0
500aAC                   update    lwrec
500aA*
500aAC                   enddo
     *
     * Loop through labels for route.
     *
     C     keylw1        setll     worklbl1
     C                   dow       forevr = forevr
     C     keylw1        reade     worklbl1                               79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *    Ignore letdowns.
500aA*      and Merge records.
     *
     C                   if        lwtype = 'R'  or
500aAC                             lwtype = 'M'
     C                   iter
     C                   endif
500aA*
500aA*    Ignore records that have been assigned to a zone.
500aA*
500aAC                   if        lwszon <> ' '
500aAC                   iter
500aAC                   endif
520aA
520aA*    Set Tote flag for item
520aA
520aAC                   exsr      setTote
520aA*
520aA*    Set slot fields
520aA*
     C                   if        lwtype = 'B'
     C                             and lwasl2 <> ' '
520aAC                   eval      $zwhdp = lwwhd2
520aAC                   eval      $zstyp = lwstyp
520aAC                   eval      $zaisl = lwasl2
520aAC                   eval      $zloc  = lwloc2
520aAC                   eval      $zrlvl = lwlvl2
520aAC                   eval      $zhand = lwhnd2
     C                   else
520aAC                   eval      $zwhdp = lwwhdp
520aAC                   eval      $zstyp = lwstyp
520aAC                   eval      $zaisl = lwaisl
520aAC                   eval      $zloc  = lwloc
520aAC                   eval      $zrlvl = lwrlvl
520aAC                   eval      $zhand = lwhand
     C                   endif
520aA
520aA*    Get designation code of slot.
520aA
520aAC     keysl2        chain     slot2
520aAC                   if        not %found(slot2)
520aAC                   eval      sldesg = ' '
720aAC                   eval      slactv = ' '
720aAC                   eval      slpick = ' '
ISYaAC                   else
ISYaA* If I Supply force zone for CHEM.
ISYaAC                   if        client = isupply and
ISYaAC                             lwwhdp = 'DRY' and
ISYaAC                             sldesg = 'CHEM'
ISY AC                   movel     @chzon        lwszon
ISY AC                   eval      lwtzon = ctzone
ISY AC                   eval      lwpzon = cpzone
ISY AC                   eval      lwcomp = ccomp
ISY AC                   z-add     cgen          lwgen
ISY AC                   goto      skip1
ISY AC                   endif
520aAC                   endif
     *
     *    Determine zone for slot.
     *
520aAC                   call      'GETZONE'
520aAC                   parm      '*GET'        $zcmd             8
530 D ***                parm      $ptruk        $ztruk           10
530 MC                   parm      $ptmpl        $ztruk           10
520aAC                   parm      $prtid        $zrtid            5
520aAC                   parm      $potyp        $zotype           1
520aAC                   parm      $pwhse        $zwhse            3 0
520aAC                   parm                    $zwhdp            5
520aAC                   parm      ' '           $zdisp           12
520aAC                   parm                    $zstyp            1
520aAC                   parm                    $zaisl            3
520aAC                   parm                    $zloc             3 0
520aAC                   parm                    $zrlvl            2 0
520aAC                   parm                    $zhand            2
520aAC                   parm      lwitem        $zitem           15
520aAC                   parm      sldesg        $zdesg            5
520aAC                   parm      lwutyp        $zutyp            1
520aAC                   parm                    $ztote            1
520aAC                   parm      ' '           $zszon            6
520aAC                   parm      ' '           $zpzon            6
520aAC                   parm      ' '           $ztzon            6
520aAC                   parm      ' '           $zcomp            1
520aAC                   parm      0             $zgen             1 0
520aAC                   parm                    opzdta
700bAC                   parm      lword         $zord             7 0
720aAC                   parm      slactv        $zactv            2
720aAC                   parm      slpick        $zpick            1
     *
     *    Update record.
     *
     C                   eval      lwszon = $zszon
     C                   eval      lwtzon = $ztzon
     C                   eval      lwpzon = $zpzon
     C                   eval      lwcomp = $zcomp
     C                   eval      lwgen = $zgen
ISYaAC     skip1         tag
     C                   update    lwrec
620aA
620aA*    For an 'S' zone, update corresponding prepick pallet slots.
620aA
620aAC                   if        opptyp = 'S'
620aAC                   exsr      promoteSZone
620aAC                   endif

     C                   enddo

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
500 A*
500 A* Get client id.
500 A*
500 AC                   call      @getcl
500 AC                   parm                    client           10
     *
     *  Define partial key for WORKLBL1 file.
     *
     C     keylw1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
HAR A*
HAR A*  Define key for ORDDM file.
HAR A*
HAR AC     keyodm        klist
HAR AC                   kfld                    lwwhse
HAR AC                   kfld                    lword
HAR AC                   kfld                    lwseq
HAR AC                   kfld                    lwitem
JORaA*
JORaA*  Define key for SLOT2 file.
JORaA*
JORaAC     keysl2        klist
JORaAC                   kfld                    lwwhse
JORaAC                   kfld                    lwwhdp
JORaAC                   kfld                    lwdisp
     *
ISYaA*  For I Supply, get CHEM zone
ISYaA*
ISYaAC                   if        client= isupply
ISYaAC     keyzw1        klist
ISYaAC                   kfld                    $pwhse
ISYaAC                   kfld                    $prtid
ISYaAC                   kfld                    kyzone
ISYaAC                   eval      ctzone = *blanks
ISYaAC                   eval      cpzone = *blanks
ISYaAC                   eval      ccomp  = *blanks
ISYaAC                   eval      cgen   = *zeros
ISYaAC                   eval      kyzone = @chzon
ISYaAC     keyzw1        chain     workzon1
ISYaAC                   if        %found(workzon1)
ISYaAC                   eval      ctzone = zwtzon
ISYaAC                   eval      cpzone = zwpzon
ISYaAC                   eval      ccomp  = zwcomp
ISYaAC                   z-add     zwgen         cgen
ISYaAC                   endif
ISYaAC                   endif
530 A *
530 A *     Truck Key.
530 A *
530 AC     keytrk        klist
530 AC                   kfld                    $pwhse
530 AC                   kfld                    $ptruk
      *
530 A * Get Zone Template Code if Template type is T=Truck
530 A *
530 AC     keytrk        chain     truckh
530 AC                   if        %found(truckh)
530 AC                             and thtype = 'T'
530 AC                   eval      $ptmpl = thztmp
530 AC                   else
530 AC                   eval      $ptmpl = $ptruk
530 AC                   endif
     *
     C                   endsr
520aA*----------------------------------------------------------------
520aA*  setTote  -  Set Tote flag for item
520aA*
520aAC     setTote       begsr

     C                   eval      $ztote = 'N'

     C                   select

     C                   when      client = harbor
     C                   exsr      setToteHAR

     C                   endsl

     C                   endsr
520aA*----------------------------------------------------------------
520aA*  setToteHAR  -  Set Tote flag for Harbor item
520aA*
520aAC     setToteHAR    begsr

HAR AC     keyodm        chain     orddm                              78
HAR AC                   if        *in78
HAR AC                   eval      dsmt1 = 'N'
HAR AC                   eval      dsmt2 = 'N'
HAR AC                   eval      dsmt3 = 'N'
HAR AC                   else
HAR AC                   eval      dsmsc1 = ommsc1
HAR AC                   eval      dsmsc2 = ommsc2
HAR AC                   eval      dsmsc3 = ommsc3
HAR AC                   eval      dsmsc4 = ommsc4
HAR AC                   eval      dsmsc5 = ommsc5
HAR AC                   endif
HAR AC                   if        lwutyp = 'N'  and
HAR AC                             dsmt1 = 'Y'  or
HAR AC                             lwutyp = '1'  and
HAR AC                             dsmt2 = 'Y'  or
HAR AC                             lwutyp = '2'  and
HAR AC                             dsmt3 = 'Y'
HAR AC                   eval      $ztote = 'Y'
HAR AC                   else
HAR AC                   eval      $ztote = 'N'
HAR AC                   endif

     C                   endsr

620aA*----------------------------------------------------------------
620aA*  PromoteSZone    Promote S zone to rest of prepick pallet slots
620aA*----------------------------------------------------------------
620aA
620aAC     PromoteSZone  begsr

      /free

         // Read corresponding prepick pallet slots

         setll (lwwhse: lwrte: lwaisl: lwloc: lwrlvl) worklbl10;

         dow forever = forever;

           reade (lwwhse: lwrte: lwaisl: lwloc: lwrlvl) worklbl10;

           if %eof(worklbl10);
             leave;
           endif;

           // Update zone info

           w10_lwszon = lwszon;
           w10_lwtzon = lwtzon;
           w10_lwpzon = lwpzon;
           w10_lwcomp = lwcomp;
           w10_lwgen  = lwgen;

           update lwrec10;

         enddo;

      /end-free

     C                   endsr
