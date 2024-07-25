      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     * Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  SL450    Slots with no actitity
     *  11 January 2011
     *  Roxanne Harrison
     *
     *  Revisions
     *
417 A*    01/11/11  RH   6.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTSQLRPGI OBJ(*) SRCFILE(*) TGTRLS(V4R4M0)
     *               COMMMIT(*NONE) DLYPRP(*YES)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Fsl450fm   cf   e             workstn usropn
     F                                     sfile(sfl1:rrn1)
     F                                     infds(info)
     Fsl450pr   O    E             printer usropn
     F                                     oflind(*IN90)

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,f#slflds
      /Copy qcopysrc,f#lbflds

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------
     D @cvtdt          c                   const('CVTDTE')
     *
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76


     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  SQL fields for screen 1
     *----------------------------------------------------------------

     D fetchds1        ds
     D   #slwhse                           like(slwhse)
     D   #slwhdp                           like(slwhdp)
     D   #sldisp                           like(sldisp)
     D   #lbsdte                           like(lbsdte)
500a D   #lbsdtei                     2b 0
500a D** #ehmetr                           like(ehmetr)
500a D** #ehmetri                     2b 0

     *----------------------------------------------------------------
     *  SQL fields for screen 2
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D noon            s               t   inz(t'12.00.00')

     D currtimestamp   s               z

     D $fromdate       s               d

     D datestamp       s               d
     D timestamp       s               t

     D datedsp         s              8
     D timedsp         s              8

     D dteodsp         s              8
     D timodsp         s              8

     D dteidsp         s              8
     D timidsp         s              8

     D nodate          s               d   inz(d'0001-01-01')

     D fmcmd           s              8  0

     *----------------------------------------------------------------
     *  Display File Information Data Structure
     *----------------------------------------------------------------

     Dinfo             ds
     D cfkey                 369    369

     *----------------------------------------------------------------
     *  Constants for attention key indicator byte
     *----------------------------------------------------------------

     D*F3              c                   const(X'33')
     D*F4              c                   const(X'34')
     D*F9              c                   const(X'39')
     D*F12             c                   const(X'3C')
     D*F21             c                   const(X'B9')

     D*Enter           c                   const(X'F1')
     D*PageDown        c                   const(X'F5')

     *----------------------------------------------------------------
     *  Constants for screen attributes
     *----------------------------------------------------------------

415aAD @attrib         s              1    inz(' ')

     D @n              c                   const(X'20')
     D @h              c                   const(X'22')
     D @u              c                   const(X'24')
     D @hu             c                   const(X'26')

     D @red            c                   const(X'28')

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

415aAD blanks          s            100    inz(' ')
417a D*SubfilePage     c                   Const(17)
417a D SubfilePage     c                   Const(16)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D inzscreen1      s               n
     D lastcode        s                   like(slwhdp)
     D lastrrn         s                   like(rrn1)
     D leftjoin        s             80a   inz(' ')
415aAD maxdate         s              6  0 inz(0)
     D oldhead         s                   like(schead)
     D oldkey          s                   like(sckey)
     D oldname         s                   like(scrname)
     D oldopt          s                   like(scopt)
     D optiontaken     s             10    inz(' ')
     D orderby         s             50a   inz(' ')
     D printflag       s               n
415aAD sc1order1       s             10    inz(' ')
415aAD sc1order2       s             10    inz(' ')
415aAD sc1order3       s             10    inz(' ')
415aAD sc2order1       s             20    inz(' ')
415aAD sc2order2       s             20    inz(' ')
415aAD scheadlen       s              3  0 inz(0)
415aAD scpad           s              3  0 inz(0)
415aAD sortorder1      s             10    inz(' ')
415aAD sortorder2      s             10    inz(' ')
415aAD*sortorder3      s             10    inz(' ')

     *----------------------------------------------------------------
     *  Hidden subfile field
     *----------------------------------------------------------------

     D sflhide         ds
     D  h1whse                 1      3  0
     D  h1code                 4      8
     D  h1disp                 9     20
     D**h1mdy                 21     28

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Error message variables
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')
415aAD $msgf           s             10    inz(' ')
     D #msgid          s              7
     D #msgtp          s              7
     D #msgdt          s            128

     D $mdt            ds
     D  errmsg                 1     50

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pcmd    *DISPLAY - Display list.
     *               *PRINT   - Print list.
     *      $pwhse   Warehouse
     *      $pcode   Department or *ALL
     *      $pfrom   From date (MMDDYY)
     *      $pdev    Printer device code.
     *      $pform   Printer form.
     *      NOTE: Only $pcode can have a value.
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pwhsea           3
     C                   parm                    $pcode            5
     C                   parm                    $pfrom            6
     C                   parm                    $pdev            10
     C                   parm                    $pform           10


     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     C                   time                    currtimestamp
     C                   move      currtimestamp datestamp

     *  Establish SQL connection.

     C                   exsr      sqlconnect

     *  Initialize selection/sort fields.

     C                   move      $pwhsea       w1whse
     C                   eval      w1whdp = $pcode
     C                   move      $pfrom        w1from

     C                   eval      inzscreen1 = *on
     C                   exsr      getcriteria1

     *  Initialize print fields.

     C                   eval      wpdev  = $pdev
     C                   eval      wpform = $pform

     *  Process main screen.

     C                   if        $pcmd = '*PRINT'
     C                   exsr      printit
     C                   else
     C                   exsr      screen1
     C                   endif


     *  Disconnect SQL connection.

     C                   exsr      sqldisconnect

     * Bye, Bye.

     C                   Eval      *inlr = *on
     C                   return

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      SQL Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  sqlbldstmt1 - Build SQL statment for screen 1
     *----------------------------------------------------------------

     C     sqlbldstmt1   BegSr

     * Create select statement.

      /free

        sqlStmt = 'select '
                +   'slwhse, slwhdp, sldisp, '
                +   '(select max(lbsdte) from label '
                +     'where lbwhse=slwhse and lbwhdp=slwhdp '
                +       'and lbdisp=sldisp) '
                + 'from slot '
                + 'where '
                +   'slwhse=' + %editc(w1whse:'P');

        if w1whdp <> '*ALL' and w1whdp <> ' ';
          sqlstmt = %trim(sqlstmt) + ' '
                  + 'and slwhdp=' + sq + %trim(w1whdp) + sq;
        endif;

        sqlstmt = %trim(sqlstmt) + ' '
                + 'and slstat not in (''V'',''Z'') '
                + 'and not exists '
                +    '(select * from label where lbwhse=slwhse '
                +     'and lbwhdp=slwhdp and lbdisp=sldisp '
                +     'and lbsdte>=' + %editc(fmcmd :'X') + ') '
                + 'order by '
                +   %trim(sc1order1) + ','
                +   %trim(sc1order2) + ','
                +   %trim(sc1order3);

      /end-free

     * Create list heading

     C                   exsr      createhead1

     C                   EndSr

     *----------------------------------------------------------------
     *  sqlbldstmt2 - Build SQL statment for screen 2
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  sqlconnect - Establish SQL connection.
     *----------------------------------------------------------------

     C     sqlconnect    BegSr

     * Establish the connection to the remote machine. The -842 return
     * code indicates that the connection is already established. If
     * you want to connect to the local machine, use CONNECT RESET.

     C/EXEC SQL
     C+ CONNECT RESET
     C/END-EXEC

     *--- DEBUG ---
     C                   if        sqlstt <> '00000'
     C                   endif

     C                   EndSr

     *----------------------------------------------------------------
     *  sqlprep - Prepare SQL cursor
     *
     *    Note: This routine must come before any other routine
     *          using an SQL statement because it declares the
     *          SQL Cursor being used.
     *----------------------------------------------------------------

     C     sqlprep       BegSr

     * Prepare the SQL statement for validation, since the program was
     * compiled with DLYPRP (*YES), it will wait until it is used before
     * it prepares the cursor.

     C/EXEC SQL
     C+   PREPARE sel FROM :SqlStmt
     C/END-EXEC
     C                   eval      sqlstt = sqlstt
      *
      * Declare the SQL cursor to hold the data retrieved from the SELECT
      *
     C/EXEC SQL
     C+ DECLARE MYCSR DYNAMIC SCROLL CURSOR FOR SEL
     C/END-EXEC
     C                   eval      sqlstt = sqlstt
      *
      * Open the SQL cursor.
      *
     C
     C/EXEC SQL
     C+ OPEN MYCSR
     C/END-EXEC
     C                   eval      sqlstt = sqlstt
      *
     C                   EndSr

     *----------------------------------------------------------------
     *  sqlclean - Clean up before exiting
     *----------------------------------------------------------------

     C     sqlclean      BegSr

     * Close the SQL cursor after all processing is complete.

     C/EXEC SQL
     C+   CLOSE mycsr
     C/END-EXEC

     *--- DEBUG ---
     C                   if        sqlstt <> '00000'
     C                   endif

     C                   Endsr

     *----------------------------------------------------------------
     *  sqldisconnect - Disconnect SQL connection
     *----------------------------------------------------------------

     C     sqldisconnect BegSr

     C/EXEC SQL
     C+   DISCONNECT CURRENT
     C/END-EXEC

     *--- DEBUG ---
     C                   if        sqlstt <> '00000'
     C                   endif

     C                   Endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                    Subfile Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  sflbld1 - Build the subfile
     *----------------------------------------------------------------

     C     sflbld1       BegSr

     C                   Eval      rrn1 = Lastrrn

     * Process the records in the SQL cursor until the return not = 0

     C                   Do        SubfilePage

     * Get the next row from the SQL cursor.

     C/EXEC SQL
     C+   FETCH NEXT FROM mycsr
500aDC*      INTO :fetchds1
500aMC+      INTO :#slwhse,:#slwhdp,:#sldisp,:#lbsdte :#lbsdtei
     C/END-EXEC

     C                   If        sqlstt = '00000'
     C                   exsr      createline1
     C                   Eval      rrn1  = rrn1  + 1
     C***                Eval      option = ' '
     C                   Write     sfl1
     C                   Else
     C                   Leave
     C                   EndIf

     C                   EndDo

     C                   If        rrn1 = 0
     C                   Eval      *in32 = *on
     C                   Else
     C                   Eval      Lastrrn = rrn1
     C                   EndIf

      * A code of 2000 means end of file.

     C                   If        sqlstt = '02000'
     C                   Eval      *in90 = *on
     C                   EndIf

     C                   EndSr

     *----------------------------------------------------------------
     *  sflbld2 - Build the subfile for item detail
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  sflclr - Clear subfile
     *----------------------------------------------------------------

     C     sflclr        BegSr

      * Clear the subfile

     C                   Eval      *in31 = *on
     C                   Write     sf1ctl
     C                   Eval      *in31 = *off
     C                   Eval      *in32 = *off
     C                   Eval      rrn1 = 0
     C                   Eval      Lastrrn = 0
     C                   Eval      *in90 = *off

      * Clear the error message subfile

MSG MC                   exsr      zmcpmq

     C                   EndSr

     *----------------------------------------------------------------
     *  sfloption1 - Get entered option
     *----------------------------------------------------------------

     C     sfloption1    BegSr

     C                   Eval      optiontaken = *off
     C                   Eval      *in21 = *off

     C                   dow       forever = forever

     C                   readc     sfl1
     C                   if        %eof
     C                   leave
     C                   endif

     C**                 select
     C**                 when      %trim(option) = '12'
     C**                 eval      optiontaken = 'Question'
     C**                 leave
     C**                 endsl

     C                   enddo

     C                   EndSr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                Screen Processing Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  screen1 - Process screen 1
     *----------------------------------------------------------------

     C     screen1       BegSr

     *  Open screen file

     C                   open(e)   sl450fm
     C                   if        %error
     C                   endif
     C                   eval      #pgmq = #pgm

     *  Initialize some screen fields.

     C                   Eval      scrname = 'SL450.01'
     C**                 eval      scopt = '12=Questions'
     C                   eval      sckey = 'F3=Exit  '
     C                                   + 'F9=Select/Sort  '
     C                                   + 'F21=Print list  '
     C                                   + 'F12=Cancel'

     *  Do initial build and display of subfile.

     C                   exsr      sqlclean
     C                   exsr      sqlbldstmt1
     C                   exsr      sqlprep
     C                   ExSr      sflclr
     C                   ExSr      sflbld1

     *  Process subfile until user wants to leave.

     C                   DoU       (cfkey = F3)

     C                   Write     fkey1
     C                   exsr      zmdmsg
     C                   ExFmt     sf1ctl
      *
     C                   Select

     *    Enter

     C                   when      cfkey = Enter
     C                   exsr      sfloption1
     C*                  select
     C*                  when      optiontaken = 'Question'
     C*                  exsr      screen2
     C*                  endsl
     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt1
     C                   ExSr      sqlprep
     C                   ExSr      sflclr
     C                   ExSr      sflbld1

     *    F9 = Get Select/Sort criteria.

     C                   When      cfkey = F9
     C                   ExSr      getcriteria1
     C                   if        cfkey = Enter
     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt1
     C                   ExSr      sqlprep
     C                   ExSr      sflclr
     C                   ExSr      sflbld1
     C                   endif
     C                   eval      cfkey = Enter

     *    F12 = Cancel

     C                   When      cfkey = F12
     C                   Leave

     *    F21 = Print list.

     C                   When      cfkey = F21
     C                   exsr      printit
     C                   if        cfkey = Enter
     C                   ExSr      sqlclean
     C                   ExSr      sqlbldstmt1
     C                   ExSr      sqlprep
     C                   ExSr      sflclr
     C                   ExSr      sflbld1
     C                   eval      errmsg = 'The list is printed'
     C                   exsr      zm0105
     C                   endif
     C                   eval      cfkey = Enter

     *    PageDown = More records

     C                   When      cfkey = PageDown
     C                   ExSr      sflbld1
      *
     C                   EndSl
      *
     C                   EndDo

     C                   ExSr      sqlclean
     C                   endsr

     *----------------------------------------------------------------
     *  screen2 - Process screen 2
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                Print Processing Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  PrintIt - Print list
     *----------------------------------------------------------------

     C     printit       BegSr
     C                   eval      oldhead = schead

     * Display window to get device and form to use (Only in *DISPLAY mode)

     C                   if        $pcmd = '*DISPLAY'

     C                   exfmt     windowp

     C                   if        cfkey = F3 or cfkey = F12
     C                   goto      endprintit
     C                   endif

     C                   endif

     *  Override printer file

     C                   if        wpdev = ' '
     C                   eval      wpdev = '*JOB'
     C                   endif

     C                   if        wpform = ' '
     C                   eval      wpform = '*STD'
     C                   endif

     C                   eval      qcmd = 'OVRPRTF '
     C                                  + 'FILE(SL450PR) '
     C                                  + 'OUTQ(*DEV) '
     C                                  + 'DEV(' + %trim(wpdev) + ') '
     C                                  + 'FORMTYPE(' + %trim(wpform) + ') '

     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5

     *  Open printer file

     C                   open(e)   sl450pr
     C                   if        %error
     C                   endif

     *  Prepare SQL statment.

     C                   exsr      sqlclean
     C                   exsr      sqlbldstmt1
     C                   exsr      sqlprep

     *  Print list.

     C                   exsr      printlist

     *  Print footer

     C                   write     foot1

     *  Close printer file

     C                   close(e)  sl450pr
     C                   if        %error
     C                   endif

     *  Delete override for printer file.

     C                   eval      qcmd = 'DLTOVR '
     C                                  + 'FILE(SL450PR) '

     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5

     *  Cleanup and leave printing

     C                   ExSr      sqlclean
     C                   eval      schead = oldhead
     C                   eval      cfkey = Enter

     C     endprintit    endsr

     *----------------------------------------------------------------
     *  printlist - Print list
     *----------------------------------------------------------------

     C     printlist     BegSr

     * Process the records in the SQL cursor until the return not = 0

     C                   eval      printflag = *off
     C                   eval      lastcode = *hival
     C                   eval      *in90 = *on
     C                   eval      *in91 = *off

     C                   dow       forever = forever

     * Get the next row from the SQL cursor.

     C/EXEC SQL
     C+   FETCH NEXT FROM mycsr
500aDC*      INTO :fetchds1
500aMC+      INTO :#slwhse,:#slwhdp,:#sldisp,:#lbsdte :#lbsdtei
     C/END-EXEC

     C                   if        sqlstt = '00000'
     C                   exsr      printline
     C                   eval      printflag = *on
     C                   else
     C                   leave
     C                   endif

     C                   enddo

     * If no records were printed, Print heading.

     C                   if        not printflag
     C                   exsr      printhead
     C                   endif

     C                   endSr

     *----------------------------------------------------------------
     *  printhead - Print heading line.
     *----------------------------------------------------------------

     C     printhead     BegSr

     *  Create heading.

     C                   eval      schead  = @u + 'Id: ' + %trim($pcode)

     C                   eval      schead  = %trim(schead)
     C                                     + '   From: '
     C                                     + %trim(%editc(w1from:'Y'))

     C                   exsr      centerschead

     *  Print report heading

     C                   write     head1
     C                   if        *in91
     C                   write     head2
     C                   endif

     *  Print column heading

     C                   write     columns1

     C                   eval      *in90 = *off
     C                   eval      *in91 = *on
     C                   endsr

     *----------------------------------------------------------------
     *  printline - Print detail line.
     *----------------------------------------------------------------

     C     printline     BegSr

     *  See if heading needs to be printed.

     C                   if        *in90 or
     C                             sortorder1='CODE' and #slwhdp<>lastcode
     C                   exsr      printhead
     C                   eval      lastcode = #slwhdp
     C                   endif

500a * Initailize outer join fields if necessary.

500a C                   if        #lbsdtei < 0
500a C                   eval      #lbsdte = 0
500a C                   endif

     *  Convert check out datestamp to date/time output fields.

     *  Change value for display.
     C                   if        #lbsdte <> 0
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      #lbsdte       $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      maxdate = $cvd6o
     C                   else
     C                   eval      maxdate = 0
     C                   endif
     C**                 if        #etoxfl = '1'
     C**                 eval      #etoxfl = 'Y'
     C**                 else
     C**                 eval      #etoxfl = ' '
     C**                 endif
     C**                 if        #etixfl = '1'
     C**                 eval      #etixfl = 'Y'
     C**                 else
     C**                 eval      #etixfl = ' '
     C**                 endif


     *  Print detail line

417c C*                  select
     C*                  when      sortorder1 = 'DATE'
     C                   write     detail1
     C*                  when      sortorder1 = 'CODE'
     C*                  write     detail2
     C*                  other
417c C*                  write     detail3
     C*                  endsl

     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     Misc. Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  centerschead - Center characters in schead
     *----------------------------------------------------------------

     C     centerschead  BegSr

     C                   eval      scheadlen = %len(%trim(schead))
     C                   if        scheadlen > 0 and
     C                             scheadlen < %size(schead)
     C                   eval      scpad = %int((%size(schead)-scheadlen)/2)
     C                   eval      schead = %subst(blanks:1:scpad)
     C                                    + %trim(schead)
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  createhead1- Create subfile heading line
     *----------------------------------------------------------------

     C     createhead1   BegSr

     C**                 select


     C**                 when      sortorder1 = 'CODE'
     C                   eval      sflhead1=       '    ' + @n
     C                                      + @h + '      ' + @n
     C                                      + @h + '     ' + @n
     C                                      + @h + '      '
     C                                      + @h + '          '
     C                                      + @h + '     '
     C                                      + @h + '       '
     C                                      + @h + '         '
     C                                      + @h + '      '
     C                   eval      sflhead = @hu + 'Opt' + @n
     C                                     + @hu + 'Whse' + @n
     C                                     + @hu + 'Dept ' + @n
     C                                     + @hu + 'Display     ' + @n
     C                                     + @hu + 'Date    ' + @n


     C**                 endsl

     C                   endsr

     *----------------------------------------------------------------
     *  createhead2 - Create subfile heading line for item detail
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  createline1- Create subfile display line
     *----------------------------------------------------------------

     C     createline1   BegSr

500a * Initailize outer join fields if necessary.

500a C**                 if        #ehmetri < 0
500a C**                 eval      #ehmetr = 0
500a C**                 endif
     *  Convert check out datestamp to date/time output fields.

     *  Change value for display.
     C                   if        #lbsdte <> 0
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      #lbsdte       $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      maxdate = $cvd6o
     C                   else
     C                   eval      maxdate = 0
     C                   endif

     *  Create subfile line.

     C*                  select

     C*                  when      sortorder1 = 'DATE'
     C                   eval      h1whse = #slwhse
     C                   eval      h1code = #slwhdp
     C                   eval      h1disp = #sldisp

     C                   eval      sflline = '  '
     C                                     + %editc(#slwhse:'Z') + '   '
     C                                     + #slwhdp + '  '
     C                                     + #sldisp + '  '
     C                                     + %editc(maxdate:'Y') + '  '


     C                   endsr

     *----------------------------------------------------------------
     *  createline2 - Create subfile display line for item detail
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  getcriteria1 - Prompt user for select and sort criteria
     *----------------------------------------------------------------

     C     getcriteria1  BegSr
     C**                 move      currtimestamp datestamp

     * Display window.

     C                   if        not inzscreen1

     C                   ExFmt     window1

     C                   if        cfkey = F3 or cfkey = F12
     C                   goto      endgetc1
     C                   endif

     C                   endif

     * Set selection criteria.

     *    Convert From date into date type field.
     *    If date is invalid, set to today's date.

     C                   if        w1from = 0
     C                   eval      $fromdate = *loval
     C                   else
     C     *MDY          test(de)                w1from
     C                   if        %error
     C                   eval      $fromdate = datestamp
     C     *MDY          movel     $fromdate     w1from
     C                   else
     C     *MDY          move      w1from        $fromdate
     C                   endif
     C                   endif
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1from        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      fmcmd = $cvd8o


     *    Create screen heading.

     C                   eval      schead  = %trim(%editc(w1from:'Y'))
     C                   exsr      centerschead

     * Set sort order.

417c C*                  if        w1sort <> '1' and w1sort <> '2'
417c C*                            and w1sort <> '3'
     C*                  eval      w1sort = '1'
     C*                  endif


     C                   eval      sortorder1 = 'CODE'
     C                   eval      sc1order1 = 'SLWHSE'
     C                   eval      sc1order2 = 'SLWHDP'
     C                   eval      sc1order3 = 'SLDISP'


     C                   eval      inzscreen1 = *off
     C     endgetc1      EndSr

     *---------------------------------------------------------------
     *---------------------------------------------------------------
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *---------------------------------------------------------------
     *---------------------------------------------------------------

     *---------------------------------------------------------------
     *    ZMCPMQ  Clear program message queue.
     *---------------------------------------------------------------

     C     zmcpmq        begsr
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
     C                   exsr      zmpmsg
     C                   endsr

     *---------------------------------------------------------------
     *    ZMDMSG  Display message record subfile
     *---------------------------------------------------------------

     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   write     msgctl
     C                   endsr

     *---------------------------------------------------------------
     *    ZMPMSG  Add message record to subfile
     *---------------------------------------------------------------

     C     zmpmsg        begsr

 1B  C                   if        $msgf = *blanks
     C                   move      #msgf         $msgf
 1E  C                   endif

     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk

     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks

     C                   endsr

     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

     *---------------------------------------------------------------
     *    PIR0105 - Generic error message
     *---------------------------------------------------------------

     C     zm0105        begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      #msgdt = errmsg
     C                   exsr      zmpmsg
     C                   endsr
