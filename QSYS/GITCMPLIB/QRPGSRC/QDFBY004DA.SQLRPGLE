      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  QDFBY004  Put items in pick slots
     *  01 December 2016
     *  Rod Roller
     *
     *  12/01/16  RTR  7.00
     *    - Created.
     *
     *----------------------------------------------------------------
     *  File Specs
     fqdfbyxref1uf   e           k disk    extmbr('TEST1')

     *----------------------------------------------------------------
     *  Standard Variables
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL Variables
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Table and array definitions
     d lower           c                   'abcdefghijklmnopqrstuvwxyz'
     d upper           c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

     *----------------------------------------------------------------
     *  Variables
     d holdDisp        s             12a
     d wkItem          s             15a
     d wkStk1          s              5s 0
     d wkStk2          s              3s 0

     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *  Main line
      /free

        dou forever <> forever;
          read qdfbyxref1;

          if %eof(qdfbyxref1);
            leave;
          endif;

          if xract <> ' ';
            iter;
          endif;

          if xrolds <> ' '
           and %subst(xrolds:5:1) = ' ';
            xract = 'SK1';
            xrtext = 'Skipped - Multi slot';
            update rlrec;
            iter;
          endif;

          holddisp = %subst(xrdisp:1:2) + '-'
                   + %subst(xrdisp:3:3) + '-'
                   + %subst(xrdisp:6:3);

          exec sql select slitem, slstk1, slstk2
                     into :wkItem, :wkStk1, :wkStk2
                     from slot
                    where sldisp = :holddisp;
          if sqlstt <> sqlsuccess;
            xract = 'ER1';
            xrtext = 'Slot not found - ' + holddisp;
            update rlrec;
            iter;
          else;
            select;
              when wkItem <> ' ' and wkItem = xritem;
                xract = 'SK2';
                xrtext = 'Same item already in slot - ' + holddisp;
                update rlrec;
              when wkItem <> ' ' and wkItem <> xritem
               and (wkStk1 <> 0 or wkStk2 <> 0);
                xract = 'SK3';
                xrtext = 'Different item already in slot - item '
                       + wkItem;
                update rlrec;
              when wkItem <> ' ' and wkItem <> xritem
               and wkStk1 = 0 and wkStk2 = 0;
                xract = 'UPR';
                xrtext = 'Different item already in slot - item '
                       + %trim(wkItem) + ' replaced';
                update rlrec;
              when wkItem = ' ';
                exec sql update slot
                            set slitem = :xritem,
                                slstat = 'A'
                          where sldisp = :holddisp;
                xract = 'UPD';
                xrtext = 'Item put into slot - ' + holddisp;
                update rlrec;
              other;
                xract = 'ER2';
                xrtext = 'Skipped for some other reason';
                update rlrec;
            endsl;
          endif;
        enddo;

        *inlr = *on;
      /end-free
