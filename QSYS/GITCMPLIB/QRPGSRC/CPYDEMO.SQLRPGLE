      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  CPYDEMO    Copy data for Demo / Test
     *  24 September 2010
     *  Roxanne Harrison
     *
650bA*  Instructions to create a new lib for demo or testing:
     *  1. Create new lib BFCDEMOxx (xx = $pcode).
     *  2. Copy your base demo, test, or live lib to BFCDEMOxx.
     *  3. Call cpydemo parm('*CLEAR' 'xx' '' '' '') to clear the files
     *     in your new lib BFCDEMOxx.
     *  4. Call cpydemo parm('*GETALL' 'xx' 'fromlib' 'yyyymmdd' 'yyyymmdd')
     *     to copy data from whatever demo, test, or live lib you wish to
     *     pull data from for the files in your new lib, and enter the from
     *     and to dates you wish to include.
     *
     *  Revisions
     *
530 A*    09/24/10  RH   5.30
     *      - Created using CPYROUTE programs.
650a *    03/22/13  KDE  6.50a
     *      - Added support for KIT Tables
650bA*    02/06/14  RBD  6.50b
     *      - Fix: cwexcp date should be cxgdte.
     *      - Fix: rnrdte date should be orrdte.
     *      - Fix: vsgdte date should be vxgdte.
     *      - Fix: ldfret date should be ldfstd.
650bA*    12/19/17  MR
     *      - Recompiled due to database change to PIRUSERA.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD    *CLEAR - Clear files in BFCNEWFcc library.
     *               *GETALL - Get data for all files, put in BFCNEWFcc
     *               *GETTABLE - Get data for table files put in BFCNEWFcc
     *      $PCODE   Code to append to BFCNEW library name.
     *      $PLIB    Library to get data from / to
     *      $PFMDT   From date
     *      $PTODT   To date
     *
     *    Returned Parameters
     *      None
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D sq              c                   Const('''')

     D field           s             10a   inz(' ')
     D file            s             10a   inz(' ')
     D fromTS          s             26
     D newlib          s             10a   inz(' ')
     D prtid           s              5a   inz(' ')
     D routelib        s             10a   inz(' ')
     D sqlfrom         s             50a   inz(' ')
     D sqlstmt         s           2000a   inz(' ')
     D sqlwhere        S            500a   inz(' ')
     D toTs            s             26

     D                 ds
     D  yyyymmdd               1      8s 0
     D    yyyy                 1      4
     D    mm                   5      6
     D    dd                   7      8

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    $pcmd             9
     c                   parm                    $pcode            2
     c                   parm                    $plib            10
     c                   parm                    $pfmdt            8
     c                   parm                    $ptodt            8

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     c                   eval      newlib = 'bfcdemo'
     c                                      + %trim($pcode)

     *  Select all records ...
     *     Table files.

     *     ACTIVITY
     c                   eval      file = 'activity'
     c                   exsr      chktblf

     *     ADJCODE
     c                   eval      file = 'adjcode'
     c                   exsr      chktblf

     *     ADJMISC
     c                   eval      file = 'adjmisc'
     c                   exsr      chktblf
     *     BATCTL
     c                   eval      file = 'batctl'
     c                   exsr      chktblf
     *     BFCACAT
     c                   eval      file = 'bfcacat'
     c                   exsr      chktblf

     *     BFCAUTH
     c                   eval      file = 'bfcauth'
     c                   exsr      chktblf

     *     BFCCLIENT
     c                   eval      file = 'bfcclient'
     c                   exsr      chktblf

     *     BLDCODE
     c                   eval      file = 'bldcode'
     c                   exsr      chktblf

     *     CLAMPRT
     c                   eval      file = 'clamprt'
     c                   exsr      chktblf

     *     CREW
     c                   eval      file = 'crew'
     c                   exsr      chktblf

     *     CTWZONDEV
     c                   eval      file = 'ctwzondev'
     c                   exsr      chktblf

     *     DCKDOOR
     c                   eval      file = 'dckdoor'
     c                   exsr      chktblf

     *     DDOPTS
     c                   eval      file = 'ddopts'
     c                   exsr      chktblf

     *     DEPTDEF
     c                   eval      file = 'deptdef'
     c                   exsr      chktblf

     *     DEPTDSG
     c                   eval      file = 'deptdsg'
     c                   exsr      chktblf

     *     DESIG
     c                   eval      file = 'desig'
     c                   exsr      chktblf

     *     DESIGSP
     c                   eval      file = 'desigsp'
     c                   exsr      chktblf

     *     DEVGRPD
     c                   eval      file = 'devgrpd'
     c                   exsr      chktblf

     *     DEVGRPH
     c                   eval      file = 'devgrph'
     c                   exsr      chktblf

     *     DOCDOOR
     c                   eval      file = 'docdoor'
     c                   exsr      chktblf

     *     DOCMTRX
     c                   eval      file = 'docmtrx'
     c                   exsr      chktblf

     *     DRIFILE
     c                   eval      file = 'drifile'
     c                   exsr      chktblf

     *     EQUIP
     c                   eval      file = 'equip'
     c                   exsr      chktblf

     *     EQUIPQ
     c                   eval      file = 'equipq'
     c                   exsr      chktblf

     *     EQUIPY
     c                   eval      file = 'equipy'
     c                   exsr      chktblf

     *     FLGTYP
     c                   eval      file = 'flgtyp'
     c                   exsr      chktblf

     *     INVNXTP
     c                   eval      file = 'invnxtp'
     c                   exsr      chktblf

     *     INVPAGH
     c                   eval      file = 'invpagh'
     c                   exsr      chktblf

     *     INVPASH
     c                   eval      file = 'invpash'
     c                   exsr      chktblf

     *     INVSASH
     c                   eval      file = 'invsash'
     c                   exsr      chktblf

     *     INVSCWH
     c                   eval      file = 'invscwh'
     c                   exsr      chktblf

     *     INVSLTH
     c                   eval      file = 'invslth'
     c                   exsr      chktblf

     *     INVTEAM
     c                   eval      file = 'invteam'
     c                   exsr      chktblf

     *     ITEMAVG
     c                   eval      file = 'itemavg'
     c                   exsr      chktblf

     *     ITEMCAT
     c                   eval      file = 'itemcat'
     c                   exsr      chktblf

     *     ITEMDEF
     c                   eval      file = 'itemdef'
     c                   exsr      chktblf

     *     ITEMDSC
     c                   eval      file = 'itemdsc'
     c                   exsr      chktblf

     *     ITEMEXT
     c                   eval      file = 'itemext'
     c                   exsr      chktblf

     *     ITEMFLD
     c                   eval      file = 'itemfld'
     c                   exsr      chktblf

     *     ITEMLNK
     c                   eval      file = 'itemlnk'
     c                   exsr      chktblf

     *     ITEMMSC
     c                   eval      file = 'itemmsc'
     c                   exsr      chktblf

     *     ITEMORD
     c                   eval      file = 'itemord'
     c                   exsr      chktblf

     *     ITEMQTY
     c                   eval      file = 'itemqty'
     c                   exsr      chktblf

     *     ITEMSLS
     c                   eval      file = 'itemsls'
     c                   exsr      chktblf

     *     ITMDIMN
     c                   eval      file = 'itmdimn'
     c                   exsr      chktblf

     *     IT112USR
     c                   eval      file = 'it112usr'
     c                   exsr      chktblf

     *     KITCOMP
     c                   eval      file = 'kitcomp'
     c                   exsr      chktblf

650aA*     KITITEM
650aAc                   eval      file = 'kititem'
650aAc                   exsr      chktblf

     *     LBLFMTD
     c                   eval      file = 'lblfmtd'
     c                   exsr      chktblf

     *     LBLFMTH
     c                   eval      file = 'lblfmth'
     c                   exsr      chktblf

     *     LBLFMTT
     c                   eval      file = 'lblfmtt'
     c                   exsr      chktblf

     *     LBLFMTV
     c                   eval      file = 'lblfmtv'
     c                   exsr      chktblf

     *     LDRCOMC
     c                   eval      file = 'ldrcomc'
     c                   exsr      chktblf

     *     LDRDOOR
     c                   eval      file = 'ldrdoor'
     c                   exsr      chktblf

     *     LDRDRLOG
     c                   eval      file = 'ldrdrlog'
     c                   exsr      chktblf

     *     LICACTIVE
     c                   eval      file = 'licactive'
     c                   exsr      chktblf

     *     LICINFOCD
     c                   eval      file = 'licinfocd'
     c                   exsr      chktblf

     *     LOADCND
     c                   eval      file = 'loadcnd'
     c                   exsr      chktblf

     *     LRSNCODE
     c                   eval      file = 'lrsncode'
     c                   exsr      chktblf

     *     MFR
     c                   eval      file = 'mfr'
     c                   exsr      chktblf

     *     MFRDATE
     c                   eval      file = 'mfrdate'
     c                   exsr      chktblf

     *     MFRITEM
     c                   eval      file = 'mfritem'
     c                   exsr      chktblf

     *     MFRTABLE
     c                   eval      file = 'mfrtable'
     c                   exsr      chktblf

     *     NAVYDEV
     c                   eval      file = 'navydev'
     c                   exsr      chktblf

     *     OPTIOND
     c                   eval      file = 'optiond'
     c                   exsr      chktblf

     *     OPTIONE
     c                   eval      file = 'optione'
     c                   exsr      chktblf

     *     OPTIONS
     c                   eval      file = 'options'
     c                   exsr      chktblf

     *     OPTIONZ
     c                   eval      file = 'optionz'
     c                   exsr      chktblf

     *     PACKAGE
     c                   eval      file = 'package'
     c                   exsr      chktblf

     *     PALLET
     c                   eval      file = 'pallet'
     c                   exsr      chktblf

     *     PATTERN
     c                   eval      file = 'pattern'
     c                   exsr      chktblf

     *     PGMUSRID
     c                   eval      file = 'pgmusrid'
     c                   exsr      chktblf

     *     PIRBUYR
     c                   eval      file = 'pirbuyr'
     c                   exsr      chktblf

     *     PIRDICT
     c                   eval      file = 'pirdict'
     c                   exsr      chktblf

     *     PIRDICTEPM
     c                   eval      file = 'pirdictepm'
     c                   exsr      chktblf

     *     PIRET#
     c                   eval      file = 'piret#'
     c                   exsr      chktblf

     *     PIREW#
     c                   eval      file = 'pirew#'
     c                   exsr      chktblf

     *     PIRITEM
     c                   eval      file = 'piritem'
     c                   exsr      chktblf

     *     PIRITMS
     c                   eval      file = 'piritms'
     c                   exsr      chktblf

     *     PIRORD#
     c                   eval      file = 'pirord#'
     c                   exsr      chktblf

     *     PIRPRNT
     c                   eval      file = 'pirprnt'
     c                   exsr      chktblf

     *     PIRRECID#
     c                   eval      file = 'pirrecid#'
     c                   exsr      chktblf

     *     PIRRTE#
     c                   eval      file = 'pirrte#'
     c                   exsr      chktblf

     *     PIRSEQ
     c                   eval      file = 'pirseq'
     c                   exsr      chktblf

     *     PIRSLCT
     c                   eval      file = 'pirslct'
     c                   exsr      chktblf

     *     PIRUSER
     c                   eval      file = 'piruser'
     c                   exsr      chktblf

     *     PIRUSERA
     c                   eval      file = 'pirusera'
     c                   exsr      chktblf

     *     PIRWRKORD#
     c                   eval      file = 'pirwrkord#'
     c                   exsr      chktblf

     *     POCTYPE
     c                   eval      file = 'poctype'
     c                   exsr      chktblf

     *     PODTL
     c                   eval      file = 'podtl'
     c                   exsr      chktblf

     *     PODTLM
     c                   eval      file = 'podtlm'
     c                   exsr      chktblf

     *     POEXCP
     c                   eval      file = 'poexcp'
     c                   exsr      chktblf

     *     POFIFO
     c                   eval      file = 'pofifo'
     c                   exsr      chktblf

     *     POHACCP
     c                   eval      file = 'pohaccp'
     c                   exsr      chktblf

     *     POHDR
     c                   eval      file = 'pohdr'
     c                   exsr      chktblf

     *     POHDRM
     c                   eval      file = 'pohdrm'
     c                   exsr      chktblf

     *     POSPO
     c                   eval      file = 'pospo'
     c                   exsr      chktblf

     *     PRODARA
     c                   eval      file = 'prodara'
     c                   exsr      chktblf

     *     PRODTYP
     c                   eval      file = 'prodtyp'
     c                   exsr      chktblf

     *     PRPLFIL
     c                   eval      file = 'prplfil'
     c                   exsr      chktblf

     *     PT640USR
     c                   eval      file = 'pt640usr'
     c                   exsr      chktblf

     *     PTERRPF
     c                   eval      file = 'pterrpf'
     c                   exsr      chktblf

     *     RACKS
     c                   eval      file = 'racks'
     c                   exsr      chktblf

     *     RCVAREA
     c                   eval      file = 'rcvarea'
     c                   exsr      chktblf

     *     RCVEXCP
     c                   eval      file = 'rcvexcp'
     c                   exsr      chktblf

     *     RDSCODE
     c                   eval      file = 'rdscode'
     c                   exsr      chktblf

     *     REPORTE
     c                   eval      file = 'reporte'
     c                   exsr      chktblf

     *     REPORTS
     c                   eval      file = 'reports'
     c                   exsr      chktblf

     *     RPTOVR
     c                   eval      file = 'rptovr'
     c                   exsr      chktblf

     *     RPTOVRDTL
     c                   eval      file = 'rptovrdtl'
     c                   exsr      chktblf

     *     RPTOVRE
     c                   eval      file = 'rptovre'
     c                   exsr      chktblf

     *     RPTOVRHDR
     c                   eval      file = 'rptovrhdr'
     c                   exsr      chktblf

     *     RSNCODE
     c                   eval      file = 'rsncode'
     c                   exsr      chktblf

     *     RTNCODE
     c                   eval      file = 'rtncode'
     c                   exsr      chktblf

     *     SHIFT
     c                   eval      file = 'shift'
     c                   exsr      chktblf

     *     SIZETRLR
     c                   eval      file = 'sizetrlr'
     c                   exsr      chktblf

     *     SI265ERR
     c                   eval      file = 'si265err'
     c                   exsr      chktblf

     *     SLOT
     c                   eval      file = 'slot'
     c                   exsr      chktblf

     *     SLOTDEF
     c                   eval      file = 'slotdef'
     c                   exsr      chktblf

     *     SLOTDGT
     c                   eval      file = 'slotdgt'
     c                   exsr      chktblf

     *     SLOTDGTA
     c                   eval      file = 'slotdgta'
     c                   exsr      chktblf

     *     SLOTDTE
     c                   eval      file = 'slotdte'
     c                   exsr      chktblf

     *     SLOTPOS
     c                   eval      file = 'slotpos'
     c                   exsr      chktblf

     *     SLOTSTAT
     c                   eval      file = 'slotstat'
     c                   exsr      chktblf

     *     SLOTXREF
     c                   eval      file = 'slotxref'
     c                   exsr      chktblf

     *     SPCLAISL
     c                   eval      file = 'spclaisl'
     c                   exsr      chktblf

     *     SPCLORD
     c                   eval      file = 'spclord'
     c                   exsr      chktblf

     *     SSLOT
     c                   eval      file = 'sslot'
     c                   exsr      chktblf

     *     STAGD
     c                   eval      file = 'stagd'
     c                   exsr      chktblf

     *     STAGH
     c                   eval      file = 'stagh'
     c                   exsr      chktblf

     *     SUPERUSR
     c                   eval      file = 'superusr'
     c                   exsr      chktblf

     *     SVSLOT
     c                   eval      file = 'svslot'
     c                   exsr      chktblf

     *     TALKMAN
     c                   eval      file = 'talkman'
     c                   exsr      chktblf

     *     TASK
     c                   eval      file = 'task'
     c                   exsr      chktblf

     *     TASKCAT
     c                   eval      file = 'taskcat'
     c                   exsr      chktblf

     *     TASKDET
     c                   eval      file = 'taskdet'
     c                   exsr      chktblf

     *     TASKSUB
     c                   eval      file = 'tasksub'
     c                   exsr      chktblf

     *     TAXCTL
     c                   eval      file = 'taxctl'
     c                   exsr      chktblf

     *     TFRCODE
     c                   eval      file = 'tfrcode'
     c                   exsr      chktblf

     *     TIEDEF
     c                   eval      file = 'tiedef'
     c                   exsr      chktblf

     *     TIEHIGH
     c                   eval      file = 'tiehigh'
     c                   exsr      chktblf

     *     TMANPRT
     c                   eval      file = 'tmanprt'
     c                   exsr      chktblf

     *     TRANPH
     c                   eval      file = 'tranph'
     c                   exsr      chktblf

     *     TRKCOMP
     c                   eval      file = 'trkcomp'
     c                   exsr      chktblf

     *     TRLSIZE
     c                   eval      file = 'trlsize'
     c                   exsr      chktblf

     *     TRUCK
     c                   eval      file = 'truck'
     c                   exsr      chktblf

     *     TRUCKD
     c                   eval      file = 'truckd'
     c                   exsr      chktblf

     *     TRUCKDFT
     c                   eval      file = 'truckdft'
     c                   exsr      chktblf

     *     TRUCKH
     c                   eval      file = 'truckh'
     c                   exsr      chktblf

     *     UNMESR
     c                   eval      file = 'unmesr'
     c                   exsr      chktblf

     *     UNMESRV
     c                   eval      file = 'unmesrv'
     c                   exsr      chktblf

     *     UPC
     c                   eval      file = 'upc'
     c                   exsr      chktblf

     *     VSLOT
     c                   eval      file = 'vslot'
     c                   exsr      chktblf

     *     WALGRNDEV
     c                   eval      file = 'walgrndev'
     c                   exsr      chktblf

     *     WAREHS
     c                   eval      file = 'warehs'
     c                   exsr      chktblf

     *     WAREHSAD
     c                   eval      file = 'warehsad'
     c                   exsr      chktblf

     *     WHDEPT
     c                   eval      file = 'whdept'
     c                   exsr      chktblf

     *     ZONED
     c                   eval      file = 'zoned'
     c                   exsr      chktblf

     *     ZONEH
     c                   eval      file = 'zoneh'
     c                   exsr      chktblf

     *  Select using date range..

     *     BULKDRP
     *   Datestamp
     c                   eval      file = 'bulkdrp'
     c                   eval      field = 'bdcrts'
     c                   exsr      chkdtsf

     *     CKEMPL
     c                   eval      file = 'ckempl'
     c                   eval      field = 'cesdte'
     c                   exsr      chkdtef

     *     CWEXCP
     c                   eval      file = 'cwexcp'
650bDc**                 eval      field = 'exgdte'
650bMc                   eval      field = 'cxgdte'
     c                   exsr      chkdtef

     *     DLYHITR
     c                   eval      file = 'dlyhitr'
     c                   eval      field = 'hrbegdte'
     c                   exsr      chkdtef

     *     DLYHITS
     c                   eval      file = 'dlyhits'
     c                   eval      field = 'htbegdte'
     c                   exsr      chkdtef

     *     DLYQTY
     c                   eval      file = 'dlyqty'
     c                   eval      field = 'dqrdte'
     c                   exsr      chkdtef

     *     DLYQTYO
     c                   eval      file = 'dlyqtyo'
     c                   eval      field = 'dordte'
     c                   exsr      chkdtef

     *     DLYQTYT
     c                   eval      file = 'dlyqtyt'
     c                   eval      field = 'dtrdte'
     c                   exsr      chkdtef

     *     DLYZROR
     c                   eval      file = 'dlyzror'
     c                   eval      field = 'hzbegdte'
     c                   exsr      chkdtef

     *     DOCHIST
     c                   eval      file = 'dochist'
     c                   eval      field = 'dhhdte'
     c                   exsr      chkdtef

     *     EQUIPA    Datestamp
     c                   eval      file = 'equipa'
     c                   eval      field = 'easdts'
     c                   exsr      chkdtef

     *     EQUIPH    Datestamp
     c                   eval      file = 'equiph'
     c                   eval      field = 'ehedts'
     c                   exsr      chkdtef

     *     EQUIPR
     c                   eval      file = 'equipr'
     c                   eval      field = 'ersdte'
     c                   exsr      chkdtef

     *     EQUIPT    Datestamp
     c                   eval      file = 'equipt'
     c                   eval      field = 'etodts'
     c                   exsr      chkdtef

     *     EQUIPW
     c                   eval      file = 'equipw'
     c                   eval      field = 'ewgdte'
     c                   exsr      chkdtef

     *     GAP
     c                   eval      file = 'gap'
     c                   eval      field = 'gapdate'
     c                   exsr      chkdtef

     *     ITEMADJ
     c                   eval      file = 'itemadj'
     c                   eval      field = 'iadate'
     c                   exsr      chkdtef

     *     ITEMADJM
     c                   eval      file = 'itemadjm'
     c                   eval      field = 'indate'
     c                   exsr      chkdtef

     *     ITEMZRO
     c                   eval      file = 'itemzro'
     c                   eval      field = 'izzdte'
     c                   exsr      chkdtef

     *     ITMEXCP
     c                   eval      file = 'itmexcp'
     c                   eval      field = 'exgdte'
     c                   exsr      chkdtef

     *     KITORDD
     c                   eval      file = 'kitordd'
     c                   eval      field = 'koddte'
     c                   exsr      chkdtef

     *     KITORDH
     c                   eval      file = 'kitordh'
     c                   eval      field = 'kohodt'
     c                   exsr      chkdtef

     *     LABEL
     c                   eval      file = 'label'
     c                   eval      field = 'lbrdte'
     c                   exsr      chkdtef

     *     LABELDO
     *     Datestamp
     c                   eval      file = 'labeldo'
     c                   eval      field = 'lboaddts'
     c                   exsr      chkdtsf
     *     LICINFO
     *     Datestamp
     c                   eval      file = 'licinfo'
     c                   eval      field = 'lnaddts'
     c                   exsr      chkdtsf

     *     LICLOG
     *     Datestamp
     c                   eval      file = 'liclog'
     c                   eval      field = 'lladdts'
     c                   exsr      chkdtsf

     *     LUMPER
     c                   eval      file = 'lumper'
     c                   eval      field = 'lmrdte'
     c                   exsr      chkdtef

     *     ORRTN
     c                   eval      file = 'orrtn'
650bDc**                 eval      field = 'rnrdte'
650bMc                   eval      field = 'orrdte'
     c                   exsr      chkdtef

     *     ORRTNM
     c                   eval      file = 'orrtnm'
     c                   eval      field = 'rmrdte'
     c                   exsr      chkdtef

     *     ORTNBAT
     c                   eval      file = 'ortnbat'
     c                   eval      field = 'obrudt'
     c                   exsr      chkdtef

     *     PIRTRAN
     c                   eval      file = 'pirtran'
     c                   eval      field = 'ptgdte'
     c                   exsr      chkdtef

     *     PIRTRCK
     c                   eval      file = 'pirtrck'
     c                   eval      field = 'trrcdt'
     c                   exsr      chkdtef

     *     POHDTL
     c                   eval      file = 'pohdtl'
     c                   eval      field = 'phdedt'
     c                   exsr      chkdtef

     *     POHDTLM
     c                   eval      file = 'pohdtlm'
     c                   eval      field = 'phdmed'
     c                   exsr      chkdtef

     *     POHEXCP
     c                   eval      file = 'pohexcp'
     c                   eval      field = 'pheedt'
     c                   exsr      chkdtef

     *     POHHACCP
     c                   eval      file = 'pohhaccp'
     c                   eval      field = 'hahedt'
     c                   exsr      chkdtef

     *     POHHDR
     c                   eval      file = 'pohhdr'
     c                   eval      field = 'phhedt'
     c                   exsr      chkdtef

     *     POHHDRM
     c                   eval      file = 'pohhdrm'
     c                   eval      field = 'phhmed'
     c                   exsr      chkdtef

     *     PORCV
     c                   eval      file = 'porcv'
     c                   eval      field = 'pordte'
     c                   exsr      chkdtef

     *     RTEHED
     c                   eval      file = 'rtehed'
     c                   eval      field = 'rhstsd'
     c                   exsr      chkdtef

     *     RTEUNDO
     c                   eval      file = 'rteundo'
     c                   eval      field = 'rudate'
     c                   exsr      chkdtef

     *     SLOTOUT   Datestamp
     c                   eval      file = 'slotout'
     c                   eval      field = 'soadts'
     c                   exsr      chkdtsf

     *     SLTRPEX
     c                   eval      file = 'sltrpex'
     c                   eval      field = 'seadte'
     c                   exsr      chkdtef

     *     STATLBL
     c                   eval      file = 'statlbl'
     c                   eval      field = 'stdate'
     c                   exsr      chkdtef

     *     STATTRN
     c                   eval      file = 'stattrn'
     c                   eval      field = 'stdate'
     c                   exsr      chkdtef

     *     TRANLOG
     c                   eval      file = 'tranlog'
     c                   eval      field = 'tsdte'
     c                   exsr      chkdtef

     *     TRAVELD
     *     datestamp
     c                   eval      file = 'traveld'
     c                   eval      field = 'trdchgts'
     c                   exsr      chkdtsf
     *     TRAVELH
     *     datestamp
     c                   eval      file = 'travelh'
     c                   eval      field = 'trhchgts'
     c                   exsr      chkdtsf

     *     UPCLOG
     c                   eval      file = 'upclog'
     c                   eval      field = 'uladte'
     c                   exsr      chkdtef

     *     VOEXCP    Datestamp
     c                   eval      file = 'voexcp'
     c                   eval      field = 'sxgdts'
     c                   exsr      chkdtsf

     *     VSLEXCP
     c                   eval      file = 'vslexcp'
650bDc**                 eval      field = 'vsgdte'
650bMc                   eval      field = 'vxgdte'
     c                   exsr      chkdtef

     *     WORKLBL
     c                   eval      file = 'worklbl'
     c                   eval      field = 'lwrdte'
     c                   exsr      chkdtef



     *  Select using linked file.
     *   Use Route file

     *   CHKLBL
     c                   eval      file = 'chklbl'
     c                   eval      field = 'clrtid'
     c                   exsr      chkrtef

     *   CHKPLT
     c                   eval      file = 'chkplt'
     c                   eval      field = 'cprtid'
     c                   exsr      chkrtef

     *   CHKTRN
     c                   eval      file = 'chktrn'
     c                   eval      field = 'ctrtid'
     c                   exsr      chkrtef

     *   CKRCTL
     c                   eval      file = 'ckrctl'
     c                   eval      field = '$ckrti'
     c                   exsr      chkrtef

     *   CKRDATA
     c                   eval      file = 'ckrdata'
     c                   eval      field = 'ckrtid'
     c                   exsr      chkrtef

     *   CKRSTMP
     c                   eval      file = 'ckrstmp'
     c                   eval      field = 'tsrtid'
     c                   exsr      chkrtef

     *   DRVRFLG
     c                   eval      file = 'drvrflg'
     c                   eval      field = 'drte#'
     c                   exsr      chkrtef

     *   EQUIPYS
     c                   eval      file = 'equipys'
     c                   eval      field = 'esrtid'
     c                   exsr      chkrtef

     *   GOALTIME
     c                   eval      file = 'goaltime'
     c                   eval      field = 'gtrtid'
     c                   exsr      chkrtef

     *   LABELDGT
     c                   eval      file = 'labeldgt'
     c                   eval      field = 'ldgrid'
     c                   exsr      chkrtef

     *   LDRDCOM
     c                   eval      file = 'ldrdcom'
     c                   eval      field = 'lcdrti'
     c                   exsr      chkrtef

     *   LDRDETL
     c                   eval      file = 'ldrdetl'
     c                   eval      field = 'ldrtid'
     c                   exsr      chkrtef

     *   LDRDTLBK
     c                   eval      file = 'ldrdtlbk'
     c                   eval      field = 'ldbrti'
     c                   exsr      chkrtef

     *   LDREXCP
     c                   eval      file = 'ldrexcp'
     c                   eval      field = 'lertid'
     c                   exsr      chkrtef

     *   LDRFILE
     c                   eval      file = 'ldrfile'
650bDc**                 eval      field = 'ldfret'
650bMc                   eval      field = 'ldfstd'
     c                   exsr      chkrtef

     *   LDRHCOM
     c                   eval      file = 'ldrhcom'
     c                   eval      field = 'lchrti'
     c                   exsr      chkrtef

     *   LDRHDETL
     c                   eval      file = 'ldrhdetl'
     c                   eval      field = 'ldhrti'
     c                   exsr      chkrtef

     *   LDRHDR
     c                   eval      file = 'ldrhdr'
     c                   eval      field = 'lhrtid'
     c                   exsr      chkrtef

     *   LDRHHDR
     c                   eval      file = 'ldrhhdr'
     c                   eval      field = 'lhhrti'
     c                   exsr      chkrtef

     *   LDROVRFL
     c                   eval      file = 'ldrovrfl'
     c                   eval      field = 'lortid'
     c                   exsr      chkrtef

     *   LDRPLTQ
     c                   eval      file = 'ldrpltq'
     c                   eval      field = 'lprtid'
     c                   exsr      chkrtef

     *   LDRTEQ
     c                   eval      file = 'ldrteq'
     c                   eval      field = 'ltrtid'
     c                   exsr      chkrtef

     *   LDR25
     c                   eval      file = 'ldr25'
     c                   eval      field = 'ltrtid'
     c                   exsr      chkrtef

     *   LOADTRN
     c                   eval      file = 'loadtrn'
     c                   eval      field = 'lortid'
     c                   exsr      chkrtef

     *   LUPDLOG
     c                   eval      file = 'lupdlog'
     c                   eval      field = 'lurtei'
     c                   exsr      chkrtef

     *   ORDH
     c                   eval      file = 'ordh'
     c                   eval      field = 'ohrte'
     c                   exsr      chkrtef

     *   ORDBSUM
     c                   eval      file = 'ordbsum'
     c                   eval      field = 'bprte'
     c                   exsr      chkrtef

     *   ORDRTE
     c                   eval      file = 'ordrte'
     c                   eval      field = 'orrte'
     c                   exsr      chkrtef

     *   PLTMISC
     c                   eval      file = 'pltmisc'
     c                   eval      field = 'pmrtid'
     c                   exsr      chkrtef

     *   PLTSTP
     c                   eval      file = 'pltstp'
     c                   eval      field = 'pssrid'
     c                   exsr      chkrtef

     *   PLTSUM
     c                   eval      file = 'pltsum'
     c                   eval      field = 'psrtid'
     c                   exsr      chkrtef

     *   RTECOMM
     c                   eval      file = 'rtecomm'
     c                   eval      field = 'lchrti'
     c                   exsr      chkrtef

     *   RTECOMTY
     c                   eval      file = 'rtecomty'
     c                   eval      field = 'lchrti'
     c                   exsr      chkrtef

     *   RTECSUM
     c                   eval      file = 'rtecsum'
     c                   eval      field = 'rcrtid'
     c                   exsr      chkrtef

     *   RTEFLGD
     c                   eval      file = 'rteflgd'
     c                   eval      field = 'rtrtid'
     c                   exsr      chkrtef

     *   RTEHSUMM
     c                   eval      file = 'rtehsumm'
     c                   eval      field = 'lhhrti'
     c                   exsr      chkrtef

     *   RTENOTE
     c                   eval      file = 'rtenote'
     c                   eval      field = 'rnrtid'
     c                   exsr      chkrtef

     *   RTEOPT
     c                   eval      file = 'rteopt'
     c                   eval      field = 'rtrte'
     c                   exsr      chkrtef

     *   RTEOPTD
     c                   eval      file = 'rteoptd'
     c                   eval      field = 'rtdrte'
     c                   exsr      chkrtef

     *   RTESTP
     c                   eval      file = 'rtestp'
     c                   eval      field = 'rtsrid'
     c                   exsr      chkrtef

     *   RTESUM
     c                   eval      file = 'rtesum'
     c                   eval      field = 'rsrtid'
     c                   exsr      chkrtef

     *   RTESUMM
     c                   eval      file = 'rtesumm'
     c                   eval      field = 'lhrtid'
     c                   exsr      chkrtef

     *   RTES3F
     c                   eval      file = 'rtes3f'
     c                   eval      field = 'lhhrte'
     c                   exsr      chkrtef

     *   RTETRCK
     c                   eval      file = 'rtetrck'
     c                   eval      field = 'rttrid'
     c                   exsr      chkrtef

     *   RTETTL
     c                   eval      file = 'rtettl'
     c                   eval      field = 'rlrtid'
     c                   exsr      chkrtef

     *   SAVHDR
     c                   eval      file = 'savhdr'
     c                   eval      field = 'ldrtid'
     c                   exsr      chkrtef

     *   TAXRDATA
     c                   eval      file = 'taxrdata'
     c                   eval      field = 'txrtid'
     c                   exsr      chkrtef

     *   TAXRSTMP
     c                   eval      file = 'taxrstmp'
     c                   eval      field = 'tsrtid'
     c                   exsr      chkrtef

     *   TOTEH
     c                   eval      file = 'toteh'
     c                   eval      field = 'tohrid'
     c                   exsr      chkrtef

     *   TOTEHDR
     c                   eval      file = 'totehdr'
     c                   eval      field = 'tohrid'
     c                   exsr      chkrtef

     *   TRKASIGN
     c                   eval      file = 'trkasign'
     c                   eval      field = 'tartid'
     c                   exsr      chkrtef


     *  Get by order

     *   ORDAD
     c                   eval      file = 'ordad'
     c                   eval      field = 'ordord'
     c                   exsr      chkordf

     *   ORDBOX
     c                   eval      file = 'ordbox'
     c                   eval      field = 'obord'
     c                   exsr      chkordf

     *   ORDC
     c                   eval      file = 'ordc'
     c                   eval      field = 'ocord'
     c                   exsr      chkordf

     *   ORDD
     c                   eval      file = 'ordd'
     c                   eval      field = 'odord'
     c                   exsr      chkordf

     *   ORDDL
     c                   eval      file = 'orddl'
     c                   eval      field = 'odlord'
     c                   exsr      chkordf

     *   ORDDM
     c                   eval      file = 'orddm'
     c                   eval      field = 'omord'
     c                   exsr      chkordf

     *   ORDDS
     c                   eval      file = 'ordds'
     c                   eval      field = 'osord'
     c                   exsr      chkordf

     *   ORDEXPDTE
     c                   eval      file = 'ordexpdte'
     c                   eval      field = 'oeord'
     c                   exsr      chkordf

     *   ORDHM
     c                   eval      file = 'ordhm'
     c                   eval      field = 'hmord'
     c                   exsr      chkordf

     *   ORDL
     c                   eval      file = 'ordl'
     c                   eval      field = 'olord'
     c                   exsr      chkordf

     *   ORDLBL
     c                   eval      file = 'ordlbl'
     c                   eval      field = 'alord'
     c                   exsr      chkordf

     *   ORDP
     c                   eval      file = 'ordp'
     c                   eval      field = 'orpord'
     c                   exsr      chkordf

     *   ORDSKIPCW
     c                   eval      file = 'ordskipcw'
     c                   eval      field = 'oscord'
     c                   exsr      chkordf

     *   ORDSLCT
     c                   eval      file = 'ordslct'
     c                   eval      field = 'osord'
     c                   exsr      chkordf

     *   ORDT
     c                   eval      file = 'ordt'
     c                   eval      field = 'otord'
     c                   exsr      chkordf

     *   PODLOG
     c                   eval      file = 'podlog'
     c                   eval      field = 'podord'
     c                   exsr      chkordf

     *   PODLOGP
     c                   eval      file = 'podlogp'
     c                   eval      field = 'pdpord'
     c                   exsr      chkordf
     *  Get by transaction

     *   FLGDELF
     c                   eval      file = 'flgdelf'
     c                   eval      field = 'flgtrn'
     c                   exsr      chktrnf

     *   LABELNK
     c                   eval      file = 'labelnk'
     c                   eval      field = 'lltrn#'
     c                   exsr      chktrnf

     *   LABELPS
     c                   eval      file = 'labelps'
     c                   eval      field = 'lstrn#'
     c                   exsr      chktrnf

     *   LICENSE
     c                   eval      file = 'license'
     c                   eval      field = 'litrn#'
     c                   exsr      chktrnf

     *   LICHIST
     c                   eval      file = 'lichist'
     c                   eval      field = 'lrtrn#'
     c                   exsr      chktrnf

     *   MULTRAN
     c                   eval      file = 'multran'
     c                   eval      field = 'mutrn#'
     c                   exsr      chktrnf

     *   ORDLT
     c                   eval      file = 'ordlt'
     c                   eval      field = 'ottrn#'
     c                   exsr      chktrnf

     *   PASSTRAN
     c                   eval      file = 'passtran'
     c                   eval      field = 'pastrn#'
     c                   exsr      chktrnf

     *   POMFR
     c                   eval      file = 'pomfr'
     c                   eval      field = 'pmtrn#'
     c                   exsr      chktrnf

     *   RUNCPY
     c                   eval      file = 'runcpy'
     c                   eval      field = 'ruotrn'
     c                   exsr      chktrnf

     *   RUNCPY2
     c                   eval      file = 'runcpy2'
     c                   eval      field = 'ruotrn'
     c                   exsr      chktrnf

     *   RUNNER
     c                   eval      file = 'runner'
     c                   eval      field = 'ruotrn'
     c                   exsr      chktrnf

     *   SLTDGTEX
     c                   eval      file = 'sltdgtex'
     c                   eval      field = 'sdetrn'
     c                   exsr      chktrnf
     *

     c                   eval      *inlr = *on

     *----------------------------------------------------------------
     *  Subroutine
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Chkdtef    Check command for files by date range.
     *----------------------------------------------------------------

     C     ChkDtef       begsr
     c                   select
     c                   when      $pcmd = '*CLEAR'
     c                   exsr      clear

     c                   when      $pcmd = '*GETALL'
     c                   exsr      getByDate

     c                   endsl

     C                   endsr
     *----------------------------------------------------------------
     *  Chkdtsf    Check command for files by date range datestamp
     *----------------------------------------------------------------

     C     ChkDtsf       begsr
     c                   select
     c                   when      $pcmd = '*CLEAR'
     c                   exsr      clear

     c                   when      $pcmd = '*GETALL'
     c                   exsr      getByDts

     c                   endsl

     C                   endsr
     *----------------------------------------------------------------
     *  Chkordf    Check command for files by order
     *----------------------------------------------------------------

     C     ChkOrdf       begsr
     c                   select
     c                   when      $pcmd = '*CLEAR'
     c                   exsr      clear

     c                   when      $pcmd = '*GETALL'
     c                   exsr      getByOrder

     c                   endsl

     C                   endsr
     *----------------------------------------------------------------
     *  Chkrtef    Check command for files by route
     *----------------------------------------------------------------

     C     ChkRtef       begsr
     c                   select
     c                   when      $pcmd = '*CLEAR'
     c                   exsr      clear

     c                   when      $pcmd = '*GETALL'
     c                   exsr      getByRtId

     c                   endsl

     C                   endsr
     *----------------------------------------------------------------
     *  Chktblf    Check command for Table files.
     *----------------------------------------------------------------

     C     ChkTblf       begsr
     c                   select
     c                   when      $pcmd = '*CLEAR'
     c                   exsr      clear

     c                   when      $pcmd = '*GETALL'
     c                             or $pcmd = '*GETTABLE'
     c                   exsr      getAll

     c                   endsl

     C                   endsr
     *----------------------------------------------------------------
     *  Chktrnf    Check command for files by transaction
     *----------------------------------------------------------------

     C     ChkTrnf       begsr
     c                   select
     c                   when      $pcmd = '*CLEAR'
     c                   exsr      clear

     c                   when      $pcmd = '*GETALL'
     c                   exsr      getByTran

     c                   endsl

     C                   endsr
     *----------------------------------------------------------------
     *  Clear   Clear file
     *----------------------------------------------------------------

     C     Clear         begsr

     C                   eval      sqlstmt = 'delete from '
     C                                     + %trim(newlib)
     C                                     + '/'
     C                                     + %trim(file)
     C/EXEC SQL
     C+   EXECUTE IMMEDIATE :sqlstmt
     C/END-EXEC
     C                   eval      sqlstt = sqlstt

     C                   endsr

     *----------------------------------------------------------------
     *  getAll   Get all records and put into BFCDEMO file
     *----------------------------------------------------------------

     C     getAll        begsr

     C                   eval      sqlstmt = 'insert into '
     C                                     + %trim(newlib)
     C                                     + '/'
     C                                     + %trim(file)
     C                                     + ' select * from '

     C                   if        $plib = '*LIBL'
     C                   eval      sqlstmt = %trim(sqlstmt)
     C                                     + ' '
     C                                     + %trim(file)
     C                   else
     C                   eval      sqlstmt = %trim(sqlstmt)
     C                                     + ' '
     C                                     + %trim($plib)
     C                                     + '/'
     C                                     + %trim(file)
     C                   endif

     C/EXEC SQL
     C+   EXECUTE IMMEDIATE :sqlstmt
     C/END-EXEC
     C                   eval      sqlstt = sqlstt

     C                   endsr

     *----------------------------------------------------------------
     *  getByDate   Get records by date range put into BFCDEMO file
     *----------------------------------------------------------------

     C     getByDate     begsr

     C                   eval      sqlstmt = 'insert into '
     C                                     + %trim(newlib)
     C                                     + '/'
     C                                     + %trim(file)
     C                                     + ' select * from '

     C                   if        $plib = '*LIBL'
     C                   eval      sqlstmt = %trim(sqlstmt)
     C                                     + ' '
     C                                     + %trim(file)
     C                   else
     C                   eval      sqlstmt = %trim(sqlstmt)
     C                                     + ' '
     C                                     + %trim($plib)
     C                                     + '/'
     C                                     + %trim(file)
     C                   endif

     C                   eval      sqlstmt = %trim(sqlstmt)
     C                                     + '  where '
     C                                     + %trim(field)
     c                                     + '>='
     c                                     + %trim($pfmdt)
     C                                     + ' and '
     C                                     + %trim(field)
     c                                     + '<='
     c                                     + %trim($ptodt)

     C/EXEC SQL
     C+   EXECUTE IMMEDIATE :sqlstmt
     C/END-EXEC
     C                   eval      sqlstt = sqlstt

     C                   endsr

     *----------------------------------------------------------------
     *  getByDts    Get records by date range datestamp put into
     *----------------------------------------------------------------

     C     getByDts      begsr

     C                   move      $Pfmdt        yyyymmdd
     C                   eval      fromTs = sq + yyyy + '-' + mm + '-'
     C                             + dd + '-' + '00.00.00' + sq
     C                   move      $Ptodt        yyyymmdd
     C                   eval      toTs = sq + yyyy + '-' + mm + '-'
     C                             + dd + '-' + '23.59.59' + sq

     C                   eval      sqlstmt = 'insert into '
     C                                     + %trim(newlib)
     C                                     + '/'
     C                                     + %trim(file)
     C                                     + ' select * from '

     C                   if        $plib = '*LIBL'
     C                   eval      sqlstmt = %trim(sqlstmt)
     C                                     + ' '
     C                                     + %trim(file)
     C                   else
     C                   eval      sqlstmt = %trim(sqlstmt)
     C                                     + ' '
     C                                     + %trim($plib)
     C                                     + '/'
     C                                     + %trim(file)
     C                   endif

     C                   eval      sqlstmt = %trim(sqlstmt)
     C                                     + '  where '
     C                                     + %trim(field)
     c                                     + '>='
     c                                     + %trim(fromTS)
     C                                     + ' and '
     C                                     + %trim(field)
     c                                     + '<='
     c                                     + %trim(toTS)

     C/EXEC SQL
     C+   EXECUTE IMMEDIATE :sqlstmt
     C/END-EXEC
     C                   eval      sqlstt = sqlstt

     C                   endsr

     *----------------------------------------------------------------
     *  getByOrder  Get records by order# and put into BFCDEMO file
     *----------------------------------------------------------------

     C     getByOrder    begsr

     C                   eval      sqlstmt = 'insert into '
     C                                     + %trim(newlib)
     C                                     + '/'
     C                                     + %trim(file)
     C                                     + ' select * from '

     C                   if        $plib = '*LIBL'
     C                   eval      sqlstmt = %trim(sqlstmt)
     C                                     + ' '
     C                                     + %trim(file)
     C                   else
     C                   eval      sqlstmt = %trim(sqlstmt)
     C                                     + ' '
     C                                     + %trim($plib)
     C                                     + '/'
     C                                     + %trim(file)
     C                   endif

     C                   eval      sqlstmt = %trim(sqlstmt)
     C                                     + '  where '
     C                                     + %trim(field)
     c                                     + ' in (select ohord from '
     c                                     + %trim(newlib)
     c                                     + '/ordh)'

     C/EXEC SQL
     C+   EXECUTE IMMEDIATE :sqlstmt
     C/END-EXEC
     C                   eval      sqlstt = sqlstt

     C                   endsr

     *----------------------------------------------------------------
     *  getByRtid   Get records by route id and put into BFCDEMO file
     *----------------------------------------------------------------

     C     getByRtid     begsr

     C                   eval      sqlstmt = 'insert into '
     C                                     + %trim(newlib)
     C                                     + '/'
     C                                     + %trim(file)
     C                                     + ' select * from '

     C                   if        $plib = '*LIBL'
     C                   eval      sqlstmt = %trim(sqlstmt)
     C                                     + ' '
     C                                     + %trim(file)
     C                   else
     C                   eval      sqlstmt = %trim(sqlstmt)
     C                                     + ' '
     C                                     + %trim($plib)
     C                                     + '/'
     C                                     + %trim(file)
     C                   endif

     C                   eval      sqlstmt = %trim(sqlstmt)
     C                                     + '  where '
     C                                     + %trim(field)
     c                                     + ' in (select rhrtid from '
     c                                     + %trim(newlib)
     c                                     + '/rtehed)'

     C/EXEC SQL
     C+   EXECUTE IMMEDIATE :sqlstmt
     C/END-EXEC
     C                   eval      sqlstt = sqlstt

     C                   endsr

     *----------------------------------------------------------------
     *  getByTran   Get records by transaction and put into BFCNEW
     *----------------------------------------------------------------

     C     getByTran     begsr

     C                   eval      sqlstmt = 'insert into '
     C                                     + %trim(newlib)
     C                                     + '/'
     C                                     + %trim(file)
     C                                     + ' select * from '

     C                   if        $plib = '*LIBL'
     C                   eval      sqlstmt = %trim(sqlstmt)
     C                                     + ' '
     C                                     + %trim(file)
     C                   else
     C                   eval      sqlstmt = %trim(sqlstmt)
     C                                     + ' '
     C                                     + %trim($plib)
     C                                     + '/'
     C                                     + %trim(file)
     C                   endif

     C                   eval      sqlstmt = %trim(sqlstmt)
     C                                     + '  where '
     C                                     + %trim(field)
     c                                     + ' in (select pttrn# from '
     c                                     + %trim(newlib)
     c                                     + '/pirtran)'

     C/EXEC SQL
     C+   EXECUTE IMMEDIATE :sqlstmt
     C/END-EXEC
     C                   eval      sqlstt = sqlstt

     C                   endsr


