      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')
      *----------------------------------------------------------
      *   Copyright (C) 2017 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  M24300      Prod Module Time Entry Function
      *  14 August 2017
      *  Kenneth Elder
      *
      *  Revisions:
      *
710 A*    08/14/17  KDE  7.10
     *      - Created.
730 A*    02/20/19  KDE  7.30
     *      - Return error if Costing not turned on
      *
      *----------------------------------------------------------

      *----------------------------------------------------------
      * File Specs
      *----------------------------------------------------------
710kAfpLabCstLneif   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      *----------------------------------------------------------
      *  Program information data structure
      *----------------------------------------------------------

      /copy qcopysrc,c#pgminfds
      /COPY *libl/qcopysrc,C#PROD

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pSess          s             40
     D  pUser          s             10
     D  pLib           s             10
     D  pPgm           s             10
     D  pEmpnum        s              5  0
     D  pWhse          s              3  0
     D  pClkCode       s              1
     d  pTask          s              6
     d  pLine          s              4
     d  pWo            s             13
     d  pOutStr        s           1024

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d CalcHours       pr             5p 0
     d  fromTS                         z   const
     d  ToTS                           z   const

     d chkEndDay       pr
     d  shift                         6    const
     d  startTS                        z   const
     d  endTS                          z   const

     d CreateTS        pr              z
     d  date                          8p 0 const
     d  time                          6p 0 const

     *
     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

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

     *----------------------------------------------------------
     *  Variables
     *----------------------------------------------------------

     d changetask      s              1
     d chkDriErr       s             60
     d clockin         s               n
     d currtime        s               z   inz(*sys)
     d curtrn#         s              7  0
     d ElapsedDays     s              4  0
     d ElapsedHours    s              5  0
     d ElapsedMins     s              7  0
     D ItemExist       s              1
730aAd opUseCost       s              1
     D noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')
     d pMessage        s             99
     d rtnDefault      s              6
     d rtnWo           s             13
     d rtnDept         s              3
     d rtnTran         s              7  0
     d rtnTask         s              6
     d rtnClkTask      s             10
     d rtnStrT         s             40
     d rtnLapseT       s             40
     d rtnName         s             40
     d rtnNo           s             10
     d saveTask        s             10
     d rtnType         s              1
     d rtnStype        s              1
     D saveVer#        s                   like($ppver#)
     D shftBegin       s               z
     d shftBtime       s              6  0
     d shftEtime       s              6  0
     D shiftEnd        s               z
     d Time1           s               z
     d wkDefault       s              6
     d addlTasks       s             24
     d wkError         s               n
     d wkfnam          s             20
     d wklnam          s             20
     d wkline          s              3  0
     d wrkemp          s              5  0

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS
      /COPY *libl/qcopysrc,C#DRIPARMP

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D shrec         E Ds                  Extname(shift)
     D ptdrec        E Ds                  Extname(pirtrand)
     D ptrec         E Ds                  Extname(pirtran)

     *----------------------------------------------------------------
     *  Called programs
     *

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSess        Session Id
     *      pWhse        Warehouse
     *      pEmpnum      Employee Number
     *      pClkCode     Clock Code
     *
     *    Returned Parameters
     *      All
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pSess
     c                   parm                    pUser
     c                   parm                    pLib
     c                   parm                    pPgm
     c                   parm                    pWhse
     c                   parm                    pEmpnum
     c                   parm                    pClkCode
     c                   parm                    pTask
     c                   parm                    pLine
     c                   parm                    pWo
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        changetask = '0';

        exsr EditCheck;
        if not error;
           select;
              when pClkCode = 'S';      // Scan from M243xx
                 exsr determineTrans;
                 rtnClkTask = 'Clock In';
              when pClkCode = 'L';      // Click Lunch from M247xx
                 exsr determineTrans;
                 rtnClkTask = 'Lunch';
              when pClkCode = 'B';      // Click Break from M247xx
                 exsr determineTrans;
                 rtnClkTask = 'Break';
              when pClkCode = 'D';      // Return to Default Task
                 exsr determineTrans;
                 // return clock task set in generatelabor routine for D
              when pClkCode = 'E';      // End of Day
                 rtnClkTask = 'Clock Out';
                 exsr determineTrans;
              when pClkCode = 'T';      // Retrieve Current Transaction Info
                 exsr determineTrans;
              when pClkCode = 'C';      // Change Task, or Line, or Work Order
                 exsr determineTrans;
                 rtnClkTask = pTask;
           endsl;
        endif;

        // Return field with up to four additional tasks employee
        // has defined in PLABCSTLNE.  Allows them to change to
        // these tasks if need be
        addlTasks=*blanks;
        setll (pWhse:pEmpnum) pLabCstLne;
        reade (pWhse:pEmpnum) pLabCstLne;
        dow not %eof(pLabCstLne);
           if lctask <> wkDefault;
              select;
                 when %subst(addlTasks:1:6)=*blanks;
                    %subst(addltasks:1:6) = lctask;
                 when %subst(addlTasks:7:6)=*blanks;
                    %subst(addltasks:7:6) = lctask;
                 when %subst(addlTasks:13:6)=*blanks;
                    %subst(addltasks:13:6) = lctask;
                 when %subst(addlTasks:19:6)=*blanks;
                    %subst(addltasks:19:6) = lctask;
                 other;
                    leave;
              endsl;
           endif;
           reade (pWhse:pEmpnum) pLabCstLne;
        enddo;
        // Build and Return Json Data
          pOutStr = '{'
                 +  '"pMessage":"'  + %trim(pMessage) + '",'
                 +  '"changetask":"'  + %trim(changetask) + '",'
                 +  '"rtnName":"'  + %trim(rtnName) + '",'
                 +  '"rtnTran":"'  + %trim(%char(rtnTran)) + '",'
                 +  '"rtnTask":"'  + %trim(rtnTask) + '",'
                 +  '"rtnClkTask":"'  + %trim(rtnClkTask) + '",'
                 +  '"rtnStrT":"'  + %trim(rtnStrT) + '",'
                 +  '"rtnNo":"'  + %trim(rtnNo) + '",'
                 +  '"rtnType":"'  + %trim(rtnType) + '",'
                 +  '"rtnWo":"'  + %trim(rtnWo) + '",'
                 +  '"rtnDept":"'  + %trim(rtnDept) + '",'
                 +  '"rtnDefault":"'  + %trim(wkDefault) + '",'
                 +  '"addlTasks":"'  + %trim(addlTasks) + '",'
                 +  '"rtnStype":"'  + %trim(rtnStype) + '",'
                 +  '"rtnLapseT":"'  + %trim(rtnLapseT) + '"}';
        *inlr = *on;

      /end-free

     *----------------------------------------------------------
     *  determineTrans  -  Determine proper Labor transaction
     *----------------------------------------------------------

      /free
          begsr determineTrans;

             // Default return values to loval in case employee
             // not clocked in.
             curtrn#=0;
             rtnTran = 0;
             rtnName = '';
             rtnTask = '';
             rtnStrT = '';
             rtnLapseT = '';
             // Employee Number scanned.  If employee has active
             // transaction within 2 hours before or 2 hours after
             // their scheduled shift then return a code that says
             // we should display a scrren that reflects what the
             // employee is currently scanned on, and for how long.
             // They will have the option to go to other charge
             // codes or return without change

             // first look to see if an active transaction exist
             exec sql select *
                         into :ptdrec
                         from pirtrand
                           where ptdwhse=:pWhse and ptdstat='2'
                              and ptdempnum=:pEmpnum
                            order by ptdsts desc
                          fetch first row only;
             if sqlStt = SqlSuccess;
                curtrn#=ptdtran;
                // if a open record within 12 hours was clocked we
                // will return flag saying to prompt for task change.
                // Otherwise we will simply issue a task change to
                // default production task as defined in pLabCstLne.
                ChkEndDay(ptdshft:ptdsts:ptdets);
                if clockin;
                   // Set rtnNo flag which tells M24700 which buttons
                   // to disable based on current task.  In other words,
                   // if employee is on break or lunch they should not
                   // be allowed to click break or lunch.  If already
                   // on default task they should not be allowed to
                   // change to default task
                   rtnno=*blanks;
                   select;
                      when ptdtask='LUNCH' or ptdTask='Lunch' or
                           ptdtask='BREAK' or ptdTask='Break';
                         rtnNo = 'nolunbrk';
                      when ptdtask=wkdefault;
                         rtnNo = 'nodefault';
                   endsl;
                   // since employee is clocked in we will simnply
                   // return a changetask value of '1' meaning we
                   // should display a screen that allows the
                   // employee to change task, line or work order
                   changetask = '1';
                   rtnTran = ptdtran;
                   rtnTask = ptdtask;
                   exec sql select usfnam,uslnam into :wkfnam,:wklnam
                        from piruser
                           where uswhse=:pWhse and usemp#=:pEmpnum
                            fetch first row only;
                   if sqlStt = sqlSuccess;
                      rtnName = %trim(wkfnam) + ' ' + %trim(wkLnam);
                   else;
                      rtnName = '* Employee Name not Found *';
                   endif;
                   // spell out date and time in string format
                   rtnStrt = %char(%subdt(ptdsts:*months)) + '/' +
                             %char(%subdt(ptdsts:*days)) + ' at ' +
                             %char(%subdt(ptdsts:*hours)) + ':' +
                             %char(%subdt(ptdsts:*minutes));
                   // Get day of week for current Start Date
                   select;
                     when %rem(%diff(ptdsts:d'0001-01-01':*days):7)=0;
                        rtnStrt = 'Monday ' + %trim(rtnStrt);
                     when %rem(%diff(ptdsts:d'0001-01-01':*days):7)=1;
                        rtnStrt = 'Tuesday ' + %trim(rtnStrt);
                     when %rem(%diff(ptdsts:d'0001-01-01':*days):7)=2;
                        rtnStrt = 'Wednesday ' + %trim(rtnStrt);
                     when %rem(%diff(ptdsts:d'0001-01-01':*days):7)=3;
                        rtnStrt = 'Thursday ' + %trim(rtnStrt);
                     when %rem(%diff(ptdsts:d'0001-01-01':*days):7)=4;
                        rtnStrt = 'Friday ' + %trim(rtnStrt);
                     when %rem(%diff(ptdsts:d'0001-01-01':*days):7)=5;
                        rtnStrt = 'Saturday ' + %trim(rtnStrt);
                     when %rem(%diff(ptdsts:d'0001-01-01':*days):7)=6;
                        rtnStrt = 'Sunday ' + %trim(rtnStrt);
                   endsl;
                   time1 = %timestamp();
                   // place duration in string format to return
                   ElapsedDays = %diff(time1: ptdsts: *days);
                   if ElapsedDays > *zero;
                      Time1 -= %days(ElapsedDays);
                   endif;

                   ElapsedHours = %diff(time1: ptdsts: *hours);
                   if ElapsedHours > *zero;
                     Time1 -= %hours(ElapsedHours);
                   endif;

                   ElapsedMins = %diff(time1: ptdsts: *minutes);

                   select;
                      when ElapsedDays <> *zeros;
                         rtnLapseT = %char(ElapsedDays) + ' days, ' +
                           %char(ElapsedHours) + ' hours, and ' +
                           %char(ElapsedMins) + ' minutes';
                      when ElapsedHours <> *zeros;
                         rtnLapseT = %char(ElapsedHours) + ' hours, and ' +
                           %char(ElapsedMins) + ' minutes';
                      when ElapsedMins <> *zeros;
                         rtnLapseT = %char(ElapsedMins) + ' minutes';
                   endsl;

                else;
                   changetask = '0';
                endif;
             else;
                 changetask = '0';
             endif;

             savever# = $ppver#;
             clear $pprod;
             clear $pprod;
             $ppver# = savever#;
             $drisubcmd = '*STRLAB';

             select;
                when (changetask = '0' or pclkCode='L' or pclkcode='D'
                  or pclkCode='B' or pClkCode='E' or pClkcode='C')
                  and pClkCode<>'T';
                  // if no active transaction is found for this employee
                  // we should start their day and a zero will be returned
                  // to MRC screen meaning we should simply state they were
                  // clocked in.

                  //  do not generate additional transaction if employee
                  // goes to Change Task screen on Production Clock screen
                  // and hits accept but did not change anything.
                  if pClkCode='C' and
                     ((rtnType='D' and
                     ptask=ptdtask and %trim(pwo)=%trim(rtnwo) and
                          %trim(pline)=%trim(rtndept)) or
                       (rtnType='I' and ptask=ptdtask));
                     // do nothing
                     // when indirect and task matches current task
                     // or when direct and either task, mfg line
                     // or work order differ
                  else;
                     exsr generatelabor;
                  endif;
             endsl;

          endsr;
      /end-free

     *----------------------------------------------------------
     *  editCheck  -  Confirm data is good
     *----------------------------------------------------------

      /free
          begsr editCheck;

             // Get Cost setting from options record
             exec sql select opUseCost into :opUseCost
                        from opsProd
                         where opwhse=900;

             // If Costing not turned on and setup return error
             if sqlstt<>'00000' or opUseCost <> 'Y';
                pMessage = 'Costing not setup nor turned on.  Please ' +
                            'BFC';
                error = *on;
                leavesr;
             endif;

             // Convert incoming Mfg Line to 000
             // Convert Labor line
             if pClkCode='C';      // Change Task, Mfg Line, Work Order
                If %trim(pLine) <> 'ALL' and
                  %trim(pLine) <> *Blanks;
                  monitor;
                     // if numeric we convert line 3 to 003
                     pLine = %editC(%Dec(pLine:3:0):'X');
                  on-error;
                     // on error we do nothing and pass as is
                  endmon;
                else;
                   if %trim(pline) = *blanks;
                      pMessage = 'Mfg Line cannot be empty';
                      error = *on;
                      leavesr;
                   endif;
                EndIf;

                if pTask = *blanks;
                   pMessage = 'Task cannot be empty';
                   error = *on;
                   leavesr;
                endif;

             else;
                pLine = *blanks;
                pWo=*blanks;
                pTask=*blanks;
             endif;

             pmessage = '*OK';
             // Make sure employee has active record defined in
             // PLABCSTLNE.  Look for Default first
             exec sql select lcempno,lctask,lcslvl
                       into :wrkemp,:wkdefault,:rtnStype
                  from plabcstlne
                    where lcwhse=:pwhse and
                          lcempno=:pEmpnum
                          and lcdefault='Y'
                          and lcctyp='A' and lcstat='A'
                          fetch first row only;
             if sqlStt <> sqlSuccess;
                // if default is not found get first non default
                // record to clock in with
                exec sql select lcempno,lctask,lcslvl
                          into :wrkemp,:wkdefault,:rtnStype
                     from plabcstlne
                       where lcwhse=:pwhse and
                             lcempno=:pEmpnum
                             and lcctyp='A' and lcstat='A'
                             fetch first row only;
             endif;
             if sqlStt <> SqlSuccess;
                error = *on;
                pmessage = 'Employee number ' + %char(pEmpnum) +
                           ' is either not defined in Cost File or' +
                           ' setup as a Standard Employee';
                leavesr;
             endif;
          endsr;
      /end-free

     *----------------------------------------------------------------
     *  GenerateLabor  - Generate appropriate labor Transaction
     *----------------------------------------------------------------

     c     GenerateLabor begsr
      /free

           $ppWhse = pWhse;             // Warehouse
           $pptrn# = curtrn#;           // Current Transaction
           $ppExpDt = %uns(%char(%Date():*Iso0));   // Date for Transaction
           $ppcord = %uns(%char(%time():*Iso0));    // current time for transact
           $ppuseru = *on;

           // For punch in transaction we will place on ALL work orders and
           // Mfg Line per the Labor Definition line (pLabCstLne)
           exec sql select substr(lcline,1,3),lcucde,lctask
                         into :$ppPrimary, :$ppUser, :$ppCustwo
                     from pLabCstLne
                    where lcwhse=:pWhse and lcempno=:pEmpnum
                        and lcstat='A'
                      fetch first row only;
           // if either the line definition says *ALL, or not
           // found we should put employee on ALL Mfg Lines
           if $ppPrimary = *blanks or $ppPrimary='*AL'
              or sqlStt <> sqlSuccess;
              $ppPrimary = 'ALL';
           else;
              // when record found we should ensure the line still
              // exists.  If so, clock in on that line, otherwise
              // use ALL
              exec sql select inlneno into :wkline
                        from plined
              where TRANSLATE(:$ppPrimary , '*' , ' 0123456789') = ' '
                and inlneno = cast(:$ppPrimary as int);
              if sqlStt <> sqlSuccess;
                 $ppPrimary = 'ALL';
              endif;
           endif;
           $ppWo# = 'ALL';

           // certain codes should override default task
           select;
              when pclkCode='L';        // option for Lunch
                 $ppCustwo='LUNCH';
                 $ppPrimary=*blanks;
                 $ppWo#=*blanks;
                 $ppTrn#=*zeros;
              when pclkCode='B';        // option for Break
                 $ppCustwo='BREAK';
                 $ppPrimary=*blanks;
                 $ppWo#=*blanks;
                 $ppTrn#=*zeros;
              when pclkCode='E';        // option to End Day (Clockout)
                 $drisubcmd = '*CLSLAB';
                 $ppCustwo='ENDDAY';
                 $ppPrimary=*blanks;
                 $ppWo#=*blanks;
                 $ppTrn#=*zeros;
              when pclkCode='C';        // Option to Change task, line, wo
                 $ppCustwo=pTask;
                 $ppPrimary=pLine;
                 $ppWo#=pWo;
              when pclkCode='S' AND curtrn#<>*zeros and not clockin;
                 // if Basic scan and employee is own from previous day
                 // we should first do End of Day and then fall through
                 // and perform normal transaction for new day
                 $dricommand = '*PROD';
                 $drisubcmd = '*CLSLAB';
                 pWo = $ppWo#;
                 pLine = $ppPrimary;
                 saveTask = $ppCustwo;
                 $ppCustwo='ENDDAY';
                 $ppPrimary=*blanks;
                 $ppWo#=*blanks;
                 $ppTrn#=*zeros;
                 $drisys2upd = 'D';
                 exsr zzDriCop;
                 $drisubcmd = '*STRLAB';
                 $ppCustwo = saveTask;
                 $ppPrimary=pLine;
                 $ppWo#=pWo;
              endsl;

           $dricommand = '*PROD';

           $drisys2upd = 'D';
           exsr zzDriCop;
           if $driReturn <> '*OK';
              chkDriErr = $driMessage;
           else;
              // return active Transaction Number
              curtrn# = $ppTrn#;
              if pClkCode='D';
                 exec sql select pttask into :rtnClkTask
                      from pirTran where pttrn#=:curTrn#
                       fetch first row only;
              endif;
           endif;

      /End-free
     c                   endsr

     *----------------------------------------------------------------
     *  zzdriCop   Call DRICOP
     *----------------------------------------------------------------

     c     zzDriCop      begsr
     *
     c                   eval      wkError = *off
     *
     c                   select
     *
     c                   when      $dricommand = '*PROD'
     c                   eval      $dridata = $pprod
     c                   eval      $dridata2 = $pprod2

     c                   endsl
     *
     c                   select
     *
     c                   when      $dricommand = '*PROD'
     c                   call(e)   'DRICOP'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata
     c                   parm                    $dridata2

     c                   other
     c                   call(e)   'DRICOP'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata

     c                   endsl

     c                   select

     c                   when      %error
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      pMessage = $drimessage
     c                   endif
     c                   eval      pMessage  = 'Error occured on call to '
     c                                       + 'DRICOP'
     c                                       + '/' + %trim($drisubcmd)
     c                                       + ' from ' + #prog

     c                   when      $drireturn <> '*OK'
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      pMessage = $drimessage
     c                   endif

     c                   endsl

     c                   select
     c                   when      $dricommand = '*PROD'
     c                   eval      $pprod = $dridata
     c                   eval      $pprod2 = $dridata2
     c                   endsl

     c                   endsr
      *----------------------------------------------------------
      *  *INZSR   Initialization subroutine
      *----------------------------------------------------------

      /free
          begsr *INZSR;

          endsr;
      /end-free

     *----------------------------------------------------------------
     *                      Sub Procedures
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  CalcHours   Calculate hours between timestamps
     *----------------------------------------------------------------

     p CalcHours       b
     d CalcHours       pi             5p 0
     d  fromTS                         z   const
     d  toTS                           z   const

     *  Local Variables

     D hours           s              5p 0

      /free

        select;
          when fromTS = noStamp;
            hours = 0;
          when toTS = noStamp;
            hours = 0;
          when fromTS > toTS;
            hours = 0;
          other;
            monitor;
              hours = %diff(toTS: fromTS: *HOURS);
            on-error;
              hours = 0;
            endmon;
        endsl;

        return hours;

      /end-free

     p CalcHours       e

     *----------------------------------------------------------------
     *  ChkEndDay
     *
     *    Determine whether Production user should simply be clocked
     *    in or asked for a task change
     *
     *----------------------------------------------------------------

     p ChkEndDay       b
     d ChkEndDay       pi
     d shift                          6    const
     d startTS                         z   const
     d endTS                           z   const

     *  Local Variables

     d shiftEndTS      s               z
     d shiftStartTS    s               z
     d startYMD        s              8s 0

      /free

        // Get Task Type (Direct or Indirect)

        rtnType = 'I';
        exec sql select tktype into :rtnType
                  from task
                  where tkcode=:ptdtask
                  fetch first row only;

        // Get current Mfg Line and Work ORder if exist
        rtnWo=*blanks;
        rtnDept=*blanks;
        if rtnType = 'D';
           exec sql select ppwo#,ppline into :rtnWo, :rtnDept
                      from pirTranp
                         where ppwhse=:ptdwhse and ppTrn#=:ptdtran
                         fetch first row only;
        endif;

        // Get Shift record

        exec sql select * into :shrec
                 from shift
                 where shwhse = :pWhse
                   and shwhdp = ' '
                   and shcode = :shift
                   fetch first row only;

        // If Shift record not found, get out.
        // The end TS/UC should have been passed in as the 'new' values.

        if sqlstt <> sqlSuccess;
          // code to see within 12 hours
          if calcHours(startTS:%timestamp()) > 12;
             clockin=*off;
          else;
             clockin=*on;
          endif;
          return;
        endif;

        // Create Shift start/end timestamps

        startYMD = %dec(%date(startTS):*iso);
        shiftStartTS = CreateTS(startYMD: shstim);
        shiftEndTS = CreateTS(startYMD: shetim);

        // Adjust Shift end TS if shift over midnight

        if shetim < shstim;
          shiftEndTS += %days(1);
        endif;

        // If transaction started within Shift range
        //   turn on "clockin" as indicator to present
        //   task change screen, otherwise turn off
        //   "clockin" to simply perform clockin

       // if startTS >= shiftStartTS and startTS <= shiftEndTS;
       //   clockin = *on;
       // else;
          if calcHours(startTS:%timestamp()) > 12;
             clockin=*off;
          else;
             clockin=*on;
          endif;

       // endif;

        return;

      /end-free

     p ChkEndDay       e

     *----------------------------------------------------------------
     *  CreateTS   Create timestamp from Date/Time
     *----------------------------------------------------------------

     p CreateTS        b
     d CreateTS        pi              z
     d  date                          8p 0 const
     d  time                          6p 0 const

     *  Local Variables

     D stamp           s               z
     D temp26          s             26

     D                 ds
     D  yyyymmdd               1      8s 0
     D    yyyy                 1      4
     D    mm                   5      6
     D    dd                   7      8

     D                 ds
     D  hhmiss                 1      6s 0
     D    hh                   1      2
     D    mi                   3      4
     D    ss                   5      6


      /free

        clear stamp;

        if date = 0;
          return stamp;
        endif;

        yyyymmdd = date;
        hhmiss = time;
        temp26 = yyyy + '-' + mm + '-' + dd + '-'
               + hh + '.' + mi + '.' + ss + '.000000';

        monitor;
          stamp = %timestamp(temp26);
        on-error;
          clear stamp;
        endmon;

        return stamp;

      /end-free

     p CreateTS        e
