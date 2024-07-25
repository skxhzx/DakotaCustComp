      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETSTOP     Get Host Stop Number
     *  21 January 2009
     *  Chuck Manny
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    01/21/09  CWM  5.20
     *      - Created.
520aA*    01/27/09  JCJ  5.20a
     *      - cleared return parm if sql returns not found.
520bA*    01/28/09  CWM  5.20b
520bA*      - Enh: Added GETDKTSTP1
520cA*    01/29/09  CWM  5.20c
520cA*      - Enh: Added GETNXTSTP1
650aA*    05/22/13  JCJ  6.50a
650aA*      - Enh: Added fields RTSDROP, RTSEXTD, RTSSD
650bA*    06/05/13  RTR  6.50b
650bA*      - Enh: Changed to handle drop parms not passed.
650bA*             (credit to Retha, her code.)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

650bAd $pDdrop         s              3
650bAd $pDextd         s             30
650bAd $pDsd           s              9
     d wkWhse          s              3  0
     d wkRte           s              5
     d wkOrd           s              7P 0
     d wkHstp          s              5  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *      $pcmd     Command Directing Process Which Routine To Use
     *                *ORDSTP = Use Order Number to Retrieve Host Stop
     *                *PLTSTP = Use Dakota Stop# to Retrieve Host Stop
520bA*                *DKTSTP = Use Host Stop # to Retrieve Dakota Stop
520cA*                *POS2STP = Use Host Stop to get next GT or EQ Dkt Stp
     *
     *    Input Parameters
     *      $pwhse    Warehouse     - RTSWHS   3.0
     *      $prtid    Route id      - RTSRID   5
     *      $pordr    Order Number  - RTSORD   7P0
     *
     *      $pdstp    Dakota Stop   - RTSSTP   2P0
     *                 OR
     *      $pHstp    Host Stop #   - RTSST5   5 0
     *
     *    Returned Parameters
     *      $pdstp    Dakota Stop   - RTSSTP   2P0
650aA*      $pDdrop   Drop          - RTSDROP  3
650aA*      $pDextd   Extended desc - RTSEXTD 30
650aA*      $pDsd     Stop/Drop Dsp - RTSSD    9
     *                 OR
     *      $pHstp    Host Stop #   - RTSST5   5 0
650aA*      $pDdrop   Drop          - RTSDROP  3
650aA*      $pDextd   Extended desc - RTSEXTD 30
650aA*      $pDsd     Stop/Drop Dsp - RTSSD    9
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    $pCmd             8
     c                   parm                    $pWhse            3 0
     c                   parm                    $pRtid            5
     c                   parm                    $pOrdr            7 0
     c                   parm                    $pDstp            2 0
     c                   parm                    $pHstp            5 0
650bMc                   parm                    $pDdropx          3
650bMc                   parm                    $pDextdx         30
650bMc                   parm                    $pDsdx            9

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

650bA      if %parms() > 6;
650bA        $pDdrop = $pDdropx;
650bA        $pDextd = $pDextdx;
650bA        $pDsd = $pDsdx;
650bA      endif;

           select;

           when $pCmd = '*ORDSTP ';
           exsr getHstStp1;

           when $pCmd = '*PLTSTP ';
           exsr getHstStp2;

520bA      when $pCmd = '*DKTSTP';
520bA      exsr getDktStp1;

520cA      when $pCmd = '*POS2STP';
520cA      exsr getNxtStp1;

           endsl;

        *inlr = *on;

      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Subroutines in Alphabetical Order
     *----------------------------------------------------------------
     *----------------------------------------------------------------

520bA*----------------------------------------------------------------
520bA*  getDktStp1    Get Dakota Stop #
520bA*----------------------------------------------------------------

520bA /free

520bA  begsr getDktStp1;

520aA    eval $pDstp = *zeros;
650aA    eval $pDdrop= *blanks;
650aA    eval $pDextd= *blanks;
650aA    eval $pDsd  = *blanks;

520bA    exec sql
650aM       select rtsstp, rtsdrop, rtsextd, rtssd
650aM          into :$pDstp, :$pDdrop, :$pDextd, :$pDsd
                  from rtestp
                  where rtswhs = :$pWhse
                    and rtsRid = :$pRtid
                    and rtsst5 = :$phstp;

520bA  endsr;

520bA /end-free

     *----------------------------------------------------------------
     *  getHstStp1    Get Host Stop Number Using Order #
     *----------------------------------------------------------------

      /free

       begsr getHstStp1;

520aA    eval $pHstp = *zeros;
650aA    eval $pDdrop= *blanks;
650aA    eval $pDextd= *blanks;
650aA    eval $pDsd  = *blanks;

         exec sql
650aM       select rtsst5, rtsdrop, rtsextd, rtssd
650aM          into :$pHstp, :$pDdrop, :$pDextd, :$pDsd
                  from rtestp
                  where rtswhs = :$pWhse
                    and rtsRid = :$pRtid
                    and rtsOrd = :$pOrdr;

650bA      if %parms() > 6;
650bA        $pDdropx = $pDdrop;
650bA        $pDextdx = $pDextd;
650bA        $pDsdx = $pDsd;
650bA      endif;

       endsr;

      /end-free

     *----------------------------------------------------------------
     *  getHstStp2    Get Host Stop Using Dakota Stop #
     *----------------------------------------------------------------

      /free

       begsr getHstStp2;

520aA    eval $pHstp = *zeros;
650aA    eval $pDdrop= *blanks;
650aA    eval $pDextd= *blanks;
650aA    eval $pDsd  = *blanks;

         exec sql
650aM       select rtsst5, rtsdrop, rtsextd, rtssd
650aM          into :$pHstp, :$pDdrop, :$pDextd, :$pDsd
                  from rtestp
                  where rtswhs = :$pWhse
                    and rtsRid = :$pRtid
                    and rtsstp = :$pDstp;

       endsr;

      /end-free


520cA*----------------------------------------------------------------
520cA*  getNxtStp1    Get Next Dakota Stop GT or EQ to Host Stop
520cA*----------------------------------------------------------------

520cA /free

520cA  begsr getNxtStp1;
520cA
520cA    exec sql
            select rtsstp
               into :$pDstp
                  from rtestp
                  where rtswhs = :$pWhse
                    and rtsRid = :$pRtid
                    and rtsst5 >= :$phstp;

520cA  endsr;

520cA /end-free

     *----------------------------------------------------------------
     *  EOP
     *----------------------------------------------------------------


