      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR611      Truck build - Batch pick pallet calc
     *  01 September 2009
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    09/01/09  MLB  5.20
     *      -  Created.
     *
     *----------------------------------------------------------------
     *  Misc Notes
     *
     *    - If there is quantity left over from a batch pick pallet
     *      and it does not meet the batch pick minimum cube, change
     *      the label so it is picked during normal allocation.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  71        EOF on read to ORDDS.
     *  79        CHAIN INDICATOR
     *  90        OVERFLOW INDICATOR FOR EXCEPTION REPORT
     *  91        OVERFLOW INDICATOR FOR CATCH WEIGHT REPORT
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fordbsum   if   e           k disk
     Foptionz   if   e           k disk
     Fworklbl8  if   e           k disk
     Fworklble  uf a e           k disk    rename(lwrec:lwrece) Prefix(a_)
     *----------------------------------------------------------------
     *  Dakota Client IDs
     *
      /COPY QCOPYSRC,ID#MATT
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
     *----------------------------------------------------------------
     *  *PICK  -  Picking options
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
     *    OPPBRK  -  Aisle to start new pallet.
     *    OPPBLD  -  Pallet building method.
     *                1 = By stop then slot location.
     *                2 = By slot location then stop.
     *                3 = Descending by stop then location.
     *    OPSELM  -  Selection method.
     *                1 = Single pass (By location).
     *                2 = Multiple pass (By stop).
     *    OPSPLT  -  Allow stop to be split across pallets (Y/N).
     *    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
     *    OPNWPL  -  Start new pallet when aisle changes if build method
     *               is 2=Location.
     *    OPFORD  -  Maximu orders per pallet.
     *    OPPTYP  -  Pallet type (P=Pallet, T=Tote, B=Batch).
     *    OPFTOT  -  Maximum totes per pallet.
     *    OPTECB  -  External tote cube.
     *    OPTICB  -  Internal tote cube.
     *    OPTSTP  -  Maximum stops per tote.
     *    OPTORD  -  Maximum orders per tote.
     *    OPTPCS  -  Maximum pieces per tote.
     *    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
     *    OPGCDE  -  USF Group Code (0-9).
     *    OPPKUP  -  Picked up by (S=Selector, L=Loader).
     *    OPSPAL  -  Merge pallet should only contain
     *               items for single truck pallet (Y=Yes, N=No).
     *    OPPITM  -  Maximum items per pallet.
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
     D  opfbld                27     27  0 inz(0)
     D  opbpck                28     30  0 inz(0)
     D  oppbrk                31     33
     D  oppbld                34     34
     D  opselm                35     35
     D  opsplt                36     36
     D  opbmrg                37     37
     D  opnwpl                38     38
     D  opford                39     40  0 inz(0)
     D  opptyp                41     41
     D  opftot                42     43  0 inz(0)
     D  optecb                44     48  2 inz(0)
     D  opticb                49     53  2 inz(0)
     D  optstp                54     55  0 inz(0)
     D  optord                56     57  0 inz(0)
     D  optpcs                58     60  0 inz(0)
     D  opstop                61     61
     ** Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
     D  opgcde                62     62
     D  oppkup                62     62
     D  opspal                63     63
     D  oppitm                64     67  0 inz(0)
     D  opdend               117    117
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
     D palletcount     s              9  3
     D today           s              8  0
     D i               s              5  0
     D cubeleft        s              5  0
     D xopt            s              2  0
     D kyzone          s              6
     D nobatchpick     s              1
     D kycode          s                   like(opzcod)
     D mincube         s                   like(opbpck)
     D maxcube         s                   like(opfcub)
     D workcube        s                   like(opfcub)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *PICK    - Picking new orders.
     *              *RESTART - Restarting abnormally ended batch.
     *      $PPRG   Program to send messages back to.
     *      $PBAT   Batch number
     *      $PWHSE  Warehouse
     *      $PTRUK  Truck
     *      $POTYP  Order type.
     *      $PRTID  Route id
     *      $PRTE   Route
     *      $PORD   Order
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
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $prtn             5
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      $prtn = *blanks
     *
     C     keyord        setll     ordbsum
     C                   dou       %eof(ordbsum)
     C     keyord        reade     ordbsum
     C                   if        not %eof(ordbsum)
     C                   exsr      getminmax

     C                   select
     * No Batch pick
     C                   when      nobatchpick = 'Y'
     C                   iter

     C                   when      bpcube <  mincube
     * No Batch pick
     C                   exsr      zzrmvgrpcode

     C                   when      bpcube >= mincube
     C                             and bpcube <= maxcube
     * Nothing todo
     C                   iter

     C                   when      bpcube >  maxcube
     * Batch pick split
     C                   exsr      zzsplgrpcode

     C                   endsl

     C                   endif
     C                   enddo
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  GetMinMax
     *
     C     getminmax     begsr

     C                   eval      kycode = '*PICK'
     C                   eval      nobatchpick = 'N'

     C     keylb8        chain     worklbl8
     C                   if        %found(worklbl8)

     C                   eval      kyzone = %trim(lwszon)

     C                   eval      mincube = *zeros
     C                   eval      maxcube = *zeros

     C     keyopz        chain     optionz
     C                   if        %found(optionz)
     C                   eval      mincube = opbpck
     C                   eval      maxcube = opfcub
     C                   eval      nobatchpick = 'Y'
     C                   endif
     C                   endif

     C                   endsr
     *----------------------------------------------------------------
     *  zzrmvgrpcode
     *
     C     zzrmvgrpcode  begsr

     C     keylbe        setll     worklble
     C                   dou       %eof(worklble)
     C     keylbe        reade     worklble
     C                   if        not %eof(worklble)

     C                   eval      a_lwbcod = *blanks
     C                   update    lwrece

     C                   endif
     C                   enddo
     C                   endsr

     *----------------------------------------------------------------
     *  zzsplgrpcode
     *
     C     zzsplgrpcode  begsr

     C                   if        maxcube <> *zeros
     C     bpcube        div       maxcube       palletcount
     C                   mvr                     cubeleft
     C                   else
     C                   eval      cubeleft = mincube
     C                   endif

     C                   if        cubeleft < mincube

     C                   eval      workcube = mincube

     C     keylbe        setgt     worklble
     C                   dou       %eof(worklble)
     C     keylbe        readpe    worklble
     C                   if        not %eof(worklble)

     C                   select
     C                   when      lwcube < workcube
     C                   eval      a_lwbcod = *blanks
     C                   update    lwrece
     C                   eval      workcube = workcube - lwcube

     C                   when      lwcube = workcube
     C                   eval      a_lwbcod = *blanks
     C                   update    lwrece
     C                   leave

     C                   when      lwcube > workcube
     *
     *     If one case doesn't fit then look for another item to split
     *
     C                   if        workcube < lwucub
     C                   iter
     C                   endif

     C                   do        lwqpck        i
     C                   eval      workcube = workcube - lwucub
     C                   if        workcube <= *zeros
     C                   exsr      zzsplititem
     C                   leave
     C                   endif
     C                   enddo

     C                   endsl

     C                   endif
     C                   enddo

     C                   endif
     C                   endsr

     *----------------------------------------------------------------
     *  zzsplititem
     *
     C     zzsplititem   begsr

     C                   eval      lwqalc = lwqalc - i
     C                   eval      lwcube = lwucub * lwqalc
     C                   eval      lwswgt = lwuwgt * lwqalc
     C                   update    lwrece

     C                   eval      lwqalc = i
     C                   eval      lwcube = lwucub * i
     C                   eval      lwswgt = lwuwgt * i
     C                   eval      lwgrp2 = *blanks
     C                   call      'PIRLBL#'
     C                   parm                    lwlbl#
     C                   write     lwrece

     C                   endsr

     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     *
     *  Define key for zone detail search file.
     *
     C     keyord        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

     *  Define key for OPTIONZ file.

     C     keyopz        klist
     C                   kfld                    kycode
     C                   kfld                    $pwhse
     C                   kfld                    lwtruk
     C                   kfld                    kyzone

     *  Define key for OPTIONZ file.

     C     keylb8        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    bpitem

     *  Define key for worklbl file.

     C     keylbe        klist
     C                   kfld                    lwwhse
     C                   kfld                    lwrte
     C                   kfld                    lwcomp
     C                   kfld                    lwtzon
     C                   kfld                    lwgen
     C                   kfld                    lwszon
     C                   kfld                    lwtype
     C                   kfld                    bpgrp2
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
