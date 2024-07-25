      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
      *----------------------------------------------------------
      *   Copyright (C) 2014 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  PCQTCK1     See if Delete is allowed for Question Type
      *  20 March 2014
      *  Lynn McMahon
      *
      *  Revisions:
      *
650 A *    03/20/14  LMC  6.50
      *      - Created.
      *
720a *    08/22/18  LMC  7.20a
     *      - Recompile only - Databases changes.
740a *    05/19/20  LMC  7.40a
     *      - Recompile only - Databases changes.
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
     *  Process control(previously Haccp) question file
     *----------------------------------------------------------------

     D hirec         E Ds                  Extname(haccpq)
     D hlrec         E Ds                  Extname(haccplog)
     D hbrec         E Ds                  Extname(haccpqt)

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *      pLevel       Level
     *      pType        Type
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
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
            exsr chkLog;
          endif;
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
                  from haccpq
                  where hiwhse = :pWhse
                    and hilevl = :pLevel
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
     *  chkLog      Check for the existence of a Log record
     *----------------------------------------------------------------

      /free
       begsr chkLog;

         exec sql select * into :hlrec
                  from haccplog
                  where hlwhse = :pWhse
                    and hllevl = :pLevel
                    and hltype = :ptype
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
                  from haccpqt
                  where hbwhse = :pWhse
                    and hblevl = :pLevel
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
