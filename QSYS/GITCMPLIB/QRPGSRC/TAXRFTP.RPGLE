      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TAXRFTP   FTP TAXREXP file to Tax-Right
     *  11 July 2006
     *  Robin Clark
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Revisions
     *
510 A*    07/11/06  RMC  5.10
     *      - Created. Copied from REDPFTPS
     *        Client custom support included.
510aA*    08/03/06  MLB  5.10a
     *      - Enh: Revised program to use file TAXRDATA1
     *        instead of TAXRDATA. This will allow us to
     *        send only records that have not yet been exported.
510bA*    08/07/06  RMC  5.10b
     *      - Enh: Revised program to create members in
     *        TAXREXP using T+transaction number.
510cA*    12/17/06  JCJ  5.10c
     *      - Enh: Add new $pcmd process for *SNDTRN.
510dA*    02/08/07  JCJ  5.10d
     *      - Enh: Revised program to use file txftplog4
     *        instead of txftplog. This adds transaction number
     *        to the key list.
510eA*    03/27/07  JCJ  5.10e
     *      - Fix: fixed ftp resend process.
510fA*    04/05/07  MLB  5.10f
     *      - Fix: Revised LOADEXPFILE routine to ITER instead of
     *        LEAVE when transaction doesn't match and cmd=*SNDTRN.
520 A*    04/17/09  JCJ  5.20
     *      - Fix: Revised program to load transaction number into
     *        key value used in chain to TXFTPLOG4 in *SEND mode.
     *
640 A*    10/05/11  MLB/JCJ  6.40
     *      - Enh: Recompiled program after changes to TAXDATA1 LF
     *        to move TXSEQ# before TXCORD#. This was done to provide
     *        support for multiple orders per tote. Also, this change
     *        will ensure that the header/detail records are sorted
     *        correctly.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: Harbor Wholesale
     *
HAR A*    08/03/06  MLB  HAR
     *      - Revised program to retrieve remote file name from
     *        TAXRDATA file from field TXSTAMP.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Wholesale
     *
CTW A*    11/18/08  JCJ  CTW
     *      - add Citywholesale client ID
     *      - Revised program to retrieve remote file name from
     *        TAXRDATA file from field TXSTAMP.
     *
CTWaA*    11/21/08  JCJ  CTWa
     *      - used txstamp field with no manipulation.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Finkle
     *
FDI A*    02/06/09  JCJ  FDI
     *      - add finkle client ID
     *
FDIaA*    04/17/09  JCJ  FDIa
     *      - add posting tax right data to a second folder.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: AJ Silberman
     *
SLBaA*    09/10/11  JCJ  SLBa
     *      - add silberman client ID
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: AJ Silberman
     *
CWDaA*    03/07/12  JCJ  CWDa
     *      - add cashwa client ID
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Foptions   if   e           k disk
510aDF*taxrdata  uf   e           k disk    usropn
510aMFtaxrdata1 uf   e           k disk    usropn
     F                                     infds(filet1ds)
510dDF*txftplog  uf a e           k disk    usropn
510dMFtxftplog4 uf a e           k disk    usropn
     Ftaxrexp   o    e           k disk    usropn
     F                                     infds(filet2ds)

     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------

     D client          s             10

HAR A /COPY QCOPYSRC,ID#Harbor
CTW AD/copy qcopysrc,id#citywho
FDI AD/copy qcopysrc,id#finkle
SLBaAD/copy qcopysrc,id#silberm
CWDaAD/copy qcopysrc,id#cashwa

     *----------------------------------------------------------------
     *  Tax-Right Detail record data structure
     *----------------------------------------------------------------

     D $taxdetail      ds

     D  $taxdrectype                  1    Inz('D')
     D  $taxlinenum                   3s 0 Inz(0)
     D  $taxupc                      12s 0
     D  $taxdesc                     30
     D  $taxcartqty                   4s 0

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
     *  *TAXRFTP      -  Tax-Right FTP options
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
     D errmsg01        c                   'Tax-Right FTP Options not set'
     D errmsg02        c                   'Host FTP Options not set'
     *
     D stsmsg01        c                   'Connect to Tax-Right server success-
     D                                     ful.       '
     D stsmsg02        c                   'Tax-Right data file sent successful-
     D                                     ly.        '

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $preturn        s             10
     D $pmessage       s             30

510aAD blankexpfile    s                   like(txexpfile)
     D expfile         s                   like(txexpdata)
     D expmbr          s             10

     D ftppwd          s             30
     D ftpremotedir    s             65
     D ftpremotefile   s             65
fdiaAD ftpremotefile2  s             65
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
CTW AD txstampt        s             12
CTW AD txstamptN       s             12  0
fdiaAD pos             s              2  0
fdiaAD w2a             s              2
fdiaAD w2n             s              2  0
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
510aAD                 ds
510aAD  mbrky                  1      8
510aAD  mbrkey                 1      8  0
510aAD mbrretry        s              5  0

510bAD ptranchar       s              7
     *----------------------------------------------------------------
     *  Program information data structure.
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
510aM*  File information data structures. TAXRDATA1, TAXREXP
     *----------------------------------------------------------------

      /Copy qcopysrc,c#filet1ds
      /Copy qcopysrc,c#filet2ds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pcmd      *SEND    - Send file(s) to Host systems
     *                            Called from TAXR.
     *                 *RESEND  - Resend file to Host system
     *                            Called from TX110.
510cA*                 *SNDTRN  - Send file to Host system for a Trn#.
510cA*                            Called from TAXR.
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
510cMC                   when         $pcmd = '*SEND   ' or
510cAC                                $pcmd = '*SNDTRN '
     C                   exsr      loadexpfile
     C     error         cabeq     *on           bottom
     *  Exit if no records written into Tax-Right export file.
     C     count         cabeq     0             bottom
     C                   endsl

     *  Close files.

     C                   exsr      closefiles

     *  FTP export file.

     C                   select
     C                   when         $pcmd = '*SEND   '
     C                             or $pcmd = '*RESEND'
510cAC                             or $pcmd = '*SNDTRN'
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
510aA
510aA* Get client id.
510aA
510aAC                   call      'GETCLIENT'
510aAC                   parm                    client
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
510aM*  Define partial key for TAXRDATA1 file
     *
     C     keytax        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
510aAC                   kfld                    blankexpfile
     *
     *  Define full key for TXFTPLOG4 file
     *
     C     txftpky       klist
     C                   kfld                    $pwhse
510dAC                   kfld                    $prte
     C                   kfld                    $prtid
510dAC                   kfld                    $ptrn#
510dAC                   kfld                    kytype

     *  Retrieve Tax-Right FTP info from file.

     C                   eval      opwhse = $pwhse
     C                   eval      opcode = '*TAXRFTP'
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
510dMC                             and (not %open(txftplog4))
510dMC                   open      txftplog4
     C                   Endif

     C                   endsr

     *----------------------------------------------------------------
     *  Gettxrec      Get TX FTP Status record.
     *----------------------------------------------------------------

     C     gettxrec      begsr
     *
510dMC     txftpky       chain     txftplog4
     C                   select
510dMC                   when      not %found(txftplog4)
     C                   eval      pfwhse = $pwhse
     C                   eval      pfrtid = $prtid
     C                   eval      pfrte  = $prte
     C                   eval      pftype = kytype
510cMC                   eval      pftrn# = txtrn#
     C                   eval      pffsts = '1'
     C                   eval      pflusr = #user
     C                   time                    currstamp
     C                   eval      pfaddts= currstamp
     C                   endsl
     *
     C     endgettxrec   endsr

     *----------------------------------------------------------------
     *  Updrte        Update route being sent to FTP log file.
     *----------------------------------------------------------------

     C     updrte        begsr
     *
     C                   select
510dMC                   when      not %found(txftplog4)
     C                   write     txftpr
     *
510dMC                   when      %found(txftplog4)
     C                   update    txftpr
     C                   endsl
     *
     C     endupdrte     endsr

     *----------------------------------------------------------------
     *  closefiles    Close data and export files.
     *----------------------------------------------------------------

     C     closefiles    begsr
     C                   eval      error = *off

     * Close data file.

510aMC                   if        %open(taxrdata1)
510aMC                   close(e)  taxrdata1
     C                   if        %error
     C                   endif
     C                   endif

     * Close export file.

     C                   if        %open(taxrexp)
     C                   close(e)  taxrexp
     C                   if        %error
     C                   endif
     C                   endif

     * Delete export file override

     C                   if        ovrdbf
     C                   eval      qcmd = 'DLTOVR FILE(TAXREXP)'
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

510cM*  For *SEND or *SNDTRN, create file name.

510cMC                   when      $pcmd = '*SEND' or
510cAC                             $pcmd = '*SNDTRN'
HAR A*
HAR AC                   if        client = Harbor
CTW Ac                             or client = citywholesale
FDI Ac                             or client = finkle
SLBaAc                             or client = silberman
CWDaAc                             or client = cashwa
HAR A*     File name will be created when first record of batch is read.
HAR AC                   else
HAR A*
     C                   eval      expfile    = 'TAX'
     C                                        + tsyear + tsmonth + tsday
     C                                        + tshour + tsmin + tssec
     C                                        + '.IMP'
HAR AC                   endif

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

510eAC                   if        $pcmd = '*RESEND'
510eAC                   open(e)   taxrexp
510eAC                   endif
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
520 AC                   if        $pcmd = '*SEND'
520 AC                   eval      $ptrn# = txtrn#
520 AC                   endif
     C                   exsr      gettxrec
     *
fdiaA* write to second Tax right folder
fdiaA*
fdiaAC                   if        $frtn =  '*OK'
fdiaAC                             and client = finkle
fdiaAC                   exsr      ftpexpfile2
fdiaAC                   endif
fdiaA*
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
     C                   parm      'TAXREXP'     $fffil           10
     C                   parm      expmbr        $ffmbr           10
     C                   parm      ' '           $ffstr           65
     C                   parm      ' '           $ftlib           10
     C                   parm      ' '           $ftfil           10
     C                   parm      ' '           $ftmbr           10
     C                   parm      ftpremotefile $ftstr           65
     C                   parm      ' '           $frtn            10
     C                   parm      ' '           $fmsg            60

     C                   eval      kytype = '03'
     C                   exsr      gettxrec
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

fdiaA*----------------------------------------------------------------
fdiaA*  ftpexpfile2   FTP export file.
fdiaA*----------------------------------------------------------------

fdiaAC     ftpexpfile2   begsr

fdiaAC                   eval      ftpremotefile2 = ftpremotefile
fdiaAC                   eval      pos = %scan('Unit':ftpremotefile2)
fdiaAC                   eval      w2a = %subst(ftpremotefile2:pos+4:2)
fdiaAC                   move      w2a           w2n
fdiaAC                   eval      w2n = w2n + 1
fdiaAC                   eval      w2a = %trim(%editc(w2n:'X'))
fdiaAC                   eval      ftpremotefile2 =
fdiaAC                             %replace(w2a:ftpremotefile2:pos+4:2)

fdiaA*  Send main export file

fdiaAC                   call      'BFCFTP'
fdiaAC                   parm      '*ACTION'     $fcmd
fdiaAC                   parm      ' '           $fsrvr
fdiaAC                   parm      ' '           $fuser
fdiaAC                   parm      ' '           $fpwd
fdiaAC                   parm      'N'           $fbin
fdiaAC                   parm      '1'           $fnfmt
fdiaAC                   parm      'N'           $fpasv
fdiaAC                   parm      'P'           $factn
fdiaAC                   parm      'FILE'        $ftype
fdiaAC                   parm      ft2library    $fflib
fdiaAC                   parm      'TAXREXP'     $fffil
fdiaAC                   parm      expmbr        $ffmbr
fdiaAC                   parm      ' '           $ffstr
fdiaAC                   parm      ' '           $ftlib
fdiaAC                   parm      ' '           $ftfil
fdiaAC                   parm      ' '           $ftmbr
fdiaAC                   parm      ftpremotefile2$ftstr
fdiaAC                   parm      ' '           $frtn
fdiaAC                   parm      ' '           $fmsg

fdiaAC     endftp2       endsr

     *----------------------------------------------------------------
     *  loadexpfile   Load export file.
     *----------------------------------------------------------------

     C     loadexpfile   begsr
     C                   eval      error = *off

     *  Open data file.

     C                   exsr      opentaxrdata
     C     error         cabeq     *on           endload

     *  Loop through records to be exported.

     C                   eval      count = 0

510aMC     keytax        setll     taxrdata1
     C                   dow       forever = forever

510aMC     keytax        reade     taxrdata1
     C                   if        %eof
     C                   leave
     C                   endif

510cAc                   if        $pcmd  =  '*SNDTRN' and
510cAc                             $ptrn# <> txtrn#
510fD ***                leave
510fMC                   iter
510cAC                   endif

     C                   eval      count = count + 1

     *    First time through, open file.

     C                   if        count = 1
     C                   exsr      opentaxrexp
     *
     *    Update FTP log with Host export file info.
     *
     C                   if        $pcmd = '*SEND'
510cMC                             and tp_ftp = 'Y' or
510cAC                             $pcmd = '*SNDTRN'
     C                             and tp_ftp = 'Y'
HAR A*
CTW AC                   select
CTW D ***                if        client = Harbor
CTW MC                   when      client = Harbor
HAR AC                   eval      expfile = %trim(txstamp) + '.IMP'
CTW Ac                   when      client = citywholesale
CTW D ***                movel     txstamp       txstamptn
CTW D ***                eval      txstampt = %char(txstamptn)
CTW D ***                eval      expfile = %trim(txstampt) + '.IMP'
CTW MC                   eval      expfile = %trim(txstamp) + '.IMP'
FDI A* Finkle
FDI Ac                   when      client = finkle
FDI AC                   eval      expfile = %trim(txstamp) + '.IMP'
SLBaA* Silberman
SLBaAc                   when      client = silberman
SLBaAC                   eval      expfile = %trim(txstamp) + '.IMP'
CWDaA* CashWA
CWDaAc                   when      client = cashwa
CWDaAC                   eval      expfile = %trim(txstamp) + '.IMP'
CTW MC                   endsl
HAR A*
     C                   eval      kytype = '03'
     C                   exsr      gettxrec
     C                   eval      pfmbr  = expmbr
HAR A*
CTW AC                   select
CTW D ***                if        client = Harbor
CTW MC                   when      client = Harbor
HARaD ***                eval      pfexpf = txstamp
HARaMC                   eval      pfexpf = expfile
CTW D ***                else
CTW Ac                   when      client = citywholesale
CTW MC                   eval      pfexpf = expfile
FDI A* Finkle
FDI Ac                   when      client = finkle
FDI AC                   eval      pfexpf = expfile
SLBaA* Silberman
SLBaAc                   when      client = silberman
SLBaAC                   eval      pfexpf = expfile
CWDaA* CashWA
CWDaAc                   when      client = cashwa
CWDaAC                   eval      pfexpf = expfile
CTW MC                   other
     C                   eval      pfexpf = expfile
CTW D ***                endif
CTW MC                   endsl
HAR A*
     C                   exsr      updrte
     C                   endif
     *
     C                   if        error
     C                             and     tp_ftp = 'Y'
     *
     *    Update FTP log with Host export file failure.
     *
     C                   eval      kytype = '03'
     C                   exsr      gettxrec
     C                   eval      pffsts = '3'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = $pmessage
     C                   Endif
     *
     C                   endif

     *    Write record to export file.

     C                   eval      txdata = txexpdata
     C                   write(e)  taxxrec
     C                   if        %error
     C                   endif

     *    Update record with export info.

510aAC                   eval      txexpfile = expmbr
     C                   eval      txexpts   = currdatestamp
     C                   update(e) taxrec
     C                   if        %error
     C                   endif

     C                   enddo

     C     endload       endsr

     *----------------------------------------------------------------
     *  logerror    Log error
     *----------------------------------------------------------------

     C     logerror      begsr
     C                   eval      pflusr = #user
520 AC                   select
520 AC                   when      count = 0
520 AC                   eval      pflusr = #user
520 AC                   eval      pffmsg = 'No Taxrdata records found'
520 AC                   exsr      updrte
520 AC                   endsl
     C                   endsr

     *----------------------------------------------------------------
     *  opentaxrdata   Open TAXRDATA file.
     *----------------------------------------------------------------

     C     opentaxrdata  begsr

     C                   eval      error = *off

510aMC                   open(e)   taxrdata1
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = '*ERROR'
     C                   eval      $pmessage = 'Error occured trying to '
510aMC                                       + 'open file TAXRDATA1'
520 AC                   exsr      updrte
     C                   goto      endopendata
     C                   endif

     C     endopendata   endsr

     *----------------------------------------------------------------
     *  opentaxrexp  Open TAXREXP file
     *----------------------------------------------------------------

     C     opentaxrexp   begsr
     C                   eval      error = *off

     * Create new member for export file.

     *   Create member name

510bAc
510bAC                   move      txtrn#        ptranchar
510bAC                   eval      expmbr = 'T'
510bAC                   eval      expmbr = %trim(expmbr) + ptranchar

     *   Call program to create member

     C                   call      'CRTTAXRMBR'
     C                   parm                    expmbr

     * Override export file member

     C                   eval      qcmd = 'OVRDBF FILE(TAXREXP) '
     C                                  + 'MBR('+%trim(expmbr)+') '
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
     C                   eval      ovrdbf = *on

     * Open file.

     C                   open(e)   taxrexp
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = '*ERROR'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open file TAXREXP.'
     C                                       + expmbr
     *    Update FTP log with Host export file failure.
     C                   eval      kytype = '03'
     C                   exsr      gettxrec
     C                   eval      pffsts = '3'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = $pmessage
     C                   exsr      updrte
     *
     C                   goto      endopenexp
     C                   endif

     C     endopenexp    endsr
