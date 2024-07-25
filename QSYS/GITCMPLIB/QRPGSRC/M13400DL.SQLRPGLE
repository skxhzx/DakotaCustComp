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
     *  FM13400DL    PO Delete - extra files not used in M13400
     *  07 November 2014
     *  Lynn McMahon
     *
     *  Revisions:
     *
650 A*    11/07/14  LMC  6.50
     *      - Created.
750aA*    10/28/21  LMC  7.50a
     *      - Added delete for the PODTLM file
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

     D client          s             10
     D clientloc       s             10

     D wklodn          s              6
     D wkphvad2        s             40
650cAD super           s               n

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D pdrec         E Ds                  Extname(podtl)
750aAD pdmrec        E Ds                  Extname(podtlm)
     D purec         E Ds                  Extname(pospo)
     D lmrec         E Ds                  Extname(lumper)
     *----------------------------------------------------------------

     c     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pPgm
     c                   parm                    pWhse
     c                   parm                    pPO

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        // is pPO a super po?
        exec sql select * into :purec
                 from pospo
                 where puwhse = :pWhse
                   and puspo   = :pPO
                 fetch first 1 rows only;

        If sqlstt = sqlSuccess;
          super = *on;
        else;
          super = *off;
        endif;

        select;
          when super;
            // delete all the records linked to the super po           e
            exec sql delete from pospo
                     where puwhse = :pWhse
                       and puspo  = :pPO;
          other;
            // delete all the podtl records for the regular po
            exec sql delete from podtl
                     where pdwhse = :pWhse
                       and pdpo   = :pPO;
750aA       // delete all the podtlm records for the regular po
750aA       exec sql delete from podtlm
750aA                where pdmwhs = :pWhse
750aA                  and pdmpo   = :pPO;
            // lumper records if they exist with no export date
            exec sql delete from lumper
                     where lmwhse = :pWhse
                       and lmpo   = :pPO
                       and lmhedt = 0;
        endsl;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         getclient(client: clientLoc);

       endsr;

      /end-free

