     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2004')
     H OPTION(*NODEBUGIO)
     F*----------------------------------------------------------------
     F*   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     F*   West Chicago, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  LO110     RF Loader Module
     F*  03 July 2004
     F*  Kenneth Elder
     F*
     F*----------------------------------------------------------------
     F*  Notes
     F*       8 X 20 Screens for hand held scanners
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
417 AF*    07/03/04  MLB  4.17
     F*      - Created.
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions:
     F*
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  01 - 20   FIELD POSITION TO
     F*  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     F*  90        VIEW MODE (PROTECT INPUT FIELDS)
     F*  91        CHANGE MODE (PROTECT KEY)
     F*  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     F*  98        ERROR ON SCREEN (SOUND BUZZER)
     F*  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FLO110FM   CF   e             WORKSTN
     F                                     INFDS(INFDS)
     F                                     SFILE(MSGREC:MSGK)
     Fpiruser1  if   e           K disk
     Frtehed    if   e           k disk
     Ftrkasign  if   e           k disk
     Fpltsum1   if   e           k disk
     Fequip     if   e           k disk
     Floadtrn1  uf a e           k disk
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D DESC            S             50    DIM(5) CTDATA PERRCD(1)
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
     d @ADJTRN         C                   CONST('ADJTRAN2')
     d @PALBAL         C                   CONST('LO120CL')
     D*----------------------------------------------------------------
     D*
     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD8I                25     32
     D  $CVD6O                33     38  0
     D  $CVD8O                39     46  0
     D  $CVSTO                47     64
     D  $CVRTN                65     72
     D  $CVERM                73    132
     D  $CVMSG                73     76
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     D*
     D $LPARM          DS
     D  $LCMD                  1      8
     D  $LPRG                  9     18
     D  $LUKY                 19     68
     D  $LRTN                 69     76
     D  $LERM                 77    136
     D  $LMSG                 77     80
     D  $LTYPE                81     88
     D*
     D*   Redefine key
     D*
     D  $LWHSE                19     21  0
     D  $LCODE                22     27
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
     D  ERFLD                  1     30
     D*----------------------------------------------------------------
     D*  Message control
     D*
     D #MSGF           C                   CONST('PIRMSGF   ')
     D*
     D                 DS
     D  #MSGDT                 1    128
     D  $MD                    1    128
     D                                     DIM(128)
     D*----------------------------------------------------------------
     D*  PIRTRAN record layout for use as parameters
     D*
     D PTPARM        E DS                  EXTNAME(PIRTRAN)
     D*----------------------------------------------------------------
     D*  Program info data structure
     D*
     D                SDS
     D  #PROG            *PROC
     D  #JOB                 244    253
     D  #USER                254    263
     D  #JOBN                264    269
     D  #JOBDT               276    281  0
     D  #JOBTM               282    287  0
     D*----------------------------------------------------------------
     D*  Workstation exception data structure
     D*
     D INFDS           DS
     D  STATUS           *STATUS
     D  ROWIN                370    370
     D  COLIN                371    371
     D*----------------------------------------------------------------
     D*  Workstation exception redefinition data structure
     D*
     D                 DS
     D  ROW#                   1      2B 0
     D  ROW                    2      2
     D  COL#                   3      4B 0
     D  COL                    4      4
     d* work fields ---------------------------------------------------
     d $ptrn#          s              7  0
     d $time           s              6  0
     I*----------------------------------------------------------------
     C*  Main line
     C*
     c     *entry        plist
     c                   parm                    w1whse
     c                   parm                    w1rte
     c                   parm                    w1rtid
     c                   parm                    $mbr             10
     c                   parm                    $rtncd            8
      *
     C                   MOVE      *ON           *IN97
     C                   MOVE      *OFF          *IN90
     C                   MOVE      *OFF          *IN91
     C                   MOVE      *OFF          ERROR
     C*
     C                   DOW       NXTSCR <> 'EOJ'
     C                   EXSR      DSPSCR
     C     NXTSCR        CASEQ     '01 '         SC1
     C     NXTSCR        CASEQ     '02 '         SC2
     C                   ENDCS
     C                   ENDDO
     C*
     C*   Do some clean up before leaving.
     C*
     C                   EXSR      ZSCLR
     c                   eval      *inlr = *on
     c                   return
     C*
     C*----------------------------------------------------------------
     C*  DSPSCR - Display screen
     C*
     CSR   DSPSCR        BEGSR
     C*
     C*   Set ON alarm indicator if error occured
     C*
     CSR                 IF        error = *ON
     CSR                 eval      *in98=*on
     CSR                 ENDIF
     C*
     C*   Overlay screen with error messages
     C*
     C                   EXSR      ZMDMSG
     C*
     C*  Overlay screen with screen to be processed.
     C*
     CSR                 select
     CSR                 when      nxtscr = '01 '
     CSR                 EXFMT     SCREEN1                              50
     c                   eval      first = '0'
     C*
     CSR                 when      nxtscr = '02 '
     C                   EXFMT     SCREEN2                              50
     C*
     CSR                 ENDSL
     C*
     C*   Initialize error indicators and fields
     C*
     CSR                 SETOFF                                       212223
     CSR                 SETOFF                                       249002
     CSR                 move      *off          cmdtkn            1
     CSR                 move      *OFF          WARN              1
     CSR                 MOVE      *OFF          ERROR             1
     C*
     C*   Initialize error subfile
     C*
     CSR                 EXSR      ZMCMSG
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*     Screen initialization and wrap-up routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  Screen 01 initialization
     C*
     CSR   SCR01I        BEGSR
     CSR                 MOVE      '01 '         NXTSCR            3
     CSR                 EXSR      ZZFIL1
     CSR                 MOVE      *OFF          REFRSH            1
     CSR   END01I        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  Screen 02 initialization
     C*
     CSR   SCR02I        BEGSR
     CSR                 MOVE      '02 '         NXTSCR            3
     CSR                 EXSR      ZZFIL2
     CSR                 MOVE      *OFF          REFRSH
     c                   eval      w1plid=0
     CSR   END02I        ENDSR
     C*----------------------------------------------------------------
     C*
     C*              Screen Processing Routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  SC1  -  Screen 1
     C*
     C     SC1           BEGSR
     C*
     C*  Test for F3 - Exit
     C*
     C                   IF        *inkc = *ON
     C                   MOVE      'EOJ'         NXTSCR
     c                   movel     '*EXIT'       $rtncd
     C*
     C                   GOTO      ENDSC1
     C                   ENDIF
     C*
     C*  Test for other command keys BEFORE verification and update.
     C*
     C                   MOVE      '*BEFORE '    CMDCHK            8
     C                   EXSR      ZZCMD1
     C     CMDTKN        CABEQ     *ON           ENDSC1
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     C                   EXSR      ZZCHK1
     C     ERROR         CABEQ     *ON           ENDSC1
     C*
     C*  Test for other command keys AFTER verification and update.
     C*
     C                   MOVE      '*AFTER  '    CMDCHK
     C                   EXSR      ZZCMD1
     C     CMDTKN        CABEQ     *ON           ENDSC1
     c                   exsr      scr02i
     C*
     C     ENDSC1        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SC2  -  Screen 2
     C*
     CSR   SC2           BEGSR
     C*
     C*  Test for F16 - Check balance of open pallets
     C*
     C                   IF        *inKQ = *on
     c
     c*  display subfile with open pallets for
     c*    warehouse, route, and truck1 on F16 pressed
     c*
     c                   movel     #user         $user            10
     c                   move      w1whse        $whse             3
     c                   call      @PALBAL
     c                   parm                    $WHSE
     c                   parm                    W1RTE
     c                   parm                    W1RTID
     c                   parm                    $user
     c                   goto      endsc2
      *
     c                   endif
     C*
     C*  Test for F12 - Cancel or F20 - Complete
     C*
     C                   IF        *inKU = *on
     c
     c*  Close load transaction issued for F20
     c*    then create idle transaction
     c*
     c                   if        *inku = *on
     c                   eval      @pcmd = '*ENDCUR'
     c                   z-add     hldPtrn#      @ptrn#
     c                   endif
     c*
     c                   call      @ADJTRN
     c                   parm                    @pcmd
     c                   parm                    #job
     c                   parm      '*INTER'      @ptype
     c                   parm                    @ptrn#
     c                   parm      'LOAD '       @ptask
     c                   parm      w1whse        @pwhse
     c                   parm      *blanks       @pwhdp
     c                   parm      rhtype        @pstyp
     c                   parm      *zeros        @pcube
     c                   parm      *zeros        @pswgt
     c                   parm      *zeros        @ppcs
     c                   parm      *zeros        @paisl
     c                   parm      *zeros        @pqty1
     c                   parm      *zeros        @pqty2
     c                   parm      *zeros        @pqty3
     c                   parm      rhrte         @prte
     c                   parm      *blanks       @ppo
     c                   parm      'S'           @pgrp1
     c                   parm      'S'           @pgrp2
     c                   parm      *zeros        @pdate
     c                   parm      *zeros        @ptime
     c                   parm      uscode        @puser
     c                   parm      *blanks       @prtn
     c                   parm      *blanks       @pmsg
     c*
     c*  create an idle transaction once employee comes off particular load
     c*
     c                   call      @ADJTRN
     c                   parm      '*CRTSTRT'    @pcmd            10
     c                   parm                    #job
     c                   parm      '*INTER'      @ptype            8
     c                   parm      *zeros        @ptrn#            7 0
     c                   parm      'IDLE '       @ptask            6
     c                   parm      w1whse        @pwhse            3 0
     c                   parm      *blanks       @pwhdp            5
     c                   parm      rhtype        @pstyp            1
     c                   parm      *zeros        @pcube            9 3
     c                   parm      *zeros        @pswgt            9 2
     c                   parm      *zeros        @ppcs             5 0
     c                   parm      *zeros        @paisl            5 0
     c                   parm      *zeros        @pqty1            5 0
     c                   parm      *zeros        @pqty2            5 0
     c                   parm      *zeros        @pqty3            5 0
     c                   parm      rhrte         @prte             5
     c                   parm      *blanks       @ppo              9
     c                   parm      'S'           @pgrp1            1
     c                   parm      'S'           @pgrp2            1
     c                   parm      *zeros        @pdate            8 0
     c                   parm      *zeros        @ptime            6 0
     c                   parm      uscode        @puser           10
     c                   parm      *blanks       @prtn             8
     c                   parm      *blanks       @pmsg             4
      *
     C                   MOVE      '01 '         NXTSCR
     C                   EXSR      SCR01I
     C                   GOTO      ENDSC2
     C                   ENDIF
     C*
     C*  Test for other command keys BEFORE verification and update.
     C*
     C                   MOVE      '*BEFORE '    CMDCHK            8
     C                   EXSR      ZZCMD2
     C     CMDTKN        CABEQ     *ON           ENDSC2
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     CSR                 EXSR      ZZCHK2
     CSR   ERROR         CABEQ     *ON           ENDSC2
     C*
     C*  Test for other command keys AFTER verification and update.
     C*
     CSR                 MOVE      '*AFTER  '    CMDCHK
     CSR                 EXSR      ZZCMD2
     CSR   CMDTKN        CABEQ     *ON           ENDSC2
     c*  write records to LOADTRN once all errors have been passed
     c                   exsr      WrtLOADTRN
     C*
     CSR   ENDSC2        ENDSR
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     CSR   *INZSR        BEGSR
     C*
     C*  Initialize special keys
     C*
     C                   Z-ADD     0             ENTER             5 0
     C                   Z-ADD     2             COMAND            5 0
     C                   Z-ADD     01122         ROLLUP            5 0
     C                   Z-ADD     01123         ROLLDN            5 0
     C                   Z-ADD     01124         CLEAR             5 0
     C                   Z-ADD     01125         HELP              5 0
     c                   move      '1'           first             1
     C*
     C*  Initialize message handling
     C*
     C                   EXSR      ZMIMSG
     C*
     C*   Call user added initialization routine.
     C*
     C                   EXSR      ZZINZ
     C                   ENDSR
     c*---------------------------------------------------------------
     c*
     c*  SUBROUTINE - WrtLOADTRN - Create records for each loaded
     c*                Pallet as placed on Truck
     c*---------------------------------------------------------------
     c     WrtLOADTRN    begsr
     c*
     c*  get current date and time
     c                   eval      $cvtdt = *loval
     c                   eval      $cvcmd = '*CURCMD'
     c                   eval      $cvprg = #job
     c                   call      @CVTDT
     c                   parm                    $CVTDT
     c                   time                    $time
     c*
     c*  load LOADTRN record format for write
     c                   eval      lotrn# = hldPtrn#
     c                   eval      lortid = psrtid
     c                   eval      lorte = rhrte
     c                   eval      loplid = psplid
     c                   eval      lopal = pspal#
     c                   eval      lodate = $cvd8O
     c                   eval      lotime = $time
     c                   write     lorec
     c*
     c                   eval      w1plid = *zeros
     c*
     c                   endsr
     C*---------------------------------------------------------------
     C*
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*
     C*    ZMCMSG  Clear message record subfile
     C*
     CSR   ZMCMSG        BEGSR
     CSR                 MOVE      *OFF          *IN97
     CSR                 WRITE     MSGCTL
     CSR                 Z-ADD     *ZERO         MSGK              4 0
     CSR                 WRITE     MSGCLR
     CSR                 MOVE      '*CLEAR '     #MSGID            7
     CSR                 MOVE      '*NULL  '     #MSGTP            7
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*
     C*    ZMDMSG  Display message record subfile
     C*
     CSR   ZMDMSG        BEGSR
     CSR                 MOVE      *ON           *IN97
     CSR   MSGK          IFGT      0
     CSR                 WRITE     MSGCTL
     CSR                 Z-ADD     *ZERO         MSGK
     CSR                 END
     CSR                 ENDSR
     C*
     C*    ZMIMSG  Initialization necessary for message subfile
     C*
     CSR   ZMIMSG        BEGSR
     CSR                 MOVE      #PROG         #PGMQ            10
     CSR                 EXSR      ZMCMSG
     CSR                 ENDSR
     C*
     C*    ZMPMSG  Add message record to subfile
     C*
     CSR   ZMPMSG        BEGSR
     CSR   $MSGF         IFEQ      *BLANKS
     CSR                 MOVE      #MSGF         $MSGF            10
     CSR                 END
     CSR                 CALL      'PUTMSG'
     CSR                 PARM                    $MSGF
     CSR                 PARM                    #MSGID
     CSR                 PARM                    #MSGTP
     CSR                 PARM                    #MSGDT
     CSR                 PARM                    #PGMQ
     CSR                 PARM                    #MSGK
     CSR   #MSGID        IFNE      '*CLEAR '
     CSR                 ADD       1             MSGK
     CSR                 WRITE     MSGREC
     CSR                 END
     CSR                 MOVE      *BLANKS       #MSGDT
     CSR                 MOVE      *BLANKS       $MSGF
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*    ZSCLR   Clear screen
     C*
     CSR   ZSCLR         BEGSR
     CSR                 WRITE     CLRSCR
     CSR                 MOVE      *ON           SCLEAR            1
     CSR                 ENDSR
     C*
     C*    ZMQMSG  Add message record to subfile from program queue
     C*
     CSR   ZMQMSG        BEGSR
     CSR                 ADD       1             MSGK
     CSR                 WRITE     MSGREC
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*   PIR7971  Error in writing a record.
     C*
     CSR   ZM71          BEGSR
     CSR                 MOVE      'PIR7971'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVE      *BLANKS       $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*   PIR7972  Error in updating a record.
     C*
     CSR   ZM72          BEGSR
     CSR                 MOVE      'PIR7972'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVE      *BLANKS       $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*      0105
     C*
     CSR   ZM0105        BEGSR
     CSR                 MOVE      'PIR0105'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*      0110  Number must be > 0
     C*
     CSR   ZM0110        BEGSR
     CSR                 MOVE      'PIR0110'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*    PIR1060  Pallet already scanned
     C*
     CSR   ZM1060        BEGSR
     CSR                 MOVE      'PIR1060'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     C*R                 MOVEA     ERRMSG        $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*    PIR1001  Invalid option entered.
     C*
     CSR   ZM1001        BEGSR
     CSR                 MOVE      'PIR1001'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*   PIR0203  Value cannot be blank
     C*
     C     ZM0203        begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      $md = *blanks
     C                   movea     errmsg        $md(1)
     C                   exsr      ZMPMSG
     C                   endsr
     C*----------------------------------------------------------------
     C*   PIR9905  Cursor not in correct position for lookup.
     C*
     CSR   ZM9905        BEGSR
     CSR                 MOVE      'PIR9905'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVE      *BLANKS       $MD
     CSR                 EXSR      ZMPMSG
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK1   Screen 1 error checking.
     C*
     C     zzchk1        BEGSR
     C                   MOVE      *OFF          ERROR
     C*
     C*   Verify warehouse and get description.
     C*
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = W1WHSE
     C                   call      'WH900'
     C                   parm                    $LPARM
     C                   if        $lrtn = '*ERROR   '
     C                               or $lrtn = '*PGMQ   '
     c                               and first = '0'
     C                   eval      error = *ON
     C                   eval      *in21 = *ON
     C                   eval      errmsg = desc(3)
     C                   exsr      ZM1001
     c                   goto      endck1
     C                   endif
     C*
     C*  Verify employee number
     C*
     C     w1emp#        chain     PIRUSER1                           79
     C                   if        *in79 = *on and first = '0'
     C                   eval      error = *on
     C                   eval      *in22 = *on
     c                   eval      *in02 = *on
     C                   eval      errmsg = desc(1)
     C                   exsr      zm1001
     C                   goto      endck1
     C                   endif
     C*
     c*  Verify Route ID
     C*
     C                   if        w1rtid<> ' ' and first = '0'
     C     rtekey        chain     rtehed                             79
     C                   if        *in79 = *on
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      errmsg = desc(2)
     C                   exsr      zm1001
     C                   goto      endck1
     C                   endif
     c                   else
     c                   if        first = '0'
      *  route id is blank
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      errmsg = desc(2)
     C                   exsr      zm0203
     c                   goto      endck1
     C                   endif
     c                   endif
     C*
     C*
     c*  Verify Truck Id
     C*
     c                   movel     w1tkid        tkideq
     C     eqkey         chain     equip                              79
     C                   if        *in79 = *on
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      errmsg = desc(4)
     C                   exsr      zm1001
     C                   goto      endck1
     C                   endif
     C*
     C                   if        w1tkid<> ' ' and first = '0'
     c                   movel     w1tkid        tkideq
     C     trkkey        chain     trkasign                           79
     C                   if        *in79 = *on
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      errmsg = desc(4)
     C                   exsr      zm1001
     C                   goto      endck1
     C                   endif
     c                   else
     c                   if        first = '0'
      *  truck id is blank
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      errmsg = desc(4)
     C                   exsr      zm0203
     C                   endif
     c                   endif
     C*
     C     endck1        tag
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK2   Screen 2 error checking.
     C*
     c     zzchk2        begsr
     C*
     C*  Verify Pallet ID
     C*
     c                   eval      *in79 = *off
     C                   if        w1plid <> *ZEROS
     C     plkey         setll     pltsum1
     C                   dow       *in79 = *off
     C     plkey         reade     pltsum1                                79
     C                   if        *in79 = *on
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      errmsg = desc(5)
     C                   exsr      zm1001
     C                   goto      endck2
     C                   endif
     C                   if        w1plid = psplid
     C                   leave
     C                   endif
     C                   enddo
     C                   endif
     c*
     c*  ensure that pallet has not already been scanned
     c*
     C     loadkey       setll     loadtrn1
     C     loadkey       reade     loadtrn1                               79
     C                   if        *in79 = *off
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      errmsg = desc(5)
     C                   exsr      zm1060
     C                   goto      endck2
     C                   endif
     c
     C     endck2        endsr
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD1   User defined command keys for screen 1.
     C*
     CSR   ZZCMD1        BEGSR
     C*
     C*  Command keys to check BEFORE verification and update.
     C*
     CSR   CMDCHK        IFEQ      '*BEFORE '
     C*
     C*  Test for F4 - Lookup
     C*
     CSR   *INKD         IFEQ      *ON
     CSR                 MOVE      *ON           CMDTKN
     CSR                 Z-ADD     0             ROW#
     CSR                 MOVE      ROWIN         ROW
     CSR                 Z-ADD     0             COL#
     CSR                 MOVE      COLIN         COL
     CSR                 SELECT
     C*
     CSR                 OTHER
     C*
     C*     Cursor not on a valid lookup field.
     C*
     CSR                 MOVE      *ON           ERROR
     CSR                 EXSR      ZM9905
     CSR                 ENDSL
     CSR                 GOTO      ENDCM1
     CSR                 ENDIF
     CSR                 ENDIF
     C*
     C*  Command keys to check AFTER verification and update.
     C*
     CSR   CMDCHK        IFEQ      '*AFTER  '
     C*
     CSR                 ENDIF
     C*
     CSR   ENDCM1        ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD2   User defined command keys for screen 2.
     C*
     CSR   ZZCMD2        BEGSR
     C*
     C*  Command keys to check BEFORE verification and update.
     C*
     CSR   CMDCHK        IFEQ      '*BEFORE '
     C*
     CSR                 ENDIF
     C*
     C*  Command keys to check AFTER verification and update.
     C*
     CSR   CMDCHK        IFEQ      '*AFTER  '
     C*
     CSR                 ENDIF
     C*
     CSR   ENDCM2        ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  zzfIL1   Fill screen 1 fields with info from file.
     C*
     CSR   ZZFIL1        BEGSR
     C*
     CSR                 eval      w1emp# = *zeros
     CSR                 eval      w1whse = *zeros
     CSR                 eval      w1rtid = *blanks
     CSR                 eval      w1tkid = *blanks
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL2   Fill screen 2 fields with info from file.
     C*
     c     zzfil2        begsr
     c*
     c*  create transaction in PIRTRAN to track time
     c*
     c                   call      @ADJTRN
     c                   parm      '*CRTSTRT'    @pcmd            10
     c                   parm                    #job
     c                   parm      '*INTER'      @ptype            8
     c                   parm      *zeros        @ptrn#            7 0
     c                   parm      'LOAD '       @ptask            6
     c                   parm      w1whse        @pwhse            3 0
     c                   parm      *blanks       @pwhdp            5
     c                   parm      rhtype        @pstyp            1
     c                   parm      *zeros        @pcube            9 3
     c                   parm      *zeros        @pswgt            9 2
     c                   parm      *zeros        @ppcs             5 0
     c                   parm      *zeros        @paisl            5 0
     c                   parm      *zeros        @pqty1            5 0
     c                   parm      *zeros        @pqty2            5 0
     c                   parm      *zeros        @pqty3            5 0
     c                   parm      rhrte         @prte             5
     c                   parm      *blanks       @ppo              9
     c                   parm      'S'           @pgrp1            1
     c                   parm      'S'           @pgrp2            1
     c                   parm      *zeros        @pdate            8 0
     c                   parm      *zeros        @ptime            6 0
     c                   parm      uscode        @puser           10
     c                   parm      *blanks       @prtn             8
     c                   parm      *blanks       @pmsg             4
     c*
     c                   z-add     @ptrn#        hldPtrn#          7 0
     c                   eval      w1rte = rhrte
     c*
     c*  build name from employee number scanned
     c*
     C                   move      '*LFM    '    $cmd              8
     C                   move      *BLANKS       $NAME            40
     C                   CALL      'FRMTNM'
     C                   PARM                    $CMD
     C                   PARM                    USFNAM
     C                   PARM                    USINIT
     C                   PARM                    USLNAM
     C                   PARM                    $NAME
     C                   MOVEL     $NAME         W1ENAM
     c*
     C     endfl2        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Initialization.  Called from Mainline
     C*
     C     ZZINZ         BEGSR
     C                   MOVE      #PROG         $LPRG
     C                   MOVE      #PROG         $CVPRG
     C                   MOVE      *OFF          FOREVR            1
     c                   eval      nxtscr = '01'
     c                   eval      *in02 = *on
     *
     *    - Get default warehouse for the user.
     *
     C                   call      'GETUSER'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     C                   parm      0             #emp#             5 0
     C                   parm                    #fnam            15
     C                   parm                    #init             1
     C                   parm                    #lnam            20
     C                   parm                    #whdp             5
     C                   parm                    #styp             1
     C                   parm                    #shft             6
     C                   parm                    #crew             6
     C                   parm      0             #nhrs             3 1
     C                   parm                    #rtn              8
     *
     C                   Z-ADD     #WHSE         W1WHSE
     *
     *  Define keys used in program.
     *
     C     rtekey        klist
     C                   kfld                    w1whse
     C                   kfld                    w1rtid
     C*
     C     trkkey        klist
     C                   kfld                    w1rtid
     C                   kfld                    tkideq
     C*
     C     plkey         klist
     C                   kfld                    w1whse
     C                   kfld                    w1rtid
     C*
     C     loadkey       klist
     C                   kfld                    psrtid
     C                   kfld                    rhrte
     C                   kfld                    w1plid
     C*
     C     eqkey         klist
     C                   kfld                    w1whse
     C                   kfld                    tkideq            8
     C*
     C                   ENDSR
     O*  COMPILE TIME TABLES
     O*
**
Employee Number
Route Id
Warehouse Number
Truck Id
Pallet Id
