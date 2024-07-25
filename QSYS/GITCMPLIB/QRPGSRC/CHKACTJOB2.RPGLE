      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     * Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CHKACTSKT  Check for multiple instances of active job
     *             Built on information from APIs at Work book, Chap 5.
     *  31 August 2012
     *  Dave Sommerville
     *
     *  Revisions
     *
417 A*    08/31/12  DAS  6.40
     *      - Created.
     *
700 A*    06/28/16  LMC/MLB  7.00
     *      - Fix - Changed the replace value to *NO when creating
     *        the user space. This change is to reduce the copies
     *        of the CHKACTJOB *USRSPC object in QRPLOBJ library
     *        on client machines, when a regular IPL is not performed.
     *        The IPL cleans up the objects in QRPLOBJ library.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  User Space Prototype
     *----------------------------------------------------------------

     D  CrtUsrSpc      PR              *
     D   CrtSpcName                  20    const

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $pjobname       S             10
417aAD $pgroup         S              2
     D $pport          S              4
     D $preturn        S             10
     D jnlen           S              3  0
     D Jtypes          S              1    inz('*')
     D KeyI            S             10i 0
     D ListFormat      S              8
     D multiple        S               n
     D NbrKeys         S             10i 0 inz(1)
     D ObjType         S             10
     D Rrn             S              4  0
     D SpacePtr        S               *
     D Status          S             10
     D UserSpace       S             20    inz('CHKACTJOB2QTEMP')
     D UseStatus       S             10

     *----------------------------------------------------------------
     *  API Data Structures
     *----------------------------------------------------------------

     DKeys             DS
     D Key1                          10i 0 inz(1004)

     DQUSLH            DS
     D*                                             Qus Ljob Header
     D QUSJN00                 1     10             inz('*ALL')
     D*                                             Job Name
     D QUSUN00                11     20             inz('*ALL')
     D*                                             User Name
     D QUSJNBR00              21     26             inz('*ALL')
     D*                                             Job Number

     DQUSL020001       DS                           based(ListPoint)
     D*                                             Qus JOBL0200
     D QUSJNU00                1     10
     D*                                             Job Name Used
     D QUSUNU00               11     20
     D*                                             User Name Used
     D QUSJNBRU00             21     26
     D*                                             Job Number Used
     D QUSIJI00               27     42
     D*                                             Internal Job Id
     D QUSTATUS01             43     52
     D*                                             Status
     D QUSJT01                53     53
     D*                                             Job Type
     D QUSJS00                54     54
     D*                                             Job Subtype
     D QUSERVED18             55     56
     D*                                             Reserved
     D QUSJIS                 57     57
     D*                                             Job Info Status
     D QUSRSV205              58     60
     D*                                             Reserved2
     D QUSNBRFR               61     64B 0
     D*                                             Number Fields Rtnd
     d KeyData                65    180

     DQUSH0300         DS                  Based(GenDsPoint)
     D*                                             Qus Generic Header 0300
     D QUSUA00                 1     64
     D*                                             User Area
     D QUSSGH00               65     68B 0
     D*                                             Size Generic Header
     D QUSSRL00               69     72
     D*                                             Structure Release Level
     D QUSFN00                73     80
     D*                                             Format Name
     D QUSAU00                81     90
     D*                                             Api Used
     D QUSDTC00               91    103
     D*                                             Date Time Created
     D QUSIS00               104    104
     D*                                             Information Status
     D QUSSUS00              105    108B 0
     D*                                             Size User Space
     D QUSOIP00              109    112B 0
     D*                                             Offset Input Parameter
     D QUSSIP00              113    116B 0
     D*                                             Size Input Parameter
     D QUSOHS00              117    120B 0
     D*                                             Offset Header Section
     D QUSSHS00              121    124B 0
     D*                                             Size Header Section
     D QUSOLD00              125    128B 0
     D*                                             Offset List Data
     D QUSSLD00              129    132B 0
     D*                                             Size List Data
     D QUSNBRLE00            133    136B 0
     D*                                             Number List Entries
     D QUSSEE00              137    140B 0
     D*                                             Size Each Entry
     D QUSSIDLE00            141    144B 0
     D*                                             CCSID List Ent
     D QUSCID00              145    146
     D*                                             Country ID
     D QUSLID00              147    149
     D*                                             Language ID
     D QUSSLI00              150    150
     D*                                             Subset List Indicator
     D QUSRSV1               151    192
     D*                                             Reserved 1
     D QUSEPN                193    448
     D*                                             Entry Point Name
     D QUSRSV2               449    576
     D*                                             Reserved 2

     *----------------------------------------------------------------
     *  Standard API Error Data Structures
     *----------------------------------------------------------------

     DQUSEC            DS           116
     D QUSBPRV                 1      4B 0          inz(116)
     D QUSBAVL                 5      8B 0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pjobname  -  Job name
     *                    Assumed to be in format BFCggSpppp
     *                      where gg is the group number
     *                            pppp is the port number.
     *
     *    Return Parameters
     *      $preturn   *EXIST    - Active job exists once.
     *                 *NOTEXIST - Active job does not exist.
     *                 *MULTIPLE - Active job exists multiple times.
     *
     *----------------------------------------------------------------

     C     *entry        Plist
     C                   parm                    $pjobname
     C                   parm                    $preturn

417aAC                   eval      $pgroup = %subst($pjobname:4:2)
417aAC                   eval      $pport  = %subst($pjobname:7:4)

     C                   eval      $preturn = '*NOTEXIST'

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     *  Create user space for file list information.

     C                   Eval      SpacePtr = CrtUsrSpc(UserSpace)

     *  Call API to list jobs to user space.

     C                   eval      QusJN00 = $pjobname

     C                   Call      'QUSLJOB'
     C                   Parm                    UserSpace
     C                   Parm      'JOBL0200'    ListFormat
     C                   Parm                    QusLH
     C                   Parm      '*ACTIVE'     Status
     C                   Parm                    QusEc
     C                   Parm                    Jtypes
     C                   Parm                    NbrKeys
     C                   Parm                    Keys

     *  Load general data structure.

     C                   eval      GenDsPoint = SpacePtr

     *  If List API was complete or partially complete,
     *    and at least one entry was returned
     *  Then job exists at active status.

     C                   if        QuSIS00 = 'C' OR
     C                             QuSIS00 = 'P'
b01  C                   select
b01  C                   when      QusNbrLE00 = 1
     C                   eval      $preturn = '*EXIST'
b01  C                   when      QusNbrLE00 > 1
     C                   eval      $preturn = '*MULTIPLE'
     C                   endsl
     C                   endif

     *  Bye, bye.

     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  CrtUsrSpc Procedure
     *
     *    Create extendable user space, return pointer to it.
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     P  CrtUsrSpc      B                   export
     d  CrtUsrSpc      PI              *
     d   CrtSpcName                  20    const

      * Local Variables
     D PasSpcName      DS            20
     D  SLib                  11     20
     D ChgAttrDs       DS            13
     D  NumberAttr                    9B 0 inz(1)
     D  KeyAttr                       9B 0 inz(3)
     D  DataSize                      9B 0 inz(1)
     D  AttrData                      1    inz('1')
     D ListPtr         S               *
     D SpaceAttr       S             10    inz
     D SpaceAuth       S             10    INZ('*CHANGE')
     D SpaceLen        S              9B 0 INZ(4096)
     D SpaceReplc      S             10    INZ('*YES')
     D SpaceText       S             50
     D SpaceValue      S              1

      * Create the user space
     c                   move      CrtSpcName    PasSpcName
     C                   CALL      'QUSCRTUS'
     C                   PARM                    PasSpcName
     C                   PARM                    SpaceAttr
     C                   PARM                    SpaceLen
     C                   PARM                    SpaceValue
     C                   PARM                    SpaceAuth
     C                   PARM                    SpaceText
700 DC*                  PARM      '*YES'        SpaceReplc
700 MC                   PARM      '*NO '        SpaceReplc
     C                   PARM                    QusEc
      * Get pointer to user space
     C                   CALL      'QUSPTRUS'
     C                   PARM                    PasSpcName
     C                   PARM                    ListPtr
      * Change user space to be extendable
     C                   CALL      'QUSCUSAT'
     C                   PARM                    Slib
     C                   PARM                    PasSpcName
     C                   PARM                    ChgAttrDs
     C                   PARM                    QusEc

     c                   return    ListPtr
     P  CrtUsrSpc      E
