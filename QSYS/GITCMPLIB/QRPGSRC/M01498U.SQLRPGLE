      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FM01498U     Open Route Maintenance
     *  10 September 2018
     *  Lynn McMahon
     *
     *  Revisions:
     *
720 A*    09/10/18  LMC  7.20
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
     *      pTruck      Truck Template
     *      pDriver     Driver
     *      pLoadMth    Loading Method - optional
     *      pAlcBld     Allocate Build Flag
     *      pTBProc     TruckBuilder Process
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
720   /copy qcopysrc,p.exrtehed

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
     D pTruck          s             10
     D pDriver         s             10
     D pLoadMth        s              1
     D pAlcBld         s              1
     D pTBProc         s              1

650cAD dpCombo         s             20
650dAD chrWhse         s              3

     D client          s             10
     D clientloc       s             10
720  D TBCmd           s             10
720  D TBRtn           s             10
720  D TBRtnMsg        s             60
720  D TBProcess       s              1
720  D TBText10        s             10
720  D TBText30        s             30
720  D TBWhse          s              3s 0
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

     *----------------------------------------------------------------

     c     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
650cAC                   parm                    pDict            10
     C                   parm                    pPgm
     c                   parm                    pWhse
     c                   parm                    pRtid
     c                   parm                    pRte
     c                   parm                    pTruck
     c                   parm                    pDriver
     c                   parm                    pLoadMth
     c                   parm                    pAlcBld
     c                   parm                    pTBProc

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
         // Alloc and build not allowed until TB Process is set.
         if palcbld = 'Y' and pTBProc = ' ';
           pmessage = 'Select TruckBuilder Process before Allocate & build';
         endif;

       endsr;

      /end-free

     *----------------------------------------------------------------
     *  UPDATE   Update subroutine
     *----------------------------------------------------------------

      /free
       begsr update;
         // update truck
         exec sql update rtehed set
                    rhtruk = :pTruck
                  where rhwhse = :pWhse
                    and rhrtid = :pRtid
                    and rhrte  = :pRte;
         If sqlstt <> sqlSuccess;
         endif;

         // update/add driver
         // get current date
         $cvcmd = '*CURCMD';
         cvtdte($cvtdt);
         ttrstd = $cvd8o;
         ttrstt = %Dec(%Time(): *ISO);

         exec sql update ttrte set
                    ttrusr = :pDriver,
                    ttrstd = :ttrstd,
                    ttrstt = :ttrstt,
700aA               ttrtru = :PTruck
                  where ttrwhs = :pWhse
                    and ttrrti = :pRtid;
700aD    //If sqlstt <> sqlSuccess;
700aM    If sqlstt <> sqlSuccess and pDriver <> ' ';
           // need to add the record to store the driver
           ttrwhs = pWhse;
           ttrrti = pRtid;
           ttrrte = pRte;
           ttrtru = pTruck;
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
         // submit Allocate & Build if requeted
         select;
           when pAlcBld = 'Y';
650cA        // Combine dictionary/program
650cA
650cA        dpCombo = %trim(pDict) + '.' + pPgm;
650cA
650dA        // Convert numeric fields into character fields
650dA        chrWhse = %editc(pWhse: 'X');

640aA        pMessage = ' ';

650bA /end-free
     C                   call(e)   'RTEBUILD'
     C                   parm                    pMessage
650cMC                   parm                    pSessId
650cMC                   parm                    pUser
650cMC                   parm                    dpCombo
650dMC                   parm                    chrWhse
     C                   parm                    pRtid
     C                   parm                    pRte

640aAC                   if        %error
640aAC                   eval      pMessage = 'Error occured calling '
640aAC                                      + 'RTEBUILD ('
640aAC                                      + %trimr(#job) + '/'
640aAC                                      + %trimr(#jobnbr) + '/'
640aAC                                      + %trimr(#user) + ')'
640aAC                   endif

      /free
             other;
         Endsl;
         // lets update the TruckBuilder Process flag
         TBCmd = '*CHANGE';
         TBWhse = pWhse;
         TBProcess = pTBProc;

         monitor;
           EXRTEHED(TBCmd: TBRtn: TBRtnMsg:
                    TBWhse: pRtId: TBProcess);
         on-error;
           TBRtn = '*ERROR';
           TBText10 = 'EXRTEHED NF';
           TBText30 = 'Error calling EXRTEHED program';
         endmon;
         // If we couldn't update, lets try to add
         if TBRtn = '*ERROR';
           TBCmd = '*ADD';
           TBWhse = pWhse;

           Monitor;
             EXRTEHED(TBCmd: TBRtn: TBRtnMsg:
                      TBWhse: pRtId: TBProcess);
           on-error;
             TBRtn = '*ERROR';
             TBText10 = 'EXRTEHED NF';
             TBText30 = 'Error calling EXRTEHED program';
           endmon;
         endif;
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

