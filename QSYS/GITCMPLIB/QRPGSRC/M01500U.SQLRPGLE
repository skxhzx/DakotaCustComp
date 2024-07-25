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
     *  FM01500U     Built Route Maintenance
     *  01 July 2015
     *  Lynn McMahon
     *
     *  Revisions:
     *
700 A*    07/01/15  LMC  7.00
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pMessage    Message
     *      pSessid     Session
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pWhse       Warehouse
     *      pRtid       Route Id
     *      pRte        Route
     *      pDriver     Driver
     *      pLoadMth    Loading Method - optional
     *      pTrailer    Trailer
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
     D pdict           s             10
     D ppgm            s             10
     D pWhse           s              3p 0
     D pRtid           s              5
     D pRte            s              5
     D pDriver         s             10
     D pLoadMth        s              1
     D pTrailer        s              8

     D dpCombo         s             20
     D chrWhse         s              3

     D client          s             10
     D clientloc       s             10
     *----------------------------------------------------------------
     *  Called program parameters
     *
     *
     *----------------------------------------------------------------
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
     D rhrec         E Ds                  Extname(rtehed)
     D ttrrec        E Ds                  Extname(ttrte)
     D rlrec         E Ds                  Extname(rtelm)
     D rttrec        E Ds                  Extname(rtetrailer)

     *----------------------------------------------------------------

     c     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pDict            10
     C                   parm                    pPgm
     c                   parm                    pWhse
     c                   parm                    pRtid
     c                   parm                    pRte
     c                   parm                    pDriver
     c                   parm                    pLoadMth
     c                   parm                    pTrailer

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        exsr edit;
        if pMessage = ' ';
          exsr update;
        endif;
        return;
      /end-free

     *----------------------------------------------------------------
     *  EDIT     Edit subroutine
     *----------------------------------------------------------------

      /free
       begsr edit;

       endsr;

      /end-free

     *----------------------------------------------------------------
     *  UPDATE   Update subroutine
     *----------------------------------------------------------------

      /free
       begsr update;

         // update/add driver
         // get current date
         $cvcmd = '*CURCMD';
         cvtdte($cvtdt);
         ttrstd = $cvd8o;
         ttrstt = %Dec(%Time(): *ISO);

         exec sql update ttrte set
                    ttrusr = :pDriver,
                    ttrstd = :ttrstd,
                    ttrstt = :ttrstt
                  where ttrwhs = :pWhse
                    and ttrrti = :pRtid;
         If sqlstt <> sqlSuccess and pDriver <> ' ';
           // need to add the record to store the driver
           // get the truck from rtehed
           exec sql select * into :rhrec
                     from rtehed
                    where rhwhse = :pWhse
                      and rhrtid = :pRtid
                      and rhrte  = :pRte;
           If sqlstt = sqlSuccess;
           endif;
           ttrwhs = pWhse;
           ttrrti = pRtid;
           ttrrte = pRte;
           ttrtru = rhtruk;
           ttrusr = pDriver;
           ttrs = 0;
           ttrsd = 0;
           ttrqs1 = 0;
           ttrqs2 = 0;
           ttrqs3 = 0;
           ttrqn1 = 0;
           ttrqn2 = 0;
           ttrqn3 = 0;
           ttrqc1 = 0;
           ttrqc2 = 0;
           ttrqc3 = 0;
           ttrqp1 = 0;
           ttrqp2 = 0;
           ttrqp3 = 0;
           ttrsrd = 0;
           ttrsrt = 0;
           ttrfid = 0;
           ttrfit = 0;
           exec sql insert into ttrte values(:ttrrec);
           If sqlstt <> sqlSuccess;
           endif;
         endif;

         // update the Route Trailer file - RTETRAILER
         if %parms >= 11 and pTrailer <> ' ';

           exec sql update rtetrailer set
                      rttcode = :pTrailer
                    where rttwhse = :pWhse
                      and rttrtid = :pRtid;
           If sqlstt <> sqlSuccess;
             // need to add the record to store the trailer
             rttwhse = pWhse;
             rttrtid = pRtid;
             rttcode = pTrailer;
             exec sql insert into rtetrailer values(:rttrec);
             If sqlstt <> sqlSuccess;
             endif;
           endif;
         endif;

         // delete rtetrailer if it exists and user removes the trailer

         if %parms >= 11 and pTrailer = ' ';
           exec sql Delete from rtetrailer
                    where rttwhse = :pWhse
                      and rttrtid = :pRtid;
           If sqlstt <> sqlSuccess;
           endif;
         endif;

         // update/add/delete loading method
         select;
           when pLoadMth = ' ';
             exec sql delete from Rtelm
                  where rlwhse = :pWhse
                    and rlrtid = :pRtid;
             If sqlstt = sqlSuccess;
             endif;
           other;
             exec sql update rtelm set
                        rltype = :ploadmth
                      where rlwhse = :pWhse
                        and rlrtid = :pRtid;
             If sqlstt <> sqlSuccess;
               // need to add the record to store the loading method
               rlwhse = pWhse;
               rlrtid = pRtid;
               rltype = pLoadmth;
               exec sql insert into rtelm values(:rlrec);
               If sqlstt <> sqlSuccess;
               endif;
             endif;
         endsl;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         getclient(client: clientLoc);

       endsr;

      /end-free

