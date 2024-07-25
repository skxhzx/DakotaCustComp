     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2001')

     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IT112A    Item maintenance - Non blank and non B item types
     *  14 June 1999
     *  Kenneth Elder
     *
     *
     *  Revisions
     *
DRI A*    10/22/01  DAS  4.16
     *      - Total rewrite. Changed to use DRI interface programs.
     *
416aA*    01/24/02  DAS  4.16a
     *      - Revised to only do one call to the DRI interface.
     *        The interface program will make the call to the host.
     *      - Revised to use '%' as the first character of the subcommand
     *        instead of '*'. This identifies that the call to the
     *        interface was initiated from Dakota and not the Host.
     *      - Revised the way the ZM0001 routines identify if the message
     *        was sent back from the host.
     *
416bA*    06/11/03  DAS  4.16b
     *      - C#ITEM revised to have two data structures, $item and $item2.
     *      - Revised program to work with second data structure.
640aA*    02/10/11  RH   6.40a
     *      - Enh: Add client custom support.                         tem2.
     *
     *----------------------------------------------------------------
DRYa *  Dariyland - Custom changes
DRYaA*    02/10/11  RH   DRYa
     *      - Only update fields not sent thru interface.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  92        CHANGE MODE (PROTECT ITEM KEYS)
     *  96        HIDE EXTENDED DESCRIPTION
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fit112afm  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Foptions   if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D desc            s             40    dim(5) ctdata perrcd(1)
     D extd            s             25    dim(2) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
     D savever#        s                   like($itver#)

640  *----------------------------------------------------------------
640  *  Customer id
640  *----------------------------------------------------------------
640
DRYa  /copy qcopysrc,id#dairyla
     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vwhse          s              3p 0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
     D help            s              5  0
DRYa D kywhse          s                   like($pwhse)
     D msgk            s              4  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D warn            s              1
     D whse            s              3  0
     D zmsflag         s               n

     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     D  $pitpe               137    137

     *   Redefine key

     D  $pwhse                19     21  0
     D  $pitem                22     36
     D  $pxflg                37     37

DRYaA*----------------------------------------------------------------
DRYaA*  *IMPITEM  -  Import Item options.
DRYaA*----------------------------------------------------------------
     *
     *    Y = Maintained by Host, imported to FSWMS
     * Fields
     *
     *    OPITYP  -  Item type
     *    OPDESC  -  Item description
     *    OPWHDP  -  Warehouse department
     *    OPSTYP  -  Section type
     *    OPWHDP  -  Default warehouse department
     *    OPDESG  -  Designation
     *    OPACTV  -  Activity
     *    OPBLD   -  Build code
     *    OPVEN#  -  Vendor number
     *    OPVIT#  -  Vendor item number
     *    OPPDSC  -  Pack description
     *    OPUM1   -  Normal unit of measure
     *    OPUM2   -  Breakdown 1 unit of measure
     *    OPUMQ2  -  Breakdown 1 UM quantity
     *    OPFLG1  -  Allow Breakdown 1 Sale
     *    OPUM3   -  Breakdown 2 unit of measure
     *    OPUMQ3  -  Breakdown 2 UM quantity
     *    OPFLG2  -  Allow Breakdown 2 Sale
     *    OPULEN  -  Unit length
     *    OPUWDT  -  Unit width
     *    OPUHGT  -  Unit height
     *    OPCUBE  -  Cube/Unit
     *    OPSWGT  -  Shipping weight
     *    OPCWGT  -  Catch weight
     *    OPREPL  -  Replenish level
     *    OPFLGD  -  Date sensitive
     *    OPFLGB  -  Allow bulk pick
     *    OPSLIF  -  Shelf life days
     *    OPNDAY  -  Notice days
     *    OPTIE   -  Mfr. Tie
     *    OPHIGH  -  Mfr. High
     *    OPMFLG  -  Manufacturing date
     *    OPDDAY  -  Distributor days
     *    OPUDAY  -  End user days
     *    OPMDAY  -  Mfr. shelf life days
     *    OPMITM  -  Master item number
     *    OPCITM  -  Contract Base item #
416i *    OPNSLT  -  Non-slotted item
416i *    OPXDCK  -  Crossdock item
416i *    OPBNBR  -  Buyer number
416i *    OPBNAM  -  Buyer name
416i *    OPVNAM  -  Vendor name
416i *    OPBRND  -  Brand
416i *    OPLOT   -  Lot code item
416i *    OPLTRK  -  Track by license
     *
     * Data structure
     *
411 D*PDATA      DS
DRY AD opdat3          ds
     D  opityp                 1      1
     D  opdesc                 2      2
     D  opwhd3                 3      3
     D  opsty3                 4      4
     D  opdesg                 5      5
     D  opactv                 6      6
     D  opbld                  7      7
     D  opven#                 8      8
     D  opvit#                 9      9
     D  oppdsc                10     10
     D  opum13                11     11
     D  opum2                 12     12
     D  opumq2                13     13
     D  opflg1                14     14
     D  opum3                 15     15
     D  opumq3                16     16
     D  opflg2                17     17
     D  opulen                18     18
     D  opuwdt                19     19
     D  opuhgt                20     20
     D  opcube                21     21
     D  opswgt                22     22
     D  opcwgt                23     23
     D  oprepl                24     24
     D  opflgd                25     25
     D  opflgb                26     26
     D  opslif                27     27
     D  opnday                28     28
     D  optie                 29     29
     D  ophigh                30     30
     D  opmflg                31     31
     D  opdday                32     32
     D  opuday                33     33
     D  opmday                34     34
     D  opmitm                35     35
     D  opcitm                36     36
     D  opnslt                37     37
     D  opxdck                38     38
     D  opbnbr                39     39
     D  opbnam                40     40
     D  opvnam                41     41
     D  opbrnd                42     42
     D  oplot                 43     43
     D  opltrk                44     44
     D  opten3               117    117
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     60

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')

     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

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
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new record.
     *              *EDIT    - Edit record.
     *              *PRINT   - Print record.
     *              *VIEW    - View record.
     *              *WORKTIE - Work with tie/highs
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for everything but *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new unique key for *ADD.
     *              Unchanged for everything else.
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $parms

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      *in97 = *on
     C                   eval      *in96 = *on
     C                   eval      *in92 = *off
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
 1B  C                   exsr      zzinz2
 1B  C                   if        error = *on
     C                   move      'EOJ'         nxtscr
 1E  C                   endif
     *
 1B  C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
 2B  C     nxtscr        caseq     '01 '         sc1
 2E  C                   endcs
 1E  C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr

     *  Close interface

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C****               eval      $drisys2upd = 'H'
     C****               exsr      zzzdricop

     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
 1B  C                   if        error = *on
     C                   eval      *in98 = *on
 1E  C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
 1B  C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
 1E  C                   endif
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
     C                   setoff                                       616263
     C                   setoff                                       646566
     C                   setoff                                       676869
     C                   setoff                                       70
     C                   setoff                                       98
     C                   move      *off          warn
     C                   move      *off          error
     C                   move      *off          cmdtkn
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
 1B  C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   eval      *in92 = *on
     C                   eval      *in96 = *on
 1E  C                   endif
     *
 1B  C                   if        $pcmd = '*CHANGE '
     C                   eval      *in92 = *on
 1E  C                   endif
     *
     *     Get field defaults if this is an add.
     *
 2B  C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft1
 2X  C                   else
     *
     *     Otherwise get existing record(s).
     *
     C                   exsr      zzget1
     C                   exsr      zzfil1
 2E  C                   endif
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
 1B  C                   if        *inkc
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
goto C                   goto      endsc1
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
 2B  C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
 2E  C                   endif
goto C                   goto      endsc1
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
goto C                   goto      endsc1
 1E  C                   endif
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
 1B  C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
 1E  C                   endif
     *
     *  Everything went fine so get out of program.
     *
     C                   move      'EOJ'         nxtscr
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
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125
     *
640
640  * Get client id.
640
640  C                   call      'GETCLIENT'
640  C                   parm                    client           10
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
 1B  C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
 1E  C                   endif
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
 1B  C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
 1E  C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
 1B  C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
 1E  C                   endif
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
 1B  C                   if        $msgf = *blanks
     C                   move      #msgf         $msgf
 1E  C                   endif
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
     *    PIR0105  Generic error.
     *----------------------------------------------------------------

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *    PIR0105  Generic error (send to different program)
     *----------------------------------------------------------------

     C     zm0105s       begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     zzchk1        begsr
     C                   eval      error = *off

     *  Initialize interface fields.

     C                   eval      savever# = $itver#
     C                   clear                   $item
416bAC                   clear                   $item2
     C                   eval      $itver# = savever#

     C                   eval      $itwhse  = $pwhse
     C                   eval      $ititem  = w1item

DRYa C                   if        client = dairyl and
DRYa C                             opityp = 'Y'
DRYa C                   eval      $ittypeu  = *off
DRYa C                   else
     C                   eval      $ittypeu = *on
     C                   eval      $ittype  = $pitpe
DRYaAC                   endif

     C                   eval      $itmitemu = *on
     C                   eval      $itmitem  = w1itm2

DRYa C                   if        client = dairyl and
DRYa C                             opcitm = 'Y'
DRYa C                   eval      $itcitemu  = *off
DRYa C                   else
     C                   eval      $itcitemu = *on
     C                   eval      $itcitem  = w1itm3
DRYa C                   endif

DRYa C                   if        client = dairyl and
DRYa C                             opdesc = 'Y'
DRYa C                   eval      $itdescu  = *off
DRYa C                   else
     C                   eval      $itdescu = *on
     C                   eval      $itdesc  = w1desc
DRYa C                   endif

DRYa C                   if        client = dairyl and
DRYa C                             oppdsc = 'Y'
DRYa C                   eval      $itpdscu  = *off
DRYa C                   else
     C                   eval      $itpdscu = *on
     C                   eval      $itpdsc  = w1pkdg
DRYa C                   endif

DRYa C                   if        client = dairyl and
DRYa C                             opdesc = 'Y'
DRYa C                   eval      $ixdsc1u  = *off
DRYa C                   eval      $ixdsc2u = *off
DRYa C                   else
     C                   eval      $ixdsc1u = *on
     C                   eval      $ixdsc1  = w1dsc1

     C                   eval      $ixdsc2u = *on
     C                   eval      $ixdsc2  = w1dsc2
DRYa C                   endif

     *  Dakota verification.

     C                   eval      $dricommand = '*ITEM'
     C                   if        $pcmd = '*ADD'
     C                   eval      $drisubcmd  = '%VERIFYADD'
     C                   else
     C                   eval      $drisubcmd  = '%VERIFYCHG'
     C                   endif
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     *  Host verification.

     C****               if        not error
     C****               eval      $drisys2upd = 'H'
     C****               exsr      zzzdricop
     C****               endif

     C     endck1        endsr

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off

     *  Test for F8 - DISPLAY/HIDE EXTENDED DESCRIPTIONS

 1B  C                   if        *inkh
     C                   eval      cmdtkn = *on
 2B  C                   if        *in96
     C                   eval      *in96 = *off
     C                   eval      fld001 = extd(2)
 2X  C                   else
     C                   eval      *in96 = *on
     C                   eval      fld001 = extd(1)
 2E  C                   endif
 1E  C                   endif

     *      F9 - View warehouse quantities.

 1B  C                   if        *inki
     C                   eval      cmdtkn = *on
     C                   eval      whse = $pwhse
     C                   call      'IT810'
     C                   parm                    whse
     C                   parm                    w1item
 1E  C                   endif

     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZDFT1   Get default values for add.
     *----------------------------------------------------------------

     C     zzdft1        begsr
     C                   eval      w1item = *blanks
     C                   eval      w1desc = *blanks
     C                   eval      w1dsc1 = *blanks
     C                   eval      w1dsc2 = *blanks
     C                   eval      w1itm2 = *blanks
     C                   eval      w1itm3 = *blanks
     C                   eval      w1pkdg = *blanks
     C                   endsr

     *----------------------------------------------------------------
     *  zzerrind    Set error indicators from DRI call.
     *----------------------------------------------------------------

     C     zzerrind      begsr

     C                   if        $ititeme = '1'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   endif

     C                   if        $itmiteme = '1'
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   endif

     C                   if        $itciteme = '1'
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   endif

     C                   if        $itdesce = '1'
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   endif

     C                   if        $itpdsce = '1'
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr

     C                   eval      w1item = $ititem
     C                   eval      w1desc = $itdesc
     C                   eval      w1pkdg = $itpdsc
     C                   eval      w1itm2 = $itmitem
     C                   eval      w1itm3 = $itcitem
     C                   eval      w1dsc1 = $ixdsc1
     C                   eval      w1dsc2 = $ixdsc2

     C                   endsr

     *----------------------------------------------------------------
     *  ZZGET1   Get record(s) for screen 1.
     *----------------------------------------------------------------

     C     zzget1        begsr

     *   Get item information.

     C                   eval      savever# = $itver#
     C                   clear                   $item
416bAC                   clear                   $item2
     C                   eval      $itver# = savever#

     C                   eval      $itwhse   = $pwhse
     C                   eval      $ititem   = $pitem

     C                   eval      zmsflag     = *on
     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C     endgt1        endsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr
DRYa *  Define key for options file, Item Import fields
DRYa
DRYa C     optiky        klist
DRYa C                   kfld                    kywhse
DRYa C                   kfld                    opcode
     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ2   Program initialization. Called from main line.
     *----------------------------------------------------------------

     C     zzinz2        begsr

     *  Open interface

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%OPEN'
     C                   eval      $drisys2upd = 'D'

     C                   exsr      zzzdricop
     C                   if        error
     C                   goto      endinz2
     C                   endif

     C****               eval      $drisys2upd = 'H'
     C****               exsr      zzzdricop
     C****               if        error
     C****               goto      endinz2
     C****               endif

     *  Get warehouse description.

     C                   eval      whcode = $pwhse
     C                   eval      whdesc = ' '

     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $pwhse        $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   when      $vreturn <> '*OK'
     C                   other
     C                   eval      whdesc = $vdesc
     C                   endsl

     *  move in correct heading based on item type

 1B  C                   if        $pitpe = 'A'
     C                   eval      hdtype = desc(1)
 1E  C                   endif

 1B  C                   if        $pitpe = 'C'
     C                   eval      hdtype = desc(2)
 1E  C                   endif

 1B  C                   if        $pitpe = 'S'
     C                   eval      hdtype = desc(3)
 1E  C                   endif
DRYa *   Get Item import field options
DRYa
DRYaAC                   if        client = dairyl
DRYa C                   eval      kywhse = *zeros
DRYa C                   eval      opcode = '*IMPITEM'
DRYa C     optiky        chain     options                            79
DRYa C                   if        *in79
DRYa C                   else
DRYa C                   eval      opdat3 = opdata
DRYa C                   endif
DRYa C                   endif


     C                   eval      fld001 = extd(1)

     *   Select first screen to display.

     C                   exsr      scr01i

     C     endinz2       endsr
     *----------------------------------------------------------------
     *  ZZUPD1   Update for screen 1.
     *----------------------------------------------------------------

     C     zzupd1        begsr
     C                   move      *off          error

     *  Update Host

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = $pcmd
     C                   eval      %subst($drisubcmd:1:1) = '%'
     C****               eval      $drisys2upd = 'H'
     C****               exsr      zzzdricop

     *  Update Dakota

     C                   if        not error
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   endif

     C     endup1        endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $item         parm      $item         $dridata
416bAC     $item2        parm      $item2        $dridata2

     C                   select

     C                   when      %error
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

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   if        zmsflag
     C                   exsr      zm0001s
     C                   else
     C                   exsr      zm0001
     C                   exsr      zzerrind
     C                   endif

     C                   endsl

     C                   eval      zmsflag = *off
     C     enddricop     endsr

     *---------------------------------------------------------------------****
     *  COMPILE TIME TABLES
     *---------------------------------------------------------------------****

**
            Alias Detail Entry
          Contract Detail Entry
    Same Slot Breakdown Detail Entry
Item number
Base item number
**
F8=Dsply Extended Desc.
F8=Hide Exteneded Desc.
