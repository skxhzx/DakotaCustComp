      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *  Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *  BFC Software, Inc.
     *  245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *  West Chicago, IL  60185
     *  (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LB411   GS1-99 internal label - options
     *  01 April 2013
     *  Lynn McMahon
     *
     *  Revisions
     *
650aA*    04/01/13  LMC  650a
     *      - Created
     *
650b *    08/29/13  LMC  6.50b
     *      - Added process for CLAMS.
     *      This process creates the UCI record, linked to the
     *      receiving dakota License.
     *      No label is printed in this program.
     *      GS1-99 code is passed back to calling program for the
     *      printing of the label.
650c *    09/10/13  LMC  6.50c
     *      - Added Replacement label process for clams
650d *    09/11/14  LMC  6.50d
     *      - Change CW entry to assume decimals.
     *      - Add CW Variance checking and overrides.
     *
700aA*    04/01/16  LMC  7.00a
     *      - Enh: Adding logic for Metric.
     *      - changed display file to LB41102
720aA*    08/16/16  LMC  7.20a
     *      - Enh: UCI Tracking.
     *      - Enh: Populate parm values in DRIUICINFO
     *             for new UCIINFO file format.
730aA*    07/23/19  JCJ  7.30a
     *      - changed display file to LB41103
     *
740aA*    05/04/20  LMC  7.40a
     *      - Force CW items to go thru zzcnvwgt
740bA*    07/03/20  MLB  7.40b  ZD#2125
     *      - Enh: Changed @PRTPG to BFCPRTLBL from PRTLBL due to
     *        conflict with TL Ashford pgm of the same name.
740cA*    09/10/20  LMC  7.40c
     *      - Allow 7 pos weight to be used when doing assign commands
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (Reverse Display)
     *  40 - 50   Non display indicators
     *  90        View mode (Protect input fields)
     *  91        Change mode (Protect key)
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
650dDF*lb411fm   cf   e             workstn
700aDF*lb41101   cf   e             workstn
730aMF*lb41102   cf   e             workstn
740cDF*lb41103   cf   e             workstn
740cMFlb41104   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(msgrec8:msgk)
     Flblfmtd   if   e           k disk
650dAFoptions   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             60    dim(10) ctdata perrcd(1)
700aAD cmdln           s             79    dim(6)ctdata perrcd(1)

700aA*----------------------------------------------------------------
700aA* Function prototypes.
700aA*----------------------------------------------------------------

700aA /copy qcopysrc,p.getimuom

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

740bMD @prtpg          c                   const('BFCPRTLBL')
     D @plfmti         c                   const('GS1_99')
720aAD @cvtdt          c                   const('CVTDTE')

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
     D  $litem                22     36
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#slot
      /COPY *libl/qcopysrc,C#UCIINFO
      /COPY *libl/qcopysrc,C#LICINFO
     D savever#        s                   like($itver#)
720aAD slot$Item       ds                  likeds($Item)
720aAD slot$Item2      ds                  likeds($Item2)
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
650dDD*$mdt            ds
650dDD* errmsg                 1     50
     *
650dDD* eritem#                1     15
     D                 ds
650dDD* $ec                    1      2p 0
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
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *

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
     * Work Variables
     *----------------------------------------------------------------
     D $msgf           s             10
     D $plen           s              3  0
     D $pstr           s             60
     D $phdte          s              8  0
     D $phloc          s             20
     D $pcert          s             20
     D $pcode          s             10
     D $plbl#          s              7  0
     D $plic#          s             15
     D $pqty           s              5  0
     D $pprt           s             10
     D $pform          s             10
     D $ppo            s                   like($lnpo)
     D $pseq           s                   like($lnposeq)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D #rcvdesc        s                   like($itdesc)
     D chk4err         s               n
     D cmdtkn          s              1
     D CnvWgt          s              9  2
     d cwalpha         s              6
     d cwformat        s             10
650dAD cwtck           s              1
     d dtwork          s              8
     D e               s              2  0
     D error           s              1
650dAD exwgt           s              9  2
     D gs199fmt        s             50
650dAD hirng           s              9  2
650dAD hivar           s              9  2
650dAD hvskp           s              1
650dAD ihrng           s              9  2
650dAD ihvar           s              9  2
650dAD ilrng           s              9  2
650dAD ilvar           s              9  2
     d icmd            s              8
     d iwhse           s              3  0
     d iwhdp           s              5
     d idisp           s             12
     d ilcns           s             15
     d iitem           s             15
     d lotformat       s             22
650dAD lvskp           s              1
650dAD lwrng           s              9  2
650dAD lwvar           s              9  2
     D kgs2lbs         c                   2.20462262
700aAD KiloLbs         s              1
700aAD IMkilolbs       s              1
700aAD IMUom           s              3
     D msgk            s              4  0
     D nxtscr          s              3
     D nextChar        s              9
     D nextNum         s              9  0
650dAD opwrncflag      s              1
650dAD ovrrid          s              1
650dAD prg1c           s              4  3
650dAD prg2c           s              4  3
     D saveitem        s                   like(w1item)
     D sclear          s              1
650dAD svaddw          s              7  0
650dAD taddw           s              7  2
720aAD today           s              8  0
650dAD uciflg          s              1    inz('0')
     D warn            s              1
650dAD wkcode          s                   like(opcode)
     D wkprtf          s             10
     D wkstyp          s              1
     D wkwhdp          s              5
     D wkwhse          s              3  0
     D work1a          s              1
     D w1whse          s              3  0
     D forevr          s               n
     D lblcount        s              3  0
     D @plfmt          S              8
     D w1tst           s              3  0
     D @lblset         s              6
     D zmflag          s               n
     D zmsflag         s               n
650dA*----------------------------------------------------------------
650dA*  Data structure for error message parameters
650dA*
650dAD $mdt            ds
650dAD  errmsg                 1     50
650dA*
650dAD  erfld                  1     30
650dAD  erfrom                31     40
650dAD  erto                  41     50
650dA*
650dAD  ertcwt                 1      5p 2
650dAD  erlrng                 6     10p 2
650dAD  erhrng                11     15p 2
650dAD  errg1c                16     17p 1
650dAD  errg2c                18     19p 1
650dAD  erexwt                20     24p 2
650dAD  erum                  25     26
650dAD  erilrng               27     31p 2
650dAD  erihrng               32     36p 2
650dA*
650dA*
650dAD  ertcw#                 1      3p 0
650dAD  erqpck                 4      6p 0
650dA*
650dAD  erfld1                 1     20
650dAD  erfld2                21     40
650dAD  erflvl                41     42p 0
650dAD  erclvl                43     44p 0
650dAD                 ds
650dAD  $ec                    1      2p 0
650dA*----------------------------------------------------------------
650dA*  *SYSTEM  -  System options.
650dA*
650dA* Fields
650dA*
650dA*    OPEPM   -  Using EPM module (Y,N).
650dA*    OPRF    -  Using RF module (Y,N).
650dA*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
650dA*    OPLETD  -  Print letdown labels (Y,N).
650dA*    OPWRNC  -  Perform catch weight variance check (Y,N).
650dA*    OPRG1C  -  Catch weight low variance percentage.
650dA*    OPRG2C  -  Catch weight high variance percentage.
650dA*    OPIMPI  -  Import item fields from host.(Y,N).
650dA*    OPICW   -  Individual catch weight entry (Y,N).
650dA*    OPUCI   -  Use UCI processing (Y,N) ntry (Y,N).
650dA*
650dA* Data structure
650dA*
650dAD opdata          ds
650dAD  opepm                  1      1
650dAD  oprf                   2      2
650dAD  opcapc                 3      3
650dAD  opletd                 4      4
650dAD  opwrnc                 5      5
650dAD  oprg1c                 6      8  1
650dAD  oprg2c                 9     11  1
650dAD  opimpi                12     12
650dAD  opicw                 13     13
650dAD  opuci                 36     36
650dAD  optend               117    117
     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
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
     *  Prototypes
     *----------------------------------------------------------------

     D gs1seq#         pr                  extpgm('GS1SEQ#')
     D   unext                        9  0
     D   uwhse                        3  0 const

     D lt311           pr                  extpgm('LT311')
     D   icmd                         8
     D   iwhse                        3  0 const
     D   iwhdp                        5
     D   idisp                       12
     D   ilcns                       15
     D   iitem                       15

      /copy qcopysrc,p.cvtdte
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $whse             3
     C                   parm                    $prtn             8
     C                   parm                    $pitem           15
     C                   parm                    $qty              2 0
     C                   parm                    $dev             10
     C                   parm                    $form            10
     C                   parm                    $cmd             10
650bAC                   parm                    $lcns            15
650bAC                   parm                    $gs199fmt        12
     C     tagfmtP       plist
     C                   parm                    $pcmd
     C                   parm      $lnwhse       $pwhse
     C                   parm      $lnpo         $ppo
     C                   parm      $lnposeq      $pseq
     C                   parm      $lnitem       $pitem
     C                   parm      $itdesc       #rcvdesc
     C                   parm      $lnlcns       $plic#
     C                   parm      1             $pqty
     C                   parm      w2hdte        $phdte
     C                   parm      w2hloc        $phloc
     C                   parm      w2cert        $pcert
     C                   parm      $lnrcvlbl#    $plbl#
     C                   parm      w2dev         $pprt
     C                   parm      w2form        $pform
     *----------------------------------------------------------------
     *  Main line
     *
720aA*
720aA*  Convert today's date into century format.
720aA*
720aAC                   eval      $cvcmd = '*CURCMD '
720aAC                   call      @cvtdt
720aAC                   parm                    $cvtdt
720aAC                   eval      today = $cvd8o
     *
740cA /free
740cA   if $cmd = '*ASSIGN' or
740cA      $cmd = '*ASSIGNR';
740cA     *in47 = *on;
740cA   else;
740cA     *in47 = *off;
740cA   endif;
740cA /end-free
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = '1'
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
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
     C                   eval      *inlr = *on
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
     c                   Select
650bAc                   when      nxtscr = '01 ' and $cmd = '*DOCLAM  '
     c                   when      nxtscr = '01 ' and $cmd <> '*ASSIGNR'
     C                   exfmt     screen1                              50
     c                   when      nxtscr = '02 '
     C                   exfmt     screen2                              50
     c                   when      nxtscr = '01 ' and $cmd = '*ASSIGNR '
     C                   exfmt     screen1r8                            50
     c*                  other
     C*                  exfmt     screen1r8                            50
     C                   endsl
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       30
     C                   setoff                                       98
     C                   setoff                                       010203
     C                   setoff                                       0405
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
     *  Get existing record.
     *
     C                   exsr      zzfil1
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *
     *  Get existing record.
     *
     C                   exsr      zzfil2
     C     end02i        endsr
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
     C                   eval      $prtn = '*EXIT   '
     C                   eval      nxtscr = 'EOJ'
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
     C                   eval      $prtn = '*CANCEL '
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
     C                   exsr      zznxt1
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
     C                   eval      $prtn = '*EXIT   '
     C                   eval      nxtscr = 'EOJ'
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
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      $prtn = '*CANCEL '
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2
     C     error         cabeq     '1'           endsc2
     C                   exsr      zznxt2
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
650dA*
650dA*  Define key for OPTIONS file.
650dA*
650dAC     opkey         klist
650dAC                   kfld                    wkwhse
650dAC                   kfld                    wkcode
650dAC                   eval      wkcode = '*SYSTEM '
650dAC                   eval      wkwhse = 0
650dAC     opkey         chain     options                            79
650dAC                   if        *in79
650dAC                   eval      opcapc = 'Y'
650dAC                   eval      opwrnc = 'N'
650dAC                   eval      oprg1c = 0
650dAC                   eval      oprg2c = 0
650dAC                   eval      opicw = 'N'
650dAC                   endif
     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     C                   move      *on           forevr
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
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$licinfo  Clear $licinfo data structure fields
     *----------------------------------------------------------------

     C     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   clear                   $licinfo2
     C                   eval      $lnver# = savever#

     C                   eval      $lnuser = #user
     C                   eval      $lnemp# = e$emp#
     C                   eval      $lnpgm  = #prog
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobn

     C                   endsr

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$uciinfo  Clear $uciinfo data structure fields
     *----------------------------------------------------------------

     C     clr$uciinfo   begsr
     C                   eval      savever# = $uiver#
     C                   clear                   $uciinfo
720aAC                   clear                   $uciinfo2
     C                   eval      $uiver# = savever#
     C                   eval      $uiaddemp = e$emp#
     C                   eval      $uiaddusr = #user
     C                   eval      $uiaddpgm  = #prog
     C                   eval      $uiaddjob  = #job
     C                   eval      $uiaddnbr = #jobn
     C*                  eval      $uiwhse = $pwhse
     C*                  eval      $uiTowhseu = *on
     C                   endsr

     *----------------------------------------------------------------
     *  GetItem   Get Item using DRI programs
     *----------------------------------------------------------------

      /free
        begsr GetItem;
          // add dri to get data from itemfld
          exsr clr$item;

          $itWhse = W1whse;
          $ititem = W1item;

          $dricommand = '*ITEM';
          $drisubcmd  = '%GETALL';
          $drisys2upd = 'D';
          chk4err = *on;
          zmflag  = *off;
          exsr zzzdricop;
          if error = *on;
            errmsg = ' ';
            *in21 = *on;
            *in01 = *on;
            errmsg = desc(2);
            exsr zm1001;
          endif;
          if $itcwgt = 'Y';
            *in41 = *on;
            *in03 = *on;
700aA       // Get Item Maintenance options.
700aA       wkwhse = $itwhse;
700aA       getimuom(wkwhse: IMkilolbs: IMUom);
700aA       select;
700aA         when IMkilolbs = 'K';
700aA           KiloLbs = 'K';
700aA           W1KgLb  = IMUom;
700aA         other;
700aA           kiloLbs = 'P';
700aA           W1KgLb  = 'Lbs';
700aA       endsl;
650dA /end-free
650dAC                   eval      lwvar = 0
650dAC                   eval      hivar = 0
650dAC                   eval      lwrng = 0
650dAC                   eval      hirng = 0
650dAC                   eval      exwgt = 0
650dAC                   eval      ilvar = 0
650dAC                   eval      ihvar = 0
650dAC                   eval      ilrng = 0
650dAC                   eval      ihrng = 0
650dAC                   eval      prg1c = *zeros
650dAC                   eval      prg2c = *zeros
650dA**   Iniz. flag used to skip variance check if = *ON.
650dAC                   eval      lvskp = *off
650dAC                   eval      hvskp = *off
650dAc                   if        $imrg1c <> 0
650dAc     $imrg1c       div       100           prg1c
650dAc                   if        $imrg1c = 99
650dAc                   eval      lvskp = *on
650dAc                   endif
650dAc                   endif
650dAc*
650dAC                   if        $imrg2c <> 0
650dAC     $imrg2c       div       100           prg2c
650dAC                   if        $imrg2c = 99
650dAC                   eval      hvskp = *on
650dAC                   endif
650dAC                   endif
650dA*
650dAC                   if        prg1c = 0
650dAC     oprg1c        div       100           prg1c
650dAC                   endif
650dAC                   if        prg2c = 0
650dAC     oprg2c        div       100           prg2c
650dAC                   endif
650dAC                   if        prg1c > 0
650dAC     exwgt         mult      prg1c         lwvar
650dAC                   eval      ilvar = $itswgt * prg1c
650dAC                   endif
650dAC                   eval      lwrng = exwgt - lwvar
650dAC                   eval      ilrng = $itswgt - ilvar
650dAC                   if        prg2c > 0
650dAC     exwgt         mult      prg2c         hivar
650dAC                   eval      ihvar = $itswgt * prg2c
650dAC                   endif
650dAC     exwgt         add       hivar         hirng
650dAC     $itswgt       add       ihvar         ihrng
650dA /free
          else;
            *in41 = *off;
          endif;
700aA     exsr zzsetcmdln1;
          if $imlot = 'Y';
            *in42 = *on;
            *in04 = *on;
          else;
            *in42 = *off;
          endif;
        endsr;
      /end-free
     *----------------------------------------------------------------
     *  GetLicinfo  Get Licinfo data
     *----------------------------------------------------------------

      /free
        begsr GetLicInfo;
          exsr clr$licinfo;
          $lnwhse  = w1whse;
          $lnlcns  = iLcns;
          $dricommand = '*LICINFO';
          $drisubcmd  = '%GET';
          $drisys2upd = 'D';
          chk4err = *on;
          zmflag  = *off;
          exsr zzzdricop;
          if $drireturn = '*OK';
            w1lotc = $lnlot;
          endif;

        endsr;
      /end-free
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     c                   if        $cmd <> '*ASSIGNR'
     C                   write     msgctl
     c                   else
     C                   write     msgctl8
     c                   endif
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
     c                   if        $cmd <> '*ASSIGNR'
     C                   write     msgctl
     c                   else
     C                   write     msgctl8
     c                   endif
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
     c                   if        $cmd <> '*ASSIGNR'
     C                   write     msgrec
     c                   else
     c                   write     msgrec8
     c                   endif
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     c                   if        $cmd <> '*ASSIGNR'
     C                   write     msgrec
     c                   else
     C                   write     msgrec8
     c                   endif
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
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
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
     *      0110 - Starting number
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1006  Invalid jobq option for view report option.
     *
     C     zm1006        begsr
     C                   eval      #msgid = 'PIR1006'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
650dA*----------------------------------------------------------------
650dA*   PT13021  Warning: Entered catch weight not within +/- range.
650dA*
650dAC     zm21          begsr
650dAC                   eval      #msgid = 'PT13021'
650dAC                   eval      #msgtp = '*DIAG  '
650dAC                   movea     errmsg        $md
650dAC                   exsr      zmpmsg
650dAC                   endsr
     *----------------------------------------------------------------
     *  verifyslot verify slot is valid
     *----------------------------------------------------------------

      /free
        begsr verifyslot;

          exsr clr$slot;

          $slWhse = w1whse;
          $sldisp = w1disp;
          $slwhdp = w1whdp;

          $dricommand = '*SLOT';
          $drisubcmd  = '%GET';
          $drisys2upd = 'D';
          chk4err = *on;
          zmflag  = *off;
          exsr zzzdricop;
          if $drireturn = '*OK';
            w1item = $slitem;
          endif;

        endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
      /free
         error = *off;
         select;

           when $cmd = '*PRTPRE';

           when $cmd = '*PRTONE' or
                $cmd = '*ASSIGN' or
                $cmd = '*ASSIGNR';
             // uci can not already exist
             if w1gs199 <> ' ';
               exsr zzucick;
               if $drireturn = '*EXIST';
                 error = *on;
                 *in26 = *on;
                 *in06 = *on;
                 errmsg = desc(8);
                 exsr zm0105;
                 leavesr;
               endif;
             endif;
             if $cmd = '*ASSIGNR' and w1item = ' ';
             // verify slot
               exsr verifyslot;
               if $drireturn = 'INVLDSLOT';
                 error = *on;
                 *in27 = *on;
                 *in07 = *on;
                 errmsg = desc(9);
                 exsr zm0105;
                 leavesr;
               else;
                 icmd = '*VIEW';
                 ilcns = ' ';
                 iitem = ' ';
                 lt311(icmd:w1whse:w1whdp:w1disp:ilcns:iitem);
                 if ilcns > ' ';
                   w1item = iitem;
                   *in46 = *on;
                   *in43 = *off;
                   exsr getlicinfo;
                 else;
                   *in46 = *on;
                   *in43 = *off;
                 endif;
               endif;
             endif;
             if saveitem <> w1item or w1item = ' ';
               exsr GetItem;
               saveitem = w1item;
               //redisplay the screen with catch weight & lot
               if *in41 or *in42;
                 error = *on;
               endif;
             endif;
             // Catch weight entry
740cM        if w1dwgt <= *zeros  and *in41
740cA           and w1dwgt7 <= *zeros and *In41;
               error = *on;
               *in23 = *on;
               *in03 = *on;
               errmsg = desc(6);
               exsr zm0110;
             endif;
700aD        // catch weight entry type
700aD        //if w1wgttype <> 'LB'  and *in41
700aD           //and w1wgttype<> 'KG' and *in41;
700aD          //error = *on;
700aD          //*in25 = *on;
700aD          //*in05 = *on;
700aD          //errmsg = desc(7);
700aD          //exsr zm1001;
700aD        //endif;
650dA /end-free
650dA*     Check individual CW if variance check = Y.
650dA*     and UCI flag is off.
650dA*   CWTCK Flags are used to force F20 for each test
650dA*   Values: Flag = 0 Do check.
650dA*           Flag = 1 Check was done, ok.
650dA*           Flag = 2 Warning condition.
740cDC*                  if        w1dwgt <> *zero
740cMC                   if        w1dwgt <> *zero and *in47 = *off
740cAC                             or w1dwgt7 <> *zero and *in47 = *on
650dA*
740cDC*                  if        svaddw <> w1dwgt
740cMC                   if        svaddw <> w1dwgt and *in47 = *Off
740cAC                             or svaddw <> w1dwgt7 and *in47 = *On
650dAC                   eval      cwtck = *off
650dAC                   endif
650dA*
650dAC                   if        cwtck = '2'  and
650dAC                             ovrrid = *on
650dAC                   eval      cwtck = *on
650dAC                   endif
650dAC                   if        cwtck <> '1'
650dAC                   eval      cwtck = *on
740aDC*                  if        opwrnc     = 'M'
740aDC*                            and uciflg = *OFF
740aDC*                             or opwrnc     = 'B'
740aDC*                            and uciflg = *OFF
740aAc                   if        uciflg = *off
700AAC                   exsr      zzcnvwgt
700aDC*    w1dwgt        div       100           taddw
700aMC     cnvwgt        div       100           taddw
650dA*
650dAC                   if        lvskp = *off  and
650dAC                             taddw < ilrng
650dA
650dAC                   eval      error = *on
650dAC                   eval      warn = *on
650dAC                   eval      cwtck = '2'
650dAC                   eval      *in23 = *on
650dAC                   eval      *in03 = *on
650dAC                   eval      errmsg = *blanks
650dAC                   eval      ertcwt = taddw
650dAC                   eval      erlrng = ilrng
650dAC                   if        hvskp = *on
650dAC                   eval      erhrng = 0
650dAC                   else
650dAC                   eval      erhrng = ihrng
650dAC                   endif
650dAC     prg1c         mult      100           errg1c
650dAC     prg2c         mult      100           errg2c
650dAC                   eval      erexwt = $itswgt
650dAC                   exsr      zm21
650dAC                   endif
650dA*
650dAC                   if        hvskp = *off  and
650dAC                             taddw > ihrng
650dA
650dAC                   eval      error = *on
650dAC                   eval      warn = *on
650dAC                   eval      cwtck = '2'
650dAC                   eval      *in23 = *on
650dAC                   eval      *in03 = *on
650dAC                   eval      errmsg = *blanks
650dAC                   eval      ertcwt = taddw
650dAC                   if        lvskp = *on
650dAC                   eval      erlrng = 0
650dAC                   else
650dAC                   eval      erlrng = ilrng
650dAC                   endif
650dAC                   eval      erhrng = ihrng
650dAC     prg1c         mult      100           errg1c
650dAC     prg2c         mult      100           errg2c
650dAC                   eval      erexwt = $itswgt
650dAC                   exsr      zm21
650dAC                   endif
650dA*
650dAC                   endif
650dAC                   endif
650dAC                   endif
740cAc                   if        w1dwgt > 0
650dAC                   eval      svaddw = w1dwgt
740cAc                   endif
740cAc                   if        w1dwgt7 > 0
740cAC                   eval      svaddw = w1dwgt7
740cAC                   endif
650dA*
650dA /free

         endsl;
      /end-free
     *
     *  Verify Quantity
     *
     C                   if        w1qty  <= *zeros or w1qty  > 99
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0110
     C                   endif
     *
     *  Verify default device
     *
     C                   movel     w1dev         work1a
     C                   if        work1a = '*'  and
     C                             w1dev <> '*SYSVAL'  and
     C                             w1dev <> '*JOB'  or
     C                             w1dev = *blanks
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(4)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
     *  Verify default form type
     *
     C                   movel     w1form        work1a
     C                   if        work1a = '*'  and
     C                             w1form <> '*STD'  or
     C                             w1form = *blanks
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(5)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
      /free
         error = *off;
         select;

           when $cmd = '*RPLCLAM';
             // uci must already exist
             if w2gs199 <> ' ';
               gs199fmt = w2gs199;
               exsr zzucick;
               if $drireturn <> '*OK';
                 error = *on;
                 *in26 = *on;
                 *in06 = *on;
                 errmsg = desc(10);
                 exsr zm0105;
                 leavesr;
               endif;
             endif;
           other;
             error = *on;
             *in26 = *on;
             *in06 = *on;
             errmsg = desc(10);
             exsr zm0105;
             leavesr;
         endsl;
         if w2hdte = 0;
           // now load the information from licinfo
           if $uilcns <> ' ';
             ilcns = $uilcns;
             exsr GetLicinfo;
             if $drireturn = '*OK';
               w2hloc = $lnhrvloc;
               w2cert = $lnhrvcert;
               if $lnhrvdate > 0;
                 $cvcmd = '*CMDMDY ';
                 $cvd8i = %trimr(%editc($lnhrvdate:'X'));
                 cvtdte ($cvtdt);
                 w2hdte = $cvd6o;
               endif;
               w1whse = $lnwhse;
               w1item = $lnitem;
               exsr getitem;
             endif;
           endif;
           error = *on;
         endif;

      /end-free
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
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
     *     Prompt
     *
     C                   select
     *
     *     Item.
     *
     C                   when      row# = 10 and  $cmd <> '*ASSIGNR'
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     c                   eval      w1item = $litem
     c                   exsr      GetItem
     c                   eval      saveitem = w1item
     C                   endif
     *
     C                   when      row# = 04 and  $cmd = '*ASSIGNR'
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     c                   eval      w1item = $litem
     c                   exsr      GetItem
     c                   eval      saveitem = w1item
     C                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   endif
700aA*
700aA*      F7 - kilograms/Pounds toggle
700aA*
700aAC                   if        *inkg
700aAC                   eval      cmdtkn = *on
700aAC                   if        KiloLbs = 'P'
700aAC                   eval      KiloLbs = 'K'
700aAC                   eval      W1KgLb  = 'Kgs'
700aAC                   else
700aAC                   eval      KiloLbs = 'P'
700aAC                   eval      W1KgLb  = 'Lbs'
700aAC                   endif
700aAc                   exsr      zzsetcmdln1
700aAC                   goto      endcm1
700aAC                   endif
650dA*
650dA*      F20 - Accept Warning.
650dA*
650dAC                   if        *inku
650dAC                   eval      ovrrid = *on
650dAC                   else
650dAC                   eval      ovrrid = *off
650dAC                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
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
     *     Prompt
     *
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endif
     *
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCNVWGT  Setup converted weight field.
     *
     C     zzcnvwgt      begsr
     *
700aA* If item options is setup as kgs and user enters kgs no conversion
700aA* If item options is setup as kgs and user enters lbs need conversion
700aA* If item options is setup as lbs and user enters lbs no conversion
700aA* If item options is setup as lbs and user enters kgs need conversion
     *
700aA /free
700aA   select;
700aA     when IMkilolbs = 'K';
700aA       if KiloLbs = 'K';
740cA         if *in47;
740aA           eval cnvwgt = w1dwgt7;
740cA         else;
700aA           eval cnvwgt = w1dwgt ;
740cA         endif;
700aa       else;
740cA         if *in47;
740cA           eval(h) cnvwgt = w1dwgt7 / kgs2lbs;
740cA         else;
700aA           eval(h) cnvwgt = w1dwgt / kgs2lbs;
740cA         endif;
700aA       endif;
700aA     other;
700aA       if KiloLbs = 'K';
740cA         if *in47;
700aA           eval(h) cnvwgt = w1dwgt7 * kgs2lbs;
740cA         else;
700aA           eval(h) cnvwgt = w1dwgt * kgs2lbs;
740cA         endif;
700aA       else;
740cA         if *in47;
740cA           eval cnvwgt = w1dwgt7 ;
740cA         else;
700aA           eval cnvwgt = w1dwgt ;
740cA         endif;
700aA       endif;
700aA   endsl;
700aA /end-free
700aDC*                  eval(h)   cnvwgt = w1dwgt * kgs2lbs

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *   Initialize printer device/form
     *
     *      Get warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     w1whse        parm      0             #whse             3 0
     C                   eval      wkwhse = w1whse
     C                   eval      w1whdp = e$whdp
     *
      /free

         Select;

           // print generic batch of preprinted
           When $cmd = '*PRTPRE';
             // I JUST NEED TO KNOW A QTY AND PRINTER
             *in43 = *on;
             *in44 = *on;
           // print single label assigned to item
           When $cmd = '*PRTONE';
             // need to allow item,cw, lot entry before print
             // default qty to 1
             *in44 = *on;
             *in45 = *on;

           // assign item to pre printed label
           When $cmd = '*ASSIGN';
             // no printing just file updates, display item, cw, lot
             // allow the scan field to be entered
             *in44 = *off;
             *in43 = *off;
             *in46 = *on;
           // assign item to pre printed label
           When $cmd = '*ASSIGNR';
             // no printing just file updates, display item, cw, lot
             // allow the scan field to be entered
             *in44 = *off;
             *in46 = *off;
             *in43 = *on;
         endsl;
      /end-free
     C                   eval      w1item  = *blanks
     C                   eval      w1qty   = 1
     *
     C                   eval      w1dev = '*JOB    '
     C                   eval      w1form = '*STD    '
700aDC*                  eval      w1wgttype = 'LB'
     C                   eval      *in41 = *off
     C                   eval      *in42 = *off
     C                   eval      *in04 = *off
     C                   eval      *in03 = *off
700aAc                   exsr      zzsetcmdln1
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     *   Initialize printer device/form
     *
     *      Get warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     w1whse        parm      0             #whse             3 0
     C                   eval      wkwhse = w1whse
     C                   eval      w1whdp = e$whdp
     *
      /free

         Select;

           // relacement clam label
           When $cmd = '*RPLCLAM';
             // call clam print program
         endsl;
      /end-free
     C                   eval      w2gs199 = *blanks
     C                   eval      w2qty   = 1
     *
     C                   eval      w2dev = '*JOB    '
     C                   eval      w2form = '*STD    '
     *
     C                   endsr
700aA*----------------------------------------------------------------
700aA*
700aA*  ZZSETCMDLN1  Setup the command keys
700aa*
700aaC     zzsetcmdln1   begsr
700aA /free
700aA   select;
700aA     when $cmd = '*ASSIGNR ';
700aA       Select;
700aA         when $itcwgt <> 'Y';
700aA           cmdln1 = cmdln(6);
700aA         when kilolbs  = 'K';
700aA           cmdln1 = cmdln(5);
700aA         when kilolbs  = 'P';
700aA           cmdln1 = cmdln(4);
700aA       endsl;
700aA     other;
700aA       Select;
700aA         when $itcwgt <> 'Y';
700aA           cmdln1 = cmdln(3);
700aA         when kilolbs  = 'K';
700aA           cmdln1 = cmdln(2);
700aA         when kilolbs  = 'P';
700aA           cmdln1 = cmdln(1);
700aA       endsl;
700aA   endsl;
700aA /end-free
700aaC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for EQUIP file.
     *
     C     itkey         klist
     C                   kfld                    wkwhse
     C                   kfld                    w1item
     *
     c                   select
     c                   when      $cmd = '*PRTPRE'
     C                   eval      $pstr  = 'GS1-99 Barcode Print'
     c                   when      $cmd = '*PRTONE'
     C                   eval      $pstr  = 'GS1-99 Barcode Print & Assign'
     c                   when      $cmd = '*ASSIGN'
     C                   eval      $pstr  = 'GS1-99 Barcode Assign'
     c                   when      $cmd = '*ASSIGNR'
     C                   eval      $pstr  = 'Assign'
     c                   other
     C                   eval      $pstr  = 'GS1-99 Barcode'
     c                   endsl
     *
     c                   Select
     c                   When      $cmd = '*ASSIGNR'
     C                   eval      rptttl = $pstr
     c                   Other
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm      40            $plen
     C                   eval      rptttl = $pstr
     c                   endsl
     *
     C     *loval        setll     lblfmtd
     C                   dou       %eof(lblfmtd)
     C                   read      lblfmtd
     C                   if        not %eof(lblfmtd)
     C                   if        lfdfmt = @plfmti
     C                   eval      @lblset = lfdset
     C                   leave
     C                   endif
     C                   endif
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Get screen size being used.
     *
     C                   call      'PIRRFSCR'
     C                   parm      '*GET'        #lcmd             8
     C                   parm                    #lline            2
     C                   parm                    #lcol             3
      *
      * Get employee options.
      *
     C                   call      'GETUSER'
     C                   parm      #user         e$code           10
     C                   parm                    e$whse            3 0
     C                   parm                    e$emp#            5 0
     C                   parm                    e$fnam           15
     C                   parm                    e$init            1
     C                   parm                    e$lnam           20
     C                   parm                    e$whdp            5
     C                   parm                    e$styp            1
     C                   parm                    e$shft            6
     C                   parm                    e$crew            6
     C                   parm                    e$nhrs            3 1
     C                   parm                    e$rtn             8
     C                   parm                    e$bpu             1
     C                   parm                    e$lng             2
     C                   if        e$rtn <> '*OK'
     C                   eval      e$lng = 'EN'
     C                   endif
     *
     *   Select first screen to display.
     *
     c                   select
     c                   when      $cmd = '*RPLCLAM'
     C                   exsr      scr02i
     c                   other
     C                   exsr      scr01i
     c                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZNXT1   What to do next when screen 1 input is ok.
     *
     C     zznxt1        begsr
     *
     * label type
     C                   eval      @plfmt = @plfmti
     *
     C                   eval      lblcount = *zeros
     *
     C                   dow       forevr = forevr
      /free
        Select;
          When $cmd = '*PRTPRE';
            // need to get next unique seq#
           gs1seq#(nextNum: w1whse);
           nextChar = %editc(nextNum:'X');
           gs199fmt = '99I' + nextChar;
           exsr zzucick;
           // If the uci already exists - get another number
           if $drireturn = '*EXIST';
             iter;
           endif;

          When $cmd = '*PRTONE';
            // need to get next unique seq#
            gs1seq#(nextNum: w1whse);
            nextChar = %editc(nextNum:'X');
            cwalpha = ' ';
            lotformat = ' ';
            if w1dwgt > 0;
              cwalpha = %editc(w1dwgt:'X');
            endif;

            select;
700aD         //when w1wgttype = 'LB' and w1dwgt > 0;
700aM         when kilolbs = 'P' and w1dwgt > 0;
                cwformat = '3202' + cwalpha;
700aD         //when w1wgttype = 'KG' and w1dwgt > 0;
700aM         when kilolbs = 'K' and w1dwgt > 0;
                cwformat = '3102' + cwalpha;
              other;
                cwformat = ' ';
            endsl;

            if w1lotc <> ' ';
              lotformat = '10' + w1lotc;
            endif;
            gs199fmt = '99I' + nextChar + ' ' + %trim(cwformat);
            // now create the uci record
            exsr zzuci;
            // If the uci already exists - get another number
            if $drireturn = '*EXIST';
              iter;
            endif;
            // if a U: license was created for PRTONE we no longer put the
            // lot# into the barcode. must go update the
            // licinfo record with the lot#
            if $uiucilcns = $uilcns and w1lotc <> ' ';
              exsr clr$licinfo;
              $lnwhse  = $uiwhse;
              $lnlcns  = $uiLcns;
              $lnlot = w1lotc;
              $dricommand = '*LICINFO';
              $drisubcmd  = '%CHANGES';
              $drisys2upd = 'D';
              chk4err = *on;
              zmflag  = *off;
              exsr zzzdricop;
            endif;

          When $cmd = '*ASSIGN' or
               $cmd = '*ASSIGNR';
            // now create the uci record
            exsr zzuci;
            // if a U: license was created for a pre printed label that
            // does not contain the lot# in the barcode, must go update the
            // licinfo record with the lot#
            if $uiucilcns = $uilcns and w1lotc <> ' ';
              exsr clr$licinfo;
              $lnwhse  = $uiwhse;
              $lnlcns  = $uiLcns;
              $lnlot = w1lotc;
              $dricommand = '*LICINFO';
              $drisubcmd  = '%CHANGES';
              $drisys2upd = 'D';
              chk4err = *on;
              zmflag  = *off;
              exsr zzzdricop;
            endif;
            leave;

650bA     When $cmd = '*DOCLAM';
650bA       // need to get next unique seq#
650bA       gs1seq#(nextNum: w1whse);
650bA       nextChar = %editc(nextNum:'X');
650bA       gs199fmt = '99I' + nextChar;
650bA       exsr zzucick;
650bA       // If the uci already exists - get another number
650bA       if $drireturn = '*EXIST';
650bA         iter;
650bA       endif;
650bA       // now create the uci record
650bA       exsr zzuci;
650bA       leave;
          When $cmd = '*RPLCLAM';
            // need to get next unique seq#
            gs1seq#(nextNum: w1whse);
            nextChar = %editc(nextNum:'X');
            gs199fmt = '99I' + nextChar;
            exsr zzucick;
            // If the uci already exists - get another number
            if $drireturn = '*EXIST';
              iter;
            endif;
            // now create the uci record
            exsr zzuci;
            leave;
        endsl;
      /end-free
     *
     C                   call      @prtpg
     C                   parm      '*GS1  '      $pcmd             8
     C                   parm      @lblset       $plset            6
     C                   parm      @plfmti       $plfmt            8
     C                   parm      wkwhse        $pwhse            3 0
     C                   parm      *blanks       $pwhsd           30
     C                   parm      *blanks       $pwhdp            5
     C                   parm                    $pdisp           12
     C                   parm      *blanks       $pdispa           1
     C                   parm      *blanks       $pdispb          11
     C                   parm                    $pchkd1           3
     C                   parm      *blanks       $pchkd2           3
     C                   parm      *blanks       $pchkd3           3
     C                   parm      *blanks       $plcn#           15
     C                   parm      *blanks       $plcn2           15
     C                   parm      *blanks       $pitm#           15
     C                   parm      *blanks       $pbrnd           10
     C                   parm      *blanks       $ppdsc           15
     C                   parm      *blanks       $pdesc           30
     C                   parm      *blanks       $ptxt1           30
     C                   parm      *blanks       $ptxt2           30
     C                   parm      *blanks       $ptxt3           30
     C                   parm      *blanks       $ptrail           8
     C                   parm      *blanks       $psize            3
     C                   parm      w1dev         $pdev            10
     C                   parm      w1form        $pform           10
     C                   parm      *blanks       $pexpd            8
     C                   parm      *blanks       $pindt            8
     C                   parm      gs199fmt      $gs199           23
     *
     C                   eval      lblcount = lblcount + 1
     *
     C                   if        lblcount = w1tst
     C                   eval      $pcmd = *blanks
     C                   endif
     *
     C                   if        lblcount >= w1qty
     C                   leave
     C                   endif
     *
     C                   enddo
     *
     C                   eval      nxtscr = 'EOJ'
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZNXT2   What to do next when screen 2 input is ok.
     *
     C     zznxt2        begsr
     *
     * call TAGFMT
     *
500cA* Print clam tags

500cAC                   call      'TAGFMT'      tagfmtP

     C                   eval      nxtscr = 'EOJ'
     C                   endsr
     *
     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $dridata = $uciinfo
720aAC                   eval      $dridata2 = $uciinfo2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   eval      $dridata2 = $licinfo2
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*LICINFO'
720aAC                             or $dricommand = '*UCIINFO'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      chk4err and %error
     C                   eval      error = *on

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $uciinfo = $dridata
720aAC                   eval      $uciinfo2 = $dridata2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
     C                   eval      $licinfo2 = $dridata2
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr
     *----------------------------------------------------------------
     *  ZZUCI     Load UCI for gs199 label
     *----------------------------------------------------------------

      /free
        begsr zzuci;

          // check to make sure UCI barcode does not already exist
          exsr zzucick;
          // if return is *EXIST seton error
          if $drireturn = '*EXIST';
            leavesr;
          endif;
          exsr clr$uciinfo;

          $uiWhse = w1whse;
          Select;
            when $cmd = '*ASSIGN' or
                 $cmd = '*ASSIGNR';
              $uiuci  = w1gs199;
650bA       when $cmd = '*DOCLAM';
650bA         $uiuci  = gs199fmt;
650bA         $uiitem = $pitem;
650bA         $uilcns = $lcns;
650bA         $gs199fmt = gs199fmt;
650bA       other;
              $uiuci  = gs199fmt;
650bA     endsl;
650bA     if $pitem = ' ';
            $uiitem = w1item;
650bA     endif;

          // load selected license from slot lookup
          if ilcns <> ' ';
            $uilcns = ilcns;
          endif;

700aA     select;
700aA     when IMkilolbs = 'K';
700aA       $uiwgtlbs = %dech(cnvwgt/100: 11: 2);
700aA       $uiwgtkgs = %dech(cnvwgt/100: 11: 2);
700aA     other;
700aA       $uiwgtlbs = %dech(cnvwgt/100: 11: 2);
700aA     endsl;
700aD     //if w1wgttype = 'LB';
650dD       //$uiwgtlbs = w1dwgt;
700aD       //$uiwgtlbs = w1dwgt / 100;
700aD     //else;
700aD       //$uiwgtkgs = w1dwgt;
700aD       //if w1dwgt > 0;
700aD         //exsr zzcnvwgt;
700aD         //$uiwgtlbs = cnvwgt;
700aD       //endif;
700aD     //endif;
650bA     select;
650bA       when $cmd = '*DOCLAM';
650bA         $uiCrtBy  = '1';
650bA       other;
              $uiCrtBy  = '4';
650bA     endsl;
720aA    $uiautyp  = 'N';
720aA    $uiaSlUTyp = 'N';
720aA    $uiaEntD  = today;
720aA   // Lets add some more stuff for tracking
720aA   $uiaction = 'CREATE';
720aA   $uiaolcns = $uilcns;
720aA   $uialcns = $uilcns;
720aA   $uiaoseq = $uiseq;
720aA   $uiscan = 'Y';


          $dricommand = '*UCIINFO';
          $drisubcmd  = '%ADDGS199';
          $drisys2upd = 'D';
          chk4err = *on;
          zmflag  = *off;
          exsr zzzdricop;
          // if return is *EXIST seton error
          if error = *on;
            leavesr;
          endif;

        endsr;
      /end-free
     *----------------------------------------------------------------
     *  ZZUCIck   Check to make sure uci gs199 label doesn't exist
     *----------------------------------------------------------------

      /free
        begsr zzucick;

          // check to make sure UCI barcode does not already exist
          if gs199fmt <> ' ' or w1gs199 <> ' ';
            exsr clr$uciinfo;

            $uiWhse = w1whse;
            Select;
              when $cmd = '*ASSIGN' or
                   $cmd = '*ASSIGNR';
                $uiuci  = w1gs199;
                $drisubcmd  = '%CHKASGN';
              when $cmd = '*RPLCLAM';
                $uiuci  = gs199fmt;
                $drisubcmd  = '%CHKGS199';
              other;
                $uiuci  = gs199fmt;
                $drisubcmd  = '%CHKACTV';
            endsl;
            $uiitem = w1item;

            $dricommand = '*UCIINFO';
            $drisys2upd = 'D';
            chk4err = *on;
            zmflag  = *off;
            exsr zzzdricop;
            // if return is *EXIST seton error
            if $drireturn = '*EXIST';
              leavesr;
            endif;
          endif;

        endsr;
      /end-free
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Item
Item not found
Quantity
Printer device
Form type
Catch Weight
Catch Weight Type  LB or KG
UCI label already Assigned
Invalid Slot
GS1-99 Is Invalid
**  CMDLN - Command display line 700a
F3=Exit  F4=Select  F5=Refresh  F7=Kilogram    F12=Cancel  F20=Override
F3=Exit  F4=Prompt  F5=Refresh  F7=Pounds      F12=Cancel  F20=Override
F3=Exit  F4=Select  F5=Refresh  F12=Cancel F20=Override
F3=Exit  F4=Select  F7=Kgs  F12=Cancel  F20=Override
F3=Exit  F4=Prompt  F7=Lbs  F12=Cancel  F20=Override
F3=Exit  F4=Select  F12=Cancel F20=Override
