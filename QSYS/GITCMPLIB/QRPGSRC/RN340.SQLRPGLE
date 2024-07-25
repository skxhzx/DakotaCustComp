     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RN340     CUSTOMER Return Transactions with License Barcoded
     *  Kenneth Elder
     *  04/05/2019
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    04/05/19  KDE  7.30
     *      - Created.
     *----------------------------------------------------------------
     *  File Specs
     *
     Fwarehs    if   e           k disk
     fwhdept    if   e           k disk
     Freports   if   e           k disk
     FRN340pr   o    e             printer oflind(*in90)
700aAF                                     usropn

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
CLD A*  Program info data structure
     *
CLD AD                sds
CLD AD  #prog            *proc
CLD AD  #job                 244    253
CLD AD  #user                254    263
CLD AD  #jobn                264    269
CLD AD  #jobdt               276    281  0
CLD AD  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  VARIABLES
     D $pwhse          s              3  0
     D $pdept          s              5
     D $plen           s              3  0
     D $pstr           s             60
     D $custord        s              7  0
     D brk             s              1    inz(*off)
     D count           s              3  0
     D first           s               n   inz('1')
     D hldDept         s              5
     D SqlStmt         s           2000    inz(' ')
700aAD wpdev           s             10
700aAD wpform          s             20

      /copy qcopysrc,c#stdvar
      *copy qcopysrc,c#stdsql

     *  SQL Data Struction Record to loop through open passed in Customer Return

     d orrec           ds           110
     d   sqwhse                       3  0 overlay(orrec)
     d   sqcord                       7  0 overlay(orrec:*next)
     d   sqitem                      15    overlay(orrec:*next)
     d   sqqty1                       5  0 overlay(orrec:*next)
     d   sqqty2                       5  0 overlay(orrec:*next)
     d   sqqty3                       5  0 overlay(orrec:*next)
     d   sqwhdp                       5    overlay(orrec:*next)
     d   sqlbl#                       7  0 overlay(orrec:*next)
     d   sqtrn#                       7  0 overlay(orrec:*next)
     d   sqlcns                      15    overlay(orrec:*next)
     d   sqdesc                      30    overlay(orrec:*next)
     d   squm1                        2    overlay(orrec:*next)
     d   squm2                        2    overlay(orrec:*next)
     d   squm3                        2    overlay(orrec:*next)
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE    -  Warehouse
     *      $Dept     -  Warehouse Department
     *      $custord  -  Customer Order Number
     *
     *    Returned Parameters
     *      *NONE
     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------
     C     *entry        plist
     C                   parm                    $pwhse
     C                   parm                    $pdept
     C                   parm                    $custord
     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free
          // open primary query file
          sqlStmt = 'select orwhse,orord,oritem,orqty1,orqty2,orqty3,' +
                     'lbwhdp,lblbl#,lbtrn#,lnlcns,itdesc,' +
                     'itum1, itum2, itum3 ' +
                     'from orrtn,label,licinfo,piritem ' +
                       'where orwhse=lbwhse and orpbat=lbpbat ' +
                         'and orwhse=lnwhse and lbtrn#=lnrcvtrn# ' +
                         'and orwhse=itwhse and oritem=ititem ' +
                         'and orwhse=' + %char($pWhse) + ' and ' +
                         'orord=' + %char($custord);
          // if department was included narrow the search
          if $pDept<>*blanks;
          sqlStmt = %trim(sqlStmt) + ' and lbwhdp=' + sq +
                    %trim($pDept) + sq;
          endif;
          sqlStmt = %trim(sqlStmt) + ' order by orwhse,lbwhdp,oritem';
710kA
710kA     exec sql PREPARE rtnD FROM :SqlStmt;
710kA     exec sql DECLARE rtnData SCROLL CURSOR FOR rtnD;
710kA     exec sql OPEN rtnData;
710kA
710kA     exec sql FETCH FIRST FROM rtnData INTO :orrec;

          dow sqlStt = '00000';

          // Report Heading

          if *in90  or
             brk = *on or
             sqWhdp <> hldDept;
             eval      rptttl = 'Customer Order Return Putaways';
             chain (sqwhse) warehs;
             chain (sqwhse:sqwhdp) whdept;
             exsr zrhead;
             write columns;
             brk=*off;
             hldDept=sqwhdp;
             count=7;
          endif;
      /end-free
     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *  Write detail line
     *
      /free
                         select;
                           when sqqty1<>0;
                              sqqty=sqqty1;
                              squom=squm1;
                           when sqqty2<>0;
                              sqqty=sqqty2;
                              squom=squm2;
                           when sqqty3<>0;
                              sqqty=sqqty3;
                              squom=squm3;
                         endsl;
      /end-free
     C                   write     detail1                              90
     C                   add       3             count
      /free
          if count > 52;
             brk = *on;
          endif;
710kA     exec sql FETCH next FROM rtnData INTO :orrec;
      /end-free
     *
     C                   enddo

     C                   eval      *inlr = *on
700aA /free
700aA    // Close printer file.

         write foot1;
700aA    close(e)   RN340pr;
700aA    if %error;
700aA    endif;
700aA /end-free
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     *
     *   Get report title.
     *
     C                   eval      rptttl = *blanks
     C                   eval      $pstr = *blanks
      /free
                         chain ('RN340PR') reports;
      /end-free
     C                   if        %found(reports)
     C                   movel     rpdesc        $pstr
700aAc                   eval      wpdev = rpdev
700aAc                   eval      wpform = rpform
     C                   else
     C                   eval      $pstr='Customer Return Putaways'
700aAc                   eval      wpdev = '*JOB'
700aAc                   eval      wpform = '*STD'
     C                   endif
     C                   eval      $plen = 40
700aAc* ovrprtf and open file
700aA /free
700aA      qcmd = 'OVRPRTF '
700aA           + 'FILE(RN340PR) '
700aA           + 'OUTQ(*DEV) '
700aA           + 'DEV(' + %trim(wpdev) + ') '
700aA           + 'FORMTYPE(' + %trim(wpform) + ') ';

700aA /end-free
700aAC                   call      'QCMDEXC'
700aAC                   parm                    qcmd             80
700aAC                   parm      80            qlen             15 5
700aA /free
700aA    // Open printer file.

700aA    open(e)   RN340PR;
700aA /end-free
     *
     *   Center report title.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         rptttl
     *
     C                   time                    time
     C                   eval      count = 0
     C                   eval      first = *on
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrhead        begsr
     *
     C                   eval      *in90 = *off
     *
     *   Get warehouse description.
     *
     C                   eval      whse = *blanks
     C                   eval      $pstr = *blanks
     C     $pWhse        chain     warehs                             79
     C                   if        not *in79
     C                   movel     whdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 30
     *
     *   Center warehouse description.
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         whse
     *
     C                   write     head1
     C                   write     head2
     C                   eval      count = 0
     *
     C                   endsr
