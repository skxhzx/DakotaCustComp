500gA /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd. #8-51
     *   West Chicago, IL 60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETCHKDGT   Get slot check digit
     *  12 June 2007
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
510 A*    06/12/07  DAS  5.10
     *      - Created
510aA*    07/12/07  RBD  5.10a
     *      - Fix: Add read order 'crl' to subr fmtDigitSingle.
     *
520aA*    02/12/08  DAS  5.20a
     *      - Fix: Revised to get check digit for base slot.
     *
520bA*    06/04/08  DAS  5.20b  P#00094
     *      - Enh: Revised to use new *CHKDGT field OPREAD, which
     *        allows a client to have both 2 and 3 digit check digits
     *        on the racks.
     *      - Enh: Revised fmtDigit routine to format 2 digit codes
     *        according to the leftmost and right most digit
     *        positions, ignoring the center digit.
     *
700aA*    02/06/16  DAS  7.00a
     *      - Enh: Added command AMPSTccc for getting check digit
     *        for AMP Staging Area (ccc is the staging area code)
     *      - Added file STAGEAMP.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Avalon Foodservice
     *
AVL A*    12/07/11  MLB  AVL
     *      - Revised program to use SLOTDGT1, SLOTDGTA1 to retrieve
     *        check digit without whse department.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fslotdgt   if   e           k disk
AVL AFslotdgt1  if   e           k disk    rename(scdrec : scdrec1)
AVL AF                                     usropn
     Fslotdgta  if   e           k disk
AVL AFslotdgta1 if   e           k disk    rename(scdreca : scdreca1)
AVL AF                                     usropn
     Foptions   if   e           k disk
700aAFstageamp  if   e           k disk    usropn

640 A*------------------------------------------------------------------
640 A*  Client id's for custom mods.
640 A*------------------------------------------------------------------
640 A*
AVL A /copy qcopysrc,id#avalon
640 A*
640 AD client          s             10
640 AD clientloc       s             10
640 A*
     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

409 AD ord             s              3    dim(6)
409 AD cod             s              1  0 dim(3)

520aA*----------------------------------------------------------------
520aA*  DRI parameters
520aA*----------------------------------------------------------------
520aA
520aA /COPY *libl/qcopysrc,C#DRIPARMS
520aA
520aA*----------------------------------------------------------------
520aA*  Data Formats
520aA*----------------------------------------------------------------
520aA
520aA /COPY *libl/qcopysrc,C#SLOT
520aAD saveVer#        s                   like($slver#)

510jA*----------------------------------------------------------------
510jA*  *CHKDGT  -  Check digit options.
510jA*----------------------------------------------------------------
510jA*
510jA* Fields
510jA*
510jA*    OPCOD#  -  Number of check digit codes per slot (1,2,3)
510jA*    OPDGT#  -  Maximum number of digits per code  (2,3)
510jA*    OPIDC1  -  Code 1 identifier
510jA*    OPIDC2  -  Code 2 identifier
510jA*    OPUNU2  -  Unused
510jA*    OPIDC3  -  Code 3 identifier
510jA*    OPUNU3  -  Unused
510jA*    OPIDD1  -  Digit 1 identifier
510jA*    OPIDD2  -  Digit 2 identifier
510jA*    OPIDD3  -  Digit 3 identifier
510jA*    OPRCOD  -  Current code to read (S=Single,R=Random)
510jA*    OPRCD1  -  Use code 1 for current reading (Y,N)
510jA*    OPRCD2  -  Use code 2 for current reading (Y,N)
510jA*    OPRCD3  -  Use code 3 for current reading (Y,N)
510jA*    OPRORD  -  Current read order (S=Single, R=Random)
510jA*    OPRLCR  -  Use read order Left/Center/Right (Y,N)
510jA*    OPRRCL  -  Use read order Right/Center/Left (Y,N)
510jA*    OPRLRC  -  Use read order Left/Right/Center (Y,N)
510jA*    OPRRLC  -  Use read order Right/Left/Center (Y,N)
510jA*    OPRCLR  -  Use read order Cener/Left/Right  (Y,N)
510jA*    OPRCRL  -  Use read order Cener/Right/Left  (Y,N)
520bA*    OPREAD  -  Number of digits user reads for codes
520bA*               less than 100.
510jA*
510jA* Data structure
510jA*
510jAD opdata          ds
510jAD  opcod#                 1      1  0
510jAD  opdgt#                 2      2  0
510jAD  opidc1                 3      8
510jAD  opidc2                 9     14
510jAD  opunu2                15     16
510jAD  opidc3                17     22
510jAD  opunu3                23     24
510jAD  opidd1                25     30
510jAD  opidd2                31     36
510jAD  opidd3                37     42
510jAD  oprcod                43     43
510jAD  oprcd1                44     44
510jAD  oprcd2                45     45
510jAD  oprcd3                46     46
510jAD  oprord                47     47
510jAD  oprlcr                48     48
510jAD  oprrcl                49     49
510jAD  oprlrc                50     50
510jAD  oprrlc                51     51
510jAD  oprclr                52     52
510jAD  oprcrl                53     53
520bAD  opread                54     54  0
520bAD  opreada               54     54
510jAD  optend               117    117

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

520aAD chk4err         s               n
     D error           s               n
     D optNotFound     s               n
520aAD zmsflag         s               n

520aAD baseSlot        s                   like($pSlot)
     D dgtOrder        s              3
520aAD errmsg          s             60
     D maxOrder        s              1  0
     D maxCode         s              1  0
     D codeToUse       s              1  0
700aAD stageCode       s              3  0
700aAD getSlotChkDgt   s               n
700aAD getStageChkDgt  s               n

     *----------------------------------------------------------------
     *  Check digit data structures
     *----------------------------------------------------------------

212 AD                 ds
212 AD  fileDigit              1      3s 0
212 AD  fileDigit1             1      1s 0
212 AD  fileDigitL             1      1s 0
212 AD  fileDigit2             2      2s 0
212 AD  fileDigitC             2      2s 0
212 AD  fileDigit3             3      3s 0
212 AD  fileDigitR             3      3s 0

212 AD                 ds
212 AD  newDigit               1      3s 0
212 AD  newDigit1              1      1s 0
212 AD  newDigit2              2      2s 0
212 AD  newDigit3              3      3s 0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
700aM*      $pCmd         blank     - Normal processing, get chkdgt for slot
700aA*                    AMPSTccc  - Get chkdgt for AMP staging area
700aA*                                where ccc is the staging area 3-digit code
     *      $pWhse        Warehouse
     *      $pWhdp        Department
     *      $pSlot        Slot
     *
     *    Returned Parameters
     *      $pCodes       Number of codes
     *      $pDigits      Number of digits
     *      $pOrderType   Read order (S=Single, R=Random)
     *      $pOrder1      Digit order code 1
     *      $pOrder2      Digit order code 2
     *      $pOrder3      Digit order code 3
     *      $pCodeType    Code type (S=Single, R=Random)
     *      $pCode        Check digit code
     *      $pChkdigit    Check digit
     *      $pReturn     *OK
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pCmd             8
     C                   parm                    $pWhse            3 0
     C                   parm                    $pWhdp            5
     C                   parm                    $pSlot           12
     C                   parm                    $pCodes           1 0
     C                   parm                    $pDigits          1 0
     C                   parm                    $pOrderType       1
     C                   parm                    $pOrder1          6
     C                   parm                    $pOrder2          6
     C                   parm                    $pOrder3          6
     C                   parm                    $pCodeType        1
     C                   parm                    $pCode            6
     C                   parm                    $pChkDigit        3 0
     C                   parm                    $pReturn         10

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

700aA* See if we want to get AMP staging area check digit
700aA
700aA /free
700aA
700aA    getSlotChkDgt = *on;
700aA    getStageChkDgt = *off;
700aA
700aA    if %subst($pcmd:1:5) = 'AMPST';
700aA      getSlotChkDgt = *off;
700aA      getStageChkDgt = *on;
700aA
700aA      // Get stage code. Get out if number not sent.
700aA
700aA      monitor;
700aA        stageCode = %dec(%subst($pcmd:6:3):3:0);
700aA      on-error;
700aA        $pDigits = 3;
700aA        $pChkDigit = 0;
700aA        $pReturn = '*INVLDSTGCD';
700aA        return;
700aA      endmon;
700aA
700aA      // Open stageamp file.
700aA
700aA      if not %open(stageamp);
700aA        open(e) stageamp;
700aA        if %error;
700aA          $pDigits = 3;
700aA          $pChkDigit = 0;
700aA          $pReturn = '*OPNERRSTGA';
700aA          return;
700aA        endif;
700aA      endif;
700aA
700aA      // Get stage code record.
700aA
700aA      chain ($pwhse: stageCode) stageamp;
700aA      if not %found(stageamp);
700aA        $pDigits = 3;
700aA        $pChkDigit = 0;
700aA        $pReturn = '*STGNOTFND';
700aA        return;
700aA      endif;
700aA
700aA    endif;
700aA
700aA
700aA /end-free

520aA
520aA*  Get base slot.
520aA
700aAC                   if        getSlotChkDgt
520aAC                   exsr      getSlot
520aAC                   if        error
520aAC                   eval      baseSlot = $pSlot
520aAC                   else
520aAC                   eval      baseSlot = $sacdsp
520aAC                   endif
700aAC                   endif

     *  If option record not found, initialize some of its fields.

     *  Note, when we don't find an option record we want to use the
     *        original check digit method.

     C                   if        optNotFound
     C                   eval      opcod# = 1
520bDC**                 eval      opdgt# = 0
520bMC                   eval      opdgt# = 2
     C                   eval      oprord = 'S'
     C                   eval      oprlcr = 'Y'
     C                   eval      oprcod = 'S'
     C                   eval      oprcd1 = 'Y'
520bAC                   eval      opread = 2
     C                   endif
520bA
520bA*  Make sure new option field is initialized properly.
520bA
520bAC                   if        opreada < '2' or opreada > '3'
520bAC                   eval      opread = opdgt#
520bAC                   endif

     *  Initialize return parameters

     C                   if        optNotFound
     C                   eval      $pReturn = '*OPTNOTFND'
     C                   else
     C                   eval      $pReturn = '*OK'
     C                   endif
     C                   eval      $pCodes     = opcod#
     C                   eval      $pDigits    = opdgt#
     C                   eval      $pOrderType = oprord
     C                   eval      $pOrder1    = ' '
     C                   eval      $pOrder2    = ' '
     C                   eval      $pOrder3    = ' '
     C                   eval      $pCodeType  = oprcod
     C                   eval      $pCode      = ' '
     C                   eval      $pChkDigit  = 0

     *  Get code to use

     C                   select
     C                   when      oprcod = 'R'
     C                   exsr      getCodeRandom
     C                   other
     C                   exsr      getCodeSingle
     C                   endsl
520bA
520bA*  Determine number of digits to read.
520bA
520bAC                   if        opread = 2
520bAC                   if        fileDigit < 100
520bAC                   eval      $pDigits = 2
520bAC                   endif
520bAC                   endif
700aAC                   if        getStageChkDgt
700aAC                   eval      $pDigits = 3
700aAC                   endif

     *  Format check digit to user defined order.

     C                   select
     C                   when      oprord = 'R'
     C                   exsr      fmtDigitRandom
     C                   other
     C                   exsr      fmtDigitSingle
     C                   endsl
520bD **
520bD** If the option record wasn't found,
520bD**   Then set the number of digits based check digit value.
520bD **
520bDC**                 if        optNotFound
520bDC**                 if        $pChkDigit >= 100
520bDC**                 eval      $pDigits = 3
520bDC**                 else
520bDC**                 eval      $pDigits = 2
520bDC**                 endif
520bDC**                 endif

     C     bottom        tag
     C                   return

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------
     C     *inzsr        begsr

640 A*  Get client id

640 AC                   call      'GETCLIENT'
640 AC                   parm                    client
640 AC                   parm                    clientloc

AVL A*  Open check digit files.
AVL AC                   if        client = avalon
AVL A*
AVL AC                   if        not %open(slotdgt1)
AVL AC                   open      slotdgt1
AVL AC                   endif
AVL A*
AVL AC                   if        not %open(slotdgta1)
AVL AC                   open      slotdgta1
AVL AC                   endif
AVL A*
AVL AC                   endif

     *  Define key for check digit files

     C     keyscd        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
520aMC                   kfld                    baseSlot
520aDC**                 kfld                    $pslot
AVL AC     keyscd1       klist
AVL AC                   kfld                    $pwhse
AVL AC                   kfld                    baseSlot

     *  Define key for OPTIONS file

     C     keyop         klist
     C                   kfld                    opwhse
     C                   kfld                    opcode

     *  Get options

     C                   eval      opwhse = $pWhse
     C                   eval      opcode = '*CHKDGT'
     C     keyop         chain     options
     C                   if        not %found
     C                   eval      optNotFound = *on
     C                   else
     C                   eval      optNotFound = *off
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  fmtDigit    Format check digit.
     *----------------------------------------------------------------
     C     fmtDigit      begsr

     C                   select

     C                   when      dgtOrder = 'lcr'
     C                   if        $pDigits = 2
     C                   eval      newDigit1 = 0
     C                   eval      newDigit2 = fileDigit2
     C                   eval      newDigit3 = fileDigit3
     C                   eval      $pOrder1 = opidd1
520bAC                   if        opdgt# = 3
520bAC                   eval      $pOrder2 = opidd3
520bAC                   else
     C                   eval      $pOrder2 = opidd2
520bAC                   endif
     C                   eval      $pOrder3 = ' '
     C                   else
     C                   eval      newDigit1 = fileDigitL
     C                   eval      newDigit2 = fileDigitC
     C                   eval      newDigit3 = fileDigitR
     C                   eval      $pOrder1 = opidd1
     C                   eval      $pOrder2 = opidd2
     C                   eval      $pOrder3 = opidd3
     C                   endif

     C                   when      dgtOrder = 'rcl'
     C                   if        $pDigits = 2
     C                   eval      newDigit1 = 0
     C                   eval      newDigit2 = fileDigit3
     C                   eval      newDigit3 = fileDigit2
520bAC                   if        opdgt# = 3
520bAC                   eval      $pOrder1 = opidd3
520bAC                   else
     C                   eval      $pOrder1 = opidd2
520bAC                   endif
     C                   eval      $pOrder2 = opidd1
     C                   eval      $pOrder3 = ' '
     C                   else
     C                   eval      newDigit1 = fileDigitR
     C                   eval      newDigit2 = fileDigitC
     C                   eval      newDigit3 = fileDigitL
     C                   eval      $pOrder1  = opidd3
     C                   eval      $pOrder2  = opidd2
     C                   eval      $pOrder3  = opidd1
     C                   endif

     C                   when      dgtOrder = 'lrc'
520bAC                   if        $pDigits = 2
520bAC                   eval      newDigit1 = 0
520bAC                   eval      newDigit2 = fileDigit2
520bAC                   eval      newDigit3 = fileDigit3
520bAC                   eval      $pOrder1 = opidd1
520bAC                   if        opdgt# = 3
520bAC                   eval      $pOrder2 = opidd3
520bAC                   else
520bAC                   eval      $pOrder2 = opidd2
520bAC                   endif
520bAC                   eval      $pOrder3 = ' '
520bAC                   else
     C                   eval      newDigit1 = fileDigitL
     C                   eval      newDigit2 = fileDigitR
     C                   eval      newDigit3 = fileDigitC
     C                   eval      $pOrder1  = opidd1
     C                   eval      $pOrder2  = opidd3
     C                   eval      $pOrder3  = opidd2
520bAC                   endif

     C                   when      dgtOrder = 'rlc'
520bAC                   if        $pDigits = 2
520bAC                   eval      newDigit1 = 0
520bAC                   eval      newDigit2 = fileDigit3
520bAC                   eval      newDigit3 = fileDigit2
520bAC                   if        opdgt# = 3
520bAC                   eval      $pOrder1 = opidd3
520bAC                   else
520bAC                   eval      $pOrder1 = opidd2
520bAC                   endif
520bAC                   eval      $pOrder2 = opidd1
520bAC                   eval      $pOrder3 = ' '
520bAC                   else
     C                   eval      newDigit1 = fileDigitR
     C                   eval      newDigit2 = fileDigitL
     C                   eval      newDigit3 = fileDigitC
     C                   eval      $pOrder1  = opidd3
     C                   eval      $pOrder2  = opidd1
     C                   eval      $pOrder3  = opidd2
520bAC                   endif

     C                   when      dgtOrder = 'clr'
520bAC                   if        $pDigits = 2
520bAC                   eval      newDigit1 = 0
520bAC                   eval      newDigit2 = fileDigit2
520bAC                   eval      newDigit3 = fileDigit3
520bAC                   eval      $pOrder1 = opidd1
520bAC                   if        opdgt# = 3
520bAC                   eval      $pOrder2 = opidd3
520bAC                   else
520bAC                   eval      $pOrder2 = opidd2
520bAC                   endif
520bAC                   eval      $pOrder3 = ' '
520bAC                   else
     C                   eval      newDigit1 = fileDigitC
     C                   eval      newDigit2 = fileDigitL
     C                   eval      newDigit3 = fileDigitR
     C                   eval      $pOrder1  = opidd2
     C                   eval      $pOrder2  = opidd1
     C                   eval      $pOrder3  = opidd3
520bAC                   endif

     C                   when      dgtOrder = 'crl'
520bAC                   if        $pDigits = 2
520bAC                   eval      newDigit1 = 0
520bAC                   eval      newDigit2 = fileDigit3
520bAC                   eval      newDigit3 = fileDigit2
520bAC                   if        opdgt# = 3
520bAC                   eval      $pOrder1 = opidd3
520bAC                   else
520bAC                   eval      $pOrder1 = opidd2
520bAC                   endif
520bAC                   eval      $pOrder2 = opidd1
520bAC                   eval      $pOrder3 = ' '
520bAC                   else
     C                   eval      newDigit1 = fileDigitC
     C                   eval      newDigit2 = fileDigitR
     C                   eval      newDigit3 = fileDigitL
     C                   eval      $pOrder1  = opidd2
     C                   eval      $pOrder2  = opidd3
     C                   eval      $pOrder3  = opidd1
520bAC                   endif

     C                   endsl

     C                   eval      $pChkDigit = newDigit

     C                   endsr

     *----------------------------------------------------------------
     *  fmtDigitRandom   Format check digit using random order
     *----------------------------------------------------------------
     C     fmtDigitRandombegsr

     C                   eval      maxOrder = 0

     C                   if        oprlcr = 'Y'
     C                   eval      maxOrder = maxOrder + 1
     C                   eval      ord(maxOrder) = 'lcr'
     C                   endif

     C                   if        oprrcl = 'Y'
     C                   eval      maxOrder = maxOrder + 1
     C                   eval      ord(maxOrder) = 'rcl'
     C                   endif

     C                   if        oprlrc = 'Y'
     C                   eval      maxOrder = maxOrder + 1
     C                   eval      ord(maxOrder) = 'lrc'
     C                   endif

     C                   if        oprrlc = 'Y'
     C                   eval      maxOrder = maxOrder + 1
     C                   eval      ord(maxOrder) = 'rlc'
     C                   endif

     C                   if        oprclr = 'Y'
     C                   eval      maxOrder = maxOrder + 1
     C                   eval      ord(maxOrder) = 'clr'
     C                   endif

     C                   if        oprcrl = 'Y'
     C                   eval      maxOrder = maxOrder + 1
     C                   eval      ord(maxOrder) = 'crl'
     C                   endif

     C                   eval      $rMin = 1
     C                   eval      $rMax = maxOrder

     C                   call      'RANDOM2'
     C                   parm                    $rSeed            9 9
     C                   parm                    $rMin             6 0
     C                   parm                    $rMax             6 0
     C                   parm                    $rNum             6 0

     C                   eval      dgtOrder = ord($rNum)
     C                   exsr      fmtDigit

     C                   endsr

     *----------------------------------------------------------------
     *  fmtDigitSingle   Format check digit using Single order.
     *----------------------------------------------------------------
     C     fmtDigitSinglebegsr

     C                   select
     C                   when      oprlcr = 'Y'
     C                   eval      dgtOrder = 'lcr'
     C                   when      oprrcl = 'Y'
     C                   eval      dgtOrder = 'rcl'
     C                   when      oprlrc = 'Y'
     C                   eval      dgtOrder = 'lrc'
     C                   when      oprrlc = 'Y'
     C                   eval      dgtOrder = 'rlc'
     C                   when      oprclr = 'Y'
     C                   eval      dgtOrder = 'clr'
510aDC**                 when      oprrlc = 'Y'
510aDC**                 eval      dgtOrder = 'rlc'
510aMC                   when      oprcrl = 'Y'
510aMC                   eval      dgtOrder = 'crl'
     C                   other
     C                   eval      dgtOrder = 'lcr'
     C                   endsl

     C                   exsr      fmtDigit

     C                   endsr

     *----------------------------------------------------------------
     *  getCode     Get check digit code to use
     *----------------------------------------------------------------
     C     getCode       begsr
     C                   eval      fileDigit = 0

     C                   select

     *  First code

     C                   when      codeToUse = 1
     C                   eval      $pCode = opidc1
AVL A*
AVL AC                   if        client = avalon
AVL AC     keyscd1       chain     slotdgt1
AVL AC                   else
AVL A*
     C     keyscd        chain     slotdgt
AVL AC                   endif
AVL A*
     C                   if        not %found
     C                   eval      $pReturn = '*DGTNOTFND'
     C                   else
     C                   eval      fileDigit = scddgt
     C                   endif

     *  Second code


     C                   when      codeToUse = 2
     C                   eval      $pCode = opidc2
AVL A*
AVL AC                   if        client = avalon
AVL AC     keyscd1       chain     slotdgta1
AVL AC                   else
AVL A*
     C     keyscd        chain     slotdgta
AVL AC                   endif
AVL A*
     C                   if        not %found
     C                   eval      $pReturn = '*DGTNOTFND'
     C                   else
     C                   eval      fileDigit = scddgt2
     C                   endif

     *  Third code

     C                   when      codeToUse = 3
     C                   eval      $pCode = opidc3
AVL A*
AVL AC                   if        client = avalon
AVL AC     keyscd1       chain     slotdgta1
AVL AC                   else
AVL A*
     C     keyscd        chain     slotdgta
AVL AC                   endif
AVL A*
     C                   if        not %found
     C                   eval      $pReturn = '*DGTNOTFND'
     C                   else
     C                   eval      fileDigit = scddgt3
     C                   endif

     C                   endsl

     C                   endsr

700aA*----------------------------------------------------------------
700aA*  getCodeAMP   Get check digit code to use for AMP staging area
700aA*----------------------------------------------------------------
700aAC     getCodeAMP    begsr

      /free
         fileDigit = 0;

         select;

           when codeToUse = 1;
             $pCode = opidc1;
             fileDigit = sachkdgt1;

           when codeToUse = 2;
             $pCode = opidc2;
             fileDigit = sachkdgt2;

           when codeToUse = 3;
             $pCode = opidc3;
             fileDigit = sachkdgt3;

         endsl;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  getCodeRandom   Get Random code to use
     *----------------------------------------------------------------
     C     getCodeRandom begsr

     C                   eval      maxOrder = 0

     C                   if        oprcd1 = 'Y'
     C                   eval      maxOrder = maxOrder + 1
     C                   eval      cod(maxOrder) = 1
     C                   endif

     C                   if        oprcd2 = 'Y'
     C                   eval      maxOrder = maxOrder + 1
     C                   eval      cod(maxOrder) = 2
     C                   endif

     C                   if        oprcd3 = 'Y'
     C                   eval      maxOrder = maxOrder + 1
     C                   eval      cod(maxOrder) = 3
     C                   endif

     C                   eval      $rMin = 1
     C                   eval      $rMax = maxOrder

     C                   call      'RANDOM2'
     C                   parm                    $rSeed            9 9
     C                   parm                    $rMin             6 0
     C                   parm                    $rMax             6 0
     C                   parm                    $rNum             6 0

     C                   eval      codeToUse = cod($rNum)
700aAC                   if        getStageChkDgt
700aAC                   exsr      getCodeAMP
700aAC                   else
     C                   exsr      getCode
700aAC                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  getCodeSingle   Get Single code to use
     *----------------------------------------------------------------
     C     getCodeSingle begsr

     C                   select
     C                   when      oprcd1 = 'Y'
     C                   eval      codeToUse = 1
     C                   when      oprcd2 = 'Y'
     C                   eval      codeToUse = 2
     C                   when      oprcd3 = 'Y'
     C                   eval      codeToUse = 3
     C                   other
     C                   eval      codeToUse = 1
     C                   endsl

700aAC                   if        getStageChkDgt
700aAC                   exsr      getCodeAMP
700aAC                   else
     C                   exsr      getCode
700aAC                   endif

     C                   endsr
520aA
520aA*----------------------------------------------------------------
520aA*  getslot   Get slot information.
520aA*----------------------------------------------------------------
520aA
520aAC     getSlot       begsr

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pWhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $pWhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = $pSlot

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop

     C                   endsr

520aA*----------------------------------------------------------------
520aA*----------------------------------------------------------------
520aA*                     DRI SUBROUTINES
520aA*----------------------------------------------------------------
520aA*----------------------------------------------------------------

520aA*----------------------------------------------------------------
520aA*  clr$slot  Clear $slot data structure fields
520aA*----------------------------------------------------------------
520aA
520aAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#
     C                   endsr
520aA
520aA*----------------------------------------------------------------
520aA*  zzzdriclose   Close any open files or programs.
520aA*----------------------------------------------------------------
520aA
520aAC     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   endsr
520aA
520aA*----------------------------------------------------------------
520aA*  zzzdricop  Call DRICOP
520aA*----------------------------------------------------------------
520aA
520aAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   endsl

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata

     C                   select

     C                   when      chk4err and %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C**                 if        zmsflag
     C**                 exsr      zm0105s
     C**                 else
     C**                 exsr      zm0105
     C**                 endif

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C**                 if        zmsflag
     C**                 exsr      zm0001s
     C**                 else
     C**                 exsr      zm0001
     C***                exsr      zzerrind
     C**                 endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr
