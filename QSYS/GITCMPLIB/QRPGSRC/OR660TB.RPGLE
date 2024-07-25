      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  OR660TB - Tote and Bundle Counts By Stop/Zone
     *  17 April 2009
     *  Chuck Manny
     *
520 A*----------------------------------------------------------------
     *  Revisions:
     *
     *    04/17/09  CWM  5.20
     *      - Created
     *
520aA*    04/21/09  DAS  5.20a
     *      - Revised to print 3 reports. First will be include all
     *        zones. Second, only DRYE15/16 and DRYZ zones.
     *        Third, only DRYH.
     *
520aA*    04/28/09  hnk  5.20b
     *      - Change zone names...
     *
530 A*    12/01/09  JCJ  5.30
     *      - Revised to use TRUCKH to lookup Template code for
     *        Zone references.
     *
530aA*    02/22/10  JCJ  5.30a
     *      - Change zone names for candy
     *
650aA*    05/24/13  RBD  6.50a
     *      - Enh: Print new stop/drop display instead of 5 dig stop.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  90        Overflow Indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Frtestp1   if   e           k disk
     Fordh      if   e           k disk
     Fzoneh     if   e           k disk
     Fworklbfi  if   e           k disk
     Frtehed    if   e           k disk
     Foptionz   if   e           k disk
530 AFtruckh    if   e           k disk
     *
     For660tbpr o    e             printer oflind(*in90)
     F                                     usropn
     *----------------------------------------------------------------
     *  Table and array
     *
     D a80             s              1    dim(80)
520aD*TTL             S             40    DIM(1) CTDATA PERRCD(1)
520aMD ttl             s             40    dim(3) ctdata perrcd(1)
     D ovrprt          s             80    dim(1) ctdata perrcd(1)
     *
     *----------------------------------------------------------------
     * Variables
     *
     D forever         s               n   inz(*on)
     D first           s               n   inz(*on)
     D firsttran#      s               n
520aAD firstzone       s               n
     D onetime         s               n   inz(*on)
     D kycode          s              8    inz('*PICK   ')
     D lastcnam        s                   like(ohcnam)
     D lastcust        s                   like(ohcust)
     D lastord         s                   like(rtsord)
     D laststop        s                   like(rtsstp)
     D laststop5       s                   like(rtsst5)
650aAD laststpdrp      s                   like(rtssd)
     D lasttran#       s                   like(lwtrn#)
520aAD pass            s              3  0
520aAD passtype        s              6
     D wkcntr          s              5  0 inz

     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10
     D $vwhse          s              3p 0
     D $whse           s              3  0 inz
     D $plen           s              3  0
     D $pstr           s             60
     D opened          s              1
530 AD $ptmpl          s             10
     *
     *----------------------------------------------------------------
     *  Constants
     *
     *----------------------------------------------------------------
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
     D  opgcde                62     62
     D  opdend               117    117
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $WHSE   Warehouse  to process.
     *      $RTE    Route      to process.
     *
     *    Returned Parameters
     *      *NONE
     *
     *----------------------------------------------------------------
     *
     *  Mainline
     *
     *----------------------------------------------------------------
     *
     C     *entry        plist
520aMC                   parm                    $whsea            3
520aMC                   parm                    $rtid             5
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C                   move      $whsea        $whse

     *  Get route header.

     C     rtkey         chain     rtehed
     C                   if        not %found(rtehed)
     C                   eval      *inlr = *on
     C                   return
     C                   endif
520aA
520aA*  Printing 3 reports.
520aA
520aAC                   for       pass = 1 to 3
520aA
520aA*    Set pass type
520aA
520aAC                   select
520aAC                   when      pass = 1
520aAC                   eval      passtype = 'ALL'
520aAC                   when      pass = 2
520bAC                   eval      passtype = 'GRO15 '
520bA**                 eval      passType = 'DRYE15'
520aAC                   when      pass = 3
520aAC                   eval      passtype = 'HBA '
520bA**                 eval      passType = 'DRYH'
520bAC                   endsl

     *    Open printer file
     *    Note, this is done for each pass so it will close the
     *          previous spool file and start a new one.

     C                   exsr      opnprt

     *    Loop through RTESTP file

     C                   eval      first = *on
     C     rtkey         setll     rtestp1

     C                   dow       forever = forever
     C     rtkey         reade     rtestp1
     C                   if        %eof(rtestp1)
     C                   exsr      printsummary
     C                   leave
     C                   endif

     *      Get order header info

     C     ohkey         chain     ordh
     C                   if        not %found(ordh)
     C                   eval      ohcust = 0
     C                   eval      ohcnam = '** ORDH NOT FOUND **'
     C                   endif

     *      First time through stuff.

     C                   if        first
     C                   eval      first = *off

     C                   exsr      zrfrmt
     C                   eval      *in90 = *on

     C                   eval      laststop = rtsstp
     C                   eval      laststop5 = rtsst5
650aAC                   eval      laststpdrp = rtssd
     C                   eval      lastcnam = ohcnam
     C                   eval      lastcust = ohcust
     C                   eval      lastord  = rtsord

     C                   endif

     *      When host stop changes, print zones for stop.

     C                   if        laststop5 <> rtsst5
     C                             or lastcust <> ohcust
     C                   exsr      printsummary
     C                   eval      laststop = rtsstp
     C                   eval      laststop5 = rtsst5
650aAC                   eval      laststpdrp = rtssd
     C                   eval      lastcnam = ohcnam
     C                   eval      lastcust = ohcust
     C                   eval      lastord  = rtsord
     C                   endif

     C                   enddo

520aAC                   if        not firstzone
     C                   write     foot1
520aAC                   endif

520aAC                   endfor

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
     C     lwkey         klist
     C                   kfld                    $whse
     C                   kfld                    $rtid
     C                   kfld                    laststop
     C                   kfld                    zhzone
     *
     C     ohkey         klist
     C                   kfld                    $whse
     C                   kfld                    rtsord
     *
     C     opzkey        klist
     C                   kfld                    kycode
     C                   kfld                    $whse
530 D ***                kfld                    zhtruk
530 MC                   kfld                    $ptmpl
     C                   kfld                    zhzone
     *
     C     rtkey         klist
     C                   kfld                    $whse
     C                   kfld                    $rtid
     *
     C     zhkey         klist
     C                   kfld                    $whse
530 D ***                kfld                    rhtruk
530 MC                   kfld                    $ptmpl
530 A*
530 A*  Define key for TRUCKH file.
530 A*
530 AC     keyth         klist
530 AC                   kfld                    $whse
530 AC                   kfld                    rhtruk
     *
     C                   move      $whsea        $whse
     *
     C                   endsr
     *----------------------------------------------------------------
     C     calcbundles   begsr

     C                   eval      wotots = 0
     C                   eval      wobndl = 0

     C     lwkey         setll     worklbfi
     C                   dow       forever = forever
     C     lwkey         reade     worklbfi
     C                   if        %eof(worklbfi)
     C                   leave
     C                   endif

     C                   if         lwtype <> 'O' and lwtype <> 'B'
     C                   iter
     C                   endif

     C                   eval      wobndl += lbqpck

     C                   enddo

     C                   endsr
     *----------------------------------------------------------------
     C     calctotes     begsr

     C                   eval      wotots = 0
     C                   eval      wobndl = 0

     C                   eval      firsttran# = *on
     C     lwkey         setll     worklbfi
     C                   dow       forever = forever
     C     lwkey         reade     worklbfi
     C                   if        %eof(worklbfi)
     C                   leave
     C                   endif

     C                   if         firsttran#
     C                   eval       firsttran# = *off
     C                   eval       lasttran# = lwtrn#
     C                   eval       wotots = 1
     C                   endif

     C                   if         lasttran# <> lwtrn#
     C                   eval       lasttran# = lwtrn#
     C                   eval       wotots += 1
     C                   endif

     C                   enddo

     C                   endsr
     *----------------------------------------------------------------
     C     printsummary  begsr

520aD**                 exsr      zrHead
530 A*
530 A* Get Zone Template Code if Template type is T=Truck
530 A*
530 AC     keyth         chain     truckh
530 AC                   if        %found(truckh)
530 AC                             and thtype = 'T'
530 AC                   eval      $ptmpl =  thztmp
530 AC                   else
530 AC                   eval      $ptmpl =  rhtruk
530 AC                   endif

     C                   eval      wottbn = 0
     C                   eval      wotttt = 0
520aAC                   eval      firstzone = *on

     C     zhkey         setll     zoneh
     C                   dow       forever = forever
     C     zhkey         reade     zoneh
     C                   if        %eof(zoneh)
     C                   leave
     C                   endif

520aAC                   select
520aA
520bD**                 when      passType = 'DRYE15'
520bD**                           and zhzone <> 'DRYE15'
520bD**                           and zhzone <> 'DRYE16'
520bD**                           and zhzone <> 'DRYZ'
520bAC                   when      passtype = 'GRO15 '
520bAC                             and zhzone <> 'GRO15 '
520bAC                             and zhzone <> 'GRO16 '
520bAC                             and zhzone <> 'CHEM'
520aAC                   iter
520aA
520bD**                 when      passType = 'DRYH'
520bD**                           and zhzone <> 'DRYH'
520bAC                   when      passtype = 'HBA '
520baC                             and zhzone <> 'HBA '
530 D ***                          and zhzone <> 'CANDY'
530aMC                             and zhzone <> 'CNDY19'
530aaC                             and zhzone <> 'CNDY20'
520aAC                   iter
520aA
520aAC                   endsl

     C     opzkey        chain     optionz

     C                   if        opptyp = 'T'
     C                   exsr      calctotes
     C                   else
     C                   exsr      calcbundles
     C                   endif

     C                   if        wotots > 0 or wobndl > 0
     C                   eval      wozone = zhzone
520aAC                   if        firstzone
520aAC                   eval      firstzone = *off
520aAC                   exsr      zrhead
520aAC                   endif
     C                   exsr      zrdetl
     C                   endif

     C                   enddo

520aAC                   if        not firstzone
     C                   exsr      zrtotl
520aAC                   endif

     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPNPRT  Open printer file.
     *
     C     opnprt        begsr
     *
     C                   if        opened = *on
     C                   close     or660tbpr
     C                   eval      opened = *off
     C                   endif
     *
     *   Get device and form type for department.
     *
     C                   call      'GETRPT'
     C                   parm      '*DEVFORM'    $cmd              8
     C                   parm      'OR660TBPR'   $lrpt            10
     C                   parm                    $whse
     C                   parm      ' '           $styp             1
     C                   parm      ' '           $whdp             5
     C                   parm                    $desc            50
     C                   parm                    $dev             10
     C                   parm                    $form            10
     *
     *   Open printer file for department.
     *
     C                   if        opened <> *on
     *
     *      If printer already open then close it.
     *
     C                   movea     ovrprt(1)     a80
     C                   movea     $dev          a80(40)
     C                   movea     $form         a80(61)
     C                   movea     a80           qcmd
     *
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
     *
     *      Open printer file.
     *
     C                   open      or660tbpr
     C                   eval      opened = *on
     *
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     *   Format report title.
     *
520aAC                   select
520aAC                   when      passtype = 'ALL'
     C                   eval      title = ttl(1)
520bD**                 when      passType = 'DRYE15'
520bAC                   when      passtype = 'GRO15 '
520bAC                   eval      title = ttl(2)
520bD**                 when      passType = 'DRYH'
520bAC                   when      passtype = 'HBA '
520aAC                   eval      title = ttl(3)
520aAC                   endsl
     C                   movel     title         $pstr
     C                   eval      $plen = 40
     *
     *   Center report title.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         title
     *
     *   Get warehouse description.
     *
     C                   eval      whse = *blanks
     C                   eval      $pstr = *blanks
     *                  movel     whDesc        $pStr            60
     *
     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $whse         $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk
     *
     C                   eval      $pstr = $vdesc
     *
     C                   eval      $plen = 30
     *
     *   Center warehouse description.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     *
     C                   movel     $pstr         whse
     *
     *   Format Route number.
     *
     C                   eval      batch = *blanks
     C                   eval      $pstr = *blanks
     C     batch         cat       'Route:':1    batch
     C     batch         cat       rhrte:1       batch
     C                   movel     batch         $pstr
     C                   eval      $plen = 30
     *
     *   Center batch/route description.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         batch
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *    Print Header
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     *                  exsr      zrfrmt
     *
     C                   eval      wocust = lastcust
     C                   eval      woname = lastcnam
650aDC**                 eval      wostop = laststop5
650aMC                   eval      wostop = laststpdrp
     *
     C                   if        *in90 = *on
     C                   write     head1
     C                   write     columns
     C                   eval      wkcntr = 6
     C                   else
     C                   write     columns
     C                   eval      wkcntr += 3
     C                   endif
     *
     C                   eval      *in90 = *off
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *    Print Detail
     *----------------------------------------------------------------
     *
     C     zrdetl        begsr
     *
     C                   eval      wottbn += wobndl
     C                   eval      wotttt += wotots
     *
     C                   eval      wkcntr += 2
     *
     C                   if        wkcntr >= 60
     C                   eval      *in90 = *on
     C                   exsr      zrhead
     C                   eval      wkcntr += 2
     C                   endif
     *
     C                   write     detail1
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *    Report Totals
     *----------------------------------------------------------------
     *
     C     zrtotl        begsr
     *
     C                   write     total1
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
**      TTL   Report title descriptions
Tote / Bundle Report - All Zones
Tote / Bundle Report - GRO15/GRO16/CHEM
Tote / Bundle Report - HBA/CANDY
**   OVRPRTF statment
OVRPRTF FILE(OR660TBPR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
