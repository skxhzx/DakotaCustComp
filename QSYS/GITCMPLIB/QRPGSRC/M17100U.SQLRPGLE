      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FM17100U     PO Receiving Delete Transaction
     *  16 March 2015
     *  Lynn McMahon
     *
     *  Revisions:
     *
650 A*    03/16/15  LMC  6.50
     *      - Created.
740aA*    06/11/20  LMC  7.40a
     *      - Send Puser to po144
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pMessage    Message
     *      pSessid     Session
     *      pUser       User
     *      pPgm        Program
     *      pWhse       Warehouse
     *      pLabel      Label#
     *      pTran       Transaction#
     *
     *    Returned Parameters
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
      /copy qcopysrc,p.cvtdte

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D pMessage        s             99
     D psessid         s             40
     D puser           s             10
     D ppgm            s             20
     D pWhse           s              3p 0
     D pLabel          s              7p 0
     D pTran           s              7p 0

     D client          s             10
     D clientloc       s             10
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsukey                 1     50
     D  uktrn#                 1      4p 0 inz(0)
     D  uklbl#                 5      8p 0 inz(0)
740aAD  ukuser                 9     18

     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
     *----------------------------------------------------------------

     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76


     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

740aA*----------------------------------------------------------------
740aA*  Translation strings
740aA*----------------------------------------------------------------

740aAD   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
740aAD   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     *----------------------------------------------------------------

     c     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pPgm
     c                   parm                    pWhse
     c                   parm                    pLabel
     c                   parm                    pTran

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
740aA   puser = %xlate(xlower: xupper: puser);
      /end-free
     *
     *  Call program to delete the receiving transaction
     *
     C*                  eval      ukwhse = pWhse
     C                   eval      uktrn# = pTran
     C                   eval      uklbl# = pLabel
740aAc                   eval      ukuser = pUser
     C                   eval      $pcmd = '*DELETE'
     C*                  eval      $ptype = '*BATCH'
     C                   eval      $prtn = 'TEXT'
     C*                  eval      $plbl# = pLabel
     C*                  eval      $pqpck = pPckQty
     C
     C                   eval      $puky = dsukey
     C                   call      'PO144'
     C                   parm                    $parms

      /free
        if $prtn <> '*OK';
          pmessage = $perm;
        endif;
      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         getclient(client: clientLoc);

       endsr;

      /end-free

