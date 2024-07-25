      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TOTEFTP   FTP TOTEEXP file to Cashwa
     *  16 March 2012
     *  Lynn McMahon
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Revisions
     *
CWDaA*    03/16/12  LMC  CWDa
     *      - Created. Copied from TAXRFTPS
     *        Client custom support included.
650aA*    11/25/14  JCJ  650a
     *      - Recompiled for TOTEDATA change of TGSEQ# from 3,0 to 5,0
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Foptions   if   e           k disk
     Ftotedata  if   e           k disk    usropn
     Ftoteexp   o    e           k disk    usropn
     F                                     infds(file14ds)

     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------

     D client          s             10

     D/copy qcopysrc,id#cashwa


     D $totedata       ds

     D TGCORD#
     D TGSEQ#
     D TGTRN#
     D TGHCNT
     D TGTRAX
     D TGITEM
     D TGPCKQ


     *----------------------------------------------------------------
     *  *FTP      -  FTP options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPFTP   -  Use FTP for exporting (Y,N)
     *    OPSRVR  -  FTP Server name
     *    OPUSER  -  FTP User id
     *    OPPWD   -  FTP Password
     *    OPPATH  -  Path for remote file
     *
     * Data structure
     *
     D opdata          ds
     D  opftp                  1      1
     D  opsrvr                 2     33
     D  opuser                34     48
     D  oppwd                 49     63
     D  oppath                64     95
     D  optend               117    117
     *----------------------------------------------------------------
     *  *PHOTFTP      -  Phote/Tote File FTP options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    TXFTP   -  Use FTP for exporting
     *    TXSRVR  -  FTP Server name
     *    TXUSER  -  FTP User id
     *    TXPWD   -  FTP Password
     *    TXPATH  -  Path for remote file
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
     D errmsg01        c                   'Tote FTP Options not set'
     D errmsg02        c                   'Host FTP Options not set'
     *
     D stsmsg01        c                   'Connect to Tote server success-
     D                                     ful.       '
     D stsmsg02        c                   'Tote File data file sent successful-
     D                                     ly.        '

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $preturn        s             10
     D $pmessage       s             30

     D expfile         s            256
     D expmbr          s             10

     D ftppwd          s             30
     D ftpremotedir    s             65
     D ftpremotefile   s             65
     D ftpserver       s             30
     D ftpuser         s             30

     D error           s               n
     D count           s              5  0
     D currstamp       s               z
     D dftstamp        s               z
     D datestamp       s               d
     D timestamp       s               t
     D kytype          s              3
     D ovrdbf          s               n
     D $pcmd           s              8
     D $pwhse          s              3  0
     D $prtid          s              5
     D $prte           s              5
     D $ptrn#          s              7  0
     D $pmbr           s             10
     D $pfile          s             30
     D txstampt        s             12
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
     *  File information data structures.  TOTEEXP
     *----------------------------------------------------------------

      /Copy qcopysrc,c#file14ds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pcmd      *SEND    - Send file(s) to Host systems
     *                            Called from TOTE.
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
     C                   when         $pcmd = '*SEND   '
     C                   exsr      loadexpfile
     C     error         cabeq     *on           bottom
     *  Exit if no records written into Tote export file.
     C     count         cabeq     0             bottom
     C                   endsl

     *  Close files.

     C                   exsr      closefiles

     *  FTP export file.

     C                   select
     C                   when         $pcmd = '*SEND   '
     C                   exsr      ftpexpfile
     C                   endsl

     c                   endif

     C     bottom        tag

     *  Close files before exit.

     C                   exsr      closefiles

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
     *  Define partial key for TOTEDATA1 file
     *
     C     keytote       klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptrn#
     C*                  kfld                    $prtid

     *  Retrieve Tote/photo FTP info from file.

     C                   eval      opwhse = $pwhse
     C                   eval      opcode = '*PHOTFTP'
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

     C                   endsr



     *----------------------------------------------------------------
     *  closefiles    Close data and export files.
     *----------------------------------------------------------------

     C     closefiles    begsr
     C                   eval      error = *off

     * Close data file.

     C                   if        %open(totedata)
     C                   close(e)  totedata
     C                   if        %error
     C                   endif
     C                   endif

     * Close export file.

     C                   if        %open(toteexp)
     C                   close(e)  toteexp
     C                   if        %error
     C                   endif
     C                   endif

     * Delete export file override

     C                   if        ovrdbf
     C                   eval      qcmd = 'DLTOVR FILE(TOTEEXP)'
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

     *  For *SEND  create file name.

     C                   when      $pcmd = '*SEND'
     *
     *     File name will be created when first record of batch is read.
     *
     C                   eval      expfile    = 'P'
     C*                  eval      expfile    = $prte
     c                                        + %trim(%editc($ptrn#:'X'))
     C                                        + tsyear + tsmonth + tsday
     C                                        + tshour + tsmin + tssec
     C                                        + '.IMP'

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
     C                   open(e)   toteexp
     C                   endif
     *
     *  Create remote file name strings.
     *    If Export to Tax-Right is Y=Yes.
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
     C                   endif
     C                   if        $frtn <> '*OK'
     C                   eval      $preturn = '*ERROR'
     C                   eval      $pmessage = $fmsg
     *
     C                   goto      endftp
     C                   Else
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
     C                   parm      f14library    $fflib           10
     C                   parm      'TOTEEXP'     $fffil           10
     C                   parm      expmbr        $ffmbr           10
     C                   parm      ' '           $ffstr           65
     C                   parm      ' '           $ftlib           10
     C                   parm      ' '           $ftfil           10
     C                   parm      ' '           $ftmbr           10
     C                   parm      ftpremotefile $ftstr           65
     C                   parm      ' '           $frtn            10
     C                   parm      ' '           $fmsg            60

     C                   eval      kytype = '03'
     *
     C                   if        $frtn <> '*OK'
     C                   eval      $preturn = '*ERROR'
     C                   eval      $pmessage = $fmsg
     *
     C                   goto      endftp
     C                   Else
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

     C                   exsr      opentotedata
     C     error         cabeq     *on           endload

     *  Loop through records to be exported.

     C                   eval      count = 0

     C     keytote       setll     totedata
     C                   dow       forever = forever

     C     keytote       reade     totedata
     C                   if        %eof
     C                   leave
     C                   endif


     C                   eval      count = count + 1

     *    First time through, open file.

     C                   if        count = 1
     C                   exsr      opentoteexp
     *
     C                   endif

     *    Write record to export file.

     C                   eval      todata = $totedata
     C                   write(e)  toterec
     C                   if        %error
     C                   endif

     C                   enddo

     C     endload       endsr

     *----------------------------------------------------------------
     *  opentotedata   Open TOTEDATA file.
     *----------------------------------------------------------------

     C     opentotedata  begsr

     C                   eval      error = *off

     C                   open(e)   totedata
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = '*ERROR'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open file TOTEDATA'
     C                   goto      endopendata
     C                   endif

     C     endopendata   endsr

     *----------------------------------------------------------------
     *  opentoteexp  Open TOTEEXP file
     *----------------------------------------------------------------

     C     opentoteexp   begsr
     C                   eval      error = *off

     * Create new member for export file.

     *   Create member name

     c
     C                   eval      expmbr = 'PHT'
     C*                  eval      expmbr = %trim(expmbr) + tgrtid
     C                   eval      expmbr = %trim(expmbr) +
     C                                      %trim(%editc($ptrn#:'X'))

     *   Call program to create member

     C                   call      'CRTTOTEMBR'
     C                   parm                    expmbr

     * Override export file member

     C                   eval      qcmd = 'OVRDBF FILE(TOTEEXP) '
     C                                  + 'MBR('+%trim(expmbr)+') '
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
     C                   eval      ovrdbf = *on

     * Open file.

     C                   open(e)   toteexp
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = '*ERROR'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open file TOTEEXP.'
     C                                       + expmbr
     *
     C                   goto      endopenexp
     C                   endif

     C     endopenexp    endsr
