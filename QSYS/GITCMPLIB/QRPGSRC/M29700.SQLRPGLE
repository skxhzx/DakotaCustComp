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
     *  M29700    Edit/Build Cycle Count Entry
     *  25 July 2019
     *  Kenneth Elder
     *

     *----------------------------------------------------------------
     *  Revisions
     *
730 A*    07/25/19  KDE  7.30
     *      - Created
740 A*    05/01/20  KDE  7.40
     *      - Add sequence number to ensure user taken through same
     *        order on RF Gun as created based on RTC Option selected
740aA*    09/24/20  KDE  7.40a
     *      - Change update sql to happen in sub-procedure
750 A*    03/22/21  KDE  7.50
     *      - Fix:  Not getting base slots for selected items when
     *        item is in virtual.  Need to pull in that base slot that
     *        then selected item lives even though only in virtual of that base
     *      - Enh:  Added 5th sort
750aA*    03/26/21  KDE  7.50a
     *      - Fix:  Not reading option settings when performing scope copy
750bA*    04/07/21  LMC  7.50b
     *      - Enh:  add default order by if no sort by pages is set   copy
     *        in RTC options.                                         copy
750cA*    04/21/21  KDE  7.50c
     *      - Fix:  Exclude BF slots
750dA*    01/26/22  LMC  7.50d
     *      - Fix:  Don't trim adjustment code, some clients have
     *        code like ' 1'
750eA*    02/14/22  LMC  7.50e
     *      - Enh:  add adj code validation.
760 A*    07/06/22  KDE  7.60
     *      - Fix:  No longer call assign pages in this program.  Called now
     *        in M29800C when user displays or prints pages
     *
     *----------------------------------------------------------------

650aAFworkrtcs  uf a e           k disk    usropn
     fpiritem   if   e           k disk
     fitemfld   if   e           k disk
     fitemcls   if   e           k disk
     foptions   if   e           k disk

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D rtcsrec       E ds                  extname(rtcscpd) inz(*EXTDFT)
     D slrec         E ds                  extname(slot) inz(*EXTDFT)
740 AD wksrecs       E ds                  extname(workrtcs) inz(*EXTDFT)
740aAd                                     prefix(i)

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

750eA*----------------------------------------------------------------
750eA*  files
750eA*----------------------------------------------------------------

750eAD adrec         E Ds                  Extname(adjcode)
     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D ts              s               z

     D bfcoffset       s              3  0 inz(0)


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.cvtcase
      /copy qcopysrc,p.dricop
      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getuser
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
     *  *RTC     -  Realtime Inventory Count Options
     *
     * Fields
     *
     *    OPASGNP -  Assign Slots to Page Id
     *    OPPGLVL -  Assign Page Id for each Level Break
     *    OPZTRN  -  Generate Zero Difference Transaction
     *    OPMSLT  -  Max slots per Page Id when selected
     *    OPSRT1  -  Sort Page Assignment by Dept, Aisle, Side Desc, Lvl, Loc, Hnd
     *    OPSRT2  -  Sort Page Assignment by Dept, Aisle, Side Desc, Loc, Lvl, Hnd
     *    OPSRT3  -  Sort Page Assignment by Dept, Styp, Aisle, Side Desc, Loc, Lvl, Hnd
     *    OPSRT4  -  Sort Page Assignment by Dept, Styp, Aisle, Side Desc, Loc, Hnd
750 A*    OPSRT5  -  Sort Page Assignment by Dept, Aisle, Loc, Level, Hand
     *
     * Data structure
     *
     D opdta           ds
     D  opasgnp                1      1
     D  oppglvl                2      2
     D  opztrn                 3      3
     D  opmslt                 4      6  0
     d  opsrt1                 7      7
     d  opsrt2                 8      8
     d  opsrt3                 9      9
     d  opsrt4                10     10
     d  opsrt5                18     18

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
     d vslots          s             10  0
     d lastpos         s              5  0
     d nextBegin       s              5  0
     d lenchar         s              5  0
     d lpos            s              5  0
     d newDir          s            300
     d p_rtcsuid       s              7  0
     d p_rtcsseq       s              5  0
     d p_rtcswhs       s              3  0
     d p_rtcsselun     s              1
     d p_rtcsstyp      s              1
     d p_rtcsadjc      s              2
     d p_rtcsecwi      s              1
     d p_rtcswhdp      s              5
     d p_rtcssect      s              1
     d p_rtcsfaisl     s              3
     d p_rtcstaisl     s              3
     d p_rtcsfloc      s              3  0
     d p_rtcstloc      s              3  0
     d p_rtcsflvl      s              2  0
     d p_rtcstlvl      s              2  0
     d p_rtcsfhs       s              2
     d p_rtcsths       s              2
     d p_rtcsside      s              1
     d p_rtcsdesg      s              5
     d p_rtcscat       s              5
     d p_rtcsclcde     s             10
     d p_rtcsivnd      s             10  0
     d p_rtcsitem      s             15
     d p_rtcspsts      s              1
     d prv_whdp        s              5
     d prv_type        s              1
     d prv_Aisl        s              3
     d prv_side        s              1  0
     d prv_lvl         s              2  0
     D e$whse          s              3  0
     D e$emp#          s              5  0
     D e$fnam          s             15
     D e$init          s              1
     D e$lnam          s             20
     D e$whdp          s              5
     D e$styp          s              1
     D e$shft          s              6
     D e$crew          s              6
     D e$nhrs          s              3  1
     D e$rtn           s              8
     D e$bpu           s              1
     D e$lng           s              2
     d psubcmd         s              1
     d pPageOpt        s             10
     d pageid          s              5  0
     d cntPerPage      s              3  0
740 Ad wrkseq          s              9  0
750 Ad pdisp           s             12
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

     d WrtBeforeDebug  pr
     d WrtAfterDebug   pr
     d WrtDebugError   pr

     d updSequence     pr

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

        exsr getcurrstamp;

        select;
          when %trim(pobjloc)='M29800C';
             // When called from M29800c we are copying an existing
             // Cycle Count and pass in the copy from UID in PARMSTR1
             if %trim(pparmstr1)='';
                pparmstr1='0';
             endif;
             monitor;
               p_rtcsuid=%dec(%trim(pparmstr1):7:0);
             on-error;
               p_rtcsuid=0;
             endmon;
             if %trim(pparmstr2)='';
                pparmstr2='0';
             endif;
             monitor;
               p_rtcswhs=%dec(%trim(pparmstr2):3:0);
             on-error;
               p_rtcswhs=0;
             endmon;

750aA        e$whse = p_rtcswhs;

750aA        chain (e$whse:'*RTC') options;
750aA        if %found(options);
750aA          eval opdta=opdata;
750aA           // protect against numeric value not being updated properly outside of system
750aA           monitor;
750aA             eval opmslt=opmslt;
750aA           on-error;
750aA             eval opmslt=0;
750aA           endmon;
750aA        else;
750aA           eval opdta=*blanks;
750aA           eval opmslt = *zeros;
750aA        endif;
             exsr writeslots;
          other;
            // when being called from MRC
            pMessage = '';
            error = *off;

            // Extract parameters from delimited string

            ExtractParms();

            if %trim(pMessage) = '';
               exsr Afteract;
            endif;
        endsl;

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


         getUser(puser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                 e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                 e$bpu: e$lng);

         chain (e$whse:'*RTC') options;
         if %found(options);
            eval opdta=opdata;
            // protect against numeric value not being updated properly outside of system
            monitor;
              eval opmslt=opmslt;
            on-error;
              eval opmslt=0;
            endmon;
         else;
            eval opdta=*blanks;
            eval opmslt = *zeros;
         endif;

      /end-free

      /free
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AddRec    Add record
     *----------------------------------------------------------------

      /free
       begsr AddRec;

         error = *off;

         exsr FillRec;

         exec sql insert into rtcscpd values(:rtcsrec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Id(' + %char(p_rtcsuid) + ') '
                    + 'Whse(' + %char(rtcswhs) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AfterAct     After action update
     *----------------------------------------------------------------

      /free
       begsr AfterAct;

       error = *off;
       if pSubCmd <> 'D';
         exsr errorCheck;
       endif;

       if not error;

         exsr GetRec;

         select;
           when pSubCmd = 'A';
             if found;
               exsr UpdRec;
               exsr writeslots;
             else;
               exsr AddRec;
               exsr writeslots;
             endif;
           when pSubCmd = 'U' or pSubCmd = 'C';
             if found;
               exsr UpdRec;
               exsr writeslots;
             else;
               exsr AddRec;
               exsr writeslots;
             endif;
           when pSubCmd = 'D';
             if found;
               exsr DelRec;
               exsr writeslots;
             endif;
           other;
             pMessage = 'Invalid command sent: ' + pSubCmd
                      + %trim(pSubCmd)
                      + ' (' + %trim(#pgm) +')';
         endsl;
       endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  errorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

          // Make sure Adjustment code is selected
          if p_rtcsadjc = *blanks;
             pMessage = 'Adjustment Code must be selected';
             error = *on;
             leavesr;
          endif;
750eA     // Make sure Adjustment code is valid
750eA     if p_rtcsadjc <> *blanks;
750eA       exec sql select * into :adrec
750eA            from adjcode
750eA            where adcode = :p_rtcsadjc;
750eA
750eA       If sqlstt <> sqlSuccess;
750eA         pMessage = 'Adjustment Code is invalid-Use Lookup';
750eA         error = *on;
750eA         leavesr;
750eA       endif;
750eA     endif;
730aA
730aA     // Ensure that From Location is between 1 and 999
730aA     if p_rtcsfloc<>*zeros and p_rtcsfloc>999;
730aA        pMessage = 'From Location must be between 1 and 999';
730aA        error = *on;
730aA        leavesr;
730aA     endif;
730aA
730aA     // Ensure that To Location is between 1 and 999
730aA     if p_rtcstloc<>*zeros and p_rtcstloc>999;
730aA        pMessage = 'To Location must be between 1 and 999';
730aA        error = *on;
730aA        leavesr;
730aA     endif;
730aA
730aA     // Ensure that To Location is greater than from Location
730aA     if p_rtcstloc<>*zeros and p_rtcsfloc>p_rtcstloc;
730aA        pMessage = 'To Location must be greater than from Location';
730aA        error = *on;
730aA        leavesr;
730aA     endif;
730aA
730aA     // Ensure that From Level is between 1 and 99
730aA     if p_rtcsflvl<>*zeros and p_rtcsflvl>99;
730aA        pMessage = 'From Level must be between 1 and 99';
730aA        error = *on;
730aA        leavesr;
730aA     endif;
730aA
730aA     // Ensure that To Level is between 1 and 99
730aA     if p_rtcstlvl<>*zeros and p_rtcstlvl>99;
730aA        pMessage = 'To Level must be between 1 and 99';
730aA        error = *on;
730aA        leavesr;
730aA     endif;
730aA
730aA     // Ensure that To Level is greater than from Level
730aA     if p_rtcstlvl<>*zeros and rtcsflvl>p_rtcstlvl;
730aA        pMessage = 'To Level must be greater than from Level';
730aA        error = *on;
730aA        leavesr;
730aA     endif;
730aA
730aA     // Ensure that From Handstack is between A and ZZ
730aA     if p_rtcsfhs<>*blanks and p_rtcsfhs>'ZZ';
730aA        pMessage = 'From Handstack must be between A and ZZ';
730aA        error = *on;
730aA        leavesr;
730aA     endif;
730aA
730aA     // Ensure that To Handstack is between A and ZZ
730aA     if p_rtcsths<>*blanks and p_rtcsths>'ZZ';
730aA        pMessage = 'To Handstack must be between A and ZZ';
730aA        error = *on;
730aA        leavesr;
730aA     endif;
730aA
730aA     // Ensure that To Handstack is greater than from Handstack
730aA     if p_rtcsths<>*blanks and p_rtcsfhs>p_rtcsths;
730aA        pMessage = 'To Handstack must be greater than from Handstack';
730aA        error = *on;
730aA        leavesr;
730aA     endif;

          // Ensure To Aisle is greater than From Aisle
          // This condition needs to be met to properly enforce
          // possible Aisle overlaps in next check
          if p_rtcstaisl<>*blanks and p_rtcsfaisl>p_rtcstaisl;
             pMessage = 'From Aisle must be less than To Aisle';
             error = *on;
             leavesr;
          endif;

          // right justify From Aisle
          select;
            when %len(%trim(p_rtcsfaisl)) = 1;
	             rtcsfaisl = '  ' + %trim(p_rtcsfaisl);
            when %len(%trim(p_rtcsfaisl)) = 2;
	             rtcsfaisl = ' ' + %trim(p_rtcsfaisl);
            other;
	             rtcsfaisl = p_rtcsfaisl;
          endsl;
          // right justify To Aisle
          select;
            when %len(%trim(p_rtcstaisl)) = 1;
	             rtcstaisl = '  ' + %trim(p_rtcstaisl);
            when %len(%trim(p_rtcstaisl)) = 2;
	             rtcstaisl = ' ' + %trim(p_rtcstaisl);
            other;
	             rtcstaisl = p_rtcstaisl;
          endsl;

          // right justify From Handstack
          select;
            when %len(%trim(p_rtcsfhs)) = 1;
	             rtcsfhs = ' ' + p_rtcsfhs;
            other;
	             rtcsfhs = p_rtcsfhs;
          endsl;
          // right justify To Handstack
          select;
            when %len(%trim(p_rtcsths)) = 1;
	             rtcsths = ' ' + p_rtcsths;
            other;
	             rtcsths = p_rtcsths;
          endsl;

730aA     // Ensure at least one record is found in Slot for Slot selections
730aA     count=0;
730aA     p_rtcsitem = %xlate(xlower: xupper: p_rtcsitem);
730aA     sqlstmt = 'select count(*) from slot where' +
730aA               ' slwhse=' + %char(p_rtcswhs);
730aA
730aA     // Include Item# if included
730aA     if p_rtcsitem<>*blanks;
730aA        sqlStmt = %trim(sqlStmt) + ' and slitem =' +
730aA                  sq + p_rtcsitem + sq;
730aA     endif;
730aA
730aA     // Include Department if included
730aA     if p_rtcswhdp<>*blanks;
730aA        sqlStmt = %trim(sqlStmt) + ' and slwhdp =' +
730aA                  sq + p_rtcswhdp + sq;
730aA     endif;
730aA
730aA     // Aisle Range
          // For Aisle ranges use the file field since it was populated above
          // with proper spaces instead of the p_ fields
730aA     sqlStmt = %trim(sqlStmt) + ' and slaisl>=' +
730aA               sq + rtcsfaisl + sq;
730aA     if rtcstaisl<>*blanks;
730aA        sqlStmt = %trim(sqlStmt) + ' and slaisl <=' +
730aA                  sq + rtcstaisl + sq;
730aA     endif;
730aA
730aA     // Location Range
730aA     sqlStmt = %trim(sqlStmt) + ' and slloc>=' +
730aA               %char(p_rtcsfloc);
730aA     if p_rtcstloc<>*zeros;
730aA        sqlStmt = %trim(sqlStmt) + ' and slloc<=' +
730aA                  %char(p_rtcstloc);
730aA     endif;
730aA
730aA     // Level Range
730aA     sqlStmt = %trim(sqlStmt) + ' and slrlvl>=' +
730aA               %char(p_rtcsflvl);
730aA     if p_rtcstlvl<>*zeros;
730aA        sqlStmt = %trim(sqlStmt) + ' and slrlvl<=' +
730aA                  %char(p_rtcstlvl);
730aA     endif;
730aA
730aA     // Handstack Range
730aA     sqlStmt = %trim(sqlStmt) + ' and slhand>=' +
730aA               sq + rtcsfhs + sq;
730aA     if p_rtcsths<>*blanks;
730aA        sqlStmt = %trim(sqlStmt) + ' and slhand<=' +
730aA                  sq + rtcsths + sq;
730aA     endif;
730aA
730aA     // Odd or Even locations
730aA     if p_rtcsside='O';
730aA        sqlStmt = %trim(sqlStmt) + ' and MOD(SLLOC,2)<>0';
730aA     endif;
730aA     if p_rtcsside='E';
730aA        sqlStmt = %trim(sqlStmt) + ' and MOD(SLLOC,2)=0';
730aA     endif;
730aA
730aA     // Slot Type Selection
730aA     if p_rtcsstyp='P';
730aA        sqlStmt = %trim(sqlStmt) + ' and slpick=' + sq + 'Y' + sq;
730aA     endif;
730aA     if p_rtcsstyp='O';
730aA        sqlStmt = %trim(sqlStmt) + ' and slpick=' + sq + 'N' + sq;
730aA     endif;
730aA
730aA     exec sql PREPARE sl FROM :SqlStmt;
730aA     exec sql DECLARE slfle SCROLL CURSOR FOR sl;
730aA     exec sql OPEN slfle;
730aA     exec sql fetch first from slfle into :count;
730aA
730aA     if sqlstt <> sqlsuccess or count=0;
730aA        pMessage = 'Slot selections return no data.  Please adjust';
730aA        error = *on;
730aA        leavesr;
730aA     endif;
730aA     exec sql close slfle;
730aA
730aA     // Ensure at least one record is found in PIRITEM for Item selections
730aA     count=0;
730aA     p_rtcsitem = %xlate(xlower: xupper: p_rtcsitem);
730aA     sqlstmt = 'select count(*) from piritem where' +
730aA               ' itwhse=' + %char(p_rtcswhs);
730aA
730aA     // Item#
730aA     if p_rtcsitem<>*blanks;
730aA        sqlStmt = %trim(sqlStmt) + ' and ititem=' +
730aA                  sq + %trim(p_rtcsitem) + sq;
730aA     endif;
730aA
730aA     // Section Type
730aA     if p_rtcssect<>*blanks;
730aA        sqlStmt = %trim(sqlStmt) + ' and itstyp=' +
730aA                  sq + %trim(p_rtcssect) + sq;
730aA     endif;
730aA
730aA     // Designation
730aA     if p_rtcsdesg<>*blanks;
730aA        sqlStmt = %trim(sqlStmt) + ' and itdesg=' +
730aA                  sq + %trim(p_rtcsdesg) + sq;
730aA     endif;
730aA
730aA     // Category - add sub select
730aA     if p_rtcscat<>*blanks;
730aA        sqlStmt = %trim(sqlStmt) + ' and (select count(*) from ' +
730aA                 'itemfld where ifwhse=itwhse and ifitem=ititem ' +
730aA                 'and ifcat=' + sq + %trim(p_rtcscat) + sq+ ')<>0';
730aA     endif;
730aA
730aA     // Class - add sub select
730aA     if p_rtcsclcde<>*blanks;
730aA        sqlStmt = %trim(sqlStmt) + ' and (select count(*) from ' +
730aA                 'itemcls where iclwhs=itwhse and iclitm=ititem ' +
730aA                 'and iclcde=' + sq + %trim(p_rtcsclcde) + sq+ ')<>0';
730aA     endif;
730aA
730aA     // Item Vendor
730aA     if p_rtcsivnd<>*zeros;
730aA        sqlStmt = %trim(sqlStmt) + ' and itven#=' +
730aA                  %char(p_rtcsivnd);
730aA     endif;
730aA
730aA     // Exclude Catch Weight Items
730aA     if p_rtcsecwi='Y';
730aA        sqlStmt = %trim(sqlStmt) + ' and itcwgt<>' +
730aA                  sq + 'Y' + sq;
730aA     endif;
730aA
730aA     exec sql PREPARE im FROM :SqlStmt;
730aA     exec sql DECLARE itfle SCROLL CURSOR FOR im;
730aA     exec sql OPEN itfle;
730aA     exec sql fetch first from itfle into :count;
730aA
730aA     if sqlstt <> sqlsuccess or count=0;
730aA        pMessage = 'Item selections return no data.  Please correct';
730aA        error = *on;
730aA        leavesr;
730aA     endif;
730aA     exec sql close itfle;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

         rtcswhs   = p_rtcswhs;
	        rtcsuid   = p_rtcsuid;
         rtcsseq   = p_rtcsseq;
         rtcsselun = p_rtcsselun;
         rtcsstyp  = p_rtcsstyp;
         rtcsadjc  = p_rtcsadjc;
         rtcsecwi  = p_rtcsecwi;
         rtcswhdp  = p_rtcswhdp;
         rtcssect  = p_rtcssect;

         // right justify From Aisle
         select;
           when %len(%trim(p_rtcsfaisl)) = 1;
	            rtcsfaisl = '  ' + %trim(p_rtcsfaisl);
           when %len(%trim(p_rtcsfaisl)) = 2;
	            rtcsfaisl = ' ' + %trim(p_rtcsfaisl);
           other;
	            rtcsfaisl = p_rtcsfaisl;
         endsl;
         // right justify To Aisle
         select;
           when %len(%trim(p_rtcstaisl)) = 1;
	            rtcstaisl = '  ' + %trim(p_rtcstaisl);
           when %len(%trim(p_rtcstaisl)) = 2;
	            rtcstaisl = ' ' + %trim(p_rtcstaisl);
           other;
	            rtcstaisl = p_rtcstaisl;
         endsl;

         rtcsfloc  = p_rtcsfloc;
         rtcstloc  = p_rtcstloc;
         rtcsflvl  = p_rtcsflvl;
         rtcstlvl  = p_rtcstlvl;

          // right justify From Handstack
          select;
            when %len(%trim(p_rtcsfhs)) = 1;
	             rtcsfhs = ' ' + p_rtcsfhs;
            other;
	             rtcsfhs = p_rtcsfhs;
          endsl;
          // right justify To Handstack
          select;
            when %len(%trim(p_rtcsths)) = 1;
	             rtcsths = ' ' + p_rtcsths;
            other;
	             rtcsths = p_rtcsths;
          endsl;

         rtcsside = p_rtcsside;
         rtcsdesg = p_rtcsdesg;
         rtcscat  = p_rtcscat;
         rtcsclcde= p_rtcsclcde;
         rtcsivnd = p_rtcsivnd;
         rtcsitem = p_rtcsitem;
         rtcspsts  = p_rtcspsts;
         rtcsts   = currstampsys;
         rtcsuc   = currstampuc;
         rtcscu   = pUser;
         rtcsju   = #user;
         rtcsj    = #job;
         rtcsjn   = #jobnbr;
         rtcspgm  = pPgm;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRec    Get record
     *----------------------------------------------------------------

      /free
       begsr GetRec;

         found = *off;

         // if zero passed as id then get next available
         if p_rtcsuid = 0;
            exec sql select max(rtcsuid) into :p_rtcsuid from rtcscpd;
            p_rtcsuid = p_rtcsuid + 1;
         endif;

         // if zero passed as next sequence within uid then get next seq
         if p_rtcsseq = 0;
            exec sql select max(rtcsseq) into :p_rtcsseq from rtcscpd
                     where rtcsuid=:p_rtcsuid;
            p_rtcsseq = p_rtcsseq + 1;
         endif;

         exec sql select * into :rtcsrec
                  from rtcscpd
                  where rtcsuid = :p_rtcsuid and rtcsseq=:p_rtcsseq;

         if sqlstt = sqlSuccess;
           found = *on;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  UpdRec    Update record
     *----------------------------------------------------------------

      /free
       begsr UpdRec;

         error = *off;
         exsr FillRec;

         exec sql update rtcscpd
                  set rtcswhs=:rtcswhs, rtcsuid=:rtcsuid, rtcsseq=:rtcsseq,
               rtcsselun=:rtcsselun, rtcsstyp=:rtcsstyp,
               rtcsadjc=:rtcsadjc, rtcsecwi=:rtcsecwi,
               rtcswhdp=:rtcswhdp, rtcssect=:rtcssect,
               rtcsfaisl=:rtcsfaisl, rtcstaisl=:rtcstaisl,
               rtcsfloc=:rtcsfloc, rtcstloc=:rtcstloc,
               rtcsflvl=:rtcsflvl, rtcstlvl=:rtcstlvl,
               rtcsfhs=:rtcsfhs, rtcsths=:rtcsths,
               rtcsside=:rtcsside, rtcsdesg=:rtcsdesg,
               rtcscat=:rtcscat, rtcsclcde=:rtcsclcde,
               rtcsivnd=:rtcsivnd, rtcsitem=:rtcsitem,
               rtcspsts=:rtcspsts, rtcsts=:rtcsts,
               rtcsuc=:rtcsuc, rtcsju=:rtcsju,
               rtcsj=:rtcsj, rtcsjn=:rtcsjn,
               rtcspgm=:rtcspgm
                  where rtcsuid = :rtcsuid and
                 rtcsseq = :rtcsseq;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Id(' + %char(p_RTCSUID) + ') '
                    + 'Seq(' + %char(p_RTCSSEQ) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DelRec    Delete record
     *----------------------------------------------------------------

      /free
       begsr DelRec;

         error = *off;

         exec sql delete from rtcscpd
                  where rtcsuid = :p_rtcsuid
                    and rtcsseq = :p_rtcsseq;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Id(' + %char(p_rtcsuid) + ') '
                    + 'Seq(' + %char(p_rtcsseq) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

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
     *  AssignPages  -  Assign Pages for current Realtime Count
     *----------------------------------------------------------------

      /free
       begsr AssignPages;

             sqlStmt = 'select slot2.* from workrtcs,slot2 ' +
                       'where wkswhs=slwhse and wkswhdp=slwhdp and ' +
                             'wksbase=sldisp and ' +
                             'slwhse=' + %char(p_rtcswhs) + ' and ' +
                             'wksuid=' + %char(p_rtcsuid) + ' and ' +
                             'wkspage=0';

             // determine sort based on option file selection
             select;
               when opsrt1='Y';
                 sqlStmt = %trim(sqlStmt) + ' order by slwhdp,slaisl,' +
                          'slside desc,slrlvl,slloc,slhand';
               when opsrt2='Y';
                 sqlStmt = %trim(sqlStmt) + ' order by slwhdp,slaisl,' +
                          'slside desc,slloc,slrlvl,slhand';
               when opsrt3='Y';
                 sqlStmt = %trim(sqlStmt) + ' order by slwhdp,slstyp,slaisl,' +
                          'slside desc,slloc,slrlvl,slhand';
               when opsrt4='Y';
                 sqlStmt = %trim(sqlStmt) + ' order by slwhdp,slstyp,slaisl,' +
                          'slside desc,slloc,slhand';
750 A          when opsrt5='Y';
750 A            sqlStmt = %trim(sqlStmt) + ' order by slwhdp,slaisl,' +
750 A                     'slloc,slrlvl,slhand';
               other;
750bA            sqlStmt = %trim(sqlStmt) + ' order by slwhdp,slaisl,' +
750bA                     'slloc,slrlvl,slhand';
             endsl;

730aA        exec sql PREPARE ap FROM :SqlStmt;
730aA        exec sql DECLARE asgnp SCROLL CURSOR FOR ap;
730aA        exec sql OPEN asgnp;

             // set Page Id to zero
             pageId = 0;
             cntPerPage=0;

             dow forever=forever;

                exec sql fetch next from asgnp into :slrec;
                if sqlStt <> sqlSuccess;
                   leavesr;
                endif;

                cntPerPage = cntPerPage + 1;
                // If first record or values change then start next page id
                if %trim(prv_Aisl)='' or
                   (prv_whdp<>slwhdp or prv_aisl<>slaisl or
                   prv_side<>slside or cntPerPage > opmslt) or (oppglvl='Y' and
                   prv_lvl<>slrlvl) or ((opsrt3='Y' or opsrt4='Y') and
                   prv_type<>slstyp);
                   prv_whdp=slwhdp;
                   prv_type=slstyp;
                   prv_aisl=slaisl;
                   prv_side=slside;
                   prv_lvl=slrlvl;
                   cntPerPage = 1;
                   exec sql select max(wkspage) into :pageId from workrtcs
                            where wkswhs=:p_rtcswhs and wksuid=:p_rtcsuid;
                   pageId = pageId + 1;
                endif;

                // update page id
                exec sql update workrtcs set wkspage=:pageId
                         where wkswhs=:p_rtcswhs and wksuid=:p_rtcsuid
                           and wkswhdp=:slwhdp and wksbase=:sldisp;

             enddo;
730aA        exec sql close asgnp;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  WriteSlots  Writes selected slots to WORKRTCS
     *----------------------------------------------------------------

      /free
       begsr WriteSlots;

          // Will only delete existing WORKRTCS records if M29700
          // from MRC sends Page Option of REDO.  If APPEND is sent
          // nothing is deleted and therefore any new slots will be added
          // to pages at the end of current pages
          select;
            when pPageOpt='REDO';
              // Allowed when no counts and either no printed pages
              // or the user said they would reprint and redistribute
              exec sql delete from workrtcs
                       where wkswhs=:p_rtcswhs and
                             wksuid=:p_rtcsuid and
                             wkscount<>'Y';
          endsl;

          sqlStmt = 'select * from rtcscpd ' +
                    'where rtcsuid=' + %char(p_rtcsuid) +
                    ' order by rtcsseq';

730aA     exec sql PREPARE sp FROM :SqlStmt;
730aA     exec sql DECLARE scprc SCROLL CURSOR FOR sp;
730aA     exec sql OPEN scprc;
730aA
          dow forever = forever;
730aA        exec sql fetch next from scprc
                      into :rtcsrec;
             if sqlStt <> sqlSuccess;
                leave;
             endif;


730aA        sqlstmt = 'select slwhse,slitem,sldisp,slpick,slstat,slwhdp,slstyp'
730aA                  + ' from slot as s ' +
750cD                  // 'where slwhse=' + %char(rtcswhs);
750cM                  'where slwhse=' + %char(rtcswhs) + ' and sldesg<>' +
750cA                         sq + 'BFC' + sq;

             // For additional includes do not add slots already in count
             if rtcsselun = 'S';   // only for selects, not unselects
                sqlstmt = %trim(sqlstmt) +
                          ' and not exists (select * from workrtcs as w' +
                          ' where w.wkswhs=s.slwhse and w.wksdisp=s.sldisp' +
                          '  and w.wksuid=' + %char(rtcsuid) + ')';
             endif;
730aA
730aA        // Include Item# if included
730aA        if rtcsitem<>*blanks;
730aA           sqlStmt = %trim(sqlStmt) + ' and slitem =' +
730aA                     sq + rtcsitem + sq;
730aA        endif;
730aA
730aA        // Include Department if included
730aA        if rtcswhdp<>*blanks;
730aA           sqlStmt = %trim(sqlStmt) + ' and slwhdp =' +
730aA                     sq + rtcswhdp + sq;
730aA        endif;
730aA
730aA        // Aisle Range
             // For Aisle ranges use the file field since it was populated above
             // with proper spaces instead of the p_ fields
730aA        sqlStmt = %trim(sqlStmt) + ' and slaisl>=' +
730aA                  sq + rtcsfaisl + sq;
730aA        if rtcstaisl<>*blanks;
730aA           sqlStmt = %trim(sqlStmt) + ' and slaisl <=' +
730aA                     sq + rtcstaisl + sq;
730aA        endif;
730aA
730aA        // Location Range
730aA        sqlStmt = %trim(sqlStmt) + ' and slloc>=' +
730aA                  %char(rtcsfloc);
730aA        if rtcstloc<>*zeros;
730aA           sqlStmt = %trim(sqlStmt) + ' and slloc<=' +
730aA                     %char(rtcstloc);
730aA        endif;
730aA
730aA        // Level Range
730aA        sqlStmt = %trim(sqlStmt) + ' and slrlvl>=' +
730aA                  %char(rtcsflvl);
730aA        if rtcstlvl<>*zeros;
730aA           sqlStmt = %trim(sqlStmt) + ' and slrlvl<=' +
730aA                     %char(rtcstlvl);
730aA        endif;
730aA
730aA        // Handstack Range
730aA        sqlStmt = %trim(sqlStmt) + ' and slhand>=' +
730aA                  sq + rtcsfhs + sq;
730aA        if rtcsths<>*blanks;
730aA           sqlStmt = %trim(sqlStmt) + ' and slhand<=' +
730aA                     sq + rtcsths + sq;
730aA        endif;
730aA
730aA        // Odd or Even locations
730aA        if rtcsside='O';
730aA           sqlStmt = %trim(sqlStmt) + ' and MOD(SLLOC,2)<>0';
730aA        endif;
730aA        if rtcsside='E';
730aA           sqlStmt = %trim(sqlStmt) + ' and MOD(SLLOC,2)=0';
730aA        endif;
730aA
730aA        // Slot Type Selection
730aA        if rtcsstyp='P';
730aA           sqlStmt = %trim(sqlStmt) + ' and slpick=' + sq + 'Y' + sq;
730aA        endif;
730aA        if rtcsstyp='O';
730aA           sqlStmt = %trim(sqlStmt) + ' and slpick=' + sq + 'N' + sq;
730aA        endif;

730aA        exec sql PREPARE ws FROM :SqlStmt;
730aA        exec sql DECLARE wrtsl SCROLL CURSOR FOR ws;
730aA        exec sql OPEN wrtsl;
             open workrtcs;
730aA
             // If not assigning slots to Pages then write page number as 99999
             if opAsgnp<>'Y';
                wkspage=99999;
             endif;

             dow forever = forever;
730aA           exec sql fetch next from wrtsl
                         into :wkswhs,:wksitem,:wksdisp,:wkspick,:wksstat,
                              :wkswhdp,:wksstyp;
                if sqlStt <> sqlSuccess;
                   leave;
                endif;

                wksuid=rtcsuid;
                wkscount='N';
                wksbase=wksdisp;
750 D           //exec sql select count(*) into :count
750 D           //       from vslot
750 D           //     where vsdisp=:wksdisp;
750 A           pdisp=*blanks;
750 A           // see if slot is base and not in Workrtcs
750 A           exec sql select sldisp into :pdisp
750 A                  from slot
750 A                where slwhse=:wkswhs and sldisp=:wksdisp and
750 A                      (select count(*) from vslot where vswhse=slwhse
750 A                      and vswhdp=slwhdp and vsdisp=sldisp)=0 and
750 A                      slwhdp=:wkswhdp and (select count(*) from
750 A                      workrtcs where wkswhs=:wkswhs and wkswhdp=:wkswhdp
750 A                      and wksuid=:rtcsuid and wksbase=sldisp)=0;
750 A           // SQL now returns base slot for any virtual found
750 A           // and ensures that base is not already in the count file
750 A           if sqlstt <> sqlSuccess;
750 M             exec sql select vspdis into :pdisp
750 M                    from vslot
750 M                  where vsdisp=:wksdisp and
750 M                        vswhdp=:wkswhdp and (select count(*) from
750 M                        workrtcs where wkswhs=:wkswhs and wkswhdp=:wkswhdp
750 M                        and wksuid=:rtcsuid and wksbase=vspdis)=0;
750 A           endif;
750 D           //if sqlStt <> sqlSuccess or count=0;
750 M           if sqlStt = sqlSuccess and pdisp<>*blanks;
750 A              wksdisp=pdisp;
750 A              wksbase=pdisp;
                   // only write if physical slot
                   // also confirm item logic if included
                   if rtcssect<>*blanks or rtcsdesg<>*blanks or
                      rtcscat<>*blanks  or rtcsclcde<>*blanks or
                      rtcsitem<>*blanks or rtcsivnd<>*zeros or
                      rtcsecwi='Y';
                      chain (wkswhs:wksitem) piritem;
                      if %found(piritem);
                         if rtcssect<>*blanks and itstyp<>rtcssect;
                            // if section included and not a match then skip
                            iter;
                         endif;
                      else;
                         // if item not valid and section included then skip
                         iter;
                      endif;

                      // confirm item if selected
                      if rtcsitem<>*blanks and ititem<>rtcsitem;
                         // skip since item not a match
                         iter;
                      endif;

                      // confirm Vendor if selected
                      if rtcsivnd<>*zeros and rtcsivnd<>itven#;
                        iter;
                      endif;

                      // confirm Catchweight if selected
                      if rtcsecwi='Y' and itcwgt='Y';
                         iter;
                      endif;

                      // confirm Designation if selected
                      if rtcsdesg<>*blanks and rtcsdesg<>itdesg;
                         iter;
                      endif;

                      // confirm category if selected
                      if rtcscat<>*blanks;
                         chain (wkswhs:wksitem) itemfld;
                         if %found(itemfld);
                            if rtcscat<>ifcat;
                               iter;
                            endif;
                         else;
                            iter;
                         endif;
                      endif;

                      // confirm class if selected
                      if rtcsclcde<>*blanks;
                         chain (wkswhs:wksitem:rtcsclcde) itemcls;
                         if not %found(itemcls);
                            iter;
                         endif;
                      endif;

                      // if we get here it says that item code selections
                      // were either not included, or match the selection
                      // and therefore we should write this record.
                      if rtcsselun = 'S';   // Select
                         wkspgprt=' ';
                         write wksrec;
                      else;                 // Unselect
                         exec sql delete from workrtcs
                                  where wkswhs=:wkswhs and wksitem=:wksitem
                                    and wksdisp=:wksdisp and wksuid=:rtcsuid
                                    and wkscount<>'Y';
                      endif;
                   else;
                      // since no item specific logic was selected and
                      // the slot logic found record and it is a base
                      // slot then write for count
                      if rtcsselun = 'S';   // Select
                         wkspgprt=' ';
                         write wksrec;
                      else;                 // Unselect
                         exec sql delete from workrtcs
                                  where wkswhs=:wkswhs and wksitem=:wksitem
                                    and wksdisp=:wksdisp and wksuid=:rtcsuid
                                    and wkscount<>'Y';
                      endif;
                   endif;
                endif;
             enddo;         // Loop WORKRTCS for given UID
730aA        exec sql close wrtsl;
             close workrtcs;
          enddo;        // Loop All Sequences for given UID per an add/update/delete
730aA     exec sql close scprc;

740 A     // Assign unique sequence number based on option setting
740 A     // for how the count is sorted
740 A     sqlStmt = 'select workrtcs.* from workrtcs,slot2 ' +
740 A               'where wkswhs=slwhse and wkswhdp=slwhdp and ' +
740 A                     'wksdisp=sldisp and ' +
740 A                     'slwhse=' + %char(p_rtcswhs) + ' and ' +
740 A                     'wksuid=' + %char(p_rtcsuid);

740 A     // determine sort based on option file selection
740 A     select;
740 A       when opsrt1='Y';
740 A         sqlStmt = %trim(sqlStmt) + ' order by slwhdp,slaisl,' +
740 A                  'slside desc,slrlvl,slloc,slhand';
740 A       when opsrt2='Y';
740 A         sqlStmt = %trim(sqlStmt) + ' order by slwhdp,slaisl,' +
740 A                  'slside desc,slloc,slrlvl,slhand';
740 A       when opsrt3='Y';
740 A         sqlStmt = %trim(sqlStmt) + ' order by slwhdp,slstyp,slaisl,' +
740 A                  'slside desc,slloc,slrlvl,slhand';
740 A       when opsrt4='Y';
740 A         sqlStmt = %trim(sqlStmt) + ' order by slwhdp,slstyp,slaisl,' +
740 A                  'slside desc,slloc,slhand';
750 A       when opsrt5='Y';
750 A         sqlStmt = %trim(sqlStmt) + ' order by slwhdp,slaisl,' +
750 A                  'slloc,slrlvl,slhand';
740 A       other;
740aA         sqlStmt = %trim(sqlStmt) + ' order by slwhse,slwhdp,' +
740aA                  'slaisl';
740 A     endsl;

740 A     exec sql PREPARE ss FROM :SqlStmt;
740 A     exec sql DECLARE srtsq SCROLL CURSOR FOR ss;
740 A     exec sql OPEN srtsq;
740 A
740 A     wrkseq=0;
740 A     dow forever = forever;
740 A
740 A        exec sql fetch next from srtsq
740 A               into :wksrecs;
740 A        if sqlStt <> sqlSuccess;
740 A          leave;
740 A        endif;
740 A        wrkseq = wrkseq + 1;
740aA        updSequence();
740 A
740 A     enddo;
740 A
740 A     exec sql CLOSE srtsq;

          // get total base slots to update rtchsth record
          exec sql select count(*) into :count
                       from workrtcs
                        where wkswhs=:rtcswhs and wksuid=:rtcsuid;

          // get total virtual slots to update rtchsth record
          exec sql select count(*) into :vslots
                       from vslot as v,workrtcs as w
                      where v.vswhse=w.wkswhs and
                            v.vspdis=w.wksdisp and
                            w.wksuid=:rtcsuid;

           // Update rtchsth
           exec sql update rtchsth set rtchbasslt=:count,
                                       rtchttlslt=:count+:vslots
                          where rtchwhse=:rtcswhs and rtchuid=:rtcsuid;

           // If option is set to Assign Slots to Pages then call AssignPages
760 D      //if opAsgnp = 'Y';
760 D      //   exsr AssignPages;
760 D      //endif;

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

730bAd  parmValuec     s            100

      /free

730bA  parmValuec = parmValue;
730bA  if %subst(parmValuec:1:5)='undef';
730bA     parmValue  = *blanks;
730bA  endif;

       monitor;

         select;

           when parmName = 'MODE';
             pSubCmd = %xlate(xlower: xupper: parmValue);

           when parmName = 'PAGEOPT';
             pPageOpt = %xlate(xlower: xupper: parmValue);

           when parmName = 'RTCSUID';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_rtcsuid =  %dec(parmValue: 7: 0);

           when parmName = 'RTCSWHS';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_RTCSWHS =  %dec(parmValue: 3: 0);

           when parmName = 'RTCSSEQ';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_rtcsseq =  %dec(parmValue: 5: 0);

           when parmName = 'RTCSSELUN';
             p_RTCSSELUN = %trim(parmValue);

           when parmName = 'RTCSSTYP';
             p_RTCSSTYP = %trim(parmValue);

           when parmName = 'RTCSADJC';
750dD        //p_rtcsadjc = %trim(parmValue);
750dM        p_rtcsadjc = parmValue;

           when parmName = 'RTCSECWI';
             p_rtcsecwi = %trim(parmValue);

           when parmName = 'RTCSWHDP';
             p_rtcswhdp = %trim(parmValue);

           when parmName = 'RTCSSECT';
             p_rtcssect = %trim(parmValue);

           when parmName = 'RTCSAISL1';
             p_RTCSFAISL = %trim(parmValue);

           when parmName = 'RTCSAISL2';
             p_RTCSTAISL = %trim(parmValue);
             if p_rtcsfaisl<>*blanks and p_rtcstaisl=*blanks;
                p_rtcstaisl=p_rtcsfaisl;
             endif;

           when parmName = 'RTCSFLOC';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_rtcsfloc =  %dec(parmValue: 3: 0);

           when parmName = 'RTCSTLOC';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_rtcstloc =  %dec(parmValue: 3: 0);
             if p_rtcsfloc<>*zeros and p_rtcstloc=*zeros;
                p_rtcstloc=p_rtcsfloc;
             endif;

           when parmName = 'RTCSFLVL';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_RTCSFLVL =  %dec(parmValue: 2: 0);

           when parmName = 'RTCSTLVL';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_rtcstlvl =  %dec(parmValue: 2: 0);
             if p_rtcsflvl<>*zeros and p_rtcstlvl=*zeros;
                p_rtcstlvl=p_rtcsflvl;
             endif;

           when parmName = 'RTCSFHS';
             p_RTCSFHS = %trim(parmValue);
             p_rtcsfhs= %xlate(xlower: xupper: p_rtcsfhs);

           when parmName = 'RTCSTHS';
             p_rtcsths = %trim(parmValue);
             p_rtcsths= %xlate(xlower: xupper: p_rtcsths);
             if p_rtcsfhs<>*blanks and p_rtcsths=*blanks;
                p_rtcsths=p_rtcsfhs;
             endif;

           when parmName = 'RTCSSIDE';
             p_rtcsside = %trim(parmValue);

           when parmName = 'RTCSDESG';
             p_rtcsdesg = %trim(parmValue);

           when parmName = 'RTCSITEM';
             p_rtcsitem = %trim(parmValue);
             p_rtcsitem= %xlate(xlower: xupper: p_rtcsitem);

           when parmName = 'RTCSCAT';
             p_rtcscat = %trim(parmValue);

           when parmName = 'RTCSCLCDE';
             p_rtcsclcde = %trim(parmValue);

           when parmName = 'RTCSIVND';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_rtcsivnd =  %dec(parmValue: 10: 0);

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

740aA*----------------------------------------------------------------
740aA*  updSequence   Update Count Sequence during creation
740aA*----------------------------------------------------------------

     p updSequence     b
     d updSequence     pi
      /free
             exec sql update workrtcs set wksseq = :wrkseq
                where wkswhs=:iwkswhs and wkswhdp=:iwkswhdp and
                      wksdisp=:iwksdisp and wksuid=:p_rtcsuid;
      /end-free
740aAp                 e
