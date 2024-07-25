500 A /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   845 W. Roosevelt Rd.  #8-51
     *   West Chicago, IL 60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IV212     Inventory sheet maint - Change
     *  24 January, 1996
     *  Roxanne Harrison
     *
     *  SK112 - 1.02
     *
     *  Revisions
     *
     *  02/13/96 RH V2.10
     *       Use multiple occurance data structure for subfile screen.
     *  04/04/96 RH V2.10
     *       Add 'F4=Prompt' to screen IV212.01.
408 A*    01/12/97  RH    4.08
     *      - Re-compiled, INVSLOT file changed.
409 A*    07/21/98  RH
     *      - Change command line to 2 lines.
     *      - Add F6 to create virtual slots based on OPTIOND manual
     *        put away option.
411 A*    05/05/99  RH
     *      - Update INVEXCP status = 4(closed) when INVSLOT changed.
     *      - If INVSLOT status = X(exception) change to SLOT1 status.
     *
413 A*    02/28/00  DAS  4.13
     *      - Revised to verify item number using command *VERIFYS.
     *        This command verifies that the item is allowed to be
     *        put into the slot. Currently, only ' ' and 'B' items
     *        are allowed into slots.
414aA*    05/12/00  RH   4.14a
     *      - Recompiled, file INVSLOT changed.
414bA*    05/26/00  RH   4.14b
     *      - Add F9 option to look up license info.
414cA*    08/30/00  RRH  4.14c
     *      - Add error check, can't change item if slot has quantity
     *        other than stock quantity.
415aA*    06/04/01  RH   4.15a
     *      - Add parms to call LP130.
416 A*  09/25/01  RH   4.16
     *    - Recompile - INVSLOT file changed.
416aA*  12/15/01  DAS  4.16a
     *    - Removed aisle from partial key.
     *    - Added IVSASL to MSFILE data structure.
     *    - Used IVSASL instead of $PSASL in keys.
     *    - Added hidden field IVSALS to format - IV212FM.
416bA*  05/15/02  RH   4.16b
     *    - Add F10 to show entire sheet as entered.
417aA*    12/10/03  RH   4.17a
     *      - Enh: If slot has pending quantity, remove from scope.
     *        write to INVCHK slot to be manually checked for count.
     *        Update from and to slot in INVPAGE.
500aA*    04/27/05  RH   5.00a
     *      - Enh: Add slot position.
500bA*    09/08/05  RH   5.00b
     *      - Enh: Verify item entered has same dept as slot.
500cA*    06/02/06  RH   5.00c
     *      - Enh: Add OPT 1 to call CW Entry IV214
     *      - Capture qty in MSQTY DS to send to IV214
510aA*    07/10/06  RH   5.10a
     *      - Enh: Add License tracking option. Protect and set
     *        POS = 1 if tracking option is No.
510bA*    08/23/06  RH   5.10b
     *      - Enh: Added client code.
510cA*    11/15/06  RH   5.10c
     *      - Enh: Only verify item dept = slot dept if item changed
510dA*    12/20/06  RH   5.10d
     *      - Add F10 option to look up sheet.
510eA*    06/05/07  RH   5.10e
     *      - Fix: $QTY was being used as array but not defined as one
     *        Change to use OQTY to call IV214
510fA*    06/16/07  RH   5.10f
     *      - Enh: Remove from INVSASN slot assignment when slot is
     *        written to INVCHK file for pending quantity.
510gA*    08/28/07  RH   5.10g
     *      - Enh: Position cursor to slot if slot passed in.  Need to
     *             add keyword CURSOR to IV212FM.
610aA*    09/18/09  RH   6.10a
     *      - Enh: Convert to ILE.
     *      - Enh: Rename IV212FM to IV21201
     *      - Enh: Add option 3=License listing.
     *      - Enh: Force pallet position tracking=N, do not use option
610bA*    10/05/10  RH   6.10b
     *      - Enh: Remove pallet Position, no longer needed with license tracki
     *             Make displayed item description larger.
     *             Change to use IV21202 format member.
700aA*    08/18/16  MR   7.00a
     *      - Enh: Update inventory count history when INVSLOT is          acki
     *             updated for history purposes.
700bA*  09/14/16  LMC  7.00b
     *    - Enh: New history files names changed.
     *    - Enh: Dept added to invinuse file to ensure unique # is
     *           by whse/department.
700cA*  11/15/16  NLK  7.00c
     *    - Fix: LP130 uses LCNS / LP130B uses TRAN
     *      Change LP130 to LP130A and cont using TRAN
710aA*  03/23/17  LMC  7.10a
     *    - Enh: Database change to INVHSTD. Recompile only.
710bA*  05/12/17  LMC  7.10b
     *    - Enh: Using different indicators to allow entry of
     *      breakdown quantities.
710cA*  12/22/17  LMC  7.10c
     *    - Enh: Database change to INVHSTD. Recompile only.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions
PAKaA*    05/03/13  RH   CDIa
PAKaA*      -  Revised program to NOT exclude slots with pending qty
PAKaA*         for JAX only.
     *----------------------------------------------------------------
PAKaA*    08/23/06  RH   PAKa
     *      - Enh: Do not allow CW entry for Packer
     *----------------------------------------------------------------
     *  Client Custom Revisions  - Chefs Warehouse
DRYaA*    05/12/17  LMC  DRYa
     *      -  Revised program to only display breakdown quantities
     *         for the breakdown fields 1 & 2 if the item is setup
     *         for allow entry on that breakdown field.
     *---------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
     *  85        Manually set subfile change flag (SFLNXTCHG)
     *  90        View mode (Protect input fields)
     *  91        Change mode (protect key)
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
710bDF*iv21202   cf   e             workstn
710bMFiv21203   cf   e             workstn
610bDF*v21201   cf   e             workstn
610aDF*v212fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(detail1:recno)
     F                                     sfile(msgrec:msgk)
     Finvslot1  uf   e           k disk
     F                                     rename(ivsrec:record)
     Finvpage   uf   e           k disk
411 AFinvexcp1  uf   e           k disk
411 AFslot1     if   e           k disk
     Fpiritem   if   e           k disk
409 AFoptiond   if   e           k disk
510aAFoptions   if   e           k disk
417a Fslot2     if   e           k disk
     F                                     rename(slrec:slrec2)
610bDF*lotdef   if   e           k disk
700aAFinvinuse  if   e           k disk
700bAFinvhstd   uf   e           k disk
700bDF*icdcntd   uf   e           k disk
417a Finvbslt4  uf   e           k disk
417a Finvslot4  uf   e           k disk
610bDF*nvspos   uf a e           k disk
510f Finvsasn   uf   e           k disk
417a Finvchk    o  a e           k disk
CDIaA /copy qcopysrc,id#cdi
DRYaA /copy qcopysrc,id#dairyla
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             50    dim(5) ctdata perrcd(1)
414bMD cmdln           s             79    dim(13) ctdata perrcd(1)
414bD*                   CMDLN   1  12 79
409 D*                   CMDLN   1   4 79
     *----------------------------------------------------------------
510b *
510bA /copy qcopysrc,id#packers
610aDD*@getcl          c                   const('GETCLIENT')
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
     D  $pswhs                19     21  0
     D  $pspag                22     26  0
     D  $pswhd                27     31
     D  $psasl                32     34
510g D  $pdisp                35     46
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
500cA*----------------------------------------------------------------
500cAD oqty            ds
500cAD  oqt1                   1      7  0 inz(0)
500cAD  oqt2                   8     10  2 inz(0)
500cAD  oqt3                  11     13  0 inz(0)
     *----------------------------------------------------------------
500cAD $qtds           ds
500cAD  $qty                   1     13
     D                                     DIM(1)
500cA*                                       1 195 $QTY
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
     *  Multiple occurance data structure for subfile screen
     *
     D msfile          ds                  occurs(99)
     D  ivsdsp                 1     12
     D  ivsloc                13     15  0 inz(0)
     D  ivslvl                16     17  0 inz(0)
     D  ivshnd                18     19
     D  w1sqt1                20     24  0 inz(0)
     D  w1sqt2                25     27  0 inz(0)
     D  w1sqt3                28     30  0 inz(0)
     D  w1sitm                31     45
610bMD  w1desc                46     65
500c D* w1desc                46     60
610bMD  recno                 66     69  0
500c D* recno                 61     64  0
610bMD  ivsasl                70     72
500c D* ivsasl                65     67
500a D* w1spos                68     70  0
500c *                                      46  63 W1DESC
500c *                                      64  670RECNO
500c *                                      68  70 IVSASL
500c *                                      71  730W1SPOS
     *----------------------------------------------------------------
     *  Workstation exception data structure
     *
     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371
     D  @sfl                 378    379b 0
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
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D @sflsv          s                   like(@sfl)
     D chgflg          s              1
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
     D ikyitm          s                   like(ivsitm)
     D ikywhs          s                   like(ivswhs)
     D kycode          s                   like(opdcod)
     D msgk            s              4  0
     D nxtscr          s              3
     D opflg           s              1
     D pgctr           s              1  0
     D pgflg           s              1
     D pndflg          s              1
     D posrec          s              4  0
     D r               s              2  0
     D reccnt          s              4  0
     D redspl          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
710bAD*savein45        s               n
710bAD*savein47        s               n
     D sclear          s              1
     D sctr            s              2  0
     D stop            s              1
     D todsp           s             12
     D tqt1            s              6  0
     D tqt2            s              4  0
     D tqt3            s              4  0
     D warn            s              1
     D xctr            s              2  0
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
     C                   eval      *in85 = *on
     C                   eval      *in37 = *off
     C                   eval      *in38 = *off
710bAC                   eval      *in45 = *off
710bAC                   eval      *in47 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     * Get Inventory In Use #
700aAC     ikey          chain     invinuse
700aAc                   if        %found
700aAc                   eval      icduid = inuuid
700aAc                   endif
     *
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
     C                   read      head1                                  50
     C                   z-add     @sfl          @sflsv
     *
     C                   when      nxtscr = '02 '
     C                   exfmt     screen2
     *
     C                   when      nxtscr = '03 '
     **                   EXFMTSCREEN3
     *
     C                   endsl
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
     C                   setoff                                       36
     *R                   SETOF                     3738
     C                   setoff                                       3940
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
     C                   eval      *in91 = *on
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
     *R                   MOVE *ON       *IN91
     *R                   EXSR ZZGET2
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
     C                   eval      *in91 = *on
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
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
     C                   endif
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
417a C                   if        pgflg = *on
417a C                   exsr      zzuppg
417a C                   endif
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
500c C                   exsr      zzckop
500c C     error         cabeq     *on           endsc1
500c C     redspl        cabeq     *on           endsc1
500c C                   eval      option = *blanks
     C                   exsr      zzupd1
500C C     opflg         cabeq     *on           endsc1
     *R         REDSPL    CABEQ*ON       ENDSC1
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
     C                   exsr      scr02i
     *R                   MOVE 'EOJ'     NXTSCR
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     *R         *INKC     IFEQ *ON
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   MOVE '*EXIT   '$PRTN
     *R                   GOTO ENDSC2
     *R                   END
     *
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
417a *  Update INVPAGE with new first and last slot.
417a C                   if        pgflg = *on
417a C                   exsr      zzuppg
417a C                   endif
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
510g C                   eval      $prtn = '*OK     '
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
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr03i
     C                   endif
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   if        $pcmd = '*ADD    '
     C                   eval      nxtscr = '01 '
     C                   else
     C                   eval      nxtscr = 'EOJ'
     C                   endif
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
     C                   exsr      zzupd3
     C     redspl        cabeq     *on           endsc3
     C     error         cabeq     *on           endsc3
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
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
610aDC*                  call      @getcl
610aMC                   call      'GETCLIENT'
510bAC                   parm                    client           10
610aAC                   parm                    clientloc        10
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
510gAC                   if        ivsdsp = $pdisp
510gAC                   eval      posnbr = reccnt
510gAC                   endif
     C                   eval      recno = reccnt
     C                   write     detail1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      recno = 0
     C                   eval      reccnt = 0
     C                   eval      posrec = 1
     *
     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
     C                   eval      *in84 = *on
     C                   write     head1
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
     C                   write     cmdrec
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   if        reccnt > 0
     C                   eval      *in81 = *on
     C                   endif
     C                   eval      recno = posrec
     C                   if        @sflsv = 0
     C                   z-add     1             @sflsv
     C                   endif
     C                   z-add     @sflsv        recno
     C                   write     head1
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
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
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
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
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
500c C                   movel     option        errmsg
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
     *    ZM9805
     *
     C     zm9805        begsr
     C                   eval      #msgid = 'PIR9805'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      errmsg = desc(2)
     C                   movea     errmsg        $md(1)
     *R                   EXSR ZMPMSG
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
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
     C                   eval      *in77 = *off
     C                   dou       *in77
     C                   readc     detail1                                77
     C                   eval      *in40 = *off
     C                   eval      *in41 = *off
     C                   eval      *in42 = *off
     C                   eval      *in43 = *off
500A C                   eval      *in46 = *off
     C                   eval      *in55 = *on
    AC                   eval      *in56 = *on
     C                   if        not *in77
     *
     C                   if        w1sqt1 <> 0  or
     C                             w1sqt2 <> 0  or
     C                             w1sqt3 <> 0
     C                   if        w1sitm = *blanks
     C                   eval      error = *on
     C                   eval      *in40 = *on
     C                   eval      *in55 = *off
     C                   exsr      zm1201
     C                   endif
     C                   endif
     *
500a C                   if        w1sqt1 <> 0  or
500a C                             w1sqt2 <> 0  or
500a C                             w1sqt3 <> 0
610bDC*                  if        w1spos = 0  and
610bDC*                            not *in44
610bDC*                  eval      error = *on
610bDC*                  eval      *in46 = *on
610bDC*                  eval      *in55 = *off
610bDC*                  exsr      zm1204
610bDC*                  endif
500a C                   endif
     *
     *  Verify normal quantity is within range.
     *
     C                   if        w1sqt1 < 0  or
     C                             w1sqt1 > 99999
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
     C                   if        w1sqt2 < 0  or
     C                             w1sqt2 > 999
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
     C                   if        w1sqt3 < 0  or
     C                             w1sqt3 > 999
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
     *
     C                   if        w1sitm <> *blanks
413 D**                   MOVE '*VERIFY '$LCMD
413 MC                   eval      $lcmd = '*VERIFYS'
     C                   eval      $lwhse = $pswhs
     C                   eval      $litem = w1sitm
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in40 = *on
     C                   eval      *in55 = *off
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in40 = *on
     C                   eval      *in55 = *off
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
510c *  Only check if Item dept = slot dept if item changed.
510cAC                   if        w1sitm <> ivsitm
500bAC                   eval      ikywhs = $pswhs
500b C                   eval      ikyitm = w1sitm
500b C     itkey         chain     piritem                            77
500b C                   if        not *in77
500b C                   if        itwhdp <> $pswhd
500b C                   eval      error = *on
500b C                   eval      *in40 = *on
500b C                   eval      *in55 = *off
500b C                   eval      errmsg = *blanks
500b C                   exsr      zm5203
500b C                   endif
500b C                   endif
510c C                   endif
     *
     C                   endif
     *
414cAC                   if        w1sitm <> ivsitm
414cAC                   if        w1alc1 <> 0  or
414cAC                             w1alc2 <> 0  or
414cAC                             w1alc3 <> 0  or
414cAC                             w1tfr1 <> 0  or
414cAC                             w1tfr2 <> 0  or
414cAC                             w1tfr3 <> 0  or
414cAC                             w1pck1 <> 0  or
414cAC                             w1pck2 <> 0  or
414cAC                             w1pck3 <> 0  or
414cAC                             w1rcv1 <> 0  or
414cAC                             w1rcv2 <> 0  or
414cAC                             w1rcv3 <> 0
414c C                   eval      error = *on
414c C                   eval      *in40 = *on
414c C                   eval      *in55 = *off
414c C                   eval      errmsg = *blanks
414c C                   exsr      zm1202
414c C                   endif
414c C                   endif
     *
     C                   update    detail1
     C                   endif
     C                   enddo
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
417a *----------------------------------------------------------------
417a *
417a *  ZZCKQT   Check if slot has pending quantities.
417a *
417a C     zzckqt        begsr
417a C                   eval      error = *off
417a C                   eval      pndflg = *off
417a *
417a *  Check if slot has pending quantities.
417a C     slkey1        chain     slot2                              78
417a C                   if        not *in78
417a C                   if        slalc1 <> 0  or
417a C                             slalc2 <> 0  or
417a C                             slalc3 <> 0  or
417a C                             sltfr1 <> 0  or
417a C                             sltfr2 <> 0  or
417a C                             sltfr3 <> 0  or
417a C                             slpck1 <> 0  or
417a C                             slpck2 <> 0  or
417a C                             slpck3 <> 0  or
417a C                             slrcv1 <> 0  or
417a C                             slrcv2 <> 0  or
417a C                             slrcv3 <> 0
417a C                   eval      pndflg = *on
417a *  Write to Inventory Check file.
417a C                   exsr      zzupck
417a *  Remove slot from INVPAGE count
417a C     keypg         chain     invpage                            75
417a C                   if        not *in75
417a *  IF slot is first or last on page, set flag to update INVPAGE.
417a C                   if        ivpfrm = ivsdsp  or
417a C                             ivpto = ivsdsp
417a C                   eval      pgflg = *on
417a C                   endif
417a C                   eval      ivpcnt = ivpcnt - 1
417a *  IF slot is only one on the page, update INVPAGE as entered.
417a C                   if        ivpfrm = ivsdsp  and
417a C                             ivpto = ivsdsp
417a C                   eval      pgflg = *off
417a C                   exsr      zzupdp
417a C                   else
417a C                   update    ivprec                               79
417a C                   endif
417a C                   endif
417a *
417a *  Remove slot from INVBSLT
417a C     slkey1        chain     invbslt4                           75
417a C                   if        not *in75
417a C                   delete    ibsrec
417a C                   endif
510f *  Remove slot from assignment
510f C     slkey         chain     invsasn                            79
510f C                   if        not *in79
510f C                   delete    ivgrec
510f C                   endif
417a *  Remove slot from scope.
417a C     slkey1        chain     invslot4                           79
417a C                   if        not *in79
417a C                   delete    ivsrec
417a C                   endif
417a *
417a C                   endif
417a C                   endif
417a *
417a C     endckq        endsr
500c *----------------------------------------------------------------
500c *
500c *  ZZCKOP   Check option.
500c *
500c C     zzckop        begsr
500c *
500c *  When change ....
500c *
500c C                   eval      opflg = *off
500c C                   if        $pcmd = '*CHANGE '
500c C                   eval      error = *off
500c C                   eval      *in77 = *off
500c C                   dou       *in77
500c C                   readc     detail1                                77
500c C                   eval      *in40 = *off
500c C                   eval      *in41 = *off
500c C                   eval      *in42 = *off
500c C                   eval      *in43 = *off
500A C                   eval      *in46 = *off
500c C                   eval      *in55 = *on
500cAC                   eval      *in56 = *on
500c C                   if        not *in77
500c *
500c C                   if        option <> *blanks  and
500c C                             option <> '1'
610aAC                             and option <> '3'
500c C                   eval      error = *on
500c C                   eval      *in21 = *on
500c C                   eval      *in55 = *off
500c C                   exsr      zm0108
500c C                   endif
PAKa *
PAKa C                   if        client = packer  and
PAKa C                             option = '1'
PAKa C                   eval      error = *on
PAKa C                   eval      *in21 = *on
PAKa C                   eval      *in55 = *off
PAKa C                   exsr      zm0108
PAKa C                   endif
500c *
500c C                   if        option = '1'  and
PAKa C                             client <> packer
500c C                   eval      opflg = *on
500c *    Verify CW item
500cAC                   eval      ikywhs = $pswhs
500c C                   eval      ikyitm = w1sitm
500c C     itkey         chain     piritem                            76
500c C                   if        not *in76  and
500b C                             itcwgt <> 'Y'
500b C                   eval      error = *on
500b C                   eval      *in21 = *on
500b C                   eval      *in55 = *off
500b C                   eval      errmsg = *blanks
500b C                   exsr      zm1305
500b C                   else
500c C                   eval      oqt1 = w1sqt1
500c C                   z-add     w1sqt2        oqt2
500c C                   eval      oqt3 = w1sqt3
500c C                   z-add     recno         r
510eD****                 MOVE OQTY      $QTY,R
500c C                   eval      $lcmd = '*CHANGE '
500c C                   eval      $lwhse = $pswhs
500c C                   eval      $lwhd = ivswhd
500c C                   eval      $ldsp = ivsdsp
500c C                   eval      $litm = w1sitm
500c C                   call      'IV214'
500c C                   parm                    $lparm
510eMC                   parm                    oqty
510eD***                  PARM           $QTY
500c C                   select
500c C                   when      $lrtn = '*ERROR  '
500c C                   eval      error = *on
500c C                   eval      *in21 = *on
500c C                   eval      *in55 = *off
500c C                   movel     $lerm         errmsg
500c C                   exsr      zm0105
500c C                   when      $lrtn = '*PGMQ   '
500c C                   eval      error = *on
500c C                   eval      *in21 = *on
500c C                   eval      *in55 = *off
500c C                   eval      #msgk = $lmsg
500c C                   exsr      zmqmsg
500c C                   when      $lrtn = '*CANCEL '
500c C                   eval      redspl = *on
500c C                   other
500c C                   eval      option = *blanks
500c C                   endsl
500c C                   endif
500c C                   endif
610aA*
610aAC                   if        option = '3'
500c C                   eval      opflg = *on
610aAC                   call      'LT310'
610aAC                   parm      '*VIEW'       $scmd             8
610aAC                   parm      $pswhs        $swhse            3 0
610aAC                   parm      ivswhd        $swhdp            5
610aAC                   parm      ivsdsp        $sdisp           12
610aAC                   parm      ' '           $sitem           15
610aAC                   parm      ' '           $sdev            10
610aAC                   parm      ' '           $sform           10
500c C                   eval      option = *blanks
610aAC                   endif
600eA*
610a C
500c *
500c C                   update    detail1
500c C                   endif
500c C                   enddo
500c C                   endif
500c *
500c *  When adding ....
500c *
500c C                   if        $pcmd = '*ADD    '
500c C                   endif
500c *
500c C     endopt        endsr
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
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
710bAc                   if        *in37 = *on
     C                   eval      *in56 = *on
    AC                   exsr      zzupsb
     C                   eval      cmdtkn = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lprg = #prog
     C                   eval      $lwhse = $pswhs
     C                   eval      $litem = w1sitm
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C     @rec          chain     detail1                            77
DRYaA /free
DRYaA   if w1sitm <> $litem and client = dairyl;
DRYaA     chain (ikywhs: $litem) piritem;
DRYaA     if %found(piritem);
DRYaA       *in45 = *off;
DRYaA       savein45 = *off;
DRYaA       *in47 = *off;
DRYaA       savein47 = *off;
DRYaA       w1flg1 = itflg1;
DRYaA       w1flg2 = itflg2;
DRYaA       if itflg1 = 'Y';
DRYaA         savein47 = *on;
DRYaA       endif;
DRYaA       if itflg2 = 'Y';
DRYaA         savein45 = *on;
DRYaA       endif;
DRYaA     endif;
DRYaA   endif;
DRYaA /end-free
     C                   eval      w1sitm = $litem
710bAc                   eval      savew1itm = $litem
     C                   movel     $lerm         w1desc
     C                   eval      *in56 = *off
     C                   update    detail1
     C                   endif
     *
710bAc                   else
710bAC                   eval      cmdtkn = *on
710bAC                   endif
     C                   endif
409 A*
409 A*  Test for F6 - Add Virtual Slot
409 A*
409 AC                   if        opmput = 'Y'
409 AC                   if        *inkf
409 AC                   eval      *in56 = *on
409 AC                   exsr      zzupsb
409 AC                   eval      cmdtkn = *on
409 AC                   eval      $lcmd = '*CREATE '
409 AC                   eval      $lprg = #prog
409 AC                   eval      $lwhse = $pswhs
409 AC                   eval      $lwhd = $pswhd
409 AC                   call      'IV213'
409 AC                   parm                    $lparm
    D*R         $LRTN     IFEQ '*SELECT '
    D*R         @REC      CHAINDETAIL1              77
    D*R                   MOVE $LITEM    W1SITM
    D*R                   MOVEL$LERM     W1DESC
    D*R                   MOVE *OFF      *IN56
    D*R                   UPDATDETAIL1
    D*R                   ENDIF
409 A*
409 AC                   endif
409 AC                   endif
     *
     *  Test for F7 - Item # entry toggel
     *
     C                   if        *inkg
      * Chef's - do to the change for controlling the breakdown entry
      * fields for this client - if the items are enabled to be changed
      * We need to turn off the enbble breakdown. Because if the item
      * is changed, the breakdown fields will need to  be reset, once
      * the item is updated.
      * as long as enable item is turned on enable breakdown can not be
      * turned on for Chef's.
    AC                   eval      *in56 = *on
    AC                   exsr      zzupsb
     C                   eval      cmdtkn = *on
     C                   if        *in37
     C                   eval      *in37 = *off
     C                   else
     C                   eval      *in37 = *on
     C                   eval      *in55 = *off
DRYaA /free
DRYaA   if client = dairyl;
DRYaA     *in38 = *off;
DRYaA     *in45 = *off;
DRYaA     *in47 = *off;
DRYaA   endif;
DRYaA /end-free
     C                   endif
     C                   if        *in37  and
     C                             *in38  and
409 AC                             opmput = 'N'
409 MC                   eval      cmdln1 = cmdln(4)
414bMC                   eval      cmdln2 = cmdln(13)
414bD*R                   MOVE *BLANKS   CMDLN2
409 D*R                   MOVE CMDLN,4   CMDLN2
     C                   endif
409 AC                   if        *in37  and
409 AC                             *in38  and
409 AC                             opmput = 'Y'
409 AC                   eval      cmdln1 = cmdln(11)
409 AC                   eval      cmdln2 = cmdln(12)
409 AC                   endif
     C                   if        *in37  and
     C                             not *in38  and
409 AC                             opmput = 'N'
409 MC                   eval      cmdln1 = cmdln(2)
414bMC                   eval      cmdln2 = cmdln(13)
414bD*R                   MOVE *BLANKS   CMDLN2
409 D*R                   MOVE CMDLN,2   CMDLN2
     C                   endif
409 AC                   if        *in37  and
409 AC                             not *in38  and
409 AC                             opmput = 'Y'
409 AC                   eval      cmdln1 = cmdln(7)
409 AC                   eval      cmdln2 = cmdln(8)
409 AC                   endif
     C                   if        not *in37  and
     C                             not *in38  and
409 AC                             opmput = 'N'
409 MC                   eval      cmdln1 = cmdln(1)
414bMC                   eval      cmdln2 = cmdln(13)
414bD*R                   MOVE *BLANKS   CMDLN2
409 D*R                   MOVE CMDLN,1   CMDLN2
     C                   endif
409 AC                   if        not *in37  and
409 AC                             not *in38  and
409 AC                             opmput = 'Y'
409 MC                   eval      cmdln1 = cmdln(5)
409 AC                   eval      cmdln2 = cmdln(6)
409 AC                   endif
     C                   if        not *in37  and
     C                             *in38  and
409 AC                             opmput = 'N'
409 MC                   eval      cmdln1 = cmdln(3)
414bMC                   eval      cmdln2 = cmdln(13)
414bD*R                   MOVE *BLANKS   CMDLN2
409 D*R                   MOVE CMDLN,3   CMDLN2
     C                   endif
409 AC                   if        not *in37  and
409 AC                             *in38  and
409 AC                             opmput = 'Y'
409 MC                   eval      cmdln1 = cmdln(9)
409 AC                   eval      cmdln2 = cmdln(10)
409 AC                   endif
     C                   exsr      zzupsb
    AC     @rec          chain     detail1                            77
    AC                   eval      *in56 = *off
710baC                   eval      *in45 = savein45
710bac                   eval      *in47 = savein47
    AC                   update    detail1
     C                   endif
     *
     *  Test for F8 - Breakdown qty entry toggel
     *
     C                   if        *inkh
    AC                   eval      *in56 = *on
    AC                   exsr      zzupsb
     C                   eval      cmdtkn = *on
DRYaA /free
DRYaA   if client = dairyl and *in37 = *off
DRYaA      or client <> dairyl;
710bM     if *in38;
710bM       *in38 = *off;
710bM     else;
710bM       *in38 = *on;
710bM     endif;
DRYaA   endif;
DRYaA /end-free
     C                   if        *in37  and
     C                             *in38  and
409 AC                             opmput = 'N'
409 MC                   eval      cmdln1 = cmdln(4)
414bMC                   eval      cmdln2 = cmdln(13)
414bD*R                   MOVE *BLANKS   CMDLN2
409 D*R                   MOVE CMDLN,4   CMDLN2
     C                   endif
409 AC                   if        *in37  and
409 AC                             *in38  and
409 AC                             opmput = 'Y'
409 MC                   eval      cmdln1 = cmdln(11)
409 AC                   eval      cmdln2 = cmdln(12)
409 AC                   endif
     C                   if        *in37  and
     C                             not *in38  and
409 AC                             opmput = 'N'
409 MC                   eval      cmdln1 = cmdln(2)
414bMC                   eval      cmdln2 = cmdln(13)
414bD*R                   MOVE *BLANKS   CMDLN2
409 D*R                   MOVE CMDLN,2   CMDLN2
     C                   endif
409 AC                   if        *in37  and
409 AC                             not *in38  and
409 AC                             opmput = 'Y'
409 AC                   eval      cmdln1 = cmdln(7)
409 AC                   eval      cmdln2 = cmdln(8)
409 AC                   endif
     C                   if        not *in37  and
     C                             not *in38  and
409 AC                             opmput = 'N'
409 MC                   eval      cmdln1 = cmdln(1)
414bMC                   eval      cmdln2 = cmdln(13)
414bD*R                   MOVE *BLANKS   CMDLN2
409 D*R                   MOVE CMDLN,1   CMDLN2
     C                   endif
409 AC                   if        not *in37  and
409 AC                             not *in38  and
409 AC                             opmput = 'Y'
409 AC                   eval      cmdln1 = cmdln(5)
409 AC                   eval      cmdln2 = cmdln(6)
409 AC                   endif
     C                   if        not *in37  and
     C                             *in38  and
409 AC                             opmput = 'N'
409 MC                   eval      cmdln1 = cmdln(3)
414bMC                   eval      cmdln2 = cmdln(13)
414bD*R                   MOVE *BLANKS   CMDLN2
409 D*R                   MOVE CMDLN,3   CMDLN2
     C                   endif
409 AC                   if        not *in37  and
409 AC                             *in38  and
409 AC                             opmput = 'Y'
409 MC                   eval      cmdln1 = cmdln(9)
409 AC                   eval      cmdln2 = cmdln(10)
409 AC                   endif
     C                   exsr      zzupsb
    AC     @rec          chain     detail1                            77
    AC                   eval      *in56 = *off
710baC                   eval      *in45 = savein45
710bac                   eval      *in47 = savein47
    AC                   update    detail1
     C                   endif
     C                   endif
414bA*
414bA*  Test for F9 - License info.
414bA*
414bAC                   if        *inki
700cD **                 call      'LP130'
700cAC                   call      'LP130B'
415aAC                   parm      '        '    $lpcmd            8
415aAC                   parm      0             $lptrn            7 0
414bAC                   eval      cmdtkn = *on
414bAC                   endif
510dA*
510dA*  Test for F10 - Item/page info.
510dA*
510dAC                   if        *inkj
510dAC                   call      'IV220'
510dA**                   PARM '        '$LPCMD  8
510dA**                   PARM 0         $LPTRN  70
510dAC                   eval      cmdtkn = *on
510dAC                   endif
500cA*
500cA*  Test for F11 - Catch Wt. Entry
500cA*
500cA*R         *INKK     IFEQ *ON
500cA*R                   MOVE *ZEROS    $QTDS
500cA*R                   EXSR ZZUPQT
500cA*R                   MOVE '*CHANGE '$LCMD
500cA*R                   MOVE $PUKY     $LUKY
500cA*R                   CALL 'IV214'
500cA*R                   PARM           $LPARM
500cA*R                   PARM           $QTY
500cA*R                   MOVE *ON       CMDTKN
500cA*R                   ENDIF
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
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
     *  Test for F4 - Lookup
     *
     *R         *INKD     IFEQ *ON
     *R                   MOVE *ON       CMDTKN
     *R                   Z-ADD0         ROW#
     *R                   MOVE ROWIN     ROW
     *R                   Z-ADD0         COL#
     *R                   MOVE COLIN     COL
     *R                   ENDIF
416bA*
416bA*      F10 - Enter entire sheet
416bA*
416bAC                   if        *inkj
416bAC                   eval      entflg = *on
416bAC                   else
416bAC                   eval      entflg = *off
416bAC                   endif
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
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   exsr      sflclr
510gAC                   eval      posnbr = 1
     *
     C     partky        setll     invslot1
     C                   eval      done = *off
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     partky        reade(n)  invslot1                               79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
500c C                   eval      option = *blanks
417a *  Check if slot has pending quantities.
CDIaAC                   if        clientloc <> 'CDIJAX'
417a C                   exsr      zzckqt
CDIaAC                   endif
417a *
417a C                   if        pndflg = *off
     C                   eval      w1sitm = ivsitm
710bAC                   eval      savew1itm = ivsitm
     C                   eval      w1sqt1 = ivsqt1
     C                   eval      w1sqt2 = ivsqt2
     C                   eval      w1sqt3 = ivsqt3
     C                   eval      ikywhs = ivswhs
     C                   eval      ikyitm = ivsitm
     C     itkey         chain     piritem                            77
     C                   if        not *in77
     C                   movel     itdesc        w1desc
710bAc                   eval      w1flg1 = itflg1
710bac                   eval      w1flg2 = itflg2
     C                   else
     C                   eval      w1desc = *blanks
     C                   endif
500a **  Get pallet position.
610bDC*    slkey         chain     invspos                            77
610bDC*                  if        not *in77
610bDC*                  eval      w1spos = ivopos
610bDC*                  else
610bDC*                  if        not *in44
610bDC*                  eval      w1spos = 0
610bDC*                  else
610bDC*                  eval      w1spos = 1
610bDC*                  endif
610bDC*                  endif
500a **
414c C     slkey         chain     slot1                              77
414c C                   if        not *in77
414c C                   eval      w1alc1 = slalc1
414c C                   eval      w1alc2 = slalc2
414c C                   eval      w1alc3 = slalc3
414c C                   eval      w1tfr1 = sltfr1
414c C                   eval      w1tfr2 = sltfr2
414c C                   eval      w1tfr3 = sltfr3
414c C                   eval      w1pck1 = slpck1
414c C                   eval      w1pck2 = slpck2
414c C                   eval      w1pck3 = slpck3
414c C                   eval      w1rcv1 = slrcv1
414c C                   eval      w1rcv2 = slrcv2
414c C                   eval      w1rcv3 = slrcv3
610bDC*    slskey        chain     slotdef                            76
610bDC*                  if        not *in76  and
610bDC*                            sdpos > 1
610bDC*                  eval      w1mult = 'Y'
610bDC*                  else
610bDC*                  eval      w1mult = ' '
610bDC*                  endif
414c C                   else
610bDC*                  eval      w1spos = 0
414c C                   eval      w1alc1 = 0
414c C                   eval      w1alc2 = 0
414c C                   eval      w1alc3 = 0
414c C                   eval      w1tfr1 = 0
414c C                   eval      w1tfr2 = 0
414c C                   eval      w1tfr3 = 0
414c C                   eval      w1pck1 = 0
414c C                   eval      w1pck2 = 0
414c C                   eval      w1pck3 = 0
414c C                   eval      w1rcv1 = 0
414c C                   eval      w1rcv2 = 0
414c C                   eval      w1rcv3 = 0
414c C                   endif
     C                   exsr      sfladd
417a C                   endif
     C                   endif
     C                   enddo
     C                   eval      posrec = 1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     C                   eval      w2tqt1 = tqt1
     C                   eval      w2tqt2 = tqt2
     C                   eval      w2tqt3 = tqt3
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
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
     *R                   EXSR ZZGET1
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET3   Get record(s) for screen 3.
     *
     C     zzget3        begsr
     *R                   EXSR ZZGET1
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
     C                   kfld                    $pswhs
     C                   kfld                    $pspag
     C                   kfld                    $pswhd
416aD**                   KFLD           $PSASL
416aMC                   kfld                    ivsasl
     C                   kfld                    ivsloc
     C                   kfld                    ivslvl
     C                   kfld                    ivshnd
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $pswhs
     C                   kfld                    $pspag
     C                   kfld                    $pswhd
416aD**                   KFLD           $PSASL
     *
     *  Define key for INVPAGE file.
     *
     C     ipkey         klist
     C                   kfld                    $pswhs
     C                   kfld                    $pspag
     *
     *  Define key for SLOT1 file.
     *
     C     slkey         klist
     C                   kfld                    $pswhs
     C                   kfld                    $pswhd
416aD**                   KFLD           $PSASL
416aMC                   kfld                    ivsasl
     C                   kfld                    ivsloc
     C                   kfld                    ivslvl
     C                   kfld                    ivshnd
     *
417a C     slkey1        klist
417a C                   kfld                    $pswhs
417a C                   kfld                    $pswhd
417a C                   kfld                    ivsdsp
417a *
417a *  Define key for INVPAGE file.
417a *
417a C     keypg         klist
417a C                   kfld                    $pswhs
417a C                   kfld                    $pspag
417a *
     *
     *  Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    ikywhs
     C                   kfld                    ikyitm
     *
500a *  Define key for SLOTDEF.
500a C     slskey        klist
500a C                   kfld                    $pswhs
500a C                   kfld                    slsdef
700aA*    Cycle Count History Detail
700aAC     dkey          klist
700aAc                   kfld                    icduid
700bAc                   kfld                    $pswhs
700bAc                   kfld                    $pswhd
     c                   kfld                    ivsdsp
700aA*    Inventory In Use
700aAC     ikey          klist
700aAc                   kfld                    $pswhs
700bAc                   kfld                    $pswhd
     *
     *  Define key for OPTIOND.
     *
409 AC     opkey2        klist
409 AC                   kfld                    kycode
409 AC                   kfld                    $pswhs
409 AC                   kfld                    $pswhd
     C                   eval      kycode = '*PICK   '
416bAC                   eval      entflg = *off
CDIaAC                   eval      pndflg = *off
510a *
510a *  Define key for OPTIONS.
510a *
510aAC     opkey         klist
510aAC                   kfld                    $pswhs
510aAC                   kfld                    kycode
     *
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *  Setup and command display lines.
409 AC                   exsr      zzputo
409 AC                   if        opmput = 'Y'
409 AC                   eval      cmdln1 = cmdln(5)
409 AC                   eval      cmdln2 = cmdln(6)
409 AC                   else
     C                   eval      cmdln1 = cmdln(1)
414bMC                   eval      cmdln2 = cmdln(13)
414bD*R                   MOVE *BLANKS   CMDLN2
409 AC                   endif
     C                   z-add     1             @sfl
     C                   eval      *in56 = *on
510a *
510aAC                   exsr      zzltrk
     *
     C                   exsr      scr01i
     C                   if        reccnt <= 0
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm9805
     C                   endif
     C     endnz2        endsr
510a *----------------------------------------------------------------
510a *
510aA*  ZZLTRK   Get License tracking option.
510a *
510aAC     zzltrk        begsr
510a *
510aAC                   eval      *in44 = *off
510aAC                   eval      kycode = '*TRACKSP'
510aAC     opkey         chain     options                            79
510aAC                   if        *in79
510aAC                   eval      opsptr = 'N'
510aAC                   endif
610aA*  Force pallet position tracking opiton to 'N', do not use
610aAC                   eval      opsptr = 'N'
510aAC                   if        opsptr = 'N'
510aAC                   eval      *in44 = *on
510aAC                   else
510aAC                   eval      *in44 = *off
510aAC                   endif
     *
409 AC                   endsr
     *----------------------------------------------------------------
     *
409 A*  ZZPUTO   Get Put away option.
     *             Directed or Manual put away
     *
409 AC     zzputo        begsr
     *
409 AC                   eval      kycode = '*PICK   '
409 AC     opkey2        chain     optiond                            79
409 AC                   if        *in79
409 AC                   eval      opmput = 'N'
409 AC                   endif
     *
409 AC                   endsr
     *----------------------------------------------------------------
411 A*
411 A*  ZZUEXC   Update Exception records.
     *
411 AC     zzuexc        begsr
     *
     *     Get record.
     *
     C     fileky        chain     invexcp1                           74
     *
     *     Record found.
     *
     C                   if        not *in74  and
     C                             chgflg = *on
     C                   eval      ivesta = '4'
     C                   update    iverec                               73
     C                   endif
     *
     *
411 AC                   endsr
500a *----------------------------------------------------------------
500aA*
500aA*  ZZUPOS   Update pallet position records.
500a *
500aAC     zzupos        begsr
500a *
500a *     Get record.
500a *     Will only add record if posiiton is entered.
500a *
610bDC*    slkey         chain     invspos                            74
500a *
500a *     Record found.
500a *
610bDC*                  if        not *in74
500a **         CHGFLG    ANDEQ*ON
610bDC*                  eval      ivopos = w1spos
610bDC*                  update    ivorec                               73
610bDC*                  else
610bDC*                  if        w1spos <> 0
610bDC*                  eval      ivowhs = $pswhs
610bDC*                  eval      ivodsp = ivsdsp
610bDC*                  eval      ivowhd = $pswhd
610bDC*                  eval      ivoasl = ivsasl
610bDC*                  eval      ivoloc = ivsloc
610bDC*                  eval      ivolvl = ivslvl
610bDC*                  eval      ivohnd = ivshnd
610bDC*                  eval      ivopos = w1spos
610bDC*                  write     ivorec
610bDC*                  endif
610bDC*                  endif
     *
500aAC                   endsr
417a *----------------------------------------------------------------
417a *
417a *  ZZUPCK   Create Inventory Check record
417a *
417a C     zzupck        begsr
417a C                   eval      ivcwhs = ivswhs
417a C                   eval      ivcdsp = ivsdsp
417a C                   eval      ivcsta = *on
417a C                   eval      ivcwhd = ivswhd
417a C                   eval      ivcasl = ivsasl
417a C                   eval      ivcloc = ivsloc
417a C                   eval      ivclvl = ivslvl
417a C                   eval      ivchnd = ivshnd
417a C                   eval      ivcstp = ivsstp
417a C                   eval      $cvcmd = '*CURCMD '
417a C                   call      @cvtdt
417a C                   parm                    $cvtdt
417a C                   eval      ivcsdt = $cvd8o
417a C                   time                    ivcstm
417a C                   eval      ivceby = #user
417a C                   eval      ivcedt = $cvd8o
417a C                   movel     '*PNDQTY'     ivcrsn
417a C                   write     ivcrec                               79
417a C                   if        *in79
417a C                   eval      error = *on
417a C                   exsr      zm7871
417a C                   goto      endckc
417a C                   endif
417a C     endckc        endsr
     *
500c *----------------------------------------------------------------
500cA*
500cA*  ZZUPQT   Read subfile records and load OQTY array.
500cA*
500cAC     zzupqt        begsr
     *
     *   Loop through changed subfile records and update.
     *
     *R                   MOVE *OFF      *IN77
     *R         *IN77     DOUEQ*ON
     *R                   READCDETAIL1                  77
     *R         *IN77     IFEQ *OFF
     *R                   UPDATDETAIL1
500c *R                   Z-ADDW1SQT1    OQT1
500c *R                   Z-ADDW1SQT2    OQT2
500c *R                   Z-ADDW1SQT3    OQT3
500c *R                   Z-ADDRECNO     R       20
500c *R                   MOVE OQTY      $QTY,R
     *R                   ENDIF
     *R                   ENDDO
     C                   endsr
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
     C                   readc     detail1                                77
     C                   if        not *in77
710bA /free
710bA     select;
710bA       when *in38 = *off;
710bA         *in47 = *off;
710bA         *in45 = *off;
DRYaA         if w1sitm <> savew1itm and client = dairyl;
DRYaA           chain (ikywhs: w1sitm) piritem;
DRYaA           if %found(piritem);
DRYaA             *in45 = *off;
DRYaA             savein45 = *off;
DRYaA             *in47 = *off;
DRYaA             savein47 = *off;
DRYaA             w1flg1 = itflg1;
DRYaA             w1flg2 = itflg2;
DRYaA             savew1itm = w1sitm;
DRYaA             if itflg1 = 'Y';
DRYaA               savein47 = *on;
DRYaA             endif;
DRYaA             if itflg2 = 'Y';
DRYaA               savein45 = *on;
DRYaA             endif;
DRYaA             w1desc = itdesc;
DRYaA           endif;
DRYaA         endif;
DRYaA       when client = dairyl and w1flg1 = 'Y'
710bA            or client <> dairyl;
710bA         *in47 = *on;
710bA       other;
710bA         *in47 = *off;
710bA     endsl;
            savein47 = *in47;
710bA     select;
710bA       when *in38 = *off;
710bA         *in47 = *off;
710bA         *in45 = *off;
DRYaA       when client = dairyl and w1flg2 = 'Y'
710bA            or client <> dairyl;
710bA         *in45 = *on;
710bA       other;
710bA         *in45 = *off;
710bA     endsl;
          savein45 = *in45;
710bA /end-free
     C                   update    detail1
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
     *
     *   Loop through changed subfile records and add/update file.
     *
     *R                   MOVE *OFF      *IN77
     *R         *IN77     DOUEQ*ON
     *R                   READCDETAIL1                  77
     *R         *IN77     IFEQ *ON
     *R                   LEAVE
     *R                   ENDIF
210 A*   Go through data structure and add/update file.
210 A*
210 AC     1             do        sctr          xctr
210 AC     xctr          occur     msfile
411 AC                   eval      chgflg = *off
     *
     *     Get detail record.
     *
     C     fileky        chain     record                             7978
     *
     *     Record locked. Tell user to try again.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in39 = *on
     C                   eval      *in40 = *on
     C                   eval      *in19 = *on
210 D*R                   UPDATDETAIL1
     C                   eval      errmsg = desc(1)
     C                   exsr      zm7872
     C                   exsr      sfldsp
     C                   leave
     C                   endif
     *
     *     Initialize record fields before trying to add or update.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        ivsedt = *zero
416b C                   if        entflg = *on
     C                   eval      ivsedt = $cvd8o
     C                   time                    ivsetm
     C                   eval      ivseby = #user
416b C                   endif
     C                   else
     C                   if        w1sqt1 <> ivsqt1  or
     C                             w1sqt2 <> ivsqt2  or
     C                             w1sqt3 <> ivsqt3  or
     C                             w1sitm <> ivsitm
     C                   eval      ivscdt = $cvd8o
     C                   time                    ivsctm
     C                   eval      ivscby = #user
411 AC                   eval      chgflg = *on
     C                   endif
     C                   endif
     C                   eval      ivsitm = w1sitm
     C                   eval      ivsqt1 = w1sqt1
     C                   eval      ivsqt2 = w1sqt2
     C                   eval      ivsqt3 = w1sqt3
411 A*
411 A*     Change status if = 'X ' for exception.
411 AC                   if        ivssta = 'X '  and
411 AC                             chgflg = *on
411 AC     slkey         chain     slot1                              74
411 AC                   if        not *in74
411 AC                   eval      ivssta = slstat
411 AC                   endif
411 AC                   endif
     *
     *     Record not found.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in39 = *on
     C                   eval      *in40 = *on
     C                   eval      *in19 = *on
210 D*R                   UPDATDETAIL1
     C                   eval      errmsg = desc(1)
     C                   exsr      zm7871
     C                   exsr      sfldsp
     C                   leave
     C                   endif
     *
700bDC*    dkey          chain     icdcntd
700bAC     dkey          chain     invhstd
700aAC                   if        %found
700aAC                   eval      icdaqty1 = w1sqt1
700aAC                   eval      icdaqty2 = w1sqt2
700aAC                   eval      icdaqty3 = w1sqt3
700aAc                   eval      icdadj1 = icdaqty1 - icdbqty1
700aAc                   eval      icdadj2 = icdaqty2 - icdbqty2
700aAc                   eval      icdadj3 = icdaqty3 - icdbqty3
700aAc                   if        ivsedt > 0
700aAc                   eval      icdslcnt= 'Y'
700aAc                   eval      icdsltts= %timestamp
700aAc                   endif
700aAC                   update    icdrec
700aAc                   endif
     *
     *     Record found. Try updating record.
     *
     C                   update    record                               76
     C                   if        *in76
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in39 = *on
     C                   eval      *in40 = *on
     C                   eval      *in19 = *on
210 D*R                   UPDATDETAIL1
     C                   eval      errmsg = desc(1)
     C                   exsr      zm7871
     C                   exsr      sfldsp
     C                   leave
     C                   endif
411 A*
411 AC                   exsr      zzuexc
500aAC                   exsr      zzupos
     *
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     C                   eval      sctr = 0
     *
     *  Save fields to multiple occurance data structure
     *
     C                   if        reccnt > 0
     *   Loop through changed subfile records and update.
     *
     C                   eval      tqt1 = 0
     C                   eval      tqt2 = 0
     C                   eval      tqt3 = 0
     C                   eval      *in77 = *off
     C                   dou       *in77
     C                   add       1             sctr
     C     sctr          occur     msfile
     C                   readc     detail1                                77
     C                   if        not *in77
     C                   add       w1sqt1        tqt1
     C                   add       w1sqt2        tqt2
     C                   add       w1sqt3        tqt3
     C                   update    detail1
     C                   else
     C                   eval      sctr = sctr - 1
     C                   endif
     C                   enddo
     C                   endif
     *
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
     C     zzupd2        begsr
     *
     *  Update detail first.
     *
     C                   if        reccnt > 0
     C                   exsr      zzusub
     C     error         cabeq     *on           endup2
     C                   endif
     *
     *      Move key values to parameters
     *
     C                   eval      $pswhs = ivswhs
     C                   move      ivspag        $pspag
     C                   eval      $pswhd = ivswhd
     C                   eval      $psasl = ivsasl
     *
     C                   eval      error = *off
     C     ipkey         chain     invpage                            78
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        ivpedt = *zero
416b C                   if        entflg = *on
     C                   eval      ivpedt = $cvd8o
     C                   time                    ivpetm
     C                   eval      ivpeby = #user
416b C                   endif
     C                   else
     C                   eval      ivpcdt = $cvd8o
     C                   time                    ivpctm
     C                   eval      ivpcby = #user
     C                   endif
416b C                   if        entflg = *on
     C                   eval      ivpsta = 'E'
416b C                   endif
     C                   update    ivprec
     *
     C     endup2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update record.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
     C     endup3        endsr
     *
417a *----------------------------------------------------------------
417a *
417a *  ZZUPDP   Update INVPAGE with entered date & time
417a *
417a C     zzupdp        begsr
417a C                   eval      ivpsta = 'E'
417a C                   eval      $cvcmd = '*CURCMD '
417a C                   call      @cvtdt
417a C                   parm                    $cvtdt
417a C                   eval      ivpedt = $cvd8o
417a C                   time                    ivpetm
417a C                   eval      ivpeby = #user
417a C                   update    ivprec                               79
417a C                   if        *in79
417a C                   eval      error = *on
417a C                   exsr      zm7872
417a C                   goto      endupp
417a C                   endif
417a C     endupp        endsr
     *
417a *----------------------------------------------------------------
417a *
417a *  ZZUPPG   Update INVPAGE with new first or last record.
417a *
417a C     zzuppg        begsr
417a *
417a C                   eval      pgctr = 0
417a C                   eval      stop = *off
417a C     keypg         setll     invslot1
417a C                   dou       stop = *on
417a C     keypg         reade     invslot1                               77
417a C                   if        *in77
417a C                   eval      stop = *on
417a C                   else
417a C                   add       1             pgctr
417a C                   if        pgctr = 1
417a C                   eval      fmdsp = ivsdsp
417a C                   else
417a C                   eval      todsp = ivsdsp
417a C                   endif
417a C                   iter
417a C                   endif
417a C                   enddo
417a *R
417a C     keypg         chain     invpage                            75
417a C                   if        not *in75
417a C                   eval      ivpfrm = fmdsp
417a C                   eval      ivpto = todsp
417a C                   update    ivprec                               79
417a C                   eval      pgflg = *off
417a C                   endif
417a C                   endsr
417a *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Inventory slot
INVSLOT1
Normal Quantity
Breakdown Qty 1
Breakdown Qty 2
**  CMDLN - Command display line
F4=Prompt  F5=Refresh  F7=Enable item  F8=Enable Brk-qty
F4=Prompt  F5=Refresh  F7=Disable item  F8=Enable Brk-qty
F4=Prompt  F5=Refresh  F7=Enable item  F8=Disable Brk-qty
F4=Prompt  F5=Refresh  F7=Disable item  F8=Disable Brk-qty
F4=Prompt  F5=Refresh  F6=Add Virtual slot  F7=Enable item
F8=Enable Brk-qty  F9=License info  F10=Item/pg  F12=Cancel
F4=Prompt  F5=Refresh  F6=Add Virtual slot  F7=Disable item
F8=Enable Brk-qty  F9=License info  F10=Item/pg  F12=Cancel
F4=Prompt  F5=Refresh  F6=Add Virtual slot  F7=Enable item
F8=Disable Brk-qty  F9=License info  F10=Item/pg  F12=Cancel
F4=Prompt  F5=Refresh  F6=Add Virtual slot  F7=Disable item
F8=Disable Brk-qty  F9=Licnese info  F10=Item/pg  F12=Cancel
F9=Licnese info  F10=Item/pg  F12=Cancel
