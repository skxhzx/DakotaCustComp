      /copy qcopysrc,hspecs
640a H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  WRTPHRASE  Write phrase
     *  09 July 2008
     *  Dave Sommerville
     *
600 A*    07/09/08  DAS  6.00  P#00045
     *      - Created
640aA*    09/10/12  RH   6.40a
     *      - Fix: Add DFTACTGRP line to prevent error if compiled
     *        with wrong value.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fphraselog o    e           k disk    usropn
     F                                     infds(file1ds)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcphras
100bA /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  File information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#file1ds

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

600aA*----------------------------------------------------------------
600aA*  Phrase Variables
600aA*----------------------------------------------------------------
600aA
600aA /COPY *libl/qcopysrc,c#phrasvar

     *----------------------------------------------------------------
     * Parameters
     *
     *   Input:
     *     pPhraseId  -  Phrase id
     *     pWhse      -  Warehouse
     *     pEmp#      -  Employee #
     *     pUser      -  Current User (Not job user)
     *     pPgm       -  Calling Program
     *     pItem      -  Item
     *     pWhdp      -  Warehouse Department
     *     pLocation  -  Location (Slot display, area code, etc.)
     *     pTrn#      -  Transaction #
     *     pLcns      -  License number
     *     pLtrn      -  License transction number
     *     v1         -  Variable 1 (optional)
     *     v2         -  Variable 2 (optional)
     *     v3         -  Variable 3 (optional)
     *     v4         -  Variable 4 (optional)
     *     v5         -  Variable 5 (optional)
     *
     *   Return Value:
     *      none
     *
     *----------------------------------------------------------------


     c     *entry        plist
     c                   parm                    pPhraseId
     c                   parm                    pWhse
     c                   parm                    pEmp#
     c                   parm                    pUser
     c                   parm                    pPgm
     c                   parm                    pItem
     c                   parm                    pWhdp
     c                   parm                    pLocation
     c                   parm                    pTrn#
     c                   parm                    pLcns
     c                   parm                    pLtrn
     c                   parm                    v1
     c                   parm                    v2
     c                   parm                    v3
     c                   parm                    v4
     c                   parm                    v5

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

       // Open PHRASELOG file. If error, get out.

         if not %open(phraselog);
           open(e) phraselog;
           if %error();
             return;
           endif;
         endif;

       // Get record id to use.

         exsr callGetRecId;
         if phlRecId < 0;
           return;
         endif;

       // Set record fields.

         phlWhse = pWhse;
         phlId = pPhraseId;
         phlEmp# = pEmp#;
         phlUser = pUser;
         phlPgm  = pPgm;
         phlItem = pItem;
         phlWhdp = pWhdp;
         phlLoc = pLocation;
         phlTrn# = pTrn#;
         phlLcns = pLcns;
         phlLtrn = pLtrn;

         phlVars = fmtVars(v1:v2:v3:v4:v5);

         callp getmicrotime(phlAddUC:phlAddTS);
         phlAddPgm= #pgm;
         phlAddUsr= #user;
         phlAddJob= #job;
         phlAddNbr= #jobnbr;

         write phlrec;

         return;

      /end-free

     *----------------------------------------------------------------
     *  callGetRecId  -  Call getRecId program.
     *----------------------------------------------------------------

     C     callGetRecId  begsr

     C                   call      'GETRECID'
     C                   parm                    pWhse
     C                   parm      'PHRASELOG'   $rfile           10
     C                   parm                    phlRecId

     C                   endsr
