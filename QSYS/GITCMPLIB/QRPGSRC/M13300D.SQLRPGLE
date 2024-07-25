      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  PM13300D    Get next Seq# and set active flag to on
     *
     *  19 June 2014
     *  Lynn McMahon
     *
     *  Revisions:
     *
650 A*    06/19/14  LMC  6.50
     *      - Created.
720aA*    08/07/18  LMC  7.20
     *      - Added the ability to handle the report scheduler files
     *        when warehouse is 0.
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
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar


     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pErrMsg        s             99
     D  pUser          s             10
     D  pPgm           s             20
     D  pWhse          s              3p 0
     D  pSeq#          s              5p 0
     D  pVSeq#         s              5p 0
     D  pActiv         s              1
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D dbgflgExists    s               n
     D debug           s               n

     D*whse            s              3p 0
     D NextSeq         s              5p 0

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Process control(previously Haccp) question file
     *----------------------------------------------------------------

     D hvrec         E Ds                  Extname(haccpv1)
720aAD hvrecrpt      E Ds                  Extname(glorptv) prefix(rpt_)
     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *       pUser  User
     *       pPgm   Calling program
     *       pWhse  Warehouse number.
     *       pSeq#  Sequence number
     *       pVSeq# Value Sequence number
     *       pActiv Active Flag
     *
     *    Returned Parameters
     *       pErrMsg     Error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Work field data structure
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pErrMsg
     c                   parm                    pUser
     c                   parm                    pPgm
     c                   parm                    pWhse
     c                   parm                    pSeq#
     c                   parm                    pVSeq#
     c                   parm                    pActiv
     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pErrMsg = ' ';


         NextSeq = 0;
         // if we already have a value we are not in add mode.
         // Do Not need to get next seq#, just return
         if pVseq# > 0;
           return;
         endif;

         exsr getnextseq;

         pVSeq# = Nextseq;
         // Write error to log

         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;


       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetNextSeq  Get the next available value sequence#
     *----------------------------------------------------------------

      /free
       begsr GetNextSeq;

720aA    if pWhse <> 0;
           exec sql select * into :hvrec
                  from haccpv1
                  where hvwhse = :pWhse
                   and  hvseq# = :pSeq#
                  order by hvwhse, hvseq#, hvvsq# desc
                 fetch first 1 rows only;

           If sqlstt = sqlSuccess;
             NextSeq = hvvsq# + 1;
             pActiv = '1';
           else;
             NextSeq = 1;
             pActiv = '1';
           endif;
720aA    else;
720aA      exec sql select * into :hvrecrpt
720aA             from glorptv
720aA             where hvseq# = :pSeq#
720aA             order by hvseq#, hvvsq# desc
720aA            fetch first 1 rows only;
720aA
720aA      If sqlstt = sqlSuccess;
720aA        NextSeq = rpt_hvvsq# + 1;
720aA        pActiv = '1';
720aA      else;
720aA        NextSeq = 1;
720aA        pActiv = '1';
720aA      endif;
720aA    endif;

       endsr;
      /end-free
