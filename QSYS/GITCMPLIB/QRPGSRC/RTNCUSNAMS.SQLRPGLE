      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RTNCUSNAMS   Return customer names for all orders per Trax stop
     *  01 July 2020
     *  Retha Davis
     *
     *  Revisions:
     *
     * ------------------------------------------------------------------
740 A*    07/01/20  RBD  7.40
     *      - Created.
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------
     *  SQL record layouts referenced
     *----------------------------------------------------------

     D ohrec         E Ds                  Extname(ordh9)

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *
     d dblqte          s              1    inz('"')
     d errmsg          s             99
     d firstTime       s               n
     d pos             s              5  0
     d rtnnames        s            500    varying
     d rtnwidth        s              4  0
     d sngqte          s              1    inz(x'7d')

     *----------------------------------------------------------------
     *  Parameters
     *
     d pwhse           s              3  0
     d pstop           s              2  0
     d prteid          s              5

     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
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
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

     d ExtractParms    pr

     d ExtractParmStr  pr

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

     d/copy qcopysrc,p.cvttext

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
     *      pOutStr     Return string in JSON format
     *
     *----------------------------------------------------------------

     D rtncusnams      pr                  extpgm('RTNCUSNAMS')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D rtncusnams      pi
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

      /free
        // Extract parameters from delimited string

        *inlr=*on;
        ExtractParms();

        // Get customer name(s)

        SqlStmt = 'select '
                +   'ohcnam '
                + 'from ordh9 '
                + 'where '
                +   'ohwhse= ' + %char(pWhse) + ' '
                +   'and ohrte=' + sq + %trimr(pRteId) + sq + ' '
                +   'and ohstop= ' + %char(pStop) + ' ';

        exec sql prepare ordsel from :SqlStmt;
        exec sql declare ordcsr cursor for ordsel;
        exec sql open ordcsr;

        dow forever = forever;

          exec sql fetch next from ordcsr
                   into :ohcnam;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          if firstTime = *off;
            firstTime = *on;
            rtnnames = %trimr(ohcnam);
          else;
            rtnnames = %trimr(rtnnames + ',  ' + ohcnam);
          endif;

        enddo;

        pos = %scan(dblqte: rtnnames);
        dow pos > 0;
          rtnnames = %replace(sngqte: rtnnames: pos: %len(dblqte)) ;
          if (pos+%len(sngqte) > %len(rtnnames));
            pos = 0;
          else;
            pos = %scan(dblqte: rtnnames: pos+%len(sngqte));
          endif;
        enddo;

        exec sql close ordcsr;

        // Multiply length of names by 6 to get the equivalent
        // of pixel width desired to size the column

        rtnwidth = (%len(%trim(rtnnames))) * 6;
        if rtnwidth > 250;
          rtnwidth = 250;
        endif;

        pOutStr = '{"rtnnames":"' + %trim(rtnnames) + '",' +
                   '"rtnwidth":"' + %char(rtnwidth) + '"}';
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

           when parmName = 'rteid';
             if parmValue = '';
               parmValue = '00000';
             endif;
             pRteId =  parmValue;

           when parmName = 'stop';
             if parmValue = '';
               parmValue = '0';
             endif;
             pStop =  %dec(parmValue: 2: 0);

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
