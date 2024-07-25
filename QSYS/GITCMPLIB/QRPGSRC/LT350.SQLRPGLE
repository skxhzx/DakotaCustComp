      /copy *libl/qcopysrc,hspecs
     H dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LT350   License History summary
     *  02 July  2020
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
740 A*    07/02/20  LMC  7.40
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position cursor
     *  21 - 29   Field input error (Reverse display)
     *  64        Reverse image breakdown text on SCANREC.
     *  76        Error indicator on write to SLTRPEX.
     *  79        Chain indicator
     *  90        Protect input fields for delete display
     *  97        Always ON (Used for SFLEND keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     FLT350fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(d16sfl:recno)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(m16rec:msgk)
     Fworkopt   uf a e           k disk
     Fworkusr3  uf a e           k disk
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
     D cmdln           s             79    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------
     D @getcl          c                   const('GETCLIENT')


     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
     D saveVer#        s                   like($itver#)
     D save$item       s                   like($item)


     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     D blanks          s            100    inz(' ')

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.cvtqty

     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1    100

     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  slwhse                 1      3  0 inz(0)
     D  slitem                 4     18
     D  slstat                19     20
     D  slpick                21     21
     D  slprty                22     22  0 inz(0)
     D  slexpd                23     30  0 inz(0)
     D  slentd                31     38  0 inz(0)
     D  slwhdp                39     43
     D  slstyp                44     44
     D  slaisl                45     47
     D  slpseq                48     52  0 inz(0)
     D  slrlvl                53     54  0 inz(0)
     D  slhand                55     56
     *
     D                 ds
     D  dsukey                 1     50
     D  ukwhse                 1      3  0 inz(0)
     D  ukwhdp                 4      8
     D  ukdisp                 9     20
     D  ukitem                21     35
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @chgpg          c                   const('NONE')
     D @vewpg          c                   const('NONE')
     D @delpg          c                   const('NONE')
     D @prtpg          c                   const('NONE')
     D @addtr          c                   const('ADDSTDTRN')
     D @addt2          c                   const('ADDSTDTRN2')
     D @adjtd          c                   const('ADJTSKDET')
     D @adjtr          c                   const('ADJTRAN  ')
     D @sltdt          c                   const('UPDSLTDTE')
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
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $pwhdp                22     26
     D  $pdisp                27     38
     D  $pitem                39     53
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
     *  API programs
     *
     D @apics          c                   const('APICVTSLT ')
     *----------------------------------------------------------------
     *  Working fields.
     *
     D                 ds
     D  lottrk                 1      4
     D  lictrk                 5      8
     D llp01           c                   const('Escanda licencia  ')
     D llp02           c                   const('Escn numero de lot')
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
     *
     *                                      16  27 ERDISP
     D  erdisp                 1     12
     *
     D  erdmsg                 1     60
     D  erdrtn                61     70
     D  erdcmd                71     80
     D  erdsub                81     90
     D                 ds
     D  $ec                    1      2p 0
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     *----------------------------------------------------------------
     *
     D                 ds
     D  wkyy                   3      4
     D  wkmm                   5      6
     D  wkdd                   7      8
     D  wkexpd                 1      8  0
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
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
     D cfkey                 369    369
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
     D  #pgm             *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobnbr              264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     D  #curruser            358    367

     *----------------------------------------------------------------
     *  Tracking variables
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,c#trackvar

     *----------------------------------------------------------------
     *  Variables
     *

     D ithead          s             65

     D $msgf           s             10
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D act             s              3
     D a58             s             58
     D append1         s              1
     D append5         s              5
     D bot             s              1
     D cancel          s              1
     D chk4err         s               n
     D ckexpd          s                   like(today)
     D ckentd          s                   like(today)
     D ck4err          s              1
     D clear           s              5  0
     D comand          s              5  0
     D cqerm           s             60
     D cqqty1          s              7  0
     D cqqty2          s              7  0
     D cqqty3          s              7  0
     D cqrtn           s              8
     D cqum1           s              2
     D cqum2           s              2
     D cqum3           s              2
     D cqustr          s             17
     D drierr          s              1
     D drizm           s              1
     D dsplyd          s              2  0
     D dspwin          s              4
     D e               s              2  0
     D eacube          s                   like($itcube)
     D easwgt          s                   like($itswgt)
     D first           s               n
     D fmentd          s              8  0
     D fmexpd          s              8  0
     D forceb          s              1
     D forevr          s              1
     D frstky          s                   like($puky)
     D fvslot          s              1
     D goback          s              2  0
     D hasvs           s              1
     D help            s              5  0
     D hldvsl          s             12
     D kyitem          s                   like($ititem)
     D lastrrn         s                   like(recno)
     D msgk            s              4  0
     D msgtyp          s              8
     D nomore          s              1
     D noslt           s              1
     D nxtscr          s              3
     D offlag          s              1
     D optcnt          s              3  0
     D optln1          s             75
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
     D partial         s               n
     D recno           s              4  0
     D recpos          s                   like(recno)
     D redspl          s              1
     D refrsh          s              1
     D repos           s              1
     D rltype          s                   like($ittype)
     D rolldn          s              5  0
     D rollup          s              5  0
     D rtvslt          s              4
     D scannedSlot     s               n
     D sclear          s              1
     D sortorder1      s             10    inz(' ')
     D stop            s              1
     D sqlgroup        s                   like(sqlorder)
     D t1              s              7  0
     D t2              s              7  0
     D t3              s              7  0
     D t#task          s              6
     D tempa2          s              2
     D tmpbeg          s              4  0
     D tmpend          s              4  0
     D today           s              8  0
     D top             s              1
     D topick          s              5  0
     D trndte          s              8  0
     D trntim          s              6  0
     D tstdte          s                   like(today)
     D view            s              1  0
     D woavl1          s              5  0
     D worqty          s              5  0
     D woslt           s             12
     D w1aqty10        s             10    inz(' ')
     D w1ldspFull      s             15
     D w1ldspFullNone  s             15    inz('-------')
     D licLen          s              3  0
     D zmsflag         s               n
     d lcnsScan        s               n
     D SubfilePage     s              1  0


     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z

     D bfcoffset       s              3  0 inz(0)
     D md              s               z

     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D liclog        e ds

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  SQL fetch fields
     *----------------------------------------------------------------

     D sqlfile         c                   'LICLOG'
     D sqlfields       c                   'SUM(LLAQTY1), SUM(LLAQTY2), +
     D                                      SUM(LLAQTY3), LLACTION, +
     D                                      MAX(LLADDUC) AS MD'


     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $iWhse   Warehouse
     *      $iItem   Item number
     *      $ilcns     License
     *
     *    Returned Parameters
     *      $iReturn   *Exit
     *                 *Cancel
     *                 *OK
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $iWhse            3 0
     C                   parm                    $iItem           15
     C                   parm                    $iReturn          8
     C                   parm                    $ilcns           15
      **

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
     C                   eval      $iReturn = *blanks
     C                   exsr      zzinz2
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   exsr      clrsch
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
     *   Set OFF command key indicators
     *
     C                   setoff                                       kckekf
     C                   setoff                                       kl
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *
     *   Overlay screen with subfile screen
     *
     C                   if        nxtscr = '01 '
     c                   eval      w1lcns = $ilcns
     C                   exsr      sfldsp
     C                   select
     C                   when      e$lng = 'EN' and #lline = '16'
     C                   read      po16nrec                               50
     C                   read      sc16rec                                50
     C                   other
     C                   read      postnrec                               50
     C                   read      scanrec                                50
     C                   endsl
     C                   endif
     *
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       2021
     C                   setoff                                       0323
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cancel = *off
     C                   eval      redspl = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *

     C                   select
     C                   when      #lline = '16'
     C                             and e$lng = 'EN'
     C                   read      d16sfc                                 50
     C                   when      #lline <> '16'
     C                             and e$lng = 'EN'
     C                   read      dspsfc                                 50
     C                   endsl
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
      /free
         exsr inzcriteria1;
         exsr setcriteria1;
         // Do initial build and display of subfile

         exsr sflBldDisp;

      /end-free
     C*                  exsr      pag01
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
      /free
        // Process subfile until user wants to leave

        dou (cfkey = F3) or (cfkey = F12);
          *in90 = *off;
          select;
            // PageDown = More records

            When cfkey = PageDown;
              exsr sflbld1;
              if sqlstt = sqlNoMoreData;
                leavesr;
                *in90 = *on;
              endif;
            When cfkey = Enter;
              leave;
          endsl;
         EndDo;

         ExSr sqlclean;
      /end-free
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
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     *
     *   Get screen size being used.
     *
     C                   call      'PIRRFSCR'
     C                   parm      '*GET'        #lcmd             8
     C                   parm                    #lline            2
     C                   parm                    #lcol             3
     *
     *
     *  Initialize special keys
     *
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

     C                   select
     C                   when      e$lng = 'EN' and #lline = '16'
     C                   write     d16sfl                               79
     C                   other
     C                   write     dspsfl                               79
     C                   endsl
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ChkCnt   Check option count, can't select > 1
     *
     C     chkcnt        begsr
     C     wkoprt        setll     workopt
     C     wkoprt        reade     workopt                              7979
     C                   if        not *in79
     C                   eval      optcnt = 1
     C                   endif
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
     C                   eval      optcnt = *zeros
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CMD01    Screen 1 command key routine
     *
     C     cmd01         begsr
     *
     *  TEST FOR F3 - EXIT
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $iReturn = '*EXIT   '
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR F12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $iReturn = '*CANCEL '
     C                   goto      cmd01e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *
     *  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     *
     C                   if        dsplyd > 0
     C     error         cabeq     '1'           cmd01e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     *   Process non-standard function keys.
     *
     C                   exsr      zzcmd
     C     cmd01e        endsr
     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     C     ent01         begsr
     *
     *  VERIFY AND SAVE OPTIONS
     *
     C                   if        dsplyd > 0
     C     error         cabeq     '1'           ent01e
     C                   endif
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           ent01e
     C     redspl        cabeq     *on           ent01e
     C     cancel        cabeq     *on           ent01e
     *

     C                   eval      $iReturn = '*OK     '
     *
     C                   eval      nxtscr = 'EOJ'
     C                   goto      ent01e
     *
     *
     *  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     *
     C                   exsr      optns
     C     ent01e        endsr
     *
     *----------------------------------------------------------------
     *
     *  INZPAR   Initialize parameters for calling add/chg/del program
     *
     C     inzpar        begsr
     C                   clear                   $parms
     C                   eval      $pprg = #prog
     C                   move      $prtky        $puky
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     C                   eval      otaken = *off
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
     *
     C                   select
     *
     *
     *   View
     *
     C                   when      wkoopt = ' 5'
     C                   eval      $pcmd = '*VIEW   '
     C                   call      @vewpg
     C                   parm                    $parms
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
     *
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
     C                   eval      offlag = *off
     C                   eval      p = 0
     *
     *  GET 8 RECORDS TO DISPLAY
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETNEXT'
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      bot = *on
     *
     *
     C                   goto      endfwd
     C                   endif
     *
     *  RECORD READ - STOP AFTER 8 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
     *
     *    Display is configured to display 1 overflow slot at a time.
     *
     *
     C                   if        recno >= 3  and
     C                             #lline <> '16'  or
     C                             recno >= 8   and
     C                             #lline = '16'
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   endif
     C                   endif
     C     endfwd        tag
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
     *    Display is limited to one overflow location at a time.
     C                   if        offlag = *on
     C     dsplyd        add       1             goback
     C                   else
     C                   select
     C                   when      #lline = '16'
     C     dsplyd        add       10            goback
     C                   other
     C     dsplyd        add       3             goback
     C                   endsl
     C                   endif
     C                   if        bot = '1'
     C                   if        goback = 3  and
     C                             #lline <> '16'  or
     C                             goback = 10  and
     C                             #lline = '16'
     C                   eval      forceb = *on
     C                   endif
     C                   eval      $pocmd = '*BOTTOM '
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
     C                   if        dsplyd > 0
     C     error         cabeq     '1'           rol01e
     C                   endif
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   if        dsplyd > 0
     C     error         cabeq     '1'           rol01e
     C                   endif
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     C     rol01e        endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     C                   add       1             recno
     C                   z-add     recno         y
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
     C                   exsr      sflfill1
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   write     d16sfl
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   write     dspsfl
     C                   endsl
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
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   write     d16sfc
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   write     dspsfc
     C                   endsl
     C                   eval      recno = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     C                   select
     C                   when      #lline = '16'
     C                   write     c16rec
     C                   other
     C                   write     cmdrec
     C                   endsl
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   select
     C                   when      #lline = '16'
     C                   other
     C                   endsl
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     C                   select
     C                   when      e$lng = 'EN' and #lline = '16'
     C                   write     po16nrec
     C                   other
     *
     C                   write     postnrec
     C                   endsl
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> '1'
     C                             and dsplyd > 0
     *
     C                   if        dsplyd > 0
     C                   eval      *in81 = *on
     C                   else
     C                   eval      *in81 = *off
     C                   endif

     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   endsl
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   update    d16sfl
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   update    dspsfl
     C                   endsl
     C                   endif


     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on

     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   write     d16sfc
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   write     dspsfc
     C                   endsl

     *
     C                   select
     C                   when      e$lng = 'EN' and #lline = '16'
     C                   write     sc16rec
     C                   other
     C                   write     scanrec
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
     C     1             do        dsplyd        x


     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C     x             chain     d16sfl                             79
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C     x             chain     dspsfl                             79
     C                   endsl


     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   eval      *in21 = wkoerr
     C                   eval      *in85 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   eval      *in85 = *off
     C                   endif



     C                   select
     C                   when      #lline = '16'  and
     C                             e$lng = 'EN'
     C                   update    d16sfl
     C                   when      #lline <> '16'  and
     C                             e$lng = 'EN'
     C                   update    dspsfl
     C                   endsl


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
     C                   select
     C                   when      #lline = '16'
     C                   write     m16ctl
     C                   other
     C                   write     msgctl
     C                   endsl
     C                   eval      msgk = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   select
     C                   when      #lline = '16'
     C                   write     m16clr
     C                   other
     C                   write     msgclr
     C                   endsl
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   select
     C                   when      #lline = '16'
     C                   write     m16ctl
     C                   other
     C                   write     msgctl
     C                   endsl
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
     C                   select
     C                   when      #lline = '16'
     C                   write     m16rec
     C                   other
     C                   write     msgrec
     C                   endsl
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   select
     C                   when      #lline = '16'
     C                   write     m16rec
     C                   other
     C                   write     msgrec
     C                   endsl
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   select
     C                   when      #lline = '16'
     C                   other
     C                   endsl
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
     *
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         begsr


     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     *
     C                   eval      action = llaction

     *
     C                   endsr


     *----------------------------------------------------------------
     *  ZZGETITEM     Get Item Information
     *----------------------------------------------------------------

     C     zzgetitem     begsr

     *  Get item.

     C                   exsr      clr$item
     C                   eval      $itwhse  = $iwhse
     C                   eval      $ititem  = $iItem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        drierr = *on
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   endif


     *  Create heading description.

     C                   call      'FRMTIT'
     C                   parm                    $ititem
     C                   parm                    $itdesc
     C                   parm                    $itpdsc
     C                   parm      ' '           ithead

     C     endgetitem    endsr




     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   eval      forevr = *off
     C                   eval      worow = *zeros
     C                   eval      wocol = *zeros
     C                   eval      msgtyp = *blanks
     *
     *  Define unique file key.
     *
     C     filuky        klist
     C                   kfld                    ukwhse
     C                   kfld                    ukwhdp
     C                   kfld                    ukdisp
     *
     *  Setup option and command display lines.
     *
     C                   eval      optln1 = optln(1)
     C                   eval      cmdln1 = cmdln(1)
     *
     C                   eval      $pprg = #prog
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Initailization for each time program is called.
     *
     C     zzinz2        begsr
     C                   eval      view = 1
     *
     *   Get employee options.
     *
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
     C                   eval      kyitem = $iItem
     *
     *   Get item description.
     *
     C                   exsr      zzgetitem
     *
     C                   exsr      clrsch
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     C     zzopt         begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *  See if user is trying to position to a certain spot
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     C     zzpos2        begsr
     *
     *    Code to use when we are not using a partial key.
     *
     *
     *    Code to use when we do have a partial key to use.
     *
     C                   endsr
     *
     *----------------------------------------------------------------

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

     C                   eval      $dricommand = '*SLOT'
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
     C                   eval      drierr = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
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
     C                   eval      drierr = *on
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
     C                   eval      drierr = *on
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
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr


     *----------------------------------------------------------------
     *  inzcriteria1 - Initialize criteria 1 values.
     *----------------------------------------------------------------

      /free
       begsr inzcriteria1;

         //if $iwhse = 0;
           //w1whse = 0;
         //else;
           //w1whse = $iwhse;
         //endif;

         //if $iitem = ' ';
           //w1item = '*ALL';
         //else;
           //w1item = $iitem;
         //endif;

         if $ilcns = ' ';
           w1lcns = '*ALL';
         else;
           w1lcns = $ilcns;
           //w1sort = 'A';
           //w1oby = '2';
         endif;


       endsr;
      /end-free

     *----------------------------------------------------------------
     *  setcriteria1 - Set criteria 1 values.
     *----------------------------------------------------------------

      /free
       begsr setcriteria1;

         sortorder1 = 'ASCEND';

         // Create screen heading.

         append1 = ' ';

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflBldDisp   Build and display subfile
     *----------------------------------------------------------------

      /free
       begsr sflBldDisp;

         exsr sqlclean;
         exsr sqlbldstmt1;
         exsr sqlprep;
         exsr sflclr;
         exsr sflbld1;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflbld1 - Build the subfile
     *----------------------------------------------------------------

      /free
       begsr sflbld1;

         recno = Lastrrn;
         recpos = lastrrn;
         first = *on;
         if #lline = '08';
           subfilePage = 3;
         else;
           subfilePage = 8;
         endif;

         // Process the records in the SQL cursor until the return not = 0

         for i = 1 to subfilePage;

           *in90 = '0';
           // Get the next row from the SQL cursor.

           exec sql FETCH NEXT FROM mycsr INTO :t1, :t2, :t3, :llaction, :md;

           If sqlstt = sqlSuccess;
             exsr sfladd;
               if first;
                 first = *off;
                 recpos = recno;
               endif;
           else;
             *in90 = '1';
             leave;
           endif;

         endfor;

         if recno= 0;
           *in32 = *on;
           *in81 = *off;
         else;
           *in81 = *on;
           lastrrn = recno;
         endif;

         if sqlstt = sqlNoMoreData;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sflFill1  -  Fill subfile line
     *----------------------------------------------------------------

      /free
       begsr sflFill1;

         // Store hiddent fields that aren't displayed on screen.


         // Format action quantity string

         cqqty1 = t1;
         cqqty2 = t2;
         cqqty3 = t3;
         cvtqty('*QTY2STR': #pgm:
                cqqty1: cqqty2: cqqty3:
                cqum1: cqum2: cqum3:
                w1aqty10: cqustr: cqrtn: cqerm);
         sumqty = %triml(w1aqty10);
         evalr sumqty = %trimr(sumqty);

         // Format result quantity string

         lastdate = %dec(%date(MD):*MDY);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sqlclean - Clean up before exiting
     *----------------------------------------------------------------

      /free
       begsr sqlclean;

         // Close the SQL cursor after all processing is complete.

         exec sql CLOSE mycsr;

         sqlstt = sqlstt;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sqlprep - Prepare SQL cursor
     *
     *    Note: This routine must come before any other routine
     *          using an SQL statement because it declares the
     *          SQL Cursor being used.
     *----------------------------------------------------------------

      /free
       begsr sqlprep;

         // Prepare the SQL statement for validation, since the program was
         // compiled with DLYPRP (*YES), it will wait until it is used before
         // it prepares th cursor.

         exec sql PREPARE sel FROM :SqlStmt;

         sqlstt = sqlstt;

         // Declare the SQL cursor to hold the data retrieved from the SELECT

         exec sql DECLARE MYCSR SCROLL CURSOR FOR SEL;

         sqlstt = sqlstt;

         // Open the SQL cursor.

         exec sql OPEN MYCSR;

         sqlstt = sqlstt;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  sqlbldstmt1 - Build SQL statment
     *----------------------------------------------------------------

      /free
       begsr sqlbldstmt1;

         // Create "From" clause.

         sqlfrom = 'FROM ' + sqlfile;

         // Create "where" clause.

         sqlwhere = ' ';
         append5  = 'WHERE';

         // Warehouse

         if $iwhse > 0;
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + 'llwhse=' + %trim(%editc($iwhse:'P'));
           append5 = ' and ';
         endif;




         // License

         if w1lcns <> '*ALL';
           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + '('
                    + 'lllcns='
                    + sq + %trim(w1lcns) + sq
                    + ' or '
                    + 'llolcns='
                    + sq + %trim(w1lcns) + sq
                    + ')';
           append5 = ' and ';
         endif;

         // Action

           sqlwhere = %trimr(sqlwhere) + append5 + ' '
                    + '('
                    + 'llaction='
                    + sq + 'RCV' + sq
                    + ' or llaction='
                    + sq + 'RTN' + sq
                    + ' or llaction='
                    + sq + 'STF' + sq
                    + ' or llaction='
                    + sq + 'SEL' + sq
                    + ' or llaction='
                    + sq + 'ADJ' + sq
                    + ' or llaction='
                    + sq + 'CNT' + sq
                    + ' or llaction='
                    + sq + 'RPL' + sq
                    + ')';
           append5 = ' and ';


         // Create "Order By" clauses.

               sqlorder = ' ORDER BY MD DESC';
               sqlgroup = ' GROUP BY LLACTION';


         // Create SQL statement.

         SqlStmt = 'SELECT '
                 + %trimr(sqlfields) + ' '
                 + %trimr(sqlfrom) + ' '
                 + %trimr(sqlwhere) + ' '
                 + %trim(sqlgroup)
                 + sqlorder;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options

**  OPTLN - Option display line

**  CMDLN - Command display line
F3/F12=Exit
