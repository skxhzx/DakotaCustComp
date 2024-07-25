      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FR15700      PO Receiving - Mfr Code Decipher.
     *  21 August 2015
     *  Lynn McMahon
     *
     *  Revisions:
     *
700 A*    08/21/15  LMC  7.00
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSession    Session
     *      pWhse       Warehouse
     *      pPO         Purchase Order
     *      pPOseq      Purchase Order seq
     *      pPOitem     Purchase Order item
     *      pMfrCode    Code to Decipher
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
     D pPo             s              9
     D pposeq          s              5p 0
     D pPoitem         s             15
     D pMfrCode        s             15
     D  pOutStr        s           1024    varying

     D pItem           s             15
     D pItemseq        s              5  0
     D pPOonSuper      s              9
     D pMessage        s             99

     D client          s             10
     D clientloc       s             10

     D pupc            s             20
     D newdate         s             10
     D chardate        s              8
     D CodeFound       s               n

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D phrec         E Ds                  Extname(pohdr)
     D pdrec         E Ds                  Extname(podtl)
     D itrec         E Ds                  Extname(piritem)
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    psession
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pPOseq
     c                   parm                    pPOitem
     c                   parm                    pMfrCode
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        pOutStr = ' ';
        // get vendor number
        exec sql select * into :phrec
           from pohdr
             where phwhse = :pWhse
               and phpo   = :pPO;
        If sqlstt = sqlSuccess;
        else;
          phven = 0;
        endif;
        // get po detail info
        exec sql select * into :pdrec
           from podtl
             where pdwhse = :pWhse
               and pdpo   = :pPO
               and pdseq  = :pPOseq
               and pditem = :pPOitem;
        If sqlstt = sqlSuccess;
        else;
          pdvitm = ' ';
          pditem = ' ';
        endif;
        CodeFound = *off;
        pupc = ' ';
        $dMfritem = pdvitm;
        $dDktitem = pditem;
        $dMfr# = phven;

        exsr decipher;

        select;
          when $dDateMDY = 0;
            // try again with vendor/mfg item from piritem
            exec sql select * into :itrec
                     from piritem
                     where itwhse = :pWhse
                       and ititem = :pPOitem;
            If sqlstt = sqlSuccess;
              $dMfr# = itven#;
              $dMfritem = itvit#;
              $dDktitem = pditem;
              exsr decipher;
              if $dDateMDY > 0;
                CodeFound = *on;
              endif;
            else;
            endif;
          when $dDateMDY > 0;
            CodeFound = *on;

         endsl;
          if CodeFound;
            chardate = %editc($dDateMDY :'Y');
            newdate =  %subst(chardate: 1: 2) + '/' +
                       %subst(chardate: 3: 2) + '/' +
                       %subst(chardate: 5: 2);
          endif;

         // Put together JSON string

         pOutStr = '{'
                +  '"cvtdte":"'  + %trimr(chardate) + '",'
                +  '"cvtrtn":"'  + %trimr($dReturn) + '",'
                +  '"cvtmsg":"'  + %trimr($dMsg) + '"';

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

     *----------------------------------------------------------------
     *  Decipher Decipher code subroutine
     *----------------------------------------------------------------

      /free
       begsr Decipher;

      /end-free
     C                   call      'CVTMFRDTE'
     C                   parm      ' '           $dCmd            10
     C                   parm      pMfrCode      $dCode           30
     C                   parm      phven         $dMfr#           11 0
     C                   parm                    $dMfrItem        15
     C                   parm                    $dDktItem        15
     C                   parm      0             $dMfrDef#         2 0
     C                   parm      0             $dDateCMD         8 0
     C                   parm      0             $dDateMDY         6 0
     C                   parm      ' '           $dReturn         10
     C                   parm      ' '           $dMsg            60
     C                   parm      ' '           $ddeftype         1
     C                   parm      pupc          $dupc            20

      /free

       endsr;

      /end-free

     *
