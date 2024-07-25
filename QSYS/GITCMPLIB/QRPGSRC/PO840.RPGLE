      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  PO840   Purchase order receiving - offsite storage processing
     *  05 August, 2014
     *  Lynn McMahon
     *
     *
     *----------------------------------------------------------------
     *  Revisions
650 A*    08/05/14  LMC  6.50
     *      - Created
700aA*    07/11/16  LMC  7.00
     *      - Enh: adding a new field - session - to workoss for gui
     *        Add 2 new parms to send in Gui User and Session.
     *        Use User passed in instead of current user if working
     *        with Gui.
     *
740bA*    07/03/20  MLB  7.40b  ZD#2125
     *      - Enh: Changed @PRTPG to BFCPRTLBL from PRTLBL due to
     *        conflict with TL Ashford pgm of the same name.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: A&D Foods
     *
ADFaA*    09/07/17  ???  ADFa
     *      - Enh: adding label set name for OSS label.
     *----------------------------------------------------------------
     *  File Specs
     *
600dAFworkoss   uf a e           k disk
     *----------------------------------------------------------------
     *  Variables
     *
     D $pWhse          s              3  0
     D $pWhdp          s              5
     D $pOCode         s              1
     D $pPlates        s              4  0
     D $pPrint         s              1
     D $pLcns          s             15
     D $pExpd          s              8s 0
     D $pStat          s              2
     D $pDev           s             10
     D $pItem          s             15
     D $pSTyp          s              1
     D $pItdesc        s             30
700aAD $pSessid        s             40
700aAD $pUser          s             10

     D ck4err          s              1
417gMD error           s               n
600cAD extstgFlag      s               n
600dAD i               s              3  0
ICBaAD icbLcns         s               n
ICBaAD icbOlcn         s             15
     D pwhse           s              3s 0
     D today           s              8  0
600aAD zmflag          s               n
     D #msgid          s              7
     D #msgtp          s              7
500 AD #rcvarea        s              6
740bA
740bA*----------------------------------------------------------------
740bA*  Called programs
740bA*----------------------------------------------------------------
740bA
740bAD @prtpg          c                   const('BFCPRTLBL')
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
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
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.cvtdte
     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#sgc
      /COPY QCOPYSRC,Id#Eastlan
      /COPY QCOPYSRC,Id#ICB
ADFaA /COPY QCOPYSRC,ID#ADF

     *----------------------------------------------------------------
     *  Program info data structure
     *
      /COPY *libl/qcopysrc,C#PGMINFDS
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
     D savever#        s                   like($slver#)
     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
     *----------------------------------------------------------------

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
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse   Warehouse
     *      $pWhdp   Department
     *      $pOCode  Outside storage code - w3stg in po236
     *      $pPlates Number of plates for printing
     *      $pPrint  Print plates flag
     *      $pLcns   License for generic plate oss
     *      $pExpd   Expiration Date
     *      $pStat   Status
     *      $pDev    Print Device
     *      $pItem   Item
     *      $pSTyp   Section Type
700aA*      $pSessID Session Id - for Gui
700aA*      $pUser   Gui user signed on
     *
     *    Returned Parameters
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pWhse
     C                   parm                    $pWhdp
     C                   parm                    $pOCode
     C                   parm                    $pPlates
     C                   parm                    $pPrint
     C                   parm                    $pLcns
     C                   parm                    $pExpd
     C                   parm                    $pStat
     C                   parm                    $pDev
     C                   parm                    $pItem
     C                   parm                    $pSTyp
     C                   parm                    $pItdesc
700aAC                   parm                    $pSessid
700aAC                   parm                    $pUser

     *     Process outside storage information

     c                   eval      *inlr = *on
     C                   eval      extstgFlag = *on
     C                   for       i = 1 to $pPlates
     C                   exsr      zzextstg2
     C                   eval      icblcns = *off
     C                   eval      icbolcn = *blanks
     C                   if        error
     C                   leave
     C                   endif
     C                   if        client = icb
     C                   eval      icbolcn = wklic
     C                   eval      icblcns = *on
     C                   endif
     C                   endfor

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
510aA* Get client id.
510aA
510aAC                   call      'GETCLIENT'
510aAC                   parm                    client           10
700aAc                   if        $pSessId <> ' '
700aAC                   eval      $code = $pUser
700aAc                   else
700aAC                   eval      $code = #curruser
700aAc                   endif
414 A*    Get User's employee number to be written to PORCV file
414 A*    if any records are flagged as touched.
414 A*
414 AC                   call      'GETUSER'
700aDC*                  parm      #curruser     $code            10
700aMC                   parm                    $code            10
414 AC                   parm      0             $whse             3 0
414 AC                   parm      0             $emp#             5 0
414 AC                   parm      *blanks       $fnam            15
414 AC                   parm      *blanks       $init             1
414 AC                   parm      *blanks       $lnam            20
414 AC                   parm      *blanks       $whdp             5
414 AC                   parm      *blanks       $styp             1
414 AC                   parm      *blanks       $shft             6
414 AC                   parm      *blanks       $crew             6
414 AC                   parm      0             $nhrs             3 1
414 AC                   parm      *blanks       $rtn              8
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZEXTSTG2  Create OSS slot
     *
     C     zzextstg2     begsr

     *  Set #rcvarea to apppropriate OSS area.

     C                   select

     C                   when      client = sgc
     C                             and $pOCode = 'K'
     C                   eval      #rcvarea = 'KANSAS'

     C                   when      client = sgc
     C                             and $pOCode = 'W'
     C                   eval      #rcvarea = 'WILLOW'

     C                   when      client = eastland
     C                             and $pOCode = 'G'
     C                   eval      #rcvarea = 'CGEN'

     C                   when      client = eastland
     C                             and $pOCode = 'F'
     C                   eval      #rcvarea = 'CFROZ'

     C                   other
     C                   eval      #rcvarea = $pOCode

     C                   endsl

     c                   if        $pPrint = 'Y'
     c                   eval      pwhse = $pwhse
     *  Create special license

     C                   call      'PIROSSLCN'
     C                   parm                    pwhse
     C                   parm                    $pOCode
     C                   parm      ' '           wklic            15
     c                   else
     c                   eval      wklic = $pLcns
     c                   endif

     *  Initialize slot fields

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $pWhdp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = $pItem
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = ' '
     C                   eval      $slstatu = *on
     C                   eval      $slstat  = $pStat
     C                   eval      $slstypu = *on
     C                   eval      $slstyp = $pSTyp
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd = $pexpd
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = $pItem

     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = 0
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'OSS'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = 0
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = 0
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'N'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'D'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = #rcvarea

     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = wklic
     C                   eval      $saOLcnsU = *on
     C                   eval      $saOLcns = wklic

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%OSSIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmflag  = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   leavesr
     C                   endif

     *  Create workoss record

     C                   eval      wowhse  = $slwhse
     C                   eval      wowhdp  = $slwhdp
     C                   eval      wodisp  = $sldisp
     C                   eval      wolcns  = wklic
     C                   eval      woaddts   = %timestamp()
700aAc                   if        $psessid <> ' '
700aAC                   eval      woaddcusr = $pUser
700aAC                   eval      wosess    = $pSessId
700aAC                   else
     C                   eval      woaddcusr = #curruser
700aAC                   endif
     C                   eval      woaddjob  = #job
     C                   eval      woaddnbr  = #jobnbr
     C                   write(e)  worec

     c                   if        $pPrint = 'Y'
     c                   exsr      printlabel
     c                   endif

     C                   endsr
600dA*----------------------------------------------------------------
600dA*  clr$slot  Clear $slot data structure fields
600dA*----------------------------------------------------------------
600dA
600dAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
600aAC                   clear                   $slot2
     C                   eval      $slver# = savever#
600aAC                   eval      $saemp#U = *on
600aAC                   eval      $saemp# = $emp#
     C                   endsr

     *----------------------------------------------------------------
     *  PrintLabel Print Oss Label
     *----------------------------------------------------------------

     C     printlabel    begsr
     *  Print label

     C                   eval      $plfmt = 'STORAGE'
     C                   select
     C                   when      client = sgc
     C                   eval      $plset = 'ZBRSF2'
     C                   when      client = eastland
     C                   eval      $plset = 'ZBREFC'
ADFaAC                   when      client = AandDF
ADFaAC                   eval      $plset = 'ZBRADF'
     C                   other
     C                   eval      $plset = 'PLBL40'
     C                   endsl
      *
     C*                  if        w3dev <> '*JOB'
     C*                  eval      $pdev  = w3dev
     C*                  endif
      /free
           $cvcmd = '*CURCMD';
           cvtdte($cvtdt);
           today  = $cvd8o;
      /end-free
     C                   eval      $pexpda = %editc($pexpd:'X')
     C                   eval      $pindta = %editc(today:'X')

740bMC                   call      @PRTPG
     C                   parm                    $pcmd             8
     C                   parm                    $plset            6
     C                   parm                    $plfmt            8
     C                   parm      $pwhse        $plwhse           3 0
     C                   parm                    $pwhsd           30
     C                   parm                    $slwhdp
     C                   parm                    $sldisp
     C                   parm                    $pdispa           1
     C                   parm                    $pdispb          11
     C                   parm                    $pchkd1           3
     C                   parm                    $pchkd2           3
     C                   parm                    $pchkd3           3
     C                   parm                    wklic            15
     C                   parm                    $plcn2           15
     C                   parm                    $slitem
     C                   parm                    $pbrnd           10
     C                   parm                    $ppdesc          15
     C                   parm      $pitdesc      $itdesc          30
     C                   parm                    $ptxt1           30
     C                   parm                    $ptxt2           30
     C                   parm                    $ptxt3           30
     C                   parm                    $ptrailr          8
     C                   parm                    $psize            3
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $pexpda           8
     C                   parm                    $pindta           8
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
     C                   endsl

     C                   if        $dricommand = '*SLOT'
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
     C                   select
     C                   when      zmflag
     C*                  exsr      zm0105
     C                   endsl

     C                   when      $drireturn <> '*OK' and ck4err = *on
     C                   eval      error = *on
     C                   select
     C                   when      zmflag
     C                   exsr      zm0001
     C                   endsl

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      ck4err = *off
     C     enddricop     endsr

     *----------------------------------------------------------------
     *    DRI0001  Local system caused error
     *----------------------------------------------------------------

     C     zm0001        begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C*                  exsr      zmpmsg
     C                   endsr

