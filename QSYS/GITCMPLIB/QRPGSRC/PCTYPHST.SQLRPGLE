      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
      *----------------------------------------------------------
      *   Copyright (C) 2014 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  PCTYPHST      Product Control - History weeks changed log
      *  22 May 2014
      *  Lynn McMahon
      *
      *  Revisions:
      *
650 A *    05/22/14  LMC  6.50
      *      - Created.
      *
      *----------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

      *----------------------------------------------------------
      * File Specs
      *----------------------------------------------------------

      *----------------------------------------------------------
      *  Program information data structure
      *----------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pWhse          s              3p 0
     D  pLevel         s              4
     D  pType          s              3
     D  pReason        s             30
     D  pNewWks        s              3p 0
     D  pUser          s             10
     D  pPgm           s             10

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------
     *  Variables
     *----------------------------------------------------------

     D  OldWks         s              3p 0
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z

     D bfcoffset       s              3  0 inz(0)
600fA*----------------------------------------------------------------
600fA* Function prototypes.
600fA*----------------------------------------------------------------
600fA
600fA /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D hhrec         E Ds                  Extname(haccpqth)
     D hbrec         E Ds                  Extname(haccpqt)

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *      pLevel       Level
     *      pType        Type
     *      pReason      Reason
     *      pNewWks      New weeks to keep
     *      pUser        User
     *      pPgm         Program
     *
     *    Returned Parameters
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pLevel
     c                   parm                    pType
     c                   parm                    pReason
     c                   parm                    pNewWks
     c                   parm                    pUser
     c                   parm                    pPgm

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

          exsr WriteLog;
          *inlr = *on;

      /end-free

      *----------------------------------------------------------
      *  *INZSR   Initialization subroutine
      *----------------------------------------------------------

      /free
          begsr *INZSR;


           endsr;

      /end-free

     *----------------------------------------------------------------
     *  WriteLog    Write Question Type History Weeks Log
     *----------------------------------------------------------------

      /free
       begsr WriteLog;
         // get existing weeks to keep
         exec sql select * into :hbrec
                  from haccpqt
                  where hbwhse = :pWhse
                    and hblevl = :pLevel
                    and hbtype = :pType;

         If sqlstt = sqlSuccess;
           OldWks = hbwkhst;
         else;
           OldWks = 0;
         endif;

         // Write log if weeks are being reduced.
         // Write log if on the add function user reduced weeks from our
         // standard setup of keeping history 106 weeks.
         // These two situation in the select do not need logs written
         select;
           // This would be an add with weeks less than standard
           when OldWks = 0 and pNewwks < 106;
           // This would be an add with standard weeks
           when OldWks = 0 and pNewwks = 106;
             return;
           // This would be an update with an increase in weeks
           when pNewWks >= OldWks;
             return;
         endsl;

         exsr zzgettime;
         exec sql insert into haccpqth
                    (hhwhse, hhtype, hhlevl, hhowkhst,
                     hhnwkhst, hhreason, hhaddts,
                     hhadduc, hhaddcpgm, hhaddjpgm, hhaddeusr)
              values(:pWhse, :pType, :pLevel, :OldWks,
                     :pNewWks, :pReason, :currstampsys,
                     :currstampuc, :pPgm, :pPgm, :pUser);

       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZGETTIME Get Timestamp information.
     *
     *----------------------------------------------------------------
      /free
       begsr zzgettime;
         getmicrotime(currstampuc:currstampsys);
       endsr;
      /end-free
