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
     *  M29100    Edit/Update IFS Purge record
     *  24 April 2019
     *  Kenneth Elder
     *

     ***************************
     *****  SPECIAL NOTES
     ***************************
     **  The soft coded values that can be used in MRC program M29100
     **  are hard coded in this process since specific code will be
     **  necessary to replace the soft coded value.  The only one that
     **  started with this process was &PIRCLIENT.  This will replace
     **  &PIRCLIENT with the value from data area PIRCLIENT
     ***************************

     *----------------------------------------------------------------
     *  Revisions
     *
730 A*    04/24/19  KDE  7.30
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D ifsrec        E ds                  extname(ifspurdir) inz(*EXTDFT)


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
     d p_ifid          s              7  0
     d p_ifwhse        s              3  0
     d p_ifdirnm       s             30
     d p_ifbsedir      s            300
     d p_ifarcdir      s            300
     d p_ifexcldf      s            300
     d p_ifincldf      s            300
     d p_ifincldsd     s              1
     d p_ifarcdys      s              3  0
     d p_ifpurdys      s              3  0
710 Ad splitAry        s          10000    dim(200)
     d validChars      s            200
     d psubcmd         s              1
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

         exec sql insert into ifspurdir values(:p_ifid, :p_ifwhse, :p_ifdirnm,
                                  :p_ifbsedir, :p_ifarcdir, :p_ifexcldf,
                                  :p_ifincldf,
                                  :p_ifarcdys, :p_ifpurdys,
                                  :p_ifincldsd);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %char(ifid) + ') '
                    + 'Whse(' + %char(ifWhse) + ') '
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

          // if Exclude and Archive directories come as undefined then blank
          if %trim(p_ifexcldf)='undefined';
            p_ifexcldf = *blanks;
          endif;
          if %trim(p_ifincldf)='undefined' or %trim(p_ifincldf)='';
             pMessage = 'You must enter value for Include Files';
             error = *on;
             leavesr;
          endif;
          if %trim(p_ifarcdir)='undefined';
             p_ifarcdir = *blanks;
          endif;

          // Make sure no duplicate records
          count=0;
          exec sql select count(*) into :count
              from ifspurdir
               where ifbsedir=:p_ifbsedir and ifarcdir=:p_ifarcdir
                 and ifincldf=:p_ifincldf and ifexcldf=:p_ifexcldf
                 and ifid<>:p_ifid;
           if count > 0;
             pMessage = 'Duplicate Archive record exists';
             error = *on;
             leavesr;
           endif;

          // Make sure purge days is greater than archive days
          if p_ifarcdys > p_ifpurdys;
             pMessage = 'Archive Days must be less than Purge Days';
             error = *on;
          endif;

          // Purge days must exist.  Archive days are optional
          if p_ifpurdys=*zeros;
             pMessage = 'You must specify a number of day before Purge';
             error = *on;
          endif;

          // Ensure filenames to exclude are entered with correct syntax
          //should be entered by user with comma separator
710 A     splitARy = Split(p_ifexcldf:',');
710 A     lpos = 1;
710 A     dow splitAry(lpos) <> *blanks;
710 A        // check each filename to ensure syntax is correct
             validChars = '0123456789/?\_-.*' + %trim(xupper) + %trim(xlower);
             if %check(%trim(validChars) : %trim(splitAry(lpos))) <> 0;
               pMessage = 'Exclude filenames have invalid characters';
               error = *on;
               leavesr;
             endif;
             if %scan('..':splitAry(lpos)) > 0;
               pMessage = 'Exclude filenames cannot have consecutive ..';
               error = *on;
               leavesr;
             endif;
             if %scan('??':splitAry(lpos)) > 0;
               pMessage = 'Exclude filenames cannot have consecutive ??';
               error = *on;
               leavesr;
             endif;
             if %scan('\\':splitAry(lpos)) > 0;
               pMessage = 'Exclude filenames cannot have consecutive \\';
               error = *on;
               leavesr;
             endif;
             if %scan('//':splitAry(lpos)) > 0;
               pMessage = 'Exclude filenames cannot have consecutive //';
               error = *on;
               leavesr;
             endif;
             if %scan('**':splitAry(lpos)) > 0;
               pMessage = 'Exclude filenames cannot have consecutive **';
               error = *on;
               leavesr;
             endif;
710 A        lpos = lpos + 1;
710 A     enddo;

          // Ensure filenames to include are entered with correct syntax
          //should be entered by user with comma separator
710 A     splitARy = Split(p_ifincldf:',');
710 A     lpos = 1;
710 A     dow splitAry(lpos) <> *blanks;
710 A        // check each filename to ensure syntax is correct
             validChars = '0123456789/?\_-.*' + %trim(xupper) + %trim(xlower);
             if %check(%trim(validChars) : %trim(splitAry(lpos))) <> 0;
               pMessage = 'Include filenames have invalid characters';
               error = *on;
               leavesr;
             endif;
             if %scan('..':splitAry(lpos)) > 0;
               pMessage = 'Include filenames cannot have consecutive ..';
               error = *on;
               leavesr;
             endif;
             if %scan('??':splitAry(lpos)) > 0;
               pMessage = 'Include filenames cannot have consecutive ??';
               error = *on;
               leavesr;
             endif;
             if %scan('\\':splitAry(lpos)) > 0;
               pMessage = 'Include filenames cannot have consecutive \\';
               error = *on;
               leavesr;
             endif;
             if %scan('//':splitAry(lpos)) > 0;
               pMessage = 'Include filenames cannot have consecutive //';
               error = *on;
               leavesr;
             endif;
             if %scan('**':splitAry(lpos)) > 0;
               pMessage = 'Include filenames cannot have consecutive **';
               error = *on;
               leavesr;
             endif;
710 A        lpos = lpos + 1;
710 A     enddo;

         // Base Directory Error Checking
          // Build Array with all variable names.  They begin with & in paths
          // for Base Directory
          clear fieldNAme;
          clear fieldCnt;
          fieldCnt = 1;
          lastpos = 1;
          // Remove starting \ if exist
          if %subst(p_ifbsedir:1:1) = '/' or %subst(p_ifbsedir:1:1) = '\';
             p_ifbsedir = %subst(p_ifbsedir:2:%len(%trim(p_ifbsedir)));
          endif;

          // Build Array of all directories in Base Path and convert
          // any softcoded names beginning with &.  Will enter do loop
          // if first directory starts with softcoded path but requires
          // forward or backward slash between every other directory in path
          dou fieldCnt > 50 or (%scan('/':p_ifbsedir:lastpos) = 0 and
                                %scan('\':p_ifbsedir:lastpos) = 0);
            // set end position to end of trimmed value plus 1
            nextBegin = %len(%trim(p_ifbsedir));
            nextBegin = nextBegin + 1;

            // if either /\ slash character found then end there
            // for this particular array element
            if %scan('\':p_ifbsedir:lastpos+1) > 0 and
               %scan('\':p_ifbsedir:lastpos+1) < nextBegin;
               nextBegin = %scan('\':p_ifbsedir:lastpos+1);
            endif;
            if %scan('/':p_ifbsedir:lastpos+1) > 0 and
               %scan('/':p_ifbsedir:lastpos+1) < nextBegin;
               nextBegin = %scan('/':p_ifbsedir:lastpos+1);
            endif;

            // save the directories one at a name in fieldName array
            // and the length for the directory name in fieldLength
            fieldName(fieldCnt) = %subst(p_ifbsedir:lastpos:
                                  nextBegin-lastpos);

            // if directory specified is softcoded values validate and convert
            if %scan('&':fieldName(fieldCnt)) <> 0;
               fieldName(fieldCnt) = %trim(getFieldValue(fieldName(fieldCnt)));
            endif;
            if %scan('*INVALIDFIELD':fieldName(fieldCnt)) <> 0;
              pMessage = 'Softcoded directory ' + %subst(p_ifbsedir:lastpos:
                                                  nextBegin-lastpos) +
                         ' is undefined (reference pgm M29100)';
              error=*on;
              leavesr;
            else;
              fieldLength(fieldCnt) = %len(%trim(fieldName(fieldCnt)));
              fieldCnt = fieldCnt + 1;
              lastpos = nextBegin;
            endif;
          enddo;

          // Rebuild original direcotry path now that soft coding has taken plac
          fieldCnt=1;
          p_ifbsedir=*blanks;
          dow fieldName(fieldCnt) <> *blanks and fieldCnt<51;
             p_ifbsedir = %trim(p_ifbsedir) + %trim(fieldName(fieldCnt));
             fieldCnt = fieldCnt + 1;
          enddo;

          // Ensure Base Directory exist
          if %subst(p_ifbsedir:1:1) <> '/' and %subst(p_ifbsedir:1:1) <> '\';
             p_ifbsedir = '/' + %trim(p_ifbsedir);
          endif;
          nextBegin = %len(%trim(p_ifbsedir));
          if %scan('/':p_ifbsedir:1) <> 0;
             nextBegin = %scan('/':p_ifbsedir:1) -1;
          endif;
          if %scan('/':p_ifbsedir:1) <> 0;
             nextBegin = %scan('/':p_ifbsedir:1) -1;
          endif;

          // Confirm that path exist on IFS
          cmdString = 'CHKIFSOBJ OBJ(' + sq + %trim(p_ifbsedir) + sq + ')';
          returnCode = GoCmd(%trim(cmdString));
          Select;
            When ReturnCode = Success;     // Command succeeded
            When Errmsgid = ObjectNotFound;  // Cmd Object not found
              pMessage = 'Base Directory cannot be found on IFS';
              error=*on;
              leavesr;
            when ErrMsgid = noSuchPath;      // No Such Path found on IFS
              pMessage = 'Base Directory cannot be found on IFS';
              error=*on;
              leavesr;
          endsl;

        // Archive Directory Error Checking
         if %trim(p_ifarcdir)<>'';
          // Ensure Archive Directory exist
          if %subst(p_ifarcdir:1:1) <> '/' and %subst(p_ifarcdir:1:1) <> '\'
              and %trim(p_ifarcdir) <> '';
             p_ifarcdir = '/' + %trim(p_ifarcdir);
          endif;

          // Build Array with all variable names.  They begin with & in paths
          // for Archive Directory
          clear fieldNAme;
          clear fieldCnt;
          fieldCnt = 1;
          lastpos = 1;
          // Remove starting \ if exist
          if %subst(p_ifarcdir:1:1) = '/' or %subst(p_ifarcdir:1:1) = '\';
             p_ifarcdir = %subst(p_ifarcdir:2:%len(%trim(p_ifarcdir)));
          endif;

          // Build Array of all directories in Base Path and convert
          // any softcoded names beginning with &.  Will enter do loop
          // if first directory starts with softcoded path but requires
          // forward or backward slash between every other directory in path
          dou fieldCnt > 50 or (%scan('/':p_ifarcdir:lastpos) = 0 and
                                %scan('\':p_ifarcdir:lastpos) = 0);
            // set end position to end of trimmed value plus 1
            nextBegin = %len(%trim(p_ifarcdir));
            nextBegin = nextBegin + 1;

            // if either /\ slash character found then end there
            // for this particular array element
            if %scan('\':p_ifarcdir:lastpos+1) > 0 and
               %scan('\':p_ifarcdir:lastpos+1) < nextBegin;
               nextBegin = %scan('\':p_ifarcdir:lastpos+1);
            endif;
            if %scan('/':p_ifarcdir:lastpos+1) > 0 and
               %scan('/':p_ifarcdir:lastpos+1) < nextBegin;
               nextBegin = %scan('/':p_ifarcdir:lastpos+1);
            endif;

            // save the directories one at a name in fieldName array
            // and the length for the directory name in fieldLength
            fieldName(fieldCnt) = %subst(p_ifarcdir:lastpos:
                                  nextBegin-lastpos);

            // if directory specified is softcoded values validate and convert
            if %scan('&':fieldName(fieldCnt)) <> 0;
               fieldName(fieldCnt) = %trim(getFieldValue(fieldName(fieldCnt)));
            endif;
            if %scan('*INVALIDFIELD':fieldName(fieldCnt)) <> 0;
              pMessage = 'Softcoded directory ' + %subst(p_ifarcdir:lastpos:
                                                  nextBegin-lastpos) +
                         ' is undefined (reference pgm M29100)';
              error=*on;
              leavesr;
            else;
              fieldLength(fieldCnt) = %len(%trim(fieldName(fieldCnt)));
              fieldCnt = fieldCnt + 1;
              lastpos = nextBegin;
            endif;
          enddo;

          // Rebuild original direcotry path now that soft coding has taken plac
          fieldCnt=1;
          p_ifarcdir=*blanks;
          dow fieldName(fieldCnt) <> *blanks and fieldCnt<51;
             p_ifarcdir = %trim(p_ifarcdir) + %trim(fieldName(fieldCnt));
             fieldCnt = fieldCnt + 1;
          enddo;

          // Ensure Base Directory exist
          if %subst(p_ifarcdir:1:1) <> '/' and %subst(p_ifarcdir:1:1) <> '\';
             p_ifarcdir = '/' + %trim(p_ifarcdir);
          endif;
          nextBegin = %len(%trim(p_ifarcdir));
          if %scan('/':p_ifarcdir:1) <> 0;
             nextBegin = %scan('/':p_ifarcdir:1) -1;
          endif;
          if %scan('/':p_ifarcdir:1) <> 0;
             nextBegin = %scan('/':p_ifarcdir:1) -1;
          endif;
          // This command will ensure path and sub directories exist
          cmdString = 'QSH CMD(' + sq + 'test -d ' +
                       %trim(p_ifarcdir) +
                      ' || mkdir -p ' +
                      %trim(p_ifarcdir) +
                      sq + ')';
          returnCode = GoCmd(%trim(cmdString));
          if ReturnCode <> Success;
             pMessage = 'Failed to generate requested IFS path for Archive Dir';
             error=*on;
             leavesr;
          endif;

          // Confirm that path exist on IFS
          cmdString = 'CHKIFSOBJ OBJ(' + sq + %trim(p_ifarcdir) + sq + ')';
          returnCode = GoCmd(%trim(cmdString));
          Select;
            When ReturnCode = Success;     // Command succeeded
            When Errmsgid = ObjectNotFound;  // Cmd Object not found
              pMessage = 'Archive Directory cannot be found on IFS';
              error=*on;
              leavesr;
            when ErrMsgid = noSuchPath;      // No Such Path found on IFS
              pMessage = 'Archive Directory cannot be found on IFS';
              error=*on;
              leavesr;
          endsl;

          // Ensure Archive Directory exist
          if %subst(p_ifarcdir:1:1) <> '/' and %subst(p_ifarcdir:1:1) <> '\'
              and %trim(p_ifarcdir) <> '';
             p_ifarcdir = '/' + %trim(p_ifarcdir);
          endif;
         endif;  // Archive Directory is blank
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

         ifid = p_ifid;
         ifwhse = p_ifwhse;
	        ifdirnm = p_ifdirnm;
	        ifbsedir = p_ifbsedir;
	        ifarcdir = p_ifarcdir;
	        ifexcldf = p_ifexcldf;
	        ifincldf = p_ifincldf;
	        ifincldsd = p_ifincldsd;
	        ifarcdys = p_ifarcdys;
	        ifpurdys = p_ifpurdys;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRec    Get record
     *----------------------------------------------------------------

      /free
       begsr GetRec;

         found = *off;

         // if Exclude and Archive directories come as undefined then blank
         if %trim(p_ifexcldf)='undefined';
           p_ifexcldf = *blanks;
         endif;
         if %trim(p_ifincldf)='undefined';
           p_ifincldf = *blanks;
         endif;
         if %trim(p_ifarcdir)='undefined';
            p_ifarcdir = *blanks;
         endif;

         exec sql select * into :ifsrec
                  from ifspurdir
                  where ifid = :p_ifid;

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

         exec sql update ifspurdir
                  set ifwhse = :p_ifwhse, ifdirnm = :p_ifdirnm,
                      ifbsedir = :p_ifbsedir, ifarcdir = :p_ifarcdir,
                      ifexcldf = :p_ifexcldf, ifarcdys = :p_ifarcdys,
                      ifincldf = :p_ifincldf, ifid = :p_ifid,
                      ifincldsd = :p_ifincldsd,
                      ifpurdys = :p_ifpurdys
                  where ifid = :p_ifid;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Id(' + %char(ifid) + ') '
                    + 'Whse(' + %char(ifWhse) + ') '
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

         exec sql delete from ifspurdir
                  where ifid = :p_ifid;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Bsedir(' + %char(ifid) + ') '
                    + 'Whse(' + %char(ifWhse) + ') '
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

      /free

       monitor;

         select;

           when parmName = 'MODE';
             pSubCmd = %xlate(xlower: xupper: parmValue);

           when parmName = 'IFWHSE';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_ifwhse =  %dec(parmValue: 3: 0);

           when parmName = 'IFID';
             if parmValue = '';
               parmValue = '0';
             endif;
             if pSubCmd = 'A';
                exec sql select max(ifid) into :p_ifid from ifspurdir;
                p_ifid =  p_ifid + 1;
             else;
                p_ifid =  %dec(parmValue: 7: 0);
             endif;

           when parmName = 'IFDIRNM';
             p_ifdirnm = %trim(parmValue);

           when parmName = 'IFBSEDIR';
             p_ifbsedir = %trim(parmValue);

           when parmName = 'IFARCDIR';
             p_ifarcdir = %trim(parmValue);

           when parmName = 'IFEXCLDF';
             p_ifexcldf = %trim(parmValue);

           when parmName = 'IFINCLDF';
             p_ifincldf = %trim(parmValue);

           when parmName = 'IFINCLDSD';
             p_ifincldsd = %trim(parmValue);
             if p_ifincldsd <> 'Y';
                p_ifincldsd = 'N';
             endif;

           when parmName = 'IFARCDYS';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_ifarcdys =  %dec(parmValue: 3: 0);

           when parmName = 'IFPURDYS';
             p_ifpurdys =  %dec(parmValue: 3: 0);

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
