      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CKRFTP    FTP CKRFTP file to Check Right
     *  24 June 2009
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    06/24/09  JCJ  5.20
     *      - Created. Copied from TAXRFTP
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: City Wholsale
     *
xxx A*    xx/xx/xx  xxx  xxx
     *      - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Foptions   if   e           k disk
     Fckrdata1  uf   e           k disk    usropn
     F                                     infds(filet1ds)
     Fckftplog4 uf a e           k disk    usropn
     Fckrexp    o    e           k disk    usropn
     F                                     infds(filet2ds)

     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------

     D client          s             10

     D/copy qcopysrc,id#citywho

     *----------------------------------------------------------------
     *  Check Right Detail record data structure
     *----------------------------------------------------------------

     D $ckrdetail      ds

     D  $ckrdrectype                  1    Inz('D')
     D  $ckrlinenum                   3s 0 Inz(0)
     D  $ckrupc                      12s 0
     D  $ckrdesc                     30
     D  $ckrcartqty                   4s 0

     *----------------------------------------------------------------
     *  *CKRFTP      -  Check Right FTP options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    CKFTP   -  Use FTP for exporting
     *    CKSRVR  -  FTP Server name
     *    CKUSER  -  FTP User id
     *    CKPWD   -  FTP Password
     *    CKPATH  -  Path for remote file
     *
     * Data structure
     *
     D tpdata          ds
     D  tp_ftp                 1      1
     D  tp_srvr                2     33
     D  tp_user               34     48
     D  tp_pwd                49     63
     D  tp_path               64     95
     D  tp_tend              117    117

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     D forever         s               n   inz('1')
     D Q               C                   Const('''')
     D errmsg01        c                   'Check Right FTP Options not set'
     D errmsg02        c                   'Host FTP Options not set'
     *
     D stsmsg01        c                   'Connect to Check Right server succe-
     D                                     ssful.     '
     D stsmsg02        c                   'Check Right data file sent successf-
     D                                     ully.        '

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $preturn        s             10
     D $pmessage       s             30

     D blankexpfile    s                   like(ckexpfile)
     D expfile         s                   like(ckexpdata)
     D expmbr          s             10

     D ftppwd          s             30
     D ftpremotedir    s             65
     D ftpremotefile   s             65
     D ftpremotefile2  s             65
     D ftpserver       s             30
     D ftpuser         s             30

     D error           s               n
     D count           s              5  0
     D currstamp       s               z
     D dftstamp        s               z
     D datestamp       s               d
     D timestamp       s               t
     D kytype          s                   like(pftype)
     D ovrdbf          s               n
     D $pcmd           s              8
     D $pwhse          s              3  0
     D $prtid          s              5
     D $prte           s              5
     D $ptrn#          s              7  0
     D $pmbr           s             10
     D $pfile          s             30
     D ckstampt        s             12
     D ckstamptN       s             12  0
     D pos             s              2  0
     D w2a             s              2
     D w2n             s              2  0
     *----------------------------------------------------------------
     *  Data conversion data structure
     *----------------------------------------------------------------

     D currdatestamp   s               z

     D dateconv        ds
     D  tsdatetime             1     26
     D  tsyear                 1      4
     D  tsmonth                6      7
     D  tsday                  9     10
     D  tshour                12     13
     D  tsmin                 15     16
     D  tssec                 18     19
     D  tssbsec               21     26
     D                 ds
     D  mbrky                  1      8
     D  mbrkey                 1      8  0
     D mbrretry        s              5  0

     D ptranchar       s              7
     *----------------------------------------------------------------
     *  Program information data structure.
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  File information data structures. CKRDATA1, CKREXP
     *----------------------------------------------------------------

      /Copy qcopysrc,c#filet1ds
      /Copy qcopysrc,c#filet2ds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pcmd      *SEND    - Send file(s) to Host systems
     *                            Called from CKR.
     *                 *RESEND  - Resend file to Host system
     *                            Called from CK110.
     *                 *SNDTRN  - Send file to Host system for a Trn#.
     *                            Called from CKR.
     *      $pwhse     warehouse
     *      $prtid     route id
     *      $prte      route
     *      $ptrn#     trans number
     *      $pmbr      member
     *      $pfile     file
     *
     *    Returned Parameters
     *      $preturn   Return code
     *      $pmessage  Return code
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------
     *
     C     *entry        plist
     C                   parm                    $pcmd
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    $prte
     C                   parm                    $ptrn#
     C                   parm                    $pmbr
     C                   parm                    $pfile
     C                   parm                    $preturn
     C                   parm                    $pmessage
     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
     C                   eval      error     = *off
     C                   eval      $preturn  = '*OK'
     C                   eval      $pmessage = ' '

     C                   if        tp_ftp = 'Y'

     *  Get current datestamp.

     C                   time                    currdatestamp
     C                   eval      tsdatetime = %char(currdatestamp)

     *  Create host file name to use.

     C                   exsr      crtfilenames
     C     error         cabeq     *on           bottom

     *  Load records into export file.

     C                   select
     C                   when         $pcmd = '*SEND   ' or
     C                                $pcmd = '*SNDTRN '
     C                   exsr      loadexpfile
     C     error         cabeq     *on           bottom
     *  Exit if no records written into Check Right export file.
     C     count         cabeq     0             bottom
     C                   endsl

     *  Close files.

     C                   exsr      closefiles

     *  FTP export file.

     C                   select
     C                   when         $pcmd = '*SEND   '
     C                             or $pcmd = '*RESEND'
     C                             or $pcmd = '*SNDTRN'
     C                   exsr      ftpexpfile
     C                   endsl

     c                   endif

     C     bottom        tag

     *  Close files before exit.

     C                   exsr      closefiles

     *  Log any errors, then loop around and wait for next request.

     C                   if        error
     C                   exsr      logerror
     C                   endif
     *
     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          Subroutines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * Get client id.

     C                   call      'GETCLIENT'
     C                   parm                    client
     *
     *  Define key for OPTIONS file.
     *
     C     opkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    opcode

     C     opkey2        klist
     C                   kfld                    opwhse
     C                   kfld                    opcode
     *
     *  Define partial key for CKRDATA1 file
     *
     C     keyckr        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    blankexpfile
     *
     *  Define full key for CKFTPLOG4 file
     *
     C     ckftpky       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prte
     C                   kfld                    $prtid
     C                   kfld                    $ptrn#
     C                   kfld                    kytype

     *  Retrieve Check Right FTP info from file.

     C                   eval      opwhse = $pwhse
     C                   eval      opcode = '*CKRFTP '
     C     opkey         chain     options
     C                   if        %found
     C                   eval      tpdata    = opdata
     C                   eval      ftpserver    = tp_srvr
     C                   eval      ftpremotedir = tp_path
     C                   eval      ftpuser      = tp_user
     C                   eval      ftppwd       = tp_pwd
     C
     C                   else
     C
     C                   eval      error       = *on
     C                   eval      $pmessage   = errmsg01
     C                   eval      tp_ftp = 'N'
     C                   clear                   ftpserver
     C                   clear                   ftpremotedir
     C                   clear                   ftpuser
     C                   clear                   ftppwd
     C
     C                   endif

     C                   eval      dftstamp = *loval
     *
     *  Open FTP Log file if required.
     *
     C                   if          ($pcmd  = '*SEND'
     C                             or $pcmd  = '*RESEND'
     C                             or $pcmd  = '*SNDTRN')
     C                             and (not %open(ckftplog4))
     C                   open      ckftplog4
     C                   Endif

     C                   endsr

     *----------------------------------------------------------------
     *  Getckrec      Get CK FTP Status record.
     *----------------------------------------------------------------

     C     getckrec      begsr
     *
     C     ckftpky       chain     ckftplog4
     C                   select
     C                   when      not %found(ckftplog4)
     C                   eval      pfwhse = $pwhse
     C                   eval      pfrtid = $prtid
     C                   eval      pfrte  = $prte
     C                   eval      pftype = kytype
     C                   eval      pftrn# = cktrn#
     C                   eval      pffsts = '1'
     C                   eval      pflusr = #user
     C                   time                    currstamp
     C                   eval      pfaddts= currstamp
     C                   endsl
     *
     C     endgetckrec   endsr

     *----------------------------------------------------------------
     *  Updrte        Update route being sent to FTP log file.
     *----------------------------------------------------------------

     C     updrte        begsr
     *
     C                   select
     C                   when      not %found(ckftplog4)
     C                   write     ckftpr
     *
     C                   when      %found(ckftplog4)
     C                   update    ckftpr
     C                   endsl
     *
     C     endupdrte     endsr

     *----------------------------------------------------------------
     *  closefiles    Close data and export files.
     *----------------------------------------------------------------

     C     closefiles    begsr
     C                   eval      error = *off

     * Close data file.

     C                   if        %open(ckrdata1)
     C                   close(e)  ckrdata1
     C                   if        %error
     C                   endif
     C                   endif

     * Close export file.

     C                   if        %open(ckrexp)
     C                   close(e)  ckrexp
     C                   if        %error
     C                   endif
     C                   endif

     * Delete export file override

     C                   if        ovrdbf
     C                   eval      qcmd = 'DLTOVR FILE(CKREXP)'
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
     C                   eval      ovrdbf = *off
     C                   endif

     C     endcloseexp   endsr

     *----------------------------------------------------------------
     *  crtfilenames    Create export file names to use.
     *----------------------------------------------------------------

     C     crtfilenames  begsr

     C                   eval      error = *off

     C                   select

     *  For *SEND or *SNDTRN, create file name.

     C                   when      $pcmd = '*SEND' or
     C                             $pcmd = '*SNDTRN'
     *
     c                   if        client = citywholesale
     *     File name will be created when first record of batch is read.
     C                   else
     *
     C                   eval      expfile    = 'CKR'
     C                                        + tsyear + tsmonth + tsday
     C                                        + tshour + tsmin + tssec
     C                                        + '.IMP'
     C                   endif

     *  For *RESEND, use the file name that was sent.

     C                   when      $pcmd = '*RESEND'
     C                   if        $pfile= ' '
     C                   eval      error = *on
     C                   eval      $preturn = '*ERROR'
     C                   eval      $pmessage = 'File name must be sent +
     C                                          for *RESEND'
     C                   goto      endcrtnames
     C                   endif
     *
     C                   eval      expfile = $pfile
     C                   eval      expmbr = $pmbr

     *  Trap invalid commands.

     C                   other
     C                   eval      error = *on
     C                   eval      $preturn = '*ERROR'
     C                   eval      $pmessage = 'Invalid command sent '
     C                                       + '(' + %trim($pcmd) + ')'
     C                   goto      endcrtnames

     C                   endsl

     C     endcrtnames   endsr

     *----------------------------------------------------------------
     *  ftpexpfile    FTP export file.
     *----------------------------------------------------------------

     C     ftpexpfile    begsr
     C                   eval      error = *off

     C                   if        $pcmd = '*RESEND'
     C                   open(e)   ckrexp
     C                   endif
     *
     *  Create remote file name strings.
     *    If Export to Check Right is Y=Yes.
     C                   if        error = *off
     C                             and tp_ftp = 'Y'

     C                   eval      ftpremotefile = %trim(ftpremotedir)
     C                                           + %trim(expfile)

     *  Open connection.

     C                   call      'BFCFTP'
     C                   parm      '*CONNECT'    $fcmd            10
     C                   parm      ftpserver     $fsrvr           65
     C                   parm      ftpuser       $fuser           30
     C                   parm      ftppwd        $fpwd            30
     C                   parm      ' '           $fbin             1
     C                   parm      ' '           $fnfmt            1
     C                   parm      ' '           $fpasv            1
     C                   parm      ' '           $factn            1
     C                   parm      ' '           $ftype            4
     C                   parm      ' '           $fflib           10
     C                   parm      ' '           $fffil           10
     C                   parm      ' '           $ffmbr           10
     C                   parm      ' '           $ffstr           65
     C                   parm      ' '           $ftlib           10
     C                   parm      ' '           $ftfil           10
     C                   parm      ' '           $ftmbr           10
     C                   parm      ' '           $ftstr           65
     C                   parm      ' '           $frtn            10
     C                   parm      ' '           $fmsg            60

     C                   eval      kytype = '03'
     C                   if        $pcmd = '*SEND'
     C                   eval      $ptrn# = cktrn#
     C                   endif
     C                   exsr      getckrec
     *
     C                   if        $frtn <> '*OK'
     C                   eval      $preturn = '*ERROR'
     C                   eval      $pmessage = $fmsg
     *
     C                   eval      pffsts = '3'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = $pmessage
     C                   exsr      updrte
     *
     C                   goto      endftp
     C                   Else
     *
     C                   eval      pffsts = '2'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = stsmsg01
     C                   exsr      updrte
     *
     C                   endif

     *  Send main export file

     C
     C                   call      'BFCFTP'
     C                   parm      '*ACTION'     $fcmd            10
     C                   parm      ' '           $fsrvr           65
     C                   parm      ' '           $fuser           30
     C                   parm      ' '           $fpwd            30
     C                   parm      'N'           $fbin             1
     C                   parm      '1'           $fnfmt            1
     C                   parm      'N'           $fpasv            1
     C                   parm      'P'           $factn            1
     C                   parm      'FILE'        $ftype            4
     C                   parm      ft2library    $fflib           10
     C                   parm      'CKREXP '     $fffil           10
     C                   parm      expmbr        $ffmbr           10
     C                   parm      ' '           $ffstr           65
     C                   parm      ' '           $ftlib           10
     C                   parm      ' '           $ftfil           10
     C                   parm      ' '           $ftmbr           10
     C                   parm      ftpremotefile $ftstr           65
     C                   parm      ' '           $frtn            10
     C                   parm      ' '           $fmsg            60

     C                   eval      kytype = '03'
     C                   exsr      getckrec
     *
     C                   if        $frtn <> '*OK'
     C                   eval      $preturn = '*ERROR'
     C                   eval      $pmessage = $fmsg
     *
     C                   eval      pffsts = '3'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = $pmessage
     C                   exsr      updrte
     *
     C                   goto      endftp
     C                   Else
     *
     C                   eval      pffsts = '4'
     C                   eval      pflusr = #user
     C                   eval      pfexpts = currstamp
     C                   eval      pffmsg = stsmsg02
     C                   exsr      updrte
     *
     C                   endif
     *
     *  Close connection.
     C                   call      'BFCFTP'
     C                   parm      '*QUIT'       $fcmd            10
     C                   parm      ' '           $fsrvr           65
     C                   parm      ' '           $fuser           30
     C                   parm      ' '           $fpwd            30
     C                   parm      ' '           $fbin             1
     C                   parm      ' '           $fnfmt            1
     C                   parm      ' '           $fpasv            1
     C                   parm      ' '           $factn            1
     C                   parm      ' '           $ftype            4
     C                   parm      ' '           $fflib           10
     C                   parm      ' '           $fffil           10
     C                   parm      ' '           $ffmbr           10
     C                   parm      ' '           $ffstr           65
     C                   parm      ' '           $ftlib           10
     C                   parm      ' '           $ftfil           10
     C                   parm      ' '           $ftmbr           10
     C                   parm      ' '           $ftstr           65
     C                   parm      ' '           $frtn            10
     C                   parm      ' '           $fmsg            60

     C                   if        $frtn <> '*OK'
     C                   eval      $preturn = '*ERROR'
     C                   eval      $pmessage = $fmsg
     C                   goto      endftp
     C                   endif

     C                   endif

     C     endftp        endsr

     *----------------------------------------------------------------
     *  loadexpfile   Load export file.
     *----------------------------------------------------------------

     C     loadexpfile   begsr
     C                   eval      error = *off

     *  Open data file.

     C                   exsr      openckrdata
     C     error         cabeq     *on           endload

     *  Loop through records to be exported.

     C                   eval      count = 0

     C     keyckr        setll     ckrdata1
     C                   dow       forever = forever

     C     keyckr        reade     ckrdata1
     C                   if        %eof
     C                   leave
     C                   endif

     c                   if        $pcmd  =  '*SNDTRN' and
     c                             $ptrn# <> cktrn#
     C                   iter
     C                   endif

     C                   eval      count = count + 1

     *    First time through, open file.

     C                   if        count = 1
     C                   exsr      openckrexp
     *
     *    Update FTP log with Host export file info.
     *
     C                   if        $pcmd = '*SEND'
     C                             and tp_ftp = 'Y' or
     C                             $pcmd = '*SNDTRN'
     C                             and tp_ftp = 'Y'
     *
     C                   select
     c                   when      client = citywholesale
     C                   eval      expfile = %trim(ckstamp) + '.IMP'
     C                   endsl
     *
     C                   eval      kytype = '03'
     C                   exsr      getckrec
     C                   eval      pfmbr  = expmbr
     *
     C                   select
     c                   when      client = citywholesale
     C                   eval      pfexpf = expfile
     C                   other
     C                   eval      pfexpf = expfile
     C                   endsl
     *
     C                   exsr      updrte
     C                   endif
     *
     C                   if        error
     C                             and     tp_ftp = 'Y'
     *
     *    Update FTP log with Host export file failure.
     *
     C                   eval      kytype = '03'
     C                   exsr      getckrec
     C                   eval      pffsts = '3'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = $pmessage
     C                   Endif
     *
     C                   endif

     *    Write record to export file.

     C                   eval      ckdata = ckexpdata
     C                   write(e)  ckrxrec
     C                   if        %error
     C                   endif

     *    Update record with export info.

     C                   eval      ckexpfile = expmbr
     C                   eval      ckexpts   = currdatestamp
     C                   update(e) ckrrec
     C                   if        %error
     C                   endif

     C                   enddo

     C     endload       endsr

     *----------------------------------------------------------------
     *  logerror    Log error
     *----------------------------------------------------------------

     C     logerror      begsr
     C                   eval      pflusr = #user
     C                   select
     C                   when      count = 0
     C                   eval      pflusr = #user
     C                   eval      pffmsg = 'No Taxrdata records found'
     C                   exsr      updrte
     C                   endsl
     C                   endsr

     *----------------------------------------------------------------
     *  openckrdata   Open CKRDATA file.
     *----------------------------------------------------------------

     C     openckrdata   begsr

     C                   eval      error = *off

     C                   open(e)   ckrdata1
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = '*ERROR'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open file CKRDATA1'
     C                   goto      endopendata
520 AC                   exsr      updrte
     C                   endif

     C     endopendata   endsr

     *----------------------------------------------------------------
     *  openckrexp   Open CKREXP file
     *----------------------------------------------------------------

     C     openckrexp    begsr
     C                   eval      error = *off

     * Create new member for export file.

     *   Create member name

     c
     C                   move      cktrn#        ptranchar
     C                   eval      expmbr = 'T'
     C                   eval      expmbr = %trim(expmbr) + ptranchar

     *   Call program to create member

     C                   call      'CRTCKRMBR'
     C                   parm                    expmbr

     * Override export file member

     C                   eval      qcmd = 'OVRDBF FILE(CKREXP) '
     C                                  + 'MBR('+%trim(expmbr)+') '
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
     C                   eval      ovrdbf = *on

     * Open file.

     C                   open(e)   ckrexp
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = '*ERROR'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open file CKREXP.'
     C                                       + expmbr
     *    Update FTP log with Host export file failure.
     C                   eval      kytype = '03'
     C                   exsr      getckrec
     C                   eval      pffsts = '3'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = $pmessage
     C                   exsr      updrte
     *
     C                   goto      endopenexp
     C                   endif

     C     endopenexp    endsr
