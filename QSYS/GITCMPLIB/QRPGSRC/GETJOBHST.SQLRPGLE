      /COPY *libl/qcopysrc,hspecs
     H dftactgrp(*NO)
     H actgrp(*CALLER)
     *----------------------------------------------------------------
     *
     *  GETJOBHST  -  Get job history snapshot
     *             http://www.code400.com/forum/archive/index.php?t-4415.html
     *  25 August 2015
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    08/25/15  DAS  7.00
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *   This program is call by never-ending CL progam GETJOBHIST,
     *   which sleeps for a user defined number of minutes then
     *   calls this program.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Status Codes
     *
     *   *ALL
     *   *ACTIVE
     *   *JOBQ
     *   *OUTQ
     *   *ALL
     *
     * Type Codes
     *
     *   *  -  All
     *   A  -  Autostart
     *   B  -  Batch
     *   I  -  Interactive
     *   M  -  Subsystem Monitor
     *   R  -  Spooled Reader
     *   S  -  System
     *   W  -  Spooled Writer
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Fjobhist   if a e           k disk

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

650aA /copy qcopysrc,p.getclien
      /copy qcopysrc,p.bfcdteti

     D  CrtUsrSpc      PR              *
     D   CrtSpcName                  20    const

     D RtvIpAdr        PR            20a
     D  Device                       10a   CONST

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d count           s              6  0
     d count2          s              3  0
     d Device          s             10a
     d I_Net_Adr       s             16a
     d Jtypes          s              1    inz('I')
     d KeyI            s             10i 0
     d keys            s             10i 0 inz dim(1)
     d LenStr          s              4  0
     d ListFormat      s              8
     d NbrKeys         s             10i 0 inz(1)
     d ObjType         s             10
     d SpacePtr        s               *
     d Status          s             10
     d UserSpace       s             20    inz('GETJOBHISTQTEMP')
     d UseStatus       s             10    inz('*ALL')
     d UseType         s              1    inz('I')
     d workjob         s             10

     *----------------------------------------------------------------
     *  API Data Structures
     *----------------------------------------------------------------

     dQUSLH            DS
      *                                             Qus Ljob Header
     d QUSJN00                 1     10             inz('*ALL')
      *                                             Job Name
     d QUSUN00                11     20             inz('*ALL')
      *                                             User Name
     d QUSJNBR00              21     26             inz('*ALL')
      *                                             Job Number
     dQUSLKF           DS
      *                                             Qus Ljob Key Fields
     d QUSLFIR                 1      4B 0
      *                                             Length Field Info Rtnd
     d QUSKF                   5      8B 0
      *                                             Key Field
     d QUSTOD                  9      9
      *                                             Type Of Data
     d QUSERVED17             10     12
      *                                             Reserved
     d QUSLD00                13     16B 0
      *                                             Length Data
      *QUSDATA06              17     17
      *
      *                             Varying length
      *QUSERVED17             18     18
      *
      *                             Varying length
     dQUSL020001       DS                           based(ListPoint)
      *                                             Qus JOBL0200
     d QUSJNU00                1     10
      *                                             Job Name Used
     d QUSUNU00               11     20
     d QUSUNU00CHR1           11     11
      *                                             User Name Used
     d QUSJNBRU00             21     26
      *                                             Job Number Used
     d QUSIJI00               27     42
      *                                             Internal Job Id
     d QUSTATUS01             43     52
      *                                             Status
     d QUSJT01                53     53
      *                                             Job Type
     d QUSJS00                54     54
      *                                             Job Subtype
     d QUSERVED18             55     56
      *                                             Reserved
     d QUSJIS                 57     57
      *                                             Job Info Status
     d QUSRSV205              58     60
      *                                             Reserved2
     d QUSNBRFR               61     64B 0
      *                                             Number Fields Rtnd
     d KeyData                65    180

     d QUSKFI          DS            16
     d  QUSLFIR01                     9B 0 OVERLAY(QUSKFI:00001)
     d  QUSKF00                       9B 0 OVERLAY(QUSKFI:00005)
     d  QUSTOD01                      1    OVERLAY(QUSKFI:00009)
     d  QUSERVED33                    3    OVERLAY(QUSKFI:00010)
     d  QUSLD01                       9B 0 OVERLAY(QUSKFI:00013)
      *
      *                                             Varying length
     dQUSH0300         DS                  Based(GenDsPoint)
      *                                             Qus Generic Header 0300
     d QUSUA00                 1     64
      *                                             User Area
     d QUSSGH00               65     68B 0
      *                                             Size Generic Header
     d QUSSRL00               69     72
      *                                             Structure Release Level
     d QUSFN00                73     80
      *                                             Format Name
     d QUSAU00                81     90
      *                                             Api Used
     d QUSDTC00               91    103
      *                                             Date Time Created
     d QUSIS00               104    104
      *                                             Information Status
     d QUSSUS00              105    108B 0
      *                                             Size User Space
     d QUSOIP00              109    112B 0
      *                                             Offset Input Parameter
     d QUSSIP00              113    116B 0
      *                                             Size Input Parameter
     d QUSOHS00              117    120B 0
      *                                             Offset Header Section
     d QUSSHS00              121    124B 0
      *                                             Size Header Section
     d QUSOLD00              125    128B 0
      *                                             Offset List Data
     d QUSSLD00              129    132B 0
      *                                             Size List Data
     d QUSNBRLE00            133    136B 0
      *                                             Number List Entries
     d QUSSEE00              137    140B 0
      *                                             Size Each Entry
     d QUSSIDLE00            141    144B 0
      *                                             CCSID List Ent
     d QUSCID00              145    146
      *                                             Country ID
     d QUSLID00              147    149
      *                                             Language ID
     d QUSSLI00              150    150
      *                                             Subset List Indicator
     d QUSRSV1               151    192
      *                                             Reserved 1
     d QUSEPN                193    448
      *                                             Entry Point Name
     d QUSRSV2               449    576
      *                                             Reserved 2

     *----------------------------------------------------------------
     *  Standard API Error Data Structures
     *----------------------------------------------------------------

     dQUSEC            DS           116
     d QUSBPRV                 1      4B 0          inz(116)
     d QUSBAVL                 5      8B 0

     *----------------------------------------------------------------
     *  External Called Programs
     *----------------------------------------------------------------

     d $getdevdata     PR                  extpgm('QUSLJOB')
     d   UserSpace                   20A   Const
     d   ListFormat                   8A   Const
     d   QusLH                      180A   Const
     d   Status                      10A   Const
     d   QusEc                      116A   Const
     d   Jtypes                       1A   Const
     d   NbrKeys                     10i 0 Const
     d   Keys                        10i 0 dim(3) Const

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z
     D ts              s               z
640pAD startStampLoc   s               z
640pAD startStampSys   s               z
640pAD startStampUC    s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     D bfcoffset       s              3  0 inz(0)
640jaD ucOffset        s              3  0

     d tsDate          s               d
     d tsTime          s              6s 0
     d sundayDate      s               d

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         getclient(jhclient: jhcliloc);

         SpacePtr = CrtUsrSpc(UserSpace);

         exsr GetCurrStamp;
         exsr SplitStamp;

         exsr GetJobs;
         exsr WrtJobs;

         *inlr = *on;

      /end-free

     *----------------------------------------------------------------
     *  GetCurrStamp   Get current timestamps
     *----------------------------------------------------------------

      /free
       begsr GetCurrStamp;

         getmicrotime(currstampuc:currstampsys);
640jA    ucOffset = %diff(currstampuc: currstampsys: *HOURS);
         currstamploc = currstampsys + %hours(bfcoffset);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetJobs  Get list of jobs
     *----------------------------------------------------------------

      /free
       begsr GetJobs;

         // list the jobs to our userspace

              keys(1) = 101;

         $getdevdata(UserSpace  :
                     'JOBL0200' :
                     QusLH      :
                     UseStatus  :
                     QusEc      :
                     UseType    :
                     NbrKeys    :
                     Keys
                    );

        // Load the general data structure

        GenDsPoint = SpacePtr;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  SplitStamp    Split stamp into individual pieces
     *----------------------------------------------------------------

      /free
       begsr SplitStamp;

         tsDate = %date(currstamploc);
         jhDate = %dec(tsDate:*ymd);
         jhTime = %dec(%time(currstamploc):*hms);
         exec sql set :jhdow = dayofweek(:tsDate),
                      :jhmonth = month(:tsDate);
         sundayDate = tsDate - %days(jhdow-1);
         jhSunDte = %dec(sundayDate:*ymd);
         jhCount = 1;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  WrtJobs  Write jobs to JOBHIST
     *----------------------------------------------------------------

      /free
       begsr WrtJobs;

         // If the list API was complete or partially complete

         if  QuSIS00 = 'C'
          or QuSIS00 = 'P';

           // Load the list data structure

           ListPoint = GenDsPoint + QusOLD00;

           for count = 1 to QusNbrLE00;

             if QUSTATUS01 = '*ACTIVE'
               and QUSUNU00CHR1 <> 'Q';

                 KeyI = 1;
                 for count2 = 1 to QusNbrFr;
                   QusKFI = %subst(KeyData:KeyI:16);
                   select;
                     when QusKf00 = 101;
                       jhstat = %subst(KeyData:KeyI+16:QusLd01);
                   endsl;
                   KeyI += QusLFir01;
                 endfor;

                 if jhstat <> 'DSC';
                   jhjob  = Qusjnu00;
                   jhjobnbr = QUSJNBRU00;
                   jhuser = QusUnU00;
                   jhip = %trim(RtvIpAdr(QUSJNU00));
                   jhaddts = currstamploc;
                   jhadduc = currstampuc;
                   write jhrec;
                 endif;

             endif;

             ListPoint +=  QusSEE00;

e01        endfor;

         endif;

       endsr;
      /end-free

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
     C                   PARM      '*YES'        SpaceReplc
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

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  RtvIpAdr Procedure
     *
     *    Retrieve PC's IP Address
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     P RtvIpAdr        B                   Export
     D RtvIpAdr        PI            20A
     D  Inp_Device                   10A   Const
     D Apierr          DS
     D  Bytprv                 1      4B 0 Inz(216)
     D  Bytavl                 5      8B 0 Inz
     D  Errid                  9     15A   Inz
     D  Rsvd                  16     16A   Inz
     D  Errdta                17    216A   Inz
     D Net_Address     S             20A   INZ
     D Format          S              8A   Inz('DEVD0600')
     D Rcvar           S           5000A   Inz
     D Varlen          S              4B 0 Inz(5000)
     C                   Eval      Device = Inp_Device
     C                   Call      'QDCRDEVD'
     C                   Parm                    Rcvar
     C                   Parm                    Varlen
     C                   Parm                    Format
     C                   Parm                    Device
     C                   Parm                    Apierr
     C                   If        BytAvl = 0
     C                   Eval      Net_Address = %Subst(Rcvar:877:16)
     C                   Endif
     C                   Return    Net_Address
     P RtvIpAdr        E
