      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
      *----------------------------------------------------------
      *   Copyright (C) 2014 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  PCQTCK2     See if Delete is allowed for Question
      *  14 May 2014
      *  Lynn McMahon
      *
      *  Revisions:
      *
650 A *    05/14/14  LMC  6.50
      *      - Created.
700aA *    08/05/15  LMC  7.00a
      *      - Revised to not allow delete if active values exist for
      *       the question.
720a *    08/22/18  LMC  7.20a
     *      - Recompile only - Databases changes.
740a *    05/14/20  LMC  7.40a
     *      - Exclude answer type 2 from check on values file.
     *        We are now auto loading Y/N answers to the haccpv
     *        file for answer type 2. Needed for parent/reactive
     *        processing.
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

     D hlrec         E Ds                  Extname(haccplog)
700aAD hvrec         E Ds                  Extname(haccpv1)
740aAD hirec         E Ds                  Extname(haccpq)

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
     c                   parm                    pseq#
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

          pOutStr = ' ';
          exsr chkLog;
700aA     if pOutStr = ' ';
740aA       exsr getanswertype;
740aA       if hiatyp <> '2';
700aA         exsr chkvalues;
740aA       endif;
700aA     endif;
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
     *  chkLog      Check for the existence of a Log record
     *----------------------------------------------------------------

      /free
       begsr chkLog;

         exec sql select * into :hlrec
                  from haccplog
                  where hlwhse = :pWhse
                    and hlseq# = :pseq#
                 fetch first 1 rows only;

         If sqlstt = sqlSuccess;
           pOutstr = '** NO DELETE **';
         else;
           pOutstr = ' ';
         endif;

       endsr;
      /end-free
700aA*----------------------------------------------------------------
700aA*  chkValues   Check for the existence of a Active value records
700aA*----------------------------------------------------------------

700aA /free
700aA  begsr chkValues;

700aA    exec sql select * into :hvrec
700aA             from haccpv
700aA             where hvwhse = :pWhse
700aA               and hvseq# = :pseq#
700aA               and hvactive = '1'
700aA            fetch first 1 rows only;

700aA    If sqlstt = sqlSuccess;
700aA      pOutstr = '** NO DELETE **';
700aA    else;
700aA      pOutstr = ' ';
700aA    endif;

700aA  endsr;
700aA /end-free
740aA*----------------------------------------------------------------
740aA*  getanswertype Get the answer type for this seq#
740aA*----------------------------------------------------------------

740aA /free
740aA  begsr getanswertype;

740aA    hiatyp = ' ';
740aA    exec sql select * into :hirec
740aA             from haccpq
740aA             where hiwhse = :pWhse
740aA               and hiseq# = :pseq#
740aA            fetch first 1 rows only;

740aA  endsr;
740aA /end-free
