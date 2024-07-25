     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd. #8-51
     *   West Chicago, IL 60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  JS050     Journal Scraper Submit
     *  15 February 2024
     *  Kenneth Elder
     *
     *  Revisions
     *
780 A*    02/15/24  KDE  7.80
     *      - Created
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
780aAFjrnscraptsuf a e           k disk
     f                                     prefix(j_)

     *----------------------------------------------------------------
     *  Data Areas
     *----------------------------------------------------------------

     D jrndtaara       s           2000    dtaara('JRNDTAARA')

     *----------------------------------------------------------------
     *  Data Structure to breakout Data Area settings
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    JRNAME  -  Journal Name
     *    JRLIBL  -  Journal Library
     *    EXTPGM  -  Exit Program
     *    ExtPgmLib  Exit Program Library
     *    Files01 -  File 1 of 34
     *    Files02 -  File 2 of 34
     *    Files03 -  File 3 of 34
     *    Files04 -  File 4 of 34
     *    Files05 -  File 5 of 34
     *    Files06 -  File 6 of 34
     *    Files07 -  File 7 of 34
     *    Files08 -  File 8 of 34
     *    Files09 -  File 9 of 34
     *    Files10 -  File 10 of 34
     *    Files11 -  File 11 of 34
     *    Files12 -  File 12 of 34
     *    Files13 -  File 13 of 34
     *    Files14 -  File 14 of 34
     *    Files15 -  File 15 of 34
     *    Files16 -  File 16 of 34
     *    Files17 -  File 17 of 34
     *    Files18 -  File 18 of 34
     *    Files19 -  File 19 of 34
     *    Files01 -  File 20 of 34
     *    Files01 -  File 21 of 34
     *    Files01 -  File 22 of 34
     *    Files01 -  File 23 of 34
     *    Files01 -  File 24 of 34
     *    Files01 -  File 25 of 34
     *    Files01 -  File 26 of 34
     *    Files01 -  File 27 of 34
     *    Files01 -  File 28 of 34
     *    Files01 -  File 29 of 34
     *    Files01 -  File 30 of 34
     *    Files01 -  File 31 of 34
     *    Files01 -  File 32 of 34
     *    Files01 -  File 33 of 34
     *    Files01 -  File 34 of 34
     *    Files01 -  File 35 of 82
     *    Files01 -  File 36 of 82
     *    Files01 -  File 37 of 82
     *    Files01 -  File 38 of 82
     *    Files01 -  File 39 of 82
     *    Files01 -  File 40 of 82
     *    Files01 -  File 41 of 82
     *    Files01 -  File 42 of 82
     *    Files01 -  File 43 of 82
     *    Files01 -  File 44 of 82
     *    Files01 -  File 45 of 82
     *    Files01 -  File 46 of 82
     *    Files01 -  File 47 of 82
     *    Files01 -  File 48 of 82
     *    Files01 -  File 49 of 82
     *    Files01 -  File 50 of 82
     *    Files01 -  File 51 of 82
     *    Files01 -  File 52 of 82
     *    Files01 -  File 53 of 82
     *    Files01 -  File 54 of 82
     *    Files01 -  File 55 of 82
     *    Files01 -  File 56 of 82
     *    Files01 -  File 57 of 82
     *    Files01 -  File 58 of 82
     *    Files01 -  File 59 of 82
     *    Files01 -  File 60 of 82
     *    Files01 -  File 61 of 82
     *    Files01 -  File 62 of 82
     *    Files01 -  File 63 of 82
     *    Files01 -  File 64 of 82
     *    Files01 -  File 65 of 82
     *    Files01 -  File 66 of 82
     *    Files01 -  File 67 of 82
     *    Files01 -  File 68 of 82
     *    Files01 -  File 69 of 82
     *    Files01 -  File 70 of 82
     *    Files01 -  File 71 of 82
     *    Files01 -  File 72 of 82
     *    Files01 -  File 73 of 82
     *    Files01 -  File 74 of 82
     *    Files01 -  File 75 of 82
     *    Files01 -  File 76 of 82
     *    Files01 -  File 77 of 82
     *    Files01 -  File 78 of 82
     *    Files01 -  File 79 of 82
     *    Files01 -  File 80 of 82
     *    Files01 -  File 81 of 82
     *    Files01 -  File 82 of 82
     *    Libr01  -  File 1 of 16
     *    Libr02  -  File 2 of 16
     *    Libr03  -  File 3 of 16
     *    Libr04  -  File 4 of 16
     *    Libr05  -  File 5 of 16
     *    Libr06  -  File 6 of 16
     *    Libr07  -  File 7 of 16
     *    Libr08  -  File 8 of 16
     *    Libr09  -  File 9 of 16
     *    Libr10  -  File 10 of 16
     *    Libr11  -  File 11 of 16
     *    Libr12  -  File 12 of 16
     *    Libr13  -  File 13 of 16
     *    Libr14  -  File 14 of 16
     *    Libr15  -  File 15 of 16
     *    Libr16  -  File 16 of 16
     *    JRTP01  -  Jrn Type 1 of 9
     *    JRTP02  -  Jrn Type 2 of 9
     *    JRTP03  -  Jrn Type 3 of 9
     *    JRTP04  -  Jrn Type 4 of 9
     *    JRTP05  -  Jrn Type 5 of 9
     *    JRTP06  -  Jrn Type 6 of 9
     *    JRTP07  -  Jrn Type 7 of 9
     *    JRTP08  -  Jrn Type 8 of 9
     *    JRTP09  -  Jrn Type 9 of 9
     *    JRLSTS  -  Last processed Timestamp
     *    JRLSDTE -  Last Date Processed (mmddccyy)
     *    JRLSTIM -  Last Time Processed (hhmmss)
     *    JROUTLIB - Jrn Entry Output Lib
     *    JRJOBID  - Job occurrence to track test and production
     *
     * Data structure
     *
     d dataAreas       ds
     d  jrname                 1     10
     d  jrlibr                11     20
     d  extpgm                21     30
     d  extpgmlib             31     40
     d  files01               41     50
     d  files02               51     60
     d  files03               61     70
     d  files04               71     80
     d  files05               81     90
     d  files06               91    100
     d  files07              101    110
     d  files08              111    120
     d  files09              121    130
     d  files10              131    140
     d  files11              141    150
     d  files12              151    160
     d  files13              161    170
     d  files14              171    180
     d  files15              181    190
     d  files16              191    200
     d  files17              201    210
     d  files18              211    220
     d  files19              221    230
     d  files20              231    240
     d  files21              241    250
     d  files22              251    260
     d  files23              261    270
     d  files24              271    280
     d  files25              281    290
     d  files26              291    300
     d  files27              301    310
     d  files28              311    320
     d  files29              321    330
     d  files30              331    340
     d  files31              341    350
     d  files32              351    360
     d  files33              361    370
     d  files34              371    380
     d  files35              381    390
     d  files36              391    400
     d  files37              401    410
     d  files38              411    420
     d  files39              421    430
     d  files40              431    440
     d  files41              441    450
     d  files42              451    460
     d  files43              461    470
     d  files44              471    480
     d  files45              481    490
     d  files46              491    500
     d  files47              501    510
     d  files48              511    520
     d  files49              521    530
     d  files50              531    540
     d  files51              541    550
     d  files52              551    560
     d  files53              561    570
     d  files54              571    580
     d  files55              581    590
     d  files56              591    600
     d  files57              601    610
     d  files58              611    620
     d  files59              621    630
     d  files60              631    640
     d  files61              641    650
     d  files62              651    660
     d  files63              661    670
     d  files64              671    680
     d  files65              681    690
     d  files66              691    700
     d  files67              701    710
     d  files68              711    720
     d  files69              721    730
     d  files70              731    740
     d  files71              741    750
     d  files72              751    760
     d  files73              761    770
     d  files74              771    780
     d  files75              781    790
     d  files76              791    800
     d  files77              801    810
     d  files78              811    820
     d  files79              821    830
     d  files80              831    840
     d  files81              841    850
     d  files82              851    860
     d  libr01               861    870
     d  libr02               871    880
     d  libr03               881    890
     d  libr04               891    900
     d  libr05               901    910
     d  libr06               911    920
     d  libr07               921    930
     d  libr08               931    940
     d  libr09               941    950
     d  libr10               951    960
     d  libr11               961    970
     d  libr12               971    980
     d  libr13               981    990
     d  libr14               991   1000
     d  libr15              1001   1010
     d  libr16              1011   1020
     d  libr17              1021   1030
     d  libr18              1031   1040
     d  libr19              1041   1050
     d  libr20              1051   1060
     d  libr21              1061   1070
     d  libr22              1071   1080
     d  libr23              1081   1090
     d  libr24              1091   1100
     d  libr25              1101   1110
     d  libr26              1111   1120
     d  libr27              1121   1130
     d  libr28              1131   1140
     d  jrtp01              1141   1142
     d  jrtp02              1143   1144
     d  jrtp03              1145   1146
     d  jrtp04              1147   1148
     d  jrtp05              1149   1150
     d  jrtp06              1151   1152
     d  jrtp07              1153   1154
     d  jrtp08              1155   1156
     d  jrtp09              1157   1158
     d  jrlsts              1159   1184
     d  jrlsdte             1185   1192
     d  jrlstim             1193   1198
     d  jroutlib            1199   1208
     d  jrjobid             1209   1218

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     d  @msgid                40     46
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcount         s              3p 0
     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10
     d javasbm         s               n
     d cnt             s              2  0
     d wkjobid         s             20
     d sq              c                   const(x'7d')
     d sqlstmt         s           1000

     D $vcode          s              2
     D $vsys           s              1

     *----------------------------------------------------------------
     *  Misc variables created by RPG4MAX.
     *----------------------------------------------------------------

     D cmdString       S            512
     D cmdLength       S             15  5

     D Execute         PR                  ExtPgm('QCMDEXC')
     D     CmdStr                   512    Options(*VarSize) const
     D     CmdLen                    15  5 Const

     ***  Get SQL timestamp since it is not adjusted by Timezone 400
     d systemTS        pr              z

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    errmsg           70

     c                   eval      *inlr = '1'
     C                   exsr      zzinz2
     C                   return
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
     *  Initialize message handling
     *
     C*                  exsr      zmimsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZsbmjob   Load, check and submit Journal Scraper process
     *
     C     zzsbmJob      begsr
                         in(e) jrndtaara;

           if %error;
             errmsg='Problem opening Data Area JRNDTAARA';
             return;
           endif;

           dataareas = jrndtaara;

           // Confirm required info is setup
           if jrname=' ' or jrlibr=' ' or extpgm=' ' or
              extpgmlib=' ' or jrlsts=' ' or jroutlib=' '
              or jrjobid=' ';
             errmsg = 'Required setup missing.  Run setup option from ' +
                      'menu to correct';
             return;
           endif;

           select;
             when not javasbm;    // RPG JRNSCRAPER submit

               wkjobid=%trim(jrjobid) + 'R';
               // Confirm that job is not already processing
               sqlStmt = 'select count(*) from TABLE(QSYS2.ACTIVE_JOB_INFO' +
                         '(DETAILED_INFO => ' + sq + 'ALL' + sq + ')) X ' +
                         'where job_name like ' + sq + '%' + %trim(wkjobid) +
                         '%' + sq;
               exec sql PREPARE aj FROM :SqlStmt;
               exec sql DECLARE actjb SCROLL CURSOR FOR aj;
               exec sql OPEN actjb;
               exec sql fetch next from actjb into :cnt;
               exec sql close actjb;
               if sqlstt <> '00000' or cnt>0;
                 errmsg = 'ARP - Journal Scraper for instance -- ' +
                          %trim(wkjobid) + ' -- already processing';
                 return;
               endif;

               // generate command to start journal scraper process
               cmdString = 'RCVJRNE JRN(';
               if %trim(jrlibr) <>'' and %trim(jrlibr)<>'*libl' and
                 %trim(jrlibr)<>'*LIBL';
                 cmdString = %trim(cmdString) + %trim(jrlibr) + '/';
               endif;

               cmdString = %trim(cmdString) + %trim(jrname) + ') EXITPGM(';
               if %trim(extpgmlib) <>'' and %trim(extpgmlib)<>'*libl' and
                 %trim(extpgmlib)<>'*LIBL';
                 cmdString = %trim(cmdString) + %trim(extpgmlib) + '/';
               endif;
               cmdString = %trim(cmdString) + %trim(extpgm) + ') FILE(';

               // We send all files and the Journal Scraper will determine if
               // file sent is included.  If you start with specific files and
               // no entries exist it will not start
               cmdString = %trim(cmdString) + '*ALLFILE)';
               cmdString = %trim(cmdString) + ' RCVRNG(*CURCHAIN)';
               if jrlsdte<>' ' and jrlstim<>' ';
                 cmdString = %trim(cmdString) + ' FROMTIME(' + %trim(jrlsdte) +
                             ' ' + %trim(jrlstim) + ')';
               endif;
               cmdString = %trim(cmdString) + ' JRNCDE((R) (U))';
               cmdString = %trim(cmdString) + ' ENTFMT(*TYPE3)';
               cmdString = %trim(cmdString) + ' BLKLEN(32)';
               cmdString = %trim(cmdString) + ' DELAY(10)';

               // Build submit command for RPG job (JRNSCRAPER)
               cmdString = 'SBMJOB CMD(' + %trim(cmdString) + ') ' +
                           'JOB(' + %trim(wkjobid) + ') ' +
                           'JOBQ(QSYSNOMAX) LOG(4 0 *NOLIST) LOGCLPGM(*NO)' +
                           ' JOBMSGQFL(*WRAP)';

             when javasbm;    // JAVA AWSCONNECTOR submit

               // Confirm that job is not already processing JAVA
               if jrjobid<>*blanks;
                 if %subst(jrjobid:7:1) = 'P' or %subst(jrjobid:7:1) = 'T';
                   wkjobid='JRNJVA' + %subst(jrjobid:7:1) + 'J';
                 else;
                   return;
                 endif;
               else;
                 return;
               endif;
               sqlStmt = 'select count(*) from TABLE(QSYS2.ACTIVE_JOB_INFO' +
                         '(DETAILED_INFO => ' + sq + 'ALL' + sq + ')) X ' +
                         'where job_name like ' + sq + '%' + %trim(wkjobid) +
                         '%' + sq;
               exec sql PREPARE a1 FROM :SqlStmt;
               exec sql DECLARE ac1jb SCROLL CURSOR FOR a1;
               exec sql OPEN ac1jb;
               exec sql fetch next from ac1jb into :cnt;
               exec sql close ac1jb;
               if sqlstt <> '00000' or cnt>0;
                 errmsg = 'ARP - Journal Scraper for instance -- ' +
                          %trim(wkjobid) + ' -- already processing';
                 return;
               endif;

               // Build submit command for JAVA job (AWSCONNECTOR)
               cmdString = 'SBMJOB CMD(CALL PGM(AWSCONNECT)) ' +
                           'JOB(' + %trim(wkjobid) + ') ' +
                           'JOBQ(QSYSNOMAX)';

           endsl;

           monitor;
             Execute(cmdString:%len(cmdString));

             chain (jrname) jrnscrapts;
              if %found(jrnscrapts);
               j_jrjobid=jrjobid;
               j_jrlsemlts = %char(systemTS());
               update(e) jrrec;
             else;
               j_jrname = jrname;
               j_jrjobid=jrjobid;
               j_jrlsemlts = %char(systemTS());
               write(e) jrrec;
             endif;

           on-error;
             errmsg = 'Error trying to submit RCVJRNE ' +
                      '(Journal Scraping process)';
             return;
           endmon;

           errmsg = 'Journal Scraper instance -- ' +
                    %trim(wkjobid) + ' -- has been submitted';

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   see if java versus RPG
     *
                         if errmsg='JAVA';
                           javasbm = *on;
                           errmsg = ' ';
                         else;
                           javasbm = *off;
                         endif;
     *
     *   Submit job to run
     *
     C                   exsr      zzsbmjob
     C     endin2        endsr

    *----------------------------------------------------------------
     *  systemTS   Get and Retrun System Timestamp.  This is retrieved
     *             using iSeries SQL to prevent the adjustment for timezone
     *             via Timezone400
     *----------------------------------------------------------------
     P systemTS        b
     D systemTS        pi              z

     D rtnTs           s               z

           exec sql select current timestamp into :rtnTs
                       from sysibm.sysdummy1;
           return rtnTs;

     P systemTS        e
