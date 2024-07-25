      /COPY *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------
     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  ADJTRANP    Add/Update Transaction Records for Production Module
     *  26 July, 2017
     *  Kenneth Elder
     *
     *   Revisions:
     *
     *    07/27/17  KDE  7.10
     *      - Created
730 A*    02/25/19  KDE  7.30
     *      - Recompile for pWrkordru
740 A*    10/16/20  KDE  7.40
     *      - Add copy source for p.bfcdteti
     *
     *----------------------------------------------------------------
     *  Custom Mods
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     FpirTranp  uf a e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#dairyla

     *----------------------------------------------------------------
     *  Standard variables and SQL constants
     *----------------------------------------------------------------
      /copy qcopysrc,c#stdvar
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  PIRTRAN record layout for use as SQL record
     *----------------------------------------------------------------

     D ptrec         e ds                  extname(pirtran)

      *  Replenishment Recordset to determine single or multi
      *  Mfg Lines/Work Orders
     d rplrec          ds
     d  rditem                 1     15
     d  rdline                16     18  0
     d  rddate                19     26  0
     d  rdnumWo               27     29  0
     d  rdSingleWo            30     42

      *  Putaway Recordset to determine single or multi
      *  Mfg Lines/Work Orders
     d putrec          ds
     d  rdtrn#                 1      7  0
     d  rdlcns                 8     22
     d  rdpdate               23     30  0
     d  rdpline               31     33  0
     d  rdpWo                 34     46

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Program variables.
     *----------------------------------------------------------------

     D bfcoffset       s              3  0 inz(0)
     d costType        s              1    inz('A')
640jaD ucOffset        s              3  0
     d date6           s              6  0
     D curdate         s              8  0
     D curtime         s              6  0
500cAD CurrStamploc    s               z
500cAD CurrStampsys    s               z
500cAD CurrStampuc     s               z
     D CurrStampmn     s             26
     D curent          s              1
     D currentstamp    s               z
     D curtrn          s              7  0
     D laststamp       s               z
     d lineTranp       s              3
     d woTranp         s             13

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------
     ***    Used to Get time stamp values
740 A /copy qcopysrc,p.bfcdteti
     D GetCurrStamp    pr

740 DD*getMicroTime    pr
740 DD* $pmicrouc                      z
740 DD* $pmicrolocal                   z

      *----------------------------------------------------------------
      *  Program information data structure
      *----------------------------------------------------------------

     D pssrflag        s               n

     D                sds
     D  #prog            *proc
500gAD  #pgm             *proc
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobnbr              264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
600fAD  #curruser            358    367

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PTRN#  Transaction number
     *      $PTASK  Task code
     *      $PWHSE  Warehouse
     *      $PUSER  User code (use if not blank)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $ptrn#            7 0
     C                   parm                    $ptask            6
     C                   parm                    $ptcat            6
     C                   parm                    $ptsub            6
     C                   parm                    $pwhse            3 0
     c                   parm                    $pcmd             1
     C                   parm                    $puser           10

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
      /free
              if $pcmd = 'D';
                 exec sql delete from pirtranp
                      where ppwhse=:$pwhse and pptrn#=:$ptrn#;
              else;
                 exsr zzPirtranp;
              endif;
              return;
      /end-free
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
     C                   endsr

      *----------------------------------------------------------------
      *  ZZpirTranp  Write Production information for Transaction
      *              This is used to spread cost at End of Day
      *----------------------------------------------------------------

     C     zzpirTranp    begsr
     c*   Also Create record in PIRTRANP (Production Module) file
     c*   which tracks whether transaction should be spread across
     c*   one Mfg Line or all, and whether it is spread across
     c*   one Work Order or All Work Orders.  This record is used
     c*   in production to determine what lines and work orders
     c*   get this labor allocated to them
      /free
               // only Replenishments and Putaways are written
               // in this program.  Other Production transactions
               // are written in DRIPROD since the Mfg Line and
               // Work Order are passed in and no searching required
               if $ptsub <> 'REPL' and $ptsub<>'PUTAWY';
                  leavesr;
               else;
                  exsr zzSetLineWo;
               endif;

               // Make sure Line and Work Order are set to *ALL
               // if they come in blank
               if LineTranp = *blanks;
                  LineTranp = 'ALL';
               endif;

               if woTranp = *blanks;
                  woTranp = 'ALL';
               endif;

               // Convert Labor line
               If %trim(LineTranp) <> 'ALL' and
                 %trim(LineTranp) <> *Blanks;
                 monitor;
                    // if numeric we convert line 3 to 003
                    LineTranp = %editC(%Dec(LineTranp:3:0):'X');
                 on-error;
                    // on error we do nothing and pass as is
                 endmon;
               EndIf;

               chain(n) ($pWhse:$ptrn#) pirTranp;
               if not %found(pirTranp);
                  ppWhse = $pWhse;
                  ppTrn# = $ptrn#;
                  ppwo# = %trim(woTranp);
                  ppLine = %trim(lineTranp);
                  ppctyp = costType;
                  GetCurrStamp();
                  ppSysts = currStampsys;
                  ppLocTs = currStampLoc;
                  ppUcTs = currStampUc;
                  ppJob = #job;
                  ppuser = #user;
                  ppJobNbr = #jobnbr;
                  write pprec;
               endif;
      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  ZZSetLineWo  Write Production information for Transaction
     *               This is used to spread cost at End of Day
     *----------------------------------------------------------------

     C     zzSetLineWO   begsr
      /free
          // determine whether to use specific Mfg Line or All
          // and whether to use specific Work Order or All based
          // on what mix of both are found associated with the
          // transaction passed.  If all one Mfg Line then use
          // that line, otherwise All and same for Work Order

          select;
             when $ptcat='PROD' and $ptsub='REPL';
                // Build SQL statement from combination of PRODLOG and
                // PWRKORDRU (Prod Usage File) to loop through and
                // determine if Replenishment was for one or many lines
                // and one or many Work Orders per this Transaction
                sqlStmt =
                'select distinct pl.plitem,pl.plline,pl.plprddte,' +
                '(select count(distinct ru.urwo#) from pwrkordru as ru ' +
                ' where pl.plwhse=ru.urwhse and pl.plprddte=ru.urprddte' +
                      ' and ru.urrmi=pl.plitem)'
                         + ' as numWo, ' +
                '(select distinct ru.urwo# from pwrkordru as ru ' +
                  'where pl.plwhse=ru.urwhse and pl.plprddte=ru.urprddte and '
                     + 'ru.urrmi=pl.plitem '
                     + 'fetch first row only) as SingleWo ' +
                 'from prodlog as pl where pl.pltrn#=' + %char($pTrn#);

                exec sql Prepare RplRd from :Sqlstmt;
                exec sql Declare readRpl scroll cursor for RplRd;
                exec sql Open readRpl;
                exec sql Fetch first from readRpl into :rplRec;

                woTranp = *blanks;
                lineTranp = *blanks;

                dow sqlStt = SqlSuccess;

                   // Setup lineTranp with either the unique Mfg Line
                   // used for this Transaction or ALL if more than
                   // one Mfg Line was represented
                   if lineTranp = *blanks;
                      lineTranp = %char(rdline);
                   else;
                      if lineTranp <> 'ALL' and lineTranp<>%char(rdline);
                         lineTranp = 'ALL';
                      endif;
                   endif;

                   if woTranp = *blanks;
                      if rdnumwo = 1;
                         woTranp = rdSingleWo;
                      else;
                         woTranp = 'ALL';
                      endif;
                   endif;

                   exec sql Fetch next from readRpl into :rplRec;
                enddo;
                exec sql Close readRpl;

             when $ptcat='PROD' and $ptsub='PUTAWY';
                // Build SQL recordset to loop for Putaway
                // transaction. It will join liclog and
                // Prodlog to retrieve information required
                // to determine if the transaction can be
                // spread specifically to one Line and Work
                // Order or be spread across All Lines and
                // or All Work Orders for a given day.
                // If a single Work Order is found that Single
                // Work Order will get all this labor, otherwise
                // it will be spread across all Work Orders.  If
                // one Mfg Line is found it will be spread across
                // one Mfg Line otherwise across all Mfg Lines
                sqlStmt =
                'select distinct lltrn#,llflcns,' +
                'case when plprddte Is Null then 0 else plprddte end ' +
                       'as plprddte, ' +
                'case when plline Is Null then 0 else plline end ' +
                       'as plline, ' +
                'case when plbfcwo Is Null then ' + sq + ' ' + sq + ' else ' +
                       'plbfcwo end as plbfcwo ' +
                'from liclog left outer join prodlog ' +
                'on llwhse=plwhse and llflcns=pltlcns ' +
                'where llaction=' + sq + 'PRD' + sq + ' and ' +
                  'lltrn#=' + %char($ptrn#);

                exec sql Prepare PutRd from :Sqlstmt;
                exec sql Declare readPut scroll cursor for PutRd;
                exec sql Open readPut;
                exec sql Fetch first from readPut into :putRec;

                woTranp = *blanks;
                lineTranp = *blanks;

                dow sqlStt = SqlSuccess;

                   // Setup lineTranp with either the unique Mfg Line
                   // used for this Transaction or ALL if more than
                   // one Mfg Line was represented
                   if lineTranp = *blanks;
                      lineTranp = %char(rdpline);
                   else;
                      if lineTranp <> 'ALL' and lineTranp<>%char(rdpline);
                         lineTranp = 'ALL';
                      endif;
                   endif;

                   if woTranp = *blanks;
                      woTranp = rdpWo;
                   else;
                      if woTranp <> rdpWo and woTranp<>'ALL';
                         woTranp = 'ALL';
                      endif;
                   endif;

                   exec sql Fetch next from readPut into :putRec;
                enddo;
                exec sql Close readPut;

             when $ptcat='PROD';
                // These transactions are maintained in DRIPROD
             other;
          endsl;

      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *  GetCurrStamp  Get current timestamps
     *----------------------------------------------------------------

     p GetCurrStamp    b
     d GetCurrStamp    pi

      /free

         getmicrotime(currstampuc:currstampsys);
         ucOffset = %diff(currstampuc: currstampsys: *HOURS);
         currstamploc = currstampsys + %hours(bfcoffset);

      /end-free

     p GetCurrStamp    e
