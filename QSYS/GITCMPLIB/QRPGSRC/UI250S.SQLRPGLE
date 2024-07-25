      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  UI250S    Import FTP UCI Production - Post
     *  12 January 2017
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *
     *----------------------------------------------------------------
     *
     *  Revisions
     *
730a *    02/01/19  LMC  730a
     *      - Wasn't loading warehouse for custmast record
730b *    02/04/19  LMC  730b
     *      - Original logic made a bad assumption that we would
     *        receive the expiration date in the gs1 barcode.
     *        Added logic to calculate the expiration date.
730c *    02/11/19  LMC  730c
     *      - Dakota item import builds the dakota item
     *        (canopy item + '-' + canopy whse).
     *        We need to build and use an item to match.
     *      - if customer is -1, set to 0
730d *    03/04/19  LMC  730d
     *      - Production not made for a specific customer
     *        will be loaded into the instkaisl instead of
     *        the inpckaisl.
     *      - added getclient
730e *    06/26/19  LMC  730e
     *      - Fix logic for PAR slots, now that we are going to be
     *        using PAR slot for Canopy Box Breaker if no pick slot
     *        exists for the item.
     *
730f *    08/08/19  LMC  730f
     *      - Enh - Auto load upc.
740a *    01/07/20  LMC  740a
     *      - Enh - Scan to usage changes, need to accomodate changing
     *        the weight in the uciinfo record, and not use the weight
     *        from the gs1 barcode.
     *        If STU uses the entire UCI, then send zero for the
     *        weight. The program will remove the UCI like it does
     *        today.
     *        If STU only removes a partial weight,
     *        then the weight being removed will be sent. The
     *        program will subtract the weight from UCIINFO. If the
     *        weight goes to zero or less, the UCI will be removed.
740bA*    03/09/20  LMC  7.40b
     *      - Revised GetClient to get parms 3 (client initials)
     *        and 4 (Host Sytem Id).
     *      - Added /copy to get Host System Id's
740cA*    12/02/20  LMC  7.40c
     *      - Revised uicrtby to be D not C.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Aspen Clients
     *
ASPaA*    03/09/20  LMC  ASPa
     *      - Revised to append '-ww' to item numbers, where ww is
     *        the 2-digit warehouse
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRYaA*    03/04/19  LMC  DRYa
     *      - Only cat the item + whse for Chef's Canopy.
DRYcA*    06/13/19  LMC  DRYc
     *      - Scan to usage  - prod line 888
DRYdA*    06/20/19  LMC  DRYd
     *      - Box breaker production - prod line 999
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF for IMPITEM
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *
     Fimpsuprd  uf   e           k disk
     Fwarehs    if   e           k disk
     Fpcslot    if   e           k disk
     Fplined    if   e           k disk
     Fui250pr   o    e             printer oflind(*in91)
     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------
730bA /copy qcopysrc,p.caldktex

     D ucilic#         pr                  extpgm('UCILIC#')
      * Input
     D   unext                       13  0 const
     D   uwhse                        3  0 const

      /copy qcopysrc,p.cvtdte
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             30    dim(7) ctdata perrcd(1)
     D rdsc            s             50    dim(1) ctdata perrcd(1)
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
     *  Called program parameters
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#XDOCK
      /COPY *libl/qcopysrc,C#LICINFO
      /COPY *libl/qcopysrc,C#LICHIST
      /COPY *libl/qcopysrc,C#LICENSE
      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#UCIINFO
      /COPY *libl/qcopysrc,C#PROD
     D savever#        s                   like($lnver#)
     *----------------------------------------------------------------
     *  Convert Barcode Parms
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#CVTPARMS
      /COPY *libl/qcopysrc,C#BARCODE
     *----------------------------------------------------------------
     *  Variables
     *
     D $plen           s              3  0
     D $pstr           s             60
     D blank6          s              6
     D ck4err          s               n
     D count           s              3  0                                      LINE COUNTER
     D eofi            s              1
     D error           s               n
     D first           s              1
     D forevr          s              1
     D i               s                   like(ipuqty)
     D impdte          s              8  0
     D importError     s               n
     D imptim          s              6  0
     D kyitem          s                   like(ipuitm)
     D len             s              1  0
     D linppg          s              3  0                                      MAX LINES PER PAGE
     D pflag           s              1
     D pos             s              1  0
     d prdSlot         s             12
730eAd parSlot         s             12
     D stamp           s               z
     D stampUC         s               z
     D today           s              8  0
     D work3a          s              3
     D workupc         s                   like(upupc)
     D wkcust          s                   like(ipucust)

     D unexta          s             13
     D $unext          s             13  0

730bAd perrmsg         s             99
730bAd psessid         s             40
730bAd pdpcombo        s             20
730bAd calpwhse        s              3  0
730bAd calpentdate     s              8  0
730bAd calpdktexpd     s              8  0
730cAd BuildItem       s             15
DRYcAD  uciqty1        s              5  0
DRYcAD  uciqty2        s              5  0
DRYcAD  uciqty3        s              5  0
DRYcAD  uciwgt         s              9  2
DRYcAD chgqt1          s                   like($saqty1)
DRYcAD chgqt2          s                   like($saqty2)
DRYcAD chgqt3          s                   like($saqty3)
DRYcAD  $ppartime      s               Z
DRYdAD wrkpline        s                   like(IPULNENO)
730fAd wkupc           s             20
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  eritem                 1     15
     *
730dA*----------------------------------------------------------------
730dA*  Customer id
730dA*
DRYaA /COPY QCOPYSRC,ID#dairyla
740aA /copy qcopysrc,hostsystem
     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D $pWhse          s              3p 0
     D $pWhse3A        s              3
     D $pBatId         s             11
     D $pReturn        s             10
     D $pMessage       s            200

     *----------------------------------------------------------------
     *  Program info data structure
     *
      /copy qcopysrc,c#pgminfds
     *

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D sbrec         E ds                  extname(stgbatch) inz(*EXTDFT)
     D iprec         E ds                  extname(itemprd) inz(*EXTDFT)
     D pdrec         E ds                  extname(prddate) inz(*EXTDFT)
     D custrec       E ds                  extname(custmast) inz(*EXTDFT)
     D uprec         E ds                  extname(upc) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse  - Warehouse
     *      $pBatId - Batch id
     *
     *    Returned Parameters
     *      $PWHSE  Warehouse to process.
     *      $pReturn  - Return code
     *      $pMessage - Return message
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pWhse3A
     c                   parm                    $pBatId
     c                   parm                    $pReturn
     c                   parm                    $pMessage


      /free
            // Set SQL default parms
            exec sql
              set Option Commit=*none, Dlyprp=*Yes,
                         Closqlcsr = *ENDMOD;
      /end-free
     c                   eval      $pWhse = %dec($pWhse3A: 3: 0)
     c                   eval      $pReturn = '*OK'
     c                   eval      $pMessage = ' '
     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     * Main line
     *
     * Update stgbatch record to start process
     *
     C                   exsr      zzzStart
     C                   if        $pReturn <> '*OK'
     C                   return
     C                   endif
     *
     * Whip through all the download uci production records.
     *
     C                   eval      first = *on
     C                   eval      pflag = *on
     C                   eval      eofi = *off
     C                   eval      linppg = 55                                  MAX LINES PER PAGE
     C                   eval      count = 0                                    LINE COUNTER
     *
     C     keysit        setll     impsuprd
     C                   dou       eofi = *on
     *
     C     keysit        reade     impsuprd                               79
     C                   eval      error = *off
     C                   if        *in79
     C                   eval      eofi = *on
     C                   goto      enddup
     C                   endif
     *
     *  Skip processed records.
     *
     C                   if        ipustatus <> 'R'
     C                   iter
     C                   endif
     *
730cA*
730cA*    Build Dakota item - (canopy item - canopy whse)
ASPaM*    For Aspen clients, append warehouse to item number
730cA*
730cA /free
ASPaD   //if client = Dairyland and clientloc = DM01;
ASPaM   if hostSys = Aspen;
730cA     BuildItem = %trim(ipuitm) + '-'
730cA               + %subst(%editc(ipuwhs:'X'):2:2);
730dA   else;
730cA     BuildItem = ipuitm;
730dA   endif;
730cA /end-free
730cA*
730cA*    Set customer to 0 if -1 is sent in.
730cA*
730cA /free
ASPaD   //if client = Dairyland and clientloc = DM01;
ASPaM   if hostSys = Aspen;
730cA     if ipucust < 0;
730cA       ipucust = 0;
730cA     endif;
730dA   endif;
730cA /end-free
DRYdA*
DRYdA*    Set up wrkpline
DRYdA*
DRYdA /free
ASPaA   if hostSys = Aspen
ASPaD   //if client = Dairyland
ASPaD      //and clientloc = DM01
DRYdA      and ipulneno = 999;
DRYdA     wrkpline = 1;
DRYdA   else;
DRYdA     wrkpline = ipulneno;
DRYdA   endif;
DRYdA /end-free
DRYdA
     *
     *    Error check for update/add.
     *
     C                   exsr      zzchki
     *
     C                   if        error = *off
730fA /free
730fA   exsr loadupc;
730fA /end-free
DRYcAc                   select
ASPaDc*                  when      client = Dairyland
ASPaDc*                            and clientloc = DM01
ASPaMc                   when      hostSys = Aspen
DRYcAc                             and ipulneno = 888
DRYcAC                   exsr      zzupdUsage
DRYdAc                   other
     C                   exsr      zzupd
DRYcAc                   endsl
     C                   endif
     *
     C                   if        error = *on
     *
     *  Print report heading if necessary.
     *
     C                   if        pflag = *on  or
     C                             count >= linppg
     C                   eval      count = 0
     C                   write     head1
     C                   add       3             count
     C                   eval      pflag = *off
     C                   endif
     *
     C                   write     detail
     C                   add       1             count
     C                   endif
     *
     C                   if        error
     C                   eval      importError = *on
     C                   eval      ipustatus = 'E'
     C                   eval      iputext   = detmsg
     C                   else
     C                   eval      ipustatus = 'S'
     C                   eval      iputext = ' '
     C                   endif
     C                   exsr      zzzGetStamps
     C                   eval      ipuststs = stamp
     C                   eval      ipustsuc = stampuc
     C                   update    ipurec
     *
     C     enddup        tag
     C                   enddo
     *
     *  Print record error grand totals.
     *
     C                   if        noitem > *zeros
     C                   if        count >= linppg
     C                   write     head1
     C                   endif
     C                   write     grndttl
     C                   endif
     *
     *  We are finished so get out.
     *
     C                   exsr      zzzEnd
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
730dA*
730dA* Get client id.
730dA*
730dAC                   call      'GETCLIENT'
730dAC                   parm                    client           10
730dAC                   parm                    clientloc        10
740aAC                   parm                    cliInit           3
740aAC                   parm                    hostSys          10
730dA*
     *
     * Key definitions
     *
     *
     *  Define key for impsuprd file.
     *
     C     keysit        klist
     C                   kfld                    $pWhse
     C                   kfld                    $pBatId
     *
     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *  AddUCI    Add Uci's from production
     *----------------------------------------------------------------

     C     AddUCI        begsr
      *
      *  convert the uci to load individual fields like weight and serial
      *
      /free
        //exsr ConvertUCI;
        exsr clr$uciinfo;
        for i = 1 to ipuqty;
          $uiWhse = ipuwhs;
730cD     //$uiItem = ipuitm;
730cM     $uiItem = BuildItem;
          $uiuci = ipuuci;
          ucilic#($unext: ipuwhs);
          unexta = %editc($unext:'X');
          $uiuciLcns = 'U:' + unexta;
          $uiLcns = $pptolcns;
          $uiseq = $uiseq +1;
          // for now load blank need to convert barcode to get this
          if $bcSer#Sent;
            $uiSerial = $bcSer#;
          endif;
          if $bcPNtLbSent;
            $uiwgtlbs = $bcPNtLb;
          endif;
          if $bcPNtKgSent;
            $uiWgtKgs = $bcPNtKg;
          endif;
          $uiSelTrn# = 0;
          $uiSelLbl# = 0;
          $uiSelOrd = 0;
          $uiSelSeq = 0;
          $uiSelCSeq = 0;
          $uiSelTrax = ' ';
740cD     //$uiCrtBy = 'C';
740cM     $uiCrtBy = 'D';
          if $bcGtin = *blanks;
             $uiaGtin = 0;
          else;
             $uiaGtin   = %DEC($bcGTin:14:0);
          endif;
          $uiaLot    = $bclot;
DRYdA     Select;
ASPaM       when hostSys = Aspen
ASPaD       //when client = Dairyland
ASPaD            //and clientloc = DM01
DRYdA            and ipulneno = 999;
DRYdA         $uiaUTyp   = '1';
DRYdA         $uiaSlUTyp = '1';
DRYdA       other;
              $uiaUTyp   = uputyp;
              $uiaSlUTyp = uputyp;
DRYdA     endsl;
          // convert expiration date if sent
          select;
            when $bcSlByDSent;
              $cvcmd = '*YMDCMD ';
              $cvd6i = %char($bcSlByD);
              cvtdte ($cvtdt);
              $uiaExpD = $cvd8o;
              $uiaExpD = %dec(%char(
              %date($uiaExpD:*iso) - %days($imuday) :*iso0):8:0);
            when $bcExpDSent;
              $cvcmd = '*YMDCMD ';
              $cvd6i = %char($bcExpD);
              cvtdte ($cvtdt);
              $uiaExpD = $cvd8o;
              $uiaExpD = %dec(%char(
              %date($uiaExpD:*iso) - %days($imuday) :*iso0):8:0);
730bA       when $bcProdDSent;
730bA         $cvcmd = '*YMDCMD ';
730bA         $cvd6i = %char($bcProdD);
730bA         cvtdte ($cvtdt);
730bA         // now calculate dakota expiration date
730bA         calpentdate = $cvd8o;
730bA         caldktexp(perrmsg: psessid: #user: pdpcombo:
730cD                   //ipuwhs: ipuitm: calpentdate: calpdktexpd);
730cM                   ipuwhs: BuildItem: calpentdate: calpdktexpd);
730bA         $cvd8o = calpdktexpd;
730bA         $uiaExpD = $cvd8o;
730bA       when $bcPackDSent;
730bA         $cvcmd = '*YMDCMD ';
730bA         $cvd6i = %char($bcPackD);
730bA         cvtdte ($cvtdt);
730bA         // now calculate dakota expiration date
730bA         calpentdate = $cvd8o;
730bA         caldktexp(perrmsg: psessid: #user: pdpcombo:
730cD                   //ipuwhs: ipuitm: calpentdate: calpdktexpd);
730cM                   ipuwhs: BuildItem: calpentdate: calpdktexpd);
730bA         $cvd8o = calpdktexpd;
730bA         $uiaExpD = $cvd8o;
          endsl;
          $uiaEntD   = today;
          // Lets add some more stuff for tracking
          $uiaction = 'CANIMPORT';
          $uiaolcns = $uilcns;
          $uialcns = $uilcns;
          $uiaoseq = $uiseq;
          $uiscan = 'N';

          $dricommand = '*UCIINFO';
          $drisubcmd  = '%ADD';
          $drisys2upd = 'D';
          exsr zzzdricop;
        endfor;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *  ConvertUCI Convert the UCI
     *----------------------------------------------------------------

     C     ConvertUCI    begsr
     C                   eval      $cbcmd = '*ALL    '
     C                   eval      $cbbar = ipuuci
     c                   clear                   $barcode
     c                   clear                   $barcode2
     c                   clear                   $cvtdata
     c                   clear                   $cvtdata2
     *
     C                   call      'CVTBAR'
     C                   parm                    $cbcmd            8
     C                   parm                    $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
     C                   parm                    $cbven           10 0
     C                   parm                    $cvtdata
     C                   parm                    $cvtdata2
     C                   parm      $pwhse        $cbwhse
     c                   eval      $barcode = $cvtdata
     c                   eval      $barcode2 = $cvtdata2
     C                   endsr
     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

DRYcA*----------------------------------------------------------------
DRYcA*  clr$license  Clear $license data structure fields
DRYcA*----------------------------------------------------------------
DRYcA
DRYcAC     clr$license   begsr
DRYcAC                   eval      savever# = $liver#
DRYcAC                   clear                   $license
DRYcAC                   eval      $liver# = savever#
DRYcAC                   eval      $liemp# = 0
DRYcAC                   eval      $liuser = #curruser
DRYcAC                   eval      $lipgm  = #pgm
DRYcAC                   eval      $lijob  = #job
DRYcAC                   eval      $lijobn = #jobnbr
DRYcAC                   eval      $liTowhse = $pwhse
DRYcAC                   eval      $liTowhseu = *on
DRYcAC                   endsr
DRYcA
DRYcA*----------------------------------------------------------------
DRYcA*  clr$slot  Clear $slot data structure fields
DRYcA*----------------------------------------------------------------
DRYcA
DRYcAC     clr$slot      begsr
DRYcAC                   eval      savever# = $slver#
DRYcAC                   clear                   $slot
DRYcAC                   clear                   $slot2
DRYcAC                   eval      $slver# = savever#
DRYcAC                   eval      $saemp#U = *on
DRYcAC                   eval      $saemp# = 0
DRYcAC                   endsr

     **----------------------------------------------------------------
     **  clr$uciinfo  Clear $uciinfo data structure fields
     **----------------------------------------------------------------

     C     clr$uciinfo   begsr
     C                   eval      savever# = $uiver#
     C                   clear                   $uciinfo
     C                   eval      $uiver# = savever#
     C                   eval      $uiaddemp = 0
     C                   eval      $uiaddusr = #user
     C                   eval      $uiaddpgm  = #prog
     C                   eval      $uiaddjob  = #job
     C                   eval      $uiaddnbr = #jobn
     C                   endsr
     *----------------------------------------------------------------
     *  GETITEM      Get item info from driitem
     *----------------------------------------------------------------
      /free
        begsr getitem;
          exsr clr$item;

          $itWhse = $pwhse;
730cD     //$ititem = ipuitm;
730cM     $ititem = BuildItem;

          $dricommand = '*ITEM';
          $drisubcmd  = '%GETALL';
          $drisys2upd = 'D';
          ck4err = *on;
          exsr zzzdricop;
        endsr;
      /end-free

     *----------------------------------------------------------------
     *  GETSLOT      Get slot for production
     *----------------------------------------------------------------
      /free
        begsr getslot;
          $ppwhdpu = *on;
          $ppwhdp  = $itwhdp;
          $ppitemu = *on;
730cD     //$ppitem  = ipuitm;
730cM     $ppitem  = BuildItem;
          // do we have a slot for this item already
          if ipucust = 0;
            // set default customer# to 99999999999
            wkcust = 99999999999;
          else;
            wkcust = ipucust;
          endif;
DRYdA     // we don't look for a customer specific slot for pline 999
DRYdA     // box breaker line 999 goes to PAR slot if no pick slot
730cD     //chain (ipuwhs:wkcust:ipuitm) pcslot;
DRYdA     select;
ASPaM       when hostSys = Aspen
ASPaD       //when client = Dairyland
ASPaD            //and clientloc = DM01
DRYdA            and ipulneno = 999;
DRYdA         chain (ipuwhs:wrkpline) plined;
DRYdA         $ppdesc = indesc;
DRYdA         prdSlot = ' ';
DRYdA         parSlot = ' ';
DRYdA         $ppdestu = *on;
DRYdA         $ppparau = *on;      // set values to look customer
DRYdA         $pppara = instkaisl;
DRYdA         $ppdest = 'P';

DRYdA         $ppwhseu = *on;
DRYdA         $ppwhse  = $pwhse;
DRYdA         $pplnenou = *on;
DRYdA         $pplneno = wrkpline;
DRYdA         $ppcustu = *on;
DRYdA         $ppcust = wkcust;
DRYdA         $ppcustwo = ' ';
DRYdA         $ppcustwou = *on;
DRYdA         $ppcord = 0;
DRYdA         $ppcordu =*on;
DRYdA         $pptypeu = *on;
DRYdA         $pptype = 'A';
DRYdA         $ppuser = #User;
DRYdA         $ppuseru = *on;

DRYdA         // convert expiration date if sent
DRYdA         select;
DRYdA           when $bcSlByDSent;
DRYdA             $cvcmd = '*YMDCMD ';
DRYdA             $cvd6i = %char($bcSlByD);
DRYdA             cvtdte ($cvtdt);
DRYdA             $ppExpDt = $cvd8o;
DRYdA             $ppExpDtU = *on;
DRYdA             $ppExpDt = %dec(%char(
DRYdA             %date($ppExpDt:*iso) - %days($imuday) :*iso0):8:0);
DRYdA           when $bcExpDSent;
DRYdA             $cvcmd = '*YMDCMD ';
DRYdA             $cvd6i = %char($bcExpD);
DRYdA             cvtdte ($cvtdt);
DRYdA             $ppExpDt = $cvd8o;
DRYdA             $ppExpDt = %dec(%char(
DRYdA             %date($ppExpDt:*iso) - %days($imuday) :*iso0):8:0);
DRYdA             $ppExpDtU = *on;
DRYdA           when $bcProdDSent;
DRYdA             $cvcmd = '*YMDCMD ';
DRYdA             $cvd6i = %char($bcProdD);
DRYdA             cvtdte ($cvtdt);
DRYdA             // now calculate dakota expiration date
DRYdA             calpentdate = $cvd8o;
DRYdA             caldktexp(perrmsg: psessid: #user: pdpcombo:
DRYdA                      //ipuwhs: ipuitm: calpentdate: calpdktexpd);
DRYdA                     ipuwhs: BuildItem: calpentdate: calpdktexpd);
DRYdA             $cvd8o = calpdktexpd;
DRYdA             $ppExpDt = $cvd8o;
DRYdA             $ppExpDtU = *on;
DRYdA           when $bcPackDSent;
DRYdA             $cvcmd = '*YMDCMD ';
DRYdA             $cvd6i = %char($bcPackD);
DRYdA             cvtdte ($cvtdt);
DRYdA             // now calculate dakota expiration date
DRYdA             calpentdate = $cvd8o;
DRYdA             caldktexp(perrmsg: psessid: #user: pdpcombo:
DRYdA                      //ipuwhs: ipuitm: calpentdate: calpdktexpd);
DRYdA                     ipuwhs: BuildItem: calpentdate: calpdktexpd);
DRYdA             $cvd8o = calpdktexpd;
DRYdA             $ppExpDt = $cvd8o;
DRYdA             $ppExpDtU = *on;
DRYdA         endsl;
DRYdA         $dricommand = '*PROD';
DRYdA         $drisubcmd = '%GETSLOT';
DRYdA         $drisys2upd = 'D';
DRYdA         ck4err = *on;
DRYdA         exsr zzzDriCop;
DRYdA         // Customer Production slot found
DRYdA         if not error;
DRYdA           prdSlot = $ppshpar;
DRYdA           parSlot = $ppparar;
DRYdA         endif;
DRYdA       other;
730cM         chain (ipuwhs:wkcust:BuildItem) pcslot;
              if %found(pcslot);
                prdslot = csdisp;
              else;
DRYdD           //chain (ipuwhs:ipulneno) plined;
DRYdM           chain (ipuwhs:wrkpline) plined;
                $ppdesc = indesc;
                prdSlot = ' ';
730eA           parSlot = ' ';
                $ppdestu = *on;
730dA           if ipucust = 0;
730dA             $ppparau = *on;      // set values to look customer
730dA             $pppara = instkaisl;
730dA             $ppdest = 'P';
730dA           else;
                  $ppshpau = *on;      // set values to look customer
                  $ppshpa = inpckaisl;
                  $ppdest = 'C';
730aA           endif;

                $ppwhseu = *on;
                $ppwhse  = $pwhse;
                $pplnenou = *on;
                $pplneno = ipmfgno;
                $ppcustu = *on;
                $ppcust = wkcust;
                $ppcustwo = ' ';
                $ppcustwou = *on;
                $ppcord = 0;
                $ppcordu =*on;
                $pptypeu = *on;
                $pptype = 'A';
                //$ppqty1u = *on;
                $ppuser = #User;
                $ppuseru = *on;

                // convert expiration date if sent
                select;
                  when $bcSlByDSent;
                    $cvcmd = '*YMDCMD ';
                    $cvd6i = %char($bcSlByD);
                    cvtdte ($cvtdt);
                    $ppExpDt = $cvd8o;
                    $ppExpDtU = *on;
                    $ppExpDt = %dec(%char(
                    %date($ppExpDt:*iso) - %days($imuday) :*iso0):8:0);
                  when $bcExpDSent;
                    $cvcmd = '*YMDCMD ';
                    $cvd6i = %char($bcExpD);
                    cvtdte ($cvtdt);
                    $ppExpDt = $cvd8o;
                    $ppExpDt = %dec(%char(
                    %date($ppExpDt:*iso) - %days($imuday) :*iso0):8:0);
                    $ppExpDtU = *on;
730bA             when $bcProdDSent;
730bA               $cvcmd = '*YMDCMD ';
730bA               $cvd6i = %char($bcProdD);
730bA               cvtdte ($cvtdt);
730bA               // now calculate dakota expiration date
730bA               calpentdate = $cvd8o;
730bA               caldktexp(perrmsg: psessid: #user: pdpcombo:
730cD                      //ipuwhs: ipuitm: calpentdate: calpdktexpd);
730cM                     ipuwhs: BuildItem: calpentdate: calpdktexpd);
730bA               $cvd8o = calpdktexpd;
730bA               $ppExpDt = $cvd8o;
730bA               $ppExpDtU = *on;
730bA             when $bcPackDSent;
730bA               $cvcmd = '*YMDCMD ';
730bA               $cvd6i = %char($bcPackD);
730bA               cvtdte ($cvtdt);
730bA               // now calculate dakota expiration date
730bA               calpentdate = $cvd8o;
730bA               caldktexp(perrmsg: psessid: #user: pdpcombo:
730cD                      //ipuwhs: ipuitm: calpentdate: calpdktexpd);
730cM                     ipuwhs: BuildItem: calpentdate: calpdktexpd);
730bA               $cvd8o = calpdktexpd;
730bA               $ppExpDt = $cvd8o;
730bA               $ppExpDtU = *on;
                endsl;
                $dricommand = '*PROD';
                $drisubcmd = '%GETSLOT';
                $drisys2upd = 'D';
                ck4err = *on;
                exsr zzzDriCop;
                // Customer Production slot found
                if not error;
                  prdSlot = $ppshpar;
730eA             parSlot = $ppparar;
                endif;
              endif;
DRYdA     endsl;
        endsr;
      /end-free

730fA*----------------------------------------------------------------
730fA*
730fA*  LoadUPC - Load the UPC if needed
730fA*
730fA*----------------------------------------------------------------
730fA /free
730fA  begsr LoadUPC;

730fA    // does the upc exist
730fA    wkupc = '      ' + $bcgtin;
730fA    exec sql select * into :uprec
730fA         from upc
730fA         where upwhse = :$itwhse
730fA           and upupc = :wkupc
730fA           and upitem = :builditem
730fA           and upuom  = :$itum1
730fA         fetch first row only;
730fA    if sqlstt <> sqlSuccess;
730fA      upwhse = $itwhse;
730fA      upitem = buildItem;
730fA      upupc = wkupc;
730fA      upven = 0;
730fA      upvnam = ' ';
730fA      upvitm = ' ';
730fA      upbran = ' ';
730fA      upuom = $itum1;
730fA      uputyp = 'N';
730fA      upctyp = '3';
730fA      exec sql insert into upc values(:uprec);
730fA    endif;

730fA  endsr;
730fA /end-free
     *----------------------------------------------------------------
     *
     *  ZZCHKI   Item update error checking.
     *
     C     zzchki        begsr
     C                   eval      error = *off
     *
     *  Item cannot be blank
     *
      /free
        if ipuitm = *blanks;
          error = *on;
          detmsg = desc(2);
          noitem = noitem + 1;
          leavesr;
        endif;
      /end-free
     *
     *  Verify item exists
     *
      /free
        exsr getitem;
        if error = *on;
          detmsg = desc(1);
          noitem = noitem + 1;
          leavesr;
        endif;
      /end-free
     *
     *  Verify Quantity exists
     *
      /free
        if ipuqty <= 0;
          error = *on;
          detmsg = desc(3);
          noitem = noitem + 1;
          leavesr;
        endif;
      /end-free
     *
     *  Verify UCI exists
     *
      /free
        if ipuuci = ' ';
          error = *on;
          detmsg = desc(4);
          noitem = noitem + 1;
          leavesr;
        endif;
      /end-free
DRYcA*
DRYcA*  Scan to usage has a different set of rules
DRYcA*
DRYcA /free
ASPaD   //if client = Dairyland and clientloc = DM01
ASPaM   if hostSys = Aspen
DRYcA      and ipulneno = 888;
DRYcA     exsr zzchk4usage;
DRYcA     leavesr;
DRYcA   endif;
DRYcA /end-free
     *
     *  Date sensitve items must have a date in the UCI
     *
      /free
        if $itflgd = 'Y';
          // we are planning for the expiration date to be sent
          // if not we will code for the manufacture date and calculate
          // a Dakota expiration date.
          // convert the uci - to see if date is included
          exsr ConvertUCI;
          if $bcProdDSent or $bcPackDSent or
             $bcSlByDSent or $bcExpDSent;

          else;
            error = *on;
            detmsg = desc(7);
            noitem = noitem + 1;
            leavesr;
          endif;
        endif;
      /end-free
     *
     *  Production line must exist
     *
      /free
        if ipulneno = 0;
          error = *on;
          detmsg = desc(5);
          noitem = noitem + 1;
          leavesr;
        endif;
      /end-free
     *
     *  Production line must be valid
     *
      /free
DRYdD   //chain (ipuwhs:ipulneno) plined;
DRYdM   chain (ipuwhs:wrkpline) plined;
        if not %found(plined);
          error = *on;
          detmsg = desc(5);
          noitem = noitem + 1;
          leavesr;
        endif;
      /end-free
     *
     *  item defined as unique uci - qty must be 1
     *
      /free
        if $ifucicde = '2' and ipuqty <> 1;
          error = *on;
          detmsg = desc(6);
          noitem = noitem + 1;
          leavesr;
        endif;
      /end-free

     *
     *  item defined as unique uci - make sure uci does not exist
     *
      /free
        if $ifucicde = '2';
          $uiWhse = ipuwhs;
          $uiuci  = ipuuci;
730cD     //$uiitem = ipuitm;
730cM     $uiitem = BuildItem;

          $dricommand = '*UCIINFO';
          $drisubcmd  = '%CHKACTV';
          $drisys2upd = 'D';
          ck4err = *on;
          exsr zzzdricop;
          if error = *on;
            error = *on;
            detmsg = $drimessage;
            noitem = noitem + 1;
            leavesr;
          endif;
        endif;
      /end-free
DRYdA*
DRYdA*  Check to make sure item has a breakdown one uom
DRYdA*
DRYdA /free
ASPaM    if hostSys = Aspen
ASPaD    //if client = Dairyland
ASPaD       //and clientloc = DM01
DRYdA       and ipulneno = 999;
DRYdA      if $itum2 = ' ';
DRYdA        error = *on;
DRYdA        detmsg = 'Item does not have Breakdown';
DRYdA        noitem = noitem + 1;
DRYdA        leavesr;
DRYdA      endif;
DRYdA    endif;
DRYdA /end-free
     *
     *  Check for ITEMPRD record - create if not found
     *
      /free
        exec sql select * into :iprec
                 from itemprd
                 where ipwhse = :ipuwhs
730cD              //and ipitem = :ipuitm;
730cM              and ipitem = :Builditem;

        if sqlstt = sqlSuccess;
        else;
	         ipwhse = ipuwhs;
730cD     //ipitem = ipuitm;
730cM     ipitem = BuildItem;
	         ipprdflg = 'F';
DRYdA     // we always want to load production line 1 because we use
DRYdA     // production line 1 data to load inventory. We only use
DRYdA     // production line 999 as an indicator that it is a box
DRYdA     // breaker record
DRYdD     //ipmfgno = ipulneno;
DRYdM     ipmfgno = wrkpline;
          ipmorp = 'M';
          ipprdq = 0;
          ipsubp = 0;
          ipbrkr = 'N';
          exec sql insert into itemprd values(:iprec);
        endif;
      /end-free
     *
     *  Check for PRDDATE record - create if not found, Update if needed
     *
      /free
        exec sql select * into :pdrec
                 from prddate
                 where pdwhse = :ipuwhs
DRYdD              //and pdline = :ipulneno;;
DRYdM              and pdline = :wrkpline;;

        if sqlstt = sqlSuccess;
          if pddate <> today;
            exec sql
                 update prddate
                   set pddate = :today
                   where pdwhse = :ipuwhs
DRYdD                //and pdline = :ipulneno;
DRYdM                and pdline = :wrkpline;
          endif;
        else;
         // Edits have passed and we will now add a record for a specific
         // Mfg Line for a specific Production Date

         pdwhse = ipuwhs;
DRYdD    //pdLine = ipulneno;
DRYdM    pdLine = wrkpline;
         pddate = today;
         pdStat = 'O';
         exec sql insert into prdDate values(:pdrec);
        endif;
      /end-free
     *
     *  Check for CUSTMAST record - add if needed.
     *
      /free
        if ipucust = 0;
          wkcust = 99999999999;
        else;
          wkcust = ipucust;
        endif;
        exec sql select * into :custrec
                 from custmast
                 where cmcust = :wkcust;

        if sqlstt = sqlSuccess;
        else;
          // create when not found
730aA     cmwhse = ipuwhs;
          cmcust = wkcust;
          cmname = 'AUTO LOADED';
          exec sql insert into CustMast values(:custrec);
        endif;
      /end-free
DRYdA*
DRYdA*  Does the item have a pick slot
DRYdA*
DRYdAC                   eval      $scmd = '*FRSTPCK'
DRYdAC                   call      'GETPSLT'
DRYdAC                   parm                    $scmd             8
DRYdAC                   parm      $itwhse       $swhse            3 0
DRYdAC                   parm      builditem     #sitem           15
DRYdAC                   parm                    woslot           12
DRYdAC                   parm      *blanks       $saisl            3
DRYdAC                   parm      *zeros        $sloc             3 0
DRYdAC                   parm      *zeros        $srlvl            2 0
DRYdAC                   parm      *blanks       $shand            2
DRYdAC                   parm                    $srtn             8
     C     endcki        endsr
     *----------------------------------------------------------------
     *  updProdSlot -   Get the correct production slot based on type
     *                  of transaction/item being processed
     *                  and add quantity that slot.
     *----------------------------------------------------------------

     C     updProdSlot   begsr
      /free

        savever# = $ppver#;
        clear $pprod;
        clear $pprod2;
        $ppver# = savever#;

DRYdD   //if ipulneno <> 0;
DRYdD     //chain (ipuwhs:ipulneno) plined;
DRYdM   if wrkpline <> 0;
DRYdM     chain (ipuwhs:wrkpline) plined;
          if %found(plined);
            $ppdesc = indesc;
            //prdSlot = ' ';
            $ppdestu = *on;
730dA       if ipucust = 0;
730dA         $ppparau = *on;      // set values to look stk slt
730dA         $pppara = instkaisl;
730dA         $ppdest = 'P';
730dA       else;
              $ppshpau = *on;      // set values to look fcust slt
              $ppshpa = inpckaisl;
              $ppdest = 'C';
730dA       endif;
730dD       //$ppparau = *off;      // else set to blank
730dD       //$pppara = ' ';
          endif;
        endif;

        $ppwhdpu = *on;
        $ppwhdp  = $itwhdp;
        $ppitemu = *on;
730cD   //$ppitem  = ipuitm;
730cM   $ppitem  = BuildItem;

        $ppshpar = prdSlot;
730eA   $ppparar = parSlot;
730eA   if $ppparar <> ' ';
730eA     $pppararu = *on;
730eA   endif;
        $ppgs1u = *on;
        $ppgs1 = ipuuci;
        $ppser#u = *on;
        $ppser# = ' ';
        $ppwgtu = *off;
        $ppwgt = 0;
        $pptareu = *on;
        $pptare = 0;
        $ppActionu = *on;
ASPaD   //if client = Dairyland
ASPaD      //and clientloc = DM01
ASPaM   if hostSys = Aspen
DRYdA      and ipulneno = 999;
DRYdA     $ppAction = 'CBB';
DRYdA   else;
          $ppAction = 'PIN';
DRYdA   endif;
        $ppuseru = *on;
        $ppuser  = #user;
        $ppwhseu = *on;
        $ppwhse  = ipuwhs;
        $pplnenou = *on;
DRYdD   //$pplneno = ipulneno;
DRYdM   $pplneno = wrkpline;
        $ppscaleu = *on;
        $ppscale = ' ';
        $ppcustu = *on;
        if ipucust = 0;
          $ppcust = 99999999999;
        else;
          $ppcust = ipucust;
        endif;
        $pptypeu = *on;
        $pptype = 'P';
        select;
ASPaD     //when client = Dairyland
ASPaD          //and clientloc = DM01
ASPaA     when hostSys = Aspen
DRYdA          and ipulneno = 999;
DRYdA       $ppqty2u = *on;
DRYdA       $ppqty2 = ipuqty;
          when uputyp = 'N';
            $ppqty1u = *on;
            $ppqty1 = ipuqty;
          when uputyp = '1';
            $ppqty2u = *on;
            $ppqty2 = ipuqty;
          when uputyp = '2';
            $ppqty3u = *on;
            $ppqty3 = ipuqty;
          other;
            $ppqty1u = *on;
            $ppqty1 = ipuqty;
        endsl;
        $ppadjcdeu = *on;
        $ppadjcde = 'CP';
        $ppwo#u = *on;
        $ppwo# = ' ';
        $ppuciu = *on;
        $ppuci = ' ';
        $ppdspbbu = *off;
        $ppdspbb = *blanks;
        $pptrn#u = *off;
        $pptrn# = *zeros;

        // convert expiration date if sent
        select;
          when $bcSlByDSent;
            $cvcmd = '*YMDCMD ';
            $cvd6i = %char($bcSlByD);
            cvtdte ($cvtdt);
            $ppExpDt = $cvd8o;
            $ppExpDtU = *on;
            $ppExpDt = %dec(%char(
            %date($ppExpDt:*iso) - %days($imuday) :*iso0):8:0);
          when $bcExpDSent;
            $cvcmd = '*YMDCMD ';
            $cvd6i = %char($bcExpD);
            cvtdte ($cvtdt);
            $ppExpDt = $cvd8o;
            $ppExpDt = %dec(%char(
            %date($ppExpDt:*iso) - %days($imuday) :*iso0):8:0);
            $ppExpDtU = *on;
730bA     when $bcProdDSent;
730bA       $cvcmd = '*YMDCMD ';
730bA       $cvd6i = %char($bcProdD);
730bA       cvtdte ($cvtdt);
730bA       // now calculate dakota expiration date
730bA       calpentdate = $cvd8o;
730bA       caldktexp(perrmsg: psessid: #user: pdpcombo:
730cD                 //ipuwhs: ipuitm: calpentdate: calpdktexpd);
730cM                 ipuwhs: BuildItem: calpentdate: calpdktexpd);
730bA       $cvd8o = calpdktexpd;
730bA       $ppExpDt = $cvd8o;
730bA       $ppExpDtU = *on;
730bA     when $bcPackDSent;
730bA       $cvcmd = '*YMDCMD ';
730bA       $cvd6i = %char($bcPackD);
730bA       cvtdte ($cvtdt);
730bA       // now calculate dakota expiration date
730bA       calpentdate = $cvd8o;
730bA       caldktexp(perrmsg: psessid: #user: pdpcombo:
730cD                 //ipuwhs: ipuitm: calpentdate: calpdktexpd);
730cM                 ipuwhs: BuildItem: calpentdate: calpdktexpd);
730bA       $cvd8o = calpdktexpd;
730bA       $ppExpDt = $cvd8o;
730bA       $ppExpDtU = *on;
        endsl;

        $dricommand = '*PROD';
        $drisubcmd = '%IMPQTY';
        $drisys2upd = 'D';
        exsr zzzDriCop;
        if error;
          detmsg = '*PRDERR';
        else;
          prdSlot = $ppshpar;
730eA     parSlot = $ppparar;
        endif;

      /end-free
     c                   endsr

     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     * Get import date/time.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      impdte = $cvd8o
     C                   time                    imptim
     *
     * Get report heading.
     *
     C                   eval      w1head = *blanks
     C                   movel     rdsc(1)       $pstr
     C                   eval      $plen = 50
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         w1head
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             77
     C                   if        *in77
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Create warehouse heading.
     *
     C                   move      $pwhse        work3a
     C     ' 0'          check     work3a        pos
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      40            $clen             3 0
     C                   movel     $cstr         whhead
     *
     * Initialize grand total fields
     *
     C                   eval      grdlin = *zeros
     C                   eval      noitem = *zeros
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update PRD slot.
     *
     C     zzupd         begsr
     *
     * Convert Uci
     *
      /free
        exsr ConvertUCI;
        // need to get the uom for this Gtin
        if $bcGtin <> ' ';
          workupc = blank6 + $bcGtin;
          exec sql select * into :uprec
                 from upc
                 where upwhse = :ipuwhs
730cD              //and upITEM = :ipuitm
730cM              and upITEM = :BuildItem
                   and upupc  = :workupc
                 fetch first row only;

          if sqlstt = sqlSuccess;
          endif;
        else;
          uputyp = ' ';
        endif;
      /end-free
     *
     * Get the Slot
     *
      /free
DRYdA   if $SRTN = '*OKPICK ';
DRYdA     parslot = woslot;
DRYdA   else;
          exsr getslot;
DRYdA   endif;
      /end-free
     *
     * Update the slot with the production qty
     *
      /free
        exsr updProdSlot;
      /end-free
     * Write uci
     *
      /free
        exsr AddUCI;
      /end-free
     *    Accumulate total number of records processed.
     *
     C                   add       1             grdlin
     C     endupd        endsr
DRYcA*----------------------------------------------------------------
DRYcA*
DRYcA*  ZZUPDUSAGE    Make adjustment for scan to usage
DRYcA*                    then the weight being removed will be sent.
DRYcAC     zzupdusage    begsr

740aA /free
740aA   // If the weight is sent, subtract the weight from uciinfo.
740aA   if ipuwgt > 0;
740aA     exsr clr$uciinfo;
740aA     $uiWhse = ipuwhs;
740aA     $uiuci  = ipuuci;
740aA     $uiwgtlbs = ipuwgt;
740aA     // Lets add some more stuff for tracking
740aA     $uiAolcns = $uiAolcns;
740aA     $uiAoseq = $uiAoseq;
740aA     $dricommand = '*UCIINFO';
740aA     $drisubcmd  = '%REDUCE';
740aA     $drisys2upd = 'D';
740aA     exsr zzzdricop;
740aA     // On the return is the remaining lbs = 0, we will adjust uci
740aA     // out of inventory
740aA     if $drireturn <> '*OK';
740aA       detmsg = 'We did not find the UCI to reduce weight';
740aA       noitem = noitem + 1;
740aA       error = *on;
740aA       leavesr;
740aA     endif;
740aA     // On the return is the remaining lbs = 0, we will adjust uci
740aA     // out of inventory
740aA     if $uiwgtlbs > 0;
740aA       leavesr;
740aA     endif;

740aA   endif;
740aA /end-free
DRYcAC                   time                    $ppartime
DRYcA /free
DRYcA   error = *off;
DRYcA   if $uiaction = 'ADJSTART';
DRYcA     $uiWhse = ipuwhs;
DRYcA     $uiuci  = ipuuci;
DRYcA     $uiapartlts = $ppartime;

DRYcA     // Lets add some more stuff for tracking
DRYcA     $uiAolcns = $uiAolcns;
DRYcA     $uiAoseq = $uiAoseq;
DRYcA     $uiscan = 'I';
DRYcA     $dricommand = '*UCIINFO';
DRYcA     $drisubcmd  = '%UPDPARTL';
DRYcA     $drisys2upd = 'D';
DRYcA     exsr zzzdricop;
DRYcA     // if return is *OK we updated the uci record
DRYcA     if $drireturn <> '*OK';
DRYcA       detmsg = 'UCI Not Updated';
DRYcA       noitem = noitem + 1;
DRYcA       error = *on;
DRYcA       leavesr;
DRYcA     endif;
DRYcA     if $uiwgtlbs > 0;
DRYcA       uciwgt = uciwgt - $uiwgtlbs;
DRYcA     endif;
DRYcA   endif;
DRYcA /end-free
DRYcA*   Fill interface data structure fields.

DRYcAC                   exsr      clr$slot
DRYcAC                   eval      $slwhseu = *on
DRYcAC                   eval      $slwhse  = ipuwhs
DRYcAC                   eval      $slwhdpu = *on
DRYcAC                   eval      $slwhdp  = $itwhdp
DRYcAC                   eval      $sldispu = *on
DRYcAC                   eval      $sldisp  = $litodisp
DRYcAC                   eval      $saitemu = *on
DRYcAC                   eval      $saitem  = $ititem

DRYcAC                   eval      $saqtyu  = *on
DRYcAC                   eval      $saqty1  = chgqt1
DRYcAC                   eval      $saqty2  = chgqt2
DRYcAC                   eval      $saqty3  = chgqt3

DRYcAC                   eval      $sacwtau = *on
DRYcAC                   eval      $sacwta  = uciwgt
DRYcAC                   eval      $sacodeu = *on
DRYcAC                   eval      $sacode  = 'CP'
DRYcAC                   eval      $samemou = *on
DRYcAC                   eval      $samemo  = 'Scan to Usage'
DRYcAC                   eval      $sabyu   = *on
DRYcAC                   eval      $saby    = #curruser

DRYcAC                   eval      $saActionU = *on
DRYcAC                   eval      $saAction = 'ADJ'
DRYcAC                   eval      $saETrn#U = *on
DRYcAC                   eval      $saETrn# = 0
DRYcAC                   if        $imltrk = 'U'
DRYcAC                   eval      $saUCIts = $ppartime
DRYcAC                   eval      $saUCItsU = *on
DRYcAC                   else
DRYcAC                   eval      $saUCIts = *loval
DRYcAC                   eval      $saUCItsU = *on
DRYcAC                   endif
DRYcAC                   if        $imltrk = 'U'
DRYcAC                   eval      $saUCItype = '2'
DRYcAC                   eval      $saUCItypeU = *on
DRYcAC                   endif
DRYcAC                   if        $imltrk = 'U'
DRYcAC                   eval      $satolcns = $litolcns
DRYcAC                   eval      $satolcnsu = *on
DRYcAC                   endif

DRYcAC                   eval      $dricommand = '*SLOT'
DRYcAC                   eval      $drisubcmd  = '%ADJUST'
DRYcAC                   eval      $drisys2upd = 'D'
DRYcAC                   eval      ck4err = *on
DRYcAC                   exsr      zzzdricop


DRYcAC     endusage      endsr
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
     C                   add       3             count
     C                   setoff                                       81
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *  zzzEnd     End processing
     *----------------------------------------------------------------

     c     zzzEnd        begsr
      /free

        if importError;
          sbstatus = 'E';
          sbtext   = 'Import completed with error(s). See impsuprd file.';
          $pReturn = '*ERROR';
          $pMessage = sbtext;
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
                    + '- ii255s/zzzend';
          leavesr;
        endif;

      /end-free
     c                   endsr

     *----------------------------------------------------------------
     *  zzzGetStamps   Get timestamps
     *----------------------------------------------------------------

     c     zzzGetStamps  begsr
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

     *----------------------------------------------------------------
     *  zzzStart   Start processing
     *----------------------------------------------------------------

     c     zzzStart      begsr
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
                    + '- UI250s/zzzstart';
          leavesr;
        endif;

        importError = *off;

      /end-free
     c                   endsr
DRYcA*----------------------------------------------------------------
DRYcA*
DRYcA*  ZZCHK4USAGE    Check for scan to usage
DRYcA
DRYcAC     zzchk4usage   begsr
DRYcA
DRYcA*   Verify UCI usage   Rules
DRYcA
DRYcA /free
DRYcA   error = *off;
DRYcA   // is the UCI active in the system
DRYcA   exsr clr$uciinfo;

DRYcA   $uiWhse = ipuwhs;
DRYcA   $uiuci  = ipuuci;
DRYcA   $uiitem = builditem;

DRYcA   $dricommand = '*UCIINFO';
DRYcA   $drisubcmd  = '%CHK4ADJ';
DRYcA   $drisys2upd = 'D';
DRYcA   //chk4err = *on;
DRYcA   exsr zzzdricop;

DRYcA   select;

DRYcA     // adjustments removing uci's from the system
DRYcA     // 1- uci currently in slot being adjusted - good to go
DRYcA     // 2- uci currently in a different slot - we will change
DRYcA     // 2- the slot being adjusted to the slot the uci is in.
DRYcA     // 3- uci isn't active in system - exception but allow
DRYcA     // return= *OK, that means the uci is already in uciinfo
DRYcA     when $drireturn = '*OK';
DRYcA       error = *off;

DRYcA       exsr clr$license;
DRYcA       if $uilcns <> ' ';
DRYcA         $liToWhseU = *on;
DRYcA         $liToWhse = ipuwhs;
DRYcA         $liToLcnsU = *on;
DRYcA         $liToLcns = $uilcns;
DRYcA         $dricommand = '*LICENSE';
DRYcA         $drisubcmd  = '%GETLCNS';
DRYcA         $drisys2upd = 'D';
DRYcA         ck4err = *on;
DRYcA         exsr zzzdricop;
DRYcA       else;
DRYcA         // uci is not currently active in the system, do not
DRYcA         // adjust inventory.
DRYcA         detmsg = 'UCI Not Active - NOSCANTOUSAGE';
DRYcA         error = *on;
DRYcA         noitem = noitem + 1;
DRYcA         leavesr;
DRYcA       endif;
DRYcA       if $LITOdisp = ' ';
DRYcA         // uci is not currently active in the system, do not
DRYcA         // adjust inventory.
DRYcA         detmsg = 'UCI Not Active - NOSCANTOUSAGE';
DRYcA         error = *on;
DRYcA         noitem = noitem + 1;
DRYcA         leavesr;
DRYcA       endif;
DRYcA       // hold this field for update
DRYcA       //$pdisp = $litodisp;
DRYcA       exsr clr$slot;
DRYcA       $slwhseu = *on;
DRYcA       $slwhse  = ipuwhs;
DRYcA       $slwhdpu = *on;
DRYcA       $slwhdp  = $itwhdp;
DRYcA       $sldispu = *on;
DRYcA       $sldisp  = $litodisp;

DRYcA       $dricommand = '*SLOT';
DRYcA       $drisubcmd  = '%GET';
DRYcA       $drisys2upd = 'D';
DRYcA       ck4err = *on;
DRYcA       exsr zzzdricop;

DRYcA       $uiaction = 'ADJSTART';
DRYcA       uciqty1 = 0;
DRYcA       uciqty2 = 0;
DRYcA       uciqty3 = 0;
DRYcA       select;
DRYcA         when $uiautyp = 'N';
DRYcA           uciqty1 = uciqty1 - 1;
DRYcA         when $uiautyp = '1';
DRYcA           uciqty2 = uciqty2 - 1;
DRYcA         when $uiautyp = '2';
DRYcA           uciqty3 = uciqty3 - 1;
DRYcA         other;
DRYcA           uciqty1 = uciqty1 - 1;
DRYcA       endsl;
DRYcA       chgqt1 = uciqty1;
DRYcA       chgqt2 = uciqty2;
DRYcA       chgqt3 = uciqty3;
DRYcA /end-free

DRYcA*   Call interface to do verification.

DRYcAC                   exsr      clr$slot
DRYcAC                   eval      $slwhseu = *on
DRYcAC                   eval      $slwhse  = ipuwhs
DRYcAC                   eval      $slwhdpu = *on
DRYcAC                   eval      $slwhdp  = $itwhdp
DRYcAC                   eval      $sldispu = *on
DRYcAC                   eval      $sldisp  = $litodisp
DRYcAC                   eval      $saitemu = *on
DRYcAC                   eval      $saitem  = $ititem

DRYcAC                   eval      $saqtyu  = *on
DRYcAC                   eval      $saqty1  = chgqt1
DRYcAC                   eval      $saqty2  = chgqt2
DRYcAC                   eval      $saqty3  = chgqt3

DRYcAC                   eval      $sacwtau = *on
DRYcAC                   eval      $sacwta  = uciwgt

DRYcAC                   eval      $sacodeu = *on
DRYcAC                   eval      $sacode  = 'CP'

DRYcAC                   eval      $samemou = *on
DRYcAC                   eval      $samemo  = 'Scan to Usage'

DRYcAC                   eval      $sabyu   = *on
DRYcAC                   eval      $saby    = #curruser

DRYcAC                   eval      $dricommand = '*SLOT'
DRYcAC                   eval      $drisubcmd  = '%VERIFY'
DRYcAC                   eval      $drisys2upd = 'D'
DRYcAC                   eval      ck4err = *on
DRYcAC                   exsr      zzzdricop
DRYcA /free

DRYcA     when $drireturn = '*NOTACTIVE';
DRYcA       // uci is not currently active in the system, do not
DRYcA       // adjust inventory.
DRYcA       detmsg = 'UCI Not Active - NOSCANTOUSAGE';
DRYcA       error = *on;
DRYcA       noitem = noitem + 1;
DRYcA       leavesr;

DRYcA     other;
DRYcA       detmsg = $drimessage;
DRYcA       error = *on;
DRYcA       noitem = noitem + 1;
DRYcA       leavesr;
DRYcA   endsl;
DRYcA /end-free
DRYcA
DRYcAC     endck4usage   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   eval      $dridata2 = $licinfo2
     C                   when      $dricommand = '*LICHIST'
     C                   eval      $dridata = $lichist
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $dridata = $uciinfo
     C                   eval      $dridata2 = $uciinfo2
     C                   when      $dricommand = '*PROD'
     C                   eval      $dridata = $pprod
     C                   eval      $dridata2 = $pprod2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*LICENSE'
     C                             or $dricommand = '*LICINFO'
     C                             or $dricommand = '*PROD'
     C                             or $dricommand = '*UCIINFO'
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
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
     C                   eval      $licinfo2 = $dridata2
     C                   when      $dricommand = '*LICHIST'
     C                   eval      $lichist = $dridata
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $license = $dridata
     C                   eval      $license2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $uciinfo = $dridata
     C                   eval      $uciinfo2 = $dridata2
     C                   when      $dricommand = '*PROD'
     C                   eval      $pprod = $dridata
     C                   eval      $pprod2 = $dridata
     C                   endsl

     C                   eval      ck4err = *off
     C     enddricop     endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
* Invalid item
* Item number cannot be blank
* Qty cannot be less than one
* UCI cannot be blank
* Invalid Production Line
* Qty must be one.
* UCI must have a date
**
Import FTP UCI Production by Item
