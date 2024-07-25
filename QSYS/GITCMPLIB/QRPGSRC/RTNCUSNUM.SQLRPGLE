      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  RTNCUSNUM  - Return proper Customer Number
     *  06 April 2019
     *  Kenneth Elder
     *
     *  Revisions:
     *
     * ------------------------------------------------------------------
740 A*    04/06/20  KDE  7.40
     *      - Created.
     *
     *
     *----------------------------------------------------------------
     * Greco Custom Changes
     *
GRCa *    04/06/20  KDE  GRCa
     *      - ENH: Pass Header Misc., filed one back as customer number
     *
     *----------------------------------------------------------------
     * Earl's Organic Custom Changes
     *
EOPa *    05/14/20  RTR  EOPa
     *      - Enh: Pass Header Misc., filed one back as customer number
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------
     *  SQL record layouts referenced
     *----------------------------------------------------------

     D lbrec         E Ds                  Extname(label)
     D ohrec         E Ds                  Extname(ordh)
     D hmrec         E Ds                  Extname(ordhm)

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------
GRCaA /copy qcopysrc,id#GRC
EOPaA /copy qcopysrc,id#eop

     *----------------------------------------------------------------
     *
     *  Variables
     *
     d rtncust         s             11  0
     d rtncusta        s             30
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
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

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
     *      pOutStr     Return string in JSON format
     *
     *----------------------------------------------------------------

     D rtncusnum       pr                  extpgm('RTNCUSNUM')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pParmStr                   1024    varying
     D  pOutStr                    1024    varying

     D rtncusnum       pi
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
      /end-free

     *  Determine and pass back proper customer number
      /free
               if pCust<>0;
                 rtncusta = %char(pCust);
710aA            pOutStr = '{'
710aA                +  '"rtncusta":"'  + %trim(rtncusta) + '"}';
                 return;
               endif;
               rtncusta=*blanks;
               // get original label record first
               exec sql select * into :lbrec
                      from label
                    where lblbl#=:plbl;
               if sqlstt='00000';
                 if sqlStt='00000';
                   // when found look first in Order Header extension file
                   exec sql select ohacusta into :rtncusta
                         from ordhexa
                       where ohawhse=:pWhse and ohaord=:lbord
                         fetch first row only;
                   if sqlStt <> '00000';
                     // look for customer override if not in extension
                     exsr custovrride;
                   endif;
                 endif;
               else;
                  // if original label is not found return zero
                  rtncusta = *blanks;
               endif;
710aA   pOutStr = '{'
710aA     +  '"rtncusta":"'  + %trim(rtncusta) + '"}';
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
     C*----------------------------------------------------------------
     C*
     C*  CUSTOVRRIDE - Override Customer Number in Misc fields
     C*
     C     custovrride   begsr
     C*
      /free
GRC A                    if client=Greco;
GRC A                      exec sql select hmmsc1 into :rtncusta
GRC A                                  from ordhm
GRC A                           where hmwhse=:pwhse and hmord=:lbord;
GRC A                    endif;
EOPaA
EOPaA                    if client = EarlsOrganic;
EOPaA                      exec sql select hmmsc1 into :rtncusta
EOPaA                                  from ordhm
EOPaA                           where hmwhse=:pwhse and hmord=:lbord;
EOPaA                    endif;
      /end-free
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
