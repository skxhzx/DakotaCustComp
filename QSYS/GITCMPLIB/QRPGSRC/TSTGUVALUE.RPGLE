      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTGUVALUE  Test extracting glousr warehouse values
     *  04 July 2014
     *  Dave Sommerville
     *----------------------------------------------------------------

     D  whseAllowed    s               n
     D  gdsid          s             10
     D  gurel          s              2
     D  guvalue        s             30
     D  idlen          s              3  0
     D  fromWhse       s              3  0
     D  toWhse         s              3  0
     D  dbWhse         s              3  0
     D  alphaWhse      s              3
     D  startPos       s              3  0
     D  pos            s              3  0
     d wkpos           s              5s 0
650bAD whsLength       S              3s 0
650bAD wkwhse          S              3a
650bAD wkwhs1B         s              2a
650bAD wkwhsB1B        s              3a
650bAD wkwhs2B         s              3a
650bAD wkwhsB2B        s              4a
650bAD wkwhs3B         s              4a
650bAD wkwhsB3B        s              5a

      /free
        *inlr = *on;

        gdsid = 'PROD001';
        exsr GetDbWhse;
        dbWhse = dbWhse;

        gurel = 'EQ';
        guvalue = '1';
        exsr ChkWhse;
        whseAllowed = whseAllowed;

        gurel = 'EQ';
        guvalue = '2';
        exsr ChkWhse;
        whseAllowed = whseAllowed;

        gurel = 'LS';
        guvalue = '2 900 1 3';
        exsr ChkWhse;
        whseAllowed = whseAllowed;

        gurel = 'LS';
        guvalue = '2 900 3';
        exsr ChkWhse;
        whseAllowed = whseAllowed;

        gurel = 'RG';
        guvalue = '1 999';
        exsr ChkWhse;
        whseAllowed = whseAllowed;

        gurel = 'RG';
        guvalue = '5 999';
        exsr ChkWhse;
        whseAllowed = whseAllowed;

        gurel = 'GE';
        guvalue = '1';
        exsr ChkWhse;
        whseAllowed = whseAllowed;

        gurel = 'GT';
        guvalue = '5';
        exsr ChkWhse;
        whseAllowed = whseAllowed;

        gdsid = 'PROD900';
        exsr GetDbWhse;
        dbWhse = dbWhse;

        gurel = 'RG';
        guvalue = '5 999';
        exsr ChkWhse;
        whseAllowed = whseAllowed;

        return;
      /end-free

     *----------------------------------------------------------------
     *  GetDbWhse    Get Database warehouse
     *----------------------------------------------------------------

      /free
       begsr GetDbWhse;
650dA
650dA    dbWhse = 0;
650dA    idLen = %len(%trimr(gdsid));

         if idLen > 3;
           alphaWhse = %subst(gdsid: idLen - 2: 3);
650dA      monitor;
650dA        dbWhse = %dec(alphaWhse: 3: 0);
650dA      on-error;
650dA        dbWhse = 0;
650dA      endmon;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChkWhse   Check user authorized to warehouse
     *----------------------------------------------------------------

      /free
       begsr ChkWhse;
650dA
650dA    whseAllowed = *off;
650dA
650dA    if dbWhse = 0;
650dA      leavesr;
650dA    endif;
650dA
650dA    select;
650dA      when gurel = 'EQ';
650dA        exsr ChkWhseList;
650dA      when gurel = 'LS';
650dA        exsr ChkWhseList;
650dA      other;
650dA        exsr ChkWhseRange;
650dA    endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChkWhseList  Check warehouse against list
     *----------------------------------------------------------------

      /free
       begsr ChkWhseList;

         wkwhse = %char(dbWhse);
         whsLength = %Len(%Trim(wkWhse));

         if whsLength = 1;
           wkwhs1B = %trim(wkwhse);
           wkwhsB1B = ' ' + %trim(wkwhse) + ' ';
           wkpos = %scan(wkwhs1B: guvalue);
           if wkpos <> 1;
             wkpos = %scan(wkwhsB1B: guvalue);
           endif;
         endif;

         if whsLength = 2;
           wkwhs2B = %trim(wkwhse);
           wkwhsB2B = ' ' + %trim(wkwhse) + ' ';
           wkpos = %scan(wkwhs2B: guvalue);
           if wkpos <> 1;
             wkpos = %scan(wkwhsB2B: guvalue);
           endif;
         endif;

         if whsLength = 3;
           wkwhs3B  = %trim(wkwhse);
           wkwhsB3B = ' ' + %trim(wkwhse) + ' ';
           wkpos = %scan(wkwhs3B: guvalue);
           if wkpos <> 1;
             wkpos = %scan(wkwhsB3B: guvalue);
           endif;
         endif;

         if wkpos > 0;
           whseAllowed = *on;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChkWhseRange   Check warehouse against range
     *----------------------------------------------------------------

      /free
       begsr ChkWhseRange;

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
650dA    monitor;
650dA      fromWhse = %dec(alphaWhse: 3: 0);
650dA    on-error;
           leavesr;
650dA    endmon;

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
650dA    monitor;
650dA      toWhse = %dec(alphaWhse: 3: 0);
650dA    on-error;
           leavesr;
650dA    endmon;

         // See if whse is within range

         if (dbWhse >= fromWhse) and (dbWhse <= toWhse);
           whseAllowed = *on;
         endif;

       endsr;
      /end-free
