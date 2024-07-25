      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GETRECID   Get next record id
     *  09 July 2008
     *  Dave Sommerville
     *
600 A*    07/09/08  DAS  6.00  P#00045
     *      - Created
     *
650aA*    06/07/13  DAS  6.50
     *      - Revised to turn on *INLR for certain files
     *
730aA*   12/05/19  DAS  7.30a
     *     - Was 6.40a 9/12/12 change done by Rod but not implemented.
     *     - Changed to print lock info if record is locked, and
     *       after retrying display screen to user with lock info.
     *
730bA*   12/05/19  DAS  7.30b
     *     - Added LABEL and PIRTRAN, which get the next seq#, not
     *       a date id.
     *     - Added optional return parameter
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fpirrecid# uf a e           k disk
     F                                     infds(file1ds)
730aAFpirlockfm cf   e             workstn usropn

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  File information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#file1ds

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

730aAd prtobjnam       s             10a
730aAd prtobjtyp       s             10a
730aAd rtnobjnam       s             20a
730aAd rtnobjtyp       s             10a
730aAd rtnlkjnam       s             10a
730aAd rtnlkjusr       s             10a
730aAd rtnlkjnum       s              6a
     D todayRecId      s             11  0 inz(0)
730bAD idType          s              5
730bAD idMax           s             13  0
730bAD idMaxDigits     s              3  0
730bAD returnCode      s             10

730aA*----------------------------------------------------------------
730aA* Constants
730aA*
730aAd errmsg          c                   'ERROR CREATING REC ID'
730aA*
     *----------------------------------------------------------------
730aA* System API: Retrieve User Job Attributes
730aAd Format          s              8
730aAd RcvVarLen       s             10i 0
730aAd dsJobDta        ds
730aAd  dsJobBytesRtn                10I 0
730aAd  dsJobBytesAvl                10I 0
730aAd  dsJobName                    10A
730aAd  dsJobUser                    10A
730aAd  dsJobNumber                   6A
730aAd  dsJobIntern                  16A
730aAd  dsJobStatus                  10A
730aAd  dsJobType                     1A
730aAd  dsJobSubtype                  1A
730aAd  dsJobReserv1                  2A
730aAd  dsJobRunPty                  10I 0
730aAd  dsJobTimeSlc                 10I 0
730aAd  dsJobDftWait                 10I 0
730aAd  dsJobPurge                   10A
730aA*
730aA*----------------------------------------------------------------
730aA* Called Programs
730aA*
730aAd prtlck          pr                  extpgm('PRTOBJLCK')
730aAd   prtobjn                     10a
730aAd   prtobjt                     10a
730aAd   prtljna                     10a
730aAd   prtljus                     10a
730aAd   prtljnu                      6a
730aA*
730aA* Retrieve lock information
730aAd rtnlckinf       pr                  extpgm('RTNLCKINF')
730aAd   rtnobjn                     20a
730aAd   rtnobjt                     10a
730aAd   rtnljna                     10a
730aAd   rtnljus                     10a
730aAd   rtnljnu                      6a
730aA*
730aA* System API: Retrieve User Job Info
730aAd getjobinfo      pr                  extpgm('QUSRJOBI')
730aAd   DsJob                             like(DsJobDta)
730aAd   Length                      10i 0 const
730aAd   APIFormat                    8    const
730aAd   ApiJob                      26    const
730aAd   InternJob                   16    const
     *

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pWhse          s              3s 0
     D  pFile          s             10
     D  pRecId         s             11p 0
730bAD  pRtnCode       s             10

     *----------------------------------------------------------------
     * Parameters
     *   Parameters:
     *     pWhse  - Warehouse
     *     pFile  - File
     *
     *   Return Value:
     *     recId      -  Record id (yymmddnnnnn)
     *                  -1 returned when error occurs.
730bA*     pRtnCode   - Return Code (optional)
     *                  *OK
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse
     C                   parm                    pFile
     C                   parm                    pRecId
730bAC                   parm                    pRtnCode

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

650aA  // Turn on LR for certain files.

650aA    if pFile = 'STGBATCH'
650aA       or pFile = 'DKTEXPORT';
650aA         *inlr = *on;
650aA    endif;

730bA  // Initialize return code

730bA  returnCode = '*OK';
730bA  if %parms >= 4;
730bA    pRtnCode = returnCode;
730bA  endif;

730bA  // Set id type

730bA  select;
730bA    when pFile = 'LABEL';
730bA      idType = 'SEQ';
730bA      idMaxDigits = 7;
730bA    when pFile = 'PIRTRAN';
730bA      idType = 'SEQ';
730bA      idMaxDigits = 7;
730bA    other;
730bA      idType = 'DATE';
730bA  endsl;

       // Get zero rec id for today.

       todayRecId = %dec(
                          %subst(
                                  %char(%date():*ymd0):1:6
                          ):6:0
                    ) * 100000;

       // Open PIRRECID#.

730bA  exsr OpenRecId;
730bA  if returnCode <> '*OK';
730bA    if %parms >= 4;
730bA      pRtnCode = returnCode;
730bA    endif;
730bA    return;
730bA  endif;

       // Get last id

730bA  exsr GetLastId;
730bA  if returnCode <> '*OK';
730bA    if %parms >= 4;
730bA      pRtnCode = returnCode;
730bA    endif;
730bA    return;
730bA  endif;

       // Get next id

730bA  exsr GetNextId;

       pRecId = nriRecId;

       return;

      /end-free
     *----------------------------------------------------------------
     * Subroutines
     *----------------------------------------------------------------

730aA*----------------------------------------------------------------
730aA*  DSPLOCK  Display lock information
730aA*----------------------------------------------------------------
730aA /Free
730aA   begsr dsplock;
730aA
730aA     RcvVarLen = %Size(DsJobDta);
730aA     Format = 'JOBI0100';
730aA
730aA     getjobinfo(dsjobdta : rcvvarlen : Format : '*' : ' ');
730aA
730aA     // Display screen if Interactive ONLY
730aA     if dsjobtype = 'I';
730aA        if not %open(pirlockfm);
730aA          open pirlockfm;
730aA        endif;
730aA
730aA       w1jnam = rtnlkjnam;
730aA       w1jusr = rtnlkjusr;
730aA       w1jnum = rtnlkjnum;
730aA
730aA       dou *inkf = *on;
730aA         w1jmsg = errmsg;
730aA         exfmt screen1;
730aA       enddo;
730aA
730aA       if %open(pirlockfm);
730aA         close pirlockfm;
730aA       endif;
730aA
730aA     endif;
730aA
730aA   endsr;
730aA
730aA /end-free

730aA*----------------------------------------------------------------
730aA*  GETLOCK  Get lock information
730aA*----------------------------------------------------------------
730aAC     getlock       begsr
730aA
730aAC                   eval      rtnobjnam = 'PIRRECID# *LIBL     '
730aAC                   eval      rtnobjtyp = '*FILE     '
730aAC                   eval      rtnlkjnam = *blanks
730aAC                   eval      rtnlkjusr = *blanks
730aAC                   eval      rtnlkjnum = *blanks
730aA
730aAC                   callp(e)  rtnlckinf(rtnobjnam: rtnobjtyp:
730aAC                                       rtnlkjnam: rtnlkjusr: rtnlkjnum)
730aA
730aAC                   endsr

730bA*----------------------------------------------------------------
730bA*  GetLastId   Get last id
730bA*----------------------------------------------------------------
730bA /Free
730bA   begsr GetLastId;

       // Get last id.
       // If record doesn't exist try creating it.

         for i = 1 to 2;

730aA      monitor;
730bM        chain (pWhse: pFile) pirrecid#;
730aA      on-error;
730aA        if %status = 1218;
730aA          exsr getlock;
730aA          exsr prtlock;
730aA          exsr dsplock;
730aA          iter;
730aA        endif;
730aA      endmon;

           // If found, get out

           if %found();
             leave;
           endif;

           // If not found and second time around,
           // Send back error.

           if i = 2;
730bA        if idType = 'DATE';
               pRecId = todayRecId + 99998;
730bA        else;
730bA          pRecId = 0;
730bA        endif;
730bA        returnCode = '*CREATEERR';
             leave;
           endif;

           // Otherwise, Create record and loop around to get it

           nriWhse = pWhse;
           nriFile = pFile;

730bA      select;
730bA        when idType = 'DATE';
               nriRecId = todayRecId;
730bA        other;
730bA          nriRecId = 0;
730bA      endsl;

           write(e) nrirec;

           if %error();
730bA        if idType = 'DATE';
               pRecId = todayRecId + 99997;
730bA        else;
730bA          pRecId = 0;
730bA        endif;
730bA        returnCode = '*WRITEERR';
             leave;
           endif;

         endfor;

        endsr;
      /end-free

730bA*----------------------------------------------------------------
730bA*  GetNextId   Get next id
730bA*----------------------------------------------------------------
730bA /Free
730bA   begsr GetNextId;

       // Calculate next rec id.
       //
       // For type DATE ...
       //   - When the day changes we start at seq# 1.
       //   - Within a day we assume that the seq# will not go
       //     past 99,999. If it does, no error will occur
       //     but we will overflow into the next day.

       select;

         when idType = 'DATE';
           if nriRecId = 0 or nriRecId < todayRecId;
             nriRecId = todayRecId + 1;
           else;
             nriRecId += 1;
           endif;

         when idType = 'SEQ';
           idMax = (10 ** idMaxDigits) - 1;
           if nriRecId >= idMax;
             nriRecId = 1;
           else;
             nriRecId += 1;
           endif;

       endsl;

       // Update the file.

       update(e) nrirec;

       endsr;
      /end-free

730bA*----------------------------------------------------------------
730bA*  OpenRecId   Open PIRRECID# file
730bA*----------------------------------------------------------------
730bA /Free
730bA   begsr OpenRecId;

         if not %open(pirrecid#);
           open(e) pirrecid#;

           if %error();

730bA        if idType = 'DATE';
               pRecId = todayRecId + 99999;
730bA        else;
730bA          pRecId = 0;
730bA        endif;

730bA        returnCode = '*OPENERR';

           endif;

         endif;

        endsr;
      /end-free

730aA*----------------------------------------------------------------
730aA*  PRTLOCK  Print lock information
730aA*----------------------------------------------------------------
730aAC     prtlock       begsr
730aA
730aAC                   eval      prtobjnam = 'PIRRECID# '
730aAC                   eval      prtobjtyp = '*FILE     '
730aA
730aAC                   callp     prtlck(prtobjnam: prtobjtyp:
730aAC                                    rtnlkjnam: rtnlkjusr: rtnlkjnum)
730aA
730aAC                   endsr

