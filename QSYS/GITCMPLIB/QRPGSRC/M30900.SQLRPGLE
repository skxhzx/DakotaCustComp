      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  M30900    Drop Pick Aisle and Location Ranges
     *  12 May 2020
     *  Kenneth Elder
     *

     *----------------------------------------------------------------
     *  Revisions
     *
730 A*    05/12/20  KDE  7.40
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data structure
     *----------------------------------------------------------------
     D drprec        E Ds                  Extname(DrpRnge)
     D slrec         E Ds                  Extname(Slot)

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Clients
     *----------------------------------------------------------------

     D client          s             10
     D clientloc       s             10

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
     D ts              s               z
     d noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')

     D bfcoffset       s              3  0 inz(0)


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.cvtcase
      /copy qcopysrc,p.dricop
      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getuser
      /copy qcopysrc,p.excustmast
      /copy qcopysrc,p.exitemord
     *----------------------------------------------------------------
     * DRI Parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
     D saveVer#        s                   like($itver#)
     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------
     d dpCombo         s             20
     D forevr          s               n
     d n               s             18  0
     d pattern         s            200
     d fieldCnt        s              2  0
     d filename        s            100
     d cmdString       s            200
     d count           s             10  0
     d lastpos         s              5  0
     d nextBegin       s              5  0
     d lenchar         s              5  0
     d lpos            s              5  0
     d newDir          s            300
     d p_command       s             10
     d p_drpwhse       s              3  0
     d p_drpseq        s              5  0
     d p_drpwhdp       s              3
     d p_drpfdais      s              3
     d p_drptdais      s              3
     d p_drpfdloc      s              3  0
     d p_drptdloc      s              3  0
     d p_drpfoais      s              3
     d p_drptoais      s              3
     d p_drpfoloc      s              3  0
     d p_drptoloc      s              3  0
     d p_drpstat       s              1
     d wkAisl          s              3
     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

      *  Client Name Data Area
     dpirclient        ds            10    DTAARA('PIRCLIENT')

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds


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
     * Prototypes
     *----------------------------------------------------------------

     D GoCmd           PR            10I 0 Extproc('system')
     D   CmdString                     *   Value
     D                                     Options(*String)
     D NullString      C                   -1
     D Success         C                   0
     D ObjectNotFound  C                   'CPF3142'
     D ObjectInUse     C                   'CPF3156'
     D NoSuchPath      C                   'CPE3025'
     D Errmsgid        S              7    Import('_EXCP_MSGID')
     D Returncode      S             10I 0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pMessage    Message
     *      pSess       Session
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pobjLoc     MRC Object Location
     *      pparmStr1   Parm String 1
     *      pparmStr2   Parm String 2
     *      pparmStr3   Parm String 3
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
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
     d  parmStr                     999    varying

     d formatAisle     pr             3
     d  aisleValue                    3

     d WrtBeforeDebug  pr
     d WrtAfterDebug   pr
     d WrtDebugError   pr

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
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        // Combine dictionary/program

        dpCombo = %trim(pDict) + '.' + pPgm;

        pMessage = '';
        error = *off;

        exsr getcurrstamp;

        // Extract parameters from delimited string

        ExtractParms();

        exsr UpdDrpRnge;

        return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *  *Inzsr  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         // Get Client name to use in Batchreports directory path
         in pirclient;

         // Convert fields to uppercase

         puser   = %xlate(xlower: xupper: puser);
         ppgm    = %xlate(xlower: xupper: ppgm);
         getclient(client: clientLoc);

      /end-free

      /free
       endsr;
      /end-free
    *
     *----------------------------------------------------------------
     *  UpdDrpRnge  -  Update DrpRnge file
     *----------------------------------------------------------------

      /free
       begsr UpdDrpRnge;

        // Make sure default entry exists for Department
        // This will be used in case system finds a overflow
        // that does not fit in the detailed overflow to
        // drop pick definitions
740 A   exec sql select * into :drprec from drprnge where
740 A          drpwhse=:p_drpwhse and drpwhdp=:p_drpwhdp
               and (drpfdais<>' ' or drptdais<>' ')
               and drpfoais=' ' and drptoais=' '
               and drpfoloc=0 and drptoloc=0
               and drpseq<>:p_drpseq
740 A              fetch first row only;
        if sqlstt = '02000' and (p_drpfoais<>*blanks or p_drptoais<>*blanks
                              or  p_drpfoloc<>0 or p_drptoloc<>0)
                              and p_command<>'D';
          pMessage = 'Before specific Overflow can be specified, you must' +
                     ' define Drop Pick locations to use for dept only';
          return;
        endif;

        // Make sure From Drop Pick Aisle is valid
        if p_drpfdais <> *blanks;
          wkAisl = formatAisle(p_drpfdais);
          exec sql select * into :slrec
                   from slot
              where slwhse=:p_drpwhse and slwhdp=:p_drpwhdp
                     and slaisl=:wkAisl
                 fetch first row only;
          if sqlstt <> '00000';
            pMessage = 'From Drop Pick Aisle is not valid';
            return;
          endif;
        endif;

        // Make sure To Drop Pick Aisle is valid
        if p_drptdais <> *blanks;
          wkAisl = formatAisle(p_drptdais);
          exec sql select * into :slrec
                   from slot
              where slwhse=:p_drpwhse and slwhdp=:p_drpwhdp
                       and slaisl=:wkAisl
                 fetch first row only;
          if sqlstt <> '00000';
            pMessage = 'To Drop Pick Aisle is not valid';
            return;
          endif;
        endif;

        // Make sure From Overflow Aisle is valid
        if p_drpfoais <> *blanks;
          wkAisl = formatAisle(p_drpfoais);
          exec sql select * into :slrec
                   from slot
              where slwhse=:p_drpwhse and slaisl=:wkAisl
                      and slwhdp=:p_drpwhdp
                 fetch first row only;
          if sqlstt <> '00000';
            pMessage = 'From Overflow Aisle is not valid';
            return;
          endif;
        endif;

        // Make sure To Overflow Aisle is valid
        if p_drptoais <> *blanks;
          wkAisl = formatAisle(p_drptoais);
          exec sql select * into :slrec
                   from slot
              where slwhse=:p_drpwhse and slaisl=:wkAisl
                      and slwhdp=:p_drpwhdp
                 fetch first row only;
          if sqlstt <> '00000';
            pMessage = 'To Overflow Aisle is not valid';
            return;
          endif;
        endif;

        // Make sure From Drop Pick Location valid
        if p_drpfdloc <> *zeros;
          wkAisl = formatAisle(p_drpfdais);
          exec sql select * into :slrec
                   from slot
              where slwhse=:p_drpwhse and slloc=:p_drpfdloc
                      and slwhdp=:p_drpwhdp and slaisl=:wkAisl
                 fetch first row only;
          if sqlstt <> '00000';
            pMessage = 'From Drop Pick Location is not valid';
            return;
          endif;
        endif;

        // Make sure To Drop Pick Location valid
        if p_drptdloc <> *zeros;
          wkAisl = formatAisle(p_drptdais);
          exec sql select * into :slrec
                   from slot
              where slwhse=:p_drpwhse and slloc=:p_drptdloc
                      and slwhdp=:p_drpwhdp and slaisl=:wkAisl
                 fetch first row only;
          if sqlstt <> '00000';
            pMessage = 'To Drop Pick Location is not valid';
            return;
          endif;
        endif;

        // Make sure From Overflow Location is valid
        if p_drpfoloc <> *zeros;
          wkAisl = formatAisle(p_drpfoais);
          exec sql select * into :slrec
                   from slot
              where slwhse=:p_drpwhse and slloc=:p_drpfoloc
                      and slwhdp=:p_drpwhdp and slaisl=:wkAisl
                 fetch first row only;
          if sqlstt <> '00000';
            pMessage = 'From Overflow Location is not valid';
            return;
          endif;
        endif;

        // Make sure To Overflow Location is valid
        if p_drptoloc <> *zeros;
          wkAisl = formatAisle(p_drptoais);
          exec sql select * into :slrec
                   from slot
              where slwhse=:p_drpwhse and slloc=:p_drptoloc
                      and slwhdp=:p_drpwhdp and slaisl=:wkAisl
                 fetch first row only;
          if sqlstt <> '00000';
            pMessage = 'To Overflow Location is not valid';
            return;
          endif;
        endif;

        // Make sure Drop Pick Aisle is always selected
        if p_drpfdais = *blanks and p_drptdais=*blanks;
          pMessage = 'Drop Pick from and/or to Aisle selection must ' +
                     'be present';
          return;
        endif;

        // Make sure Aisle is present when using location
        if (p_drpfoloc <>0 or p_drptoloc<>0) and p_drpfoais=*blanks
               and p_drptoais=*blanks;
          pMessage = 'An Aisle range must exist for Overflow to use' +
                     ' a location range';
          return;
        endif;

        // Make sure Aisle is present when using location
        if (p_drpfdloc <>0 or p_drptdloc<>0) and p_drpfdais=*blanks
               and p_drptdais=*blanks;
          pMessage = 'An Aisle range must exist for Drop Pick to use' +
                     ' a location range';
          return;
        endif;

        // Confirm no overlapping logic for Overflow Aisles and Locations
        sqlstmt = 'Select * from drprnge where drpwhse=' +
              %char(p_drpwhse) + ' and drpwhdp=' + sq + %trim(p_drpwhdp) + sq +
              ' and drpseq<>' + %char(p_drpseq);
        // add Overflow Aisle location range compare if sent
        if p_drpfoais<>*blanks;
          sqlstmt = %trim(sqlStmt) + ' and drpfoais<>' + sq + sq +
          ' and ((drpfoais >= ' + sq + %trim(p_drpfoais) + sq +
          ' and drptoais <= ' + sq + %trim(p_drptoais) + sq + ') or (' +
          ' drpfoais <= ' + sq + %trim(p_drpfoais) + sq +
          ' and drptoais >= ' + sq + %trim(p_drptoais) + sq + '))';
        else;
          sqlstmt = %trim(sqlstmt) + ' and drpfoais=' + sq + sq +
                    ' and drptoais=' + sq + sq;
        endif;
        // add Overflow location range compare if sent
        if p_drpfoloc<>*zeros;
          sqlstmt = %trim(sqlStmt) + ' and drpfoloc<>0' +
          ' and ((drpfoloc >= ' + %char(p_drpfoloc) +
          ' and drptoloc <= ' + %char(p_drptoloc) + ') or (' +
          ' drpfoloc <= ' + %char(p_drpfoloc) +
          ' and drptoloc >= ' + %char(p_drptoloc) + '))';
        //else;
        //  sqlstmt = %trim(sqlstmt) + ' and drpfoloc=0 and drptoloc=0';
        endif;

        if p_command <> 'D';
          // do not check for overlap if deleting
          exec sql PREPARE ol FROM :SqlStmt;
          exec sql DECLARE olslt SCROLL CURSOR FOR ol;
          exec sql OPEN olslt;
          exec sql fetch first from olslt into :drprec;
          if sqlstt = '00000' and drpwhdp<>*blanks;
            pMessage = 'This overlaps with another Overflow range ' +
                       'already defined';
            return;
          endif;
          exec sql close olslt;
        endif;

        // Update or Add Drop Pick Range defimition
        select;
          when p_command = 'A' or p_command='C' or p_command='U';     // Add or Update
            // Check for Add or Update
            exec sql select * into :drprec
                   from drprnge
                 where drpwhse=:p_drpwhse and drpseq=:p_drpseq;
            if sqlstt <> '00000';
              // if not found then determine next usabe sequence number
              monitor;
              exec sql
                select a.drpseq + 1 into :p_drpseq
                FROM drprnge as a
                LEFT JOIN drprnge AS b
                ON b.drpwhse = a.drpwhse
                and  b.drpseq = a.drpseq + 1
                WHERE b.drpseq IS NULL and a.drpwhse=:drpwhse
                fetch first row only;
              on-error;
                // indicates no records found, so start with 1
                p_drpseq=0;
              endmon;

              if sqlstt <> '00000' or p_drpseq=0;
                exec sql select * into :drprec
                      from drprnge order by drpwhse,drpseq desc
                   fetch first row only;
                if sqlstt = '00000';
                  p_drpseq = drpseq + 1;
                else;
                  p_drpseq = 1;
                endif;
              endif;

              // insert new definition
              // do not store aisles in this file with spaces in front
              p_drpfdais=%trim(p_drpfdais);
              p_drptdais=%trim(p_drptdais);
              p_drpfoais=%trim(p_drpfoais);
              p_drptoais=%trim(p_drptoais);
              exec sql insert into DRPRNGE
                  values(:p_drpwhse, :p_drpseq, :p_drpwhdp, :p_drpfdais,
                         :p_drptdais, :p_drpfdloc, :p_drptdloc, :p_drpfoais,
                         :p_drptoais, :p_drpfoloc, :p_drptoloc,
                         'Y');
              if sqlstt <> '00000';
                pMessage = 'SQL Insert failed for warehouse (' +
                      %char(p_drpwhse) + ', sequence(' + %char(p_drpseq) + ')';
                return;
              endif;
            else;
              // update found sequence
              p_drpfdais=%trim(p_drpfdais);
              p_drptdais=%trim(p_drptdais);
              p_drpfoais=%trim(p_drpfoais);
              p_drptoais=%trim(p_drptoais);
              exec sql update drprnge
                     set drpwhdp=:p_drpwhdp, drpfdais=:p_drpfdais,
                         drptdais=:p_drptdais, drpfdloc=:p_drpfdloc,
                         drptdloc=:p_drptdloc, drpfoais=:p_drpfoais,
                         drptoais=:p_drptoais, drpfoloc=:p_drpfoloc,
                         drptoloc=:p_drptoloc
                  where drpwhse=:p_drpwhse and drpseq=:p_drpseq;
            endif;
          when p_command = 'D';                      // Delete
            // do not allow deletion of default dept record if other
            // more detail definitions exist for this department
            exec sql select * into :drprec
                from drprnge as a where a.drpwhse=:p_drpwhse
                   and a.drpseq=:p_drpseq
                   and (a.drpfdais<>' ' or a.drptdais<>' ')
                   and a.drpfoais=' ' and a.drptoais=' '
                   and a.drpfoloc=0 and a.drptoloc=0 and
                    (select count(*) from drprnge as b
                      where b.drpwhse=:p_drpwhse and b.drpwhdp=:p_drpwhdp
                        and (b.drpfoais<>' ' or b.drptoais<>' '
                         or  b.drpfoloc<>0 or b.drptoloc<>0)) >0;
            if sqlstt = '00000';
              pMessage = 'Default Department record cannot be deleted' +
                         ' when detail department records exist';
                         return;
            else;
              exec sql delete from drprnge
                       where drpwhse=:p_drpwhse and drpseq=:p_drpseq;
            endif;

          other;
            pMessage = 'Invalid update command sent (A, C, D)';
            return;
        endsl;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

      /free
       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

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

     d  parmValuec     s            100

      /free

       monitor;

         select;

           when parmName = 'DRPWHSE';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_DRPWHSE =  %dec(parmValue: 3: 0);

           when parmName = 'DRPSEQ';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_DRPSEQ =  %dec(parmValue: 5: 0);

           when parmName = 'DRPSTAT';
             p_DRPSTAT =  %trim(parmValue);

           when parmName = 'CMD';
             p_COMMAND =  %trim(parmValue);

           when parmName = 'DRPWHDP';
             p_DRPWHDP =  %trim(parmValue);

           when parmName = 'DRPFDAIS';
             p_DRPFDAIS =  %trimr(parmValue);
             p_DRPTDAIS =  %trimr(parmValue);

           when parmName = 'DRPTDAIS';
             if %trim(parmValue) <> '';
               p_DRPTDAIS =  %trimr(parmValue);
             endif;

           when parmName = 'DRPFDLOC';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_DRPFDLOC =  %dec(parmValue: 3: 0);
             p_DRPTDLOC =  %dec(parmValue: 3: 0);

           when parmName = 'DRPTDLOC';
             if parmValue = '';
               parmValue = '0';
             endif;
             if parmValue <> '0';
               p_DRPTDLOC =  %dec(parmValue: 3: 0);
             endif;

           when parmName = 'DRPFOAIS';
             p_DRPFOAIS =  %trimr(parmValue);
             p_DRPTOAIS =  %trimr(parmValue);

           when parmName = 'DRPTOAIS';
             if %trim(parmValue) <> '';
               p_DRPTOAIS =  %trimr(parmValue);
             endif;

           when parmName = 'DRPFOLOC';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_DRPFOLOC =  %dec(parmValue: 3: 0);
             p_DRPTOLOC =  %dec(parmValue: 3: 0);

           when parmName = 'DRPTOLOC';
             if parmValue = '';
               parmValue = '0';
             endif;
             if parmValue <> '0';
               p_DRPTOLOC =  %dec(parmValue: 3: 0);
             endif;

         endsl;

       on-error;

         pMessage = 'Error extracting parameter '
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
           pMessage = 'Error: Parameter string is empty '
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

         if pMessage <> '';
           return;
         endif;

         // Extract parms for string 2

         parmStr = %trim(pParmStr2);
         ExtractParmStr(parmStr);

         if pMessage <> '';
           return;
         endif;

         // Extract parms for string 3

         parmStr = %trim(pParmStr3);
         ExtractParmStr(parmStr);

         if pMessage <> '';
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
           pMessage = 'Error: Invalid parameter group '
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
         if pMessage <> '';
           leave;
         endif;

       enddo;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  formatAisle  Include proper number of spaces in Aislering
     *----------------------------------------------------------------

     p formatAisle     b
     d formatAisle     pi             3
     d  parmValue                     3

     * Local Variables

      /free

       select;
         when %len(%trim(parmValue)) = 1;
           parmValue = '  ' + %trim(parmValue);
         when %len(%trim(parmValue)) = 2;
           parmValue = ' ' + %trim(parmValue);
         other;
           // uses all three position so no changed required
       endsl;

       return parmValue;

      /end-free

     p                 e
