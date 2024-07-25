      /copy *libl/qcopysrc,hspecs
     H dftactgrp(*NO) actgrp(*NEW)
      *****************************************************************
      *
      *  To compile:
      *
      *             CRTSQLRPGI PGM(XXX/SQL003RG) SRCFILE(XXX/QRPGLESRC)
      *
      *
      * COMPILING. In order to compile this program you will need
      *            to use options which allow it to work correctly
      *            between machines. These options are---
      *
      *               COMMIT = *NONE
      *               RDB    = Machine name that you will connect to.
      *               DLYPRP = *YES
      *               SQLPKG = The name & library that you want to
      *                        use for the package. This will put the
      *                        package on the RDB machine that you
      *                        specify.
      *****************************************************************
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  LT310     View LICACTIVE file
     *  25 February 2009
     *  Dave Sommerville
     *
     *  Revisions
     *
600 A*    02/25/09  DAS  6.00  P#00045
     *      - Created.
     *
600aA*    06/01/09  DAS  6.00a
     *      - Revised to stay on same subfile page when pressing
     *        function keys.
     *
600bA*    06/03/09  DAS  6.00b
     *      - Added license to selection criteria.
     *
600cA*    06/09/09  DAS  6.00c
     *      - Change 'Date' order into 'Fifo' order.
     *
600dA*    06/12/09  DAS  6.00d
     *      - Change field layout in subfiles to show FIFO info on
     *        first screen.
     *
600eA*    06/23/09  DAS  6.00e
     *      - Added LIKE to some sql selects.
     *
600fA*    07/01/09  DAS  6.00f
     *      - Added sql CONNECT RESET to ensure we are connected to db.
     *
610aA*    07/08/09  DAS  6.10a
     *      - Added 5=View to call LL830.
     *      - Added h1whse field.
     *      - Changed length of sflhide from 100 to 110.
     *
610bA*    07/22/09  CWM  6.10b
     *      - Added 2=Change FIFO - Call LT312
     *
610cA*    08/20/09  CWM  6.10c
     *      - Added copybook for LT312
     *
610dA*    08/21/09  DAS  6.10d
     *      - Revised to display F9 window if no parms passed in.
     *
610eA*    08/24/09  DAS  6.10e
     *      - Added command *SPECIAL and SCREEN2.
     *
610fA*    09/02/09  CWM  6.10f
     *      - Add Subfile Message processing for SC2
     *      - Add GETUSER default warehouse  for SC2
     *      - Add WHSE, DEPT and SLOT Verification for SC2.
     *
610gA*    09/04/09  CWM  6.10g
     *      - Fixed Session / Device error on READC SFL1 or SFL2.
     *        Readc conditioned on RRN1 <> 0 Changed so it was
     *        conditioned on RECPOS > 0.
     *
610hA*    09/08/09  DAS  6.10h
     *      - Added hidden option SP=Split, which will take the LP
     *        and split it off into a new virtual for the slot.
     *        Re: This was created when an import ended up putting
     *        multiple LP's into a slot instead of creating virtuals.
     *
610iA*    09/10/09  DAS  6.10i
     *      - Revised option heading.
     *      - Revised to refresh after coming back from LT312.
     *
610j *    01/15/10  GJA  6.10j
     *      - Fix:  GETUSER call was missing parameters
610j *    10/22/10  RH   6.10k
     *      - Enh:  Add 'XDK' cross dock slots to select.
     *      - Rename LT310fm to LT31002 for GUI.
650aA*    02/18/13  LMC  6.50a
     *      - Enh: Add slot item to selection screen.
     *      - Default slot item to item being passed in.
     *      - Add driitem to get the slot item for item selected.
     *      - Rename LT31002 to LT31003.
650bA*    05/03/13  LMC  6.50b
     *      - Enh: Add option 7 Fix License, similar to V1.
     *      - added CHKLIST security.
650cA*    07/17/14  KDE  6.50c
     *      - Enh: Added Production Module Slot Types
700aA*    12/06/16  LMC  7.00a
     *      - Enh: Do not allow the call to LA830 to fix the license
     *        if the license is on the RCVDOCK
700bA*    01/05/17  LMC  7.00b
     *      - Enh: Do not allow the call to LA830 to fix the license
     *        if the license is on the RTNDOCK. Returns now go to
     *        RTNDOCK instead of RCVDOCK.
     *      - Enh: Changed display file to LT31004.
720a *    01/09/19  GJA  7.20a
     *      - Enh: Add option 2 Change Fifo
730aA*    09/24/19  LMC  7.30a
     *      - Enh: Do not allow the call to LA830 to fix the license
     *        if the license is on the RWODOCK. Receipts without PO
     *        go to RWODOCK instead of RCVDOCK.
730bA*    09/27/19  LMC  7.30b
     *      - Enh: Change display file to LT31006.
750aA*    05/14/21  RH   7.50a
     *      - Enh: Add option 8 Replace License, similar to 7-fix lic
     *        Prints Item License with original license info.
     *      - added CHKLIST security.
750bA*    05/21/21  RH   7.50b
     *      - Enh: Only display option 8 if not using generic license
     *
     *----------------------------------------------------------------
CBIaA*    03/05/18  TDF  CBIaA  Work List# 2017083
     *      - If Change User is "SAPUSR" replace with user id
CBIbA*    04/23/18  TDF  CBIbA  Work List# 2016133
     *      - Add print option
     *----------------------------------------------------------------
650aA*----------------------------------------------------------------
650aA*  Binding Directories
650aA*----------------------------------------------------------------

650aAHbnddir('BFCBND')

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------
CBIaAFimpsrcvp2 if   e           k disk
     F*t310fm   cf   e             workstn
650aDF*lt31002   cf   e             workstn
700bDF*lt31003   cf   e             workstn
CBIaDF*lt31004   cf   e             workstn
730bDF*lt31005   cf   e             workstn
730bMFlt31006   cf   e             workstn
     F                                     sfile(sfl1:rrn1)
     F                                     sfile(sfl2:rrn1)
     F                                     infds(info)
610fAF                                     sfile(msgrec:msgk)

CBIaA /COPY QCOPYSRC,ID#cheney
     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

610hA /copy qcopysrc,p.drislot
      /copy qcopysrc,p.cvtdte
      /copy qcopysrc,p.cvtqty
      /copy qcopysrc,p.lt320
610cA /copy qcopysrc,p.lt312
      /copy qcopysrc,p.lp130
610aA /copy qcopysrc,p.la830
610fA /copy qcopysrc,p.getuser
610fA /copy qcopysrc,p.putmsg
650aA /copy qcopysrc,p.driitem
650bA /copy qcopysrc,p.chklist
CBIaA /copy qcopysrc,p.getclien

610hA*----------------------------------------------------------------
610hA*  DRI parameters
610hA*----------------------------------------------------------------
610hA
610hA /COPY *libl/qcopysrc,C#DRIPARMS
650aA /COPY *libl/qcopysrc,C#DRIPARMP
610hA
     *----------------------------------------------------------------
750bA*  Files
     *----------------------------------------------------------------

750b D oprec         E Ds                  Extname(opsrcvlbl)
610hA*----------------------------------------------------------------
610hA*  Data Formats
610hA*----------------------------------------------------------------
610hA
610hA /COPY *libl/qcopysrc,C#SLOT
650aA /COPY *libl/qcopysrc,C#ITEM
610hAD saveVer#        s                   like($slver#)
500cAD save$slot       s                   like($slot)


610fA*----------------------------------------------------------------
610fA*  Data structure for error message parameters
610fA*----------------------------------------------------------------
610fA
610fAD $mdt            ds
610fAD  errmsg                 1     50
610fA
610fA*----------------------------------------------------------------
610fA*  Message control
610fA*----------------------------------------------------------------
610fA
610fAD #msgf           c                   const('PIRMSGF   ')
610fA
610fAD                 ds
610fAD  #msgdt                 1    128
610fAD  $md                    1    128
610fAD                                     DIM(128)

     *----------------------------------------------------------------
     *  Display File Information Data Structure
     *----------------------------------------------------------------

     Dinfo             ds
     D cfkey                 369    369

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

415aAD blanks          s            100    inz(' ')
     D SubfilePage     C                   Const(14)

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D licactive     e ds

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  SQL fetch fields
     *----------------------------------------------------------------

     D sqlfile         c                   'LICACTIVE'
     D sqlfields       c                   '*'

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Paramerters
     *----------------------------------------------------------------

415aAD $icmd           s              8
500eMD $iwhse          s              3  0
415aAD $iwhdp          s              5
415aAD $idisp          s             12
415aAD $iitem          s             15
415aAD $idev           s             10
415aAD $iform          s             10

415aAD $pcmd           s                   like($icmd)
415aAD $pwhse          s                   like($iwhse)
415aAD $pwhdp          s                   like($iwhdp)
415aAD $pdisp          s                   like($idisp)
415aAD $pitem          s                   like($iitem)
415aAD $pdev           s                   like($idev)
415aAD $pform          s                   like($iform)

610fAD #whse           s              3  0
610fAD #emp#           s              5  0
610fAD #fnam           s             15
610fAD #init           s              1
610fAD #lnam           s             20
610fAD #whdp           s              5
610fAD #styp           s              1
610fAD #shft           s              6
610fAD #crew           s              6
610fAD #nhrs           s              3  1
610fAD #rtn            s              8
610jAD #BeltPrt        s              1
610jAD #Language       s              2

650aA*----------------------------------------------------------------
650aA*  Called program flags
650aA*----------------------------------------------------------------

650aAD driItemCalled   s               n

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

415aAD $code           s              2    inz(' ')
415aAD $count          s              8b 0 inz(0)
415aAD append1         s              1
415aAD append5         s              5
650bAD chklistrtn      s             10
CBIaAD client          s             10
CBIaAD clientloc       s             10
     D cqerm           s             60
500bAD cqqty1          s              7  0
500bAD cqqty2          s              7  0
500bAD cqqty3          s              7  0
     D cqrtn           s              8
     D cqum1           s              2
     D cqum2           s              2
     D cqum3           s              2
     D cqustr          s             17
500bAD curview         s              1  0 inz(1)
415aAD eorder1         s             20    inz(' ')
415aAD eorder2         s             20    inz(' ')
500cAD first           s               n
416aMD groupby         S            100a   inz(' ')
416aMD groupfields     S            100a   inz(' ')
415aAD iorder1         s             20    inz(' ')
415aAD iorder2         s             20    inz(' ')
     D lastrrn         s                   like(rrn1)
500bAD maxview         s              1  0 inz(2)
415aAD newordpos       s              3  0 inz(0)
610dAD noParmsPassed   s               n
     D oldhead         s                   like(schead)
     D oldname         s                   like(scrname)
     D oldopt          s                   like(scopt1)
415aAD opcode          s              6
     D optiontaken     s             10    inz(' ')
415aAD order1          s             10    inz(' ')
415aAD order2          s             10    inz(' ')
416aMD orderby         S            100a   inz(' ')
415aAD orderfield      s             10    inz(' ')
415aAD orderposition   s              3  0 inz(0)
500bAD posfld          s              5    inz(' ')
500aAD recpos          s                   like(rrn1)
415aAD scheadlen       s              3  0 inz(0)
415aAD scpad           s              3  0 inz(0)
415aAD sortorder1      s             10    inz(' ')
415aAD sortorder2      s             10    inz(' ')
415aAD sortorder3      s             10    inz(' ')
610fAD $msgf           s             10
610fAD $pmsg           s              4
610fAD $pprg           s             10
610fAD #msgid          s              7
610fAD*#msgdt          s            128
610fAD #msgtp          s              7
610fAD #pgmq           s             10
610fAD #msgk           s              4
610fAD dummy           s              1
610fAD msgk            s              4  0
610fAD sclear          s              1
610fAD wkWhse          s              3  0
610fAD wkDept          s              5
     D b               s             10  0
610hAD chk4err         s               n
610hAD zmsflag         s               n
610hAD zmflag          s               n

     *----------------------------------------------------------------
     *  Hidden subfile field
     *----------------------------------------------------------------

     D sflhide         ds
500cMD  h1lcns                 1     15
500cMD  h1olcns               16     30
500cMD  h1item                31     45
500cMD  h1whdp                46     50
500cMD  h1disp                51     62
610aAD  h1whse                63     65S 0
610hAD  h1qty1                66     70S 0
610hAD  h1qty2                71     75S 0
610hAD  h1qty3                76     80S 0
500cMD  h1base                81     92
500cMD  h1dummy              100    100
CBIaAD  h1chgeu              101    110
CBIaAD  h1chge               111    115S 0

     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
     *----------------------------------------------------------------

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
     *  Parameters
     *
     *    Input Parameters
     *      $icmd    - *DISPLAY
     *                 *PRINT
610eA*                 *SPECIAL - Choose special slot (i.e. RCV)
     *      $iwhse   - Warehouse
     *      $iwhdp   - Warehouse department
     *      $ivalue  - Value
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $icmd
     C                   parm                    $iwhse
     C                   parm                    $iwhdp
     C                   parm                    $idisp
     C                   parm                    $iitem
     C                   parm                    $idev
     C                   parm                    $iform
CBIbAC                   if        client = Cheney
CBIbAC                   eval      *in39 = *on
CBIbAC                   endif

      /free

610dA    noParmsPassed = *on;

         if %parms >= 1;
           $pcmd = $icmd;
         else;
           $pcmd = ' ';
         endif;

610dM    if %parms >= 2 and $iwhse > 0;
           $pwhse = $iwhse;
610dA      noParmsPassed = *off;
         else;
           $pwhse = 0;
         endif;

610dM    if %parms >= 3 and $iwhdp <> ' ';
           $pwhdp = $iwhdp;
610dA      noParmsPassed = *off;
         else;
           $pwhdp = ' ';
         endif;

610dM    if %parms >= 4 and $idisp <> ' ';
           $pdisp = $idisp;
610dA      noParmsPassed = *off;
         else;
           $pdisp = ' ';
         endif;

610dM    if %parms >= 5 and $iitem <> ' ';
           $pitem = $iitem;
610dA      noParmsPassed = *off;
         else;
           $pitem = ' ';
         endif;

         if %parms >= 6;
           $pdev = $idev;
         else;
           $pdev = ' ';
         endif;

         if %parms >= 7;
           $pform = $iform;
         else;
           $pform = ' ';
         endif;

      /end-free

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free
610hA
610hA    // Get default values for the user.
610hA
610hA    //getUser(#user: #whse: #emp#: #fnam: #init: #lnam: #whdp:
610hA    //         #styp: #shft: #crew: #nhrs: #rtn);
610jA    getUser(#user: #whse: #emp#: #fnam: #init: #lnam: #whdp:
610jA          #styp: #shft: #crew: #nhrs: #rtn: #BeltPrt: #Language);
610hA

600fA    // Establish the connection to the remote machine. The -842 return
600fA    // code indicates that the connection is already established. If
600fA    // you want to connect to the local machine, use CONNECT RESET.
600fA
600fA    exec sql CONNECT RESET;
600fA
600fA    If sqlstt = sqlSuccess;
600fA    endif;

         // Process main screen.

610eA    select;
610eM      when $pcmd = '*PRINT';
             exsr printit;
610eA      when $pcmd = '*SPECIAL';
610eA        exsr sc2;
610eM    other;
             exsr screen1;
610eM    endsl;

610fA    // Cleanup
610fA    exsr zsclr;

         *inlr = *on;

650aA    if driItemCalled;
650aA      driItem('%CLOSE': $pprogram: $drireturn: $drimessage:
650aA               $dridata: $dridata2);
650aA    endif;

         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *inzsr;

610fA    // Initialize message handling
610fA
610fA    error = *off;
610fA    exsr zmimsg;

CBIaA    // Get client ID

CBIaA    getclient(client: clientloc);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      SQL Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  sqlbldstmt1 - Build SQL statment
     *----------------------------------------------------------------

      /free
       begsr sqlbldstmt1;

         // Create "From" clause.

         sqlfrom = 'FROM ' + sqlfile;

         // Create "where" clause.

         sqlwhere = ' ';
         append5  = 'WHERE';

         // Warehouse

         if w1whse > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'lawhse=' + %trim(%editc(w1whse:'P'));
           append5 = ' and ';
         endif;

         // Department

         if w1whdp <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'lawhdp='
                    + sq + %trim(w1whdp) + sq;
           append5 = ' and ';
         endif;

         // Slot

         if w1slot <> '*ALL';
           if %scan('%':w1slot) > 0;
             opcode = 'LIKE';
           else;
             opcode = '=';
           endif;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + '('
                    + 'ladisp' + ' ' + %trim(opcode) + ' '
                    + sq + %trim(w1slot) + sq
                    + ')';
           append5 = ' and ';
         endif;

         //  Base Slot

         if w1base <> '*ALL';
600eA      if %scan('%':w1base) > 0;
600eA        opcode = 'LIKE';
600eA      else;
600eA        opcode = '=';
600eA      endif;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
600eM               + 'labase' + ' ' + %trim(opcode) + ' '
                    + sq + %trim(w1base) + sq;
           append5 = ' and ';
         endif;

650aM    // Slot Item

         if w1item <> '*ALL';
600eA      if %scan('%':w1item) > 0;
600eA        opcode = 'LIKE';
600eA      else;
600eA        opcode = '=';
600eA      endif;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
650aD               //+ 'laitem' + ' ' + %trim(opcode) + ' '
650aM               + 'lasitem' + ' ' + %trim(opcode) + ' '
650aD               //+ sq + %trim(w1item) + sq;
650aM               + sq + %trim($ititem) + sq;
           append5 = ' and ';
         endif;

650aA    // License Item

650aA    if w1itemL <> '*ALL';
650aA      if %scan('%':w1itemL) > 0;
650aA        opcode = 'LIKE';
650aA      else;
650aA        opcode = '=';
650aA      endif;
650aA      sqlwhere = %trimr(sqlwhere) + append5 + ' '
650aA               + 'laitem' + ' ' + %trim(opcode) + ' '
650aA               + sq + %trim(w1itemL) + sq;
650aA      append5 = ' and ';
650aA    endif;

600bA    // License
600bA
600bA    if w1lcns <> '*ALL';
600eA      if %scan('%':w1lcns) > 0;
600eA        opcode = 'LIKE';
600eA      else;
600eA        opcode = '=';
600eA      endif;
600bA      sqlwhere = %trimr(sqlwhere) + append5 + ' '
600eM               + 'lalcns' + ' ' + %trim(opcode) + ' '
600bA               + sq + %trim(w1lcns) + sq;
600bA      append5 = ' and ';
600bA    endif;

         // Create "Order By" clauses.

         select;

           when sortorder1 = 'DESCEND';
             if w1oby = '1';
               sqlorder = 'ORDER BY LALCNS DESC';
             else;
600cD          //sqlorder = 'ORDER BY LACHGUC DESC';
600cM          sqlorder = 'ORDER BY LAPRTY DESC,LAEXPD DESC,'
600cM                   + 'LAENTD DESC,LALCNS DESC';
             endif;

           other;
             if w1oby = '1';
               sqlorder = 'ORDER BY LALCNS';
             else;
600cD          //sqlorder = 'ORDER BY LACHGUC';
600cM          sqlorder = 'ORDER BY LAPRTY,LAEXPD,LAENTD,LALCNS';
             endif;

         endsl;

         // Create SQL statement.

         SqlStmt = 'SELECT '
                 + %trimr(sqlfields) + ' '
                 + %trimr(sqlfrom) + ' '
                 + %trimr(sqlwhere) + ' '
                 + sqlorder;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sqlprep - Prepare SQL cursor
     *
     *    Note: This routine must come before any other routine
     *          using an SQL statement because it declares the
     *          SQL Cursor being used.
     *----------------------------------------------------------------

      /free
       begsr sqlprep;

         // Prepare the SQL statement for validation, since the program was
         // compiled with DLYPRP (*YES), it will wait until it is used before
         // it prepares th cursor.

         exec sql PREPARE sel FROM :SqlStmt;

         sqlstt = sqlstt;

         // Declare the leavesror to hold the data retrieved from the SELECT

         exec sql DECLARE MYCSR SCROLL CURSOR FOR SEL;

         sqlstt = sqlstt;

         // Open the SQL cursor.

         exec sql OPEN MYCSR;

         sqlstt = sqlstt;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sqlclean - Clean up before exiting
     *----------------------------------------------------------------

      /free
       begsr sqlclean;

         // Close the SQL cursor after all processing is complete.

         exec sql CLOSE mycsr;

         sqlstt = sqlstt;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                    Subfile Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  sflBldDisp   Build and display subfile
     *----------------------------------------------------------------

      /free
       begsr sflBldDisp;

         exsr sqlclean;
         exsr sqlbldstmt1;
         exsr sqlprep;
         exsr sflclr;
         exsr sflbld1;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflbld1 - Build the subfile
     *----------------------------------------------------------------

      /free
       begsr sflbld1;

         rrn1 = Lastrrn;
         recpos = lastrrn;
         first = *on;

         // Process the records in the SQL cursor until the return not = 0

         for i = 1 to subfilePage;

           // Get the next row from the SQL cursor.

           exec sql FETCH NEXT FROM mycsr INTO :licactive;

           If sqlstt = sqlSuccess;
             exsr sflFill1;
             rrn1 = rrn1  + 1;
             if first;
               first = *off;
               recpos = rrn1;
             endif;
             option = ' ';
             write sfl1;
             write sfl2;
           else;
             leave;
           endif;

         endfor;

         if rrn1 = 0;
           *in32 = *on;
         else;
           lastrrn = rrn1;
         endif;

         if sqlstt = sqlNoMoreData;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflclr - Clear subfile
     *----------------------------------------------------------------

      /free
       begsr sflclr;

         // Clear the subfile

         *in31 = *on;
         write sf1ctl;
         write sf2ctl;
         *in31 = *off;
         *in32 = *off;
         rrn1 = 0;
         lastrrn = 0;
         recpos = 0;
         *in90 = *off;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflFill1  -  Fill subfile line
     *----------------------------------------------------------------

      /free
       begsr sflFill1;

         // Store hidden fields that aren't displayed on screen.

         h1lcns = lalcns;
         h1olcns = laolcns;
CBIaA    h1chge = lachgemp;
CBIaA    h1chgeu = lachgeusr;
         h1item = laitem;
         h1whdp = lawhdp;
         h1disp = ladisp;
610aA    h1whse = lawhse;
610hA    h1qty1 = laqty1;
610hA    h1qty2 = laqty2;
610hA    h1qty3 = laqty3;
610hA    h1base = labase;

         // Format quantity string

         cqqty1 = laqty1;
         cqqty2 = laqty2;
         cqqty3 = laqty3;
         cvtqty('*QTY2STR': #pgm:
                cqqty1: cqqty2: cqqty3:
                cqum1: cqum2: cqum3:
                w1qty: cqustr: cqrtn: cqerm);
         evalr w1qty = %trimr(w1qty);

600dA    // Change priority from negative to positive
600dA
600dA    w1prty = -(laprty);

         // Convert Entered date

         if laentd = 0;
           w1entd = 0;
         else;
           $cvcmd = '*CMDMDY';
           $cvd8i = %char(laentd);
           cvtdte($cvtdt);
           w1entd = $cvd6o;
         endif;

         // Convert Expiration date

         if laexpd = 0;
           w1expd = 0;
         else;
           $cvcmd = '*CMDMDY';
           $cvd8i = %char(laexpd);
           cvtdte($cvtdt);
           w1expd = $cvd6o;
         endif;
CBIaA  exsr r_name;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sfloption1 - Get entered option
     *----------------------------------------------------------------

      /free
       begsr sfloption1;

         recpos = csrrrn;

610gD    //if rrn1 = 0;
610gA    if recpos = 0;
           leavesr;
         endif;

         optiontaken = ' ';
         *in21 = *off;

         dow  forever = forever;

           select;
             when curview = 2;
               readc sfl2;
             other;
               readc sfl1;
           endsl;

           if %eof;
            leave;
           endif;

           select;

             when %trim(option) = '2';
720aA          // check to see if user has access
720aa          chklist(#prog: %trim(option): #user: chklistrtn);
720aA          if chklistrtn = '*NO ';
720aA            optiontaken = ' ';
720aA          else;
                 optiontaken = 'Change';
720aA          endif;
               recpos = rrn1;

             when %trim(option) = '5';
               optiontaken = 'View';
               recpos = rrn1;

650bA        when %trim(option) = '7';
650bA          // check to see if user has access
650ba          chklist(#prog: %trim(option): #user: chklistrtn);
650bA          if chklistrtn = '*NO ';
650bA            optiontaken = ' ';
650bA          else;
700aA            // Do not allow fix license if license is on RCVDOCK
700aA            if %subst(h1disp:1:7) = 'RCVDOCK'
730aA               or %subst(h1disp:1:7) = 'RWODOCK'
700bA               or %subst(h1disp:1:7) = 'RTNDOCK';
700aA            else;
650bA              optiontaken = 'FixLcns';
700aA            endif;
650bA          endif;
650bA          recpos = rrn1;

750aA        when %trim(option) = '8';
750aA          // check to see if user has access
750aa          chklist(#prog: %trim(option): #user: chklistrtn);
750aA          if chklistrtn = '*NO '
750aA             or opplcn = 'Y';
750aA            optiontaken = ' ';
750aA          else;
750aA            // Do not allow Replace lcn if license is on RCVDOCK
750aA            if %subst(h1disp:1:7) = 'RCVDOCK'
750aA               or %subst(h1disp:1:7) = 'RWODOCK'
700aA               or %subst(h1disp:1:7) = 'RTNDOCK';
700aA            else;
750aA              optiontaken = 'RpcLcns';
750aA            endif;
750aA          endif;
750aA          recpos = rrn1;

             when %trim(option) = '71';
               optiontaken = 'LcnsLog';
               recpos = rrn1;

             when %trim(option) = '72';
               optiontaken = 'ItemLog';
               recpos = rrn1;

             when %trim(option) = '73';
               optiontaken = 'SlotLog';
               recpos = rrn1;

             when %trim(option) = '74';
               optiontaken = 'OLcnsLog';
               recpos = rrn1;

             when %trim(option) = '75';
               optiontaken = 'LcnsInfo';
               recpos = rrn1;

610aA        when %trim(option) = 'V1';
610aA          optiontaken = 'V1';
610aA          recpos = rrn1;

610hA        when %trim(option) = 'SP';
610hA          optiontaken = 'Split';
610hA          recpos = rrn1;

           endsl;

           option = ' ';
           select;
             when curview = 2;
               update sfl2;
             other;
               update sfl1;
           endsl;

           leave;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                Screen Processing Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  screen1 - Process screen 1
     *----------------------------------------------------------------

      /free
       begsr screen1;

         // Initialize screen fields

         scrname = 'LT310.01';
         w1sort = 'A';
         w1oby = '2';
         exsr inzcriteria1;

650aA    exsr zzgetslotitem;

         exsr setcriteria1;

750b    exec sql select * into :oprec
750b         from opsrcvlbl
750b         where opwhse = :$pwhse;

750bA   if sqlstt = sqlSuccess;
650bD    //scopt1 = '2=Change fifo  5=View  ';
750aD    //scopt1 = '2=Change fifo  5=View  7=Fix License  ';
750bA     If opplcn = 'Y';
750aD        scopt1 = '2=Change fifo  5=View  7=Fix License  ';
750b      else;
750aM        scopt1 = '2=Change fifo  5=View  7=Fix License  '
                    + '8=Replace License';
750bA     endif;
750bA   endif;

610iD    //scopt1 = '5=View  '
610iD    //       = '71=Lcns hist  '
610iM    scopt2 = '71=Lcns hist  '
                + '72=Item hist  '
                + '73=Slot hist  '
                + '74=OLcns hist  '
                + '75=Lcnse Info  ';

610iD    //scopt2 = ' ';

610dA    // If no parms are passed in, display F9 window.
610dA
610dA    if noParmsPassed;
610dA      exsr getcriteria1;
610dA      if cfkey <> Enter;
610dA        leavesr;
610dA      endif;
610dA    endif;

         // Do initial build and display of subfile

         exsr sflBldDisp;

         // Process subfile until user wants to leave

         dou (cfkey = F3);

           Write fkey1;
           if recpos > 0 and recpos <= lastrrn;
             rrn1 = recpos;
           else;
             rrn1 = 1;
           endif;
           select;
             when curview = 2;
               exfmt sf2ctl;
             other;
               exfmt sf1ctl;
           endsl;

600aA      recpos = csrrrn;

           Select;

             // Enter

             When cfkey = Enter;
               ExSr sfloption1;

               select;

                  when optiontaken = 'Change';
610bA               lt312('*CHANGE': h1Whse: h1lcns);
610iA               exsr sflBldDisp;

                  when optiontaken = 'View';
610aA               la830('*VIEW': h1whse: h1lcns);

610aA             when optiontaken = 'V1';
610aA               la830(' ': h1whse: h1lcns);
610aA               exsr sflBldDisp;

650bA             when optiontaken = 'FixLcns';
650bA               la830('*FIXLCNS': h1whse: h1lcns);
650bA               exsr sflBldDisp;

750aA             when optiontaken = 'RpcLcns';
750aA               la830('*RPCLCNS': h1whse: h1lcns);
750aA               exsr sflBldDisp;

                  when optiontaken = 'LcnsLog';
                    lt320('*VIEW': lawhse: ' ': ' ': ' ':
                          h1lcns: 0: ' ': ' ');

                  when optiontaken = 'ItemLog';
                    lt320('*VIEW': lawhse: ' ': ' ': h1item:
                          ' ': 0: ' ': ' ');

                  when optiontaken = 'SlotLog';
                    lt320('*VIEW': lawhse: h1whdp: h1disp: ' ':
                          ' ': 0: ' ': ' ');

610hA             when optiontaken = 'Split';
610hA               exsr split;
610hA               exsr sflBldDisp;

                  when optiontaken = 'OLcnsLog';
                    lt320('*VIEW': lawhse: ' ': ' ': ' ':
                          h1olcns: 0: ' ': ' ');

                  when optiontaken = 'LcnsInfo';
                    lp130('*NOOPT': h1lcns);

               endsl;

             // F5 = Refresh

             when cfkey = F5;
               exsr sflBldDisp;
               cfkey = Enter;

             // F9 = Get Select/Sort criteria.

             when cfkey = F9;
               exsr getcriteria1;
               if cfkey = Enter;
                 exsr sflBldDisp;
               endif;
               cfkey = Enter;

             // F10 = Previous view.

             when cfkey = F10;
               if curview <= 1;
                 curview = maxview;
               else;
                 curview = curview - 1;
               endif;
               cfkey = Enter;

             // F11 = Next view

             When cfkey = F11;
               if curview >= maxview;
                 curview = 1;
               else;
                 curview = curview + 1;
               endif;
               cfkey = Enter;

             // F12 = Cancel

             when cfkey = F12;
               leave;

             // PageDown = More records

             When cfkey = PageDown;
               exsr sflbld1;

           EndSl;

         EndDo;

         ExSr sqlclean;

       endsr;
      /end-free

610eA*----------------------------------------------------------------
610eA*  sc2 - Process screen 2
610eA*----------------------------------------------------------------
610eA
610eA /free
610eA  begsr sc2;

         // Initialize screen fields

         exsr sc2Init;

         // Process subfile until user wants to leave

         dou (cfkey = F3);

610fA      // Set ON alarm indicator if error occured
610fA
610fA      if error = *on;
610fA        *in98 = *on;
610fA      endIf;
610fA
610fA      // Overlay screen with error messages
610fA
610fA      exsr zmdmsg;

           exfmt screen2;

CBIbA      exsr prtlist;

610fA      *in98 = *off;
610fA      *in22 = *off;
610fA      *in23 = *off;
610fA      *in24 = *off;
610fA      exsr zmcmsg;

           Select;

             // Enter

             When cfkey = Enter;
               exsr sc2vfy;
               if error;
                 iter;
               endif;

               $pwhse = w2whse;
               $pwhdp = w2whdp;
               $pdisp = w2type + '%';
610dA          noParmsPassed = *off;
               exsr screen1;
               leave;

             // F5 = Refresh

             when cfkey = F5;
               exsr sc2init;
               cfkey = Enter;

             // F12 = Cancel

             when cfkey = F12;
               leave;

           EndSl;

         EndDo;


       endsr;
      /end-free

610eA*----------------------------------------------------------------
610eA*  sc2init - Initialize screen2 fields.
610eA*----------------------------------------------------------------
610eA
610eA /free
610eA  begsr sc2init;

610fA    error = *off;
610fA    exsr zmimsg;
610fA
610fA    // Get default values for the user.
610fA
610fA    //getUser(#user: #whse: #emp#: #fnam: #init: #lnam: #whdp:
610fA    //         #styp: #shft: #crew: #nhrs: #rtn);
610jA    getUser(#user: #whse: #emp#: #fnam: #init: #lnam: #whdp:
610jA          #styp: #shft: #crew: #nhrs: #rtn: #BeltPrt: #Language);
610fA
610fA    w2whse = #whse;

610fD    //w2whse = 0;
         w2whdp = '*ALL';
         w2type = ' ';

       endsr;
      /end-free

610eA*----------------------------------------------------------------
610eA*  sc2vfy  - Verify screen2 fields.
610eA*----------------------------------------------------------------
610eA
610eA /free

610eA  begsr sc2vfy;

         error = *off;
         msgk = *zero;

         // Verify warehouse

610fA    exec sql
610fA      select whcode into :wkwhse
610fA      from warehs
610fA      where whcode = :w2whse;

610fA    if sqlstt <> sqlSuccess;
610fA      error = *on;
610fA      *in22 = *on;
610fA      errmsg = 'Invalid Warehouse entered';
610fA      exsr zm0105;
610fA    endIf;

         // Verify department

610fA    if w2whdp <> '*ALL';
610fA      exec sql
610fA        select wdcode into :wkdept
610fA        from whdept
610fA        where wdcode = :w2whdp and wdwhse = :w2whse;

610fA      if sqlstt <> sqlSuccess;
610fA        error = *on;
610fA        *in23 = *on;
610fA        errmsg = 'Invalid Department entered';
610fA        exsr zm0105;
610fA      endIf;
610fA    endIf;

         // Verify slot type

         if w2type <> 'RCV'
700bA      and w2type <> 'RTN'
730aA      and w2type <> 'RWO'
           and w2type <> 'STG'
           and w2type <> 'OSS'
           and w2type <> 'USR'
610k       and w2type <> 'XDK'
650c       and w2type <> 'PRD'
650c       and w2type <> 'WIP'
650c       and w2type <> 'LIN'
650c       and w2type <> 'PAR';
             error = *on;
610fA        *in24 = *on;
610fA        errmsg = 'Invalid slot type entered';
610fA        exsr zm0105;
         endif;

       endsr;

      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                Print Processing Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  printit - Print list
     *----------------------------------------------------------------

      /free
       begsr printit;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  printlist - Print list
     *----------------------------------------------------------------

      /free
       begsr printlist;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  printhead - Print heading line
     *----------------------------------------------------------------

      /free
       begsr printhead;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  printline - Print detail line
     *----------------------------------------------------------------

      /free
       begsr printline;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     Misc. Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  centerschead - Center characters in schead
     *----------------------------------------------------------------

      /free
       begsr centerschead;

         scheadlen = %len(%trim(schead));
         if scheadlen > 0
            and scheadlen < %size(schead);
              scpad = %int((%size(schead)-scheadlen)/2);
              schead = %subst(blanks:1:scpad)
                     + %trim(schead);
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getcriteria1 - Prompt user for select and sort criteria
     *----------------------------------------------------------------

      /free
       begsr getcriteria1;

         // Display window.

         exfmt window1;

         if cfkey = F3 or cfkey = F12;
           leavesr;
         endif;

650aA    // get slot item
650aA    exsr zzgetslotitem;
         // Set selection criteria.

         exsr setcriteria1;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  inzcriteria1 - Initialize criteria 1 values.
     *----------------------------------------------------------------

      /free
       begsr inzcriteria1;

         if $pwhse = 0;
           w1whse = 0;
         else;
           w1whse = $pwhse;
         endif;

         if $pwhdp = ' ';
           w1whdp = '*ALL';
         else;
           w1whdp = $pwhdp;
         endif;

         if $pdisp = ' ';
           w1slot = '*ALL';
         else;
           w1slot = $pdisp;
         endif;

         if $pitem = ' ';
           w1item = '*ALL';
         else;
           w1item = $pitem;
         endif;

         w1base = '*ALL';

600bA    w1lcns = '*ALL';
650aA    w1itemL= '*ALL';

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  setcriteria1 - Set criteria 1 values.
     *----------------------------------------------------------------

      /free
       begsr setcriteria1;

         // Set sort order

         if w1sort <> 'A' and w1sort <> 'D';
           w1sort = 'A';
         endif;

         if w1oby <> '1' and w1oby <> '2';
           w1oby = '2';
         endif;

         select;

           when w1sort = 'D';
             sortorder1 = 'DESCEND';

           other;
             sortorder1 = 'ASCEND';

         endsl;

         // Create screen heading.

         schead = ' ';
         append1 = ' ';

         if w1sort = 'D';
           schead = %trimr(schead) + append1
                  + 'Descend';
           append1 = ',';
         else;
           schead = %trimr(schead) + append1
                  + 'Ascend';
           append1 = ',';
         endif;

         if w1oby = '2';
           schead = %trimr(schead) + append1
                  + 'By FIFO';
           append1 = ',';
         else;
           schead = %trimr(schead) + append1
                  + 'By Lcns';
           append1 = ',';
         endif;

         if w1whdp <> '*ALL';
           schead = %trimr(schead) + append1
                  + 'Dept=' + %trim(w1whdp);
           append1 = ',';
         endif;

         if w1slot <> '*ALL';
           schead = %trimr(schead) + append1
                  + 'Slot=' + %trim(w1slot);
           append1 = ',';
         endif;

         if w1base <> '*ALL';
           schead = %trimr(schead) + append1
                  + 'Base=' + %trim(w1base);
           append1 = ',';
         endif;

         if w1item <> '*ALL';
           schead = %trimr(schead) + append1
                  + 'Item=' + %trim(w1item);
           append1 = ',';
         endif;

600bA    if w1lcns <> '*ALL';
600bA      schead = %trimr(schead) + append1
600bA             + 'Lcns=' + %trim(w1lcns);
600bA      append1 = ',';
600bA    endif;

         if append1 = ' ';
           schead = %trimr(schead) + ',Everything';
         endif;

         exsr centerschead;

       endsr;
      /end-free

610hA*----------------------------------------------------------------
610hA*  split  -  Split LP into new virtual slot for base slot
610hA*----------------------------------------------------------------
610hA
610hA /free
610hA  begsr split;

         // Not allowd for * LP's
         if %subst(h1lcns:1:1) = '*';
           errmsg = 'SP not allowed for license '
               + %trim(h1lcns);
           exsr zm0105;
           leavesr;
         endif;

         // Transfer license to USR slot.
         exsr clr$slot;
         $slwhseu = *on;
         $slwhse  = h1whse;
         $slwhdpu = *on;
         $slwhdp  = h1whdp;
         $sldispu = *on;
         $sldisp  = h1disp;
         $saitemu = *on;
         $saitem  = h1item;

         $saqtyu = *on;
         $saqty1 = h1qty1;
         $saqty2 = h1qty2;
         $saqty3 = h1qty3;

         $saActionU = *on;
         $saAction = 'SPL';
         $saETrn#U = *on;
         $saETrn# = 0;
         $saToLcnsU = *on;
         $saToLcns = h1lcns;
         $saToPosU = *on;
         $saToPos = 1;
         $saToVrfyU = *on;
         $saToVrfy = 'N';
         $saToCodeu = *on;
         $saToCode = 'U';
         $saToAreaU = *on;
         $saToArea = 'User';
         $saOLcnsU = *on;
         $saOLcns = h1olcns;

         $dricommand = '*SLOT';
         $drisubcmd  = '%TFR2USR';
         $drisys2upd = 'D';
         chk4err = *on;
         zmflag = *off;
         exsr zzzdricop;
         if error;
           errmsg = 'Error transfering '
               + %trim(h1lcns)
               + ' to USR slot';
           exsr zm0105;
           exsr zm0001;
           leavesr;
         endif;

         // Transfer license back into slot.
         $sacwhdu = *on;
         $sacwhd  = $slwhdp;
         $sacdspu = *on;
         $sacdsp  = $sldisp;
         $sacitemu = *on;
         $sacitem  = $slitem;

         $slwhseu = *on;
         $slwhse  = h1whse;
         $slwhdpu = *on;
         $slwhdp  = h1whdp;
         $sldispu = *on;
         $sldisp  = h1base;
         $saitemu = *on;
         $saitem  = h1item;

         $saqtyu = *on;
         $saqty1 = h1qty1;
         $saqty2 = h1qty2;
         $saqty3 = h1qty3;

         $saActionU = *on;
         $saAction = 'SPL';
         $saETrn#U = *on;
         $saETrn# = 0;
         $saToLcnsU = *on;
         $saToLcns = h1lcns;
         $saToPosU = *on;
         $saToPos = 1;
         $saToVrfyU = *on;
         $saToVrfy = 'N';
         $saToCodeu = *on;
         $saToCode = 'U';
         $saToAreaU = *on;
         $saToArea = 'User';
         $saOLcnsU = *on;
         $saOLcns = h1olcns;

         $dricommand = '*SLOT';
         $drisubcmd  = '%USR2PUT';
         $drisys2upd = 'D';
         chk4err = *on;
         zmflag = *off;
         exsr zzzdricop;
         if error;
           errmsg = 'Error transfering '
               + %trim(h1lcns)
               + ' back to '
               + %trim(h1disp);
           exsr zm0105;
           exsr zm0001;
           leavesr;
         endif;

       endsr;
      /end-free

610fA*---------------------------------------------------------------
610fA*  SUBROUTINE ZMxxxx  Control message display subfile
610fA*---------------------------------------------------------------
610fa
610fA*---------------------------------------------------------------
610fA*    ZMCMSG  Clear message record subfile
610fA*---------------------------------------------------------------
610fA
610fA /free
610fA  begsr zmcmsg;

         *in97 = *off;
         write  msgctl;
         msgk = *zeros;
         write  msgclr;
         #msgid = '*CLEAR ';
         #msgtp = '*NULL  ';
         exsr  zmpmsg;

       endsr;
      /end-free

610fA*---------------------------------------------------------------
610fA*    ZMDMSG  Display message record subfile
610fA*---------------------------------------------------------------
610fA
610fA /free
610fA  begsr zmdmsg;

         *in97 = *on;
         if  msgk > 0;
           write  msgctl;
           msgk = *zeros;
         endif;

       endsr;
      /end-free

610fA*---------------------------------------------------------------
610fA*    ZMIMSG  Initialization necessary for message subfile
610fA*---------------------------------------------------------------
610fA
610fA /free
610fA  begsr zmimsg;

         #pgmq = #prog;
         exsr  zmcmsg;

       endsr;
      /end-free

610fA*---------------------------------------------------------------
610fA*    ZMPMSG  Add message record to subfile
610fA*---------------------------------------------------------------
610fA
610fA /free
610fA  begsr zmpmsg;

         if $msgf = *blanks;
           $msgf = #msgf;
         endif;

         putmsg($msgf: #msgid: #msgtp: #msgdt: #pgmq: #msgk);

         if #msgid <> '*CLEAR ';
           msgk += 1;
           write  msgrec;
         endif;

         #msgdt = *blanks;
         #msgk = *blanks;

       endsr;
      /end-free

610fA*---------------------------------------------------------------
610fA*    ZMQMSG  Add message record to subfile from program queue
610fA*---------------------------------------------------------------
610fA
610fA /free
610fA  begsr zmqmsg;

         msgk = msgk + 1;
         write  msgrec;

       endsr;
      /end-free

610fA*---------------------------------------------------------------
610fA*    ZSCLR   Clear screen
610fA*---------------------------------------------------------------
610fA
610fA /free
       begsr zsclr;

         write  clrscr;
         sclear = *on;

       endsr;
      /end-free

610fA*---------------------------------------------------------------
610fA*    ZMSMSG  Send program message to a different program msgq
610fA*---------------------------------------------------------------
610fA
610fA /free
610fA  begsr zmsmsg;

         if $msgf = *blanks;
           $msgf = #msgf;
         endif;

         putmsg($msgf: #msgid: #msgtp: #msgdt: #pgmq: #msgk);
         #msgdt = *blanks;
         $msgf = *blanks;

       endsr;
      /end-free

610fA*----------------------------------------------------------------
610fA*    ZMnnnn  Build and send message nnnn to this program
610fA*----------------------------------------------------------------
610fA
610hA*----------------------------------------------------------------
610hA*    DRI0001  Local system caused error
610hA*----------------------------------------------------------------
610hA
      /free
610hA  begsr zm0001;

         if %subst($drimessage:1:2) = 'H:';
           #msgid = 'DRI0002';
           $drimessage = %subst($drimessage:3);
         else;
           #msgid = 'DRI0001';
         endif;
         #msgtp = '*DIAG';
         #msgdt = $drimessage + $drireturn
             + $dricommand + $drisubcmd;
         exsr zmpmsg;

       endsr;
      /end-free

610fA  //----------------------------------------------------------------
610fA*      0105
610fA*----------------------------------------------------------------
610fA
610fA /free
610fA  begsr zm0105;

         #msgid = 'PIR0105';
         #msgtp = '*DIAG  ';
         #msgdt = errmsg;
         exsr zmpmsg;

       endsr;
      /end-free

500hA*----------------------------------------------------------------
500hA*----------------------------------------------------------------
500hA*                     DRI SUBROUTINES
500hA*----------------------------------------------------------------
500hA*----------------------------------------------------------------


500hA*----------------------------------------------------------------
500hA*  clr$slot  Clear $slot data structure fields
500hA*----------------------------------------------------------------
500hA
500hAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = #emp#
     C                   endsr

500hA*----------------------------------------------------------------
500hA*  zzzdricop  Call DRICOP
500hA*----------------------------------------------------------------
500hA
500hAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
600dAC                   eval      $dridata2 = $slot2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
600dAC                             or $dricommand = '*SLOT'
600dAC                             or $dricommand = '*LICENSE'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      chk4err and %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
600dAC                   select
600dAC                   when      zmsflag
     C**                 exsr      zm0105s
600dAC                   when      zmflag
     C                   exsr      zm0105
600dAC                   endsl

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
600dAC                   select
600dAC                   when      zmsflag
     C**                 exsr      zm0001s
600dAC                   when      zmflag
     C                   exsr      zm0001
     C**                 exsr      zzerrind
600dAC                   endsl

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
600dAC                   eval      $slot2 = $dridata2
     C                   endsl

600dAC                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

650aA*----------------------------------------------------------------
650aA*
650aA*  ZZGETSLOTITEM - Get slot item.
650aA*
650aA*----------------------------------------------------------------
650aA /free
650aA  begsr zzgetslotitem;

         //exsr clr$item;
         error = *off;

         savever# = $itver#;
         clear $item;
         clear $item2;
         $itver# = savever#;

         $itWhse = $pwhse;
         $ititem = w1item;
         $dridata = $item;
         $dridata2 = $item2;

         driItemCalled = *on;
         driItem('%GETSLOT': $pprogram: $drireturn: $drimessage:
                  $dridata: $dridata2);
         $item = $dridata;
         $item2 = $dridata2;


650aA  endsr;
650aA /end-free
CBIaA*----------------------------------------------------------------
CBIaA*
CBIaA*  R_NAME - If Change User is "SAPUSR" replace with user id
CBIaA*
CBIaA*----------------------------------------------------------------
CBIaAcsr   r_name        begsr
CBIaAc     impkey        klist
CBIaAc                   kfld                    rcpwhse
CBIaAc                   kfld                    rcpstatus
CBIaAc                   kfld                    rcplcns
CBIaAC                   if        client = Cheney
CBIaAC                               and w2type = 'RCV'
CBIaAC                   movel     h1chgeu       check6            6
CBIaAC*---
CBIaAc*    h1chge        chain     usrec                              38
CBIaAc*                  if        *in38 = *off
CBIaAc*                  movel     uscode        lachgeusr
CBIaAc*                  endif
CBIaAC*--- Chain to IMPSRCVP2 to get receiver
CBIaAc                   eval      rcpwhse   = h1whse
CBIaAc                   eval      rcpstatus = 'S'
CBIaAc                   eval      rcplcns   = h1lcns
CBIaAc     impkey        chain     rcprec                             38
CBIaAc                   if        *in38 = *off
CBIaAc                   movel     RCPUSR        lachgeusr
CBIaAc                   endif
CBIaAC*---
CBIaAC                   endif
CBIaAcsr                 endsr
CBIbA*----------------------------------------------------------------
CBIbA*
CBIbA*  prtlist - print list
CBIbA*
CBIbA*----------------------------------------------------------------
CBIbAcsr   prtlist       begsr
CBIbAC                   if        client = Cheney
CBIbAc     *in40         cabeq     *on           eprint
CBIbAC                   if        *in39 = *on
CBIbAC                                and w2prt <> *blanks
CBIbAC                   move      '001'         pwhse             3
CBIbAC                   call      'LT310PCL'
CBIbAC                   parm                    pwhse
CBIbAC                   parm                    w2type
CBIbAC                   parm                    w2prt
CBIbAC                   eval      *in40 = *on
CBIbAC                   endif
CBIbAC                   endif
CBIbAcsr   eprint        endsr
