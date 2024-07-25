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
     *  M29300    Pick Order Maintenance
     *  06 May 2019
     *  Kenneth Elder
     *

     *----------------------------------------------------------------
     *  Revisions
     *
730 A*    05/06/19  KDE  7.30
     *      - Created
730aA*    06/05/19  KDE  7.30a
     *      - Add the multitude of options and edit check to ensure
     *        selection actually returns at least one record
730bA*    07/22/19  KDE  7.30b
     *      - Ensure nothing is updated with undefin coming from MRC
730cA*    10/25/19  KDE  7.30c
     *      - Remove Aisle overlapping message for the time.  Need to give
     *        more thought.  It gives this error when you use same Aisle
     *        with unique Locations
740aA*    03/04/20  KDE  7.40a
     *      - Fix: change hand compare to use *blanks
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D dfrec         E ds                  extname(dfpickdtl) inz(*EXTDFT)


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
     d p_dfdid         s              7  0
     d p_dfdwhse       s              3  0
     d p_dfdcode       s             10
     d p_dfddesc       s             50
     d p_dfdlvl2       s              2  0
     d p_dfdcmpprty    s              3  0
     d p_dfdwhdp       s              5
     d p_dfdstyp       s              1
     d p_dfdaisl1      s              3
     d p_dfdaisl2      s              3
     d p_dfdloc1       s              3  0
     d p_dfdloc2       s              3  0
     d p_dfdrlvl1      s              2  0
     d p_dfdrlvl2      s              2  0
     d p_dfdhnd1       s              2
     d p_dfdhnd2       s              2
     d p_dfdutyp       s              1
     d p_dfdside       s              1
     d p_dfditem1      s             15
     d p_dfditem2      s             15
     d p_dfddesg       s              5
     d p_dfdcat        s             10
     d p_dfdclcde      s             10
     d p_dfdactv       s              2
     d p_dfdbld        s              2
     d p_dfdszon       s              6
     d p_dfduwgt1      s              7  2
     d p_dfduwgt2      s              7  2
     d p_dfdswgt1      s              9  2
     d p_dfdswgt2      s              9  2
     d p_dfdltype      s              1
710 Ad splitAry        s          10000    dim(200)
     d validChars      s            200
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

710 A***    Used to Split delimited values into an Array   ***
710 Ad Split           pr            50    dim(50)
710 AD  strToSplit                 1000    const
710 AD  delimiter                     3    const

710 A***    Return Field Value for Softcoded variables in path for IFS
710 Ad getFieldValue   pr            50
710 AD  valueSent                    50    const

710 A***    Used to Determine all variable name path descriptors
     d                 ds
     d fieldAry                            dim(50)
     d   fieldName                   50    overlay(fieldAry)
     d   fieldLength                  3  0 overlay(fieldAry:*next)

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

        if %trim(pMessage) = '';
           exsr Afteract;
        endif;

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

         exec sql insert into dfpickdtl values(:dfrec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Id(' + %char(p_dfdid) + ') '
                    + 'Whse(' + %char(dfdWhse) + ') '
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
             else;
               exsr AddRec;
             endif;
           when pSubCmd = 'U' or pSubCmd = 'C';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;
           when pSubCmd = 'D';
             if found;
               exsr DelRec;
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

          // Make sure Pick Order is passed and numeric
          monitor;
            dfdlvl2 = p_dfdlvl2;
          on-error;
             pMessage = 'Pick Order must be numeric and must be entered';
             error = *on;
             leavesr;
          endmon;

          // Ensure that at mininum Warehouse Department is specified
          //if p_dfdWhdp = *blanks;
          //   pMessage = 'Warehouse Department must be selected';
          //   error = *on;
          //   leavesr;
          //endif;
730aA
730aA     // Ensure To Item Weight is greater than from Item Weight
730aA     if dfduwgt1>dfduwgt2 and dfduwgt2<>0;
730aA        pMessage = 'From Item Weight must be less than To Item Weight';
730aA        error = *on;
730aA        leavesr;
730aA     endif;
730aA
730aA     // Ensure To Label Weight is greater than from Label Weight
730aA     if dfdswgt1>dfdswgt2 and dfdswgt2<>0;
730aA        pMessage = 'From Label Weight must be less than To Label Weight';
730aA        error = *on;
730aA        leavesr;
730aA     endif;
730aA
730aA     // Ensure To Location is greater than From Location
730aA     if dfdloc1>dfdloc2 and dfdloc2<>0;
730aA        pMessage = 'From Location must be less than To Location';
730aA        error = *on;
730aA        leavesr;
730aA     endif;
730aA
730aA     // Ensure To Level is greater than From Level
730aA     if dfdrlvl1>dfdrlvl2 and dfdrlvl2<>0;
730aA        pMessage = 'From Level must be less than To Level';
730aA        error = *on;
730aA        leavesr;
730aA     endif;
730aA
730aA     // Ensure To Handstack is greater than From Handstack
730aA     if dfdhnd1>dfdhnd2 and dfdhnd2<>*blanks;
730aA        pMessage = 'From Handstack must be less than To Handstack';
730aA        error = *on;
730aA        leavesr;
730aA     endif;
730aA
730aA     // Ensure To Item is greater than From Item
730aA     if dfditem1>dfditem2 and dfditem2<>*blanks;
730aA        pMessage = 'From Item must be less than To Item';
730aA        error = *on;
730aA        leavesr;
730aA     endif;

          // Ensure To Aisle is greater than From Aisle
          // This condition needs to be met to properly enforce
          // possible Aisle overlaps in next check
          if dfdaisl1>dfdaisl2;
             pMessage = 'From Aisle must be less than To Aisle';
             error = *on;
             leavesr;
          endif;

          // Ensure Aisle ranges do not overlap
          // right justify From Aisle
          select;
            when %len(%trim(p_dfdaisl1)) = 1;
	             dfdaisl1 = '  ' + %trim(p_dfdaisl1);
            when %len(%trim(p_dfdaisl1)) = 2;
	             dfdaisl1 = ' ' + %trim(p_dfdaisl1);
            other;
	             dfdaisl1 = p_dfdaisl1;
          endsl;
          // right justify To Aisle
          select;
            when %len(%trim(p_dfdaisl2)) = 1;
	             dfdaisl2 = '  ' + %trim(p_dfdaisl2);
            when %len(%trim(p_dfdaisl2)) = 2;
	             dfdaisl2 = ' ' + %trim(p_dfdaisl2);
            other;
	             dfdaisl2 = p_dfdaisl2;
          endsl;
          count=*zeros;
          if dfdaisl1<>*blanks or dfdaisl2<>*blanks;
            exec sql  select count(*) into :count
                         from dfpickdtl as a where
                       :p_dfdid <> a.dfdid and
                     :p_dfdwhdp=a.dfdwhdp and (a.dfdaisl1<>'' or a.dfdaisl2<>''
                       ) and (((:dfdaisl1 >= a.dfdaisl1
                   and :dfdaisl1 <= a.dfdaisl2) or
                    (:dfdaisl2 >= a.dfdaisl1
                             and :dfdaisl2 <= a.dfdaisl2)) or
                       (:dfdaisl1 <= a.dfdaisl1
                   and :dfdaisl1 <= a.dfdaisl2 and
                    :dfdaisl2 >= a.dfdaisl1
                             and :dfdaisl2 >= a.dfdaisl2) or
                  (:dfdaisl1=a.dfdaisl1 and a.dfdaisl2=' '));
            if count > 0;
730cD          //pMessage = 'Aisle range overlaps with another definition';
730cD          //error = *on;
730cD          //leavesr;
            endif;
          endif;

730aA     // Ensure at least one record is found in Slot for Slot selections
730aA     count=0;
730aA     p_dfditem1 = %xlate(xlower: xupper: p_dfditem1);
730aA     p_dfditem2 = %xlate(xlower: xupper: p_dfditem2);
730aA     sqlstmt = 'select count(*) from slot where' +
730aA               ' slwhse=' + %char(p_dfdwhse) + ' and slitem >=' +
730aA               sq + %trim(p_dfditem1) + sq;
730aA     if p_dfditem2 <> *blanks;
730aA        sqlStmt = %trim(sqlStmt) + ' and slitem <=' +
730aA                  sq + %trim(p_dfditem2) + sq;
730aA     endif;
730aA
730aA     // Include Department if included
730aA     if p_dfdwhdp<>*blanks;
730aA        sqlStmt = %trim(sqlStmt) + ' and slwhdp =' +
730aA                  sq + p_dfdwhdp + sq;
730aA     endif;
730aA
730aA     // Aisle Range
          // For Aisle ranges use the file field since it was populated above
          // with proper spaces instead of the p_ fields
730aA     sqlStmt = %trim(sqlStmt) + ' and slaisl>=' +
730aA               sq + dfdaisl1 + sq;
730aA     if dfdAisl2<>*blanks;
730aA        sqlStmt = %trim(sqlStmt) + ' and slaisl <=' +
730aA                  sq + dfdAisl2 + sq;
730aA     endif;
730aA
730aA     // Location Range
730aA     sqlStmt = %trim(sqlStmt) + ' and slloc>=' +
730aA               %char(p_dfdloc1);
730aA     if p_dfdLoc2<>*zeros;
730aA        sqlStmt = %trim(sqlStmt) + ' and slloc<=' +
730aA                  %char(p_dfdLoc2);
730aA     endif;
730aA
730aA     // Level Range
730aA     sqlStmt = %trim(sqlStmt) + ' and slrlvl>=' +
730aA               %char(p_dfdrlvl1);
730aA     if p_dfdrLvl2<>*zeros;
730aA        sqlStmt = %trim(sqlStmt) + ' and slrlvl<=' +
730aA                  %char(p_dfdrlvl2);
730aA     endif;
730aA
730aA     // Handstack Range
730aA     sqlStmt = %trim(sqlStmt) + ' and slhand>=' +
730aA               sq + %trim(p_dfdhnd1) + sq;
740aD     //if p_dfdhnd2<>*zeros;
740aA     if p_dfdhnd2<>*blanks;
730aA        sqlStmt = %trim(sqlStmt) + ' and slhand<=' +
730aA                  sq + %trim(p_dfdhnd2) + sq;
730aA     endif;
730aA
730aA     // Odd or Even locations
730aA     if p_dfdside='O';
730aA        sqlStmt = %trim(sqlStmt) + ' and MOD(SLLOC,2)<>0';
730aA     endif;
730aA     if p_dfdside='E';
730aA        sqlStmt = %trim(sqlStmt) + ' and MOD(SLLOC,2)=0';
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
730aA     p_dfditem1 = %xlate(xlower: xupper: p_dfditem1);
730aA     p_dfditem2 = %xlate(xlower: xupper: p_dfditem2);
730aA     sqlstmt = 'select count(*) from piritem where' +
730aA               ' itwhse=' + %char(p_dfdwhse) + ' and ititem >=' +
730aA               sq + %trim(p_dfditem1) + sq;
730aA     if p_dfditem2 <> *blanks;
730aA        sqlStmt = %trim(sqlStmt) + ' and ititem <=' +
730aA                  sq + %trim(p_dfditem2) + sq;
730aA     endif;
730aA
730aA     // Section Type
730aA     if p_dfdstyp<>*blanks;
730aA        sqlStmt = %trim(sqlStmt) + ' and itstyp=' +
730aA                  sq + %trim(p_dfdstyp) + sq;
730aA     endif;
730aA
730aA     // Unit of Measure Type
730aA     if p_dfdutyp='1';
730aA        sqlStmt = %trim(sqlStmt) + ' and itumq2>0';
730aA     endif;
730aA     if p_dfdutyp='2';
730aA        sqlStmt = %trim(sqlStmt) + ' and itumq3>0';
730aA     endif;
730aA
730aA     // Designation
730aA     if p_dfddesg<>*blanks;
730aA        sqlStmt = %trim(sqlStmt) + ' and itdesg=' +
730aA                  sq + %trim(p_dfddesg) + sq;
730aA     endif;
730aA
730aA     // Category - add sub select
730aA     if p_dfdcat<>*blanks;
730aA        sqlStmt = %trim(sqlStmt) + ' and (select count(*) from ' +
730aA                 'itemfld where ifwhse=itwhse and ifitem=ititem ' +
730aA                 'and ifcat=' + sq + %trim(p_dfdcat) + sq+ ')<>0';
730aA     endif;
730aA
730aA     // Activity
730aA     if p_dfdactv<>*blanks;
730aA        sqlStmt = %trim(sqlStmt) + ' and itactv=' +
730aA                  sq + %trim(p_dfdactv) + sq;
730aA     endif;
730aA
730aA     // Build Code
730aA     if p_dfdbld<>*blanks;
730aA        sqlStmt = %trim(sqlStmt) + ' and itbld=' +
730aA                   sq + %trim(p_dfdbld) + sq;
730aA     endif;
730aA
730aA     // Class - add sub select
730aA     if p_dfdclcde<>*blanks;
730aA        sqlStmt = %trim(sqlStmt) + ' and (select count(*) from ' +
730aA                 'itemcls where iclwhs=itwhse and iclitm=ititem ' +
730aA                 'and iclcde=' + sq + %trim(p_dfdclcde) + sq+ ')<>0';
730aA     endif;
730aA
730aA     // Item Weight Range
730aA     sqlStmt = %trim(sqlStmt) + ' and itswgt>=' +
730aA               %char(p_dfduwgt1);
730aA     if p_dfduwgt2<>*zeros;
730aA        sqlStmt = %trim(sqlStmt) + ' and itswgt<=' +
730aA                  %char(p_dfduwgt2);
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

         dfdwhse  = p_dfdwhse;
	        dfdid    = p_dfdid;
	        dfdcode  = p_dfdcode;
	        dfddesc  = p_dfddesc;
	        dfdlvl2  = p_dfdlvl2;
	        dfdcmpprty=  p_dfdcmpprty;
	        dfdwhdp  = p_dfdwhdp;
	        dfdstyp  = p_dfdstyp;
         // right justify From Aisle
         select;
           when %len(%trim(p_dfdaisl1)) = 1;
	            dfdaisl1 = '  ' + %trim(p_dfdaisl1);
           when %len(%trim(p_dfdaisl1)) = 2;
	            dfdaisl1 = ' ' + %trim(p_dfdaisl1);
           other;
	            dfdaisl1 = p_dfdaisl1;
         endsl;
         // right justify To Aisle
         select;
           when %len(%trim(p_dfdaisl2)) = 1;
	            dfdaisl2 = '  ' + %trim(p_dfdaisl2);
           when %len(%trim(p_dfdaisl2)) = 2;
	            dfdaisl2 = ' ' + %trim(p_dfdaisl2);
           other;
	            dfdaisl2 = p_dfdaisl2;
         endsl;
         dfdloc1  = p_dfdloc1;
         dfdloc2  = p_dfdloc2;
         dfdrlvl1 = p_dfdrlvl1;
         dfdrlvl2 = p_dfdrlvl2;
         dfdhnd1  = p_dfdhnd1;
         dfdhnd2  = p_dfdhnd2;
         dfdutyp  = p_dfdutyp;
         dfdside  = p_dfdside;
         dfditem1 = p_dfditem1;
         dfditem2 = p_dfditem2;
         dfddesg  = p_dfddesg;
         dfdcat   = p_dfdcat;
         dfdclcde = p_dfdclcde;
         dfdactv  = p_dfdactv;
         dfdbld   = p_dfdbld;
         dfdszon  = p_dfdszon;
         dfduwgt1 = p_dfduwgt1;
         dfduwgt2 = p_dfduwgt2;
         dfdswgt1 = p_dfdswgt1;
         dfdswgt2 = p_dfdswgt2;
         dfdltype = p_dfdltype;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRec    Get record
     *----------------------------------------------------------------

      /free
       begsr GetRec;

         found = *off;

         // if zero passed as id then get next available
         if p_dfdid = 0;
            exec sql select max(dfdid) into :p_dfdid from dfpickdtl;
            p_dfdid = p_dfdid + 1;
         endif;

         exec sql select * into :dfrec
                  from dfpickdtl
                  where dfdid = :p_dfdid;

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

         exec sql update dfpickdtl
                  set dfdwhse=:dfdwhse, dfdcode=:dfdcode, dfddesc=:dfddesc,
                      dfdlvl2=:dfdlvl2, dfdcmpprty=:dfdcmpprty,
                      dfdwhdp=:dfdwhdp, dfdstyp=:dfdstyp, dfdaisl1=:dfdaisl1,
                      dfdaisl2=:dfdaisl2, dfdloc1=:dfdloc1, dfdloc2=:dfdloc2,
                      dfdrlvl1=:dfdrlvl1, dfdrlvl2=:dfdrlvl2, dfdhnd1=:dfdhnd1,
                      dfdhnd2=:dfdhnd2, dfdutyp=:dfdutyp, dfdside=:dfdside,
                      dfditem1=:dfditem1, dfditem2=:dfditem2, dfddesg=:dfddesg,
                      dfdcat=:dfdcat, dfdclcde=:dfdclcde, dfdactv=:dfdactv,
                      dfdbld=:dfdbld, dfdszon=:dfdszon, dfduwgt1=:dfduwgt1,
                      dfdswgt1=:dfdswgt1, dfdltype=:dfdltype,
                      dfdswgt2=:dfdswgt2, dfduwgt2=:dfduwgt2
                  where dfdid = :p_dfdid;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Id(' + %char(p_dfdId) + ') '
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

         exec sql delete from dfpickdtl
                  where dfdid = :p_dfdid;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Id(' + %char(p_dfdid) + ') '
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

           when parmName = 'DFDID';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_dfdid =  %dec(parmValue: 7: 0);

           when parmName = 'DFDWHSE';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_dfdwhse =  %dec(parmValue: 3: 0);

           when parmName = 'DFDCODE';
             if parmValue = '';
               parmValue = '*DEFAULT';
             endif;
             p_dfdcode =  parmValue;

           when parmName = 'DFDDESC';
             p_dfddesc = %trim(parmValue);

           when parmName = 'DFDLVL2';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_dfdlvl2 =  %dec(parmValue: 2: 0);

           when parmName = 'DFDCMPPRTY';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_dfdcmpprty =  %dec(parmValue: 3: 0);

           when parmName = 'DFDWHDP';
             p_dfdwhdp = %trim(parmValue);

           when parmName = 'DFDSTYP';
             p_dfdstyp = %trim(parmValue);

           when parmName = 'DFDAISL1';
             p_dfdaisl1 = %trim(parmValue);

           when parmName = 'DFDAISL2';
             p_dfdaisl2 = %trim(parmValue);

           when parmName = 'DFDLOC1';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_dfdloc1 =  %dec(parmValue: 3: 0);

           when parmName = 'DFDLOC2';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_dfdloc2 =  %dec(parmValue: 3: 0);

           when parmName = 'DFDRLVL1';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_dfdrlvl1 =  %dec(parmValue: 2: 0);

           when parmName = 'DFDRLVL2';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_dfdrlvl2 =  %dec(parmValue: 2: 0);

           when parmName = 'DFDLOC1';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_dfdloc1 =  %dec(parmValue: 3: 0);

           when parmName = 'DFDLOC2';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_dfdloc2 =  %dec(parmValue: 3: 0);

           when parmName = 'DFDHND1';
             p_dfdhnd1 = %trim(parmValue);

           when parmName = 'DFDHND2';
             p_dfdhnd2 = %trim(parmValue);

           when parmName = 'DFDUTYP';
             p_dfdutyp = %trim(parmValue);

           when parmName = 'DFDSIDE';
             p_dfdside = %trim(parmValue);

           when parmName = 'DFDITEM1';
             p_dfditem1 = %trim(parmValue);

           when parmName = 'DFDITEM2';
             p_dfditem2 = %trim(parmValue);

           when parmName = 'DFDDESG';
             p_dfddesg = %trim(parmValue);

           when parmName = 'DFDCAT';
             p_dfdcat = %trim(parmValue);

           when parmName = 'DFDCLCDE';
             p_dfdclcde = %trim(parmValue);

           when parmName = 'DFDACTV';
             p_dfdactv = %trim(parmValue);

           when parmName = 'DFDBLD';
             p_dfdbld = %trim(parmValue);

           when parmName = 'DFDSZON';
             p_dfdszon = %trim(parmValue);

           when parmName = 'DFDUWGT1';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_dfduwgt1 =  %dec(parmValue: 7: 2);

           when parmName = 'DFDUWGT2';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_dfduwgt2 =  %dec(parmValue: 7: 2);

           when parmName = 'DFDSWGT1';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_dfdswgt1 =  %dec(parmValue: 9: 2);

           when parmName = 'DFDSWGT2';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_dfdswgt2 =  %dec(parmValue: 9: 2);

           when parmName = 'DFDLTYPE';
             p_dfdltype = %trim(parmValue);

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
     *  getFieldValue    Returns either soft coded value or invalid field error
     *----------------------------------------------------------------

     p getFieldValue   b
     d getFieldValue   pi            50
     d  incomingField                50    const

     * Local Variables

     D returnField     s             50
     d replaceSlash    s               n

      /free

          // Currently we only check for softcode field &pirclient
          // If we add more soft coded fields build on the when clause
          returnField = %xlate(xlower:xupper:incomingField);

          // if first byte has slash then remove for softcode replacement
          // and put back at end before return
          if %subst(returnField:1:1)='/' or %subst(returnField:1:1)='\';
             replaceSlash = *on;
             returnField = %subst(returnField:2:%len(%trim(returnField))-1);
          else;
             replaceSlash = *off;
          endif;

          select;
            when %trim(returnField) = '&PIRCLIENT';
              returnField = %trim(pirclient);
            other;
              returnField = '*INVALIDFIELD';
          endsl;

          // if value started with slash replace before returning with soft code
          if replaceSlash;
             returnField = '/' + %trim(returnField);
          endif;

       return returnField;

      /end-free

     p                 e
710 A *
710 A *  Procedure Split..............
710 A *
710 A *  Split Procedure that work like SPLIT in javascript.  It expects an inpu
710 A *  string up to 1000 characters long, a delimiter 3 character long, and pa
710 A *  back an array with 50 elements 50 character each.  The delmiter could
710 A *  be increased if need be and the code (%len) takes care of it.  You coul
710 A *  also change the array size and element count.  If you do you should cha
710 A *  split and returnarray here and you procedure definition in main program
710 A *  as well as the array defined in the main program that receives the retu
710 A *  from this procedure.  When you return simply loop through array looking
710 A *  non blanks and do what you need to given your data.
710 A *
710 AP split           b
710 AD split           pi            50    dim(50)
710 AD  data                       1000    const
710 AD  delimiter                     3    const
710 A
710 AD returnArray     s             50    dim(50)
710 A
710 AD startPos        s             10i 0
710 AD foundPos        s             10i 0
710 AD increment       s             10i 0
710 AD index           s              5i 0 inz(1)
710 A /free
710 A  if data <> *blanks;
710 A     increment = %len(%trim(delimiter));
710 A     startPos = 1;
710 A     dou foundPos = %len(data) + 1;
710 A        foundPos = %scan(%trim(delimiter):data:startPos);
710 A        if foundPos = 0;
710 A           foundPos = %len(data) + 1;
710 A        endif;
710 A        returnArray(index) = %subst(data:startPos:foundPos - startPos);
710 A        index += 1;
710 A        startPos = foundPos + increment;
710 A     enddo;
710 A  endif;
710 A
710 A  return returnArray;
710 A /end-free
710 AP split           e
