      /copy *libl/qcopysrc,hspecs
     H dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  PO250  Box Labeler Print
     *  04 October 2018
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Notes:
     *
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
720aA*    11/20/18  LMC  7.20a
     *      - Enh: change sql to first row only, this will allow
     *        the ability to reprint for an item that has a UPC
     *        code already setup. Some items have multiple UPC's.
720bA*    12/19/18  LMC  7.20b
     *      - Enh: Added ability to control printers for different
     *        departments and different UOM.
     *      - Enh: Close label spool file when done with each uom.
730aA*    02/15/19  JCJ  7.30a
     *      - Enh: Added uom to @prtpg parms
740aA*    02/04/20  LMC  7.40a
     *      - Enh: Retrieve label set name from LBLFMTH
740bA*    03/17/20  LMC  7.40b
     *      - Enh: Enhance box labeler to handle unique uci's
     *        Added the serial# to the barcode if the item is
     *        setup for uci receiving or uci selection.
740cA*    05/22/20  LMC  7.40c
     *      - Enh: Move the serial processing to the print loop.
740dA*    07/01/20  LMC  7.40d
     *     - We have changed our internal gs1 labels to use AI code 98
     *       instead of AI code 01.
740eA*    07/03/20  MLB  7.40e  ZD#2125
     *      - Enh: Changed @PRTPG to BFCPRTLBL from PRTLBL due to
     *        conflict with TL Ashford pgm of the same name.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Dairyland
     *
DRYaA*    10/19/18  LMC  DRYa
     *      - Setup label set
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *      po
     *  01 - 10   Position cursor indicators
     *  21 - 30   Reverse display indicators
     *  59        User changed item number during transfer.
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *
     FPO250FM   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Funmesr    if   e           k disk
720bAFReports   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a2n             s              1    dim(2)
     D a10             s              1    dim(10)
     D hnd             s              2    dim(702)
     D desc            s             50    dim(6) ctdata perrcd(1)
     D ltr             s              1    dim(27) ctdata perrcd(27)
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
DRYaA /COPY QCOPYSRC,id#dairyla
      *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#LICINFO
      /COPY *libl/qcopysrc,C#LICENSE
     D saveVer#        s                   like($itver#)

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
     D  $ppo                  19     27
     D  $prcvdt               28     35  0
     D  $pqty                 36     40  0
     D  $pprint               41     50
     D  $pitem                51     65
     D  $puom                 66     67

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z

     D bfcoffset       s              3  0 inz(0)
     *----------------------------------------------------------------
     *  Phrase Variables
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,c#phrasvar
     D  currFile       s             10
     D  currRoutine    s             20
     D  lastnxtscr     s              3
     D  stackCount     s              3  0
     D  aRoutine       s             20    dim(30)

     *----------------------------------------------------------------
     *  Phrases
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,c#phrases

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.cvtdte

     D pirgtin#        pr                  extpgm('PIRGTIN#')
      * Input
     D   unext                       14    const
     D   uwhse                        3  0 const

740bAD gs1ser#         pr                  extpgm('GS1SER#')
740bAD   unext                        7  0
740bAD   uwhse                        3  0 const

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
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
740eMD @prtpg          c                   const('BFCPRTLBL')
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
     D  $luom                 19     20
     *
     *----------------------------------------------------------------
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
     *----------------------------------------------------------------
     *  Working fields.
     *
     D                 ds
     D  lottrk                 1      4
     D  lictrk                 5      8
     D  llptp1                 9     16
     D  llptp2                17     24
     D  llptp3                25     32
     D  savllp                33     47
     D  newllp                48     62
     *
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  erqty                  1     10
     D  eritem                11     25
     D  erfrom                26     37
     D  erto                  38     49
     *
     D  erdisp                 1     12
     *
     D  erfsts                 1      2
     D  ertsts                 3      4
     *
     D  ernpck                 1      3p 0
     D  erapck                 4      6p 0
     *
     D  eritdp                 1      5
     D  erslds                 6     17
     D  ersldp                18     22
     D  eritsc                23     23
     D  erslsc                24     24
     *
     D  erdmsg                 1     60
     D  erdrtn                61     70
     D  erdcmd                71     80
     D  erdsub                81     90
     *----------------------------------------------------------------
     *  Working variables.
     *
     D  bkdwn1                 1      4    inz('*NO ')
     D  bkdwn2                 5      8    inz('*NO ')
     D  avlqty                 9     17  0 inz(0)
     D  chkqty                18     26  0 inz(0)
     *----------------------------------------------------------------
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     D #msgsp          c                   const('PIRMSGFSP ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D uprec         e ds                  extname(upc) inz(*EXTDFT)
     D whrec         e ds                  extname(warehs) inz(*EXTDFT)
740aAD lfhrec        e ds                  extname(lblfmth) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *
      /Copy qcopysrc,c#pgminfds
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
     D $ptrn#          s              7  0
     D $rtncd          s              8
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
     D a58             s             58
     D chk4err         s               n
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D curent          s              1
     D dfchk           s              1
     D drierr          s              1
     D e               s              2  0
     D enter           s              5  0
     D eof             s              1
     D error           s               n
     D exist           s              1
     D forever         s               n
     D forevr          s              1
     D found           s              1
     D help            s              5  0
     D i               s              5  0
     D msgk            s              4  0
     D nextNum         s              7  0
     D nxtscr          s              3
     D redspl          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D today           s              8  0
     D whse            s              3  0
720bAD wkprtf          s             10
     D zmsflag         s               n
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

     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   move      'EOJ'         nxtscr
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
     C     nxtscr        caseq     '04 '         sc4
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
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
     C                   if        nxtscr = '03 '
     C                   exfmt     screen3                              50
     C                   endif
     *
     C                   if        nxtscr = '04 '
     C                   exfmt     screen4                              50
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
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       363738
     C                   setoff                                       3940
     C                   setoff                                       98
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      redspl = *off
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
     C                   exsr      zzfil1
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   move      '02 '         nxtscr
     *
     C                   exsr      zzfil2
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   move      '03 '         nxtscr
     *
     C                   exsr      zzfil3
     *
     C     end03i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 04 initialization
     *
     C     scr04i        begsr
     C                   move      '04 '         nxtscr
     *
     C                   exsr      zzfil4
     *
     C     end04i        endsr
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
     C                   move      'EOJ'         nxtscr
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      'EOJ'         nxtscr
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
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
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
     C                   move      'EOJ'         nxtscr
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endif
     *
     *
     *  Test for F12 - Previous
     *
     c                   if        *inkl
     C                   move      '01 '         nxtscr
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C     redspl        cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     C     redspl        cabeq     *on           endsc2
     *
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     c                             and $ppo = ' '
     C                   move      'EOJ'         nxtscr
     C                   goto      endsc3
     C                   endif
     *
     C                   if        *inkc
     c                             and $ppo <> ' '
     C                   eval      error = *on
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr03i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     c                             and $ppo = ' '
     C                   move      '02 '         nxtscr
     C                   goto      endsc3
     C                   endif
     *
     C                   if        *inkl
     c                             and $ppo <> ' '
     C                   eval      error = *on
     C                   goto      endsc3
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
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
     C     endsc3        endsr
     *----------------------------------------------------------------
     *
     *  SC4  -  Screen 4
     *
     C     sc4           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      'EOJ'         nxtscr
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr04i
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      '03 '         nxtscr
     C                   goto      endsc4
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk4
     C     error         cabeq     *on           endsc4
     C                   exsr      zzupd4
     C     error         cabeq     *on           endsc4
     *
     C     endsc4        endsr
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
     C                   call      @getcl
     C                   parm                    client           10
     *
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
     C                   write     clrbtm
     c                   exsr      zsclr
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GetItem    Get Item
     *
     C     GetItem       begsr
      /free
        exsr clr$item;
        $itwhse  = #whse;
        select;
          when w1item <> ' ';
            $ititem  = w1item;
          when $litoitem <> ' ';
            $ititem  = $litoitem;
          when $pitem <> ' ';
            $ititem = $pitem;
        endsl;

        $dricommand = '*ITEM';
        $drisubcmd  = '%GETMAIN';
        $drisys2upd = 'D';
        chk4err = *on;
        exsr zzzdricop;
      /end-free
     c                   if        not error
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $ititem
     C                   parm                    $itdesc
     C                   parm                    $itpdsc
     C                   parm                    $istr            70
     C                   eval      w2itemds = *blanks
     C                   movel     $istr         w2itemds
     c                   endif
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
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      $msgf = #msgsp
     C                   other
     C                   eval      $msgf = #msgf
     C                   endsl
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
     C                   move      *on           sclear
     C                   endsr
     *
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
     C                   move      #msgf         $msgf
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

     *----------------------------------------------------------------
     *    DRI0001  Local system caused error
     *----------------------------------------------------------------

     C     zm0001        begsr
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

     *----------------------------------------------------------------
     *    DRI0001s Local system caused error (send to different program)
     *----------------------------------------------------------------

     C     zm0001s       begsr
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
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0105s
     *
     C     zm0105s       begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0203  Field cna't be blank.
     *
     C     zm0203        begsr
     C                   move      'PIR0203'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1005        begsr
     C                   move      'PIR1005'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0110  Quantity must be greater than 0.
     *
     C     zm0110        begsr
     C                   move      'PIR0110'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   move      'PIR1001'     #msgid
     C                   move      '*DIAG  '     #msgtp
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
     C                   move      *off          error
      /free
        // must have either license or item
        if w1lcns = ' ' and
           w1item = ' ';
           errmsg = 'Enter License or Item';
           exsr zm0105;
           error = *on;
           *in23 = *on;
           *in24 = *on;
           leavesr;
        endif;
        // only one choice can be entered
        if w1lcns <> ' ' and
           w1item <> ' ';
           errmsg = 'Enter License or Item';
           exsr zm0105;
           error = *on;
           *in23 = *on;
           *in24 = *on;
           leavesr;
        endif;
        // validate License
        if w1lcns <> ' ';
          exsr clr$license;
          $liToLcnsU = *on;
          $liToLcns = w1lcns;
          $dricommand = '*LICENSE';
          $drisubcmd  = '%GETINFO';
          $drisys2upd = 'D';
          chk4err = *on;
          exsr zzzdricop;

          if error;
            errmsg = $drimessage;
            exsr zm0105;
            *in23 = *on;
            leavesr;
          endif;
          exsr getitem;
        endif;

        // validate item
        if w1item <> ' ' or
           $Litoitem <> ' ';
          exsr getitem;

          if error;
            errmsg = $drimessage;
            exsr zm0105;
            *in24 = *on;
            leavesr;
          endif;
        endif;
      /end-free
     *
     C     endck1        tag
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C*
     *
      /free
        error = *off;
        // is the date valid
        if w2rcvdt <> 0;
          $cvcmd = '*MDYEDT ';
          $cvprg = #prog;
          $cvd6i = %char(w2rcvdt);
          cvtdte ($cvtdt);
           if $cvrtn = '*PGMQ   ';
             error = *on;
             //*in(xedit) = *on;
             errmsg = 'Invalid Date';
             exsr zm0105;
           endif;
        endif;
      /end-free
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   move      *off          error
     *
     *  validate UOM
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $luky = ' '
     C                   eval      $luom  = w3uom
     C                   call      'UM900'
     C                   parm                    $lparm
     C                   if        $lrtn <> '*OK  '
     C                   eval      error = *on
     C                   eval      *in20 = *on
     C                   eval      errmsg = 'Invalid UOM code - use F4'
     C                   exsr      zm0105
     c                   leavesr
     C                   endif
     *
     *  validate UOM for the Item
     *

      * w1uom must match a uom from the item
      /free
        Select;
          when w3uom = $itum1;
          when w3uom = $itum2;
          when w3uom = $itum3;
          other;
            error = *on;
            *in20 = *on;
            errmsg = 'Invalid UOM for Item';
            exsr zm0105;
            leavesr;
        endsl;
      /end-free
     *
     *  Quantity cannot be zero
     *

      /free
        if w3qty = 0;
          error = *on;
          *in21 = *on;
          errmsg = 'Quantity must be Entered';
          exsr zm0105;
          leavesr;
        endif;
      /end-free
     *
     *
     *  Printer cannot be blank
     *

      /free
        if w3print = ' ';
          error = *on;
          *in22 = *on;
          errmsg = 'Printer must be Entered';
          exsr zm0105;
          leavesr;
        endif;
      /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK4   Screen 4 error checking.
     *
     C     zzchk4        begsr
     C                   move      *off          error
     *
     *    Confirmation Y,N
     *
     C                   if        w4CONF <> 'Y'  and
     C                             w4CONF <> 'N'
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = 'Answer must be Y or N'
     C                   exsr      zm1005
     C                   endif
     *
     C     endck4        endsr
     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
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
     *     UOM.
     *
     C                   when      row# = 04
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $luky = ' '
     C                   eval      $luom  = w3uom
     C                   call      'UM900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w3uom  = $luom
     C                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     c                   endif
     C     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD4   User defined command keys for screen 4.
     *
     C     zzcmd4        begsr
     C     endcm4        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
      /free
        w1lcns = ' ';
        w1item = ' ';
      /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
      *
      /free
        *in90 = *off;
        *in91 = *off;
        w2po = ' ';
        w2rcvdt = 0;
        // did these parms come in or did I enter license on screen1
        if w1lcns <> ' ';
          exsr clr$licinfo;
          $lnwhse  = #whse;
          $lnlcns = w1lcns;
          $dricommand = '*LICINFO';
          $drisubcmd  = '%GET';
          $drisys2upd = 'D';
          chk4err = *off;
          exsr zzzdricop;
          if $drireturn = '*OK';
            *in90 = *On;
            w2po = $lnpo;
          endif;
          if $liToEntD <> 0;
            *in91 = *On;
            $cvcmd = '*CMDMDY ';
            $cvd8i = %char($litoentd);
            cvtdte ($cvtdt);
            w2rcvdt = $cvd6o;
          endif;
        else;
          // parms sent in
          if $ppo <> ' ';
            *in90 = *On;
            w2po = $ppo;
            if $prcvdt  <> 0;
              *in91 = *On;
              w2rcvdt = $prcvdt;
            endif;
          endif;
        endif;

      /end-free
     C     endfl2        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     *
      /free
        *in92 = *off;
        if $ppo <> ' ';
          eval w3uom = $puom;
          eval *in92 = *on;
          eval w3qty = $pqty;
          eval w3print = $pprint;
        else;
          // if the item only has one uom then load it
          if $itflg1 = 'Y';
            eval w3uom = ' ';
          else;
            eval w3uom = $itum1;
            eval *in92 = *on;
          endif;
          eval w3qty = 0;
          eval w3print = '*JOB';
        endif;
720bA   if $pdev='*JOB' or $pdev=*blanks;
720bA     wkprtf = 'BOX' + %trimr($itwhdp)
720bA            + w3uom;
720bA     chain (wkprtf) reports;
720bA     If %Found(reports);
720bA       w3print = rpdev;
720bA       $pform = rpform;
720bA     endif;
720bA   endif;
      /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL4   Fill screen 4 fields with info from file.
     *
     C     zzfil4        begsr
     *
      /free
        w4conf = 'N';
      /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

     C     zzgetcurrstampbegsr

     C                   callp     getmicrotime(currstampuc:currstampsys)
     C     currstampsys  adddur    bfcoffset:*H  currstamploc

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     C                   eval      worow = 0
     C                   eval      wocol = 0
     *
     *    - Get default values for the user.
     *
     C                   call      'GETUSER'
     C                   parm                    #curruser
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
     C                   parm                    e$bpu             1
     C                   parm                    e$lng             2
     C                   if        #rtn <> '*OK'
     C                   eval      e$lng = 'EN'
     C                   endif
      /free
        // was the po sent in?
        if $ppo <> ' ';
          exsr getitem;
          exsr scr03i;
        else;
          exsr scr01i;
        endif;
      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *
     *  ZZCVDT  Convert date to proper format.
     *
     C     zzcvdt        begsr
     *
     *    Convert date into proper format.
     *
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     *
     C     endcvd        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     C                   move      *off          error
     *
     C                   exsr      scr02i
     *
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
     C     zzupd2        begsr
     C                   move      *off          error
     C                   exsr      scr03i
     *
     *
     C     endup2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update record.
     *
     C     zzupd3        begsr
      /free
        error = *off;
        // do we have a gtin already for this item and uom.
        exec sql select * into :uprec
                 from upc
                 where upwhse = :#whse
                   and upitem = :$ititem
                   and upuom = :w3uom
720aA            fetch first 1 rows only;

        if sqlstt <> sqlSuccess;
          // need to create a GTIN
          w4gtin = ' ';
          pirgtin#(w4gtin: #whse);
          // now I need to load the upc file
          upwhse = #whse;
          upitem = $ititem;
          upupc = '      ' + w4gtin;
          upven = 0;
          upvnam = ' ';
          upvitm = ' ';
          upbran = ' ';
          upuom = w3uom;
          Select;
            when w3uom = $itum1;
              uputyp = 'N';
            when w3uom = $itum2;
              uputyp = '1';
            when w3uom = $itum3;
              uputyp = '2';
          endsl;
          upctyp = '3';
          exec sql insert into upc  values(:uprec);

        else;
          w4gtin = %triml(upupc);
        endif;
        // load up all the fields to send to print program
        select;
          when uputyp = 'N';
              $pLfmt = 'BOXLBLC';
          when uputyp = '1';
              $pLfmt = 'BOXLBLE';
          when uputyp = '2';
              $pLfmt = 'BOXLBLE';
        endsl;
740cD   //if $ifrcvmth = '2' or $ifsltmth = '2';
740cD     //gs1ser#(nextNum: $itwhse);
740cD   //endif;
740cD   //if nextNum <> 0;
740cD     //$gs1fmt = '01' + w4gtin + '21' + %editc(nextNum:'X');
740cD   //else;
740cD     //$gs1fmt = '01' + w4gtin;
740cD   //endif;
        //$cvcmd = '*MDYCMD ';
        //$cvd6i = %char(w2rcvdt);
        //cvtdte ($cvtdt);
        $pindta = %editc(w2rcvdt:'Y');

        // get warehouse description
        exec sql select * into :whrec
                 from warehs
                 where whcode = :#whse;

        // call the print program   ***
740aA   // Get the label set name from LBLFMTH.
740aA   exec sql select * into :lfhrec
740aA            from lblfmth;
740aA   if sqlstt = sqlSuccess;
740aA     $plset = lfhset;
740aA   else;
740aA     $plset = 'PLBL40';
740aA   endif;

      /end-free
740aDc*                  select
740aDC*                  when      client = dairyland
740aDC*                  eval      $plset = 'ZBRDRY'
740aDC*                  other
740aDC*                  eval      $plset = 'PLBL40'
740aDC*                  endSL
720bA /free
720bA   if w3print = '*JOB';
720bA     wkprtf = 'BOX' + %trimr($itwhdp)
720bA            + w3uom;
720bA     chain (wkprtf) reports;
720bA     If %Found(reports);
720bA       w3print = rpdev;
720bA       $pform = rpform;
720bA     endif;
720bA   endif;
720bA /end-free
     C                   for       i = 1 to W3QTY
740cA /free
740cM    // moved from
740bM   if $ifrcvmth = '2' or $ifsltmth = '2';
740bM     gs1ser#(nextNum: $itwhse);
740bM   endif;
740bM   if nextNum <> 0;
740dD     //$gs1fmt = '01' + w4gtin + '21' + %editc(nextNum:'X');
740dM     $gs1fmt = '98' + w4gtin + '21' + %editc(nextNum:'X');
740bM   else;
740dD     //$gs1fmt = '01' + w4gtin;
740dM     $gs1fmt = '98' + w4gtin;
740cM   endif;
740cA /end-free
     C                   call      @prtpg
     C                   parm      '*BOXLBL '    $pcmd             8
     C                   parm                    $plset            6
     C                   parm                    $plfmt            8
     C                   parm      #whse         $plwhse           3 0
     C                   parm      whdesc        $pwhsd           30
     C                   parm                    $slwhdp           5
     C                   parm                    $sldisp          12
     C                   parm                    $pdispa           1
     C                   parm                    $pdispb          11
730aAC                   parm      w3uom         $pchkd1           3
     C                   parm                    $pchkd2           3
     C                   parm                    $pchkd3           3
     C                   parm                    wklic            15
     C                   parm                    $plcn2           15
     C                   parm      $ititem       $pditem          15
     C                   parm                    $pbrnd           10
     C                   parm      $itpdsc       $ppdesc          15
     C                   parm      $itdesc       $itdesc          30
     C                   parm      w2po          $ptxt1           30
     C                   parm                    $ptxt2           30
     C                   parm                    $ptxt3           30
     C                   parm                    $ptrailr          8
     C                   parm                    $psize            3
     C                   parm      w3print       $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $pexpda           8
     C                   parm                    $pindta           8
     C                   parm                    $gs1fmt          40
     C                   endfor
720bAC                   call      @prtpg
720bAC                   parm      '*BOXEND '    $pcmd             8
720bAC                   parm                    $plset            6
720bAC                   parm                    $plfmt            8
720bAC                   parm      #whse         $plwhse           3 0
720bAC                   parm      whdesc        $pwhsd           30
720bAC                   parm                    $slwhdp           5
720bAC                   parm                    $sldisp          12
720bAC                   parm                    $pdispa           1
720bAC                   parm                    $pdispb          11
720bAC                   parm                    $pchkd1           3
720bAC                   parm                    $pchkd2           3
720bAC                   parm                    $pchkd3           3
720bAC                   parm                    wklic            15
720bAC                   parm                    $plcn2           15
720bAC                   parm      $ititem       $pditem          15
720bAC                   parm                    $pbrnd           10
720bAC                   parm      $itpdsc       $ppdesc          15
720bAC                   parm      $itdesc       $itdesc          30
720bAC                   parm      w2po          $ptxt1           30
720bAC                   parm                    $ptxt2           30
720bAC                   parm                    $ptxt3           30
720bAC                   parm                    $ptrailr          8
720bAC                   parm                    $psize            3
720bAC                   parm      w3print       $pdev            10
720bAC                   parm                    $pform           10
720bAC                   parm                    $pexpda           8
720bAC                   parm                    $pindta           8
720bAC                   parm                    $gs1fmt          40
      /free
        exsr scr04i;
      /end-free
     *
     C     endup3        endsr

     *----------------------------------------------------------------
     *
     *  ZZUPD4   Update record.
     *
     C     zzupd4        begsr
     *
      /free
        error = *off;
        select;
          when w4conf = 'Y';
            if $ppo <> ' ';
              nxtscr = 'EOJ';
            else;
              exsr scr01i;
            endif;
          when w4conf = 'N';
            nxtscr = '03 ';
        endsl;
      /end-free
     *
     C     endup4        endsr


     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr
     *----------------------------------------------------------------
     *  clr$license  Clear $license data structure fields
     *----------------------------------------------------------------

     C     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   eval      $liTowhse = #whse
     C                   eval      $liTowhseu = *on
     C                   endsr

     *----------------------------------------------------------------
     *  clr$licinfo  Clear $licinfo data structure fields
     *----------------------------------------------------------------

     C     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   clear                   $licinfo2
     C                   eval      $lnver# = savever#

     C                   eval      $lnuser = #curruser
     C                   eval      $lnemp# = #emp#
     C                   eval      $lnpgm  = #pgm
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobnbr

     C                   endsr


     *----------------------------------------------------------------
     *  zzzdriclose   Close any open files or programs.
     *----------------------------------------------------------------

     C     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   eval      $dridata2 = $licinfo2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*LICENSE'
     C                             or $dricommand = '*LICINFO'
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

     C                   when      chk4err and %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   if        zmsflag
     C                   exsr      zm0105s
     C                   else
     C                   exsr      zm0105
     C                   endif

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   if        zmsflag
     C                   exsr      zm0001s
     C                   else
     C                   exsr      zm0001
     C                   endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $license = $dridata
     C                   eval      $license2 = $dridata2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
     C                   eval      $licinfo2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  License Plate Tracking Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------


     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
**
Slot
Adjustment Type
Transfer Quantity
Verify Zero
F10 not allowed - Mult Lic Exist
Invalid OSS slot - Print new label
**
 ABCDEFGHIJKLMNOPQRSTUVWXYZ
