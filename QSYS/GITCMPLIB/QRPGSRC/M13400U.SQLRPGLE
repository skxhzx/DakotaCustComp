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
     *  FM13400U     PO Receiving - Extra Header updates
     *  10 November 2014
     *  Lynn McMahon
     *
     *  Revisions:
     *
650 A*    11/10/14  LMC  6.50
     *      - Created.
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
     *      pPO         Purchase Order
     *      pLumper     Lumper
     *      pLPallet    Palletized
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

      /copy qcopysrc,id#coastal

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D pMessage        s             99
     D psessid         s             40
     D puser           s             10
     D ppgm            s             20
     D pWhse           s              3p 0
     D pPo             s              9
     D pLumper         s              1
     D pLPallet        s              1

     D client          s             10
     D clientloc       s             10

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

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D lmrec         E Ds                  Extname(lumper)
     *----------------------------------------------------------------

     c     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pPgm
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pLumper
     c                   parm                    pLPallet

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        // update/add to the lumper file if needed
        exec sql select * into :lmrec
                 from lumper
                 where lmwhse = :pWhse
                   and lmpo   = :pPO
                   and lmhedt = 0;
        if sqlstt = sqlSuccess;
          exec sql update lumper set
                  lmlmpr = :pLumper,
                  lmpalt = :pLPallet
                   where lmwhse = :pWhse
                     and lmpo   = :pPO
                     and lmhedt = 0;
        else;
          // only add if one of the flags is populated with Y
          if pLumper = 'Y' or
             pLPallet = 'Y';
             // get current date
             $cvcmd = '*CURCMD';
             cvtdte($cvtdt);
            exec sql insert into lumper
                 values(:pWhse,
                        :pPO,
                        :$cvd8o,
                        :pLumper,
                        :pLPallet,
                        0,
                        0) ;
          endif;
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

