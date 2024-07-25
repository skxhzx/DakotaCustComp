      *----------------------------------------------------------------
      *
      *  ADD1DAY   Add one day to a date
      *  March, 09, 2005
      *  Jose Duque
      *
     *   1. Convert date (mmddyy) to its representation in number
     *      of days add one day to it and convert the result back
     *      to Gregorian date (mmddyy).
      *
      *----------------------------------------------------------------
      *
     C     *Entry        Plist
     C                   Parm                    $w1tod            6
      *
      *
     C                   Move      $w1tod        G$date            6 0
     C                   Exsr      Gtod$
     C                   Z-add     G$jd          Todte             5 0
      *
     C                   Z-add     *Zeros        J$jd              5 0
      *
      *
      *  Add 1 day to converted 'To Date' date and convert result back
      *  to Gregorian date.  NOTE: This convertion is utilized in
      *  applications processing information related to work shift
      *  that run into next day (ie; From 6:00 p.m. to 6:00 a.m. next day)
      *
     C     Todte         Add       1             J$jd
     C                   Exsr      Jtog$
     C                   Z-add     J$date        Nw1tod            6 0
     C                   Move      Nw1tod        $w1tod
      *
     C                   Return
      *
     C*
      *---------------------------------------------------------------*
      * Convert 'Gregorian' date (mmddyy) to its representation in    *
      * days. (Copied from Pgm:PIRMODSCBI/GR131)                      *
      *---------------------------------------------------------------*
     C     Gtod$         Begsr
      *
      *
      * Split date into Month, Day, Year fields
      *
     C                   Movel     G$date        G$mm              2 0
     C                   Move      G$date        Work4             4
     C                   Movel     work4         G$dd              2 0
     C                   Move      Work4         G$yy              2 0
      *
      * Create 4 Digit Year
     C                   Move      G$yy          G$yyyy            4 0
     C                   If        G$yy >= 60
     C                   Movel     '19'          G$yyyy
     C                   Else
     C                   Movel     '20'          G$yyyy
     C                   End
      *
     C                   Z-add     *Zeros        G$jd
     C     G$mm          Sub       3             G$mmwk            2 0
     C                   Z-add     G$mmwk        Gmwksv            2 0
     C                   If        G$mmwk < *zeros
     C                   Add       12            G$mmwk
     C                   End
      *
     C                   If        Gmwksv <> *zeros
     C     G$mmwk        Mult(h)   30.6          G$jd
     C                   End
      *
     C                   Add       G$dd          G$jd              5 0
     C     G$yyyy        Sub       1900          G$yywk            3 0
      *
     C                   If        G$yywk <> *zeros
     C                   If        Gmwksv <  *zeros
     C                   Sub       1             G$yywk
     C                   End
     C                   End
      *
     C     G$yywk        Mult      365.25        G$jyd             7 0
     C                   Add       G$jyd         G$jd
      *
     C                   Endsr
      *---------------------------------------------------------------*
      * Convert 'Julian' date (dddddd) to 'Gregorion'                 *
      * (Partially copied from Pgm:ER211)                             *
      *  JTOG$    Julian to Gregorian conversion                      *
      *---------------------------------------------------------------*
     C     Jtog$         Begsr
      *
      *
     C     J$jd          Div       365.25        J$yywk            3 0
     C     J$jd          Div       365.25        J$tst             9 9
      *
     C                   If        J$tst  =  *zeros
     C                   Sub       1             J$yywk
     C                   End
      *
     C     J$yywk        Mult      365.25        J$yd              7 0
     C     J$jd          Sub       J$yd          J$yd
     C                   If        J$yd > 306
     C                   Add       1             J$yywk
     C                   End
      *
     C                   Z-add     *zeros        J$x               2 0
     C     J$yd          Doule     J$md
     C                   Add       1             J$x
     C     J$x           Mult(h)   30.6          J$md              3 0
     C                   Enddo
      *
     C                   Sub       1             J$x
     C     J$x           Mult(h)   30.6          J$md
     C     J$yd          Sub       J$md          J$dd              2 0
     C     J$x           Add       3             J$mm              2 0
      *
     C                   If        J$mm > 12
     C                   Sub       12            J$mm
     C                   End
      *
     C     J$yywk        Add       1900          j$yyyy            4 0
     C                   Move      j$yyyy        Work2             2
     C                   Movel     J$mm          Work4
     C                   Move      J$dd          Work4
     C                   Move      Work2         J$date            6 0
     C                   Movel     Work4         J$date
     C                   Endsr
