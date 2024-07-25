      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *  For some clients, use CHGDSPF to set RSTDSP to *YES for the
     *  screen specs.  When running pgms OR910 or OR920 using iSeries
     *  Access, and the user selects an item with an error, OR200
     *  would blow up with an I/O error.
     *----------------------------------------------------------------
     H*COPYRIGHT('(c) Copyright BFC Software, Inc - 2002')
     H*Option(*NODEBUGIO)

500hA*----------------------------------------------------------------
500hA*  Multilingual Verision
500hA*  Every screen and message has a corresponding Spanish version.
500hA*  Any changes must be made to both languages.
500hA*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL 60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR200     RF single order select
     *  30 May 2002
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
640aA*  Compile instructions
     *
640aA*    CRTSQLRPGI OBJ(*) SRCFILE(*) TGTRLS(V5R3M0)
640aA*               COMMMIT(*NONE) DLYPRP(*YES)
     *----------------------------------------------------------------
640uA*  NOTE:
     *
640uA*    For EPM with SOS, set EPM options Voice Module=Y
640uA*    Tote/Box/Drop=Y to use LABELDO and PASSTRAN files
     *----------------------------------------------------------------
     *  Revisions
     *
416 A*    05/30/02  DAS  4.16
     *      - Created
416aA*    06/11/02  DAS  4.16a
     *      - Recompiled because of change to C#SLOT.
416bA*    07/18/02  DAS  4.16b
     *      - Revised to send the last item picked to list display ordered
     *        by line #.
     *      - Revised ZZLIST to get first pick slot with avail qty for item
     *      - Revised ZZCHK2 to use base slot for comparison.
416cA*    07/18/02  DAS  4.16c
     *      - Revised to create a new label record under certain conditions
416dA*    07/19/02  DAS  4.16d
     *      - Split pallet number and stage location screens.
     *      - Pallet now using screen 8.
     *      - Change F10=Finish to F8=Finish.
     *      - Revised to force entry of stage location.
416eA*    07/19/02  mlb  4.16e
     *      - Enh: Added support to program for 8x40 line screens.
     *             Revised ZZINZ2 to toggle screen selection.
416fA*    07/30/02  DAS  4.16f
     *      - Revised routine ZZUPD8 to not lock PLTSUM2 record.
416gA*    08/01/02  DAS  4.16g
     *      - Revised routine ZZFIL2 to init field WOITM2.
416hA*    08/08/02  MLB  4.16h
     *      - Converted program to SQL RPGLE.
     *      - Fix: Revised ZZLBL to use SQL to accumulate total qty
     *             picked.
416iA*    08/19/02  MLB  4.16i
     *      - Fix: Revised ZZLBL# to release lock on file LABEL.
416jA*    10/15/02  MLB  4.16j
     *      - Enh: Revised ZZCHK3 to validate quantity picked against
     *        available quantity in the slot.  Send warning msg and
     *        force user to press f key to accept qty exception.
416kA*    10/24/02  RH   4.16k
     *      - Enh: Changed to display item desc in 2 15 character fields
416lA*    11/14/02  MLB  4.16l
     *      - Enh: Added exception tracking when user overrides qty
     *        warning picking more than available qty in slot.
     *      - Add file ITMEXCP to program.
     *      - Add new routines: ZZCVDT, ZZEXCP.
     *      - Revised ZZCHK3 to call ZZEXCP to log exception.
416mA*    11/19/02  MLB  4.16m
     *      - Enh: Added exception tracking when user overrides qty
     *        warning picking more than available qty in slot.
     *
416nA*    06/11/03  DAS  4.16n
     *      - Recompiled because of change to C#ITEM.
     *      - Note, this program doesn't use the second data
     *        parameter, $item2, because the fields are not used.
     *
417 A*    01/19/04  MLB  4.17
     *      - Fix: Initialize slot fields when retrieving next pick slot
     *        with available quantity. Wasn't allowing first available
     *        slot to be selected.
500aA*    07/07/05  RH   5.00a
     *      - ENH: Change to allow picked product to be sent to a slot
     *        and held to be shipped later.  Pick qty will be removed
     *        from pick and stock bucket of original slot and added to
     *        pick and stock bucket of holding slot.  Label record
     *        will be updated with new holding slot.  Qty will be
     *        removed when pick is closed.
     *        Add WORKSOS to stage items selected.  Record is removed
     *        from file after item is staged.
500bA*    07/20/05  RH   5.00b
     *      - FIX: Change to position to order# for order # error.
500cA*    08/05/05  RH   5.00c
     *      - FIX: Use new cmds to allow use with directed put away.
500dA*    08/23/05  RH   5.00d
     *      - ENH: Add license to WORKSOS file. Allow each pallet
     *        license to be staged to seperate location. PSPAL# and
     *        WKSPLI contain the 7 digit PALLET LICENSE.
500eA*    10/31/05  RH   5.00e
     *      - Enh: Revised program to add support for Client ID
500fA*    11/15/05  RH   5.00f
     *      - Fix: Was updating stage slot for normal qty and brk qty.
     *      - Fix: Add code to clear data structure before call to DRI
500gA*    12/21/05  RH   5.00g
     *      - Fix: Pick qty must be greater than 0.  Was causing error
     *        for DRISLOT update when staging 0 qty.
     *
500hA*    06/06/06  JCJ  5.00b
     *      - Added Multilingual logic.
     *
640aA*    03/04/11  RBD  6.40a
     *      - Revised to synchronize the slot/license after a slot's
     *        stock qty changes by calling DRISLOT with %SYNCLCNS.
     *        This will only take place when they stage what they
     *        picked.
     *
640bA*    03/25/11  DAS  6.40b
     *      - Revised to user license tracking methods.
     *
640cA*    04/01/11  DAS  6.40c
     *      - Revised to use %tfr2usrn instead of %tfr2usr when
     *        working with a Pick slot. This will allow the slot to
     *        go negative.
     *      - Added error checking after call with %tfr2usr.
     *
640dA*    04/04/11  RH   6.40d
     *      - Enh: Revised to prevent overflow slot going negative
     *        will allow pick slot to go negative.
     *
640eA*    04/07/11  DAS  6.40e
     *      - Revised to get license of USR slot before %USR2PUT call.
     *      - Revised catchweights to work properly with licenses.
     *
640fA*    04/08/11  RH   6.40f
     *      - Enh: Do not allow to select overflow slot with 0 avail.
     *        Do not allow overflow slot to go negative on CW entry.
     *
640gA*    05/02/11  RBD  6.40g
     *      - Enh: Write a record to the LABELDO & EPMSUMO files when
     *        an item is picked, basically when the USR slot is
     *        created.
640hA*    05/05/11  RH   6.40h
     *      - Enh: Renamed screen format to OR20001 for web facing.
     *      - Enh: Add Screen10,scrn10sp, scrn60sp, screen60 for UPC
640iA*    05/06/11  RH   6.40i
     *      - Enh: Renamed screen format to OR20002 for web facing.
     *        Add Screen4A,scrn4Asp, scrn6Asp, screen6A for total wt.
640jA*    05/24/11  RH   6.40j
     *      - Enh: Renamed screen format to OR20003 for web facing.
     *        Remove F7=new pallet, program flow not for multiple
     *        pallets.
640kA*    05/17/11  RH   6.40k
     *      - Enh: Change to get first pick slot OR overflow slot.
640lA*    05/18/11  JCJ  6.40l
     *      - Enh: Renamed screen format to OR20004 for web facing.
     *        Add Screen70
640mA*    06/21/11  RBD  6.40m
     *      - Fix: Added unlock each time LABEL is accessed.
640nA*    06/23/11  DAS  6.40n
     *      - Enh: Revised to call OR204 to create ORDDSOS records.
640oA*    07/05/11  DAS  6.40o
     *      - Enh: Revised to catch DRISLOT error in ZZUPD6.
640pA*    07/06/11  DAS  6.40p
     *      - Fix: Reversed 640m changes.
     *      - Took qty check out of zzlbl# and put it into zzchkqty.
     *      - Revised zzlbl# to use a lock flag that is sent in.
     *      - Revised to not lock label record until just before update.
640qA*    07/06/11  DAS  6.40q
     *      - Revised zzchkqty to used order detail ordered qty
     *        instead of lbqalc.
640rA*    07/07/11  DAS  6.40r
     *      - Revised to initialize $llbl# before calling zzlbl#.
     *      - Revised zzchkqty to use LB fields instead of $L fields.
640sA*    08/04/11  RBD  6.40s
     *      - Revised to not allow user to pick qty from RCVDOCK slot,
     *        based on condition SLDESG = 'BFC'.
640tA*    08/11/11  RH   6.40t
     *      - Enh: add pgm parm to IT232 call to limit slots displayed
     *        on F4=slots, display active, non BFC, non SOSSG slots
640u *    08/12/11  GJA  6.40u
     *      - Enh: create PASSTRAN record when selector starts order.
640vA*    08/17/11  RH   6.40v
     *      - Fix: Clear W8LICA, was leaving previous license in field
640wA*    08/26/11  RBD  6.40w
     *      - Fix: Pgms OR910 and OR920 have been revised to set
     *        LABEL field lbvrfy to an 'I' (in use) when an item is
     *        selected and sent back to this pgm.  Pgms OR910 and
     *        OR920 have also been revised to not allow the user to
     *        select a label when lbvrfy = I, or in other words, is
     *        in use. All this to prevent multiple users from
     *        selecting the same line item simultaneously, risking it
     *        being overpicked. This pgm has been revised to change
     *        the lbvrfy field back to a blank once the selected item
     *        has either been canceled or staged ... then if it's
     *        still not been completely picked, the record is once
     *        again available to be picked.
640xA*    09/13/11  MLB  6.40x
     *      - Fix: Revised pgm to initialize fields $hdrportL and
     *        $hdrportC with zeros prior to call to VOSELECT. These
     *        fields were being left blank which was causing a data
     *        decimal error in VOSELECT when it tried to write to the
     *        BFCSKTLOG file.
640z *    09/27/11  RBD  6.40z
     *      - Fix: If user selects an item already picked, reset
     *        the label in use flag.
     *
650 A*    03/08/13  MLB  6.50
     *      - Fix: Revised pgm to check if value loaded into exqty > 999
     *        and if yes, then set exqty = 999. Error found at Get
     *        Fresh who stores watermelon in lbs in qty fields.
     *
650aA*    03/15/13  LMC  6.50a
     *      - Enh: Added CWLOG. This adds a call to a new program
     *        CW800 and new file CWLOG.
650b *    09/26/13  RH/MLB  6.50b
     *      - Fix: Add error check to prevent using license not
     *        in warehouse slot. Was allowing license assigned to
     *        USR slot at Eastland
700aA*    04/06/16  LMC  7.00a
     *      - Enh: Adding logic for Metric.
     *
720 A*    04/02/18  MLB  7.20
     *      - Enh: Revised routine ZZUPD4 to clear LBVRFY when updating
     *        label record. Updating catchwgts was leaving LBVRFY = I
     *        and not clearing Inuse flag after update was complete.
     *        Found at Chef's Warehouse.
750aA*    02/01/20  RH   7.50a
     *      - FIX: Change ZZCHK4 and ZZCHK4A to not allow qty picked  g
     *        greater than quantity ordered.                          g
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

640hDF*r200fm   cf   e             workstn
640iDF*r20001   cf   e             workstn
640jDF*r20002   cf   e             workstn
640lDF*r20003   cf   e             workstn
700aDF*or20004   cf   e             workstn
700aMFor20005   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(m16rec:msgk)
     Frtehed    uf a e           k disk    infds(file1ds)
416cDF*abel     uf   e           k disk
416cMFlabel     uf a e           k disk
     Fordc      uf a e           k disk
     Fordl      o  a e           k disk
     Fpltsum2   uf a e           k disk
416lAFitmexcp   o  a e           k disk
500aAFworksos   uf a e           k disk
500aAFworksos1  if   e           k disk
417g F                                     rename(wksrec:wksrec1)
500aAFslot2     if   e           k disk
640uAFpasstran  uf a e           k disk
640uAFoptione   if   e           k disk
640uAFlabel93   if   e           k disk
640uAF                                     rename(lbrec:lbrec93)
640uAFordh5     if   e           k disk

700aA*----------------------------------------------------------------
700aA*  Table and array definitions
700aA*----------------------------------------------------------------

700aAD cmdln           s             79    dim(12)ctdata perrcd(1)

500e *----------------------------------------------------------------
500e *  Client ID's for custom mods
500e *----------------------------------------------------------------
500eAD @getcl          c                   const('GETCLIENT')
500e  /copy *libl/qcopysrc,id#vigo
640hA*----------------------------------------------------------------
640hA*  Talkman record formats
640hA*----------------------------------------------------------------

640hA /Copy qcopysrc,r#header
640hA /Copy qcopysrc,rislvfyupc
640hA /Copy qcopysrc,roslvfyupc
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#ORDH
      /COPY *libl/qcopysrc,C#ORDD
640lA /COPY *libl/qcopysrc,C#LICENSE
650aA /COPY *libl/qcopysrc,C#CWLOG
     D savever#        s                   like($slver#)

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcount         s              3p 0
     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vwhse          s              3p 0

640uA*----------------------------------------------------------------
     *  *USER  -  User options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPMAN   -  Manually assign employee number (Y,N).
     *    OPNXTE  -  Next employee number.
     *    OPVYN   -  Processing selection by voice (Y,N).
     *    OPZORD  -  Collect selection data by zone or department?
     *    OPTBD   -  Tote/Box/Drop?  (Y,N)
     *
     * Data structure
     *
     D opedta          ds
     D  opman                  1      1
     D  opnxte                 2      6  0
     D  opvyn                  7      7
     D  opzord                 8      8
     D  optbd                  9      9
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

640bAD #fromithead     s             70
     D $msgf           s             10
416gAD $iitem          s                   like(lbitem)
416gAD $idesc          s                   like($itdesc)
416gAD $ipdsc          s                   like($itpdsc)
416gAD $istr           s             70
     D $pbat           s              7  0
640hAD $pdqlib         s             10
640hAD $pdqnameout     s             10
640hAD $pdqkey         s             36
640hAD $pcominfo       s             25
640hAD $pheader        s            512
640hAD $pfields        s           2048
640hAD $prtnfields     s           2048
     D $poid           s              7  0
640nAD $prtid          s              5
640gAD $pStampSys      s               z
640gAD $pStampUc       s               z
     D $ptrn#          s              7  0
     D $pwhse          s              3  0
640nAD $pwhseS         s              3s 0
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
416jAD availqty        s              9  0
640lAD chk4err         s              1
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D curdate         s              8  0
640bAD curlic#         s                   like($tlic#)
     D curtime         s              6  0
650aAD CWcmd           s             10
650aAD CWpgm           s             10
650aAD CWrtn           s             10
650aAD CWmsg           s             60
650aAD CWdata          s            512
650aAD processstatus   s             10
640gAD difpck          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D errcode         s             10
     D error           s               n
     D forevr          s               n   inz(*on)
     D help            s              5  0
     D i               s              5  0
416b D lastitem        s                   like(lbitem)
416b D lastseq         s                   like(lbord)
     D lasttime        s              6  0 inz(999999)
     D licpick         s               n
     D listorder       s              4
640pAD lock            s               n
     D msgk            s              4  0
640gAD noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')
     D nxtscr          s              3
640qAD ordered1        s              7  0
640qAD ordered2        s              7  0
640qAD ordered3        s              7  0
640eAD origLcns        s             15
     D ovrrid          s              1
640bAD partial         s               n
640uAD passact         s               n
     D picked          s              7  0
     D pickcount       s              5  0
640cAD pickSlot        s               n
     D redspl          s              1
     D refrsh          s              1
640gAD ref#            s             13  0
640gAD ref#Date        s              6  0
640gAD ref#Time        s              6  0
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D totalcube       s                   like(pscube)
     D totalpcs        s                   like(pspcs)
     D totalswgt       s                   like(psswgt)
     D warn            s              1
640iAD w4cwt           s                   like(#cwweight)
500a D svswhd          s                   like(wkswhd)
500d D pliccount       s              3  0
500d D stagcount       s              3  0
500d D kyplic          s              7  0
640lAD zmflag          s               n
640lAD zmsflag         s               n

700aAD KiloLbs         s              1
700aAD IMkilolbs       s              1
700aAD IMUom           s              3
700aAD wkwhse          s                   like(lbwhse)
640bA*----------------------------------------------------------------
640bA*  LT210 parameters
640bA*----------------------------------------------------------------

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
500jAD  $tnorm1        s              5  0
500jAD  $tnorm2        s              3  0
500jAD  $tnorm3        s              3  0
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
600fAD  wkType         s              3    INZ('TFR')

     *----------------------------------------------------------------
     *  Catchweight Multiple-Occurence Data Structure
     *----------------------------------------------------------------

     D #cwmax          s              5  0 inz(100)
     D #cwprev         s              5  0

     D #cwentries      ds                  occurs(100)
     D  #cwentry                     50
     D  #cwweight                     7  3 inz(0)

     *----------------------------------------------------------------
     *  Pallet id data structure
     *
     *    DSPLID  -  Pallet id.
     *    DSPLXX  -  Unused.
     *    DSPLGN  -  Generation.
     *    DSPLRW  -  Pallet row.
     *    DSPLCL  -  Pallet column.
     *    DSPLSQ  -  Sequence number.
     *               Equal to zero     - Only one pallet in this position.
     *               Greater than zero - Multiple pallets in this position.
     *
     *----------------------------------------------------------------

     D pltid           ds
     D  dsplid                 1      7  0 inz(0)
     D  dsplxx                 1      2  0
     D  dsplgn                 3      3  0
     D  dsplrw                 4      5  0
     D  dsplcl                 6      6  0
     D  dsplsq                 7      7  0

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   const('CVTDTE')

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
     *  Called program parameters
     *----------------------------------------------------------------

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
     D  $lord                 22     28  0
     D  $lseq                 29     33  0
     D  $litem                34     48
     D  $lrtid                49     53
     D  $lpbat                54     60  0
     D  $llbl#                61     67  0
     *
416aAD  $lwhs2                19     21  0
416aAD  $litm2                22     36
416aAD  $lwhd2                37     41
416aAD  $ldsp2                42     53

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
650aA*----------------------------------------------------------------
650aA*  Prototypes
650aA*----------------------------------------------------------------
650aA /copy qcopysrc,p.cw800
700aA /copy qcopysrc,p.getimuom

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

640lA /Copy qcopysrc,c#pgminfds
640lDD*               sds
640lDD* #prog            *proc
640lDD* #job                 244    253
640lDD* #user                254    263
640lDD* #jobn                264    269
640lDD* #jobdt               276    281  0
640lDD* #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50

     D  err01          c                   'Order not found'

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')
500hAD #msgsp          c                   const('PIRMSGFSP ')

     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

640qA*----------------------------------------------------------------
640qA*  Standard SQL variables and constants
640qA*----------------------------------------------------------------
640qA
640qA /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  File info data structures
     *----------------------------------------------------------------

     D File1DS         ds
     D  f1filename             1      8
     D  f1openind              9      9
     D  f1endoffile           10     10
     D  f1status              11     15  0
     D  f1opercode            16     21
     D  f1routine             22     29
     D  f1stmtnbr             30     37
     D  f1recordcd            38     45
     D  f1messageid           46     52
     D  f1sourceid            53     54

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
 1B  C                   if        error = *on
     C                   move      'EOJ'         nxtscr
 1E  C                   endif
     *
 1B  C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
 2B  C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
     C     nxtscr        caseq     '04 '         sc4
     C     nxtscr        caseq     '05 '         sc5
     C     nxtscr        caseq     '06 '         sc6
     C     nxtscr        caseq     '07 '         sc7
     C     nxtscr        caseq     '08 '         sc8
640hAC     nxtscr        caseq     '10 '         sc10
640iAC     nxtscr        caseq     '11 '         sc4a
 2E  C                   endcs
 1E  C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
   x C                   write     clrscr
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
 2B  C                   select
500hAC                   when      #lline = '16' and e$lng = 'SP'
500haC                   exfmt     scrn61sp                             50
500hAC                   when      #lline = '16' and e$lng = 'EN'
     C                   exfmt     screen61                             50
500hD**                  other
500hAC                   when      #lline <> '16' and e$lng = 'SP'
500hAC                   exfmt     scrn1sp                              50
500hAC                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen1                              50
 2E  C                   endsl
 1E  C                   endif
 1B  C                   if        nxtscr = '02 '
 2B  C                   select
500hAC                   when      #lline = '16' and e$lng = 'SP'
500haC                   exfmt     scrn62sp                             50
500hAC                   when      #lline = '16' and e$lng = 'EN'
     C                   exfmt     screen62                             50
500hD**                  other
500hAC                   when      #lline <> '16' and e$lng = 'SP'
500hAC                   exfmt     scrn2sp                              50
500hAC                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen2                              50
 2E  C                   endsl
 1E  C                   endif
 1B  C                   if        nxtscr = '03 '
 2B  C                   select
500hAC                   when      #lline = '16' and e$lng = 'SP'
500haC                   exfmt     scrn63sp                             50
500hAC                   when      #lline = '16' and e$lng = 'EN'
     C                   exfmt     screen63                             50
500hD**                  other
500hAC                   when      #lline <> '16' and e$lng = 'SP'
500hAC                   exfmt     scrn3sp                              50
500hAC                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen3                              50
 2E  C                   endsl
 1E  C                   endif
 1B  C                   if        nxtscr = '04 '
 2B  C                   select
500hAC                   when      #lline = '16' and e$lng = 'SP'
500haC                   exfmt     scrn64sp                             50
500hAC                   when      #lline = '16' and e$lng = 'EN'
     C                   exfmt     screen64                             50
500hD**                  other
500hAC                   when      #lline <> '16' and e$lng = 'SP'
500hAC                   exfmt     scrn4sp                              50
500hAC                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen4                              50
 2E  C                   endsl
 1E  C                   endif
 1B  C                   if        nxtscr = '05 '
 2B  C                   select
500hAC                   when      #lline = '16' and e$lng = 'SP'
500haC                   exfmt     scrn65sp                             50
500hAC                   when      #lline = '16' and e$lng = 'EN'
     C                   exfmt     screen65                             50
500hD**                  other
500hAC                   when      #lline <> '16' and e$lng = 'SP'
500haC                   exfmt     scrn5sp                              50
500hAC                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen5                              50
 2E  C                   endsl
 1E  C                   endif
 1B  C                   if        nxtscr = '06 '
 2B  C                   select
500hAC                   when      #lline = '16' and e$lng = 'SP'
500haC                   exfmt     scrn66sp                             50
500hAC                   when      #lline = '16' and e$lng = 'EN'
     C                   exfmt     screen66                             50
500hD**                  other
500hAC                   when      #lline <> '16' and e$lng = 'SP'
500haC                   exfmt     scrn6sp                              50
500hAC                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen6                              50
 2E  C                   endsl
 1E  C                   endif
 1B  C                   if        nxtscr = '07 '
500hAC                   select
500hAC                   when      e$lng = 'SP'
500hAC                   exfmt     scrn7SP                              50
500hAC                   when      e$lng = 'EN'
     C                   exfmt     screen7                              50
500hAC                   endsl
 1E  C                   endif
 1B  C                   if        nxtscr = '08 '
 2B  C                   select
500hAC                   when      #lline = '16' and e$lng = 'SP'
500haC                   exfmt     scrn68sp                             50
500hAC                   when      #lline = '16' and e$lng = 'EN'
     C                   exfmt     screen68                             50
500hD**                  other
500hAC                   when      #lline <> '16' and e$lng = 'SP'
500haC                   exfmt     scrn8sp                              50
500hAC                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen8                              50
 2E  C                   endsl
 1E  C                   endif
640hAC                   if        nxtscr = '10 '
 2B AC                   select
640hAC                   when      #lline = '16' and e$lng = 'SP'
640hAC                   exfmt     scrn60sp                             50
640hAC                   when      #lline = '16' and e$lng = 'EN'
640hAC                   exfmt     screen60                             50
640hAC                   when      #lline <> '16' and e$lng = 'SP'
640hAC                   exfmt     scrn10sp                             50
640hAC                   when      #lline <> '16' and e$lng = 'EN'
640hAC                   exfmt     screen10                             50
 2E AC                   endsl
640hAC                   endif
640iAC                   if        nxtscr = '11 '
 2B AC                   select
640iAC                   when      #lline = '16' and e$lng = 'SP'
640iAC                   exfmt     scrn6Asp                             50
640iAC                   when      #lline = '16' and e$lng = 'EN'
640iAC                   exfmt     screen6A                             50
640iAC                   when      #lline <> '16' and e$lng = 'SP'
640iAC                   exfmt     scrn4Asp                             50
640iAC                   when      #lline <> '16' and e$lng = 'EN'
640iAC                   exfmt     screen4A                             50
 2E AC                   endsl
640iAC                   endif
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
     C                   setoff                                       9298
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
     C                   move      '01 '         nxtscr
 1B  C                   if        refrsh = *on
     C                   exsr      zzfil1
 1E  C                   endif
     C                   eval      refrsh = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   move      '02 '         nxtscr
500a C                   eval      *in01 = *on
 1B  C                   if        refrsh = *on
     C                   exsr      zzfil2
 1E  C                   endif
     C                   eval      refrsh = *off
700aA*
700aA*   Want to set back to system defaults on each item
700aA*   Get Item Maintenance options.
700aA*
700aA /free
700aA    wkwhse = e$whse;
700aA    getimuom(wkwhse: IMkilolbs: IMUom);
700aA    select;
700aA      when IMkilolbs = 'K';
700aA        KiloLbs = 'K';
700aA        W4kgLb  = IMUom;
700aA      other;
700aA        kiloLbs = 'P';
700aA        W4KgLb  = 'Lbs';
700aA    endsl;
700aA /end-free
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   move      '03 '         nxtscr
 1B  C                   if        refrsh = *on
     C                   exsr      zzfil3
 1E  C                   endif
     C                   eval      refrsh = *off
     C                   eval      ovrrid = *off
     C     end03i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 04 initialization
     *
     C     scr04i        begsr
     C                   move      '04 '         nxtscr
 1B  C                   if        refrsh = *on
     C                   exsr      zzfil4
 1E  C                   endif
     C                   eval      refrsh = *off
700aAc                   exsr      zzsetcmdln1
     C     end04i        endsr
640iA*----------------------------------------------------------------
640iA*
640iA*  Screen 4A initialization
640iA*
640iAC     scr4Ai        begsr
640iAC                   move      '11 '         nxtscr
640iAC                   if        refrsh = *on
640iAC                   exsr      zzfil4A
640iAC                   endif
640iAC                   eval      refrsh = *off
700aAc                   exsr      zzsetcmdln1a
640iAC     end4Ai        endsr
     *----------------------------------------------------------------
     *
     *  Screen 05 initialization
     *
     C     scr05i        begsr
     C                   move      '05 '         nxtscr
 1B  C                   if        refrsh = *on
     C                   exsr      zzfil5
 1E  C                   endif
     C                   move      *off          refrsh
     C     end05i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 06 initialization
     *
     C     scr06i        begsr
     C                   move      '06 '         nxtscr
 1B  C                   if        refrsh = *on
     C                   exsr      zzfil6
 1E  C                   endif
     C                   move      *off          refrsh
     C     end06i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 07 initialization
     *
     C     scr07i        begsr
     C                   move      '07 '         nxtscr
 1B  C                   if        refrsh = *on
 1E  C                   endif
     C                   exsr      zzfil7
     C                   move      *off          refrsh
     C     end07i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 08 initialization
     *
     C     scr08i        begsr
     C                   move      '08 '         nxtscr
 1B  C                   if        refrsh = *on
     C                   exsr      zzfil8
 1E  C                   endif
     C                   move      *off          refrsh
     C     end08i        endsr
640hA*----------------------------------------------------------------
640hA*
640hA*  Screen 10 initialization
640hA*
640hAC     scr10i        begsr
640hAC                   move      '10 '         nxtscr
640hAC                   if        refrsh = *on
640hAC                   exsr      zzfil10
640hAC                   endif
640hAC                   eval      refrsh = *off
640hAC     end10i        endsr
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
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr01i
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      'EOJ'         nxtscr
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
640wAC                   eval      lock = *on
640wAC                   exsr      zzlbl#
640wAC                   eval      lbvrfy = ' '
640wAC                   update    lbrec
 1B  C                   unlock    label
     C                   exsr      zzlist
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr02i
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
640wAC                   eval      lock = *on
640wAC                   exsr      zzlbl#
640wAC                   eval      lbvrfy = ' '
640wAC                   update    lbrec
 1B  C                   unlock    label
     C                   exsr      zzlist
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C     redspl        cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C                   move      *off          refrsh
     C                   exsr      scr02i
goto Csr                 goto      endsc3
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr03i
goto Csr                 goto      endsc3
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      *off          refrsh
     C                   exsr      scr02i
goto Csr                 goto      endsc3
 1E  C                   endif
     *
     *  Test for other command keys
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     *
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     C     endsc3        endsr
     *----------------------------------------------------------------
     *
     *  SC4  -  Screen 4
     *
     C     sc4           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C                   move      *off          refrsh
     C                   exsr      scr02i
goto Csr                 goto      endsc4
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr04i
goto Csr                 goto      endsc4
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      *off          refrsh
     C                   exsr      scr02i
goto Csr                 goto      endsc4
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk4
     C     error         cabeq     *on           endsc4
     C                   exsr      zzupd4
     C     error         cabeq     *on           endsc4
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     C     endsc4        endsr
640i *----------------------------------------------------------------
640iA
640i *  SC4A -  Screen 4A
640i *
640i C     sc4A          begsr
640iA*
640iA*  Test for F3 - Exit
640iA*
640iAC                   if        *inkc
640iAC                   move      *off          refrsh
640iAC                   exsr      scr04i
goto Csr                 goto      endsc4a
 1E  C                   endif
640iA*
640iA*  Test for F5 - Refresh
640iA*
640iAC                   if        *inke
640iAC                   move      *on           refrsh
640iAC                   exsr      scr4ai
gotoACsr                 goto      endsc4a
640iAC                   endif
640iA*
640iA*  Test for F12 - Previous
640iA*
640iAC                   if        *inkl
640iAC                   move      *off          refrsh
640iAC                   exsr      scr04i
gotoACsr                 goto      endsc4a
640iAC                   endif
640iA*
640iA*  Test for other command keys BEFORE verification and update.
640iA*
640iAC                   move      '*BEFORE '    cmdchk
640iAC                   exsr      zzcmd4a
640iAC     cmdtkn        cabeq     *on           endsc4a
640iA*
640iA*  Some other key pressed.
640iA*
640iA*     Check input and write/update record.
640iA*
640iAC                   exsr      zzchk4a
640iAC     error         cabeq     *on           endsc4a
640iAC                   exsr      zzupd4a
640iAC     error         cabeq     *on           endsc4a
640iA*
640iA*  Test for other command keys AFTER verification and update.
640iA*
640iAC                   move      '*AFTER  '    cmdchk
640iAC                   exsr      zzcmd4a
640iAC     cmdtkn        cabeq     *on           endsc4a
640iA*
640iAC     endsc4a       endsr
     *----------------------------------------------------------------
     *
     *  SC5  -  Screen 5
     *
     C     sc5           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C****               move      'EOJ'         nxtscr
goto Csr                 goto      endsc5
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr05i
goto Csr                 goto      endsc5
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C****               exsr      scr02i
goto Csr                 goto      endsc5
 1E  C                   endif
     *
     *  Test for other command keys
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk5
     C     error         cabeq     *on           endsc5
     C                   exsr      zzupd5
     C     error         cabeq     *on           endsc5
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
     C     endsc5        endsr
     *----------------------------------------------------------------
     *
     *  SC6  -  Screen 6
     *
     C     sc6           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C                   move      *off          refrsh
     C                   exsr      scr05i
goto Csr                 goto      endsc6
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr06i
goto Csr                 goto      endsc6
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      *off          refrsh
     C                   exsr      scr05i
goto Csr                 goto      endsc6
 1E  C                   endif
     *
     *  Test for other command keys
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd6
     C     cmdtkn        cabeq     *on           endsc6
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk6
     C     error         cabeq     *on           endsc6
     C                   exsr      zzupd6
     C     error         cabeq     *on           endsc6
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd6
     C     cmdtkn        cabeq     *on           endsc6
     *
     C     endsc6        endsr
     *----------------------------------------------------------------
     *
     *  SC7  -  Screen 7
     *
     C     sc7           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C                   move      'EOJ'         nxtscr
goto Csr                 goto      endsc7
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr07i
goto Csr                 goto      endsc7
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
     *
     *R         *INKL     IFEQ *ON
     *R                   MOVE *OFF      REFRSH
     *R                   EXSR SCR03I
     *R                   GOTO ENDSC7
     *R                   ENDIF
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd7
     C     cmdtkn        cabeq     *on           endsc7
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk7
     C     error         cabeq     *on           endsc7
     C                   exsr      zzupd7
     C     error         cabeq     *on           endsc7
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd7
     C     cmdtkn        cabeq     *on           endsc7
     *
     C     endsc7        endsr
     *----------------------------------------------------------------
     *
     *  SC8  -  Screen 8
     *
     C     sc8           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
416dDC**                 move      'EOJ'         nxtscr
416eDC**                 exsr      scr05i
416eAC                   eval      refrsh = *on
416eMC                   exsr      scr01i
goto Csr                 goto      endsc8
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr08i
goto Csr                 goto      endsc8
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      *off          refrsh
416dDC**                 exsr      scr03i
416eDC**                 exsr      scr05i
416eAC                   eval      refrsh = *on
416eMC                   exsr      scr01i
goto Csr                 goto      endsc8
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd8
     C     cmdtkn        cabeq     *on           endsc8
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk8
     C     error         cabeq     *on           endsc8
     C                   exsr      zzupd8
     C     error         cabeq     *on           endsc8
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd8
     C     cmdtkn        cabeq     *on           endsc8
     *
     C     endsc8        endsr
640h *----------------------------------------------------------------
640h *
640h *  SC10 -  Screen 10
640h *
640h C     sc10          begsr
640h *
640h *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C                   move      *off          refrsh
     C**                 exsr      scr02i
     Csr                 goto      endsc10
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr10i
     Csr                 goto      endsc10
 1E  C                   endif
     *
     *  Test for F9 - Skip
     *
 1B  C                   if        *inki
     C                   move      *on           cmdtkn
     C                   move      'SKPUPC '     exerid
     C                   exsr      zzexcp
     *  Now either get the quantity picked or the catchweights.

     C                   eval      refrsh = *on
 2B  C                   if        $itcwgt = 'Y'
     C                   eval      woqty = lbqalc
     C                   eval      wopck = picked
     C                   eval      woum  = lbucod
     C                   eval      w4cnt  = 1
     C                   eval      w4qty = lbqalc - lbqpck
     C                   exsr      scr04i
     C                   else
     C                   exsr      scr03i
 2E  C                   endif
     Csr                 goto      endsc10
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      *off          refrsh
     C                   exsr      scr02i
     Csr                 goto      endsc10
 1E  C                   endif
     *
     *  Test for other command keys
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd10
     C     cmdtkn        cabeq     *on           endsc10
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     *
     C                   exsr      zzchk10
     C     error         cabeq     *on           endsc10
     C                   exsr      zzupd10
     C     error         cabeq     *on           endsc10
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd10
     C     cmdtkn        cabeq     *on           endsc10
     *
640hAC     endsc10       endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
500e *
500e *  Get client ID
500e *
500e C                   call      @getcl
500e C                   parm                    client           10
     *
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   z-add     01122         rollup
     C                   z-add     01123         rolldn
     C                   z-add     01124         clear
     C                   z-add     01125         help
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
650aA*----------------------------------------------------------------
650aA*  clrCWLog     Clear $cwlog   data structure fields
650aA*----------------------------------------------------------------

650aA /free
650aA   begsr ClrCWLog;

650aA     savever# = $cwver#;
650aA     clear $cwlog;
650aA     $cwver# = savever#;
650aA     $cwaddemp = e$emp#;
650aA     $cwaddusr = #user;
650aA     $cwaddpgm  = #prog;
650aA     $cwaddjob  = #job;
650aA     $cwaddnbr = #jobn;

650aA   endsr;
650aA /end-free

650aA*----------------------------------------------------------------
650aA*  ProcessCWLog  Process the CWLOG file Add/Update/Delete
650aA*----------------------------------------------------------------

650aA /free
650aA   begsr processCWlog;
650aA     exsr clrCWLog;
650aA     $cwwhse = ocwhse;
650aA     $cwitem = ocitem;
650aA     $cwseltrn# = octran;
650aA     $cwsellbl# = oclbl#;
650aA     $cwselord  = ocord;
650aA     $cwselseq  = ocseq#;
650aA     $cwselcseq = ocseq;
650aA     $cwwgtlbs = occwgt;
650aA     $cwscan = #cwentry;
650aA     $cwentflg = 3;

650aA     cwdata = $cwlog;
650aA     cw800(processstatus: cwpgm: cwrtn: cwmsg: cwdata);

650aA     $cwlog = cwdata;

650aA   endsr;
650aA /end-free
     *---------------------------------------------------------------
640gA
640gA*  WRTLABELDO  Write label detail and EPMSUMO record for item
640gA*  picked, basically when the USR slot is created.
640gA
640gAC     wrtLABELDO    begsr

     C                   eval      $Cvcmd = '*CURYMD '
     C                   call      @Cvtdt
     C                   parm                    $Cvtdt
     C                   eval      ref#Date = $Cvd6o
     C                   time                    ref#Time
     C                   eval      ref# = ref#Date * 1000000 + ref#Time

     C                   call(e)   'WRTLABELDO'
     C                   parm      '*WRITE'      $pCmd             8
     C                   parm      noStamp       $pStampSys
     C                   parm      noStamp       $pStampUc
     C                   parm      lbwhse        $pWhse            3 0
     C                   parm      *blanks       $pAct             6
     C                   parm      lblbl#        $pLbl#            7 0
     C                   parm      lbitem        $pItem           15
     C                   parm      lbtrn#        $pTrn#            7 0
     C                   parm      0             $pTrn2#           9 0
     C                   parm      lbqpck        $pQty             5 0
     C                   parm      difpck        $pQtyS            5 0
     C                   parm      #prog         $pPgm            10
     C                   parm      'SELECT'      $pPtyp            6
     C                   parm      *blanks       $pIp             15
     C                   parm      *blanks       $pUid            10
     C                   parm      e$code        $pUser           10
     C                   parm      e$emp#        $pEmp#            5 0
     C                   parm      ref#          $pRef#           13 0
     C                   parm      lbtype        $pLtype           1
     C                   parm      psszon        $pZone            5
     C                   parm      e$shft        $pShift           6
     C                   parm      e$crew        $pCrew            6

640uAC                   If        optbd = 'Y'
640uAC                   eval      $cvcmd = '*CURCMD '
640uAC                   call      @cvtdt
640uAC                   parm                    $cvtdt
640uAC                   time                    ref#Time
640uAC     pskey         setll     passtran
640uAC                   dow       forevr = forevr
640uAC     pskey         reade     passtran                               78
640uAC                   select
640uAC                   when      not *in78 and pasetyp='C'
640uAC                   eval      pasedte = $cvd8o
640uAC                   eval      pasetim = ref#time
640uAC                   eval      paspcs  = +$pQty
640uAC                   update    pasrec
640uAC                   leave
640uAC                   when      *in78
640uAC                   leave
640uAC                   endsl
640uAC                   enddo
640uAC                   endif
     C                   endsr

     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
 1B  C                   select
 1X  C                   when      #lline = '16'
     C                   write     m16ctl
 1X  C                   other
     C                   write     msgctl
 1E  C                   endsl
     C                   eval      msgk = *zeros
 1B  C                   select
 1X  C                   when      #lline = '16'
     C                   write     m16clr
 1X  C                   other
     C                   write     msgclr
 1E  C                   endsl
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
 2B  C                   select
 2X  C                   when      #lline = '16'
     C                   write     m16ctl
 2X  C                   other
     C                   write     msgctl
 2E  C                   endsl
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
500hAC                   select
500hAC                   when      e$lng = 'SP'
500hAC                   eval      $msgf = #msgsp
500hAC                   other
     C                   eval      $msgf = #msgf
500hAC                   endsl
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
 2B  C                   select
 2X  C                   when      #lline = '16'
     C                   write     m16rec
 2X  C                   other
     C                   write     msgrec
 2E  C                   endsl
 1E  C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
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
 1B  C                   select
 1X  C                   when      #lline = '16'
     C                   write     m16rec
 1X  C                   other
     C                   write     msgrec
 1E  C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *    DRI0001/2  Error returned from DRICOP.
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
640lA*----------------------------------------------------------------
640lA*    LP11022  License not on file.
640lA*
640lAC     zm022         begsr
640lAC                   eval      #msgid = 'LP11022'
640lAC                   eval      #msgtp = '*DIAG  '
640lAC                   eval      $md = *blanks
640lAC                   exsr      zmpmsg
640lAC                   endsr

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
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     zzchk1        begsr
     C                   eval      error = *off

     *  Verify warehouse.

     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      w1whse        $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'VFYWHSE'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   exsr      zm0105
     C                   goto      endck1

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      errmsg = $vmessage
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   exsr      zm0105
     C                   goto      endck1

     C                   endsl

     *  Retreive order

     C                   eval      woinf1 = '  Retrieving Order'
     C                   eval      woinf2 = '     from Host'
     C                   write     screen61
     C                   eval      woinf1 = ' '
     C                   eval      woinf2 = ' '

     C                   eval      savever# = $ohver#
     C                   clear                   $ordh
     C                   eval      $ohver# = savever#

     C                   eval      $ohwhseu = *on
     C                   eval      $ohwhse = w1whse

     C                   eval      $ohcordu = *on
     C                   eval      $ohcord = w1ord

     C                   eval      $dricommand = '*ORD'
     C                   eval      $drisubcmd  = '%RTVCORD'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
500bDC*                  eval      *in21 = *on
500bDC*                  eval      *in01 = *on
500bMC                   eval      *in22 = *on
500bMC                   eval      *in02 = *on
     C                   eval      errmsg = err01
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif

     *  Now get order header information.

     C                   eval      savever# = $ohver#
     C                   clear                   $ordh
     C                   eval      $ohver# = savever#

     C                   eval      $ohwhseu = *on
     C                   eval      $ohwhse = w1whse

     C                   eval      $ohcordu = *on
     C                   eval      $ohcord = w1ord

     C                   eval      $dricommand = '*ORD'
     C                   eval      $drisubcmd  = '%GETHDRWCO'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   goto      endck1
     C                   endif

     C     endck1        endsr

     *----------------------------------------------------------------
     *  ZZCHK2   Screen 2 error checking.
     *----------------------------------------------------------------

     C     zzchk2        begsr
     C                   eval      error = *off

     *  Call API for slot.

     C                   call      'APICVTSLT'
     C                   parm                    w2slot
     C                   parm      11            worow
     C                   parm      7             wocol
     C                   parm                    @artn             8
 1B  C                   if        @artn = '*REDSPLY'
     C                   move      *on           redspl
goto Csr                 goto      endck2
 1E  C                   endif

     *  Verify display.(SCAN slot)

416bA*  Note: %GET/%NXTPICKAV return the base slot in $sacdsp. If slot
416bA*        is not virtual, actual slot is returned.

416bDC**                 if        w2slot <> lbdisp
416bMC                   if        w2slot <> $sldisp and
416bMC                             w2slot <> $sacdsp
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg    = 'Wrong slot scanned '
     C                                       + '('
     C                                       + %trim(w2slot)
     C                                       + ')'
     C                   exsr      zm0105
 1E  C                   endif
640fA
640fA*     Overflow slot can not go negative.
640fA*     Error if pick quantity is > available for overflow slot.
640fAC                   if        $slpick = 'N' and
640fAC                             $slavl1 <= 0 and
640fAC                             $slavl2 <= 0 and
640fAC                             $slavl3 <= 0
640fAC                   eval      error = *on
640fAC                   eval      *in21 = *on
640fAC                   eval      *in01 = *on
640fAC                   eval      errmsg = 'No available Qty'
640fAC                   exsr      zm0105
640fAC                   goto      endck2
640fAC                   endif
640sA
640sA*     Do not allow user to pick qty from RCVDOCK slot,
640sA*     based on condition SLDESG = 'BFC'.
640sAC                   if        $sldesg = 'BFC'
640sAC                   eval      error = *on
640sAC                   eval      *in21 = *on
640sAC                   eval      *in01 = *on
640sAC                   eval      errmsg = 'Cannot pick from '
640sAC                                       + 'RCVDOCK slot'
640sAC                   exsr      zm0105
640sAC                   goto      endck2
640sAC                   endif

     *  Verify license entered

 1B  C                   if        licpick and w2lic = ' '
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg    = 'License not entered'
     C                   exsr      zm0105
 1E  C                   endif

     C     endck2        endsr

     *----------------------------------------------------------------
     *  ZZCHK3   Screen 3 error checking.
     *----------------------------------------------------------------

     C     zzchk3        begsr
     C                   move      *off          error

 500g*  Quantity entered cannot be 0

 500gC                   if        w3qty <=0
 500gC                   move      *on           error
 500gC                   eval      *in21 = *on
 500gC                   eval      *in01 = *on
 500gC                   eval      errmsg = 'Enter Qty    '
 500gC                   exsr      zm0105
 500gC                   goto      endck3
 500gC                   endif
     *  Quantity entered cannot be greater than quantity remaining.

 1B  C                   if        w3qty > (lbqalc - lbqpck)
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = 'Qty too large'
     C                   exsr      zm0105
     C                   goto      endck3
 1E  C                   endif
416jA
416jA*  Quantity entered should not be greater than available slot qty.
416jA
640fA*  Code to calculate available quantity moved to ZZQAVL          .
640fAC                   exsr      zzqavl
640bAC*                  exsr      clr$slot
640bDC**                 eval      savever# = $slver#
640bDC**                 clear                   $slot
640bDC**                 eval      $slver# = savever#
416jA *
416jAC*                  eval      $dricommand = '*SLOT'
416jAC*                  eval      $drisubcmd  = '%GET'
416jA *
416jAC*                  eval      $slwhseu = *on
416jAC*                  eval      $slwhse = lbwhse
416jAC*                  eval      $slwhdpu = *on
416jAC*                  eval      $slwhdp = lbwhdp
416jAC*                  eval      $sldispu = *on
416jAC*                  eval      $sldisp = wodisp
416jAC*                  exsr      zzzdricop
416jA*
416jAC*                  eval      availqty = $slavl1
416jA*
416jA*    Convert case qty to breakdown qty 1 level.
416jAC*                  select
416jAC*                  when      $itflg1  = 'Y' and $itumq2 > 0 and
416jAC*                            lbutyp = '1'
416jAC*                  eval      availqty = (availqty * $itumq2) +
416jAC*                            $slavl2
416jA *
416jA*
416jA*    Convert break down qty 2 to breakdown qty 3.
416jAC*                  when      $itflg2  = 'Y' and $itumq3 > 0 and
416jAC*                            lbutyp = '2'
416jAC*                  eval      availqty = (((availqty * $itumq2) +
416jAC*                            $slavl2) * $itumq3) + $slavl3
416jaC*                  endsl
640dA
640dA*     Overflow slot can not go negative.
640dA*     Error if pick quantity is > available for overflow slot.
640dAC                   if        w3qty > availqty and
640dAC                             $slpick = 'N'
640dAC                   eval      error = *on
640dAC                   eval      *in21 = *on
640dAC                   eval      *in01 = *on
640dAC                   eval      errmsg = 'Qty > available'
640dAC                   exsr      zm0105
640dAC                   goto      endck3
640dAC                   endif
640bA
640bA*     Set partial flag
640bA
640bAC                   if        w3qty < availqty
640bAC                   eval      partial = *on
640bAC                   else
640bAC                   eval      partial = *off
640bAC                   endif
640bA
416jA*     Pick qty greater than available slot qty.
416jAC                   select
416jAC                   when      w3qty > availqty
416jAC                   eval      errcode = 'PCKGTAVAIL'
416jAC                   exsr      zzdsperr
416jA*
416jAC                   select
416jA*        F10=Accept was selected. Allow user to continue.
416jAC                   when      *inkj = *on
416lA*          Log exception error for user, then procesd.
416lAC                   eval      exerid = 'PCKGTAV'
650 A*
650 AC                   if        w3qty > 999
650 AC                   eval      exqty = 999
650 AC                   else
650 A*
416lAC                   z-add     w3qty         exqty
650 AC                   endif
650 A*
416lAC                   exsr      zzexcp
416jA*
416jA*        F10=Accept was NOT selected. Do NOT allow user to continue.
416jAC                   other
416jAC                   eval      error = *on
416jAC                   eval      *in21 = *on
416jAC                   eval      *in01 = *on
640dAC                   eval      errmsg = 'Qty > available'
640dAC                   exsr      zm0105
416jAC                   goto      endck3
416jAC                   endsl
416jAC                   endsl
416jA
     C     endck3        endsr

     *----------------------------------------------------------------
     *  ZZCHK4   Screen 4 error checking.
     *----------------------------------------------------------------

     C     zzchk4        begsr
     C                   eval      error = *off

     *  Catchweight cannot be blank

 1B  C                   if        w4cw = ' '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg    = 'Catchweight cannot be blank'
     C                   exsr      zm0105
     C                   goto      endck4
 1E  C                   endif
640f *   Get avail qty.
640f C                   exsr      zzqavl
640f
640fA*     Overflow slot can not go negative.
640fA*     Error if pick quantity is > available for overflow slot.
640fAC                   if        $slpick = 'N' and
640fAC                             w4cnt > availqty
640fAC                   eval      error = *on
640fAC                   eval      *in21 = *on
640fAC                   eval      *in01 = *on
640fAC                   eval      errmsg = 'Qty > available'
640fAC                   exsr      zm0105
640fAC                   goto      endck4
640fAC                   endif
750aA*
750aA*     Error if pick quantity is >= quantity needed.
750aAC                   if        w4cnt >= w4qty
750aAC                   eval      error = *on
750aAC                   eval      *in21 = *on
750aAC                   eval      *in01 = *on
750aAC                   eval      errmsg = 'Total qty picked'
750aAC                   exsr      zm0105
750aAC                   goto      endck4
750aAC                   endif
640sA
640sA*     Do not allow user to pick qty from RCVDOCK slot,
640sA*     based on condition SLDESG = 'BFC'.
640sAC                   if        $sldesg = 'BFC'
640sAC                   eval      error = *on
640sAC                   eval      *in21 = *on
640sAC                   eval      *in01 = *on
640sAC                   eval      errmsg = 'Cannot pick from '
640sAC                                       + 'RCVDOCK slot'
640sAC                   exsr      zm0105
640sAC                   goto      endck4
640sAC                   endif

     *  Convert catchweight entry to a number.

     C                   call      'CVTBAR'
     C                   parm      '*CWGTLBS'    $cbcmd            8
     C                   parm      w4cw          $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
700aAC                   parm      0             $cbven           10 0
700aAC                   parm                    $cvtdata        256
700aAC                   parm                    $cvtdata2       256
700aAC                   parm      $itwhse       $cbwhse           3 0
700aAC                   parm      kilolbs       $cbsent           1

 1B  C                   if        $cbrtn <> '*OK'
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg    = $cberm
     C                   exsr      zm0105
     C                   goto      endck4
 1E  C                   endif

     *  Save entry to data structure.

     C     w4cnt         occur     #cwentries
     C                   eval      #cwentry  = w4cw
     C                   eval      #cwweight = $cbv1

     C     endck4        endsr

640iA*----------------------------------------------------------------
640iA*  ZZCHK4a  Screen 4a error checking.
640iA*----------------------------------------------------------------
640iA
640iAC     zzchk4a       begsr
640iAC                   eval      error = *off
640iA
640iA*  Catchweight cannot be blank
640iA
640iAC                   if        w4cw = ' '
640iAC                   move      *on           error
640iAC                   eval      *in21 = *on
640iAC                   eval      *in01 = *on
640iAC                   eval      errmsg    = 'Catchweight cannot be blank'
640iAC                   exsr      zm0105
640iAC                   goto      endck4a
640iAC                   endif
640iA
640iA*  Total quantity can not be zero
640iA
640iAC                   if        w4tqt < 0 or
640iAC                             w4tqt = 0
640iAC                   move      *on           error
640iAC                   eval      *in23 = *on
640iAC                   eval      *in03 = *on
640iAC                   eval      errmsg    = 'Total qty must be > 0'
640iAC                   exsr      zm0105
640iAC                   goto      endck4a
640iAC                   endif
750aA*
750aA*     Total qty greater than quantity needed.
750aAC                   if        w4tqt > (woqty - wopck)
750aAC                   eval      error = *on
750aAC                   eval      *in23 = *on
750aAC                   eval      *in03 = *on
750aAC                   eval      errmsg = 'Total qty > ordered'
750aAC                   exsr      zm0105
750aAC                   goto      endck4a
750aAC                   endif
640iA*   Get avail qty.
640iAC                   exsr      zzqavl
640iA
640iA*     Overflow slot can not go negative.
640iA*     Error if pick quantity is > available for overflow slot.
640iAC                   if        $slpick = 'N' and
640iAC                             w4tqt > availqty
640iAC                   eval      error = *on
640iAC                   eval      *in23 = *on
640iAC                   eval      *in03 = *on
640iAC                   eval      errmsg = 'Qty > available'
640iAC                   exsr      zm0105
640iAC                   goto      endck4a
640iAC                   endif
640iA
640iA*  Convert catchweight entry to a number.
640iA
640iAC                   call      'CVTBAR'
640iAC                   parm      '*CWGTLBS'    $cbcmd            8
640iAC                   parm      w4cw          $cbbar          100
640iAC                   parm                    $cbcod            3 0
640iAC                   parm                    $cbdec            1 0
640iAC                   parm                    $cbdsc           30
640iAC                   parm                    $cbpos            3 0
640iAC                   parm                    $cbtyp            1 0
640iAC                   parm                    $cbv1            11 3
640iAC                   parm                    $cbv2            50
640iAC                   parm                    $cbrtn            8
640iAC                   parm                    $cberm           60
700aAC                   parm      0             $cbven           10 0
700aAC                   parm                    $cvtdata        256
700aAC                   parm                    $cvtdata2       256
700aAC                   parm      $itwhse       $cbwhse           3 0
700aAC                   parm      kilolbs       $cbsent           1
640iA
640iAC                   if        $cbrtn <> '*OK'
640iAC                   move      *on           error
640iAC                   eval      *in21 = *on
640iAC                   eval      *in01 = *on
640iAC                   eval      errmsg    = $cberm
640iAC                   exsr      zm0105
640iAC                   goto      endck4a
640iAC                   endif
640iA
640iA*  Save weight, not using data structure
640iA
640iAC***  w4cnt         occur     #cwentries
640iAC***                eval      #cwentry  = w4cw
640iAC                   eval      w4cwt = $cbv1
640iA
640iAC     endck4a       endsr
640iA
     *----------------------------------------------------------------
     *  ZZCHK5   Screen 5 error checking.
     *----------------------------------------------------------------

     C     zzchk5        begsr
     C                   eval      error = *off
     C     endck5        endsr

     *----------------------------------------------------------------
     *  ZZCHK6   Screen 6 error checking.
     *----------------------------------------------------------------

     C     zzchk6        begsr
     C                   move      *off          error
500dD ** Reversed 416d that commented out the license check.
500d ** Verify pallet license entered.
416dD **
500d C                   if        w6lic = 0
500d C                   move      *on           error
500d C                   eval      *in21 = *on
500d C                   eval      *in01 = *on
500d C                   eval      errmsg = 'License not entered'
500d C                   exsr      zm0105
500d C     error         cabeq     *on           endck6
500d C                   endif
500dA
500d ** Verify pallet license entered is valid.
500d C                   eval      kyplic = w6lic
500dAC     wskey         setll     worksos
500d C     wskey         reade     worksos                                79
500d C                   if        *in79 = *on
500d C                   move      *on           error
500d C                   eval      *in21 = *on
500d C                   eval      *in01 = *on
500d C                   eval      errmsg = 'License invalid'
500d C                   exsr      zm0105
500d C     error         cabeq     *on           endck6
500d C                   endif
416dA
416dA*  Verify stage entered.
416dA
416dAC                   if        w6stag = ' '
416dAC                   eval      error = *on
416dAC                   eval      *in21 = *on
416dAC                   eval      *in01 = *on
416dAC                   eval      errmsg = 'Stage not entered'
416dAC                   exsr      zm0105
500d C     error         cabeq     *on           endck6
416dAC                   endif

500a *  Verify scanned slot exists for each staged item department.
500aAC                   exsr      zzwhdp
500aAC     error         ifeq      *on
500aAC                   eval      *in21 = *on
500aAC                   eval      *in01 = *on
500aAC                   eval      errmsg = 'Slot not in dept'
500aAC                   exsr      zm0105
500a C     error         cabeq     *on           endck6
500a C                   endif

500a *  Verify item/qty can be putaway in stage slot.
500aAC                   exsr      zzsput
500aAC     error         ifeq      *on
500aAC                   eval      *in21 = *on
500aAC                   eval      *in01 = *on
500aAC*                  eval      errmsg = 'Slot not in dept'
500aAC*                  exsr      zm0105
500a C     error         cabeq     *on           endck6
500a C                   endif
     C     endck6        endsr

     *----------------------------------------------------------------
     *  ZZCHK7   Screen 7 error checking.
     *----------------------------------------------------------------

     C     zzchk7        begsr
     C                   eval      error = *off
     C     endck7        endsr

     *----------------------------------------------------------------
     *  ZZCHK8   Screen 8 error checking.
     *----------------------------------------------------------------

     C     zzchk8        begsr
     C                   eval      error = *off
416dA
416dA*  Verify pallet license entered.
416dA
416dAC                   if        w8lic  = 0
416dAC                   eval      error  = *on
416dAC                   eval      *in21  = *on
416dAC                   eval      *in01  = *on
416dAC                   eval      errmsg = 'License not entered'
416dAC                   exsr      zm0105
416dAC                   endif

     C     endck8        endsr

640hA*----------------------------------------------------------------
640hA*  ZZCHK10  Screen 10 error checking.
640hA*----------------------------------------------------------------

640hAC     zzchk10       begsr
     C                   eval      error = *off
     *
     *  Verify UPC is for label item.
     * Fill r#header ds
     C                   eval      $hdrcommand = 'vfyupc'
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slvuitman# = #job
     C                   eval      $slvuilbl# = lblbl#
640h C                   eval      $slvuivalue = wIupcd
640xAC                   eval      $hdrportL   = 0
640xAC                   eval      $hdrportC   = 0
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slvfyupcin
640h00*                  exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
     C                   parm                    $prtnfields
     C                   eval      $slvfyupcout = $prtnfields
     *
     C                   if        $slvuoerrnum <> 0
     C                   eval      error = *on
     C                   eval      *in22 = *on
640hDC**                 eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = $slvuoerrtext
640hDC**                 exsr      zm9898
640hMC                   exsr      zm0105
     C                   goto      endck10
     C                   else
     C                   endif
     *
640hAC     endck10       endsr

640qA*----------------------------------------------------------------
640qA*  ZZCHKQTY    Check if entire qty has been picked
640qA*----------------------------------------------------------------
640qa
640qAC     zzChkQty      begsr
      /free
         error = *off;

         // Get ordered quantity

         exec sql
           select odqor1, odqor2, odqor3
           into   :ordered1, :ordered2, :ordered3
           from   ordd
640rM      where  odwhse = :lbwhse and
640rM             odord  = :lbord  and odseq = :lbseq;

         if sqlstt <> sqlSuccess;
           ordered1 = 0;
           ordered2 = 0;
           ordered3 = 0;
         endif;

         // Get total qty picked

         exec sql
           select sum(lbqpck) into :picked
           from   label
           where  lbwhse = :lbwhse and lbrte = :lbrte and
                  lbord  = :lbord  and lbseq = :lbseq and
                  lbutyp = :lbutyp;

         if sqlstt <> sqlSuccess;
           picked = 0;
         endif;

         if lbutyp = 'N' and picked >= ordered1
            or lbutyp = '1' and picked >= ordered2
            or lbutyp = '2' and picked >= ordered3;
              error = *on;
              errcode = 'ZEROREMAIN';
              exsr zzdsperr;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     zzcmd1        begsr

     *  Command keys to check BEFORE verification and update.

 1B  C                   if        cmdchk = '*BEFORE '
 1E  C                   endif

     *  Command keys to check AFTER verification and update.

 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZCMD2   User defined command keys for screen 2.
     *----------------------------------------------------------------

     C     zzcmd2        begsr

     *  Command keys to check BEFORE verification and update.

 1B  C                   if        cmdchk = '*BEFORE '
416aA
416aA*  Test for F4 - Lookup
416aA
416aAC                   if        *inkd
416bA
416bA*    Display list of slots for item.
416bA
416aAC                   eval      cmdtkn = *on
416aAC                   eval      $lwhs2 = lbwhse
416aAC                   eval      $litm2 = lbitem
416aAC                   eval      $lwhd2 = lbwhdp
416aAC                   eval      $ldsp2 = lbdisp
416aAC                   call      'IT232'
416aAC                   parm                    $luky
416aAC                   parm                    $lrtn
640tAC                   parm                    $lprg
416bA
640wAC                   eval      $llbl# = lblbl#
416bA*    Get info on selected slot.
416bA
416aAC                   if        $lrtn = '*SELECT'
416aAC                   eval      wodisp = $ldsp2
416bA
640bAC                   exsr      clr$slot
640bDC**                 eval      savever# = $slver#
640bDC**                 clear                   $slot
640bDC**                 eval      $slver# = savever#
416bA
416bAC                   eval      $dricommand = '*SLOT'
416bAC                   eval      $drisubcmd  = '%GET'
416bA
416bAC                   eval      $slwhseu = *on
416bAC                   eval      $slwhse = $lwhs2
416bAC                   eval      $slwhdpu = *on
416bAC                   eval      $slwhdp = $lwhd2
416bAC                   eval      $sldispu = *on
416bAC                   eval      $sldisp = $ldsp2
416bAC                   exsr      zzzdricop
640bAC                   eval      curlic# = $saToLcns
416aAC                   endif
416aAC                   endif
640lA
640lA*  Test for F6 - License entry
640lA
640lAC                   if        *inkf
640lA
640lAC     again         tag
640lA
640lAC                   write     clrscr
640lA*
640lA*   Set ON alarm indicator if error occured
640lA*
640lAC                   if        error = *on
640lAC                   eval      *in98 = *on
640lAC                   endif
640lA*
640lA*   Overlay screen with error messages
640lA*
640lAC                   exsr      zmdmsg
640lA
640lAC                   if        nxtscr = '02 '
640lAC                   select
640lAC                   when      #lline = '16' and e$lng = 'SP'
640lAC                   exfmt     scrn71sp                             50
640lAC                   when      #lline = '16' and e$lng = 'EN'
640lAC                   exfmt     screen71                             50
640lA**                  other
640lAC                   when      #lline <> '16' and e$lng = 'SP'
640lAC                   exfmt     scrn11sp                             50
640lAC                   when      #lline <> '16' and e$lng = 'EN'
640lAC                   exfmt     screen11                             50
640lAC                   endsl
640lAC                   endif
640lA*
640lAC                   if        *inkl
640lAC                   eval      cmdtkn = *on
640lAC                   goto      endcm2
640lAC                   endif
640lA*
640lA*   Initialize error indicators and fields
640lA*
640lAC                   setoff                                       010203
640lAC                   setoff                                       040506
640lAC                   setoff                                       070809
640lAC                   setoff                                       101112
640lAC                   setoff                                       131415
640lAC                   setoff                                       161718
640lAC                   setoff                                       1920
640lAC                   setoff                                       212223
640lAC                   setoff                                       242526
640lAC                   setoff                                       272829
640lAC                   setoff                                       303132
640lAC                   setoff                                       333435
640lAC                   setoff                                       363738
640lAC                   setoff                                       3940
640lAC                   setoff                                       9298
640lAC                   eval      warn = *off
640lAC                   eval      error = *off
640lAC                   eval      cmdtkn = *off
640lAC                   eval      redspl = *off
640lAC                   eval      e = 0
640lA*
640lA*   Initialize error subfile
640lA*
640lAC                   exsr      zmcmsg
640lA*
640lA*  Verify License if entered.
640lA*
640lAC                   if        w8lica <> ' '
640lAC                   exsr      clr$license
640lAC                   eval      $liToLcnsU = *on
640lAC                   eval      $liToLcns = w8lica
640lAC                   eval      $dricommand = '*LICENSE'
640lMC                   eval      $drisubcmd  = '%GETINFO'
640lAC                   eval      $drisys2upd = 'D'
640lAC                   eval      chk4err = *on
640lAC                   eval      zmflag  = *off
640lAC                   exsr      zzzdricop
640lA
640lAC                   select
640lAC                   when      error
640lAC                   eval      *in21 = *on
640lAC                   eval      *in01 = *on
640lAC                   eval      errmsg = *blanks
640lAC                   exsr      zm022
640lAC                   goto      again
640lA
640lAC                   when      $litoitem <> woitem
640lAC                   eval      error = *on
640lAC                   eval      errmsg    = 'License not associated +
640lAC                                          with Item'
640lAC                   eval      *in21 = *on
640lAC                   eval      *in01 = *on
640lAC                   exsr      zm0105
640lAC                   goto      again
650bA
650bAC                   when      $litocode <> 'S'
650bAC                   eval      error = *on
650bAC                   eval      errmsg    = 'License not available +
650bAC                                          in slot  '
650bAC                   eval      *in21 = *on
650bAC                   eval      *in01 = *on
650bAC                   exsr      zm0105
650bAC                   goto      again
640lA
640lAC                   other
640bAC                   eval      curlic# = w8lica
640bAC                   eval      w2slot = $litodisp
640bAC                   eval      wodisp = $litodisp
640bAC                   eval      $sldisp = $litodisp
640bAC                   eval      $sacdsp = $litodisp
640vAC                   eval      w8lica = *blanks
640lAC                   endsl
640lAC                   endif
640lAC                   endif
416aA
 1E  C                   endif

     *  Command keys to check AFTER verification and update.

 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
     C     endcm2        endsr

     *----------------------------------------------------------------
     *  ZZCMD3   User defined command keys for screen 3.
     *----------------------------------------------------------------

     C     zzcmd3        begsr
     C                   move      *off          cmdtkn

     *  Command keys to check BEFORE verification and update.

 1B  C                   if        cmdchk = '*BEFORE '
 1E  C                   endif

     *  Command keys to check AFTER verification and update.

 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
     C     endcm3        endsr

     *----------------------------------------------------------------
     *  ZZCMD4   User defined command keys for screen 4.
     *----------------------------------------------------------------

     C     zzcmd4        begsr

     *  Command keys to check BEFORE verification and update.

 1B  C                   if        cmdchk = '*BEFORE '

     *  Test for F7 - Previous

 2B  C                   if        *inkg
     C                   move      *on           cmdtkn

     C                   if        w4cnt > 1
     C                   eval      w4cnt  = w4cnt - 1
 1B  C                   eval      refrsh = *on
     C                   exsr      scr04i
     C                   else
     C                   exsr      scr02i
     C                   endif

     C                   endif
640iA
640iA*  Test for F9 - Enter total quantity and weight

640iAC                   if        *inki
640iAC                   move      *on           cmdtkn
640iA
640iAC                   eval      refrsh = *on
640iAC                   exsr      scr4Ai
640iA
640iAC                   endif

     *  Test for F13 - No More

 2B  C                   if        *inkm
     C                   move      *on           cmdtkn
     C                   if        w4cnt = 1
     C                   eval      error = *on
     C                   eval      errmsg = 'Nothing entered yet'
     C                   else
     C                   eval      w4cnt = w4cnt - 1
     C                   eval      w4qty = w4cnt
     C                   exsr      zzupd4
     C                   endif
     C                   endif
700aA*
700aA*      F19 - kilograms/Pounds toggle
700aA*
700aAC                   if        *inkt
700aAC                   eval      cmdtkn = *on
700aAC                   if        KiloLbs = 'P'
700aAC                   eval      KiloLbs = 'K'
700aAC                   eval      W4KgLb  = 'Kgs'
700aAC                   else
700aAC                   eval      KiloLbs = 'P'
700aAC                   eval      W4KgLb  = 'Lbs'
700aAC                   endif
700aAc                   exsr      zzsetcmdln1
700aAC                   goto      endcm4
700aAC                   endif

 1E  C                   endif

     *  Command keys to check AFTER verification and update.

 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
     C     endcm4        endsr

640iA*----------------------------------------------------------------
640iA*  ZZCMD4A  User defined command keys for screen 4A
640iA*----------------------------------------------------------------
640iA
640iAC     zzcmd4A       begsr
640iAC                   move      *off          cmdtkn
640iA
640iA*  Command keys to check BEFORE verification and update.
640iA
640iAC                   if        cmdchk = '*BEFORE '
700aA*
700aA*      F19 - kilograms/Pounds toggle
700aA*
700aAC                   if        *inkt
700aAC                   eval      cmdtkn = *on
700aAC                   if        KiloLbs = 'P'
700aAC                   eval      KiloLbs = 'K'
700aAC                   eval      W4KgLb  = 'Kgs'
700aAC                   else
700aAC                   eval      KiloLbs = 'P'
700aAC                   eval      W4KgLb  = 'Lbs'
700aAC                   endif
700aAc                   exsr      zzsetcmdln1a
700aAC                   goto      endcm4a
700aAC                   endif
640iAC                   endif
640iA
640iA*  Command keys to check AFTER verification and update.
640iA
640iAC                   if        cmdchk = '*AFTER  '
640iAC                   endif
640iAC     endcm4a       endsr
640iA
     *----------------------------------------------------------------
     *  ZZCMD5   User defined command keys for screen 5.
     *----------------------------------------------------------------

     C     zzcmd5        begsr
     C                   eval      cmdtkn = *off

     *  Command keys to check BEFORE verification and update.

 1B  C                   if        cmdchk = '*BEFORE '
416dA*
416dA*  Test for F7 - Start new pallet
416dA*
416dAC                   if        *inkg
416dAC                   move      *on           cmdtkn
416dAC                   eval      refrsh = *on
416dAC                   exsr      scr08i
416dAC                   endif
     *
416dM*  Test for F8 - Finished
     *
416dDC**                 if        *inkj
416dMC                   if        *inkh
     C                   move      *on           cmdtkn
 1B  C                   eval      refrsh = *on
     C                   exsr      scr06i
     C                   endif

 1E  C                   endif

     *  Command keys to check AFTER verification and update.

 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
     C     endcm5        endsr

     *----------------------------------------------------------------
     *  ZZCMD6   User defined command keys for screen 6.
     *----------------------------------------------------------------

     C     zzcmd6        begsr
     C                   move      *off          cmdtkn

     *  Command keys to check BEFORE verification and update.

 1B  C                   if        cmdchk = '*BEFORE '
 1E  C                   endif

     *  Command keys to check AFTER verification and update.

 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
     C     endcm6        endsr

     *----------------------------------------------------------------
     *  ZZCMD7   User defined command keys for screen 7.
     *----------------------------------------------------------------

     C     zzcmd7        begsr

     *  Command keys to check BEFORE verification and update.

 1B  C                   if        cmdchk = '*BEFORE '
 1E  C                   endif

     *  Command keys to check AFTER verification and update.

 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
     C     endcm7        endsr

     *----------------------------------------------------------------
     *  ZZCMD8   User defined command keys for screen 8.
     *----------------------------------------------------------------

     C     zzcmd8        begsr
     C                   eval      cmdtkn = *off

     *  Command keys to check BEFORE verification and update.

 1B  C                   if        cmdchk = '*BEFORE '
 1E  C                   endif

     *  Command keys to check AFTER verification and update.

 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
     C     endcm8        endsr

640hA*----------------------------------------------------------------
640hA*  ZZCMD10  User defined command keys for screen 10.
640hA*----------------------------------------------------------------

640hAC     zzcmd10       begsr
     C                   move      *off          cmdtkn

     *  Command keys to check BEFORE verification and update.

 1B  C                   if        cmdchk = '*BEFORE '
 1E  C                   endif

     *  Command keys to check AFTER verification and update.

 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
640hAC     endcm10       endsr
640hA
     *----------------------------------------------------------------
     *  ZZCWINZ   Initialize catchweight data structure
     *----------------------------------------------------------------

     C     zzcwinz       begsr

     C                   do        #cwmax        i
     C     i             occur     #cwentries
     C                   reset                   #cwentries
     C                   enddo

     C                   endsr

416lA*----------------------------------------------------------------
416lA*  ZZCVTDT    Convert Date to correct format.
416lA*----------------------------------------------------------------
416lA
416lAC     zzcvdt        BegSr
416lA *
416lAC                   Call      @cvtdt
416lAC                   parm                    $cvtdt
416lAC     EndCvd        ENDSR

     *----------------------------------------------------------------
     *  ZZDSPERR   Display full screen error message.
     *----------------------------------------------------------------

     C     zzdsperr      begsr

     * Clear message lines.

     C                   eval      woln01 = ' '
     C                   eval      woln02 = ' '
     C                   eval      woln03 = ' '
     C                   eval      woln04 = ' '
     C                   eval      woln05 = ' '
     C                   eval      woln06 = ' '
     C                   eval      woln07 = ' '
     C                   eval      woln08 = ' '
     C                   eval      woln09 = ' '
     C                   eval      woln10 = ' '

     * Create message

     C                   select

     C                   when      errcode = 'LBLNOTFND'
     C                   eval      woln01 = '  Label record was'
     C                   eval      woln02 = '   not found for'
     C                   eval      woln03 = '   selected item'
     C                   eval      woln06 = '   Press Enter to'
     C                   eval      woln07 = '      continue'

     C                   when      errcode = 'LBLLOCKED'
     C                   eval      woln01 = '  Label record is'
     C                   eval      woln02 = '     locked by'
     C                   eval      woln03 = '    another user'
     C                   eval      woln06 = '   Press Enter to'
     C                   eval      woln07 = '      continue'

     C                   when      errcode = 'ZEROREMAIN'
     C                   eval      woln01 = 'Entire qty for item'
     C                   eval      woln02 = ' has already been'
     C                   eval      woln03 = '      picked'
416eMC                   eval      woln05 = '   Press Enter to'
416eMC                   eval      woln06 = 'continue         '

416jAC                   when      errcode = 'PCKGTAVAIL'
416jA*    Activate F10=Accept error function key.
416jAC                   eval      *in45  = *on
416jAC                   eval      woln01 = 'Pick qty greater   '
416jAC                   eval      woln02 = 'than available slot'
416jAC                   eval      woln03 = 'qty. Press         '
416jAC                   eval      woln05 = 'F10=Accept error to'
416jAC                   eval      woln06 = 'continue.        '

     C                   other
     C                   eval      woln05 = errcode

     C                   endsl

     * Display message

416eAC                   select
500hAC                   when      #lline = '16' and e$lng = 'SP'
500hAC                   exfmt     scrn69sp                             50
500hAC                   when      #lline = '16' and e$lng = 'EN'
     C                   exfmt     screen69                             50
500hD**                  other
500hAC                   when      #lline <> '16' and e$lng = 'SP'
500hAC                   exfmt     scrn9sp                              50
500hAC                   when      #lline <> '16' and e$lng = 'EN'
     C                   exfmt     screen9                              50
416eAC                   endsl
416jAC                   eval      *in45  = *off

     C                   endsr

416lA*----------------------------------------------------------------
416lA*  ZZEXCP Write item exception record to file.
416lA*----------------------------------------------------------------
416lA*
416lAC     ZZEXCP        BEGSR
416lA*
416lA*    Write out item exception record
416lAC                   eval      exwhse = lbwhse
416lAC                   eval      exwhdp = lbwhdp
416lAC                   eval      exstyp = lbstyp
416lAC                   eval      exitem = lbitem
416lAC                   eval      exfdis = wodisp
416lAC                   eval      extdis = *blanks
416lAC                   eval      extask = 'SELECT'
416lA*    Get todays date.
416lAC                   eval      $cvcmd = '*CURCMD '
416lAC                   exsr      zzcvdt
416lAC                   eval      exgdte = $CVD8O
416lAC                   time                    exgtim
416lAC                   eval      exgby  = #user
416lAC                   eval      exesta = '1 '
416lAC                   write     exrec
416lA*
416lAC     endexc        EndSr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr

     * Get User information.

     C                   call      'GETUSER'
     C                   parm      #user         $code            10
     C                   parm      0             $whse             3 0
     C                   parm      0             $emp#             5 0
     C                   parm      *blanks       $fnam            15
     C                   parm      *blanks       $init             1
     C                   parm      *blanks       $lnam            20
     C                   parm      *blanks       $whdp             5
     C                   parm      *blanks       $styp             1
     C                   parm      *blanks       $shft             6
     C                   parm      *blanks       $crew             6
     C                   parm      0             $nhrs             3 1
     C                   parm      *blanks       $rtn              8

     C                   eval      w1whse = $whse
     C                   eval      w1ord = 0
     C                   eval      woinf1 = ' '
     C                   eval      woinf2 = ' '

640uAC                   if        passact = *on
640uAC     pskey         setll     passtran
640uAC                   dow       forevr = forevr
640uAC     pskey         reade     passtran                               78
640uAC                   select
640uAC                   when      not *in78 and pasetyp='C'
640uAC                   eval      $cvcmd = '*CURCMD '
640uAC                   call      @cvtdt
640uAC                   parm                    $cvtdt
640uAC                   time                    ref#Time
640uAC                   eval      pasetyp = 'X'
640uAC                   eval      pasedte = $cvd8o
640uAC                   eval      pasetim = ref#time
640uAC                   eval      paspcs  = +$pQty
640uAC                   eval      passact = *off
640uAC                   update    pasrec
640uAC                   leave
640uAC                   when      *in78
640uAC                   leave
640uAC                   endsl
640uAC                   enddo
640uAC                   endif
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil2        begsr

     *  Get item information.

     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#

     C                   eval      $itwhse = lbwhse
     C                   eval      $ititem = lbitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
640bA
640bA*  Create heading description.
640bA
640bAC                   call      'FRMTIT'
640bAC                   parm                    $ititem
640bAC                   parm                    $itdesc
640bAC                   parm                    $itpdsc
640bAC                   parm      ' '           #fromithead

     *  Fill in screen fields.

     C                   eval      woord  = $ohcord
     C                   eval      woline = lbseq
     C                   eval      woitem = lbitem
     C                   eval      wodesc = $itdesc
416aDC**                 eval      wodisp = lbdisp

416gAC                   eval      woitm2 = %trim(lbitem) + '/' + $itdesc
     C                   movel     woitm2        woitma           15
     C                   move      woitm2        woitmb           55

     C                   eval      w2slot = ' '
     C                   eval      w2lic  = ' '

     *  Determine if license needs to be captured.

     C                   if        %scan('*L' : $ohmisc) = 0
     C                   eval      *in94 = *off
     C                   eval      licpick = *off
     C                   else
     C                   eval      *in94 = *on
     C                   eval      licpick = *on
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil3        begsr

     C                   eval      woqty = lbqalc
416hDC*                  eval      wopck = lbqpck
416hMC                   eval      wopck = picked
     C                   eval      woum  = lbucod

     C                   eval      w3qty = 0

     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL4   Fill screen 4 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil4        begsr

     C     w4cnt         occur     #cwentries
     C                   eval      w4cw = #cwentry

     C                   if        w4cnt = 1
     C                   eval      w4last = 0
     C                   else
     C                   eval      #cwprev = w4cnt - 1
     C     #cwprev       occur     #cwentries
     C                   eval      w4last = #cwweight
     C                   endif

     C                   endsr

640iA*----------------------------------------------------------------
640iA*  ZZFIL4A  Fill screen 4a fields with info from file.
640iA*----------------------------------------------------------------
640iA
640iAC     zzfil4A       begsr
640iA
640iAC                   endsr
640iA
     *----------------------------------------------------------------
     *  ZZFIL5   Fill screen 5 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil5        begsr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL6   Fill screen 6 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil6        begsr
416dAC                   eval      w6stag = ' '
500d C                   eval      wolctr = pliccount
500d C                   if        pliccount = 1
500d C                   eval      w6lic = kyplic
500d C                   else
500d C                   eval      w6lic = 0
500d C                   endif
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL7   Fill screen 7 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil7        begsr
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL8   Fill screen 3 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil8        begsr
416dAC                   eval      w8lic = 0
416dAC                   eval      woord = w1ord
640uAC                   If        optbd = 'Y'
640uAC                   exsr      zzpass
640uAC                   endif
     C                   endsr

640hA*----------------------------------------------------------------
640hA*  ZZFIL10  Fill screen 10 fields with info from file.
640hA*----------------------------------------------------------------

640hAC     zzfil10       begsr


     *  Fill in screen fields.

     C*                  eval      woord  = $ohcord
     C*                  eval      woline = lbseq
     C*                  eval      woitem = lbitem
     C*                  eval      wodesc = $itdesc

     C*                  eval      woitm2 = %trim(lbitem) + '/' + $itdesc
     C*                  movel     woitm2        woitma           15
     C*                  move      woitm2        woitmb           55

     C                   eval      wiupcd = ' '

640hAC                   endsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog

     *  Define key for RTEHED file

     C     keyrh         klist
     C                   kfld                    $ohwhse
     C                   kfld                    $ohrid

     *  Define partial key for ORDC file

     C     keyoc         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbord
     C                   kfld                    lbseq
     C                   kfld                    lbitem
     C                   kfld                    lblbl#

     *  Define partial key for PLTSUM2 file

     C     keyps2        klist
     C                   kfld                    rhwhse
     C                   kfld                    rhrtid
416dA
416dA*  Define full key for PLTSUM2 file
416dA
416dAC     keyps2f       klist
416dAC                   kfld                    pswhse
416dAC                   kfld                    psrtid
416dAC                   kfld                    pstype
416dAC                   kfld                    psgen
416dAC                   kfld                    psrow
416dAC                   kfld                    pscol

500aAC     wskey         klist
500aAC                   kfld                    w1whse
500aAC                   kfld                    #user
500dAC                   kfld                    kyplic

500dAC     wskey1        klist
500dAC                   kfld                    w1whse
500dAC                   kfld                    #user

500aAC     slkey2        klist
500aAC                   kfld                    w1whse
500aAC                   kfld                    wkswhd
500aAC                   kfld                    w6stag
640uA*
640uA*  Define PASSTRAN key
640uA*
640uAC     pskey         klist
640uAC                   kfld                    $pEmp#
640uAC                   kfld                    lbtrn#

640uA*  Define key for ORDH5
640uA*
640uAC     keyord5       klist
640uAC                   kfld                    w1whse
640uAC                   kfld                    w1ord
640uA*  Define key for LABEL93
640uA*
640uAC     keylbl93      klist
640uAC                   kfld                    w1whse
640uAC                   kfld                    ohord
640uA*  Define full key for option file.
640uA*
640uAC     opkey         klist
640uAC                   kfld                    cod               8
640uAC                   kfld                    whs               3 0
640uAC                   kfld                    wdp               5
640uA*
640uAC                   movel     '*USER'       cod
     C                   eval      #pgmq = #prog

     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ2   Program initialization. Called from main line.
     *----------------------------------------------------------------

     C     zzinz2        begsr
500hA*
500hA*   Get employee options.
500hA*
500hAC                   call      'GETUSER'
500hAC                   parm      #USER         E$CODE           10
500hAC                   parm                    E$WHSE            3 0
500hAC                   parm                    E$EMP#            5 0
500hAC                   parm                    E$FNAM           15
500hAC                   parm                    E$INIT            1
500hAC                   parm                    E$LNAM           20
500hAC                   parm                    E$WHDP            5
500hAC                   parm                    E$STYP            1
500hAC                   parm                    E$SHFT            6
500hAC                   parm                    E$CREW            6
500hAC                   parm                    E$NHRS            3 1
500hAC                   parm                    E$RTN             8
500hAC                   parm                    E$BPU             1
500hAC                   parm                    E$LNG             2
500hAC                   if        E$RTN <> '*OK'
500hAC                   eval      E$LNG = 'EN'
500hAC                   endif
500hA*
     C                   setoff                                       kckl
     C                   move      *on           refrsh

     * Get screen size being used.

     C                   call      'PIRRFSCR'
     C                   parm      '*GET'        #lcmd             8
     C                   parm                    #lline            2
     C                   parm                    #lcol             3

640uAC                   eval      wdp = *blanks
640uAC                   eval      whs = 0
640uAC     opkey         chain     optione
640uAC                   if        not %found(optione)
640uAC                   eval      optbd  = 'N'
640uAC                   endif

     * Force screen size to 16 lines.

416eDC**                 eval      #lline = '16'

     * Define item list to initially display by line #.

     C                   eval      listorder = 'LINE'

     * Display the first screen.

416bAC                   eval      lastitem = ' '
416bAC                   eval      lastseq  = 0
     C                   exsr      scr01i

     C                   endsr

     *----------------------------------------------------------------
     *  ZZLBL#   Get label record.
     *----------------------------------------------------------------

     C     zzlbl#        begsr
     C                   eval      error = *off

     *  Get label record.

640pAC                   if        lock
     C     $llbl#        chain     label                                78
640pAC                   else
640pAC     $llbl#        chain(n)  label                                78
640pAC                   endif
     C                   if        not %found
     C                   eval      error = *on
     C                   eval      errcode = 'LBLNOTFND'
     C                   exsr      zzdsperr
     C                   goto      endlbl#
     C                   endif

     C                   if        *in78 = *on
     C                   eval      error = *on
     C                   eval      errcode = 'LBLLOCKED'
     C                   exsr      zzdsperr
     C                   goto      endlbl#
     C                   endif

640pDC**                 eval      picked = 0
640pDC**
640pDC**XEC SQL
640pDC** SELECT SUM(LBQPCK), MIN(LBLBL#)
640pDC**        INTO :PICKED, :$LLBL#
640pDC** FROM   LABEL
640pDC** WHERE  LBWHSE = :$LWHSE AND LBRTE = :$LRTID AND
640pDC**        LBORD  = :$LORD  AND LBSEQ = :$LSEQ
640pDC**ND-EXEC
640pDC**
640pDC**                 if        lbqpck >= lbqalc
640pDC**                 if        picked >= lbqalc
640pDC**                 unlock    label
640pDC**                 eval      error = *on
640pDC**                 eval      errcode = 'ZEROREMAIN'
640pDC**                 exsr      zzdsperr
640pDC**                 goto      endlbl#
640pDC**                 endif

     C     endlbl#       endsr

     *----------------------------------------------------------------
     *  ZZLIST   Display list of items.
     *----------------------------------------------------------------

     C     zzlist        begsr
     C     zzlistbeg     tag
     C                   eval      error = *off

     *  Initialize parameters.

     C                   eval      $lwhse = $ohwhse
     C                   eval      $lord  = $ohoid
     C                   eval      $lrtid = $ohrid
     C                   eval      $lpbat = rhpbat
416bAC                   eval      $litem = lastitem
416bAC                   eval      $lseq  = lastseq

     C                   if        #lline = '16'
     C                   eval      $lcmd = '*SELEC16'
     C                   else
     C                   eval      $lcmd = '*SELECT'
     C                   endif

     *  Display list.

     C                   dow       forevr = forevr

     C                   select
     C                   when      listorder = 'LINE'
     C                   call      'OR910'
     C                   parm                    $lparm
     C                   other
     C                   call      'OR920'
     C                   parm                    $lparm
     C                   endsl

     C                   if        $lrtn = '*F9'
     C                   if        listorder = 'LINE'
     C                   eval      listorder = 'SLOT'
     C                   else
     C                   eval      listorder = 'LINE'
     C                   endif
     C                   iter
     C                   endif

     C                   leave
     C                   enddo

     *  Now what ...

     C                   select

     *    When a record was not selected.

     C                   when      $lrtn <> '*SELECT'

     *      If an item hasn't been picked yet,
     *        then return to the first screen.
     *        otherwise return to the "next step" screen.

     C                   if        pickcount = 0
 1B  C                   eval      refrsh = *off
     C                   exsr      scr01i
     C                   else
     C                   exsr      scr05i
     C                   endif

     *    When a record was selected.

     C                   other

     *      Get label record to work with (returned from list display).

640pAC                   eval      lock = *off
     C                   exsr      zzlbl#
     C                   if        error
     C                   goto      zzlistbeg
     C                   endif
     C                   eval      error = *off
640pA
640pA*      Check if entire qty has already been picked.
640pA
640pAC                   exsr      zzChkQty
640pAC                   if        error
640zAC                   if        errcode = 'ZEROREMAIN'
640zAC                   eval      lock = *on
640zAC                   exsr      zzlbl#
640zAC                   eval      lbvrfy = ' '
640zAC                   update    lbrec
640zAC                   unlock    label
640zAC                   endif
640pAC                   goto      zzlistbeg
640pAC                   endif
416bA
416bA*      Get first pick slot with available quantity.
416bA
640bAC                   exsr      clr$slot
640bDC**                 eval      savever# = $slver#
640bDC**                 clear                   $slot
640bDC**                 eval      $slver# = savever#
416bA
416bAC                   eval      $dricommand = '*SLOT'
416bAC                   eval      $drisubcmd  = '%NXTPICKAV'
416bA
416bAC                   eval      $slwhseu = *on
416bAC                   eval      $slwhse = lbwhse
417 AC                   eval      $slwhdpu = *on
417 AC                   eval      $slwhdp = lbwhdp
417 AC                   eval      $slstypu = *on
417 AC                   eval      $slstyp = lbstyp
416bAC                   eval      $slitemu = *on
416bAC                   eval      $slitem = lbitem
416bAC                   eval      $slstatu = *on
416bAC                   eval      $slstat = 'A'
417 AC                   eval      $slpicku = *on
417 AC                   eval      $slpick = 'Y'
417 AC                   eval      $slprtyu = *on
417 AC                   eval      $slexpdu = *on
417 AC                   eval      $slentdu = *on
417 AC                   eval      $slaislu = *on
417 AC                   eval      $slaisl = lbaisl
417 AC                   eval      $slpsequ = *on
417 AC                   eval      $slpseq = lbpseq
417 AC                   eval      $slpsequ = *on
417 AC                   eval      $slpseq = lbpseq
417 AC                   eval      $slrlvlu = *on
417 AC                   eval      $slhandu = *on
416bAC                   exsr      zzzdricop
416bAC     error         cabeq     *on           endlist
640kA
640kA*   If no pick slot w avail qty, get first pick slot.
640kA
640kAC                   if        $sldisp = *blanks
640kAC                   exsr      clr$slot
640bDC**                 eval      savever# = $slver#
640bDC**                 clear                   $slot
640bDC**                 eval      $slver# = savever#
    A
   kAC                   eval      $dricommand = '*SLOT'
640kDC**                 eval      $drisubcmd  = '%NXTPICKAV'
640kMC                   eval      $drisubcmd  = '%NXTPICK  '
640kA
640kAC                   eval      $slwhseu = *on
640kAC                   eval      $slwhse = lbwhse
640kAC                   eval      $slwhdpu = *on
640kAC                   eval      $slwhdp = lbwhdp
640kAC                   eval      $slstypu = *on
640kAC                   eval      $slstyp = lbstyp
640kAC                   eval      $slitemu = *on
640kAC                   eval      $slitem = lbitem
640kAC                   eval      $slstatu = *on
640kAC                   eval      $slstat = 'A'
640kAC                   eval      $slpicku = *on
640kAC                   eval      $slpick = 'Y'
640kAC                   eval      $slprtyu = *on
640kAC                   eval      $slexpdu = *on
640kAC                   eval      $slentdu = *on
640kAC                   eval      $slaislu = *on
640kAC                   eval      $slaisl = lbaisl
640kAC                   eval      $slpsequ = *on
640kAC                   eval      $slpseq = lbpseq
640kAC                   eval      $slpsequ = *on
640kAC                   eval      $slpseq = lbpseq
640kAC                   eval      $slrlvlu = *on
640kAC                   eval      $slhandu = *on
640kAC                   exsr      zzzdricop
640kAC     error         cabeq     *on           endlist
640kAC                   endif
640bAC                   eval      curlic# = $saToLcns
416bAC                   eval      wodisp = $sldisp

     *      Initialize catchweight data structure.

     C                   exsr      zzcwinz

     *      Display pick slot screen.

 1B  C                   eval      refrsh = *on
     C                   exsr      scr02i

     *      Save item & seq.

416bAC                   eval      lastitem = lbitem
416bAC                   eval      lastseq  = lbseq

     C                   endsl

     C     endlist       endsr

640uA*----------------------------------------------------------------
640uA*  ZZPASS   Create initial PASSTRAN record.
640uA*----------------------------------------------------------------
640uA
640uAC     zzpass        begsr
640uAC                   eval      passact = *on
640uAC     keyord5       chain(n)  ordh5
640uAC                   if        %found(ordh5)
640uAC     keylbl93      chain(n)  label93
640uAC                   if        %found(label93)
640uAC                   eval      $cvcmd = '*CURCMD '
640uAC                   call      @cvtdt
640uAC                   parm                    $cvtdt
640uAC                   time                    ref#Time
640uA*  Check to make sure employee did not leave record open
640uAC     $emp#         setll     passtran
640uAC                   dow       forevr = forevr
640uAC     $emp#         reade     passtran                               78
640uAC                   select
640uAC                   when      not *in78 and pasetyp='C'
640uAC                   eval      pasetyp = 'X'
640uAC                   update    pasrec
640uAC                   leave
640uAC                   when      *in78
640uAC                   leave
640uAC                   endsl
640uAC                   enddo
640uAC                   eval      pasetyp = 'C'
640uAC                   eval      pastrn# = lbtrn#
640uAC                   eval      paswhse = lbwhse
640uAC                   eval      passhft = $shft
640uAC                   eval      pasemp# = $emp#
640uAC                   eval      pascrew = $crew
640uAC                   eval      paspcs  = *zeros
640uAC                   eval      passdte = $cvd8o
640uAC                   eval      passtim = ref#time
640uAC                   eval      pasedte = *zeros
640uAC                   eval      pasetim = *zeros
640uAC                   write     pasrec
640uAC                   endif
640uAC                   endif
640uAC                   endsr
640f *----------------------------------------------------------------
640f *  ZZQAVL   Get Slot Available quantity.
640f *----------------------------------------------------------------
640f
640f C     zzqavl        begsr
640fAC                   exsr      clr$slot
640fA
640fAC                   eval      $dricommand = '*SLOT'
640fAC                   eval      $drisubcmd  = '%GET'
640fA
640fAC                   eval      $slwhseu = *on
640fAC                   eval      $slwhse = lbwhse
640fAC                   eval      $slwhdpu = *on
640fAC                   eval      $slwhdp = lbwhdp
640fAC                   eval      $sldispu = *on
640fAC                   eval      $sldisp = wodisp
640fAC                   exsr      zzzdricop
640fA*
640fAC                   eval      availqty = $slavl1
640fA*
640fA*    Convert case qty to breakdown qty 1 level.
640fAC                   select
640fAC                   when      $itflg1  = 'Y' and $itumq2 > 0 and
640fAC                             lbutyp = '1'
640fAC                   eval      availqty = (availqty * $itumq2) +
640fAC                             $slavl2
640fA
640fA*
640fA*    Convert break down qty 2 to breakdown qty 3.
640fAC                   when      $itflg2  = 'Y' and $itumq3 > 0 and
640fAC                             lbutyp = '2'
640fAC                   eval      availqty = (((availqty * $itumq2) +
640fAC                             $slavl2) * $itumq3) + $slavl3
640faC                   endsl
640f C     endqavl       endsr
     *----------------------------------------------------------------
     *  ZZUPD1   Update for screen 1.
     *----------------------------------------------------------------

     C     zzupd1        begsr
     C                   eval      error = *off

     *  Get route header information.

     C     keyrh         chain     rtehed                               78
     C                   if        not %found
     C                   eval      error = *on
     C                   eval      errmsg    = 'Could not find route '
     C                                       + 'record for order '
     C                                       + '('
     C                                       + %trim($ohrid)
     C                                       + ')'
     C                   exsr      zm0105
     C                   goto      endup1
     C                   endif
     C                   if        *in78 = *on
     C                   eval      error = *on
     C                   eval      errmsg    = 'Route in use by another '
     C                                       + 'user '
     C                                       + '('
     C                                       + %trim($ohrid)
     C                                       + ')'
     C                   exsr      zm0105
     C                   goto      endup1
     C                   endif

     *  If route is not at open status then skip to displaying detail.
640nA*  Now we always want to continue because the order may have changed.

     C                   if        rhstat <> '1'
     C                   unlock    rtehed
640nDC**                 goto      skipcrtlbl
     C                   endif

     *  Otherwise ...
640nD
640nD **    Create label records for order.
640nD **    (LABEL records now created during import)
640nD **
640nDC**                 eval      woinf1 = '   Getting Item'
640nDC**                 eval      woinf2 = '    Pick Slots'
640nDC**                 write     screen61
640nDC**                 eval      woinf1 = ' '
640nDC**                 eval      woinf2 = ' '
640nD **
640nDC**                 call      'OR203'
640nDC**                 parm      $ohwhse       $pwhse
640nDC**                 parm      $ohoid        $poid
640nDC**                 parm                    $ptrn#
640nDC**                 parm                    $pbat
640nDC**                 parm                    $lrtn

640nA*     Create ORDDSOS records for order.
640nA
640nAC                   call      'OR204'
640nAC                   parm      $ohwhse       $pwhseS
640nAC                   parm      $ohrid        $prtid
640nAC                   parm      $ohoid        $poid
640nAC                   parm                    $lrtn

     *     Change status of route to Printed.

640nAC                   if        rhstat <> '4'
     C                   exsr      getdatetime
     C                   eval      rhstat = '4'
     C                   eval      rhstsd = curdate
     C                   eval      rhstst = curtime
     C                   eval      rhprtd = curdate
     C                   eval      rhprtt = curtime
     C                   eval      rhpbat = $pbat
     C                   update    rhrec
640nAC                   endif

     *  Let's get picking ...

     C     skipcrtlbl    tag
416dD **
416dD** Initialize pallet record to be created.
416dD **
416dDC**   keyps2        setgt     pltsum2
416dDC**   keyps2        readpe    pltsum2
416dDC**                 if        %eof
416dDC**                 eval      psrow = 0
416dDC**                 endif
416dDC**
416dDC**                 eval      pswhse = rhwhse
416dDC**                 eval      psrtid = rhrtid
416dDC**                 eval      pscomp = ' '
416dDC**                 eval      pstzon = ' '
416dDC**                 eval      pspzon = ' '
416dDC**                 eval      psszon = ' '
416dDC**                 eval      psgen  = 1
416dDC**                 eval      pstruk = ' '
416dDC**                 eval      psunld = 0
416dDC**                 eval      psrow = psrow + 1
416dDC**                 eval      pscol  = 1
416dDC**                 eval      psmaxc = 0
416dDC**                 eval      pspcs  = 0
416dDC**                 eval      pscube = 0
416dDC**                 eval      psswgt = 0
416dDC**                 eval      psstp1 = 0
416dDC**                 eval      psstp2 = 0
416dDC**                 eval      pstype = 'O'
416dDC**                 eval      psbcnt = 0
416dDC**                 eval      psflag = ' '
416dDC**                 eval      pslbl# = 0
416dDC**                 eval      pstrn# = 0
416dDC**
416dDC**                 eval      dsplxx = 0
416dDC**                 eval      dsplgn = psgen
416dDC**                 eval      dsplrw = psrow
416dDC**                 eval      dsplcl = pscol
416dDC**                 eval      dsplsq = 0
416dDC**
416dDC**                 eval      psplid = dsplid

     *  Initialize counts.

     C                   eval      totalpcs  = 0
     C                   eval      totalcube = 0
     C                   eval      totalswgt = 0

     C                   eval      pickcount = 0
500d C                   eval      pliccount = 0
500d C                   eval      stagcount = 0
416dD **
416dD** Display list of order detail lines.
416dD **
416dDC**                 exsr      zzlist

     *  Get initial pallet number.

 1B  C                   eval      refrsh = *on
     C                   exsr      scr08i

     C     endup1        endsr

     *----------------------------------------------------------------
     *  ZZUPD2   Update for screen 2.
     *----------------------------------------------------------------

     C     zzupd2        begsr
     C                   eval      error = *off
640bA
640bA*    Call program that will (if necessary) ...
640bA*      - Have user verify license being pulled.
640bA
640bAC                   exsr      zzzclr$lt210
640bAC                   eval      $tcmd  = '*PULDROP'
640bAC                   eval      $twhse = lbwhse
640bAC                   eval      $twhdp = lbwhdp
640bAC                   eval      $tslot = wodisp
640bAC                   eval      $titem = lbitem
640bAC                   eval      $titemdsc = $itdesc
640bAC                   eval      $tlic# = curlic#
640bAC                   exsr      zzzcall$lt210
640bA
640bAC                   if        $treturn = '*CANCEL'
640bAC                   eval      error = *on
640bAC                   leavesr
640bAC                   endif
640bA
640bAC                   if        $treturn = '*NOTFND'
640bA
640bAC                   exsr      zzzclr$lt210
640bAC                   eval      $tcmd   = '*PULRTN'
640bAC                   eval      $twhse  = lbwhse
640bAC                   eval      $twhdp  = lbwhdp
640bAC                   eval      $tslot  = lbdisp
640bAC                   eval      $titem  = lbitem
640bAC                   eval      $titemdsc = $itdesc
640bAC                   eval      $tlic# = curlic#
640bAC                   exsr      zzzcall$lt210
640bA
640bAC                   eval      error = *on
640bAC                   leavesr
640bAC                   endif

640hA*  Display screen for UPC code.
640hAC                   eval      refrsh = *on
640hAC                   exsr      scr10i
640hA*  Code below moved to ZZUPD10.
     *  Now either get the quantity picked or the catchweights.

640hDC**                 eval      refrsh = *on
640hDC**                 if        $itcwgt = 'Y'
640hDC**                 eval      woqty = lbqalc
416hDC*                  eval      wopck = lbqpck
640hDC**                 eval      wopck = picked
640hDC**                 eval      woum  = lbucod
640hDC**                 eval      w4cnt  = 1
640hDC**                 eval      w4qty = lbqalc - lbqpck
640hDC**                 exsr      scr04i
640hDC**                 else
640hDC**                 exsr      scr03i
640hDC**                 endif

     C     endup2        endsr

     *----------------------------------------------------------------
     *  ZZUPD3   Update for screen 3.
     *----------------------------------------------------------------

     C     zzupd3        begsr
     C                   eval      error = *off
640pA
640pA*  Get/Lock Label record.
640pA
640pAC                   eval      lock = *on
640rAC                   eval      $llbl# = lblbl#
640pAC                   exsr      zzlbl#
640pAC                   if        error
640pAC                   leavesr
640wAC                   else
640wAC                   if        lbqpck <> 0
640wAC                   eval      lbvrfy = ' '
640wAC                   update    lbrec
640wAC                   endif
640pAC                   endif
640bA
640bA*  License plate tracking item. Update to show in transit.
640bA
640bAC                   exsr      zzzclr$lt210
640bAC                   eval      $tcmd     = '*PULTRAN'
640bAC                   eval      $tlic#    = curlic#
640bAC                   eval      $tnewlic# = curlic#
640bAC                   eval      $twhse    = lbwhse
640bAC                   eval      $titem    = lbitem
640bAC                   eval      $titemdsc = #fromithead
640bAC                   eval      $tpartial = partial
640bAC                   eval      $tqty1    = 0
640bAC                   eval      $tqty2    = 0
640bAC                   eval      $tqty3    = 0
640bAC                   select
640bAC                   when      lbutyp = 'N'
640bAC                   eval      $tqty1 = w3qty
640bAC                   when      lbutyp = '1'
640bAC                   eval      $tqty2 = w3qty
640bAC                   when      lbutyp = '2'
640bAC                   eval      $tqty3 = w3qty
640bAC                   endsl
640bAC                   eval      $tnorm1   = $tqty1
640bAC                   eval      $tnorm2   = $tqty2
640bAC                   eval      $tnorm3   = $tqty3
640bAC                   exsr      zzzcall$lt210
640bA
640bAC                   if        $treturn <> '*OK'
640bAC                   endif
640bA
640bAC                   eval      curlic# = $tinlic#

     *  Update slot picked quantity.

640cAC                   if        $slpick = 'Y'
640cAC                   eval      pickSlot = *on
640cAC                   else
640cAC                   eval      pickSlot = *off
640cAC                   endif

640bAC                   exsr      clr$slot
640bDC**                 eval      savever# = $slver#
640bDC**                 clear                   $slot
640bDC**                 eval      $slver# = savever#

     C                   eval      $dricommand = '*SLOT'
640bDC**                 eval      $drisubcmd  = '%PICK'
640cAC                   if        pickSlot
640cMC                   eval      $drisubcmd  = '%TFR2USRN'
640cMC                   else
640bMC                   eval      $drisubcmd  = '%TFR2USR'
640cMC                   endif

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse = lbwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp = lbwhdp
     C                   eval      $sldispu = *on
416aDC**                 eval      $sldisp = lbdisp
416aMC                   eval      $sldisp = wodisp
     C                   eval      $saitemu = *on
     C                   eval      $saitem = lbitem
     C                   eval      $saqtyu = *on
     C                   select
     C                   when      lbutyp = 'N'
     C                   eval      $saqty1 = w3qty
     C                   when      lbutyp = '1'
     C                   eval      $saqty2 = w3qty
     C                   when      lbutyp = '2'
     C                   eval      $saqty3 = w3qty
     C                   endsl

640bAC                   eval      $satasku = *on
640bMC                   eval      $satask  = 'TFRMOV'
640bA
640bAC                   eval      $saActionU = *on
640bAC                   eval      $saAction = 'SOS'
640bAC                   eval      $saTrn#U = *on
640bAC                   eval      $saTrn# = lbtrn#
640bAC                   eval      $saETrn#U = *on
640bAC                   eval      $saETrn# = 0
640bAC                   eval      $saLbl#U = *on
640bAC                   eval      $saLbl# = lblbl#
640bAC                   eval      $saToLcnsU = *on
640bAC****               eval      $saToLcns = '*MULTIPLE'
640bAC                   eval      $saToLcns = $tinlic#
640bAC                   eval      $saToPosU = *on
640bAC                   eval      $saToPos = $tslotpos
640bAC                   eval      $saToVrfyU = *on
640bAC                   eval      $saToVrfy = 'N'
640bAC                   eval      $saToCodeu = *on
640bAC                   eval      $saToCode = 'U'
640bAC                   eval      $saToAreaU = *on
640bAC                   eval      $saToArea = 'User'
640bAC                   eval      $saFrmLcnsU = *on
640bAC                   eval      $saFrmLcns = $toutlic#
640bAC**                 eval      $saOLcnsU = *on
640bAC**                 eval      $saOLcns = wuPulolcns

     C                   exsr      zzzdricop

640cAC                   if        error
640pAC                   unlock    label
640cAC                   leavesr
640cAC                   endif

640bAC                   eval      curlic# = $saToLcns
640bAC                   eval      $tinlic# = $saToLcns

     *  Update label record.

416cDC**                 eval      lbqpck = lbqpck + w3qty
     C                   eval      lbpal# = psplid
416cAC                   eval      lbdisp = $sldisp
416cAC                   eval      lbwhdp = $slwhdp
416cAC                   eval      lbaisl = $slaisl
416cAC                   eval      lbloc  = $slloc
416cAC                   eval      lbrlvl = $slrlvl
416cAC                   eval      lbhand = $slhand
640wA*    Update lbvrfy (I=in use) back to a blank.
640wAC                   eval      lbvrfy = ' '
416cA
416cA*    If nothing was previously picked then update record.
416cA*    Otherwise, create new label record.
416cA
416cAC                   if        lbqpck = 0
416cAC                   eval      lbqpck = lbqpck + w3qty
416mA*    Update status date/time to reflect qty update.
416mAC                   eval      $cvcmd = '*CURCMD '
416mAC                   exsr      zzcvdt
416mAC                   eval      lbsdte = $CVD8O
416mAC                   time                    lbstim
416mA*
     C                   update    lbrec
640pDC**                 unlock    label
500aAC                   exsr      zzwsos
416cAC                   else
416cAC                   unlock    label
416cAC                   call      'PIRLBL#'
416cAC                   parm                    lblbl#
416cAC                   eval      lbqpck = w3qty
416mA*    Update status date/time to reflect qty update.
416mAC                   eval      $cvcmd = '*CURCMD '
416mAC                   exsr      zzcvdt
416mAC                   eval      lbsdte = $CVD8O
416mAC                   time                    lbstim
416mA*
416cAC                   write     lbrec
500aAC                   exsr      zzwsos
416cAC                   endif

     *  Write license to ORDL file.

     C                   if        licpick and w2lic <> ' '
     C                   eval      olwhse = lbwhse
     C                   eval      olord  = lbord
     C                   eval      olseq# = lbseq
     C                   eval      olitem = lbitem
     C                   eval      oltran = lbtrn#
     C                   eval      ollbl# = lblbl#
     C                   eval      ollic# = w2lic
     C                   write     olrec
     C                   endif

     *  Update pallet counts.

     C                   eval      totalpcs  = totalpcs + w3qty
     C                   eval      totalcube = totalcube + (w3qty * lbucub)
     C                   eval      totalswgt = totalswgt + (w3qty * lbuwgt)
416dA
416dA*  Update pallet summary record.
416dA
416dAC     keyps2f       chain     pltsum2
416dAC                   if        %found
416dAC                   eval      pspcs  = pspcs + w3qty
416dAC                   eval      pscube = pscube + (w3qty * lbucub)
416dAC                   eval      psswgt = psswgt + (w3qty * lbuwgt)
416dAC                   eval      pstrn# = lbtrn#
416dAC                   update    psrec
640gAC                   else
640gAC                   eval      psszon = *blanks
416dAC                   endif

640gA*  Write LABELDO and EPMSUMO record.
640gA
640gAC                   exsr      wrtLABELDO

     *  Increment pick count.

     C                   eval      pickcount = pickcount + 1

     *  Display "next step" screen.

 1B  C                   eval      refrsh = *on
     C                   exsr      scr05i

     C     endup3        endsr

     *----------------------------------------------------------------
     *  ZZUPD4   Update for screen 4.
     *----------------------------------------------------------------

     C     zzupd4        begsr
     C                   eval      error = *off

     *  Determine what to do next.

     C                   select

     *    Get the next catchweight ...

     C                   when      w4cnt < w4qty and w4cnt < #cwmax
     C                   eval      w4cnt  = w4cnt + 1
 1B  C                   eval      refrsh = *on
     C                   exsr      scr04i

     *    Update order and move on to "next step" screen.


     C                   other
640pA
640pA*     Get/Lock Label record.
640pA
640pAC                   eval      lock = *on
640rAC                   eval      $llbl# = lblbl#
640pAC                   exsr      zzlbl#
640pAC                   if        error
640pAC                   leavesr
640pAC                   endif
640bA
640bA*     License plate tracking item. Update to show in transit.
640bA
640bAC                   exsr      zzzclr$lt210
640bAC                   eval      $tcmd     = '*PULTRAN'
640bAC                   eval      $tlic#    = curlic#
640bAC                   eval      $tnewlic# = curlic#
640bAC                   eval      $twhse    = lbwhse
640bAC                   eval      $titem    = lbitem
640bAC                   eval      $titemdsc = #fromithead
640bA*     For now, just assume qty is a partial slot qty because qty
640bA*     checks are not done like they are for non-catchweight items.
640bAC                   eval      $tpartial = *on
640bAC                   eval      $tqty1    = 0
640bAC                   eval      $tqty2    = 0
640bAC                   eval      $tqty3    = 0
640bAC                   select
640bAC                   when      lbutyp = 'N'
640bAC                   eval      $tqty1 = w4cnt
640bAC                   when      lbutyp = '1'
640bAC                   eval      $tqty2 = w4cnt
640bAC                   when      lbutyp = '2'
640bAC                   eval      $tqty3 = w4cnt
640bAC                   endsl
640bAC                   eval      $tnorm1   = $tqty1
640bAC                   eval      $tnorm2   = $tqty2
640bAC                   eval      $tnorm3   = $tqty3
640bAC                   exsr      zzzcall$lt210
640bA
640bAC                   if        $treturn <> '*OK'
640bAC                   endif
640bA
640bAC                   eval      curlic# = $tinlic#

     *  Update slot picked quantity.

640cAC                   if        $slpick = 'Y'
640cAC                   eval      pickSlot = *on
640cAC                   else
640cAC                   eval      pickSlot = *off
640cAC                   endif

640bAC                   exsr      clr$slot
640bDC**                 eval      savever# = $slver#
640bDC**                 clear                   $slot
640bDC**                 eval      $slver# = savever#

     C                   eval      $dricommand = '*SLOT'
640bDC**                 eval      $drisubcmd  = '%PICK'
640cAC                   if        pickSlot
640cMC                   eval      $drisubcmd  = '%TFR2USRN'
640cMC                   else
640bMC                   eval      $drisubcmd  = '%TFR2USR'
640cMC                   endif

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse = lbwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp = lbwhdp
     C                   eval      $sldispu = *on
416aDC**                 eval      $sldisp = lbdisp
416aMC                   eval      $sldisp = wodisp
     C                   eval      $saitemu = *on
     C                   eval      $saitem = lbitem
     C                   eval      $saqtyu = *on
     C                   select
     C                   when      lbutyp = 'N'
     C                   eval      $saqty1 = w4cnt
     C                   when      lbutyp = '1'
     C                   eval      $saqty2 = w4cnt
     C                   when      lbutyp = '2'
     C                   eval      $saqty3 = w4cnt
     C                   endsl

640bAC                   eval      $satasku = *on
640bMC                   eval      $satask  = 'TFRMOV'
640bA
640bAC                   eval      $saActionU = *on
640bAC                   eval      $saAction = 'SOS'
640bAC                   eval      $saTrn#U = *on
640bAC                   eval      $saTrn# = lbtrn#
640bAC                   eval      $saETrn#U = *on
640bAC                   eval      $saETrn# = 0
640bAC                   eval      $saLbl#U = *on
640bAC                   eval      $saLbl# = lblbl#
640eMC                   eval      $saToLcnsU = *on
640eMC                   eval      $saToLcns = $tinlic#
640eMC                   eval      $saToPosU = *on
640eMC                   eval      $saToPos = $tslotpos
640bAC                   eval      $saToVrfyU = *on
640bAC                   eval      $saToVrfy = 'N'
640bAC                   eval      $saToCodeu = *on
640bAC                   eval      $saToCode = 'U'
640bAC                   eval      $saToAreaU = *on
640bAC                   eval      $saToArea = 'User'
640eMC                   eval      $saFrmLcnsU = *on
640eMC                   eval      $saFrmLcns = $toutlic#
640bAC**                 eval      $saOLcnsU = *on
640bAC**                 eval      $saOLcns = wuPulolcns

     C                   exsr      zzzdricop

640cAC                   if        error
640pAC                   unlock    label
640cAC                   leavesr
640cAC                   endif

640eAC                   eval      curlic# = $saToLcns
640eAC                   eval      $tinlic# = $saToLcns

     *      Update label record.

416cDC**                 eval      lbqpck = lbqpck + w4cnt
     C                   eval      lbpal# = psplid
416cAC                   eval      lbdisp = $sldisp
416cAC                   eval      lbwhdp = $slwhdp
416cAC                   eval      lbaisl = $slaisl
416cAC                   eval      lbloc  = $slloc
416cAC                   eval      lbrlvl = $slrlvl
416cAC                   eval      lbhand = $slhand
720 A*    Update lbvrfy (I=in use) back to a blank.
720 AC                   eval      lbvrfy = ' '
416cA
416cA*    If nothing was previously picked then update record.
416cA*    Otherwise, create new label record.
416cA
416cAC                   if        lbqpck = 0
416cAC                   eval      lbqpck = lbqpck + w4cnt
416mA*    Update status date/time to reflect qty update.
416mAC                   eval      $cvcmd = '*CURCMD '
416mAC                   exsr      zzcvdt
416mAC                   eval      lbsdte = $CVD8O
416mAC                   time                    lbstim
416mA*
     C                   update    lbrec
640pDC**                 unlock    label
500aAC                   exsr      zzwsos
416cAC                   else
416cAC                   unlock    label
416cAC                   call      'PIRLBL#'
416cAC                   parm                    lblbl#
416cAC                   eval      lbqpck = w4cnt
416mA*    Update status date/time to reflect qty update.
416mAC                   eval      $cvcmd = '*CURCMD '
416mAC                   exsr      zzcvdt
416mAC                   eval      lbsdte = $CVD8O
416mAC                   time                    lbstim
416mA*
416cAC                   write     lbrec
500aAC                   exsr      zzwsos
416cAC                   endif

     *      Write license to ORDL file.

     C                   if        licpick and w2lic <> ' '
     C                   eval      olwhse = lbwhse
     C                   eval      olord  = lbord
     C                   eval      olseq# = lbseq
     C                   eval      olitem = lbitem
     C                   eval      oltran = lbtrn#
     C                   eval      ollbl# = lblbl#
     C                   eval      ollic# = w2lic
     C                   write     olrec
     C                   endif

     *      Write catchweights to ORDC file.

     C     keyoc         setgt     ordc
     C     keyoc         readpe    ordc
     C                   if        %eof
     C                   eval      ocseq = 0
     C                   endif

     C                   eval      ocwhse = lbwhse
     C                   eval      ocord  = lbord
     C                   eval      ocseq# = lbseq
     C                   eval      ocitem = lbitem
     C                   eval      octran = lbtrn#
     C                   eval      oclbl# = lblbl#

     C                   do        w4cnt         i
     C     i             occur     #cwentries
     C                   eval      ocseq  = ocseq + 1
     C                   eval      occwgt = #cwweight
     C                   write     ocrec
650aAc                   eval      processstatus = '*ADD'
650aAc                   exsr      processCWLog
     C                   enddo

     *  Update pallet counts.

     C                   eval      totalpcs  = totalpcs + w4cnt
     C                   eval      totalcube = totalcube + (w4cnt * lbucub)
     C                   eval      totalswgt = totalswgt + (w4cnt * lbuwgt)
416dA
416dA*  Update pallet summary record.
416dA
416dAC     keyps2f       chain     pltsum2
416dAC                   if        %found
416dAC                   eval      pspcs  = pspcs + w4qty
416dAC                   eval      pscube = pscube + (w4qty * lbucub)
416dAC                   eval      psswgt = psswgt + (w4qty * lbuwgt)
416dAC                   eval      pstrn# = lbtrn#
416dAC                   update    psrec
640gAC                   else
640gAC                   eval      psszon = *blanks
416dAC                   endif

640gA*  Write LABELDO and EPMSUMO record.
640gA
640gAC                   exsr      wrtLABELDO


     *      Increment pick count.

     C                   eval      pickcount = pickcount + 1

     *      Display "next step" screen.

 1B  C                   eval      refrsh = *on
     C                   exsr      scr05i

     C                   endsl

     C     endup4        endsr

640iA*----------------------------------------------------------------
640iA*  ZZUPD4A  Update for screen 4A.
640iA*----------------------------------------------------------------
640iA
640iAC     zzupd4a       begsr
640iAC                   eval      error = *off
640pA
640pA*  Get/Lock Label record.
640pA
640pAC                   eval      lock = *on
640rAC                   eval      $llbl# = lblbl#
640pAC                   exsr      zzlbl#
640pAC                   if        error
640pAC                   leavesr
640pAC                   endif
640iA
640iA*  License plate tracking item. Update to show in transit.
640iA
640iAC                   exsr      zzzclr$lt210
640iAC                   eval      $tcmd     = '*PULTRAN'
640iAC                   eval      $tlic#    = curlic#
640iAC                   eval      $tnewlic# = curlic#
640iAC                   eval      $twhse    = lbwhse
640iAC                   eval      $titem    = lbitem
640iAC                   eval      $titemdsc = #fromithead
640iAC                   eval      $tpartial = partial
640iAC                   eval      $tqty1    = 0
640iAC                   eval      $tqty2    = 0
640iAC                   eval      $tqty3    = 0
640iAC                   select
640iAC                   when      lbutyp = 'N'
640iAC                   eval      $tqty1 = w4tqt
640iAC                   when      lbutyp = '1'
640iAC                   eval      $tqty2 = w4tqt
640iAC                   when      lbutyp = '2'
640iAC                   eval      $tqty3 = w4tqt
640iAC                   endsl
640iAC                   eval      $tnorm1   = $tqty1
640iAC                   eval      $tnorm2   = $tqty2
640iAC                   eval      $tnorm3   = $tqty3
640iAC                   exsr      zzzcall$lt210
640iA
640iAC                   if        $treturn <> '*OK'
640iAC                   endif
640iA
640iAC                   eval      curlic# = $tinlic#
640iA
640iA*  Update slot picked quantity.
640iA
640iAC                   if        $slpick = 'Y'
640iAC                   eval      pickSlot = *on
640iAC                   else
640iAC                   eval      pickSlot = *off
640iAC                   endif

640iAC                   exsr      clr$slot

640iAC                   eval      $dricommand = '*SLOT'
640iAC                   if        pickSlot
640iAC                   eval      $drisubcmd  = '%TFR2USRN'
640iAC                   else
640iAC                   eval      $drisubcmd  = '%TFR2USR'
640iAC                   endif

640i C                   eval      $slwhseu = *on
640i C                   eval      $slwhse = lbwhse
640i C                   eval      $slwhdpu = *on
640i C                   eval      $slwhdp = lbwhdp
640i C                   eval      $sldispu = *on
640i C                   eval      $sldisp = wodisp
640iAC                   eval      $saitemu = *on
640iAC                   eval      $saitem = lbitem
640iAC                   eval      $saqtyu = *on
640iAC                   select
640iAC                   when      lbutyp = 'N'
640iAC                   eval      $saqty1 = w4tqt
640iAC                   when      lbutyp = '1'
640iAC                   eval      $saqty2 = w4tqt
640iAC                   when      lbutyp = '2'
640iAC                   eval      $saqty3 = w4tqt
640iAC                   endsl
640iA
640iAC                   eval      $satasku = *on
640iAC                   eval      $satask  = 'TFRMOV'
640iA
640iAC                   eval      $saActionU = *on
640iAC                   eval      $saAction = 'SOS'
640iAC                   eval      $saTrn#U = *on
640iAC                   eval      $saTrn# = lbtrn#
640iAC                   eval      $saETrn#U = *on
640iAC                   eval      $saETrn# = 0
640iAC                   eval      $saLbl#U = *on
640iAC                   eval      $saLbl# = lblbl#
640iAC                   eval      $saToLcnsU = *on
640bAC****               eval      $saToLcns = '*MULTIPLE'
640iAC                   eval      $saToLcns = $tinlic#
640iAC                   eval      $saToPosU = *on
640iAC                   eval      $saToPos = $tslotpos
640iAC                   eval      $saToVrfyU = *on
640iAC                   eval      $saToVrfy = 'N'
640iAC                   eval      $saToCodeu = *on
640iAC                   eval      $saToCode = 'U'
640iAC                   eval      $saToAreaU = *on
640iAC                   eval      $saToArea = 'User'
640iAC                   eval      $saFrmLcnsU = *on
640iAC                   eval      $saFrmLcns = $toutlic#
640iAC**                 eval      $saOLcnsU = *on
640iAC**                 eval      $saOLcns = wuPulolcns

640iAC                   exsr      zzzdricop

640iAC                   if        error
640pAC                   unlock    label
640iAC                   leavesr
640iAC                   endif

640iAC                   eval      curlic# = $saToLcns
640iAC                   eval      $tinlic# = $saToLcns

640iA*  Update label record.
640iA
640iAC                   eval      lbpal# = psplid
640iAC                   eval      lbdisp = $sldisp
640iAC                   eval      lbwhdp = $slwhdp
640iAC                   eval      lbaisl = $slaisl
640iAC                   eval      lbloc  = $slloc
640iAC                   eval      lbrlvl = $slrlvl
640iAC                   eval      lbhand = $slhand
720 A*    Update lbvrfy (I=in use) back to a blank.
720 AC                   eval      lbvrfy = ' '
640iA
640iA*    If nothing was previously picked then update record.
640iA*    Otherwise, create new label record.
640iA
640iAC                   if        lbqpck = 0
640iAC                   eval      lbqpck = lbqpck + w4tqt
640iA*    Update status date/time to reflect qty update.
640iAC                   eval      $cvcmd = '*CURCMD '
640iAC                   exsr      zzcvdt
640iAC                   eval      lbsdte = $CVD8O
640iAC                   time                    lbstim
640iA*
640iAC                   update    lbrec
640pDC**                 unlock    label
640iAC                   exsr      zzwsos
640iAC                   else
640iAC                   unlock    label
640iAC                   call      'PIRLBL#'
640iAC                   parm                    lblbl#
640iAC                   eval      lbqpck = w4tqt
640iA*    Update status date/time to reflect qty update.
640iAC                   eval      $cvcmd = '*CURCMD '
640iAC                   exsr      zzcvdt
640iAC                   eval      lbsdte = $CVD8O
640iAC                   time                    lbstim
640iA*
640iAC                   write     lbrec
640iAC                   exsr      zzwsos
640iAC                   endif
640iA
640iA*  Write license to ORDL file.
640iA
640iAC                   if        licpick and w2lic <> ' '
640iAC                   eval      olwhse = lbwhse
640iAC                   eval      olord  = lbord
640iAC                   eval      olseq# = lbseq
640iAC                   eval      olitem = lbitem
640iAC                   eval      oltran = lbtrn#
640iAC                   eval      ollbl# = lblbl#
640iAC                   eval      ollic# = w2lic
640iAC                   write     olrec
640iAC                   endif
640iA
640iA*      Write catchweights to ORDC file.
640iA
640iAC     keyoc         setgt     ordc
640iAC     keyoc         readpe    ordc
640iAC                   if        %eof
640iAC                   eval      ocseq = 0
640iAC                   endif
640iA
640iAC                   eval      ocwhse = lbwhse
640iAC                   eval      ocord  = lbord
640iAC                   eval      ocseq# = lbseq
640iAC                   eval      ocitem = lbitem
640iAC                   eval      octran = lbtrn#
640iAC                   eval      oclbl# = lblbl#
640iA
640iAC**                 do        w4cnt         i
640iAC**   i             occur     #cwentries
640iAC                   eval      ocseq  = ocseq + 1
640iAC                   eval      occwgt = w4cwt
640iAC                   write     ocrec
650aAc                   eval      processstatus = '*ADD'
650aAc                   exsr      processCWLog
640iAC**                 enddo
640iA
640iA
640iA*  Update pallet counts.
640iA
640iAC                   eval      totalpcs  = totalpcs + w4tqt
640iAC                   eval      totalcube = totalcube + (w4tqt * lbucub)
640iAC                   eval      totalswgt = totalswgt + (w4tqt * lbuwgt)
640iA
640iA*  Update pallet summary record.
640iA
640iAC     keyps2f       chain     pltsum2
640iAC                   if        %found
640iAC                   eval      pspcs  = pspcs + w4tqt
640iAC                   eval      pscube = pscube + (w4tqt * lbucub)
640iAC                   eval      psswgt = psswgt + (w4tqt * lbuwgt)
640iAC                   eval      pstrn# = lbtrn#
640iAC                   update    psrec
640iAC                   else
640iAC                   eval      psszon = *blanks
640iAC                   endif

640iA*  Write LABELDO and EPMSUMO record.
640iA
640iAC                   exsr      wrtLABELDO

640iA*  Increment pick count.
640iA
640iAC                   eval      pickcount = pickcount + 1
640iA
640iA*  Display "next step" screen.
640iA
640iAC                   eval      refrsh = *on
640iAC                   exsr      scr05i
640iA
640iAC     endup4a       endsr
640iA
     *----------------------------------------------------------------
     *  ZZUPD5   Update for screen 5.
     *----------------------------------------------------------------

     C     zzupd5        begsr
     C                   eval      error = *off

     *  Display list of order detail lines.

     C                   exsr      zzlist

     C     endup5        endsr

     *----------------------------------------------------------------
     *  ZZUPD6   Update for screen 6.
     *----------------------------------------------------------------

     C     zzupd6        begsr
     C                   eval      error = *off
416dD **
416dD** Create pallet record (fields initialized in ZZUPD1)
416dD **
416dDC**                 eval      pspcs  = totalpcs
416dDC**                 eval      pscube = totalcube
416dDC**                 eval      psswgt = totalswgt
416dDC**                 eval      pstrn# = lbtrn#
416dDC**                 eval      pspal# = w6lic
416dDC**                 write     psrec

500a *  Update slot and label for staged product.
500a C     w6stag        ifne      *blanks
500aAC     wskey         setll     worksos
500aAC                   dow       forevr = forevr
500aAC     wskey         reade     worksos                                79
500aAC                   select
500aAC                   when      *in79
500aAC                   leave
416dAC                   other
640pDC**   wkslbl        chain     label                                78
640pA
640pA*    Get/Lock Label record.
640pA
640pAC                   eval      lock = *on
640pAC                   eval      $llbl# = wkslbl
640pAC                   exsr      zzlbl#
640pAC                   if        error
640pAC                   leavesr
640pAC                   endif
640pA
500a *  Remove qty from pick and stock of original slot.
500a *  pick qty was created using actual pick qty, not ordered qty.
640bDC**                 eval      savever# = $slver#
640bDC**                 clear                   $slot
640bDC**                 eval      $slver# = savever#
640bDC**                 eval      $dricommand = '*SLOT'
640bDC**                 eval      $drisubcmd  = '%CLSPICK'
640bDC**
640bDC**                 eval      $slwhseu = *on
640bDC**                 eval      $slwhse = lbwhse
640bDC**                 eval      $slwhdpu = *on
640bDC**                 eval      $slwhdp = lbwhdp
640bDC**                 eval      $sldispu = *on
640bDC**                 eval      $sldisp = lbdisp
640bDC**                 eval      $saitemu = *on
640bDC**                 eval      $saitem = lbitem
640bDC**                 eval      $saqtyu = *on
500fDC**                 eval      $saqty1 = wkspck
500a C*                  eval      $saqty1 = w3qty
640bDC**                 select
640bDC**                 when      lbutyp = 'N'
500a C*                  eval      $saqty1 = lbqpck
640bDC**                 eval      $saqty1 = wkspck
500a C*                  eval      $saorg1 = lbqalc
640bDC**                 eval      $saorg1 = wkspck
640bDC**                 when      lbutyp = '1'
640bDC**                 eval      $saqty2 = wkspck
640bDC**                 eval      $saorg2 = wkspck
640bDC**                 when      lbutyp = '2'
640bDC**                 eval      $saqty3 = wkspck
640bDC**                 eval      $saorg3 = wkspck
640bDC**                 endsl
640bDC**                 exsr      zzzdricop
640eA
640eA*  Get USR slot info
640eA
640eAC                   exsr      clr$slot
640eA
640eAC                   eval      $dricommand = '*SLOT'
640eAC                   eval      $drisubcmd  = '%GET'
640eA
640eAC                   eval      $slwhseu = *on
640eAC                   eval      $slwhse = lbwhse
640eAC                   eval      $slwhdpu = *on
640eAC                   eval      $slwhdp = lbwhdp
640eAC                   eval      $sldispu = *on
640eAC                   eval      $sldisp = lbdisp
640eAC                   exsr      zzzdricop
640eAC                   eval      $tinlic# = $saToLcns
640eAC                   eval      $toutlic# = $saToLcns
640eAC                   eval      $tslotpos = $saToPos
640eAC                   eval      origLcns = $saOLcns
500a
500a *  Update holding slot with stock quantity.
640bA
640bA*    Note: We are not calling LT210 for the putaway because we do not
640bA*    want to ask the user for a new license plate.
640bA
640bAC                   exsr      clr$slot
500a C                   eval      $dricommand = '*SLOT'
640bMC                   eval      $drisubcmd  = '%USR2PUT'
640bDC**                 eval      $drisubcmd  = '%STAGEPUT'
500cDC*                  eval      $drisubcmd  = '%PUTAWAY'
500a
500a C                   eval      $slwhseu = *on
500a C                   eval      $slwhse = lbwhse
500a C                   eval      $slwhdpu = *on
500a C                   eval      $slwhdp = lbwhdp
500a C                   eval      $sldispu = *on
500a C                   eval      $sldisp = w6stag
500a C                   eval      $saitemu = *on
500a C                   eval      $saitem = lbitem
500a C                   eval      $saqtyu = *on
500a C                   select
500a C                   when      lbutyp = 'N'
500a C                   eval      $saqty1 = lbqpck
500a C                   eval      $saorg1 = 0
500a C                   when      lbutyp = '1'
500a C                   eval      $saqty2 = lbqpck
500a C                   eval      $saorg2 = 0
500a C                   when      lbutyp = '2'
500a C                   eval      $saqty3 = lbqpck
500a C                   eval      $saorg3 = 0
500a C                   endsl

640bAC*                  eval      $slentdu  = *on
640bAC*                  eval      $slentd   = #fromslentd
640bAC*                  eval      $slexpdu  = *on
640bAC*                  eval      $slexpd   = #fromslexpd
640bAC*                  eval      $sacitemu = *on
640bAC*                  eval      $sacitem  = #fromslitem
640bAC                   eval      $sacwhdu = *on
640bAC                   eval      $sacwhd  = lbwhdp
640bAC                   eval      $sacdspu  = *on
640bAC                   eval      $sacdsp   = lbdisp
640bA
640bAC                   eval      $saActionU = *on
640bAC                   eval      $saAction = 'SOS'
640bAC                   eval      $saTrn#U = *on
640bAC                   eval      $saTrn# = lbtrn#
640bAC                   eval      $saETrn#U = *on
640bAC                   eval      $saETrn# = 0
640bAC                   eval      $saLbl#U = *on
640bAC                   eval      $saLbl# = lblbl#
640bAC                   eval      $saToLcnsU = *on
640bAC                   eval      $saToLcns = $tinlic#
640bAC                   eval      $saToPosU = *on
640bAC                   eval      $saToPos = 0
640bAC                   eval      $saToPos = $tslotpos
640bAC                   eval      $saToVrfyU = *on
640bAC                   eval      $saToVrfy = 'N'
640bAC                   eval      $saToCodeu = *on
640bAC                   eval      $saToCode = 'S'
640bAC                   eval      $saToAreaU = *on
640bAC                   eval      $saToArea = 'Slot'
640bAC                   eval      $saFrmLcnsU = *on
640bAC                   eval      $saFrmLcns = $toutlic#
640eAC                   eval      $saOLcnsU = *on
640eAC                   eval      $saOLcns = origLcns
640bA
640bAC*                  eval      $sapullwhdpu = *on
640bAC*                  eval      $sapullwhdp  = wuPulWhdp
640bAC*                  eval      $sapulldispu = *on
640bAC*                  eval      $sapulldisp  = wuPulDisp
640bAC*                  eval      $sapullbaseu = *on
640bAC*                  eval      $sapullbase  = wuPulBase
640bAC*                  eval      $sapulllcnsu = *on
640bAC*                  eval      $sapulllcns  = wuPulLcns

500a C                   exsr      zzzdricop
500a C
640oAC                   if        error = *on
640pAC                   unlock    label
640oAC                   leavesr
640oAC                   endif
640oA
640bDC**                 eval      $dricommand = '*SLOT'
640bDC**                 eval      $drisubcmd  = '%CLSSTGPUT'
500cDC*                  eval      $drisubcmd  = '%CLSPUTAWY'
640bDC**
640bDC**                 eval      $slwhseu = *on
640bDC**                 eval      $slwhse = lbwhse
640bDC**                 eval      $slwhdpu = *on
640bDC**                 eval      $slwhdp = lbwhdp
640bDC**                 eval      $sldispu = *on
500a C***                eval      $sldisp = w6stag
640bDC**                 eval      $saitemu = *on
640bDC**                 eval      $saitem = lbitem
640bDC**                 eval      $saqtyu = *on
640bDC**                 select
640bDC**                 when      lbutyp = 'N'
640bDC**                 eval      $saqty1 = lbqpck
640bDC**                 eval      $saorg1 = lbqpck
640bDC**                 when      lbutyp = '1'
640bDC**                 eval      $saqty2 = lbqpck
640bDC**                 eval      $saorg2 = lbqpck
640bDC**                 when      lbutyp = '2'
640bDC**                 eval      $saqty3 = lbqpck
640bDC**                 eval      $saorg3 = lbqpck
640bDC**                 endsl
640bDC**                 exsr      zzzdricop
500a
500a *  Update holding slot with pick quantity.
640bAC***********        exsr      clr$slot
500a C                   eval      $dricommand = '*SLOT'
500a C                   eval      $drisubcmd  = '%PICK'
500a
500a C                   eval      $slwhseu = *on
500a C                   eval      $slwhse = lbwhse
500a C                   eval      $slwhdpu = *on
500a C                   eval      $slwhdp = lbwhdp
500a C                   eval      $sldispu = *on
500a C***                eval      $sldisp = w6stag
500a C                   eval      $saitemu = *on
500a C                   eval      $saitem = lbitem
500a C                   eval      $saqtyu = *on
500a C                   select
500a C                   when      lbutyp = 'N'
500a C                   eval      $saqty1 = lbqpck
500a C                   eval      $saorg1 = 0
500a C                   when      lbutyp = '1'
500a C                   eval      $saqty2 = lbqpck
500a C                   eval      $saorg2 = 0
500a C                   when      lbutyp = '2'
500a C                   eval      $saqty3 = lbqpck
500a C                   eval      $saorg3 = 0
500a C                   endsl
500a C                   exsr      zzzdricop
500a
500a *  Update label record with holding slot.
500a C***  $llbl#        chain     label                                78
500aAC                   eval      lbdisp = $sldisp
500aAC                   eval      lbaisl = $slaisl
500aAC                   eval      lbloc  = $slloc
500aAC                   eval      lbrlvl = $slrlvl
500aAC                   eval      lbhand = $slhand
500aA
500aA*    Update status date/time to reflect qty update.
500aAC                   time                    lbstim
500aA*
500a C                   update    lbrec
640pDC**                 unlock    label
     *  Remove work record from WORKSOS.
500a C                   delete    wksrec
500aAC                   endsl
500aAC                   enddo
500a
500d C                   eval      stagcount = stagcount + 1
500a C                   endif


     *  Start all over at the beginning.
     *  Re-dsiplay screen 6 if staging until all pallet license are staged

500d C     w6stag        ifne      *blanks
500d C     stagcount     andlt     pliccount
500d C                   eval      refrsh = *on
500d C                   exsr      scr06i
500d C                   else
 1B  C                   eval      refrsh = *on
     C                   exsr      scr01i
500d C                   endif
     C     endup6        endsr

     *----------------------------------------------------------------
     *  ZZUPD7   Update for screen 7.
     *----------------------------------------------------------------

     C     zzupd7        begsr
     C                   eval      error = *off
     C     endup7        endsr

     *----------------------------------------------------------------
     *  ZZUPD8   Update for screen 8.
     *----------------------------------------------------------------

     C     zzupd8        begsr
     C                   eval      error = *off
500d C                   eval      kyplic = w8lic

     *  Create new pallet record.

     C     keyps2        setgt     pltsum2
416fDC**   keyps2        readpe    pltsum2
416fMC     keyps2        readpe(n) pltsum2
     C                   if        %eof
     C                   eval      psrow = 0
     C                   endif

     C                   eval      pswhse = rhwhse
     C                   eval      psrtid = rhrtid
     C                   eval      pscomp = ' '
     C                   eval      pstzon = ' '
     C                   eval      pspzon = ' '
     C                   eval      psszon = ' '
     C                   eval      psgen  = 1
     C                   eval      pstruk = ' '
     C                   eval      psunld = 0
     C                   eval      psrow = psrow + 1
     C                   eval      pscol  = 1
     C                   eval      psmaxc = 0
     C                   eval      pspcs  = 0
     C                   eval      pscube = 0
     C                   eval      psswgt = 0
     C                   eval      psstp1 = 0
     C                   eval      psstp2 = 0
     C                   eval      pstype = 'O'
     C                   eval      psbcnt = 0
     C                   eval      psflag = ' '
     C                   eval      pslbl# = 0
     C                   eval      pstrn# = 0
     C                   eval      pspal# = kyplic

     C                   eval      dsplxx = 0
     C                   eval      dsplgn = psgen
     C                   eval      dsplrw = psrow
     C                   eval      dsplcl = pscol
     C                   eval      dsplsq = 0

     C                   eval      psplid = dsplid

     C                   write     psrec
500d *  Increment Pallet license counter
500d C                   eval      pliccount = pliccount + 1

     *  Display list of order detail lines.

     C                   exsr      zzlist

     C     endup8        endsr

640hA*----------------------------------------------------------------
640hA*  ZZUPD10  Update for screen 10.
640hA*----------------------------------------------------------------

640hAC     zzupd10       begsr
     C                   eval      error = *off


     *  Now either get the quantity picked or the catchweights.

 1B  C                   eval      refrsh = *on
     C                   if        $itcwgt = 'Y'
     C                   eval      woqty = lbqalc
416hDC*                  eval      wopck = lbqpck
416hMC                   eval      wopck = picked
     C                   eval      woum  = lbucod
     C                   eval      w4cnt  = 1
     C                   eval      w4qty = lbqalc - lbqpck
     C                   exsr      scr04i
     C                   else
     C                   exsr      scr03i
     C                   endif

640hAC     endup10       endsr
640hA
500a *----------------------------------------------------------------
500a *  ZZSPUT   Verify putaway for stage product
500a *----------------------------------------------------------------
500a
500a C     zzsput        begsr
500a C                   eval      error = *off
500aAC     wskey         setll     worksos
500aAC                   dow       forevr = forevr
500aAC     wskey         reade     worksos                                79
500aAC                   select
500aAC                   when      *in79 = *on
500aAC                   leave
500aAC                   other
640mDC**   wkslbl        chain     label                                78
640mMC     wkslbl        chain(n)  label                                78
500aAC     *in78         ifeq      *on
500aAC                   leave
500aAC                   endif
500a *  Verify item/qty can be put into stage slot.
640bAC                   exsr      clr$slot
640bDC**                 eval      savever# = $slver#
640bDC**                 clear                   $slot
640bDC**                 eval      $slver# = savever#
500a C                   eval      $dricommand = '*SLOT'
500cMC                   eval      $drisubcmd  = '%VFYSTGPUT'
500cDC*                  eval      $drisubcmd  = '%VERIFYPUT'
500a
500a C                   eval      $slwhseu = *on
500a C                   eval      $slwhse = wkswhs
500a C                   eval      $slwhdpu = *on
500a C                   eval      $slwhdp = wkswhd
500a C                   eval      $sldispu = *on
500a C                   eval      $sldisp = w6stag
500a C                   eval      $saitemu = *on
500a C                   eval      $saitem = lbitem
500a C                   eval      $saqtyu = *on
500a C                   eval      $slpicke= '3'
500a C                   select
500a C                   when      lbutyp = 'N'
500a C                   eval      $saqty1 = wkspck
500a C                   eval      $saorg1 = 0
500a C                   when      lbutyp = '1'
500a C                   eval      $saqty2 = wkspck
500a C                   eval      $saorg2 = 0
500a C                   when      lbutyp = '2'
500a C                   eval      $saqty3 = wkspck
500a C                   eval      $saorg3 = 0
500a C                   endsl
500a C                   exsr      zzzdricop
500a C     error         ifeq      *on
500aAC                   leave
500aAC                   endif
500a
500aAC                   iter
500aAC                   endsl
500aAC                   enddo
500a C     endspt        endsr
500a
500a *----------------------------------------------------------------
500a *  ZZWHDP   Verify slot for each staged item department
500a *----------------------------------------------------------------
500a
500a C     zzwhdp        begsr
500a C                   eval      error = *off
500a C                   eval      svswhd = *blanks
500dDC*    wskey         setll     worksos1
500dMC     wskey1        setll     worksos1
500aAC                   dow       forevr = forevr
500aAC     wskey1        reade     worksos1                               79
500aAC                   select
500aAC                   when      *in79 = *on
500aAC                   leave
500aAC                   other
500aAC     svswhd        ifne      wkswhd
500aAC     slkey2        chain     slot2                              79
500aAC                   if        *in79 = *on
500a C                   eval      error = *on
500aAC                   leave
500aAC                   endif
500a C                   eval      svswhd = wkswhd
500aAC                   endif
500aAC                   iter
500aAC                   endsl
500aAC                   enddo
500a C     endwhd        endsr
500a *----------------------------------------------------------------
500a *  ZZWSOS   Update work file of selected items
500a *----------------------------------------------------------------
500a
500a C     zzwsos        begsr
500a C                   eval      error = *off
500a C                   eval      wkswhs = lbwhse
500a C                   eval      wksusr = #user
500a C                   eval      wkslbl = lblbl#
500a C                   eval      wkstyp = 'L'
500a C                   eval      wkstrn = lbtrn#
500a C                   eval      wkswhd = lbwhdp
500a C                   eval      wksasl = lbaisl
500a C                   eval      wksloc = lbloc
500a C                   eval      wkslvl = lbrlvl
500a C                   eval      wkshnd = lbhand
500a C                   eval      wksdsp = lbdisp
500a C                   eval      wkspck = lbqpck
500d C                   eval      wkspli = kyplic
500a C                   write     wksrec
500a C     endsos        endsr

640lA*----------------------------------------------------------------
640lA*                     DRI SUBROUTINES
640lA*----------------------------------------------------------------
640lA*----------------------------------------------------------------

640lA*----------------------------------------------------------------
640lA*  clr$license  Clear $license data structure fields
640lA*----------------------------------------------------------------
640lA
640lAC     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   eval      $liTowhse = w1whse
     C                   eval      $liTowhseu = *on
640lAC                   endsr
640lA
640bA*----------------------------------------------------------------
640bA*  clr$slot  Clear $slot data structure fields
640bA*----------------------------------------------------------------
640bA
640bAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = e$emp#
     C                   endsr
500a
     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   when      $dricommand = '*ORD'
     C                   eval      $dridata = $ordh
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
640aAC                   eval      $dridata2 = $slot2
640lAC                   when      $dricommand = '*LICENSE'
640lAC                   eval      $dridata = $license
640lAC                   eval      $dridata2 = $license2
     C                   endsl

640bAC                   if        $dricommand = '*SLOT'
640lAC                             or $dricommand = '*LICENSE'
640bAC                   call(e)   'DRICOP'
640bAC                   parm                    $dricommand
640bAC                   parm                    $drisubcmd
640bAC                   parm                    $drisys2upd
640bAC                   parm      #prog         $driprogram
640bAC                   parm      ' '           $drireturn
640bAC                   parm      ' '           $drimessage
640bAC                   parm                    $dridata
640bAC                   parm                    $dridata2
640bAC                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
640bAC                   endif

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   exsr      zm0105

416rAC                   when      $drireturn = 'EOF' and
416rAC                             $drisubcmd = '*NXTPICKAV'

640kAC                   when      $drireturn = 'EOF' and
640kAC                             $drisubcmd = '*NXTPICK  '

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   exsr      zm0001
     C                   exsr      zzzerrind

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   when      $dricommand = '*ORD'
     C                   eval      $ordh = $dridata
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
640aAC                   eval      $slot2 = $dridata2
640lAC                   when      $dricommand = '*LICENSE'
640lAC                   eval      $license = $dridata
640lAC                   eval      $license2 = $dridata2
     C                   endsl

     C     enddricop     endsr

     *----------------------------------------------------------------
     *  zzzerrind    Set error indicators from DRI call.
     *----------------------------------------------------------------

     C     zzzerrind     begsr

     C                   select

     *  Screen 1

     C                   when      nxtscr = '01'

     C                   if        $ohcorde = '1'
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   endif

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  getdatetime  Get current date & time
     *----------------------------------------------------------------

     C     getdatetime   begsr

     C                   time                    curtime

     C                   if        curtime < lasttime
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o
     C                   endif

     C                   eval      lasttime = curtime

     C                   endsr

700aA*----------------------------------------------------------------
700aA*
700aA*  ZZSETCMDLN1  Setup the command keys
700aa*
700aaC     zzsetcmdln1   begsr
700aA /free
700aA   Select;
700aA     when e$lng = 'SP';
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
700aA*----------------------------------------------------------------
700aA*
700aA*  ZZSETCMDLN1a Setup the command keys
700aa*
700aaC     zzsetcmdln1a  begsr
700aA /free
700aA   Select;
700aA     when e$lng = 'SP';
700aA       Select;
700aA         when $itcwgt <> 'Y';
700aA           cmdln1 = cmdln(12);
700aA         when kilolbs  = 'K';
700aA           cmdln1 = cmdln(11);
700aA         when kilolbs  = 'P';
700aA           cmdln1 = cmdln(10);
700aA       endsl;
700aA     other;
700aA       Select;
700aA         when $itcwgt <> 'Y';
700aA           cmdln1 = cmdln(9);
700aA         when kilolbs  = 'K';
700aA           cmdln1 = cmdln(8);
700aA         when kilolbs  = 'P';
700aA           cmdln1 = cmdln(7);
700aA       endsl;
700aA   endsl;
700aA /end-free
700aaC                   endsr
640bA*----------------------------------------------------------------
640bA*----------------------------------------------------------------
640bA*  License Plate Tracking Routines
640bA*----------------------------------------------------------------
640bA*----------------------------------------------------------------

640bA*----------------------------------------------------------------
640bA*  ZZZCLR$LT210  -  Clear LT210 parameters.
640bA*----------------------------------------------------------------
640bA
640bAC     ZZZCLR$LT210  begsr

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

640bA*----------------------------------------------------------------
640bA*  ZZZCALL$LT210  -  Call LT210 program.
640bA*----------------------------------------------------------------
640bA
640bAC     ZZZCALL$LT210 begsr

     C                   call      'LT210'
     C                   parm                    $tcmd
     C                   parm      #prog         $tprogram
     C                   parm      'SOS'         $ttype
     C                   parm      'SOSTfr'      $thead
     C                   parm                    $twhse
     C                   parm                    $titem
     C                   parm                    $titemdsc
     C                   parm                    $twhdp
     C                   parm                    $tslot
     C                   parm                    $tslotpos
     C                   parm      e$emp#        $templ#
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

     C                   endsr
**  CMDLN - Command display line 700a
F7=Prv F9=Total F13=No More F19=Kgs
F7=Prv F9=Total F13=No More F19=Lbs
F7=Prv F9=Total F13=No More
F7=Antror F9=Total F13=No Mas F19=Kgs
F7=Antror F9=Total F13=No Mas F19=Lbs
F7=Antror F9=Total F13=No Mas
F12=Cancel F19=Kgs
F12=Cancel F19=Lbs
F12=Cancel
F12=Cancelar F19=Kgs
F12=Cancelar F19=Lbs
F12=Cancelar
