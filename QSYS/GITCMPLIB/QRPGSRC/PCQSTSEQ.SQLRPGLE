      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
      *----------------------------------------------------------
      *   Copyright (C) 2014 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  PCQSTSEQ      Get Next Sequence Number
      *  15 May 2014
      *  Lynn McMahon
      *
      *  Revisions:
      *
650 A *    05/15/14  LMC  6.50
      *      - Created.
740a *    05/19/20  LMC  7.40a
     *      - Recompile only - Databases changes.
      *
      *----------------------------------------------------------

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
     D  pNextSeq       s              5p 0

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------
     *  Variables
     *----------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Process control(previously Haccp) question file
     *----------------------------------------------------------------

     D hirec         E Ds                  Extname(haccpq1)

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *
     *    Returned Parameters
     *      pNextSeq     Next Sequence# to use
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pNextSeq

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

          pNextSeq = 0;
          exsr GetNextSeq;
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
     *  GetNextSeq  Get the next available sequence#
     *----------------------------------------------------------------

      /free
       begsr GetNextSeq;

         exec sql select * into :hirec
                  from haccpq1
                  where hiwhse = :pWhse
                  order by hiwhse, hiseq# desc
                 fetch first 1 rows only;

         If sqlstt = sqlSuccess;
           pNextSeq = hiseq# + 1;
         else;
           pNextSeq = 0;
         endif;

       endsr;
      /end-free
