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
     *  R26300       Slot Maint - calculate pick seq.
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
     D  pOutStr        s           1024    varying

     D pMessage        s             99

     D client          s             10
     D clientloc       s             10

     D pseq            s              5p 0
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
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        pOutStr = ' ';
      /end-free
     C                   if        pSect = 'F'
     C                   eval      pseq = pLoc
     C                   else
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm      pAisle        $cstr            30
     C                   move      $cstr         pAisle
     C                   call      'PIRPCK'
     C                   parm      ' '           $lcmd
     C                   parm                    $lprg
     C                   parm                    pwhse
     C                   parm                    pdept
     C                   parm                    paisle
     C                   parm                    ploc
     C                   parm                    plevel
     C                   parm      0             pseq
     C                   parm                    $lrtn
     C                   parm                    $lerm
     C                   endif


      /free

         // Put together JSON string

         pOutStr = '{'
                +  '"pseq":"'  + %char(pseq) + '"';

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


