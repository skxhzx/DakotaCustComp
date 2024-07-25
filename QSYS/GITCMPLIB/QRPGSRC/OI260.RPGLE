      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave #203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OI260     Auto-select truck
     *  29 April 2004
     *  Dave Sommerville
     *
417 A*    04/29/04  DAS  4.17
     *      - Created
     *
510aA*    09/08/07  JCJ  5.10a
     *      - Ehn: Revised program to add support for Client id
     *
510bA*    09/28/08  JCJ  5.10b
     *      - Enh: Add default truck selection
     *
520 A*    10/23/08  MLB  5.20
     *      - Enh: Add new $pcmd value: *DFTNOAU - Assign default truck
     *        template. If no default, then leave blank.
     *
530 A*    11/06/09  JCJ  5.30
     *      - Enh: Recomplied for database change to TRUCKH
     *      - Enh: Exclude truck templates.
     *
740aA*    01/17/20  DAS  6.40
     *      - Enh: Revised to look for *DFT entry if route not found.
     *
     *----------------------------------------------------------------
     * Custom Client - A&D Foods
ADFaA*    09/15/17  NLK  ADFa
     *      -Revised program to not auto-assign truck def's
     *----------------------------------------------------------------
     * Custom Client - Anderson DuBose
ADCaA*    09/15/17  NLK  ADCa
     *      -Revised program to not auto-assign truck def's
     *----------------------------------------------------------------
     * Custom Client - Harbor Wholesale
HARaA*    09/14/17  NLK  HARa
     *      -Revised program to not auto-assign truck def's
     *----------------------------------------------------------------
     * Custom Client - I Supply
     *    03/01/06  MLB  ISYa   (added GJA)
     *      -Revised progrma to not auto-assign truck def's
     *----------------------------------------------------------------
JDOaA* Custom Client - Jordanos
     *    11/20/13  RH   JDOa
     *      - if no truck selected default truck to '28F2'.
     *----------------------------------------------------------------
NCSaA* Custom Client - Nicholas
     *    08/04/11  JCJ  NCSa
     *      - if no truck selected default truck to 'VAN'.
NCSbA*    07/18/19  MLB  NCSb  P#02108
     *      - Revised NCSa mod. Revised pgm to default to 'SVAN' now
     *        Nicholas is using SAE for label printing/selection.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

530 D **truckh    if   e           k disk
530 MFtruckh2   if   e           k disk
     Ftruckd    if   e           k disk
     Frtesum    if   e           k disk
510bAFtruckdft  if   e           k disk    rename(tdrec:dtrec)
510bAFrtehed    if   e           k disk

     *----------------------------------------------------------------
     *  Multiple occurance truck data structure
     *----------------------------------------------------------------

     D truckds         DS                  OCCURS(100)
417fAD  tdsstat                       1
417fAD  tdscode                      10
417fAD  tdsdrycube                    9  3
417fAD  tdsfrzcube                    9  3
417fAD  tdspltcube                    9  3

414 A*----------------------------------------------------------------
414 A* Program variables.
414 A*----------------------------------------------------------------
414 A
     D cubeneeded      s              9  3
     D forever         s               n
417fAD i               s              3  0
     D lowcube         s              9  3
417fAD maxdrycube      s              9  3 inz(0)
417fAD maxfrzcube      s              9  3 inz(0)
417fAD maxpltcube      s              9  3 inz(0)
417fAD mindrycube      s              9  3 inz(*hival)
417fAD minfrzcube      s              9  3 inz(*hival)
417fAD minpltcube      s              9  3 inz(*hival)
     D rtesumfound     s               n
     D truckcount      s              3  0 inz(0)
740aAD starDFT         s              5

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

510aA*----------------------------------------------------------------
510aA*  Customer id
510aA*
510aAD @getcl          c                   const('GETCLIENT')
ADCaA /COPY QCOPYSRC,ID#ADC
ADFaA /copy qcopysrc,id#adf
HARaAD/copy qcopysrc,ID#HARBOR
ISYaAD/copy qcopysrc,ID#ISUPPLY
NCSaAD/copy qcopysrc,ID#NICHOLA
JDOaAD/copy qcopysrc,ID#JORDANO
510aA*

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
510bA*      $PCMD   *DFLT    - Default truck by route in file truckdft
510bA*                         If no truck found process like *AUTO
520 A*      $PCMD   *DFTNOAU - Default truck by route in file truckdft
520 A*                         If no truck found, get out.
510bA*              *AUTO    - Select truck based of Compatrment cubes
     *      $PPRG   Program to send messages back to.
     *      $PWHSE  Warehouse
     *      $PRTEID Route id
     *
     *    Returned Parameters
417eM*      $PTRUCK Selected truck code, if any.
     *      $PRTN   *OK      - Truck found.
     *              *NOTFND  - No matching truck found.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prteid           5
     C                   parm                    $ptruck          10
     C                   parm                    $prtn             8
510bAC                   parm                    $pcmd             8

ISYaAC                   if        client  = isupply
HARaAC                             or client  = harbor
ADCaAC                             or client = andersondubose
ADFaAC                             or client = AandDFoods
ISYaAC                   return
ISYaAC                   endif

     C                   eval      $ptruck = *blanks
     C                   eval      $prtn   = '*NOTFND'

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  Determine processing mode

510bAC                   Select
510bAC                   When      $pcmd = '*DFLT   '
520 AC                             or $pcmd = '*DFTNOAU'
510bAC     keyrh         chain     rtehed
510bAC                   if        %found(rtehed)
510bAC     keydt         chain     truckdft
510bAC                   if        %found(truckdft)
510bAC                   eval      $ptruck = tdtruk
510bAC                   eval      $prtn   = '*OK'
510bAC                   goto      bottom
520 A*
520 AC                   else
740aAC
740aAC     keydft        chain     truckdft
740aAC                   if        %found(truckdft)
740aAC                   eval      $ptruck = tdtruk
740aAC                   eval      $prtn   = '*OK'
740aAC                   goto      bottom
740aAC
740aAC                   else
740aAC
520 AC                   if        $pcmd   = '*DFTNOAU'
520 AC                   goto      bottom
520 AC                   endif
740aA*
740aAC                   endif
520 A*
510bAC                   endif
520 A*
510bAC                   endif
510bAC                   When      $pcmd = '*AUTO   '
     *  select truck based on compartment cubes
510bAC                   endsl

     *  Get truck information.

     *    Read through Header file.

530 D **   keyth         setll     truckh
530 MC     keyth         setll     truckh2
     C                   dow       forever = forever
530 D **   keyth         reade     truckh
530 MC     keyth         reade     truckh2
     C                   if        %eof
     C                   leave
     C                   endif

     *      See if truck should be exluded.

     *      Exclude truck templates.
530 AC                   if        thtype = 'Z'
530 AC                   iter
530 AC                   endif

     C                   if        %subst(thdesc:22:9) = '*exclude*'
     C                   iter
     C                   endif

     C                   if        truckcount = 100
     C                   iter
     C                   endif

     *      Initialize data structure entry for truck.

     C                   eval      truckcount = truckcount + 1
     C     truckcount    occur     truckds
     C                   eval      tdscode = thtruk
     C                   eval      tdsstat = ' '
     C                   eval      tdsdrycube = 0
     C                   eval      tdsfrzcube = 0
     C                   eval      tdspltcube = 0

     *      Read througth Detail.

     C     keytd         setll     truckd
     C                   dow       forever = forever
     C     keytd         reade     truckd
     C                   if        %eof
     C                   leave
     C                   endif

     *        Added cube to appropriate compartment total.

     C                   select
     C                   when      tdcomp = 'D'
     C                   eval      tdsdrycube = tdsdrycube + tdcube
     C                   when      tdcomp = 'F'
     C                   eval      tdsfrzcube = tdsfrzcube + tdcube
     C                   when      tdcomp = 'P'
     C                   eval      tdspltcube = tdspltcube + tdcube
     C                   endsl

     C                   enddo

     C                   if        tdsfrzcube <  minfrzcube
     C                   eval      minfrzcube = tdsfrzcube
     C                   endif

     C                   if        tdsfrzcube >  maxfrzcube
     C                   eval      maxfrzcube = tdsfrzcube
     C                   endif

     C                   if        tdsdrycube <= 0
     C                             and tdsfrzcube <= 0
     C                             and tdspltcube <= 0
     C                   eval      truckcount = truckcount - 1
     C                   endif

     C                   enddo

     C                   if        truckcount = 0
     C                   goto      bottom
     C                   endif

     C                   eval      rtesumfound = *off

     *  First, select truck based on best match for FRZ.

     C                   eval      kywhdp = 'FRZ'
     C     keyrs         chain     rtesum
 1B  C                   if        %found
     C                   eval      cubeneeded = rsordc
 1E  C                   else
     C                   eval      cubeneeded = 0
 1E  C                   endif

     C                   eval      rtesumfound = *on
     C                   eval      lowcube = *hival

     C     1             do        truckcount    i
     C     i             occur     truckds

     C                   select

     C                   when      cubeneeded <= 0
     C                             and tdsfrzcube = minfrzcube
     C                   eval      lowcube = tdsfrzcube

     C                   when      cubeneeded > 0
     C                             and cubeneeded <= tdsfrzcube
     C                             and tdsfrzcube <= lowcube
     C                   eval      lowcube = tdsfrzcube

     C                   when      cubeneeded > maxfrzcube
     C                             and tdsfrzcube = maxfrzcube

     C                   other
     C                   eval      tdsstat = '1'

     C                   endsl

     C                   if        tdsstat = ' ' and tdspltcube < minpltcube
     C                   eval      minpltcube = tdspltcube
     C                   endif

     C                   if        tdsstat = ' ' and tdspltcube > maxpltcube
     C                   eval      maxpltcube = tdspltcube
     C                   endif

     C                   enddo

     *  Next, select truck based on best match for PLT.

     C                   eval      kywhdp = 'PLT'
     C     keyrs         chain     rtesum
 1B  C                   if        %found
     C                   eval      cubeneeded = rsordc
 1E  C                   else
     C                   eval      cubeneeded = 0
 1E  C                   endif

     C                   eval      rtesumfound = *on
     C                   eval      lowcube = *hival

     C     1             do        truckcount    i
     C     i             occur     truckds

     C                   if        tdsstat <> ' '
     C                   iter
     C                   endif

     C                   select

     C                   when      cubeneeded <= 0
     C                             and tdspltcube = minpltcube
     C                   eval      lowcube = tdspltcube

     C                   when      cubeneeded > 0
     C                             and cubeneeded <= tdspltcube
     C                             and tdspltcube <= lowcube
     C                   eval      lowcube = tdspltcube

     C                   when      cubeneeded > maxpltcube
     C                             and tdspltcube = maxpltcube

     C                   other
     C                   eval      tdsstat = '2'

     C                   endsl

     C                   if        tdsstat = ' ' and tdsdrycube < mindrycube
     C                   eval      mindrycube = tdsdrycube
     C                   endif

     C                   if        tdsstat = ' ' and tdsdrycube > maxdrycube
     C                   eval      maxdrycube = tdsdrycube
     C                   endif

     C                   enddo

     *  Last, select truck based on best match for DRY.

     *  Currently, this is not needed because the way the trucks are
     *  defined at City Line, only 1 truck will be left.


     C**********         GOTO      SKIPDRYREF


     C                   eval      kywhdp = 'DRY'
     C     keyrs         chain     rtesum
 1B  C                   if        %found
     C                   eval      cubeneeded = rsordc
 1E  C                   else
     C                   eval      cubeneeded = 0
 1E  C                   endif

     C                   eval      kywhdp = 'REF'
     C     keyrs         chain     rtesum
 1B  C                   if        %found
     C                   eval      cubeneeded = cubeneeded + rsordc
 1E  C                   endif

     C                   eval      rtesumfound = *on
     C                   eval      lowcube = *hival

     C     1             do        truckcount    i
     C     i             occur     truckds

     C                   if        tdsstat <> ' '
     C                   iter
     C                   endif

     C                   select

     C                   when      cubeneeded <= 0
     C                             and tdsdrycube = mindrycube
     C                   eval      lowcube = tdsdrycube

     C                   when      cubeneeded > 0
     C                             and cubeneeded <= tdsdrycube
     C                             and tdsdrycube <= lowcube
     C                   eval      lowcube = tdsdrycube

     C                   when      cubeneeded > maxdrycube
     C                             and tdsdrycube = maxdrycube

     C                   other
     C                   eval      tdsstat = '3'

     C                   endsl

     C                   enddo

     C     skipdryref    tag

     *  Now select from the remaining trucks

 1B  C                   if        not rtesumfound
     C                   goto      bottom
 1E  C                   endif

     C                   eval      lowcube = *hival

     C     1             do        truckcount    i
     C     i             occur     truckds

     C                   if        tdsstat <> ' '
     C                   iter
     C                   endif

     C                   if        tdspltcube < lowcube
     C                   eval      lowcube = tdspltcube
     C                   eval      $ptruck = tdscode
     C                   eval      $prtn   = '*OK'
     C                   endif

     C                   enddo

     C     bottom        tag

NCSaAC                   if        client = nicholas
NCSaAC                   if        $ptruck = *blanks
NCSbDC*                  eval      $ptruck = 'VAN'
NCSbMC                   eval      $ptruck = 'SVAN'
NCSaAC                   eval      $prtn   = '*OK'
NCSaAC                   endif
NCSaAC                   endif


JDOaAC                   if        client = jordanos
JDOaAC                   if        $ptruck = *blanks
JDOaAC                   eval      $ptruck = '28F2'
JDOaAC                   eval      $prtn   = '*OK'
JDOaAC                   endif
NCSaAC                   endif
     C                   eval      *inlr = *on
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
510aA*
510aA* Get client id.
510aA*
510aAC                   call      @getcl
510aAC                   parm                    client           10

     *  Define partial key for TRUCKH file.

     C     keyth         klist
     C                   kfld                    $pwhse

     *  Define partial key for TRUCKD file.

     C     keytd         klist
     C                   kfld                    thwhse
     C                   kfld                    thtruk

     *  Define key for RTESUM file.

     C     *like         define    rswhdp        kywhdp
     C     keyrs         klist
     C                   kfld                    thwhse
     C                   kfld                    $prteid
     C                   kfld                    kywhdp

510bA*  Define key for RTEHED file.

510bAC     keyrh         klist
510bAC                   kfld                    $pwhse
510bAC                   kfld                    $prteid

510bA*  Define key for TRUCKDFT file.

510bAC     keydt         klist
510bAC                   kfld                    $pwhse
510bAC                   kfld                    rhrte

740aA*  Define *DFT key for TRUCKDFT file.
740aA
740aAC                   eval      starDFT = '*DFT'
740aAC     keydft        klist
740aAC                   kfld                    $pwhse
740aAC                   kfld                    starDFT

     C                   endsr
