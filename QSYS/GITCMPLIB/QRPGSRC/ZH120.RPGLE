      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave #203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *                  WEBFACING REQUIREMENTS
     *
     * CHANGES TO THE DISPLAY FILE WILL REQUIRE THE F-SPEC TO BE
     * RENAMED TO THE NEXT SEQUENTIAL MEMBER NAME.
     *
     * I.E. ZH120FM WILL BE REPALCED WITH ZH12001
     *----------------------------------------------------------------
     *
     *  ZH120  Zone maintenance - Display
     *  10 June 1997
     *  Dave Sommerville
     *
     *  Revisions
     *
530 A*    11/02/09  JCJ  5.30
     *      - Converted to RPGIV.
     *      - Added Truck Template heading to Screen Title.
     *      - For a truck, display info for the corresponding
     *        template code.
     *      - For a truck, activated option 5=View, deactivated
     *        options 2, 3 & 4.
     *
620aA*    12/16/10  DAS  6.20
     *      - Revised to prohibit going to zone detail for an 'S' zone.
     *
640 A*    01/19/11  JCJ  6.40
     *      - Allow zone detail to display in View mode when called
     *        from truck maintenance.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program uses to display subfiles to show more than one
     *    view of the record. To see what was changed search for VW2
     *    starting in column 1.
     *
     *    Allowed F17 and F18 for positioning to top and bottom.
     *
     *    Created a second line for commands.
     *
     *    CMD5 changed to chain and update each view seperately.
     *
     *    RECNO used for all subfiles, SFLRCDNBR not used in format member.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position Cursor
     *  21 - 29   Field Input Error (Reverse Display)
     *  79        Chain Indicator
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
     *  85        Manually set subfile change flag (SFLNXTCHG)
     *  90        Protect Input Fields for Delete Display
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound Buzzer)
     *  99        Universal Record Indicator (Very Temporary Usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
530 D*ZH120FM CF  E                    WORKSTN
530 MFzh12001   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(vw2sfl:recno)
     F                                     sfile(vw3sfl:recno)
222 D*                                       RECNO2KSFILE VW2SFL
222 D*                                       RECNO3KSFILE VW3SFL
     F                                     sfile(msgrec:msgk)
     Fworkopt   uf a e           k disk
     Fzoneh     if   e           k disk
     F                                     rename(zhrec:record)
530 AFtruckh    if   e           k disk
620aAFoptionz   if   e           k disk
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
     D zopt            s              2    dim(20) ctdata perrcd(20)
     D optln           s             75    dim(1) ctdata perrcd(1)
VW2 D*                   CMDLN   1   1 79
VW2 MD cmdln           s             79    dim(6) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D  $kwhse                 1      3  0
     D  $ktruk                 4     13
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  dsukey                 1     50
     D  zhwhse                 1      3  0 inz(0)
     D  zhtruk                 4     13
     D  zhzone                14     19
620aAD  svptyp                20     20
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @chgpg          c                   const('ZH122')
     D @cpypg          c                   const('ZH123')
     D @delpg          c                   const('ZH124')
     D @prtpg          c                   const('NONE')
     *----------------------------------------------------------------
     *  Called program parameters
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
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
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
     D  $ltruk                22     31
530 AD  $lzone                32     37
640 AD  $lcmd2                38     45
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
     *  Other data structures
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
620aA*----------------------------------------------------------------
620aA*  OPTIONZ data structure
620aA*
620aAD opzdta          ds
620aAD  opzend               117    117
620aA*----------------------------------------------------------------
620aA*  *PICK  -  Picking options
620aA*
     *     11/28/94  DAS
     *       - Changed OPFSTP to 2 digits from 1.
     *
     *     02/16/95  DAS   2.09
     *       - Moved option from OPTIONS to OPTIOND in order to have
     *         the options by department.
     *       - Added option OPFBLD for identifying the method to use
     *         for building a fixed pallet.
     *
213 A*     06/11/96  DAS   2.13
     *       - Redefined OPBPCK to 3.0 from 2.0.
     *       - Added option OPPBRK.
     *
214 A*     07/01/96  DAS
     *       - Redefined OPPBRK to 3 from 1 and to contain aisle
     *         instead of Y/N.
     *
300 A*     06/11/97  DAS
     *       - Moved into OPTIONZ from OPTIOND file.
     *       - OPPBRK is not used with zones.
     *
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
214 D**** OPPBRK  -  Break pallets by aisle (Y,N).
214 M*    OPPBRK  -  Aisle to start new pallet.
400 A*    OPPBLD  -  Pallet building method.
400 A*                1 = By stop then slot location.
400 A*                2 = By slot location then stop.
416 A*                3 = By descening stop, then slot location.
400 A*    OPSELM  -  Selection method.
400 A*                1 = Single pass (By location).
400 A*                2 = Multiple pass (By stop).
400 A*    OPSPLT  -  Allow stop to be split across pallets (Y/N).
400 A*    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
416aA*    OPNWPL  -  Start new pallet when aisle changes if build method
416aA*               is 2=Location.
500dA*    OPFORD  -  Maximun orders per pallet.
520dM*    OPPTYP  -  Pallet type (P=Pallet, T=Tote, B=Batch).
500dA*    OPFTOT  -  Maximum totes per pallet.
500dA*    OPTECB  -  External tote cube.
500dA*    OPTICB  -  Internal tote cube.
500dA*    OPTSTP  -  Maximum stops per tote.
500dA*    OPTPCS  -  Maximum pieces per tote.
510dA*    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
520dA*    OPGCDE  -  USF Group Code (0-9).
520cA*    OPPKUP  -  Picked up by (S=Selector, L=Loader).
520cA*    OPSPAL  -  Merge pallet should only contain
520cA*               items for single truck pallet (Y=Yes, N=No).
520dA*    OPPITM  -  Maximum items per pallet.
     *
     * Data structure
     *
     D opdta1          ds
     D  opnxtp                 1      7  0 inz(0)
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
209 AD  opfbld                27     27  0 inz(0)
213 AD  opbpck                28     30  0 inz(0)
214 AD  oppbrk                31     33
400 AD  oppbld                34     34
400 AD  opselm                35     35
400 AD  opsplt                36     36
500 MD  opbmrg                37     37
500 MD  opnwpl                38     38
500dAD  opford                39     40  0 inz(0)
500cMD  opptyp                41     41
500dAD  opftot                42     43  0 inz(0)
500dAD  optecb                44     48  2 inz(0)
500dAD  opticb                49     53  2 inz(0)
500dAD  optstp                54     55  0 inz(0)
500dAD  optord                56     57  0 inz(0)
500dAD  optpcs                58     60  0 inz(0)
510dAD  opstop                61     61
520dA** Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
520dAD**opgcde                62     62
520cAD  oppkup                62     62
520cAD  opspal                63     63
520dAD  oppitm                64     67  0 inz(0)
     D  opend1               117    117
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
530 A*
     D #ztmp           c                   const('  TEMPLATE')
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
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Work Fields
     *
     D $msgf           s             10
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D bot             s              1
     D cancel          s              1
     D clear           s              5  0
     D comand          s              5  0
     D dsplyd          s              2  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D forceb          s              1
     D forevr          s              1
     D frstky          s                   like($puky)
     D goback          s              2  0
     D help            s              5  0
     D ktruk           s             10
     D maxvw           s              1  0
     D msgk            s              4  0
     D nomore          s              1
     D nxtscr          s              3
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
     D posrec          s              4  0
     D reccnt          s              4  0
     D recno           s              4  0
     D refrsh          s              1
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D top             s              1
     D v               s              2  0
     D view            s              1  0
     D warn            s              1
     D x               s              3  0
     D y               s              3  0
530 AD $ucat           s             10
530 AD $uaction        s             10
530 AD $uuser          s             10
530 AD $ureturn        s             10
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PRTKY  Partial key
     *
     *    Returned Parameters
     *      $RTNCD  *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $prtky
     C                   parm                    $rtncd            8
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
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      $rtncd = *blanks
     C                   exsr      zzinz2
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   exsr      clrsch
     C                   seton                                        lr
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
     *   Set OFF command key indicators
     *
     C                   setoff                                       kckekf
     C                   setoff                                       kl
     *
     *   Overlay screen with title
     *
     C                   write     title
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *   Overlay screen with subfile screen
     *
     C                   if        nxtscr = '01 '
     C                   exsr      sfldsp
     C                   read      postnrec                               50
     C                   endif
     C                   if        nxtscr = '02 '
     C                   exsr      deldsp
     C                   endif
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
VW2 AC                   select
VW2 AC                   when      view = 1
     C                   read      dspsfc                                 50
VW2 AC                   when      view = 2
VW2 AC                   read      vw2sfc                                 50
VW2 AC                   when      view = 3
VW2 AC                   read      vw3sfc                                 50
VW2 AC                   endsl
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
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   eval      *in90 = *on
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   write     clr0306
     C                   write     delrec
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag02
     C                   write     cmddel
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 wrap-up
     *
     C     scr02e        begsr
     C                   eval      nxtscr = '01 '
     C                   eval      *in90 = *off
     C                   write     clr0306
     *
     *   If delete was not canceled (no errors)
     *     then reposition to record just before first deleted rec.
     *
     C                   if        cancel = *off
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = frstky
     C                   exsr      fgtway
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     C                   if        $portn = '*NOMORE '
     C                   eval      $pocmd = '*TOP    '
     C                   else
     *
     *   Otherwise, position to last record read.
     *
     C                   eval      $pocmd = '*POSTN2 '
     C                   endif
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   exsr      optns
     C                   else
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
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
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     C     status        caseq     rollup        roll02
     C     status        caseq     rolldn        roll02
     C     status        caseq     comand        cmd02
     C                   cas                     ent02
     C                   endcs
     C     endsc2        endsr
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
     *  Initialize subfile (DSPSFL) record
     *
     C                   eval      recno = 1
     C                   write     dspsfl                               79
222 D*                    Z-ADD1         RECNO2
VW2 AC                   write     vw2sfl                               79
222 D*                    Z-ADD1         RECNO3
VW2 AC                   write     vw3sfl                               79
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
     C                   eval      $rtncd = '*EXIT   '
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $rtncd = '*CANCEL '
     C                   goto      cmd01e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR CMD5 - REFRESH
     *
     C                   if        *inke
     C                   exsr      clrsch
     C     1             do        10            x
     C     x             chain     dspsfl                             79
222 D*R         X         CHAINVW2SFL               79
222 D*R         X         CHAINVW3SFL               79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    dspsfl
222 D*R                   UPDATVW2SFL
222 D*R                   UPDATVW3SFL
     C                   endif
222 AC     x             chain     vw2sfl                             79
222 AC                   if        not *in79
222 AC                   eval      option = '  '
222 AC                   update    vw2sfl
222 AC                   endif
222 AC     x             chain     vw3sfl                             79
222 AC                   if        not *in79
222 AC                   eval      option = '  '
222 AC                   update    vw3sfl
222 AC                   endif
     C                   enddo
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           cmd01e
     *
     *  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     *
     *  TEST FOR CMD6 - ADD RECORD
     *
     C                   if        *inkf
530 A*
530 A*   IF A TRUCK DO NOT ALLOW F6
530 A*
530 AC                   if        thtype = 'T'
530 AC                   eval      $prtn = '*ERROR2 '
530 AC                   else
     C                   exsr      inzpar
     C                   eval      $pcmd = '*ADD    '
     C                   call      @chgpg
     C                   parm                    $parms
530 AC                   endif
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
530 AC                   if        $prtn = '*ERROR2 '
530 AC                   eval      error = *on
530 AC                   movel     $perm         errmsg
530 AC                   exsr      zm0104
530 AC                   else
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     C                   if        $prtn <> '*CANCEL '  and
     C                             $prtn <> '*EXIT   '
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     C                   endif
530 AC                   endif
     C                   endif
220 AC                   eval      pagcmd = '*REFRESH'
220 AC                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
VW2 D*  TEST FOR CMD10 - MOVE RECORD THAT CUSOR IS ON TO TOP
VW2 M*  TEST FOR CMD20 - MOVE RECORD THAT CUSOR IS ON TO TOP
     *
VW2 D*R         *INKJ     IFEQ '1'
VW2 MC                   if        *inku
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     MAKE SURE CURSOR IS ON ONE OF THE DISPLAYED RECORDS
     *
     C                   sub       10            row#
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
     *R         CLERR     CABEQ'1'       CMD01E
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
VW2 A*
VW2 A*  TEST FOR CMD10 - Previous view
VW2 A*
VW2 AC                   if        *inkj
VW2 AC                   if        view = 1
VW2 AC                   eval      view = maxvw
VW2 AC                   else
VW2 AC                   eval      view = view - 1
VW2 AC                   endif
VW2 AC                   eval      v = view * 2
VW2 AC                   eval      cmdln2 = cmdln(v)
VW2 AC                   eval      v = v - 1
VW2 AC                   eval      cmdln1 = cmdln(v)
VW2 AC                   goto      cmd01e
VW2 AC                   endif
VW2 A*
VW2 A*  TEST FOR CMD11 - Next view
VW2 A*
VW2 AC                   if        *inkk
VW2 AC                   if        view = maxvw
VW2 AC                   eval      view = 1
VW2 AC                   else
VW2 AC                   add       1             view
VW2 AC                   endif
VW2 AC                   eval      v = view * 2
VW2 AC                   eval      cmdln2 = cmdln(v)
VW2 AC                   eval      v = v - 1
VW2 AC                   eval      cmdln1 = cmdln(v)
VW2 AC                   goto      cmd01e
VW2 AC                   endif
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
     *
     *   Process non-standard function keys.
     *
     C                   exsr      zzcmd
     C     cmd01e        endsr
     *----------------------------------------------------------------
     *
     *  CMD02    Screen 2 command key routine
     *
     C     cmd02         begsr
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      cancel = *on
     C                   exsr      scr02e
     C                   goto      cmd02e
     C                   endif
     C     cmd02e        endsr
     *----------------------------------------------------------------
     *
     *  DELADD   Add record to subfile for delete display
     *
     C     deladd        begsr
     C                   if        recno < 11
     C                   add       1             reccnt
     C                   eval      recno = reccnt
222 D*R                   Z-ADDRECCNT    RECNO2
222 D*R                   Z-ADDRECCNT    RECNO3
     C                   z-add     reccnt        y
     *
     *  GET RECORD INFO
     *
     C                   eval      $pocmd = '*GET    '
     C                   eval      $pouky = wkokyu
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       DELADE
     *
     *  SAVE KEY TO RECORD OF FIRST SCREEN LINE
     *
     C                   if        recno = 1
     C                   eval      $wkof = wkokyf
     C                   eval      $wkou = wkokyu
     C                   endif
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
     C                   eval      option = wkoopt
     C                   write     dspsfl
VW2 AC                   write     vw2sfl
VW2 AC                   write     vw3sfl
     C                   endif
     C     delade        endsr
     *----------------------------------------------------------------
     *
     *  DELDSP   Display subfile of records marked for deletion
     *
     C     deldsp        begsr
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   if        reccnt > 0
     C                   eval      *in81 = *on
     C                   endif
     C                   eval      recno = posrec
222 D*R                   Z-ADDPOSREC    RECNO2
222 D*R                   Z-ADDPOSREC    RECNO3
VW2 AC                   select
VW2 AC                   when      view = 1
     C                   write     dspsfc
VW2 AC                   when      view = 2
VW2 AC                   write     vw2sfc
VW2 AC                   when      view = 3
VW2 AC                   write     vw3sfc
VW2 AC                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     C     ent01         begsr
     *
     *  VERIFY AND SAVE OPTIONS
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           ent01e
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
     *R         OTAKEN    IFEQ '0'
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   GOTO ENT01E
     *R                   END
     C     ent01e        endsr
     *----------------------------------------------------------------
     *
     *  ENT02    Screen 2 enter key routine
     *
     C     ent02         begsr
     *
     *  Save first delete key.
     *
     C                   eval      frstky = $puky
     *
     *  Delete the records that have been selected
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     *
     C                   if        wkoopt = ' 4'
     *
     *  Call delete program
     *
     C                   exsr      inzpar
     C                   eval      $pcmd = '*DELETE '
     C                   eval      $puky = wkokyu
     C                   call      @delpg
     C                   parm                    $parms
     *
     *     Error occured - Error message sent back
     *
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     *
     *     Error occured - Error message sent to program msgq
     *
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     *
     *     Delete canceled
     *
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   else
     *
     *     Delete was successful.
     *
     C                   if        $prtn = '*OK     '
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   if        cancel = '0'
     C                   delete    wkorec
     C                   else
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   endif
     *
     C                   endif
     C                   enddo
     C                   exsr      scr02e
     C     ent02e        endsr
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
     *      $PORTN   *NOMORE  - Beginning/End of file was reached
     *               *NOTFND  - Record not found on a GET
     *               *FOUND   - Record found
     *               *REPOS   - Repositioning took place
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
     C                   exsr      zzfget
     C                   if        *in79
     C                   eval      $portn = '*NOTFND '
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
     *  INZPAR   Initialize parameters for calling add/chg/del program
     *
     C     inzpar        begsr
     C                   clear                   $parms
     C                   eval      $pprg = #prog
     C                   eval      $puky = $prtky
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     C                   eval      otaken = *off
     *
     *     DO ALL DELETES FIRST (OPTION 4)
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C     wkoprt        reade     workopt                                79
     C                   dow       not *in79  and
     C                             wkoopt <> ' 4'
     C     wkoprt        reade     workopt                                79
     C                   enddo
     C                   if        not *in79  and
     C                             wkoopt = ' 4'
     C                   eval      otaken = *on
     C                   eval      $puky = wkokyu
     C                   exsr      scr02i
     C                   goto      optnse
     C                   endif
     *
     *  THEN DO THE OTHER OPTIONS IN THE ORDER THEY WERE ENTERED
     *     STOP WHEN NO MORE OPTIONS OR USER ENTERS CMD12
     *
     C     wkoprt        setll     workopt
     C                   eval      cancel = *off
     C                   eval      stop = *off
     C                   dou       stop = '1'  or
     C                             cancel = '1'
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        wkoopt <> '  '
     C                   eval      otaken = *on
     C                   exsr      optns2
     C     wkounq        chain     workopt                            78
     C                   eval      refrsh = *on
     C                   if        error = '0'
     C                   delete    wkorec
     C                   endif
     C                   if        cancel = '1'
     C                   eval      stop = *on
     C                   if        error = '1'
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C                   endif
     C                   endif
     C                   enddo
     C                   if        refrsh = '1'
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C     optnse        endsr
     *----------------------------------------------------------------
     *
     *  OPTNS2   Execute individual options
     *
     C     optns2        begsr
     C                   exsr      inzpar
     C                   eval      $puky = wkokyu
530 AC                   eval      $luky = wkokyu
     *
     C                   select
     *
     *   Change
     *
     C                   when      wkoopt = ' 2'
     C                   eval      $pcmd = '*CHANGE '
     C                   call      @chgpg
     C                   parm                    $parms
     *
     *   Copy
     *
     C                   when      wkoopt = ' 3'
     C                   eval      $pcmd = '*COPY   '
     C                   call      @cpypg
     C                   parm                    $parms
     *
     *   View
     *
     C                   when      wkoopt = ' 5'
530 A **                 eval      $ltruk = $ktruk
530 A **                 eval      $lzone = zhzone
530 D**                   MOVE '*VIEW   '$PCMD
530 MC                   eval      $lcmd = '*VIEW   '
     C                   call      @chgpg
530 D**                   PARM           $PARMS
530 MC                   parm                    $lparm
     *
     *   Print
     *
     C                   when      wkoopt = ' 6'
     C                   eval      $pcmd = '*PRINT  '
     C                   call      @prtpg
     C                   parm                    $parms
     *
     C                   other
     C                   exsr      zzopt
     C                   endsl
     *
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   else
     C                   if        $prtn = '*ERROR  '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $prtn = '*PGMQ   '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     C                   endsr
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
     *R         CLERR     CABEQ'1'       PAG01E
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
     *R         CLERR     CABEQ'1'       PAG01E
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
     *  PAG02    Screen 2 page routines
     *
     C     pag02         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag2fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag2bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C     deltop        setll     workopt
     C                   eval      bot = *off
     C                   exsr      pag2fw
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
     C     pag02e        endsr
     *----------------------------------------------------------------
     *
     *  PAG1FW   Let's see that next page of records
     *
     C     pag1fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     '1'           endf
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
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfac
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
     C                   if        p >= 10
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C     endfac        tag
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
     C     top           cabeq     '1'           endb
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C     dsplyd        add       10            goback
     C                   if        bot = '1'
     C                   if        goback = 10
     C                   eval      forceb = *on
     C                   endif
     C                   eval      $pocmd = '*BOTTOM '
     C                   exsr      fgtway
     C                   add       1             goback
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
     C                   dou       stop = '1'
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
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C     endbk         tag
     C                   enddo
     *
     * IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     *
     C                   if        top = '1'
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   endif
     C                   exsr      pag1fw
     C     endb          endsr
     *----------------------------------------------------------------
     *
     *  PAG2FW   Let's see that next page of delete records
     *
     C     pag2fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     '1'           endf2
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  GET 10 RECORDS TO DISPLAY
     *
     C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfw2
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   exsr      deladd
     C                   if        p >= 10
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C                   endif
     C     endfw2        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf2         endsr
     *----------------------------------------------------------------
     *
     *  PAG2BK   Let's see the previous page of delete records
     *
     C     pag2bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     '1'           endb2
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C     dsplyd        add       10            goback
     C                   if        bot = '1'
     C     wkoprt        setgt     workopt
     C                   add       1             goback
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
     C                   dou       stop = '1'
     C     wkoprt        readpe    workopt                                79
     *
     *  HIT TOP OF FILE
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk2
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C                   endif
     C     endbk2        tag
     C                   enddo
     *
     * IF WE HIT THE TOP REPOSITION POINTER TO TOP OF FILE
     *
     C                   if        top = '1'
     C     wkoprt        setll     workopt
     C                   endif
     C                   exsr      pag2fw
     C     endb2         endsr
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
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     C     rol01e        endsr
     *----------------------------------------------------------------
     *
     *  ROLL02   Screen 2 roll up/down routine
     *
     C     roll02        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     C     rol02e        endsr
     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     C     savopt        begsr
     *
     *  READ ONLY THE CHANGED OPTIONS
     *
     C                   eval      nomore = *off
     C                   dou       nomore = '1'
     C                   eval      *in21 = *off
VW2 AC                   select
VW2 AC                   when      view = 1
     C                   readc     dspsfl                                 79
VW2 AC                   when      view = 2
VW2 AC                   readc     vw2sfl                                 79
VW2 AC                   when      view = 3
VW2 AC                   readc     vw3sfl                                 79
VW2 AC                   endsl
     C                   if        *in79
     C                   eval      nomore = *on
     C                   goto      enddo1
     C                   endif
     *
     *  DISPLAY ERROR IF OPTION IS NOT VALID
     *
     C                   if        option <> *blanks
     C                   movea     option        a2
     C                   if        a2(2) = ' '
     C                   eval      a2(2) = a2(1)
     C                   eval      a2(1) = ' '
     C                   movea     a2            option
     C                   endif
     *
     *    LOOK UP OPTION IN PROFILE - ERROR IF NOT FOUND
     *
     C     option        lookup    zopt                                   50
     C                   if        not *in50
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
     C                   endif
530 A*
530 A*    TRUCK OPTION CHECK - ERROR IF OPTION 2, 3, OR 4 ARE SELECTED
530 A*
530 AC                   if        w1ztmp <> #ztmp  and
530 AC                             option = ' 2'  or
530 AC                             w1ztmp <> #ztmp  and
530 AC                             option = ' 3'  or
530 AC                             w1ztmp <> #ztmp  and
640 MC                             option = ' 4'
640 D ***                          w1ztmp <> #ztmp  and
640 D ***                          option = '12'
530 AC                   eval      error = *on
530 AC                   eval      *in21 = *on
530 AC                   eval      *in85 = *on
530 AC                   eval      errmsg = *blanks
530 AC                   exsr      zm1018
530 AC                   endif
620aA*
620aA*    Do som extra checking.
620aA*
620aAC                   exsr      zzOptChk
620aA*
     C                   endif
     *
     *  SAVE OPTION
     *
VW2 AC                   select
VW2 AC                   when      view = 1
     C                   z-add     recno         y
VW2 AC                   when      view = 2
222 D*R                   Z-ADDRECNO2    Y       30
222 MC                   z-add     recno         y
VW2 AC                   when      view = 3
222 D*R                   Z-ADDRECNO3    Y       30
222 MC                   z-add     recno         y
VW2 AC                   endsl
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C     wkounq        chain     workopt                            79
     C                   if        not *in79
     C                   if        option = *blanks
     C                   delete    wkorec
     C                   else
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   update    wkorec
     C                   endif
     C                   else
     C                   if        option <> *blanks
     C                   eval      wkousr = #user
     C                   eval      wkopgm = #prog
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
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
     C                   if        reccnt < 11
     C                   add       1             reccnt
     C                   eval      recno = reccnt
222 D*R                   Z-ADDRECCNT    RECNO2
222 D*R                   Z-ADDRECCNT    RECNO3
     C                   z-add     reccnt        y
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
     C                   write     dspsfl
VW2 AC                   write     vw2sfl
VW2 AC                   write     vw3sfl
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
     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
     C                   eval      *in84 = *on
     *
     C                   write     dspsfc
VW2 AC                   write     vw2sfc
VW2 AC                   write     vw3sfc
     C                   eval      reccnt = 0
     C                   eval      posrec = 1
     C                   eval      recno = 0
222 D*R                   Z-ADD0         RECNO2  40
222 D*R                   Z-ADD0         RECNO3  40
     *
     C                   eval      *in82 = *on
     C                   eval      *in83 = *off
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
     C                   write     optrec
     C                   write     cmdrec
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     C                   write     postnrec
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> '1'
VW2 AC                   select
VW2 AC                   when      view = 1
     C     1             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   update    dspsfl
     C                   endif
VW2 AC                   when      view = 2
VW2 AC     1             chain     vw2sfl                             79
VW2 AC                   if        not *in79
VW2 AC                   eval      *in20 = *on
VW2 AC                   update    vw2sfl
VW2 AC                   endif
VW2 AC                   when      view = 3
VW2 AC     1             chain     vw3sfl                             79
VW2 AC                   if        not *in79
VW2 AC                   eval      *in20 = *on
VW2 AC                   update    vw3sfl
VW2 AC                   endif
VW2 AC                   endsl
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
222 D*R         RECCNT    IFGT 0
     C                   eval      *in81 = *on
222 D*R                   ENDIF
     C                   eval      recno = posrec
222 D*R                   Z-ADDPOSREC    RECNO2
222 D*R                   Z-ADDPOSREC    RECNO3
VW2 AC                   select
VW2 AC                   when      view = 1
     C                   write     dspsfc
VW2 AC                   when      view = 2
VW2 AC                   write     vw2sfc
VW2 AC                   when      view = 3
VW2 AC                   write     vw3sfc
VW2 AC                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
     C     1             do        10            x
VW2 AC                   select
VW2 AC                   when      view = 1
     C     x             chain     dspsfl                             79
VW2 AC                   when      view = 2
VW2 AC     x             chain     vw2sfl                             79
VW2 AC                   when      view = 3
VW2 AC     x             chain     vw3sfl                             79
VW2 AC                   endsl
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   eval      option = wkoopt
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   endif
VW2 AC                   select
VW2 AC                   when      view = 1
     C                   update    dspsfl
VW2 AC                   when      view = 2
VW2 AC                   update    vw2sfl
VW2 AC                   when      view = 3
VW2 AC                   update    vw3sfl
VW2 AC                   endsl
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
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   write     msgclr
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
     C                   parm      #prog         #pgmq
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
     *R                   WRITECLRSCR
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
     C                   parm      '*PREV'       #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0101  Program not found.
     *
     C     zm0101        begsr
     C                   eval      #msgid = 'PIR0101'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0102  Program not found.
     *
     C     zm0102        begsr
     C                   eval      #msgid = 'PIR0102'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0103  Program not found while exec. subroutine.
     *
     C     zm0103        begsr
     C                   eval      #msgid = 'PIR0103'
     C                   eval      #msgtp = '*DIAG  '
     *R                   MOVE CLPRGM    ERRCL1
     *R                   MOVE CLINFO    ERRCL2
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
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
530 A*----------------------------------------------------------------
530 A*      1018  Invalid Option.
530 A*
530 AC     zm1018        begsr
530 AC                   eval      #msgid = 'PIR1018'
530 AC                   eval      #msgtp = '*DIAG  '
530 AC                   movel     option        errmsg
530 AC                   movea     errmsg        $md(1)
530 AC                   exsr      zmpmsg
530 AC                   endsr
530 A*----------------------------------------------------------------
530 A*      0148  User not authorized to use ...
530 A*
530 AC     ZM0148        BEGSR
530 AC                   MOVE      'PIR0148'     #MSGID
530 AC                   MOVE      '*DIAG  '     #MSGTP
530 AC                   MOVEA     ERRMSG        $MD(1)
530 AC                   EXSR      ZMPMSG
530 AC                   ENDSR
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
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         begsr
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     Warehouse.
     *
     C                   if        row# = 3  and
     C                             col# >= 44
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      ptinp1 = $lwhse
     C                   endif
     *
     *     Truck.
     *
     C                   else
     C                   if        row# = 4  and
     C                             col# >= 44
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = $kwhse
     C                   eval      $ltruk = ptinp2
     C                   call      'TM900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      ptinp2 = $ltruk
     C                   endif
     C                   else
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endif
     C                   goto      endcm1
     C                   endif
     C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     C     zzfget        begsr
     *
     *    Code to use when file key and unique key are the same.
     *
     C     fileky        chain     record                             79
     *
     *    Code to use when file key and unique key are different.
     *
     *R         FILUKY    CHAINRECORDU              79
     *
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
     *                    READ RECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C     partky        reade     record                                 79
620aAC                   if        *in79
620aAC                   leavesr
620aAC                   endif

620aA*    Get corresponding optionz info
620aA
620aA /free
620aA
620aA    chain ('*PICK': zhwhse: zhtruk: zhzone) optionz;
620aA    if not %found(optionz);
620aA      opdta1 = ' ';
620aA    else;
620aA      opdta1 = opzdta;
620aA    endif;
620aA    svptyp = opptyp;
620aA
620aA /end-free

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
620aAC                   if        *in79
620aAC                   leavesr
620aAC                   endif

620aA*    Get corresponding optionz info
620aA
620aA /free
620aA
620aA    chain ('*PICK': zhwhse: zhtruk: zhzone) optionz;
620aA    if not %found(optionz);
620aA      opdta1 = ' ';
620aA    else;
620aA      opdta1 = opzdta;
620aA    endif;
620aA    svptyp = opptyp;
620aA
620aA /end-free

     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      forevr = *on
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    zhwhse
     C                   kfld                    zhtruk
     C                   kfld                    zhzone
     *
     *  Define UNIQ key for main file.
     *
     C     filuky        klist
     C                   kfld                    zhwhse
     C                   kfld                    zhtruk
     C                   kfld                    zhzone
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $kwhse
530 D**                   KFLD           $KTRUK
530 MC                   kfld                    ktruk
     *
     *  Setup option and command display lines.
     *
VW2 AC                   eval      view = 1
VW2 AC                   eval      maxvw = 3
     C                   eval      optln1 = optln(1)
     C                   eval      cmdln1 = cmdln(1)
VW2 AC                   eval      cmdln2 = cmdln(2)
     *
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from *INZSR.
     *
     C     zzinz2        begsr
     C                   eval      dsfkey = $prtky
     *
     *   Verify warehouse and get description.
     *
     C                   eval      whcode = zhwhse
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = zhwhse
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
     C                   else
     C                   eval      $kwhse = zhwhse
     C                   eval      whcode = zhwhse
     C                   movel     $lerm         whdesc
     C                   endif
     C                   endif
     *
     *   Get truck description.
     *
     C                   eval      w1truk = *blanks
     C                   movel     $ktruk        w1truk
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = $kwhse
     C                   eval      $ltruk = $ktruk
     C                   call      'TM900'
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
     C                   else
     C                   eval      w1truk = *blanks
     C                   eval      w1truk = %trimr($ktruk) + ' ' + '-'
     C                   eval      w1truk = %trimr(w1truk) + ' ' + $lerm
     C                   endif
     C                   endif
     *
530 AC                   eval      w1ztmp = *zeros
530 AC                   eval      ktruk = $ktruk
530 AC     partky        chain     truckh                             99
530 AC                   if        not *in99
530 AC                   move      #ztmp         w1ztmp
530 AC                   if        thtype = 'T'
530 AC                   move      thztmp        w1ztmp
530 AC                   eval      ktruk = thztmp
530 AC                   endif
530 AC                   endif
530 A*
     C                   exsr      clrsch
     C                   exsr      scr01i
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
     C                   eval      $pouky = dsukey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     C     zzopt         begsr
     C                   select
     *
     *   Work with detail
     *
     C                   when      wkoopt = '12'
640 AC                   if        w1ztmp <> #ztmp
640 AC                   eval      $lcmd2 = '*VIEW   '
640 AC                   endif
530 AC                   eval      dsfkey = wkokyf
530 AC                   eval      $ltruk = $ktruk
530 AC                   eval      $lzone = zhzone
     C                   call      'ZH130'
530 D**                   PARM           $PUKY
530 D**                   PARM           $PRTN
530 MC                   parm                    $luky
530 MC                   parm                    $lrtn
     *
     C                   endsl
     C                   endsr

620aA*----------------------------------------------------------------
620aA*  ZZOPTCHK   Do extra checking for savopt routine
620aA*----------------------------------------------------------------
620aA
620aAC     zzOptChk      begsr
     C                   eval      dsfkey = fkey(recno)
     C                   select

     *   Work with detail

     C                   when      option = '12'
     C                   if        svptyp = 'S'
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      *in21 = *on
     C                   eval      *in85 = *on
     C                   eval      errmsg = 'Zone detail entry not '
     C                                    + 'allowed for S zone'
     C                   exsr      zm0105
     C                   endif

     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *  See if user is trying to change warehouse.
     *
     C                   if        ptinp1 <> 0
     *
     *      Verify warehouse entry.
     *
     C                   eval      whcode = ptinp1
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   goto      endzps
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   goto      endzps
     C                   else
     C                   eval      zhwhse = ptinp1
     C                   eval      $kwhse = zhwhse
     C                   eval      zhtruk = *blanks
     C                   eval      zhzone = *blanks
     C                   eval      whcode = ptinp1
     C                   movel     $lerm         whdesc
     C                   eval      ptinp1 = 0
     C                   eval      repos = *on
     C                   endif
     C                   endif
     C                   endif
     *
     *  See if user is trying to change truck.
     *
     C                   if        ptinp2 <> *blanks
     *
     *      Verify truck entry.
     *
     C                   eval      w1truk = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   if        ptinp1 = 0
     C                   eval      $lwhse = $kwhse
     C                   else
     C                   eval      $lwhse = ptinp1
     C                   endif
     C                   eval      $ltruk = ptinp2
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   goto      endzps
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   goto      endzps
     C                   else
     C                   eval      zhtruk = ptinp2
     C                   eval      $ktruk = ptinp2
     C                   eval      zhzone = *blanks
     C                   eval      w1truk = *blanks
     C                   eval      w1truk = %trimr($ktruk) + ' ' + '-'
     C                   eval      w1truk = %trimr(w1truk) + ' ' + $lerm
     C                   eval      ptinp2 = *blanks
     C                   eval      repos = *on
530 AC                   exsr      zzinz2
     C                   endif
     C                   endif
     C                   endif
     *
     *  See if user is trying to position to code
     *
     C                   if        ptinp3 <> *blanks
     C                   eval      zhzone = ptinp3
     C                   eval      ptinp3 = *blanks
     C                   eval      repos = *on
     C                   endif
     C     endzps        endsr
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
     *R                   END
     *R                   END
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
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
 2 3 4 512
**  OPTLN - Option display line
2=Change  3=Copy  4=Delete  5=View  12=Work with detail
**  CMDLN - Command display line
F3=Exit  F4=Prompt  F5=Refresh  F6=Create  F12=Cancel
F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F4=Prompt  F5=Refresh  F10=View 1  F11=View 3  F12=Cancel
F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F4=Prompt  F5=Refresh  F10=View 2  F11=View 1  F12=Cancel
F17=Top  F18=Bottom  F20=Move to top
