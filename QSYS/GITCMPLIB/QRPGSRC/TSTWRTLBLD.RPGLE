      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTWRTLBLD   Test WRTLABELDO
     *  17 April 2019
     *  Dave Sommerville
     *----------------------------------------------------------------

520cAD noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')
520cAD $pStampSys      s               z
520cAD $pStampUc       s               z

      /free
         *inlr = *on;
      /end-free

520cAC                   call(e)   'WRTLABELDO'
520cAC                   parm      '*WRITE'      $pCmd             8
520cAC                   parm      noStamp       $pStampSys
520cAC                   parm      noStamp       $pStampUc
520cAC                   parm      999           $pWhse            3 0
520cAC                   parm      'VPICK'       $pAct             6
520cAC                   parm      12345         $pLbl#            7 0
520cAC                   parm      'ITM101'      $pItem           15
520cAC                   parm      2346          $pTrn#            7 0
520cAC                   parm      0             $pTrn2#           9 0
520cAC                   parm      10            $pQty             5 0
520cAC                   parm      2             $pQtyS            5 0
520cAC                   parm      'TSRWRTLBLD'  $pPgm            10
520cAC                   parm      'SELECT'      $pPtyp            6
520cAC                   parm      '1.2.3.4'     $pIp             15
520cAC                   parm      '98765'       $pUid            10
520cAC                   parm      'USER'        $pUser           10
520cAC                   parm      123           $pEmp#            5 0
520cAC                   parm      456           $pRef#           13 0
520cAC                   parm      'O'           $pLtype           1
520cAC                   parm      'DRY'         $pZone            5
520cAC                   parm      'SHIFT1'      $pShift           6
520cAC                   parm      'CREW1'       $pCrew            6

      /free
         return;
      /end-free
