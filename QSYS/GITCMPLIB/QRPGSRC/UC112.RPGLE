      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  UC112     UPC code maintenance - Change
     *  04 April, 1997
     *  Roxanne Harrison
     *
     *----------------------------------------------------------------
     *  Revisions
417a *    04/14/03  RH   4.17a
     *      - Change to use UPC2 file, UPC file is not unique.
417b *    05/28/03  RH   4.17b
     *      - Change to use UPC3 file, UPC2 file is not unique.
417c *    11/04/03  RH   4.17c
     *      - Change to use CVTBAR to check UPC code.
510a *    06/29/06  RH   5.10a
     *      - Add F20 Ovrride for UPC Code.
530a *    10/26/09  RH   5.30a
     *      - Enh: Screen change, re-compile only.
650aA*    07/17/13  LMC  6.50a
     *      - Enh: Added the ability to Add UPC passed from PO120
     *      This will help facilitate the loading of GTIN into the
     *      UPC file needed for items that will be using PTI selection
650bA*    08/19/13  LMC  6.50b
     *      - Converted to RPGLE.
     *      - Enh: Added the ability to scan GS1 barcode to load
     *      the UPC file. Do not edit for Vendor number when a GTIN
     *      is found on the scan.
650cA*    03/10/14  LMC  6.50c
     *      Fix - Don't adjust the UCI entry field until all edits are
     *      passed, or override is taken.
650dA*    07/21/14  LMC  6.50d
     *      Fix - Always right adjust not just for GTIN entry.
     *
700 A*    05/13/15  MLB  7.00
     *      Enh - Added client custom code support to pgm.
     *
700a *    10/14/16  LMC  7.00a
     *      - Enh: UPC file has changed, we now store UOM information
     *        for the UPC. Display file changed to UC11202.
740a *    04/22/20  LMC  7.40a
     *      - Enh: Add new parms for cvtbar.
     *      - Enh: Populated $cbven and $cbitem from screen fields (das)
     *----------------------------------------------------------------
     *  Client Custom Revisions: Will Foods
     *
WIL A*    05/13/15  MLB  WIL
     *      - Revised program to allow vendor number to be zero.
     *        Will Foods' vendor numbers are alphameric.
     *        Per Jesse K email 05/13/15.
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
650bDF*uc112fm   cf   e             workstn
700aDF*uc11201   cf   e             workstn
700aMFuc11202   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
417aD*PC     UF  E           K        DISK                      A
417b *PC2    UF  E           K        DISK                      A
417b Fupc3      uf a e           k disk
     F                                     rename(uprec:record)
     Fwarehs    if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
700aDD*desc            s             50    dim(3) ctdata perrcd(1)
700aMD desc            s             50    dim(4) ctdata perrcd(1)
700 A
700aA*----------------------------------------------------------------
700aA*  DRI parameters
700aA*----------------------------------------------------------------
700aA
700aA /COPY *libl/qcopysrc,C#DRIPARMS
700aA
700aA*----------------------------------------------------------------
700aA*  Data Formats
700aA*----------------------------------------------------------------
700aA
700aA /COPY *libl/qcopysrc,C#ITEM
700aA /COPY *libl/qcopysrc,C#SLOT
700aA /COPY *libl/qcopysrc,C#SLOTDEF
700aAD saveVer#        s                   like($slver#)
700 A*----------------------------------------------------------------
700 A*  Customer id
700 A*
700 AD @getcl          c                   const('GETCLIENT')
700 A*
WIL A /copy qcopysrc,id#wil
700 A
650bA*----------------------------------------------------------------
650bA*  Convert Barcode Parms
650bA*----------------------------------------------------------------

650bA /COPY *libl/qcopysrc,C#CVTPARMS
650bA /COPY *libl/qcopysrc,C#BARCODE
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
417aAD  $pitem                22     36
417aAD  $pupc                 37     56
417bAD  $pven                 57     67  0
700aAD  $putyp                68     68
417aD*                                      22  41 $PUPC
     *----------------------------------------------------------------
     *  Called programs
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
     *
700aAD  $luom                 19     20
     *
     D @cvtdt          c                   const('CVTDTE')
     D $cvtdt          ds
     D  $cvdop                 1      8
     D  $cvdd6                 9     14  0
     D  $cvdd8                15     22  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
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
700aAD chk4err         s               n
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D help            s              5  0
     D msgk            s              4  0
700aAD Ntype           s              7
     D nxtscr          s              3
     D ovrrid          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D svupc           s                   like(w1upc)
650bAD savew1upc       s                   like(w1upc)
     D warn            s              1
700aAD zmsflag         s               n
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
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
     C                   if        error = '1'
     C                   eval      nxtscr = 'EOJ'
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
     C                   exfmt     screen1                              50
     C                   endif
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
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
510aAC                   eval      svupc = '#*'
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft1
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   exsr      zzfil1
     C                   endif
510aAC                   eval      ovrrid = *off
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
     C     *loval        setll     record
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
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
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
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
     C                   exsr      zzupd
     C     error         cabeq     '1'           endsc1
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
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
700 A*
700 A* Get client id.
700 A*
700 AC                   call      @getcl
700 AC                   parm                    client           10
700 AC                   parm                    clientloc        10
700 A*
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
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
417bD**                   MOVEADESC      ERRMSG
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
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
     *     PIR7973  UPC record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  UPC record is locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
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
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  When adding ....
     *
     C                   if        $pcmd = '*ADD    '
650bA*  Check for GTIN from GS1 barcode
650bAC                   if        w1upc <> *blanks                             Begin If 1
650bAC                   eval      $cbcmd = '*ALL    '
650bAC                   eval      $cbbar = w1upc
740aAC                   eval      $cbven = w1vnum
740aAC                   eval      $cbitem = w1item
650bAc                   clear                   $barcode
650bAc                   clear                   $barcode2
650bA*
650bAC                   call      'CVTBAR'
650bAC                   parm                    $cbcmd            8
650bAC                   parm                    $cbbar          100
650bAC                   parm                    $cbcod            3 0
650bAC                   parm                    $cbdec            1 0
650bAC                   parm                    $cbdsc           30
650bAC                   parm                    $cbpos            3 0
650bAC                   parm                    $cbtyp            1 0
650bAC                   parm                    $cbv1            11 3
650bAC                   parm                    $cbv2            50
650bAC                   parm                    $cbrtn            8
650bAC                   parm                    $cberm           60
650bAC                   parm                    $cbven           10 0
650bAC                   parm                    $cvtdata
650bAC                   parm                    $cvtdata2
740aAC                   parm      $pwhse        $cbwhse           3 0
740aAC                   parm                    $cbsent           1
740aAC                   parm                    $cbitem          15
650bA*
650bAc                   eval      $barcode = $cvtdata
650bAc                   eval      $barcode2 = $cvtdata2
650bA*
650bAC                   endif
417b *  Moved item checking here, was after UPC checking
     *
     *  Item is required.
     *
     C                   if        w1item = *blanks
417b C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
650bDC*                  eval      errmsg = desc(1)
650bMC                   eval      errmsg = desc(2)
417b C                   exsr      zm01
     C                   endif
     *
     *  Verify item number
     *
700aDC*                  eval      $lcmd = '*VERIFY '
700aDC*                  eval      $lwhse = $pwhse
700aDC*                  eval      $litem = w1item
700aDC*                  call      'IT900'
700aDC*                  parm                    $lparm
700aDC*                  if        $lrtn = '*ERROR  '
700aDC*                  eval      error = *on
700aDC*                  eval      *in22 = *on
700aDC*                  eval      *in02 = *on
700aDC*                  movel     $lerm         errmsg
700aDC*                  exsr      zm0105
700aDC*                  else
700aDC*                  if        $lrtn = '*PGMQ   '
700aDC*                  eval      error = *on
700aDC*                  eval      *in22 = *on
700aDC*                  eval      *in02 = *on
700aDC*                  eval      #msgk = $lmsg
700aDC*                  exsr      zmqmsg
700aDC*                  endif
700aDC*                  endif
700aAc* use dri programs to do edit for item - need the ituom fields
700aAC                   exsr      clr$item
700aAC                   eval      $itwhse  = $pwhse
700aAC                   eval      $ititem  = w1item

700aAC                   eval      $dricommand = '*ITEM'
700aAC                   eval      $drisubcmd  = '%GETALL'
700aAC                   eval      $drisys2upd = 'D'
700aAC                   eval      chk4err = *on
700aAC                   eval      zmsflag = *off
700aAC                   exsr      zzzdricop
700aAC                   if        error = '1'
700aAC                   eval      error = *on
700aAC                   eval      *in22 = *on
700aAC                   eval      *in02 = *on
700aAC                   movel     $drimessage   errmsg
700aAC                   exsr      zm0105
700aAC                   leavesr
700aAC                   endif
417b *
417b *  Vendor # is required.
417b *
650bAc                   if        not $bcGtinSent
417b C                   if        w1vnum = *zeros
WIL AC                             and client <> WillFoods
417b C                   eval      error = *on
417b C                   eval      *in24 = *on
417b C                   eval      *in04 = *on
417b C                   eval      errmsg = desc(3)
417b C                   exsr      zm01
417b C                   endif
650bAC                   endif
700aA*
700aA*  validate UOM
700aA*
700aAC                   eval      $lcmd = '*VERIFY '
700aAC                   eval      $luky = ' '
700aAC                   eval      $luom  = w1uom
700aAC                   call      'UM900'
700aAC                   parm                    $lparm
700aAC                   if        $lrtn <> '*OK  '
700aAC                   eval      error = *on
700aAC                   eval      *in26 = *on
700aAC                   eval      *in06 = *on
700aAC                   eval      errmsg = 'Invalid UOM code - use F4'
700aAC*                  eval      errmsg = desc(4)
700aAC                   exsr      zm0105
700aAc                   leavesr
700aAC                   endif
700aA*
700aA*  validate UOM for the Item
700aA*
700aA
700aA * w1uom must match a uom from the item
700aA /free
700aA   Select;
700aA     when w1uom = $itum1;
700aA       $putyp = 'N';
700aA     when w1uom = $itum2;
700aA       $putyp = '1';
700aA     when w1uom = $itum3;
700aA       $putyp = '2';
700aA     other;
700aA       error = *on;
700aA       *in26 = *on;
700aA       *in06 = *on;
700aA       errmsg = 'Invalid UOM for Item';
700aA       exsr zm0105;
700aA       leavesr;
700aA   endsl;
700aA /end-free
     *
     *
     *    Make sure code was entered.
     *
     C                   if        w1upc = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
417b C                   eval      *in04 = *on
417b C                   eval      errmsg = desc(1)
     C                   exsr      zm01
     C                   endif
700aMc                   eval      savew1upc = w1upc
650bAc                   if        $bcGtinSent
700aDc*                  eval      savew1upc = w1upc
650bAc                   eval      w1upc  = $bcGtin
650bAC                   endif
510aA*
510aA*  Skip UPC code verification if second time around.
510aA*
510aAC                   if        ovrrid = *on  and
510aAC                             w1upc = svupc
510aAC                   goto      skpupc
510aAC                   endif
417cA*
417cAC                   if        w1upc <> *blanks                             Begin If 1
417cAC                   eval      $cbcmd = '*UPC    '
417cAC                   eval      $cbbar = w1upc
740aAC                   eval      $cbven = w1vnum
740aAC                   eval      $cbitem = w1item
417cA*
417cAC                   call      'CVTBAR'
417cAC                   parm                    $cbcmd            8
417cAC                   parm                    $cbbar          100
417cAC                   parm                    $cbcod            3 0
417cAC                   parm                    $cbdec            1 0
417cAC                   parm                    $cbdsc           30
417cAC                   parm                    $cbpos            3 0
417cAC                   parm                    $cbtyp            1 0
417cAC                   parm                    $cbv1            11 3
417cAC                   parm                    $cbv2            50
417cAC                   parm                    $cbrtn            8
417cAC                   parm                    $cberm           60
740aAC                   parm                    $cbven           10 0
740aAC                   parm                    $cvtdata
740aAC                   parm                    $cvtdata2
740aAC                   parm      $pwhse        $cbwhse           3 0
740aAC                   parm                    $cbsent           1
740aAC                   parm                    $cbitem          15
417cA*
417cAC                   if        $cbrtn <> '*OK'
417cAC                   eval      error = *on
417cAC                   eval      *in21 = *on
417cAC                   eval      *in01 = *on
417cAC                   movel     $cberm        errmsg
417cAC                   exsr      zm0105
417cAC                   endif
650cAc                   if        error = *on and ovrrid = *off
650cAC                   eval      svupc = w1upc
650cAc                   goto      endck1
650cAc                   endif
     *
510aAC     skpupc        tag
     *   Right adjust UPC code for file.
     *
700aAc                   eval      ntype = %trimr($cbdsc)
     C                   eval      $cstr = *blanks
     C                   movel     w1upc         $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
650dDc**                 if        $bcGtinSent
650bAc                   eval       w1upc = ' '
650dDc**                 endif
     C                   move      $cstr         w1upc
510aAC                   eval      svupc = w1upc
     *
     *    Make sure code doesn't already exist.
     *
700aDc*                  if        $bcGtinSent
650bAc                   move      w1upc         $pupc
700aDc*                  else
700aDC*                  eval      $pupc = w1upc
700aDc*                  endif
417a C                   eval      $pitem = w1item
417b C                   eval      $pven = w1vnum
     C     fileky        chain     record                             79
     C                   if        not *in79
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   exsr      zm02
     C                   endif
417cAC                   endif
700aAc                   else
700aAC                   eval      $lcmd = '*VERIFY '
700aAC                   eval      $luky = ' '
700aAC                   eval      $luom  = w1uom
700aAC                   call      'UM900'
700aAC                   parm                    $lparm
700aAC                   if        $lrtn <> '*OK  '
700aAC                   eval      error = *on
700aAC                   eval      *in26 = *on
700aAC                   eval      *in06 = *on
700aAC                   eval      errmsg = 'Invalid UOM code - use F4'
700aAC*                  eval      errmsg = desc(4)
700aAC                   exsr      zm0105
700aAc                   leavesr
700aAC                   endif
700aA*
700aA*  validate UOM for the Item
700aA*
700aAc* use dri programs to do edit for item - need the ituom fields
700aAC                   exsr      clr$item
700aAC                   eval      $itwhse  = $pwhse
700aAC                   eval      $ititem  = w1item

700aAC                   eval      $dricommand = '*ITEM'
700aAC                   eval      $drisubcmd  = '%GETALL'
700aAC                   eval      $drisys2upd = 'D'
700aAC                   eval      chk4err = *on
700aAC                   eval      zmsflag = *off
700aAC                   exsr      zzzdricop
700aAC                   if        error = '1'
700aAC                   eval      error = *on
700aAC                   eval      *in22 = *on
700aAC                   eval      *in02 = *on
700aAC                   movel     $drimessage   errmsg
700aAC                   exsr      zm0105
700aAC                   leavesr
700aAC                   endif
700aA
700aA * w1uom must match a uom from the item
700aA /free
700aA   Select;
700aA     when w1uom = $itum1;
700aA     when w1uom = $itum2;
700aA     when w1uom = $itum3;
700aA     other;
700aA       error = *on;
700aA       *in26 = *on;
700aA       *in06 = *on;
700aA       errmsg = 'Invalid UOM for Item';
700aA       exsr zm0105;
700aA       leavesr;
700aA   endsl;
700aA /end-free
     C                   endif
417b *  Item Checking was here, moved before UPC checking
650bAc                   if        error = '1'
700aDc*                  if        $bcgtinsent
650bAc                   eval      w1upc = savew1upc
700aDc*                  endif
650bAc                   endif
     *
     C     endck1        endsr
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
     *
     C                   select
     *
     *     Item.
     *
     C                   when      row# = 11
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = $pwhse
     C                   eval      $litem = w1item
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1item = $litem
     C                   endif
700aA*
700aA*     UOM.
700aA*
700aAC                   when      row# = 16
700aAC                   eval      *in02 = *on
700aAC                   eval      $lcmd = '*LOOKUP '
700aAC                   eval      $luky = ' '
700aAC                   eval      $luom  = w1uom
700aAC                   call      'UM900'
700aAC                   parm                    $lparm
700aAC                   if        $lrtn = '*SELECT '
700aAC                   eval      w1uom  = $luom
700aAC                   endif
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
510aA*
510aA*      F20 - Accept Warning.
510aA*
510aAC                   if        *inku
510aAC                   eval      ovrrid = *on
510aAC                   else
510aAC                   eval      ovrrid = *off
510aAC                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   eval      w1upc = *blanks
     C                   eval      w1item = *blanks
     C                   eval      w1bran = *blanks
     C                   eval      w1vnum = 0
     C                   eval      w1vnam = *blanks
     C                   eval      w1vitm = *blanks
700aAC                   eval      w1uom  = *blanks
650aAC                   if        $pprg = 'PO120'
650aAC                   move      $PUPC         W1UPC
650aAC                   move      $PVEN         W1VNUM
650aAC                   move      '1'           *IN02
650aAC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   eval      w1upc = upupc
     C                   eval      w1item = upitem
     C                   eval      w1bran = upbran
     C                   eval      w1vnum = upven
     C                   eval      w1vnam = upvnam
     C                   eval      w1vitm = upvitm
700aAC                   eval      w1uom  = upuom
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
     C                   if        $pcmd = '*VIEW   '
     C     fileky        chain(n)  record                             7978
     C                   else
     C     fileky        chain     record                             7978
     C                   endif
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt2
     C                   endif
     *
     *  Record not found.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt2
     C                   endif
     C     endgt2        endsr
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
417a C                   kfld                    $pitem
     C                   kfld                    $pupc
417bAC                   kfld                    $pven
700aAC                   kfld                    $putyp
510aA*  Define variables
510aA*
     *
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Select first screen to display.
     *
     C                   if        $pcmd = '*ADD    '
650aAC                   if        $pprg <> 'PO120'
     C                   eval      $pupc = *blanks
650aAc                   endif
417aAC                   eval      $pitem = *blanks
     C                   endif
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
     C                   eval      upwhse = $pwhse
650dDc**                 if        $bcgtinsent
700aDc*                  move      w1upc         upupc
650dDc**                 else
650dDC*                  eval      upupc = w1upc
650dDc**                 endif
     C                   eval      upitem = w1item
     C                   eval      upbran = w1bran
     C                   eval      upven = w1vnum
     C                   eval      upvnam = w1vnam
     C                   eval      upvitm = w1vitm
700aAC                   eval      upuom  = w1uom
700aA /free
700aA   Select;
700aA     when w1uom = $itum1;
700aA       uputyp = 'N';
700aA     when w1uom = $itum2;
700aA       uputyp = '1';
700aA     when w1uom = $itum3;
700aA       uputyp = '2';
700aA   endsl;
700bA   Select;
700bA     when ntype = 'UPC-12';
700bA       upctyp = '1';
700bA     when ntype = 'EAN-13';
700bA       upctyp = '2';
700bA     when ntype = 'GTIN';
700bA       upctyp = '3';
700bA     when ntype = 'SCC-14';
700bA       upctyp = '4';
700bA     when ntype = 'SSCC-18';
700bA       upctyp = '5';
700bA     other;
700bA       upctyp = '6';
700bA   endsl;
700aA /end-free
     *
     *   Add record
     *
     C                   if        $pcmd = '*ADD    '
700aAc                   move      w1upc         upupc
     C                   write     record                               79
650bAc                   eval      $bcgtinsent = '0'
650bAc                   eval      savew1upc = ' '
650bAc                   eval      $bcgtin = ' '
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endupd
     C                   endif
     C                   else
     *
     *   -OR- Update record (it was read and locked in ZZGET2)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endupd
     C                   endif
     C                   endif
     *
     *   Move key values to parameters
     *
     C                   eval      $pupc = upupc
417aAC                   eval      $pitem = upitem
     C     endupd        endsr
     *
700aA*----------------------------------------------------------------
700aA*  clr$item  Clear $item data structure fields
700aA*----------------------------------------------------------------
700aA
700aAC     clr$item      begsr
700aAC                   eval      savever# = $itver#
700aAC                   clear                   $item
700aAC                   clear                   $item2
700aAC                   eval      $itver# = savever#
700aAC                   endsr

700aA*----------------------------------------------------------------
700aA*  zzzdricop  Call DRICOP
700aA*----------------------------------------------------------------
700aA
700aAC     zzzdricop     begsr
700aA
700aAC                   select
700aAC                   when      $dricommand = '*ITEM'
700aAC                   eval      $dridata = $item
700aAC                   eval      $dridata2 = $item2
700aAC                   endsl
700aA
700aAC                   if        $dricommand = '*ITEM'
700aAC                   call(e)   'DRICOP'
700aAC                   parm                    $dricommand
700aAC                   parm                    $drisubcmd
700aAC                   parm                    $drisys2upd
700aAC                   parm      #prog         $driprogram
700aAC                   parm      ' '           $drireturn
700aAC                   parm      ' '           $drimessage
700aAC                   parm                    $dridata
700aAC                   parm                    $dridata2
700aAC                   else
700aAC                   call(e)   'DRICOP'
700aAC                   parm                    $dricommand
700aAC                   parm                    $drisubcmd
700aAC                   parm                    $drisys2upd
700aAC                   parm      #prog         $driprogram
700aAC                   parm      ' '           $drireturn
700aAC                   parm      ' '           $drimessage
700aAC                   parm                    $dridata
700aAC                   endif
700aA
700aAC                   select
700aA
700aAC                   when      chk4err and %error
700aAC                   eval      error = *on
700aAC                   eval      errmsg    = 'Error occured on call to '
700aAC                                       + 'DRICOP'
700aAC                                       + '/' + %trim($drisubcmd)
700aAC                                       + ' from ' + #prog
700aAC                   exsr      zm0105
700aA
700aAC                   when      chk4err and $drireturn <> '*OK'
700aAC                   eval      error = *on
700aA
700aAC                   endsl
700aA
700aAC                   select
700aAC                   when      $dricommand = '*ITEM'
700aAC                   eval      $item = $dridata
700aAC                   eval      $item2 = $dridata2
700aAC                   endsl
700aA
700aAC                   eval      zmsflag = *off
700aAC                   eval      chk4err = *off
700aAC     enddricop     endsr

     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
UPC Code
Item
Vendor #
UOM
