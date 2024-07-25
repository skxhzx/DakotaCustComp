      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  R26400       Slot Maint - Format slot display
     *  06 September 2017
     *  Lynn McMahon
     *
     *  Revisions:
     *
710 A*    09/06/17  LMC  7.10
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSession    Session
     *      pWhse       Warehouse
     *      pDept       Department
     *      pSect       Section
     *      pAisle      Aisle
     *      pLoc        Location
     *      pLevel      Level
     *      pHand       Hand
     *      pPckseq     Pick Seq
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D psession        s             40    varying
     D pWhse           s              3p 0
     D pDept           s              5
     D pSect           s              1
     D pAisle          s              3
     D pLoc            s              3p 0
     D pLevel          s              2p 0
     D phand           s              2
     D pPckseq         s              5p 0
     D  pOutStr        s           1024    varying

     D pMessage        s             99

     D client          s             10
     D clientloc       s             10

     D display         s             12
     D $lcmd           s              8
     D $lprg           s             10
     D $lrtn           s              8
     D $lerm           s             50

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    psession
     c                   parm                    pWhse
     c                   parm                    pDept
     c                   parm                    pSect
     c                   parm                    pAisle
     c                   parm                    pLoc
     c                   parm                    pLevel
     c                   parm                    pHand
     c                   parm                    pPckseq
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        pOutStr = ' ';
      /end-free

     C                   call      'FRMTSL'
     C                   parm                    pwhse
     C                   parm                    pdept
     C                   parm                    paisle
     C                   parm                    ploc
     C                   parm                    plevel
     C                   parm                    phand
     C                   parm                    psect
     C                   parm                    ppckseq
     C                   parm                    display

      /free

         // Put together JSON string

         pOutStr = '{'
                +  '"display":"'  + %trimr(display) + '"';

         // Close off the JSON string
         pOutStr += '}';

      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         getclient(client: clientLoc);

       endsr;

      /end-free


