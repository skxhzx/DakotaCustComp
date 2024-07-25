      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M235001  Production Labor Cost Definition
     *  27 Jul 2017
     *  Thomas Bryant
     *
     *  Revisions:
     *
     *    07/27/17  TAB  7.10
     *      - Created.
710a *    12/19/17  NR   7.10a
     *      - Add email/text and pictures fields to sql on PIRUSERA.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D lcrec         E ds                  extname(plabcstlne) inz(*EXTDFT)
     D lclrec        E ds                  extname(plabcstlog) inz(*EXTDFT)
     D usrrec        E ds                  extname(piruser) inz(*EXTDFT)

      *----------------------------------------------------------------
      *  Query used to determine next available PIRUSER Employee number
      *----------------------------------------------------------------
     D epmdta          ds           117
     d  filler                        1
     D  epmnxte                       6  0

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pMessage       s             99
     d  pSessId        s             40
     d  pUser          s             10
     d  dpCombo        s             20
     d  pAction        s              1
     d  pWhse          s              3  0
     d  pMfgL          s              4
     d  pEmpl          s              5  0
     d  ignoreDefault  s               n
     d  pCostT         s              1
     d  pScanT         s              1
     d  pLabr          s              7  3
     d  pHour          s              2  0
     d  pBnft          s              6  4
     d  pOvrh          s              6  4
     d  pStatus        s              1
     d  pSun           s              1
     d  pMon           s              1
     d  pTue           s              1
     d  pWed           s              1
     d  pThu           s              1
     d  pFri           s              1
     d  pSat           s              1
     d  pCcntr         s             10
     d  pCrew          s              6
     d  pTask          s              6
     d  pnumEmp        s              3  0
     d  pUcde          s             10
     d  pIdle          s              1
     d  pDefault       s              1
     d  pApyStd        s              1
     D Non_Num_Posn    S              2  0 Inz(*Zero)
     D Numberss        C                   ' 0123456789'
     d  LineNo         s              3  0
     d  LineAl         s              3
     d  $LcLine        s              4

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D logText         s            100
     d DaysofWk        s              7    Inz
     d reccnt          s              5  0
     d howmany         s              5  0
     d difflabr        s              7  3
     d diffhrsd        s              2  0
     d diffdywk        s              7
     d diffbenrt       s              6  4
     d diffohpct       s              6  4
     d diffcntr        s             10

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar
     D Up              C                   CONST('ABCDEFGHIJKLMNOPQRST+
     D                                     UVWXYZ')
     D Low             C                   CONST('abcdefghijklmnopqrst+
     D                                     uvwxyz')

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z

     D bfcoffset       s              3  0 inz(0)
     D ucOffset        s              3  0

     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------
     d GetCurrStamp    pr

     D GetMicroTime    pr
     D  $pmicrouc                      z
     D  $pmicrolocal                   z
     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.wrtsessl

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       GUI User
     *      pPgm        GUI dictionary.program
     *      pWhse       Warehouse
     *      PBOM  fields
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     c                   parm                    pMessage
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm                    dpCombo
     c                   parm                    pAction
     c                   parm                    pWhse
     c                   parm                    pMfgL
     c                   parm                    pEmpl
     c                   parm                    pCostT
     c                   parm                    pScanT
     c                   parm                    pLabr
     c                   parm                    pHour
     c                   parm                    pBnft
     c                   parm                    pOvrh
     c                   parm                    pStatus
     c                   parm                    pSun
     c                   parm                    pMon
     c                   parm                    pTue
     c                   parm                    pWed
     c                   parm                    pThu
     c                   parm                    pFri
     c                   parm                    pSat
     c                   parm                    pCcntr
     c                   parm                    pTask
     c                   parm                    pnumemp
     c                   parm                    pcrew
     c                   parm                    pUcde
     c                   parm                    pIdle
     c                   parm                    pDefault
     c                   parm                    pApyStd

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         // Set SQL default parms
         exec sql
           set Option Commit=*none, Dlyprp=*Yes,
                      Closqlcsr = *ENDMOD;

         *inlr = *on;

         select;
            when pMessage = 'Ignore Warning';
               ignoreDefault = *on;
            other;
               ignoreDefault = *off;
         endsl;
         pMessage = ' ';

         // Write GLOSESSLOG record
         logText = 'objloc:' + pAction;
         wrtsesslog(pSessId: #pgm: dpCombo: pUser: logText);


         // Convert Labor line
           If pMfgL <> '*ALL' and
              pMfgL <> *Blanks;
             LineNo = %Dec(pMfgL:3:0);
             LineAl = %editC(LineNo:'X');
             Eval $LcLine = LineAl;
             Eval pMfgL = LineAl;
           Else;
             Eval $LcLine = pMfgL;
           EndIf;

         //  Validates entries and then update if no errors found
         exsr FldValid;

         return;
      /end-free

     *----------------------------------------------------------------
     *  AddRec    Add record
     *----------------------------------------------------------------

      /free
       begsr AddRec;

         error = *off;

         exsr FillRec;

         If pCostT <> 'S';
            lcdywk = *blanks;
            exec sql select uscode,uscrew,usshft
                       into :lcucde,:lccrew,:lcshft
                from piruser where usemp#=:pempl and uswhse=:pwhse;
            lcwhse=pWhse;
            exec sql insert into plabcstlne values(:lcrec);

            if sqlstt <> sqlSuccess;
              pMessage = 'Error adding Labor Cost record: '
                       + 'Sqlstt(' + sqlstt + ') '
                       + 'Whse(' + %char(pWhse) + ') '
                       + 'pMfgL(' + %trimr($LcLine) + ') '
                       + 'pEmpl(' + %char(pEmpl) + ') '
                       + 'Pgm(' + %trim(#pgm) +')';
              LeaveSR;
            endif;
         endif;

         If pCostT = 'S';
            // Loop and add number of employees per the
            // number keyed on Labor Definition Screen
            dow pNumEmp > 0;

               // get next available Employee number for PIRUSER
               exec sql
                 SELECT min(a.usemp#+1) into :usemp#
                 FROM piruser a where (select count(*)
                 from piruser b where b.usemp#=a.usemp#+1)=0;
               uslnam = %editc(usemp#:'X');
               usstyp='F';
               uscode = 'STDLB' + %editc(usemp#:'X');
               uscrew = pcrew;
               usshft=*blanks;
               uswhdp=*blanks;
               uswhse=pWhse;

               // shift, dept and beginning hour
               exec sql select shcode,shwhdp,
               case
                 when shstim>=100000 then cast(left(shstim,2) as int)
                 when shstim>=10000 then cast(left(shstim,1) as int)
                 else 0 end
                 into :usshft,:uswhdp,:lcbhr
                from shift,crew where shwhse=:pWhse and
                 shcode=crshft and crcode=:pCrew
                  fetch first row only;

               // Get valid department if not on shift definition
               if uswhdp=*blanks;
                  exec sql select uswhdp into :uswhdp
                       from piruser
                     where uswhse=:pWhse and uscrew=:pcrew
                        and uswhdp<>' '
                        fetch first row only;
               endif;

               exec sql insert into piruser values(:usrrec);
               if sqlstt <> sqlSuccess;
                  pMessage = 'Error adding User record: '
                           + 'Sqlstt(' + sqlstt + ') '
                           + 'Whse(' + %char(pWhse) + ') '
                           + 'UserID(' + %trimr(pUcde) + ') '
                           + 'Pgm(' + %trim(#pgm) +')';
                  LeaveSR;
               endif;

               // Insert Labor Cost Definition when Standard
               lcucde = uscode;
               lcempno = usemp#;
               lcshft = usshft;
               lccrew = uscrew;
               lcwhse=pWhse;
               exec sql insert into plabcstlne values(:lcrec);
               if sqlstt <> sqlSuccess;
                 pMessage = 'Error adding Labor Cost record: '
                          + 'Sqlstt(' + sqlstt + ') '
                          + 'Whse(' + %char(pWhse) + ') '
                          + 'pMfgL(' + %trimr($LcLine) + ') '
                          + 'pEmpl(' + %char(pEmpl) + ') '
                          + 'Pgm(' + %trim(#pgm) +')';
                 LeaveSR;
               endif;

               // add records to PIRUSERA for Standard Records
               exec sql insert into pirusera
710aD             // values(:uscode,'N','EN');
710aM                values(:uscode,'N','EN','N','N');

               pNumEmp = pNumEmp - 1;
            enddo;
         endif;

         /// First lets write a log record
         exsr AddLogRec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DelRec     Delete record
     *----------------------------------------------------------------

      /free
       begsr DelRec;

         error = *off;

         /// First lets write a log record
         exsr AddLogRec;

         // Delete Labor record and if Standard
         // delete user profile from PIRUSER

         select;
            when pCostT='A' or (pCostT='S' and pApyStd<>'Y');
               if pCostT='S';
                  exec sql delete from piruser as u
                           where u.USWHSE = :pwhse and
                           exists(select 1 from pLabCstLne as L where
                           l.lcucde=u.uscode and l.lctask=:pTask and
                           l.lcline=:$LcLine and l.lcctyp='S' and
                           l.lcempno=:pEmpl);
                  exec sql delete from pirusera as u
                           where
                           exists(select 1 from pLabCstLne as L where
                           l.lcucde=u.usacod and l.lctask=:pTask and
                           l.lcline=:$LcLine and l.lcctyp='S' and
                           l.lcempno=:pEmpl);
               endif;
               exec sql delete from Plabcstlne
                        where lcwhse = :pwhse
                        and lcline = :$LcLine
                        and LCEMPNO = :pEmpl
                        and LCTask = :pTask;
            when (pCostT='S' and pApyStd='Y');
               // delete users associated with Std Tasks
               exec sql delete from piruser as u
                        where u.USWHSE = :pwhse and
                        exists(select 1 from pLabCstLne as L where
                        l.lcucde=u.uscode and l.lctask=:pTask and
                        l.lcline=:$LcLine and l.lcctyp='S');
               exec sql delete from pirusera as u
                        where
                        exists(select 1 from pLabCstLne as L where
                        l.lcucde=u.usacod and l.lctask=:pTask and
                        l.lcline=:$LcLine and l.lcctyp='S');
               exec sql delete from Plabcstlne
                        where lcwhse = :pwhse
                        and lcline = :$LcLine
                        and LCTask = :pTask;
         endsl;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'pMfgL(' + %trimr($LcLine) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  UpdRec    Update Record
     *----------------------------------------------------------------

      /free
       begsr UpdRec;

         error = *off;

         exsr FillRec;

         exec sql select shcode into :lcshft
              from shift,crew where
              shcode=crshft and crwhse=:pwhse
              and crcode=:pcrew
              fetch first row only;
         select;
            when pCostT='A' or (pCostT='S' and pApyStd<>'Y');
               exec sql update plabcstlne
                  Set LCSRTE  = :pLabr,
                      LCHRSD  = :pHour,
                      LCDYWK  = :DaysofWk,
                      LCBENRT = :pBnft,
                      LCOHPCT = :pOvrh,
                      LCSTAT  = :pStatus,
                      LCCTYP  = :pCostT,
                      LCSLVL  = :pScanT,
                      LCCREW  = :pCrew,
                      LCCNTR  = :pCCNTR,
                      LCIDLE  = :pIDLE,
                      LCDEFAULT  = :pDefault,
                      LCTASK  = :pTask
                  where lcwhse = :pwhse
                    and lcline = :$LcLine
                    and LCEMPNO = :pEmpl
                    and LCTask = :pTask;
            when (pCostT='S' and pApyStd='Y');
               exec sql update plabcstlne
                  Set LCSRTE  = :pLabr,
                      LCHRSD  = :pHour,
                      LCDYWK  = :DaysofWk,
                      LCBENRT = :pBnft,
                      LCOHPCT = :pOvrh,
                      LCSTAT  = :pStatus,
                      LCCTYP  = :pCostT,
                      LCSLVL  = :pScanT,
                      LCCREW  = :pCrew,
                      LCCNTR  = :pCCNTR,
                      LCIDLE  = :pIDLE,
                      LCDEFAULT  = :pDefault,
                      LCTASK  = :pTask
                  where lcwhse = :pwhse
                    and lcline = :$LcLine
                    and lcctyp = 'S'
                    and LCTask = :pTask;
         endsl;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'pMfgL(' + %trimr($LcLine) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
         endif;

         /// First lets write a log record
         exsr AddLogRec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ErrorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

         // Check and covert line if needed
         If pMfgL = *blanks;
           pMessage = 'Labor Line must be selected';
           error = *on;
           leavesr;
         Else;
         EndIf;

         // Ensure there are no duplicate configs between Warehouse,
         // Mfg Line, Employee and Task
         If pAction = 'A';     // Additions
           select;
             when pCostT = 'A';
               exec sql select count(*) into :reccnt
                   from pLabCstLne
                     where lcwhse=:pWhse and lcline=:pMfgL
                      and lcEmpno=:pEmpL and lctask=:pTask
                      and lcctyp='A';
           endsl;
           if reccnt <> 0;
             if pCostT='A';
               pMessage = 'A configuation already exist for given ' +
                        'Warehouse, Line, Employee and Task';
             else;
               pMessage = 'A configuation already exist for given ' +
                        'Warehouse, Line, and Task';
             endif;
             error = *on;
             leavesr;
           endif;
         Else;
         EndIf;

         // Ensure there is only one Default Transaction when Active
         // Employee Configuration
         reccnt=0;
         If pCostT = 'A' and pDefault='Y';     // Active Employee Only
           exec sql select count(*) into :reccnt
                 from pLabCstLne
                  where lcwhse=:pWhse
                    and lcEmpno=:pEmpL and lctask<>:pTask
                    and lcDefault='Y' and lcctyp='A';
           if reccnt <> 0;
             pMessage = 'Only one line can be defined as ' +
                        'default for specific employee';
             error = *on;
             leavesr;
           endif;
         Else;
         EndIf;

         // Return Warning if no default transactions exist for given
         // employee
         reccnt=0;
         If pCostT = 'A' and pDefault=' ' and not ignoreDefault;
           exec sql select count(*) into :howmany
                 from pLabCstLne
                  where lcwhse=:pWhse
                    and lcEmpno=:pEmpL and lcstat='A';
           exec sql select count(*) into :reccnt
                 from pLabCstLne
                  where lcwhse=:pWhse
                    and lcEmpno=:pEmpL and lcTask<>:pTask
                    and lcDefault='Y' and lcctyp='A';
           if ((reccnt = 0 and howmany>1) or (reccnt=0 and pStatus='A'))
                  and pStatus<>'I';
             pMessage = 'No transaction marked as -Default- ' +
                        'for this employee.  Click Accept to continue';
             error = *on;
             leavesr;
           endif;
         Else;
         EndIf;

         // Return Warning if MODIFIYING Labor Rate and it
         // differs from like transaction with same wh, line and task
         difflabr=0;
         If not ignoreDefault;
           select;
             when pAction = 'A' and pCostT='S';
               exec sql select lcsrte into :difflabr
                    from pLabCstLne
                     where lcwhse=:pWhse
                       and lcline=:pMfgL and lcTask=:pTask
                       and lcsrte<>:pLabr and lcctyp='S'
                       fetch first row only;
             when pAction = 'U' and pCostT = 'S';
               exec sql select lcsrte into :difflabr
                    from pLabCstLne
                     where lcwhse=:pWhse
                       and lcline=:pMfgL and lcTask=:pTask
                       and lcsrte<>:pLabr and lcempno<>:pEmpL
                       and lcctyp='S'
                       fetch first row only;
             when pCostT = 'A';
               exec sql select lcsrte into :difflabr
                    from pLabCstLne
                     where lcwhse=:pWhse
                       and lcempno=:pEmpl and lcctyp='A'
                       and lcsrte<>:pLabr
                       and lcline<>:pMfgl
                       and lcTask<>:pTask
                       fetch first row only;
           endsl;
           if difflabr <> 0;
             select;
               when pCostT = 'S';
                 pMessage = 'Labor Rate mismatch between another ' +
                            'like Standard trans(' + %char(difflabr) +
                            ').  Click Accept to continue';
               when pCostT = 'A';
                 pMessage = 'Labor Rate mismatch for this Employee ' +
                            'compared to another trans(' + %char(difflabr) +
                            ').  Click Accept to continue';
             endsl;
             error = *on;
             leavesr;
           endif;
         Else;
         EndIf;

         // Return Warning if modifiying Benefit Rate and it
         // differs from like transaction with same wh, line and task
         diffbenrt=0;
         If not ignoreDefault;
           select;
             when pAction = 'A' and pCostT='S';
               exec sql select lcbenrt into :diffbenrt
                    from pLabCstLne
                     where lcwhse=:pWhse
                       and lcline=:pMfgL and lcTask=:pTask
                       and lcbenrt<>:pbnft and lcctyp='S'
                       fetch first row only;
             when pAction = 'U' and pCostT = 'S';
               exec sql select lcbenrt into :diffbenrt
                    from pLabCstLne
                     where lcwhse=:pWhse
                       and lcline=:pMfgL and lcTask=:pTask
                       and lcbenrt<>:pbnft and lcempno<>:pEmpL
                       and lcctyp='S'
                       fetch first row only;
             when pCostT = 'A';
               exec sql select lcbenrt into :diffbenrt
                    from pLabCstLne
                     where lcwhse=:pWhse
                       and lcempno=:pEmpl
                       and lcbenrt<>:pbnft
                       and lcline<>:pMfgl
                       and lcTask<>:pTask
                       and lcctyp='A'
                       fetch first row only;
           endsl;
           if diffbenrt <> 0;
             select;
               when pCostT = 'S';
                 pMessage = 'Benefit Rate mismatch between another ' +
                            'like Standard trans(' + %char(diffbenrt) +
                            ').  Click Accept to continue';
               when pCostT = 'A';
                 pMessage = 'Benefit Rate mismatch for this Employee ' +
                            'compared to another trans(' + %char(diffbenrt) +
                            ').  Click Accept to continue';
             endsl;
             error = *on;
             leavesr;
           endif;
         Else;
         EndIf;

         // Return Warning if modifiying Overhead Rate and it
         // differs from like transaction with same wh, line and task
         diffohpct=0;
         If not ignoreDefault;
           select;
             when pAction = 'A' and pCostT='S';
               exec sql select lcohpct into :diffohpct
                    from pLabCstLne
                     where lcwhse=:pWhse
                       and lcline=:pMfgL and lcTask=:pTask
                       and lcohpct<>:povrh and lcctyp='S'
                       fetch first row only;
             when pAction = 'U' and pCostT = 'S';
               exec sql select lcohpct into :diffohpct
                    from pLabCstLne
                     where lcwhse=:pWhse
                       and lcline=:pMfgL and lcTask=:pTask
                       and lcohpct<>:povrh and lcempno<>:pEmpL
                       and lcctyp='S'
                       fetch first row only;
             when pCostT = 'A';
               exec sql select lcohpct into :diffohpct
                    from pLabCstLne
                     where lcwhse=:pWhse
                       and lcempno=:pEmpl
                       and lcohpct<>:povrh
                       and lcline<>:pMfgl
                       and lcTask<>:pTask
                       and lcctyp='A'
                       fetch first row only;
           endsl;
           if diffohpct <> 0;
             select;
               when pCostT = 'S';
                 pMessage = 'Overhead Rate mismatch between another ' +
                            'like Standard trans(' + %char(diffohpct) +
                            ').  Click Accept to continue';
               when pCostT = 'A';
                 pMessage = 'Overhead Rate mismatch for this Employee ' +
                            'compared to another trans(' + %char(diffohpct) +
                            ').  Click Accept to continue';
             endsl;
             error = *on;
             leavesr;
           endif;
         Else;
         EndIf;

         // Return Warning if modifiying Cost Center and it
         // differs from like transaction with same wh, line and task
         diffcntr=' ';
         If not ignoreDefault;
           select;
             when pAction = 'A' and pCostT='S';
               exec sql select lccntr into :diffcntr
                    from pLabCstLne
                     where lcwhse=:pWhse
                       and lcline=:pMfgL and lcTask=:pTask
                       and lccntr<>:pCcntr and lcctyp='S'
                       fetch first row only;
             when pAction = 'U' and pCostT = 'S';
               exec sql select lccntr into :diffcntr
                    from pLabCstLne
                     where lcwhse=:pWhse
                       and lcline=:pMfgL and lcTask=:pTask
                       and lccntr<>:pCcntr and lcempno<>:pEmpL
                       and lcctyp='S'
                       fetch first row only;
             when pCostT = 'A';
               exec sql select lccntr into :diffcntr
                    from pLabCstLne
                     where lcwhse=:pWhse
                       and lcempno=:pEmpl
                       and lccntr<>:pcCntr
                       and lcline<>:pMfgl
                       and lcTask<>:pTask
                       and lcctyp='A'
                       fetch first row only;
           endsl;
           if diffcntr <> *blanks;
             select;
               when pCostT = 'S';
                 pMessage = 'Cost Center mismatch between another ' +
                            'like Standard trans(' + %trim(diffCntr) +
                            ').  Click Accept to continue';
               when pCostT = 'A';
                 pMessage = 'Cost Center mismatch for this Employee ' +
                            'compared to another trans(' + %trim(diffCntr) +
                            ').  Click Accept to continue';
             endsl;
             error = *on;
             leavesr;
           endif;
         Else;
         EndIf;

         // Return Warning if adding Standard record and Housr per
         // day differs from like transaction for same wh, line and task
         diffhrsd=0;
         If pCostT = 'S' and not ignoreDefault;
           if pAction = 'A';
              exec sql select lchrsd into :diffhrsd
                    from pLabCstLne
                     where lcwhse=:pWhse
                       and lcline=:pMfgL and lcTask=:pTask
                       and lchrsd<>:pHour and lcctyp='S'
                       fetch first row only;
           else;
              exec sql select lchrsd into :diffhrsd
                    from pLabCstLne
                     where lcwhse=:pWhse
                       and lcline=:pMfgL and lcTask=:pTask
                       and lchrsd<>:pHour and lcempno<>:pEmpL
                       and lcctyp='S'
                       fetch first row only;
           endif;
           if diffhrsd <> 0;
             pMessage = 'Hours per day mismatch between another ' +
                        'like Standard trans(' + %char(diffhrsd) +
                        ').  Click Accept to continue';
             error = *on;
             leavesr;
           endif;
         Else;
         EndIf;

         // Return Warning if adding Standard record and Days Worked
         // differ from like transaction with same wh, line and task
         DaysofWk = pSun + pMon + pTue + pWed + pThu + pFri + pSat;
         difflabr=0;
         If pCostT = 'S' and not ignoreDefault;
           if pAction = 'A';
              exec sql select lcdywk into :diffdywk
                    from pLabCstLne
                     where lcwhse=:pWhse
                       and lcline=:pMfgL and lcTask=:pTask
                       and lcdywk<>:DaysofWk and lcctyp='S'
                       fetch first row only;
           else;
              exec sql select lcdywk into :diffdywk
                    from pLabCstLne
                     where lcwhse=:pWhse
                       and lcline=:pMfgL and lcTask=:pTask
                       and lcdywk<>:DaysofWk and lcempno<>:pEmpL
                       and lcctyp='S'
                       fetch first row only;
           endif;
           if sqlstt = sqlSuccess;
             if %subst(diffdywk:1:1)=*blanks;
                %subst(diffdywk:1:1)='N';
             endif;
             if %subst(diffdywk:2:1)=*blanks;
                %subst(diffdywk:2:1)='N';
             endif;
             if %subst(diffdywk:3:1)=*blanks;
                %subst(diffdywk:3:1)='N';
             endif;
             if %subst(diffdywk:4:1)=*blanks;
                %subst(diffdywk:4:1)='N';
             endif;
             if %subst(diffdywk:5:1)=*blanks;
                %subst(diffdywk:5:1)='N';
             endif;
             if %subst(diffdywk:6:1)=*blanks;
                %subst(diffdywk:6:1)='N';
             endif;
             if %subst(diffdywk:7:1)=*blanks;
                %subst(diffdywk:7:1)='N';
             endif;
             pMessage = 'Days of Week Worked mismatch between another ' +
                        'like Standard trans(' + diffdywk +
                        ').  Click Accept to continue';
             error = *on;
             leavesr;
           endif;
         Else;
         EndIf;

         // Check Task code to see if entered
         If pStatus = 'A' and
            pTask = *Blanks;
            pMessage = 'Task must be selected';
            error = *on;
            leavesr;
         EndIf;

         // Check Scan type if user is actual
         If pStatus = 'A' and
            pCostT = 'A' and
            pScanT = *Blanks;
            pMessage = 'You select scan type when actual employee';
            error = *on;
            leavesr;
         EndIf;

         // Check to see that labor rate was entered
         If pStatus = 'A' and
            ((pLabr = 0) or (pLabr > 250.000));
            pMessage = 'Valid labor rate: Greater than 0/250.00 max';
            error = *on;
            leavesr;
         endif;

         // Check that Hours per day was entered
         If pStatus ='A' and  pCostT='S' and
            ((pHour < 1) or (pHour > 12.00));
                pMessage = 'Valid labor hours: 1 hr/12.00hr max';
                error = *on;
                leavesr;
          endif;

         // Check Benefit rate
             If pStatus ='A' and
                ((pBnft < 1.0000) or (pBnft > 30.0000));
                pMessage = 'Valid Benefit Rate: .0001 min/30.0000 max';
                error = *on;
                leavesr;
             endif;

         // Check Overhead Rate
             If pStatus ='A' and
              ((pOvrh < 1.0000) or (pOvrh > 25.0000));
                pMessage = 'Valid Overhead Rate: 1 min/25.0000 max';
                error = *on;
                leavesr;
             endif;

         // Check #Emp to Add for Standard
             If pAction ='A' and pStatus='A' and
               pCostT = 'S' and pnumEmp=0;
                pMessage = 'Number of Standard Employees must be at ' +
                           'least one';
                error = *on;
                leavesr;
             endif;

         // Check Days if record is active
             if pCostT  = 'S' and
                pMon <> 'Y' and
                pTue <> 'Y' and
                pWed <> 'Y' and
                pThu <> 'Y' and
                pFri <> 'Y' and
                pSat <> 'Y' and
                pSun <> 'Y';
                pMessage = 'At least one Work Day must be selected for' +
                           ' a standard user';
                error = *on;
                leavesr;
             EndIf;

         // Ensure employee and task is not active before allowing user
         // to inactivate
             if pStatus = 'I';
                exec sql select count(*) into :reccnt
                     from pirtrand
                       where ptdwhse=:pWhse and ptdempnum=:pEmpL
                             and ptdtask=:pTask and ptdstat<'3';
                if reccnt <> *zeros;
                   pMessage = 'User and Task cannot be deactivated. ' +
                              'They have an open transaction with this Task';
                   error = *on;
                   leavesr;
                EndIf;
             EndIf;

          // get PLABCSTLNE record again
          exsr getRec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

         DaysofWk = pSun + pMon + pTue + pWed + pThu + pFri + pSat;
         LCEMPNO  = pEmpl;
         LCSRTE  = pLabr;
         LCHRSD  = pHour;
         LCDYWK  = DaysofWk;
         LCBENRT = pBnft;
         LCOHPCT = pOvrh;
         LCSTAT  = pStatus;
         LCCTYP  = pCostT;
         LCSLVL  = pScanT;
         LCUCDE  = pUcde;
         LCTASK  = pTask;
         LCIDLE  = pIDLE;
         LCDEFAULT  = pDefault;
         LCCNTR  = pCCNTR;
         GetCurrStamp();
         LCLOCTS = CurrStamploc;
         LCSYSTS = CurrStampsys;
         LCUTCTS = CurrStampuc;
         LCJOB   = #Pgm;
         LCUSER  = pUser;
         LCJOBN  = #jobn;
         LCCNTR  = pCcntr;
         // If Standard user then setup fields for PIRUSER
         // record addition

       If pCostT = 'S';
          USCODE = pUcde;
          USEMP# = pEmpl;
          USFNAM = 'Standard';
          USSTYP = 'F';
          USWHSE = pWhse;
          USNHRS = pHour;
       EndIf;
       endsr;
      /end-free
     *----------------------------------------------------------------
     *  AddLogRec  Add log record to PLABCSTLOG file
     *----------------------------------------------------------------

      /free
       begsr AddLogRec;

         Select;

         When pAction = 'A' or
              pAction = 'C';
            LCLTYPE = 'Add';
         When pAction = 'U';
            LCLTYPE = 'Update';
         When pAction = 'D';
            LCLTYPE = 'Delete';
         Other;
         EndSL;

         LCLWHSE  = LCWHSE;
         LCLLINE  = LCLINE;
         LCLCTYP  = LCCTYP;
         LCLSLVL  = LCSLVL;
         LCLEMPNO  = LCEMPNO;
         LCLUCDE  = LCUCDE;
         LCLTASK  = LCTASK;
         lclcrew = lccrew;
         lclshft = lcshft;
         lclbhr = lcbhr;
         LCLSRTE  = LCSRTE;
         LCLidle  = LCidle;
         LCLDefault  = LCdefault;
         LCLHRSD  = LCHRSD;
         LCLDYWK  = LCDYWK;
         LCLBENRT = LCBENRT;
         LCLOHPCT = LCOHPCT;
         LCLSTAT  = LCSTAT;
         LCLSYSTS = LCSYSTS;
         LCLLOCTS = LCLOCTS;
         LCLUTCTS = LCUTCTS;
         LCLJOB   = LCJOB;
         LCLUSER  = LCUSER;
         LCLJOBN  = LCJOBN;
         LCLCNTR  = LCCNTR;

         exec sql insert into plabcstlog values(:lclrec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record in PLABCSTLOG : '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'pMfgL(' + %trimr($LcLine) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         else;
         endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FldValid   Validate fields
     *----------------------------------------------------------------

      /free
       begsr FldValid;

         error = *off;
         exsr GetRec;

         // Set Default and Apply Standard flags based on Type Cost
         if pCostT = 'S';
           // there can only be one record for Standard Employee
           // and no Idle transactions apply
           pDefault='Y';
           pIdle='N';
         else;
           // Applying changes across multiple Standard employees
           // does not apply when entry is for actual employee
           pApyStd='N';
         endif;

         // Validate input

         if pAction <> 'D';
           exsr errorcheck;
           if error;
             leavesr;
           endif;
         else;
           // If delete and Costing History exist do not allow
           if pAction='D';
              reccnt=*zeros;
              exec sql
                    select count(*) into :reccnt
                      from pirTranD where ptdempnum=:pempl
                             and ptdstat='4' and ptdtask=:pTask
                        fetch first row only;
              if sqlstt=sqlSuccess and reccnt<>*zeros;
                 pMessage = 'Active Transaactions exist for Employee ' +
                      %char(pempl) + ' and Task ' + %trim(pTask) +
                      '.  Inactivate instead';
                 error = *on;
                 leavesr;
              endif;
           endif;
         endif;

         select;

           // Add

           when pAction = 'A';
             if found;
             //  pMessage = 'User definition already setup';
             //  error = *on;
             //  leavesr;
             else;
               LCWHSE  = pWhse;
               LCLINE  = $LcLine;
               LCEMPNO  = pEmpl;
               exsr AddRec;
             endif;

           // Update
           when pAction = 'U';
             if found;
               exsr UpdRec;
             endif;

           // Delete

           when pAction = 'D';
             if found;
               exsr DelRec;
             endif;

           other;
             pMessage = 'Invalid command sent: ' + pAction
                      + %trim(pAction)
                      + ' (' + %trim(#pgm) +')';
         endsl;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  GetRec    Get record
     *----------------------------------------------------------------

      /free
       begsr GetRec;

         found = *off;

         exec sql select * into :lcrec
                  from plabcstlne
                  where lcwhse = :pwhse
                    and lcline = :$LcLine
                    and lcempno = :pEmpl
                    and lcTASK = :pTask;

         if sqlstt = sqlSuccess;
           found = *on;
         endif;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  GetCurrStamp  Get current timestamps
     *----------------------------------------------------------------

     p GetCurrStamp    b
     d GetCurrStamp    pi

      /free

         getmicrotime(currstampuc:currstampsys);
640jA    ucOffset = %diff(currstampuc: currstampsys: *HOURS);
         currstamploc = currstampsys + %hours(bfcoffset);

      /end-free

     p GetCurrStamp    e

