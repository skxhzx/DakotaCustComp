      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTRPGMOD MODULE(*) SRCFILE(*) TGTRLS(V5R2M0)
     *
     *    CRTPGM PGM(*) MODULE(*) ACTGRP(*CALLER)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  WRTLABELDO  Write LABELDO record
     *  01 June 2008
     *  Dave Sommerville
     *
     *  Revisions
     *
520 A*    06/01/08  DAS  5.20  P#00059
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fepmsumo   uf a e           k disk
     Flabeldo   uf a e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $pStampSys      s               z
     D $pStampUc       s               z

     D $gwStamp        s               z
     D $gwWeek         s              2  0
     D $gwDOW          s              1  0
     D $gwSunday       s              6  0
     D dayShift        s               t   inz(t'05.00.00')

     D error           s               n
     D forever         s               n

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')

     D bfcoffset       s              3  0 inz(0)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pcmd       *OPEN
     *                  *WRITE
     *      $pStampSys  System stamp
     *      $pStampUc   UC stamp
     *      $pwhse      Warehouse
     *      $pAct       Action
     *      $pLbl#      Label#
     *      $pItem      Repack item
     *      $pTrn#      Tran#
     *      $pTrn2#     Tran2#
     *      $pQty       Quantity
     *      $pQtyS      Short Qty
     *      $pPgm       Program
     *      $pPtype     Program type
     *      $pIp        IP Address
     *      $pUid       Unit id
     *      $pRef#      Reference number
     *      $pUser      User id
     *      $pEmp#      Employee number
     *      $pLtype     Label type
     *      $pZone      Zone
     *      $pShift     Shift
     *      $pCrew      Crew
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pCmd             8
     C                   parm                    $pStampSys
     C                   parm                    $pStampUc
     C                   parm                    $pWhse            3 0
     C                   parm                    $pAct             6
     C                   parm                    $pLbl#            7 0
     C                   parm                    $pItem           15
     C                   parm                    $pTrn#            7 0
     C                   parm                    $pTrn2#           9 0
     C                   parm                    $pQty             5 0
     C                   parm                    $pQtyS            5 0
     C                   parm                    $pPgm            10
     C                   parm                    $pPtype           6
     C                   parm                    $pIp             15
     C                   parm                    $pUid            10
     C                   parm                    $pUser           10
     C                   parm                    $pEmp#            5 0
     C                   parm                    $pRef#           13 0
     C                   parm                    $pLtype           1
     C                   parm                    $pZone            5
     C                   parm                    $pShift           6
     C                   parm                    $pCrew            6

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   if        $pCmd = '*OPEN'
     C                   return
     C                   endif

     C                   if        $pStampSys = noStamp
     C                   exsr      getcurrstamp
     C                   else
     C                   eval      currstampsys = $pStampSys
     C                   eval      currstampuc  = $pStampUc
     C                   endif

     C                   exsr      wrtLABELDO

     C                   exsr      updEPMSUMO

     C                   return

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     C     keyESO        klist
     C                   kfld                    lbowhse
     C                   kfld                    lboemp#
     C                   kfld                    lboSOW
     C                   kfld                    lboZone
     C                   kfld                    lboShift
     C                   kfld                    lboCrew

     C                   if        1<>1
     C                   update    lborec
     C                   endif
     C                   endsr

     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

     C     getcurrstamp  begsr

     C                   callp     getmicrotime(currstampuc:currstampsys)
     C     currstampsys  adddur    bfcoffset:*H  currstamploc

     C                   endsr

     *----------------------------------------------------------------
     *  updEPMSUMO    Update EPMSUMO record
     *----------------------------------------------------------------

     C     updEPMSUMO    begsr

     C     keyESO        chain(e)  epmsumo

     C                   if        not %found(epmsumo)
     C                   clear                   esorec
     C                   eval      esoWhse     = lboWhse
     C                   eval      esoEmp#     = lboEmp#
     C                   eval      esoWeek     = lboWeek
     C                   eval      esoSOW      = lboSOW
     C                   eval      esoZone     = lboZone
     C                   eval      esoShift    = lboShift
     C                   eval      esoCrew     = lboCrew
     C                   eval      esoaddts    = lboaddts
     C                   eval      esoadduc    = lboadduc
     C                   eval      esoaddpgm   = lboaddpgm
     C                   eval      esoaddjob   = lboaddjob
     C                   eval      esoaddnbr   = lboaddnbr
     C                   eval      esoaddusr   = lboaddusr
     C                   endif

     C                   if        lboLtype = 'M'
     C                   exsr      updESOMrg
     C                   else
     C                   exsr      updESOQty
     C                   endif

     C                   eval      esochgts    = lboaddts
     C                   eval      esochguc    = lboadduc
     C                   eval      esochgpgm   = lboaddpgm
     C                   eval      esochgjob   = lboaddjob
     C                   eval      esochgnbr   = lboaddnbr
     C                   eval      esochgusr   = lboaddusr

     C                   if        not %found(epmsumo)
     C                   write(e)  esorec
     C                   else
     C                   update(e) esorec
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  updESOMrg     Update EPMSUMDO Mrg
     *----------------------------------------------------------------

     C     updESOMrg     begsr

     C                   select

     C                   when      lboDOW = 1
     C                   eval      ESOMrgP1 += lboQty
     C                   eval      ESOMrgS1 += lboQtyS

     C                   when      lboDOW = 2
     C                   eval      ESOMrgP2 += lboQty
     C                   eval      ESOMrgS2 += lboQtyS

     C                   when      lboDOW = 3
     C                   eval      ESOMrgP3 += lboQty
     C                   eval      ESOMrgS3 += lboQtyS

     C                   when      lboDOW = 4
     C                   eval      ESOMrgP4 += lboQty
     C                   eval      ESOMrgS4 += lboQtyS

     C                   when      lboDOW = 5
     C                   eval      ESOMrgP5 += lboQty
     C                   eval      ESOMrgS5 += lboQtyS

     C                   when      lboDOW = 6
     C                   eval      ESOMrgP6 += lboQty
     C                   eval      ESOMrgS6 += lboQtyS

     C                   when      lboDOW = 7
     C                   eval      ESOMrgP7 += lboQty
     C                   eval      ESOMrgS7 += lboQtyS

     C                   endsl

     C                   eval      ESOMrgPT += lboQty
     C                   eval      ESOMrgST += lboQtyS

     C                   endsr

     *----------------------------------------------------------------
     *  updESOQty     Update EPMSUMDO Qty
     *----------------------------------------------------------------

     C     updESOQty     begsr

     C                   select

     C                   when      lboDOW = 1
     C                   eval      ESOQtyP1 += lboQty
     C                   eval      ESOQtyS1 += lboQtyS

     C                   when      lboDOW = 2
     C                   eval      ESOQtyP2 += lboQty
     C                   eval      ESOQtyS2 += lboQtyS

     C                   when      lboDOW = 3
     C                   eval      ESOQtyP3 += lboQty
     C                   eval      ESOQtyS3 += lboQtyS

     C                   when      lboDOW = 4
     C                   eval      ESOQtyP4 += lboQty
     C                   eval      ESOQtyS4 += lboQtyS

     C                   when      lboDOW = 5
     C                   eval      ESOQtyP5 += lboQty
     C                   eval      ESOQtyS5 += lboQtyS

     C                   when      lboDOW = 6
     C                   eval      ESOQtyP6 += lboQty
     C                   eval      ESOQtyS6 += lboQtyS

     C                   when      lboDOW = 7
     C                   eval      ESOQtyP7 += lboQty
     C                   eval      ESOQtyS7 += lboQtyS

     C                   endsl

     C                   eval      ESOQtyPT += lboQty
     C                   eval      ESOQtyST += lboQtyS
     C                   endsr

     *----------------------------------------------------------------
     *  wrtLABELDO  Write LABELDO record
     *----------------------------------------------------------------

     C     wrtLABELDO    begsr

     C                   eval      lbowhse     = $pWhse
     C                   eval      lboact      = $pAct
     C                   eval      lbolbl#     = $pLbl#
     C                   eval      lboitem     = $pItem
     C                   eval      lbotrn#     = $pTrn#
     C                   eval      lbotrn2#    = $pTrn2#
     C                   eval      lboqty      = $pQty
     C                   eval      lboqtys     = $pQtyS
     C                   eval      lbopgm      = $pPgm
     C                   eval      lboPtype    = $pPtype
     C                   eval      lboip       = $pIp
     C                   eval      lboUid      = $pUid
     C                   eval      lboRef#     = $pRef#
     C                   eval      lboLtype    = $pLtype
     C                   eval      lboEmp#     = $pEmp#
     C                   eval      lboZone     = $pZone
     C                   eval      lboShift    = $pShift
     C                   eval      lboCrew     = $pCrew

     C                   call      'GETWEEK'
     C                   parm      currstampsys  $gwStamp
     C                   parm                    $gwWeek
     C                   parm                    $gwDOW
     C                   parm                    $gwSunday

     C                   eval      lboWeek = $gwWeek
     C                   eval      lboSOW  = $gwSunday
     C                   if        %time(currstampsys)<dayShift
     C                   eval      lboDOW  = $gwDOW -1
     C                   else
     C                   eval      lboDOW  = $gwDOW
     C                   endif
     C                   if        lboDOW = 0
     C                   eval      lboDOW = 7
     C                   endif

     C                   eval      lboaddts    = currstampsys
     C                   eval      lboadduc    = currstampuc
     C                   eval      lboaddpgm   = #pgm
     C                   eval      lboaddjob   = #job
     C                   eval      lboaddnbr   = #jobnbr
     C                   eval      lboaddusr   = $pUser

     C                   write(e)  lborec
     C                   if        %error
     C                   endif

     C                   endsr
