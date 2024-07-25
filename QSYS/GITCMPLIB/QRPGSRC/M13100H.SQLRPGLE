      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M13100H     Product Control Question Maintenance
     *  02 June 2014
     *  Lynn McMahon
     *
     *  Revisions:
     *
650 A*    06/02/14  LMC  6.50
     *      - Created.
     *      - ProtectOnUpd - if haccplog records exist for question
     *        Seq#.
     *      - Validation  - if haccpv records exist for question Seq#.
     *
700aA*    08/05/15  LMC  7.00a
     *      - Revised to set validation field on active records only.
720aA*    08/07/18  LMC  7.20a
     *      - Added the ability to check the GLORPT files if pwhse=0.
720b *    08/22/18  LMC  7.20b
     *      - Recompile only - Databases changes.
740aA*    05/18/20  LMC  7.40a
     *      - ADDED a field to determine if child questions exist.
     *        this is used by M131** to display the link green.
     *      - ADDED a field to send back the answer type question.
     *        Need this for the child question maintenance.
     *      - ADDED a field to determine if entries exist to create
     *        work orders based on a answer value.
     *      - If a child question is sent in, get the parent question
     *        so we can display it in M131**.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------
     D  pSessId        s             40
     D  pUser          s             10
     D  pPgm           s             20
     D  pWhse          s              3  0
     D  pSeq#          s              5  0
     D  pOutStr        s           1024    varying
     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar


     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------


     D ProtectOnUpd    s              1
     D Validation      s              1
740aAD ChildQuestion   s              1
740aAD AnswerDesc      s             30
740aAD WO              s              1
740aAD pq              s             80

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D hlrec         E Ds                  Extname(haccplog)
     D hvrec         E Ds                  Extname(haccpv1)
720aAD hvrecrpt      E Ds                  Extname(glorptv) prefix(rpt_)
740aAD hdrec         E Ds                  Extname(haccpqc)
740aAD hcrec         E Ds                  Extname(haccpat)
740aAD hirec         E Ds                  Extname(haccpq)
740aAD hwrec         E Ds                  Extname(haccpqw)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pPgm        Program name
     *      pWhse       Warehouse
     *      pSeq#       Question Sequence Number
     *
     *    Returned Parameters
     *      pOutStr     JSON output string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm                    pPgm
     c                   parm                    pWhse
     c                   parm                    pSeq#
     c                   parm                    pOutStr
     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;

740aA    pq = ' ';
         // check for Protection on fields
         protectonUpd = 'N';
720aA    if pWhse <> 0;
           exec sql select * into :hlrec
                from haccplog
                where hlwhse = :pWhse
                  and hlSeq# = :pSeq#
                   fetch first 1 rows only;

           If sqlstt = sqlSuccess;
             ProtectOnUpd = 'Y';
           endif;
720aA    endif;

720aA    if pWhse <> 0;
         // check for Validation Entries
           Validation = 'N';
           exec sql select * into :hvrec
                from haccpv1
                where hvwhse = :pWhse
                  and hvSeq# = :pSeq#
                  and hvactive = '1'
                   fetch first 1 rows only;

           If sqlstt = sqlSuccess;
             Validation = 'Y';
           endif;
720aA    else;
720aA      Validation = 'N';
720aA      exec sql select * into :hvrecrpt
720aA           from glorptv
720aA           where hvSeq# = :pSeq#
720aA             and hvactive = '1'
720aA              fetch first 1 rows only;

720aA      If sqlstt = sqlSuccess;
720aA        Validation = 'Y';
720aA      endif;
720aA    endif;

740aA    // check for Child Questions
740aA    ChildQuestion = 'N';
740aA    exec sql select * into :hdrec
740aA         from haccpqc
740aA         where hdwhse = :pWhse
740aA           and hdpSeq# = :pSeq#
740aA            fetch first 1 rows only;

740aA    If sqlstt = sqlSuccess;
740aA      ChildQuestion = 'Y';
740aA    endif;

740aA    // Get answer type description for child question M27200
740aA    exec sql select * into :hirec
740aA         from haccpq
740aA         where hiwhse = :pWhse
740aA           and hiSeq# = :pSeq#;
740aA    If sqlstt = sqlSuccess;
740aA      AnswerDesc = ' ';
740aA      if hiatyp = '2';
740aA        // I now store Y/N in the haccpv file, so validation would
740aA        // get set to 'Y' in earlier logic.
740aA        Validation = 'N';
740aA      endif;
740aA      exec sql select * into :hcrec
740aA           from haccpat
740aA           where hctype = :hiatyp;

740aA      If sqlstt = sqlSuccess;
740aA        AnswerDesc = hcdesc;
740aA      endif;
740aA      if hipc = 'R';
740aA        exec sql select * into :hdrec
740aA             from haccpqc
740aA             where hdwhse = :pWhse
740aA               and hdSeq# = :pSeq#
740aA            fetch first 1 rows only;
740aA        If sqlstt = sqlSuccess;
740aA          // go get question from Parent
740aA          exec sql select * into :hirec
740aA              from haccpq
740aA              where hiwhse = :pWhse
740aA                and hiSeq# = :hdpseq#;
740aA          If sqlstt = sqlSuccess;
740aa            pq = hiqstn + ' = ' + hdvalu;
740aA          endif;
740aA
740aA
740aA        endif;
740aA      endif;
740aA    endif;

740aA    // check for answers that are to generate work orders
740aA    WO = 'N';
740aA    exec sql select * into :hwrec
740aA         from haccpqw
740aA         where hwwhse = :pWhse
740aA           and hwpSeq# = :pSeq#
740aA            fetch first 1 rows only;

740aA    If sqlstt = sqlSuccess;
740aA      WO = 'Y';
740aA    endif;

740aA
         // Put together JSON string

         pOutStr = '{'
                +  '"values":"'  + %trimr(Validation) + '",'
740aA           +  '"childq":"'  + %trimr(ChildQuestion) + '",'
740aA           +  '"adesc":"'  + %trimr(AnswerDesc) + '",'
740aA           +  '"crtWO":"'  + %trimr(WO) + '",'
740aA           +  '"pq":"'  + %trimr(pq) + '",'
                +  '"protect":"'  + %trimr(ProtectOnUpd) + '"';

         // Close off the JSON string
         pOutStr += '}';

      /end-free

650aA*----------------------------------------------------------------
650aA*  *INZSR   Initialization subroutine
650aA*----------------------------------------------------------------
650aA
650aA /free
650aA  begsr *INZSR;

       endsr;

      /end-free

