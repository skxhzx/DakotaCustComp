      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  RH160A  Exported routes (One whse) - Display
     *  27 June 1997
     *  Dave Sommerville
     *
     *  Revisions
     *
402 A*    07/15/97   HNK  4.02
     *        Add Option 9 to view order details.
404 A*    08/18/97   RH   4.04
     *        Add option 8 view breakdown.
404 A*    09/05/97   DAS  4.04
     *        Add $PCMMD to pass to PS130.
     *
414aA*    06/30/00  DAS  4.14a
     *      - Revised display file to use ind 21 with SFLNXTCHG
     *        instead of ind 85 as stated in this program. The
     *        actual indicator used in the program was never changed
     *        from 21 to 85.
     *      - Only had to recompile the program.
     *
414bA*    08/15/00  DAS  4.14
     *      - Revised @PRTPG to be OR675CL instead of OR645CL. The
     *        difference is that OR675CL doesn't allow the reprinting
     *        of labels and includes report 'Route Summary by Stop'.
     *
416 A*    10/29/01  HNK  4.16
     *      - Revised TO display picked qty, wt and cube.
416aA*    04/16/02  MLB  4.16a
     *      - Revised program to call RS120 for compartment summary
     *        when option 8=Summary is selected.
510 A*    06/15/06  RMC  5.10
     *      - Enh: Create new subfile (DSPPSF) to display
     *             Shipment number for Packers.
     *             Add logic to determine if Packers is accessing
     *             this program.
510aA*    12/01/06  JCJ  5.10a
     *      - ENH: Add option 13=Zone Detail.
530aA*    05/17/10  RBD  5.30a
     *      - Added data structure for *SYSTEM options.
     *      - Revised ZZINZ routine to get *SYSTEM options.
     *      - Revised array OPTLN to add text for opt 14 -
     *        Assign driver.
     *      - Added opt 14 to OPTLST array.
     *      - Added call to TR850 - Assign driver to route if
     *        system option 'Using TRAX' equals Y.
     *      - Revised array OPTLN to add text for opt 15 -
     *        Rebuild Trax file.
     *      - Added opt 15 to OPTLST array.
     *      - Added call to TR810 - Rebuild Trax xml route file
     *        if user selects option 15 and is a Trax client.
     *
530bA*    09/03/10  RBD  5.30b
     *      - Added display of driver.
     *      - Changed name of dspf from RH160AFM to RH160A01.
     *
530cA*    10/25/10  RBD  5.30c
     *      - Added the following hidden options :
     *        VO = reverse exported route to Open status
     *        VP = reverse exported route to Printed status
     *        VC = reverse exported route to Closed status
     *      - If you wish to reverse a route to Built status,
     *        use option VO to reverse it to Open status, then
     *        use TB to build it.
     *
640aA*    03/02/11  DAS  6.40a
     *      - Add option ER to export route to staging files.
     *      - Add option EH to export header/detail to staging files.
     *
640bA*    03/18/11  RBD  6.40b
     *      - Added logic for new Trax log status code '4'.
     *
640cA*    10/20/11  RBD  6.40c
     *      - Recompiled, TTRTE file changed.
640dA*    05/08/12  MLB  6.40d
     *      - Fix: Revised routine zzopt to load wkokyu into dsukey
     *        before calling ZH140. Wrong data was being passed to
     *        ZH140 causing erroneous data to be displayed.
     *
640eA*    01/17/12  RBD  6.40e
     *      - Recompiled, TTRTE file changed.
     *      - If user selects 15=Rebuild Trax and the route is a
     *        merged route, only call TR810 if all of the connected
     *        routes have been exported.
     *
650 A*    08/26/13  RBD  6.50
     *      - Recompiled, TTLOG file changed.
     *
650aA*    10/14/14  RBD  6.50a
     *      - Disabled hidden option VO.  It should remain disabled
     *        until changes can be made to RH136 to either not update
     *        slots at all for option VO or only update slots where
     *        the item has not been changed, and that determination has
     *        yet to be made. In the meantime, if you wish to take a
     *        a route from exported to open status, use option VP to
     *        get it to printed status, then undo it.
     *
700aA*    01/08/16  RBD  7.00a
     *      - Added call to TR811 to rebuild version 1.3 Trax(c) xml
     *        file if user selects option 15 and is a Trax(c) client.
     *
700bA*    05/05/16  NLK  7.00b
     *      - Added call to BX310 to view AMP box information
     *
710aA*    04/19/17  RBD  7.10a
     *      - For now skip over code that writes merged routes into
     *        the same xml. The handheld is not yet ready to handle
     *        multiple routes in the same xml.  So for now merged
     *        routes (TTMERG) is only used by the Loader Module.
     *        When you're ready to reinstate this logic simply take out
     *        these 710a revs.
     *
720aA*    03/03/18  DAS  7.20a
     *      - Do not allow Trax XML file rebuild if one of the routes
     *        of a merge group has not been exported.
     *
730 A*    02/06/19  MLB  7.30
     *      - Enh: Added clientloc parm to @getcl pgm call.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
     *
CSP A*    02/06/19  MLB  CSP
     *      - Revised to use CHKLIST to allow only certain users to
     *        use option VC=Change route to Closed status. Per Rich K.
     *        email.
     *      - Removed VO, VP options from ZOPT compile time table to
     *        prevent user access.
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
510  *  70        Chain Indicator (ORDHM2)
     *  79        Chain Indicator
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
414aD** 85        Manually set subfile change flag (SFLNXTCHG)
414aM*  21        Manually set subfile change flag (SFLNXTCHG)
     *  90        Protect Input Fields for Delete Display
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound Buzzer)
     *  99        Universal Record Indicator (Very Temporary Usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
530bDF*rh160afm  cf   e             workstn
530bMFrh160a01  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(vw2sfl:recno)
     F                                     sfile(dsppsf:recno)
     F                                     sfile(vw3sfl:recno)
222 D*                                       RECNO2KSFILE VW2SFL
222 D*                                       RECNO3KSFILE VW3SFL
     F                                     sfile(msgrec:msgk)
     Fworkopt   uf a e           k disk
     Frtehed2   if   e           k disk
     F                                     rename(rhrec:record)
640eAfrtehed    if   e           k disk    rename(rhrec:rhrec2)
640eAf                                     prefix(r_)
     Frtesum    if   e           k disk
510  Fordhm2    if   e           k disk
530aAFoptions   if   e           k disk
530aAFpiruser   if   e           k disk
530aAFttlog     if   e           k disk
640eAFttmerg1   if   e           k disk    prefix(t1_)
640eAfttmerg2   if   e           k disk    rename(ttmrec:ttmrec2)
640eAf                                     prefix(t2_)
530aAFttrte     if   e           k disk
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
510aD***                 OPTLN   1   1 75
510aMD optln           s             75    dim(2) ctdata perrcd(1)
VW2 D*                   CMDLN   1   1 79
 W2 MD cmdln           s             79    dim(6) ctdata perrcd(1)
     D stat            s             10    dim(6) ctdata perrcd(1)
640eDD*em              s             50    dim(2) ctdata perrcd(1)
640eMD em              s             50    dim(3) ctdata perrcd(1)
510  *
510   /COPY QCOPYSRC,ID#PACKERS
CSP A /COPY QCOPYSRC,ID#Coastal
     D @getcl          c                   const('GETCLIENT')
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D  $kwhse                 1      3  0
     D  $kstat                 4      4
     D  $ktype                 5      5
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                 1     50
     D  dsukey                 1     50
     D  rhwhse                 1      3  0 inz(0)
     D  rhrte                  4      8
     D  rhrtid                 9     13
     D  rhtruk                14     23
     D  rhstat                24     24
     D  rhtype                25     25
     *----------------------------------------------------------------
530aA*  *SYSTEM  -  System options.
530aA*----------------------------------------------------------------
530aA*
530aA* Fields
530aA*
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Perform catch weight variance check (Y,N).
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *    OPICW   -  Individual catch weight entry (Y,N).
     *    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
     *    OPRCDY  -  Number of days to keep receiving logs.
     *    OPMPCK  -  Number of days to keep picking logs.
     *    OPRTHS  -  Number of weeks - exported routes to keep.
     *    OPCRHS  -  Number of weeks - exported customer rtns to keep.
     *    OPPOHS  -  Number of weeks - exported p/o's to keep.
     *    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
     *    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
     *    OPTBJQ  -  Run Truck Builder on Job Que (Y,N).
     *    OPISHS  -  Number of weeks to keep history file
     *    OPUCI   -  Use UCI processing (Y,N).
     *    OPICWR  -  Check CW count for receiving. (N,M,B,C)
     *    OPWRNR -   Check CW variance for receiving. (N,M,B,C)
     *    OPTRAX -   Using TRAX module (Y,N).
     *
     * Data structure
     *
     D opdat1          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
     D  opmpck                14     14
     D  oprcdy                15     15  0
     D  oppkdy                16     16  0
     D  oprths                17     19  0
     D  opcrhs                20     22  0
     D  oppohs                23     25  0
     D  opiahs                26     28  0
     D  opmshs                29     31  0
     D  optbjq                32     32
     D  opishs                33     35  0
     D  opuci                 36     36
     D  opicwr                37     37
     D  opwrnr                38     38
     D  optrax                39     39
     D  opten1               117    117
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @chgpg          c                   const('RH122')
     D @delpg          c                   const('NONE')
414bD**            'OR645CL'             C         @PRTPG
     D @prtpg          c                   const('OR675CL')
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
     D  $pwhse                19     21  0 inz(0)
     D  $prte                 22     26
     D  $prtid                27     31
     D  $ptruk                32     41
     D  $pstat                42     42
     D  $ptype                43     43
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
     D  $ltrk2                32     41
510aA*
510aAD  $krte                 32     36
510aAD  $krtid                37     41
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
510  *  Shipment number from Miscellaneous field
510  D                 ds
510  D  hmmsc1                 1     40
510  D  hmmshp                 4     14
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
CSP A*----------------------------------------------------------------
CSP A* Status message(s)
CSP AD err01           c                   const('Not authorized t-
CSP AD                                     o use option  ')
     *----------------------------------------------------------------
     *  Variables
     *
     D $awhse          s              3
     D $emp#           s              5
     D $msgf           s             10
     D $pcmmd          s              8
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
640eAD firstpass       s              1
     D forceb          s              1
     D forevr          s              1
     D frstky          s                   like($puky)
     D goback          s              2  0
     D help            s              5  0
     D maxvw           s              1  0
     D msgk            s              4  0
     D nomore          s              1
     D nxtscr          s              3
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
640eAD parentRte       s              5
     D posrec          s              4  0
     D p1              s              1  0
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
510  C                   if        client = packer
510  C                   read      dsppfc                                 50
510  C                   else
     C                   read      dspsfc                                 50
510  C                   endif
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
510 A*
510 A* Get client id.
510 A*
510 AC                   call      @getcl
510 AC                   parm                    client           10
730 AC                   parm                    clientloc        10
510 A*
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
510  C                   if        client = packer
510  C                   write     dsppsf                               79
510  C                   else
     C                   write     dspsfl                               79
510  C                   endif
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
510  C                   if        client = packer
510  C     x             chain     dsppsf                             79
510  C                   else
     C     x             chain     dspsfl                             79
510  C                   endif
222 D*R         X         CHAINVW2SFL               79
222 D*R         X         CHAINVW3SFL               79
     C                   if        not *in79
     C                   eval      option = '  '
510  C                   if        client = packer
510  C                   update    dsppsf
510  C                   else
     C                   update    dspsfl
510  C                   endif
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
     C                   exsr      inzpar
     C                   eval      $pcmd = '*ADD    '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
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
     C                   add       1             recno
222 D*R                   ADD  1         RECNO2
222 D*R                   ADD  1         RECNO3
     C                   z-add     recno         y
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
510  C                   if        client = packer
510  C                   write     dsppsf
510  C                   else
     C                   write     dspsfl
510  C                   endif
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
     C                   eval      *in01 = *on
     C                   eval      recno = 1
222 D*R                   Z-ADD1         RECNO2
222 D*R                   Z-ADD1         RECNO3
VW2 AC                   select
VW2 AC                   when      view = 1
510  C                   if        client = packer
510  C                   write     dsppfc
510  C                   else
     C                   write     dspsfc
510  C                   endif
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
     *
     *   Change
     *
     C                   if        wkoopt = ' 2'
     C                   eval      $pcmd = '*CHANGE '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   else
     *
     *   View
     *
     C                   if        wkoopt = ' 5'
     C                   eval      $pcmd = '*VIEW   '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   else
     *
     *   Print
     *
     C                   if        wkoopt = ' 6'
     C                   eval      $pcmd = '*REPRINT'
     C                   call      @prtpg
222 D**                   PARM           $PARMS
222 AC                   parm                    $pcmd
222 AC                   parm                    $ptype
222 AC                   parm                    $pwhse
222 AC                   parm                    $prte
222 AC                   parm                    $prtid
222 AC                   parm                    $ptruk
222 AC                   parm                    $prtn
     C                   else
530aA*
530aA*   Assign driver to route.
530aA*
530aAC                   if        wkoopt = '14'
530aAC                   if        optrax <> 'Y'
530aAC                   eval      error = *on
530aAC                   eval      wkoerr = *on
530aAC                   update    wkorec
530aAC                   eval      otaken = *off
530aAC                   eval      errmsg = em(1)
530aAC                   exsr      zm0105
530aAC                   goto      endop2
530aAC                   endif
530aAC                   move      $pwhse        $awhse
530aAC                   eval      $puky = wkokyu
530aAC                   eval      dsukey = $puky
530aAC                   call      'TR850'
530aAC                   parm                    $pprg
530aAC                   parm                    $awhse
530aAC                   parm                    $prtid
530aAC                   parm      *blanks       $prtn
530aAC                   else
     *
700aM*    Call TR810 and TR811 to rebuild Trax(c) xml files.
530aA*
530aAC                   if        wkoopt = '15'
     *
530aAC                   if        optrax <> 'Y'
530aAC                   eval      error = *on
530aAC                   eval      wkoerr = *on
530aAC                   update    wkorec
530aAC                   eval      otaken = *off
530aAC                   eval      errmsg = em(1)
530aAC                   exsr      zm0105
530aAC                   goto      endop2
530aAC                   endif
     *
530aAC                   eval      $puky = wkokyu
530aAC                   eval      dsukey = $puky
530aAC     keyrs         setll     ttlog
530aAC                   dow       forevr = forevr
530aAC     keyrs         reade     ttlog                                  79
530aAC                   if        *in79
530aAC                   leave
530aAC                   endif
530aAC                   if        ttlstatus = '3'
640bAC                             or ttlstatus = '4'
530aAC                   eval      error = *on
530aAC                   eval      wkoerr = *on
530aAC                   update    wkorec
530aAC                   eval      otaken = *off
530aAC                   eval      errmsg = em(2)
530aAC                   exsr      zm0105
530aAC                   goto      endop2
530aAC                   leave
530aAC                   endif
530aAC                   enddo
     *
720aDC**                 goto      skipMerge
720aD **
720aD **   If this is a Trax merged route, do not rebuild Trax unless
720aD **   all of the connected routes have also been exported.
720aD **
720aDC**                 eval      parentRte = rhrtid
720aDC**   keyrs         setll     ttmerg2
720aDC**                 dow       forevr = forevr
720aDC**   keyrs         reade     ttmerg2
720aDC**                 if        %eof
720aDC**                 leave
720aDC**                 else
720aDC**                 eval      parentRte = t2_ttmpri
720aDC**                 leave
720aDC**                 endif
720aDC**                 enddo
720aD **
720aDC**                 eval      firstpass = *on
720aDC**   keyttm        setll     ttmerg1
720aDC**                 dow       forevr = forevr
720aDC**   keyttm        reade     ttmerg1
720aDC**                 if        %eof
720aDC**                 leave
720aDC**                 endif
720aD **
720aD ** Throw error message if this is a child being exported
720aD ** and the parent route has not yet been exported.
720aDC**                 if        firstpass = *on and parentRte <> rhrtid
720aDC**   keyttm        chain     rtehed
720aDC**                 if        %found(rtehed)
720aDC**                           and r_rhstat = '6'
720aDC**                 else
720aDC**                 eval      error = '1'
720aDC**                 eval      errmsg = em(3)
720aDC**                 eval      wkoerr = *on
720aDC**                 update    wkorec
720aDC**                 eval      otaken = *off
720aDC**                 exsr      zm0105
720aDC**                 goto      endop2
720aDC**                 endif
720aDC**                 endif
720aDC**                 eval      firstpass = *off
720aD**
720aDC**                 if        t1_rhstat <> '6'
720aDC**                           and t1_ttmcri <> rhrtid
720aDC**                 eval      error = '1'
720aDC**                 eval      errmsg = em(3)
720aDC**                 eval      wkoerr = *on
720aDC**                 update    wkorec
720aDC**                 eval      otaken = *off
720aDC**                 exsr      zm0105
720aDC**                 goto      endop2
720aDC**                 endif
720aDC**                 enddo
720aD
720aA /free
720aA
720aA    // See if route is part of a child of a merge group.
720aA    // If so, get parent, then see if any routes not exported.
720aA    // If it is the parent, we don't care, because is exported.
720aA    // If so, get parent, then see if any routes not exported.
720aA
720aA    parentRte = '';
720aA
720aA    chain (rhwhse: rhrtid) ttmerg1;
720aA    if %found(ttmerg1);
720aA      parentRte = rhrtid;
720aA    else;
720aA      chain (rhwhse: rhrtid) ttmerg2;
720aA      if %found(ttmerg2);
720aA        parentRte = t2_ttmpri;
720aA      endif;
720aA    endif;
720aA
720aA    if parentRte <> '';
720aA
720aA      chain (rhwhse: parentRte) rtehed;
720aA      if r_rhstat < '6';
720aA        error = '1';
720aA        errmsg = em(3);
720aA        wkoerr = *on;
720aA        update wkorec;
720aA        otaken = *off;
720aA        exsr zm0105;
720aA        leavesr;
720aA      endif;
720aA
720aA      setll (rhwhse: parentRte) ttmerg1;
720aA      dow forevr = forevr;
720aA
720aA        reade (rhwhse: parentRte) ttmerg1;
720aA        if %eof(ttmerg1);
720aA          leave;
720aA        endif;
720aA
720aA        if t1_rhstat < '6';
720aA          error = '1';
720aA          errmsg = em(3);
720aA          wkoerr = *on;
720aA          update wkorec;
720aA          otaken = *off;
720aA          exsr zm0105;
720aA          leavesr;
720aA        endif;
720aA
720aA      enddo;
720aA
720aA    endif;
720aA
720aA /end-free

710aAC     skipMerge     tag
640eA*
530aAC                   eval      usemp# = 0
530aAC     keyrs         chain     ttrte                              77
530aAC                   if        not *in77
530aAC     ttrusr        chain     piruser                            77
530aAC                   endif
530aAC                   move      usemp#        $emp#
530aAC                   eval      $whs30 = $pwhse
530aAC                   call      'TR810'
530aAC                   parm      $pwhse        $whs30            3 0
530aAC                   parm      rhrtid        $brtid            5
530aAC                   parm                    $emp#
530aAC                   parm      ' '           $filsn           30
530aAC                   parm      ' '           $prtn
530aAC                   parm      ' '           $perm
700aAC                   if        $prtn = '*OK     '
700aAC                   call      'TR811'
700aAC                   parm      $pwhse        $whs30            3 0
700aAC                   parm      rhrtid        $brtid            5
700aAC                   parm                    $emp#
700aAC                   parm      ' '           $filsn           30
700aAC                   parm      ' '           $prtn
700aAC                   parm      ' '           $perm
700aAC                   endif
530aAC                   else
     *
700bA*    Call BX310 to view AMP box information.
700bA*
700bAC                   if        wkoopt = 'BX'
700bAC                   eval      $pcmd = '*AMPINFO'
700bAC                   call      'BX310'
700bAC                   parm                    $pcmd
700bAC                   parm                    $pwhse
700bAC                   parm                    $cvd6i
700bAC                   parm                    $prte
700bAC                   parm                    $prtid
700bAC                   parm                    $prtn
700bAC                   else
     *
530cA*   Reverse route from Exported status to Open, Printed,
530cA*   or Closed.
530cA*
650aDC**                 if           wkoopt = 'VO'
650aMC                   if           wkoopt = 'VP'
530cAC                             or wkoopt = 'VC'
CSP A*
CSP A*     Check if user is authorized to use this option.
CSP AC                   if        client = Coastalsunbelt
CSP AC                   call      'CHKLIST'
CSP AC                   parm      #prog         $cpgm            10
CSP AC                   parm      wkoopt        $copt            20
CSP AC                   parm      #user         $cuser           10
CSP AC                   parm      *blanks       $crtn            10
CSP A*       User not authorized to use this option.
CSP AC                   if        $crtn  = '*NO '
CSP AC                   eval      error  = *on
CSP AC                   eval      $prtn  = $crtn
CSP AC                   eval      cancel = *on
CSP AC                   eval      errmsg = err01
CSP AC                   exsr      zm0105
CSP AC                   goto      #skipundo
CSP AC                   endif
CSP AC                   endif
CSP A*
530cAC                   select
530cAC                   when      wkoopt = 'VO'
530cAC                   eval      $pcmd = '*UNDO'
530cAC                   when      wkoopt = 'VP'
530cAC                   eval      $pcmd = '*PRINTED'
530cAC                   when      wkoopt = 'VC'
530cAC                   eval      $pcmd = '*CLOSED'
530cAC                   endsl
530cAC                   call      'RH136'
530cAC                   parm                    $parms
530cA*     Delete was successful, show info msg.
CSP AC     #skipundo     tag
530cAC                   if        $prtn = '*OK     '
530cAC                   eval      #msgk = $pmsg
530cAC                   exsr      zmqmsg
530cAC                   endif
530cAC                   else
     *
     C                   exsr      zzopt
700bAC                   endif
530cAC                   endif
530aAC                   endif
530aAC                   endif
     C                   endif
     C                   endif
     C                   endif
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
530aMC     endop2        endsr
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
510  C                   if        client = packer
510  C                   readc     dsppsf                                 79
510  C                   else
     C                   readc     dspsfl                                 79
510  C                   endif
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
510  C                   if        client = packer
510  C                   write     dsppsf
510  C                   else
     C                   write     dspsfl
510  C                   endif
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
510  C                   if        client = packer
510  C                   write     dsppfc
510  C                   else
     C                   write     dspsfc
510  C                   endif
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
510  C                   if        client = packer
510  C     1             chain     dsppsf                             79
510  C                   else
     C     1             chain     dspsfl                             79
510  C                   endif
     C                   if        not *in79
     C                   eval      *in20 = *on
510  C                   if        client = packer
510  C                   update    dsppsf
510  C                   else
     C                   update    dspsfl
510  C                   endif
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
510  C                   if        client = packer
510  C                   write     dsppfc
510  C                   else
     C                   write     dspsfc
510  C                   endif
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
510  C                   if        client = packer
510  C     x             chain     dsppsf                             79
510  C                   else
     C     x             chain     dspsfl                             79
510  C                   endif
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
510  C                   if        client = packer
510  C                   update    dsppsf
510  C                   else
     C                   update    dspsfl
510  C                   endif
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
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0001  Option under construction.
     *
     C     zm0001        begsr
     C                   eval      #msgid = 'PIR0001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
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
     *     Warehouse department.
     *
     C                   if        row# = 4  and
     C                             col# >= 48
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      ptinp1 = $lwhse
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
     *
     *
     *  Test for F8 - Truck detail
     *
     C                   if        *inkh
     C                   eval      $pcmd = '*CHANGE '
     C                   call      'TM110A'
     C                   parm                    $prtky
     C                   parm                    $rtncd
     C                   endif
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
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     *
     *   Status description
     *
     C                   move      rhstat        p1
     C                   eval      w1stat = stat(p1)
     C                   eval      w3stat = stat(p1)
     *
     *   Summary totals
     *
416 AC                   eval      w1pckc = 0
416 AC                   eval      w1pckw = 0
416 AC                   eval      w1pckp = 0
416 AC                   eval      w1ordp = 0
416 D**                   Z-ADD0         W1CUBE
416 D**                   Z-ADD0         W1SWGT
416 D**                   Z-ADD0         W1PCS
     C     keyrs         setll     rtesum
     C                   dow       forevr = forevr
     C     keyrs         reade     rtesum                                 79
     C                   if        *in79
     C                   leave
     C                   endif
416 AC                   add       rspckc        w1pckc
416 AC                   add       rspckw        w1pckw
416 AC                   add       rspckp        w1pckp
416 AC                   add       rsordp        w1ordp
416 D**                   ADD  RSORDC    W1CUBE
416 D**                   ADD  RSORDW    W1SWGT
416 D**                   ADD  RSORDP    W1PCS
     C                   enddo
     *
     *   Report date
     *
     C                   if        rhrptd = 0
     C                   eval      w2rptd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      rhrptd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w2rptd = $cvd6o
     C                   endif
     *
     *   Imported date
     *
     C                   if        rhimpd = 0
     C                   eval      w2impd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      rhimpd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w2impd = $cvd6o
     C                   endif
     *
     *   Built date
     *
     C                   if        rhbldd = 0
     C                   eval      w2bldd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      rhbldd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w2bldd = $cvd6o
     C                   endif
     *
     *   Printed date
     *
     C                   if        rhprtd = 0
     C                   eval      w2prtd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      rhprtd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w2prtd = $cvd6o
     C                   endif
     *
     *   Exported date
     *
     C                   if        rhexpd = 0
     C                   eval      w3expd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      rhexpd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w3expd = $cvd6o
     C                   endif
     *
     *   Driver
     *
530bAC     keyrs         chain     ttrte
530bAC                   if        not %found
530bAC                   eval      ttrusr = ' '
530bAC                   endif
     *
     *   Status date
     *
     C                   if        rhstsd = 0
     C                   eval      w3stsd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      rhstsd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w3stsd = $cvd6o
     C                   endif
510  *
510  *   Shipment Number for Packers
510  *
510  C                   eval      w1ship = *blanks
510  C                   if        client = packer
510  C     keyrs         chain     ordhm2                             70
510  C                   if        not *in70
510  C                   eval      w1ship = hmmshp
510  C                   endif
510  C                   endif
     *
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
     C                   kfld                    rhwhse
     C                   kfld                    rhstat
     C                   kfld                    rhtype
     C                   kfld                    rhrte
     C                   kfld                    rhrtid
     *
     *  Define UNIQ key for main file.
     *
     C     filuky        klist
     C                   kfld                    rhwhse
     C                   kfld                    rhstat
     C                   kfld                    rhtype
     C                   kfld                    rhrte
     C                   kfld                    rhrtid
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kstat
     C                   kfld                    $ktype
     *
     *  Define partial key for file RTESUM.
     *
     C     keyrs         klist
     C                   kfld                    rhwhse
     C                   kfld                    rhrtid
     *
530aA*
530aA*  Define key for options file.
530aA*
530aAC     keyop         klist
530aAC                   kfld                    opwhse
530aAC                   kfld                    opcode
     *
640eA*  Define partial key for file TTMERG1.
640eA*
640eAC     keyttm        klist
640eAC                   kfld                    rhwhse
640eAC                   kfld                    parentRte
     *
530aA*   Get *SYSTEM options from options file.
530aA*
530aAC                   eval      opwhse = 0
530aAC                   eval      opcode = '*SYSTEM '
530aAC     keyop         chain     options                            79
530aAC                   if        *in79
530aAC                   eval      optrax = 'N'
530aAC                   else
530aAC                   eval      opdat1 = opdata
530aAC                   endif
     *
     *  Setup option and command display lines.
     *
VW2 AC                   eval      view = 1
VW2 AC                   eval      maxvw = 3
     C                   eval      optln1 = optln(1)
510aAC                   eval      optln2 = optln(2)
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
222 MC                   eval      $ktype = ' '
222 MC                   eval      $kstat = '6'
     C                   eval      dsfkey = $prtky
     *
     *   Get warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     rhwhse        parm      0             #whse             3 0
     *
     *   Verify warehouse and get description.
     *
     C                   eval      whcode = rhwhse
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = rhwhse
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
     C                   eval      $kwhse = rhwhse
     C                   eval      whcode = rhwhse
     C                   movel     $lerm         whdesc
     C                   endif
     C                   endif
     *
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
     *
     C                   select
     *
     *   Close transactions
     *
     C                   when      wkoopt = ' 1'
     C                   call      'PT640'
     C                   parm                    $puky
     C                   parm                    $prtn
     *
     *   Reprint
     *
     C                   when      wkoopt = ' 6'
     *R                   CALL 'PS130'
     *R                   PARM           $PUKY
     *R                   PARM           $PRTN
404 A*
404 A*   Department summary
404 A*
404 AC                   when      wkoopt = ' 8'
416aD*R                   CALL 'RS110'
416aMC                   call      'RS120'
404 AC                   parm                    $puky
404 AC                   parm                    $prtn
402 A*
402 A*   Order Details
402 A*
402 AC                   when      wkoopt = ' 9'
402 AC                   eval      $luky = $puky
402 AC                   eval      $lrtn = *blanks
402 AC                   call      'RH170'
402 AC                   parm                    $luky
402 AC                   parm                    $lrtn
     *
     *   Truck Detail
     *
     C                   when      wkoopt = '12'
404 AC                   eval      $pcmmd = '*VIEW   '
     C                   call      'PS130'
404 AC                   parm                    $pcmmd
     C                   parm                    $puky
     C                   parm                    $prtn
510aA*
510aA*   Zone Detail
510aA*
510aAC                   when      wkoopt = '13'
510aAC                   eval      error = *off
640dAC                   eval      dsukey = wkokyu
510aAC                   eval      $lwhse = $pwhse
510aAC                   eval      $ltruk = rhtruk
510aAC                   eval      $krte = rhrte
510aAC                   eval      $krtid = rhrtid
510aAC                   call      'ZH140'
510aAC                   parm                    $luky
510aAC                   parm                    $lrtn
640aA
640aA*  ER - Export route to staging files
640aA
640aAC                   when      wkoopt = 'ER'
640aAC                   eval      dsukey = wkokyu
640aAC                   call      'RH155S'
640aAC                   parm      'TALL'        $scmd             8
640aAC                   parm      rhwhse        $swhse            3 0
640aAC                   parm      rhrtid        $srtid            5
640aAC                   parm      rhrte         $srte             5
640aAC                   parm      ' '           $srtn             8
640aA
640aA*  EH - Export header/detail to staging files
640aA
640aAC                   when      wkoopt = 'EH'
640aAC                   eval      dsukey = wkokyu
640aAC                   call      'RH155S'
640aAC                   parm      'THDRDTL'     $scmd             8
640aAC                   parm      rhwhse        $swhse            3 0
640aAC                   parm      rhrtid        $srtid            5
640aAC                   parm      rhrte         $srte             5
640aAC                   parm      ' '           $srtn             8
     *
     C                   endsl
     *
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
222 D*R                   MOVE '3'       RHSTAT
222 MC                   eval      rhstat = $kstat
     C                   eval      rhwhse = ptinp1
     C                   eval      $kwhse = rhwhse
     C                   eval      rhrte = *blanks
     C                   eval      rhrtid = *blanks
     C                   eval      rhtruk = *blanks
     C                   eval      whcode = ptinp1
     C                   movel     $lerm         whdesc
     C                   eval      ptinp1 = 0
     C                   eval      repos = *on
     C                   endif
     C                   endif
     C                   endif
     *
     *  See if user is trying to position to code
     *
     C                   if        ptinp2 <> *blanks
     C                   eval      rhrte = ptinp2
     C                   eval      rhrtid = *blanks
     C                   eval      rhtruk = *blanks
     C                   eval      ptinp2 = *blanks
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
 6 8 912131415VOVPVCBX
**  OPTLN - Option display line
  6=Reprint  8=View breakdown  9=Order details  12=View truck detail
 13=Zone detail  14=Assign driver  15=Rebuild Trax
**  CMDLN - Command display line
F3=Exit  F4=Prompt  F5=Refresh  F8=Truck maint.  F12=Cancel
F10=View 3  F11=View 2  F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F4=Prompt  F5=Refresh  F8=Truck maint.  F12=Cancel
F10=View 1  F11=View 3  F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F4=Prompt  F5=Refresh  F8=Truck maint.  F12=Cancel
F10=View 2  F11=View 1  F17=Top  F18=Bottom  F20=Move to top
**  STAT - Route status codes
Open
Allocated
Built
Printed
Closed
Exported
**  EM - Error message
Option not allowed, must be a TRAX user.
Cannot rebuild Trax, already downloaded.
Can't rebuild Trax, connected routes not exported.
