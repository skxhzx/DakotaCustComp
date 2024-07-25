      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M13300H     Product Control Question Values
     *  04 June 2014
     *  Lynn McMahon
     *
     *  Revisions:
     *
650 A*    06/04/14  LMC  6.50
     *      - Created.
     *      - Returns value field for displaying on list.
     *
720aA*    08/07/18  LMC  7.20
     *      - Added the ability to handle the report scheduler files
     *        when warehouse is 0.
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
     D  plevel         s              4
     D  ptype          s              3
     D  pcode          s             15
     D  pSeq#          s              5  0
     D  pvSeq#         s              5  0
     D  pOutStr        s           1024    varying
     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar


     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D Value           s             50
     D Desc            s             30

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D hvrec         E Ds                  Extname(haccpv2)
720aAD hvrecrpt      E Ds                  Extname(glorptv) prefix(rpt_)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pPgm        Program name
     *      pWhse       Warehouse
     *      plevel      Level
     *      pType       Type
     *      pCode       Code
     *      pSeq#       Question Sequence Number
     *      pVSeq#      Validation sequence Number
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
     c                   parm                    plevel
     c                   parm                    ptype
     c                   parm                    pcode
     c                   parm                    pseq#
     c                   parm                    pvseq#
     c                   parm                    pOutStr
     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;

         // Get validtion record to format display value
         Value = ' ';
720aA    if pWhse <> 0;
           exec sql select * into :hvrec
                from haccpv1
                where hvwhse = :pWhse
                  and hvlevl = :pLevel
                  and hvtype = :pType
                  and hvcode = :pCode
                  and hvseq# = :pSeq#
                  and hvvsq# = :pVSeq#;

           If sqlstt = sqlSuccess;
             select;
               when hvt3vl <> ' ';
                 value = %trim(hvt3vl);
               when hvt5vl <> 0;
                 value = %char(hvt5vl) + ' ' + 'thru' + ' ' + %char(hvt5rg);
               when hvvalu <> 0;
                 value = %char(hvvalu) + ' ' + 'thru' + ' ' + %char(hvvalr);
             endsl;
             // Get description or warning
             desc = ' ';
             select;
               when hvdesc <> ' ';
                 desc = hvdesc;
               when hvwarn <> ' ';
                 desc = hvwarn;
             endsl;
           endif;
720aA    else;
720aA      exec sql select * into :hvrecrpt
720aA           from glorptv
720aA           where hvlevl = :pLevel
720aA             and hvtype = :pType
720aA             and hvcode = :pCode
720aA             and hvseq# = :pSeq#
720aA             and hvvsq# = :pVSeq#;
720aA
720aA      If sqlstt = sqlSuccess;
720aA        select;
720aA          when rpt_hvt3vl <> ' ';
720aA            value = %trim(rpt_hvt3vl);
720aA          when rpt_hvt5vl <> 0;
720aA            value = %char(rpt_hvt5vl) + ' '
720aA            + 'thru' + ' ' + %char(rpt_hvt5rg);
720aA          when rpt_hvvalu <> 0;
720aA            value = %char(rpt_hvvalu) + ' '
720aA            + 'thru' + ' ' + %char(rpt_hvvalr);
720aA        endsl;
720aA        // Get description or warning
720aA        desc = ' ';
720aA        select;
720aA          when rpt_hvdesc <> ' ';
720aA            desc = rpt_hvdesc;
720aA          when rpt_hvwarn <> ' ';
720aA            desc = rpt_hvwarn;
720aA        endsl;
720aA      endif;
720aA    endif;


         // Put together JSON string

         pOutStr = '{'
                +  '"value":"'  + %trimr(Value) + '",'
                +  '"desc":"'  + %trimr(desc) + '"';

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

