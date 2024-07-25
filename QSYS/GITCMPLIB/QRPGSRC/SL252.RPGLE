      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  SL252    Change existing item number in slot
     *  18 January 2000
     *  Dave Sommerville
     *
     *  Revisions:
     *
413 A*    01/18/00  DAS  4.13
     *      - Created
     *
413aA*    02/28/00  DAS  4.13
     *      - Revised to verify item number using command *VERIFYS.
     *        This command verifies that the item is allowed to be
     *        put into the slot. Currently, only ' ' and 'B' items
     *        are allowed into slots.
414bA*    09/07/00  RH   4.14b
     *      - Revised to check for corresponding SSB record. If one
     *        exists, two records are written to ITEMADJ.
414cA*    09/07/00  RH   4.14c
     *      - Calculate catch weight for each item adjust. record.
     *
415aA*    05/24/01  MLB  4.15a
     *      - Revise pgm to add multi pick slot code.
     *      - Added file OPTIONS, ITEMMSC.
     *
415bA*    08/03/01  DAS  4.15
     *      - Created routine ZZZDTE to get today's date.
     *      - Revised every place that used TODAY to see if time went
     *        past midnight. If it did, ZZZDTE is called.
     *
415cA*    08/03/01  DAS  4.15
     *      - Added logic to write label adjustment record when
     *        adjustment record is created.
416 A*    07/02/02  RH   4.16
     *      - Recompiled, ITEMMSC changed.
417aA*    04/03/03  RH   4.17a
     *      - Recompiled, ITEMMSC file changed.
     *
510aA*    06/09/06  DAS  5.10a
     *      - Enh: Revised ZZZCHG to call UPDSLTDTE.
     *
600 A*    05/18/09  DAS  6.00   P$00045
     *      - License tracking
     *      - Converted to ILE
     *
600aA*    05/18/09  DAS  6.00a  P$00045
     *      - Revised to use DRISLOT to do change.
     *      - Deleted all unnecessary code for readability.
     *
530aA*    10/22/09  RH   5.30a
     *      - Renamed screen format to SL25201
     *      - Enh: Add CW to screen3 if either item is CW.
610aA*    10/26/09  DAS  6.10a
     *      - Revised to send *MULTIPLE for license fields for *CHGITEM.
     *        This is because we don't work with the license number
     *        when changing an item number.
610bA*    06/04/10  RH   6.10b
     *      - Fix: send user in $SABY field to DRISLOT.  Adjustment
     *        was being created with blank adjusted by field.
640aA*    06/02/11  DAS  6.40a
     *      - Revised to send new DRISLOT parm $saItmChg.
640bA*    05/24/12  LMC  6.40b
     *      - Revised to edit New item cannot be the same as old item.
640cA*    06/22/12  LMC  6.40c
     *      - Revised to add Memo field for entry to be passed to the
     *        dry interface, and eventually be stored in the ITEMADJ
     *        file in field IAMEMO.
     *
700aA*    03/25/15  LMC  7.00a
     *      - Enh: Added the ITEMCHG file.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 10   Position cursor indicators
     *  21 - 30   Reverse display indicators
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
530aDF*l252fm   cf   e             workstn
640cDF*sl25201   cf   e             workstn
640cMFsl25202   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
600aMFslot2     if   e           k disk
     F                                     rename(slrec:record)
415aAFslot3     if   e           k disk
     F                                     rename(slrec:s3rec)
     Fwarehs    if   e           k disk
     Fwhdept    if   e           k disk
     Fslotstat  if   e           k disk
415aAFitemmsc   if   e           k disk
415aAFoptions   if   e           k disk
     Fpiritem   if   e           k disk
     Funmesr    if   e           k disk
600aDF*temadj   o  a e           k disk
600aDF*abel     o  a e           k disk
700aAFitemchg   if a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
640bDD*desc            s             50    dim(2) ctdata perrcd(1)
640bMD desc            s             50    dim(3) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
600aA /COPY *libl/qcopysrc,C#SLOT
600aA /COPY *libl/qcopysrc,C#ITEM
600aAD savever#        s                   like($slver#)
600aAD #from           ds                  likeds($item)
600aAD #from2          ds                  likeds($item2)
600aAD #new            ds                  likeds($item)
600aAD #new2           ds                  likeds($item2)

     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $pwhdp                22     26
     D  $pdisp                27     38
     D  $pitem                39     53
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  *PICK  -  Picking options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPNXTP  -  Next pallet number.
     *    OPBPCK  -  Bulk pick definition.
     *    OPPCUB  -  Maximum cube for PIR.
     *    OPFPAL  -  Pallets on fixed fork lift.
     *    OPFCUB  -  Maximum cube per fixed pallet.
     *    OPFSTP  -  Maximum stops per fixed pallet.
     *    OPINCL  -  Include PIR in fixed cube.
     *    OPSRCH  -  Number of previous pallets to search for space.
     *    OPFBLD  -  Fixed pallet building method.
     *                1 = By piece without concern for splitting stop.
     *                2 = By stop without splitting stop between plts.
     *    OPPBRK  -  Break pallets by aisle (Y,N).
     *    OPMPUT  -  Manual Put away (Y,N).
     *
     * Data structure
     *
     D opddta          ds
     D  opnxtp                 1      7  0 inz(0)
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
     D  opfbld                27     27  0 inz(0)
     D  opbpck                28     30  0 inz(0)
     D  oppbrk                31     33
     D  opmput                34     34
     D  opdend               117    117
415aA*----------------------------------------------------------------
415aA*  *SYSTEM  -  System options.
415aA*----------------------------------------------------------------
415aA*
415aA* Fields
415aA*
415aA*    OPEPM   -  Using EPM module (Y,N).
415aA*    OPRF    -  Using RF module (Y,N).
415aA*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
415aA*    OPLETD  -  Print letdown labels (Y,N).
415aA*    OPWRNC  -  Perform catch weight variance check (Y,N).
415aA*    OPRG1C  -  Catch weight low variance percentage.
415aA*    OPRG2C  -  Catch weight high variance percentage.
415aA*    OPIMPI  -  Import item fields from host.(Y,N).
415aA*    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
415aA*
415aA* Data structure
415aA*
415aAD opdat2          ds
415aAD  opepm                  1      1
415aAD  oprf                   2      2
415aAD  opcapc                 3      3
415aAD  opletd                 4      4
415aAD  opwrnc                 5      5
415aAD  oprg1c                 6      8  1
415aAD  oprg2c                 9     11  1
415aAD  opimpi                12     12
415aAD  opmpck                14     14
415aAD  opten2               117    117
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     D @sltdt          c                   const('UPDSLTDTE')
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
     D  $lcode                19     20
     *
     D  $lwhs1                19     21  0
     D  $litm1                22     36
     *
     D  $lwhs8                19     21  0
     D  $lwhd8                22     26
     D  $ldsp8                27     38
     D  $litm8                39     53
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     D  $litem                27     41
     D  $ldisp                42     53
     D  $ldesg                54     58
     D  $lstat                59     60
     D  $lsdef                61     62
     D  $lactv                63     64
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
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfitm                 1     15
     D  erfdsp                16     27
     D  ertitm                28     42
     *
     D  erdisp                 1     12
     D  erstat                13     15
     *
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
600aA /COPY *libl/qcopysrc,C#PGMINFDS
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
     *  Variables
     *
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D brkqty          s              5  0
     D brkwgt          s              6  3
600aAD chk4err         s              1
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D eof             s              1
     D error           s               n
     D help            s              5  0
     D kywhse          s                   like($pwhse)
     D k3pick          s                   like(slpick)
     D k3stat          s                   like(slstat)
     D lsttim          s              6  0
     D msgk            s              4  0
     D nbrpck          s              5  0
     D nxtscr          s              3
     D ovrrid          s              1
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D savqt1          s                   like($cqty1)
     D savqt2          s                   like($cqty2)
     D savqt3          s                   like($cqty3)
     D savst           s                   like(slstat)
     D sclear          s              1
     D ssbflg          s              1
     D svpick          s                   like(slpick)
     D today           s              8  0
     D warn            s              1
     D w1um1           s              2
     D w1um2           s              2
     D w1um3           s              2
     D w2fcwt          s              1
     D w2fswt          s              7  2
     D w2tcwt          s              1
     D w2tswt          s              7  2
600aAD zmflag          s               n
600aAD zmsflag         s               n
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new batch.
     *              *EDIT    - Edit batch.
     *              *DELETE  - Delete batch.
     *              *PRINT   - Print batch edit listing.
     *              *POST    - Post batch.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new batch number for *ADD.
     *              Unchanged for everything else.
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      *in92 = *off
     C                   eval      *in93 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
530aAC     nxtscr        caseq     '03 '         sc3
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
530aA*
530aAC                   if        nxtscr = '03 '
530aAC                   exfmt     screen3                              50
530aAC                   endif
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
     *  Refresh screen fields if requested.
     *
     C                   if        refrsh = *on
     *
     *     Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft1
     C                   else
     *
     *     Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   exsr      zzfil1
     C                   endif
     C                   endif
     C                   eval      ovrrid = *off
     C                   eval      refrsh = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft2
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget2
     C                   exsr      zzfil2
     C                   endif
     C                   eval      ovrrid = *off
     C     end02i        endsr
     *----------------------------------------------------------------
     *
530aA*  Screen 03 initialization
530a *
530a C     scr03i        begsr
530a C                   eval      nxtscr = '03 '
530a *
530a *  Get field defaults if this is an add.
530a *
530a C                   if        $pcmd = '*ADD    '
530a C                   exsr      zzdft3
530a C                   else
530a *
530a *  Otherwise get existing record(s).
530a *
530a C                   eval      *in91 = *on
530a C                   exsr      zzget3
530a C                   exsr      zzfil3
530a C                   endif
530a C                   eval      ovrrid = *off
530a C     end03i        endsr
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
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
     C                   endif
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd
     C     error         cabeq     *on           endsc1
     C                   endif
     *
     *  Everything went fine so get out of program.
     *
530aDC*                  exsr      scr02i
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr02i
     C                   endif
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scr01i
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
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Everything ok, go on to update.
     *
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     C                   endif
     *
     C     endsc2        endsr
530a *----------------------------------------------------------------
530aA*
530aA*  SC3  -  Screen 3
530aA*
530aAC     sc3           begsr
530aA*
530aA*  Test for F3 - Exit
530aA*
530aAC                   if        *inkc
530aAC                   eval      nxtscr = 'EOJ'
530aAC                   eval      $prtn = '*EXIT   '
530aAC                   goto      endsc3
530aAC                   endif
530aA*
530aA*  Test for F5 - Refresh
530aA*
530aAC                   if        *inke
530aAC                   if        $pcmd <> '*VIEW   '
530aAC                   exsr      scr03i
530aAC                   endif
530aAC                   goto      endsc3
530aAC                   endif
530aA*
530aA*  Test for F12 - Previous
530aA*
530aAC                   if        *inkl
530aAC                   exsr      scr01i
530aAC                   goto      endsc3
530aAC                   endif
530aA*
530aA*  Test for other command keys BEFORE verification and update.
530aA*
530aAC                   eval      cmdchk = '*BEFORE '
530aAC                   exsr      zzcmd3
530aAC     cmdtkn        cabeq     *on           endsc3
530aA*
530aA*  Some other key pressed.
530aA*
530aA*     Check input and write/update record.
530aA*
530aAC                   if        $pcmd = '*ADD    '  or
530aAC                             $pcmd = '*CHANGE '
530aAC                   exsr      zzchk3
530aAC     error         cabeq     *on           endsc3
530aA*
530aA*  Test for other command keys BEFORE verification and update.
530aA*
530aAC                   eval      cmdchk = '*AFTER  '
530aAC                   exsr      zzcmd3
530aAC     cmdtkn        cabeq     *on           endsc3
530aA*
530aA*  Everything ok, go on to update.
530aA*
530aAC                   exsr      zzupd3
530aAC     error         cabeq     *on           endsc3
530aAC                   endif
530aA*
530aAC     endsc3        endsr
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
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

600aA*----------------------------------------------------------------
600aA*    DRI0001  Local system caused error
600aA*----------------------------------------------------------------
600aA
600aAC     zm0001        begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmpmsg
     C                   endsr

600aA*----------------------------------------------------------------
600aA*    DRI0001s Local system caused error (send to different program)
600aA*----------------------------------------------------------------
600aA
600aAC     zm0001s       begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
600aA*----------------------------------------------------------------
600aA*      0105s
600aA*
600aAC     zm0105s       begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0203  Field cna't be blank.
     *
     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
415aA*----------------------------------------------------------------
415aA*     ZM1204   Pick slot already exists for this item in the
415aA*              fixed section.
415aA*
415aAC     zm1204        begsr
415aAC                   eval      #msgid = 'SL11204'
415aAC                   eval      #msgtp = '*DIAG  '
415aAC                   movea     errmsg        $md(1)
415aAC                   exsr      zmpmsg
415aAC                   endsr
415aA*----------------------------------------------------------------
415aA*     ZM1205   Maximum number of pick slots reached for this item
415aA*              in the fixed section.
415aA*
415aAC     zm1205        begsr
415aAC                   eval      #msgid = 'SL11205'
415aAC                   eval      #msgtp = '*DIAG  '
415aAC                   movel     imnrpk        errmsg
415aAC                   movea     errmsg        $md(1)
415aAC                   exsr      zmpmsg
415aAC                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7973  Slot record does not exist.
     *
     C     zm7973        begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
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
     *     IT12215  Slot does not contian item.
     *
     C     zm15          begsr
     C                   eval      #msgid = 'IT12215'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     IT12217  Warning: Slot quanitiy changed before adjustment.
     *
     C     zm17          begsr
     C                   eval      #msgid = 'IT12217'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     SL25273  Item change not completed - Record doesn't exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'SL25273'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     SL25274  Item change not completed - Record locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'SL25274'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     SL25201  Can't change item - Slot has non-stock quantities
     *
     C     zm2521        begsr
     C                   eval      #msgid = 'SL25201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     SL25202  Change completed successfully.
     *
     C     zm2522        begsr
     C                   eval      #msgid = 'SL25202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     SL25203  Invalid slot status code.
     *
     C     zm2523        begsr
     C                   eval      #msgid = 'SL25203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
415aA*---------------------------------------------------------------
415aA*  Retrieve number of pick slots for item and accumulate
415aA*  number of pick slots assigned to item.
415aA*
415aAC     chkpck        begsr
415aAC     keyitn        chain     itemmsc                            79
415aAC                   if        *in79
415aAC                   eval      imnrpk = 1
415aAC                   endif
415aA*
415aA*    Accumulate number of pick slots assigned to item.
415aA*
415aAC                   eval      k3stat = 'A '
415aAC                   eval      k3pick = 'Y'
415aAC     keys3         setll     slot3
415aAC                   eval      nbrpck = *zeros
415aAC                   eval      eof = *off
415aAC                   dow       eof = *off
415aAC     keys3         reade     slot3                                  79
415aAC                   move      *in79         eof
415aAC                   select
415aAC                   when      not *in79
415aAC                   add       1             nbrpck
415aAC                   endsl
415aAC                   enddo
415aAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  New item can't be blank.
     *
     C                   if        w1item = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movea     desc(1)       errmsg
     C                   exsr      zm0203
     C                   goto      endck1
     C                   endif
640bA*
640bA*  New item can't be same as olditem.
640bA*
640bAC                   if        w1item = slitem
640bAC                   eval      error = *on
640bAC                   eval      *in21 = *on
640bAC                   eval      *in01 = *on
640bAC                   eval      errmsg = *blanks
640bAC                   movea     desc(3)       errmsg
640bAC                   exsr      zm0105
640bAC                   goto      endck1
640bAC                   endif
     *
413aA*  Verify item number
     *
     C                   if        w1item <> *blanks
     C                   eval      $lcmd = '*VERIFYS'
     C                   eval      $lwhs1 = $pwhse
     C                   eval      $litm1 = w1item
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
600aA
600aA*  Verify change
600aA
600aAC                   exsr      clr$slot
600aAC                   eval      $slwhseu = *on
600aAC                   eval      $slwhse  = $pwhse
600aAC                   eval      $slwhdpu = *on
600aAC                   eval      $slwhdp = $pwhdp
600aAC                   eval      $sldispu = *on
600aAC                   eval      $sldisp = $pdisp
600aAC                   eval      $saitemu = *on
600aAC                   eval      $saitem  = w1item
600aA
600aAC                   eval      $dricommand = '*SLOT'
600aAC                   eval      $drisubcmd  = '%VFYCHGITM'
600aaC                   eval      $drisys2upd = 'D'
600aAC                   eval      chk4err = *on
600aAC                   eval      zmflag = *on
600aAC                   exsr      zzzdricop
600aAC                   if        error
600aAC                   eval      *in21 = *on
600aAC                   eval      *in01 = *on
600aAC                   leavesr
600aAC                   endif
     *
415aA*
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
600aA
600aA*  Do verification again in case anything has changed.
600aA
600aAC                   exsr      clr$slot
600aAC                   eval      $slwhseu = *on
600aAC                   eval      $slwhse  = $pwhse
600aAC                   eval      $slwhdpu = *on
600aAC                   eval      $slwhdp = $pwhdp
600aAC                   eval      $sldispu = *on
600aAC                   eval      $sldisp = $pdisp
600aAC                   eval      $saitemu = *on
600aAC                   eval      $saitem  = w1item
600aA
600aAC                   eval      $dricommand = '*SLOT'
600aAC                   eval      $drisubcmd  = '%VFYCHGITM'
600aaC                   eval      $drisys2upd = 'D'
600aAC                   eval      chk4err = *on
600aAC                   eval      zmflag = *on
600aAC                   exsr      zzzdricop
600aAC                   if        error
600aAC                   eval      *in21 = *on
600aAC                   eval      *in01 = *on
600aAC                   leavesr
600aAC                   endif
     *
     C     endck2        endsr
     *----------------------------------------------------------------
530a *
530a *  ZZCHK3   Screen 3 error checking.
530a *
530a C     zzchk3        begsr
530a C                   eval      error = *off
530aA
530a *
530a C     endck3        endsr
     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     C                   select
     *
     *     ITEM
     *
     C                   when      row# = 17
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = $pwhse
     C                   eval      $litm1 = *blanks
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1item = $litm1
     C                   endif
     *
     *     Cursor not on a valid lookup field.
     *
     C                   other
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
     *
     *      F8 - View slot information.
     *
     C                   if        *inkh
     C                   eval      cmdtkn = *on
     C                   eval      $lwhs8 = $pwhse
     C                   eval      $lwhd8 = $pwhdp
     C                   eval      $ldsp8 = $pdisp
     C                   eval      $litm8 = $pitem
     C                   call      'IT135'
     C                   parm                    $lparm
     C                   endif
     *
     *      F9 - View slot quantities.
     *
     C                   if        *inki
     C                   eval      cmdtkn = *on
     C                   call      'SL810'
     C                   parm      $pwhse        whse              3 0
     C                   parm                    $pwhdp
     C                   parm                    $pdisp
     C                   endif
     *
     *      F21 - Item Tie/High Maintenance.
     *
     C                   if        *inkv
     C                   eval      cmdtkn = *on
     C                   call      'IT141'
     C                   parm      $pwhse        whse
     C                   parm                    w1item
     C                   endif
     *
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
     *      F20 - Accept Warning.
     *
     C                   if        *inku
     C                   eval      ovrrid = *on
     C                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     *
     *      F10 - Change item.
     *
     C                   if        *inkj
     C                   exsr      zzzchg
     C                   if        error = *off
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     C                   endif
     C                   endif
     *
     C     endcm2        endsr
530aA*----------------------------------------------------------------
530aA*
530aA*  ZZCMD3   User defined command keys for screen 3.
530aA*
530aAC     zzcmd3        begsr
530aA*
530aA*  Command keys to check BEFORE verification and update.
530aA*
530aAC                   if        cmdchk = '*BEFORE '
530aA*
530aAC                   endif
530aA*
530aA*  Command keys to check AFTER verification and update.
530aA*
530aAC                   if        cmdchk = '*AFTER  '
530aA*
530aAC                   endif
530aA*
530aAC     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     *
     *   This program is only called with *CHANGE.
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     *
     *   This program is only called with *CHANGE.
     *
     C                   endsr
530a *----------------------------------------------------------------
530a *
530a *  ZZDFT3   Get default values for add.
530a *
530a C     zzdft3        begsr
530a *
530a *   This program is only called with *CHANGE.
530a *
530a C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL0   Fill screen 1 & 2 heading fields.
     *
     C     zzfil0        begsr
     *
     *   Convert quantity to string.
     *
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
     *
     C                   call      'SLOTQTY'
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3
     *
     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3
     *
     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3
     *
     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3
     *
     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3
     *
     C                   parm                    stock1            5 0
     C                   parm                    stock2            3 0
     C                   parm                    stock3            3 0
     *
     C                   parm                    avail1            5 0
     C                   parm                    avail2            3 0
     C                   parm                    avail3            3 0
     *
     C                   eval      $cqty1 = avail1
     C                   eval      $cqty2 = avail2
     C                   eval      $cqty3 = avail3
     *
     C                   call      'CVTQTY'
     C                   parm                    $ccmd             8
     C                   parm                    $cprg            10
     C                   parm                    $cqty1            7 0
     C                   parm                    $cqty2            7 0
     C                   parm                    $cqty3            7 0
     C                   parm                    $cum1             2
     C                   parm                    $cum2             2
     C                   parm                    $cum3             2
     C                   parm                    $cqstr           10
     C                   parm                    $custr           17
     C                   parm                    $crtn             8
     C                   parm                    $cerm
     C                   movel     $cqstr        w1curq
     *
     *  Get status description.
     *
     C     slstat        chain     slotstat                           79
     C                   if        *in79
     C                   eval      ssdesc = *blanks
     C                   movel     slstat        ssdesc
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *   Get current item record.
     *
     C     keyit         chain     piritem                            79
     C                   if        *in79
     C                   eval      itdesc = *blanks
     C                   eval      itpdsc = *blanks
     C                   eval      itstyp = *blanks
     C                   eval      itdesg = *blanks
     C                   eval      itumq2 = 0
     C                   eval      itumq3 = 0
     C                   endif
     *
     C                   move      $pitem        woitem
     C                   eval      w1styp = slstyp
     *
     *   Save 'From' item information.
     *
     C                   eval      w2fitm = $pitem
     C                   eval      w2fdsc = itdesc
     C                   eval      w2fwdp = itwhdp
     C                   eval      w2fstp = itstyp
     C                   eval      w2fdsg = itdesg
414cAC                   eval      w2fcwt = itcwgt
414cAC                   eval      w2fswt = itswgt
     *
     *   Format item description for display.
     *
     C                   eval      $iitem = slitem
     C                   eval      $idesc = itdesc
     C                   eval      $ipdsc = itpdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   eval      woitem = *blanks
     C                   movel     $istr         woitem
     *
     *   Get SSB item, if one exists
     *
     C                   eval      ssbflg = *off
     C                   eval      w1lbls = *blanks
     C                   eval      w1itms = *blanks
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
     C                   eval      w1um1 = *blanks
     C                   eval      w1um2 = *blanks
     C                   eval      w1um3 = *blanks
     C                   exsr      zzuom
     C                   movel     'SSB ('       w1lbls
     C     w1lbls        cat       w1um2:0       w1lbls
     C     w1lbls        cat       ')':0         w1lbls
     C                   move      ':'           w1lbls
     *
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    #bitem
     C                   parm                    #bdesc
     C                   parm                    #bpdsc
     C                   parm                    $istr
     C                   movel     $istr         w1itms
     *
     C                   endif
     *
     C                   endif
     *
     C                   eval      w1whdp = itwhdp
     *
     *   Initialize entry fields
     *
     C                   eval      w1item = *blanks
640cAC                   eval      w1memo = *blanks
     *
     *   Initialize header fields. Save quantities and status for
     *     comparison before updating.
     *
     C                   exsr      zzfil0
     C                   eval      savqt1 = $cqty1
     C                   eval      savqt2 = $cqty2
     C                   eval      savqt3 = $cqty3
     C                   eval      savst = slstat
     C                   eval      fmdisp = sldisp
415aAC                   eval      svpick = slpick
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     *   Get new item record.
     *
     C     keyitn        chain     piritem                            79
     C                   if        *in79
     C                   eval      itdesc = *blanks
     C                   eval      itpdsc = *blanks
     C                   eval      itstyp = *blanks
     C                   eval      itdesg = *blanks
     C                   endif
     *
     *   Save new item information.
     *
     C                   eval      w2titm = w1item
     C                   eval      w2tdsc = itdesc
     C                   eval      w2twhd = itwhdp
     C                   eval      w2tstp = itstyp
     C                   eval      w2tdsg = itdesg
414cAC                   eval      w2tcwt = itcwgt
414cAC                   eval      w2tswt = itswgt
640cAC                   eval      w2memo = w1memo
     *
     *   Highlight differences.
     *
     C                   if        w2fwdp <> w2twhd
     C                   eval      *in21 = *on
     C                   endif
     C                   if        w2fstp <> w2tstp
     C                   eval      *in22 = *on
     C                   endif
     C                   if        w2fdsg <> w2tdsg
     C                   eval      *in23 = *on
     C                   endif
     *
     C                   endsr
530a *----------------------------------------------------------------
530a *
530a *  ZZFIL3   Fill screen 3 fields with info from file.
530a *
530a C     zzfil3        begsr
530a *
530a C                   eval      *in22 = *on
530a *
530a C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
     C     fileky        chain(n)  record                             79
     *
     *  Record not found.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      errmsg = desc(2)
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm7973
     C                   goto      endgt1
     C                   endif
     *
     *  Slot has invalid status code.
     *
     C                   if        slstat = 'Z'  or
     C                             slstat = 'V'
     C                   eval      error = *on
     C                   eval      erdisp = sldisp
     C                   move      slstat        erstat
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm2523
     C                   goto      endgt1
     C                   endif
     *
     *  Slot does not contain an item.
     *
     C                   if        slitem = *blanks
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm15
     C                   goto      endgt1
     C                   endif
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     C     zzget2        begsr
     C     endgt2        endsr
530a *----------------------------------------------------------------
530a *
530aA*  ZZGET3   Get record(s) for screen 3.
530a *
530a C     zzget3        begsr
530aAC     endgt3        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $pdisp
     *
     *  Define key for PIRITEM file for 'From' item.
     *
     C     keyit         klist
     C                   kfld                    $pwhse
     C                   kfld                    slitem
     *
     *  Define key for PIRITEM file for new item.
     *
     C     keyitn        klist
     C                   kfld                    $pwhse
     C                   kfld                    w1item
     *
     *  Define key for itemdef file.
     *
     C     idkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    ititem
     C                   kfld                    slsdef
415aA*
415aA*  Define partial key for SLOT3 file.
415aA*
415aAC     keys3         klist
415aAC                   kfld                    $pwhse
415aAC                   kfld                    w1item
415aAC                   kfld                    k3stat
415aAC                   kfld                    k3pick
415AA*
415AA*    Partial key for SLOT3 file.
415AA*
415AAC     sl3key        klist
415AAC                   kfld                    $pwhse
415AAC                   kfld                    w1item
415aA*
415aA*
415aA*  Define key for options file, System values.
415aA*
415aAC     optsky        klist
415aAC                   kfld                    kywhse
415AAC                   kfld                    opcode
415aA*
415aAC                   eval      nbrpck = *zeros
415aAC                   eval      svpick = *blanks
     *
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
600aA*
600aA*    Get User's employee number to be written to PORCV file
600aA*    if any records are flagged as touched.
600aA*
600aAC                   call      'GETUSER'
600aAC                   parm      #curruser     $code            10
600aAC                   parm      0             $whse             3 0
600aAC                   parm      0             $emp#             5 0
600aAC                   parm      *blanks       $fnam            15
600aAC                   parm      *blanks       $init             1
600aAC                   parm      *blanks       $lnam            20
600aAC                   parm      *blanks       $whdp             5
600aAC                   parm      *blanks       $styp             1
600aAC                   parm      *blanks       $shft             6
600aAC                   parm      *blanks       $crew             6
600aAC                   parm      0             $nhrs             3 1
600aAC                   parm      *blanks       $rtn              8
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     C                   move      $pwhse        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd
     C                   parm                    $cstr            30
     C                   movel     $cstr         wowhse
     *
     *   Get department description.
     *
     C     keywd         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C     keywd         chain     whdept                             79
     C                   if        *in79
     C                   eval      wdcode = *blanks
     C                   eval      wddesc = *blanks
     C                   endif
415aA*
415aA*   Get system options.
415aA*
415aAC                   eval      kywhse = *zeros
415aAC                   eval      opcode = '*SYSTEM '
415aAC     optsky        chain     options                            79
415aAC                   if        *in79
415aAC                   eval      opmpck = 'N'
415aAC                   else
415aAC                   eval      opdat2 = opdata
415aAC                   endif
     *
     *   Select first screen to display.
     *
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUOM    Get Unit Of Measure Normal, Breakdown1, Breakdown2.
     *
     C     zzuom         begsr
     *
     *   Get Unit of Measures.
     *    *IN92=Protect & non-display breakdown1 unit of measure
     *    *IN93=Protect & non-display breakdown2 unit of measure
     *
     *
     C     keyit         chain     piritem                            75
     C                   if        *in75
     C                   eval      *in92 = *on
     C                   eval      *in93 = *on
     C                   goto      enduom
     C                   else
     C                   if        itflg1 = 'N'  and
     C                             ssbflg = *off
     C                   eval      *in92 = *on
     C                   endif
     C                   if        itflg2 = 'N'  and
     C                             ssbflg = *off  or
     C                             itflg2 = 'N'  and
     C                             ssbflg = *on  and
     C                             itum3 = *blanks
     C                   eval      *in93 = *on
     C                   endif
     C                   endif
     *
     C     itum1         chain     unmesr                             75
     C                   if        not *in75
     C                   move      umshrt        w1um1
     C                   else
     C                   eval      w1um1 = *blanks
     C                   endif
     *
     C                   if        not *in92
     C     itum2         chain     unmesr                             75
     C                   if        not *in75
     C                   move      umshrt        w1um2
     C                   else
     C                   eval      w1um2 = *blanks
     C                   endif
     C                   endif
     *
     C                   if        not *in93
     C     itum3         chain     unmesr                             75
     C                   if        not *in75
     C                   move      umshrt        w1um3
     C                   else
     C                   eval      w1um3 = *blanks
     C                   endif
     C                   endif
     C     enduom        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
530aA*
530aA*   Check if from or to item is CW
530aA*     Get 'TO' item info.
530aAC                   eval      w2tcwt = 'N'
530aAC     keyitn        chain     piritem                            79
530aAC                   if        not *in79
530aAC                   eval      w2tcwt = itcwgt
530aAC                   endif
     C                   eval      error = *off
530aAC                   if        w2fcwt = 'Y'
530aAC                             or w2tcwt = 'Y'
530aAC                   exsr      scr03i
530aAC                   else
     C                   exsr      scr02i
530aAC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     C                   endsr
530aA*----------------------------------------------------------------
530aA*
530aA*  ZZUPD3   Update record.
530aA*
530aAC     zzupd3        begsr
530aAC                   eval      error = *off
530aAC                   exsr      scr02i
530aAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZZCHG   Change item.
     *
     C     zzzchg        begsr
     C                   eval      error = *off
600aA
600aAC                   exsr      clr$slot
600aAC                   eval      $slwhseu = *on
600aAC                   eval      $slwhse  = $pwhse
600aAC                   eval      $slwhdpu = *on
600aAC                   eval      $slwhdp = $pwhdp
600aAC                   eval      $sldispu = *on
600aAC                   eval      $sldisp = $pdisp
600aAC                   eval      $saitemu = *on
600aAC                   eval      $saitem  = w1item
530aAC                   eval      $sacwtau = *on
530aAC                   eval      $sacwta  = w3cwt
600aA
610bAC                   eval      $sabyu   = *on
610bAC                   eval      $saby    = #curruser
610bA
600aAC                   eval      $saActionU = *on
600aAC                   eval      $saAction = 'CHG'
600aAC*                  eval      $saTrn#U = *on
600aAC*                  eval      $saTrn# = pttrn#
600aAC                   eval      $saETrn#U = *on
600aAC                   eval      $saETrn# = 0
600aAC*                  eval      $saLbl#U = *on
600aAC*                  eval      $saLbl# = newlbl#
600aAC*                  eval      $saToPosU = *on
600aAC*                  eval      $saToPos = 1
610aAC                   eval      $saToLcnsU = *on
610aAC                   eval      $saToLcns = '*MULTIPLE'
610aAC                   eval      $saToVrfyU = *on
610aAC                   eval      $saToVrfy = 'N'
610aAC                   eval      $saOLcnsU = *on
610aAC                   eval      $saOLcns = '*MULTIPLE'
610aAC                   eval      $saFrmLcnsU = *on
610aAC                   eval      $saFrmLcns = '*MULTIPLE'
640aAC                   eval      $saItmChgU = *on
640aAC                   eval      $saItmChg = 'Y'
640cAc                   eval      $samemo = w1memo
640cAc                   eval      $samemoe = '0'
640cAc                   eval      $samemou = '1'
600aA
600aAC                   eval      $dricommand = '*SLOT'
600aAC                   eval      $drisubcmd  = '%CHGITEM'
600aaC                   eval      $drisys2upd = 'D'
600aAC                   eval      chk4err = *on
600aAC                   eval      zmflag = *on
600aAC                   exsr      zzzdricop
600aAC                   if        error
600aAC                   eval      *in21 = *on
600aAC                   eval      *in01 = *on
600aAC                   leavesr
600aAC                   endif
700aA /free
700aA   // write change item record
700aA   icwhse = $pwhse;
700aA   icfitm = w2fitm;
700aA   ictitm = w2titm;
700aA   chain (icwhse: icfitm: ictitm) itemchg;
700aA   if %found(itemchg);
700aA   else;
700aA     write icrec;
700aA   endif;
700aA /end-free

     C     endzzz        endsr

600aA*----------------------------------------------------------------
600aA*----------------------------------------------------------------
600aA*                     DRI SUBROUTINES
600aA*----------------------------------------------------------------
600aA*----------------------------------------------------------------

600aA*----------------------------------------------------------------
600aA*  clr$item  Clear $item data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

600aA*----------------------------------------------------------------
600aA*  clr$slot  Clear $slot data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = $emp#
     C                   endsr

600aA*----------------------------------------------------------------
600aA*  zzzdricop  Call DRICOP
600aA*----------------------------------------------------------------
600aA
600aAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      %error and chk4err = *on
     C                   eval      error = *on
600aAC                   eval      errmsg    = 'Error occured on call to '
600aAC                                       + 'DRICOP'
600aAC                                       + '/' + %trim($drisubcmd)
600aAC                                       + ' from ' + #pgm
600aAC                   select
600aAC                   when      zmsflag
600aAC                   exsr      zm0105s
600aAC                   when      zmflag
600aAC                   exsr      zm0105
600aAC                   endsl

417yMC                   when      $drireturn <> '*OK' and chk4err = *on
     C                   eval      error = *on
600aAC                   select
600aAC                   when      zmsflag
600aAC                   exsr      zm0001s
600aAC                   when      zmflag
600aAC                   exsr      zm0001
     C*                  exsr      zzerrind
600aAC                   endsl

     C                   endsl

     C                   select
417yAC                   when      $dricommand = '*SLOT'
417yAC                   eval      $slot = $dridata
600aAC                   eval      $slot2 = $dridata2
500 AC                   when      $dricommand = '*ITEM'
500 AC                   eval      $item = $dridata
500 AC                   eval      $item2 = $dridata2
     C                   endsl

600aAC                   eval      zmflag = *off
600aAC                   eval      zmsflag = *off
417yAC                   eval      chk4err = *off
     C     enddricop     endsr

     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
**
Item
Slot
New item must be different than old item
