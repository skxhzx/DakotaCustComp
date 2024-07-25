      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
      *----------------------------------------------------------
      *   Copyright (C) 2018 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  M27800      See if Delete is allowed for Question
      *  06 August 2018
      *  Lynn McMahon
      *
      *  Revisions:
      *
720 A *    08/06/18  LMC  7.20
      *      - Created.
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

     D  pseq#          s              5p 0
     D  pOutStr        s            512    varying

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

     D hvrec         E Ds                  Extname(glorptv)

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pLevel       Level
     *      pType        Type
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pseq#
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

          pOutStr = ' ';
          if pOutStr = ' ';
            exsr chkvalues;
          endif;
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
     *  chkValues   Check for the existence of a Active value records
     *----------------------------------------------------------------

      /free
       begsr chkValues;

         exec sql select * into :hvrec
                  from glorptv
                  where hvseq# = :pseq#
                    and hvactive = '1'
                 fetch first 1 rows only;

         If sqlstt = sqlSuccess;
           pOutstr = '** NO DELETE **';
         else;
           pOutstr = ' ';
         endif;

       endsr;
      /end-free
