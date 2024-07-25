      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
      *----------------------------------------------------------
      *   Copyright (C) 2018 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  M27700      See if Delete is allowed for Question Type
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

     D  plevel         s              4
     D  ptype          s              3
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
     *  Report Schedule question file
     *----------------------------------------------------------------

     D hirec         E Ds                  Extname(glorptq)
     D hbrec         E Ds                  Extname(glorptqt)

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
     c                   parm                    pLevel
     c                   parm                    pType
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

          pOutStr = ' ';
          exsr chkQuestion;
          if pOutstr = ' ';
            exsr chkSysReq;
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
     *  chkQuestion Check for the existence of a question
     *----------------------------------------------------------------

      /free
       begsr chkQuestion;

         exec sql select * into :hirec
                  from glorptq
                  where hilevl = :pLevel
                    and hitype = :ptype
                    and hiactive = '1'
                 fetch first 1 rows only;

         If sqlstt = sqlSuccess;
           pOutstr = '** NO DELETE **';
         else;
           pOutstr = ' ';
         endif;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  chkSysReq   Check for System Required Level/Type records
     *----------------------------------------------------------------

      /free
       begsr chkSysReq;

         exec sql select * into :hbrec
                  from glorptqt
                  where hblevl = :pLevel
                    and hbtype = :ptype
                    and hbuctl = 'N'
                 fetch first 1 rows only;

         If sqlstt = sqlSuccess;
           pOutstr = '** NO DELETE **';
         else;
           pOutstr = ' ';
         endif;

       endsr;
      /end-free
