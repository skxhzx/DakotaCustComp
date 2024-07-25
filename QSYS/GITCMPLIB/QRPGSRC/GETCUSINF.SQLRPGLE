      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GETCUSINF  - Return customer Number & Order
     *  01 October 2020
     *  Lynn McMahon
     *
     *  Revisions:
     *
     * ------------------------------------------------------------------
740 A*    10/01/20  LMC  7.40
     *      - Created.
     *
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

     D/copy qcopysrc,p.exordh
     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------
     *  SQL record layouts referenced
     *----------------------------------------------------------

     D lbrec         E Ds                  Extname(label)
     D ohrec         E Ds                  Extname(ordh)

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  Variables
     *
     d rtncust         s             11  0
     d rtncusta        s             30
     d rtncordcnum     s             45
     d blank15         s             15    inz('')
     d blank30         s             30    inz('')
     d hold15          s             15    inz('')
     d hold30          s             30    inz('')
     d pwhse           s              3  0
     d plbl            s              7  0
     d pCust           s             11  0
     d errmsg          s             99
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     *
     *
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

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

     d ExtractParms    pr

     d ExtractParmStr  pr

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pParmStr    String of '|' delimited parameters
     *
     *    Returned Parameters
     *      pOutStr
     *
     *----------------------------------------------------------------

     D getcusinf       pr                  extpgm('GETCUSINF')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D getcusinf       pi
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     * Get client id.

     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     c

      /free
        // Extract parameters from delimited string

        *inlr=*on;
        ExtractParms();

        rtncordcnum =*blanks;
        // get original label record first
        exec sql select * into :lbrec
                 from label
                 where lblbl#=:plbl;
        if sqlstt = sqlSuccess;
          exWhse = lbwhse;
          ohaord = lbord;
          exordh ('*GET': exRtnCode: exRtnMsg: exWhse: ohaord:
                  ohaaudflg: ohaaudid: ohaaudcmp: ohaaudby: ohaaudts:
                  ohaorda: ohacusta);
          select;
            when exRtnCode = '*ERROR';
              // get info from ordh
              exec sql select * into :ohrec
                       from ordh
                       where ohord =:lbord;
              if sqlstt = sqlSuccess;
                hold15 = %char(ohcord);
                hold30 = %char(ohcust);
                rtncordcnum  = hold15  + hold30;
              endif;
            when ohaorda <> *blanks and ohacusta <> *blanks;
              rtncordcnum  = ohaorda + ohacusta;
            when ohaorda <> *blanks and ohacusta = *blanks;
              rtncordcnum  = ohaorda + blank30;
            when ohaorda = *blanks and ohacusta <> *blanks;
              rtncordcnum  = blank15 + ohacusta;
          endsl;
        endif;
        pOutStr = %trim(rtncordcnum);
               return;
      /end-free
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     C     *inzsr        begsr
     C*
     C                   endsr

     *----------------------------------------------------------------
     *  ConvertField   Convert incoming field to DRI field
     *----------------------------------------------------------------

     p ConvertField    b
     d ConvertField    pi
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

      /free

       monitor;

         select;

           when parmName = 'whs';
             if parmValue = '';
               parmValue = '0';
             endif;
             pwhse =  %dec(parmValue: 3: 0);

           when parmName = 'lbl';
             if parmValue = '';
               parmValue = '0';
             endif;
             plbl =  %dec(parmValue: 7: 0);

           when parmName = 'cust';
             if parmValue = '';
               parmValue = '0';
             endif;
             pCust =  %dec(parmValue: 11: 0);

         endsl;

       on-error;

         errMsg = 'Error extracting parameter '
                + %char(parmCount) + ' '
                + parmName + ' '
                + '(' + parmValue + ')'
                + '('
                + %trimr(#Job) + '/'
                + %trimr(#JobN) + '/'
                + %trimr(#user)
                + ')';

       endmon;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ExtractParms   Extract parms from parameter string
     *----------------------------------------------------------------

     p ExtractParms    b
     d ExtractParms    pi

      /free

         // Error if parameter string is blank

         if pParmStr = '';
           errMsg = 'Error: Parameter string is empty '
                  + '('
                  + %trimr(#Job) + '/'
                  + %trimr(#JobN) + '/'
                  + %trimr(#user)
                  + ')';
           return;
         endif;

         // Extract parms for string 1

         ExtractParmStr();

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ExtractParmStr   Extract parms from single parameter string
     *----------------------------------------------------------------

     p ExtractParmStr  b
     d ExtractParmStr  pi

     * Local Variables

     D parmCount       s              3  0
     D parmGroup       s            200    varying
     D parmLen         s              5  0
     D parmName        s             10    varying
     D parmStrLen      s              5  0
     D parmValue       s            100    varying
     D pos             s              5  0
     D start           s              5  0

      /free

       // Parameters are separated by '|'

       start = 1;
       parmStrLen = %len(pParmStr);
       parmCount = 0;

       dow start <= parmStrLen;

         // Extract parameter ('fldname=value')

         pos = %scan('|': pParmStr: start);

         parmCount += 1;

         if pos = 0;
           parmGroup = %subst(pParmStr: start);
           start = parmStrLen + 1;
         else;
           parmLen = pos - start;
           parmGroup = %subst(pParmStr: start: parmLen);
           start = pos + 1;
         endif;

         // Extract parameter name

         pos = %scan('=': parmGroup: 1);

         // If no '=' found, invalid group.

         if pos = 0;
           errMsg = 'Error: Invalid parameter group '
                   + %char(parmCount) + ' '
                   + '(' + parmGroup + ')'
                   + '('
                   + %trimr(#Job) + '/'
                   + %trimr(#JobN) + '/'
                   + %trimr(#user)
                   + ')';
           leave;
         endif;

         parmName = %subst(parmGroup: 1: pos - 1);

         // Extract parameter value

         parmLen = %len(parmGroup);

         if parmLen = pos;
           parmValue = '';
         else;
           parmValue = %subst(parmGroup: pos + 1);
         endif;

         // Convert extracted value and put into DRI field

         ConvertField(parmCount: parmName: parmValue);
         if errMsg <> '';
           leave;
         endif;

       enddo;

       return;

      /end-free

     p                 e
