     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ** NO LONGER USED **
     *  RN150     Customer returns putaway
     *  May 11, 1999
     *  Roxanne Harrison
     *    Created using RN120
     *  Revisions
412 A*    09/22/99  RH   4.12
     *      - Change for Virtual Slots.
     *        If Manual put away, call RN250 after screen 1.
412aA*    09/27/99  RH   4.12
     *        If item type S, display breakdown UOM.
     *
413aA*    10/14/99  MLB  4.13a
     *      - Add F17=View rcv log to panels SCREEN1 and SCREEN2.
     *      - Add call to PO135 to ZZCMD1, ZZCMD2 subroutines.
415aA*    01/03/01  RH   4.15a
     *      - Add scan label #.
     *      - If label# scanned, do not enter license plates,
     *        write old label, new label and new transaction# to
     *        LABELNK link file.
     *      - MOVE F17 TO CMDBEFORE
415cA*    03/30/01  RH   4.15c
     *      - Add scan UPC.
     *
416 A*    10/15/01  MLB  4.16
     *      - Add support to allow return record to be updated when return
     *        putaway transaction is closed.
416aA*    10/17/01  RH   4.16a
     *      - Fix F4 Item lookup.
     *      - Add $LLTRN (trans#) to parms for RN250.
416bA*    11/09/01  RH   4.16b
     *      - Add disposition code and use label to screen2.
     *      - Add Screen3,impact inventory, memo and correspond item.
416CA*    12/03/01  RH   4.16C
     *      - PROGRAM NO LONGER USED - RN120 CHANGED TO HANDLE QUICK.
530cA*    09/09/10  JCJ  5.30b
     *      - Enh: increase label entry to 10 positions for Trax.
     *      - ENH: Change to ILE.
     *
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
     *  File Specs
     *
530cD*** Frn150fm   cf   e             workstn
530cMFrn15001   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Funmesr    if   e           k disk
     Fpiritem   if   e           k disk
     Forrtn     o  a e           k disk
     Foptions   if   e           k disk
412 AFoptiond   if   e           k disk
415aAFLabel     if   e           k disk
415aAFLabel2    if   e           k disk
     F                                     rename(lbrec:record)
415aAFLabelnk   o  a e           k disk
415bAFordh      if   e           k disk
415cAFupc       if   e           k disk
416bAFpiritem4  if   e           k disk
     F                                     rename(itrec:i4rec)
416bAFrdscode   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
530cD ***desc            s             50    dim(6) ctdata perrcd(1)
530cMD desc            s             50    dim(7) ctdata perrcd(1)
     D hed             s             50    dim(3) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
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
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $litem                22     36
412 AD  $lusr                 37     46
412 AD  $ldev                 47     56
412 AD  $lform                57     66
     *
     D  $lcode                19     20
     *
     D  $ltrn#                19     25  0
     *
     D  $luser                19     28
     *
     D  $lpo                  37     45
     D  $lrq1                 46     50  0
     D  $lrq2                 51     55  0
     D  $lrq3                 56     60  0
     D  $lrpal                61     63  0
     *
413aAD  $lrpo                 22     30
413aAD  $lrseq                31     35  0
413aAD  $lritm                36     50
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
530cAD @cvtbarsel      c                   const('CVTBARSEL')
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
     *
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erulen                 1      3p 2
     D  eruwdt                 4      6p 2
     D  eruhgt                 7      9p 2
     D  ercalc                10     13p 3
     D  ercube                14     17p 3
     D  ercdiv                18     22p 2
     D  ercrng                23     24p 1
     D  ermax                 25     28p 4
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
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
     * Data structure
     *
     D opdata          ds
     D  oplpgm                 1     10
     D  opupct                11     13  0
     D  oppdef                14     14  0
     D  oppbld                15     15  0
     D  oppact                16     16  0
     D  opfdef                17     17  0
     D  opfasl                18     18  0
     D  opfsid                19     19  0
     D  opflvl                20     20  0
     D  oppasl                21     21  0
     D  oppfrc                22     22
     D  opplcn                23     23
     D  opcum                 24     43
     D  opcdiv                44     52  2
     D  opcaut                53     53
     D  opcwrn                54     54
     D  opcrng                55     57  1
     D  opwum                 58     72
     D  opxdsc                73     73
     D  optend               117    117
412 A*----------------------------------------------------------------
412 A*  *PICK  -  Picking options
412 A*----------------------------------------------------------------
412 A*
412 A* Fields
412 A*
412 A*    OPNXTP  -  Next pallet number.
412 A*    OPBPCK  -  Bulk pick definition.
412 A*    OPPCUB  -  Maximum cube for PIR.
412 A*    OPFPAL  -  Pallets on fixed fork lift.
412 A*    OPFCUB  -  Maximum cube per fixed pallet.
412 A*    OPFSTP  -  Maximum stops per fixed pallet.
412 A*    OPINCL  -  Include PIR in fixed cube.
412 A*    OPSRCH  -  Number of previous pallets to search for space.
412 A*    OPFBLD  -  Fixed pallet building method.
412 A*                1 = By piece without concern for splitting stop.
412 A*                2 = By stop without splitting stop between plts.
412 A*    OPPBRK  -  Break pallets by aisle (Y,N).
412 A*    OPMPUT  -  Manual Put away (Y,N).
412 A*
412 A* Data structure
412 A*
412 AD opddta          ds
412 AD  opnxtp                 1      7  0 inz(0)
412 AD  oppcub                10     14  2 inz(0)
412 AD  opfpal                15     15  0 inz(0)
412 AD  opfcub                16     20  2 inz(0)
412 AD  opincl                22     22
412 AD  opsrch                23     24  0 inz(0)
412 AD  opfstp                25     26  0 inz(0)
412 AD  opfbld                27     27  0 inz(0)
412 AD  opbpck                28     30  0 inz(0)
412 AD  oppbrk                31     33
412 AD  opmput                34     34
412 AD  opdend               117    117
412 A*
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
     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------
     D $lord           s              7  0
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
     D expd            s              8  0
     D help            s              5  0
     D kycode          s                   like(opdcod)
     D kyupc           s                   like(upupc)
     D lcnflg          s              1
     D msgk            s              4  0
     D nxtscr          s              3
     D ocode           s              8
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D rtntyp          s              1
     D sclear          s              1
     D stop            s              1
     D svuser          s                   like(w1user)
     D today           s              8  0
     D warn            s              1
     D wolbl#          s              7  0
     D woord           s              7  0
     D work1a          s              1
     D wotrn#          s              7  0
     D wscitm          s             15
     D w1memo          s             30
     D w1slot          s             12
     D w3iinv          s              1
530cAD w1lbl#          s              7  0
530cAD kyvmfg          s             15
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *RETURN  - Customer return.
     *              *TFRRTN  - Transfer returns.
     *              *POSRTN  - POS returns.
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
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
     C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
     C                   endif
     *
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       101112
     C                   setoff                                       131415
     C                   setoff                                       161718
     C                   setoff                                       1920
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       3031
     C                   setoff                                       333435
     C                   setoff                                       363738
     C                   setoff                                       3940
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
     C                   if        refrsh = *on
     C                   exsr      zzfil1
     C                   endif
     C                   eval      refrsh = *off
     C     end01i        endsr
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *R         REFRSH    IFEQ *ON
     C                   exsr      zzfil2
     *R                   ENDIF
     C                   eval      refrsh = *off
     C     end02i        endsr
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     *R         REFRSH    IFEQ *ON
     C                   exsr      zzfil3
     *R                   ENDIF
     C                   eval      refrsh = *off
     C     end03i        endsr
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
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
411 D*R                   MOVE *OFF      *IN32
     C                   exsr      scr01i
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
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
412 AC                   if        opmput = 'Y'  and
412 AC                             $lrtn = '*CANCEL '
412 AC                   eval      nxtscr = '01 '
412 AC                   goto      endsc1
412 AC                   endif
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Everything went fine so onto the next screen.
     *
412 AC                   if        opmput = 'Y'
415bAC                   eval      refrsh = *on
415bAC                   exsr      scr01i
412 AC                   else
412 A***                  MOVE 'EOJ'     NXTSCR
     C                   exsr      scr02i
412 AC                   endif
     *
     C     endsc1        endsr
     *
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
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = '01 '
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Everything went fine so onto the next screen.
     *
416BAC                   eval      refrsh = *on
416b C                   exsr      scr03i
     *
     C     endsc2        endsr
     *
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
416bMC                   eval      nxtscr = '03 '
416bM**                   MOVE 'EOJ'     NXTSCR
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr03i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = '02 '
     C                   goto      endsc3
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
530cD ***                exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
530cD ***                exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     C     endsc3        endsr
     *
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
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125
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
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
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
     *   PIR0109  Value can not be less than 0.
     *
     C     zm0109        begsr
     C                   eval      #msgid = 'PIR0109'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0110  Value must be > 0.
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
530cA*----------------------------------------------------------------
530cA*   PIR0204  Can only enter one value.
530cA*
530cAC     zm0204        begsr
530cAC                   eval      #msgid = 'PIR0204'
530cAC                   eval      #msgtp = '*DIAG  '
530cAC                   movea     errmsg        $md
530cAC                   exsr      zmpmsg
530cAC                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1008  Date is required.
     *
     C     zm1008        begsr
     C                   eval      #msgid = 'PIR1008'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1009  Date must be > today's date.
     *
     C     zm1009        begsr
     C                   eval      #msgid = 'PIR1009'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PO15021  P.O. number must be entered.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'PO15021'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
415cA*----------------------------------------------------------------
415cA*   PO20029  UPC not on file.
415cA*
415cAC     zm29          begsr
415cAC                   eval      #msgid = 'PO20029'
415cAC                   eval      #msgtp = '*DIAG  '
415cAC                   movea     errmsg        $md(1)
415cAC                   exsr      zmpmsg
415cAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  Verify warehouse code.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   else
     C                   eval      $fwhse = w1whse
     C                   movel     $lerm         $fdesc
     C                   call      'FRMTWH'
     C                   parm                    $fwhse            3 0
     C                   parm                    $fdesc           30
     C                   parm                    wowhse
     C                   endif
     *
     *  Verify user id.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $luser = w1user
     C                   call      'US900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
415aA*
415aA*  Verify label number.
415aA*
415aAC                   eval      wolbl# = 0
415aAC                   eval      wotrn# = 0
415bAC                   eval      woord = 0
530cD ***                if        w1lbl# <> 0
530cMC                   if        w1lbl#b <> *blanks
     * grab label#
530cAC                   move      w1whse        $pwhseb
530cAC                   movel     w1lbl#b       $pbarcode
530cAC                   call      @cvtbarsel
530cAC                   parm                    $pwhseb           3
530cAC                   parm                    $pbarcode        15
530cAC                   parm                    $plbl#            7 0
530cAC                   parm                    $prtid            5
530cAC                   parm                    $punq#            5
530cAC                   parm                    $preturn          8
530cAC                   parm                    $perrmsg         60
530cAC                   if        $preturn = '*OK'
530cAC                   eval      w1lbl# = $plbl#
530cAC                   move      *blanks       w1lbl#b
530cAC                   move      $plbl#        w1lbl#b
530cAC                   else
530cAC                   eval      error = *on
530cAC                   eval      *in22 = *on
530cAC                   movel     desc(7)       errmsg
530cAC                   exsr      zm0110
530cAC                   endif
415aAC                   eval      wolbl# = w1lbl#
415aAC     wolbl#        chain     label                              79
415aAC                   if        *in79
415aAC                   eval      error = *on
415aAC                   eval      errmsg = *blanks
415aAC                   eval      errmsg = desc(1)
415aAC                   eval      *in34 = *on
415aAC                   eval      *in14 = *on
415aAC                   exsr      zm1001
415aAC                   else
415aAC                   eval      w1item = lbitem
415aAC                   eval      wotrn# = lbtrn#
415bAC                   eval      woord = lbord
415aAC                   endif
415aAC                   endif
415c *
415c *
415cAC                   select
415c *  UPC entered
415cAC                   when      w1upc <> *blanks
415c *
415cAC                   eval      $cbcmd = '*UPC    '
415cAC                   movel     w1upc         $cbbar
415cAC                   call      'CVTBAR'
415cAC                   parm                    $cbcmd            8
415cAC                   parm                    $cbbar          100
415cAC                   parm                    $cbcod            3 0
415cAC                   parm                    $cbdec            1 0
415cAC                   parm                    $cbdsc           30
415cAC                   parm                    $cbpos            3 0
415cAC                   parm                    $cbtyp            1 0
415cAC                   parm                    $cbv1            11 3
415cAC                   parm                    $cbv2            50
415cAC                   parm                    $cbrtn            8
415cAC                   parm                    $cberm           60
415c *
415cAC                   if        $cbrtn = '*OK'
415cAC                   eval      w1upc = $cbv2
415cAC                   endif
415c *
415c *   Right adjust UPC code for file.
415c *
415cAC                   eval      $cstr = *blanks
415cAC                   movel     w1upc         $cstr
415cAC                   call      'ADJUST'
415cAC                   parm      '*RIGHT  '    $ccmd             8
415cAC                   parm                    $cstr            30
415cAC                   move      $cstr         kyupc
415cAC     upckey        chain     upc                                79
415cAC                   if        *in79
415cAC                   eval      error = *on
415cAC                   eval      *in25 = *on
415cAC                   eval      *in05 = *on
415cAC                   eval      errmsg = *blanks
415cAC                   exsr      zm29
415cAC                   goto      endck1
415cAC                   endif
415c *
415cAC                   eval      w1item = upitem
415c *
415cAC                   endsl
     *
     *
     *
     *  Verify item number.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $litem = w1item
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     *
     *  Verify printer device.
     *
     C                   movel     w1dev         work1a
     C                   if        work1a = '*'  and
     C                             w1dev <> '*DEFAULT'  and
     C                             w1dev <> '*SYSVAL'  and
     C                             w1dev <> '*JOB'  or
     C                             w1dev = *blanks
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(3)
     C                   exsr      zm1001
     C                   endif
     *
     *  Verify default form type
     *
     C                   movel     w1form        work1a
     C                   if        work1a = '*'  and
     C                             w1form <> '*DEFAULT'  and
     C                             w1form <> '*STD'  or
     C                             w1form = *blanks
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(4)
     C                   exsr      zm1001
     C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     *
     *  Verify normal quantity.
     *
     C                   if        w1qt01 < 0
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       erfld
     C                   exsr      zm0109
     C                   endif
     *
     *  Verify breakdown 1 quantity.
     *
     C                   if        w1qt02 < 0
     C                   eval      error = *on
     C                   eval      *in31 = *on
     C                   eval      *in11 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       erfld
     C                   exsr      zm0109
     C                   endif
     *
     *  Verify breakdown 2 quantity.
     *
     C                   if        w1qt03 < 0
     C                   eval      error = *on
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       erfld
     C                   exsr      zm0109
     C                   endif
     *
     *     Verify expired date (optional)
     *
     C                   if        not *in96  and
     C                             w1expd = 0
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1008
     C                   else
     C                   if        w1expd <> 0
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1expd        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      #msgk = $cvmsg
     C                   exsr      zmqmsg
     C                   else
     C                   eval      w1expd = $cvd6o
     C                   eval      $cvcmd = '*MDYCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        expd
     C                   if        expd <= today
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1009
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     *
     *  Verify return code.
     *
     C                   if        w1code <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lcode = w1code
     C                   call      'RN900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
416b *
416b *  Verify disposition code.
416b *
416b C                   if        w1dcde <> *blanks
416b C                   eval      $lcmd = '*VERIFY '
416b C                   move      w1dcde        $lcode
416b C                   call      'RD900'
416b C                   parm                    $lparm
416b C                   if        $lrtn = '*ERROR  '
416b C                   eval      error = *on
416b C                   eval      *in27 = *on
416b C                   eval      *in07 = *on
416b C                   movel     $lerm         errmsg
416b C                   exsr      zm0105
416b C                   else
416b C                   if        $lrtn = '*PGMQ   '
416b C                   eval      error = *on
416b C                   eval      *in27 = *on
416b C                   eval      *in07 = *on
416b C                   eval      #msgk = $lmsg
416b C                   exsr      zmqmsg
416b C                   endif
416b C                   endif
416b C                   endif
     *
     *
416bA*  Verify Use label for putaway Y/N.
     *
416bAC                   if        w1flbl <> 'Y'  and
416bAC                             w1flbl <> 'N'
416bAC                   eval      error = *on
416bAC                   eval      *in28 = *on
416bAC                   eval      *in08 = *on
416bAC                   eval      errmsg = *blanks
416bAC                   eval      errmsg = desc(6)
416bAC                   exsr      zm1001
416bAC                   endif
     *
416bA*  Use label MUST=N if label was not entered.
     *
416bAC                   if        w1flbl = 'Y'  and
416bAC                             wolbl# = 0
416bAC                   eval      error = *on
416bAC                   eval      *in28 = *on
416bAC                   eval      *in08 = *on
416bAC                   eval      errmsg = *blanks
416bAC                   eval      errmsg = desc(6)
416bAC                   exsr      zm1001
416bAC                   endif
     *
     *  Verify transaction number.
     *
     C                   if        w1trn# <> 0
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $ltrn# = w1trn#
     C                   call      'PT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in34 = *on
     C                   eval      *in14 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *
416b *  The code to verify item was moved to screen3.
     *  Verify item number.
     *
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
416bAC                   eval      wscitm = *blanks
     *
416bA*  Verify Impact inventory Y/N.
     *
415c *
416bAC                   select
416b *  UPC entered
416bAC                   when      w3upc <> *blanks
416bAC                   if        w3citm = *blanks  and
416bAC                             w3vmfg = *blanks
416b *
416bAC                   eval      $cbcmd = '*UPC    '
416bAC                   movel     w3upc         $cbbar
416bAC                   call      'CVTBAR'
416bAC                   parm                    $cbcmd
416bAC                   parm                    $cbbar
416bAC                   parm                    $cbcod
416bAC                   parm                    $cbdec
416bAC                   parm                    $cbdsc
416bAC                   parm                    $cbpos
416bAC                   parm                    $cbtyp
416bAC                   parm                    $cbv1
416bAC                   parm                    $cbv2
416bAC                   parm                    $cbrtn
416bAC                   parm                    $cberm
416b *
416bAC                   if        $cbrtn = '*OK'
416bAC                   eval      w3upc = $cbv2
416bAC                   endif
416b *
416b *   Right adjust UPC code for file.
416b *
416bAC                   eval      $cstr = *blanks
416bAC                   movel     w3upc         $cstr
416bAC                   call      'ADJUST'
416bAC                   parm      '*RIGHT  '    $ccmd
416bAC                   parm                    $cstr
416bAC                   move      $cstr         kyupc
416bAC     upckey        chain     upc                                79
416bAC                   if        *in79
416bAC                   eval      error = *on
416bAC                   eval      *in25 = *on
416bAC                   eval      *in05 = *on
416bAC                   eval      errmsg = *blanks
416bAC                   exsr      zm29
416bAC                   goto      endck3
416bAC                   endif
416b *
416bAC                   eval      wscitm = upitem
416bAC                   else
416bA*  Error, more than one value entered.
416bAC                   eval      error = *on
416bAC                   eval      *in23 = *on
416bAC                   eval      *in25 = *on
416bAC                   eval      *in26 = *on
416bAC                   eval      *in05 = *on
416bAC                   eval      errmsg = *blanks
416bAC                   exsr      zm0204
416bAC                   goto      endck3
416bAC                   endif
416b *
416bAC                   endsl
416b *
416b *  Verify Mfg code/vendor item.
416b *
416bAC                   if        w3vmfg <> *blanks
416bAC                   if        w3upc = *blanks  and
416bAC                             w3citm = *blanks
416bAC                   move      w3vmfg        kyvmfg
416bAC     mfgkey        chain     piritem4                           79
416bAC                   if        *in79
416bAC                   eval      error = *on
416bAC                   eval      *in25 = *on
416bAC                   eval      *in05 = *on
416bAC                   eval      errmsg = *blanks
416bAC                   exsr      zm29
416bAC                   goto      endck3
416bAC                   else
416bAC                   eval      wscitm = ititem
416bAC                   endif
416bAC                   else
416bA*  Error, more than one value entered.
416bAC                   eval      error = *on
416bAC                   eval      *in23 = *on
416bAC                   eval      *in25 = *on
416bAC                   eval      *in26 = *on
416bAC                   eval      *in05 = *on
416bAC                   eval      errmsg = *blanks
416bAC                   exsr      zm0204
416bAC                   goto      endck3
416bAC                   endif
416bAC                   endif
     *
416bA*  Error, more than one value entered.
416bAC                   if        w3citm <> *blanks
416bAC                   if        w3upc <> *blanks  or
416bAC                             w3vmfg <> *blanks
416bAC                   eval      error = *on
416bAC                   eval      *in23 = *on
416bAC                   eval      *in25 = *on
416bAC                   eval      *in26 = *on
416bAC                   eval      *in03 = *on
416bAC                   eval      errmsg = *blanks
416bAC                   exsr      zm0204
416bAC                   goto      endck3
416bAC                   endif
416bAC                   endif
     *
     *  Get item # from other field entered.
     *
416bAC                   if        w3citm = *blanks  and
416bAC                             w3citm <> *blanks
416bAC                   eval      w3citm = wscitm
416bAC                   endif
     *
     *  Verify item number.
     *
416bAC                   if        w3citm <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $litem = w3citm
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
416bAC                   goto      endck3
     C                   endif
416bAC                   endif
     *
     *
     C     endck3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     *     Warehouse.
     *
     C                   when      row# = 5
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
     C                   endif
     *
     *     Item.
     *
416aD**         ROW#      WHEQ 10
416aMC                   when      row# = 12
     C                   eval      *in03 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lprg = #prog
     C                   eval      $lwhse = w1whse
     C                   eval      $litem = w1item
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1item = $litem
     C                   endif
     *
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
415aA*
415aA*  Test for F17 - View receiving log.
415aA*
415aAC                   select
415aAC                   when      *inkr  and
415aAC                             w1item > *blanks
415aAC                   eval      cmdtkn = *on
415 AC                   eval      $lwhse = w1whse
415aAC                   eval      $lrpo = '*RETURN '
415aAC                   eval      $lrseq = *zeros
415aAC                   eval      $lritm = w1item
415aAC                   call      'PO135'
415aAC                   parm                    $lparm
415aAC                   parm                    $lrtn
415aAC                   endsl
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
415aD*
415aD*  Test for F17 - View receiving log.
415aD*
415aD*                    SELEC
415aD*          *INKR     WHEQ *ON
415aD*          W1ITEM    ANDGT*BLANKS
415aD*                    MOVE *ON       CMDTKN
415 D*                    Z-ADDW1WHSE    $LWHSE
415aD*                    MOVEL'*RETURN '$LRPO     P
415aD*                    MOVE *ZEROS    $LRSEQ
415aD*                    MOVE W1ITEM    $LRITM
415aD*                    CALL 'PO135'
415aD*                    PARM           $LPARM
415aD*                    PARM           $LRTN
415aD*                    ENDSL
     *
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     *
     *     Return code.
     *
     C                   when      row# = 15
     C                   eval      *in06 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lprg = #prog
     C                   eval      $lcode = w1code
     C                   call      'RN900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1code = $lcode
     C                   endif
     *
     *
     *     Item.
     *
     C                   when      row# = 18
     C                   eval      *in03 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lprg = #prog
     C                   eval      $lwhse = w1whse
530cD ***                move      w1citm        $litem
530cD ***                call      'IT900'
530cD ***                parm                    $lparm
530cD ***                if        $lrtn = '*SELECT '
530cD ***                eval      w1citm = $litem
530cD ***                endif
     *
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm2
     C                   endif
413aA*
413aA*  Test for F17 - View receiving log.
413aA*
413aAC                   select
413aAC                   when      *inkr
413aAC                   eval      cmdtkn = *on
223 AC                   eval      $lwhse = w1whse
413aAC                   eval      $lrpo = '*RETURN '
413aAC                   eval      $lrseq = *zeros
413aAC                   eval      $lritm = w1item
413aAC                   call      'PO135'
413aAC                   parm                    $lparm
413aAC                   parm                    $lrtn
413aAC                   endsl
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *   Only blank fields first time in.
     C                   if        not *in32
     C                   eval      w1user = *blanks
     C                   eval      w1item = *blanks
     C                   eval      w1dev = *blanks
     C                   movel     '*DEFAULT'    w1dev
     C                   eval      w1form = *blanks
     C                   movel     '*DEFAULT'    w1form
415aAC                   eval      w1lbl# = 0
     C                   else
415bMC                   eval      w1user = svuser
     C                   eval      w1item = *blanks
415aAC                   eval      w1lbl# = 0
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     *   Get Unit of measure fields
     C                   eval      w1um1 = *blanks
     C                   eval      w1um2 = *blanks
     C                   eval      w1um3 = *blanks
     C                   exsr      zzuom
     *
     *   Format item description
     *
     C                   call      'FRMTIT'
     C                   parm                    ititem
     C                   parm                    itdesc
     C                   parm                    itpdsc
     C                   parm                    $frtn            70
     C                   movel     $frtn         woitem
     *
     *   Initialize entry fields
     *
     C                   eval      w1qt01 = 0
     C                   eval      w1qt02 = 0
     C                   eval      w1qt03 = 0
411 D*R                   Z-ADD0         W1CWTR
     C                   eval      w1expd = 0
     C                   eval      w1code = *blanks
     C                   eval      w1memo = *blanks
416b C                   eval      w1dcde = *blanks
     C                   eval      w1trn# = 0
416bD**                   MOVE *BLANKS   W1CITM
     C                   eval      w1slot = *blanks
415aAC                   eval      w1trn# = wotrn#
416bAC                   if        wolbl# <> 0
416b C                   eval      w1flbl = 'Y'
416b C                   else
416b C                   eval      w1flbl = 'N'
416b C                   endif
416b C                   eval      w1inv# = *blanks
     C                   if        itcwgt <> 'Y'
     C                   eval      *in95 = *on
     C                   else
     C                   eval      *in95 = *off
     C                   endif
     C                   if        itflgd <> 'Y'
     C                   eval      *in96 = *on
     C                   else
     C                   eval      *in96 = *off
     C                   endif
     C                   if        not *in32
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     *
416b C     w1dcde        chain     rdscode                            79
416b C                   eval      w3iinv = 'N'
     *
416bAC                   eval      w3upc = *blanks
416bAC                   eval      w3vmfg = *blanks
416b C                   eval      w3citm = *blanks
     C                   eval      w3memo = *blanks
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      $rprg = #prog
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     *
     *  Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    w1whse
     C                   kfld                    w1item
415b *
415b C     ohkey         klist
415b C                   kfld                    w1whse
415b C                   kfld                    woord
415cA*
415cA*  Define key for UPC file.
415cA*
415cAC     upckey        klist
415cAC                   kfld                    w1whse
415cAC                   kfld                    kyupc
     *
     C     partk2        klist
     C                   kfld                    $rord
     C                   kfld                    w1whse
     *
     *     OPTIONS
     *
     C     opkey         klist
     C                   kfld                    w1whse
     C                   kfld                    ocode
412 A*
    A*  Define key for OPTIOND.
    A*
412 AC     opkey2        klist
412 AC                   kfld                    kycode
412 AC                   kfld                    itwhse
412 AC                   kfld                    itwhdp
412 AC                   eval      kycode = '*PICK   '
530cA*
530cA*  Define key for PIRITEM4 MFG code.
530cA*
530cAC     mfgkey        klist
530cAC                   kfld                    w1whse
530cAC                   kfld                    kyvmfg
     *
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     w1whse        parm      0             #whse             3 0
     *
     *   Open putaway program.
     *
     C                   call      'RC160'
     C                   parm      '*OPEN   '    $rcmd             8
     C                   parm                    $rprg            10
     C                   parm      '*INTER  '    $rtype            8
     C                   parm                    w1whse
     C                   parm                    w1item
     C                   parm                    w1qty1
     C                   parm                    w1qty2
     C                   parm                    w1qty3
     C                   parm      *blanks       $rpo              9
     C                   parm      0             $rven            11 0
     C                   parm      *blanks       $rvnam           40
     C                   parm      *blanks       $rvitm           15
     C                   parm                    $rord             7 0
     C                   parm                    w1code
     C                   parm                    w1memo
     C                   parm                    $rexpd            8 0
     C                   parm                    w1dev            10
     C                   parm                    w1form           10
     C                   parm                    $rslot           12
     C                   parm      0             $rseq             5 0
     C                   parm                    $rrpck            1
     C                   parm                    $rplbl            1
     C                   parm      0             $rdwgt            9 2
     C                   parm                    $rrq1             5 0
     C                   parm                    $rrq2             5 0
     C                   parm                    $rrq3             5 0
     C                   parm                    $rrpal            3 0
     C                   parm                    $rrtn             8
     C                   parm                    $rmsg             4
     *
     *   Initialize headings and return type.
     *
     C                   select
     C                   when      $pcmd = '*RETURN '
     C                   eval      rtntyp = ' '
     C                   eval      w1scrn = 'RN150.01'
     C                   eval      w2scrn = 'RN150.02'
     C                   move      hed(1)        wohead
     C                   when      $pcmd = '*TFRRTN '
     C                   eval      rtntyp = 'T'
     C                   eval      w1scrn = 'RN155.01'
     C                   eval      w2scrn = 'RN155.02'
     C                   move      hed(2)        wohead
     C                   when      $pcmd = '*POSRTN '
     C                   eval      rtntyp = 'P'
     C                   eval      w1scrn = 'RN157.01'
     C                   eval      w2scrn = 'RN157.02'
     C                   move      hed(3)        wohead
     C                   endsl
     *
     *   Center screen heading.
     *
     C                   call      'CENTER'
     C                   parm                    wohead
     C                   parm      60            $clen             3 0
     *
415bAC                   eval      svuser = *blanks
     *
     *   Display first screen.
     *
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZLCNS   Get use generic license option
     *
     C     zzlcns        begsr
     *
     *   Get use generic license option.
     C                   eval      lcnflg = *off
     C                   eval      ocode = '*RCVLBL '
     *
     C     opkey         chain     options                            79
     C                   if        not *in79
     C                   if        opplcn = 'Y'
     C                   eval      lcnflg = *on
     C                   endif
     C                   endif
     *
     C                   endsr
     *
412 A*----------------------------------------------------------------
412 A*
412 A*  ZZPUTO   Get Put away option.
412 A*             Directed or Manual put away
412 A*
412 AC     zzputo        begsr
412 A*
412 AC     itkey         chain     piritem                            79
412 AC                   if        not *in79
412 AC                   eval      kycode = '*PICK   '
412 AC     opkey2        chain     optiond                            79
412 AC                   if        *in79
412 AC                   eval      opmput = 'N'
412 AC                   endif
412 AC                   endif
412 A*
412 AC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUOM    Get Unit Of Measure Normal, Breakdown1, Breakdown2.
     *
     C     zzuom         begsr
     *
     *   Get Unit of Measures.
     *    *IN91=Protect & non-display breakdown1 unit of measure
     *    *IN92=Protect & non-display breakdown2 unit of measure
     *
     *
     C                   eval      *in94 = *off
     C                   eval      *in93 = *off
     C     itkey         chain     piritem                            75
     C                   if        *in75
     C                   eval      *in94 = *on
     C                   eval      *in93 = *on
     C                   goto      enduom
     C                   else
     C                   if        itflg1 = 'N'
     C                   eval      *in94 = *on
     C                   endif
     C                   if        itflg2 = 'N'
     C                   eval      *in93 = *on
     C                   endif
     C                   endif
     *
     C     itum1         chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w1um1 = umshrt
     C                   else
     C                   eval      w1um1 = *blanks
     C                   endif
     *
     C                   if        not *in94
     C     itum2         chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w1um2 = umshrt
     C                   else
     C                   eval      w1um2 = *blanks
     C                   endif
     C                   endif
     *
     C                   if        not *in93
     C     itum3         chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w1um3 = umshrt
     C                   else
     C                   eval      w1um3 = *blanks
     C                   endif
     C                   endif
412aA*
412aAC                   if        ittype = 'S'
412aAC                   eval      itum1 = itum2
412aAC                   eval      itum2 = itum3
412aAC                   eval      itum3 = *blanks
412aAC     itum1         chain     unmesr                             75
412aAC                   if        not *in75
412aAC                   eval      w1um1 = umshrt
412aAC                   else
412aAC                   eval      w1um1 = *blanks
412aAC                   endif
     *
412aAC     itum2         chain     unmesr                             75
412aAC                   if        not *in75
412aAC                   eval      w1um2 = umshrt
412aAC                   else
412aAC                   eval      w1um2 = *blanks
412aAC                   endif
     *
412aAC                   endif
     *
     C     enduom        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
415bAC                   eval      svuser = w1user
     *
415bAC                   if        woord > 0
415bAC     ohkey         chain     ordh                               79
415bAC                   if        not *in79
415bAC                   eval      woord = ohcord
415bAC                   endif
415bAC                   endif
     *
412 AC                   exsr      zzputo
412 AC                   if        opmput = 'Y'
412 AC                   eval      $lcmd = '*RETURN '
412 AC                   eval      $lprg = #prog
412 AC                   eval      $lwhse = w1whse
412 AC                   eval      $litem = w1item
412 AC                   eval      $lusr = w1user
412 AC                   eval      $ldev = w1dev
412 AC                   eval      $lform = w1form
415aAC                   eval      $llbl# = wolbl#
415bAC                   eval      $lord# = woord
415bAC                   eval      $lltrn = wotrn#
412 AC                   call      'RN250'
412 AC                   parm                    $lparm
415aAC                   parm                    $llbl#            7 0
415bAC                   parm                    $lord#            7 0
416bAC                   parm                    $lltrn            7 0
412 AC                   if        $lrtn = '*PGMQ   '
412 AC                   eval      error = *on
412 AC                   eval      *in23 = *on
412 AC                   eval      *in03 = *on
412 AC                   eval      #msgk = $lmsg
412 AC                   exsr      zmqmsg
412 AC                   endif
412 AC                   if        $lrtn = '*CANCEL '
412 AC                   eval      refrsh = *off
412 AC                   exsr      scr01i
412 AC                   goto      endup1
412 AC                   endif
415bAC                   eval      *in32 = *on
412  *
412 AC                   else
     C                   exsr      zzlcns
412 AC                   endif
     *
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     *
     C                   if        w1expd = 0
     C                   eval      $rexpd = 0
     C                   else
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1expd        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   move      $cvd8o        $rexpd
     C                   endif
416b *    Code to enter license and putaway was moved to ZZUPD3
     *
     *
     C     endup2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 3.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
     *
     C                   call      'RC160'
     C                   parm      $pcmd         $rcmd
     C                   parm                    $rprg
     C                   parm      '*INTER  '    $rtype
     C                   parm                    w1whse
     C                   parm                    w1item
     C                   parm      w1qt01        w1qty1            5 0
     C                   parm      w1qt02        w1qty2            5 0
     C                   parm      w1qt03        w1qty3            5 0
     C                   parm      *blanks       $rpo
     C                   parm      0             $rven
     C                   parm      *blanks       $rvnam
     C                   parm      *blanks       $rvitm
415bMC                   parm      woord         $rord
415bD*R                   PARM 0         $RORD
     C                   parm                    w1code
     C                   parm                    w1memo
     C                   parm                    $rexpd
     C                   parm                    w1dev
     C                   parm                    w1form
     C                   parm                    w1slot
     C                   parm      0             $rseq
     C                   parm                    $rrpck
     C                   parm                    $rplbl
     C                   parm      0             $rdwgt
     C                   parm                    $rrq1
     C                   parm                    $rrq2
     C                   parm                    $rrq3
     C                   parm                    $rrpal
     C                   parm                    $rrtn
     C                   parm                    $rmsg
     *
     *   What happened with putaway?
     *
     C                   select
     *
     *      Error occured.
     *
     C                   when      $rrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      #msgk = $rmsg
     C                   exsr      zmqmsg
     *
     *      Enter license if LCNFLG is on.                            .
     *
     C                   other
     *
     C                   if        lcnflg = *on  and
415aAC                             wolbl# = 0
     C                   eval      $lcmd = '*CHANGE '
     C                   eval      $lwhse = w1whse
     C                   move      0             $lpo
     C                   eval      $litem = w1item
     C                   eval      $lrq1 = $rrq1
     C                   eval      $lrq2 = $rrq2
     C                   eval      $lrq3 = $rrq3
     C                   eval      $lrpal = $rrpal
     C                   eval      $lord = $rord
     C                   call      'RN146'
     C                   parm                    $lparm
     *R                   PARM           $LUM1
     *R                   PARM           $LUM2
     *R                   PARM           $LUM3
     C                   parm                    $lord
     C                   endif
415aA*
415aA*      Write to label link file if Label # was entered.          .
415aA*
     *
415aAC                   if        wolbl# <> 0
415aAC                   exsr      zzulnk
415aAC                   endif
     *
     *      Product put away. Write history record and display message.
     C                   clear                   orrec
     C                   eval      orwhse = w1whse
415bMC                   eval      orord = woord
415bD*R                   Z-ADD0         ORORD
     C                   eval      oritem = w1item
     C                   eval      orqty1 = $rrq1
     C                   eval      orqty2 = $rrq2
     C                   eval      orqty3 = $rrq3
     C                   eval      orcwtr = 0
     C                   eval      orrdte = today
     C                   time                    orrtim
     C                   eval      orudte = today
     C                   time                    orutim
     C                   eval      orrusr = w1user
     C                   eval      ortype = rtntyp
     C                   eval      ortrn# = w1trn#
416 AC                   eval      orpbat = $rord
530cD ***                move      w1citm        orcitm
     C                   eval      orrcod = w1code
     C                   eval      orrmem = w1memo
     C                   eval      orslot = w1slot
     C                   write     orrec
     *
     *   *IN32 = position cursor to item number after 1st time in.
     C                   eval      *in32 = *on
     C                   eval      #msgk = $rmsg
     C                   exsr      zmqmsg
411 D*R                   MOVE *OFF      REFRSH
411 MC                   eval      refrsh = *on
     C                   exsr      scr01i
     *
     C                   endsl
     *
     C     endup3        endsr
     *----------------------------------------------------------------
415aA*
415aA*  ZZULNK   Update for LABELNK FILE
415aA*
415aAC     zzulnk        begsr
415aA*
415aA*
415aA*      Write to label link file if Label # was entered.          .
415aA*
     *
415aAC                   if        wolbl# <> 0
415aAC     partk2        setll     label2
415aAC                   eval      stop = *off
415aAC                   dou       stop = *on
415aAC     partk2        reade     label2                                 79
415aAC                   if        *in79
415aAC                   eval      stop = *on
415aAC                   else
415aAC                   eval      lllblo = wolbl#
415aAC                   eval      lllbl# = lblbl#
415aAC                   eval      lltrn# = lbtrn#
415aAC                   eval      llqpck = lbqpck
415aAC                   eval      llucod = lbucod
415aAC                   write     llrec
415aAC                   endif
415aAC                   enddo
415aAC                   endif
415aAC     endlnk        endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Order Number
Quantity Returned
Printer Device
Printer Form
Catch weight
Use label for putaway
Invalid Label#
**  HED
Customer Returns
Transfer Returns
POS Returns
