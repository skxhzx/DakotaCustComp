      /copy qcopysrc,hspecs
501jAH dftactgrp(*NO)
501jAH actgrp(*NEW)
501jAH bnddir('QC2LE')
     *----------------------------------------------------------------
     * Compile
     *
     *   CRTBNDRPG PGM(EMAILPING) DFTACTGRP(*NO) ACTGRP(*NEW)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  EMAILPING   Ping email accounts
     *  14 March 2007
     *  Dave Sommerville
     *
     *  Revisions
     *
510 A*    03/14/07  DAS  5.10
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Factivity  if   e           k disk
     F                                     infds(file1ds)

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
     *  Constants
     *----------------------------------------------------------------

     D cr              c                   Const(x'0D')
     D crlf            c                   Const(x'0D25')
     D lf              c                   Const(x'25')
     D begsend         s               t   inz(t'06.00.00')
     D endsend         s               t   inz(t'17.00.00')
     D noon            s               t   inz(t'12.00.00')
     D sq              c                   Const('''')
     D file            c                   const('slots.csv')

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D cmd             s            512
     D cmdlen          s             15  5
     D forever         s               n
     D head            s            100
     D i               s              3  0
     D message         s            200
     D seconds         s             10U 0
     D sqlstmt         s            500
     D subject         s             44

     *----------------------------------------------------------------
     *  Date/time variables
     *----------------------------------------------------------------

     D currtimestamp   s               z
     D datestamp       s               d
     D dateusa8        s             26
     D timedsp10       s             30
     D timestamp       s               t

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D QCmdExc         PR                  ExtPgm('QCMDEXC')
     D   command                    512A   const
     D   len                         15P 5 const

     D sleep           PR            10U 0 extproc('sleep')
     D   seconds                     10U 0 value

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pemail   Email address.
     *      $pwhdp    Warehouse dept.
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pemail          32
     C                   parm                    $pwhdp            5

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     *  Translate department into upper case.

     C     xlower:xupper xlate(p)  $pwhdp        $pwhdp

     *      Get and format date/time

     C                   time                    currtimestamp
     C                   move      currtimestamp datestamp
     C                   move      currtimestamp timestamp

     C     *MDY          movel     datestamp     dateusa8

     C                   if        timestamp < noon
     C                   eval      timedsp10 = %char(timestamp)+'am'
     C                   else
     C     timestamp     subdur    12:*H         timestamp
     C                   eval      timedsp10 = %char(timestamp)+'pm'
     C                   endif

     *  Create heading.

     C                   eval      head = %trim($pwhdp)
     C                                  + ' Slots From Library '
     C                                  + %trim(f1lib)
     C                                  + ' - '
     C                                  + %trim(dateusa8)
     C                                  + ' '
     C                                  + %trim(timedsp10)

     *  Create SQL statment

     C                   eval      sqlstmt = 'select * from slot '
     C                   if        $pwhdp <> '*ALL'
     C                   eval      sqlstmt = %trim(sqlstmt)
     C                                     + ' where slwhdp=' + sq + sq
     C                                     +    %trim($pwhdp) + sq + sq
     C                   endif
     C                   eval      sqlstmt = %trim(sqlstmt)
     C                                     + ' order by slwhse,slwhdp,sldisp'

     *  Call program to create IFS file.

     C                   eval      cmd = 'SQL2CSV '
     C                                 + 'SQLSTMT(' + sq
     C                                 +   %trim(sqlstmt) + sq + ') '
     C                                 + 'TOCSV(' + sq
     C                                 +   '/QDLS/TEMP/'
     C                                 +   %trim(file)
     C                                 +   sq + ') '
     C                                 + 'COLHDRS(*FLDNAM) '
     C                                 + 'TITLE(' + sq
     C                                 +   %trim(head)
     C                                 +   sq + ') '

     C                   eval      cmdlen = %len(%trim(cmd))
     C                   callp     QcmdExc(%trim(cmd) : cmdlen)

     *      Create subject line

     C                   eval      subject = head

     *      Create body text

     C                   eval      message = 'This email was sent from '
     C                                     + 'the BFC iSeries system at '
     C                                     + %trim(dateusa8)
     C                                     + ' '
     C                                     + %trim(timedsp10) + '.'
     C                                     + crlf + crlf
     C                   eval      cmdlen = %len(%trim(message))

     *      Create command to send email

     C                   eval      cmd = 'SNDDST'
     C                                 + ' '
     C                                 + 'TYPE(*DOC)'
     C                                 + ' '
     C                                 + 'TOINTNET(('
     C                                 + %trim($pemail)
     C                                 + '))'
     C                                 + ' '
     C                                 + 'DSTD('
     C                                 + sq + %trim(subject) + sq
     C                                 + ')'
     C                                 + ' '
     C                                 + 'MSG('
     C                                 + sq + %trim(message) + sq
     C                                 + ')'
     C                                 + ' '
     C                                 + 'DOC('
     C                                 + sq + %trim(file) + sq
     C                                 + ')'
     C                                 + ' '
     C                                 + 'FLR('
     C                                 + sq + 'temp' + sq
     C                                 + ')'

     *      Send email

     C                   eval      cmdlen = %len(%trim(cmd))
     C                   callp     QcmdExc(%trim(cmd) : cmdlen)

     *  Bye, Bye

     C                   eval      *inlr = *on
