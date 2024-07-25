      /copy *libl/qcopysrc,hspecs
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
     *  GETASN    Get/Update Birite ASN Data
     *  01 August 2012
     *  Lynn McMahon
     *
     *  Revisions
     *
640aA*    08/01/12  LMC  6.40a
     *      - Created.
     *
650aA*    03/17/15  LMC  6.50a
     *      - Changed display file to be user controlled.
     *        GUI PO receiving - for Deleting a Transaction.
     *
700aA*    03/21/15  LMC  7.00a
     *      - Enh - New command *CHKASN - To check to see if we
     *        have an ASN for the purchase order being received.
     *      - Enh - Renamed display file to GETASN01.
     *      - Enh - New command *GETLOTS - when receipt has multiple
     *        lots - need each lot/quantity/weight for licinfo.
740 A*    07/14/20  KDE  7.40
     *      - Enh - Use additional fields in query select for PUTLCNS
     *        if sent
     *      - Change sql loop to use forever dow loop
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

700aDF*Getasnfm  cf   e             workstn
700aMFGetasn01  cf   e             workstn usropn
     F                                     sfile(sfl1:rrn1)
     F                                     infds(info)
     F                                     sfile(msgrec:msgk)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.cvtdte
      /copy qcopysrc,p.getuser
      /copy qcopysrc,p.putmsg

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     D  erdate                 1      6  0

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
     D SubfilePage     C                   Const(14)

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D poasn         e ds

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

     D sqlfile         c                   'POASN'
     D sqlfields       c                   '*'

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D $icmd           s              8
     D $irtn           s              8
     D $iwhse          s              3  0
     D $ipo            s              9
     D $ilpn           s             50
     D $ilcns          s             15
     D $ilot           s             20
     D $iitem          s             15
     D $iseq           s              5  0
     D $iqty           s              8  0
     D $imfgdt         s              6  0
     D $imfgexp        s              6  0
     D $iwgt           s             11  3
     D $iupc           s             21

     D $pcmd           s                   like($icmd)
     D $prtn           s                   like($irtn)
     D $pwhse          s                   like($iwhse)
     D $ppo            s                   like($ipo )
     D $plpn           s                   like($ilpn)
     D $plcns          s                   like($ilcns)
     D $pitem          s                   like($iitem)
     D $pseq           s                   like($iseq)
740 Ad $plot           s                   like($ilot)
740 Ad $pmfgdt         s              8  0
740 Ad $pmfgexp        s              8  0

     D #whse           s              3  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $code           s              2    inz(' ')
     D append1         s              1
     D append5         s              5
     D count           s              5p 0
700aAD countInd        s              2b 0
     D curview         s              1  0 inz(1)
     D eorder1         s             20    inz(' ')
     D eorder2         s             20    inz(' ')
     D first           s               n
     D groupby         S            100a   inz(' ')
     D groupfields     S            100a   inz(' ')
     D iorder1         s             20    inz(' ')
     D iorder2         s             20    inz(' ')
     D lastrrn         s                   like(rrn1)
     D maxview         s              1  0 inz(2)
     D newordpos       s              3  0 inz(0)
     D noParmsPassed   s               n
     D opcode          s              6
     D optiontaken     s             10    inz(' ')
     D order1          s             10    inz(' ')
     D order2          s             10    inz(' ')
     D orderby         S            100a   inz(' ')
     D orderfield      s             10    inz(' ')
     D orderposition   s              3  0 inz(0)
700aAD pcsInd          s              2b 0
     D posfld          s              5    inz(' ')
     D recpos          s                   like(rrn1)
     D rtnCode         s             10
     D rtnMessage      s            200
700aAD savepo          s                   like(papo)
700aAD savewhse        s                   like(pawhse)
700aAD savelpn         s                   like(palpn)
700aAD saveitem        s                   like(paitem)
700aAD saveseq         s                   like(paseq)
700aAD savemfgdt       s                   like(pamfgdt)
700aAD savemfgexp      s                   like(pamfgexp)
     D scheadlen       s              3  0 inz(0)
     D scpad           s              3  0 inz(0)
     D sortorder1      s             10    inz(' ')
     D sortorder2      s             10    inz(' ')
     D sortorder3      s             10    inz(' ')
700aAD sumcount        s              5p 0
700aAD wgtind          s              2b 0
     D $imfgdt8        s              8  0
     D $imfgexp8       s              8  0
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
     D wkRte           s              5
     D wkDlvd          s              8  0
     D wkSrd           s              8  0
     D wkWhse          s              3  0
     D b               s             10  0
     D chk4err         s               n
     D zmsflag         s               n
     D zmflag          s               n

     *----------------------------------------------------------------
     *  Hidden subfile field
     *----------------------------------------------------------------

     D sflhide         ds
     D  h1dummy              100    100

     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
     *----------------------------------------------------------------
     D @cvtdt          c                   const('CVTDTE')

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
     *  Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $icmd    - *GETLPN
     *                 *PUTLCNS
     *      $iwhse   - Warehouse
     *      $ipo     - PO
     *      $iLPN    - Pallet LNP Number
     *      $iform   - Form type
     *      $ilot    - Lot number  for *PUTLCNS
     *
     *    Returned Parameters
     *      $ilot    - Lot number
     *      $item    - Item Number
     *      $iseq    - Po seq#
     *      $iqty    - quantity/pieces
     *      $imfgdt  - MFG Date
     *      $imfgexp - MFG Expiration Date
     *      $iwgt    - Weight
     *      $iupc    - UPC
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $icmd
     C                   parm                    $irtn
     C                   parm                    $iwhse
     C                   parm                    $ipo
     C                   parm                    $iLPN
     C                   parm                    $ilcns
     C                   parm                    $ilot
     C                   parm                    $iitem
     C                   parm                    $iseq
     C                   parm                    $iqty
     C                   parm                    $imfgdt
     C                   parm                    $imfgexp
     C                   parm                    $iwgt
     C                   parm                    $iupc

      /free

740 A    // ensure passed dates have valid numeric data
740 A    monitor;
740 A      $imfgdt=$imfgdt;
740 A    on-error;
740 A      $imfgdt=0;
740 A    endmon;
740 A
740 A    monitor;
740 A      $imfgexp=$imfgexp;
740 A    on-error;
740 A      $imfgexp=0;
740 A    endmon;

         noParmsPassed = *on;

         if %parms >= 1;
           $pcmd = $icmd;
         else;
           $pcmd = ' ';
         endif;

         if %parms >= 2;
           $prtn = $irtn;
         else;
           $prtn = ' ';
         endif;

         if %parms >= 3 and $iwhse > 0;
           $pwhse = $iwhse;
           noParmsPassed = *off;
         else;
           $pwhse = 0;
         endif;

         if %parms >= 4 and $ipo <> ' ';
           $ppo  = $ipo;
           noParmsPassed = *off;
         else;
           $ppo  = ' ';
         endif;

         if %parms >= 5;
           $plpn = $ilpn;
         else;
           $plpn = ' ';
         endif;

         if %parms >= 6;
           $plcns = $ilcns;
         else;
           $plcns = ' ';
         endif;

740 A    if %parms >= 7;
740 A      $plot = $ilot;
740 A    else;
740 A      $plot = ' ';
740 A    endif;

         if %parms >= 8;
           $pitem = $iitem;
         else;
           $pitem = ' ';
         endif;

         if %parms >= 9;
           $pseq = $iseq;
         else;
           $pseq = 0;
         endif;

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

         // Make sure the file exist on client box
         exec sql select count(*)
                  into :count
                  from systables
                  where name = 'POASN';

         If sqlstt = sqlSuccess;
           if count = 0;
             return;
           endif;
         endif;
         select;
700aA      when $pcmd = '*CHKASN';
700aA        exsr check4ASN;
           when $pcmd = '*GETLPN';
             exsr screen1;
           when $pcmd = '*PUTLCNS';
             exsr putasnlicense;
           when $pcmd = '*RMVLCNS';
             exsr rmvasnlicense;
700aA      when $pcmd = '*GETLOTS';
700aA        exsr getlots;
           other;
         endsl;

650aA    select;
650aA      when $pcmd = '*GETLPN';
         // Cleanup
         exsr zsclr;
650aA      other;
650aA    endsl;

         *inlr = *on;

         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *inzsr;

650aA    // open display file if needed
650aA    select;
650aA      when $icmd = '*GETLPN';
650aA        open getasn01;
         // Initialize message handling

         error = *off;
         exsr zmimsg;

650aA      other;
650aA        error = *off;
650aA    endsl;

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

         if $pwhse > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'pawhse=' + %trim(%editc($pwhse:'P'));
           append5 = ' and ';
         endif;

         // PO

         if w1po <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'papo  ='
                    + sq + %trim(w1po) + sq;
           append5 = ' and ';
         endif;

         // Pallet Lpn Number

         if $plpn <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'palpn ='
                    + sq + %trim(W1lpn) + sq;
           append5 = ' and ';
         endif;

         // only get blank license records - not received

         if $plpn <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'palcns ='
                    + sq + ' ' + sq;
           append5 = ' and ';
         endif;

         // Create "Order By" clauses.


         // Create SQL statement.

         SqlStmt = 'SELECT '
                 + %trimr(sqlfields) + ' '
                 + %trimr(sqlfrom) + ' '
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

         // Create "where" clause.

         sqlwhere = ' ';
         append5  = 'WHERE';

         // Warehouse

         if $pwhse > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'pawhse=' + %trim(%editc($pwhse:'P'));
           append5 = ' and ';
         endif;

         // PO

         if w1po <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'papo  ='
                    + sq + %trim($ipo) + sq;
           append5 = ' and ';
         endif;

         // Pallet Lpn Number

         if $plpn <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'palpn ='
                    + sq + %trim($ilpn) + sq;
           append5 = ' and ';
         endif;

         // Item Number

         if $pitem <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'paitem ='
                    + sq + %trim($pitem) + sq;
           append5 = ' and ';
         endif;

740 A    // Lot Code
740 A
740 A    if $plot <> '*ALL';
740 A      sqlwhere = %trimr(sqlwhere) + append5 + ' '
740 A               + 'palot ='
740 A               + sq + %trim($plot) + sq;
740 A      append5 = ' and ';
740 A    endif;

740 A    // Mfg Date
740 A
740 A    if $pmfgdt > 0;
740 A      sqlwhere = %trimr(sqlwhere) + append5 + ' '
740 A               + 'pamfgdt=' + %trim(%editc($pmfgdt:'P'));
740 A      append5 = ' and ';
740 A    endif;

740 A    // Expiration Date
740 A
740 A    if $pmfgexp > 0;
740 A      sqlwhere = %trimr(sqlwhere) + append5 + ' '
740 A               + 'pamfgexp=' + %trim(%editc($pmfgexp:'P'));
740 A      append5 = ' and ';
740 A    endif;

         // Seq Number

         if $pseq  > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'paseq =' + %trim(%editc($pseq:'P'));
           append5 = ' and ';
         endif;
         // only get blank license records - not received

         if $plpn <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'palcns ='
                    + sq + ' ' + sq;
           append5 = ' and ';
         endif;

         // Create "Order By" clauses.


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

           exec sql FETCH NEXT FROM mycsr INTO :poasn;

           If sqlstt = sqlSuccess;
700aA        // need to determine if summary record should be loaded
700aA        exsr Lotsummary;
700aA        if sumcount > 1;
700aA          rrn1 = rrn1  + 1;
700aA          if first;
700aA            first = *off;
700aA            recpos = rrn1;
700aA          endif;
700aA          option = ' ';
700aA          write sfl1;
700aA        endif;
             exsr sflFill1;
700aA        if sumcount > 1
700aA         or sumcount = 0;
700aA          *in91 = '1';
700aA        else;
700aA          *in91 = '0';
700aA        endif;
             rrn1 = rrn1  + 1;
             if first;
               first = *off;
               recpos = rrn1;
             endif;
             option = ' ';
             write sfl1;
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
     *  sflclr - Clear subfile
     *----------------------------------------------------------------

      /free
       begsr sflclr;

         // Clear the subfile

700aA    savepo = ' ';
700aA    w1lot = ' ';
700aA    w1dsplot = ' ';
         *in31 = *on;
         write sf1ctl;
         *in31 = *off;
         *in32 = *off;
         rrn1 = 0;
         lastrrn = 0;
         recpos = 0;
         // *in90 = *off;
         *in84 = *off;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflFill1  -  Fill subfile line
     *----------------------------------------------------------------

      /free
       begsr sflFill1;

700aA    // is this the same po/item/date/different lot
700aA    // if multiple lots we will allow to one license
700aA    // if different dates, must receive separately on date sensitive
700aA    //if $itflgd = 'Y';
700aA    //endif;

700aA    if savepo = papo;
700aA      w1dsppo = ' ';
700aA    else;
700aA      w1dsppo = papo;
700aA      savepo = papo;
700aA    endif;
         w1qty  = paqty;
         if pamfgdt > 0;
           $cvcmd = '*CMDYMD';
           $cvd8i = %char(pamfgdt);
           cvtdte($cvtdt);
           w1mfgdt = $cvd6o;
700aA      $cvcmd = '*CMDMDY';
700aA      $cvd8i = %char(pamfgdt);
700aA      cvtdte($cvtdt);
700aA      w1date = $cvd6o;
700aA      dattype = 'M';
         endif;
         if pamfgexp > 0;
           $cvcmd = '*CMDYMD';
           $cvd8i = %char(pamfgexp);
           cvtdte($cvtdt);
           w1mfgexp = $cvd6o;
700aA      $cvcmd = '*CMDMDY';
700aA      $cvd8i = %char(pamfgexp);
700aA      cvtdte($cvtdt);
700aA      w1date   = $cvd6o;
700aA      dattype = 'X';
         endif;
         w1wgt  = pawgt;
         w1upc  = paupc;
         w1whse = pawhse;
         w1po = papo;
         w1lpn= palpn;
         w1item = paitem;
         w1lot = palot;
700aA    w1dsplot = palot;
         w1seq = paseq;

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

           select;
             when curview = 2;
             other;
               readc sfl1;
           endsl;

           if %eof;
            leave;
           endif;

           select;

             when %trim(option) = '1';
               optiontaken = 'Select';
               recpos = rrn1;

           endsl;

           option = ' ';
           select;
             when curview = 2;
             other;
               update sfl1;
           endsl;

           leave;

         enddo;

       endsr;
      /end-free

700aA*----------------------------------------------------------------
700aA*  Lotsummary - Check to see if summary record should be loaded
700aA*----------------------------------------------------------------

700aA /free
700aA  begsr Lotsummary;

700aA   // if data is different check for new summary record to display
700aA   sumcount = 0;
700aA   select;
700aA     //when savewhse = 0;

700aA     when pawhse   <> savewhse
700aA      or  papo     <> savepo
700aA      or  palpn    <> savelpn
700aA      or  paitem   <> saveitem
700aA      or  paseq    <> saveseq
700aA      or  pamfgdt  <> savemfgdt
700aA      or  pamfgexp <> savemfgexp;
700aA       exec sql select count(*), sum(paqty), sum(pawgt)
700aA                into :sumcount :countInd,
700aA                     :w1qty :pcsInd,
700aA                     :w1wgt :wgtInd
700aA                from poasn a_
700aA                where pawhse   = :pawhse
700aA                  and papo     = :papo
700aA                  and palpn    = :palpn
700aA                  and paitem   = :paitem
700aA                  and paseq    = :paseq
700aA                  and pamfgdt  = :pamfgdt
700aA                  and pamfgexp = :pamfgexp;

700aA       sqlstt = sqlstt;
700aA       if sumcount > 1;
700aA         // is this the same po/item/date/different lot
700aA         // if multiple lots we will allow to one license
700aA         // if different dates, must receive separate on date sensitive
700aA         //if $itflgd = 'Y';
700aA         //endif;

700aA         savewhse = pawhse;
700aA         savepo = papo;
700aA         savelpn = palpn;
700aA         saveitem = paitem;
700aA         saveseq = paseq;
700aA         savemfgdt = pamfgdt;
700aA         savemfgexp = pamfgexp;
700aA
700aA         if savepo = papo;
700aA           w1dsppo = ' ';
700aA         else;
700aA           w1dsppo = papo;
700aA           savepo = papo;
700aA         endif;
              if pamfgdt > 0;
                $cvcmd = '*CMDYMD';
                $cvd8i = %char(pamfgdt);
                cvtdte($cvtdt);
                w1mfgdt = $cvd6o;
700aA           $cvcmd = '*CMDMDY';
700aA           $cvd8i = %char(pamfgdt);
700aA           cvtdte($cvtdt);
700aA           w1date = $cvd6o;
700aA           dattype = 'M';
              endif;
              if pamfgexp > 0;
                $cvcmd = '*CMDYMD';
                $cvd8i = %char(pamfgexp);
                cvtdte($cvtdt);
                w1mfgexp = $cvd6o;
700aA           $cvcmd = '*CMDMDY';
700aA           $cvd8i = %char(pamfgexp);
700aA           cvtdte($cvtdt);
700aA           w1date   = $cvd6o;
700aA           dattype = 'X';
              endif;
              w1upc  = paupc;
              w1whse = pawhse;
              w1po = papo;
700aA         w1dsppo = papo;
              w1lpn= palpn;
              w1item = paitem;
              w1lot = palot;
700aA         w1dsplot = 'ASN Multiple';
              w1seq = paseq;
            endif;
        endsl;
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

         scrname = 'GETASN.1';
         exsr inzcriteria1;

         exsr setcriteria1;

         scopt1 = '1=Select';

         scopt2 = ' ';


         // Do initial build and display of subfile

         exsr sflBldDisp;

         // Process subfile until user wants to leave

         dou (cfkey = F3);

           if rrn1 = 0;
             // load parms to return
             exsr loaderror;
             leave;
           endif;

           if rrn1 = 1;
             // load parms to return
             exsr loadreturn;
             leave;
           endif;

           Write fkey1;
           if recpos > 0 and recpos <= lastrrn;
             rrn1 = recpos;
           else;
             rrn1 = 1;
           endif;
           select;
             other;
               exfmt sf1ctl;
           endsl;

           recpos = csrrrn;

           Select;

             // Enter

             When cfkey = Enter;
               ExSr sfloption1;

               select;

                 when optiontaken = 'Select';
                   // load parms to return
                   exsr loadreturn;
                   leave;

               endsl;

             // F5 = Refresh

             when cfkey = F5;
               exsr sflBldDisp;
               cfkey = Enter;


             // F3 = Exit or F12 = Cancel

             when cfkey = F3 or cfkey = F12;
               // Cleanup
               exsr zsclr;
               *inlr = *on;
               return;
               leave;

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
     *                     Misc. Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------
700aA*----------------------------------------------------------------
700aA*  getlots      - gets all lots for the receipt for LICINFO
700aA*----------------------------------------------------------------
700aA /free
       begsr getlots;
         if $irtn <> '*MORE';
           if $imfgdt > 0;
             $cvcmd = '*YMDCMD';
             $cvd6i = %char($imfgdt);
             cvtdte($cvtdt);
             $imfgdt8 = $cvd8o;
           endif;
           if $imfgexp > 0;
             $cvcmd = '*YMDCMD';
             $cvd6i = %char($imfgexp);
             cvtdte($cvtdt);
             $imfgexp8 = $cvd8o;
           endif;

           exsr sqlclean;
           exsr sqlbldstmt2;
           exsr sqlprep;
         endif;
         exsr lotbld1;

       endsr;
700aA /end-free

     *----------------------------------------------------------------
     *  Lotbld1 - Get the lots for the receipt
     *----------------------------------------------------------------

      /free
       begsr lotbld1;

         //first = *on;

         // Process the records in the SQL cursor until the return not = 0

         for i = 1 to 9999;

           // Get the next row from the SQL cursor.

           exec sql FETCH NEXT FROM mycsr INTO :poasn;

           If sqlstt = sqlSuccess;
700aA        // need to determine if summary record should be loaded
             if $irtn <> '*MORE';
700aA          exsr Lotsummary;
             endif;
700aA        if sumcount > 1
              or $irtn = '*MORE';
               $ilot = palot;
               $iqty = paqty;
               $iwgt = pawgt;
700aA          $irtn = '*MORE';
               return;
700aA        endif;
           else;
             if $irtn = '*MORE';
               $irtn = '*DONE';
               leave;
             else;
700aA          $irtn = ' ';
               leave;
             endif;
           endif;

         endfor;

         //if sqlstt = sqlNoMoreData;
           //*in84 = *on;
         //endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  loaderror    - Load error  parms
     *----------------------------------------------------------------
      /free
       begsr loaderror;
         $irtn = '*INVALID';
         $ilot = ' ';
         $iitem = ' ';
         $iseq = 0;
         $iqty = 0;
         $imfgdt = 0;
         $imfgexp = 0;
         $iwgt = 0;
         $iupc = ' ';
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  loadreturn   - Load return parms
     *----------------------------------------------------------------
      /free
       begsr loadreturn;
         $irtn = '*OK';
         $ilot = w1lot;
         $iitem = w1item;
         $iseq = w1seq;
         $iqty = w1qty;
         $imfgdt = w1mfgdt;
         $imfgexp = w1mfgexp;
         $iwgt = w1wgt;
         $iupc = w1upc;
       endsr;
      /end-free

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

         dou (cfkey = F3) or (cfkey = F12);

           // Set ON alarm indicator if error occured

           if error = *on;
             *in98 = *on;
           endIf;

           // Overlay screen with error messages

           exsr zmdmsg;

           //exfmt window1;

           *in98 = *off;
           *in25 = *off;
           *in24 = *off;
           *in23 = *off;
           *in22 = *off;
           *in05 = *off;
           *in04 = *off;
           *in03 = *off;
           *in02 = *off;
           exsr zmcmsg;

           Select;

             // Enter

             When cfkey = Enter;
               if error;
                 iter;
               endif;

               noParmsPassed = *off;
               exsr screen1;
               leave;

           EndSl;

         EndDo;

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

         if $ppo = ' ';
           w1po = '*ALL';
         else;
           w1po  = $ppo;
         endif;

         if $plpn = ' ';
           w1lpn = '*ALL';
         else;
           w1lpn = $plpn;
         endif;

       endsr;
      /end-free

700aA*----------------------------------------------------------------
700aA*  check4ASN - Check POASN for purchase order being received     d.
700aA*----------------------------------------------------------------
700aA /free
700aA  begsr check4ASN;

700aA    exec sql select * into :poasn
700aA             from poasn
700aA             where palcns = ' '
700aA               and pawhse= :$pwhse
700aA               and papo  = :$ppo
700aA             fetch first row only;
700aA    If sqlstt = sqlSuccess;
700aA      // found po in asn file
700aA      $irtn = '*OK';
700aA    endif;
700aA  endsr;
700aA /end-free

     *----------------------------------------------------------------
     *  putasnlicense - Load license into POASN to mark record received.
     *----------------------------------------------------------------
      /free
       begsr putasnlicense;

         if $imfgdt > 0;
           $cvcmd = '*YMDCMD';
           $cvd6i = %char($imfgdt);
           cvtdte($cvtdt);
           $imfgdt8 = $cvd8o;
740 A      $pmfgdt = $cvd8o;
         endif;
         if $imfgexp > 0;
           $cvcmd = '*YMDCMD';
           $cvd6i = %char($imfgexp);
           cvtdte($cvtdt);
           $imfgexp8 = $cvd8o;
740 A      $pmfgexp = $cvd8o;
         endif;
         exsr sqlclean;
         exsr sqlbldstmt2;
         exsr sqlprep;
         // Process the records in the SQL cursor until the return not = 0

740 D    //for i = 1 to 9999;
740 M    dow forever = forever;
           // Get the next row from the SQL cursor.

           exec sql FETCH NEXT FROM mycsr INTO :poasn;

           If sqlstt = sqlSuccess;
             exec sql update poasn
                      set palcns = :$plcns
                      where palcns = ' '
                        and pawhse= :pawhse
                        and papo  = :papo
                        and palpn = :palpn
                        and paitem= :paitem
                        and paseq = :paseq
                        and palot = :palot
700aA                   and pamfgdt  = :pamfgdt
700aA                   and pamfgexp = :pamfgexp;
740 A      else;
740 A        leave;
           endif;
740 D    //endfor;
740 M    enddo;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  rmvasnlicense - Remove License from POASN - receipt is deleted.
     *----------------------------------------------------------------
      /free
       begsr rmvasnlicense;

          exec sql update poasn
                   set palcns = ' '
                   where palcns = :$plcns;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  setcriteria1 - Set criteria 1 values.
     *----------------------------------------------------------------

      /free
       begsr setcriteria1;

         // Set sort order

         // Create screen heading.

         schead = ' ';
         append1 = ' ';


         if $pLpn <> ' ';
           schead = %trimr(schead) + append1
                  + 'LPN=' + %trim($pLpn);
           append1 = ',';
         endif;

         exsr centerschead;

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
     *      PIR1007  Invalid date entered.
     *----------------------------------------------------------------

      /free
       begsr zm1007;

         #msgid = 'PIR1007';
         #msgtp = '*DIAG  ';
         #msgdt = errmsg;
         exsr zmpmsg;

       endsr;
      /end-free

     *----------------------------------------------------------------
