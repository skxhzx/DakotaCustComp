      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  MINPODTE  Get minimum PO delivery date for item
     *  11 October 2018
     *  Dave Sommerville
     *
     *  Revisions
     *
610 A*    10/11/18  DAS  6.10
     *      - Created.
     *
610aA*    07/03/10  DAS  6.10a
     *      - Rewritten.
     *
650aA*    07/06/14  DAS  6.50a
     *      - Revised to not allow user to use a db that starts with
     *        TEST if user not assigned to *TESTER group.
     *      - Revised to extract warehouse number from last 3 characters
     *        of db id. If number found, it will be compared against
     *        the allowed warehouses from the glousr file.
     *
650bA*    07/07/14  DAS  6.50b
     *      - Added null indicator field to SQL statements to prevent
     *        job log entries when a record isn't found.
     *
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
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

650aAD guRel           s              2
650aAD guValue         s             30
     D sqlUser         s             10
     D sqlView         s              1
     D sqlAuth         s              1

650aAD alphaWhse       s              3
650aAD dbWhse          s              3  0
650aAD fromWhse        s              3  0
650aAD idlen           s              3  0
650bAD nullInd         s              2b 0 inz(0)
650aAD pos             s              3  0
650aAD startPos        s              3  0
650aAD toWhse          s              3  0
650aAD whseAllowed     s               n
650bAD whsLength       S              3s 0
650aAd wkpos           s              5s 0
650bAD wkwhse          S              3a
650bAD wkwhs1B         s              2a
650bAD wkwhsB1B        s              3a
650bAD wkwhs2B         s              3a
650bAD wkwhsB2B        s              4a
650bAD wkwhs3B         s              4a
650bAD wkwhsB3B        s              5a

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pDBid   - Databas id
     *      pUser   - User code
     *
     *    Returned Parameters
     *      pFlag   - 0 = Not authorized to use
     *                 1 = Authorized to use
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pDBid            10
     C                   parm                    pUser            10
     C                   parm                    pFlag             1 0

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         // Group ADMIN trumps all

650bM    exec sql select guguser into :sqlUser :nullInd
                  from glousrgrp
                  where guguser = :pUser and guggroup = 'ADMIN';

         if sqlstt = sqlSuccess;
           pFlag = 1;
           return;
         endif;

         // Next, a user security record takes precedence

650bM    exec sql select gdsview into :sqlView :nullInd
                  from glodbsec
                  where gdssdbid = :pDBid
                    and gdsstype = 'U'
                    and gdsscode = :pUser;

         if sqlstt = sqlSuccess;
           if sqlView = 'I';
             pFlag = 1;
           else;
             pFlag = 0;
           endif;
           return;
         endif;

         // Next, a group security record takes precedence.
         // A gdsview = 'I' takes precedence over 'E'.
         // Therefore, if a 'I' record is found, even if 'E' records exist,
         // the user has authority to view the db.

650bM    exec sql select max(gdsview) into :sqlView :nullInd
                  from glodbsec
                  inner join glousrgrp
                          on guguser = :pUser and guggroup = gdsscode
                  where gdssdbid = :pDBid
                    and gdsstype = 'G';

650bM    if sqlstt = sqlSuccess and nullInd >= 0;
           if sqlView = 'I';
             pFlag = 1;
           else;
             pFlag = 0;
           endif;
           return;
         endif;

650aA    // If db id starts with 'TEST',
650aA    // Then user must be in group *TESTER
650aA
650aA    if %subst(pDBid: 1: 4) = 'TEST';
650aA
650aA      exec sql select guguser into :sqlUser :nullInd
650aA               from glousrgrp
650aA               where guguser = :pUser and guggroup = '*TESTER';
650aA
650aA      if sqlstt <> sqlSuccess;
650aA        pFlag = 0;
650aA        return;
650aA      endif;
650aA
650aA    endif;

650aA    // If db id ends with 3-digits,
650aA    // Then treat as a warehouse number and verify
650aA    // against user's authorized databases.
650aA
650aA    exsr GetDbWhse;
650aA    if dbWhse <> 0;
650aA      exsr ChkWhse;
650aA      if whseAllowed;
650aA        pFlag = 1;
650aA      else;
650aA        pFlag = 0;
650aA      endif;
650aA      return;
650aA    endif;

         // Last of all, use the db default.

650bM    exec sql select gdsauth into :sqlAuth :nullInd
                  from glodbsrc
                  where gdsid = :pDBid;

         if sqlstt = sqlSuccess;
           if sqlAuth = 'I';
             pFlag = 1;
           else;
             pFlag = 0;
           endif;
           return;
         endif;

         // We shouldn't make it here, but if we do ...

         pFlag = 0;
         return;

      /end-free

650aA*----------------------------------------------------------------
650aA*  GetDbWhse    Get Database warehouse
650aA*----------------------------------------------------------------
650aA
650aA /free
650aA  begsr GetDbWhse;

         dbWhse = 0;
         idLen = %len(%trimr(pDBid));

         if idLen > 3;
           alphaWhse = %subst(pDBid: idLen - 2: 3);
           monitor;
             dbWhse = %dec(alphaWhse: 3: 0);
           on-error;
             dbWhse = 0;
             leavesr;
           endmon;
         endif;

       endsr;
      /end-free

650aA*----------------------------------------------------------------
650aA*  ChkWhse   Check user authorized to warehouse
650aA*----------------------------------------------------------------
650aA
650aA /free
650aA  begsr ChkWhse;

         whseAllowed = *off;

         exec sql select gurel,guvalue into :guRel, :guValue
                  from glousr
                  where guuser = :pUser;

         if sqlstt <> sqlSuccess;
           leavesr;
         endif;

         select;
           when gurel = 'EQ';
             exsr ChkWhseList;
           when gurel = 'LS';
             exsr ChkWhseList;
           other;
             exsr ChkWhseRange;
         endsl;

       endsr;
      /end-free

650aA*----------------------------------------------------------------
650aA*  ChkWhseList  Check warehouse against list
650aA*----------------------------------------------------------------
650aA
650aA /free
650aA  begsr ChkWhseList;

         wkwhse = %char(dbWhse);
         whsLength = %Len(%Trim(wkWhse));

         select;

           when whsLength = 1;
             wkwhs1B = %trim(wkwhse);
             wkwhsB1B = ' ' + %trim(wkwhse) + ' ';
             wkpos = %scan(wkwhs1B: guvalue);
             if wkpos <> 1;
               wkpos = %scan(wkwhsB1B: guvalue);
             endif;

           when whsLength = 2;
             wkwhs2B = %trim(wkwhse);
             wkwhsB2B = ' ' + %trim(wkwhse) + ' ';
             wkpos = %scan(wkwhs2B: guvalue);
             if wkpos <> 1;
               wkpos = %scan(wkwhsB2B: guvalue);
             endif;

           when whsLength = 3;
             wkwhs3B  = %trim(wkwhse);
             wkwhsB3B = ' ' + %trim(wkwhse) + ' ';
             wkpos = %scan(wkwhs3B: guvalue);
             if wkpos <> 1;
               wkpos = %scan(wkwhsB3B: guvalue);
             endif;

         endsl;

         if wkpos > 0;
           whseAllowed = *on;
         endif;

       endsr;
      /end-free

650aA*----------------------------------------------------------------
650aA*  ChkWhseRange   Check warehouse against range
650aA*----------------------------------------------------------------
650aA
650aA /free
650aA  begsr ChkWhseRange;

         fromWhse = 0;
         toWhse = 0;
         guvalue = %trim(guvalue);

         // Get first value

         wkpos = %scan(' ': guvalue);

         // If string is not 1 - 3 characters,
         // something is defined wrong so get out.

         if wkpos < 2 or wkpos > 4;
           leavesr;
         endif;

         // Turn string into number

         alphaWhse = %subst(guvalue: 1: wkpos-1);
         monitor;
           fromWhse = %dec(alphaWhse: 3: 0);
         on-error;
           leavesr;
         endmon;

         // Do non-RG checks

         select;
           when gurel = 'GT';
             if dbWhse > fromWhse;
               whseAllowed = *on;
               leavesr;
             endif;
           when gurel = 'GE';
             if dbWhse >= fromWhse;
               whseAllowed = *on;
               leavesr;
             endif;
           when gurel = 'LT';
             if dbWhse < fromWhse;
               whseAllowed = *on;
               leavesr;
             endif;
           when gurel = 'LE';
             if dbWhse <= fromWhse;
               whseAllowed = *on;
               leavesr;
             endif;
         endsl;

         // Get out for any other non-RG check.

         if gurel <> 'RG';
           leavesr;
         endif;

         // Get second value and check range.

         // If we don't find another non-blank character,
         // something is defined wrong so get out.

         startPos = %check(' ': guvalue: wkpos);
         if startPos = 0;
           leavesr;
         endif;

         // If we don't find a space after the above character,
         // something is defined wrong so get out.

         wkpos = %scan(' ': guvalue: startPos);
         if wkpos = 0;
           leavesr;
         endif;

         // If the length of the string we find is > 3,
         // something is defined wrong so get out.

         if (wkpos - startPos) > 3;
           leavesr;
         endif;

         // Now turn string into number

         alphaWhse = %subst(guvalue: startPos: wkpos-1);
         monitor;
           toWhse = %dec(alphaWhse: 3: 0);
         on-error;
           leavesr;
         endmon;

         // See if whse is within range

         if (dbWhse >= fromWhse) and (dbWhse <= toWhse);
           whseAllowed = *on;
         endif;

       endsr;
      /end-free
