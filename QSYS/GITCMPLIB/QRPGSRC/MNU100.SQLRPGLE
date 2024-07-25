      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  MNU100    Custom Menu Driver
     *  January 20, 2012
     *  Rod Roller
     *
     *  NOTES:
     *    TO CREATE/MAINTAIN MENU OPTIONS, USE MNU110CL.
     *    Call MNU100 with no parms to use default client name menu.
     *    Program uses PIRCLIENT DTAARA for default menu name.
     *    Seq 0, Active = N for menu title header.
     *    Seq 10 (etc.), Active = 'Y' and menu option text and command for others.
700a *    To call another custom menu, use '*MENU <name>' to call the next menu.
     *
     *  Revisions
     *
     *    01/20/12  RTR  6.40
     *      -  Created from RF840.
     *    01/30/14  RTR  6.50
     *      -  Updated notes to include maintenance program.
650a *    08/13/14  RTR  6.50a
     *      -  Fix to show group headings.
     *
700a *    09/08/15  RTR  7.00a
     *      -  Change to allow command of '*MENU NEWMENU' to
     *         display another menu (ex. NEWMENU)
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  98        Error on screen (sound alarm)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fmnu100fm  cf   e             workstn

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D menutable       s             36    dim(26)

     *----------------------------------------------------------------
     *  Program info data structure
     *
      /COPY *libl/qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *
     D client          s             10a
     D count           s              5  0
     D dscommand       s            120a
     D dsoption        s              2  0
     D dstext          s             36a
     D dstitle         s             36a
     D nxtscr          s              3
     d optcmd          s            200a
     d optlen          s             15  5
     D workmenu        s             10a
     *
     *----------------------------------------------------------------
     *  Program Prototype and Entry Parms
     *
     d Main            pr                  extpgm('MNU100')
     d                               10
     d Main            pi
     d  parmmenu                     10a

     *----------------------------------------------------------------
     *  Called Program Prototypes
     *
     d OptionCall      pr                  extpgm('QCMDEXC')
     d  parmcmd                     200
     d  parmlen                      15  5

     *----------------------------------------------------------------
     *  Customer id
     *
     D GetClient       pr                  extpgm('GETCLIENT')
     d  parmclient                   10a

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pmenu    Specific Menu Name Override
     *                (If blank program uses Customer ID)
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *----------------------------------------------------------------
     *  Main line
     *
      /free

        exsr zzinz2;

        dow nxtscr <> 'EOJ';
          exsr dspscr;

          if nxtscr = '01 ';
            exsr sc1;
          endif;

        enddo;

        *inlr = *on;
        return;

      /end-free

     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
      /free
        Begsr dspscr;

          if nxtscr = '01 ';
            exfmt screen1;
          endif;

          *in98 = *off;

        Endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
     *
     *  Screen 01 initialization
     *
      /free
        Begsr scr01i;

          nxtscr = '01 ';
          exsr zzfil1;

        Endsr;  // end01i
      /end-free

     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
      /free
        Begsr Sc1;

          Select;
            when *inkc;
              nxtscr = 'EOJ';

            when *inkl;
              nxtscr = 'EOJ';

            when w1opt = 0;
              nxtscr = 'EOJ';

            other;
              exsr zzchk1;
              if *in98 = *off;
                exsr zzupd1;
              endif;

          Endsl;

        Endsr;  // Sc1
      /end-free

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
      /free
        Begsr *inzsr;

          // Get client id.
          GetClient ( client );

          // Call user added initialization routine.
          exsr zzinz;

          // If menu name not passed, use client as default
          if %parms = 1;
            workmenu = parmmenu;
          else;
            workmenu = client;
          endif;

        Endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
      /free
        Begsr zzchk1;

          Exec Sql select MNUCMD into :dscommand from MNUCFG
                    where MNUKEY = :workmenu and MNUOPT = :w1opt
                      and MNUACT = 'Y';

          if sqlstt <> '00000';
            *in98 = *on;
          endif;

        Endsr;  // zzchk1
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
      /free
        Begsr zzcmd1;
        Endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
      /free
        Begsr zzfil1;

          w1opt = 0;

          // Get title for menu from sequence 0 record
          exec sql select MNUTXT into :dstitle from MNUCFG
                    where MNUKEY = :workmenu and MNUSEQ = 0;

          // If no sequence 0 record, use 'Client Menu'
          if sqlstt = '00000';
            w1head = dstitle;
          else;
            w1head = '            ' + %trim(client) + ' Menu';
          endif;

          // Select active config records for menu
          exec sql declare mnucsr cursor for
            select MNUOPT, MNUTXT from MNUCFG
             where MNUKEY = :workmenu and MNUACT = 'Y'
             order by MNUSEQ;
          exec sql open mnucsr;

          // Read config records into table
          count = 0;
          clear menutable;
          exec sql fetch next from mnucsr
            into :dsoption, :dstext;

          dow sqlstt = '00000' and count < 26;
            count += 1;
650aA       select;
650aA         when dsoption <> 0;
                if dsoption < 10;
                  menutable(count) = ' ' + %trimr(%char(dsoption))
                                   + '. ' + %trim(dstext);
                else;
                  menutable(count) = %trimr(%char(dsoption))
                                   + '. ' + %trim(dstext);
                endif;
650aA         when dsoption = 0;
650aA           menutable(count) = %trim(dstext);
650aA       endsl;
            exec sql fetch next from mnucsr
              into :dsoption, :dstext;
          enddo;

          exec sql close mnucsr;

          // Move table to screen fields
          mnut01 = menutable(1);
          mnut02 = menutable(2);
          mnut03 = menutable(3);
          mnut04 = menutable(4);
          mnut05 = menutable(5);
          mnut06 = menutable(6);
          mnut07 = menutable(7);
          mnut08 = menutable(8);
          mnut09 = menutable(9);
          mnut10 = menutable(10);
          mnut11 = menutable(11);
          mnut12 = menutable(12);
          mnut13 = menutable(13);
          mnut14 = menutable(14);
          mnut15 = menutable(15);
          mnut16 = menutable(16);
          mnut17 = menutable(17);
          mnut18 = menutable(18);
          mnut19 = menutable(19);
          mnut20 = menutable(20);
          mnut21 = menutable(21);
          mnut22 = menutable(22);
          mnut23 = menutable(23);
          mnut24 = menutable(24);
          mnut25 = menutable(25);
          mnut26 = menutable(26);

        Endsr;  // zzfil1
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
      /free
        Begsr zzinz;

          *in98 = *off;

        Endsr;  // zzinz
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
      /free
        Begsr zzinz2;

          exsr scr01i;

        Endsr;  // zzinz2
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
      /free
        Begsr zzupd1;

700aA     if %subst(dscommand:1:5) = '*MENU ';
700aA       workmenu = %subst(dscommand:7:10);
700aA       exsr scr01i;
700aA     else;
            clear optcmd;
            optcmd = dscommand;
            optlen = %len(%trim(dscommand));
            callp(e) OptionCall ( optcmd : optlen );
700aA     endif;

          w1opt = 0;

        Endsr;  // zzupd1
      /end-free
