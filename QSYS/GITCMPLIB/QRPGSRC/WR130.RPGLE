      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave #203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  WR130     Repack Item Work Order Entry List
     *  August 17, 2010
     *  Jeffrey Jahnke
     *
     *  Revisions
     *
650aA*    04/03/13  KDE  6.50a
     *      - Moved creation of Repack Slot to CRTWRKORD with
     *        Repack changes
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position cursor
     *  21 - 29   Field input error (Reverse Display)
     *  79        Chain indicator
     *  90        Protect input fields for delete display
     *  91        Protect "Position to" Field #1
     *  92        Protect "Position to" Field #2
     *  97        Alwats ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fwr130fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(vw3sfl:recno)
     F                                     sfile(msgrec:msgk)
     Fpiritem6  if   e           k disk
     F                                     rename(itrec:record)
     Fwarehs    if   e           k disk
     Fitemdsc   if   e           k disk
     Foptions   if   e           k disk
     Frpkdemd   uf a e           k disk
     Fitemqty   if   e           k disk
     Fkitcomp1  if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             50    dim(1) ctdata perrcd(1)
     D zopt            s              2    dim(20) ctdata perrcd(20)
     D optln           s             75    dim(1) ctdata perrcd(1)
     D cmdln           s             79    dim(4) ctdata perrcd(1)
     *----------------------------------------------------------------
     *
      /copy qcopysrc,id#royal
     D @getcl          c                   const('GETCLIENT')

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#PRTYRPL

     D saveVer#        s                   like($slver#)

     D $prtky          ds
     D  $len50                 1     50
     D  $pcmd                  1      8

     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
     D* $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $pitem                22     36
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
409 A*
409 AD  $lwhd                 22     26
500cAD  $ldsp                 27     38
500cAD  $litm                 39     53
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
409 A*----------------------------------------------------------------
409 A*  *PICK  -  Picking options
409 A*----------------------------------------------------------------
409 A*
409 A* Fields
409 A*
409 A*    OPNXTP  -  Next pallet number.
409 A*    OPBPCK  -  Bulk pick definition.
409 A*    OPPCUB  -  Maximum cube for PIR.
409 A*    OPFPAL  -  Pallets on fixed fork lift.
409 A*    OPFCUB  -  Maximum cube per fixed pallet.
409 A*    OPFSTP  -  Maximum stops per fixed pallet.
409 A*    OPINCL  -  Include PIR in fixed cube.
409 A*    OPSRCH  -  Number of previous pallets to search for space.
409 A*    OPFBLD  -  Fixed pallet building method.
409 A*                1 = By piece without concern for splitting stop.
409 A*                2 = By stop without splitting stop between plts.
409 A*    OPPBRK  -  Break pallets by aisle (Y,N).
409 A*    OPMPUT  -  Manual Put away (Y,N).
409 A*
409 A* Data structure
409 A*
409 AD opddta          ds
409 AD  opnxtp                 1      7  0 inz(0)
409 AD  oppcub                10     14  2 inz(0)
409 AD  opfpal                15     15  0 inz(0)
409 AD  opfcub                16     20  2 inz(0)
409 AD  opincl                22     22
409 AD  opsrch                23     24  0 inz(0)
409 AD  opfstp                25     26  0 inz(0)
409 AD  opfbld                27     27  0 inz(0)
409 AD  opbpck                28     30  0 inz(0)
409 AD  oppbrk                31     33
409 AD  opmput                34     34
409 AD  opdend               117    117
409 A*
510aA*----------------------------------------------------------------
510aA*  *TRACKSP  -  Track slot position options
510aA*----------------------------------------------------------------
510aA*
510aA* Fields
510aA*
510aA*    OPSPTR  -  Track slot pallet position (Y/N)
510aA*    OPMRG   -  Putaway merge option
510aA*               1 = Only ask for pallet position.
510aA*               2 = Direct user step by step.
510aA*    OPRTN   -  Return pallet option
510aA*               1 = Assume user returns pallets in LOFI order.
510aA*               2 = Direct user step by step.
510aA*
510aA* Data structure
510aA*
510aAD opdata          ds
510aAD  opsptr                 1      1
510aAD  opmrg                  2      2
510aAD  oprtn                  3      3
510aAD  optend               117    117

     *----------------------------------------------------------------
     *  *REPLEN  -  Replenishment options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPRPLB  -  Replenishment basis (*AVGQTY, *ORDQTY).
     *    OPOQRP  -  Order qty replenishment (Y/N).
     *
     * Data structure
     *
     D opdat2          ds
     D  oprplb                 1      8
     D  opoqrp                 9      9
     D  opten2               117    117

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

     D                 ds
     D  wopqndec               1      5  2
     D  dec                    4      5  0

     D Today                           d   Datfmt(*ISO) Inz
     D  TodayYear                     4    overlay(Today)
     D  TodayMonth                    2    overlay(Today:6)
     D  TodayDay                      2    overlay(Today:9)
     *----------------------------------------------------------------
     * Work Variables
     *----------------------------------------------------------------
     D currstamp       s               z
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D done            s              1
     D e               s              2  0
     D enter           s              5  0
     D entflg          s              1
     D error           s              1
     D fmdsp           s             12
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D ocode           s              8
     D opflg           s              1
     D pgctr           s              1  0
     D pgflg           s              1
     D pndflg          s              1
     D posrec          s              4  0
     D r               s              2  0
     D prcrec          s              2  0
     D reccnt          s              4  0
     D reccnt3         s              4  0
     D redspl          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D sctr            s              2  0
     D stop            s              1
     D uxflag          s              1
     D todsp           s             12
     D warn            s              1
     D maxvw           s              1  0
     D xctr            s              2  0
     D #bitem          s             15
     D view            s              1  0
     D viewall         s              1  0
     D v               s              2  0
     D x               s              3  0
     D goodrecord      s              1
     D prqtyn          s              7  0
     D rhwhse          s              3  0 inz(0)
     D option          s              2
     D wopqn           s              3  0
     D recno           s              4  0
     D $lwhse30        s              3  0
     D $lqtyn50        s              5  0
     D $lord70         s              7  0
     D $lref           s             15
     D $lmsg60         s             60
     D $lcmd10         s             10
     D MDY             s               d   DatFmt(*MDY)
     D ISO             s               d   DatFmt(*ISO)
     D @CurrTimestmp   s               z   inz(*sys)
     D $lby            s              1
     D $lndt           s              8  0
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
     C                   parm                    $prtky
     C                   parm                    $rtncd            8
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
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
     C                   select
     *
     C                   when      nxtscr = '01 '
     C                   exsr      sfldsp
     C                   read      dspsfc                                 50
     C                   Eval      posnbr = @CSRPO
     *
     C                   when      nxtscr = '02 '
     C***                exfmt     screen2
     C                   when      nxtscr = '03 '
     C                   exsr      sfldsp3
     C                   read      vw3sfc                                 50
     *
     C                   endsl
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       101112
     C                   setoff                                       161718
     C                   setoff                                       212223
     C                   setoff                                       36
     C                   setoff                                       98
     C                   eval      warn = *off
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
     C                   eval      nxtscr = '01 '
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft1
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   exsr      zzget1
     C                   exsr      zzfil1
     C                   endif
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft2
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   exsr      zzfil2
     C                   endif
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft3
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   exsr      zzget3
     C                   exsr      zzfil3
     C                   endif
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
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke

     C     *loval        setll     rpkdemd
     C                   dou       %eof(rpkdemd)
     C                   read      rpkdemd
     C                   if        not %eof(rpkdemd)
     C                   select
     C                   when      drrpkd <> *zeros
     C                   eval      drrpkb = 0
     C                   update    drrec
     C                   when      drrpkd = *zeros
     C                   delete    drrec
     C                   endsl
     C                   endif
     C                   enddo

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
     C     error         cabeq     *on           endsc1
     C     redspl        cabeq     *on           endsc1
     C                   exsr      zzupd1
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
      ***                exsr      scr02i
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = '01 '
     C                   eval      $prtn = '*CANCEL '
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
     C                   exsr      zzupd2
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*OK     '
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = '01 '
     C                   eval      $prtn = '*CANCEL '
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
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C     redspl        cabeq     *on           endsc3
     C                   exsr      zzupd3
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Everything went fine so get out of program.
     *
     C                   exsr      scr01i
     C     endsc3        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
510bA*
510bA* Get client id.
510bA*
510bAC                   call      @getcl
510bAC                   parm                    client           10
510bA*
     *
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125

     C                   move      *year         TodayYear
     C                   move      *month        TodayMonth
     C                   move      *day          TodayDay

     C                   move      *year         TodayYear
     C                   move      *month        TodayMonth
     C                   move      *day          TodayDay
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     C                   add       1             reccnt

     C     fileky        chain     rpkdemd
     C                   if        not %found(rpkdemd)
     C                   eval      drrpkd = 0
     C                   eval      drrpkb = 0
     C                   endif

     *    Get repack quantity

     C                   eval      w1whsq = 0
     C     idkey         chain     itemqty
     C                   if        %found(itemqty)
     C                   eval      w1whsq = iqstk1 - iqalc1 - iqhld1
     C                   if        w1whsq > 999
     C                   eval      w1whsq = 999
     C                   endif
     C                   endif

     *    Get warehouse quantity

     C                   exsr      zzbase

     C                   eval      w2whsq = 0
     C     idkey2        chain     itemqty
     C                   if        %found(itemqty)
     C                   eval      w2whsq = iqstk1 - iqalc1 - iqhld1
     C                   if        w2whsq > 999
     C                   eval      w2whsq = 999
     C                   endif
     C                   endif

     C                   eval      w1rpkd = drrpkd
     C                   eval      w1build = w1rpkd - w1whsq

     C                   if        drrpkb <> *zeros
     C                   eval      w1build = drrpkb
     C                   endif

     C                   if        w1build < 0
     C                             or not %found(rpkdemd)
     C                   eval      w1build = 0
     C                   eval      w2build = 0
     C                   endif
     C                   eval      h1build = w1build
     C                   eval      w2build = w1build
     C                   eval      h1whdp  = itwhdp

     * add up repack qty
     C                   exsr      accumrplqty

     C                   select
     C                   when      w1build <> 0
     C                   eval      w2need = prqtyn
     C                   when      w1build =  0
     C                   eval      w2need = 0
     C                   endsl

     C                   eval      recno = reccnt
     C                   write     dspsfl

     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      *in26 = *off
     C                   eval      *in27 = *on
     C                   write     dspsfc
     C                   write     vw2sfc
     C                   eval      *in27 = *off
     C                   eval      *in28 = *off
     C                   eval      reccnt = 0
     C                   eval      recno = 0
510gAC                   eval      posnbr = 1
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR3  Clear display subfile
     *
     C     sflclr3       begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      *in36 = *off
     C                   eval      *in37 = *on
     C                   write     vw3sfl
     C                   write     vw3sfc
     C                   eval      *in37 = *off
     C                   eval      *in38 = *off
     C                   eval      reccnt3 = 0
     C                   eval      recno = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     C                   write     cmdrec
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   if        reccnt > 0
     C                   eval      *in26 = *on
     C                   endif
     C                   eval      recno = posrec
     C                   write     dspsfc
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP3  Display subfile
     *
     C     sfldsp3       begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     C                   write     cmddel
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   if        reccnt3 > 0
     C                   eval      *in36 = *on
     C                   endif
     C                   write     vw3sfc
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
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   eval      sclear = *on
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *    ZM0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
500c *----------------------------------------------------------------
500c *      0108  Invalid Option.
500c *
500c C     zm0108        begsr
500c C                   eval      #msgid = 'PIR0108'
500c C                   eval      #msgtp = '*DIAG  '
500c C                   movea     errmsg        $md(1)
500c C                   exsr      zmpmsg
500c C                   endsr
     *----------------------------------------------------------------
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7871  Error in writing a record.
     *
     C     zm7871        begsr
     C                   eval      #msgid = 'PIR7871'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7872  Error in updating a record.
     *
     C     zm7872        begsr
     C                   eval      #msgid = 'PIR7872'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IV21201  Quantity entered without item number.
     *
     C     zm1201        begsr
     C                   eval      #msgid = 'IV21201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
414cA*----------------------------------------------------------------
414cA*     IV21202  Can't change item, pending quantity exists.
414cA*
414cAC     zm1202        begsr
414cAC                   eval      #msgid = 'IV21202'
414cAC                   eval      #msgtp = '*DIAG  '
414cAC                   movea     errmsg        $md(1)
414cAC                   exsr      zmpmsg
414cAC                   endsr
500aA*----------------------------------------------------------------
500aA*     IV21204  Pallet position required.
500aA*
500aAC     zm1204        begsr
500aAC                   eval      #msgid = 'IV21204'
500aAC                   eval      #msgtp = '*DIAG  '
500aAC                   movea     errmsg        $md(1)
500aAC                   exsr      zmpmsg
500aAC                   endsr
500aA*----------------------------------------------------------------
500aA*     IV21305  Item not catch weight item.
500aA*
500aAC     zm1305        begsr
500aAC                   eval      #msgid = 'IV21305'
500aAC                   eval      #msgtp = '*DIAG  '
500aAC                   movea     errmsg        $md(1)
500aAC                   exsr      zmpmsg
500aAC                   endsr
500bA*----------------------------------------------------------------
500bA*     IT25203  Slot and item department do not match.
500bA*
500bAC     zm5203        begsr
500bAC                   eval      #msgid = 'IT25203'
500bAC                   eval      #msgtp = '*DIAG  '
500bAC                   movea     errmsg        $md(1)
500bAC                   exsr      zmpmsg
500bAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  When change ....
     *
     C                   if        $pcmd = '*CHANGE '
     C                   endif
     *
     *  When adding ....
     *
     C                   if        $pcmd = '*ADD    '
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
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
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
     *  Test for F8 - Breakdown qty entry toggel
     *
     C                   if        *inkh
     C                   if        viewall = maxvw
     C                   eval      viewall = 1
     C                   else
     C                   eval      viewall = viewall + 1
     C                   endif
     C                   eval      v = viewall * 2
     C                   eval      cmdln2 = cmdln(v)
     C                   eval      v = v - 1
     C                   eval      cmdln1 = cmdln(v)
     *
     C                   exsr      scr01i
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     *
     *  TEST FOR CMD16 - Create repack work orders
     *
     C                   if        *inkq
     C                   exsr      scr03i
     C                   endif

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
     *      F10 - Enter entire sheet
     *
     C                   if        *inkj
     C                   eval      entflg = *on
     C                   else
     C                   eval      entflg = *off
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 1.
     *
     C     zzcmd3        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   exsr      sflclr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT3   Get default values for add.
     *
     C     zzdft3        begsr
     C                   exsr      sflclr3
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   exsr      sflclr
     *
     C     $pwhse        setll     piritem6
     C                   dou       %eof(piritem6)
     C     $pwhse        reade     piritem6
     C                   if        not %eof(piritem6)

     C                   if        itwhse <> $pwhse
     C                   iter
     C                   endif

     C     fileky        chain     rpkdemd
     C                   if        %found(rpkdemd)
     C                             and drstat <> '0'
     C                   iter
     C                   endif
     C                   select
     C                   when      viewall = 2
     * select all
     C                   when      not %found(rpkdemd)
     C                   iter
     C                   when      %found(rpkdemd)
     C                             and drrpkd = 0
     C                             and drrpkb = 0
     C                   iter
     C                   endsl
     C                   exsr      sfladd
     C                   endif
     C                   enddo
     *
     C                   eval      posrec = 1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     C                   exsr      sflclr3
     *
     C     1             do        reccnt        x
     C     x             chain     dspsfl
     C                   if        %found

     C                   if        w1build <> *zeros
     C                   add       1             reccnt3
     C                   eval      h3bitem = h1bitem
     C                   eval      h3whdp = h1whdp
     C                   eval      w3item = ititem
     C                   eval      w3desc = itdesc
     C                   eval      w3rpkd = w1rpkd
     C                   eval      w3whsq = w1whsq
     C                   eval      w3build = w1build
     C                   eval      recno = reccnt3
     C                   write     vw3sfl
     C                   endif
     C                   endif
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     C     zzget2        begsr
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET3   Get record(s) for screen 3.
     *
     C     zzget3        begsr
     C     endgt3        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    itwhse
     C                   kfld                    ititem
     *
     *     EXTENDED ITEM DESCRIPTION
     *
     C     idkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    ititem
     *
     C     idkey2        klist
     C                   kfld                    $pwhse
     C                   kfld                    #bitem
     *
     C     kycomp2       klist
     C                   kfld                    $pwhse
     C                   kfld                    #bitem
     C                   kfld                    ititem
     *
     *     OPTIONS
     *
     C     opkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    ocode
     *
     C     rpkeya        klist
     C                   kfld                    $pwhse
     C                   kfld                    ititem
     *
     C     rpkeyb        klist
     C                   kfld                    $pwhse
     C                   kfld                    w3item
     *----------------------------------------------------------------
     *  Setup option and command display lines.
     *
     C                   eval      cmdln1 = cmdln(1)
     C                   eval      cmdln2 = cmdln(2)
     C                   eval      view = 1
     C                   eval      viewall = 1
     C                   eval      maxvw = 2
     *
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Get warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     rhwhse        parm      0             #whse             3 0

     C                   eval      $pwhse = #whse
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif

     C                   eval      *in56 = *on

     C                   exsr      zzxopt
     C                   exsr      scr01i

     C     endnz2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPSB   Update subfile records.
     *
     C     zzupsb        begsr
     *
     *   Loop through changed subfile records and update.
     *
     C                   eval      *in77 = *off
     C                   dou       *in77
     C                   readc     dspsfl
     C                   if        not *in77
     C                   update    dspsfl
     C                   endif
     C                   enddo
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUSUB   Update using subfile records.
     *
     C     zzusub        begsr
     C                   eval      error = *off
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     *
     C     1             do        reccnt        x
     C     x             chain     dspsfl
     C                   if        %found
510gAC                   if        ititem = ptinp1
510gAC                   eval      posnbr = x
510gAC                   endif
     C                   if        w1build <> h1build
     C                   eval      h1build = w1build
     C     rpkeya        chain     rpkdemd
     C                   select
     C                   when      %found(rpkdemd)
     C                   eval      drrpkb = w1build
     C                   update    drrec
     C                   when      not %found(rpkdemd)
     C                   eval      drwhse = $pwhse
     C                   eval      dritem = ititem
     C                   eval      drrpkd = *zeros
     C                   time                    currstamp
     C                   eval      dradts = currstamp
     C                   eval      drstat = '0'
     C                   eval      drby   = #user
     C                   eval      drcdts = currstamp
     C                   eval      drrpkb = w1build
     C                   write     drrec
     C                   endsl
     C                   endif
     C                   update    dspsfl
     C                   endif
     C                   enddo
     *
     C                   eval      ptinp1 = *blanks
     *
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
     C     zzupd2        begsr
     *
     C     endup2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update record.
     *
     C     zzupd3        begsr

     C     1             do        reccnt3       x
     C     x             chain     vw3sfl
     C                   if        %found

     C                   exsr      zzcrtwrkord
     C                   if        $lrtn = '*OK     '
     C     rpkeyb        chain     rpkdemd
     C                   if        %found(rpkdemd)
     C                   eval      drstat = '4'
     C                   eval      drby = #user
     C                   time                    currstamp
     C                   eval      drcdts = currstamp
     C                   update    drrec
     C                   endif
650aDC*                  exsr      zzcrtprtyrepl
     C                   endif

     C                   endif
     C                   enddo

     C     endup3        endsr
     *----------------------------------------------------------------
     *
     *  ZZBASE   Get base item
     *
     C     zzbase        begsr
     *
     C                   call      'GETBASE'
     C                   parm      $pwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
     C                   parm      ' '           #bitem
     C                   parm                    #bityp            1
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum1             2
     C                   parm                    #bum2             2
     C                   parm                    #bumq2            3 0
     C                   parm                    #bum3             2
     C                   parm                    #bumq3            3 0
     C                   parm      ' '           #bcitm           15
     C                   parm                    #bctyp            1
     C                   parm                    #bcdsc           30
     C                   parm                    #bcpds           15
     C                   parm                    #bcwdp            5
     C                   parm                    #bcstp            1
     C                   parm                    #bcum1            2
     C                   parm                    #bcum2            2
     C                   parm                    #bcuq2            3 0
     C                   parm                    #bcum3            2
     C                   parm                    #bcuq3            3 0
     C                   parm                    #brtn             8
     *
     C                   if        #bitem <> *blanks
     C                   eval      h1bitem = #bitem
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *  accumrplqty   accumulate repack order quantity
     *----------------------------------------------------------------

     C     accumrplqty   begsr

     * retrieve repack item

     C                   eval      GOODRECORD = *off
     C                   eval      prqtyn = *zeros
     C     kycomp2       chain     kitcomp1
     C                   if        %found(kitcomp1)
     C                   eval      goodrecord = *on
     C                   endif

     C                   select
     C                   when      kcqty1 > *zeros
     C                   eval      prqtyn = prqtyn + (w1rpkd * kcqty1)

     C                   when      kcqty2 > *zeros
     C                             and #bumq2 <> *zeros
     C                   eval(h)   wopqndec= (w1rpkd * kcqty2)
     C                                       / #bumq2
     C                   eval      wopqn = wopqndec
     C                   if        dec >= 01
     C                   eval      wopqn   = wopqn + 1
     C                   endif
     C                   eval      prqtyn = prqtyn + wopqn

     C                   when      kcqty3 > *zeros
     C                   eval(h)   wopqndec= (w1rpkd * kcqty3)
     C                                       / (#bumq2
     C                                           * #bumq3)
     C                   eval      wopqn = wopqndec
     C                   if        dec >= 01
     C                   eval      wopqn   = wopqn + 1
     C                   endif
     C                   eval      prqtyn = prqtyn + wopqn
     C                   endsl

     C                   endsr
     *----------------------------------------------------------------
     *
     *  zzcrtwrkord     create repack work order
     *
     C     zzcrtwrkord   begsr

     C                   move      today         iso
     C                   move      iso           $lndt
     C                   eval      $lord70 = 0

     C                   call      'CRTWRKORD'
     C                   parm      '*CRTWRKORD'  $lcmd10
     C                   parm      itwhse        $lwhse30
     C                   parm      w3item        $litem
     C                   parm      w3build       $lqtyn50
     C                   parm      'M'           $lby
     C                   parm      ' '           $lref
     C                   parm      ' '           $lrtn
     C                   parm      ' '           $lmsg60
     C                   parm                    $lord70
     C                   parm                    $lndt

     C                   if        $lrtn = '*ERROR'
     C                   eval      error = *on
     C                   eval      errmsg = $lmsg60
     C                   exsr      zm0105
     C                   else
     C                   eval      $lrtn = '*OK   '
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  clr$prtyrpl  Clear $prtyrpl data structure fields
     *----------------------------------------------------------------
     C     clr$prtyrpl   begsr
     C                   eval      savever# = $prver#
     C                   clear                   $prtyrpl
     C                   eval      $prver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  zzcrtprtyrepl   create repack priorit replenishment
     *
650aDC*    zzcrtprtyrepl begsr

     * Create Priority Replenishment to move parent qty to repack area

650aDC*                  exsr      clr$prtyrpl

     *    Retrieve FS-WMS replenishment options.

650aDC*                  eval      ocode = '*REPLEN '
650aDC*    opkey         chain     options
650aDC*                  select
650aDC*                  when      not %found(options)
650aDC*                  eval      opoqrp = 'N'
650aDC*                  when      %found(options)
650aDC*                  eval      opdat2 = opdata
650aDC*                  endsl
     *
650aDC*                  move      $pwhse        $twhse            3
650aDC*                  call      'LT110E'
650aDC*                  parm                    $twhse
650aDC*                  parm      h3whdp        $twhdp            5
650aDC*                  parm      oprplb        $tplb             8
650aDC*                  parm      h3bitem       $tpitm           15
650aDC*                  parm                    $trtn             8

650aDC*                  endsr
     *----------------------------------------------------------------
     *
     *  ZZXOPT   Get use extended description option
     *
     C     zzxopt        begsr
     *
     *   Get extended description option.
     C                   eval      prcrec = 10
     C                   eval      uxflag = *off
     C                   eval      ocode = '*ITEMMNT'
     *
     C     opkey         chain     options                            79
     C                   if        not *in79
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Item Number
**  ZOPT - Valid options

**  OPTLN - Option display line

**  CMDLN - Command display line
F3=Exit  F5=Refresh  F8=All Repack Items  F12=Cancel
F16=Create Work Orders
F3=Exit  F5=Refresh  F8=Repack Items W/Demand  F12=Cancel
F16=Create Work Orders
