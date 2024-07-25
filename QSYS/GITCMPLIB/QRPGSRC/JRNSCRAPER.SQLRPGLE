     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *
     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383       libr
     *----------------------------------------------------------------
     *
     *  JRNSCRAPER  Journal Scraper - Called as Exit Program from RCVJRNE CMD
     *  07 February 2024
     *  Kenneth Elder
     *
416  *    02/07/24  KDE  7.80
     *      - Created
     *
     *----------------------------------------------------------------
     *
     * JRNSCRAPER - PROGRAM TO RUN AS RCVJRNE EXIT POINT.
     * IT WILL CREATE TABLES OF JOURNAL RECORDS IN WHICH THE BLOB
     * FIELD JOESD IS PARSED INTO THE FIELDS OF THE RECORD THAT
     * IS THE SUBJECT OF THE JOURNAL RECORD.
     * - - - - - - - - - - - - - - - - - - - - - - - -
     *    Dependencies
     * 1. JRNDTA Data area provides properties
     * 2. FLATFILE PHYSICAL FILE REQUIRED FOR COMPILE
     * 3. QCMDEXC
     * 4. SQL
     * - - - - - - - - - - - - - - - - - - - - - - - -

       CTL-OPT OPTION(*SRCSTMT:*NODEBUGIO:*NOUNREF);
       CTL-OPT MAIN(MAIN);

780aAFjrnscraptsuf a e           k disk    usropn

       DCL-PR QCMDEXC EXTPGM;
        CMD          CHAR(500)     CONST OPTIONS(*VARSIZE);
        CMDLENGTH    PACKED(15: 5) CONST;
       END-PR;

     D updjrndta       PR                  ExtPgm('JS055CL')
     D     TSchar                    26
     D     DateChar                   8
     D     Timechar                   6
     D     outlib                    10
     D     jname                     10
     D     jjob                      10
     d     jfiles                   340
     d     jlibrs                   160
     d     jtypes                    18
     D     Cmdchar                    1    const

       DCL-PROC MAIN;
       DCL-PI *N EXTPGM;
         PTYPE2 like(maxData);
         pJocom char(3);
       end-pi;

        dcl-f flatfile usage(*output) usropn extfile(myfile);
        dcl-s myfile char(20);  // name of file written
        dcl-s cmd char(500);
        dcl-s maxdata char(32922) template;
        dcl-s oneEntry like(maxdata);
        dcl-s lenOfJrnEntry zoned(6);
        dcl-s nxtCharpos zoned(6);
        dcl-s forever char(1);
        dcl-ds flatFileDS likerec(RFLAT);
        dcl-s cnt zoned(4);
        dcl-s systemTS char(26);

        dcl-c sqlCreateTable
          'create table ';

        dcl-c sqlCreateBfc
           '/tempbfc (BFCSTAT CHAR(1) +
            , BFCCLI  CHAR(10) +
            , BFCCLI2  CHAR(10) +
            , BFCJRNNAM  CHAR(10))';

        dcl-c sqlCreateTemp
           '/tempjrn (JOENTL NUMERIC(5,0) +
            , JOSEQN  NUMERIC(10,0) +
            , JOCODE  CHAR(1) +
            , JOENTT  CHAR(2) +
            , JOTSTP  TIMESTAMP +
            , JOJOB   CHAR(10) +
            , JOUSER  CHAR(10) +
            , JONBR   NUMERIC(6,0) +
            , JOPGM   CHAR(10) +
            , JOOBJ   CHAR(10) +
            , JOLIB   CHAR(10) +
            , JOMBR   CHAR(10) +
            , JOCTRR  NUMERIC(10,0) +
            , JOFLAG  CHAR(1) +
            , JOCCID  NUMERIC(10,0) +
            , JOUSPF CHAR(10) +
            , JOSYNM CHAR(8) +
            , JOINCDAT CHAR(1) +
            , JOMINESD CHAR(1) +
            , JORES   CHAR(8))';

        DCL-S TEMPJRNCREATED             IND;
        DCL-S STMTTXT                    CHAR(3000);
        DCL-S FILE_SYSTEM_NAME           CHAR(10);
        DCL-S CREATEDTABLEARRAY          CHAR(20) DIM(999);
        DCL-S LASTENTRYCREATEDTABLEARRAY PACKED(3:0) INZ(0);
        DCL-S jrlsts                     CHAR(26) inz(' ');
        DCL-S jrlsdte                    CHAR(8) inz(' ');
        DCL-S jrlstim                    CHAR(6) inz(' ');
        DCL-S jrnlib                     CHAR(10) inz(' ');
        DCL-S jname                      CHAR(10) inz(' ');
        DCL-S jjob                       CHAR(10) inz(' ');
     D SqlStmt         s           2000    inz(' ')
     D SQ              C                   CONST(X'7D')

        DCL-DS UNFORMATTEDINPUT;
          UNFORMATTEDDATA               CHAR(32922);
        END-DS;

        DCL-DS FORMATTEDINPUT;
           BFCSTAT               CHAR(1);
           BFCCLI                CHAR(10);
           BFCCLI2               CHAR(10);
           BFCJRNNAM             CHAR(10);
           JOENTL                ZONED(5:0);
           JOSEQN                ZONED(10:0);
           JOCODE                CHAR(1);
           JOENTT                CHAR(2);
           JOTSTP                TIMESTAMP;
           JOJOB                 CHAR(10);
           JOUSER                CHAR(10);
           JONBR                 ZONED(6:0);
           JOPGM                 CHAR(10);
           JOOBJ                 CHAR(10);
           JOLIB                 CHAR(10);
           JOMBR                 CHAR(10);
           JOCTRR                ZONED(10:0);
           JOFLAG                CHAR(1);
           JOCCID                ZONED(10:0);
           JOUSPF                CHAR(10);
           JOSYNM                CHAR(8);
           JOINCDAT              CHAR(1);
           JOMINESD              CHAR(1);
           JORES                 CHAR(8);
           JOESD                 char(32641);
       END-DS;

       dcl-pr OpenFile pointer extproc('_C_IFS_fopen') ;
         *n pointer value ;  // File name
         *n pointer value ;  // File mode
       end-pr ;

       dcl-pr CloseFile extproc('_C_IFS_fclose') ;
         *n pointer value ;  // Misc pointer
       end-pr ;

     D mkdir           PR            10I 0 ExtProc('mkdir')
     D  dirpath                        *   Value options(*string)
     D  mode                         10U 0 Value

     Dreturn_mkdir     s             10i 0 inz
     D dirpath         s            512a   inz
     D mode            s             10U 0 inz

      * <-----mode---->
      * owner,group,other (RWX)
      *                                         owner authority
     D M_readowner     C                   256
     D M_writeowner    C                   128
     D M_executeowner  C                   64
      *                                         group authority
     D M_readgroup     C                   32
     D M_writegroup    C                   16
     D M_executegroup  C                   8
      *                                         other people
     D M_readother     C                   4
     D M_writeother    C                   2
     D M_executeother  C                   1

       dcl-s PathFile char(50) ;
       dcl-s OpenMode char(100) ;
       dcl-s FilePtr pointer inz ;

     *  Files selected
     d selFiles        ds           820
     d  jrfl01                 1     10
     d  jrfl02                11     20
     d  jrfl03                21     30
     d  jrfl04                31     40
     d  jrfl05                41     50
     d  jrfl06                51     60
     d  jrfl07                61     70
     d  jrfl08                71     80
     d  jrfl09                81     90
     d  jrfl10                91    100
     d  jrfl11               101    110
     d  jrfl12               111    120
     d  jrfl13               121    130
     d  jrfl14               131    140
     d  jrfl15               141    150
     d  jrfl16               151    160
     d  jrfl17               161    170
     d  jrfl18               171    180
     d  jrfl19               181    190
     d  jrfl20               191    200
     d  jrfl21               201    210
     d  jrfl22               211    220
     d  jrfl23               221    230
     d  jrfl24               231    240
     d  jrfl25               241    250
     d  jrfl26               251    260
     d  jrfl27               261    270
     d  jrfl28               271    280
     d  jrfl29               281    290
     d  jrfl30               291    300
     d  jrfl31               301    310
     d  jrfl32               311    320
     d  jrfl33               321    330
     d  jrfl34               331    340
     d  jrfl35               341    350
     d  jrfl36               351    360
     d  jrfl37               361    370
     d  jrfl38               371    380
     d  jrfl39               381    390
     d  jrfl40               391    400
     d  jrfl41               401    410
     d  jrfl42               411    420
     d  jrfl43               421    430
     d  jrfl44               431    440
     d  jrfl45               441    450
     d  jrfl46               451    460
     d  jrfl47               461    470
     d  jrfl48               471    480
     d  jrfl49               481    490
     d  jrfl50               491    500
     d  jrfl51               501    510
     d  jrfl52               511    520
     d  jrfl53               521    530
     d  jrfl54               531    540
     d  jrfl55               541    550
     d  jrfl56               551    560
     d  jrfl57               561    570
     d  jrfl58               571    580
     d  jrfl59               581    590
     d  jrfl60               591    600
     d  jrfl61               601    610
     d  jrfl62               611    620
     d  jrfl63               621    630
     d  jrfl64               631    640
     d  jrfl65               641    650
     d  jrfl66               651    660
     d  jrfl67               661    670
     d  jrfl68               671    680
     d  jrfl69               681    690
     d  jrfl70               691    700
     d  jrfl71               701    710
     d  jrfl72               711    720
     d  jrfl73               721    730
     d  jrfl74               731    740
     d  jrfl75               741    750
     d  jrfl76               751    760
     d  jrfl77               761    770
     d  jrfl78               771    780
     d  jrfl79               781    790
     d  jrfl80               791    800
     d  jrfl81               801    810
     d  jrfl82               811    820

     *  Libraries selected
     d selLibrs        ds           280
     d  jrlb01                 1     10
     d  jrlb02                11     20
     d  jrlb03                21     30
     d  jrlb04                31     40
     d  jrlb05                41     50
     d  jrlb06                51     60
     d  jrlb07                61     70
     d  jrlb08                71     80
     d  jrlb09                81     90
     d  jrlb10                91    100
     d  jrlb11               101    110
     d  jrlb12               111    120
     d  jrlb13               121    130
     d  jrlb14               131    140
     d  jrlb15               141    150
     d  jrlb16               151    160
     d  jrlb17               161    170
     d  jrlb18               171    180
     d  jrlb19               181    190
     d  jrlb20               191    200
     d  jrlb21               201    210
     d  jrlb22               211    220
     d  jrlb23               221    230
     d  jrlb24               231    240
     d  jrlb25               241    250
     d  jrlb26               251    260
     d  jrlb27               261    270
     d  jrlb28               271    280

     *  Journal Types selected
     d selJtypes       ds            18
     d  jrtp01                 1      2
     d  jrtp02                 3      4
     d  jrtp03                 5      6
     d  jrtp04                 7      8
     d  jrtp05                 9     10
     d  jrtp06                11     12
     d  jrtp07                13     14
     d  jrtp08                15     16
     d  jrtp09                17     18

        // *************************************************
        // MAIN PROC
        // *************************************************

        updJrnDta (jrlsts:jrlsdte:jrlstim:jrnlib:jname:jjob:
                   selFiles:selLibrs:selJtypes:'R');

        // Load 21 blanks in front of journal data as place holder for bfc fields
        FORMATTEDINPUT = '                               ' + ptype2;
        UNFORMATTEDINPUT = '                               ' + ptype2;

        // Process based on status code sent from RCVJRNE

        select;
          when %subst(pjocom:1:1)='0';
            // No journal entry being passed.  Simply return.  This
            // happens when RCVJRNE wakes up from no journal entry to
            // process wait time and still nothing to process.  Letting
            // exit program know it is running but nothing to process
            exsr updTsFile;
            return;
          when %subst(pjocom:1:1)='1';
            // Single entry sent.  No blocking (BLKLEN) on RCVJRNE
            oneEntry = pType2;
            exsr prcjrne;
            exsr updTsFile;
            return;
          when %subst(pjocom:1:1)='2';
            // Multiple enties sent with one call to RCVJRNE
            exsr multEntries;
            exsr updTsFile;
            return;
          when %subst(pjocom:1:1)='3';
            // System sends this status when the receiver changes for
            // the journal.  The system sends and will not end the
            // RCVJRNE process until return is given back from this
            // being sent.  Therefore we send a status to the RCVJRNE
            // submit process to know is being submitted for this
            // purpose instead of someone just tring to start a second
            // time in the case where this submit tries to run before
            // return can happen and the system ends this process.  In
            // that case it will delay 10 seconds and try again until
            // it can resubmit in the cl bening submitted below.
            // only restarts the RPG portion for this since the
            // receiver does not impact the JAVA portion
            cmd = 'CALL PGM(JS050CL) PARM((' + sq + 'J' + sq +
                  ') (' + sq + ' ' + sq + '))';
            cmd = 'SBMJOB CMD(' + %trim(cmd) + ') ' +
                  'JOBQ(QSYSNOMAX)';
            QCMDEXC(CMD:%LEN(CMD));
            return;
          when jocode = 'U';   // sent with SNDJRNE
            // If shutdown received then end gracefully;
            exsr applycurrts;
            if %scan('SHUTDOWNNOW':joesd)>0;
              exsr shutDownJava;
              %subst(pjocom:1:1)='9';
              return;
            endif;
        endsl;

        // When non data processed entries show up in the journal like
        // our user entry to shuwdown the process we need to update the
        // time to current timestamp so our last processed time will be
        // beyond the shutdown transaction or it will never restart and
        // get past that transaction

        begsr ApplyCurrTS;

          // update latest processed timestamp, date and time in settings area
          if %char(jotstp)<>' ';
            jrlsts = %char(jotstp);
            jrlsdte=%subst(jrlsts:6:2) + %subst(jrlsts:9:2) +
                    %subst(jrlsts:1:4);
            jrlstim=%subst(jrlsts:12:2) + %subst(jrlsts:15:2) +
                    %subst(jrlsts:18:2);
            updJrnDta (jrlsts:jrlsdte:jrlstim:jrnlib:jname:jjob:
                       selFiles:selLibrs:selJtypes:'U');
          endif;

        endsr;

        // Shutdown Java process

        begsr shutDownJava;

          // ensure journalscraper directory exists
          ifsPath = '/pirjava/journalscraper';
          %subst(ifsPath:100:1)='X';
     c                   call      'JS060CL'
     c                   parm                    ifspath         100
     c                   parm      '0'           pathBad           1
          if pathBad = '1';
             dirpath = '/pirjava/journalscraper';
             mode = M_readowner + M_writeowner + M_executeowner +
                    M_readother + M_writeother + M_executeother;
             return_mkdir = mkdir(%trim(dirpath):mode);
          endif;

          // create shutdown file to tell java to shutdown
          PathFile = '/pirjava/journalscraper/SHUTDOWN' + x'00';
          OpenMode = 'w, o_ccsid=1252' + x'00' ;

          FilePtr = OpenFile(%addr(PathFile):%addr(OpenMode)) ;
          if (FilePtr = *null) ;
          endif ;
          CloseFile(%addr(PathFile)) ;

        endsr;

        // loop thru incoming parm from RCVJRNE.  The first five bytes represent the
        // total length of incoming parm per KB.  The next five represent individual
        // length of journal entry, and after last entry you will have five zeros.
        // this is what will trigger the end and exit.

        begsr multEntries;

        nxtCharpos = 6;
        dow forever = forever;

          lenOfjrnEntry = %dec(%subst(pType2:nxtCharpos:5):5:0);
          oneEntry = %subst(pType2:nxtCharPos:lenOfjrnEntry);
          exsr prcjrne;
          nxtCharpos = nxtcharpos + lenOfJrnEntry;

          if nxtCharPos+5 > %len(pType2);
            return;
          endif;
          if %subst(pType2:nxtCharPos:5)='00000';
            return;
          endif;

        enddo;

        endsr;

        // confirm, open and override Timestamp file for this journal instance
        // This record is updated and checked by both the RPG and JAVA sides of this
        // journal scraper process.  The RPG side updates JRRPGTS with system timestamp
        // after each update and JAVA side updates JRJAVAJR after each update.  There
        // is a record written in here for each journal being processed on this LPAR/iSeries.
        // The RPG side will make sure no JAVA timestamp is more than 5 hours old
        // and the JAVA side will make sure no RPG timestamps are more than 5 hours old.
        // this will ensure both are running.  If fail then they send emails to Arun,
        // and Kyle

        begsr updTsFile;

        // confirm journal scraper timestamp file exist in journal output lib
        CMD = 'CHKOBJ OBJ(' + %trim(jrnlib) + '/JRNSCRAPTS) OBJTYPE(*FILE)';
        monitor;
          QCMDEXC(CMD:%LEN(CMD));
        on-error;
          // create  journal scraper timestamp file exist in journal output lib
          CMD = 'CRTPF FILE(' + %trim(jrnlib) +
                            '/JRNSCRAPTS) SRCFILE(QDDSFILES)';
          monitor;
            QCMDEXC(CMD:%LEN(CMD));
          on-error;
          endmon;
        endmon;

        // open journal scraper timestamp file.  Used by this program
        // and Java side to ensure all is running as it should
        CMD = 'OVRDBF '+ 'FILE(JRNSCRAPTS) TOFILE(' + %trim(jrnlib) +
              '/JRNSCRAPTS)' + ' LVLCHK(*NO) OVRSCOPE(*JOB)';
        QCMDEXC(CMD:%LEN(CMD));
        OPEN JRNSCRAPTS;

        exsr getTs;
        chain (jname) jrnscrapts;
        if %found(jrnscrapts);
          jrjobid=jjob;
          jrrpgts = systemTS;
          update(e) jrrec;
        else;
          jrname = jname;
          jrjobid=jjob;
          jrrpgts = systemTS;
          write(e) jrrec;
        endif;

        exsr confirmPRC;
        close jrnscrapts;
        cmd = 'DLTOVR JRNSCRAPTS LVL(*JOB)';
        QCMDEXC(CMD:%LEN(CMD));

        endsr;

        // Confirm that the Java process is running for it's portion of the Journal
        // Scraper process.  Also confirm that no other RPG instances appear to not
        // be running.  Anything on either side older than 1 hour will have a
        // communication sent.

        begsr conFirmPrc;

          // loop thru each journal on this lpar to ensure no issues
          // with either RPG or Java processes running

          setll *blanks jrnscrapts;

          dow forever = forever;
            read jrnscrapts;
            if %eof(jrnscrapts);
              leave;
            endif;

            // Confirm email has not been processed in last hour for this
            // Journal
            if jrlsemlts = ' ';
              jrlsemlts = '0001-01-01-00.00.00.000000';
            endif;
            if jrrpgts = ' ';
              jrrpgts = '0001-01-01-00.00.00.000000';
            endif;
            if jrjavats = ' ';
              jrjavats = '0001-01-01-00.00.00.000000';
            endif;

            exsr getTs;
            if %diff(%timestamp(systemTS):%timestamp(jrlsemlts):*minutes)<60;
              // iter for any journal where email sent in last hour
              iter;
            endif;

            if %diff(%timestamp(systemTS):%timestamp(jrrpgts):*minutes)>60;
              // Send email stating Instance and Journal RPG process not
              // ran in last hour or more
              cmd = 'BFCEMAIL EMAILTO(kennethe@bfcsoftware.com) SUBJECT(' + sq +
                    'RPG Journal Scraper Issue' + sq + ') BODY(' + sq +
                    'RPG Journal Scraper Instance ' + %trim(jjob) +
                    ' for Journal ' + %trim(jname) + ' Has not ran in the ' +
                    'last hour.  Please Correct ASAP.' + sq + ')';
              QCMDEXC(CMD:%LEN(CMD));
              jrlsemlts = systemTS;
              update jrrec;
              iter;
            endif;

            if %diff(%timestamp(systemTS):%timestamp(jrjavats):*minutes)>60;
              // Send email stating Instance and Journal JAVA process not
              // ran in last hour or more
              cmd = 'BFCEMAIL EMAILTO(kennethe@bfcsoftware.com) SUBJECT(' + sq +
                    'JAVA Journal Scraper Issue' + sq + ') BODY(' + sq +
                    'JAVA Journal Scraper Instance ' + %trim(jjob) +
                    ' for Journal ' + %trim(jname) + ' Has not ran in the ' +
                    'last hour.  Please Correct ASAP.' + sq + ')';
              QCMDEXC(CMD:%LEN(CMD));
              jrlsemlts = systemTS;
              update jrrec;
              iter;
            endif;

            // if reaches here just unlock record
            unlock jrnscrapts;
          enddo;

        endsr;

        // Process indivudal journal entry received.  This is called from main line
        // since RCVJRNE can pass single entries or block entries based on blklen
        // parm on RCVJRNE.  We block to reduce the number of calls to the exit pgm
        // from RCVJRNE

        begsr prcjrne;

        // Load 21 blanks in front of journal data as place holder for bfc fields
        FORMATTEDINPUT = '                               ' + oneEntry;
        UNFORMATTEDINPUT = '                               ' + oneEntry;

        // read up pass last processed transaction
        if jrlsts >= %char(jotstp);
          leavesr;
        endif;

        // if shutdown received then end gracefully;
        if jocode = 'U';   // sent with SNDJRNE
          if %scan('SHUTDOWNNOW':joesd)>0;
            exsr shutDownJava;
            %subst(pjocom:1:1)='9';
            exsr applyCurrTs;
            exsr updTsFile;
            return;
          endif;
        endif;

        // five zeros in joentl means nothing to process
        if joentl=00000;
          exsr updTsFile;
          return;
        endif;

        // ensure entry belongs to files(s) we are processing per the settings.
        // These settings can be viewed in by calling JS100
        if selfiles <> ' ';
          if %scan(joobj:selFiles) = 0;
            leavesr;
          endif;
        endif;

        // Ensure this journal came from a library we want to process
        if sellibrs <> ' ';
          if %scan(jolib:selLibrs) = 0;
            leavesr;
          endif;
        endif;

        // Ensure this journal type is one we want to process
        if seljtypes <> ' ';
          if %scan(joentt:seljtypes) = 0;
            leavesr;
          endif;
        endif;

        IF NOT TEMPJRNCREATED;
            STMTTXT = SQLCREATETABLE + 'QTEMP' + SQLCREATETEMP;
            EXEC SQL EXECUTE IMMEDIATE :STMTTXT;
            STMTTXT = SQLCREATETABLE + 'QTEMP' + SQLCREATEBFC;
            EXEC SQL EXECUTE IMMEDIATE :STMTTXT;
            TEMPJRNCREATED = *ON;
        ENDIF;

        IF %LOOKUP((%TRIM(JRNLIB) + %TRIM(JOOBJ)) : CREATEDTABLEARRAY ) = 0;
            STMTTXT = SQLCREATETABLE + %TRIM(JRNLIB) + '.' + %TRIM(JOOBJ)
                    + ' as (select * from ' + 'QTEMP' + '.TEMPBFC JOIN '
                    + 'QTEMP.TEMPJRN T2 ON 1=1 JOIN '
                    + %TRIM(JOLIB) + '.' + %TRIM(JOOBJ)
                    + ' T3 ON 1=1) '
                    + 'WITH NO DATA RCDFMT RFLAT';
            EXEC SQL EXECUTE IMMEDIATE :STMTTXT;
            LASTENTRYCREATEDTABLEARRAY += 1;
            CREATEDTABLEARRAY(LASTENTRYCREATEDTABLEARRAY) =
                %TRIM(JRNLIB) + %TRIM(JOOBJ);
        ENDIF;

        MYFILE = JOOBJ;
       // CMD = 'OVRDBF FLATFILE ' + %TRIM(MYFILE) +
        CMD = 'OVRDBF FLATFILE ' + %trim(jrnlib) + '/' +%TRIM(MYFILE) +
               ' LVLCHK(*NO) OVRSCOPE(*JOB)';
        QCMDEXC(CMD:%LEN(CMD));
        CMD = 'OVRDBF '+ %TRIM(MYFILE) + ' ' + %trim(jrnlib) + '/' +
              %trim(myfile) + ' LVLCHK(*NO) OVRSCOPE(*JOB)';
        QCMDEXC(CMD:%LEN(CMD));
        OPEN FLATFILE;
        // get bfc client info
      /end-free
     c                   call      'GETCLNTS'
     c                   parm      jolib         plib             10
     c                   parm      *blanks       pclnt1           10
     c                   parm      *blanks       pclnt2           10
      /free
        bfcstat='J';
        bfccli=pclnt1;
        bfccli2=pclnt2;
        bfcjrnnam=jname;
        FLATFILEDS = FORMATTEDINPUT;
        WRITE RFLAT FLATFILEDS;
        // update latest processed timestamp, date and time in settings area
        jrlsts = %char(jotstp);
        jrlsdte=%subst(jrlsts:6:2) + %subst(jrlsts:9:2) +
                %subst(jrlsts:1:4);
        jrlstim=%subst(jrlsts:12:2) + %subst(jrlsts:15:2) +
                %subst(jrlsts:18:2);
        exsr ApplyCurrTs;

        CLOSE FLATFILE;
        cmd = 'DLTOVR ' + %trim(MYFILE) + ' LVL(*JOB)';
        QCMDEXC(CMD:%LEN(CMD));
        cmd = 'DLTOVR FLATFILE LVL(*JOB)';
        QCMDEXC(CMD:%LEN(CMD));

        endsr;

    *----------------------------------------------------------------
     *  getTs      Get and Retrun System Timestamp.  This is retrieved
     *             using iSeries SQL to prevent the adjustment for timezone
     *             via Timezone400
     *----------------------------------------------------------------
        begsr getTs;

           exec sql set :systemTS = now(6);

        endsr;

        END-PROC;
