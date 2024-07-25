417cA /copy *libl/qcopysrc,hspecs
     H dftactgrp(*NO)
     H actgrp(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TR710    Tracker - Verify employee number
     *  12 December 2009
     *  Dave Sommerville
     *
     *  Revisions:
     *
610 A*    12/11/09  DAS  6.10
     *      - Created.
     *
640aA*    01/19/11  RBD  6.40a
     *      - Added return parm for user code (user name).
     *
640bA*    02/22/11  RBD  6.40b
     *      - Activate VfyEmployee logic.
     *
640cA*    05/15/12   RBD  6.40c
     *      - Fix: If driver in file = 'N/A' or 'uid' populate
     *        pEmpNo with 99999.  This is a temporary fix until Susan
     *        gets it fixed on the handheld.
     *
650aA*    01/28/14   RBD  6.50a
     *      - Verify employee number against global file GLOUSR rather
     *        than calling GETEMPL which verifies against PIRUSER and
     *        PIRUSERA in case client has multiple warehouses.
     *
     *----------------------------------------------------------------

650aAFglousr1   if   e           k disk

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Global Variables
     *----------------------------------------------------------------

     D forever         s               n   inz(*on)
     D gEmp#           s              5  0
     D gUser           s             10
     D gParmCount      s              3  0

     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

     D/copy qcopysrc,p.getempl

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     D VerifyParms     pr
     D VfyEmployee     pr
     D VfyPassword     pr

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pEmpNo      Employee number
     *      pPwd        Password
     *
     *    Returned Parameters
     *      pRtnMessage    Return error message
640aA*      guser          User code (name)
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pEmpNo            5
     C                   parm                    pRtnMessage      60
640aAC                   parm                    gUser            10
     C                   parm                    pPwd             10

      /free
        *inlr = *on;
        gParmCount = %parms();
        pRtnMessage = ' ';

        // Verify parameters

        VerifyParms();
        if pRtnMessage <> ' ';
          return;
        endif;

        return;
      /end-free

     *----------------------------------------------------------------
     *  VerifyParms   Verify parameters
     *----------------------------------------------------------------

     p VerifyParms     b
     d VerifyParms     pi

      /free

        // Verify employee number

640bM   VfyEmployee();
        if pRtnMessage <> ' ';
          return;
        endif;

        // Verify password

        VfyPassword();
        if pRtnMessage <> ' ';
          return;
        endif;

       return;
      /end-free

     p VerifyParms     e

     *----------------------------------------------------------------
     *  VfyEmpl  Verify employee number
     *----------------------------------------------------------------

     p VfyEmployee     b
     d VfyEmployee     pi

     * Local variables

     d e$whse          s              3  0
     d e$user          s             10
     d e$fnam          s             15
     d e$init          s              1
     d e$lnam          s             20
     d e$whdp          s              5
     d e$styp          s              1
     d e$shft          s              6
     d e$crew          s              6
     d e$nhrs          s              3  1
     d e$rtn           s              8
     d e$bpu           s              1
     d e$lng           s              2

      /free

640cA    if pEmpNo = 'N/A  ' or pEmpNo = 'uid  ';
640cA      pEmpNo = '99999';
640cA    endif;

         // Convert to a number

         monitor;
           gEmp# = %dec(pEmpNo:5:0);
         on-error;
           pRtnMessage = '(TR710) Invalid Emp# - '
                    + pEmpNo;
           return;
         endmon;

         // Get employee info

650aD    //monitor;
650aD    //  getEmpl(gEmp#: e$whse: gUser: e$fnam: e$init: e$lnam:
650aD    //        e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
650aD    //        e$bpu: e$lng);
650aD    //on-error;
650aD    //pRtnMessage = '(TR710) Error calling getEmpl';
650aD    //return;
650aD    //endmon;

650aA    chain (gEmp#) glousr1;

650aD    //if e$rtn = '*ERROR';
650aM    if not %found(glousr1);
           pRtnMessage = '(TR710) User not found for emp#';
           return;
         endif;

       return;
      /end-free

     p VfyEmployee     e

     *----------------------------------------------------------------
     *  VfyPassword   Verify password
     *----------------------------------------------------------------

     p VfyPassword     b
     d VfyPassword     pi

      /free

         // If password not sent, then leave.

640aD    // if gParmCount < 3;
640aM    if gParmCount < 4;
           return;
         endif;

         // For now just do a simple password check.

         if pEmpNo <> pPwd;
           pRtnMessage = '(TR710) Invalid password';
           return;
         endif;

       return;
      /end-free

     p VfyPassword     e
