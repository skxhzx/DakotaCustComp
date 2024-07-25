417cA /copy *libl/qcopysrc,hspecs
     H dftactgrp(*NO)
     H actgrp(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TR730    Tracker - Complete route
     *  22 December 2009
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTSQLRPGI OBJ(*) SRCFILE(*) TGTRLS(V5R3M0)
     *               COMMMIT(*NONE) DLYPRP(*YES)
     *
     *----------------------------------------------------------------
     *
     *  Revisions:
     *
610 A*    12/22/09  DAS  6.10
     *      - Created.
     *
610aA*    08/18/10  RBD  6.10a
     *      - Removed parm EPM file, added parm warehouse.
     *
640aA*    03/09/11  RBD  6.40a
     *      - Added call to TR840 to process Trax returns file.
     *
640bA*    05/14/12   RBD  6.40b
     *      - Fix: If driver in upload file = 'N/A' or 'uid' populate
     *        pEmpNo with 99999.  This is a temporary fix until Susan
     *        gets it fixed on the handheld.
     *
710aA*    12/22/17   MR   7.10a
     *      - Add email and pics parms to GETEMPL.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fbfcdebug  o    e           k disk

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
     D gWhse           s              3  0
     D gFileName       s             60
640aAD pRtnCode        s             10
640aAD pRtnMessage     s             60

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

     D/copy qcopysrc,p.getempl

     D getliblcl       pr                  extpgm('GETLIBLCL')
     D  zLibl                      1024

640aAD TR840           pr                  extpgm('TR840')
640aAD  $pfile                       30
640aAD  pRtnCode                     10
640aAD  pRtnMessage                  60

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     D ProcessEPMFile  pr
     D ProcessRtnFile  pr
     D VerifyParms     pr
     D VfyEmployee     pr
     D VfyEpmFile      pr
     D VfyRteId        pr
     D VfyRtnFile      pr
     D wrtDebugLibl    pr

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pEmpNo      Employee number
610aA*      pWhse       Warehouse
     *      pRteId      Route Id
     *      pRtnFile    Returns file
610aD***    pEpmFile    EPM file
     *
     *    Returned Parameters
     *      pRtnCode       Return code (*OK, *ERROR)
     *      pRtnMessage    Return file name or error message
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pEmpNo            5
610aAC                   parm                    pWhse             3
     C                   parm                    pRteId            5
     C                   parm                    pRtnFile         60
610aDC***                parm                    pEpmFile         60
     C                   parm                    pRtnCode         10
     C                   parm                    pRtnMessage      60

      /free
        *inlr = *on;
        pRtnCode    = ' ';
        pRtnMessage = ' ';

        wrtDebugLibl();

        // Verify Parameters

        VerifyParms();
        if pRtnMessage <> ' ';
          return;
        endif;

        // Verify Returns file exists

        VfyRtnFile();
        if pRtnMessage <> ' ';
          return;
        endif;

        // Verify EPM file exists

        VfyEpmFile();
        if pRtnMessage <> ' ';
          return;
        endif;

        // Process Returns file

        ProcessRtnFile();
        if pRtnMessage <> ' ';
          return;
        endif;

        // Process EPM file

        ProcessEpmFile();
        if pRtnMessage <> ' ';
          return;
        endif;

        // Send back file name

        pRtnCode = '*OK';
        pRtnMessage = ' ';

        return;
      /end-free

     *----------------------------------------------------------------
     *  ProcessEpmFile  Process EPM file exists
     *----------------------------------------------------------------

     p ProcessEpmFile  b
     d ProcessEpmFile  pi

      /free


       return;
      /end-free

     p ProcessEpmFile  e

     *----------------------------------------------------------------
     *  ProcessRtnFile  Process Returns file exists
     *----------------------------------------------------------------

     p ProcessRtnFile  b
     d ProcessRtnFile  pi

     * Local variables

640aAd $pfile          s             30

      /free

640aA    $pfile = %trimr(pRtnFile);

640aA   TR840($pfile : pRtnCode : pRtnMessage);

640aA   // Clear pos 31-60 of pRtnFile ... can't explain why, but
640aA   // pgm TR840 contaminates pRtnFile with pRtnCode starting in
640aA   // pos 34, even though pRtnFile is not being passed to TR840.
640aA   // MLB, JJ, & RBD all researched and couldn't figure it out.

640aA    %subst(pRtnFile:31:30) = *blanks;

       return;
      /end-free

     p ProcessRtnFile  e

     *----------------------------------------------------------------
     *  VerifyParms   Verify parameters
     *----------------------------------------------------------------

     p VerifyParms     b
     d VerifyParms     pi

      /free

        // Verify employee number

        VfyEmployee();
        if pRtnMessage <> ' ';
          return;
        endif;

        // Verify route id

        VfyRteId();
        if pRtnMessage <> ' ';
          return;
        endif;

       return;
      /end-free

     p VerifyParms     e

     *----------------------------------------------------------------
     *  VfyEmployee  Verify employee number
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
710aAd e$email         s              1
710aAd e$pics          s              1

      /free

640bA    if pEmpNo = 'N/A  ' or pEmpNo = 'uid  ';
640bA      pEmpNo = '99999';
640bA    endif;

         // Convert to a number

         monitor;
           gEmp# = %dec(pEmpNo:5:0);
         on-error;
           pRtnCode    = '*ERROR';
           pRtnMessage = '(TR730) Invalid Emp# - '
                    + pEmpNo;
           return;
         endmon;

         // Get employee info

         monitor;
           getEmpl(gEmp#: gWhse: gUser: e$fnam: e$init: e$lnam:
                   e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
710aD         //   e$bpu: e$lng);
710aM              e$bpu: e$lng: e$email: e$pics);
         on-error;
           pRtnCode    = '*ERROR';
           pRtnMessage = '(TR730) Error calling getEmpl';
           return;
         endmon;

         if e$rtn = '*ERROR';
           pRtnCode    = '*ERROR';
           pRtnMessage = '(TR730) User not found for emp#';
           return;
         endif;

       return;
      /end-free

     p VfyEmployee     e

     *----------------------------------------------------------------
     *  VfyEpmFile  Verify EPM file exists
     *----------------------------------------------------------------

     p VfyEpmFile      b
     d VfyEpmFile      pi

      /free


       return;
      /end-free

     p VfyEpmFile      e

     *----------------------------------------------------------------
     *  VfyRteId   Verify route id
     *----------------------------------------------------------------

     p VfyRteId        b
     d VfyRteId        pi

     * Local variables

     d  rteStatus      s              1

      /free

         // Verify route exists in RTEHED file

         exec sql select rhstat
                into  :rteStatus
                from rtehed
                where rhwhse = :gWhse and rhrtid = :prteid;
         If sqlstt <> sqlSuccess;
           pRtnCode    = '*ERROR';
           pRtnMessage = '(TR730) Route not found ('
                    + %trim(pRteId) + ')';
           return;
         endif;

         // Verify route status is Closed or Exported

         If rteStatus <> '5'
            and rteStatus <> '6';
              pRtnCode    = '*ERROR';
              pRtnMessage = '(TR730) Route not at Closed '
                       + 'or Exported status ('
                       + %trim(pRteId) + ')';
             return;
         endif;

       return;
      /end-free

     p VfyRteId        e

     *----------------------------------------------------------------
     *  VfyRtnFile  Verify Returns file exists
     *----------------------------------------------------------------

     p VfyRtnFile      b
     d VfyRtnFile      pi

      /free


       return;
      /end-free

     p VfyRtnFile      e

     *----------------------------------------------------------------
     *  wrtDebugLibl   Write out debug parm record
     *----------------------------------------------------------------

     p wrtDebugLibl    b
     d wrtDebugLibl    pi

      /free

         bdtype = 'LIBL';

600fA    getliblcl(bdvalues);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       return;
      /end-free

     p wrtDebugLibl    e
