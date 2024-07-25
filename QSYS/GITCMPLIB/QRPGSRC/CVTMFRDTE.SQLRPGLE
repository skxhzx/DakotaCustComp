      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CVTMFRDTE    Convert Mfr date code
     *  25 September 2007
     *  Dave Sommerville
     *
     *  Revisions
     *
510 A*    09/25/07  DAS  5.10
     *      - Created.
510aA *    10/01/07  LMC  5.10a
      *      - Enh: Added the return of the def type
510bA *    10/02/07  LMC  5.10b
      *      - Fix: wrong field name for all four year fields check
510cA *    10/02/07  LMC  5.10c
      *      - Fix: Correct manufacturer field size to 11 positions
510dA *    10/08/07  LMC  5.10d
      *      - Enh: Add upc code
510eA *    10/10/07  LMC  5.10e
      *      - Enh: If no Day code is specified default to day 01
      *      - Enh: If the type is manufacturer date and there is no year
      *             code in the definition, check to make sure date is not
      *             greater than today, if so use previous year. This was
      *             added to handle items like produce at the beginning of
      *             the year.
510fA *    11/06/07  DAS  5.10f
      *      - Enh: Added logic for calculating week.
      *      - Enh: Removed "W3". Instead, user should define
      *        year separately and "Y4".
      *      - Enh: Added Year/Month custom code 001.
520aA *    03/04/08  DAS  5.20a
      *      - Enh: Added standard Spanish months.
520bA *    05/15/09  RBD  5.20b
      *      - Fix: If 2 digit year, allow it to be 2 years less
      *        than the current year.
      *
610aA *    11/23/09  DAS  6.10a
      *      - Revised routine getDefOvr to look for a Dakota
      *        item override with a blank upc code.
      *
610bA *    01/13/10  DAS  6.10b
      *      - Revised cvtyearnum to handle a Y4-only code correctly.
610cA *    08/31/10  RH   6.10c
      *      - Fix: Revised routine getDefOvr to look for a Mfg # /
      *        Dakota item override.
      *      - Fix: Add code to go to endgetdefovr if def found.
720aA *    03/13/18  DAS  7.20a
      *      - Added Week code WD for Day of Week. This value can be
      *        1 - 7 or A - G.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fmfrdate   if   e           k disk
     Fmfrtable  if   e           k disk
     Fmfritem   if   e           k disk
     Fmfritem3  if   e           k disk
     F                                     rename(mfirec:mfirec3)
510dAFmfritem4  if   e           k disk
510dAF                                     rename(mfirec:mfirec4)
610cAFmfritem7  if   e           k disk
610cAF                                     rename(mfirec:mfirec7)

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a15             s              1    dim(15)

     *----------------------------------------------------------------
     *  Constants / Variables
     *----------------------------------------------------------------

     D months          c                   '*JAN*FEB*MAR*APR*MAY*JUN-
     D                                     *JUL*AUG*SEP*OCT*NOV*DEC'
520aAD monthsSP        c                   '*ENE*FEB*MAR*ABR*MAY*JUN-
520aAD                                     *JUL*AGO*SEP*OCT*NOV*DIC'
     D numbers         c                   '0123456789'
     D yearTbl         c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ-
     D                                     0123456789'
720aAD wkdays          c                   '1234567ABCDEFG'
720aAD daysAlpha       c                   'ABCDEFG'
720aAD daysNum         c                   '1234567'

     D error           s               n
     D forever         s               n
     D found           s               n

     D y1flag          s               n
     D y2flag          s               n
     D y3flag          s               n
     D y4flag          s               n
     D m1flag          s               n
     D m2flag          s               n
     D m3flag          s               n
     D w1flag          s               n
     D w2flag          s               n
510fDD*w3flag          s               n
     D d1flag          s               n
     D d2flag          s               n
     D d3flag          s               n

720aAD wdflag          s               n
720aAD wd              s              1
720aAD wdnum           s              1  0

     D codeElem        s              1
     D count           s              3  0
     D defElem         s              2
     D defLen          s              3  0
     D i               s              3  0
510fAD jan1Date        s               d
510fAD jan1DOW         s              1  0
     D julDatets       s               d
     D kymfr#          s                   like(mdmfr#)
     D kydef#          s                   like(mddef#)
     D kytype          s                   like(mttype)
610aAD kyupc           s                   like(mfiupc)
     D monthCode       s              4
     D pos             s              3  0
510fAD temp2n          s              2  0
     D temp4a          s              4
520bAD twoYrsAgo       s              2  0
510fAD weekDate        s               d

     *----------------------------------------------------------------
     *  Date data structures
     *----------------------------------------------------------------

     D                 ds
     D  codeDate               1      8  0
     D    codeYear             1      4  0
     D    codeMonth            5      6  0
     D    codeDay              7      8  0

     D                 ds
     D  currDate               1      8  0
     D    currYear             1      4  0
     D    currY1               1      1  0
     D    currY2               2      2  0
     D    currY3               3      3  0
     D    currY4               4      4  0
     D    currMonth            5      6  0
     D    currDay              7      8  0
     D                 ds
     D  prevDate               1      8  0
     D    prevYear             1      4  0
     D    prevY1               1      1  0
     D    prevY2               2      2  0
     D    prevY3               3      3  0
     D    prevY4               4      4  0
     D    prevYear234          2      4  0
     D    prevYear34           3      4  0
     D    prevYear4            4      4  0
610bAD                 ds
610bAD  prv2Date               1      8  0
610bAD    prv2Year             1      4  0
610bAD    prv2Y1               1      1  0
610bAD    prv2Y2               2      2  0
610bAD    prv2Y3               3      3  0
610bAD    prv2Y4               4      4  0
610bAD    prv2Year234          2      4  0
610bAD    prv2Year34           3      4  0
610bAD    prv2Year4            4      4  0
     D                 ds
     D    maxYear              1      4  0
     D    maxY1                1      1  0
     D    maxY2                2      2  0
     D    maxY3                3      3  0
     D    maxY4                4      4  0
     D    maxYear234           2      4  0
     D    maxYear34            3      4  0
     D    maxYear4             4      4  0

     D                 ds
     D julDate                 1      7  0
     D  JulDateYear            1      4  0
     D  JulDateDay             5      7  0

     D                 ds
     D  Y1234                  1      4
     D  Y1234num               1      4  0
     D  Y234num                2      4  0
     D  Y34num                 3      4  0
510fAD  Y1num                  1      1  0
     D  Y4num                  4      4  0
     D  Y1                     1      1
     D  Y2                     2      2
     D  Y3                     3      3
     D  Y4                     4      4
     D                 ds
     D  M123                   1      3
510fAD  M123num                1      3  0
     D  M12                    1      2
     D  M12num                 1      2  0
     D  M1                     1      1
     D  M2                     2      2
     D  M3                     3      3
     D                 ds
510fDD**W123                   1      3
510fMD  W12                    1      2
     D  W12num                 1      2  0
     D  W1                     1      1
     D  W2                     2      2
510fDD**W3                     3      3
     D                 ds
     D  D12                    1      2
     D  D12num                 1      2  0
     D  D123                   1      3
     D  D123num                1      3  0
     D  D1                     1      1
     D  D2                     2      2
     D  D3                     3      3

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
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $pCmd     -  *MFRDATE
     *                  *INUSEDATE
     *     $pCode    -  Mfr code to decipher
     *     $pMfr#    -  Mfr number
     *     $pMfrItem -  Mfr item number
     *     $pDktItem -  Dakota item number
     *     $pMfrDef#    -  Mfr definition
510dA*     $pupc     -  upc code
     *
     *  Output parameters
     *
     *     $pDateCMD -  Extracted date in yyyymmdd format
     *     $pDateMDY -  Extracted date in mmddyy format
     *     $pReturn -  *OK        - Code extracted successfully
     *     $pMsg    -  Error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pCmd            10
     C                   parm                    $pCode           30
510cDC*                  parm                    $pMfr#           10 0
510cAC                   parm                    $pMfr#           11 0
     C                   parm                    $pMfrItem        15
     C                   parm                    $pDktItem        15
     C                   parm                    $pMfrDef#         2 0
     C                   parm                    $pDateCMD         8 0
     C                   parm                    $pDateMDY         6 0
     C                   parm                    $pReturn         10
     C                   parm                    $pMsg            60
510aAC                   parm                    $pdeftype         1
510dAC                   parm                    $pupc            20

     C                   eval      $pDateCMD = 0
     C                   eval      $pDateMDY = 0
     C                   eval      $pReturn  = 'ERROR'
     C                   eval      $pMsg     = ' '

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  Get Mfr code definition.

     C                   exsr      getDef
     C     error         cabeq     *on           bottom

     *  Extract elements from code

510fAC                   clear                   codeDate
     C                   clear                   Y1234
     C                   clear                   M123
510fDC**                 clear                   W123
510fMC                   clear                   W12
     C                   clear                   D123
     C                   eval      y1Flag = *off
     C                   eval      y2Flag = *off
     C                   eval      y3Flag = *off
     C                   eval      y4Flag = *off
     C                   eval      m1Flag = *off
     C                   eval      m2Flag = *off
     C                   eval      m3Flag = *off
     C                   eval      w1Flag = *off
     C                   eval      w2Flag = *off
510fDC**                 eval      w3Flag = *off
720aAC                   eval      wdFlag = *off
     C                   eval      d1Flag = *off
     C                   eval      d2Flag = *off
     C                   eval      d3Flag = *off

     C                   eval      defLen = %size($pCode) / 2
     C     1             do        defLen        i

     C                   eval      defElem = %subst(mdcode:(i*2-1):2)
     C                   eval      codeElem = %subst($pCode:i:1)
     C                   select

     C                   when      defElem = 'Y1'
     C                   eval      Y1 =  codeElem
     C                   eval      y1Flag = *on

     C                   when      defElem = 'Y2'
     C                   eval      Y2 =  codeElem
     C                   eval      y2Flag = *on

     C                   when      defElem = 'Y3'
     C                   eval      Y3 =  codeElem
     C                   eval      y3Flag = *on

     C                   when      defElem = 'Y4'
     C                   eval      Y4 =  codeElem
     C                   eval      y4Flag = *on

     C                   when      defElem = 'M1'
     C                   eval      M1 =  codeElem
     C                   eval      m1Flag = *on

     C                   when      defElem = 'M2'
     C                   eval      M2 =  codeElem
     C                   eval      m2Flag = *on

     C                   when      defElem = 'M3'
     C                   eval      M3 =  codeElem
     C                   eval      m3Flag = *on

     C                   when      defElem = 'D1'
     C                   eval      D1 =  codeElem
     C                   eval      d1Flag = *on

     C                   when      defElem = 'D2'
     C                   eval      D2 =  codeElem
     C                   eval      d2Flag = *on

     C                   when      defElem = 'D3'
     C                   eval      D3 =  codeElem
     C                   eval      d3Flag = *on

     C                   when      defElem = 'W1'
     C                   eval      W1 =  codeElem
     C                   eval      w1Flag = *on

     C                   when      defElem = 'W2'
     C                   eval      W2 =  codeElem
     C                   eval      w2Flag = *on

720aAC                   when      defElem = 'WD'
720aAC                   eval      WD =  codeElem
720aAC                   eval      wdFlag = *on

     C                   endsl

     C                   enddo

     *  Get current date

     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      currDate = $cvd8o
     C                   eval      prevDate = currDate
     C                   eval      prevYear = currYear - 1
610bAC                   eval      prv2Year = currYear - 2

     *  Decipher year

     C                   select
     C                   when      mdyear = 'C'
     C                   exsr      cvtYearCstm
     C                   when      mdyear = 'N'
     C                   exsr      cvtYearNum
     C                   when      mdyear = 'T'
     C                   exsr      cvtYearTbl
     C                   other
     C                   eval      codeYear = currYear
     C                   endsl
     C     error         cabeq     *on           bottom

     *  Decipher month

     C                   select
     C                   when      mdmnth = 'A'
     C                   exsr      cvtMonthStd
     C                   when      mdmnth = 'C'
     C                   exsr      cvtMonthCstm
     C                   when      mdmnth = 'N'
     C                   exsr      cvtMonthNum
     C                   when      mdmnth = 'T'
     C                   exsr      cvtMonthTbl
     C                   other
     C                   eval      codeMonth = 0
     C                   endsl
     C     error         cabeq     *on           bottom

     *  Decipher day

     C                   select
     C                   when      mdday = 'J'
     C                   exsr      cvtDayJul
     C                   when      mdday = 'N'
     C                   exsr      cvtDayNum
     C                   when      mdday = 'T'
     C                   exsr      cvtDayTbl
     C                   other
510eMC*                  eval      codeDay = 0
510fAC                   if        codeDay = 0
510eAC                   eval      codeDay = 1
510fAC                   endif
     C                   endsl
     C     error         cabeq     *on           bottom

     *  Decipher week

510fAC                   select
510fAC                   when      mdweek = 'C'
510fAC                   exsr      cvtWeekCstm
510fAC                   when      mdweek = 'N'
510fAC                   exsr      cvtWeekNum
510fAC                   endsl
510fAC     error         cabeq     *on           bottom

     *  Now return the date that was extracted.
     *    Not guaranteed to be a valid date.

510eA * if manufacture date is greater than today use prevyear for date
510eAC                   if        mdtype = '1'  and  mdyear = 'X' and
510eAC                             codedate > currdate
510eAC                   eval      codeyear = prevyear
510eAC                   endif
510eA
     C                   eval      $pDateCMD = codeDate

     C                   eval      $cvd8i = %char(codeDate)
     C                   eval      $cvcmd = '*CMDMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      $pDateMDY = $cvd6o

     C                   eval      $pReturn = 'OK'
510aAC                   eval      $pdeftype = mdtype

     C     bottom        tag
     C                   return

     *----------------------------------------------------------------
     *          Subroutines in Alphabetical Order
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *  Define full key for MFRDATE file.

     C     keymd         klist
     C                   kfld                    kyMfr#
     C                   kfld                    kyDef#

     *  Define partial key for MFRDATE file.

     C     keymdp        klist
     C                   kfld                    $pMfr#

     *  Define full key for MFRITEM file.

     C     keymfi        klist
     C                   kfld                    $pMfr#
     C                   kfld                    $pMfrItem
     C                   kfld                    $pDktItem

     *  Define full key for MFRITEM3 file.

     C     keymfi3       klist
     C                   kfld                    $pDktItem
     C                   kfld                    $pMfrItem

510dA*  Define full key for MFRITEM4 file.
510dA
510dAC     keymfi4       klist
510dAC                   kfld                    $pDktItem
610aAC                   kfld                    kyupc
510aDC**                 kfld                    $pupc
510dAC
610cA*  Define full key for MFRITEM7 file.
610cA
610cAC     keymfi7       klist
610cAC                   kfld                    $pMfr#
610cAC                   kfld                    $pDktItem
     *  Define full key for MFRTABLE file

     C     keymt         klist
     C                   kfld                    mdmfr#
     C                   kfld                    mddef#
     C                   kfld                    kyType

510fA*  Connect to local machine. The -842 return code indicates that the
510fA*  connection is already established.
510fA
510fAC/EXEC SQL
510fAC+ CONNECT RESET
510fAC/END-EXEC
510fAC                   if        sqlstt <> '00000'
510fAC                   endif
     *
     C                   eval      $cvprg = #prog
     C                   endsr

     *----------------------------------------------------------------
     *  decipherYear  Decipher year
     *----------------------------------------------------------------

     C     decipherYear  begsr
     C                   eval      error = *off

     *  getDef   Get code definition

     C                   endsr

     *----------------------------------------------------------------
     *  getDef   Get code definition
     *----------------------------------------------------------------

     C     getDef        begsr
     C                   eval      error = *off
     C                   eval      found = *off

     *  If def# sent, then use it.

     C                   if        $pMfrDef# > 0
     C                   eval      kyMfr# = $pMfr#
     C                   eval      kyDef# = $pMfrDef#
     C     keymd         chain     mfrDate
     C                   if        not %found
     C                   eval      error = *on
     C                   eval      $pReturn = 'INVLDDEF#'
     C                   eval      $pMsg = 'Definition '
     C                                   + %trim(%editc($pMfrDef#:'P'))
     C                                   + ' not found'
     C                   endif
     C                   goto      endGetDef
     C                   endif

     *  See if definition exists for item.

     C                   exsr      getDefOvr
     C     error         cabeq     *on           endGetDef

     *  Otherwise, see if default definition exists for Mfr.

     C                   if        not found
     C                   exsr      getDefDft
     C     error         cabeq     *on           endGetDef
     C                   endif

     *  If found, see if default definition exists for Mfr.

     C                   if        not found
     C                   eval      error = *on
     C                   eval      $pReturn = 'NODEF'
     C                   eval      $pMsg = 'No definition found for '
     C                                   + %trim(%editc($pmfr#:'Z'))
     C                                   + '/'
     C                                   + %trim($pMfrItem)
     C                                   + '/'
     C                                   + %trim($pDktItem)
     C                   goto      endGetDef
     C                   endif

     C     endGetDef     endsr

     *----------------------------------------------------------------
     *  getDefDft   Get default definition for Mfr
     *----------------------------------------------------------------

     C     getDefDft     begsr

     *  See if definition exists for item.

     C                   eval      count = 0
     C     keymdp        setll     mfrDate
     C                   dow       forever = forever
     C     keymdp        reade     mfrDate
     C                   if        %eof
     C                   leave
     C                   endif
     C                   if        mddflt <> 'Y'
     C                   iter
     C                   endif
     C                   eval      found = *on
     C                   leave
     C                   enddo

     C     endGetDefDft  endsr

     *----------------------------------------------------------------
     *  getDefOvr   Get overrid definition for item
     *----------------------------------------------------------------

     C     getDefOvr     begsr

     *  First, see if definition exists for Mfr/Mfr Item/Dkt Item

     C                   eval      count = 0
     C     keymfi        setll     mfrItem
     C                   dow       forever = forever
     C     keymfi        reade     mfrItem
     C                   if        %eof
     C                   leave
     C                   endif
     C                   eval      count = count + 1
     C                   leave
     C                   enddo

     *  If def found, get it, set on Found flag and get out.

     C                   if        count = 1
     C                   eval      kyMfr# = mfimf#
     C                   eval      kyDef# = mfidd#
     C     keymd         chain     mfrDate
     C                   if        %found
     C                   eval      found = *on
     C                   goto      endGetDefOvr
     C                   endif
     C                   endif

     *  Now see if definition exists for Dkt Item / Mfr Item

     C                   eval      count = 0
     C     keymfi3       setll     mfrItem3
     C                   dow       forever = forever
     C     keymfi3       reade     mfrItem3
     C                   if        %eof
     C                   leave
     C                   endif
     C                   eval      count = count + 1
     C                   enddo

     *  If more that 1 definition exists for item,
     *    Return an error.

     C                   if        count > 1
     C                   eval      error = *on
     C                   eval      $pReturn = 'MLTITMDEF'
     C                   eval      $pMsg = 'Multiple definitions exist for '
     C                                   + %trim(%editc($pmfr#:'Z'))
     C                                   + '/'
     C                                   + %trim($pMfrItem)
     C                                   + '/'
     C                                   + %trim($pDktItem)
     C                   goto      endGetDefOvr
     C                   endif

     *  If 1 definition found for item,
     *    Get definition and set Found flag.

     C                   if        count = 1
     C                   eval      kyMfr# = mfimf#
     C                   eval      kyDef# = mfidd#
     C     keymd         chain     mfrDate
     C                   if        %found
     C                   eval      found = *on
610cAC                   goto      endGetDefOvr
     C                   endif
     C                   endif

510dA*  Now see if definition exists for Dkt Item / upc code
610aA*    - Only if upc is not blank.
510dA
610aAC                   if        $pupc <> ' '
610aA
510dAC                   eval      count = 0
610aAC                   eval      kyupc = $pupc
510dAC     keymfi4       setll     mfrItem4
510dAC                   dow       forever = forever
510dAC     keymfi4       reade     mfrItem4
510dAC                   if        %eof
510dAC                   leave
510dAC                   endif
510dAC                   eval      count = count + 1
510dAC                   enddo
510dA
510dA*  If more that 1 definition exists for item,
510dA*    Return an error.
510dA
510dAC                   if        count > 1
510dAC                   eval      error = *on
510dAC                   eval      $pReturn = 'MLTITMDEF'
510dAC                   eval      $pMsg = 'Multiple definitions exist for '
510dAC                                   + %trim(%editc($pmfr#:'Z'))
510dAC                                   + '/'
510dAC                                   + %trim($pupc)
510dAC                                   + '/'
510dAC                                   + %trim($pDktItem)
510dAC                   goto      endGetDefOvr
510dAC                   endif
510dA
510dA*  If 1 definition found for item,
510dA*    Get definition and set Found flag.
510dA
510dAC                   if        count = 1
510dAC                   eval      kyMfr# = mfimf#
510dAC                   eval      kyDef# = mfidd#
510dAC     keymd         chain     mfrDate
510dAC                   if        %found
510dAC                   eval      found = *on
610cAC                   goto      endGetDefOvr
510dAC                   endif
510dAC                   endif
510dA
610aAC                   endif
610cA
610cA*  Now see if definition exists for Mfr# / Dkt Item
610cAC                   eval      count = 0
610cAC     keymfi7       setll     mfrItem7
610cAC                   dow       forever = forever
610cAC     keymfi7       reade     mfrItem7
610cAC                   if        %eof
610cAC                   leave
610cAC                   endif
610cAC                   eval      count = count + 1
610cAC                   enddo
610cA
610cA*  If more that 1 definition exists for item,
610cA*    Return an error.
610cA
610cAC                   if        count > 1
610cAC                   eval      error = *on
610cAC                   eval      $pReturn = 'MLTITMDEF'
610cAC                   eval      $pMsg = 'Multiple definitions exist for '
610cAC                                   + %trim(%editc($pmfr#:'Z'))
610cAC                                   + '/'
610cAC                                   + %trim($pupc)
610cAC                                   + '/'
610cAC                                   + %trim($pDktItem)
610cAC                   goto      endGetDefOvr
610cAC                   endif
610cA
610cA*  If 1 definition found for item,
610cA*    Get definition and set Found flag.
610cA
610cAC                   if        count = 1
610cAC                   eval      kyMfr# = mfimf#
610cAC                   eval      kyDef# = mfidd#
610cAC     keymd         chain     mfrDate
610cAC                   if        %found
610cAC                   eval      found = *on
610cAC                   goto      endGetDefOvr
610cAC                   endif
610cAC                   endif
610aA
610aA
610aA*  Now see if definition exists for Dkt Item / blank upc code
610aA
610aAC                   eval      count = 0
610aAC                   eval      kyupc = ' '
610aAC     keymfi4       setll     mfrItem4
610aAC                   dow       forever = forever
610aAC     keymfi4       reade     mfrItem4
610aAC                   if        %eof
610aAC                   leave
610aAC                   endif
610aAC                   eval      count = count + 1
610aAC                   enddo
610aA
610aA*  If more that 1 definition exists for item,
610aA*    Return an error.
610aA
610aAC                   if        count > 1
610aAC                   eval      error = *on
610aAC                   eval      $pReturn = 'MLTITMDEF'
610aAC                   eval      $pMsg = 'Multiple definitions exist for '
610aAC                                   + %trim(%editc($pmfr#:'Z'))
610aAC                                   + '/'
610aAC                                   + %trim($pupc)
610aAC                                   + '/'
610aAC                                   + %trim($pDktItem)
610aAC                   goto      endGetDefOvr
610aAC                   endif
610aA
610aA*  If 1 definition found for item,
610aA*    Get definition and set Found flag.
610aA
610aAC                   if        count = 1
610aAC                   eval      kyMfr# = mfimf#
610aAC                   eval      kyDef# = mfidd#
610aAC     keymd         chain     mfrDate
610aAC                   if        %found
610aAC                   eval      found = *on
610cAC                   goto      endGetDefOvr
610aAC                   endif
610aAC                   endif
610aA
     C     endGetDefOvr  endsr

     *----------------------------------------------------------------
     *  cvtDayJul   Convert day - Julian
     *----------------------------------------------------------------

     C     cvtDayJul     begsr
     C                   eval      error = *off

     *  Make sure all Day digits have been defined.

     C                   if        not d1Flag
     C                   eval      error = *on
     C                   eval      $pReturn = 'MISSD1'
     C                   eval      $pMsg = 'D1 code missing from '
     C                                   + 'definition'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtDayJul
     C                   endif

     C                   if        not d2Flag
     C                   eval      error = *on
     C                   eval      $pReturn = 'MISSD2'
     C                   eval      $pMsg = 'D2 code missing from '
     C                                   + 'definition'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtDayJul
     C                   endif

     C                   if        not d3Flag
     C                   eval      error = *on
     C                   eval      $pReturn = 'MISSD3'
     C                   eval      $pMsg = 'D3 code missing from '
     C                                   + 'definition'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtDayJul
     C                   endif

     *  Verify elements are all numeric.

     C                   if        d1Flag
     C                   eval      pos = %scan(D1:numbers:1)
     C                   if        pos = 0
     C                   eval      error = *on
     C                   eval      $pReturn = 'INVALIDD1'
     C                   eval      $pMsg = 'D1 value not numeric '
     C                                   + '(' + D1 + ')'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtDayJul
     C                   endif
     C                   endif

     C                   if        d2Flag
     C                   eval      pos = %scan(D2:numbers:1)
     C                   if        pos = 0
     C                   eval      error = *on
     C                   eval      $pReturn = 'INVALIDD2'
     C                   eval      $pMsg = 'D2 value not numeric '
     C                                   + '(' + D2 + ')'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtDayJul
     C                   endif
     C                   endif

     C                   if        d3Flag
     C                   eval      pos = %scan(D3:numbers:1)
     C                   if        pos = 0
     C                   eval      error = *on
     C                   eval      $pReturn = 'INVALIDD3'
     C                   eval      $pMsg = 'D3 value not numeric '
     C                                   + '(' + D3 + ')'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtDayJul
     C                   endif
     C                   endif

     *  Initialize Julian date.

     C                   eval      julDateYear = codeYear
     C                   eval      julDateDay  = D123num

     *  Verify julian date if valid.

     C     *longjul      test(DE)                julDate
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $pReturn = 'INVALIDJUL'
     C                   eval      $pMsg = 'Invalid Julian date '
     C                                   + '(' + %char(julDate) + ')'
     C                   goto      endCvtDayJul
     C                   endif

     *  Convert Julian date into standard date.

     C                   eval      julDatets = %date(julDate:*longjul)
     C                   eval      codeDate = %dec(%char(julDatets:*iso0):8:0)

     C     endcvtDayJul  endsr

     *----------------------------------------------------------------
     *  cvtDayNum  Convert day - Number
     *----------------------------------------------------------------

     C     cvtDayNum     begsr
     C                   eval      error = *off

     *  Make sure both Day digits have been defined.

     C                   if        not d1Flag
     C                   eval      error = *on
     C                   eval      $pReturn = 'MISSD1'
     C                   eval      $pMsg = 'D1 code missing from '
     C                                   + 'definition'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtDayNum
     C                   endif

     C                   if        not d2Flag
     C                   eval      error = *on
     C                   eval      $pReturn = 'MISSD2'
     C                   eval      $pMsg = 'D2 code missing from '
     C                                   + 'definition'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtDayNum
     C                   endif

     *  Verify elements are all numeric.

     C                   if        d1Flag
     C                   eval      pos = %scan(D1:numbers:1)
     C                   if        pos = 0
     C                   eval      error = *on
     C                   eval      $pReturn = 'INVALIDD1'
     C                   eval      $pMsg = 'D1 value not numeric '
     C                                   + '(' + D1 + ')'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtDayNum
     C                   endif
     C                   endif

     C                   if        d2Flag
     C                   eval      pos = %scan(D2:numbers:1)
     C                   if        pos = 0
     C                   eval      error = *on
     C                   eval      $pReturn = 'INVALIDD2'
     C                   eval      $pMsg = 'D2 value not numeric '
     C                                   + '(' + D2 + ')'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtDayNum
     C                   endif
     C                   endif

     *  Set code day to extracted value.

     C                   eval      codeDay = D12num

     C     endcvtDayNum  endsr

     *----------------------------------------------------------------
     *  cvtDayTbl  Convert day - Table
     *----------------------------------------------------------------

     C     cvtDayTbl     begsr
     C                   eval      error = *off

     *  Get definition day table.

     C                   eval      kytype = 'D'
     C     keymt         chain     mfrtable
     C                   if        not %found
     C                   eval      error = *on
     C                   eval      $pReturn = 'NODAYTBL'
     C                   eval      $pMsg = 'Day table does not exist for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtDayTbl
     C                   endif

     *  Look up code in day table codes.

     C                   eval      pos = %scan(D1:mttbl:1)

     *  Error if code not found.

     C                   if        pos = 0
     C                   eval      error = *on
     C                   eval      $pReturn = 'DCODNOTFND'
     C                   eval      $pMsg = 'Day code '
     C                                   + '(' + D1 + ') '
     C                                   + 'not found in table for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtDayTbl
     C                   endif

     *  Otherwise, set month to position code was found.

     C                   eval      codeDay = pos

     C     endcvtDayTbl  endsr

     *----------------------------------------------------------------
     *  cvtMonthCstm  Convert month - Custom
     *----------------------------------------------------------------

     C     cvtMonthCstm  begsr
     C                   eval      error = *off

510fAC                   select
510fA
510fAC                   when      mdmcst = 1
510fAC                   exsr      cvtMonthC001
510fA
510fAC                   endsl

     C     endcvtMonthCstendsr

510fA*----------------------------------------------------------------
510fA*  cvtMonthC001  Convert month - Custom 001
510fA*----------------------------------------------------------------
510fA
510fAC     cvtMonthC001  begsr
     C                   eval      error = *off

     *  Make sure all Month digits have been defined.

     C                   if        not m1Flag
     C                   eval      error = *on
     C                   eval      $pReturn = 'MISSM1'
     C                   eval      $pMsg = 'M1 code missing from '
     C                                   + 'definition'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtMonth001
     C                   endif

     C                   if        not m2Flag
     C                   eval      error = *on
     C                   eval      $pReturn = 'MISSM2'
     C                   eval      $pMsg = 'M2 code missing from '
     C                                   + 'definition'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtMonth001
     C                   endif

     C                   if        not m3Flag
     C                   eval      error = *on
     C                   eval      $pReturn = 'MISSM3'
     C                   eval      $pMsg = 'M3 code missing from '
     C                                   + 'definition'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtMonth001
     C                   endif

     *  Verify elements are all numeric.

     C                   if        m1Flag
     C                   eval      pos = %scan(M1:numbers:1)
     C                   if        pos = 0
     C                   eval      error = *on
     C                   eval      $pReturn = 'INVALIDM1'
     C                   eval      $pMsg = 'M1 value not numeric '
     C                                   + '(' + M1 + ')'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtMonth001
     C                   endif
     C                   endif

     C                   if        m2Flag
     C                   eval      pos = %scan(M2:numbers:1)
     C                   if        pos = 0
     C                   eval      error = *on
     C                   eval      $pReturn = 'INVALIDM2'
     C                   eval      $pMsg = 'M2 value not numeric '
     C                                   + '(' + M2 + ')'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtMonth001
     C                   endif
     C                   endif

     C                   if        m3Flag
     C                   eval      pos = %scan(M3:numbers:1)
     C                   if        pos = 0
     C                   eval      error = *on
     C                   eval      $pReturn = 'INVALIDM3'
     C                   eval      $pMsg = 'M3 value not numeric '
     C                                   + '(' + M3 + ')'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtMonth001
     C                   endif
     C                   endif

     *  Calculate Month/Day
     *    Month: Divide 3-digit month by 50.
     *           This is the last complete month prior to Mfr.
     *           Therefore, add 1 to get Mfr month.

     *    Day:   Remainder of above division.

     C     M123num       div       50            temp2n
     C                   mvr                     codeDay

     C                   eval      codeMonth = temp2n + 1

     C     endcvtMonth001endsr

     *----------------------------------------------------------------
     *  cvtMonthNum  Convert month - Number
     *----------------------------------------------------------------

     C     cvtMonthNum   begsr
     C                   eval      error = *off

     *  Make sure both Month digits have been defined.

     C                   if        not m1Flag
     C                   eval      error = *on
     C                   eval      $pReturn = 'MISSM1'
     C                   eval      $pMsg = 'M1 code missing from '
     C                                   + 'definition'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtMonthNum
     C                   endif

     C                   if        not m2Flag
     C                   eval      error = *on
     C                   eval      $pReturn = 'MISSM2'
     C                   eval      $pMsg = 'M2 code missing from '
     C                                   + 'definition'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtMonthNum
     C                   endif

     *  Verify elements are all numeric.

     C                   if        m1Flag
     C                   eval      pos = %scan(M1:numbers:1)
     C                   if        pos = 0
     C                   eval      error = *on
     C                   eval      $pReturn = 'INVALIDM1'
     C                   eval      $pMsg = 'M1 value not numeric '
     C                                   + '(' + M1 + ')'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtMonthNum
     C                   endif
     C                   endif

     C                   if        m2Flag
     C                   eval      pos = %scan(M2:numbers:1)
     C                   if        pos = 0
     C                   eval      error = *on
     C                   eval      $pReturn = 'INVALIDM2'
     C                   eval      $pMsg = 'M2 value not numeric '
     C                                   + '(' + M2 + ')'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtMonthNum
     C                   endif
     C                   endif

     *  Set code month to extracted value.

     C                   eval      codeMonth = M12num

     C     endcvtMonthNumendsr

     *----------------------------------------------------------------
     *  cvtMonthStd  Convert month - Std Alpha
     *----------------------------------------------------------------

     C     cvtMonthStd   begsr
     C                   eval      error = *off

     *  Make sure all Month characters have been defined.

     C                   if        not m1Flag
     C                   eval      error = *on
     C                   eval      $pReturn = 'MISSM1'
     C                   eval      $pMsg = 'M1 code missing from '
     C                                   + 'definition'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtMonthStd
     C                   endif

     C                   if        not m2Flag
     C                   eval      error = *on
     C                   eval      $pReturn = 'MISSM2'
     C                   eval      $pMsg = 'M2 code missing from '
     C                                   + 'definition'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtMonthStd
     C                   endif

     C                   if        not m3Flag
     C                   eval      error = *on
     C                   eval      $pReturn = 'MISSM3'
     C                   eval      $pMsg = 'M3 code missing from '
     C                                   + 'definition'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtMonthStd
     C                   endif

     *  Look up code in year table codes.

     C                   eval      monthCode = '*' + M123
     C                   eval      pos = %scan(monthCode:months:1)
520aA
520aA*  If not found, look for Spanish month.
520aA
520aAC                   if        pos = 0
520aAC                   eval      pos = %scan(monthCode:monthsSP:1)
520aAC                   endif

     *  Error if code not found.

     C                   if        pos = 0
     C                   eval      error = *on
     C                   eval      $pReturn = 'MSTDERR'
     C                   eval      $pMsg = 'Month code '
     C                                   + '(' + M123 + ') '
     C                                   + 'not found in table for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtMonthStd
     C                   endif

     *  Otherwise, set month to position code was found.

     C                   eval      codeMonth = pos / 4 + 1

     C     endcvtMonthStdendsr

     *----------------------------------------------------------------
     *  cvtMonthTbl  Convert month - Table
     *----------------------------------------------------------------

     C     cvtMonthTbl   begsr
     C                   eval      error = *off

     *  Initializ missing Month characters

     C                   if        not m2Flag
     C                   eval      M2 = ' '
     C                   endif

     C                   if        not m3Flag
     C                   eval      M3 = ' '
     C                   endif

     *  Get definition month table.

     C                   eval      kytype = 'M'
     C     keymt         chain     mfrtable
     C                   if        not %found
     C                   eval      error = *on
     C                   eval      $pReturn = 'NOMNTHTBL'
     C                   eval      $pMsg = 'Month table does not exist for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtMonthTbl
     C                   endif

     *  Look up code in year table codes.

     C                   eval      monthCode = '*' + M123
     C                   eval      pos = %scan(monthCode:mttbl:1)

     *  Error if code not found.

     C                   if        pos = 0
     C                   eval      error = *on
     C                   eval      $pReturn = 'MCODNOTFND'
     C                   eval      $pMsg = 'Month code '
     C                                   + '(' + M123 + ') '
     C                                   + 'not found in table for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtMonthTbl
     C                   endif

     *  Otherwise, set month to position code was found.

     C                   eval      codeMonth = pos / 4 + 1

     C     endcvtMonthTblendsr

510fA*----------------------------------------------------------------
510fA*  cvtWeekCstm  Convert week - Custom
510fA*----------------------------------------------------------------
510fA
510fAC     cvtWeekCstm   begsr
     C                   eval      error = *off

     C     endcvtWeekCstmendsr

510fA*----------------------------------------------------------------
510fA*  cvtWeekNum   Convert week - Number
510fA*----------------------------------------------------------------
510fA
510fAC     cvtWeekNum    begsr
     C                   eval      error = *off

     *  Make sure both Week digits have been defined.

     C                   if        not w1Flag
     C                   eval      error = *on
     C                   eval      $pReturn = 'MISSW1'
     C                   eval      $pMsg = 'W1 code missing from '
     C                                   + 'definition'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtWeekNum
     C                   endif

     C                   if        not w2Flag
     C                   eval      error = *on
     C                   eval      $pReturn = 'MISSW2'
     C                   eval      $pMsg = 'W2 code missing from '
     C                                   + 'definition'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtWeekNum
     C                   endif

     *  Verify elements are all numeric.

     C                   if        w1Flag
     C                   eval      pos = %scan(W1:numbers:1)
     C                   if        pos = 0
     C                   eval      error = *on
     C                   eval      $pReturn = 'INVALIDW1'
     C                   eval      $pMsg = 'W1 value not numeric '
     C                                   + '(' + W1 + ')'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtWeekNum
     C                   endif
     C                   endif

     C                   if        w2Flag
     C                   eval      pos = %scan(W2:numbers:1)
     C                   if        pos = 0
     C                   eval      error = *on
     C                   eval      $pReturn = 'INVALIDW2'
     C                   eval      $pMsg = 'W2 value not numeric '
     C                                   + '(' + W2 + ')'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtWeekNum
     C                   endif
     C                   endif
720aA
720aA*  Verify Day or Week is 1-7 or A-G
720aA
720aAC                   if        wdFlag
720aAC                   eval      pos = %scan(WD:wkdays:1)
720aAC                   if        pos = 0
720aAC                   eval      error = *on
720aAC                   eval      $pReturn = 'INVALIDWD'
720aAC                   eval      $pMsg = 'WD value not 0-1 or A-G '
720aAC                                   + '(' + WD + ')'
720aAC                                   + ' for '
720aAC                                   + 'Mfr# '
720aAC                                   + %trim(%editc(mdmfr#:'Z'))
720aAC                                   + ' Def# '
720aAC                                   + %trim(%editc(mddef#:'Z'))
720aAC                   leavesr
720aAC                   endif
720aAC                   endif
720aA
720aA*  If WD defined, calculate days to add. Set to zero if not defined.
720aA
720aA /free
720aA     wdNum = 0;
720aA     if wdFlag;
720aA       monitor;
720aA         wdNum = %dec(%xlate(daysAlpha: daysNum: wd): 1: 0);
720aA       on-error;
720aA         error = *on;
720aA         $pReturn = 'INVALIDWD';
720aA         $pMsg = 'WD value not 0-1 or A-G '
720aA               + '(' + WD + ')'
720aA               + ' for '
720aA               + 'Mfr# '
720aA               + %trim(%editc(mdmfr#:'Z'))
720aA               + ' Def# '
720aA               + %trim(%editc(mddef#:'Z'));
720aA         leavesr;
720aA       endmon;
720aA
720aA       // We assume the beginning of the week defines the day
720aA       // for '1' or 'A'. Therefore, we reduce the WD value
720aA       // by 1 for the days to be added to the date.
720aA
720aA       wdNum -= 1;
720aA
720aA     endif;
720aA /end-free

     *  Calculate Jan 1st date for code year.

     C                   eval      jan1Date = %date('0001-01-01')
     C                                      + %years(codeYear-1)

     *  Calculate day of week for Jan 1st.

     C/Exec SQL
     C+   Set :jan1DOW = dayofweek(:jan1Date)
     C/End-Exec
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Calculate the 1st day of the week for the Jan 1st week.

     *    First assume Sunday is 1st day of the week.

     C                   eval      weekDate = jan1Date - %days(Jan1DOW - 1)

     *    Add 1 day if 1st day of the week is defined as Monday.

     C                   if        mdwbeg = '2'
     C                   eval      weekDate = weekDate + %days(1)
     C                   endif
720aA
720aA*    Add WD days.
720aA
720aAC                   if        wdNum > 0
720aAC                   eval      weekDate += %days(wdNum)
720aAC                   endif

     *  Calculate first day of the code week.

     C                   eval      weekDate = weekDate + %days((W12num - 1) * 7)

     *  Extract Year from week date.

     C/Exec SQL
     C+   Set :codeYear = year(:weekDate)
     C/End-Exec
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Extract Month from week date.

     C/Exec SQL
     C+   Set :codeMonth = month(:weekDate)
     C/End-Exec
     C                   if        sqlstt <> '00000'
     C                   endif

     *  Extract Day from week date.

     C/Exec SQL
     C+   Set :codeDay = day(:weekDate)
     C/End-Exec
     C                   if        sqlstt <> '00000'
     C                   endif

     C     endcvtWeekNum endsr

     *----------------------------------------------------------------
     *  cvtYearCstm  Convert year - Custom
     *----------------------------------------------------------------

     C     cvtYearCstm   begsr
     C                   eval      error = *off

510fAC                   select
510fA
510fAC                   when      mdycst = 1
510fAC                   exsr      cvtYearC001
510fA
510fAC                   endsl

     C     endcvtYearCstmendsr

510fA*----------------------------------------------------------------
510fA*  cvtYearC001  Convert year - Custom 001
510fA*----------------------------------------------------------------
510fA
510fAC     cvtYearC001   begsr
     C                   eval      error = *off

     *  Make sure Year digit has been defined.

     C                   if        not y1Flag
     C                   eval      error = *on
     C                   eval      $pReturn = 'MISSY1'
     C                   eval      $pMsg = 'Y1 code missing from '
     C                                   + 'definition'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtYearC001
     C                   endif

     *  Verify elements are all numeric.

     C                   if        y1Flag
     C                   eval      pos = %scan(Y1:numbers:1)
     C                   if        pos = 0
     C                   eval      error = *on
     C                   eval      $pReturn = 'INVALIDY1'
     C                   eval      $pMsg = 'Y1 value not numeric '
     C                                   + '(' + Y1 + ')'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtYearC001
     C                   endif
     C                   endif

     *  Calculate actual year.

     C                   if        Y1num < 5
     C                   eval      Y4num = Y1num + 5
     C                   else
     C                   eval      Y4num = Y1num - 5
     C                   endif

     *  Initialize unused digits with current year values

     C                   eval      Y1 = %char(currY1)
     C                   eval      Y2 = %char(currY2)
     C                   eval      Y3 = %char(currY3)

     *  Ensure date is within date range that start with previous year.

     C                   eval      codeYear = Y1234num

     C                   select

     *    ... If only 1 digit defined in code,
     *          and that digit is less than previous years digit
     *          then add 10 to the year.

     C                   when      y4Flag
     C                             and Y4num < prevYear4
     C                   eval      codeYear = codeYear + 10

     *    ... If only 1 digit defined in code,
     *          and that digit is 9 years in the future
     *          then set the year to the previous year

     C                   when      y4Flag
     C                   eval      maxYear = currYear + 9
     C                   if        Y4num = maxYear4
     C                   eval      codeYear = prevYear
     C                   endif

     C                   endsl

     C     endcvtYearC001endsr

     *----------------------------------------------------------------
     *  cvtYearNum   Convert year - Number
     *----------------------------------------------------------------

     C     cvtYearNum    begsr
     C                   eval      error = *off

     *  Verify elements are all numeric.

     C                   if        y1Flag
     C                   eval      pos = %scan(Y1:numbers:1)
     C                   if        pos = 0
     C                   eval      error = *on
     C                   eval      $pReturn = 'INVALIDY1'
     C                   eval      $pMsg = 'Y1 value not numeric '
     C                                   + '(' + Y1 + ')'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtYearNum
     C                   endif
     C                   endif

     C                   if        y2Flag
     C                   eval      pos = %scan(Y2:numbers:1)
     C                   if        pos = 0
     C                   eval      error = *on
     C                   eval      $pReturn = 'INVALIDY2'
     C                   eval      $pMsg = 'Y2 value not numeric '
     C                                   + '(' + Y2 + ')'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtYearNum
     C                   endif
     C                   endif

     C                   if        y3Flag
     C                   eval      pos = %scan(Y3:numbers:1)
     C                   if        pos = 0
     C                   eval      error = *on
     C                   eval      $pReturn = 'INVALIDY3'
     C                   eval      $pMsg = 'Y3 value not numeric '
     C                                   + '(' + Y3 + ')'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtYearNum
     C                   endif
     C                   endif

     C                   if        y4Flag
     C                   eval      pos = %scan(Y4:numbers:1)
     C                   if        pos = 0
     C                   eval      error = *on
     C                   eval      $pReturn = 'INVALIDY4'
     C                   eval      $pMsg = 'Y4 value not numeric '
     C                                   + '(' + Y4 + ')'
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtYearNum
     C                   endif
     C                   endif

     *  Initialize unused digits with current year values

     C                   if        not y1Flag
     C                   eval      Y1 = %char(currY1)
     C                   endif

     C                   if        not y2Flag
     C                   eval      Y2 = %char(currY2)
     C                   endif

     C                   if        not y3Flag
     C                   eval      Y3 = %char(currY3)
     C                   endif

     *  Ensure date is within date range that start with previous year.

     C                   eval      codeYear = Y1234num

520bA*  Allow dates to be as much as 2 years old.
520bAC                   eval      twoYrsAgo = prevYear34 - 1

     C                   select

     *    ... If all 4 digits defined in code,
     *          then ther is nothing else to do.

510bDC*                  when      y2Flag and y2flag and y3Flag and y4Flag
510bAC                   when      y1Flag and y2flag and y3Flag and y4Flag

     *    ... If only 3 digits defined in code,
     *          and those digits are less than previous years 3 digits
     *          then add 1000 to the year.

     C                   when      y2flag and y3Flag and y4Flag
     C                             and Y234num < prevYear234
     C                   eval      codeYear = codeYear + 1000

     *    ... If only 3 digits defined in code,
     *          and those digits are 999 years in the future
     *          then set the year to the previous year

     C                   when      y2flag and y3Flag and y4Flag
     C                   eval      maxYear = currYear + 999
     C                   if        Y234num = maxYear234
     C                   eval      codeYear = prevYear
     C                   endif

520bD***  ... If only 2 digits defined in code,
520bD***        and those digits are less than previous years 2 digits
520bD***        then add 100 to the year.
520bM*    ... If only 2 digits defined in code,
520bM*          and the year defined is older than 2 years ago,
520bM*          then add 100 to the year.

     C                   when      y3Flag and y4Flag
520bDC**                           and Y34num < prevYear34
520bMC                             and Y34num < twoYrsAgo
     C                   eval      codeYear = codeYear + 100

     *    ... If only 2 digits defined in code,
     *          and those digits are 99 years in the future
     *          then set the year to the previous year

     C                   when      y3Flag and y4Flag
     C                   eval      maxYear = currYear + 99
     C                   if        Y34num = maxYear34
     C                   eval      codeYear = prevYear
     C                   endif

     *    ... If only 1 digit defined in code,
610bD***        and that digit is less than previous years digit
610bD***        then add 10 to the year.
610bD*          If digit is same as previous year digit
610bD*             then set date to previous year.
610bD*          If digit is same as two years ago digit
610bD*             then set date to two years ago.

610bDC**                 when      y4Flag
610bDC**                           and Y4num < prevYear4
610bDC**                 eval      codeYear = codeYear + 10

610bAC                   when      y4Flag
610bAC                             and Y4num = prevYear4
610bAC                   eval      codeYear = prevYear

610bAC                   when      y4Flag
610bAC                             and Y4num = prv2Year4
610bAC                   eval      codeYear = prv2Year

     *    ... If only 1 digit defined in code,
     *          and that digit is 9 years in the future
     *          then set the year to the previous year

     C                   when      y4Flag
     C                   eval      maxYear = currYear + 9
     C                   if        Y4num = maxYear4
     C                   eval      codeYear = prevYear
     C                   endif

     C                   endsl

     C     endcvtYearNum endsr

     *----------------------------------------------------------------
     *  cvtYearTbl   Convert year - Table
     *----------------------------------------------------------------

     C     cvtYearTbl    begsr
     C                   eval      error = *off

     *  Get definition year table.


     C                   eval      kytype = 'Y'
     C     keymt         chain     mfrtable
     C                   if        not %found
     C                   eval      error = *on
     C                   eval      $pReturn = 'NOYEARTBL'
     C                   eval      $pMsg = 'Year table does not exist for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtYearTbl
     C                   endif

     *  Look up code in year table codes.

     C                   eval      pos = %scan(Y1:yearTbl:1)

     *  Error if code not found.

     C                   if        pos = 0
     C                   eval      error = *on
     C                   eval      $pReturn = 'YCODNOTFND'
     C                   eval      $pMsg = 'Year code '
     C                                   + '(' + Y1 + ') '
     C                                   + 'not found in table for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtYearTbl
     C                   endif

     *  Otherwise, get date that corresponds to code position.

     C                   eval      pos = pos * 4 - 3
     C                   eval      temp4a  = %subst(mttbl:pos:4)
     C                   move      temp4a        codeYear

     *  Error if year is zero.

     C                   if        codeYear = 0
     C                   eval      error = *on
     C                   eval      $pReturn = 'YNOTBLVAL'
     C                   eval      $pMsg = 'Year value is zero '
     C                                   + 'for code '
     C                                   + '(' + Y1 + ') '
     C                                   + ' for '
     C                                   + 'Mfr# '
     C                                   + %trim(%editc(mdmfr#:'Z'))
     C                                   + ' Def# '
     C                                   + %trim(%editc(mddef#:'Z'))
     C                   goto      endCvtYearTbl
     C                   endif

     C     endcvtYearTbl endsr
