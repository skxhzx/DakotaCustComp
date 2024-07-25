      /COPY *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *
     *  LCKRTEHED   Manually lock RTEHED record
     *  01 March 2016
     *  Dave Sommerville
     *
     *  This program was created for USF to test a record lock
     *  condition when calling the USFDLTRTE Stored Procedure.
     *
     *  To use enter the following on the command line:
     *
     *    call lckrtehd (1 '22222')
     *
     *  where 1 is the warehouse and 22222 is the route id to lock.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Frtehed    uf   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D  dsplyMsg       s             52
     D  pRtid          s              5
     D  pWhse          s             15  5
     D  whse3          s              3  0

     d ddWhse          s              3  0
     d ddRtid          s              5
     d ddmrid          s             26
     d ddGrpId         s              7  0
     d ddGrpCode       s             10
     d ddSubGrp        s             12
     d ddType          s              1
     d ddCurUsr        s             10
     d ddpgm           s             10
     d ddJobqTS        s             26
     d ddJobqUC        s             26

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D WrtRteLog       pr

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse     Warehouse
     *      pRtid     Route id
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pRtid

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

        // Verify parameter has been sent in

        if %parms < 2;
          dsplyMsg = 'Usage: CALL LCKRTEHD (1 ''22222'')';
          dsply DsplyMsg;
          return;
        endif;

        whse3 = pWhse;

        // Get and lock record

        chain (whse3: pRtid) rtehed;
        if not %found(rtehed);
          dsplyMsg = 'Rtid ' + %char(whse3) + '/' + pRtid + ' not found.';
          dsply DsplyMsg;
          return;
        endif;

         ddType = '1';
         WrtRteLog();

        // Send message to user and wait.

        dsplyMsg = 'Rtid ' + %char(whse3) + '/' + pRtid
                 + ' locked. Press Enter to unlock.';
        dsply DsplyMsg;

        // Unlock record and leave.

        unlock rtehed;

         ddType = '2';
         WrtRteLog();

        *inlr = *on;
        return;

      /end-free

     *----------------------------------------------------------------
     *  WrtRteLog  Write GLORTELOG record
     *----------------------------------------------------------------

     p WrtRteLog       b
     d WrtRteLog       pi

     c                   eval      ddWhse = pWhse
     c                   eval      ddRtid = pRtid
     c                   eval      ddGrpCode = 'LCKRTEHED'

     C                   call      'WRTRTELOG'
     C                   parm                    ddWhse
     C                   parm                    ddRtid
     C                   parm                    ddmrid
     C                   parm                    ddGrpId
     C                   parm                    ddGrpCode
     C                   parm                    ddSubGrp
     C                   parm                    ddType
     C                   parm      ''            ddCurUsr
     C                   parm      'LCKRTEHED'   ddpgm
     C                   parm      ''            ddJobqTS
     C                   parm      ''            ddJobqUC

     p WrtRteLog       e
