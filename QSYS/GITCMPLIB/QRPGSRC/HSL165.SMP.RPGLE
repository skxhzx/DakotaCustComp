     H option(*nodebugio)
     F*----------------------------------------------------------------
     F*   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     F*   West Chicago, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  HSL165    Retrieve up to 5 Dakota slot locations
     F*  08 February 2005
     F*  Max Blacknik
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
500 AF*   02/08/05  MLB  5.00
     F*     - Enh: Revised program to add support for Client id
     F*
600aAF*   09/14/05  RLP  6.00a
     F*     - Replace /COPY statements for WebSmart project.
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: BiRite
     F*
BIR AF*   02/08/05  MLB  BIR
     F*     - Enh: Revised program to look for overflow slots if no
     F*       pick slots are found for item.
     F*     - Enh: Revised program to convert Dakota slot display into
     F*       BiRite slot format.
BIR1AF*   02/24/05  MLB  BIR1
     F*    - Revised program to extract first 7 characters of slot
     F*      display to update host item balance file. Slots with
     F*      levels >= 10 will be converted to letter J-Z.
BIR2AF*  03/01/05  MLB  BIR2
     F*    - Revised program to change format for slot when updated in
     F*      host files. Ex E101-7A.
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  79        CHAIN INDICATOR
     F*  90        OVERFLOW INDICATOR FOR EXCEPTION REPORT
     F*  91        OVERFLOW INDICATOR FOR CATCH WEIGHT REPORT
     F*  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FEXPFQTY   IF   E           K DISK
     Fhwlink    IF   E           K DISK
     FPIRITEM   IF   E           K DISK
     FPIRITEM3  IF   E           K DISK
     F                                     RENAME(ITREC:ITREC3)
     FITEMLNK   IF   E           K DISK
     FSLOT3     IF   E           K DISK
500 AD*----------------------------------------------------------------
500 AD*  Customer id
500 AD*----------------------------------------------------------------
500 AD @GETCL          C                   CONST('GETCLIENT')
500 A *
600aD */COPY QCOPYSRC,ID#ANDREWS
600aAD andrews         c                   'ANDREWS'
600aD */COPY QCOPYSRC,ID#BIRITE
600aAD birite          c                   'BIRITE'
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
     D*----------------------------------------------------------------
     D*  Constants
BIR AD letters         C                   CONST('ABCDEFGHIJKLMNOPQRSTUVWXYZ')
BIR AD digits          C                   CONST('0123456789')
     D pos             s              3S 0
     D aisle           s              3A
     D Loc             s              3A
     D Lvlhnd          s              4A
BIR AD jlvl            s              2
BIR1AD jlvl2           s              2
BIR1AD jlvl3           s              1
BIR AD jhand           s              2
BIR AD wkdisp          s                    like(sldisp)
BIR1AD wkdisp7         s              7
     D svcmpn          s                    like($pcmpn) inz(' ')
     D svdivn          s                    like($pdivn) inz(' ')
     D svdptn          s                    like($pdptn) inz(' ')
     D svwhsn          s                    like($pwhsn) inz(' ')
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD8I                25     32
     D  $CVD6O                33     38  0
     D  $CVD8O                39     46  0
     D  $CVSTO                47     64
     D  $CVRTN                65     72
     D  $CVERM                73    132
     D  $CVMSG                73     76
     D*----------------------------------------------------------------
     D*  Program info data structure
     D*
     D                SDS
     D  #PROG            *PROC
     D  #JOB                 244    253
     D  #USER                254    263
     D  #JOBN                264    269
     D  #JOBDT               276    281  0
     D  #JOBTM               282    287  0
     I*----------------------------------------------------------------
     I*  PIRITEM3 renamed fields
     I*
     IITREC3
     I              ITWHSE                      ITWHS3
     I              ITITEM                      ITITM3
     I              ITTYPE                      ITTYP3
     I              ITDESC                      ITDSC3
     I              ITSTYP                      ITSTP3
     I              ITWHDP                      ITWHP3
     I              ITDESG                      ITDSG3
     I              ITACTV                      ITACT3
     I              ITUPC                       ITUPC3
     I              ITBLD                       ITBLD3
     I              ITVEN#                      ITVNR3
     I              ITVIT#                      ITVIT3
     I              ITPDSC                      ITPDS3
     I              ITUM1                       ITUM13
     I              ITUM2                       ITUM23
     I              ITUMQ2                      ITUQ23
     I              ITFLG1                      ITFL13
     I              ITUM3                       ITUM33
     I              ITUMQ3                      ITUQ33
     I              ITFLG2                      ITFL23
     I              ITULEN                      ITULN3
     I              ITUWDT                      ITUWD3
     I              ITUHGT                      ITUHG3
     I              ITCUBE                      ITCBU3
     I              ITSWGT                      ITSWG3
     I              ITCWGT                      ITCWG3
     I              ITREOR                      ITROR3
     I              ITREPL                      ITRPL3
     I              ITRCVD                      ITRCD3
     I              ITFLGD                      ITFLD3
     I              ITFLGB                      ITFLB3
     I              ITSLIF                      ITSLF3
     I              ITNDAY                      ITNDY3
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PCMD    *CLOSE   - End program with *INLR = *On
     C*      $PCMD    *GETITEM - Get item qty record for item.
     C*      $PCMD    *GETSLOT - Get slot(s) for item
     C*      $PCMPN   Host company number
     C*      $PDIVN   Host division number
     C*      $PDPTN   Host department/location number
     C*      $PWHSN   Host warehouse number
     C*      $PITMN   Host item number
     C*
     C*    Returned Parameters
     C*      $Pslot1   1st pick/overflow slot for item
     C*      $Pslot2   2nd pick/overflow slot for item
     C*      $Pslot3   3rd pick/overflow slot for item
     C*      $Pslot4   4th pick/overflow slot for item
     C*      $Pslot5   5th pick/overflow slot for item
     C*      $Preturn  *OK    - One or more slots found.
     C*                *ERROR - No slots found or item invalid.
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PCMD             8
     C                   PARM                    $PCMPN            3
     C                   PARM                    $PDIVN            3
     C                   PARM                    $PDPTN            3
     C                   PARM                    $PWHSN            3
     C                   PARM                    $PITMN           10
     C                   PARM                    $Pslot1          12
     C                   PARM                    $Pslot2          12
     C                   PARM                    $Pslot3          12
     C                   PARM                    $Pslot4          12
     C                   PARM                    $Pslot5          12
     C                   PARM                    $Preturn          8
     C*
     C*----------------------------------------------------------------
     C*  Main line
     C*
     C                   select
     C                   when      $pcmd <> '*CLOSE'
     C
     C                   exsr      zzinz2
     C*
     C*  Set beginning limits on appropriate file.
     C*
     C                   if        nxtprc <> 'EOF'
      *
     C                   MOVE      '*LEFT   '    DIRCTN
     C                   MOVE (p)  $PITMN        WKIT11
     C                   EXSR      ZZLTRT
     C                   MOVEl(p)  WKIT15        Kyitem
     C*
     C                   select
     C                   when      $pcmd = '*GETITEM'
     C     keyit         chain     expfqty
     C                   if        not %found(expfqty)
     C                   eval      qedsp1 = ' '
     C                   eval      qedsp2 = ' '
     C                   eval      qedsp3 = ' '
     C                   endif
     C
     C                   eval      $pslot1 = qedsp1
     C                   eval      $pslot2 = qedsp2
     C                   eval      $pslot3 = qedsp3
     C
     C*    Retrieve slots for item.
     C                   when      $pcmd = '*GETSLOT'
     C
     C*  Retrieve item master record.
     C*
     C                   CLEAR                   ILITM2
     C                   CLEAR                   ILITM3
     C     KEYIT         chain     PIRITEM
     C*
     C*      Process item if Master item found.
     C*
     C                   select
     C                   when      not %found(piritem)
     C                   eval      ittype = ' '
     C                   eval      itstyp = ' '
     C                   eval      itwhdp = ' '
     C
     C                   when      %found(piritem)
     C*
     C*    Get corresponding base item.
     C*
     C     ITTYPE        IFNE      ' '
     C     KEYIL         CHAIN     ITEMLNK                            78
     C     *IN78         IFEQ      *ON
     C                   CLEAR                   ILITM2
     C                   CLEAR                   ILITM3
     C                   ENDIF
     C                   ENDIF
BIR AC*
     C                   Endsl
     C*
     C*  Get pick slots for item (max of 5) or Overflow slots if no picks.
     C*
     C                   EXSR      GETPCK
     C                   endsl
     C*
BIR AC*      Convert Dakota slot into BiRite format.
BIR AC                   if        Client = BiRite
BIR AC*
BIR AC                   if        $pslot1 > ' '
BIR AC                   eval      wkdisp = $pslot1
BIR AC                   exsr      ZZcvtslot
BIR AC                   eval      $pslot1= wkdisp
BIR AC                   Endif
BIR AC*
BIR AC                   if        $pslot2 > ' '
BIR AC                   eval      wkdisp = $pslot2
BIR AC                   exsr      ZZcvtslot
BIR AC                   eval      $pslot2= wkdisp
BIR AC                   Endif
BIR AC*
BIR AC                   if        $pslot3 > ' '
BIR AC                   eval      wkdisp = $pslot3
BIR AC                   exsr      ZZcvtslot
BIR AC                   eval      $pslot3= wkdisp
BIR AC                   Endif
BIR AC*
BIR AC                   if        $pslot4 > ' '
BIR AC                   eval      wkdisp = $pslot4
BIR AC                   exsr      ZZcvtslot
BIR AC                   eval      $pslot4= wkdisp
BIR AC                   Endif
BIR AC*
BIR AC                   if        $pslot5 > ' '
BIR AC                   eval      wkdisp = $pslot5
BIR AC                   exsr      ZZcvtslot
BIR AC                   eval      $pslot5= wkdisp
BIR AC                   Endif
BIR AC*
BIR AC                   Endif
     C*
     C                   Endif
     C*
     C                   when      $Pcmd = '*CLOSE'
     C                   eval      *inlr = *on
     C*
     C                   endsl
     C*
     C*    Set Return flag with status of operation.
     C                   select
     C                   when         scount > 0
     C                             or $pcmd = '*CLOSE'
     C                   eval      $preturn = '*OK     '
     C                   other
     C                   eval      $preturn = '*ERROR  '
     C                   endsl
     C
     C                   RETURN
     C*
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     C     *INZSR        BEGSR
500 AC*
500 A* Get client id.
500 AC*
500 AC                   CALL      @GETCL
500 AC                   PARM                    CLIENT           10
500 AC*
     C*
     C*  Define key for HWLINK file.
     C*
     C     KEYHW         KLIST
     C                   KFLD                    $pcmpn
     C                   KFLD                    $pdivn
     C                   KFLD                    $pdptn
     C                   KFLD                    $pwhsn
     C*
     C*  Define key for PIRITEM3 file.
     C*
     C     KEYIT3        KLIST
     C                   KFLD                    KYITEM
     C                   KFLD                    HWWHSE
     C*
     C*  Define key for PIRITEM file.
     C*
     C     KEYIT         KLIST
     C                   KFLD                    HWWHSE
     C                   KFLD                    KYITEM
     C*
     C*  Define key for ITEMLNK file.
     C*
     C     KEYIL         KLIST
     C                   KFLD                    HWWHSE
     C                   KFLD                    ITITEM
     C     KEYIL3        KLIST
     C                   KFLD                    HWWHSE
     C                   KFLD                    KYITEM
     C*
     C*  Define partial key for SLOT3 file.
     C*
     C     *LIKE         DEFINE    SLITEM        KYITEM
     C     *LIKE         DEFINE    SLSTAT        KYSTAT
     C     *LIKE         DEFINE    SLPICK        KYPICK
     C     KEYSL3        KLIST
     C                   KFLD                    HWWHSE
     C                   KFLD                    KYITEM
     C                   KFLD                    KYSTAT
     C                   KFLD                    KYPICK
     C*
     C*  Variables and constants.
     C*
     C                   MOVE      *OFF          FOREVR            1
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  GETPCK  Get pick slots for item (max of 5)
     C*
     C     GETPCK        BEGSR
     C                   Z-ADD     0             SCOUNT            3 0
     C*
     C*  If Contract or SSB item
     C*   Then use Base item to look for slots
     C*   Otherwise use record item
     C*
     C     ITTYPE        IFEQ      'C'
     C     ITTYPE        OREQ      'S'
     C*   Then use Base item to look for slots FOR ALIAS ITEMS.
     C     ITTYPE        OREQ      'A'
     C                   MOVE      ILITM2        KYITEM
     C                   ELSE
     C                   MOVE      ITITEM        KYITEM
     C                   ENDIF
     C*
     C*   If Alias item, get type for base item.
     C     ITTYPE        IFEQ      'A'
     C     KEYIT3        CHAIN     PIRITEM3                           76
     C     *IN76         IFEQ      *ON
     C                   MOVE      *BLANKS       ITTYP3
     C                   ENDIF
     C*
     C*   If base item for Alias is SSB, get Base item for SSB.
     C     ITTYP3        IFEQ      'S'
     C     KEYIL3        CHAIN     ITEMLNK                            78
     C     *IN78         IFEQ      *ON
     C                   CLEAR                   ILITM2
     C                   CLEAR                   ILITM3
     C                   ELSE
     C                   MOVE      ILITM2        KYITEM
     C                   ENDIF
     C                   ENDIF
     C*
     C                   ENDIF
     C*
     C*   Loop through picking slots for base item.
     C*
     C                   MOVE      'A '          KYSTAT
     C                   MOVE      'Y'           KYPICK
     C     KEYSL3        SETLL     SLOT3
     C     FOREVR        DOUNE     FOREVR
     C     KEYSL3        READE     SLOT3                                  77
     C     *IN77         IFEQ      *ON
     C                   LEAVE
     C                   ENDIF
     C*
     C*     Ignore slot if past expiration date.
     C*
     C     SLEXPD        IFNE      0
     C     SLEXPD        ANDLT     TODAY
     C                   ENDIF
     C*
     C*     Add to item's slots
     C*
     C                   ADD       1             SCOUNT
     C                   SELECT
     C     SCOUNT        WHENEQ    1
     C                   MOVE      SLDISP        $pslot1
     C     SCOUNT        WHENEQ    2
     C                   MOVE      SLDISP        $pslot2
     C     SCOUNT        WHENEQ    3
     C                   MOVE      SLDISP        $pslot3
     C     SCOUNT        WHENEQ    4
     C                   MOVE      SLDISP        $pslot4
     C     SCOUNT        WHENEQ    5
     C                   MOVE      SLDISP        $pslot5
     C                   LEAVE
     C                   ENDSL
     C*
     C                   ENDDO
BIR AC*
BIR AC     CLIENT        IFEQ      BIRITE
BIR AC*
BIR AC*    Look for overflow slots when no pick slot(s) found.
BIR AC     SCOUNT        IFEQ      0
BIR AC                   MOVE      'A '          KYSTAT
BIR AC                   MOVE      'N'           KYPICK
BIR AC     KEYSL3        SETLL     SLOT3
BIR AC     FOREVR        DOUNE     FOREVR
BIR AC     KEYSL3        READE     SLOT3                                  77
BIR AC     *IN77         IFEQ      *ON
BIR AC                   LEAVE
BIR AC                   ENDIF
BIR AC*
BIR AC*     Add to item's slots
BIR AC*
BIR AC                   ADD       1             SCOUNT
BIR AC                   SELECT
BIR AC     SCOUNT        WHENEQ    1
BIR AC                   MOVE      SLDISP        $pslot1
BIR AC     SCOUNT        WHENEQ    2
BIR AC                   MOVE      SLDISP        $pslot2
BIR AC     SCOUNT        WHENEQ    3
BIR AC                   MOVE      SLDISP        $pslot3
BIR AC     SCOUNT        WHENEQ    4
BIR AC                   MOVE      SLDISP        $pslot4
BIR AC     SCOUNT        WHENEQ    5
BIR AC                   MOVE      SLDISP        $pslot5
BIR AC                   LEAVE
BIR AC                   ENDSL
BIR AC*
BIR AC                   ENDDO
BIR AC                   ENDIF
BIR AC                   ENDIF
     C*
     C                   ENDSR
      *----------------------------------------------------------------
      *
      *  ZZCVTSLOT    Convert Slot into Birite format.
      *
     C     ZZCVTSLOT     BEGSR
     C*
     C                   Eval      pos    = 0
     C                   Eval      aisle  = ' '
     C                   Eval      loc    = ' '
     C                   Eval      lvlhnd = ' '
     C*
     C*    Look for Dakota slot separators.
     C     '-'           scan      wkdisp:1      POS
     C                   select
     C*
     C*      Slot has 1 character aisle code.
     C                   when      pos = 2
     C     1             subst     wkdisp:1      aisle
     C*
     C*      Slot has 2 character aisle code.
     C                   when      pos = 3
     C     2             subst     wkdisp:1      aisle
     C*
     C*      Slot has 3 character aisle code.
     C                   when      pos = 4
     C     3             subst     wkdisp:1      aisle
     C*
     C                   Endsl
     C*
     C*      Extract slot location.
     C                   eval      pos = pos + 1
     C     3             subst     wkdisp:Pos    loc
     C*
     C*      Extract slot rack level/handstack.
     C                   eval      pos = pos + 4
     C     4             subst     wkdisp:Pos    Lvlhnd
     C*
     C*      Convert slot into Host format.
     C                   select
     C*
     C                   when         Client <> BiRite
     C*
     C*     Default slot format: XXYYYZZZ X=aisle, Y=location,
     C*                                   Z=Racklvl+handstack.
     C                   eval      wkdisp  = %trim(aisle) + %trim(loc) +
     C                             %trim(lvlhnd)
     C*
     C*
BIR AC                   when      Client = BiRite
BIR AC*
BIR2MC*     BiRite (Fixed) slot format: XYYY-ZZ  Where X=aisle, Y=location,
BIR AC*     -or-                                      Z=Racklvl + handstack.
BIR2MC*     BiRite (PIR) slot format: XYYY-ZZ  Where X=aisle, Y=location,
BIR AC*     -or-                                       Z=Racklvl + handstack.
BIR AC                   Exsr      ZZcvtlevel
BIR AC*
BIR AC*    Build PIR item slot format.
BIR AC                   if        itstyp = 'P'
BIR1DC*                  eval      wkdisp  = %trim(aisle) + %trim(jlvl) +
BIR1DC*                            %trim(loc) + %trim(jhand)
BIR2DC*                  eval      wkdisp  = %subst(qedsp1:1:7)
BIR2MC                   eval      wkdisp  = %trim(aisle) + %trim(loc) +
BIR2MC                             '-' + %trim(jlvl2) + %trim(jhand)
BIR AC*
BIR AC*    Build Fixed item slot format.
BIR AC                   else
BIR1DC*                  eval      wkdisp  = %trim(aisle) + %trim(loc) +
BIR1DC*                            %trim(jlvl) + %trim(jhand)
BIR2DC*                  eval      wkdisp  = %subst(qedsp1:1:7)
BIR2MC                   eval      wkdisp  = %trim(aisle) + %trim(loc) +
BIR2MC                             '-' + %trim(jlvl2) + %trim(jhand)
BIR AC*
BIR AC                   Endif
BIR1AC*
BIR1AC*    Convert slots with level greater than 10 to character.
BIR1AC*    Example V-301-10 will look like this V-301-J.
BIR1AC                   if        jlvl  >= 'J '
BIR2DC*                  eval      jlvl3 = %subst(jlvl:1:1)
BIR2DC*                  movel     wkdisp        wkdisp7
BIR2DC*                  move      jlvl3         wkdisp7
BIR2DC*                  movel(p)  wkdisp7       wkdisp
BIR1AC                   endif
BIR AC*
     C                   Endsl
     C*
     C                   ENDSR
BIR AC*----------------------------------------------------------------
BIR AC*
BIR AC*  ZZCVTLEVEL   Convert numeric rack level into alphabetic level.
BIR AC*
BIR AC     ZZCVTLEVEL    BEGSR
BIR AC*
BIR AC                   eval      jlvl  = *blanks
BIR AC                   eval      jhand = *blanks
BIR AC*
BIR AC     digits        check     lvlhnd:1      POS
BIR AC                   select
BIR AC*
BIR AC*      Slot has 1 digit level.
BIR AC                   when      pos = 2
BIR AC     1             subst     lvlhnd:1      jlvl
BIR AC     1             subst     lvlhnd:2      jhand
BIR AC*
BIR AC*      Slot has 2 digit level.
BIR AC                   when      pos = 3
BIR AC     2             subst     lvlhnd:1      jlvl
BIR AC     1             subst     lvlhnd:3      jhand
BIR AC*
BIR AC                   Endsl
BIR1AC                   eval      jlvl2 = jlvl
BIR AC*
BIR AC                   select
BIR AC                   when      jlvl = '1 '
BIR AC                   eval      jlvl = 'A '
BIR AC                   when      jlvl = '2 '
BIR AC                   eval      jlvl = 'B '
BIR AC                   when      jlvl = '3 '
BIR AC                   eval      jlvl = 'C '
BIR AC                   when      jlvl = '4 '
BIR AC                   eval      jlvl = 'D '
BIR AC                   when      jlvl = '5 '
BIR AC                   eval      jlvl = 'E '
BIR AC                   when      jlvl = '6 '
BIR AC                   eval      jlvl = 'F '
BIR AC                   when      jlvl = '7 '
BIR AC                   eval      jlvl = 'G '
BIR AC                   when      jlvl = '8 '
BIR AC                   eval      jlvl = 'H '
BIR AC                   when      jlvl = '9 '
BIR AC                   eval      jlvl = 'I '
BIR AC                   when      jlvl = '10'
BIR AC                   eval      jlvl = 'J '
BIR AC                   when      jlvl = '11'
BIR AC                   eval      jlvl = 'K '
BIR AC                   when      jlvl = '12'
BIR AC                   eval      jlvl = 'L '
BIR AC                   when      jlvl = '13'
BIR AC                   eval      jlvl = 'M '
BIR AC                   when      jlvl = '14'
BIR AC                   eval      jlvl = 'N '
BIR AC                   when      jlvl = '15'
BIR AC                   eval      jlvl = 'O '
BIR AC                   when      jlvl = '16'
BIR AC                   eval      jlvl = 'P '
BIR AC                   when      jlvl = '17'
BIR AC                   eval      jlvl = 'Q '
BIR AC                   when      jlvl = '18'
BIR AC                   eval      jlvl = 'R '
BIR AC                   when      jlvl = '19'
BIR AC                   eval      jlvl = 'S '
BIR AC                   when      jlvl = '20'
BIR AC                   eval      jlvl = 'T '
BIR AC                   when      jlvl = '21'
BIR AC                   eval      jlvl = 'U '
BIR AC                   when      jlvl = '22'
BIR AC                   eval      jlvl = 'V '
BIR AC                   when      jlvl = '23'
BIR AC                   eval      jlvl = 'W '
BIR AC                   when      jlvl = '24'
BIR AC                   eval      jlvl = 'X '
BIR AC                   when      jlvl = '25'
BIR AC                   eval      jlvl = 'Y '
BIR AC                   when      jlvl = '26'
BIR AC                   eval      jlvl = 'Z '
BIR AC                   endsl
BIR AC*
BIR AC                   ENDSR
     C*
      *----------------------------------------------------------------
      *
      *  ZZINZ2   Program initialization. Called from main line.
      *
     C     ZZINZ2        BEGSR
      *
      *    Retrieve warehouse to process.
      *
     C                   if           $pcmpn <> svcmpn
     C                             or $pdivn <> svdivn
     C                             or $pdptn <> svdptn
     C                             or $pwhsn <> svwhsn
      *
     C     keyhw         chain     HWLINK
     C                   SELECT
     C                   when      not %found(hwlink)
     C                   MOVE      'EOF'         NXTPRC            3
     C                   ENDSL
     C*
     C*    Fill save fields.
     C                   eval      svcmpn = $pcmpn
     C                   eval      svdivn = $pdivn
     C                   eval      svdptn = $pdptn
     C                   eval      svwhsn = $pwhsn
     C*
     C                   endif
      *
      *      Clear working fields.
     C                   MOVE      *BLANKS       WKIT11           11
     C                   MOVE      *BLANKS       WKIT15           15
     C                   MOVE      *BLANKS       DIRCTN            8
     C                   eval      scount = 0
      *
      *      Clear slot fields being sent back to calling pgm.
      *
     C                   eval      $pslot1 = ' '
     C                   eval      $pslot2 = ' '
     C                   eval      $pslot3 = ' '
     C                   eval      $pslot4 = ' '
     C                   eval      $pslot5 = ' '
     C*
     C*  Convert today's date into century format.
     C*
     C                   MOVE      '*CURCMD '    $CVCMD
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD8O        TODAY             8 0
      *
     C                   ENDSR
      *----------------------------------------------------------------
      *
      *  ZZLTRT   Make item number left/right justified.
      *
     C     ZZLTRT        BEGSR
     C                   SELECT
     C     DIRCTN        WHENEQ    '*LEFT   '
     C                   MOVE      *BLANKS       WKIT15
     C                   EVAL      WKIT15 = %TRIM(WKIT11)
      *
     C     DIRCTN        WHENEQ    '*RIGHT  '
     C                   MOVE      *BLANKS       WKIT11
     C                   EVALR     WKIT11 = %TRIMR(WKIT15)
      *
     C                   ENDSL
     C                   ENDSR
