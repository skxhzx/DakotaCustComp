610aA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W Roosevelt Rd.  #8-51
     *   West Chicago, IL. 60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IV213   Inventory sheet maint Virtual slot
     *  16 July, 1998
     *  Roxanne Harrison
     *
     *  Revisions
     *
412 A*    09/27/99  DAS  4.12
     *      - Changed program to format virtual slot display from
     *        FRMTSL to FRMTVS.
     *      - Changed to create vslot with Pick type of physical slot.
     *      - Revised ZZCKNS routine to check handstack of physical
     *        slot. If both characters being used then getout. If
     *        only one char being used then limit the possible
     *        virtual handstack so that the first character must
     *        equal the last character of the physical handstack.
     *        Remember, the handstack is right justified so if
     *        the physical slot already has handstack ' A', then
     *        the possible virtual handstacks are 'AA', 'AB' . . .
     *      - In ZZINZ2, set $PCMD to '*ADD'. It is coming in as
     *        '*CREATE'.  ZZCHK1 is only called for *ADD or *CHANGE
     *        and ZZCHK1 only verified slot for *ADD.
     *      - Moved saving of slot fields from ZZUPD1 to ZZCHK1.
     *      - Revised ZZCHK1 to verify slot is a physical slot, that
     *        it does not have a 2-character handstack code and
     *        that a virtual slot can be created for it (by calling
     *        ZZCKNS).
     *
413 A*    02/28/00  DAS  4.13
     *      - Revised to verify item number using command *VERIFYS.
     *        This command verifies that the item is allowed to be
     *        put into the slot. Currently, only ' ' and 'B' items
     *        are allowed into slots.
414aA*    05/12/00  RH   4.14a
     *      - Recompiled, file INVSLOT changed.
414bA*    07/19/00  RRH  4.14b
     *      - Correct # for Do loop in ZZCKNS
414gA*    10/25/00  RRH  4.14g
     *      - Don't lock VSLOT records in ZZCKSL.
416 A*  09/25/01  RH   4.16
     *    - Recompile - INVSLOT file changed.
416bA*    09/25/02  RH   4.16a
     *      - Revised to create virutal slot with same status as base
     *        if base is not Z or V.
500aA*    04/27/05  RH   5.00a
     *      - Enh: Add slot pallet position.  Write to INVSPOS.
500bA*    05/10/05  RH   5.00b
     *      - Enh: Skip check for item in slot if slot allows mult positions
500cA*    06/06/06  RH   5.00c
     *      - Enh: Add catch wt. Convert to ILE
500dA*    06/17/06  MLB  5.00d
     *      - Fix: Revised program to remove check for zero catchweight.
510aA*    07/14/06  RH   5.10a
     *      - Fix: Physical slot must bein inventory scope.
     *      - Fix: Create INVSLOT new slot record with adjustment code.
510bA *    09/01/06  RH   5.10b
      *      - Fix: Verify item is for same department as slot.
510cA *    11/15/06  RH   5.10c
      *      - Enh: Added client code.
510dA *    06/06/07  RH   5.10d
      *      - Fix: Was missing 'Pallet position required' message
      *        added ZM1204
520aA *    06/21/08  MLB  5.20a
      *      - Fix: Change to only check CW for CW item.
520bA *    07/15/08  RH   5.20b
      *      - Enh: Move item # to screen 1 to allow CW field to only
      *        display for CW item.
     *
610aA*    09/20/09  DAS  6.10a
     *      - Revised to use DRISLOT to create virtual slot.
     *      - Revised to call LT210 to get new license for
     *        Medium/High tracked items.
700aA*    08/18/16  MR   7.00a
700aA*      - Enh: Write to ICDCNTD when virutal slot is added.
     *             Update Cycle Count in INHCNTH.
700bA*  09/15/16  LMC  7.00b
     *    - Enh: New history files names changed.
     *    - Enh: Dept added to invinuse file to ensure unique # is
     *           by whse/department.
710aA*  03/23/17  LMC  7.10a
     *    - Enh: Database change to INVHSTD. Recompile only.
710bA*  05/12/17  LMC  7.10b
     *    - Enh: Conditional the display/entry of the breakdown fields
     *      on independent indicators.
710cA*  12/22/17  LMC  7.10c
     *    - Enh: Database change to INVHSTD. Recompile only.
      *
      *----------------------------------------------------------------
      *  Client Custom Revisions:
pck A *    11/15/06  RH   PCKa
      *      - Enh: Do not check item/slot dept for Packers
     *
     *  Client Custom Revisions  - Chefs Warehouse
DRYaA*    05/12/17  LMC  DRYa
     *      -  Revised program to only display breakdown quantities
     *         for the breakdown fields 1 & 2 if the item is setup
     *         for allow entry on that breakdown field.
     *---------------------------------------------------------------
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
     *  90        View moSe (Protect input fields)
     *  91        Change mode (protect key)
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
710bDF*iv213fm   cf   e             workstn
710bMFiv21301   cf   e             workstn
     F                                     infds(infds)
500a Fslotdef   if   e           k disk
     Finvslot   uf a e           k disk
     *           IVSREC                            KRENAMERECORD
     Fslot2     uf a e           k disk
     Finvpage2  uf a e           k disk
     Finvnxtp   uf   e           k disk
500c Finvscw    uf a e           k disk
500cAFitemmsc   if   e           k disk
500c Foptions   if   e           k disk
     Fvslot2    uf a e           k disk
510a Finvslot4  if   e           k disk
     F                                     rename(ivsrec:ivsrec4)
500a Finvspos   o  a e           k disk
520b F*iritem   if   e           k disk
700bDF*ICHCNTH   uf   e           k disk    PREFIX(H_)
700bAFinvhsth   uf   e           k disk    PREFIX(H_)
700bDF*ICDCNTD   O  A E           K DISK
700bAFinvhstd   O  A E           K DISK
700aAFINVINUSE  IF   E           K DISK
510bA*----------------------------------------------------------------
510bA*  Customer id
510bA*
510bAD @getcl          c                   const('GETCLIENT')
510bAD*
510bA /COPY QCOPYSRC,ID#PACKERS
DRYa  /copy qcopysrc,id#dairyla
     *----------------------------------------------------------------
     *  Table and array definitions
     *
412 AD a2              s              1    dim(2)
412 AD a2n             s              1    dim(2)
     D a10             s              1    dim(10)
     D hnd             s              2    dim(702)
     D desc            s             20    dim(7) ctdata perrcd(1)
     D ltr             s              1    dim(27) ctdata perrcd(27)
500cA*----------------------------------------------------------------
500cA*  DRI parameters
500cA*----------------------------------------------------------------
500cA
500cA /COPY *libl/qcopysrc,C#DRIPARMS
500cA
500cA*----------------------------------------------------------------
500cA*  Data Formats
500cA*----------------------------------------------------------------
500cA
500cA /COPY *libl/qcopysrc,C#ITEM
610aA /COPY *libl/qcopysrc,C#SLOT
500cAD saveVer#        s                   like($itver#)

610aA*----------------------------------------------------------------
610aA*  LT210 parameters
610aA*----------------------------------------------------------------

     D  $tcmd          s              8
     D  $tprogram      s             10
     D  $ttype         s              3
     D  $thead         s             20
     D  $twhse         s              3  0
     D  $titem         s             15
     D  $titemdsc      s             65
     D  $twhdp         s              5
     D  $tslot         s             12
     D  $tslotpos      s              3  0
     D  $templ#        s              5  0
     D  $ttran#        s              7  0
     D  $tlic#         s             15
     D  $tnewlic#      s             15
     D  $tqty1         s              5  0
     D  $tqty2         s              3  0
     D  $tqty3         s              3  0
     D  $tnorm1        s              5  0
     D  $tnorm2        s              3  0
     D  $tnorm3        s              3  0
     D  $tpartial      s               n
     D  $tpulled       s              3  0
     D  $tinslot       s              1
     D  $tsamepos      s              1
     D  $tdiffpos      s              1
     D  $tpsplit       s              1
     D  $tinlic#       s             15
     D  $toutlic#      s             15
     D  $tnexttask     s             10
     D  $treturn       s              8
     D  $terrmsg       s             60
     D  $tmsgid        s              4

610aA*----------------------------------------------------------------
610aA*  Tracking variables
610aA*----------------------------------------------------------------
610aA
610aA /COPY *libl/qcopysrc,c#trackvar

     *----------------------------------------------------------------
500c *  Variables
500cAD #toititem       s                   like($ititem)
500cAD #toittype       s                   like($ittype)
500cAD #toitdesc       s                   like($itdesc)
500cAD #toitpdsc       s                   like($itpdsc)
500cAD #toithead       s             70
500cAD #toitwhdp       s                   like($itwhdp)
500cAD #toitstyp       s                   like($itstyp)
500cAD #toitdesg       s                   like($itdesg)
500cAD #toitum1        s                   like($itum1)
500cAD #toitflg1       s                   like($itflg1)
500cAD #toitum2        s                   like($itum2)
500cAD #toitumq2       s                   like($itumq2)
500cAD #toitflg2       s                   like($itflg2)
500cAD #toitum3        s                   like($itum3)
500cAD #toitumq3       s                   like($itumq3)
500cAD #toitnrpk       s                   like($imnrpk)
500cAD #toitflgd       s                   like($itflgd)
500cAD #toitcube       s                   like($itcube)
500cAD #toitswgt       s                   like($itswgt)
500cAD #toitcwgt       s                   like($itcwgt)
500cAD #toitmitem      s                   like($itmitem)
500cAD #toitsdef       s                   like($idsdef)
500cAD #toittie        s                   like($idtie)
500cAD #toithigh       s                   like($idhigh)

500cAD #tossbititem    s                   like($ititem)
500cAD #tossbittype    s                   like($ittype)
500cAD #tossbitdesc    s                   like($itdesc)
500cAD #tossbitpdsc    s                   like($itpdsc)
500cAD #tossbitwhdp    s                   like($itwhdp)
500cAD #tossbitstyp    s                   like($itstyp)
500cAD #tossbitdesg    s                   like($itdesg)
500cAD #tossbitum1     s                   like($itum1)
500cAD #tossbitum2     s                   like($itum2)
500cAD #tossbitumq2    s                   like($itumq2)
500cAD #tossbitum3     s                   like($itum3)
500cAD #tossbitumq3    s                   like($itumq3)
     D $msgf           s             10
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
610aAD cancel          s               n
500cAD chk4err         s               n
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
500c D exwgt           s              9  2
500c D exwg2           s              7  2
     D exist           s              1
     D flaghs          s              1
500cAD forever         s               n
     D help            s              5  0
500c D hirng           s              9  2
500c D hivar           s              9  2
500c D hvskp           s              1
     D i               s              2  0
500c D ihrng           s              9  2
500c D ihvar           s              9  2
500c D ilrng           s              9  2
500c D ilvar           s              9  2
     D j               s              2  0
     D k               s              3  0
     D kypage          s              5  0
500c D lvskp           s              1
500c D lwrng           s              9  2
500c D lwvar           s              9  2
     D msgk            s              4  0
     D newvs           s              1
     D nxtscr          s              3
     D ovrrid          s              1
     D pexp            s              1
500c D prg1c           s              4  3
500c D prg2c           s              4  3
     D rolldn          s              5  0
     D rollup          s              5  0
510a D sadj            s                   like(ivsadj)
     D sclear          s              1
     D sheet           s                   like(ivppag)
500cAD ssbflg          s               n
     D svactv          s                   like(slactv)
     D svaisl          s                   like(slaisl)
     D svbld           s                   like(slbld)
     D svdesg          s                   like(sldesg)
     D svdisp          s                   like(sldisp)
     D svhand          s                   like(slhand)
     D svitem          s                   like(slitem)
     D svloc           s                   like(slloc)
610aAD svpick          s                   like(slpick)
     D svprty          s                   like(slprty)
     D svpseq          s                   like(slpseq)
     D svrlvl          s                   like(slrlvl)
     D svsdef          s                   like(slsdef)
     D svside          s                   like(slside)
     D svslfd          s                   like(slslfd)
     D svstat          s                   like(slstat)
     D svstyp          s                   like(slstyp)
     D svwhdp          s                   like(slwhdp)
     D svwhse          s                   like(slwhse)
500c D swgt2           s              7  2
     D today           s              8  0
610aAD trackLevel      s              1
520b D w2sitm          s                   like(slitem)
     D warn            s              1
500c D wkcode          s              8
500c D wkwhse          s                   like($pwhse)
     D womult          s              1
     D woqt01          s              5  0
     D woqt02          s              3  0
     D woqt03          s              3  0
500c D wtchk           s              1
500c D zmsflag         s               n
     *----------------------------------------------------------------
500c I*  *SYSTEM  -  System options.
     I*
     I* Fields
     I*
     I*    OPEPM   -  Using EPM module (Y,N).
     I*    OPRF    -  Using RF module (Y,N).
     I*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     I*    OPLETD  -  Print letdown labels (Y,N).
     I*    OPWRNC  -  Perform catch weight variance check (Y,N).
     I*    OPRG1C  -  Catch weight low variance percentage.
     I*    OPRG2C  -  Catch weight high variance percentage.
     I*    OPIMPI  -  Import item fields from host.(Y,N).
     I*    OPICW   -  Individual catch weight entry (Y,N).
     *
     * Data structure
     *
500c D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
500c D  optend               117    117
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
     D  $pwhdp                22     26
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     *----------------------------------------------------------------
     *  Called program parameters
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
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *   Redefine key
     D  $lwhse                19     21  0
     D  $litem                22     36
     *
     *
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
500c D  ertcwt                 1      5p 2
500c D  erlrng                 6     10p 2
500c D  erhrng                11     15p 2
500c D  errg1c                16     17p 1
500c D  errg2c                18     19p 1
500c D  erexwt                20     24p 2
     *
500c D  ertcw#                 1      3p 0
500c D  erqpck                 4      6p 0
     *
     D  erwhse                 1      2p 0
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  eritm                  1     15
     D  erco#                 16     19p 0
     *
     D  erdisp                16     27
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
500cAD  #pgm             *proc
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
     C                   eval      *in92 = *off
710bAC                   eval      *in93 = *off
710bAC                   eval      *in94 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     * Get Inventory In Use #
700aAC     ikey          chain     invinuse
700aAc                   if        %found
700aAc                   eval      h_ichuid = inuuid
700aAc                   endif
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
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       10
     C                   setoff                                       111213
     C                   setoff                                       14
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       333440
     C                   setoff                                       414243
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
610aAC                   eval      cancel = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcpmq
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
     C                   eval      ovrrid = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzget2
     C                   exsr      zzdft2
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget2
     C                   exsr      zzfil2
     C                   endif
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
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
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
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     C                   endif
     *
     C                   exsr      scr02i
409 D*R                   MOVE '02 '     NXTSCR
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
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr02i
     C                   endif
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = '01 '
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
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
610aAC     cancel        cabeq     *on           endsc2
     C                   endif
     C                   eval      nxtscr = 'EOJ'
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
     *  Initialize message handling
     *
     C                   exsr      zmimsg
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
     *    ZMCPMQ  Clear program message queue.
     *
     C     zmcpmq        begsr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   write     msgctl
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
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
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
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
500 A*----------------------------------------------------------------
500cA*    DRI0001  Local system caused error
500cA*----------------------------------------------------------------
500cA
500cAC     zm0001        begsr
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

500cA*----------------------------------------------------------------
500cA*    DRI0001s Local system caused error (send to different program)
500cA*----------------------------------------------------------------
500cA
500cAC     zm0001s       begsr
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
     *   PIR0201  Code must be entered for create.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    ZM0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
500cA*----------------------------------------------------------------
500cA*      0105s
500cA*
500cAC     zm0105s       begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
500c C                   endsr
     *----------------------------------------------------------------
     *   PIR0110  Value must be > 0.
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
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
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM04     Slot record does not exist.
     *
     C     zm04          begsr
     C                   eval      #msgid = 'IT13204'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      erdisp = w1slot
     C                   movea     errmsg        $md(1)
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
500aA*----------------------------------------------------------------
500aA*     IV21203  Cannot count, Pending quantity exists.
500aA*
500aAC     zm1203        begsr
500aAC                   eval      #msgid = 'IV21203'
500aAC                   eval      #msgtp = '*DIAG  '
500aAC                   movea     errmsg        $md(1)
500aAC                   exsr      zmpmsg
500aAC                   endsr
510dA*----------------------------------------------------------------
510dA*     IV21204  Pallet position required.
510dA*
510dAC     zm1204        begsr
510dAC                   eval      #msgid = 'IV21204'
510dAC                   eval      #msgtp = '*DIAG  '
510dAC                   movea     errmsg        $md(1)
510dAC                   exsr      zmpmsg
510dAC                   endsr
     *----------------------------------------------------------------
     *     IV21301  Quantity entered without item number.
     *
     C     zm1301        begsr
     C                   eval      #msgid = 'IV21301'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
412 A*     IV21302  Not a physical slot
     *
     C     zm1302        begsr
     C                   eval      #msgid = 'IV21302'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
412 A*     IV21303  Virtual slot not allowed for slot w/2-Char handstk
     *
     C     zm1303        begsr
     C                   eval      #msgid = 'IV21303'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
412 A*     IV21304  Virtual slot not created
     *
     C     zm1304        begsr
     C                   eval      #msgid = 'IV21304'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
510bA*     IV21306  Item dept not the same as slot department
510b *
510b C     zm1306        begsr
510b C                   eval      #msgid = 'IV21306'
510b C                   eval      #msgtp = '*DIAG  '
510b C                   movea     errmsg        $md(1)
510b C                   exsr      zmpmsg
510b C                   endsr
     *----------------------------------------------------------------
500cA*     PT13021  Warning: Entered catch wt not within +/- range.
500cA*
500c C     zm21          begsr
500c C                   eval      #msgid = 'PT13021'
500c C                   eval      #msgtp = '*DIAG  '
500c C                   movea     errmsg        $md(1)
500c C                   exsr      zmpmsg
500c C                   endsr
510a *----------------------------------------------------------------
510aA*     IV33002  Slot no in inventory scope.
510a *
510aAC     zm3002        begsr
510a C                   eval      #msgid = 'IV33002'
510a C                   eval      #msgtp = '*DIAG  '
510a C                   movea     errmsg        $md(1)
510a C                   exsr      zmpmsg
510a C                   endsr
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
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7973  Record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     ****                 EXSR ZMSMSG
     ****                 MOVE #MSGK     $PMSG
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Record is locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     ****                 EXSR ZMSMSG
     ****                 MOVE #MSGK     $PMSG
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
610aDC**                 if        $pcmd = '*ADD    '
610aDC**
610aDC** Verify "Physical slot" number.
610aDC**
412 D*R         W1SLOT    IFNE *BLANKS
610aDC**   slkey         chain     slot2                              79
     *R         SLKEY     CHAINSLOT2               N79
610aDC**
610aDC**     Slot doesn't exist.
610aDC**
610aDC**                 if        *in79
610aDC**                 eval      error = *on
610aDC**                 eval      *in33 = *on
610aDC**                 eval      *in13 = *on
610aDC**                 eval      errmsg = *blanks
610aDC**                 movel     w1slot        errmsg
610aDC**                 exsr      zm04
610aDC**                 goto      endck1
610aDC**                 endif
610aA
610aA*  Get slot information.
610aA
610aAC                   exsr      clr$slot
610aAC                   eval      $slwhseu = *on
610aAC                   eval      $slwhse  = $pwhse
610aAC                   eval      $slwhdpu = *on
610aAC                   eval      $slwhdp  = $pwhdp
610aAC                   eval      $sldispu = *on
610aAC                   eval      $sldisp  = w1slot
610aA
610aAC                   eval      $dricommand = '*SLOT'
610aAC                   eval      $drisubcmd  = '%GET'
610aAC                   eval      $drisys2upd = 'D'
610aAC                   eval      chk4err = *on
610aAC                   eval      zmsflag = *off
610aAC                   exsr      zzzdricop
610aAC                   if        error
610aAC                   eval      *in33 = *on
610aAC                   eval      *in13 = *on
610aAC                   eval      errmsg = w1slot
610aAC                   exsr      zm04
610aAC                   goto      endck1
610aAC                   endif
     *
510a *  Verify "Physical slot" is in scope.
510a *
510a *
510a C     slkey         chain     invslot4                           77
510a *      Slot doesn't exist in scope
510a *
510a C                   if        *in77
510a C                   eval      error = *on
510a C                   eval      *in33 = *on
510a C                   eval      *in13 = *on
510aAC                   eval      errmsg = *blanks
510a C                   exsr      zm3002
510a C                   goto      endck1
510a C                   else
510a C                   eval      sadj = ivsadj
510a C                   endif
412 D*R                   ENDIF
610aDC**                 endif                                               E1
412 A*
412 A*  Slot must be a physical slot.
412 A*
610aMC                   if        $slrsrv = 'V'
412 AC                   eval      error = *on
412 AC                   eval      *in33 = *on
412 AC                   eval      *in13 = *on
412 AC                   eval      errmsg = *blanks
610aMC                   movel     $sldisp       errmsg
412 AC                   exsr      zm1302
412 AC                   goto      endck1
412 AC                   endif
412 A*
412 A*  Physical slot can not have two character handstack code.
412 A*
610aMC                   movea     $slhand       a2
412 AC                   if        a2(1) <> ' '
412 AC                   eval      error = *on
412 AC                   eval      *in33 = *on
412 AC                   eval      *in13 = *on
412 AC                   eval      errmsg = *blanks
610aMC                   movel     $sldisp       errmsg
412 AC                   exsr      zm1303
412 AC                   goto      endck1
412 AC                   endif
412 A*
412 A*  Save slot info.
412 A*
610aAC                   eval      svitem = $slitem
610aAC                   eval      svwhse = $slwhse
610aAC                   eval      svwhdp = $slwhdp
610aMC                   eval      svstat = $slstat
610aMC                   eval      svaisl = $slaisl
610aMC                   eval      svloc = $slloc
610aMC                   eval      svrlvl = $slrlvl
610aMC                   eval      svhand = $slhand
610aMC                   eval      svside = $slside
610aMC                   eval      svstyp = $slstyp
610aMC                   eval      svdisp = $sldisp
610aMC                   eval      svsdef = $slsdef
610aMC                   eval      svdesg = $sldesg
610aMC                   eval      svactv = $slactv
610aMC                   eval      svbld = $slbld
610aMC                   eval      svpseq = $slpseq
610aMC                   eval      svslfd = $slslfd
610aMC                   eval      svprty = $slprty
610aAC                   eval      svpick = $slpick
610aDC**
610aDC** Verify that a virtual slot can be created for slot.
610aDC**
610aDC**                 exsr      zzckns
610aDC**                 if        error = *on
610aDC**                 eval      *in33 = *on
610aDC**                 eval      *in13 = *on
610aDC**                 eval      errmsg = *blanks
610aDC**                 movel     w1slot        errmsg
610aDC**                 exsr      zm1304
610aDC**                 goto      endck1
610aDC**                 endif
520b *   W1sitm code was moved from screen 2, w2sitm field moved to sceen1
520b *    Make sure code was entered.
520b *
520b C                   if        w1sitm = *blanks
520b C                   eval      error = *on
520b C                   eval      *in40 = *on
520b C                   exsr      zm01
520b C                   endif
     *
520b C                   if        w1sitm <> *blanks
520b *
520b C                   eval      $lcmd = '*VERIFYS'
520b C                   eval      $lwhse = $pwhse
520b C                   eval      $litem = w1sitm
520b C                   call      'IT900'
520b C                   parm                    $lparm
520b C                   if        $lrtn = '*ERROR  '
520b C                   eval      error = *on
520b C                   eval      *in40 = *on
520b C                   eval      *in55 = *off
520b C                   movel     $lerm         errmsg
520b C                   exsr      zm0105
520b C                   else
520b C                   if        $lrtn = '*PGMQ   '
520b C                   eval      error = *on
520b C                   eval      *in40 = *on
520b C                   eval      *in55 = *off
520b C                   eval      #msgk = $lmsg
520b C                   goto      endck1
520b C                   endif
520b C                   endif
520bA*    Get item info for CW.
520bAC                   exsr      zzgeti
     *
520b * Verify item department is same as slot department
520b C*    itkey         chain     piritem                            78
PAKaAC                   if        Client <> packers
520b C*                  if        itwhdp <> svwhdp
520b C                   if        #toitwhdp <> svwhdp
520b C                   eval      error = *on
520b C                   eval      *in40 = *on
520b C                   exsr      zm1306
520b C                   goto      endck1
520b C                   endif
PAKa C                   endif
     *
520bAC                   eval      w2sitm = w1sitm
520 AC*                  if        itcwgt = 'N'
520bAC                   if        #toitcwgt = 'N'
520bAC                   eval      *in47 = *on
520b C                   else
520bAC                   eval      *in47 = *off
520b C                   endif
     *
520b C                   endif
     *
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     C                   if        $pcmd = '*CHANGE '  or
     C                             $pcmd = '*ADD    '
     *
     *
     *    Make sure code was entered.
     *
520b C*                  if        w2sitm = *blanks
520b C*                  eval      error = *on
520b C*                  eval      *in40 = *on
520b C*                  exsr      zm01
520b C*                  endif
     *
     *    Verify item was entered if a qty was entered.
520b *    Item entered on screen1, w2sitm field is saved from screen 1.
     *
520b C*                  if        w2sqt1 <> 0  or
520b C*                            w2sqt2 <> 0  or
520b C*                            w2sqt3 <> 0
520b C*                  if        w2sitm = *blanks
520b C*                  eval      error = *on
520b C*                  eval      *in40 = *on
520b C*                  eval      *in55 = *off
520b C*                  exsr      zm1201
520b C*                  endif
520b C*                  endif
     *
     *  Verify normal quantity is within range.
     *
     C                   if        w2sqt1 < 0  or
     C                             w2sqt1 > 99999
     C                   eval      error = *on
     C                   eval      *in41 = *on
     C                   eval      *in55 = *off
     *R                   MOVE *ON       *IN10
     C                   eval      errmsg = *blanks
     C                   movel     desc(3)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     *
     *  Verify Breakdown qty 1 is within range.
     *
     C                   if        w2sqt2 < 0  or
     C                             w2sqt2 > 999
     C                   eval      error = *on
     C                   eval      *in42 = *on
     C                   eval      *in55 = *off
     *R                   MOVE *ON       *IN10
     C                   eval      errmsg = *blanks
     C                   movel     desc(4)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '999'         erto
     C                   exsr      zm0112
     C                   endif
     *
     *  Verify Breakdown qty 2 is within range.
     *
     C                   if        w2sqt3 < 0  or
     C                             w2sqt3 > 999
     C                   eval      error = *on
     C                   eval      *in43 = *on
     C                   eval      *in55 = *off
     *R                   MOVE *ON       *IN10
     C                   eval      errmsg = *blanks
     C                   movel     desc(5)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '999'         erto
     C                   exsr      zm0112
     C                   endif
     *
610aDC**
610aDC**   Must enter pallet position if multi position slot def.
610aDC**
610aDC**                 if        w2spos = 0  and
610aDC**                           womult = 'Y'
610aDC**                 eval      error = *on
610aDC**                 eval      *in44 = *on
610aDC**                 eval      errmsg = *blanks
610aDC**                 exsr      zm1204
510dDC*                  exsr      zm1203
610aDC**                 goto      enderr
610aDC**                 endif
610aDC**
610aDC**
610aDC**   Skip check if slot allows multiple positions.
610aDC**   Check if item exists in physical slot or virtual slot.
610aDC**
610aDC**                 if        womult <> 'Y'
610aDC**                 exsr      zzcksl
610aDC**                 if        exist = *on
610aDC**                 eval      error = *on
610aDC**                 eval      *in40 = *on
610aDC**                 eval      *in55 = *off
610aDC**                 exsr      zm1301
610aDC**                 goto      enderr
610aDC**                 endif
610aDC**                 endif
     *
520b * Code for item was moved to Screen 1.
510b * Verify item department is same as slot department
510b C*    itkey         chain     piritem                            78
PAKaAC*                  if        Client <> packers
510b C*                  if        itwhdp <> svwhdp
510b C*                  eval      error = *on
510b C*                  eval      *in40 = *on
510b C*                  exsr      zm1306
510b C*                  goto      enderr
510b C*                  endif
PAKa C*                  endif
520bD *
520bDC*                  if        w2sitm <> *blanks
413bD**                   MOVE '*VERIFY '$LCMD
413bMC*                  eval      $lcmd = '*VERIFYS'
520bDC*                  eval      $lwhse = $pwhse
520bDC*                  eval      $litem = w2sitm
520bDC*                  call      'IT900'
520bDC*                  parm                    $lparm
520bDC*                  if        $lrtn = '*ERROR  '
520bDC*                  eval      error = *on
520bDC*                  eval      *in40 = *on
520bDC*                  eval      *in55 = *off
520bDC*                  movel     $lerm         errmsg
520bDC*                  exsr      zm0105
520bDC*                  else
520bDC*                  if        $lrtn = '*PGMQ   '
520bDC*                  eval      error = *on
520bDC*                  eval      *in40 = *on
520bDC*                  eval      *in55 = *off
520bDC*                  eval      #msgk = $lmsg
520bDC*                  goto      enderr
409bD*R                   EXSR ZMQMSG
520bDC*                  endif
520bDC*                  endif
520bDC*                  endif
     *
520bA*    Get item info for CW.  Moved to Screen1
520bAC*                  exsr      zzgeti
500c C                   eval      woqt01 = w2sqt1
500c C                   eval      woqt02 = w2sqt2
500c C                   eval      woqt03 = w2sqt3
500cA*    Weight can't be zero.
     *
520 AC                   eval      taddw = 0
520 AC                   eval      lwrng = 0
520 AC                   eval      hirng = 0
520 A*   Check catchweight value entered for item.
520 AC*                  if        itcwgt = 'Y'
520bAC                   if        #toitcwgt = 'Y'
520 A*
     C                   if        w2cwgt = 0
500dDC*                  eval      error = *on
500dDC*                  eval      *in09 = *on
500dDC*                  eval      *in46 = *on
500dDC*                  eval      errmsg = *blanks
500dDC*                  movel     desc(4)       errmsg
500dDC*                  exsr      zm0110
500dDC*                  goto      endck2
     C                   endif
     *   Calculate catch weight values for check.
     C                   exsr      zzcwgt
500c C                   z-add     0             taddw             7 2
500c C                   eval      taddw = w2cwgt
     *
     *   WTCHK, Flags are used to force F8 for each test
     *   Values: Flag = 0 Do check.
     *           Flag = 1 Check was done, ok.
     *           Flag = 2 Warning condition.
     *
     C                   eval      error = *off
     * Set flag
     C                   if        wtchk = '2' and
     C                             ovrrid = *on
     C                   eval      wtchk = '1'
     C                   endif
     *  Verify catch weight.
     C                   if        wtchk <> '1'
     C                   eval      wtchk = '1'
     *
     C*     Check individual CW if variance check = Y.
     C                   if        opwrnc = 'Y'
    DC**                           opicw  = 'Y'
500c C**                 z-add     w2cwgt        cwgt              7 0
500c C**   cwgt          div       100           taddw             7 2
500c C*                  z-add     0             taddw             7 2
500c C*                  eval      taddw = cwgt
     C                   if        lvskp = *off and
     C                             taddw < lwrng
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      *in46 = *on
     C*                  eval      *in21 = *on
     C*                  eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   z-add     taddw         ertcwt
     C                   z-add     lwrng         erlrng
     *
     C                   if        hvskp  = *on
     C                   z-add     0             erhrng
     C                   else
     C                   z-add     hirng         erhrng
     C                   endif
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   z-add     exwgt         erexwt
     C*                  z-add     lbuwgt        erexwt
     C                   exsr      zm21
     C                   endif
     *
     C                   if        hvskp  = *off and
     C                             taddw  > hirng
     C                   eval      error = *on
     C                   eval      warn  = *on
     C                   eval      wtchk = '2'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   z-add     taddw         ertcwt
     C                   if        lvskp = *on
     C                   z-add     0             erlrng
     C                   else
     C                   z-add     lwrng         erlrng
     C                   endif
     C                   z-add     hirng         erhrng
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   z-add     exwgt         erexwt
     C                   exsr      zm21
     C                   endif
     *
     C                   endif
     C                   endif
     *
520 AC                   endif
520 A*
     C                   endif
     C     enderr        tag
     *
     C     endck2        endsr
610aDC**---------------------------------------------------------------
610aDC**
610aDC**
610aDC** ZZCKNS   Get new Vslot.
610aDC**
610aDC**   zzckns        begsr
610aDC**                 eval      error = *on
610aDC**  Set handstack flag for later use.
610aDC**                 if        svhand <> ' '
610aDC**                 eval      flaghs = *on
610aDC**                 else
610aDC**                 eval      flaghs = *off
610aDC**                 endif
610aDC***
610aDC**                 eval      $vdisp = *blanks
610aDC**                 eval      k = 0
610aDC**                 eval      $vwhse = svwhse
610aDC**                 eval      $vwhdp = svwhdp
610aDC**                 eval      $vaisl = svaisl
610aDC**                 eval      $vloc = svloc
610aDC**                 eval      $vrlvl = svrlvl
610aDC**                 eval      $vhand = *blanks
610aDC**                 eval      $vstyp = svstyp
610aDC**                 eval      $vpseq = svpseq
610aDC**                 eval      $vdisp = *blanks
610aDC**                 eval      $vpick = slpick
610aDC*** Loop & increment handstack to find new v-slot to create.
414bD*R         K         DOWLE720
610aDC**                 dow       k <= 702
610aDC**                 add       1             k
610aDC**    If physical slot had handstack then limit hs we can use.
610aDC**                 if        flaghs = *on
610aDC**                 movea     hnd(k)        a2n
610aDC**                 if        a2n(1) <> a2(2)
610aDC**                 iter
610aDC**                 endif
610aDC**                 endif
610aDC**                 eval      $vhand = hnd(k)
610aDC**                 call      'FRMTVS'
610aDC**                 parm                    svdisp
610aDC**                 parm                    flaghs
610aDC**                 parm                    $vhand            2
610aDC**                 parm                    $vdisp           12
     *
412 D*R                   CALL 'FRMTSL'
412 D*R                   PARM           $VWHSE  30
412 D*R                   PARM           $VWHDP  5
412 D*R                   PARM           $VAISL  3
412 D*R                   PARM           $VLOC   30
412 D*R                   PARM           $VRLVL  20
412 D*R                   PARM           $VHAND  2
412 D*R                   PARM           $VSTYP  1
412 D*R                   PARM           $VPSEQ  50
412 D*R                   PARM           $VDISP 12
610aDC**   ckkey         chain(n)  slot2                              79
610aDC**                 if        *in79
610aDC**                 eval      newvs = *on
610aDC**                 eval      error = *off
     *R                   MOVE $VDISP    W1DISP
610aDC**                 leave
610aDC**                 else
610aDC**                 iter
610aDC**                 endif
610aDC**                 enddo
610aDC**
610aDC**   endckn        endsr
610aDC**---------------------------------------------------------------
610aDC**
610aDC**
610aDC** ZZCKSL   Check if item exists in reg or V slot
610aDC**
610aDC**   zzcksl        begsr
610aDC**                 eval      exist = *off
520bDC*                  if        svitem = w2sitm
610aDC**                 if        svitem = w1sitm
610aDC**                 eval      exist = *on
610aDC**                 goto      endcks
610aDC**                 else
610aDC**   vskey         setll     vslot2
610aDC**   nxt1          tag
414gD**         VSKEY     READEVSLOT2                   78
610aDC**   vskey         reade(n)  vslot2                                 78
610aDC**                 if        not *in78
610aDC**                 eval      $vdisp = vsdisp
610aDC**   ckkey         chain(n)  slot2                              79
610aDC**                 if        not *in79  and
520bDC*                            slitem = w2sitm
610aDC**                           slitem = w1sitm
610aDC**                 eval      exist = *on
610aDC**                 goto      endcks
610aDC**                 else
610aDC**                 goto      nxt1
610aDC**                 endif
610aDC**                 endif
610aDC**                 endif
610aDC**
610aDC**   endcks        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     C                   eval      cmdtkn = *off
     *
500c *  Test for F8 -  Catch Weight Override
     *
500c C                   if        *inkh
500c C                   move      *on           ovrrid
500c C*                  eval      cmdtkn = *on
500c C                   goto      endcm2
500c C                   else
500c C                   move      *off          ovrrid
500c C                   endif
     C     endcm2        endsr
500cA*----------------------------------------------------------------
500cA*
500cA*  ZZCWGT   Calculate catch weight variance values.
500cA*
500cAC     zzcwgt        begsr
     *
     *  If verify catch weight = yes
     *   Calculate total expected catch weight,
     *   Calculate low/high ranges.
     C                   if        opwrnc = 'Y'
     C                   z-add     0             lwvar
     C                   z-add     0             hivar
     C                   z-add     0             lwrng
     C                   z-add     0             hirng
     C                   z-add     0             exwgt
     C                   z-add     0             exwg2
     C                   z-add     0             ilvar
     C                   z-add     0             ihvar
     C                   z-add     0             ilrng
     C                   z-add     0             ihrng
     C                   z-add     0             swgt2
     *   Calc extended wt.
500c C**   $slvlopickqty mult      $slvlouwgt    exwgt
     C     woqt01        mult      #toitswgt     exwgt
     *   Calc extended wt for each item.
     C                   if        #toitumq2 <> 0
     C     #toitswgt     div       #toitumq2     swgt2
     C     woqt02        mult      swgt2         exwg2
     C                   add       exwg2         exwgt
     C                   endif
     *   Iniz flag used to skip variance check if = *ON.
     C                   eval      lvskp = *off
     C                   eval      hvskp = *off
     *   Use item variance % if it exists.
     C     imkey         chain     itemmsc                            79
     C                   if        *in79 = *off
     C                   if        imrg1c <> 0
     C     imrg1c        div       100           prg1c
     C                   if        imrg1c = 99
     C                   eval      lvskp = *on
     C                   endif
     C                   endif
     *
     C                   if        imrg2c <> 0
     C     imrg2c        div       100           prg2c
     C                   if        imrg2c = 99
     C                   eval      hvskp = *on
     C                   endif
     C                   endif
     *
     C                   endif
     *
     C                   if        prg1c = 0
     C     oprg1c        div       100           prg1c
     C                   endif
     C                   if        prg2c = 0
     C     oprg2c        div       100           prg2c
     C                   endif
     *
     C                   if        prg1c > 0
     C     exwgt         mult      prg1c         lwvar
     C*    $slvlouwgt    mult      prg1c         ilvar
     C     #toitswgt     mult      prg1c         ilvar
     C                   endif
     C     exwgt         sub       lwvar         lwrng
     C*    $slvlouwgt    sub       ilvar         ilrng
     C     #toitswgt     sub       ilvar         ilrng
     C                   if        prg2c > 0
     C     exwgt         mult      prg2c         hivar
     C*    $slvlouwgt    mult      prg2c         ihvar
     C     #toitswgt     mult      prg2c         ihvar
     C                   endif
     C     exwgt         add       hivar         hirng
     C*    $slvlouwgt    add       ihvar         ihrng
     C     #toitswgt     add       ihvar         ihrng
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   eval      w1slot = *blanks
520b C                   eval      w1sitm = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     C                   eval      exist = *off
     C                   eval      newvs = *off
520bDC*                  eval      w2sitm = *blanks
     C                   eval      w2sqt1 = 0
     C                   eval      w2sqt2 = 0
     C                   eval      w2sqt2 = 0
500a C                   eval      w2spos = 0
500c C                   eval      w2cwgt = 0
710bAc* lets seton the appropriate indicators for the breakdown entry
710bA /free
DRYaA   if client = dairyl and  #toitflg1 = 'Y'
710bA    or client <> dairyl;
710bA     eval *in93 = *off;
710bA   else;
710bA     eval *in93 = *on;
710bA   endif;
DRYaA   if client = dairyl and  #toitflg2 = 'Y'
710bA    or client <> dairyl;
710bA     eval *in94 = *off;
710bA   else;
710bA     eval *in94 = *on;
710bA   endif;
710bA /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
710bAc* lets seton the appropriate indicators for the breakdown entry
710bA /free
710bA   if #toitflg1  = 'Y';
710bA     eval *in93 = *off;
710bA   else;
710bA     eval *in93 = *on;
710bA   endif;
710bA   if #toitflg2  = 'Y';
710bA     eval *in94 = *off;
710bA   else;
710bA     eval *in94 = *on;
710bA   endif;
710bA /end-free
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
500a C                   eval      womult = ' '
500a C                   eval      *in45 = *on
610aDC**   slskey        chain     slotdef                            76
610aDC**                 if        not *in76  and
610aDC**                           sdpos > 1
610aDC**                 eval      womult = 'Y'
610aDC**                 eval      *in45 = *off
610aDC**                 endif
500cA*    Get options
500c C                   exsr      zzoptn
     *
     C     endgt2        endsr
500c *----------------------------------------------------------------
500c *
500cAC*  ZZGETI   Get item info
500c *
500cAC     zzgeti        begsr
500cA
500cA*  Use DRI interface to get item.
500cA
500cAC                   exsr      clr$item
500cAC                   eval      $itwhse  = $pwhse
520bDC*                  eval      $ititem  = w2sitm
520bMC                   eval      $ititem  = w1sitm
500cA
500cAC                   eval      $dricommand = '*ITEM'
610aDC**                 eval      $drisubcmd  = '%GETMAIN'
610aAC                   eval      $drisubcmd  = '%GETSLOT'
500cAC                   eval      $drisys2upd = 'D'
500cAC                   eval      chk4err = *on
500cAC                   eval      zmsflag = *off
500cAC                   exsr      zzzdricop
500cAC                   if        error
500cAC                   eval      error = *off
500cAC                   eval      $itdesc = 'ITEM NOT FOUND'
500cAC                   endif
500cA
500cAC                   eval      #toititem = $ititem
500cAC                   eval      #toittype = $ittype
500cAC                   eval      #toitdesc = $itdesc
500cAC                   eval      #toitpdsc = $itpdsc
500cAC                   eval      #toitwhdp = $itwhdp
500cAC                   eval      #toitstyp = $itstyp
500cAC                   eval      #toitdesg = $itdesg
500cAC                   eval      #toitum1  = $itum1
500cAC                   eval      #toitflg1 = $itflg1
500cAC                   eval      #toitum2  = $itum2
500cAC                   eval      #toitumq2 = $itumq2
500cAC                   eval      #toitflg2 = $itflg2
500cAC                   eval      #toitum3  = $itum3
500cAC                   eval      #toitumq3 = $itumq3
500cAC                   eval      #toitnrpk = $imnrpk
500cAC                   eval      #toitflgd = $itflgd
500cAC                   eval      #toitcube = $itcube
500cAC                   eval      #toitswgt = $itswgt
500cAC                   eval      #toitcwgt = $itcwgt
500cAC                   eval      #toitmitem = $itmitem
610aA
610aAC                   eval      tracklevel = $imltrk
500cA
500cA*  Use DRI interface to get corresponding SSB item, if any.
500cA
500cAC                   exsr      clr$item
500cAC                   eval      $itwhse  = $pwhse
520bDC*                  eval      $ititem  = w2sitm
520bMC                   eval      $ititem  = w1sitm
500cA
500cAC                   eval      $dricommand = '*ITEM'
500cAC                   eval      $drisubcmd  = '%GETSSB'
500cAC                   eval      $drisys2upd = 'D'
500cAC                   eval      chk4err = *off
500cAC                   eval      zmsflag = *off
500cAC                   exsr      zzzdricop
500cAC                   if        $drireturn = 'SSBNOTFND'
500cAC                   eval      ssbflg  = *off
500cAC                   eval      #tossbititem = ' '
500cAC                   eval      #tossbittype = ' '
500cAC                   eval      #tossbitdesc = ' '
500cAC                   eval      #tossbitpdsc = ' '
500cAC                   eval      #tossbitwhdp = ' '
500cAC                   eval      #tossbitstyp = ' '
500cAC                   eval      #tossbitdesg = ' '
500cAC                   eval      #tossbitum1  = ' '
500cAC                   eval      #tossbitum2  = ' '
500cAC                   eval      #tossbitumq2 = 0
500cAC                   eval      #tossbitum3  = ' '
500cAC                   eval      #tossbitumq3 = 0
500cAC                   else
500cAC                   eval      ssbflg  = *on
500cAC                   eval      #tossbititem = $ititem
500cAC                   eval      #tossbittype = $ittype
500cAC                   eval      #tossbitdesc = $itdesc
500cAC                   eval      #tossbitpdsc = $itpdsc
500cAC                   eval      #tossbitwhdp = $itwhdp
500cAC                   eval      #tossbitstyp = $itstyp
500cAC                   eval      #tossbitdesg = $itdesg
500cAC                   eval      #tossbitum1  = $itum1
500cAC                   eval      #tossbitum2  = $itum2
500cAC                   eval      #tossbitumq2 = $itumq2
500cAC                   eval      #tossbitum3  = $itum3
500cAC                   eval      #tossbitumq3 = $itumq3
500cAC                   endif

500cAC     endgti        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
510bA*
510bA* Get client id.
510bA*
510bAC                   call      @getcl
510bAC                   parm                    client           10
510bA*
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     *
     *  Define partial key for main file.
     *
     C     partky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     *
     *  Define key for SLOT2 file.
     *
     C     slkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    w1slot
     *
     *  Define key for VSLOT2 file.
     *
     C     vskey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    w1slot
610aDC**
610aDC** Define key for SLOT2 file.
610aDC**
610aDC**   ckkey         klist
610aDC**                 kfld                    $pwhse
610aDC**                 kfld                    $pwhdp
610aDC**                 kfld                    $vdisp
500c *  Define key for INVSCW file.
     *
500c C     cwkey         klist
500c C                   kfld                    $pwhse
500c C                   kfld                    $pwhdp
610aMC                   kfld                    $sldisp
500c C                   kfld                    w2sitm
     *
500c *     ITEMMSC file -
500c C     imkey         klist
500c C                   kfld                    $pwhse
500c C                   kfld                    w2sitm
     *
     *  Define key for INVSLOT file.
     *
     C     ivskey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
610aMC                   kfld                    $slaisl
610aMC                   kfld                    $slloc
610aMC                   kfld                    $slrlvl
610aMC                   kfld                    $slhand
     *
500c *     OPTIONS file
500c C     opkeys        klist
500c C                   kfld                    wkwhse
500c C                   kfld                    wkcode
     *
     *  Define key for INVPAGE2 file.
     *
     C     pagkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    kypage
     *
510b *     PIRITEM file
510b C     itkey         klist
510b C                   kfld                    $pwhse
510b C                   kfld                    w2sitm
     *
500a *  Define key for SLOTDEF.
500a C     slskey        klist
610aMC                   kfld                    $slwhse
610aMC                   kfld                    $slsdef
700aA*    Inventory In Use
700aAC     ikey          klist
700aAc                   kfld                    $pwhse
700bAc                   kfld                    $pwhdp
700aA*    Cycle Count History Header
700aAC     hkey          klist
700aAc                   kfld                    h_ichuid
700aAc                   kfld                    $pwhse
     *
     *
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   eval      #pgmq = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
610aA*
610aA*   Get employee options.
610aA*
610aAC                   call      'GETUSER'
610aAC                   parm      #user         e$code           10
610aAC                   parm                    e$whse            3 0
610aAC                   parm                    e$emp#            5 0
610aAC                   parm                    e$fnam           15
610aAC                   parm                    e$init            1
610aAC                   parm                    e$lnam           20
610aAC                   parm                    e$whdp            5
610aAC                   parm                    e$styp            1
610aAC                   parm                    e$shft            6
610aAC                   parm                    e$crew            6
610aAC                   parm                    e$nhrs            3 1
610aAC                   parm                    e$rtn             8
610aAC                   parm                    e$bpu             1
610aAC                   parm                    e$lng             2
610aAC                   if        e$rtn <> '*OK'
610aAC                   eval      e$lng = 'EN'
610aAC                   endif
     *
     *   Load handstack array with codes (A..Z, AA..AZ, ...)
     *
     C                   eval      k = 0
     C     1             do        27            i
     C     2             do        27            j
     C                   add       1             k
     C     ltr(i)        cat       ltr(j)        hnd(k)
     C                   enddo
     C                   enddo
     *
     C                   eval      newvs = *off
     *
412 AC                   eval      $pcmd = '*ADD    '
     C                   exsr      scr01i
     *
     C     endinz        endsr
500cA*----------------------------------------------------------------
     *
500cA*  ZZOPTN   Get options
     *
500c C     zzoptn        begsr
     *
500c *   Get catch wt options.
     C                   eval      wkcode = '*SYSTEM '
     C                   eval      wkwhse = 0
     *
     C     opkeys        chain     options                            79
     C                   if        *in79
     C                   eval      opcapc = 'Y'
     C                   eval      opwrnc = 'N'
     C                   eval      oprg1c = 0
     C                   eval      oprg2c = 0
     C                   eval      opicw  = 'N'
     C                   endif
     C*
500c C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
412 D*R                   MOVE SLITEM    SVITEM
412 D*R                   Z-ADDSLWHSE    SVWHSE
412 D*R                   MOVE SLWHDP    SVWHDP
412 D*R                   MOVE SLAISL    SVAISL
412 D*R                   Z-ADDSLLOC     SVLOC
412 D*R                   Z-ADDSLRLVL    SVRLVL
412 D*R                   MOVE SLHAND    SVHAND
412 D*R                   Z-ADDSLSIDE    SVSIDE
412 D*R                   MOVE SLSTYP    SVSTYP
412 D*R                   MOVE SLDISP    SVDISP
412 D*R                   MOVE SLSDEF    SVSDEF
412 D*R                   MOVE SLDESG    SVDESG
412 D*R                   MOVE SLACTV    SVACTV
412 D*R                   MOVE SLBLD     SVBLD
412 D*R                   Z-ADDSLPSEQ    SVPSEQ
412 D*R                   Z-ADDSLSLFD    SVSLFD
412 D*R                   Z-ADDSLPRTY    SVPRTY
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
610aA
610aA*  Call license tracking - Before
610aA
610aAC                   if        tracklevel = tLow
610aAC                   eval      $tinlic# = '*CC'
610aAC                   else
610aAC                   exsr      zzzclr$lt210
610aAC                   eval      $tcmd     = '*GETNEW'
610aAC                   eval      $twhse    = svwhse
610aAC                   eval      $titem    = w2sitm
610aAC                   eval      $titemdsc = w2sitm
610aAC                   eval      $tlic#    = ' '
610aAC                   exsr      zzzcall$lt210
610aAC
610aAC                   if        $treturn <> '*OK'
610aAC                   eval      cancel = *on
610aAC                   leavesr
610aAC                   endif
610aA
610aAC                   endif
610aA
610aA*  Put qty in slot.
610aA
610aAC                   exsr      clr$slot
610aAC                   eval      $slwhseu = *on
610aAC                   eval      $slwhse  = svwhse
610aAC                   eval      $slwhdpu = *on
610aAC                   eval      $slwhdp  = svwhdp
610aAC                   eval      $sldispu = *on
610aAC                   eval      $sldisp  = svdisp
610aAC                   eval      $slstatu = *on
610aAC                   if        svstat <> 'Z '  and
610aAC                             svstat <> 'V '
610aAC                   eval      $slstat = svstat
610aAC                   else
610aAC                   eval      $slstat = 'A '
610aAC                   endif
610aA
610aAC                   eval      $saitemu = *on
610aAC                   eval      $saitem  = #toititem
610aAC                   eval      $saqtyu = *on
610aAC                   eval      $saqty1 = 0
610aAC                   eval      $saqty2 = 0
610aAC                   eval      $saqty3 = 0
610aA
610aAC                   eval      $saActionU = *on
610aAC                   eval      $saAction = 'CNT'
610aAC                   eval      $saETrn#U = *on
610aAC                   eval      $saETrn# = 0
610aAC                   eval      $saToLcnsU = *on
610aAC                   eval      $saToLcns = $tinlic#
610aAC                   eval      $saToPosU = *on
610aAC                   eval      $saToPos = 1
610aAC                   eval      $saToVrfyU = *on
610aAC                   eval      $saToVrfy = 'Y'
610aAC                   eval      $saToCodeu = *on
610aAC                   eval      $saToCode = 'S'
610aAC                   eval      $saToAreaU = *on
610aAC                   eval      $saToArea = 'Slot'
610aA
610aAC                   eval      $dricommand = '*SLOT'
610aAC                   eval      $drisubcmd  = '%QTY2PUT0'
610aAC                   eval      $drisys2upd = 'D'
610aAC                   eval      chk4err = *on
610aAC                   eval      zmsflag = *off
610aAC                   exsr      zzzdricop
610aAC                   if        error
610aAC                   goto      endup2
610aAC                   endif
     *
     *
     *   Get last page of INVPAGE2
     *
     C                   eval      kypage = 99999
     C     pagkey        setgt     invpage2
     C                   readp     invpage2                               79
     C                   if        not *in79
     C                   eval      sheet = ivppag
     C                   if        ivpvtl = *off  or
     C                             ivpcnt = 15
     *
     C     $pwhse        chain     invnxtp                            7978
     *
     *  Record locked.
     *
     C                   select
     C                   when      *in78
     C                   eval      error = *on
    D*R                   MOVE '*PGMQ   '$PRTN
    D*R                   EXSR ZM78
     *
     *  Record found - Get next page number and update record.
     *
     C                   other
     C                   eval      sheet = ivxpag
     C                   add       1             ivxpag
     C                   update    ivxrec
     *
     C                   endsl
     *
     *     Initialize fields for the next page record.
     *
     C                   clear                   ivprec
     C                   eval      ivppag = sheet
610aMC                   eval      ivpwhs = $slwhse
     C                   eval      ivpsta = 'E'
610aMC                   eval      ivpwhd = $slwhdp
610aMC                   eval      ivpasl = $slaisl
610aMC                   eval      ivplvl = $slrlvl
610aMC                   eval      ivpstp = $slstyp
     C                   movel     'VIRTUAL'     ivpfrm
     C                   movel     'VIRTUAL'     ivpto
     C                   eval      ivpcnt = 1
     C                   eval      ivppdt = today
     C                   time                    ivpptm
     C                   eval      ivpedt = today
     C                   time                    ivpetm
     C                   eval      ivpmor = *off
     C                   eval      ivpvtl = *on
     C                   write     ivprec
     C                   else
     C     ivpcnt        add       1             ivpcnt
     C                   update    ivprec
     C                   endif
     C                   endif
     *
     C     ivskey        chain(n)  invslot                            79
     C                   if        not *in79
     C                   eval      pexp = ivspex
     C                   else
     C                   eval      pexp = 'N'
     C                   endif
610aDC**  Create Virtual Slot
610aDC**
610aDC**                 exsr      zzckns
610aDC**                 if        error = *on
610aDC**                 eval      *in21 = *on
610aDC**                 eval      *in01 = *on
610aDC**                 eval      errmsg = *blanks
610aDC**                 movel     w1slot        errmsg
610aDC**                 exsr      zm1304
610aDC**                 goto      endup2
610aDC**                 endif
610aDC**
610aDC**                 if        newvs = *on
610aDC**                 eval      slitem = w2sitm
610aDC**                 eval      slwhse = $vwhse
610aDC**                 eval      slwhdp = $vwhdp
610aDC**                 if        svstat <> 'Z '  and
610aDC**                           svstat <> 'V '
610aDC**                 eval      slstat = svstat
610aDC**                 else
610aDC**                 eval      slstat = 'A '
610aDC**                 endif
610aDC**                 eval      slaisl = $vaisl
610aDC**                 eval      slloc = $vloc
610aDC**                 eval      slrlvl = $vrlvl
610aDC**                 eval      slhand = $vhand
610aDC**                 eval      slside = svside
610aDC**                 eval      slstyp = $vstyp
610aDC**                 eval      sldisp = $vdisp
610aDC**                 eval      slsdef = svsdef
610aDC**                 eval      sldesg = svdesg
610aDC**                 eval      slactv = svactv
610aDC**                 eval      slbld = svbld
412 D*R                   MOVE 'N'       SLPICK
610aDC**                 eval      slpick = $vpick
610aDC**                 eval      slpseq = $vpseq
610aDC**                 eval      slslfd = svslfd
610aDC**                 eval      slslfd = 0
610aDC**                 eval      slrsrv = 'V'
610aDC**                 eval      slentd = today
610aDC**                 eval      slexpd = 0
610aDC**                 eval      slsdte = today
610aDC**                 time                    slstim
610aDC**                 eval      slprty = svprty
610aDC**                 eval      slstk1 = 0
610aDC**                 eval      slstk2 = 0
610aDC**                 eval      slstk3 = 0
610aDC**                 eval      slalc1 = 0
610aDC**                 eval      slalc2 = 0
610aDC**                 eval      slalc3 = 0
610aDC**                 eval      sltfr1 = 0
610aDC**                 eval      sltfr2 = 0
610aDC**                 eval      sltfr3 = 0
610aDC**                 eval      slpck1 = 0
610aDC**                 eval      slpck2 = 0
610aDC**                 eval      slpck3 = 0
610aDC**                 eval      slrcv1 = 0
610aDC**                 eval      slrcv2 = 0
610aDC**                 eval      slrcv3 = 0
610aDC***
610aDC**                 write     slrec                                79
610aDC**                 if        *in79
610aDC**                 eval      $prtn = '*PGMQ   '
610aDC**                 eval      error = *on
610aDC**                 exsr      zm72
610aDC**                 goto      endup2
610aDC**                 endif
610aDC** create vslot record.
610aDC**                 eval      vswhse = $vwhse
610aDC**                 eval      vswhdp = $vwhdp
610aDC**                 eval      vsaisl = $vaisl
610aDC**                 eval      vsloc = $vloc
610aDC**                 eval      vsrlvl = $vrlvl
610aDC**                 eval      vshand = $vhand
610aDC**                 eval      vsdisp = $vdisp
610aDC**                 eval      vspdis = svdisp
610aDC**                 eval      $cvcmd = '*CURCMD '
610aDC**                 call      @cvtdt
610aDC**                 parm                    $cvtdt
610aDC**                 eval      vscdte = $cvd8o
610aDC**                 time                    vsctim
610aDC**                 add       1             vsctim
610aDC**                 write     vsrec                                79
610aDC**                 if        *in79
610aDC**                 eval      $prtn = '*PGMQ   '
610aDC**                 eval      error = *on
610aDC**                 exsr      zm72
610aDC**                 goto      endup2
610aDC**                 endif
     *
     *     Initialize record fields before add.
     *
     C     ivskey        chain     invslot                            79
     *
     C                   if        *in79
610aMC                   eval      ivswhs = $slwhse
     C                   eval      ivspag = sheet
610aMC                   eval      ivsdsp = $sldisp
610aMC                   eval      ivssta = $slstat
610aMC                   eval      ivswhd = $slwhdp
610aMC                   eval      ivsasl = $slaisl
610aMC                   eval      ivsloc = $slloc
610aMC                   eval      ivslvl = $slrlvl
610aMC                   eval      ivshnd = $slhand
610aMC                   eval      ivsstp = $slstyp
610aMC                   eval      ivssid = $slside
640aAC                   eval      ivspck = $slpick
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ivspdt = $cvd8o
     C                   time                    ivsptm
     C                   eval      ivsedt = $cvd8o
     C                   time                    ivsetm
     C                   eval      ivseby = #user
     C                   eval      ivscdt = 0
     C                   eval      ivsctm = 0
     C                   eval      ivscby = *blanks
     C                   eval      ivspex = pexp
     C                   eval      ivsitm = w2sitm
     C                   eval      ivsqt1 = w2sqt1
     C                   eval      ivsqt2 = w2sqt2
     C                   eval      ivsqt3 = w2sqt3
510a C                   eval      ivsadj = sadj
     C                   write     ivsrec                               79
700aAc                   eval      icdbqty1 = w2sqt1
700aAc                   eval      icdbqty2 = w2sqt2
700aAc                   eval      icdbqty3 = w2sqt3
700aAc                   if        ivsadj <> *blanks
700aAc                   eval      icdadj1 = w2sqt1
700aAc                   eval      icdadj2 = w2sqt2
700aAc                   eval      icdadj3 = w2sqt3
700aAc                   endif
700aAc                   eval      icdsldsp = ivsdsp
700aAc                   eval      icdwhsdp = ivswhd
700bAc                   eval      icwhse   = ivswhs
700aAc                   eval      icdslcnt = 'N'
700aAc                   eval      icdsltts = %timestamp
700aAC                   if        ivsedt > 0
700aAc                   eval      icdslcnt= 'Y'
700aAc                   endif
700aAc                   write     icdrec
     *
700bDC*    hkey          chain     ichcnth
700bAC     hkey          chain     invhsth
700aAc                   if        %found
700aAc                   eval      H_ichcycnt = H_ichcycnt + 1
700aAc                   update    ichrec
700aAc                   endif
     *
     C                   if        *in79
     C                   eval      $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endup2
     C                   endif
500a C                   if        womult = 'Y'
500a C                   eval      ivowhs = ivswhs
500a C                   eval      ivodsp = ivsdsp
500a C                   eval      ivowhd = ivswhd
500a C                   eval      ivoasl = ivsasl
500a C                   eval      ivoloc = ivsloc
500a C                   eval      ivolvl = ivslvl
500a C                   eval      ivohnd = ivshnd
500a C                   eval      ivopos = w2spos
500a C                   write     ivorec
500a C                   endif
     C                   endif
     *
520 A*     Only update Slot Catchwgt file for catchwgt items.
520 AC*                  if        itcwgt = 'Y'
520bAC                   if        #toitcwgt = 'Y'
520 A*
500c C     cwkey         chain     invscw                             79
500c *
500c C                   if        not *in79
500c C                   eval      $cvcmd = '*CURCMD '
500c C                   call      @cvtdt
500c C                   parm                    $cvtdt
500c C                   eval      ivwedt = $cvd8o
500c C                   time                    ivwctm
500c C                   eval      ivwcby = #user
500c C                   eval      ivwwgt = taddw
500c C                   eval      ivwlrg = lwrng
500c C                   eval      ivwhrg = hirng
500c C                   eval      ivwwtx = ovrrid
500c C                   update    ivwrec
500c C                   else
500c C                   eval      $cvcmd = '*CURCMD '
500c C                   call      @cvtdt
500c C                   parm                    $cvtdt
500c C                   eval      ivwedt = $cvd8o
500c C                   time                    ivwetm
500c C                   eval      ivweby = #user
500c C                   eval      ivwwhs = ivswhs
500c C                   eval      ivwdsp = ivsdsp
500c C                   eval      ivwwhd = ivswhd
500c C                   eval      ivwasl = ivsasl
500c C                   eval      ivwloc = ivsloc
500c C                   eval      ivwlvl = ivslvl
500c C                   eval      ivwhnd = ivshnd
500c C                   eval      ivwstp = ivsstp
500c C                   eval      ivwitm = ivsitm
500c C                   eval      ivwsid = ivssid
500c C                   eval      ivwwgt = taddw
500c C                   eval      ivwlrg = lwrng
500c C                   eval      ivwhrg = hirng
500c C                   eval      ivwwtx = ovrrid
     *
500c C                   write     ivwrec
500c C                   endif
520 A*
520 AC                   endif
     *
500c C                   eval      ovrrid = *off
500c C                   eval      wtchk = *off
500c C                   eval      woqt01 = 0
500c C                   eval      woqt02 = 0
500c C                   eval      woqt03 = 0
     *
610aDC**                 endif
     *
     *
     *
     *R         $RRTN     IFEQ '*OK     '
     *R                   MOVE $RRTN     $PRTN
     *R                   MOVE $RMSG     $PMSG
     *  If no error was found then send message to calling program.
     *R                   CALL 'MOVMSGP'
     *R                   PARM           $PPRG
     *R                   ENDIF
     *
     *   Move key values to parameters
     *
     C     endup2        endsr
     *
500cA*----------------------------------------------------------------
500cA*----------------------------------------------------------------
500cA*                     DRI SUBROUTINES
500cA*----------------------------------------------------------------
500cA*----------------------------------------------------------------
     *
500cA*----------------------------------------------------------------
500cA*  clr$item  Clear $item data structure fields
500cA*----------------------------------------------------------------
     *
500cAC     clr$item      begsr
500c C                   eval      savever# = $itver#
500c C                   clear                   $item
610aAC                   clear                   $item2
500c C                   eval      $itver# = savever#
500c C                   endsr

610aA*----------------------------------------------------------------
610aA*  clr$slot  Clear $slot data structure fields
610aA*----------------------------------------------------------------
610aA
610aAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = e$emp#
     C                   endsr
500c *
500cA*----------------------------------------------------------------
500cA*  zzzdricop  Call DRICOP
500cA*----------------------------------------------------------------
     *
500cAC     zzzdricop     begsr
500c C                   eval      error = *off
      *
500c C                   select
610aAC                   when      $dricommand = '*SLOT'
610aAC                   eval      $dridata = $slot
610aAC                   eval      $dridata2 = $slot2
500c C                   when      $dricommand = '*ITEM'
500c C                   eval      $dridata = $item
500c C                   eval      $dridata2 = $item2
500c C                   endsl
     *
500c C                   if        $dricommand = '*ITEM'
610aAC                             or $dricommand = '*SLOT'
500c C                   call(e)   'DRICOP'
500c C                   parm                    $dricommand
500c C                   parm                    $drisubcmd
500c C                   parm                    $drisys2upd
500c C                   parm      #pgm          $driprogram
500c C                   parm      ' '           $drireturn
500c C                   parm      ' '           $drimessage
500c C                   parm                    $dridata
500c C                   parm                    $dridata2
500c C                   else
500c C                   call(e)   'DRICOP'
500c C                   parm                    $dricommand
500c C                   parm                    $drisubcmd
500c C                   parm                    $drisys2upd
500c C                   parm      #pgm          $driprogram
500c C                   parm      ' '           $drireturn
500c C                   parm      ' '           $drimessage
500c C                   parm                    $dridata
500c C                   endif
     *
500c C                   select
     *
500c C                   when      chk4err and %error
500c C                   eval      error = *on
500c C                   eval      errmsg    = 'Error occured on call to '
500c C                                       + 'DRICOP'
500c C                                       + '/' + %trim($drisubcmd)
500c C                                       + ' from ' + #prog
500c C                   if        zmsflag
500c C                   exsr      zm0105s
500c C                   else
500c C                   exsr      zm0105
500c C                   endif
     *
500c C                   when      chk4err and $drireturn <> '*OK'
500c C                   eval      error = *on
500c C                   if        zmsflag
500c C                   exsr      zm0001s
500c C                   else
500c C                   exsr      zm0001
500c C***                exsr      zzerrind
500c C                   endif
     *
500c C                   endsl
     *
500c C                   select
610aAC                   when      $dricommand = '*SLOT'
610aAC                   eval      $slot = $dridata
610aAC                   eval      $slot2 = $dridata2
500c C                   when      $dricommand = '*ITEM'
500c C                   eval      $item = $dridata
500c C                   eval      $item2 = $dridata2
500c C                   endsl
     *
500c C                   eval      zmsflag = *off
500c C                   eval      chk4err = *off
500c C     enddricop     endsr

610aA*----------------------------------------------------------------
610aA*----------------------------------------------------------------
610aA*  License Plate Tracking Routines
610aA*----------------------------------------------------------------
610aA*----------------------------------------------------------------

610aA*----------------------------------------------------------------
610aA*  ZZZCLR$LT210  -  Clear LT210 parameters.
610aA*----------------------------------------------------------------
610aA
610aAC     ZZZCLR$LT210  begsr

     C                   clear                   $tcmd
     C                   clear                   $tprogram
     C                   clear                   $ttype
     C                   clear                   $thead
     C                   clear                   $twhse
     C                   clear                   $titem
     C                   clear                   $titemdsc
     C                   clear                   $twhdp
     C                   clear                   $tslot
     C                   clear                   $tslotpos
     C                   clear                   $templ#
     C                   clear                   $ttran#
     C                   clear                   $tlic#
     C                   clear                   $tnewlic#
     C                   clear                   $tqty1
     C                   clear                   $tqty2
     C                   clear                   $tqty3
     C                   clear                   $tnorm1
     C                   clear                   $tnorm2
     C                   clear                   $tnorm3
     C                   clear                   $tpartial
     C                   clear                   $tpulled
     C                   clear                   $tinslot
     C                   clear                   $tsamepos
     C                   clear                   $tdiffpos
     C                   clear                   $tpsplit
     C                   clear                   $tinlic#
     C                   clear                   $toutlic#
     C                   clear                   $tnexttask
     C                   clear                   $treturn
     C                   clear                   $terrmsg
     C                   clear                   $tmsgid

     C                   endsr

610aA*----------------------------------------------------------------
610aA*  ZZZCALL$LT210  -  Call LT210 program.
610aA*----------------------------------------------------------------
610aA
610aAC     ZZZCALL$LT210 begsr

     C                   eval      $thead = 'Inv Count'

     C                   call      'LT210'
     C                   parm                    $tcmd
     C                   parm      #prog         $tprogram
     C                   parm      'INV'         $ttype
     C                   parm                    $thead
     C                   parm                    $twhse
     C                   parm                    $titem
     C                   parm                    $titemdsc
     C                   parm                    $twhdp
     C                   parm                    $tslot
     C                   parm                    $tslotpos
     C                   parm      0             $templ#
     C                   parm                    $ttran#
     C                   parm                    $tlic#
     C                   parm                    $tnewlic#
     C                   parm                    $tqty1
     C                   parm                    $tqty2
     C                   parm                    $tqty3
     C                   parm                    $tnorm1
     C                   parm                    $tnorm2
     C                   parm                    $tnorm3
     C                   parm                    $tpartial
     C                   parm                    $tpulled
     C                   parm                    $tinslot
     C                   parm                    $tsamepos
     C                   parm                    $tdiffpos
     C                   parm                    $tpsplit
     C                   parm                    $tinlic#
     C                   parm                    $toutlic#
     C                   parm                    $tnexttask
     C                   parm                    $treturn
     C                   parm                    $terrmsg
     C                   parm                    $tmsgid

     C                   if        %error
     C                   eval      $treturn = $treturn
     C                   endif
     C                   endsr


     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Normal quantity
Breakdown 1 quantity
Breakdown 2 quantity
Catch weight
Average
UPC code
Number of pallets
**
 ABCDEFGHIJKLMNOPQRSTUVWXYZ
