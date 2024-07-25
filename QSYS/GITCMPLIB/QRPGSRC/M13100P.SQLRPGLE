      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M13100       Product Control Question Maintenance edits
     *  13 May 2020
     *  Lynn McMahon
     *
     *  Revisions:
     *
740 A*    05/13/20  LMC  7.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk
     fhaccpq    if   e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D HACCPV        E Ds
     D hvrecck       E Ds                  Extname(haccpv) prefix(ck_)
     D hirecck       E Ds                  Extname(haccpq) prefix(q_)

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#ITEM
     D savever#        s                   like($itver#)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d dbgflgExists    s               n
     d debug           s               n
     d debugAfter      s               n
     d debugBefore     s               n
     d debugLoc        s              1

     d dpCombo         s             20    varying
     d mode            s              1
     d extendedMode    s             10    varying
     d aawhse          s              3  0
     D aaseq#          s              5p 0
     d aaLevel         s              4
     d aaType          s              3
     d aaCode          s             15
     d aaAType         s              1


     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pMessage    Message
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pObjLoc     External object location called from.
     *      pParmStr1   String of '|' delimited parameters
     *      pParmStr2   String of '|' delimited parameters
     *      pParmStr3   String of '|' delimited parameters
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z
     D ts              s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     D bfcoffset       s              3  0 inz(0)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pSess          s             40
     D  puser          s             10
     D  pDict          s             10
     D  ppgm           s             10
     D  pObjLoc        s             10
     D  pparmStr1      s            999
     D  pparmStr2      s            999
     D  pparmStr3      s            999

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.cvtdte
      /copy qcopysrc,p.driitem

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

     d ExtractParms    pr

     d ExtractParmStr  pr
     d  parmStr                     999    varying

     d WrtBeforeDebug  pr
     d WrtAfterDebug   pr
     d WrtDebugError   pr


     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
     *----------------------------------------------------------------

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
     *  Work field data structure
     *

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSess
     C                   parm                    pUser
     C                   parm                    pDict
     C                   parm                    pPgm
     C                   parm                    pObjLoc
     C                   parm                    pparmStr1
     C                   parm                    pparmStr2
     C                   parm                    pparmStr3
     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         // Combine dictionary/program

         dpCombo = %trim(pDict) + '.' + pPgm;

         pMessage = '';
         error = *off;

         debug = *off;
         debugBefore = *off;
         debugAfter = *off;
         if dbgflgExists;
           chain(e) (#pgm) bfcdbgflg;
           if %found(bfcdbgflg);
             select;
               when bdfflag = 1;
                 debug = *on;
                 debugAfter = *on;
               when bdfflag = 2;
                 debug = *on;
                 debugBefore = *on;
               when bdfflag = 3;
                 debug = *on;
                 debugBefore = *on;
                 debugAfter = *on;
             endsl;
           endif;
         endif;

         // **** FOR TESTING ****
         debugAfter = *on;

         // Combine dictionary/program

         dpCombo = %trim(pDict) + '.' + pPgm;

         // Write out 'Before' Debug info

         if debugBefore;
           debugLoc = 'B';
           wrtBeforeDebug();
         endif;

         // Extract parameters from delimited string

         ExtractParms();

         // Get out if error

         if pMessage <> '';
           WrtDebugError();
           return;
         endif;

         // Do processing

         Select;
           when aaAType = '2' and aaSEQ# = 0;
             //this would be an add
             setll (aawhse: aalevel: aatype: aacode) haccpq;
             dow forever = forever;
               reade (aawhse: aalevel: aatype: aacode) haccpq;
               if %eof(haccpq);
                 leave;
               endif;
               if hiatyp <> '2';
                 iter;
               endif;
               // do we have Y/N entries in the haccpv file
               exec sql select * into :hvrecck
                  from haccpv
                  where hvwhse = :aawhse
                    and hvlevl = :aalevel
                    and hvtype = :aatype
                    and hvcode = :aacode
                    and hvSeq# = :hiseq#
                    and hvt3vl = 'Y'
                    and hvactive = '1'
                  fetch first 1 rows only;

               If sqlstt = sqlSuccess;
               else;
                 hvwhse = aawhse;
                 hvlevl = aalevel;
                 hvtype = aatype;
                 hvcode = aacode;
                 hvseq# = hiseq#;
                 hvactive = '1';
                 hvt5vl = 0;
                 hvt5rg = 0;
                 hvvalu = 0;
                 hvvalr = 0;
                 hvvsq# = 1;
                 hvt3vl = 'Y';
                 hvdesc = 'Yes';
                 exec sql insert into haccpv  values(:haccpv);
               endif;
               exec sql select * into :hvrecck
                  from haccpv
                  where hvwhse = :aawhse
                    and hvlevl = :aalevel
                    and hvtype = :aatype
                    and hvcode = :aacode
                    and hvSeq# = :hiseq#
                    and hvt3vl = 'N'
                    and hvactive = '1'
                  fetch first 1 rows only;

               If sqlstt = sqlSuccess;
               else;
                 hvwhse = aawhse;
                 hvlevl = aalevel;
                 hvtype = aatype;
                 hvcode = aacode;
                 hvseq# = hiseq#;
                 hvactive = '1';
                 hvt5vl = 0;
                 hvt5rg = 0;
                 hvvalu = 0;
                 hvvalr = 0;
                 hvvsq# = 2;
                 hvt3vl = 'N';
                 hvdesc = 'No';
                 exec sql insert into haccpv  values(:haccpv);
               endif;
             enddo;
           when aaAType = '2' and aaSEQ# > 0;
             // is this an update or a delete
             exec sql select * into :hirecck
                  from haccpq
                  where hiwhse = :aawhse
                    and hilevl = :aalevel
                    and hitype = :aatype
                    and hicode = :aacode
                    and hiSeq# = :aaseq#
                  fetch first 1 rows only;

             If sqlstt <> sqlSuccess;
               // the question has been deleted
               exec sql delete from haccpv
                        where hvwhse = :aawhse
                        and hvlevl = :aalevel
                        and hvtype = :aatype
                        and hvcode = :aacode
                        and hvseq# = :aaseq#;

             else;
               //this would be an update
               // do we already have Y/N values in haccpv
               exec sql select * into :hvrecck
                    from haccpv
                    where hvwhse = :aawhse
                      and hvlevl = :aalevel
                      and hvtype = :aatype
                      and hvcode = :aacode
                      and hvSeq# = :aaseq#
                      and hvt3vl = 'Y'
                      and hvactive = '1'
                    fetch first 1 rows only;

               If sqlstt = sqlSuccess;
               else;
                 hvwhse = aawhse;
                 hvlevl = aalevel;
                 hvtype = aatype;
                 hvcode = aacode;
                 hvseq# = aaseq#;
                 hvactive = '1';
                 hvt5vl = 0;
                 hvt5rg = 0;
                 hvvalu = 0;
                 hvvalr = 0;
                 hvvsq# = 1;
                 hvt3vl = 'Y';
                 hvdesc = 'Yes';
                 exec sql insert into haccpv  values(:haccpv);
               endif;
               exec sql select * into :hvrecck
                    from haccpv
                    where hvwhse = :aawhse
                      and hvlevl = :aalevel
                      and hvtype = :aatype
                      and hvcode = :aacode
                      and hvSeq# = :aaseq#
                      and hvt3vl = 'N'
                      and hvactive = '1'
                    fetch first 1 rows only;

               If sqlstt = sqlSuccess;
               else;
                 hvwhse = aawhse;
                 hvlevl = aalevel;
                 hvtype = aatype;
                 hvcode = aacode;
                 hvseq# = aaseq#;
                 hvactive = '1';
                 hvt5vl = 0;
                 hvt5rg = 0;
                 hvvalu = 0;
                 hvvalr = 0;
                 hvvsq# = 2;
                 hvt3vl = 'N';
                 hvdesc = 'No';
                 exec sql insert into haccpv  values(:haccpv);
               endif;
             endif;
         endsl;

         // need to create the Y/N values for a answer type 2 question

         //pMessage= 'Hello ' + pUser + ', '
                 //+ 'you are calling from ' + dpCombo + ' '
           //pMessage=  extendedMode + ' mode ';
                 //+ 'with warehouse ' + %char(aawhse);

         // Write out 'After' Debug info

         if debugAfter;
           debugLoc = 'A';
           wrtAfterDebug();
         endif;

         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         open(e) bfcdbgflg;
         if %error;
           dbgflgExists = *off;
         else;
           dbgflgExists = *on;
         endif;

       endsr;
      /end-free

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

           when parmName = 'MODE';
             mode = %xlate(xlower: xupper: parmValue);

           when parmName = 'HIWHSE';
             if parmValue = '';
               parmValue = '0';
             endif;
             aawhse =  %dec(parmValue: 3: 0);

           when parmName = 'HISEQP_';
             if parmValue = ''
                or parmValue = 'undefined';
               parmValue = '0';
             endif;
             aaSEQ# =  %dec(parmValue: 5: 0);

           when parmName = 'HILEVL';
             aalevel = %xlate(xlower: xupper: parmValue);

           when parmName = 'HITYPE';
             aatype = %xlate(xlower: xupper: parmValue);

           when parmName = 'HICODE';
             aacode = %xlate(xlower: xupper: parmValue);

           when parmName = 'HIATYP';
             aaAtype = %xlate(xlower: xupper: parmValue);


         endsl;

       on-error;

         pMessage= 'Error extracting parameter '
                 + %char(parmCount) + ' '
                 + parmName + ' '
                 + '(' + parmValue + ')'
                 + '('
                 + %trimr(#Job) + '/'
                 + %trimr(#JobNbr) + '/'
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

     * Local Variables

     d parmStr         s            999    varying

      /free

         // Error if first parameter string is blank

         if pParmStr1 = '';
           pMessage= 'Error: Parameter string is empty '
                   + '('
                   + %trimr(#Job) + '/'
                   + %trimr(#JobNbr) + '/'
                   + %trimr(#user)
                   + ')';
           return;
         endif;

         // Extract parms for string 1

         parmStr = %trim(pParmStr1);
         ExtractParmStr(parmStr);

         if pMessage<> '';
           return;
         endif;

         // Extract parms for string 2

         parmStr = %trim(pParmStr2);
         ExtractParmStr(parmStr);

         if pMessage<> '';
           return;
         endif;

         // Extract parms for string 3

         parmStr = %trim(pParmStr3);
         ExtractParmStr(parmStr);

         if pMessage<> '';
           return;
         endif;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ExtractParmStr   Extract parms from single parameter string
     *----------------------------------------------------------------

     p ExtractParmStr  b
     d ExtractParmStr  pi
     d  parmStr                     999    varying

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
       parmStrLen = %len(parmStr);
       parmCount = 0;

       dow start <= parmStrLen;

         // Extract parameter ('fldname=value')

         pos = %scan('|': parmStr: start);

         parmCount += 1;

         if pos = 0;
           parmGroup = %subst(parmStr: start);
           start = parmStrLen + 1;
         else;
           parmLen = pos - start;
           parmGroup = %subst(parmStr: start: parmLen);
           start = pos + 1;
         endif;

         // Extract parameter name

         pos = %scan('=': parmGroup: 1);

         // If no '=' found, invalid group.

         if pos = 0;
           pMessage= 'Error: Invalid parameter group '
                   + %char(parmCount) + ' '
                   + '(' + parmGroup + ')'
                   + '('
                   + %trimr(#Job) + '/'
                   + %trimr(#JobNbr) + '/'
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
         if pMessage<> '';
           leave;
         endif;

       enddo;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  wrtBeforeDebug  Write out 'Before' debug info
     *----------------------------------------------------------------

     p WrtBeforeDebug  b
     d WrtBeforeDebug  pi

      /free

         bdtype = 'PARMS';

         bdvalues = 'pSess:' + %trimr(pSess) + ', '
                  + 'dbgloc:' + %trimr(debugLoc) + ', '
                  + 'pUser:' + %trimr(pUser) + ', '
                  + 'pDict:' + %trimr(pDict) + ', '
                  + 'pPgm:' + %trimr(pPgm) + ', '
                  + 'pObjLoc:' + %trimr(pObjLoc) + ', '
                  + 'pParm1:' + pParmStr1;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

         return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  wrtAfterDebug  Write out 'After' debug info
     *----------------------------------------------------------------

     p WrtAfterDebug   b
     d WrtAfterDebug   pi

      /free

         bdtype = 'PARMS';

         bdvalues = 'pSess:' + %trimr(pSess) + ', '
                  + 'dbgloc:' + %trimr(debugLoc) + ', '
                  + 'pUser:' + %trimr(pUser) + ', '
                  + 'pDict:' + %trimr(pDict) + ', '
                  + 'pPgm:' + %trimr(pPgm) + ', '
                  + 'pObjLoc:' + %trimr(pObjLoc) + ', '
                  + 'pParm1:' + pParmStr1 + ','
                  + 'pMessage:' + %trimr(pMessage);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

         return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  wrtDebugError  Write out debug error
     *----------------------------------------------------------------

     p WrtDebugError   b
     d WrtDebugError   pi

      /free

         bdtype = 'ERROR';

         bdvalues = pMessage;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

         return;

      /end-free

     p                 e


