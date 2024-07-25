      /copy qcopysrc,hspecs
501jAH dftactgrp(*NO)
501jAH actgrp(*NEW)

     *----------------------------------------------------------------
     *
     *  GETJDLIBL   Get library list based for job description
     *  29 April 2009
     *  Dave Sommerville
     *
     *  Revisions
     *   04/29/09  DAS  5.20
     *     - Created
720aA*   01/09/19  DAS  7.20a
     *     - Replaced BNDDIR PIRSQLPGM with BFCBND.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

720aDH*bnddir('PIRSQLPGM')
720aMH bnddir('BFCBND')

510aA*----------------------------------------------------------------
510aA* File Specs
510aA*----------------------------------------------------------------
510aA
510aAFworklbl   if   e           k disk    usropn
     F                                     infds(file1ds)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcjobd
      /copy qcopysrc,p.bfclibl

     *----------------------------------------------------------------
     * Input parameters
     *----------------------------------------------------------------

510aAD $pcmd           S              8
     D $pjd            S             10
     D $preturn        S             10
     D $pmessage       S            275

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
     D  f1filename2           83     92
     D  f1lib                 93    102

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     * API Error Data Structure
     *----------------------------------------------------------------

     D APIErrorDS      DS
     D  BytesProvided                10I 0 Inz( %Size( APIErrorDS ) )
     D  BytesAvail                   10I 0 Inz( *Zero )
     D  MsgID                         7    Inz( *Blanks )
     D  Reserved                      1    Inz( X'00' )
     D  MsgDta                      256    Inz( *Blanks )

     D NoAPIError      C                   Const( *Zero )

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D  error          s               n
     D  i              s              3  0
     D  jobdName       s             10
     D  jobdLib        s             10
     D  llCount        s              5I 0
     D  rtnFlag        s               n
     D  jobdLiblAry    s             11    DIM(250)

     *----------------------------------------------------------------
     * Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * User Information API Fields
     *----------------------------------------------------------------

     *   User Information data structure format USRI0300

     DQSYI0300         DS                  Based(ReceivePtr)
     D*                                             Qsy USRI0300
     D QSYBRTN02               1      4B 0
     D*                                             Bytes Returned
     D QSYBAVL02               5      8B 0
     D*                                             Bytes Available
     D QSYUP03                 9     18
     D*                                             User Profile
     D QSYPS00                19     31
     D*                                             Previous Signon
     D QSYRSV103              32     32
     D*                                             Reserved 1
     D QSYSN00                33     36B 0
     D*                                             Signon Notval
     D QSYUS02                37     46
     D*                                             User Status
     D QSYPD02                47     54
     D*                                             Pwdchg Date
     D QSYNP00                55     55
     D*                                             No Password
     D QSYRSV203              56     56
     D*                                             Reserved 2
     D QSYPI01                57     60B 0
     D*                                             Pwdexp Interval
     D QSYPD03                61     68
     D*                                             Pwdexp Date
     D QSYPD04                69     72B 0
     D*                                             Pwdexp Days
     D QSYPE00                73     73
     D*                                             Password Expired
     D QSYUC00                74     83
     D*                                             User Class
     D  QSYAOBJ01             84     84
     D*                                             All Object
     D  QSYSA05               85     85
     D*                                             Security Admin
     D  QSYJC01               86     86
     D*                                             Job Control
     D  QSYSC01               87     87
     D*                                             Spool Control
     D  QSYSS02               88     88
     D*                                             Save System
     D  QSYRVICE01            89     89
     D*                                             Service
     D  QSYAUDIT01            90     90
     D*                                             Audit
     D  QSYISC01              91     91
     D*                                             Io Sys Cfg
     D  QSYERVED10            92     98
     D*                                             Reserved
     D QSYGP02                99    108
     D*                                             Group Profile
     D QSYOWNER01            109    118
     D*                                             Owner
     D QSYGA00               119    128
     D*                                             Group Auth
     D QSYAL04               129    138
     D*                                             Assistance Level
     D QSYCLIB               139    148
     D*                                             Current Library
     D  QSYNAME14            149    158
     D*                                             Name
     D  QSYBRARY14           159    168
     D*                                             Library
     D  QSYNAME15            169    178
     D*                                             Name
     D  QSYBRARY15           179    188
     D*                                             Library
     D QSYLC00               189    198
     D*                                             Limit Capabilities
     D QSYTD                 199    248
     D*                                             Text Description
     D QSYDS00               249    258
     D*                                             Display Signon
     D QSYLDS                259    268
     D*                                             Limit DeviceSsn
     D QSYKB                 269    278
     D*                                             Keyboard Buffering
     D QSYRSV300             279    280
     D*                                             Reserved 3
     D QSYMS                 281    284B 0
     D*                                             Max Storage
     D QSYSU                 285    288B 0
     D*                                             Storage Used
     D QSYSP                 289    289
     D*                                             Scheduling Priority
     D  QSYNAME16            290    299
     D  qjobdname            290    299
     D*                                             Name
     D  QSYBRARY16           300    309
     D  qjobdlib             300    309
     D*                                             Library
     D QSYAC                 310    324
     D*                                             Accounting Code
     D  QSYNAME17            325    334
     D*                                             Name
     D  QSYBRARY17           335    344
     D*                                             Library
     D QSYMD                 345    354
     D*                                             Msgq Delivery
     D QSYRSV4               355    356
     D*                                             Reserved 4
     D QSYMS00               357    360B 0
     D*                                             Msgq Severity
     D  QSYNAME18            361    370
     D*                                             Name
     D  QSYBRARY18           371    380
     D*                                             Library
     D QSYPD05               381    390
     D*                                             Print Device
     D QSYSE                 391    400
     D*                                             Special Environment
     D  QSYNAME19            401    410
     D*                                             Name
     D  QSYBRARY19           411    420
     D*                                             Library
     D QSYLI                 421    430
     D*                                             Language Id
     D QSYCI                 431    440
     D*                                             Country Id
     D QSYCCSID00            441    444B 0
     D*                                             CCSID
     D  QSYSK00              445    445
     D*                                             Show Keywords
     D  QSYSD00              446    446
     D*                                             Show Details
     D  QSYFH00              447    447
     D*                                             Fullscreen Help
     D  QSYSS03              448    448
     D*                                             Show Status
     D  QSYNS00              449    449
     D*                                             Noshow Status
     D  QSYRK00              450    450
     D*                                             Roll Key
     D  QSYPM00              451    451
     D*                                             Print Message
     D  QSYERVED11           452    480
     D*                                             Reserved
     D  QSYNAME20            481    490
     D*                                             Name
     D  QSYBRARY20           491    500
     D*                                             Library
     D QSYOBJA18             501    510
     D*                                             Object Audit
     D  QSYCMDS00            511    511
     D*                                             Command Strings
     D  QSYREATE00           512    512
     D*                                             Create
     D  QSYELETE00           513    513
     D*                                             Delete
     D  QSYJD01              514    514
     D*                                             Job Data
     D  QSYOBJM07            515    515
     D*                                             Object Mgt
     D  QSYOS00              516    516
     D*                                             Office Services
     D  QSYPGMA00            517    517
     D*                                             Program Adopt
     D  QSYSR00              518    518
     D*                                             Save Restore
     D  QSYURITY00           519    519
     D*                                             Security
     D  QSYST00              520    520
     D*                                             Service Tools
     D  QSYSFILD00           521    521
     D*                                             Spool File Data
     D  QSYSM00              522    522
     D*                                             System Management
     D  QSYTICAL00           523    523
     D*                                             Optical
     D  QSYERVED12           524    574
     D*                                             Reserved
     D QSYGAT00              575    584
     D*                                             Group Auth Type
     D QSYSGO00              585    588B 0
     D*                                             Supp Group Offset
     D QSYSGNBR02            589    592B 0
     D*                                             Supp Group Number
     D QSYUID                593    596B 0
     D*                                             UID
     D QSYGID                597    600B 0
     D*                                             GID
     D QSYHDO                601    604B 0
     D*                                             HomeDir Offset
     D QSYHDL                605    608B 0
     D*                                             HomeDir Len
     D QSYLJA                609    624
     D*                                             Locale Job Attributes
     D QSYLO                 625    628B 0
     D*                                             Locale Offset
     D QSYLL                 629    632B 0
     D*                                             Locale Len
     D QSYGMI03              633    633
     D*                                             Group Members Indicator
     D QSYDCI                634    634
     D*                                             Digital Certificate Indicato
     D QSYCC                 635    644
     D*                                             Chrid Control
     D*QSYSGN02              645    654    DIM(00001)
     D*
     D*                                  Varying length
     D*QSYPI02               655    655
     D*
     D*                             Varying length
     D*QSYLI00               656    656
     D*
     D*                               Varying length

     D Receiver1       DS
     D  BytesRtn1                    10i 0
     D  BytesAvl1                    10i 0

     DQUSEC            DS           116    inz
     D QUSBPRV                 1      4B 0 inz(116)
     D QUSBAVL                 5      8B 0 inz(0)
     D QUSEI                   9     15
     D QUSERVED               16     16
     D QUSED01                17    116

     D FormatName      S              8    inz('USRI0300')
     D ReceiveLen      S             10i 0
     D SgDsp           s             10
     D OI              S              4  0

     * End of User Information Fields


     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
510aA*      $pcmd    *ALL     - Entire library list space delimited
510aA*               *ALLCSV  - Entire library list comma delimited
510aA*               *FILE    - File library only.
     *      $pjd     Job Description
     *
     *    Returned Parameters
     *      $preturn    *OK
     *                  *ERROR
     *      $pmessage   Message for *ERROR
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     c     *entry        Plist
510aAc                   Parm                    $pcmd
     c                   Parm                    $pjd
     c                   Parm                    $preturn
     c                   Parm                    $pmessage

     c                   eval      $preturn = '*OK'
     c                   eval      $pmessage = ' '

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     *  Translate input into upper case.

     C     xlower:xupper xlate(p)  $pcmd         $pcmd
     C     xlower:xupper xlate(p)  $pjd          $pjd

     *  Get job descripiton initial library list

     c                   eval      jobdName = $pjd
     c                   eval      jobdLib = 'QGPL'

     C                   Reset                   APIErrorDS
     C                   Eval      jobdLiblAry = RtvJobDInlLibL(
     C                                                          jobdName   :
     C                                                          jobdLib    :
     C                                                          APIErrorDS
     C                                                         )

     C                   If        BytesAvail <> NoAPIError
     C                   eval      $preturn = '*ERROR'
     C                   eval      $pmessage = 'Error getting job '
     C                                       + 'description library '
     C                                       + 'list: '
     C                                       + msgid
     C                   return
     C                   EndIf

     *  Return requested library(s) - Default to just file library.

     C                   select
     C                   when      $pcmd = '*ALL'
     C                   exsr      returnLibl
     C                   when      $pcmd = '*ALLCSV'
     C                   exsr      returnLiblCSV
     C                   other
     C                   exsr      returnFile
     C                   endsl

     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  returnFile   Return file library only
     *----------------------------------------------------------------

     C     returnFile    begsr

     *  Set library list to job description initial library list.

     C                   Eval      rtnFlag = SetLibL(
     C                                               jobdLiblAry :
     C                                               llUsrLibl
     C                                               )

     *  Open file to get its library.

     C                   open(e)   worklbl
     C                   if        %error
     C                   eval      $preturn = '*ERROR'
     C                   eval      $pmessage = 'Error opening file: '
     C                                       + f1messageid
     C                   goto      endrtnfile
     C                   endif

     *  Return library name.

     C                   eval      $pmessage = f1lib

     C     endrtnfile    endsr

     *----------------------------------------------------------------
     *  returnLibl  Return entire library list space delimited
     *----------------------------------------------------------------

     C     returnLibl    begsr

     C                   eval      $pmessage = ' '
     C     1             do        25            i

     C                   if        jobdLiblAry(i) = ' '
     C                   leave
     C                   endif

     C                   select
     C                   when      i = 1
     C                   eval      $pmessage = jobdLiblAry(i)
     C                   other
     C                   eval      $pmessage = %trimr($pmessage)
     C                                       + ' ' + jobdLiblAry(i)
     C                   endsl

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  returnLiblcsv  Return entire library list comma delimited
     *----------------------------------------------------------------

     C     returnLiblCSV begsr

     C                   eval      $pmessage = ' '
     C     1             do        25            i

     C                   if        jobdLiblAry(i) = ' '
     C                   leave
     C                   endif

     C                   select
     C                   when      i = 1
     C                   eval      $pmessage = jobdLiblAry(i)
     C                   other
     C                   eval      $pmessage = %trimr($pmessage)
     C                                       + ',' + jobdLiblAry(i)
     C                   endsl

     C                   enddo

     C                   endsr
