      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTGUVALUE  Test extracting glousr warehouse values
     *  04 July 2014
     *  Dave Sommerville
     *----------------------------------------------------------------

650bAD guvalue         S             30
650bAD uswhse          S              3  0
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

        uswhse = 9;
        guvalue = '900 1 2';
        exsr ChkWhseList;

        uswhse = 9;
        guvalue = '9 1 2';
        exsr ChkWhseList;

        return;
      /end-free

     *----------------------------------------------------------------
     *  ChkWhseList  Check warehouse against list
     *----------------------------------------------------------------

      /free
       begsr ChkWhseList;
650dA
           wkpos = 0;
           wkwhse = %char(uswhse);
650bA      whsLength = %Len(%Trim(%char(uswhse)));

650bA      if whsLength = 1;
650bA        wkwhs1B = %trim(wkwhse);
650bA        wkwhsB1B = ' ' + %trim(wkwhse) + ' ';
650bA        wkpos = %scan(wkwhs1B: guvalue);
650bA        if wkpos <> 1;
650bA          wkpos = %scan(wkwhsB1B: guvalue);
650bA        endif;
650bA      endif;

650bA      if whsLength = 2;
650bA        wkwhs2B = %trim(wkwhse);
650bA        wkwhsB2B = ' ' + %trim(wkwhse) + ' ';
650bA        wkpos = %scan(wkwhs2B: guvalue);
650bA        if wkpos <> 1;
650bA          wkpos = %scan(wkwhsB2B: guvalue);
650bA        endif;
650bA      endif;

650bA      if whsLength = 3;
650bA        wkwhs3B  = %trim(wkwhse);
650bA        wkwhsB3B = ' ' + %trim(wkwhse) + ' ';
650bA        wkpos = %scan(wkwhs3B: guvalue);
650bA        if wkpos <> 1;
650bA          wkpos = %scan(wkwhsB3B: guvalue);
650bA        endif;
650bA      endif;

       endsr;
      /end-free
