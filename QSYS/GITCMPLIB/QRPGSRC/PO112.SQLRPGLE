     F*----------------------------------------------------------------
     F*   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  PO112     PO header maintenance - Change
     F*  08 October, 1996
     F*  Hemant Kapadia
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
415 AF*   07/02/01  DAS  4.15
     F*     - Recompiled because format changed to use ind 91 to
     F*       protect PO# for *CHANGE.
     F*
510  F*   06/07/06  RMC  5.10
     F*     - Added Buyer number and name to SCREEN1.
     F*
510A F*   06/16/06  RMC  5.10
     F*     - Add Destination storage location for Packers.
     F*       Display format SCRPCK1 for Packers instead of
     F*       SCREEN1.
510b F*   10/30/06  RAH  5.10
     F*     - Add Shipper Name to SCREEN1.  Output to
     F*       field PHMM5 in POHDRM for use in PO812.
510c F*   11/16/06  RAH  5.10c
     F*     - If entering shipper name for a SuperPO, put shipper
     F*       name on all associated PO's if they don't have one yet.
     F*
520 AF*   10/08/09  MLB  5.20
     F*     - Fix: Revised program to unlock POHDRM when F3/F12
     F*       is pressed to release lock on record when pgm is
     F*       called with $PCMD = *CHANGE and user does not press Enter.
750a *    05/14/21  RTR  7.50a
     *      - DockVue: Added update of POSTATUS table when PO added or
     *        updated.
     *
770aA*   08/27/22  TDC  770a
     *     - Add system option opdckv to control DockVue processing.
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Y.Hata
     F*
YHT AF*   01/03/08  MLB  YHT
     F*     - Revised program to use last 3 positions of Vendor
     F*       address line 2 for H&S freight code. Program
     F*       will display fmt SCRYHT1 for Y.Hata.
YHTbAF*   12/02/10  RH   YHTb  P#01024
     F*     - Revised program to use last 6 positions of Vendor address
     F*       line 2 before H&S freight code for container code.
     F*       Will display fmt SCRYHT1 for Y.Hata.
     F*      - DSPF renamed to PO11201 from PO112FM for new fmts added.
     F*
     A*----------------------------------------------------------------
     A*  Client Custom Revisions: Coastal Sunbelt Produce
     A*
CSP AA*   12/16/10  MLB  CSP  P#01028
     F*     - Revised program to update Load Number on p/o.
     F*       Load number stored in vendor address line 2 in last 6 pos.
     A*
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
YHTbDf*po112fm   cf   e             workstn
YHTbMfpo11201   cf   e             workstn
     f                                     infds(infds)
     f                                     sfile(msgrec:msgk)
     fpohdr     uf a e           k disk
     f                                     rename(phrec:record)
     fwarehs    if   e           k disk
510c fpospo     if   e           k disk
510A F*510POHDRM  IF  E           K        DISK
510A fpohdrm    uf a e           k disk
770aA*----------------------------------------------------------------
770aA*  System options
770aA*----------------------------------------------------------------
770aAD oprec         E Ds                  Extname(options)
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     d a10             s              1    dim(10)
CSP DD*desc            s             20    dim(1) ctdata perrcd(1)
CSP MD desc            s             20    dim(2) ctdata perrcd(1)
770aA*----------------------------------------------------------------
770aA*  Standard SQL variables and constants
770aA*----------------------------------------------------------------
770aA /copy qcopysrc,c#stdsql
770aA*----------------------------------------------------------------
770aA* Variables
770aA*----------------------------------------------------------------
770aAd dockvue         s               n   inz('0')
770aAD ocode           s              8
770aAD wkwhse          s              3  0
510A D*
770aA*----------------------------------------------------------------
510A  /COPY QCOPYSRC,ID#PACKERS
YHT A /copy qcopysrc,id#yhata
CSP A /copy qcopysrc,id#coastal
     d @getcl          c                   const('GETCLIENT')
770aA*----------------------------------------------------------------
770aA*  *SYSTEM   -  System options.
770aA*----------------------------------------------------------------
770aA* Fields
770aA*----------------------------------------------------------------
770aA*
770aA* Data structure
770aA*
770aAD sysoptions      ds
770aAD  opepm                  1      1
770aAD  oprf                   2      2
770aAD  opcapc                 3      3
770aAD  opletd                 4      4
770aAD  opwrnc                 5      5
770aAD  oprg1c                 6      8  1
770aAD  oprg2c                 9     11  1
770aAD  opimpi                12     12
770aAD  opicw                 13     13
770aAD  opmpck                14     14
770aAD  oprcdy                15     15  0
770aAD  oppkdy                16     16  0
770aAD  oprths                17     19  0
770aAD  opcrhs                20     22  0
770aAD  oppohs                23     25  0
770aAD  opiahs                26     28  0
770aAD  opmshs                29     31  0
770aAD  optbjq                32     32
770aAD  opishs                33     35  0
770aAD  opishsa               33     35
770aAD  opuci                 36     36
770aAD  opwrncr               37     37
770aAD  opicwr                38     38
770aAD  optrax                39     39
770aAD  opdckv                50     50
770aAD  op4end               117    117
     D*----------------------------------------------------------------
     D*  Program parameters
     D*
     d $parms          ds
     d  $pcmd                  1      8
     d  $pprg                  9     18
     d  $puky                 19     68
     d  $prtn                 69     76
     d  $perm                 77    136
     d  $pmsg                 77     80
     D*
     D*   Redefine key
     D*
     d  $pwhse                19     21  0
     d  $ppo                  22     30
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     d @cvtdt          c                   const('CVTDTE')
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     d $cvtdt          ds
     d  $cvcmd                 1      8
     d  $cvprg                 9     18
     d  $cvd6i                19     24
     d  $cvd8i                25     32
     d  $cvd6o                33     38  0
     d  $cvd8o                39     46  0
     d  $cvsto                47     64
     d  $cvrtn                65     72
     d  $cverm                73    132
     d  $cvmsg                73     76
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     d $mdt            ds
     d  errmsg                 1     50
     D*
     d  erfld                  1     30
     d  erfrom                31     40
     d  erto                  41     50
     d                 ds
     d  $ec                    1      2p 0
510   * Buyer Name and Number
510  d                 ds
510  d  phmm1                  1     40
510  d  phbuyr                 1      3
510  d  phname                 4     33
510A  * Destination Storage Location - Packers
510A d                 ds
510A d  phmm5                  1     40
510A d  phdest                 1      4
CSP AD*----------------------------------------------------------------
CSP AD*  Working Variables
CSP AD*
CSP AD Nbrlodn         s              6  0   inz(0)
CSP AD pos             s              5  0   inz(0)
CSP AD valid           c                   const('0123456789 ')
CSP AD wklodn          s              6      inz(' ')
770aAD nostamp         s               z     inz
     D*----------------------------------------------------------------
     D*  Message control
     D*
     d #msgf           c                   const('PIRMSGF   ')
     D*
     d                 ds
     d  #msgdt                 1    128
     d  $md                    1    128
     d                                     dim(128)
     D*----------------------------------------------------------------
     D*  Program info data structure
     D*
     d                sds
     d  #prog            *proc
     d  #job                 244    253
     d  #user                254    263
     d  #jobn                264    269
     d  #jobdt               276    281  0
     d  #jobtm               282    287  0
     D*----------------------------------------------------------------
     D*  Workstation exception data structure
     D*
     d infds           ds
     d  status           *status
     d  rowin                370    370
     d  colin                371    371
     D*----------------------------------------------------------------
     D*  Workstation exception redefinition data structure
     D*
     d                 ds
     d  row#                   1      2b 0
     d  row                    2      2
     d  col#                   3      4b 0
     d  col                    4      4
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PCMD   *ADD     - Create new batch.
     C*              *EDIT    - Edit batch.
     C*              *DELETE  - Delete batch.
     C*              *PRINT   - Print batch edit listing.
     C*              *POST    - Post batch.
     C*      $PPRG   Program to send messages back to.
     C*      $PUKY   Contains key for everything by *ADD.
     C*
     C*    Returned Parameters
     C*      $PUKY   Contains new batch number for *ADD.
     C*              Unchanged for everything else.
     C*      $PRTN   blank    - No problem encountered.
     C*              *ERROR   - Error occured. Message in $PERM
     C*              *PGMQ    - Error occured. Message sent to pgmq.
     C*      $PERM   Error message or pointer to message in pgmq.
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     c     *entry        plist
     c                   parm                    $parms
     C*----------------------------------------------------------------
     C*  Main line
     C*
     c                   move      *on           *in97
     c                   move      *off          *in90
     c                   move      *off          *in91
     c                   move      *off          error
     c                   move      *blanks       $prtn
     c                   move      *blanks       $perm
     c                   exsr      zzinz2
     c     error         ifeq      *on
     c                   move      'EOJ'         nxtscr
     c                   end
     C*
     c     nxtscr        downe     'EOJ'
     c                   exsr      dspscr
     c     nxtscr        caseq     '01 '         sc1
     c                   end
     c                   end
     C*
     C*   Do some clean up before leaving.
     C*
     c                   exsr      zsclr
     c                   return
     C*----------------------------------------------------------------
     C*  DSPSCR - Display screen
     C*
     c     dspscr        begsr
     C*
     C*   Set ON alarm indicator if error occured
     C*
     c     error         ifeq      *on
     c                   move      *on           *in98
     c                   end
     C*
     C*   Overlay screen with error messages
     C*
     c                   exsr      zmdmsg
     C*
     C*  Overlay screen with screen to be processed.
     C*
     c     nxtscr        ifeq      '01 '
510A c                   select
510A c     client        wheneq    packers
510A c                   exfmt     scrpck1
YHT Ac     client        wheneq    yhata
YHT Ac                   exfmt     scryht1
CSP Ac     client        wheneq    coastalsunbelt
CSP Ac                   exfmt     scrcsp1
510A c                   other
     c                   exfmt     screen1                              50
510A c                   endsl
     c                   end
     C*
     C*   Initialize error indicators and fields
     C*
     c                   setoff                                       010203
     c                   setoff                                       040506
     c                   setoff                                       070809
     c                   setoff                                       101112
     c                   setoff                                       131415
     c                   setoff                                       161718
     c                   setoff                                       1920
     c                   setoff                                       212223
     c                   setoff                                       242526
     c                   setoff                                       272829
     c                   setoff                                       303132
     c                   setoff                                       333435
     c                   setoff                                       363738
     c                   setoff                                       3940
     c                   setoff                                       98
     c                   move      *off          warn              1
     c                   move      *off          error             1
     c                   move      *off          cmdtkn            1
     c                   z-add     0             e                 2 0
     C*
     C*   Initialize error subfile
     C*
     c                   exsr      zmcmsg
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*     Screen initialization and wrap-up routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  Screen 01 initialization
     C*
     c     scr01i        begsr
     c                   move      '01 '         nxtscr            3
     C*
     c     $pcmd         ifeq      '*VIEW   '
     c                   move      *on           *in90
     c                   endif
     C*
     C*  Get field defaults if this is an add.
     C*
     c     $pcmd         ifeq      '*ADD    '
     c                   exsr      zzdft1
     c                   else
     C*
     C*  Otherwise get existing record(s).
     C*
     c                   move      *on           *in91
     c                   exsr      zzget1
     c                   exsr      zzfil1
     c                   end
     c     end01i        endsr
     C*----------------------------------------------------------------
     C*
     C*              Screen Processing Routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  SC1  -  Screen 1
     C*
     c     sc1           begsr
     C*
     C*  Test for F3 - Exit
     C*
     c     *inkc         ifeq      *on
     c     *loval        setll     record
520 AC                   unlock    pohdrm
     c                   move      'EOJ'         nxtscr
     c                   move      '*EXIT   '    $prtn
     c                   goto      endsc1
     c                   end
     C*
     C*  Test for F5 - Refresh
     C*
     c     *inke         ifeq      *on
     c     $pcmd         ifne      '*VIEW   '
     c                   exsr      scr01i
     c                   end
     c                   goto      endsc1
     c                   end
     C*
     C*  Test for F12 - Previous
     C*
     c     *inkl         ifeq      *on
     c     *loval        setll     record
520 AC                   unlock    pohdrm
     c                   move      'EOJ'         nxtscr
     c                   move      '*CANCEL '    $prtn
     c                   goto      endsc1
     c                   end
     C*
     C*  Test for other command keys BEFORE verification and update.
     C*
     c                   move      '*BEFORE '    cmdchk            8
     c                   exsr      zzcmd1
     c     cmdtkn        cabeq     *on           endsc1
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     c     $pcmd         ifeq      '*ADD    '
     c     $pcmd         oreq      '*CHANGE '
     c                   exsr      zzchk1
     c     error         cabeq     *on           endsc1
     c                   exsr      zzupd
     c     error         cabeq     *on           endsc1
     c                   end
     C*
     C*  Test for other command keys AFTER verification and update.
     C*
     c                   move      '*AFTER  '    cmdchk
     c                   exsr      zzcmd1
     c     cmdtkn        cabeq     *on           endsc1
     C*
     C*  Everything went fine so get out of program.
     C*
     c                   move      'EOJ'         nxtscr
     c     endsc1        endsr
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     c     *inzsr        begsr
510A C*
510A C* Get client id.
510A C*
510A c                   call      @getcl
510A c                   parm                    client           10
510A C*
     C*
     C*  Initialize special keys
     C*
     c                   z-add     0             enter             5 0
     c                   z-add     2             comand            5 0
     c                   z-add     01122         rollup            5 0
     c                   z-add     01123         rolldn            5 0
     c                   z-add     01124         clear             5 0
     c                   z-add     01125         help              5 0
     C*
     C*  Initialize message handling
     C*
     c                   exsr      zmimsg
     C*
     C*   Call user added initialization routine.
     C*
     c                   exsr      zzinz
     c                   endsr
     C*---------------------------------------------------------------
     C*
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*
     C*    ZMCMSG  Clear message record subfile
     C*
     c     zmcmsg        begsr
     c                   move      *off          *in97
     c                   write     msgctl
     c                   z-add     *zero         msgk              4 0
     c                   write     msgclr
     c                   move      '*CLEAR '     #msgid            7
     c                   move      '*NULL  '     #msgtp            7
     c                   exsr      zmpmsg
     c                   endsr
     C*
     C*    ZMDMSG  Display message record subfile
     C*
     c     zmdmsg        begsr
     c                   move      *on           *in97
     c     msgk          ifgt      0
     c                   write     msgctl
     c                   z-add     *zero         msgk
     c                   end
     c                   endsr
     C*
     C*    ZMIMSG  Initialization necessary for message subfile
     C*
     c     zmimsg        begsr
     c                   move      #prog         #pgmq            10
     c                   exsr      zmcmsg
     c                   endsr
     C*
     C*    ZMPMSG  Add message record to subfile
     C*
     c     zmpmsg        begsr
     c     $msgf         ifeq      *blanks
     c                   move      #msgf         $msgf            10
     c                   end
     c                   call      'PUTMSG'
     c                   parm                    $msgf
     c                   parm                    #msgid
     c                   parm                    #msgtp
     c                   parm                    #msgdt
     c                   parm                    #pgmq
     c                   parm                    #msgk
     c     #msgid        ifne      '*CLEAR '
     c                   add       1             msgk
     c                   write     msgrec
     c                   end
     c                   move      *blanks       #msgdt
     c                   move      *blanks       $msgf
     c                   endsr
     C*
     C*    ZMQMSG  Add message record to subfile from program queue
     C*
     c     zmqmsg        begsr
     c                   add       1             msgk
     c                   write     msgrec
     c                   endsr
     C*
     C*    ZSCLR   Clear screen
     C*
     c     zsclr         begsr
     c                   write     clrscr
     c                   move      *on           sclear            1
     c                   endsr
     C*
     C*    ZMSMSG  Send program message to a different program msgq
     C*
     c     zmsmsg        begsr
     c     $msgf         ifeq      *blanks
     c                   move      #msgf         $msgf            10
     c                   end
     c                   call      'PUTMSG'
     c                   parm                    $msgf
     c                   parm                    #msgid
     c                   parm                    #msgtp
     c                   parm                    #msgdt
     c                   parm      $pprg         #pgmq2           10
     c                   parm                    #msgk             4
     c                   move      *blanks       #msgdt
     c                   move      *blanks       $msgf
     c                   endsr
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
CSP A*----------------------------------------------------------------
CSP A*      0105
CSP A*
CSP AC     zm0105        begsr
CSP AC                   move      'PIR0105'     #msgid
CSP AC                   move      '*DIAG  '     #msgtp
CSP AC                   movea     errmsg        $md(1)
CSP AC                   exsr      zmpmsg
CSP AC                   endsr
CSP AC*
     C*----------------------------------------------------------------
     C*   PIR0201  Code must be entered for create.
     C*
     c     zm01          begsr
     c                   move      'PIR0201'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     desc          errmsg
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   PIR0202  Code already exists.
     C*
     c     zm02          begsr
     c                   move      'PIR0202'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     desc          errmsg
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   PIR7971  Error in writing a record.
     C*
     c     zm71          begsr
     c                   move      'PIR7971'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       $md
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   PIR7972  Error in updating a record.
     C*
     c     zm72          begsr
     c                   move      'PIR7972'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       $md
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*     PIR7973  Slot record does not exist.
     C*
     c     zm73          begsr
     c                   move      'PIR7973'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmsmsg
     c                   move      #msgk         $pmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*     PIR7974  Slot record is locked.
     C*
     c     zm74          begsr
     c                   move      'PIR7974'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmsmsg
     c                   move      #msgk         $pmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   PO11221  Invalid order type entered.
     C*
     c     zm21          begsr
     c                   move      'PO11221'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       $md
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK1   Screen 1 error checking.
     C*
     c     zzchk1        begsr
     c                   move      *off          error
     C*
     C*  When adding ....
     C*
     c     $pcmd         ifeq      '*ADD    '
     C*
     C*    Make sure code was entered.
     C*
     c     w1po          ifeq      *blanks
     c                   move      *on           error
     c                   move      *on           *in21
     c                   move      *on           *in01
     c                   exsr      zm01
     c                   endif
     C*
     C*    Make sure code doesn't already exist.
     C*
     c                   move      w1po          $ppo
     c     fileky        chain     record                             79
     c     *in79         ifeq      *off
     c                   move      *on           error
     c                   move      *on           *in21
     c                   move      *on           *in01
     c                   exsr      zm02
     c                   endif
     c                   endif
CSP A*
CSP AC                   if        client = CoastalSunbelt
CSP A*
CSP A*    Validate characters entered for Load Number.
CSP AC                   eval      pos  = %check (valid : w1lodn)
CSP A*    Invalid characters in qty found fields.
CSP AC                   If           pos  > 0
CSP AC                   eval      error = *on
CSP AC                   eval      *in32 = *on
CSP AC                   eval      *in12 = *on
CSP AC                   movel     desc(2)       errmsg
CSP AC                   exsr      zm0105
CSP AC                   goto      endck1
CSP AC                   Endif
CSP A*
CSP A*    Convert characters entered into numeric field.
CSP AC                   eval      nbrlodn = 0
CSP A*
CSP AC                   if        w1lodn > ' '
CSP AC                             and pos = 0
CSP AC                   eval      nbrlodn = %dec(w1lodn:6:0)
CSP AC                   endif
CSP A*
CSP AC                   Endif
CSP A*
     c     endck1        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD1   User defined command keys for screen 1.
     C*
     c     zzcmd1        begsr
     C*
     C*  Command keys to check BEFORE verification and update.
     C*
     c     cmdchk        ifeq      '*BEFORE '
     c                   end
     C*
     C*  Command keys to check AFTER verification and update.
     C*
     c     cmdchk        ifeq      '*AFTER  '
     c                   end
     c     endcm1        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZDFT1   Get default values for add.
     C*
     c     zzdft1        begsr
     C*
     C*     - Get new order number.
     C*
     C**                   CALL 'PIRPO# '
     C**                   PARM $PWHSE    $OWHSE  30
     C**                   PARM           W1PO
     C*
     c                   move      *blanks       w1po
     c                   z-add     0             w1ven
     c                   move      *blanks       w1vnam
     c                   move      *blanks       w1vad1
     c                   move      *blanks       w1vad2
     c                   move      *blanks       w1vcty
     c                   move      *blanks       w1vst
     c                   move      *blanks       w1vzp1
     c                   move      *blanks       w1buyr
510A c                   z-add     *zeros        w1dest
510b c                   move      *blanks       w1shpr
YHT Ac                   eval      w1yad2 = ' '
YHT Ac                   eval      w1frgt = ' '
YHTbAc                   eval      w1cont = ' '
CSP Ac                   eval      w1lodn = ' '
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL1   Fill screen 1 fields with info from file.
     C*
     c     zzfil1        begsr
510A c                   z-add     *zeros        w1dest
510A c                   move      *off          *in30
     c                   move      phpo          w1po
     c                   z-add     phven         w1ven
     c                   move      phvnam        w1vnam
     c                   move      phvad1        w1vad1
YHT AC
YHT AC                   select
YHT AC                   when      client = YHata
YHT AC                   movel     phvad2        w1yad2
YHT AC                   move      phvad2        w1frgt
YHTbAC*                  move      phvad2        w1wrk9            9
YHTbAC*                  movel     w1wrk9        w1cont
YHTbAC                   eval      w1cont = %subst(phvad2:32:6)
CSP AC*
CSP AC                   when      client  = CoastalSunbelt
CSP AC                   eval      w1vad2c = %subst(phvad2:1:34)
CSP AC                   eval      w1lodn  = %subst(phvad2:35:6)
CSP AC
YHT AC                   other
YHT AC
     c                   move      phvad2        w1vad2
YHT AC                   endsl
YHT AC
     c                   move      phvcty        w1vcty
     c                   move      phvst         w1vst
     c                   move      phvzp1        w1vzp1
510A c     $pcmd         ifeq      '*VIEW'
510A c     fileky        chain(n)  pohdrm                             80
510A c                   else
510A c     fileky        chain     pohdrm                             80
510A c                   endif
510  c     *in80         ifeq      *off
510  c                   movel     phbuyr        w1buyr
510  c                   movel     phname        w1name
510bac                   move      phmm5         w1shpr
510  c                   else
510  c                   move      *blanks       w1buyr
510  c                   move      *blanks       w1name
510bac                   move      *blanks       w1shpr
510  c                   endif
510A  * Destination storage location for Packers
510  c     *in80         ifeq      *off
510A c     client        andeq     packers
510A c                   move      phdest        w1dest
510A c     phstat        ifeq      '3'
510A c                   move      *on           *in30
510A c                   endif
510A c                   endif
510A  *
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZGET1   Get record(s) for screen 1.
     C*
     c     zzget1        begsr
     C*
     C*   Get record from main file.
     C*
     c     $pcmd         ifeq      '*VIEW   '
     c     fileky        chain(n)  record                             7978
     c                   else
     c     fileky        chain     record                             7978
     c                   endif
     C*
     C*  Record locked.
     C*
     c     *in78         ifeq      *on
     c                   move      *on           error
     c                   move      '*PGMQ   '    $prtn
     c                   exsr      zm74
     c                   goto      endgt2
     c                   end
     C*
     C*  Record not found.
     C*
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   move      '*PGMQ   '    $prtn
     c                   exsr      zm73
     c                   goto      endgt2
     c                   end
     c     endgt2        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     c     zzinz         begsr
     C*
     C*  Define key for main file.
     C*
     c     fileky        klist
     c                   kfld                    $pwhse
     c                   kfld                    $ppo
510cac     filek2        klist
510cac                   kfld                    $pwhse
510cac                   kfld                    pupo
770aA
770aA*  Get System options.
770aA /free
770aA   ocode = '*SYSTEM ';
770aA   exec sql select * into :oprec
770aA        from options
770aA        where opwhse = 0
770aA          and opcode = :ocode;
770aA
770aA   If sqlstt = sqlSuccess;
770aA     sysoptions = opdata;
770aA   else;
770aA     opdckv = 'N';
770aA   endif;
770aA
770aA   If opdckv = 'Y';
770aA     dockvue = *on;
770aA   else;
770aA     dockvue = *off;
770aA   endif;
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Program initialization. Called from main line.
     C*
     c     zzinz2        begsr
     C*
     C*   Get warehouse description.
     C*
     c     $pwhse        chain     warehs                             79
     c     *in79         ifeq      *on
     c                   move      *blanks       whdesc
     c                   end
     C*
     C*   Select first screen to display.
     C*
     c     $pcmd         ifeq      '*ADD    '
     c                   move      *blanks       $ppo
     c                   end
     c                   exsr      scr01i
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD    Update record.
     C*
     c     zzupd         begsr
     c                   move      *off          error
     C*
     C*  Move screen fields to record fields
     C*
     c                   z-add     $pwhse        phwhse
     c                   move      w1po          phpo
     c                   z-add     w1ven         phven
     c                   move      w1vnam        phvnam
     c                   move      w1vad1        phvad1
YHT AC
YHT AC                   select
YHT AC                   when      client = YHata
YHT AC                   movel     w1yad2        phvad2
YHT AC                   eval      phvad2 = %replace(w1frgt:phvad2:38:3)
YHTbAC                   eval      phvad2 = %replace(w1cont:phvad2:32:6)
CSP AC
CSP AC                   when      client = CoastalSunbelt
CSP AC                   eval      phvad2 = %subst(w1vad2c:1:34)
CSP AC                   eval      wklodn = %editc(nbrlodn:'X')
CSP AC                   eval      phvad2 = %replace(wklodn:phvad2:35:6)
CSP AC
YHT AC                   other
YHT AC
     c                   move      w1vad2        phvad2
YHT AC                   endsl
YHT AC
     c                   move      w1vcty        phvcty
     c                   move      w1vst         phvst
     c                   move      w1vzp1        phvzp1
     C*
     C*   Add record
     C*
     c     $pcmd         ifeq      '*ADD    '
     c                   move      '0'           phstat
     c                   move      '*CURCMD '    $cvcmd
     c                   call      @cvtdt
     c                   parm                    $cvtdt
     C**                   Z-ADD$CVD8O    OHSDTE
     C**                   TIME           OHSTIM
     c                   write     record                               79
770aA /free
770aM   // Set status for DockVue for header add
770aA   // Check system option for DockVue
770aA   if dockvue;
770aA     exec sql insert into postatus
770aA              values (:phwhse, :phpo, :phstat,
770aA                      current_timestamp, :nostamp);
770aA
770aA     if sqlstate <> sqlSuccess;
770aA       exec sql update postatus
770aA                   set posstat = :phstat,
770aA                       posupdts = current_timestamp
770aA                 where poswhs = :phwhse
770aA                   and pospo = :phpo;
770aA     endif;
770aA   endif;
770aA /end-free
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   exsr      zm71
     c                   goto      endupd
     c                   end
     c                   else
     C*
     C*   -OR- Update record (it was read and locked in ZZGET2)
     C*
     c                   update    record                               79
770aA /free
770aA   // Update POSTATUS for a po change
770aA   // Check system option for DockVue
770aA   if dockvue;
770aA   exec sql update postatus
770aD   //          set posstat = 'X',
770aM               set posstat = :phstat,
770aA                   posupdts = current_timestamp
770aA             where poswhs = :phwhse
770aA               and pospo = :phpo;
770aA
770aA     if sqlstate <> sqlSuccess;
770aA       exec sql insert into postatus
770aA                values (:phwhse, :phpo, :phstat,
770aA                        current_timestamp, :nostamp);
770aA     endif;
770aA   endif;
770aA /end-free
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   exsr      zm72
     c                   goto      endupd
     c                   end
CSP Ac*
YHTbAc     client        ifeq      yhata
CSP Ac     client        oreq      CoastalSunbelt
YHTb C*   For SuperPO, update all individule P/O
YHTbac     fileky        setll     pospo
YHTbac     fileky        reade     pospo                                  77
YHTbac     *in81         doweq     *off
YHTbAc     filek2        chain     pohdr                              81
YHTbAc     *in81         ifeq      *off
CSP AC*
CSP AC                   select
CSP AC                   when      client = YHata
YHTbAC                   eval      phvad2 = %replace(w1cont:phvad2:32:6)
CSP AC*
CSP AC                   when      client = CoastalSunbelt
CSP AC                   eval      wklodn = %editc(nbrlodn:'X')
CSP AC                   eval      phvad2 = %replace(wklodn:phvad2:35:6)
CSP AC                   endsl
CSP AC*
YHTbac                   update    record                               79
770aA /free
770aA   // Set status for POSTATUS for DockVue on change
770aA   // Chek the DockVue system option
770aA   if dockvue;
770aA     exec sql update postatus
770aA                 set posstat = :phstat,
770aA                     posupdts = current_timestamp
770aA               where poswhs = :phwhse
770aA                 and pospo = :phpo;
770aA
770aA     if sqlstate <> sqlSuccess;
770aA       exec sql insert into postatus
770aA                values (:phwhse, :phpo, :phstat,
770aA                        current_timestamp, :nostamp);
770aA     endif;
770aA   endif;
770aA /end-free
YHTbac                   endif
YHTbac     fileky        reade     pospo                                  81
YHTbAc                   enddo
YHTbAc                   endif
     c                   end
510A C*
510A C*   Add/Change record for Packers - destination storage loc
510A C*
510A c     client        ifeq      packers
510A c     phstat        ifeq      '3'
510A c                   goto      endupd
510A c                   endif
510A c     $pcmd         ifeq      '*ADD    '
510A c                   z-add     $pwhse        phmwh
510A c                   move      w1po          phmpo
510A c                   move      w1dest        phdest
510A c                   write     phmrec                               79
510A c                   unlock    pohdrm
510A c                   endif
510A c     *in80         ifeq      *off
510A c     $pcmd         andeq     '*CHANGE '
510A c                   move      w1dest        phdest
510A c                   update    phmrec                               79
510A c                   unlock    pohdrm
510A c                   endif
510A c     *in80         ifeq      *on
510A c     $pcmd         andeq     '*CHANGE '
510A c                   z-add     $pwhse        phmwh
510A c                   move      w1po          phmpo
510A c                   move      w1dest        phdest
510A c                   write     phmrec                               79
510A c                   unlock    pohdrm
510A c                   endif
510BAC* ELSE IT'S NOT PACKERS
510bac                   else
510bac     $pcmd         ifeq      '*ADD    '
510bac                   z-add     $pwhse        phmwh
510bac                   move      w1po          phmpo
510bac                   move      w1shpr        phmm5
510bac                   write     phmrec                               79
510bac                   unlock    pohdrm
510bac                   endif
510bac     *in80         ifeq      *off
510bac     $pcmd         andeq     '*CHANGE '
510bac                   move      w1shpr        phmm5
510bac                   update    phmrec                               79
510bac                   unlock    pohdrm
510bac                   endif
510bac     *in80         ifeq      *on
510bac     $pcmd         andeq     '*CHANGE '
510bac                   z-add     $pwhse        phmwh
510bac                   move      w1po          phmpo
510bac                   move      w1shpr        phmm5
510bac                   write     phmrec                               79
510bac                   unlock    pohdrm
510A c                   endif
510cac     fileky        setll     pospo
510cac     fileky        reade     pospo                                  81
510cac     *in81         doweq     *off
510cac     filek2        chain     pohdrm                             81
510cac     *in81         ifeq      *off
510cac                   move      w1shpr        phmm5
510cac                   update    phmrec                               79
510cac                   else
510cac                   z-add     $pwhse        phmwh
510cac                   move      pupo          phmpo
510cac                   move      w1shpr        phmm5
510cac                   write     phmrec                               79
510cac                   endif
510cac     fileky        reade     pospo                                  81
510cac                   enddo
510A c                   endif
510A c     *in79         ifeq      *on
510A c                   move      *on           error
510A c                   exsr      zm72
510A c                   goto      endupd
510A c                   end
510A  *
     C*
     C*   Move key values to parameters
     C*
510A c                   unlock    pohdrm
     c                   move      phpo          $ppo
     c     endupd        endsr
     C*
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
**
Order
Only numbers allowed                              16
