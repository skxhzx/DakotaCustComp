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
     *  JS100     Journal Scraper Settings
     *  13 February 2024
     *  Kenneth Elder
     *
     *  Revisions
     *
780 A*    02/13/24  KDE  7.80
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

780aAFJS100FM   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)

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
     *    Files01 -  File 1 of 82
     *    Files02 -  File 2 of 82
     *    Files03 -  File 3 of 82
     *    Files04 -  File 4 of 82
     *    Files05 -  File 5 of 82
     *    Files06 -  File 6 of 82
     *    Files07 -  File 7 of 82
     *    Files08 -  File 8 of 82
     *    Files09 -  File 9 of 82
     *    Files10 -  File 10 of 82
     *    Files11 -  File 11 of 82
     *    Files12 -  File 12 of 82
     *    Files13 -  File 13 of 82
     *    Files14 -  File 14 of 82
     *    Files15 -  File 15 of 82
     *    Files16 -  File 16 of 82
     *    Files17 -  File 17 of 82
     *    Files18 -  File 18 of 82
     *    Files19 -  File 19 of 82
     *    Files01 -  File 20 of 82
     *    Files01 -  File 21 of 82
     *    Files01 -  File 22 of 82
     *    Files01 -  File 23 of 82
     *    Files01 -  File 24 of 82
     *    Files01 -  File 25 of 82
     *    Files01 -  File 26 of 82
     *    Files01 -  File 27 of 82
     *    Files01 -  File 28 of 82
     *    Files01 -  File 29 of 82
     *    Files01 -  File 30 of 82
     *    Files01 -  File 31 of 82
     *    Files01 -  File 32 of 82
     *    Files01 -  File 33 of 82
     *    Files01 -  File 34 of 82
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

     *  Screen file data structure
     d scrnFiles       ds           820
     d  w1fl01                 1     10
     d  w1fl02                11     20
     d  w1fl03                21     30
     d  w1fl04                31     40
     d  w1fl05                41     50
     d  w1fl06                51     60
     d  w1fl07                61     70
     d  w1fl08                71     80
     d  w1fl09                81     90
     d  w1fl10                91    100
     d  w1fl11               101    110
     d  w1fl12               111    120
     d  w1fl13               121    130
     d  w1fl14               131    140
     d  w1fl15               141    150
     d  w1fl16               151    160
     d  w1fl17               161    170
     d  w1fl18               171    180
     d  w1fl19               181    190
     d  w1fl20               191    200
     d  w1fl21               201    210
     d  w1fl22               211    220
     d  w1fl23               221    230
     d  w1fl24               231    240
     d  w1fl25               241    250
     d  w1fl26               251    260
     d  w1fl27               261    270
     d  w1fl28               271    280
     d  w1fl29               281    290
     d  w1fl30               291    300
     d  w1fl31               301    310
     d  w1fl32               311    320
     d  w1fl33               321    330
     d  w1fl34               331    340
     d  w1fl35               341    350
     d  w1fl36               351    360
     d  w1fl37               361    370
     d  w1fl38               371    380
     d  w1fl39               381    390
     d  w1fl40               391    400
     d  w1fl41               401    410
     d  w1fl42               411    420
     d  w1fl43               421    430
     d  w1fl44               431    440
     d  w1fl45               441    450
     d  w1fl46               451    460
     d  w1fl47               461    470
     d  w1fl48               471    480
     d  w1fl49               481    490
     d  w1fl50               491    500
     d  w1fl51               501    510
     d  w1fl52               511    520
     d  w1fl53               521    530
     d  w1fl54               531    540
     d  w1fl55               541    550
     d  w1fl56               551    560
     d  w1fl57               561    570
     d  w1fl58               571    580
     d  w1fl59               581    590
     d  w1fl60               591    600
     d  w1fl61               601    610
     d  w1fl62               611    620
     d  w1fl63               621    630
     d  w1fl64               631    640
     d  w1fl65               641    650
     d  w1fl66               651    660
     d  w1fl67               661    670
     d  w1fl68               671    680
     d  w1fl69               681    690
     d  w1fl70               691    700
     d  w1fl71               701    710
     d  w1fl72               711    720
     d  w1fl73               721    730
     d  w1fl74               731    740
     d  w1fl75               741    750
     d  w1fl76               751    760
     d  w1fl77               761    770
     d  w1fl78               771    780
     d  w1fl79               781    790
     d  w1fl80               791    800
     d  w1fl81               801    810
     d  w1fl82               811    820

     *  Screen library data structure
     d scrnLibrs       ds           280
     d  w1lb01                 1     10
     d  w1lb02                11     20
     d  w1lb03                21     30
     d  w1lb04                31     40
     d  w1lb05                41     50
     d  w1lb06                51     60
     d  w1lb07                61     70
     d  w1lb08                71     80
     d  w1lb09                81     90
     d  w1lb10                91    100
     d  w1lb11               101    110
     d  w1lb12               111    120
     d  w1lb13               121    130
     d  w1lb14               131    140
     d  w1lb15               141    150
     d  w1lb16               151    160
     d  w1lb17               161    170
     d  w1lb18               171    180
     d  w1lb19               181    190
     d  w1lb20               191    200
     d  w1lb21               201    210
     d  w1lb22               211    220
     d  w1lb23               221    230
     d  w1lb24               231    240
     d  w1lb25               241    250
     d  w1lb26               251    260
     d  w1lb27               261    270
     d  w1lb28               271    280

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
     *  Workstation exception data structure
     *----------------------------------------------------------------

     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371

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

     D $vcode          s              2
     D $vsys           s              1

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     D                 ds
     D  $ec                    1      2p 0

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  Misc variables created by RPG4MAX.
     *----------------------------------------------------------------

     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D tmpflg          s              1
     D warn            s              1
     d loopidx         s              4  0
     d filenamex       s             10
     d chkobjcnt       s              4  0
     D cmdString       S            256
     D cmdLength       S             15  5
     d cnt             s              4  0
     d wkjobid         s             20
     d sq              c                   const(x'7d')
     d sqlstmt         s           1000

     ***  Get SQL timestamp since it is not adjusted by Timezone 400
     d systemTS        pr              z

     D Execute         PR                  ExtPgm('QCMDEXC')
     D     CmdStr                   256    Options(*VarSize) const
     D     CmdLen                    15  5 Const

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     c                   eval      *inlr = '1'
     C                   eval      *in97 = *on
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = '1'
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = '1'
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
     C                   if        nxtscr = '01 '
     c                   if        *in90=*on
               errmsg = 'End Journal Scraper to make changes';
                         exsr zm0105;
                         endif;
     C                   exfmt     screen1                              50
     C                   endif

     C                   if        nxtscr = '02 '
     c                   if        *in90=*on
               errmsg = 'End Journal Scraper to make changes';
                         exsr zm0105;
                         endif;
     C                   exfmt     screen2                              50
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
     *
     *  Screen 01 initialization
     *
     C     scr01i        begsr
     C                   eval      nxtscr = '01 '
     *
     *  get existing settings
     *
     C                   eval      *in91 = *on
     C                   exsr      zzfil1
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
     C                   if        *in90=*off
     C                   exsr      zzupd1
     c                   endif
     C     error         cabeq     '1'           endsc1
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = '02'
     C     endsc1        endsr
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = '01'
     C                   goto      endsc2
     C                   endif
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2
     C     error         cabeq     '1'           endsc2
     C                   if        *in90=*off
     C                   exsr      zzupd2
     c                   endif
     C     error         cabeq     '1'           endsc2
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
     C     endsc2        endsr
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
     C                   exsr      zmimsg
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr
     *
     *    ZMPMSG  Add message record to subfile
     *
     C     zmpmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off

     *  Confirm jobid exists.  It is on the user to specify different libraries
     *  for source and outlib for journal output if it should be different.  This
     *  value is ONLY being used to determine if this job is active when submitting

           if w1jobid = *blanks;
             error = *on;
             errmsg = 'Occurrence is required. Unique jobid';
             exsr zm0105;
           endif;

     *  Confirm journal exist

           exec sql select count(*) into :chkobjcnt
              from qsys2/jrninfo
             where journal_name=:w1jrnm and journal_library=:w1jrlb
                and journal_type='*LOCAL' and journal_state='*ACTIVE';
           if sqlstt <> '00000' or chkobjcnt=0;
             error = *on;
             errmsg = 'Jrn/Jrn Library -- ' +
                      %trim(w1jrlb) + '/' + %trim(w1jrnm) +
                      '-- is invalid';
             exsr zm0105;
           endif;

     *  Confirm files as being valid

           loopIdx = 1;
           dow loopidx <820;
             if %subst(scrnfiles:loopIdx:10) <> *blanks;
               filenamex = %subst(scrnfiles:loopIdx:10);
               exec sql select count(*) into :chkobjcnt
                  from qsys2/systables
                 where TABLE_NAME=:filenamex;
               if sqlstt <> '00000' or chkobjcnt=0;
                 error = *on;
                 errmsg = 'File -- ' + %trim(filenamex) + '-- is invalid';
                 exsr zm0105;
                 leave;
               endif;
             endif;
             loopidx = loopidx + 10;
           enddo;

     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off

     *  Confirm libraries as being valid

           loopIdx = 1;
           dow loopidx <280;
             if %subst(scrnlibrs:loopIdx:10) <> *blanks;
               filenamex = %subst(scrnlibrs:loopIdx:10);
               exec sql select count(*) into :chkobjcnt
                  from qsys2/sysschemas
                 where SCHEMA_NAME=:filenamex ;
               if sqlstt <> '00000' or chkobjcnt=0;
                 error = *on;
                 errmsg = 'Library -- ' + %trim(filenamex) + '-- is invalid';
                 exsr zm0105;
                 leave;
               endif;
             endif;
             loopidx = loopidx + 10;
           enddo;

     *  Confirm output library for produced journal data

           exec sql select count(*) into :chkobjcnt
              from qsys2/sysschemas
             where SCHEMA_NAME=:w1outlib;
           if sqlstt <> '00000' or chkobjcnt=0;
             error = *on;
             errmsg = 'JRN output library -- ' + %trim(w1outlib) +
                      ' -- is invalid';
             exsr zm0105;
           endif;

     *  Confirm output library for produced journal data

           if w1jrtp01<>'00' and w1jrtp02<>'00' and w1jrtp03<>'0'
             and w1jrtp04<>'00' and w1jrtp05<>'00' and w1jrtp06<>'00'
             and w1jrtp07<>'00' and w1jrtp08<>'00' and w1jrtp09<>'00';
             error = *on;
             errmsg = 'Journal type 00 is required';
             exsr zm0105;
           endif;

     *  Validate Exit Program and library combination

           cmdString = 'CHKOBJ OBJ(';
           if w1exlb <> '*LIBL';
             cmdString = %trim(cmdString) + %trim(w1exlb) + '/';
           endif;
           cmdString = %trim(cmdString) + %trim(w1expg) + ')' +
                       ' OBJTYPE(*PGM)';
           monitor;
             Execute(cmdString:%len(cmdString));
           on-error;
             error = *on;
             errmsg = 'Journal Exit Library/Program combination invalid';
             exsr zm0105;
           endmon;

     *  Confirm timestamp is valid

           if w1lsts <> ' ';
             test(ze) w1lsts;
             if %error;
               error = *on;
               errmsg = 'Timestamp is invalid';
               exsr zm0105;
             endif;
           endif;

     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from journal scraper data area
     *
     C     zzfil1        begsr
                         *in90=*off;
                         in(e) jrndtaara;
                         dataareas = jrndtaara;
     C                   eval      w1jrnm = jrname
     C                   eval      w1jrlb = jrlibr
     C                   eval      w1expg = extpgm
     C                   eval      w1exlb = extpgmlib
     C                   eval      w1fl01 = files01
     C                   eval      w1fl02 = files02
     C                   eval      w1fl03 = files03
     C                   eval      w1fl04 = files04
     C                   eval      w1fl05 = files05
     C                   eval      w1fl06 = files06
     C                   eval      w1fl07 = files07
     C                   eval      w1fl08 = files08
     C                   eval      w1fl09 = files09
     C                   eval      w1fl10 = files10
     C                   eval      w1fl11 = files11
     C                   eval      w1fl12 = files12
     C                   eval      w1fl13 = files13
     C                   eval      w1fl14 = files14
     C                   eval      w1fl15 = files15
     C                   eval      w1fl16 = files16
     C                   eval      w1fl17 = files17
     C                   eval      w1fl18 = files18
     C                   eval      w1fl19 = files19
     C                   eval      w1fl20 = files20
     C                   eval      w1fl21 = files21
     C                   eval      w1fl22 = files22
     C                   eval      w1fl23 = files23
     C                   eval      w1fl24 = files24
     C                   eval      w1fl25 = files25
     C                   eval      w1fl26 = files26
     C                   eval      w1fl27 = files27
     C                   eval      w1fl28 = files28
     C                   eval      w1fl29 = files29
     C                   eval      w1fl30 = files30
     C                   eval      w1fl31 = files31
     C                   eval      w1fl32 = files32
     C                   eval      w1fl33 = files33
     C                   eval      w1fl34 = files34
     C                   eval      w1fl35 = files35
     C                   eval      w1fl36 = files36
     C                   eval      w1fl37 = files37
     C                   eval      w1fl38 = files38
     C                   eval      w1fl39 = files39
     C                   eval      w1fl40 = files40
     C                   eval      w1fl41 = files41
     C                   eval      w1fl42 = files42
     C                   eval      w1fl43 = files43
     C                   eval      w1fl44 = files44
     C                   eval      w1fl45 = files45
     C                   eval      w1fl46 = files46
     C                   eval      w1fl47 = files47
     C                   eval      w1fl48 = files48
     C                   eval      w1fl49 = files49
     C                   eval      w1fl50 = files40
     C                   eval      w1fl51 = files51
     C                   eval      w1fl52 = files52
     C                   eval      w1fl53 = files53
     C                   eval      w1fl54 = files54
     C                   eval      w1fl55 = files55
     C                   eval      w1fl56 = files56
     C                   eval      w1fl57 = files57
     C                   eval      w1fl58 = files58
     C                   eval      w1fl59 = files59
     C                   eval      w1fl60 = files60
     C                   eval      w1fl61 = files61
     C                   eval      w1fl62 = files62
     C                   eval      w1fl63 = files63
     C                   eval      w1fl64 = files64
     C                   eval      w1fl65 = files65
     C                   eval      w1fl66 = files66
     C                   eval      w1fl67 = files67
     C                   eval      w1fl68 = files68
     C                   eval      w1fl69 = files69
     C                   eval      w1fl70 = files70
     C                   eval      w1fl71 = files71
     C                   eval      w1fl72 = files72
     C                   eval      w1fl73 = files73
     C                   eval      w1fl74 = files74
     C                   eval      w1fl75 = files75
     C                   eval      w1fl76 = files76
     C                   eval      w1fl77 = files77
     C                   eval      w1fl78 = files78
     C                   eval      w1fl79 = files79
     C                   eval      w1fl80 = files80
     C                   eval      w1fl81 = files81
     C                   eval      w1fl82 = files82
     c                   eval      w1lb01 = libr01
     c                   eval      w1lb02 = libr02
     c                   eval      w1lb03 = libr03
     c                   eval      w1lb04 = libr04
     c                   eval      w1lb05 = libr05
     c                   eval      w1lb06 = libr06
     c                   eval      w1lb07 = libr07
     c                   eval      w1lb08 = libr08
     c                   eval      w1lb09 = libr09
     c                   eval      w1lb10 = libr10
     c                   eval      w1lb11 = libr11
     c                   eval      w1lb12 = libr12
     c                   eval      w1lb13 = libr13
     c                   eval      w1lb14 = libr14
     c                   eval      w1lb15 = libr15
     c                   eval      w1lb16 = libr16
     c                   eval      w1lb17 = libr17
     c                   eval      w1lb18 = libr18
     c                   eval      w1lb19 = libr19
     c                   eval      w1lb20 = libr20
     c                   eval      w1lb21 = libr21
     c                   eval      w1lb22 = libr22
     c                   eval      w1lb23 = libr23
     c                   eval      w1lb24 = libr24
     c                   eval      w1lb25 = libr25
     c                   eval      w1lb26 = libr26
     c                   eval      w1lb27 = libr27
     c                   eval      w1lb28 = libr28
     c                   eval      w1jrtp01 = jrtp01
     c                   eval      w1jrtp02 = jrtp02
     c                   eval      w1jrtp03 = jrtp03
     c                   eval      w1jrtp04 = jrtp04
     c                   eval      w1jrtp05 = jrtp05
     c                   eval      w1jrtp06 = jrtp06
     c                   eval      w1jrtp07 = jrtp07
     c                   eval      w1jrtp08 = jrtp08
     c                   eval      w1jrtp09 = jrtp09
     c                   eval      w1lsts = jrlsts
     c                   eval      w1outlib = jroutlib
     c                   eval      w1jobid = jrjobid
                         if w1jrnm=*blanks;
                           w1jrnm='PIRJRN';
                         endif;
                         if w1jrlb=*blanks;
                           w1jrlb='PIRJRNF';
                         endif;
                         if w1expg=*blanks;
                           w1expg='JRNSCRAPER';
                         endif;
                         if w1exlb=*blanks;
                           w1exlb='*LIBL';
                         endif;
                         if w1lsts=*blanks;
                           w1lsts=%char(systemTS());
                         endif;
                         if w1jrtp01=' ' and w1jrtp02=' ' and w1jrtp03=' ' and
                            w1jrtp04=' ' and w1jrtp05=' ' and w1jrtp06=' ' and
                            w1jrtp07=' ' and w1jrtp08=' ' and w1jrtp09=' ';
                            w1jrtp01='PT';
                            w1jrtp02='PX';
                            w1jrtp03='DL';
                            w1jrtp04='UP';
                            w1jrtp04='00';
                         endif;
                         if w1outlib=*blanks;
                           w1outlib='JRNWKLIB';
                         endif;

           // Protect fields if options jobid is running
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
             *in90=*on;
           endif;
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Select first screen to display.
     *
           rptttl = '      Journal Scraper Settings   ';

           exsr scr01i;

     C     endin2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Go to Screen2 and perform updates there
     *
     C     zzupd1        begsr

     C                   eval      nxtscr = '02 '
     *
     C     endupd1       endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
                         in(e) *lock jrndtaara;
     C                   eval      jrname = w1jrnm
     C                   eval      jrlibr = w1jrlb
     C                   eval      extpgm = w1expg
     C                   eval      extpgmlib = w1exlb
     C                   eval      files01 = w1fl01
     C                   eval      files02 = w1fl02
     C                   eval      files03 = w1fl03
     C                   eval      files04 = w1fl04
     C                   eval      files05 = w1fl05
     C                   eval      files06 = w1fl06
     C                   eval      files07 = w1fl07
     C                   eval      files08 = w1fl08
     C                   eval      files09 = w1fl09
     C                   eval      files10 = w1fl10
     C                   eval      files11 = w1fl11
     C                   eval      files12 = w1fl12
     C                   eval      files13 = w1fl13
     C                   eval      files14 = w1fl14
     C                   eval      files15 = w1fl15
     C                   eval      files16 = w1fl16
     C                   eval      files17 = w1fl17
     C                   eval      files18 = w1fl18
     C                   eval      files19 = w1fl19
     C                   eval      files20 = w1fl20
     C                   eval      files21 = w1fl21
     C                   eval      files22 = w1fl22
     C                   eval      files23 = w1fl23
     C                   eval      files24 = w1fl24
     C                   eval      files25 = w1fl25
     C                   eval      files26 = w1fl26
     C                   eval      files27 = w1fl27
     C                   eval      files28 = w1fl28
     C                   eval      files29 = w1fl29
     C                   eval      files30 = w1fl30
     C                   eval      files31 = w1fl31
     C                   eval      files32 = w1fl32
     C                   eval      files33 = w1fl33
     C                   eval      files34 = w1fl34
     C                   eval      files35 = w1fl35
     C                   eval      files36 = w1fl36
     C                   eval      files37 = w1fl37
     C                   eval      files38 = w1fl38
     C                   eval      files39 = w1fl39
     C                   eval      files40 = w1fl40
     C                   eval      files41 = w1fl41
     C                   eval      files42 = w1fl42
     C                   eval      files43 = w1fl43
     C                   eval      files44 = w1fl44
     C                   eval      files45 = w1fl45
     C                   eval      files46 = w1fl46
     C                   eval      files47 = w1fl47
     C                   eval      files48 = w1fl48
     C                   eval      files49 = w1fl49
     C                   eval      files50 = w1fl50
     C                   eval      files51 = w1fl51
     C                   eval      files52 = w1fl52
     C                   eval      files53 = w1fl53
     C                   eval      files54 = w1fl54
     C                   eval      files55 = w1fl55
     C                   eval      files56 = w1fl56
     C                   eval      files57 = w1fl57
     C                   eval      files58 = w1fl58
     C                   eval      files59 = w1fl59
     C                   eval      files60 = w1fl60
     C                   eval      files61 = w1fl61
     C                   eval      files62 = w1fl62
     C                   eval      files63 = w1fl63
     C                   eval      files64 = w1fl64
     C                   eval      files65 = w1fl65
     C                   eval      files66 = w1fl66
     C                   eval      files67 = w1fl67
     C                   eval      files68 = w1fl68
     C                   eval      files69 = w1fl69
     C                   eval      files70 = w1fl70
     C                   eval      files71 = w1fl71
     C                   eval      files72 = w1fl72
     C                   eval      files73 = w1fl73
     C                   eval      files74 = w1fl74
     C                   eval      files75 = w1fl75
     C                   eval      files76 = w1fl76
     C                   eval      files77 = w1fl77
     C                   eval      files78 = w1fl78
     C                   eval      files79 = w1fl79
     C                   eval      files80 = w1fl80
     C                   eval      files81 = w1fl81
     C                   eval      files82 = w1fl82
     c                   eval      libr01 = w1lb01
     c                   eval      libr02 = w1lb02
     c                   eval      libr03 = w1lb03
     c                   eval      libr04 = w1lb04
     c                   eval      libr05 = w1lb05
     c                   eval      libr06 = w1lb06
     c                   eval      libr07 = w1lb07
     c                   eval      libr08 = w1lb08
     c                   eval      libr09 = w1lb09
     c                   eval      libr10 = w1lb10
     c                   eval      libr11 = w1lb11
     c                   eval      libr12 = w1lb12
     c                   eval      libr13 = w1lb13
     c                   eval      libr14 = w1lb14
     c                   eval      libr15 = w1lb15
     c                   eval      libr16 = w1lb16
     c                   eval      libr17 = w1lb17
     c                   eval      libr18 = w1lb18
     c                   eval      libr19 = w1lb19
     c                   eval      libr20 = w1lb20
     c                   eval      libr21 = w1lb21
     c                   eval      libr22 = w1lb22
     c                   eval      libr23 = w1lb23
     c                   eval      libr24 = w1lb24
     c                   eval      libr25 = w1lb25
     c                   eval      libr26 = w1lb26
     c                   eval      libr27 = w1lb27
     c                   eval      libr28 = w1lb28
     c                   eval      jrtp01 = w1jrtp01
     c                   eval      jrtp02 = w1jrtp02
     c                   eval      jrtp03 = w1jrtp03
     c                   eval      jrtp04 = w1jrtp04
     c                   eval      jrtp05 = w1jrtp05
     c                   eval      jrtp06 = w1jrtp06
     c                   eval      jrtp07 = w1jrtp07
     c                   eval      jrtp08 = w1jrtp08
     c                   eval      jrtp09 = w1jrtp09
     c                   eval      jrlsts = w1lsts
     c                   eval      jroutlib = w1outlib
     c                   eval      jrjobid = w1jobid
                         if jrlsts<>*blanks;
                           jrlsdte=%subst(jrlsts:6:2) + %subst(jrlsts:9:2) +
                                   %subst(jrlsts:1:4);
                         endif;
                         if jrlsts<>*blanks;
                           jrlstim=%subst(jrlsts:12:2) + %subst(jrlsts:15:2) +
                                   %subst(jrlsts:18:2);
                         endif;
                         jrndtaara = dataareas;
                         out jrndtaara;
     *
     C     endupd2       endsr

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
