     *----------------------------------------------------------------
     *
     *  TM815     Create Truck/Zone definitions.
     *  13 June, 1997
     *  Hemant Kapadia
     *
     *  Note:  The CL program preceding this program selects records
     *         from the SLOT file and groups the records by
     *         Whse/Dept/Section.
     *
     *  Revisions
     *
402 A*    07/18/97  4.02  DAS
     *      - Added files TRUCKD and OPTIONZ.
     *      - Created routines CRTTD and CRTOPZ.
     *      - Routine CRTZH was rewritten.
     *
520aA*    02/28/09  DAS  5.20a  P#00150
     *      - Recompiled because of change to ZONED
     *
720aA*    10/14/18  DAS  7.20a
     *      -  Recompiled because of new ZONED fields
     *
     *----------------------------------------------------------------
     Ftm815     if   e           k disk
     Ftruckh    uf a e           k disk
402 AFtruckd    o  a e           k disk
402 D*ONEH   UF  E           K        DISK                      A
402 MFzoneh     o  a e           k disk
     Fzoned     o  a e           k disk
402 AFoptionz   o  a e           k disk
402 A**** Start 4.02 add ****
     *----------------------------------------------------------------
     *  OPTIONZ data structure
     *
     D opzdta          ds
     D  opzend               117    117
     *----------------------------------------------------------------
     *  *PICK  -  Picking options
     *
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
400 A*    OPSELM  -  Selection method.
400 A*                1 = Single pass (By location).
400 A*                2 = Multiple pass (By stop).
400 A*    OPSPLT  -  Allow stop to be split across pallets (Y/N).
     *
     * Data structure
     *
     D opdta1          ds
     D  opnxtp                 1      7  0 inz(0)
213 D*I            0                         8   90OPBPCK
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     *I            0                        21  210OPFSTP
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
209 AD  opfbld                27     27  0 inz(0)
213 AD  opbpck                28     30  0 inz(0)
214 D*                                      31  31 OPPBRK
214 AD  oppbrk                31     33
400 AD  oppbld                34     34
400 AD  opselm                35     35
400 AD  opsplt                36     36
     D  opend1               117    117
     *----------------------------------------------------------------
     *  *PICKLBL  -  Picking label options
     *
300 A*     06/11/97  DAS
     *       - Moved into OPTIONZ from OPTIOND file.
     *       - Added field OPPDEV.
     *
     *----------------------------------------------------------------
     * Fields
     *
     *    OPCLVL  -  Qty level for combined labels.
     *    OPCWRB  -  Print combined label warning before.
     *    OPCWRA  -  Print combined label warning after.
     *    OPUWRB  -  Print unit of measure warning before.
     *    OPUWRA  -  Print unit of measure warning after.
     *    OPTEXT  -  Text for last line of label.
     *    OPERR   -  Error label ratio.
     *    OPCWGT  -  Catch weight label ratio.
     *    OPLPGM  -  Picking label program.
300 A*    OPPDEV  -  Printer device.
300 A*    OPPFRM  -  Printer form.
     *
     * Data structure
     *
     D opdta2          ds
     D  opclvl                 1      3  0 inz(0)
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0 inz(0)
     D  opcwgt                53     54  0 inz(0)
     D  oplpgm                55     64
300 AD  oppdev                65     74
300 AD  oppfrm                75     84
     D  opend2               117    117
402 A**** End 4.02 add ****
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
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
     *----------------------------------------------------------------
     D @desc1          c                   const('Auto created')
     *----------------------------------------------------------------
     D                 ds
     D  dstruk                 1     10
     D  dstrk                  1      8
     D  dstr                   1      5
     D  dswht                  6      8
     D  dsdgt                  9     10
     *
     D  dswil                  1      7
     D  dswl                   1      4
     D  dswhw                  5      7
     D  dsdgw                  8      9
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
     * Work Variables
     *----------------------------------------------------------------
     D $msgf           s             10
     D $pprg           s              8
     D $pwhse          s              3  0
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D comp            s              1
     D digit           s              2  0
     D error           s              1
     D forevr          s              1
     D msgk            s              4  0
     D s#truk          s                   like(thtruk)
     D s#zone          s                   like(zhzone)
     D sclear          s              1
     D svstyp          s                   like(slstyp)
     D svwhdp          s                   like(slwhdp)
     D t#truk          s                   like(thtruk)
     D whsea           s              3
     D zondry          s                   like(zhzone)
     D zonfrz          s                   like(zhzone)
     D zonref          s                   like(zhzone)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $WHSE   Warehouse number
     *      $TTYPE  Type - *NORMAL or *WILLCAL
     *
     *    Returned Parameters
     *      $PRTN   Return code
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $whse            15 5
     C                   parm                    $ptype            8
     C                   parm                    $prtn             8
     *----------------------------------------------------------------
     *  Main line
     *
     *
     * Create TRUCKH record for the warehouse.
     *
     C                   select
     *
     *  *NORMAL
     *
     C                   when      $ptype = '*NORMAL '
     C                   eval      t#truk = *blanks
     C                   movel     'TRUCK'       t#truk
     C     t#truk        cat       whsea:0       t#truk
     *
     *  *WILLCAL
     *
     C                   when      $ptype = '*WILLCAL'
     C                   eval      t#truk = *blanks
     C                   movel     'WILL'        t#truk
     C     t#truk        cat       whsea:0       t#truk
     *
     C                   endsl
     C                   eval      s#truk = t#truk
     C     s#truk        cat       '99':0        s#truk
     *
     C     thkeyt        chain(n)  truckh                             79
     *  Not found - Create it.
     C                   if        *in79
     C                   exsr      crtth
     C                   endif
     *  Found - Append two digits to the warehouse to make the code unique.
     C                   if        not *in79
     C                   exsr      exist
     C                   endif
     *
     C                   dou       forevr <> forevr
     C                   read      tm815                                  79
     C                   if        *in79
     C                   leave
     C                   endif
     * For each Dept/Sect, create a ZONEH & ZONED record.
     C                   if        slwhdp <> svwhdp  or
     C                             slstyp <> svstyp
     C                   exsr      crtzh
     C                   exsr      crtzd
402 AC                   exsr      crtopz
     C                   eval      svwhdp = slwhdp
     C                   eval      svstyp = slstyp
     C                   endif
     C                   enddo
402 A*
402 A*  Create truck detail
402 A*
402 AC                   exsr      crttd
     *
402 D*                    RETRN
402 MC                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      error = *off
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
402 A*----------------------------------------------------------------
402 A*
402 A*  CRTOPZ   Create OPTIONZ records.
402 A*
402 AC     crtopz        begsr
402 A*
402 A*   Pick options
402 A*
402 AC                   eval      opzcod = '*PICK   '
402 AC                   eval      opzwhs = slwhse
402 AC                   eval      opztrk = zhtruk
402 AC                   eval      opzzon = zhzone
402 AC                   eval      opnxtp = 1
402 AC                   eval      opbpck = 35
402 AC                   eval      oppcub = 0
402 AC                   eval      oppbrk = *blanks
402 AC                   eval      opfpal = 1
402 AC                   eval      opfcub = 64
402 AC                   eval      opfstp = 99
402 AC                   eval      opincl = 'Y'
402 AC                   eval      opsrch = 0
402 AC                   eval      opfbld = 1
402 AC                   if        slstyp = 'P'
402 AC                   eval      oppbld = '2'
402 AC                   else
402 AC                   eval      oppbld = *on
402 AC                   endif
402 AC                   eval      opselm = *on
402 AC                   eval      opsplt = 'Y'
402 A*
402 AC                   eval      opzdta = opdta1
402 AC                   write     opzrec                               78
402 A*
402 A*   Pick label options
402 A*
402 AC                   eval      opzcod = '*PICKLBL'
402 AC                   eval      opzwhs = slwhse
402 AC                   eval      opztrk = zhtruk
402 AC                   eval      opzzon = zhzone
402 AC                   eval      oplpgm = 'PLBL43'
402 AC                   eval      oppdev = '*JOB'
402 AC                   eval      oppfrm = 'PCKLBL'
402 AC                   eval      opclvl = 10
402 AC                   eval      opcwrb = 'Y'
402 AC                   eval      opcwra = 'N'
402 AC                   eval      opuwrb = 'Y'
402 AC                   eval      opuwra = 'N'
402 AC                   eval      operr = 99
402 AC                   eval      opcwgt = 2
402 AC                   eval      optext = *blanks
402 A*
402 AC                   eval      opzdta = opdta2
402 AC                   write     opzrec                               78
402 A*
402 AC                   endsr
402 A*----------------------------------------------------------------
402 A*
402 A*  CRTTD    Create TRUCKD record.
402 A*
402 A*     Create 2 rows (4 pallets) for each truck compartment
402 A*     that has a zone assigned to it.
402 A*
402 AC     crttd         begsr
402 AC                   eval      tdwhse = $pwhse
402 AC                   eval      tdtruk = t#truk
402 AC                   eval      tdcube = 64
402 AC                   eval      tdrow = 0
402 A*
402 AC                   if        zonfrz <> *blanks
402 AC                   eval      tdcomp = 'F'
402 AC                   add       1             tdrow
402 AC                   eval      tdcol = 1
402 AC                   eval      tdpick = 4
402 AC                   write     tdrec                                78
402 AC                   eval      tdcol = 2
402 AC                   eval      tdpick = 2
402 AC                   write     tdrec                                78
402 AC                   add       1             tdrow
402 AC                   eval      tdcol = 1
402 AC                   eval      tdpick = 3
402 AC                   write     tdrec                                78
402 AC                   eval      tdcol = 2
402 AC                   eval      tdpick = 1
402 AC                   write     tdrec                                78
402 AC                   endif
402 A*
402 AC                   if        zonref <> *blanks
402 AC                   eval      tdcomp = 'R'
402 AC                   add       1             tdrow
402 AC                   eval      tdcol = 1
402 AC                   eval      tdpick = 4
402 AC                   write     tdrec                                78
402 AC                   eval      tdcol = 2
402 AC                   eval      tdpick = 2
402 AC                   write     tdrec                                78
402 AC                   add       1             tdrow
402 AC                   eval      tdcol = 1
402 AC                   eval      tdpick = 3
402 AC                   write     tdrec                                78
402 AC                   eval      tdcol = 2
402 AC                   eval      tdpick = 1
402 AC                   write     tdrec                                78
402 AC                   endif
402 A*
402 AC                   if        zondry <> *blanks
402 AC                   eval      tdcomp = 'D'
402 AC                   add       1             tdrow
402 AC                   eval      tdcol = 1
402 AC                   eval      tdpick = 4
402 AC                   write     tdrec                                78
402 AC                   eval      tdcol = 2
402 AC                   eval      tdpick = 3
402 AC                   write     tdrec                                78
402 AC                   add       1             tdrow
402 AC                   eval      tdcol = 1
402 AC                   eval      tdpick = 2
402 AC                   write     tdrec                                78
402 AC                   eval      tdcol = 2
402 AC                   eval      tdpick = 1
402 AC                   write     tdrec                                78
402 AC                   endif
402 A*
402 AC                   endsr
     *----------------------------------------------------------------
     *
     *  CRTTH    Create TRUCKH record.
     *
     C     crtth         begsr
     C                   eval      thwhse = $pwhse
     C                   eval      thtruk = t#truk
     C                   movel     @desc1        thdesc
     C                   eval      throws = 0
     C                   eval      thcols = 2
     C                   eval      thbulk = 'N'
     C                   eval      thbat = 'N'
     C                   write     threc                                78
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CRTZH    Create ZONEH record.
     *
     C     crtzh         begsr
     *  Note:  For fixed section the compartment should be 'F', if
     *         department = 'FRZ', 'FRZN', 'FREEZ'. If department=
     *         'REF' then set it to 'R' otherwise set to 'D'.
     *         For PIR section the compartment should be ' ' and the
     *         parent zone should be its corresponding fixed zone.
     *         If no corresponding fixed zone exists then set the
     *         compartment to 'F','R'or 'D' and the parent zone to ' '
     *
402 A*
402 A*  Initialize zone fields.
402 A*
402 AC                   eval      s#zone = *blanks
402 AC     slwhdp        cat       slstyp:0      s#zone
402 AC                   eval      zhwhse = slwhse
402 AC                   eval      zhtruk = thtruk
402 AC                   eval      zhzone = %trimr(slwhdp) + slstyp
402 AC                   movel     @desc1        zhdesc
402 AC                   eval      zhdrop = *blanks
402 A*
402 A*  Determine truck compartment for zone.
402 A*
402 AC                   select
402 AC                   when      slwhdp = 'FRZ  '  or
402 AC                             slwhdp = 'FRZN '  or
402 AC                             slwhdp = 'FREEZ'
402 AC                   eval      comp = 'F'
402 AC                   when      slwhdp = 'REF  '
402 AC                   eval      comp = 'R'
402 AC                   other
402 AC                   eval      comp = 'D'
402 AC                   endsl
402 A*
402 A*  Determine zone type: Truck compartment, Merge.
402 A*
402 AC                   select
402 A*
402 A*    First dept/styp zone for a compartment is assigned
402 A*      to that compartment.
402 A*
402 AC                   when      comp = 'D'  and
402 AC                             zondry = *blanks  or
402 AC                             comp = 'R'  and
402 AC                             zonref = *blanks  or
402 AC                             comp = 'F'  and
402 AC                             zonfrz = *blanks
402 A*
402 AC                   eval      zhgen = 1
402 AC                   eval      zhcomp = comp
402 AC                   eval      zhpzon = *blanks
402 AC                   select
402 AC                   when      comp = 'D'
402 AC                   eval      zondry = zhzone
402 AC                   when      comp = 'R'
402 AC                   eval      zonref = zhzone
402 AC                   when      comp = 'F'
402 AC                   eval      zonfrz = zhzone
402 AC                   endsl
402 A*
402 A*    Otherwise, the dept/styp zone becomes a merge zone which is
402 A*      merged into the zone already assigned to the compartment.
402 A*
402 AC                   other
402 A*
402 AC                   eval      zhgen = 2
402 AC                   eval      zhcomp = *blanks
402 AC                   select
402 AC                   when      comp = 'D'
402 AC                   eval      zhpzon = zondry
402 AC                   when      comp = 'R'
402 AC                   eval      zhpzon = zonref
402 AC                   when      comp = 'F'
402 AC                   eval      zhpzon = zonfrz
402 AC                   endsl
402 A*
402 AC                   endsl
402 A*
402 A*   Create record.
402 A*
402 AC                   write     zhrec                                78
402 D*
402 D***** Start 4.02 Delete  (Original Routine) *****
402 D*
402 D*                    MOVE *BLANKS   S#ZONE
402 D*          SLWHDP    CAT  SLSTYP:0  S#ZONE
402 D*          ZHKEY     CHAINZONEH                79
402 D*  Zone does not exist, add it.
402 D*          *IN79     IFEQ *ON
402 D*                    Z-ADDSLWHSE    ZHWHSE
402 D*                    MOVE THTRUK    ZHTRUK
402 D*          SLWHDP    CAT  SLSTYP:0  ZHZONE
402 D*                    MOVEL@DESC1    ZHDESC
402 D*                    SELEC
402 D*          SLSTYP    WHEQ 'F'
402 D*
402 D*                    SELEC
402 D*          SLWHDP    WHEQ 'FRZ  '
402 D*          SLWHDP    OREQ 'FRZN '
402 D*          SLWHDP    OREQ 'FREEZ'
402 D*                    MOVE 'F'       ZHCOMP
402 D*          SLWHDP    WHEQ 'REF  '
402 D*                    MOVE 'R'       ZHCOMP
402 D*                    OTHER
402 D*                    MOVE 'D'       ZHCOMP
402 D*                    ENDSL
402 D*                    MOVE *BLANKS   ZHPZON
402 D*
402 D*          SLSTYP    WHEQ 'P'
402 D*                    MOVE *BLANKS   S#ZONE
402 D*          SLWHDP    CAT  'F':0     S#ZONE
402 D*          ZHKEY     CHAINZONEH               N79
402 D*                    Z-ADDSLWHSE    ZHWHSE
402 D*                    MOVE THTRUK    ZHTRUK
402 D*          SLWHDP    CAT  SLSTYP:0  ZHZONE
402 D*                    MOVEL@DESC1    ZHDESC
402 D*                    MOVE ' '       ZHCOMP
402 D*  - Match found
402 D*          *IN79     IFEQ *OFF
402 D*                    MOVE S#ZONE    ZHPZON
402 D*                    ENDIF
402 D*  - Match NOT found
402 D*          *IN79     IFEQ *ON
402 D*                    SELEC
402 D*          SLWHDP    WHEQ 'FRZ  '
402 D*          SLWHDP    OREQ 'FRZN '
402 D*          SLWHDP    OREQ 'FREEZ'
402 D*                    MOVE 'F'       ZHCOMP
402 D*          SLWHDP    WHEQ 'REF  '
402 D*                    MOVE 'R'       ZHCOMP
402 D*                    OTHER
402 D*                    MOVE 'D'       ZHCOMP
402 D*                    ENDSL
402 D*                    MOVE *BLANKS   ZHPZON
402 D*                    ENDIF
402 D*
402 D*                    ENDSL
402 D*
402 D*          SLSTYP    IFEQ 'F'
402 D*                    Z-ADD1         ZHGEN
402 D*                    ENDIF
402 D*
402 D*          SLSTYP    IFEQ 'P'
402 D*                    Z-ADD2         ZHGEN
402 D*                    ENDIF
402 D*
402 D*                    MOVE *BLANKS   ZHDROP
402 D*
402 D*                    WRITEZHREC
402 D*                    ENDIF
402 D*
402 D***** End 4.02 Delete  (Original Routine) *****
402 D*
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CRTZD    Create ZONED record.
     *
     C     crtzd         begsr
     C                   eval      zdwhse = slwhse
     C                   eval      zdtruk = zhtruk
     C                   eval      zdzone = zhzone
     C                   eval      zdwhdp = slwhdp
     C                   eval      zdstyp = slstyp
     C                   eval      zdaisl = *blanks
     C                   eval      zdrlvl = 0
     C                   eval      zdloc1 = 0
     C                   eval      zdloc2 = 0
     *
     C                   write     zdrec                                78
     C                   endsr
     *----------------------------------------------------------------
     *
     *  EXIST    Record exists - make it unique before adding.
     *
     C     exist         begsr
     C     thkeys        setgt     truckh
     C                   readp(n)  truckh                                 78
     C                   select
     *
     C                   when      not *in78  and
     C                             $ptype = '*NORMAL '
     C                   eval      dstruk = thtruk
     C                   move      dsdgt         digit
     C                   add       1             digit
     C                   move      digit         dsdgt
     C                   eval      t#truk = dstruk
     *
     C                   when      not *in78  and
     C                             $ptype = '*WILLCAL'
     C                   eval      dstruk = thtruk
     C                   move      dsdgw         digit
     C                   add       1             digit
     C                   move      digit         dsdgw
     C                   eval      t#truk = dstruk
     C                   endsl
     *
     C                   exsr      crtth
     *
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     **                   WRITEMSGCTL
     C                   eval      msgk = *zeros
     **                   WRITEMSGCLR
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
     **                   WRITEMSGCTL
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
     **                   WRITEMSGREC
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     **                   WRITEMSGREC
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     **                   WRITECLRSCR
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
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      forevr = *off
     C                   z-add     $whse         $pwhse
     *
     *  Define key for TRUCKH file.
     *
     C     thkeyt        klist
     C                   kfld                    $pwhse
     C                   kfld                    t#truk
     *
     *  Define key for TRUCKH file.
     *
     C     thkeys        klist
     C                   kfld                    $pwhse
     C                   kfld                    s#truk
     *
     *  Define partial key for TRUCKH file.
     *
     C     thkeyp        klist
     C                   kfld                    $pwhse
     *
     *  Define partial key for ZONEH file.
     *
     C     zhkeyp        klist
     C                   kfld                    $pwhse
     C                   kfld                    thtruk
     *
     *  Define key for ZONEH file.
     *
     C     zhkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    thtruk
     C                   kfld                    s#zone
     *
     *  Define partial key for ZONED1 file.
     *
     C     zd1key        klist
     C                   kfld                    $pwhse
     C                   kfld                    thtruk
     C                   kfld                    zhzone
     *
402 AC                   eval      zondry = *blanks
402 AC                   eval      zonref = *blanks
402 AC                   eval      zonfrz = *blanks
     *
     C                   move      $pwhse        whsea
     C                   move      #prog         $pprg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     C     endupd        endsr
