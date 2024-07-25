      /copy *libl/qcopysrc,hspecs
600fAH dftactgrp(*NO) actgrp(*NEW)
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
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  HA300     HACCP Log file display/print/export
     *  24 April 2012
     *  Lynn McMahon
     *
     *  Revisions
     *
640 A*    04/24/12  LMC  6.40
     *      - Created.
     *
640aA*    11/08/12  LMC  6.40b
     *      - Added time stamp to display and printout
650aA*    01/02/13  LMC  6.50a
     *      - Enh: Added selection by Vendor#/Customer#
650bA*    03/07/13  LMC  6.50b
     *      - Enh: inzcriteria1 if *PRINT is sent from another program
650cA*    04/16/13  LMC  6.50c
     *      - Enh - Quantity Exception reporting - parms sent in.
650dA*    07/03/13  LMC  6.50d
     *      - Enh - Added user from log file to display and print
650eA*    09/11/13  LMC  6.50e
     *      - Enh - Added logic to pull Dev/Forms from file REPORTS
     *      (RP110CL).
650fA*    11/04/13  LMC  6.50f
     *      - Enh - Added Printer override ability when using F21
     *      to print from the log display
650gA*    03/31/14  LMC  6.50g
     *      - Enh - Added ability to select equipment and display
     *      equipment name on the heading line in the subfile.
700aA*    04/15/16  LMC  7.00a
     *      - Enh - Make the display file usropn, so we can call
     *      the print from gui.
710a *    02/17/17  GJA  7.10a
     *      - Enh - Added ability to print by department
720a *    05/09/18  LMC  7.20a
     *      - Recompile only - Databases changes.
730a *    09/10/19  LMC  7.30a
     *      - Do not allow the user to print everything. Reports are
     *        way too long.
740a *    05/18/20  LMC  7.40a
     *      - Do not show hlobsolete = 'H'. Hidden child questions.
750a *    04/14/21  LMC  7.50a
     *      - Adding item description if Item and no license.
     *      - if there is a license, there is no room currently to
     *        add the item description. Very few clients do pcm at
     *        the license level. So this should work for now.
     *
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')


     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

650aDF*ha300fm   cf   e             workstn
650gDF*ha30001   cf   e             workstn
700aDF*ha30002   cf   e             workstn
700aMFha30002   cf   e             workstn usropn
     F                                     sfile(sfl1:rrn1)
     F                                     infds(info)
     F                                     sfile(msgrec:msgk)
     Fha300pr   O    E             printer usropn
     F                                     oflind(*IN90)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.cvtdte
      /copy qcopysrc,p.putmsg
      /copy qcopysrc,p.lt320
      /copy qcopysrc,p.lp130
600fA /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')

     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  Display File Information Data Structure
     *----------------------------------------------------------------

     Dinfo             ds
     D cfkey                 369    369

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     D blanks          s            100    inz(' ')
     D SubfilePage     C                   Const(12)

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D fetchds         ds
     D   #fwhse                            like(hlwhse)
     D   #fseq#                            like(hlseq#)
     D   #flevl                            like(hllevl)
     D   #ftype                            like(hltype)
     D   #fdata                            like(hldata)
     D   #fpo                              like(hlpo)
     D   #fname                            like(hlname)
     D   #fposeq                           like(hlposeq)
     D   #flcns                            like(hllcns)
     D   #fitem                            like(hlitem)
     D   #faddts                           like(hladdts)
     D   #fqstn                            like(hiqstn)
     D   #ftabl                            like(hitabl)
     D   #fuctl                            like(hbuctl)
     D   #fdesc                            like(hbdesc)
     D   #fvsq#                            like(hlvsq#)
     D   #fwarn                            like(hlwarn)
     D   #fsid                             like(hlsid)
     D   #fobsolete                        like(hlobsolete)
650aAD   #fhlcust                          like(hlcust)
650dAD   #fladdeusr                        like(hladdeusr)
     D fetchdshdr      ds
     D   #hwhse                            like(hlwhse)
     D   #hseq#                            like(hlseq#)
     D   #hlevl                            like(hllevl)
     D   #htype                            like(hltype)
     D   #hdata                            like(hldata)
     D   #hpo                              like(hlpo)
     D   #hname                            like(hlname)
     D   #hposeq                           like(hlposeq)
     D   #hlcns                            like(hllcns)
     D   #hitem                            like(hlitem)
     D   #haddts                           like(hladdts)
     D   #hqstn                            like(hiqstn)
     D   #htabl                            like(hitabl)
     D   #huctl                            like(hbuctl)
     D   #hdesc                            like(hbdesc)
     D   #hvsq#                            like(hlvsq#)
     D   #hwarn                            like(hlwarn)
     D   #hsid                             like(hlsid)
     D   #hobsolete                        like(hlobsolete)
650aAD   #hhlcust                          like(hlcust)
650dAD   #hladdeusr                        like(hladdeusr)
     D haccplog      e ds
     D Haccpq        e ds
     D Haccpqt       e ds

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

     D sqlfile         c                   'HACCPLOG'
     D sqlfile1        c                   'HACCPQ   '
     D sqlfile2        c                   'HACCPQT  '
     D sqlfields       c                   'hlwhse,hlseq#,hllevl,+
     D                                      hltype,hldata,hlpo,+
     D                                      hlname,hlposeq,hllcns,+
     D                                      hlitem,hladdts,hiqstn,+
     D                                      hitabl,hbuctl,hbdesc,+
     D                                      hlvsq#,hlwarn,hlsid,+
650aDD*                                     hlobsolete'
650dDD*                                     hlobsolete,hlcust'
650dMD                                      hlobsolete,hlcust,hladdeusr'
     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D cktabl          pr                  extpgm(#FTABL)
      * Input
     D   pparm                       80

     D cktablh         pr                  extpgm(#hTABL)
      * Input
     D   pparm                       80

     D hb900           pr                  extpgm('HB900')
      * Input
     D   pparm                       80

     D getwhse         pr                  extpgm('GETWHSE')
      * Input
     D   puser                        8    const
     D   pWhse                        3  0 const

     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *   Redefine key
     *
     D  $ltbldata             19     38
     D  $lwhse                19     21  0
     d  $llevl                22     25
     D  $ltype                26     28
     D  $lusrctl              65     65
     *----------------------------------------------------------------
     *  Paramerters
     *----------------------------------------------------------------

     D $icmd           s              8
650cDD*$iwhse          s              3  0
650cMD $iwhse          s             15  5
650dAD $gwhse          s              3  0
     D $ipo            s              9
     D $iitem          s             15
650cAD $ilevl          s              4
     D $idev           s             10
     D $iform          s             10

     D $pcmd           s                   like($icmd)
     D $pwhse          s                   like($iwhse)
     D $ppo            s                   like($ipo)
     D $pitem          s                   like($iitem)
     D $pdev           s                   like($idev)
     D $pform          s                   like($iform)
650cAD $plevl          s                   like($ilevl)

     D #whse           s              3  0
     D #emp#           s              5  0
     D #fnam           s             15
     D #init           s              1
     D #lnam           s             20
     D #whdp           s              5
     D #styp           s              1
     D #nhrs           s              3  1
     D #rtn            s              8
     D #BeltPrt        s              1
     D #Language       s              2

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D*$code           s              2    inz(' ')
     D*$count          s              8b 0 inz(0)
     D append1         s              1
     D append5         s              5
     D cqerm           s             60
     D cqustr          s             17
     D dateonly        s             10
     D timecurr        s              8
     D timeonly        s              8
     D datecurr        s             19
     D datetime        s             19
     D fa              s              2  0
     D foundanswer     s              2  0
     D first           s               n
640bAD hms             s              6  0
     D holddate        s               d
     D holdinfo        s             76
     D lastrrn         s                   like(rrn1)
     D lrtnCode        s             20
     D*maxview         s              1  0 inz(4)
     D*newordpos       s              3  0 inz(0)
     D noParmsPassed   s               n
     D*oldhead         s                   like(schead)
     D*oldname         s                   like(scrname)
     D*oldopt          s                   like(scopt1)
     D*opcode          s              6
     D optiontaken     s             10    inz(' ')
     D order1          s             10    inz(' ')
     D order2          s             10    inz(' ')
     D orderby         S            100a   inz(' ')
     D orderfield      s             10    inz(' ')
     D*orderposition   s              3  0 inz(0)
     D*posfld          s              5    inz(' ')
     D printflag       s               n
     D recpos          s                   like(rrn1)
     D rtnCode         s             10
     D rtnMessage      s            200
     D save#fpo        s                   like(#fpo)
     D saveinfo        s             76
650fAD savef21         s                   like(cfkey)
     D scheadlen       s              3  0 inz(0)
     D scpad           s              3  0 inz(0)
     D sortorder1      s             10    inz(' ')
     D*sortorder2      s             10    inz(' ')
     D*sortorder3      s             10    inz(' ')
     D $dtetme         s               z
     D $msgf           s             10
     D $pmsg           s              4
     D $pprg           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D #msgk           s              4
     D dummy           s              1
     D msgk            s              4  0
     D sclear          s              1
750aDD*wkdesc          s             30
750aMD wkdesc          s             28
     D wkdesc1         s             30
     D wkRte           s              5
     D wkWhse          s              3  0
     D b               s             10  0
     D chk4err         s               n
     D zmsflag         s               n
     D zmflag          s               n
     D*cure            s               n

600fA*----------------------------------------------------------------
600fA*  Time variables
600fA*----------------------------------------------------------------
600fA
600fAD CurrStamploc    s               z
600fAD CurrStampsys    s               z
600fAD CurrStampuc     s               z
600fA
600fAD bfcoffset       s              3  0 inz(0)
     *----------------------------------------------------------------
     *  Hidden subfile field
     *----------------------------------------------------------------

     D sflhide         ds
     D  h1lcns                 1     15
     D  h1item                31     45

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
     *      $icmd    - *SPECIAL
     *                 *PRINT
     *      $iwhse   - Warehouse
     *      $ipo     - PO#
     *      $iitem   - Item#
     *      $idev    - Printer device
     *      $iform   - Form type
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
     C                   parm                    $ipo
     C                   parm                    $iitem
650cAC                   parm                    $ilevl
710aAC                   parm                    $idev

      /free

         noParmsPassed = *on;

         if %parms >= 1;
           $pcmd = $icmd;
         else;
           $pcmd = ' ';
         endif;

         if %parms >= 2  and $iwhse > 0;
           $pwhse = $iwhse;
           noParmsPassed = *off;
         else;
650dD      //getwhse(#user:$pwhse);
650dM      getwhse(#user:$gwhse);
650dA      $pwhse = $gwhse;
         endif;

         if %parms >= 3 and $ipo <> ' ';
           $ppo   = $ipo;
           noParmsPassed = *off;
         else;
           $ppo   = ' ';
         endif;


         if %parms >= 4 and $iitem <> ' ';
           $pitem   = $iitem;
           noParmsPassed = *off;
         else;
           $pitem   = ' ';
         endif;

650cA    if %parms >= 5 and $ilevl <> ' ';
650cA      $plevl   = $ilevl;
650cA      noParmsPassed = *off;
650cA    else;
650cA      $plevl   = ' ';
650cA    endif;

      /end-free

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         // Establish the connection to the remote machine. The -842 return
         // code indicates that the connection is already established. If
         // you want to connect to the local machine, use CONNECT RESET.

         exec sql CONNECT RESET;

         If sqlstt = sqlSuccess;
         endif;

         // Process main screen.

         select;
           when $pcmd = '*PRINT';
650bA        exsr inzcriteria1;
             exsr printit;
         other;
             exsr screen1;
         endsl;

         // Cleanup
700aA    if $jtype = *on;
           exsr zsclr;
700aA    endif;

         *inlr = *on;

         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *inzsr;
         // Initialize message handling

         error = *off;
         //wkcount = 0;
700aA /end-free
700aAC                   call      'GETJTYPE'
700aAC                   parm                    $jtype            1
700aA*
700aA*   Open display file if this program is being run interactively.
700aA*
700aAC                   if        $jtype = *on
700aAC                   open      ha30002
700aAC                   endif
700aA*
700aA*  Initialize message handling
700aA*
700aAC                   if        $jtype = *on
700aAC                   exsr      zmimsg
700aAC                   endif
700aA /free
700aD    //exsr zmimsg;

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

         // Create "Inner join" clause.

         sqljoin = 'INNER JOIN ' + sqlfile1 + ' ' +
                    'ON ' + 'hiwhse=hlwhse and hiseq#=hlseq#';


         sqljoin2 = 'INNER JOIN ' + sqlfile2 + ' ' +
                    'ON ' + 'hlwhse=hbwhse and hltype=hbtype  +
                             and hllevl=hblevl';


         // Create "where" clause.

         sqlwhere = ' ';
         append5  = 'WHERE';

         // obsolete records excluded

         sqlwhere = %trimr(sqlwhere) + append5 + ' '
                  + 'hlobsolete <>'
                    + sq + 'Y' + sq;
         append5 = ' and ';
740aA    sqlwhere = %trimr(sqlwhere) + append5 + ' '
740aA             + 'hlobsolete <>'
740aA               + sq + 'H' + sq;
740aA    append5 = ' and ';
         // Warehouse

         if w1whse > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'hlwhse=' + %trim(%editc(w1whse:'P'));
           append5 = ' and ';
         endif;

         // po

         if w1po   <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'hlpo  ='
                    + sq + %trim(w1po) + sq;
           append5 = ' and ';
         endif;

         // item

         if w1item <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'hlitem ='
                    + sq + %trim(w1item) + sq;
           append5 = ' and ';
         endif;

650aA    // Vendor#/Customer#

650aA    if w1hlcust > 0;
650aA      sqlwhere = %trimr(sqlwhere) + append5 + ' '
650aA               + 'hlcust=' + %trim(%editc(w1hlcust:'P'));
650aA      append5 = ' and ';
650aA    endif;

         // warning overridden

         if w1warn <> ' ';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'hlwarn ='
                    + sq + %trim(w1warn) + sq;
           append5 = ' and ';
         endif;

         // From Date Selection

         if w1fdte > 0;
           $cvcmd = '*MDYCMD ';
           $cvd6i = %trimr(%editc(w1fdte:'X'));
           cvtdte ($cvtdt);
           holddate = %date($cvd8o);
           $dtetme= %timestamp(%char(holddate) +
                      '-00.00.00.000000');
           sqlwhere = %trim(sqlwhere) + append5 + ' '
                    + 'hladdts >='
                    + sq + %char($dtetme) + sq;
           append5 = ' and ';
         endif;
         // To Date Selection
         if w1tdte > 0;
           $cvcmd = '*MDYCMD ';
           $cvd6i = %trimr(%editc(w1tdte:'X'));
           cvtdte ($cvtdt);
           holddate = %date($cvd8o);
           $dtetme= %timestamp(%char(holddate) +
                      '-24.00.00.000000');
           sqlwhere = %trim(sqlwhere) + append5 + ' '
                    + 'hladdts <='
                    + sq + %char($dtetme) + sq;
           append5 = ' and ';
         endif;

650cA    // exception reporting
650cA    if $plevl <> ' ';
650cA      sqlwhere = %trimr(sqlwhere) + append5 + ' '
650cA               + 'hllevl ='
650cA               + sq + %trim($plevl) + sq;
650cA      append5 = ' and ';
650cA    endif;

         // Level/Type

650cA    // if exception reporting - do not allow this selection
650cA    if $plevl =  ' ';
           if w1levl <> ' ';
             sqlwhere = %trimr(sqlwhere) + append5 + ' '
                      + 'hllevl ='
                      + sq + %trim(w1levl) + sq;
             append5 = ' and ';
             sqlwhere = %trimr(sqlwhere) + append5 + ' '
                      + 'hltype ='
                      + sq + %trim(w1type) + sq;
             append5 = ' and ';
650gA        // we are storing equipment in th po field in the file
650gA        if w1eq   <> '*ALL';
650gA          sqlwhere = %trimr(sqlwhere) + append5 + ' '
650gA                   + 'hlpo  ='
650gA                   + sq + %trim(w1eq) + sq;
650gA          append5 = ' and ';
650gA        endif;
           else;
             sqlwhere = %trimr(sqlwhere) + append5 + ' '
                      + 'hbuctl <>'
                      + sq + 'Y' + sq;
             append5 = ' and ';
           endif;
650cA    endif;

         // Create "Order By" clauses.

         select;
           when w1levl <> ' ';
             sqlorder = 'ORDER BY hlwhse,hlsid,hladdts';

           other;
               //sqlorder = 'ORDER BY hlwhse,hlpo,hlposeq,hllcns';
               sqlorder = 'ORDER BY hlwhse,hlsid,hlpo,hlposeq,hllcns';

         endsl;

         // Create SQL statement.

         SqlStmt = 'SELECT '
                 + %trimr(sqlfields) + ' '
                 + %trimr(sqlfrom) + ' '
                 + %trimr(sqljoin) + ' '
                 + %trimr(sqljoin2) + ' '
                 + %trimr(sqlwhere) + ' '
                 + sqlorder;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sqlbldstmt2 - Build SQL statment
     *----------------------------------------------------------------

      /free
       begsr sqlbldstmt2;

         // Create "From" clause.

         sqlfrom = 'FROM ' + sqlfile;

         // Create "Inner join" clause.

         sqljoin = 'INNER JOIN ' + sqlfile1 + ' ' +
                    'ON ' + 'hiwhse=hlwhse and hiseq#=hlseq#';


         sqljoin2 = 'INNER JOIN ' + sqlfile2 + ' ' +
                    'ON ' + 'hlwhse=hbwhse and hltype=hbtype  +
                             and hllevl=hblevl';


         // Create "where" clause.

         sqlwhere = ' ';
         append5  = 'WHERE';

         // exclude obsolete
         sqlwhere = %trimr(sqlwhere) + append5 + ' '
                  + 'hlobsolete <>'
                    + sq + 'Y' + sq;
         append5 = ' and ';

         // Warehouse

         if w1whse > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'hlwhse=' + %trim(%editc(w1whse:'P'));
           append5 = ' and ';
         endif;

         // po

         if w1po   <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'hlpo  ='
                    + sq + %trim(w1po) + sq;
           append5 = ' and ';
         endif;

         // item

         if w1item <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'hlitem ='
                    + sq + ' ' + sq;
           append5 = ' and ';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'hlpo ='
                    + sq + %trim(#fpo) + sq;
           append5 = ' and ';
         endif;

650aA    // Vendor#/Customer#

650aA    if w1hlcust > 0;
650aA      sqlwhere = %trimr(sqlwhere) + append5 + ' '
650aA               + 'hlcust=' + %trim(%editc(w1hlcust:'P'));
650aA      append5 = ' and ';
650aA    endif;

         // From Date Selection

         if w1fdte > 0;
           $cvcmd = '*MDYCMD ';
           $cvd6i = %trimr(%editc(w1fdte:'X'));
           cvtdte ($cvtdt);
           holddate = %date($cvd8o);
           $dtetme= %timestamp(%char(holddate) +
                      '-00.00.00.000000');
           sqlwhere = %trim(sqlwhere) + append5 + ' '
                    + 'hladdts >='
                    + sq + %char($dtetme) + sq;
           append5 = ' and ';
         endif;
         // To Date Selection
         if w1tdte > 0;
           $cvcmd = '*MDYCMD ';
           $cvd6i = %trimr(%editc(w1tdte:'X'));
           cvtdte ($cvtdt);
           holddate = %date($cvd8o);
           $dtetme= %timestamp(%char(holddate) +
                      '-24.00.00.000000');
           sqlwhere = %trim(sqlwhere) + append5 + ' '
                    + 'hladdts <='
                    + sq + %char($dtetme) + sq;
           append5 = ' and ';
         endif;

         // Level/Type

         if w1levl <> ' ';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'hllevl ='
                    + sq + %trim(w1levl) + sq;
           append5 = ' and ';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'hltype ='
                    + sq + %trim(w1type) + sq;
           append5 = ' and ';
650gA      if w1eq   <> '*ALL';
650gA        sqlwhere = %trimr(sqlwhere) + append5 + ' '
650gA                 + 'hlpo  ='
650gA                 + sq + %trim(w1eq) + sq;
650gA        append5 = ' and ';
650gA      endif;
650gA
         else;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'hbuctl <>'
                    + sq + 'Y' + sq;
           append5 = ' and ';
         endif;

         // Create "Order By" clauses.

         select;

           when sortorder1 = 'DESCEND';

           other;
               sqlorder = 'ORDER BY hlwhse,hlpo,hlposeq,hllcns';

         endsl;

         // Create SQL statement.

         SqlStmt = 'SELECT '
                 + %trimr(sqlfields) + ' '
                 + %trimr(sqlfrom) + ' '
                 + %trimr(sqljoin) + ' '
                 + %trimr(sqljoin2) + ' '
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
         // it prepares the cursor.

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
     *  sqlprep2- Prepare SQL cursor
     *
     *    Note: This routine must come before any other routine
     *          using an SQL statement because it declares the
     *          SQL Cursor being used.
     *----------------------------------------------------------------

      /free
       begsr sqlprep2;

         // Prepare the SQL statement for validation, since the program was
         // compiled with DLYPRP (*YES), it will wait until it is used before
         // it prepares the cursor.

         exec sql PREPARE sel1 FROM :SqlStmt;

         sqlstt = sqlstt;

         // Declare the leavesror to hold the data retrieved from the SELECT

         exec sql DECLARE MYCSR1 SCROLL CURSOR FOR SEL1;

         sqlstt = sqlstt;

         // Open the SQL cursor.

         exec sql OPEN MYCSR1;

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
     *  sqlclean2 - Clean up before exiting
     *----------------------------------------------------------------

      /free
       begsr sqlclean2;

         // Close the SQL cursor after all processing is complete.

         exec sql CLOSE mycsr1;

         sqlstt = sqlstt;

       endsr;
      /end-free

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

           exec sql FETCH NEXT FROM mycsr INTO :fetchds;

           If sqlstt = sqlSuccess;
             exsr sflFill1;
             // load only if answer was found, or answer not selected
             if w1answer <> ' ' and foundanswer <> 0 or w1answer = ' ';
               rrn1 = rrn1  + 1;
               if first;
                 first = *off;
                 recpos = rrn1;
               endif;
               option = ' ';
               write sfl1;
             endif;
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
           *in84 = *on;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflbld2 - Build the header portion of report
     *----------------------------------------------------------------

      /free
       begsr sflbld2;

         recpos = lastrrn;
         first = *on;

         // Process the records in the SQL cursor until the return not = 0

         dou sqlstt <> sqlsuccess;

           // Get the next row from the SQL cursor.

           exec sql FETCH NEXT FROM mycsr1 INTO :fetchdshdr;

           If sqlstt = sqlSuccess;
             exsr zzfill2;
             write detail1;
           else;
             leave;
           endif;

         enddo;



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
         *in31 = *off;
         *in32 = *off;
         rrn1 = 0;
         lastrrn = 0;
         recpos = 0;
         *in84 = *off;

         saveinfo = ' ';
         holdinfo = ' ';
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflFill1  -  Fill subfile line
     *----------------------------------------------------------------

      /free
       begsr sflFill1;

         // Get Item Description
         wkdesc = ' ';
         if #fitem <> ' ';
           exec sql
             select itdesc into :wkdesc
             from piritem
             where itwhse = :#fwhse and ititem = :#fitem;
         endif;
         // Get value Description
         wkdesc1 = ' ';
         if #fvsq# <> 0;
           exec sql
             select hvdesc into :wkdesc1
             from haccpv
             where hvwhse = :#fwhse and hvseq# = :#fseq# and
                   hvvsq# = :#fvsq#;
         endif;
         // Selection on Answer
         foundanswer = 0;
         if w1answer <> ' ';

           fa = %scan(' ' :w1answer);
           if fa = 0;
             fa = 30;
           endif;
           foundanswer = %scan((%subst(w1answer:1:fa-1)):#fdata);
           if foundanswer = 0;
             // check the value description field also
             foundanswer = %scan((%subst(w1answer:1:fa-1)):wkdesc1);
           endif;
         endif;
         if w1answer <> ' ' and foundanswer = 0;
           leavesr;
         endif;

         // build information line
         datetime = %char(#fsid);
         dateonly = %subst(datetime:1:10);
         timeonly = %subst(datetime:12:8);
         select;
           when w1type <> ' ';
650dD        //saveinfo = dateonly + ' ' + timeonly + ' ' + %trim(#fdesc);
650gD      //saveinfo = dateonly + ' ' + timeonly + ' ' + %trim(#fdesc) +
650gM        saveinfo = dateonly + ' ' + timeonly + ' ' + (#fdesc)      +
650gA          ' ' + (#fpo) +
650gD        //'                                           ' + #fladdeusr;
650gM          '           ' + #fladdeusr;
           when #fitem = ' ';
             saveinfo = dateonly + ' ' +
650dD                   //(#fpo) + ' ' + #fname;
650dM                   (#fpo) + ' ' + #fname +
650dA                    '     ' + #fladdeusr;
750aA      when #fitem <> ' 'and #flcns = ' ' and
750aA           %Subst(#fitem:1:4) <> 'Dept';
750aA        saveinfo =  dateonly + ' ' +(#fpo) + ' '
750aA                 +  (#fitem) + '-'
750aA                 + (wkdesc) + ' ' + #fladdeusr;
           when #fitem <> ' ';
             saveinfo =  dateonly + ' ' +(#fpo) + ' ' + #fitem + ' '
                      //+ wkdesc + ' ' + #flcns;
650dD                 //+  #flcns;
650dM                 +  #flcns + '              ' + #fladdeusr;
         endsl;
         //endif;
         // when displaying need special heading lines writte to subfile
         select;
           when  $pcmd = '*PRINT' or
                  cfkey = F21;
           if saveinfo <> holdinfo;
             w1info = saveinfo;
             holdinfo = saveinfo;
             eval i = i+1;
             if first;
               first = *off;
             endif;
             exsr printline1;
           else;
             w1info = ' ';
           endif;
         other;
           if saveinfo <> holdinfo;
             w1info = saveinfo;
             holdinfo = saveinfo;
             h1lcns = #flcns;
             h1item = #fitem;
             *in92 = *off;
             h1sv92 = *in92;
             eval i = i+1;
             rrn1 = rrn1  + 1;
             if first;
               first = *off;
               recpos = rrn1;
             endif;
             option = ' ';
             write sfl1;
             // need heading at the begining of the display screen
             if rrn1 = 12;
               w1info = saveinfo;
               *in92 = *off;
               h1sv92 = *in92;
               eval i = i+1;
               rrn1 = rrn1  + 1;
               if first;
                 first = *off;
                 recpos = rrn1;
               endif;
               option = ' ';
               write sfl1;
             endif;
           else;
             w1info = ' ';
             *in92 = *on;
           endif;
         endsl;
         // build question/answer
         *in92 = *on;
         h1lcns = #flcns;
         h1item = #fitem;
640bA    hms = %dec(%time(#faddts):*hms);
640bA    if w1type <> ' ';
           w1info = %trim(#fqstn)
                  + '? '
                  + %trim(#fdata)
                  + ' '
                  + %trim(wkdesc1);
640bA    else;
640bA      w1info = %trimr(%editw(hms:'  :  :  '))
640bA             + '  '
640bA             + %trim(#fqstn)
640bA             + '? '
640bA             + %trim(#fdata)
640bA             + ' '
640bA             + %trim(wkdesc1);
640bA    endif;
         // if table validation - get actual answer - code is stored only
         // except on US900 it has the correct answer stored
         if #ftabl <> ' ' and #ftabl <> 'US900';
           $lcmd = '*VERIFY ';
           $ltbldata = #fdata;
           ckTABL($lparm);
           if $lerm <> ' ';
640bA        if w1type <> ' ';
               w1info = %trim(#fqstn)
                    + '? '
                    + %trim($lerm);
640bA        else;
640bA        w1info = %trimr(%editw(hms:'  :  :  '))
640bA             + '  '
640bA             + %trim(#fqstn)
640bA               + '? '
640bA               + %trim($lerm);
640bA        endif;
           endif;

         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sfloption1 - Get entered option
     *----------------------------------------------------------------

      /free
       begsr sfloption1;

         recpos = csrrrn;

         if recpos = 0;
           leavesr;
         endif;

         optiontaken = ' ';
         *in21 = *off;

         dow  forever = forever;

           readc sfl1;

           if %eof;
            leave;
           endif;

           select;

             when %trim(option) = '12';
               optiontaken = 'ItemDetail';
               recpos = rrn1;

             when %trim(option) = '71' and h1lcns <> ' ';
               optiontaken = 'LcnsLog';
               recpos = rrn1;

             when %trim(option) = '72' and h1item <> ' ';
               optiontaken = 'ItemLog';
               recpos = rrn1;

             when %trim(option) = '75' and h1lcns <> ' ';
               optiontaken = 'LcnsInfo';
               recpos = rrn1;

           endsl;

           option = ' ';
           *in92 = h1sv92;
           update sfl1;

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

         scrname = 'HA300.01';
         exsr inzcriteria1;

         exsr setcriteria1;

         scopt1 = '71=Lcns hist  72=Item hist  75=Lcnse Info';
         scopt2 = ' ';

         // If no parms are passed in, display F9 window.

         if noParmsPassed;
           exsr getcriteria1;
           if cfkey <> Enter;
             leavesr;
           endif;
         endif;

         // Do initial build and display of subfile

         exsr sflBldDisp;

         // Process subfile until user wants to leave

         dou (cfkey = F3);

           Write fkey1;
           Write mkey1;
           if recpos > 0 and recpos <= lastrrn;
             rrn1 = recpos;
           else;
             rrn1 = 1;
           endif;
           exfmt sf1ctl;

           recpos = csrrrn;

           Select;

             // Enter

             When cfkey = Enter;
               ExSr sfloption1;

               select;
                  when optiontaken = 'LcnsLog';
                    lt320('*VIEW': $pwhse: ' ': ' ': ' ':
                          h1lcns: 0: ' ': ' ');

                  when optiontaken = 'ItemLog';
                    lt320('*VIEW': $pwhse: ' ': ' ': h1item:
                          ' ': 0: ' ': ' ');

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



             // F12 = Cancel

             when cfkey = F12;
               leave;

             // F21 = Print

             when cfkey = F21;
               exsr printit;

             // PageDown = More records

             When cfkey = PageDown;
               exsr sflbld1;

           EndSl;

         EndDo;

         ExSr sqlclean;

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
         exsr zzgettime;
         holdinfo = ' ';
         wpdev = $pdev;
         wpform = $pform;

         exsr setcriteria1;
730aA    if append1 = ' ';
730aA    else;
         exsr printlist;
730aA    endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  printlist - Print list
     *----------------------------------------------------------------

      /free
       begsr printlist;

         exsr sqlclean;
         exsr sqlbldstmt1;
         exsr sqlprep;
         exsr setupPrint;

650fD    //exsr prtRprt;


       endsr;
      /end-free

     *----------------------------------------------------------------
     *  printhead - Print heading line
     *----------------------------------------------------------------

      /free
       begsr printhead;

        // Print report heading
         write head1;

         // Print Column Headings
         write columns1;

         *in90 = *off;
         *in91 = *on;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  printline - Print detail line
     *----------------------------------------------------------------

      /free
       begsr printline;

         // See if heading needs to be printed.

         if *in90;
           exsr printhead;
         endif;

        // Print detail line

         write detail1;
         printflag = *on;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  printline1 - Print detail line 1
     *----------------------------------------------------------------

      /free
       begsr printline1;

         // See if heading needs to be printed.

         if *in90;
           exsr printhead;
         else;
         // Print Column Headings
         write skip1;
         write columns1;
         endif;

        // Print detail line

         write detailchg;
         printflag = *on;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  prtRprt -  Print the Report
     *----------------------------------------------------------------

      /free

       begsr prtRprt;

         *in90 = *on;
         // Open printer file.

         open(e)   ha300pr;
         if %error;
           $pcmd = $pcmd;
         endif;

         // Process the records in the SQL cursor until the return not = 0

         dou 1 <> 1;

           // Get the next row from the SQL cursor.

           exec sql FETCH NEXT FROM mycsr INTO :fetchds;

           If sqlstt = sqlSuccess;
             if save#fpo  <> #fpo and w1item <> '*ALL';
               exsr sqlclean2;
               exsr sqlbldstmt2;
               exsr sqlprep2;
               exsr sflbld2;
               save#fpo  = #fpo;
             endif;
             exsr sflFill1;

             if first;
               exsr printhead;
               first = *off;
               exsr printline;
               else;
               if w1answer <> ' ' and foundanswer <> 0 or w1answer = ' ';
                 exsr printline;
               endif;
             endif;
           else;
             leave;
             endif;

         enddo;

         if sqlstt = sqlNoMoreData;
         endif;

          if        not printflag;
            exsr      printhead;
            else;
            write foot1;
          endif;

         // Close printer file.

         close(e)   ha300pr;
         if %error;
         endif;

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
     *  inzcriteria1 - Initialize criteria 1 values.
     *----------------------------------------------------------------

      /free
       begsr inzcriteria1;

         if $pwhse = 0;
           w1whse = 0;
         else;
           w1whse = $pwhse;
         endif;

         if $ppo  = ' ';
           w1po  = '*ALL';
         else;
           w1po  = $ppo;
         endif;

         if $pitem = ' ';
           w1item  = '*ALL';
         else;
           w1item  = $pitem;
         endif;

650gA    w1eq  = '*ALL';

         w1rte  = '*ALL';

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  setcriteria1 - Set criteria 1 values.
     *----------------------------------------------------------------

      /free
       begsr setcriteria1;

         select;

           other;
             sortorder1 = 'ASCEND';

         endsl;

         // Create screen heading.

         schead = ' ';
         append1 = ' ';
         subhead = ' ';

650cA    if $plevl <> ' ';
650cA      schead = %trimr(schead) + append1
650cA             + 'Qty Exceptions';
650cA      append1 = ',';
650cA    endif;

         if w1po <> '*ALL';
           schead = %trimr(schead) + append1
640aM             + 'PO#=' + %trim(w1po);
           append1 = ',';
         endif;

650gA    if w1eq <> '*ALL';
650gA      schead = %trimr(schead) + append1
650gA             + 'Equipment' + %trim(w1eq);
650gA      append1 = ',';
650gA    endif;
650gA
         if w1rte <> '*ALL';
           schead = %trimr(schead) + append1
640aM             + 'Route#=' + %trim(w1rte);
           append1 = ',';
         endif;

         if w1item <> '*ALL';
           schead = %trimr(schead) + append1
640aM             + 'Item=' + %trim(w1item);
           append1 = ',';
         endif;

650aA    if w1hlcust <> 0;
650aA      schead = %trimr(schead) + append1
650aA             + 'Vendor=' + %trim(%editc(w1hlcust:'Z'));
650aA      append1 = ',';
650aA    endif;

         if w1fdte <> 0 and w1tdte = 0;
           schead = %trimr(schead) + append1
640aM             + 'Date=' + %trim(%editc(w1fdte:'Y')) + '-today';
           append1 = ',';
         endif;

         if w1fdte <> 0 and w1tdte <> 0;
           schead = %trimr(schead) + append1
640aM             + 'Date=' + %trim(%editc(w1fdte:'Y')) + '-'
640aM             + %trim(%editc(w1tdte:'Y'));
           append1 = ',';
         endif;

         // heading for user types
         if w1levl <> ' ';
           schead = %trimr(schead) + append1
640aM             + 'Type=' + %trim(w1levl) + ' '
640aM             + %trim(w1type);
           append1 = ',';
         endif;
         if append1 = ' ';
           schead = %trimr(schead) + 'Everything';
         endif;

         exsr centerschead;

         if w1levl <> ' ';
650dD      //subhead = 'Date       Time     Question/Answer';
650dM      subhead = 'Date       Time     Question/Answer' +
650dA       '                               User';
         else;
           subhead = 'Date       +
                      PO#       Item            +
650dD                 //License';
650dM                 License                      User';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getcriteria1 - Prompt user for select and sort criteria
     *----------------------------------------------------------------

      /free
       begsr getcriteria1;

         // Display window.

         holdinfo = ' ';
         exfmt window1;

         if cfkey = F3 or cfkey = F12;
           leavesr;
         endif;

         // prompt for level/type for random
         if cfkey = F4;
           $lcmd = '*SELECT ';
           $lwhse = w1whse;
           $lusrctl = 'Y';
           hb900($lparm);
           if $lrtn = '*SELECT ';
             w1levl = $llevl;
             w1type = $ltype;
           endif;
           cfkey = Enter;
         endif;

         // Set selection criteria.

         exsr setcriteria1;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZGETTIME Get Timestamp information.
     *
     *----------------------------------------------------------------
      /free
       begsr zzgettime;
         getmicrotime(currstampuc:currstampsys);
         datecurr = %char(currstampsys);
         timecurr = %subst(datecurr:12:8);
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzfill2   -  Fill header info for printout
      *----------------------------------------------------------------

      /free
       begsr zzfill2;


         // build information line
         wkdesc = ' ';
         datetime = %char(#hsid);
         dateonly = %subst(datetime:1:10);
         timeonly = %subst(datetime:12:8);
         select;
           when w1type <> ' ';
             //dateonly = %char(#fsid);
             //saveinfo = dateonly + ' ' + %trim(#fdesc);
650dD      //saveinfo = dateonly + ' ' + timeonly + ' ' + %trim(#fdesc);
650gD      //saveinfo = dateonly + ' ' + timeonly + ' ' + %trim(#fdesc)
650gM        saveinfo = dateonly + ' ' + timeonly + ' ' + (#fdesc)
650gA        + ' ' + (#fpo)
650gD      //+ '                                           ' + #fladdeusr;
650gM        + '           ' + #fladdeusr;
           when #hitem = ' ';
             //saveinfo = (#hpo) + ' ' + #hname;
             saveinfo = dateonly + ' ' +
650dD                   //(#hpo) + ' ' + #fname;
650dM                   (#hpo) + ' ' + #fname +
650dA                    '     ' + #fladdeusr;
           when #hitem <> ' ';
             //saveinfo = (#hpo) + ' ' + #hitem + ' '
                      //+ wkdesc + ' ' + #hlcns;
             saveinfo =  dateonly + ' ' +(#hpo) + ' ' + #fitem + ' '
                      //+ wkdesc + ' ' + #hlcns;
650dD                 //+ #hlcns;
650dM                 + #hlcns + '              ' + #hladdeusr;
         endsl;
         //if w1type <> ' ';
           //dateonly = %char(#hsid);
           //saveinfo = dateonly;
         //else;
           //saveinfo = (#hpo) + ' ' + #hitem + ' '
                    //+ wkdesc + ' ' + #hlcns;
         //endif;
         // when displaying need special heading lines writte to subfile
           if saveinfo <> holdinfo;
             w1info = saveinfo;
             holdinfo = saveinfo;
             eval i = i+1;
             if first;
               first = *off;
             endif;
             exsr printline1;
           else;
             w1info = ' ';
           endif;
         // build question/answer
         *in92 = *on;
640bA    if w1type <> ' ';
           w1info = %trim(#hqstn)
                  + '? '
                  + %trim(#hdata);
640bA    else;
640bA      w1info = %trimr(%editw(hms:'  :  :  '))
640bA             + '  '
640bA             + %trim(#hqstn)
640bA             + '? '
640bA             + %trim(#hdata);
640bA    endif;
         // if table validation - get actual answer - code is stored only
         // except on US900 it has the correct answer stored
         if #htabl <> ' ' and #htabl <> 'US900';
           $lcmd = '*VERIFY ';
           $ltbldata = #hdata;
           ckTABLh($lparm);
           if $lerm <> ' ';
640bA        if w1type <> ' ';
               w1info = %trim(#hqstn)
                      + '? '
                      + %trim($lerm);
640bA        else;
640bA          w1info = %trimr(%editw(hms:'  :  :  '))
640bA                 + '  '
640bA                 + %trim(#hqstn)
640bA                 + '? '
640bA                 + %trim($lerm);
640bA        endif;
           endif;

         endif;

       endsr;
      /end-free

     *---------------------------------------------------------------
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *---------------------------------------------------------------

     *---------------------------------------------------------------
     *    ZMCMSG  Clear message record subfile
     *---------------------------------------------------------------

      /free
       begsr zmcmsg;

         *in97 = *off;
         write  msgctl;
         msgk = *zeros;
         write  msgclr;
         #msgid = '*CLEAR ';
         #msgtp = '*NULL  ';
         exsr  zmpmsg;

       endsr;
      /end-free

     *---------------------------------------------------------------
     *    ZMDMSG  Display message record subfile
     *---------------------------------------------------------------

      /free
       begsr zmdmsg;

         *in97 = *on;
         if  msgk > 0;
           write  msgctl;
           msgk = *zeros;
         endif;

       endsr;
      /end-free

     *---------------------------------------------------------------
     *    ZMIMSG  Initialization necessary for message subfile
     *---------------------------------------------------------------

      /free
       begsr zmimsg;

         #pgmq = #prog;
         exsr  zmcmsg;

       endsr;
      /end-free

     *---------------------------------------------------------------
     *    ZMPMSG  Add message record to subfile
     *---------------------------------------------------------------

      /free
       begsr zmpmsg;

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

     *---------------------------------------------------------------
     *    ZMQMSG  Add message record to subfile from program queue
     *---------------------------------------------------------------

      /free
       begsr zmqmsg;

         msgk = msgk + 1;
         write  msgrec;

       endsr;
      /end-free

     *---------------------------------------------------------------
     *    ZSCLR   Clear screen
     *---------------------------------------------------------------

      /free
       begsr zsclr;

         write  clrscr;
         sclear = *on;

       endsr;
      /end-free

     *---------------------------------------------------------------
     *    ZMSMSG  Send program message to a different program msgq
     *---------------------------------------------------------------

      /free
       begsr zmsmsg;

         if $msgf = *blanks;
           $msgf = #msgf;
         endif;

         putmsg($msgf: #msgid: #msgtp: #msgdt: #pgmq: #msgk);
         #msgdt = *blanks;
         $msgf = *blanks;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *      PIR0105  Generic message id.
     *----------------------------------------------------------------

      /free
       begsr zm0105;

         #msgid = 'PIR0105';
         #msgtp = '*DIAG  ';
         #msgdt = errmsg;
         exsr zmpmsg;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *      PIR9906  Invalid date entered.
     *----------------------------------------------------------------

      /free
       begsr zm9906;

         #msgid = 'PIR9906';
         #msgtp = '*DIAG  ';
         #msgdt = errmsg;
         exsr zmpmsg;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  setupPrint - Setup Report
     *----------------------------------------------------------------

      /free
       begsr setupPrint;

710aA    if %parms >= 6 and $idev <> ' ';
710aA      wpform = '*STD';
710aA      wpdev  = $idev;
710aA    else;
         // Load device and form if not loaded.
650eA      exec sql
650eA        select rpdev, rpform
650eA        into :wpdev, :wpform
650eA        from reports
650eA        where rpprtf = 'HA300PR';

         if wpdev = ' ';
           wpdev = '*JOB';
         endif;

         if wpform = ' ';
           wpform = '*STD';
         endif;

710aA    endif;
         //  Display window to get device and form to use (Only in *DISPLAY mode

650fD    //if $pcmd = '*VIEW';
650fM    if $pcmd = ' ';
650fA      savef21 = cfkey;
           exfmt windowp;
650fA      w1msg1 = ' ';
         endif;

         if cfkey <> F3 and cfkey <> F12;

650fA      cfkey = savef21;
           // Override printer file.
             w1msg1 = 'Report has been printed';
             *in55 = *on;

           if wpdev = ' ';
             wpdev = '*JOB';
           endif;

           if wpform = ' ';
             wpform = '*STD';
           endif;

           qcmd = 'OVRPRTF '
                + 'FILE(HA300PR) '
                + 'OUTQ(*DEV) '
                + 'DEV(' + %trim(wpdev) + ') '
                + 'FORMTYPE(' + %trim(wpform) + ') ';

      /end-free
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
      /free

650fA      exsr prtRprt;
         endif;

         first = *on;
         printflag = *off;

       endsr;

      /end-free
     *----------------------------------------------------------------
