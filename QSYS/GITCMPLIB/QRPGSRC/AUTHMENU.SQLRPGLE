      /copy *libl/qcopysrc,hspecs
      *****************************************************************
      *
      *  To compile:
      *
      *             CRTSQLRPGI PGM(XXX/SQL003RG) SRCFILE(XXX/QRPGLESRC)
      *
      *
      * COMPILING. In order to compile this program you will need
      *            to use options which allow it to work correctly
      *            between machines. These options are---
      *
      *               COMMIT = *NONE
      *               RDB    = Machine name that you will connect to.
      *               DLYPRP = *YES
      *               SQLPKG = The name & library that you want to
      *                        use for the package. This will put the
      *                        package on the RDB machine that you
      *                        specify.
      *****************************************************************
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  AUTHMENU  Authorize menu item
     *  03 July 2010
     *  Dave Sommerville
     *
     *  Revisions
     *
610 A*    07/03/10  DAS  6.10
     *      - Created.
     *
650aA*    12/18/13  DAS  6.50a
     *      - Enhanced to get the actual program to call.
     *
650bA*    04/10/14  DAS  6.50b
     *      - Revised to initialize dft values
     *
700aA*    05/25/16  MR   7.00
     *      - Add null indicators to sql to avoid generating
     *        SQLCOD 305 'Indicator Variable Required' errors
     *        in the job log.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D sqlUser         s             10
     D sqlAdd          s              1
     D sqlChange       s              1
     D sqlDelete       s              1
     D sqlView         s              1
650aAD dftAdd          s              1  0
650aAD dftChange       s              1  0
650aAD dftDelete       s              1  0
650aAD dftView         s              1  0
650aAD sqlPgm          s             20
700aAD nullInd         s              2b 0 inz(0)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pMenuItemId  - Menu item id
     *      pUser        - User code
     *
     *    Returned Parameters
     *      pViewFlag   - 0 = Not authorized, 1 = Authorized
     *      pAddFlag    - 0 = Not authorized, 1 = Authorized
     *      pChgFlag    - 0 = Not authorized, 1 = Authorized
     *      pDltFlag    - 0 = Not authorized, 1 = Authorized
650aA*      pPgm        - Actual program to call
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMenuItemId      20
     C                   parm                    pUser            10
     C                   parm                    pViewFlag         1 0
     C                   parm                    pAddFlag          1 0
     C                   parm                    pChgFlag          1 0
     C                   parm                    pDltFlag          1 0
650aAC                   parm                    pPgm             20

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         // Initialize to not authorized

         pViewFlag = 0;
         pAddFlag = 0;
         pChgFlag = 0;
         pDltFlag = 0;
650bA    dftView = 0;
650bA    dftAdd = 0;
650bA    dftChange = 0;
650bA    dftDelete = 0;

650aA    // Get actual program to call and default authorizations
650aA
650aA    exec sql select gmipgm,gmiview,gmiadd,gmichg,gmidlt
650aA             into :sqlPgm,:sqlView,:sqlAdd,:sqlChange,:sqlDelete
650aA             from glomenuitm
650aA             where gmiid = :pMenuItemId;
650aA
650aA    if sqlstt = sqlSuccess;
650aA      if %parms >= 7;
650aA        pPgm = sqlPgm;
650aA      endif;
650aA      if sqlView = 'Y';
650aA        dftView = 1;
650aA      endif;
650aA      if sqlAdd = 'Y';
650aA        dftAdd = 1;
650aA      endif;
650aA      if sqlChange = 'Y';
650aA        dftChange = 1;
650aA      endif;
650aA      if sqlDelete = 'Y';
650aA        dftDelete = 1;
650aA      endif;
650aA    else;
650aA      dftView = 0;
650aA      dftAdd = 0;
650aA      dftChange = 0;
650aA      dftDelete = 0;
650aA    endif;
650aA
650aA    // If actual program not found, set to sent in program
650aA
650aA    if %parms >= 7;
650aA      if pPgm = ' ';
650aA        pPgm = pMenuItemId;
650aA      endif;
650aA    endif;

         // Group ADMIN trumps all

         exec sql select guguser into :sqlUser
                  from glousrgrp
                  where guguser = :pUser and guggroup = 'ADMIN';

         if sqlstt = sqlSuccess;
           pViewFlag = 1;
           pAddFlag = 1;
           pChgFlag = 1;
           pDltFlag = 1;
           return;
         endif;

         // Next, a user security record takes precedence

         exec sql select gmisview,gmisadd,gmischg,gmisdlt
                  into :sqlView,:sqlAdd,:sqlChange,:sqlDelete
                  from glomenusec
                  where gmismiid = :pMenuItemId
                    and gmistype = 'U'
                    and gmiscode = :pUser;

         if sqlstt = sqlSuccess;
           if sqlView = 'Y';
             pViewFlag = 1;
           endif;
           if sqlAdd = 'Y';
             pAddFlag = 1;
           endif;
           if sqlChange = 'Y';
             pChgFlag = 1;
           endif;
           if sqlDelete = 'Y';
             pDltFlag = 1;
           endif;
           return;
         endif;

         // Next, a group security record takes precedence.
         // A 'Y' takes precedence over 'N'. Therefore, if a 'Y' record is
         // found, even if 'N' records exist, the user is given authority.

         exec sql select max(gmisview),max(gmisadd),max(gmischg),max(gmisdlt)
700aM        //   into :sqlView,:sqlAdd,:sqlChange,:sqlDelete
700aA             into :sqlView :nullInd,:sqlAdd :nullInd,
700aA             :sqlChange :nullInd,:sqlDelete :nullInd
                  from glomenusec
                  inner join glousrgrp
                          on guguser = :pUser and guggroup = gmiscode
                  where gmismiid = :pMenuItemId
                  and gmistype = 'G';

700aA   // If sqlView, sqlAdd, sqlChange,sqlDelete are blank then
700aA   // record does not exists in GLOMENUSEC

         if sqlstt = sqlSuccess
700aA      and sqlView <> ''
700aA      and sqlAdd <> ''
700aA      and sqlChange <> ''
700aA      and sqlDelete <> '';
           if sqlView = 'Y';
             pViewFlag = 1;
           endif;
           if sqlAdd = 'Y';
             pAddFlag = 1;
           endif;
           if sqlChange = 'Y';
             pChgFlag = 1;
           endif;
           if sqlDelete = 'Y';
             pDltFlag = 1;
           endif;
           return;
         endif;

         // Last of all, use the menu item default.

650aA    pViewFlag = dftView;
650aA    pAddFlag = dftAdd;
650aA    pChgFlag = dftChange;
650aA    pDltFlag = dftDelete;
650aA    return;

650aD    //exec sql select gmiview,gmiadd,gmichg,gmidlt
650aD    //         into :sqlView,:sqlAdd,:sqlChange,:sqlDelete
650aD    //         from glomenuitm
650aD    //         where gmiid = :pMenuItemId;
650aD
650aD    //if sqlstt = sqlSuccess;
650aD    //  if sqlView = 'Y';
650aD    //    pViewFlag = 1;
650aD    //  endif;
650aD    //  if sqlAdd = 'Y';
650aD    //    pAddFlag = 1;
650aD    //  endif;
650aD    //  if sqlChange = 'Y';
650aD    //    pChgFlag = 1;
650aD    //  endif;
650aD    //  if sqlDelete = 'Y';
650aD    //    pDltFlag = 1;
650aD    //  endif;
650aD    //  return;
650aD    //endif;

         // We shouldn't make it here, but if we do ...

         return;

      /end-free
