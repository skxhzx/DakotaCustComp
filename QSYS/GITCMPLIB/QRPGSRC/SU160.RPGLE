      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  SU160     RF Stuffit Overflow Slots
     *  08 February, 2005
     *  Roxanne Harrison
     *
     *  Notes
     *       Created using SU140
     *       Previous revisions were removed to read easier.
     *       8 X 20 Screens for hand held scanners
     *       Program to be used for start up only.
     *        - All overflow slots must have Status = V, no item, and
     *          no quantity.
     *        - No virtual slots can exist in the SLOT or VSLOT file.
     *        - Program will create virtual slots for manual put away.
     *        - Use item maintenance to change an item in a slot,
     *          program will not replace an item already in a slot.
     *        - Program will reduce quantity in overflow from pick slot.
     *
     *
     *----------------------------------------------------------------
     *  Revisions
413aA*    01/12/00  RH  4.13a
     *      - Revised for virtual slots.
413bA*    02/03/00  RH  4.13b
     *      - Fix, ZZCKNS was resetting ERROR and allowing item type
     *        'S' into slot for some cases.
     *
414aA*    07/19/00  RRH  4.14a
     *      - Correct # for Do loop in ZZCKNS
414bA*    10/25/00  RRH  4.14b
     *      - Don't lock VSLOT records in ZZCKSL.
     *
415 A*    03/28/01  DAS  4.15
     *      - Changed SCREEN2 to get item number.
     *      - Added SCREEN3 to get quantity.
     *      - Added some supporting files and routines.
     *      - Saved some of the old SCREEN2 routines by making them
     *        SCREEN99 routines.
     *
415aA*    03/29/01  DAS  4.15a
     *      - Added APICVTDLT.
     *
415bA*    04/17/01  DAS  4.15b
     *      - Added W1SCAN to SCREEN2 & 3.
     *      - Only needed to recompile this program.
     *
416 A*    07/04/02  DAS  4.16
     *      - Added logic to extract item # from Vigo license #
     *      - Enh: Added call to pgm APICVTITM to extract item number
     *             out of data scanned in. Revised routines: SC5, ZZCHK5,
     *             ZZINZ.
416aA*    07/27/02  MLB  4.16a
     *      - FIX: Revised ZZUPD3 when adding a slot record to
     *             initialize all qty fields to zero.
     *             Revised ZZUPD3 when updating a slot record to
     *             move W2QT01,W2QT02,W2QT03 into slot fields if
     *             screen qty's GE zero.
416bA*    09/25/02  RH   4.16b
     *      - Revised to create virutal slot with same status as base
     *        if base is not Z or V.
417aA*    04/14/03  RH   4.17a
     *      - Enh: Allow multiple items for one UPC code.
     *
500 A*    01/10/05  DAS  5.00
     *      - Enh: Converted to ILE.
     *      - Enh: Added "client" logic.
     *
510 A*    09/07/06  MLB  5.10
     *      - Fix: Changed handstack loop in ZZCKNS to be LT 702
     *        instead of LE 702.
     *
700aA*    11/03/16  LMC  7.00a
     *      - Enh: UPC file has a database change. Recompile only.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * City Line Mods
     *
     *   All City Line custom mods should be conditioned with ...
     *      'if client = cityline'
     *   or 'client  cabne  cityline   skipcityln1'
     *   or 'select / when client = cityline / other / endsl'
     *
     *
CLD A*    01/10/05  DAS  CLD
     *      - Enh: Revised to allow scanning of license plate to get item.
     *      - Enh: Added screen
CLDaA*    02/22/05  RLP  CLDa
     *      - Enh: Revised to plug received date into slentd if license entered
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
CLD A*  81        Display license entry field on screen 2
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

     Fsu160fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fslot2     uf a e           k disk
     F                                     rename(slrec:record)
     Fpiritem   if   e           k disk
413aAFoptiond   if   e           k disk
413aAFvslot2    uf a e           k disk
415 AFupc       if   e           k disk
415 AFunmesr    if   e           k disk
x    Fslot3     if   e           k disk
x    Flicense   if   e           k disk
x    Flabel7    if   e           k disk
CLDaAFporcv2    if   e           k disk

     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------

417nA /copy qcopysrc,id#citylin
417nAD client          s             10

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

413aAD a2              s              1    dim(2)
413aAD a2n             s              1    dim(2)
     D a10             s              1    dim(10)
     D desc            s             60    dim(3) ctdata perrcd(1)
     D hnd             s              2    dim(702)
     D ltr             s              1    dim(27) ctdata perrcd(27)

415aA*----------------------------------------------------------------
415aA*  API programs
415aA*----------------------------------------------------------------
415aA
     D @apics          c                   const('APICVTSLT ')
     D @apici          c                   const('APICVTITM ')
415aA
     *----------------------------------------------------------------
     *  Redefinition data structures
     *----------------------------------------------------------------

     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4

413aA*----------------------------------------------------------------
413aA*  *PICK  -  Picking options
413aA*----------------------------------------------------------------
413aA*
413aA* Fields
413aA*
413aA*    OPNXTP  -  Next pallet number.
413aA*    OPBPCK  -  Bulk pick definition.
413aA*    OPPCUB  -  Maximum cube for PIR.
413aA*    OPFPAL  -  Pallets on fixed fork lift.
413aA*    OPFCUB  -  Maximum cube per fixed pallet.
413aA*    OPFSTP  -  Maximum stops per fixed pallet.
413aA*    OPINCL  -  Include PIR in fixed cube.
413aA*    OPSRCH  -  Number of previous pallets to search for space.
413aA*    OPFBLD  -  Fixed pallet building method.
413aA*                1 = By piece without concern for splitting stop.
413aA*                2 = By stop without splitting stop between plts.
413aA*    OPPBRK  -  Break pallets by aisle (Y,N).
413aA*    OPMPUT  -  Manual Put away (Y,N).
413aA*
413aA* Data structure
413aA*
413aAD opddta          ds
413aAD  opnxtp                 1      7  0 inz(0)
413aAD  oppcub                10     14  2 inz(0)
413aAD  opfpal                15     15  0 inz(0)
413aAD  opfcub                16     20  2 inz(0)
413aAD  opincl                22     22
413aAD  opsrch                23     24  0 inz(0)
413aAD  opfstp                25     26  0 inz(0)
413aAD  opfbld                27     27  0 inz(0)
413aAD  opbpck                28     30  0 inz(0)
413aAD  oppbrk                31     33
413aAD  opmput                34     34
413aAD  opdend               117    117
413aA
     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   const('CVTDTE')
415 D**            'FRMTIT'              C         @FMTIT
     D @fmtit          c                   const('FRMTIT2')

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     D  $ltype                81     88
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     D  $litem                27     41
     D  $ldisp                42     53
     *
     D  $litm                 22     36
     *
417a D  $lupc                 22     41
417a D  $litm1                42     56
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
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     *
     *                                   P   1   20ERWHSE
     *
     D  erfld                  1     30
     *
     D  erqty                  1      4p 0
     D  ernqty                 5      8p 0
     *
413 AD  errit1                 1     15
413 AD  errtyp                16     16
413 AD  errit2                17     31
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
     *  PIRTRAN record layout for use as parameters
     *----------------------------------------------------------------

     D ptparm        e ds                  extname(pirtran)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
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
     *  Workstation exception redefinition data structure
     *----------------------------------------------------------------

     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $item           s             15
     D $jobq           s              1
     D $msgf           s             10
     D $pwhs           s             15  5
     D $vaisl          s              3
     D $vloc           s              3  0
     D $vpick          s              1
     D $vpseq          s              5  0
     D $vrlvl          s              2  0
     D $vstyp          s              1
     D $vwhdp          s              5
     D $vwhse          s              3  0
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
     D exist           s              1
     D flaghs          s              1
     D forevr          s              1
     D help            s              5  0
     D i               s              2  0
     D j               s              2  0
     D k               s              3  0
     D kycode          s                   like(opdcod)
     D kyupc           s                   like(upupc)
     D more            s              1
     D msgk            s              4  0
     D newvs           s              1
     D noupc           s              1
     D nxtscr          s              3
     D odisp           s                   like(sldisp)
     D phactv          s                   like(slactv)
     D phaisl          s                   like(slaisl)
     D phbld           s                   like(slbld)
     D phdesg          s                   like(sldesg)
     D phdisp          s                   like(sldisp)
     D phhand          s                   like(slhand)
     D phloc           s                   like(slloc)
     D phpseq          s                   like(slpseq)
     D phrlvl          s                   like(slrlvl)
     D phsdef          s                   like(slsdef)
     D phside          s                   like(slside)
     D phslfd          s                   like(slslfd)
     D phstat          s                   like(slstat)
     D phstyp          s                   like(slstyp)
     D phwhdp          s                   like(slwhdp)
     D phwhse          s                   like(slwhse)
     D redspl          s              1
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D sitem           s             15
     D ssbflg          s              1
     D svexpd          s                   like(slexpd)
     D svscan          s             12
     D today           s              8  0
     D upcctr          s              3  0
     D warn            s              1
     D wxdisp          s                   like(sldisp)
     D woqt01          s                   like(slstk1)
     D woqt02          s                   like(slstk2)
     D woqt03          s                   like(slstk3)
     D k3stat          s                   like(slstat)
     D k3pick          s                   like(slpick)
     D wowhdp          s                   like(w1whdp)
     D woscan          s                   like(sldisp)
     D wolic           s                   like(w2lic)
     D wotrn#          s                   like(litrn#)
     D wodisp          s                   like(sldisp)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      *in99 = *off
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
415 AC     nxtscr        caseq     '03 '         sc3
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   return

     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *----------------------------------------------------------------

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
     C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
     C                   endif
415 AC                   if        nxtscr = '03 '
415 AC                   exfmt     screen3                              50
415 AC                   endif
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
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       363738
     C                   setoff                                       3940
     C                   setoff                                       9298
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
415aAC                   eval      redspl = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *     Screen initialization and wrap-up routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Screen 01 initialization
     *----------------------------------------------------------------

     C     scr01i        begsr
     C                   eval      nxtscr = '01 '
     C                   exsr      zzfil1
     C                   eval      refrsh = *off
     C     end01i        endsr

     *----------------------------------------------------------------
     *  Screen 02 initialization
     *----------------------------------------------------------------

     C     scr02i        begsr
     C                   eval      exist = *off
     C                   eval      newvs = *off
     C                   eval      nxtscr = '02 '
     C                   exsr      zzfil2
     C                   eval      refrsh = *off
     C     end02i        endsr

415 A*----------------------------------------------------------------
415 A*  Screen 03 initialization
415 A*----------------------------------------------------------------

415 AC     scr03i        begsr
415 AC                   eval      exist = *off
415 AC                   eval      newvs = *off
415 AC                   eval      nxtscr = '03 '
415 AC                   exsr      zzfil3
415 AC                   eval      refrsh = *off
415 AC     end03i        endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *              Screen Processing Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  SC1  -  Screen 1
     *----------------------------------------------------------------

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
415aAC     redspl        cabeq     *on           endsc1
     C                   exsr      zzputo
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     C     endsc1        endsr

     *----------------------------------------------------------------
     *  SC2  -  Screen 2
     *----------------------------------------------------------------

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
     C                   eval      refrsh = *off
     C                   eval      nxtscr = '01 '
     C                   eval      w1scan = svscan
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
     C     endsc2        endsr

415 A*----------------------------------------------------------------
415 A*  SC3  -  Screen 3
415 A*----------------------------------------------------------------

415 AC     sc3           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
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
     C                   eval      refrsh = *off
     C                   eval      nxtscr = '02 '
     C                   goto      endsc3
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd3
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
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     C     endsc3        endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

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
     *---------------------------------------------------------------
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *---------------------------------------------------------------
     *---------------------------------------------------------------

     *---------------------------------------------------------------
     *    ZMCMSG  Clear message record subfile
     *---------------------------------------------------------------

     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr

     *---------------------------------------------------------------
     *    ZMDMSG  Display message record subfile
     *---------------------------------------------------------------

     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr

     *---------------------------------------------------------------
     *    ZMIMSG  Initialization necessary for message subfile
     *---------------------------------------------------------------

     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr

     *---------------------------------------------------------------
     *    ZMPMSG  Add message record to subfile
     *---------------------------------------------------------------

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

     *----------------------------------------------------------------
     *    ZSCLR   Clear screen
     *----------------------------------------------------------------

     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr

     *----------------------------------------------------------------
     *    ZMQMSG  Add message record to subfile from program queue
     *----------------------------------------------------------------

     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr

     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *----------------------------------------------------------------

     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *----------------------------------------------------------------

     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *   PIR0105  Invalid slot entered.
     *----------------------------------------------------------------

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *   LP11022  License not on file.
     *----------------------------------------------------------------

     C     zm022         begsr
     C                   eval      #msgid = 'LP11022'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *   PIR0203  Value cannot be blank
     *----------------------------------------------------------------

     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

415 A*----------------------------------------------------------------
415 A*   PIR0205  Value must be entered
415 A*----------------------------------------------------------------

415 AC     zm0205        begsr
415 AC                   eval      #msgid = 'PIR0205'
415 AC                   eval      #msgtp = '*DIAG  '
415 AC                   movea     errmsg        $md(1)
415 AC                   exsr      zmpmsg
415 AC                   endsr

     *----------------------------------------------------------------
     *   IT28001  Invalid slot entered.
     *----------------------------------------------------------------

     C     zm2801        begsr
     C                   eval      #msgid = 'IT28001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *      0110  Number must be > 0
     *----------------------------------------------------------------

     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *    PIR1001  Invalid value entered.
     *----------------------------------------------------------------

     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *   PIR1005  Value must be 'Y' or 'N'
     *----------------------------------------------------------------

     C     zm1005        begsr
     C                   eval      #msgid = 'PIR1005'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr

413 A*----------------------------------------------------------------
413 A*      1301  Can't adjust item type.
413 A*----------------------------------------------------------------

413 AC     zm1301        begsr
     C                   eval      #msgid = 'IT13001'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      errmsg = *blanks
     C                   eval      errit1 = w2item
     C                   eval      errtyp = ittype
     C                   move      ittype        errit2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
413 AC                   endsr

     *----------------------------------------------------------------
413aA*     IT15204  Virtual slot could not be created.
     *----------------------------------------------------------------

413a C     zm1524        begsr
413a C                   eval      #msgid = 'IT15204'
413a C                   eval      #msgtp = '*DIAG  '
413a C                   movea     errmsg        $md(1)
413a C                   exsr      zmpmsg
413a C                   endsr

     *----------------------------------------------------------------
     *   SL16001 No more zero slots.
     *----------------------------------------------------------------

     C     zm1601        begsr
     C                   eval      #msgid = 'SL16001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *----------------------------------------------------------------

     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr

415 A*----------------------------------------------------------------
415 A*   PO20029  UPC not on file.
415 A*----------------------------------------------------------------

415 AC     zm29          begsr
415 AC                   eval      #msgid = 'PO20029'
415 AC                   eval      #msgtp = '*DIAG  '
415 AC                   movea     errmsg        $md(1)
415 AC                   exsr      zmpmsg
415 AC                   endsr

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *   Verify warehouse and get description.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *  Verify warehouse department.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *  Slot can't be blank
     *
     C                   if        w1scan = *blanks
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   movea     desc(2)       errmsg
     C                   exsr      zm0203
     C                   endif
415aA*
415aA*  Call API for slot.
415aA*
415aAC                   call      @apics
415aAC                   parm                    w1scan
415aAC                   parm      5             worow
415aAC                   parm      8             wocol
415aAC                   parm                    @artn             8
415aAC                   if        @artn = '*REDSPLY'
415aAC                   eval      redspl = *on
415aAC                   goto      endck1
415aAC                   endif
     *
     *  Verify slot
     *
     C                   if        w1scan <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   eval      $litem = *blanks
     C                   eval      $ldisp = w1scan
     C                   call      'SL900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   eval      svscan = w1scan
     C                   endif
     *
     C     endck1        endsr

415 A*----------------------------------------------------------------
415 A*  ZZCHK2   Screen 2 error checking.
415 A*----------------------------------------------------------------

415 AC     zzchk2        begsr
     C                   eval      error = *off
     C                   eval      noupc = *off
     *
     *  At least one value must be entered.
     *
     C                   if        w2upc = *blanks  and
CLD AC                             w2lic = *blanks  and
     C                             w2item = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in22 = *on
CLD AC                   eval      *in23 = *on
     C                   eval      *in01 = *on
CLD AC                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0205
     C                   goto      endck2
     C                   endif
     *
     C                   select
500 A*
500 A*  License entered
500 A*
500 AC                   when      w2lic <> *blanks
     *  Left justify license.
     C                   eval      $cstr = *blanks
     C                   eval      $cstr = w2lic
     C                   call      'ADJUST'
     C                   parm      '*LEFTNOZ'    $ccmd
     C                   parm                    $cstr
     C                   movel     $cstr         w2lic
     *  Verify license #
     C     lcnsky        chain     license                            79
     C     *in79         ifeq      *on
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in22 = *on
CLD AC                   eval      *in23 = *on
     C                   eval      *in01 = *on
CLD AC                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm022
     C                   goto      endck2
     C                   endif
     C                   eval      wotrn# = litrn#
     *  Get item# from label
     C     lbkey         setll     label7
     C     lbkey         reade     label7                                 79
     C     *in79         ifeq      *on
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in22 = *on
CLD AC                   eval      *in23 = *on
     C                   eval      *in01 = *on
CLD AC                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm022
     C                   goto      endck2
     C                   endif
xx   C                   eval      wolic  = w2lic
xx   C                   eval      woitem = lbitem
xx   C                   eval      w2item = lbitem
     C*
     *
     *  UPC entered
     *
     C                   when      w2upc <> *blanks
     *
     *     UPC code not on file.
     *
     C                   eval      $cbcmd = '*UPC    '
     C                   movel     w2upc         $cbbar
     C                   call      'CVTBAR'
     C                   parm                    $cbcmd            8
     C                   parm                    $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
     *
     C                   if        $cbrtn = '*OK'
     C                   eval      w2upc = $cbv2
     C                   endif
     *
     *   Right adjust UPC code for file.
     *
     C                   eval      $cstr = *blanks
     C                   movel     w2upc         $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     C                   move      $cstr         kyupc
417a *   Check if mulitple items exist for one UPC code.
417a *    UPCCTR = 0, error, upc code not found.
417a *    UPCCTR = 1, only one upc found, process for item.
417a *    UPCCTR > 1, multiple upc found, need to select item.
417a C                   eval      upcctr = 0
417a C     upckey        setll     upc
417a C                   dow       forevr = forevr
417a C     upckey        reade     upc                                    79
     *
417a C                   if        *in79
417a C                   leave
417a C                   else
417a C                   add       1             upcctr
417a C                   endif
     *
417a C                   enddo
417aD**         UPCKEY    CHAINUPC                  79
417aD**         *IN79     IFEQ *ON
417a C                   if        upcctr = 0
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm29
     C                   goto      endck2
     C                   endif
     *
     *   Multiple items exist for UPC
417a C                   if        upcctr > 1
417a C                   eval      $lcmd = '*VERIFY '
417a C                   eval      $lwhse = w1whse
417a C                   eval      $lupc = kyupc
417a C                   call      'UC920'
417a C                   parm                    $lparm
417a C                   if        $lrtn = '*ERROR  '
417a C                   eval      error = *on
417a C                   eval      *in24 = *on
417a C                   eval      *in04 = *on
417a C                   movel     $lerm         errmsg
417a C                   exsr      zm0105
417a C                   else
417a C                   if        $lrtn = '*PGMQ   '
417a C                   eval      error = *on
417a C                   eval      *in24 = *on
417a C                   eval      *in04 = *on
417a C                   eval      #msgk = $lmsg
417a C                   exsr      zmqmsg
417a C                   endif
417a C                   endif
417a C                   eval      upitem = $litm1
     *
417a C                   endif
     *
     C                   eval      w2item = upitem
     C                   eval      woitem = w2item
     *
     C                   endsl
416 A*
416 A*  Determine if item # or license # entered.
416 A*
416 A*    A vigo license plate is 15 char, same as our item #.
416 A*    A vigo item number is 8 char.
416 A*    A vigo license contains item number in pos 8 - 15.
416 A*    If pos 9-15 are not blank, then assume vigo license.
416 A*
416 A*
416 A*  Call API for item.
416 A*
416 AC                   call      @apici
416 AC                   parm                    w2item
416 AC                   parm      5             worow             3 0
416 AC                   parm      6             wocol             3 0
416 AC                   parm                    @artn
416 AC                   if        @artn = '*REDSPLY'
416 A*R                   MOVE *ON       REDSPL
416 A*R                   GOTO ENDCK5
416 AC                   endif
     *
     *  Verify item #
     *
     C                   eval      $lcmd = '*VERIFYS'
     C                   eval      $lwhse = w1whse
     C                   eval      $litem = w2item
     C                   eval      $litm = w2item
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   goto      endck2
     C                   endif
     * Get pic slot
x    C                   exsr      zzgetp
     *
     C     endck2        endsr

415 A*----------------------------------------------------------------
415 A*  ZZCHK3   Screen 3 error checking.
415 A*----------------------------------------------------------------

415 AC     zzchk3        begsr
     C                   eval      error = *off
     *
     *   Verify that item can go into slot.
     *
     C                   exsr      zzcksl
     C                   if        opmput = 'Y'  and
     C                             exist = *off
     C                   exsr      zzckns
     C                   if        error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     w1scan        errmsg
     C                   exsr      zm1524
     C                   goto      endck3
     C                   endif
     C                   endif
     *
     C     endck3        endsr

     *----------------------------------------------------------------
415 D*  ZZCHK2   Screen 2 error checking.
415 M*  ZZCH99   Screen 99 error checking.
     *----------------------------------------------------------------

415 D**         ZZCHK2    BEGSR
415 MC     zzch99        begsr
     C                   eval      error = *off
     *
     *  Verify item #
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $litem = w2item
     C                   eval      $litm = w2item
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
415 D**         ERROR     CABEQ*ON       ENDCK2
415 MC     error         cabeq     *on           endc99
     *
     *  Only allow entry of normal( ) or breakdown(B) items.
     *
     C     keyit         chain     piritem                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   movea     desc(3)       errmsg
     C                   exsr      zm0105
415 D**                   GOTO ENDCK2
415 MC                   goto      endc99
     C                   else
     *
     C                   if        ittype <> ' '  and
     C                             ittype <> 'B'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1301
     C                   endif
     *
     *
     *  Check if breakdown quantities are valid.
     *
     C                   if        w2qt02 <> 0  or
     C                             w2qt03 <> 0
     C                   if        itflg1 = 'N'  and
     C                             w2qt02 <> 0
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   movea     desc(3)       errmsg
     C                   exsr      zm1001
     C                   endif
     C                   if        itflg2 = 'N'  and
     C                             w2qt03 <> 0
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   movea     desc(3)       errmsg
     C                   exsr      zm1001
     C                   endif
     C                   endif
     C                   endif
415 D**         ERROR     CABEQ*ON       ENDCK2
415 MC     error         cabeq     *on           endc99
     *
413a C                   exsr      zzcksl
413aAC                   if        opmput = 'Y'  and
413XAC                             exist = *off
413a C                   exsr      zzckns
413aAC                   if        error = *on
413aAC                   eval      *in21 = *on
413aAC                   eval      *in01 = *on
413aAC                   eval      errmsg = *blanks
413aAC                   movel     w1scan        errmsg
413aAC                   exsr      zm1524
415 D**                   GOTO ENDCK2                                C
415 MC                   goto      endc99
413aAC                   endif
413aAC                   endif
     *
415 D**         ENDCK2    ENDSR
415 MC     endc99        endsr

     *----------------------------------------------------------------
     *  ZZCKNS   Use reg slot or get new Vslot.
     *----------------------------------------------------------------

     C     zzckns        begsr
     C                   eval      error = *on
     C     keysl2        chain(n)  record                             79
     C                   if        not *in79
     C                   if        slitem = *blanks
     C                   eval      error = *off
     C                   goto      endckn
     C                   else
413 A*   Get out if physical slot already uses both
413aA*   positions of handstack field.
413aAC                   movea     slhand        a2
413aAC                   if        a2(1) <> ' '
413aAC                   goto      endckn
413aAC                   endif
     *   Set handstack flag for later use.
413aAC                   if        slhand <> ' '
413aAC                   eval      flaghs = *on
413aAC                   else
413aAC                   eval      flaghs = *off
413aAC                   endif
     * SAVE PHYSICAL SLOT FIELDS
     C                   eval      phwhse = slwhse
     C                   eval      phwhdp = slwhdp
416b C                   eval      phstat = slstat
     C                   eval      phaisl = slaisl
     C                   eval      phloc = slloc
     C                   eval      phrlvl = slrlvl
     C                   eval      phhand = slhand
     C                   eval      phside = slside
     C                   eval      phstyp = slstyp
     C                   eval      phdisp = sldisp
     C                   eval      phsdef = slsdef
     C                   eval      phdesg = sldesg
     C                   eval      phpseq = slpseq
     C                   eval      phactv = slactv
     C                   eval      phbld = slbld
     C                   eval      phslfd = slslfd
     ***
     C                   eval      $vpseq = slpseq
     C                   eval      $vdisp = *blanks
     C                   eval      k = 0
     C                   eval      $vwhse = slwhse
     C                   eval      $vwhdp = slwhdp
     C                   eval      $vaisl = slaisl
     C                   eval      $vloc = slloc
     C                   eval      $vrlvl = slrlvl
     C                   eval      $vhand = *blanks
     C                   eval      $vstyp = slstyp
     C                   eval      $vpseq = slpseq
     C                   eval      $vdisp = *blanks
     C                   eval      $vpick = slpick
     *** Loop & increment handstack to find new v-slot to create.
414aD*R         K         DOWLE720
510 DC*                  dow       k <= 702
510 MC                   dow       k <  702
     C                   add       1             k
     *     If physical slot had handstack then limit hs we can use.
413aAC                   if        flaghs = *on
413aAC                   movea     hnd(k)        a2n
413aAC                   if        a2n(1) <> a2(2)
413aAC                   iter
413aAC                   endif
413aAC                   endif
     C                   eval      $vhand = hnd(k)
413aAC                   call      'FRMTVS'
413aAC                   parm                    phdisp
413aAC                   parm                    flaghs
413aAC                   parm                    $vhand            2
413aAC                   parm                    $vdisp           12
     *
     C     ckkey         chain(n)  record                             79
     C                   if        *in79
     C                   eval      newvs = *on
413aAC                   eval      error = *off
     C                   eval      w1scan = $vdisp
     C                   leave
     C                   else
     C                   iter
     C                   endif
     C                   enddo
     C                   endif
     C                   endif
     *
     C     endckn        endsr

     *----------------------------------------------------------------
413  *  ZZCKSL   Check if item exists in reg or V slot
     *----------------------------------------------------------------

     C     zzcksl        begsr
x    C                   eval      woqt01= 0
     C                   eval      woqt02= 0
     C                   eval      woqt03= 0
     C     keysl2        chain(n)  record                             79
     C                   if        not *in79  and
     C                             slitem = w2item
x    C                   eval      woqt01= slstk1
     C                   eval      woqt02= slstk2
     C                   eval      woqt03= slstk3
     C                   eval      exist = *on
     C                   goto      endcks
     C                   else
     C     keysl2        setll     vslot2
     C     nxt1          tag
414bD**         KEYSL2    READEVSLOT2                   78
414bMC     keysl2        reade(n)  vslot2                                 78
     C                   if        not *in78
     C     vskey         chain(n)  record                             79
     C                   if        not *in79  and
     C                             slitem = w2item
x    C                   eval      woqt01= slstk1
     C                   eval      woqt02= slstk2
     C                   eval      woqt03= slstk3
     C                   eval      exist = *on
     C                   eval      w1scan = sldisp
     C                   goto      endcks
     C                   else
     C                   goto      nxt1
     C                   endif
     C                   endif
     C                   endif
     *
     C     endcks        endsr

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

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
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZCMD2   User defined command keys for screen 2.
     *----------------------------------------------------------------

     C     zzcmd2        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr

415 A*----------------------------------------------------------------
415 A*  ZZCMD3   User defined command keys for screen 3.
415 A*----------------------------------------------------------------

415 AC     zzcmd3        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3        endsr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr
     *
     C                   eval      w1scan = *blanks
     C                   endsr

415 A*----------------------------------------------------------------
415 A*  ZZFIL2   Fill screen 2 fields with info from file.
415 A*----------------------------------------------------------------

415 AC     zzfil2        begsr
     *
CLD AC                   eval      w2lic = *blanks
     C                   eval      w2upc = *blanks
     C                   eval      w2item = *blanks
     C                   eval      *in99 = *on
CLD A*
CLD A*  See if license entry field should be displayed.
CLD A*
CLD AC*                  if        client = cityline
CLD AC*                  eval      *in81 = *on
CLD AC*                  else
CLD AC*                  eval      *in81 = *off
CLD AC*                  endif
     *
     C                   endsr

415 A*----------------------------------------------------------------
415 A*  ZZFIL3   Fill screen 3 fields with info from file.
415 A*----------------------------------------------------------------

415 AC     zzfil3        begsr
     *
     C                   exsr      zzgeti
     C                   exsr      zzuom
     C                   eval      w2qt01 = 0
     C                   eval      w2qt02 = 0
     C                   eval      w2qt03 = 0
     *
     C                   endsr

     *----------------------------------------------------------------
415 D** ZZFIL2   Fill screen 2 fields with info from file.
415 M*  ZZFI99   Fill screen 99 fields with info from file.
     *----------------------------------------------------------------

415 D**         ZZFIL2    BEGSR
415 MC     zzfi99        begsr
     C                   eval      w2item = *blanks
     C                   eval      w2qt01 = 0
     C                   eval      w2qt02 = 0
     C                   eval      w2qt03 = 0
     C     keysl2        chain(n)  slot2                              79
     C                   if        not *in79
     *R                   MOVE SLITEM    W2ITEM
     *R                   Z-ADDSLSTK1    W2QT01
     *R                   Z-ADDSLSTK2    W2QT02
     *R                   Z-ADDSLSTK3    W2QT03
     C                   else
     C                   eval      error = *on
     C                   eval      nxtscr = '01 '
     C                   exsr      zm1601
     C                   eval      errmsg = *blanks
     C                   exsr      zm1601
     C                   endif
     C                   eval      *in99 = *on
     *
415 D**         ENDFL2    ENDSR
415 MC     endf99        endsr

415 A*----------------------------------------------------------------
415 A*  ZZGETI   Get item description and pack description.
415 A*----------------------------------------------------------------

415 AC     zzgeti        begsr
     *
     *   Get item
     *
     C                   eval      woitem = *blanks
     C     keyit         chain     piritem                            79
     C                   if        *in79
     C                   eval      itdesc = *blanks
     C                   eval      itpdsc = *blanks
     C                   endif
     *
     *   Format item description
     *
     C                   eval      $iitem = w2item
     C                   eval      $idesc = itdesc
     C                   eval      $ipdsc = itpdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   movel     $istr         woitem
     *
     *   Get SSB item, if one exists
     *
     C                   eval      ssbflg = *off
     C                   if        ittype = ' '
     C                   call      'GETSSB'
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
     C                   parm      ' '           #bitem           15
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum              2
     C                   parm                    #bum2             2
     C                   parm                    #bumq2            3 0
     C                   parm                    #bum3             2
     C                   parm                    #bumq3            3 0
     C                   parm                    #brtn             8
     *
     C                   if        #brtn = '*FOUND  '
     C                   eval      ssbflg = *on
     C                   endif
     C                   endif
     *
     C                   endsr

x   A*----------------------------------------------------------------
    A*  ZZGETP   Get first pick slot for item.
    A*----------------------------------------------------------------

    AC     zzgetp        begsr
     *
     *   Get first pick slot for item.
     C                   eval      k3stat = 'A'
     C                   eval      k3pick = 'Y'
     C     keys3         setll     slot3
     C     keys3         reade     slot3                                  79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in22 = *on
CLD AC                   eval      *in23 = *on
     C                   eval      *in01 = *on
CLD AC                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm022
     C                   else
     C                   eval      wowhdp = slwhdp
     C                   eval      wodisp = sldisp
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr
417a C                   eval      forevr = *off
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   eval      wxdisp = *blanks
     C                   eval      forevr = *off
x    C*    *like         define    slstat        k3stat
x    C*    *like         define    slpick        k3pick
x    C*    *like         define    w1whdp        wowhdp
x    C*    *like         define    sldisp        woscan
x    C*    *like         define    w2lic         wolic
x    C*    *like         define    w2item        woitem
x    C*    *like         define    litrn#        wotrn#
x    C*    *like         define    sldisp        wodisp
     *
     *  Define key for PIRITEM.
     *
     C     keyit         klist
     C                   kfld                    $lwhse
     C                   kfld                    w2item
     *
     *  Define key for slot2 file by display field.
     *
     C     keysl2        klist
     C                   kfld                    $lwhse
     C                   kfld                    w1whdp
     C                   kfld                    w1scan
     *
     C     keyslp        klist
     C                   kfld                    $lwhse
     C                   kfld                    w1whdp
     C                   kfld                    wodisp
     *
     C     vskey         klist
     C                   kfld                    $lwhse
     C                   kfld                    w1whdp
     C                   kfld                    vsdisp
     *
     C     ckkey         klist
     C                   kfld                    $lwhse
     C                   kfld                    w1whdp
     C                   kfld                    $vdisp
     *
     *  Define key for OPTIOND.
     *
     C     opkey2        klist
     C                   kfld                    kycode
     C                   kfld                    $lwhse
     C                   kfld                    w1whdp
     C                   eval      kycode = '*PICK   '
415 A*
415 A*  Define key for UPC file.
415 A*
415 AC     upckey        klist
415 AC                   kfld                    w1whse
415 AC                   kfld                    kyupc
     *
     *  Define key for SLOT3 file.
     *
x    C     keys3         klist
     C                   kfld                    w1whse
     C                   kfld                    w2item
     C                   kfld                    k3stat
     C                   kfld                    k3pick
     *
     *  Define key for LICENSE file.
     *
x    C     lcnsky        klist
     C                   kfld                    w1whse
     C                   kfld                    w2lic
     *
     *  Define key for Label7 file.
     *
x    C     lbkey         klist
     C                   kfld                    wotrn#
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *
     *
     *    - Get default warehouse for the user.
     *
VGOaD*R                   CALL 'GETWHSE'
VGOaMC                   call      'GETUSER'
VGOaAC                   parm                    #user
VGOaAC                   parm      0             #whse             3 0
VGOaAC                   parm                    #emp#             5 0
VGOaAC                   parm                    #fnam            15
VGOaAC                   parm                    #init             1
VGOaAC                   parm                    #lnam            20
VGOaAC                   parm      *blanks       #whdp             5
VGOaAC                   parm                    #styp             1
VGOaAC                   parm                    #shft             6
VGOaAC                   parm                    #crew             6
VGOaAC                   parm                    #nhrs             3 1
VGOaAC                   parm                    #rtn              8
     *
     C                   eval      w1whse = #whse
VGOaMC                   eval      w1whdp = #whdp

500 A* Get client id

500 AC                   call      'GETCLIENT'
500 AC                   parm                    client
     *
     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ2   Program initialization. Called from main line.
     *----------------------------------------------------------------

     C     zzinz2        begsr
     *
     *   Load handstack array with codes (A..Z, AA..AZ, ...)
     *
     C                   eval      k = 0
     C     1             do        27            i
     C     2             do        27            j
     C                   add       1             k
     C     ltr(i)        cat       ltr(j)        hnd(k)
     C                   enddo
     C                   enddo
     *
     C                   eval      refrsh = *on
     C                   eval      more = *off
VGOaD*R                   MOVE *BLANKS   W1WHDP
     C                   exsr      scr01i
     C                   endsr

x   A*----------------------------------------------------------------
    A*  ZZPSLT   Reduce pick slot by stuffit quantity
    A*----------------------------------------------------------------

    AC     zzpslt        begsr
     *
     *   Get pick slot.
     C     keyslp        chain     record                             79
     *
     C                   if        not *in79
     C                   if        slstat = 'V' or
     C                             slstat = 'Z'
     C                   goto      endslp
     C                   endif
     *
     *
416aMC                   if        w2qt01 >= 0  and
     C                             ittype <> 'S'
     C                   eval      slstk1 = slstk1 - (w2qt01 - woqt01)
     C                   endif
     C                   if        w2qt02 >= 0  and
     C                             ittype <> 'S'
     C                   eval      slstk2 = slstk2 - (w2qt02 - woqt02)
     C                   endif
     C                   if        w2qt03 >= 0  and
     C                             ittype <> 'S'
     C                   eval      slstk3 = slstk3 - (w2qt03 - woqt03)
     C                   endif
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endslp
     C                   endif
     C                   endif
     C     endslp        endsr
     *----------------------------------------------------------------
     *  ZZRCAL   Recalculate item quantity from slots.
     *----------------------------------------------------------------

     C     zzrcal        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     * Recalculate item qty.
     C                   eval      $pwhs = $lwhse
     C                   eval      $jobq = 'N'
     C                   call      'UT812'
     C                   parm                    $pwhs
     C                   parm                    $item
     C                   parm                    $jobq
     C                   parm                    $lprg
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endcal
     C                   endif
     *
     C     endcal        endsr

     *----------------------------------------------------------------
     *  ZZPUTO   Get Put away option.
     *             Directed or Manual put away
     *----------------------------------------------------------------

     C     zzputo        begsr
     *
     C                   eval      kycode = '*PICK   '
     C     opkey2        chain     optiond                            79
     C                   if        *in79
     C                   eval      opmput = 'N'
     C                   endif
     *
     C                   endsr

415 A*----------------------------------------------------------------
415 A*  ZZUOM    Get Unit Of Measure Normal, Breakdown1, Breakdown2.
415 A*
415 A*    *IN95=Protect & non-display breakdown1 unit of measure
415 A*----------------------------------------------------------------

415 AC     zzuom         begsr
     *
     *   Determine which UOM's are needed.
     *
     C                   if        itflg1 = 'Y'  or
     C                             ssbflg = *on
     C                   eval      *in95 = *off
     C                   else
     C                   eval      *in95 = *on
     C                   endif
     *
     C                   if        itflg2 = 'Y'  or
     C                             ssbflg = *on  and
     C                             itum3 <> *blanks
     C                   eval      *in96 = *off
     C                   else
     C                   eval      *in96 = *on
     C                   endif
     *
     *   Get Unit of Measures.
     *
     *
     C     itum1         chain     unmesr                             75
     C                   if        not *in75
     C                   eval      woum1 = umshrt
     C                   else
     C                   eval      woum1 = *blanks
     C                   endif
     *
     C                   eval      woum2 = *blanks
     C                   if        itflg1 = 'Y'  or
     C                             ssbflg = *on
     C     itum2         chain     unmesr                             75
     C                   if        not *in75
     C                   eval      woum2 = umshrt
     C                   else
     C                   eval      woum2 = *blanks
     C                   endif
     C                   endif
     *
     C                   eval      woum3 = *blanks
     C                   if        itflg2 = 'Y'  or
     C                             ssbflg = *on  and
     C                             itum3 <> *blanks
     C     itum3         chain     unmesr                             75
     C                   if        not *in75
     C                   eval      woum3 = umshrt
     C                   else
     C                   eval      woum3 = *blanks
     C                   endif
     C                   endif
     *
     C     enduom        endsr

     *----------------------------------------------------------------
     *  ZZUPD1   Update for screen 1.
     *----------------------------------------------------------------

     C     zzupd1        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     C                   exsr      scr02i
     C     endup1        endsr

415 A*----------------------------------------------------------------
415 A*  ZZUPD2   Update for screen 2.
415 A*----------------------------------------------------------------

415 AC     zzupd2        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     C                   exsr      scr03i
     C     endup2        endsr

     *----------------------------------------------------------------
     *  ZZUPD3   Update for screen 3.
     *----------------------------------------------------------------

     C     zzupd3        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     C                   eval      sitem = *blanks
     *
     *   Update record.
     *
     *
     *  Create new slot record
     *  $V = from Physical slot when virtual was checked
     *  PH = from saved from physical slot when virtual was checked
     *  SV = saved from 'FROM' slot.
     *  SL = saved from 'FROM' slot.
     C                   if        newvs = *on
     C                   eval      slwhse = $vwhse
     C                   eval      slwhdp = $vwhdp
416bAC                   if        phstat <> 'Z '  and
416bAC                             phstat <> 'V '
416bAC                   eval      slstat = phstat
416bAC                   else
     C                   eval      slstat = 'A '
416bAC                   endif
     C                   eval      slaisl = $vaisl
     C                   eval      slloc = $vloc
     C                   eval      slrlvl = $vrlvl
     C                   eval      slhand = $vhand
     C                   eval      slside = phside
     C                   eval      slstyp = $vstyp
     C                   eval      sldisp = $vdisp
     C                   eval      slsdef = phsdef
     C                   eval      sldesg = phdesg
     C                   eval      slactv = phactv
     C                   eval      slbld = phbld
     C                   eval      slpseq = $vpseq
     C                   eval      slslfd = 0
     C                   eval      slrsrv = 'V'
     C                   eval      slexpd = svexpd
     C                   eval      slprty = 0
     C                   eval      slentd = today
     C                   eval      slsdte = today
     C                   time                    slstim
CLDaA*   Get received date if license entered and plug into slentd
CLDaAC                   if        client = cityline and
CLDaAC                             w2lic <> *blanks
CLDaAC     w2lic         chain(n)  porrec                             79
CLDaAC                   if        not *in79
CLDaAC                   eval      slentd = pordte
CLDaAC                   endif
CLDaAC                   eval      *in79 = *off
CLDaAC                   endif
CLDaA*
     C                   eval      slitem = w2item
416aAC                   eval      slstk1 = *zeros
416aAC                   eval      slstk2 = *zeros
416aAC                   eval      slstk3 = *zeros
416aAC                   eval      slalc1 = *zeros
416aAC                   eval      slalc2 = *zeros
416aAC                   eval      slalc3 = *zeros
416aAC                   eval      slpck1 = *zeros
416aAC                   eval      slpck2 = *zeros
416aAC                   eval      slpck3 = *zeros
416aAC                   eval      sltfr1 = *zeros
416aAC                   eval      sltfr2 = *zeros
416aAC                   eval      sltfr3 = *zeros
416aAC                   eval      slrcv1 = *zeros
416aAC                   eval      slrcv2 = *zeros
416aAC                   eval      slrcv3 = *zeros
     C                   if        w2qt01 > 0  and
     C                             ittype <> 'S'
     C                   eval      slstk1 = w2qt01
     C                   endif
     C                   if        w2qt02 > 0  and
     C                             ittype <> 'S'
     C                   eval      slstk2 = w2qt02
     C                   endif
     C                   if        w2qt03 > 0  and
     C                             ittype <> 'S'
     C                   eval      slstk3 = w2qt03
     C                   endif
     *
     C                   write     record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
415 MC                   goto      endup3
     C                   endif
     *  create vslot record.
     C                   eval      vswhse = $vwhse
     C                   eval      vswhdp = $vwhdp
     C                   eval      vsaisl = $vaisl
     C                   eval      vsloc = $vloc
     C                   eval      vsrlvl = $vrlvl
     C                   eval      vshand = $vhand
     C                   eval      vsdisp = $vdisp
     C                   eval      vspdis = phdisp
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      vscdte = $cvd8o
     C                   time                    vsctim
     C                   add       1             vsctim
     C                   write     vsrec                                79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
415 MC                   goto      endup3
     C                   endif
     ***
     C                   else
     *** Update slot record
     *
     C     keysl2        chain     record                             79
     *
     C                   if        not *in79
     *
     C                   eval      slitem = w2item
     C                   if        slstat = 'V '  or
     C                             slstat = 'Z '
     C                   eval      slstat = 'A '
     C                   endif
416aD**         W2QT01    IFGT 0
416aMC                   if        w2qt01 >= 0  and
     C                             ittype <> 'S'
     C                   eval      slstk1 = w2qt01
     C                   endif
416aD**         W2QT02    IFGT 0
416aMC                   if        w2qt02 >= 0  and
     C                             ittype <> 'S'
     C                   eval      slstk2 = w2qt02
     C                   endif
416aD**         W2QT03    IFGT 0
416aMC                   if        w2qt03 >= 0  and
     C                             ittype <> 'S'
     C                   eval      slstk3 = w2qt03
     C                   endif
     *
     C                   eval      slentd = today
     C                   eval      slsdte = today
     C                   time                    slstim
CLDaA*   Get received date if license entered and plug into slentd
CLDaAC                   if        client = cityline and
CLDaAC                             w2lic <> *blanks
CLDaAC     w2lic         chain(n)  porrec                             79
CLDaAC                   if        not *in79
CLDaAC                   eval      slentd = pordte
CLDaAC                   endif
CLDaAC                   eval      *in79 = *off
CLDaAC                   endif
CLDaA*
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endup3
     C                   endif
     C                   endif
     C                   endif
     * Reduce pick slot by entered quantity.
x    C                   exsr      zzpslt
     * Recalculate item qty for slot item
     C                   eval      $item = w2item
     C                   exsr      zzrcal
     C                   if        error = *on
     C                   goto      endup3
     C                   endif
     *
     C     endup3        tag
     C                   exsr      scr01i
     C                   endsr

     *----------------------------------------------------------------*********
     *----------------------------------------------------------------*********
     *  COMPILE TIME TABLES
     *----------------------------------------------------------------*********
     *----------------------------------------------------------------*********
**
Dept
Slot
Quantity
**
 ABCDEFGHIJKLMNOPQRSTUVWXYZ
