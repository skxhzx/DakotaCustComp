     *----------------------------------------------------------------
     *   2018 Cheney Brothers
     *----------------------------------------------------------------
     *   Author:  Tom Forrest
     *   Date:    04/23/2018     TDF   Work List #2016133
     *
     *   Pgm: Print out from LT310
     *
     *----------------------------------------------------------------
     Flicactivetif   e           k disk
     Fqsysprt   O    F  132        PRINTER oflind(*inof)
     *
      /copy qcopysrc,p.cvtqty
     *
500bAD cqqty1          s              7  0
500bAD cqqty2          s              7  0
500bAD cqqty3          s              7  0
     D cqum1           s              2
     D cqum2           s              2
     D cqum3           s              2
     D w1qty           s             10
     D cqustr          s             17
     D cqrtn           s              8
     D cqerm           s             60
     D exdate          s              6S 0
     D endate          s              6S 0
     *
     c     *entry        plist
     c                   parm                    pwhse             3
     c                   parm                    pstyp             3
     *
     c                   move      pwhse         ckwhse            3 0
     c                   movel     pstyp         slot12           12
     c                   move      *all'_'       dashout         132
     *
     c     lkey          klist
     c                   kfld                    ckwhse
     c                   kfld                    laprty
     c                   kfld                    laexpd
     c                   kfld                    laentd
     c                   kfld                    lalcns
     *
     c                   time                    timedate         12 0
     c                   movel     timedate      hhmmss            6 0
     c                   move      timedate      cdate             6 0
     c                   movel     cdate         mmdd              4 0
     c                   move      cdate         yy                2 0
     *
     c                   except    hdr
     *
     c     lkey          setll     larec
     c                   read      larec                                  01
     c                   dow       *in01 = *off
     c                               and lawhse = ckwhse
     c                   movel     ladisp        check             3
     c     pstyp         cabne     check         skip1
     c                   if        *inof
     c                   except    hdr
     c                   endif

      /free

         // Format quantity string

         cqqty1 = laqty1;
         cqqty2 = laqty2;
         cqqty3 = laqty3;
         cvtqty('*QTY2STR': 'LT310P':
                cqqty1: cqqty2: cqqty3:
                cqum1: cqum2: cqum3:
                w1qty: cqustr: cqrtn: cqerm);
         evalr w1qty = %trimr(w1qty);

      /end-free

     c                   movel     laexpd        yyyy              4 0
     c                   move      yyyy          yy                2 0
     c                   move      laexpd        mmdd              4 0
     c                   eval      exdate = (mmdd * 100) + yy
     c                   movel     laentd        yyyy
     c                   move      yyyy          yy
     c                   move      laentd        mmdd
     c                   eval      endate = (mmdd * 100) + yy
     c                   except    detail
     c     skip1         tag
     c                   read      larec                                  01
     c                   enddo
     c                   eval      *inlr = *on
     ***********************************************************
     *          *****  OUTPUT *****                            *
     ***********************************************************
     OQSYSPRT   E            HDR            2  2
     O                                            6 'LT310P'
     O                       cdate         Y     20
     O                       hhmmss              35 '  :  :  '
     O                                           73 'License Infomation For'
     O                       pstyp               77
     O                                          127 'Page'
     O                       PAGE               132
     O          E            HDR            0
     O                       dashout            132
     O          E            HDR            1
     O                                            7 'License'
     O                                           24 'Item'
     O                                           39 'Slot'
     O                                           58 'Pr'
     O                                           74 'Expires'
     O                                           89 'Entered'
     O                                          108 'Quantity'
     O          E            DETAIL      1  1
     O                       lalcns              15
     O                       laitem              35
     O                       ladisp              47
     O                       laprty              58
     O                       exdate              74 '  /  / 0'
     O                       endate              89 '  /  / 0'
     O                       w1qty              108
