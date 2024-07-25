      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave #203
     *   Batavia, IL 60510
     *   630.562.0375
     *----------------------------------------------------------------
     *
     *  RH550     Batch PIR Label Printing
     *  September 4, 2012
     *  Rod Roller
     *
     *  NOTE: For this to work the customer must also have UT880CL,
     *        AND PFMT revisions 640a & 640b,
     *        AND you must set user BFCPRINT authority to *PUBLIC *USE!
     *
650aA*    02/11/12  RTR  6.50a
     *      - Enh: Increased transactions from 15 to 50
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  31 - 80   Field input error (Reverse Display)
     *  95        View mode (Protect input fields)
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
650aDF**rh550fm   cf   e             workstn
650aMFrh55001   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpirtran   if   e           k disk
     Freports   if   e           k disk
     Frptovr1   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             60    dim(6) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Program parameters
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lorg                 19     24  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erdate                 1      6  0
     *
     D  erpo#                  1      5p 0
     D  eritem                 6     20
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     D  #curruser            358    367
     *----------------------------------------------------------------
     *  Workstation exception data structure
     *
     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4

     D $MSGF           s             10
     D $PLEN           s              3  0
     D $PSTR           s             60
     D #MSGID          s              7
     D #MSGTP          s              7
     D #PGMQ           s             10
     D CMDTKN          s              1
     D E               s              2  0
     D ERROR           s               n
     D MSGK            s              4  0
     D NXTSCR          s              3
     D SCLEAR          s              1
     D tranent         s               n
     D WARN            s              1
     D WKPRTF          s             10
     D WKSTYP          s              1
     D WKWHDP          s              5
     D WKWHSE          s              3  0
     D WORK1A          s              1
     D W1VP            s              1
     D w1frm8          s              8  0
     D w1to8           s              8  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *              *GOOD    - Edits passed
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $prtn             8
     C                   parm                    $tr01             7
     C                   parm                    $tr02             7
     C                   parm                    $tr03             7
     C                   parm                    $tr04             7
     C                   parm                    $tr05             7
     C                   parm                    $tr06             7
     C                   parm                    $tr07             7
     C                   parm                    $tr08             7
     C                   parm                    $tr09             7
     C                   parm                    $tr10             7
     C                   parm                    $tr11             7
     C                   parm                    $tr12             7
     C                   parm                    $tr13             7
     C                   parm                    $tr14             7
     C                   parm                    $tr15             7
650aAC                   parm                    $tr16             7
650aAC                   parm                    $tr17             7
650aAC                   parm                    $tr18             7
650aAC                   parm                    $tr19             7
650aAC                   parm                    $tr20             7
650aAC                   parm                    $tr21             7
650aAC                   parm                    $tr22             7
650aAC                   parm                    $tr23             7
650aAC                   parm                    $tr24             7
650aAC                   parm                    $tr25             7
650aAC                   parm                    $tr26             7
650aAC                   parm                    $tr27             7
650aAC                   parm                    $tr28             7
650aAC                   parm                    $tr29             7
650aAC                   parm                    $tr30             7
650aAC                   parm                    $tr31             7
650aAC                   parm                    $tr32             7
650aAC                   parm                    $tr33             7
650aAC                   parm                    $tr34             7
650aAC                   parm                    $tr35             7
650aAC                   parm                    $tr36             7
650aAC                   parm                    $tr37             7
650aAC                   parm                    $tr38             7
650aAC                   parm                    $tr39             7
650aAC                   parm                    $tr40             7
650aAC                   parm                    $tr41             7
650aAC                   parm                    $tr42             7
650aAC                   parm                    $tr43             7
650aAC                   parm                    $tr44             7
650aAC                   parm                    $tr45             7
650aAC                   parm                    $tr46             7
650aAC                   parm                    $tr47             7
650aAC                   parm                    $tr48             7
650aAC                   parm                    $tr49             7
650aAC                   parm                    $tr50             7
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $pwhse            3
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in95 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = '1'
     C                   move      'EOJ'         nxtscr
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = *on
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
     C                   exfmt     screen1                              50
     C                   endif
     *
     *   Initialize error indicators and fields
     *
650aAC                   setoff                                       313233
650aAC                   setoff                                       343536
650aAC                   setoff                                       373839
650aAC                   setoff                                       404142
650aAC                   setoff                                       434445
650aAC                   setoff                                       464748
650aAC                   setoff                                       495051
650aAC                   setoff                                       525354
650aAC                   setoff                                       555657
650aAC                   setoff                                       585960
650aAC                   setoff                                       616263
650aAC                   setoff                                       646566
650aAC                   setoff                                       676869
650aAC                   setoff                                       707172
650aAC                   setoff                                       737475
650aAC                   setoff                                       767778
650aAC                   setoff                                       7980
650aAC                   setoff                                       919293
650aAC                   setoff                                       959798
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
     C                   move      '01 '         nxtscr
     *
     *  Get existing record.
     *
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
     C                   eval      $prtn = '*EXIT   '
     C                   move      'EOJ'         nxtscr
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      $prtn = '*CANCEL '
     C                   move      'EOJ'         nxtscr
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zznxt1
     C     endsc1        endsr
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
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
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
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
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
     C                   move      *on           sclear
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    PIR9901  Invalid date entered.
     *
     C     zm9901        begsr
     C                   eval      #msgid = 'PIR9901'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    PIR9906  Invalid date entered.
     *
     C     zm9906        begsr
     C                   eval      #msgid = 'PIR9906'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   move      'PIR9905'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR9999  Generic message text
     *
     C     zm9999        begsr
     C                   move      'PIR9999'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   move      'PIR1001'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1006  Invalid jobq option for view report option.
     *
     C     zm1006        begsr
     C                   move      'PIR1006'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  Verify default device
     *
     C                   movel     w1dev         work1a
     C                   if        work1a = '*'  and
     C                             w1dev <> '*JOB'  or
     C                             w1dev = *blanks
     c                   eval      error = *on
     C                   eval      *in92 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(4)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
650aAC                   if        w1dev <> '*JOB'
650aAC                   movel     w1dev         hlddv1
650aAc                   call      'UT880CL'
650aAc                   parm                    hlddv1           10
650aAc                   parm                    $lrtn
650aAc                   if        $lrtn = '*ERROR '
650aAc                             or hlddv1 = ' '
650aAc                   eval      error = *on
650aAc                   eval      *in92 = *on
650aAC                   eval      errmsg = *blanks
650aAc                   eval      errmsg = desc(4)
650aAC                   exsr      zm1001
650aAC                   endif
650aAC                   endif
     *
     *  Verify default form type
     *
     C                   movel     w1form        work1a
     C                   if        work1a = '*'  and
     C                             w1form <> '*STD'  or
     C                             w1form = *blanks
     C                   move      '1'           error
     C                   eval      *in41 = *on
     C                   eval      *in17 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(5)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
     *  If F20=Override, skip checks
     *
     C                   if        *inku = *off
     *
     *  Verify transactions if entered
     *
     C                   eval      tranent = *off
     C                   if        wtr01 <> 0
     C                   eval      tranent = *on
     C     wtr01         chain     pirtran                            89
     C                   if        *in89
     C                             or ptstat <> '1'
     C                   eval      error = *on
     C                   eval      *in31 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(6)       errmsg
     C                   endif
     C                   endif
     *
     C                   if        wtr02 <> 0
     C                   eval      tranent = *on
     C     wtr02         chain     pirtran                            89
     C                   if        *in89
     C                             or ptstat <> '1'
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(6)       errmsg
     C                   endif
     C                   endif
     *
     C                   if        wtr03 <> 0
     C                   eval      tranent = *on
     C     wtr03         chain     pirtran                            89
     C                   if        *in89
     C                             or ptstat <> '1'
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(6)       errmsg
     C                   endif
     C                   endif
     *
     C                   if        wtr04 <> 0
     C                   eval      tranent = *on
     C     wtr04         chain     pirtran                            89
     C                   if        *in89
     C                             or ptstat <> '1'
     C                   eval      error = *on
     C                   eval      *in34 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(6)       errmsg
     C                   endif
     C                   endif
     *
     C                   if        wtr05 <> 0
     C                   eval      tranent = *on
     C     wtr05         chain     pirtran                            89
     C                   if        *in89
     C                             or ptstat <> '1'
     C                   eval      error = *on
     C                   eval      *in35 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(6)       errmsg
     C                   endif
     C                   endif
     *
     C                   if        wtr06 <> 0
     C                   eval      tranent = *on
     C     wtr06         chain     pirtran                            89
     C                   if        *in89
     C                             or ptstat <> '1'
     C                   eval      error = *on
     C                   eval      *in36 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(6)       errmsg
     C                   endif
     C                   endif
     *
     C                   if        wtr07 <> 0
     C                   eval      tranent = *on
     C     wtr07         chain     pirtran                            89
     C                   if        *in89
     C                             or ptstat <> '1'
     C                   eval      error = *on
     C                   eval      *in37 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(6)       errmsg
     C                   endif
     C                   endif
     *
     C                   if        wtr07 <> 0
     C                   eval      tranent = *on
     C     wtr07         chain     pirtran                            89
     C                   if        *in89
     C                             or ptstat <> '1'
     C                   eval      error = *on
     C                   eval      *in37 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(6)       errmsg
     C                   endif
     C                   endif
     *
     C                   if        wtr08 <> 0
     C                   eval      tranent = *on
     C     wtr08         chain     pirtran                            89
     C                   if        *in89
     C                             or ptstat <> '1'
     C                   eval      error = *on
     C                   eval      *in38 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(6)       errmsg
     C                   endif
     C                   endif
     *
     C                   if        wtr09 <> 0
     C                   eval      tranent = *on
     C     wtr09         chain     pirtran                            89
     C                   if        *in89
     C                             or ptstat <> '1'
     C                   eval      error = *on
     C                   eval      *in39 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(6)       errmsg
     C                   endif
     C                   endif
     *
     C                   if        wtr10 <> 0
     C                   eval      tranent = *on
     C     wtr10         chain     pirtran                            89
     C                   if        *in89
     C                             or ptstat <> '1'
     C                   eval      error = *on
     C                   eval      *in40 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(6)       errmsg
     C                   endif
     C                   endif
     *
     C                   if        wtr11 <> 0
     C                   eval      tranent = *on
     C     wtr11         chain     pirtran                            89
     C                   if        *in89
     C                             or ptstat <> '1'
     C                   eval      error = *on
     C                   eval      *in41 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(6)       errmsg
     C                   endif
     C                   endif
     *
     C                   if        wtr12 <> 0
     C                   eval      tranent = *on
     C     wtr12         chain     pirtran                            89
     C                   if        *in89
     C                             or ptstat <> '1'
     C                   eval      error = *on
     C                   eval      *in42 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(6)       errmsg
     C                   endif
     C                   endif
     *
     C                   if        wtr13 <> 0
     C                   eval      tranent = *on
     C     wtr13         chain     pirtran                            89
     C                   if        *in89
     C                             or ptstat <> '1'
     C                   eval      error = *on
     C                   eval      *in43 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(6)       errmsg
     C                   endif
     C                   endif
     *
     C                   if        wtr14 <> 0
     C                   eval      tranent = *on
     C     wtr14         chain     pirtran                            89
     C                   if        *in89
     C                             or ptstat <> '1'
     C                   eval      error = *on
     C                   eval      *in44 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(6)       errmsg
     C                   endif
     C                   endif
     *
     C                   if        wtr15 <> 0
     C                   eval      tranent = *on
     C     wtr15         chain     pirtran                            89
     C                   if        *in89
     C                             or ptstat <> '1'
     C                   eval      error = *on
     C                   eval      *in45 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(6)       errmsg
     C                   endif
     C                   endif
     *
650aAC                   if        wtr16 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr16         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in46 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr17 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr17         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in47 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr18 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr18         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in48 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr19 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr19         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in49 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr20 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr20         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in50 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr21 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr21         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in51 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr22 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr22         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in52 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr23 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr23         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in53 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr24 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr24         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in54 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr25 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr25         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in55 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr26 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr26         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in56 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr27 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr27         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in57 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr28 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr28         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in58 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr29 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr29         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in59 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr30 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr30         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in60 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr31 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr31         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in61 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr32 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr32         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in62 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr33 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr33         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in63 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr34 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr34         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in64 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr35 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr35         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in65 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr36 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr36         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in66 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr37 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr37         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in67 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr38 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr38         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in68 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr39 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr39         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in69 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr40 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr40         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in70 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr41 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr41         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in71 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr42 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr42         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in72 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr43 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr43         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in73 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr44 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr44         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in74 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr45 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr45         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in75 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr46 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr46         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in76 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr47 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr47         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in77 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr48 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr48         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in78 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr49 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr49         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in79 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
650aA*
650aAC                   if        wtr50 <> 0
650aAC                   eval      tranent = *on
650aAC     wtr50         chain     pirtran                            89
650aAC                   if        *in89
650aAC                             or ptstat <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in80 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   movel     desc(6)       errmsg
650aAC                   endif
650aAC                   endif
     *
     *  If any transaction numbers were invalid, display message
     *
     C                   if        error = *on
     C                   exsr      zm9999
     C                   endif
     *
     *  If nothing entered, redisplay screen
650aAC                   if        tranent = *off
650aAC                   eval      error = *on
650aAC                   endif
     *
     C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   move      '0'           cmdtkn
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   move      *on           cmdtkn
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     Cursor not on a valid lookup field.
     *
     C                   move      *on           error
     C                   exsr      zm9905
     C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *   Initialize printer device/form
     *
     C                   eval      wkstyp = *blanks
     C                   eval      wkwhdp = *blanks
     *
     C     rokey         chain     rptovr1                            89
     C                   if        not *in89
     C                   eval      w1dev  = rodev
     C                   eval      w1form = '*STD'
     C                   endif
     *
     C                   if        *in89
     C     rpkey         chain     reports                            89
     C                   if        not *in89
     C                   eval      w1dev  = rpdev
     C                   eval      w1form = '*STD '
     C                   else
     C                   movel     '*JOB    '    w1dev
     C                   movel     '*STD    '    w1form
     C                   endif
     C                   endif
     *
     *    Get User's info for warehouse
     *
     C                   call      'GETUSER'
     C                   parm      #curruser     $code            10
     C                   parm      0             $whse             3 0
     C                   parm      0             $emp#             5 0
     C                   parm      *blanks       $fnam            15
     C                   parm      *blanks       $init             1
     C                   parm      *blanks       $lnam            20
     C                   parm      *blanks       $whdp             5
     C                   parm      *blanks       $styp             1
     C                   parm      *blanks       $shft             6
     C                   parm      *blanks       $crew             6
     C                   parm      0             $nhrs             3 1
     C                   parm      *blanks       $rtn              8
     *
     C                   if        $rtn = '*OK' and $whse > 0
     C                   eval      w1whse = $whse
     C                   else
     C                   eval      w1whse = 1
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C     rokey         klist
     C                   kfld                    wkprtf
     C                   kfld                    wkwhse
     C                   kfld                    wkstyp
     C                   kfld                    wkwhdp
     *
     C     rpkey         klist
     C                   kfld                    wkprtf
     *
     C                   movel     'RH555PR '    wkprtf
     C                   eval      rptttl = *blanks
     C     rpkey         chain     reports                            89
     C                   if        not *in89
     C                   movel     rpdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 40
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm                    $plen
     C                   movel     $pstr         rptttl
     *
     C                   eval      $lprg = #prog
     *
     C                   seton                                        01
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZNXT1   What to do next when screen 1 input is ok.
     *
     C     zznxt1        begsr
     *
     C                   eval      $prtn  = '*GOOD'
     *
     C                   eval      $tr01 = %editc(wtr01:'X')
     C                   eval      $tr02 = %editc(wtr02:'X')
     C                   eval      $tr03 = %editc(wtr03:'X')
     C                   eval      $tr04 = %editc(wtr04:'X')
     C                   eval      $tr05 = %editc(wtr05:'X')
     C                   eval      $tr06 = %editc(wtr06:'X')
     C                   eval      $tr07 = %editc(wtr07:'X')
     C                   eval      $tr08 = %editc(wtr08:'X')
     C                   eval      $tr09 = %editc(wtr09:'X')
     C                   eval      $tr10 = %editc(wtr10:'X')
     C                   eval      $tr11 = %editc(wtr11:'X')
     C                   eval      $tr12 = %editc(wtr12:'X')
     C                   eval      $tr13 = %editc(wtr13:'X')
     C                   eval      $tr14 = %editc(wtr14:'X')
     C                   eval      $tr15 = %editc(wtr15:'X')
650aAC                   eval      $tr16 = %editc(wtr16:'X')
650aAC                   eval      $tr17 = %editc(wtr17:'X')
650aAC                   eval      $tr18 = %editc(wtr18:'X')
650aAC                   eval      $tr19 = %editc(wtr19:'X')
650aAC                   eval      $tr20 = %editc(wtr20:'X')
650aAC                   eval      $tr21 = %editc(wtr21:'X')
650aAC                   eval      $tr22 = %editc(wtr22:'X')
650aAC                   eval      $tr23 = %editc(wtr23:'X')
650aAC                   eval      $tr24 = %editc(wtr24:'X')
650aAC                   eval      $tr25 = %editc(wtr25:'X')
650aAC                   eval      $tr26 = %editc(wtr26:'X')
650aAC                   eval      $tr27 = %editc(wtr27:'X')
650aAC                   eval      $tr28 = %editc(wtr28:'X')
650aAC                   eval      $tr29 = %editc(wtr29:'X')
650aAC                   eval      $tr30 = %editc(wtr30:'X')
650aAC                   eval      $tr31 = %editc(wtr31:'X')
650aAC                   eval      $tr32 = %editc(wtr32:'X')
650aAC                   eval      $tr33 = %editc(wtr33:'X')
650aAC                   eval      $tr34 = %editc(wtr34:'X')
650aAC                   eval      $tr35 = %editc(wtr35:'X')
650aAC                   eval      $tr36 = %editc(wtr36:'X')
650aAC                   eval      $tr37 = %editc(wtr37:'X')
650aAC                   eval      $tr38 = %editc(wtr38:'X')
650aAC                   eval      $tr39 = %editc(wtr39:'X')
650aAC                   eval      $tr40 = %editc(wtr40:'X')
650aAC                   eval      $tr41 = %editc(wtr41:'X')
650aAC                   eval      $tr42 = %editc(wtr42:'X')
650aAC                   eval      $tr43 = %editc(wtr43:'X')
650aAC                   eval      $tr44 = %editc(wtr44:'X')
650aAC                   eval      $tr45 = %editc(wtr45:'X')
650aAC                   eval      $tr46 = %editc(wtr46:'X')
650aAC                   eval      $tr47 = %editc(wtr47:'X')
650aAC                   eval      $tr48 = %editc(wtr48:'X')
650aAC                   eval      $tr49 = %editc(wtr49:'X')
650aAC                   eval      $tr50 = %editc(wtr50:'X')
     *
     C                   eval      $pdev  = w1dev
     C                   eval      $pform = w1form
     C                   eval      $pwhse = %editc(w1whse:'X')
     *
     C                   move      'EOJ'         nxtscr
     C                   endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Section type
Print option
Job queue option
Printer device
Form type
Transaction is Started, Ended, or Closed.
