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
     *  FM16100U     PO Receiving - Super Po - Load# update
     *  06 November 2014
     *  Lynn McMahon
     *
     *  Revisions:
     *
650 A*    11/06/14  LMC  6.50
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
     *      pLoad#      Load#
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
     D pLoad#          s              6p 0

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

     D phrec         E Ds                  Extname(pohdr)
     D purec         E Ds                  Extname(pospo)
     *----------------------------------------------------------------

     c     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pPgm
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pLoad#

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        select;
          when client = CoastalSunbelt;
            exec sql select * into :phrec
                     from pohdr
                     where phwhse = :pWhse
                       and phpo   = :pPO;
            if sqlstt = sqlSuccess;
              if pLoad# > 0;
                wklodn = %editc(pLoad#:'X');
                wkphvad2 = phvad2;
                %subst(wkphvad2:35:6) = %subst(wklodn:1:6);
                exec sql update pohdr set
                           phvad2 = :wkphvad2
                         where phwhse = :pWhse
                           and phpo = :pPO;
              else;
                // just get the load number to post to linked pohdr
                wklodn = %subst(phvad2:35:6);
              endif;
            endif;
650cA       // is pPO a super po?
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

            // now put load# into the pohdr for all po's attached
            select;
              when super;
650cA           // get the po's linked to the super po
                SqlStmt = 'select * from pospo '
                    +     'where puwhse = ' + %char(pWhse) + ' '
                    +       'and puspo = '
                    +       sq + %trimr(pPO) + sq;
                exec sql prepare sposel from :SqlStmt;
                exec sql declare spocsr cursor for sposel;
                exec sql open spocsr;
650cA           dow forever = forever;
                  exec sql fetch next from spocsr
                           into :purec;
                  if sqlstt <> sqlSuccess;
                    exec sql close spocsr;
                    leave;
                  endif;
                  exec sql select * into :phrec
                           from pohdr
                           where phwhse = :pWhse
                             and phpo   = :pupo;
                  if sqlstt = sqlSuccess;
                    wkphvad2 = phvad2;
                    %subst(wkphvad2:35:6) = %subst(wklodn:1:6);
                    exec sql update pohdr set
                              phvad2 = :wkphvad2
                             where phwhse = :pWhse
                               and phpo = :pupo;
                  endif;
650ca           enddo;
            endsl;
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

