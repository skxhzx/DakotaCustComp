     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IV110     Define scope of inventory
     *  Dave Sommeville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
213 A*    06/10/96  DAS
     *      - Added IVSSID and SLSIDE to f selectRT statements.
     *      - Not calling ZZUPD2 to calculate side anymore.
     *      - Added OR statement to look for code 100 in ZZUPD1.
     *
404 A*    08/11/97  RH    4.04
     *      - Added W1ASLE, W1FLOC, W1TLOC, W1FLVL, W1TLVL, W1HSTK
     *        to selection criteria.
     *      - Change to Select using Section OR Aisle, loc, level, handstack.
     *      - Correct error message display for section type.
408 A*    01/12/97  RH    4.08
     *      - Added W1PEXP, export items effected by aisle inventory
     *        only.
414 A*    05/11/00  RH    4.14
     *      - Added W1CYCL, aisle cycle count option.
     *      - Added W1ADJ , aisle cycle count reason code to be used
     *        for the adjustments created for cycle count.
415aA*    06/10/01  RH    4.15a
     *      - Added W1SLTS, Pick slots, Overflow or Both
     *      - Added call to IV111P and IV112P for W1SLTS
     *      - Change position of fields on screen.
416aA*    09/20/01  RH    4.16a
     *      - Added W1DESG, Designation code or All
416bA*    09/26/01  RH    4.16b
     *      - Added IVSPCK field to INVSLOT, change code to select/
     *        unselect pick/overflow slots or both.
416cA*    05/02/02  RH    4.16c
     *      - Add SQL to set commitment=*none,
     *        no special compile needed.
500aA*    02/23/05  RH    5.00a
     *      - Changed to ILE, removed unused code.
     *      - Changed to build SQL statements 1 thru 4, then execute
     *      - Add side of aisle W1SIDE to selection.
510aA*    08/21/06  RH    5.10a
     *      - Enh: Exclude catch weight items from cycle count.
510bA*    08/22/06  DAS   5.10b
     *      - Enh:Added Left Outer Join to sqlbldstmt4.
     *      - Enh:Added exclude catchweight logic to sqlbldstmt4.
510cA*    08/23/06  RH    5.10c
     *      - Enh:Added client code.
510dA*    01/20/07  RH/MLB 5.10d
     *      - Fix:Remove SQL set committment, was not compiling
520aA*    04/04/08  RH    5.20a
     *      - Added W1CAT, Category code or All
520bA*    04/05/08  DAS   5.20b
     *      - Revised SQL statements to work with category code.
520cA*    05/01/08  DAS   5.20c
     *      - Removed Connect/Disconnect
     *      - Re: CALINVSTS would not work correctly on City Line's
     *        system after Disconnect unless you signed off / on.
520dA*    11/24/08  RH    5.20d
     *      - Added W1VEN, Vendor # or All
     *      - Revised SQL statements to work with vendor #.
530aA*    06/08/10  RH    5.30a
     *      - Enh: Allow from and to location to be 0.  Clients have
     *        slots with location = 0.
640a *    10/18/12  LMC  6.40a
     *      ITEMFLD database change - requires recompile.
650a *    09/30/13  RH   6.50a
     *      - Enh: Default section to ' ' so user needs to enter
     *        either section OR aisle etc. selection
700a *    08/01/16  MR   7.00a
     *      - Enh: Add "Item" option to Inventory Scope.
700b *    09/14/16  MR   7.00b
     *      - Enh: Add SLDESG <> BFC in sql statement.
700c *    09/14/16  LMC  7.00c
     *      - Enh: Set the default of W1CYCL = 'Y'.
     *
710  *    03/21/17  TAB  7.10
     *      - Fix: Add code to prevent production base slots from
     *             being deleted
710aA*    03/23/17  LMC  7.10a
     *      - Enh: Database change to INVHSTD. Recompile only.
710bA*    07/28/17  MLB  7.10b
     *      - Enh: Renamed dspf, IV11001 to IV11002 as part of DRY mod.
710cA*    08/17/17  LMC  7.10c
     *      - Fix: When selecting by Category code - BFC designated   .
     *        slots were being included.                              .
710dA*    09/07/17  KDE  7.10d
     *      - Fix: Add RPK slots to 710 logic to exclude RPK base
     *        slots from count file
710eA*  12/22/17  LMC  7.10e
     *    - Enh: Database change to INVHSTD. Recompile only.
740aA*  10/20/20  RH   7.40a
     *    - Fix: Only clear INVITM if status='V', Z status slots
     *      will be counted, was not processing Z slots with blank
     *      item correctly when posting.
740bA*    11/03/20  KDE  7.40b
     *      - Fix: Add sql to where clause to exclude Drop Pick
     *        slots.  Inventory Control will manually adjust if necessary
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Line Distributors
CLD A*    01/21/09  MLB  CLD
     *      - Enh: Default Cyle Count Adj code to 15 per Steve D.
     *----------------------------------------------------------------
     *  Custom
PAKaA*    08/23/06  RH    PAKa
     *      - Enh:Default Exclude CW item to 'Y' for cycle count.
     *----------------------------------------------------------------
     *  Client Custom Revisions
GFCa *    08/23/10  GJA   GFCa
     *      - Force "Y" to W1CYCL and " C" to W1ADJ as default.
     *----------------------------------------------------------------
     *  Greenleaf Custom Revisions
GLPa *    09/30/13  RH    GLPa
     *      - Force "Y" to W1CYCL and "8 " to W1ADJ as default.
     *----------------------------------------------------------------
     *  Fischer Foods
FFCa *    02/16/15  RH    FFCa
     *      - Force "Y" to W1CYCL
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
DRY A*    07/28/17  MLB  DRY
     *      - Force "Y" to W1CYCL and "CC" to W1ADJ as default.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program needs to be compiled with DEFER=*NO so the status
     *    messages can be displayed.
     *
     *    This program uses a revised method to display error messages.
     *    Instead of the program writting each message to the subfile
     *    using the message key the subfile has been revised to display
     *    all messages from the program message queue automatically.
     *
     *    All changes have been marked with MSG in position 1.
     *
     *    This program has been modified to use field CSRFLD which
     *    identifies the field the cursor is located on. The only
     *    routine that was modified was ZZCMD.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
414 D*  21 - 30   Field input error (Reverse Display)
414 M*  21 - 33   Field input error (Reverse Display)
DRY A*  41        Protect Cycle Count flag. Default to Y for Dairyland.
     *  90        View mode (Protect input fields)
     *  91        Change mode (Protect key)
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
700aDF*iv110fm   cf   e             workstn
710bDF*iv11001   cf   e             workstn
710bMFiv11002   cf   e             workstn
     F                                     infds(infds)
MSG D*                                       MSGK  KSFILE MSGREC
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  SQL fields for screen 1
     *----------------------------------------------------------------

     D sqlfile1        c                   'INVSLOT'
      *
710 A*----------------------------------------------------------------
710 A*  File data data structure
710 A*----------------------------------------------------------------
710 A
710 AD plrec         E ds                  extname(plined) inz(*EXTDFT)
710 A
710 A*----------------------------------------------------------------
510cA*----------------------------------------------------------------
510cA*  Customer id
510cA*
510cAD @getcl          c                   const('GETCLIENT')
510cAD*
510cA /COPY QCOPYSRC,ID#PACKERS
CLD A /COPY QCOPYSRC,ID#CITYLIN
GFCaA /COPY QCOPYSRC,ID#GLAZIER
GLPaA /COPY QCOPYSRC,ID#GLP
FFCaA /COPY QCOPYSRC,ID#FISCHER
DRY A /COPY QCOPYSRC,ID#DAIRYLA
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
520dAD desc            s             60    dim(12) ctdata perrcd(1)
520dDD*desc            s             60    dim(11) ctdata perrcd(1)
520aDD*desc            s             60    dim(10) ctdata perrcd(1)
510aDD*desc            s             60    dim(9) ctdata perrcd(1)
500aD*                   DESC    1   8 60
414 D*                   DESC    1   6 60
408 D*                   DESC    1   5 60
     *----------------------------------------------------------------
     *  Data structure for SQL select.
     *
     D dscnt           ds
     D  dsrecs                 1      4b 0
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
     *
     D  $lcode                19     20
416a *
416a D  $ldesg                19     23
520a *
520a D  $lcat                 19     28
700aA*
700aAD  $litem                22     36
     *
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  ercnt                  1      4p 0
     D  ercode                 1      3p 0
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
     *  Variables
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     *AND IVSSTP=     s          STYP
     *AND IVSWHD=     s          WHDP
     *AND SLDESG=     s          DESG
     *AND SLSTYP=     s          STYP
     *SITM, IVSSID,   s          IVSPE X,
     *SLOC, IVSLVL,   s          IVSHN D,
     D asle            s              3
     D cmdtkn          s              1
     D e               s              2  0
     D*error           s              1
     D hstk            s              2
     D loc             s              3  0
     D lvl             s              2  0
     D nxtscr          s              3
     D sclear          s              1
     D side            s              1  0
     D temp4n          s              4  0
     D*warn            s              1
     D w1pick          s              1
710 AD LinItm          S             15
710 AD PrdItm          S             15
710 AD ParItm          S             15
710dAD RpkItm          S             15
710 AD WipItm          S             15
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
     C                   parm                    $prtn             8
     *----------------------------------------------------------------
     *  Main line
     *
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
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
520cDC**                 exsr      sqldisconnect
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
     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif
     *
     *   Initialize error indicators and fields
     *
401 AC                   setoff                                       010203
401 AC                   setoff                                       040506
401 AC                   setoff                                       070809
414 MC                   setoff                                       101213
510aAC                   setoff                                       17
414 D*R                   SETOF                     10
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
414 D*R                   SETOF                     30
414 MC                   setoff                                       303233
510aAC                   setoff                                       37
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
MSG D*                    EXSR ZMCMSG
MSG MC                   exsr      zmcpmq
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
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
510cA*
510cA* Get client id.
510cA*
510cAC                   call      @getcl
510cAC                   parm                    client           10
510cA*
     *  Initialize message handling
     *
MSG D*                    EXSR ZMIMSG
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
MSG D*          ZMCMSG    BEGSR
MSG D*                    MOVE '0'       *IN97
MSG D*                    WRITEMSGCTL
MSG D*                    Z-ADD*ZERO     MSGK    40
MSG D*                    WRITEMSGCLR
MSG D*                    MOVE '*CLEAR ' #MSGID  7
MSG D*                    MOVE '*NULL  ' #MSGTP  7
MSG D*                    EXSR ZMPMSG
MSG D*                    ENDSR
     *
     *    ZMCPMQ  Clear program message queue.
     *
     C     zmcpmq        begsr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
MSG D*
MSG D*    ZMCSBF  Clear message subfile.
MSG D*
MSG D*          ZMCSBF    BEGSR
MSG D*                    MOVE *OFF      *IN97
MSG D*                    WRITEMSGCTL
MSG D*                    ENDSR
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
MSG D*          MSGK      IFGT 0
     C                   write     msgctl
MSG D*                    Z-ADD*ZERO     MSGK
MSG D*                    END
     C                   endsr
MSG D*
MSG D*    ZMIMSG  Initialization necessary for message subfile
MSG D*
MSG D*          ZMIMSG    BEGSR
MSG D*                    MOVE #PROG     #PGMQ  10
MSG D*                    EXSR ZMCMSG
MSG D*                    ENDSR
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
MSG D*          #MSGID    IFNE '*CLEAR '
MSG D*                    ADD  1         MSGK
MSG D*                    WRITEMSGREC
MSG D*                    END
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
MSG D*
MSG D*    ZMQMSG  Add message record to subfile from program queue
MSG D*
MSG D*          ZMQMSG    BEGSR
MSG D*                    ADD  1         MSGK
MSG D*                    WRITEMSGREC
MSG D*                    ENDSR
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     *R                   WRITECLRSCR
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
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0204  Can only enter one value.
     *
     C     zm0204        begsr
     C                   eval      #msgid = 'PIR0204'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
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
     *----------------------------------------------------------------
     *    IV11005  Selecting slots.
     *
     C     zm05          begsr
     C                   eval      #msgid = 'IV11005'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    IV11006  Verifying that no slots have already been selected.
     *
     C     zm06          begsr
     C                   eval      #msgid = 'IV11006'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    IV11007  Verifying that slots can be unselected.
     *
     C     zm07          begsr
     C                   eval      #msgid = 'IV11007'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    IV11008  Unselecting slots.
     *
     C     zm08          begsr
     C                   eval      #msgid = 'IV11008'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    IV11021  No slots selected.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'IV11021'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    IV11022  Slots selected.
     *
     C     zm22          begsr
     C                   eval      #msgid = 'IV11022'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    IV11023  Unmonitored error occured.
     *
     C     zm23          begsr
     C                   eval      #msgid = 'IV11023'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   if        sqlcod < 0
     C                   eval      temp4n = -(sqlcod)
     C                   movel     'SQL'         #msgid
     C                   move      temp4n        #msgid
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     sqlerm        $md
     C                   movel     'QSQLMSG'     $msgf
     C                   exsr      zmpmsg
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *    IV11024  No slots selected - Slots already exist.
     *
     C     zm24          begsr
     C                   eval      #msgid = 'IV11024'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    IV11025  Can not unselect slots.
     *
     C     zm25          begsr
     C                   eval      #msgid = 'IV11025'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    IV11026  Slots unselected.
     *
     C     zm26          begsr
     C                   eval      #msgid = 'IV11026'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    IV11027  No slots unselected.
     *
     C     zm27          begsr
     C                   eval      #msgid = 'IV11027'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
500a *  sqlbldstmt1 - Build SQL statment for zzzcks
     *----------------------------------------------------------------

500a C     sqlbldstmt1   BegSr

     * Create select statement for zzzcks


     *   Create "From" clause.

     C                   eval      sqlfrom = 'FROM INVSLOT'
520eA
520eA*   Create "left outer join" clause.
520eA
520eAC                   eval      sqljoin = 'LEFT OUTER JOIN PIRITEM '
520eAC                                     + 'ON ITWHSE=IVSWHS '
520eAC                                     + 'AND ITITEM=IVSITM '
520bA
520bA*   Create "left outer join" clause.
520bA
520bAC                   eval      sqljoin2 = 'LEFT OUTER JOIN ITEMFLD '
520bAC                                      + 'ON IFWHSE=IVSWHS '
520bAC                                      + 'AND IFITEM=IVSITM '

     *   Create "Where" clause.

     C                   eval      sqlwhere = 'WHERE '
     C                               + 'IVSWHS=' + %editc(w1whse:'P')
520eA
520eA*   Exclude catchweight items.
520eAC                   if        w1excw = 'Y'
520eAC                   eval      sqlwhere = %trim(sqlwhere) + ' '
520eAC                               + 'AND IFNULL(ITCWGT,'
520eAC                               +    sq + 'N' + sq + ')' + '<>'
520eAC                               +    sq + 'Y' + sq
510eAC                   endif

     *   Select pick or overflow
     C                   if        w1slts <> 'B'
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND IVSPCK='
     C                               +    sq + %trim(w1pick) + sq
     C                   endif
     *   Select department.
     C                   if        w1whdp <> '*ALL'
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND IVSWHD='
     C                               +    sq + %trim(w1whdp) + sq
     C                   endif
     *   Select section type.
     C                   if        w1styp <> 'B' and w1asle = ' '
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND IVSSTP='
     C                               +    sq + %trim(w1styp) + sq
     C                   endif
     *   Select designation code.
     C                   if        w1desg <> '*ALL'
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND IVSDSG='
     C                               +    sq + %trim(w1desg) + sq
     C                   endif
520bA*   Select category code
520bAC                   if        w1cat <> '*ALL'
520bAC                   eval      sqlwhere = %trim(sqlwhere) + ' '
520bAC                               + 'AND IFCAT='
520bAC                               +    sq + %trim(w1cat) + sq
520bAC                   endif
520eA*   Select item vendor
520eAC                   if        w1ven <> 0
520eAC                   eval      sqlwhere = %trim(sqlwhere) + ' '
520eAC                               + 'AND ITVEN#='
520eAC                               +     %editc(w1ven:'P')
520eAC                   endif
700aA*   Select item #
700aAC                   if        w1itm <> '*ALL'
700aAC                   eval      sqlwhere = %trim(sqlwhere) + ' '
700aAC                               + 'AND IVSITM= '+
700aAC                              sq + W1ITM + sq
700aAC                   endif
     *   Select aisle.
     C                   if        w1asle <> '*ALL' and w1asle <> ' '
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND IVSASL='
     C                               +    sq + (asle) + sq
     C                   endif
     *   Select side.
     C                   if        w1side <> '*BOTH'
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND IVSSID='
     C                               +    %editc(side:'P')
     C                   endif
     *   Select handstack
     C                   if        w1hstk <> '*ALL' and w1asle <> ' '
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND IVSHND='
     C                               +    sq + %trim(hstk) + sq
     C                   endif
     *   Select location.
     C                   if        w1asle <> ' '
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND (IVSLOC>='
     C                               +   %editc(w1floc:'P')
     C                               + ' AND IVSLOC<='
     C                               +   %editc(w1tloc:'P')
     C                               +   ')'
     C                   endif
     *   Select level.
     C                   if        w1asle <> ' '
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND (IVSLVL>='
     C                               +    %editc(w1flvl:'P')
     C                               + ' AND IVSLVL<='
     C                               +    %editc(w1tlvl:'P')
     C                               +   ')'
     C                   endif

     *   Create SQL statement.

     C                   eval      sqlstmt = 'SELECT '
     C                                       + 'COUNT(*) '
     C                                       + %trimr(sqlfrom) + ' '
520bAC                                       + %trimr(sqljoin) + ' '
520eAC                                       + %trimr(sqljoin2) + ' '
     C                                       + %trimr(sqlwhere)
500a C                   EndSr

     *----------------------------------------------------------------
500a *  sqlbldstmt2 - Build SQL statment for zzzcku
     *----------------------------------------------------------------

500a C     sqlbldstmt2   BegSr

     * Create select statement for zzzcku


     *   Create "From" clause.

     C                   eval      sqlfrom = 'FROM INVSLOT'

     *   Create "Where" clause.

     C                   eval      sqlwhere = 'WHERE '
     C                               + 'IVSWHS=' + %editc(w1whse:'P')
     C                               + ' AND IVSPAG>0'

     *   Select pick or overflow
     C                   if        w1slts <> 'B'
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND IVSPCK='
     C                               +    sq + %trim(w1pick) + sq
     C                   endif
     *   Select department.
     C                   if        w1whdp <> '*ALL'
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND IVSWHD='
     C                               +    sq + %trim(w1whdp) + sq
     C                   endif
     *   Select section type.
     C                   if        w1styp <> 'B' and w1asle = ' '
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND IVSSTP='
     C                               +    sq + %trim(w1styp) + sq
     C                   endif
     *   Select designation code.
     C                   if        w1desg <> '*ALL'
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND IVSDSG='
     C                               +    sq + %trim(w1desg) + sq
     C                   endif
     *   Select aisle.
     C                   if        w1asle <> '*ALL' and w1asle <> ' '
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND IVSASL='
     C                               +    sq + (asle) + sq
     C                   endif
     *   Select side.
     C                   if        w1side <> '*BOTH'
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND IVSSID='
     C                               +    %editc(side:'P')
     C                   endif
     *   Select handstack
     C                   if        w1hstk <> '*ALL' and w1asle <> ' '
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND IVSHND='
     C                               +    sq + %trim(hstk) + sq
     C                   endif
     *   Select location.
     C                   if        w1asle <> ' '
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND (IVSLOC>='
     C                               +   %editc(w1floc:'P')
     C                               + ' AND IVSLOC<='
     C                               +    %editc(w1tloc:'P')
     C                               +    ')'
     C                   endif
     *   Select level.
     C                   if        w1asle <> ' '
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND (IVSLVL>='
     C                               +    %editc(w1flvl:'P')
     C                               + ' AND IVSLVL<='
     C                               +    %editc(w1tlvl:'P')
     C                               +    ')'
     C                   endif

     *   Create SQL statement.

     C                   eval      sqlstmt = 'SELECT '
     C                                       + 'COUNT(*) '
     C                                       + %trimr(sqlfrom) + ' '
     C                                       + %trimr(sqlwhere)
     C                   EndSr

     *----------------------------------------------------------------
500a *  sqlbldstmt3 - Build SQL statment for zzzdel
     *----------------------------------------------------------------

500a C     sqlbldstmt3   BegSr

     * Create select statement for zzzdel


     *   Create "From" clause.

     C                   eval      sqlfrom = 'FROM INVSLOT'

     *   Create "Where" clause.

     C                   eval      sqlwhere = 'WHERE '
     C                               + 'IVSWHS=' + %editc(w1whse:'P')

     *   Select pick or overflow
     C                   if        w1slts <> 'B'
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND IVSPCK='
     C                               +    sq + %trim(w1pick) + sq
     C                   endif
     *   Select department.
     C                   if        w1whdp <> '*ALL'
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND IVSWHD='
     C                               +    sq + %trim(w1whdp) + sq
     C                   endif
     *   Select section type.
     C                   if        w1styp <> 'B' and w1asle = ' '
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND IVSSTP='
     C                               +    sq + %trim(w1styp) + sq
     C                   endif
     *   Select designation code.
     C                   if        w1desg <> '*ALL'
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND IVSDSG='
     C                               +    sq + %trim(w1desg) + sq
     C                   endif
     *   Select aisle.
     C                   if        w1asle <> '*ALL' and w1asle <> ' '
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND IVSASL='
     C                               +    sq + (asle) + sq
     C                   endif
     *   Select side.
     C                   if        w1side <> '*BOTH'
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND IVSSID='
     C                               +    %editc(side:'P')
     C                   endif
     *   Select handstack
     C                   if        w1hstk <> '*ALL' and w1asle <> ' '
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND IVSHND='
     C                               +    sq + %trim(hstk) + sq
     C                   endif
     *   Select location.
     C                   if        w1asle <> ' '
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND (IVSLOC>='
     C                               +   %editc(w1floc:'P')
     C                               + ' AND IVSLOC<='
     C                               +    %editc(w1tloc:'P')
     C                               +    ')'
     C                   endif
     *   Select level.
     C                   if        w1asle <> ' '
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND (IVSLVL>='
     C                               +    %editc(w1flvl:'P')
     C                               + ' AND IVSLVL<='
     C                               +    %editc(w1tlvl:'P')
     C                               +    ')'
     C                   endif

     *   Create SQL statement.

     C                   eval      sqlstmt = 'DELETE '
     C                                       + %trimr(sqlfrom) + ' '
     C                                       + %trimr(sqlwhere)
     C                   EndSr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
500a *  sqlbldstmt4 - Build SQL statment for zzzsel
     *----------------------------------------------------------------

500a C     sqlbldstmt4   BegSr

     * Create select statement for zzzsel

710 A* Check for Production module base slots
710 AC                   ExSR      ChkPrdBas


     *   Create "From" clause.

     C                   eval      sqlfrom = 'FROM SLOT1 as S1'
510bA
510bA*   Create "left outer join" clause.
510bA
510bAC                   eval      sqljoin = 'LEFT OUTER JOIN PIRITEM '
510bAC                                     + 'ON ITWHSE=s1.SLWHSE '
510bAC                                     + 'AND ITITEM=s1.SLITEM '
520bA
520bA*   Create "left outer join" clause.
520bA
520bAC                   eval      sqljoin2 = 'LEFT OUTER JOIN ITEMFLD '
520bAC                                      + 'ON IFWHSE=s1.SLWHSE '
520bAC                                      + 'AND IFITEM=s1.SLITEM '

     *   Create "Where" clause.

     C                   eval      sqlwhere = 'WHERE '
     C                               + 'SLWHSE=' + %editc(w1whse:'P')

710 A*   Exclude Production Base slots
710 AC                   eval      sqlwhere = %trim(sqlwhere) + ' '
710 AC                               + 'AND SLITEM <> '+ sq + PrdItm + sq + ' '
710 AC                               + 'AND SLITEM <> '+ sq + WipItm + sq + ' '
710 AC                               + 'AND SLITEM <> '+ sq + LinItm + sq + ' '
710 AC                               + 'AND SLITEM <> '+ sq + ParItm + sq + ' '
710dAC                               + 'AND SLITEM <> '+ sq + RpkItm + sq + ' '
740bA*   Exclude Drop Pick slots
740bAc                   eval      sqlwhere = %trim(sqlwhere) + ' '
740bAc                              + 'and s1.sldesg<>' + sq + '*DROP' + sq
740bAc                              + ' and s1.slstat<>' + sq + 'DP' + sq
520eA
520eA*   Exclude slots that are alread in invslot file.
520eAC                   eval      sqlwhere = %trim(sqlwhere) + ' '
520eAC                               + 'AND NOT EXISTS (select ivsdsp '
520eAC                               + 'from invslot as i2 '
520eAC                               + 'where i2.ivswhs=s1.slwhse '
520eAC                               + '  and i2.ivswhd=s1.slwhdp '
520eAC                               + '  and i2.ivsdsp=s1.sldisp)'
520eA
520eA*   Exclude slots that are alread in invslot file.
520eAC*                  eval      sqlwhere = %trim(sqlwhere) + ' '
520eAC*                              + 'AND (select count(*) '
520eAC*                              + 'from invslot as i2 '
520eAC*                              + 'where i2.ivswhs=s1.slwhse '
520eAC*                              + '  and i2.ivswhd=s1.slwhdp '
520eAC*                              + '  and i2.ivsdsp=s1.sldisp) = 0'
510bA
510bA*   Exclude catchweight items.
510bAC                   if        w1excw = 'Y'
510bAC                   eval      sqlwhere = %trim(sqlwhere) + ' '
510bAC                               + 'AND IFNULL(ITCWGT,'
510bAC                               +    sq + 'N' + sq + ')' + '<>'
510bAC                               +    sq + 'Y' + sq
510bAC                   endif

     *   Select pick or overflow
     C                   if        w1slts <> 'B'
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND SLPICK='
     C                               +    sq + %trim(w1pick) + sq
     C                   endif
     *   Select department.
     C                   if        w1whdp <> '*ALL'
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND SLWHDP='
     C                               +    sq + %trim(w1whdp) + sq
     C                   endif
     *   Select section type.
     C                   if        w1styp <> 'B' and w1asle = ' '
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND SLSTYP='
     C                               +    sq + %trim(w1styp) + sq
     C                   endif
     *   Select designation code.
     C                   if        w1desg <> '*ALL'
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND SLDESG='
     C                               +    sq + %trim(w1desg) + sq
     C                   endif
520bA*   Select category code
520bAC                   if        w1cat <> '*ALL'
520bAC                   eval      sqlwhere = %trim(sqlwhere) + ' '
520bAC                               + 'AND IFCAT='
520bAC                               +    sq + %trim(w1cat) + sq
710cAC                               + ' AND SLDESG <> '
710cAC                               + sq + 'BFC' + sq
520bAC                   endif
520dA*   Select item vendor
520dAC                   if        w1ven <> 0
520dAC                   eval      sqlwhere = %trim(sqlwhere) + ' '
520dAC                               + 'AND ITVEN#='
520dAC                               +     %editc(w1ven:'P')
520dAC                   endif
700aA*   Select item #
700aAC                   if        w1itm <> '*ALL'
700aAC                   eval      sqlwhere = %trim(sqlwhere) + ' '
700aAC                               + 'AND SLITEM= '+
700aAC                              sq + W1ITM + sq +
700bAC                              ' AND SLDESG <> ' +
700bAC                              sq + 'BFC' + sq
700aAC                   endif
     *   Select aisle.
     C                   if        w1asle <> '*ALL' and w1asle <> ' '
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND SLAISL='
     C                               +    sq + (asle) + sq
     C                   endif
     *   Select side.
     C                   if        w1side <> '*BOTH'
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND SLSIDE='
     C                               +    %editc(side:'P')
     C                   endif
     *   Select handstack
     C                   if        w1hstk <> '*ALL' and w1asle <> ' '
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND SLHAND='
     C                               +    sq + %trim(hstk) + sq
     C                   endif
     *   Select location.
     C                   if        w1asle <> ' '
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND (SLLOC>='
     C                               +    %editc(w1floc:'P')
     C                               + ' AND SLLOC<='
     C                               +    %editc(w1tloc:'P')
     C                               +   ')'
     C                   endif
     *   Select level.
     C                   if        w1asle <> ' '
     C                   eval      sqlwhere = %trim(sqlwhere) + ' '
     C                               + 'AND (SLRLVL>='
     C                               +    %editc(w1flvl:'P')
     C                               + ' AND SLRLVL<='
     C                               +    %editc(w1tlvl:'P')
     C                               +   ')'
     C                   endif

     *   Create SQL statement.

     C                   eval      sqlstmt = 'INSERT '
408 MC                             + 'into invslot (ivswhs, ivswhd, '
408 MC                             + 'ivsasl, ivsloc, ivslvl, ivshnd, '
408 MC                             + 'ivsstp, ivsdsp, ivssta, ivsitm, '
416aMC                             + 'ivssid, ivspex, ivsadj, ivsdsg, '
416aMC                             + 'ivspck) '
     C                             + 'select slwhse, slwhdp, slaisl, '
     C                             + 'slloc,  slrlvl, slhand, slstyp, '
414 MC                             + 'sldisp, slstat, slitem, slside, '
     C                             + sq + w1pexp + sq + ', '
     C                             + sq + w1adj + sq + ', '
416aMC                             + 'sldesg, slpick '
     C                                       + %trimr(sqlfrom) + ' '
510bAC                                       + %trimr(sqljoin) + ' '
520bAC                                       + %trimr(sqljoin2) + ' '
     C                                       + %trimr(sqlwhere)
500a C                   EndSr

     *----------------------------------------------------------------
500a *  sqlprep - Prepare SQL statement and cursor
     *
     *    Note: This routine must come before any other routine
     *          using an SQL statement because it declares the
     *          SQL Cursor being used.
     *
     *----------------------------------------------------------------

500a C     sqlprep       BegSr

     * Prepare the SQL statement for validation, since the program was
     * compiled with DLYPRP (*YES), it will wait until it is used before
     * it prepares the cursor.

     C/EXEC SQL
     C+   PREPARE sel FROM :SqlStmt
     C/END-EXEC
     C                   eval      sqlstt = sqlstt
      *
      * Declare the SQL cursor to hold the data retrieved from the SELECT
      *
     C/EXEC SQL
     C+ DECLARE MYCSR DYNAMIC SCROLL CURSOR FOR SEL
     C/END-EXEC
     C                   eval      sqlstt = sqlstt
      *
      * Open the SQL cursor.
      *
     C
     C/EXEC SQL
     C+ OPEN MYCSR
     C/END-EXEC
     C                   eval      sqlstt = sqlstt
      *
500a C                   EndSr

     *----------------------------------------------------------------
500a *  sqlclose - Clean up after executing SQL
     *----------------------------------------------------------------

500a C     sqlclose      BegSr

     * Close the SQL cursor after all processing is complete.

     C/EXEC SQL
     C+   CLOSE mycsr
     C/END-EXEC

     *--- DEBUG ---
     C                   if        sqlstt <> '00000'
     C                   endif

500a C                   Endsr

     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  Verify warehouse code.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
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
MSG D*                    EXSR ZMQMSG
     C                   endif
     C                   endif
     *
     *  Verify warehouse department.
     *
     C                   if        w1whdp <> '*ALL '
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
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
MSG D*                    EXSR ZMQMSG
     C                   endif
     C                   endif
     C                   endif
416a *
416a *  Verify designation area (optional).
416a *
416a C                   if        w1desg <> '*ALL '
416a C                   eval      $lcmd = '*VERIFY '
416a C                   eval      $ldesg = w1desg
416a C                   call      'DS900'
416a C                   parm                    $lparm
416a C                   if        $lrtn = '*ERROR  '
416a C                   eval      error = *on
416a C                   eval      *in35 = *on
416a C                   eval      *in15 = *on
416a C                   movel     $lmsg         errmsg
416a C                   exsr      zm0105
416a C                   else
416a C                   if        $lrtn = '*PGMQ   '
416a C                   eval      error = *on
416a C                   eval      *in35 = *on
416a C                   eval      *in15 = *on
416a C                   eval      #msgk = $lmsg
416a C                   endif
416a C                   endif
416a C                   endif
     *
520a *
520aA*  Can not unselect by category code.
520a *
520aAC                   if        w1type = 'U'  and
520aAC                             w1cat <> '*ALL'
520aAC                   eval      error = *on
520aAC                   eval      *in38 = *on
520aAC                   eval      *in18 = *on
520aAC                   eval      errmsg = *blanks
520aAC                   movel     desc(11)      errmsg
520aAC                   exsr      zm1001
520aDC*                  exsr      zm25
520aAC                   endif
     *
520a *
520a *  Verify category code (optional).
520a *
520a C                   if        w1cat <> '*ALL      '
520a C                   eval      $lcmd = '*VERIFY '
520a C                   eval      $lcat = w1cat
520a C                   call      'IC900'
520a C                   parm                    $lparm
520a C                   if        $lrtn = '*ERROR  '
520a C                   eval      error = *on
520a C                   eval      *in38 = *on
520a C                   eval      *in18 = *on
520a C                   movel     $lmsg         errmsg
520a C                   exsr      zm0105
520a C                   else
520a C                   if        $lrtn = '*PGMQ   '
520a C                   eval      error = *on
520a C                   eval      *in38 = *on
520a C                   eval      *in18 = *on
520a C                   eval      #msgk = $lmsg
520a C                   endif
520a C                   endif
520a C                   endif
     *
520d *
520dA*  Can not unselect by vendor #.
520d *
520dAC                   if        w1type = 'U'  and
520dAC                             w1ven <> 0
520dAC                   eval      error = *on
520dAC                   eval      *in39 = *on
520dAC                   eval      *in19 = *on
520dAC                   eval      errmsg = *blanks
520dAC                   movel     desc(12)      errmsg
520dAC                   exsr      zm1001
520dAC                   endif
     *
700aA*
700aA*  Verfiy Item.
700aA*
700aAC                   if        w1itm <> '*ALL'
700aAC                   eval      $lcmd = '*VERIFY'
700aAC                   eval      $litem= w1itm
700aAC                   call      'IT900'
700aAC                   parm                    $lparm
700aAC                   if        $lrtn = '*ERROR  '
700aAC                   eval      error = *on
700aAC                   eval      *in40 = *on
700aAC                   eval      *in20 = *on
700aAC                   eval      errmsg = *blanks
700aAC                   movel     $lmsg         errmsg
700aAC                   exsr      zm0105
700aAC                   else
700aAC                   if        $lrtn = '*PGMQ   '
700aAC                   eval      error = *on
700aAC                   eval      *in40 = *on
700aAC                   eval      *in20 = *on
700aAC                   eval      #msgk = $lmsg
700aAC                   endif
700aAC                   endif
700aAC                   endif
     *
     *
     *
     *  Verify section type.
     *
404 AC                   if        w1asle = *blanks
     C                   if        w1styp <> 'P'  and
     C                             w1styp <> 'F'  and
     C                             w1styp <> 'B'
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
404 AC                   eval      errmsg = *blanks
404 AC                   movel     desc(1)       errmsg
404 D*R                   MOVE *BLANKS   $MD
404 D*R                   MOVEADESC,1    $MD
     C                   exsr      zm1001
     C                   endif
404 AC                   endif
     *
404 A*  Enter section type OR Aisle, not both.
404 A*
404 AC                   if        w1asle <> *blanks  and
404 AC                             w1styp <> *blanks
404 AC                   eval      error = *on
404 AC                   eval      *in29 = *on
404 AC                   eval      *in23 = *on
404 AC                   eval      *in03 = *on
404 AC                   eval      errmsg = *blanks
404 D*R                   MOVELDESC,1    ERRMSG
404 AC                   exsr      zm0204
404 AC                   endif
     *
     *  Verify type.
     *
     C                   if        w1type <> 'S'  and
     C                             w1type <> 'U'
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
404 AC                   eval      errmsg = *blanks
404 AC                   movel     desc(2)       errmsg
404 D*R                   MOVE *BLANKS   $MD
404 D*R                   MOVEADESC,2    $MD
     C                   exsr      zm1001
     C                   endif
     *
415a *  Verify Slots (P=Pick, O=Overflow, B=Both)
415a *
415a C                   if        w1slts <> 'P'  and
415a C                             w1slts <> 'O'  and
415a C                             w1slts <> 'B'
415a C                   eval      error = *on
415a C                   eval      *in34 = *on
415a C                   eval      *in14 = *on
415a C                   eval      errmsg = *blanks
415a C                   movel     desc(3)       errmsg
415a C                   exsr      zm1001
415a C                   endif
416b *
416b C                   if        w1slts = 'P'
416b C                   eval      w1pick = 'Y'
416b C                   else
416b C                   eval      w1pick = 'N'
416b C                   endif
     *
414 A*  Verify Aisle cycle count Y/N.
     *
414 AC                   if        w1cycl <> 'Y'  and
414 AC                             w1cycl <> 'N'
414 AC                   eval      error = *on
414 AC                   eval      *in32 = *on
414 AC                   eval      *in12 = *on
414 AC                   eval      errmsg = *blanks
414 AC                   movel     desc(7)       errmsg
414 AC                   exsr      zm1001
414 AC                   endif
     *
     *
414 A*  Adjustment reason code is required for Asile cycle count.
     *
414 AC                   if        w1cycl = 'Y'  and
414 AC                             w1adj = ' '
414 AC                   eval      error = *on
414 AC                   eval      *in33 = *on
414 AC                   eval      *in13 = *on
414 AC                   eval      errmsg = *blanks
414 AC                   movel     desc(8)       errmsg
414 AC                   exsr      zm1001
414 AC                   endif
     *
414 A*  Verify adjustment reason code.
414 A*
414 AC                   if        w1adj <> ' '
414 AC                   eval      $lcmd = '*VERIFY '
414 AC                   eval      $lcode = w1adj
414 AC                   call      'AD900'
414 AC                   parm                    $lparm
414 AC                   if        $lrtn = '*ERROR  '
414 AC                   eval      error = *on
414 AC                   eval      *in33 = *on
414 AC                   eval      *in13 = *on
414 AC                   movel     $lerm         errmsg
414 AC                   exsr      zm0105
414 AC                   else
414 AC                   if        $lrtn = '*PGMQ   '
414 AC                   eval      error = *on
414 AC                   eval      *in33 = *on
414 AC                   eval      *in13 = *on
414 AC                   eval      #msgk = $lmsg
414 AC                   endif
414 AC                   endif
414 AC                   endif
     *
414 A*  If aisle cycle count =N, adjustment code must be blank.
414 A*
414 AC                   if        w1cycl = 'N'  and
414 AC                             w1adj <> ' '
414 AC                   eval      error = *on
414 AC                   eval      *in32 = *on
414 AC                   eval      *in33 = *on
414 AC                   eval      *in12 = *on
414 AC                   eval      errmsg = *blanks
414 AC                   movel     desc(7)       errmsg
414 AC                   exsr      zm1001
414 AC                   endif
     *
510aA*  Verify Exclude CW items = Y/N.
     *
510aAC                   if        w1excw <> 'Y'  and
510aAC                             w1excw <> 'N'
510aAC                   eval      error = *on
510aAC                   eval      *in37 = *on
510aAC                   eval      *in17 = *on
510aAC                   eval      errmsg = *blanks
510aAC                   movel     desc(10)      errmsg
510aAC                   exsr      zm1001
510aAC                   endif
     *
     *
510aA*  If aisle cycle count =N, exclude CW items must be N.
510aA*
510aAC                   if        w1cycl = 'N'  and
510aAC                             w1excw <> 'N'
510aAC                   eval      error = *on
510aAC                   eval      *in37 = *on
510aAC                   eval      *in33 = *on
510aAC                   eval      *in17 = *on
510aAC                   eval      errmsg = *blanks
510aAC                   movel     desc(10)      errmsg
510aAC                   exsr      zm1001
510aAC                   endif
     *
     *
PAKaA*  Packers Custom- If cycle count =Y, exclude CW items must be Y.
PAKaA*
PAKaAC                   if        Client = packers
PAKaAC                   if        w1cycl = 'Y'  and
PAKaAC                             w1excw <> 'Y'
PAKaAC                   eval      error = *on
PAKaAC                   eval      *in37 = *on
PAKaAC                   eval      *in33 = *on
PAKaAC                   eval      *in17 = *on
PAKaAC                   eval      errmsg = *blanks
PAKaAC                   movel     desc(10)      errmsg
PAKaAC                   exsr      zm1001
PAKaAC                   endif
PAKaAC                   endif
     *
404 A*
404 A*  Verify slot location is within range.
404 A*
404 AC                   if        w1asle <> *blanks
530aDC*                  if        w1floc < 1  or
530aDC*                            w1floc > 999  or
530aDC*                            w1tloc <= 0  or
530aDC*                            w1tloc < w1floc
530aMC                   if        w1floc < 0  or
530aMC                             w1floc > 999  or
530aMC                             w1tloc < 0  or
530aMC                             w1tloc < w1floc
404 AC                   eval      error = *on
404 AC                   eval      *in25 = *on
404 AC                   eval      *in26 = *on
404 AC                   eval      *in05 = *on
404 AC                   eval      errmsg = *blanks
404 AC                   movel     desc(4)       erfld
404 AC                   movel     '1'           erfrom
404 AC                   movel     '999'         erto
404 AC                   exsr      zm0112
404 AC                   endif
404 AC                   endif
404 A*
404 A*  Verify level is within range.
404 A*
404 AC                   if        w1asle <> *blanks
404 AC                   if        w1flvl < 1  or
404 AC                             w1flvl > 99  or
404 AC                             w1tlvl <= 0  or
404 AC                             w1tlvl < w1flvl
404 AC                   eval      error = *on
404 AC                   eval      *in27 = *on
404 AC                   eval      *in28 = *on
404 AC                   eval      *in07 = *on
404 AC                   eval      errmsg = *blanks
404 AC                   movel     desc(5)       erfld
404 AC                   movel     '1'           erfrom
404 AC                   movel     '99'          erto
404 AC                   exsr      zm0112
404 AC                   endif
404 AC                   endif
404 A*
404 AC                   if        w1asle <> '*ALL '
404 AC                   move      w1asle        $cstr
404 AC                   call      'ADJUST'
404 AC                   parm      '*RIGHT  '    $ccmd             8
404 AC                   parm                    $cstr            30
404 AC                   move      $cstr         asle
404 AC                   endif
404 A*
404 AC                   eval      loc = w1floc
404 AC                   eval      lvl = w1flvl
404 A*
404 AC                   if        w1hstk <> '*ALL '
404 AC                   move      w1hstk        $cstr
404 AC                   call      'ADJUST'
404 AC                   parm      '*RIGHT  '    $ccmd
404 AC                   parm                    $cstr
404 AC                   move      $cstr         hstk
404 AC                   endif
404 A*
     *
408 A*  Verify Export Aisle items only.
     *
408 AC                   if        w1asle <> *blanks
408 AC                   if        w1pexp <> 'Y'  and
408 AC                             w1pexp <> 'N'
408 AC                   eval      error = *on
408 AC                   eval      *in31 = *on
408 AC                   eval      *in11 = *on
408 AC                   eval      errmsg = *blanks
408 AC                   movel     desc(6)       errmsg
408 AC                   exsr      zm1001
408 AC                   endif
408 AC                   endif
     *
500aA*  Verify Side, *BOTH, ODD, EVEN.
     *
500aAC                   if        w1side <> '*BOTH'  and
500aAC                             w1side <> 'ODD  '  and
500aAC                             w1side <> 'EVEN '
500aAC                   eval      error = *on
500aAC                   eval      *in36 = *on
500aAC                   eval      *in16 = *on
500aAC                   eval      errmsg = *blanks
500aAC                   movel     desc(9)       errmsg
500aAC                   exsr      zm1001
500aAC                   endif
     *
500aAC                   select
500aAC                   when      w1side = 'ODD  '
500aAC                   eval      side = 1
500aAC                   when      w1side = 'EVEN '
500aAC                   eval      side = 0
500aAC                   other
500aAC                   eval      side = 0
500aAC                   endsl
     *
     C     endck1        endsr
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
     *     Warehouse
     *
     C                   select
     C                   when      csrfld = 'W1WHSE'
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lprg = #prog
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
     C                   endif
     *
     *     Department.
     *
     C                   when      csrfld = 'W1WHDP'
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whdp = $lwhdp
     C                   endif
416a *
416a *     Designation code.
416a *
416a C                   when      csrfld = 'W1DESG'
416a C                   eval      $lcmd = '*LOOKUP '
416a C                   eval      $lwhse = w1whse
416a C                   eval      $ldesg = w1desg
416a C                   call      'DS900'
416a C                   parm                    $lparm
416a C                   if        $lrtn = '*SELECT '
416a C                   eval      w1desg = $ldesg
416a C                   endif
520a *
520a *     Category code.
520a *
520a C                   when      csrfld = 'W1CAT'
520a C                   eval      $lcmd = '*LOOKUP '
520a C                   eval      $lwhse = w1whse
520a C                   eval      $lcat = w1cat
520a C                   call      'IC900'
520a C                   parm                    $lparm
520a C                   if        $lrtn = '*SELECT '
520a C                   eval      w1cat = $lcat
520a C                   endif
     *
700aA*
700aA*     Item code.
700aA*
700aAC                   when      csrfld = 'W1ITM'
700aAC                   eval      $lcmd = '*LOOKUP'
700aAC                   eval      $lwhse = w1whse
700aAC                   eval      $litem = w1itm
700aAC                   call      'IT900'
700aAC                   parm                    $lparm
700aAC                   if        $lrtn = '*SELECT '
700aAC                   eval      w1itm = $litem
700aAC                   endif
     *
     C                   other
     *
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   endif
     *
     C     endcm1        endsr
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
     *
     C                   eval      w1whdp = '*ALL '
416a C                   eval      w1desg = '*ALL '
520a C                   eval      w1cat = '*ALL      '
520d C                   eval      w1ven = 0
700aAC                   eval      w1itm = '*ALL'
650aDC*                  eval      w1styp = 'B'
650aMC                   eval      w1styp = ' '
     C                   eval      w1type = 'S'
DRY AC                   eval      *in41  = '0'
GFCaAC                   select
GFCaAC                   when      client = glazier
GFCaAC                   eval      w1cycl = 'Y'
GFCaAC                   eval      w1adj = ' C'
GLPaAC                   when      client = greenleaf
GLPaAC                   eval      w1cycl = 'Y'
GLPaAC                   eval      w1adj = '8 '
CLD AC*
CLD AC                   when      client = Cityline
CLDaAC                   eval      w1cycl = 'Y'
CLD AC                   eval      w1adj = '15'
CLD AC*
FFCaAC                   when      client = fischerfoods
FFCaAC                   eval      w1cycl = 'Y'
DRY A*
DRY AC                   when      client = dairyland
DRY A*       Force Protect=On Cycle Count flag.
DRY AC                   eval      *in41  = '1'
DRY AC                   eval      w1cycl = 'Y'
DRY AC                   eval      w1adj = 'CC'
DRY A*
GFCaAC                   other
700cDC*                  eval      w1cycl = 'N'
700cMC                   eval      w1cycl = 'Y'
414 AC                   eval      w1adj = *blanks
GFCaAC                   endsl
510aAC                   eval      w1excw = 'N'
404 AC                   eval      w1asle = *blanks
500aAC                   eval      w1side = '*BOTH'
404 AC                   eval      w1floc = 0
404 AC                   eval      w1tloc = 0
404 AC                   eval      w1flvl = 0
404 AC                   eval      w1tlvl = 0
500aMC                   eval      w1hstk = '*ALL'
500aD**                   MOVE *BLANKS   W1HSTK
415aD**                   MOVE *BLANKS   W1PEXP
415aMC                   eval      w1pexp = 'Y'
415a C                   eval      w1slts = 'B'
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   eval      $lprg = #prog
MSG AC                   eval      #pgmq = #prog
510d C*EXEC SQL
510d C* set option commit=*none
510d C*END-EXEC
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *  Establish SQL connection.

520cDC**                 exsr      sqlconnect

     *   Select first screen to display.
     *
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *  sqlconnect - Establish SQL connection.
     *----------------------------------------------------------------

     C     sqlconnect    BegSr

     * Establish the connection to the remote machine. The -842 return
     * code indicates that the connection is already established. If
     * you want to connect to the local machine, use CONNECT RESET.

     C/EXEC SQL
     C+ CONNECT RESET
     C/END-EXEC

     *--- DEBUG ---
     C                   if        sqlstt <> '00000'
     C                   endif

     C                   EndSr

     *----------------------------------------------------------------
     *  sqldisconnect - Disconnect SQL connection
     *----------------------------------------------------------------

     C     sqldisconnect BegSr

     C/EXEC SQL
     C+   DISCONNECT CURRENT
     C/END-EXEC

     *--- DEBUG ---
     C                   if        sqlstt <> '00000'
     C                   endif

     C                   Endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZNXT1   What to do next when screen 1 input is ok.
     *
     C     zznxt1        begsr
     *
     *   Unselect slots.
     *
     C                   select
     C                   when      w1type = 'U'
     C                   exsr      sqlbldstmt2
     C                   exsr      sqlprep
     C                   exsr      zzzcku
     C                   exsr      sqlclose
     C                   if        error = *off
     C                   exsr      sqlbldstmt3
     C                   exsr      zzzdel
     C                   endif
     *
     *   Select slots.
     *
     C                   other
     C                   exsr      sqlbldstmt1
     C                   exsr      sqlprep
     C                   exsr      zzzcks
     C                   exsr      sqlclose
     C                   if        error = *off
408 AC                   if        w1pexp <> 'Y'
408 AC                   eval      w1pexp = 'N'
408 AC                   endif
     C                   exsr      sqlbldstmt4
     C                   exsr      zzzsel
     C                   if        error = *off
     C                   exsr      zzzup1
     C                   endif
520cAC                   if        error = *off
520cAC                   call      'IV110V'
520cAC                   parm                    w1pexp
520cAC                   parm                    w1adj
520cAC                   endif
     C                   endif
     C                   endsl
710 AC                   exsr      LstChkBas
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZZCKS   Selection check - No slots can exist in work file.
     *
     C     zzzcks        begsr
     C                   eval      error = *off
     *
     *  Keep user informed.
     *
     C                   exsr      zm06
     C                   exsr      zmdmsg
     C                   exsr      zmcpmq
     *
500a C/EXEC SQL
500a C+   FETCH NEXT FROM mycsr
500a C+      INTO :dscnt
500a C/END-EXEC
     *
     *  What happened?
     *
     C                   select
     *
     *     Completed successfully
     *        Count = 0  - Allow selection to continue.
     *        Count > 0  - Error. Do not allow selection.
     *
     C                   when      sqlcod = 0
     C                   if        dsrecs > 0
520eDC****               eval      error = *on
520eDC****               z-add     dsrecs        ercnt
520eDC****               exsr      zm24
     C                   endif
     *
     *     Who knows? Display unmonitored SQL message.
     *
     C                   other
     C                   eval      error = *on
     C                   eval      ercode = sqlcod
     C                   exsr      zm23
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZZCKU   UnSelect check - Slots can not have page numbers.
     *
     C     zzzcku        begsr
     C                   eval      error = *off
     *
     *  Keep user informed.
     *
     C                   exsr      zm07
     C                   exsr      zmdmsg
     C                   exsr      zmcpmq
     *
500a C/EXEC SQL
500a C+   FETCH NEXT FROM mycsr
500a C+      INTO :dscnt
500a C/END-EXEC
     *
     *  What happened?
     *
     C                   select
     *
     *     Completed successfully
     *        Count = 0  - Allow unselect to continue.
     *        Count > 0  - Error. Do not allow unselect.
     *
     C                   when      sqlcod = 0
     C                   if        dsrecs > 0
     C                   eval      error = *on
     C                   exsr      zm25
     C                   endif
     *
     *     Who knows? Display unmonitored SQL message.
     *
     C                   other
     C                   eval      error = *on
     C                   eval      ercode = sqlcod
     C                   exsr      zm23
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZZDEL   Delete (unselect) slots from inventory work file.
     *
     C     zzzdel        begsr
     C                   eval      error = *off
     *
     *  Keep user informed.
     *
     C                   exsr      zm08
     C                   exsr      zmdmsg
     C                   exsr      zmcpmq

500a C/EXEC SQL
500a C+   EXECUTE IMMEDIATE :sqlstmt
500a C/END-EXEC
500a C                   eval      sqlstt = sqlstt

     *
     *  What happened?
     *
     C                   select
     *
     *     Completed normally - Display records unselected.
     *
     C                   when      sqlcod = 0
     C                   eval      *in98 = *on
     C                   eval      ercnt = sqler3
     C                   exsr      zm26
     *
     *     No records found that match criteria.
     *
     C                   when      sqlcod = 100
     C                   eval      error = *on
     C                   exsr      zm27
     *
     *     Who knows? Display unmonitored SQL message.
     *
     C                   other
     C                   eval      error = *on
     C                   eval      ercode = sqlcod
     C                   exsr      zm23
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZZSEL   Select records for entered scope.
     *
     C     zzzsel        begsr
     C                   eval      error = *off
     *
     *  Keep user informed.
     *
     C                   exsr      zm05
     C                   exsr      zmdmsg
     C                   exsr      zmcpmq
500a C/EXEC SQL
500a C+   EXECUTE IMMEDIATE :sqlstmt
500a C/END-EXEC
500a C                   eval      sqlstt = sqlstt

     *
     *  What happened?
     *
     C                   select
     *
     *     Completed normally - Display records selected.
     *
     C                   when      sqlcod = 0
     C                   eval      *in98 = *on
     C                   eval      ercnt = sqler3
     C                   exsr      zm22
     *
     *     No records found that match criteria.
     *
     C                   when      sqlcod = 100
     C                   eval      error = *on
     C                   exsr      zm21
     *
     *     Who knows? Display unmonitored SQL message.
     *
     C                   other
     C                   eval      error = *on
     C                   eval      ercode = sqlcod
     C                   exsr      zm23
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZZUP1   Clear item number if status is 'Z' or 'V'.
740aA*  Only clear item if status='V'
416b *  Changed to process all the records.
     *
     C     zzzup1        begsr
     C                   eval      error = *off
     *
     *  Selecting records and add them to work file using SQL.
     *
     C/EXEC SQL
     C+  update invslot
     C+  set ivsitm=' '
     C+  where ivswhs=:w1whse
740aMC+        and ivsitm<>' ' and ivssta in ('V')
740aDC*        and ivsitm<>' ' and ivssta in ('Z','V')
     C/END-EXEC
     *
     *  What happened?
     *
     C                   select
     *
     *     Completed normally - Do nothing.
     *
     C                   when      sqlcod = 0  or
213 AC                             sqlcod = 100
     *
     *     Who knows? Display unmonitored SQL message.
     *
     C                   other
     C                   eval      error = *on
     C                   eval      ercode = sqlcod
     C                   exsr      zm23
     C                   endsl
     *
     *
     C                   endsr
710 A*----------------------------------------------------------------
710 A* ChkPrdBas - Set things up to exclude Production Base slots
710 A*----------------------------------------------------------------
710 A /Free
710 A      BegSr ChkPrdBas;
710 A      exec sql select * into :plrec
710 A           from plined
710 A           fetch first row only;
710 A
710 A           if sqlstt <> sqlSuccess;
710 A              Eval PrdItm = 'PRDITM';
710 A              Eval ParItm = 'PARITM';
710 A              Eval WipItm = 'WIPITM';
710 A              Eval LinItm = 'LINITM';
710dA              Eval RpkItm = 'RPK101';
710 A           Else;
710 A              Eval PrdItm = %triml(INPCKAISL) + '101';
710 A              Eval LinItm = %triml(INRCVAISL) + '101';
710 A              Eval WipItm = %triml(INWIPAISL) + '101';
710 A              Eval ParItm = %triml(INSTKAISL) + '101';
710dA              Eval RpkItm = 'RPK101';
710 A           endif;
710 A      EndSr;
710 A /End-Free
710 A*----------------------------------------------------------------
710 A*----------------------------------------------------------------
710 A* LstChkBas - Check one more time for possible base slots selected
710 A*           - * Side Note *
710 A*           - This routine is called due to program IV110V can
710 A*             also select base slots and add them to the file
710 A*----------------------------------------------------------------
710 A /Free
710 A      BegSr LstChkBas;
710 A      exec sql delete from invslot
710 A           Where (IVSITM = :PrdItm)
710 A              or (IVSITM = :ParItm)
710 A              or (IVSITM = :WipItm)
710 A              or (IVSITM = :LinItm) or
710dA              (ivsasl='RPK' and ivshnd=' ' and ivssta='RP');

710 A           if sqlstt <> sqlSuccess;
710 A           endif;
710 A      EndSr;
710 A /End-Free
710 A*----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**
Section type
Select/Unselect
Slots
Slot location
Slot level
Export Aisle Items
Aisle Cycle Count
Cycle Adjustment code
Side of aisle
Exclude CW items
Unselect/Category code
Unselect/Vendor #
