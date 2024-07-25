      /copy *libl/qcopysrc,hspecs
500 A*----------------------------------------------------------------
500 A*  Multilingual Verision
500 A*  Every screen and message has a corresponding Spanish version.
500 A*  Any changes must be made to both languages.
500 A*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0618
     *----------------------------------------------------------------
     *
     *  VS820     Virtual Slot Lookup - Display - 8x40 RF device
     *  19 September 2000
     *  Max Blacknik
     *
     *    NOTE: This is not a normal 900 list display program.
     *          The 1st record is from the slot file(physical slot)
     *          The balance of records are from vslot(virtual slot)
     *          This program was copied from VS810.  A second view
     *          was added to accomodate the smaller format.
     *
     *  Revisions
     *
416 A*    11/12/02  MLB  4.16
     *      - Fix: Revised ZZFGTP to setoff PSFLAG when
     *        beginning of file is reached. Changed
     *        record not found ind. for SLOT2 to 76 from 79.
     *
417 A*   06/14/04  DAS  4.17
     *     - Revised to display desc/pack instead of pack/desc
     *       for Packers.
     *
500 A*    06/07/06  JCJ  5.00
     *      - Added Multilingual logic.
510aA*    10/20/07  LMC  5.10a
     *      - Added third view, to display the pack/desc screen
     *
520 A*    07/01/09  JCJ  5.20
     *      - Fix: Unlock file WORKOPT before leaving program.
     *
600 A*    04/28/08  DAS  6.00  P#00045
     *      - License Tracking
     *
600aA*    04/28/08  DAS  6.00a P#00045
     *      - Enh: Converted to ILE.
     *      - Enh: Added slot position to detail line.
     *      - Enh: Added DRI routines to get Slot and Item info.
     *      - These were 500/500a changes in Jordano's version.
     *
600bA*    01/24/09  DAS  6.00
     *      - Added $item2 and $slot2.
610aA*    11/03/10  RH   6.10a
     *      - Enh: Remove positon from screen, no longer used.
640aA*    03/21/11  RH   6.40a
     *      - Enh: Revised to not display 'Z' status slots.
640bA*    08/24/12  RH   6.40b
     *      - Enh: Add license to display
650a *    04/24/13  GJA  6.50a
     *      - Fix: Put F3 back on screen - screen reformat VS82002
     *
720 A*    10/08/18  MLB  7.20
     *      - Fix: Changes to Spanish screen formats.
     *        Update pgm to reference VS82003.
     F*
740aAF*    06/06/20  DAS  7.40a
     F*      - Added 16-Line screens
     F*      - Change dispaly file to VS82004
     *
     *----------------------------------------------------------------
     *  Custom Revisions - Dairyland
     *
DRYaA*    02/23/11  MLB  DRYa
     *      - Revised to not display 'Z' status slots.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: TPC
     *
TPC A*    04/10/07  RH   TPC
     *      - Revised program to default to item/location view 2.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position cursor
     *  21 - 29   Field input error (Reverse display)
     *  79        Chain indicator
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  85        Manually set subfile change flag (SFLNXTCHG)
     *  90        Protect input fields for delete display
     *  91        Protect "POSITION TO" field #1
     *  97        Always ON (Used for SFLEND keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
740aMFvs82004   cf   e             workstn
740aDF*s82003   cf   e             workstn
720 DF**vs82002   cf   e             workstn
650aAF**vs82001   cf   e             workstn
640bAF*s820fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(pacsfl:recno)
     F                                     sfile(vw2sfl:recno)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(dspsflsp:recno)
     F                                     sfile(pacsflsp:recno)
     F                                     sfile(vw2sflsp:recno)
740aAF                                     sfile(d16sfl:recno)
740aAF                                     sfile(p16sfl:recno)
740aAF                                     sfile(v16sfl:recno)
740aAF                                     sfile(m16rec:msgk)
740aAF                                     sfile(d16sflsp:recno)
740aAF                                     sfile(p16sflsp:recno)
740aAF                                     sfile(v16sflsp:recno)
     Fworkopt   uf a e           k disk
     Fvslot2    if   e           k disk
     F                                     rename(vsrec:record)
600aDF*lot2     if   e           k disk
600aDF*iritem   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a10             s              1    dim(10)
     D a75             s              1    dim(75)
     D fkey            s             50    dim(10)
     D ukey            s             50    dim(10)
     D optlst          s              2    dim(24)
     D cmdlst          s              2    dim(24)
     D desc            s             20    dim(1) ctdata perrcd(1)
     D cmd             s             75    dim(1) ctdata perrcd(1)
500 AD descsp          s             20    dim(1) ctdata perrcd(1)
500 AD cmdsp           s             75    dim(1) ctdata perrcd(1)
417 A*----------------------------------------------------------------
417 A*  Customer id
417 A*
      /COPY QCOPYSRC,ID#PACKERS
DRYaA /copy qcopysrc,id#dairyla
TPC A /COPY QCOPYSRC,ID#TPC

600aA*----------------------------------------------------------------
600aA*  DRI parameters
600aA*----------------------------------------------------------------
600aA
600aA /COPY *libl/qcopysrc,C#DRIPARMS
600aA
600aA*----------------------------------------------------------------
600aA*  Data Formats
600aA*----------------------------------------------------------------
600aA
600aA /COPY *libl/qcopysrc,C#ITEM
600aA /COPY *libl/qcopysrc,C#SLOT
600aAD saveVer#        s                   like($slver#)
600aAD save$slot       s                   like($slot)

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
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     D  $ldisp                27     38
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  vswhse                 1      3  0 inz(0)
     D  vswhdp                 4      8
     D  vspdis                 9     20
     *
     D                 ds
     D  dsukey                 1     50
     D  ukwhse                 1      3  0 inz(0)
     D  ukwhdp                 4      8
     D  ukdisp                 9     20
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0 inz(0)
     D  $cvd8o                39     46  0 inz(0)
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
     *----------------------------------------------------------------
     *  Data structure for PgUp/Dn routines
     *
     D $postn          ds
     D  $pocmd                 1      8
     D  $poprg                 9     18
     D  $pofky                19     68
     D  $pouky                69    118
     D  $podsc               119    307
     D                                     DIM(3)
     D  $popt1               308    322
     D  $popt2               323    335
     D  $portn               336    343
     D  $poerm               344    403
     D  $pomsg               336    339
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
     D                 ds
     D  $ec                    1      2p 0
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
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
600aAD  #pgm             *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Variables
     *
     D $msgf           s             10
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D bot             s              1
     D cancel          s              1
600aAD chk4err         s               n
     D clear           s              5  0
     D comand          s              5  0
     D dsplyd          s              2  0
     D e               s              2  0
     D enter           s              5  0
500aMD error           s               n
     D forceb          s              1
     D gobsdk          s              2  0
     D help            s              5  0
740aAD maxval          s              3  0
     D maxvw           s              1  0
     D moreln          s              7
     D msgk            s              4  0
     D nomore          s              1
     D nxtscr          s              3
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
     D psflag          s              1
     D ptinp1          s             12
     D recno           s              4  0
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D top             s              1
     D view            s              1  0
     D warn            s              1
     D x               s              3  0
     D y               s              3  0
600aAD zmsflag         s               n
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $LCMD   *SELECT  - Selection lookup.
     *      $LPRG   Program to send messages back to.
     *      $LUKY   Contains key to be verified.
     *
     *    Returned Parameters
     *      $LUKY   Contains first key selected.
     *      $LRTN   blank    - No problem encountered.
     *              *SELECT  - Slot selected from list.
     *              *CANCEL  - CMD12 was entered
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *              -or- Description of verified code.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $lparm
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      $lrtn = *blanks
     C                   exsr      zzinz2
     C                   exsr      clrsch
     C                   exsr      scr01i
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
520 AC                   unlock    workopt
600aAC                   exsr      zzzdriclose
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
     *   Set OFF command key indicators
     *
     C                   setoff                                       kckekf
     C                   setoff                                       kl
     *
     *   Overlay screen with title
     *
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   write     titlesp
500 AC                   other
     C                   write     title
500 AC                   endsl
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *   Overlay screen with subfile screen
     *
     C                   select
     C                   when      nxtscr = '01 '
     C                   exsr      sfldsp
     C                   endsl
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       2021
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cancel = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
740aA
740aA*  8 line - Displays
740aA
740aAC                   if        #lline <> '16'
740aA
     C                   select
     C                   when      view = 1
417 AC                   select
500 D**         CLIENT    WHEQ PACKER
500 AC                   when      e$lng = 'SP'
500 AC                   read      pacsfcsp                               50
500 AC                   when      e$lng = 'EN'
417 AC                   read      pacsfc                                 50
417 AC                   other
     C                   read      dspsfc                                 50
417 AC                   endsl
     C                   when      view = 2  and
500 AC                             e$lng = 'SP'
500 AC                   read      vw2sfcsp                               50
500 AC                   when      view = 2  and
500 AC                             e$lng = 'EN'
     C                   read      vw2sfc                                 50
510aAC                   when      view = 3  and
510aAC                             e$lng = 'SP'
510aAC                   read      dspsfcsp                               50
510aAC                   when      view = 3  and
510aAC                             e$lng = 'EN'
510aAC                   read      dspsfc                                 50
     C                   endsl
740aA
740aA*  16 line - Displays
740aA
740aAC                   else
740aA
740aAC                   select
740aAC                   when      view = 1
740aAC                   select
740aAC                   when      e$lng = 'SP'
740aAC                   read      p16sfcsp                               50
740aAC                   when      e$lng = 'EN'
740aAC                   read      p16sfc                                 50
740aAC                   other
740aAC                   read      d16sfc                                 50
740aAC                   endsl
740aAC                   when      view = 2  and
740aAC                             e$lng = 'SP'
740aAC                   read      v16sfcsp                               50
740aAC                   when      view = 2  and
740aAC                             e$lng = 'EN'
740aAC                   read      v16sfc                                 50
740aAC                   when      view = 3  and
740aAC                             e$lng = 'SP'
740aAC                   read      d16sfcsp                               50
740aAC                   when      view = 3  and
740aAC                             e$lng = 'EN'
740aAC                   read      d16sfc                                 50
740aAC                   endsl
740aA
740aAC                   endif
     *
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
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   write     clr0306
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     C     status        caseq     rollup        roll01
     C     status        caseq     rolldn        roll01
     C     status        caseq     comand        cmd01
     C                   cas                     ent01
     C                   endcs
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
     *  Define keys
     *
     *     WORKOPT  (Unique key)
     *
     C     wkounq        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     C                   kfld                    wkokyf
     C                   kfld                    wkokyu
     *
     *     WORKOPT  (Partial key)
     *
     C     wkoprt        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     *
     *     WORKOPT  (Save key for top record on delete display)
     *
     C     deltop        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     C                   kfld                    $wkof
     C                   kfld                    $wkou
500 A*
500 A*   Get employee options.
500 A*
500 AC                   call      'GETUSER'
500 AC                   parm      #user         e$code           10
500 AC                   parm                    e$whse            3 0
500 AC                   parm                    e$emp#            5 0
500 AC                   parm                    e$fnam           15
500 AC                   parm                    e$init            1
500 AC                   parm                    e$lnam           20
500 AC                   parm                    e$whdp            5
500 AC                   parm                    e$styp            1
500 AC                   parm                    e$shft            6
500 AC                   parm                    e$crew            6
500 AC                   parm                    e$nhrs            3 1
500 AC                   parm                    e$rtn             8
500 AC                   parm                    e$bpu             1
500 AC                   parm                    e$lng             2
500 AC                   if        e$rtn <> '*OK'
500 AC                   eval      e$lng = 'EN'
500 AC                   endif
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
     *  Initialize subfile (DSPSFL) record
     *
     C                   eval      recno = 1
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   write     dspsflsp                             79
500 AC                   write     pacsflsp                             79
500 AC                   write     vw2sflsp                             79
740aAC                   write     d16sflsp                             79
740aAC                   write     p16sflsp                             79
740aAC                   write     v16sflsp                             79
500 AC                   other
     C                   write     dspsfl                               79
417 AC                   write     pacsfl                               79
     C                   write     vw2sfl                               79
740aAC                   write     d16sfl                               79
740aAC                   write     p16sfl                               79
740aAC                   write     v16sfl                               79
500 AC                   endsl
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CLRSCH   Clear everything out of work file
     *
     C     clrsch        begsr
     C     wkoprt        setll     workopt
     C     wkoprt        reade     workopt                              7979
     C                   dow       not *in79
     C                   delete    wkorec
     C     wkoprt        reade     workopt                              7979
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CMD01    Screen 1 command key routine
     *
     C     cmd01         begsr
     *
     *  TEST FOR CMD3 - EXIT
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $lrtn = '*EXIT   '
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD08 - Next view
     *
     C                   if        *inkh
     C                   if        view = maxvw
     C                   eval      view = 1
     C                   else
     C                   add       1             view
     C                   endif
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD9 - Goto empty slot lookup.
     *
     C                   if        *inki
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $lrtn = '*SWITCH '
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD12 - CANCEL
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $lrtn = '*CANCEL '
     C                   goto      cmd01e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR CMD5 - REFRESH
     *
     C                   if        *inke
     C                   exsr      clrsch
740aA
740aDC**   1             do        3             x
740aMC     1             do        maxval        x
740aA
740aA*   8 line dispalys                      .
740aA
740aAC                   if        #lline <> '16'
740aA
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC     x             chain     dspsflsp                           79
500 AC                   other
     C     x             chain     dspsfl                             79
500 AC                   endsl
740aA
740aA*   16 line dispalys                      .
740aA
740aAC                   else
740aAC                   select
740aAC                   when      e$lng = 'SP'
740aAC     x             chain     d16sflsp                           79
740aAC                   other
740aAC     x             chain     d16sfl                             79
740aAC                   endsl
740aA
740aAC                   endif
740aA
     C                   if        not *in79
     C                   move      '  '          option
740aA
740aA*   8 line dispalys                      .
740aA
740aAC                   if        #lline <> '16'
740aA
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   update    dspsflsp
500 AC                   other
     C                   update    dspsfl
500 AC                   endsl
740aA
740aA*   16 line dispalys                      .
740aA
740aAC                   else
740aAC                   select
740aAC                   when      e$lng = 'SP'
740aAC                   update    d16sflsp
740aAC                   other
740aAC                   update    d16sfl
740aAC                   endsl
740aA
740aAC                   endif
740aA
     C                   endif
740aA
740aA*   8 line dispalys                      .
740aA
740aAC                   if        #lline <> '16'
740aA
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC     x             chain     pacsflsp                           79
500 AC                   other
417 AC     x             chain     pacsfl                             79
500 AC                   endsl
740aA
740aA*   16 line dispalys                      .
740aA
740aAC                   else
740aAC                   select
740aAC                   when      e$lng = 'SP'
740aAC     x             chain     p16sflsp                           79
740aAC                   other
740aAC     x             chain     p16sfl                             79
740aAC                   endsl
740aA
740aAC                   endif
740aA
417 AC                   if        not *in79
417 AC                   move      '  '          option
740aA
740aA*   8 line dispalys                      .
740aA
740aAC                   if        #lline <> '16'
740aA
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   update    pacsflsp
500 AC                   other
417 AC                   update    pacsfl
500 AC                   endsl
740aA
740aA*   16 line dispalys                      .
740aA
740aAC                   else
740aAC                   select
740aAC                   when      e$lng = 'SP'
740aAC                   update    p16sflsp
740aAC                   other
740aAC                   update    p16sfl
740aAC                   endsl
740aA
740aAC                   endif
740aA
417 AC                   endif
740aA
740aA*   8 line dispalys                      .
740aA
740aAC                   if        #lline <> '16'
740aA
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC     x             chain     vw2sflsp                           79
500 AC                   other
     C     x             chain     vw2sfl                             79
500 AC                   endsl
740aA
740aA*   16 line dispalys                      .
740aA
740aAC                   else
740aAC                   select
740aAC                   when      e$lng = 'SP'
740aAC     x             chain     v16sflsp                           79
740aAC                   other
740aAC     x             chain     v16sfl                             79
740aAC                   endsl
740aA
740aAC                   endif
740aA
     C                   if        not *in79
     C                   move      '  '          option
740aA
740aA*   8 line dispalys                      .
740aA
740aAC                   if        #lline <> '16'
740aA
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   update    vw2sflsp
500 AC                   other
     C                   update    vw2sfl
500 AC                   endsl
740aA
740aA*   16 line dispalys                      .
740aA
740aAC                   else
740aAC                   select
740aAC                   when      e$lng = 'SP'
740aAC                   update    v16sflsp
740aAC                   other
740aAC                   update    v16sfl
740aAC                   endsl
740aA
740aAC                   endif
740aA
     C                   endif
     C                   enddo
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     *
     C                   exsr      savopt
     C     error         cabeq     *on           cmd01e
     *
     *  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     *
     *  TEST FOR CMD10 - MOVE RECORD THAT CUSOR IS ON TO TOP
     *
     C                   if        *inkj
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     MAKE SURE CURSOR IS ON ONE OF THE DISPLAYED RECORDS
     *
     C                   sub       3             row#
     C                   if        row# < 1  or
     C                             row# > dsplyd
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0106
     C                   goto      cmd01e
     C                   endif
     *
     *     REPOSITION RECORD THAT CURSOR IS ON TO THE TOP
     *
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = ukey(row#)
     C                   exsr      fgtway
     *R         CLERR     CABEQ*ON       CMD01E
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD17 - REPOSITION TO TOP OF DISPLAY
     *
     C                   if        *inkr
     C                   eval      pagcmd = '*TOP    '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD18 - REPOSITION TO BOTTOM OF DISPLAY
     *
     C                   if        *inks
     C                   eval      pagcmd = '*BOTTOM '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     C     cmd01e        endsr
     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     C     ent01         begsr
     *
     *  VERIFY AND SAVE OPTIONS
     *
     C                   exsr      savopt
     C     error         cabeq     *on           ent01e
     *
     *  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     *
     C                   eval      repos = *off
     C                   exsr      zzpos
     C                   if        repos = *on
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      ent01e
     C                   endif
     *
     *  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     *
     C                   exsr      optns
     *
     *  IF OPTION WAS NOT TAKEN THEN RETURN LIKE CMD12 WAS ENTERED
     *
     C                   if        otaken = *off
     C                   eval      $lrtn = '*CANCEL '
     C                   else
     C                   eval      $lrtn = '*SELECT '
     C                   endif
     C                   eval      nxtscr = 'EOJ'
     C     ent01e        endsr
     *----------------------------------------------------------------
     *
     *  FGTWAY   Gateway to file handling routines
     *
     *    Input Parameters
     *      $POCMD   *INIT    - Initialize and return
     *               *GET     - Get record for $POUKY value
     *               *GETNEXT - Get next record
     *               *GETPREV - Get previous record
     *               *WRITPOS - Write position record to display
     *               *READPOS - Read position record
     *               *POSTN2  - Position to $POFKY
     *               *POSTN2U - Position to $POUKY
     *               *TOP     - Position to top of file
     *               *BOTTOM  - Position to bottom of file
     *      $POFKY   Key for positioning within file
     *      $POUKY   Unique key used for change/delete operations
     *
     *    Returned Parameters
     *      $PORTN   *NOMORE  - Beginning/End of file was reSDhed
     *               *NOTFND  - Record not found on a GET
     *               *FOUND   - Record found
     *               *REPOS   - Repositioning took plSDe
     *               *ERROR   - Error occured
     *      $POERM   Error message
     *
     C     fgtway        begsr
     C                   eval      $portn = *blanks
     C     $pocmd        caseq     '*GET    '    fget
     C     $pocmd        caseq     '*GETNEXT'    fgetn
     C     $pocmd        caseq     '*GETPREV'    fgetp
     C     $pocmd        caseq     '*POSTN2 '    fpos2
     C     $pocmd        caseq     '*POSTN2U'    fpos2u
     C     $pocmd        caseq     '*TOP'        zzpos2
     C     $pocmd        caseq     '*BOTTOM'     zzpos2
     C                   endcs
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGET     Get record using file with unique key
     *
     *              In this case the lookup file and the unique key
     *              file are the same.
     *
     C     fget          begsr
     C                   eval      dsukey = $pouky
     C     fileky        chain     record                             79
     C                   if        *in79
     C                   eval      $portn = '*NOTFND '
     C                   eval      $pofky = *blanks
     C                   eval      $pouky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETN    Get next record
     *
     C     fgetn         begsr
     C                   exsr      zzfgtn
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   eval      $pofky = *blanks
     C                   eval      $pouky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETP    Get previous record
     *
     C     fgetp         begsr
     C                   exsr      zzfgtp
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   eval      $pofky = *blanks
     C                   eval      $pouky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2    Position to record
     *
     C     fpos2         begsr
     C                   eval      dsfkey = $pofky
     C     fileky        setll     record
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2U   Position to record using unique key
     *
     C     fpos2u        begsr
     *
     *  GET RECORD FOR UNIQUE KEY
     *
     C                   exsr      fget
     *
     *  POSITION TO RECORD IN LOOKUP FILE
     *
     C                   exsr      fpos2
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     *
     *  Move first selected value to $LUKY  parameter and set
     *     the option taken flag.
     *
     C                   eval      otaken = *off
     C     wkoprt        setll     workopt
     C     wkoprt        reade     workopt                                79
     C                   if        not *in79
     C                   eval      otaken = *on
     C                   eval      $luky = wkokyu
     C                   endif
     C     optnse        endsr
     *----------------------------------------------------------------
     *
     *  PAG01    Screen 1 page routines
     *
     C     pag01         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag1fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag1bk
     C                   else
     *
     *  TOP
     *
     C                   if        pagcmd = '*TOP    '
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     *R         CLERR     CABEQ*ON       PAG01E
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  BOTTOM
     *
     C                   if        pagcmd = '*BOTTOM '
     C                   eval      bot = *on
     C                   eval      dsplyd = 0
     C                   exsr      pag1bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C                   if        fkey(1) = *loval
     C                   eval      $pocmd = '*TOP    '
     C                   else
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = fkey(1)
     C                   endif
     C                   exsr      fgtway
     *R         CLERR     CABEQ*ON       PAG01E
     C                   eval      bot = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  REPOSITIONING
     *
     C                   if        pagcmd = '*REPOS  '
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag1fw
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
     C     pag01e        endsr
     *----------------------------------------------------------------
     *
     *  PAG1FW   Let's see that next page of records
     *
     C     pag1fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     *on           endf
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  GET 10 RECORDS TO DISPLAY
     *
     C                   dou       stop = *on
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfsd
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
740aA
740aDC**                 if        p >= 3
740aMC                   if        p >= maxval
     C                   eval      stop = *on
     C                   if        forceb = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C     endfsd        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf          endsr
     *----------------------------------------------------------------
     *
     *  PAG1BK   Let's see the previous page
     *
     C     pag1bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     *on           endb
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BSDKWARDS
     *
740aA
740aDC**   dsplyd        add       3             gobsdk
740aMC     dsplyd        add       maxval        gobsdk
     C                   if        bot = *on
740aDC**                 if        gobsdk = 3
740aMC                   if        gobsdk = maxval
     C                   eval      forceb = *on
     C                   endif
     C                   eval      $pocmd = '*BOTTOM '
     C                   exsr      fgtway
     C                   add       1             gobsdk
     C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  READ SPECIFIED FLITCHES FILE
     *
     C                   dou       stop = *on
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     *
     *  HIT TOP OF FILE
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBSDK' NUMBER OF GOOD RECS
     *
     C                   add       1             p
     C                   if        p >= gobsdk
     C                   eval      stop = *on
     C                   endif
     C     endbk         tag
     C                   enddo
     *
     * IF THE TOP WAS RESDHED THEN POSITION POINTER TO TOP OF FILE
     *
     C                   if        top = *on
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   endif
     C                   exsr      pag1fw
     C     endb          endsr
     *----------------------------------------------------------------
     *
     *  ROLL01   Screen 1 roll up/down routine
     *
     C     roll01        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   exsr      savopt
     C     error         cabeq     *on           rol01e
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   exsr      savopt
     C     error         cabeq     *on           rol01e
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     C     rol01e        endsr
     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     C     savopt        begsr
     *
     *  Read only the changed options.
     *
     C                   eval      nomore = *off
     C                   dou       nomore = '1'
     C                   eval      *in85 = *off
740aA
740aA*   8 line dispalys                      .
740aA
740aAC                   if        #lline <> '16'
740aA
     C                   select
     C                   when      view = 1  and
500 AC                             e$lng = 'SP'
500 AC                   readc     pacsflsp                               79
500 D**         CLIENT    WHEQ PACKER
500 AC                   when      view = 1  and
500 AC                             e$lng = 'EN'
417 AC                   readc     pacsfl                                 79
417 AC                   other
     C                   readc     dspsfl                                 79
417 AC                   endsl
500 AC                   select
     C                   when      view = 2  and
500 AC                             e$lng = 'SP'
500 AC                   readc     vw2sflsp                               79
500 AC                   when      view = 2  and
500 AC                             e$lng = 'EN'
500 AC                   readc     vw2sfl                                 79
     C                   endsl
510aAC                   select
510aAC                   when      view = 3  and
510aAC                             e$lng = 'SP'
510aAC                   readc     dspsflsp                               79
510aAC                   when      view = 3  and
510aAC                             e$lng = 'EN'
510aAC                   readc     dspsfl                                 79
510aAC                   endsl
740aA
740aA*   16 line dispalys                      .
740aA
740aAC                   else
740aA
740aAC                   select
740aAC                   when      view = 1  and
740aAC                             e$lng = 'SP'
740aAC                   readc     p16sflsp                               79
740aAC                   when      view = 1  and
740aAC                             e$lng = 'EN'
740aAC                   readc     p16sfl                                 79
740aAC                   other
740aAC                   readc     d16sfl                                 79
740aAC                   endsl
740aAC                   select
740aAC                   when      view = 2  and
740aAC                             e$lng = 'SP'
740aAC                   readc     v16sflsp                               79
740aAC                   when      view = 2  and
740aAC                             e$lng = 'EN'
740aAC                   readc     v16sfl                                 79
740aAC                   endsl
740aAC                   select
740aAC                   when      view = 3  and
740aAC                             e$lng = 'SP'
740aAC                   readc     d16sflsp                               79
740aAC                   when      view = 3  and
740aAC                             e$lng = 'EN'
740aAC                   readc     d16sfl                                 79
740aAC                   endsl
740aA
740aAC                   endif
740aA
     C                   if        *in79
     C                   eval      nomore = *on
     C                   goto      enddo1
     C                   endif
     *
     *  Display error if option is not valid.
     *
     C                   if        option <> *blanks  and
     C                             option <> '1'
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
     C                   endif
     *
     *  Save option
     *
     C                   z-add     recno         y
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C     wkounq        chain     workopt                            79
     C                   if        not *in79
     C                   if        option = *blanks
     C                   delete    wkorec
     C                   else
     C                   move      option        wkoopt
     C                   move      *in85         wkoerr
     C                   update    wkorec
     C                   endif
     C                   else
     C                   if        option <> *blanks
     C                   eval      wkousr = #user
     C                   eval      wkopgm = #prog
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C                   move      option        wkoopt
     C                   move      *in85         wkoerr
     C                   write     wkorec
     C                   endif
     C                   endif
     C     enddo1        tag
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
740aA
740aDC**                 if        recno < 3
740aMC                   if        recno < maxval
     C                   add       1             recno
     C                   z-add     recno         y
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
740aA
740aA*   8 line dispalys                      .
740aA
740aAC                   if        #lline <> '16'
740aA
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   write     dspsflsp
500 AC                   write     pacsflsp
500 AC                   write     vw2sflsp
500 AC                   other
     C                   write     dspsfl
417 AC                   write     pacsfl
     C                   write     vw2sfl
500 AC                   endsl
740aA
740aA*   16 line dispalys                      .
740aA
740aAC                   else
740aA
740aAC                   select
740aAC                   when      e$lng = 'SP'
740aAC                   write     d16sflsp
740aAC                   write     p16sflsp
740aAC                   write     v16sflsp
740aAC                   other
740aAC                   write     d16sfl
740aAC                   write     p16sfl
740aAC                   write     v16sfl
740aAC                   endsl
740aA
740aAC                   endif
740aA
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      *in01 = *off
     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
740aA
740aA*   8 line dispalys                      .
740aA
740aAC                   if        #lline <> '16'
740aA
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   write     dspsfcsp
500 AC                   write     pacsfcsp
500 AC                   write     vw2sfcsp
500 AC                   other
     C                   write     dspsfc
417 AC                   write     pacsfc
     C                   write     vw2sfc
500 AC                   endsl
740aA
740aA*   16 line dispalys                      .
740aA
740aAC                   else
740aA
740aAC                   select
740aAC                   when      e$lng = 'SP'
740aAC                   write     d16sfcsp
740aAC                   write     p16sfcsp
740aAC                   write     v16sfcsp
740aAC                   other
740aAC                   write     d16sfc
740aAC                   write     p16sfc
740aAC                   write     v16sfc
740aAC                   endsl
740aA
740aAC                   endif
740aA
     C                   eval      recno = 0
     C                   eval      *in82 = *on
     C                   eval      *in83 = *off
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     *R                   WRITEOPTREC
740aAC                   if        #lline <> '16'
     C                   write     cmdrec
740aAC                   else
740aAC                   write     cmdrec16
740aAC                   endif
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     *R                   WRITEMORREC
740aAC                   if        #lline = '16'
740aAC                   write     morrec16
740aAC                   endif
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     *R                   WRITEPOSTNREC
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> *on
740aA
740aA*   8 line dispalys                      .
740aA
740aAC                   if        #lline <> '16'
740aA
     C                   select
     C                   when      view = 1
417 AC                   select
500 D**         CLIENT    WHEQ PACKER
500 AC                   when      e$lng = 'SP'
500 AC     1             chain     pacsflsp                           79
500 AC                   when      e$lng = 'EN'
500 AC     1             chain     pacsfl                             79
417 AC                   other
     C     1             chain     dspsfl                             79
417 AC                   endsl
     C                   when      view = 2  and
500 AC                             e$lng = 'SP'
500 AC     1             chain     vw2sflsp                           79
500 AC                   when      view = 2  and
500 AC                             e$lng = 'EN'
     C     1             chain     vw2sfl                             79
510aAC                   when      view = 3  and
510aAC                             e$lng = 'SP'
510aAC     1             chain     dspsflsp                           79
510aAC                   when      view = 3  and
510aAC                             e$lng = 'EN'
510aAC     1             chain     dspsfl                             79
     C                   endsl
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   select
     C                   when      view = 1
417 AC                   select
500 D**         CLIENT    WHEQ PACKER
500 AC                   when      e$lng = 'SP'
500 AC                   update    pacsflsp
500 AC                   when      e$lng = 'EN'
500 AC                   update    pacsfl
417 AC                   other
     C                   update    dspsfl
417 AC                   endsl
     C                   when      view = 2  and
500 AC                             e$lng = 'SP'
500 AC                   update    vw2sflsp
500 AC                   when      view = 2  and
500 AC                             e$lng = 'EN'
     C                   update    vw2sfl
510aAC                   when      view = 3  and
510aAC                             e$lng = 'SP'
510aAC                   update    dspsflsp
510aAC                   when      view = 3  and
510aAC                             e$lng = 'EN'
510aAC                   update    dspsfl
     C                   endsl
     C                   endif
740aA
740aA*   16 line dispalys                      .
740aA
740aAC                   else
740aA
740aAC                   select
740aAC                   when      view = 1
740aAC                   select
740aAC                   when      e$lng = 'SP'
740aAC     1             chain     p16sflsp                           79
740aAC                   when      e$lng = 'EN'
740aAC     1             chain     p16sfl                             79
740aAC                   other
740aAC     1             chain     d16sfl                             79
740aAC                   endsl
740aAC                   when      view = 2  and
740aAC                             e$lng = 'SP'
740aAC     1             chain     v16sflsp                           79
740aAC                   when      view = 2  and
740aAC                             e$lng = 'EN'
740aAC     1             chain     v16sfl                             79
740aAC                   when      view = 3  and
740aAC                             e$lng = 'SP'
740aAC     1             chain     d16sflsp                           79
740aAC                   when      view = 3  and
740aAC                             e$lng = 'EN'
740aAC     1             chain     d16sfl                             79
740aAC                   endsl
740aAC                   if        not *in79
740aAC                   eval      *in20 = *on
740aAC                   select
740aAC                   when      view = 1
740aAC                   select
740aAC                   when      e$lng = 'SP'
740aAC                   update    p16sflsp
740aAC                   when      e$lng = 'EN'
740aAC                   update    p16sfl
740aAC                   other
740aAC                   update    d16sfl
740aAC                   endsl
740aAC                   when      view = 2  and
740aAC                             e$lng = 'SP'
740aAC                   update    v16sflsp
740aAC                   when      view = 2  and
740aAC                             e$lng = 'EN'
740aAC                   update    v16sfl
740aAC                   when      view = 3  and
740aAC                             e$lng = 'SP'
740aAC                   update    d16sflsp
740aAC                   when      view = 3  and
740aAC                             e$lng = 'EN'
740aAC                   update    d16sfl
740aAC                   endsl
740aAC                   endif
740aA
740aAC                   endif
740aA
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      *in81 = *on
     C                   eval      recno = 1
740aA
740aA*   8 line dispalys                      .
740aA
740aAC                   if        #lline <> '16'
740aA
     C                   select
     C                   when      view = 1
417 AC                   select
500 D**         CLIENT    WHEQ PACKER
500 AC                   when      e$lng = 'SP'
500 AC                   write     pacsfcsp
500 AC                   when      e$lng = 'EN'
500 AC                   write     pacsfc
417 AC                   other
     C                   write     dspsfc
417 AC                   endsl
     C                   when      view = 2  and
500 AC                             e$lng = 'SP'
500 AC                   write     vw2sfcsp
500 AC                   when      view = 2  and
500 AC                             e$lng = 'EN'
     C                   write     vw2sfc
510aAC                   when      view = 3  and
510aAC                             e$lng = 'SP'
510aAC                   write     dspsfcsp
510aAC                   when      view = 3  and
510aAC                             e$lng = 'EN'
510aAC                   write     dspsfc
     C                   endsl
740aA
740aA*   16 line dispalys                      .
740aA
740aAC                   else
740aA
740aAC                   select
740aAC                   when      view = 1
740aAC                   select
740aAC                   when      e$lng = 'SP'
740aAC                   write     p16sfcsp
740aAC                   when      e$lng = 'EN'
740aAC                   write     p16sfc
740aAC                   other
740aAC                   write     d16sfc
740aAC                   endsl
740aAC                   when      view = 2  and
740aAC                             e$lng = 'SP'
740aAC                   write     v16sfcsp
740aAC                   when      view = 2  and
740aAC                             e$lng = 'EN'
740aAC                   write     v16sfc
740aAC                   when      view = 3  and
740aAC                             e$lng = 'SP'
740aAC                   write     d16sfcsp
740aAC                   when      view = 3  and
740aAC                             e$lng = 'EN'
740aAC                   write     d16sfc
740aAC                   endsl
740aA
740aAC                   endif
740aA
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
740aA
740aDC**   1             do        5             x
740aMC     1             do        maxval        x
740aA
740aA*   8 line dispalys                      .
740aA
740aAC                   if        #lline <> '16'
740aA
     C                   select
     C                   when      view = 1
417 AC                   select
500 D**         CLIENT    WHEQ PACKER
500 AC                   when      e$lng = 'SP'
500 AC     x             chain     pacsflsp                           79
500 AC                   when      e$lng = 'EN'
500 AC     x             chain     pacsfl                             79
417 AC                   other
     C     x             chain     dspsfl                             79
417 AC                   endsl
     C                   when      view = 2  and
500 AC                             e$lng = 'SP'
500 AC     x             chain     vw2sflsp                           79
500 AC                   when      view = 2  and
500 AC                             e$lng = 'EN'
     C     x             chain     vw2sfl                             79
510aAC                   when      view = 3  and
510aAC                             e$lng = 'SP'
510aAC     x             chain     dspsflsp                           79
510aAC                   when      view = 3  and
510aAC                             e$lng = 'EN'
510aAC     x             chain     dspsfl                             79
     C                   endsl
740aA
740aA*   16 line dispalys                      .
740aA
740aAC                   else
740aA
740aAC                   select
740aAC                   when      view = 1
740aAC                   select
740aAC                   when      e$lng = 'SP'
740aAC     x             chain     p16sflsp                           79
740aAC                   when      e$lng = 'EN'
740aAC     x             chain     p16sfl                             79
740aAC                   other
740aAC     x             chain     d16sfl                             79
740aAC                   endsl
740aAC                   when      view = 2  and
740aAC                             e$lng = 'SP'
740aAC     x             chain     v16sflsp                           79
740aAC                   when      view = 2  and
740aAC                             e$lng = 'EN'
740aAC     x             chain     v16sfl                             79
740aAC                   when      view = 3  and
740aAC                             e$lng = 'SP'
740aAC     x             chain     d16sflsp                           79
740aAC                   when      view = 3  and
740aAC                             e$lng = 'EN'
740aAC     x             chain     d16sfl                             79
740aAC                   endsl
740aA
740aAC                   endif
740aA
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   move      wkoopt        option
     C                   eval      *in85 = wkoerr
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   eval      *in85 = *off
     C                   endif
740aA
740aA*   8 line dispalys                      .
740aA
740aAC                   if        #lline <> '16'
740aA
     C                   select
     C                   when      view = 1
417 AC                   select
500 D**         CLIENT    WHEQ PACKER
500 AC                   when      e$lng = 'SP'
500 AC                   update    pacsflsp
500 AC                   when      e$lng = 'EN'
500 AC                   update    pacsfl
417 AC                   other
     C                   update    dspsfl
417 AC                   endsl
     C                   when      view = 2  and
500 AC                             e$lng = 'SP'
500 AC                   update    vw2sflsp
500 AC                   when      view = 2  and
500 AC                             e$lng = 'EN'
     C                   update    vw2sfl
510aAC                   when      view = 3  and
510aAC                             e$lng = 'SP'
510aAC                   update    dspsflsp
510aAC                   when      view = 3  and
510aAC                             e$lng = 'EN'
510aAC                   update    dspsfl
     C                   endsl
740aA
740aA*   16 line dispalys                      .
740aA
740aAC                   else
740aA
740aAC                   select
740aAC                   when      view = 1
740aAC                   select
740aAC                   when      e$lng = 'SP'
740aAC                   update    p16sflsp
740aAC                   when      e$lng = 'EN'
740aAC                   update    p16sfl
740aAC                   other
740aAC                   update    d16sfl
740aAC                   endsl
740aAC                   when      view = 2  and
740aAC                             e$lng = 'SP'
740aAC                   update    v16sflsp
740aAC                   when      view = 2  and
740aAC                             e$lng = 'EN'
740aAC                   update    v16sfl
740aAC                   when      view = 3  and
740aAC                             e$lng = 'SP'
740aAC                   update    d16sflsp
740aAC                   when      view = 3  and
740aAC                             e$lng = 'EN'
740aAC                   update    d16sfl
740aAC                   endsl
740aA
740aAC                   endif
740aA
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
740aA
740aA*   8 line dispalys                      .
740aA
740aAC                   if        #lline <> '16'
740aA
     C                   write     msgctl
740aA
740aA*   16 line dispalys                      .
740aA
740aAC                   else
740aA
740aAC                   write     m16ctl
740aA
740aAC                   endif
740aA
     C                   eval      msgk = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
740aA
740aA*   8 line dispalys                      .
740aA
740aAC                   if        #lline <> '16'
740aA
     C                   write     msgclr
740aA
740aA*   16 line dispalys                      .
740aA
740aAC                   else
740aA
740aAC                   write     m16clr
740aA
740aAC                   endif
740aA
     C                   eval      *in97 = *on
     C                   if        msgk > 0
740aA
740aA*   8 line dispalys                      .
740aA
740aAC                   if        #lline <> '16'
740aA
     C                   write     msgctl
740aA
740aA*   16 line dispalys                      .
740aA
740aAC                   else
740aA
740aAC                   write     m16ctl
740aA
740aAC                   endif
740aA
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
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   eval      $msgf = #msgsp
500 AC                   other
     C                   eval      $msgf = #msgf
500 AC                   endsl
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      #prog         #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
740aA
740aA*   8 line dispalys                      .
740aA
740aAC                   if        #lline <> '16'
740aA
     C                   write     msgrec
740aA
740aA*   16 line dispalys                      .
740aA
740aAC                   else
740aA
740aAC                   write     m16rec
740aA
740aAC                   endif
740aA
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
740aA
740aA*   8 line dispalys                      .
740aA
740aAC                   if        #lline <> '16'
740aA
     C                   write     msgrec
740aA
740aA*   16 line dispalys                      .
740aA
740aAC                   else
740aA
740aAC                   write     m16rec
740aA
740aAC                   endif
740aA
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     *R                   WRITECLRSCR
740aMC                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   eval      $msgf = #msgsp
500 AC                   other
     C                   eval      $msgf = #msgf
500 AC                   endsl
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      $lprg         #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
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
     C****               eval      $pmsg = #msgk
     C                   endsr

     *      0104  Pressed an invalid key.
     *
     C     zm0104        begsr
     C                   eval      #msgid = 'PIR0104'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
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
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C***                eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *      0106  Invalid cursor position.
     *
     C     zm0106        begsr
     C                   eval      #msgid = 'PIR0106'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0107  Invalid value for "position To"
     *
     C     zm0107        begsr
     C                   eval      #msgid = 'PIR0107'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0108  Invalid Option.
     *
     C     zm0108        begsr
     C                   eval      #msgid = 'PIR0108'
     C                   eval      #msgtp = '*DIAG  '
     C                   movel     option        errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR1001  Invalid code.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   movea     descsp        errmsg
500 AC                   other
     C                   movea     desc          errmsg
500 AC                   endsl
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $lmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTN   Get next record
     *
     C     zzfgtn        begsr
     C     try1          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *R                   READ RECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C                   if        psflag = *off
     C                   eval      vsdisp = $ldisp
     C                   eval      vswhse = $lwhse
     C                   eval      vswhdp = $lwhdp
600aDC**   slkey         chain     slot2                              79
600aMC                   exsr      zzgetslot
600aAC                   eval      *in79 = error
     C                   eval      psflag = *on
     C                   else
     C     partky        reade     record                                 79
DRYaAC*
DRYaAC***                if           client = Dairyland
DRYaAC***                          and not *in79
640aAC                   if        not *in79
DRYaAC                   exsr      zzgetslot
DRYaAC                   if        not error  and
DRYaAC                             $slstat = 'Z'
DRYaAC                   goto      try1
DRYaAC                   endif
640aAC                   endif
640aAC*
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTP   Get previous record
     *
     C     zzfgtp        begsr
     C     try2          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *R                   READPRECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C     partky        readpe    record                                 79
DRYaA*
DRYaAC***                if        client = Dairyland
DRYaAC***                          and not *in79
640aAC                   if        not *in79
DRYaAC*
DRYaAC                   exsr      zzgetslot
DRYaAC                   if        not error  and
DRYaAC                             $slstat = 'Z'
DRYaAC                   goto      try2
DRYaAC                   endif
DRYaA*
640aAC                   endif
640aA*
     C                   if        *in79
416 AC                   eval      psflag = *off
     C                   eval      vsdisp = $ldisp
416 D*R         SLKEY     CHAINSLOT2                79
600aDC**   slkey         chain     slot2                              76
600aMC                   exsr      zzgetslot
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     *
     *   Get fields from slot file.
     *
600aDC**   slkey         chain     slot2                              78
600aDC**                 if        not *in78
600aDC**   itkey         chain     piritem                            77
600aDC**                 if        *in77
600aDC**                 eval      itpdsc = *blanks
600aDC**                 eval      itdesc = *blanks
600aDC**                 endif
600aDC**                 endif
600aA
600aMC                   exsr      zzgetslot
610aDC*                  eval      w1pos = $saToPos
640bA
640bA*   License
640bA
640bAC                   if        %len(%trim($saToLcns)) <= 14
640bAC                   eval      w1Lcns = $saToLcns
640bAC                   else
640bAC                   eval      w1Lcns = %subst($saToLcns:1:12) + '..'
640bAC                   endif
600aA
600aA*  Get item.
600aA
600aAC                   exsr      clr$item
600aAC                   eval      $itwhse  = $slwhse
600aAC                   eval      $ititem  = $slitem
600aA
600aAC                   eval      $dricommand = '*ITEM'
600aAC                   eval      $drisubcmd  = '%GETMAIN'
600aAC                   eval      $drisys2upd = 'D'
600aAC                   eval      chk4err = *on
600aAC                   eval      zmsflag = *on
600aAC                   exsr      zzzdricop
600aAC                   if        error
600aAC                   eval      error = *off
600aAC                   eval      $itdesc = '** NOT FOUND **'
600aAC                   endif
     *
     *
     C                   endsr

600aA*----------------------------------------------------------------
600aA*  ZZGETSLOT   Get slot.
600aA*----------------------------------------------------------------
600aA
600aAC     zzgetslot     begsr
     C                   eval      error = *off

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $lwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $lwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = vsdisp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
640bAC                   eval      $saToPos = 0
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    $lwhse
     C                   kfld                    $lwhdp
     C                   kfld                    vspdis
     C                   kfld                    vsdisp
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $lwhse
     C                   kfld                    $lwhdp
     C                   kfld                    vspdis
     *
     *  Define key for SLOT file.
     *
600aDC**   slkey         klist
600aDC**                 kfld                    $lwhse
600aDC**                 kfld                    $lwhdp
600aDC**                 kfld                    vsdisp
     *
     *  Define key for item file.
     *
600aDC**   itkey         klist
600aDC**                 kfld                    $lwhse
600aDC**                 kfld                    slitem
     *
     *  Define key for warehouse department.
     *
     C     wdkey         klist
     C                   kfld                    $lwhse
     C                   kfld                    $lwhdp
     *
510aD*                    Z-ADD2         MAXVW   10
510aMC                   eval      maxvw = 3
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   eval      w1cmd = cmdsp(1)
500 AC                   other
     C                   eval      w1cmd = cmd(1)
500 AC                   endsl
     C                   eval      $poprg = #prog
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Initailization for each time program is called.
     *
     C     zzinz2        begsr
417 A*
417 A* Get client id.
417 A*
417 AC     *dtaara       define    pirclient     client           10
417 AC                   in        client
     *
     C                   clear                   dsfkey
     C                   clear                   dsukey
TPC AC                   if        client = tpc
TPC  C                   eval      view = 2
TPC  C                   else
     C                   eval      view = 1
TPC  C                   endif
     C                   eval      vspdis = $ldisp
     C                   eval      psflag = *off
740aA
740aA*   Get screen size being used.
740aA
740aAC                   CALL      'PIRRFSCR'
740aAC                   PARM      '*GET'        #LCMD             8
740aAC                   PARM                    #LLINE            2
740aAC                   PARM                    #LCOL             3
740aAC                   if        #lline <> '16'
740aAC                   eval      maxval = 3
740aAC                   else
740aAC                   eval      maxval = 10
740aAC                   endif
740aA
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYF   Create key for file being used
     *
     C     zzkeyf        begsr
     C                   eval      $pofky = dsfkey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
     C                   eval      ukwhse = vswhse
     C                   eval      ukwhdp = vswhdp
     C                   eval      ukdisp = vsdisp
     C                   eval      $pouky = dsukey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *  See if user is trying to position to a certain spot
     *
     C                   if        ptinp1 <> *blanks
600aMC                   eval      $sldisp = ptinp1
     C                   eval      ptinp1 = *blanks
     C                   eval      repos = *on
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     C     zzpos2        begsr
     *
     *    Code to use when we are not using a partial key.
     *
     *R         $POCMD    IFEQ '*TOP'
     *R         *LOVAL    SETLLRECORD
     *R                   ELSE
     *R         $POCMD    IFEQ '*BOTTOM'
     *R         *HIVAL    SETLLRECORD
     *R                   ENDIF
     *R                   ENDIF
     *
     *    Code to use when we do have a partial key to use.
     *
     C                   if        $pocmd = '*TOP'
     C     partky        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     partky        setgt     record
     C                   endif
     C                   endif
     C                   endsr

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
600bAC                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

600aA*----------------------------------------------------------------
600aA*  clr$slot  Clear $slot data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
600bAC                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   endsr
600aA
600aA*----------------------------------------------------------------
600aA*  zzzdriclose   Close any open files or programs.
600aA*----------------------------------------------------------------
600aA
600aAC     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

640bAC                   if        error = *on
640bAC                   eval      error = *off
640bAC                   eval      $saToPos = 0
640bAC                   endif
     C                   endsr
600aA
600aA*----------------------------------------------------------------
600aA*  zzzdricop  Call DRICOP
600aA*----------------------------------------------------------------
600aA
600aAC     zzzdricop     begsr

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
600bAC                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
600bAC                             or $dricommand = '*SLOT'
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
     C***                exsr      zzerrind
     C                   endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
600bAC                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
Slot Type
**
F3=Exit F8=Next view F12=Cancel
** DESCSP
Tipo de slot
** CMDSP
F8=Ver proximo  F12=Cancelar
