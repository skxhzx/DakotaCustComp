      /copy *libl/qcopysrc,hspecs
     H dftactgrp(*NO) actgrp('QILE') bnddir('QC2LE')
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Compile
     *
     *   CRTBNDRPG PGM(APTFTP) DFTACTGRP(*NO) ACTGRP(QILE)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  APTFTP   FTP APTEXP file
     *  November 10, 2011
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    11/10/11  RTR  LED
     *      - Created.
     *
650a *    08/30/13  RTR  650a
     *      - Changed member name logic to prevent conflicts
650b *    06/30/14  RTR  650b
     *      - Fix - Something changed on Ledyard FTP server requiring
     *        passive FTP. Incase this somehow switches back or it
     *        also happens to Fox River, I have changed it to use Y/N
     *        value from *APTFTP options record.
740a *    10/27/20  RTR  740a
     *      - Changed to update record sequence in data record so
     *        count matches count in current batch.
750a *    03/11/22  KDE  750a
     *      - Add command *SENDT to send specific Transaction
     *      - Changed to only use remote directory if not blank
760  *    04/06/22  KDE  760
     *      - Add milliseconds to export file name.  Yhata had a transaction
     *        get overwritten with duplicate name to the second
760a *    04/14/22  KDE  760a
     *      - Fix issue where bad transaction causing program to end
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     Foptions   if   e           k disk
     Faptdata2  uf   e           k disk    usropn
     Faptdata1  uf   e           k disk    usropn rename(aptrec:aptrec1)
     Fsaftplog  uf a e           k disk    usropn
     Fsaftplog3 uf   e           k disk    usropn
     F                                     rename(saftpr:saftpr3)
     Flabel7    if   e           k disk    usropn
     Faptexp    o    e           k disk    usropn

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D*cmd             S             80    DIM(2) CTDATA PERRCD(1)
     D cmd             S             80    DIM(3) CTDATA PERRCD(1)
     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#usfcrp
      /copy qcopysrc,id#usfasys
      /copy qcopysrc,id#usfpsys
      /copy qcopysrc,id#ledyard

     *----------------------------------------------------------------
     *  *APTFTP   -  APT FTP options
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
     *  *APTFTP      -  APT FTP options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    APFTP   -  Use FTP for exporting
     *    APSRVR  -  FTP Server name
     *    APUSER  -  FTP User id
     *    APPWD   -  FTP Password
     *    APPATH  -  Path for remote file
     *    APFLIB  -  File Library
650bA*    APPASV  -  Passive FTP Flag Y/N
     *
     * Data structure
     *
     D apdata          ds
     D  ap_ftp                 1      1
     D  ap_srvr                2     33
     D  ap_user               34     48
     D  ap_pwd                49     63
     D  ap_path               64     95
     D  ap_flib               96    105
650bAD  ap_pasv              106    106
     D  ap_tend              117    117

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     D forever         s               n   inz('1')
     D Q               C                   Const('''')
     D fromlibc        c                   'PIRF      '
740aAd editw6nz        c                   '     0'
     D errmsg01        c                   'FTP Options not set'
     D errmsg02        c                   'Host FTP Options not set'
     *
     D stsmsg01        c                   'Connect to server successful.      -
     D                                                '
     D stsmsg02        c                   'Data file sent successfully.       -
     D                                                '
     D stsmsg03        c                   'Semaphore file sent successfully.  -
     D                                                '
     D stsmsg04        c                   'Link file sent successfully to Host-
     D                                     .          '
     D stsmsg05        c                   'Link file on Host. Resend file manu-
     D                                     ally.      '
     D stsmsg06        c                   'Connect to P-System server successf-
     D                                     ul.        '
     D stsmsg07        c                   'Connect to A-System server successf-
     D                                     ul.        '
     D stsmsg08        c                   'Data file sent successfully to A-Sy-
     D                                     s Host.    '
     D stsmsg09        c                   'Route ready for export to APT.     -
     D                                                '
     D stsmsg10        c                   'Export to P-Sys in progress.       -
     D                                                '
     D stsmsg11        c                   'CPYTOIMPF failed. Resend file manua-
     D                                     lly.       '
     D stsmsg12        c                   'Work file not deleted from folder: -
     D                                                '
     D stsmsg13        c                   'Work file not renamed in folder:   -
     D                                                '

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $preturn        s             10
     D $pmessage       s             30

     D blnkexpfile     s                   like(apexpfile)
     D expfile         s                   like(apexpfile)
     D expfilesem      s                   like(apexpfile)
     D usf_expfile     s                   like(apexpfile)
     D usf_expfilesem  s                   like(apexpfile)
     D apt_expfile     s                   like(apexpfile)
     D apt_expfilesem  s                   like(apexpfile)
     D expmbr          s             10

     D ftppwd          s             30
     D ftpremotedir    s             65
     D ftpremotefile   s             65
     D ftpremotesem    s             65
     D ftpserver       s             30
     D ftpuser         s             30

760aAd emptyCall       s               n
     D error           s               n
     D count           s              5  0
     D currstamp       s               z
     D dftstamp        s               z
     D datestamp       s               d
     D ftpretry        s              3  0
     D ftpdelay        s              5  0
     D newmessage      s                   like(pffmsg)
     D newstatus       s                   like(pffsts)
     D timestamp       s               t
     D updexpinfo      s              4    inz('*NO ')
     D kytype          s                   like(pftype)
     D kyfsts          s                   like(pffsts)
     D ovrdbf          s               n
     D nbrftpretry     s              7  0
     D nbrftpretry2    s              7  0
     D nbrftpretry3    s              7  0
     D nbrrteexp       s              7  0
650bAD pasflg          s              1a
     D seconds         s             10U 0
     D wkwaitsec       s                   like($qwaitsec)
     D kytrn#1         s              7  0 inz(1)
     D kyseq           s              6a
750aAd wkRte           s              5

     *----------------------------------------------------------------
     *  Procedure Definitions
     *----------------------------------------------------------------

     D sleep           PR            10U 0 extproc('sleep')
     D   seconds                     10U 0 value

     *----------------------------------------------------------------
     *  Data Queue Variables
     *----------------------------------------------------------------

     D  dqdata         s            128
     D  dqlen          s              5  0
     D  dqlib          s             10    inz('*LIBL')
     D  dqname         s             10    inz('APTDTAQ ')
     D  dqwaitsec      s              5  0 inz(300)

     D $qdata          ds
     D  $qcmd                  1      8
     D  $qwaitsec              9     13
     D  $qfilename             9     38
     D  $qrte                  9     13
750aAd  $qTran                 9     15  0
     D  $qend                128    128

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

     *----------------------------------------------------------------
     *  Program information data structure.
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pcmd      *ADDRTE  - Add route being picked to FTP log file
     *                 *SEND    - Send file(s) to Host systems
750aA*                 *SENDT   - Send specific Transaction only
     *                 *RESEND  - Not used in this implementation
     *                 *RESENDH - Resend file to Host system
     *                 *RESENDR - Resend file to FTP Server
     *
     *      $pprogram  Calling program (the one that called interface)
     *      $pdata     Data needed by command
     *      $pdata2    Data needed by command
     *
     *    Returned Parameters
     *      $preturn   Return code
     *      $pmessage  Return code
     *      $pdata     Data returned by command
     *      $pdata2    Data returned by command
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     C                   eval      error     = *off
     C                   eval      $preturn  = '*OK'
     C                   eval      $pmessage = ' '

     *  Read incoming request ...

     C                   call      'QRCVDTAQ'
     C                   parm                    dqname
     C                   parm                    dqlib
     C                   parm                    dqlen
     C                   parm      ' '           dqdata
     C                   parm                    dqwaitsec

      *  If nothing read do a *SEND.

     C                   if        dqlen = 0
     C                   eval      dqdata = '*SEND'
     C                   endif

      *  Move received record into data structure.

     C                   clear                   $qdata
     C                   eval      $qdata = dqdata

750aA        // Test to see if Transaction or Route Id Sent
750aAc/free
760aA           emptyCall = *off;
750aA           monitor;
750aA             // if route id is sent the last two
750aA             // positions of transaction will be
750aA             // blank and cause this to fail, and
750aA             // then we will assume route id.  Otherwise
750aA             // we check to see if valid transaction
750aA             // and get route id and pout in wkRte
750aA             // from here forward instead of $qrte since
750aA             // it uses same space as transaction on parm
750aA             $qTran = $qTran;
750aA             setll ($qTran) label7;
750aA             reade ($qTran) label7;
750aA             if %equal(label7);
750aA               wkRte = lbrte;
750aA             else;
750aA               wkRte = $qrte;
                    if $qcmd='*SENDT';
                      if $qrte=*blanks or $qrte='0';
                        // if it makes it here it means *SENDT was sent
                        // with either not transaction or invalid transaction
                        // and $qrte is blank so we have nothing to send.  We
                        // will skip without doing anything.
760aA                   emptyCall = *on;
                      else;
                        $qcmd='*SEND';
                      endif;
                    endif;
750aA             endif;
750aA           on-error;
750aA             wkrte = $qrte;
                  if $qcmd='*SENDT';
                    if $qrte=*blanks or $qrte='0';
                      // if it makes it here it means *SENDT was sent
                      // with either not transaction or invalid transaction
                      // and $qrte is blank so we have nothing to send.  We
                      // will return without doing anything.
760aA                 emptyCall = *on;
                    else;
                      $qcmd='*SEND';
                    endif;
                  endif;
750aA           endmon;
750aAc/end-free

      *  See if program should end.

     C                   if        $qcmd = '*END'
     C                   eval      *inlr=*on
     C                   return
     C                   endif

760aAc                   if        emptyCall
760aAc                   goto      bottom
760aAc                   endif

     *  See if we should change the wait time.

     C                   if        $qcmd = '*CHGWAIT'
      *    Ensure new wait time is right adjusted.
     C                   evalr     wkwaitsec = %trimr($qwaitsec)
     C                   eval      $qwaitsec = wkwaitsec
     C                   move      $qwaitsec     dqwaitsec
     C                   if        dqwaitsec <= 0
     C*                  eval      dqwaitsec = 600
     C                   eval      dqwaitsec = 300
     C                   endif
     C                   goto      bottom
     C                   endif

     *  Otherwise, assume that command is *SEND or *RESEND.
     *    (verified when creating file names)

     *  Retrieve FTP info from OPTIONS file.

     C                   eval      $pwhse = 1
     C                   eval      opwhse = $pwhse
     C                   eval      opcode = '*APTFTP'
     C     opkey         chain     options
     C                   if        %found(options)
     C                   eval      apdata    = opdata
     C                   else
     C                   eval      ap_ftp     = 'N'
     C                   endif
     *
     C                   select
     C                   when      $qcmd = '*ADDRTE '
     C                   eval      kytype = '01'
     C                   exsr      addrte
     *
     *    Write record to tracking file only if FTP is active
     C                   if        ap_ftp = 'Y'
     C                   eval      kytype = '02'
     C                   exsr      addrte
     C                   endif
     *
     C                   other
     *
     C                   eval      error     = *off
     C                   eval      $preturn  = '*OK'
     C                   eval      $pmessage = ' '
     C                   eval      aptrn# = 0

     *  Retrieve warehouse information.

     C                   call      'GETWHSE2'
     C                   parm                    #user
     C                   parm                    $pwhse            3 0
     C                   parm      *blanks       $pdesc           30
     C                   parm      *blanks       $pfmtdsc         40

     *  Get current datestamp.

     C                   time                    currdatestamp
     C                   eval      tsdatetime = %char(currdatestamp)

     *  Create host file name to use.

     C                   exsr      crtfilenames
     C     error         cabeq     *on           bottom

     *  Load records into export file.

     C                   select
     C                   when      $qcmd = '*SEND   '
750aAC                             or $qcmd = '*SENDT  '
     C                   exsr      loadexpfile
     C     error         cabeq     *on           bottom

     *  Exit if no records written into export file.
     C     count         cabeq     0             bottom
     C                   endsl

     *  Close files.

     C                   exsr      closefiles

     *  FTP export file.

     C                   select
     C                   when         $qcmd = '*SEND   '
750aAC                             or $qcmd = '*SENDT  '
     C                             or $qcmd = '*RESEND '
     *  Send export file to APT.
     C                   exsr      ftpexpfile
     *
     C                   endsl
     *
     C     bottom        tag

     *  Log any errors, then loop around and wait for next request.

     C                   if        error
     C                   exsr      closefiles
     C                   exsr      logerror
740aAc                   else
740aAc                   eval      qcmd = 'RMVM FILE(APTEXP)  '
740aAc                                  + 'MBR('+%trim(expmbr)+') '
740aAc                   eval      qlen = %len(%trim(qcmd))
740aAc                   monitor
740aAc                   call      'QCMDEXC'
740aAc                   parm                    qcmd
740aAc                   parm                    qlen             15 5
740aAc                   on-error
740aAc                   endmon
     c                   endif
     *
     C                   endsl

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          Subroutines in Alphabetical Order
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * Get client id.

     C                   call      'GETCLIENT'
     C                   parm                    client           10

     C                   if        client = USFCRP
     * Get USF System Type (ASYS or PSYS).
     C                   call      'GETUSFSYS'
     C                   parm                    usfsystype       10
     C                   endif

     C                   eval      dftstamp = *loval
     *
     *  Retrieve FTP Retry delay, FTP Retry Max values.
     *
     *      Retrieve delay time between FTP attempts.
     C*    *DTAARA       define    ftpdlyasys    ftpdelaya         5 0
     C*                  in(e)     ftpdelaya
     C*                  if        %error
     C*                  eval      ftpdelaya = 30
     C*                  endif
     C*                  eval      seconds = ftpdelaya
     C                   eval      seconds = 30
     *
     *      Retrieve maximum FTP retry attempts.
     C*    *DTAARA       define    ftprtyasys    ftpretrya         3 0
     C*                  in(e)     ftpretrya
     C*                  if        %error
     C*                  eval      ftpretrya = 3
     C*                  endif
     C*                  eval      ftpretry = ftpretrya
     C                   eval      ftpretry = 3
     *
     *  Open FTP Log file if required.
     *
     C                   if        not %open(saftplog)
     C                   open      saftplog
     C                   Endif
     *
     *  Open FTP Log file - view 3.
     *
     C                   if        not %open(saftplog3)
     C                   open      saftplog3
     C                   Endif
     *
     *  Open LABEL7.
     *
     C                   if        not %open(label7)
     C                   open      label7
     C                   Endif
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
     *  Define partial key for APTDATA1 file
     C     keyap1        klist
     C                   kfld                    blnkexpfile
     C                   kfld                    $qTran
     *
     *  Define partial key for APTDATA2 file

     C     keyap2        klist
     C                   kfld                    $pwhse
750aDC*                  kfld                    $qrte
750aMC                   kfld                    wkRte
     C                   kfld                    blnkexpfile
     *
     *  Define partial key for APTDATA2 file

     C     keyap2a       klist
     C                   kfld                    $pwhse
750aDC*                  kfld                    $qrte
750aMC                   kfld                    wkRte
     C                   kfld                    blnkexpfile
740aDC**                 kfld                    kystamp
740aMc                   kfld                    dftstamp
     *
     *  Define full key for SAFTPLOG file

     C     saftpky       klist
     C                   kfld                    $pwhse
750aDC*                  kfld                    $qrte
750aMC                   kfld                    wkRte
     C                   kfld                    kytype
     *
     *  Define full key for SAFTPLOG file

     C     saftp3ky      klist
     C                   kfld                    $pwhse
     C                   kfld                    kytype
     C                   kfld                    kyfsts

     C                   endsr

     *----------------------------------------------------------------
     *  Addrte        Add route being printed to FTP log file.
     *----------------------------------------------------------------

     C     addrte        begsr
     *
     C                   clear                   saftpr
     C                   eval      pfwhse = $pwhse
750aDC*                  eval      pfrtid = $qrte
750aMC                   eval      pfrtid = wkrte
     C                   eval      pftype = kytype
750aDC*                  eval      pfrte  = $qrte
750aMC                   eval      pfrte  = wkRte
     *      Add new status. "Not ready for export."
     C                   if        usfsystype = usfpsys
     C                   eval      pffsts = '0'
     C                   else
     C                   eval      pffsts = '1'
     C                   endif
     C                   eval      pflusr = #user
     C                   time                    currstamp
     C                   eval      pfaddts= currstamp
     *
     C                   write     saftpr
     *
     C     endaddrte     endsr

     *----------------------------------------------------------------
     *  Dltlink       Delete file created in IFS for FTP to A-Sys.
     *----------------------------------------------------------------

     C     dltlink       begsr
     *

     *  Create IFS folder name and copy APTEXP.mbrname to IFS folder.

     C                   eval      qcmd = 'del'
     C                                  + ' objlnk(' + Q
     C                                  + '/' + expmbr
     C                                  + Q + ')'

     C                   eval      qlen = %len(%trim(qcmd))
     C                   CALL      'QCMDEXC'                            78
     C                   PARM                    qcmd
     C                   PARM                    qlen
     *
     C                   if        *in78 = *on
     C                   eval      error       = *on
     C                   eval      $pmessage   = %trim(stsmsg12)
     C                                           + %subst(qcmd:14:10)
     *
     C                   eval      kytype = '01'
     C                   exsr      getsarec
     C                   eval      pffsts = '3'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = stsmsg11
     C                   exsr      updrte
     C                   endif
     *
     C     enddltlnk     endsr

     *----------------------------------------------------------------
     *  Rnmlink       Rename file created in IFS for FTP to A-Sys.
     *----------------------------------------------------------------

     C     rnmlink       begsr

     C                   time                    currdatestamp

     *  Build rename cmd string to save file copied to IFS.
     C                   eval      qcmd = 'rnm'
     C                                  + ' obj(' + Q
     C                                  + '/' + expmbr
     C                                  + Q + ')'
     C                                  + ' newobj(' + Q
     c                                  + 'SAVE.'
     c                                  + %trim(expmbr)
     c                                  + '.' + %char(currdatestamp)
     C                                  + Q + ')'

     *  Execute rename cmd to save file copied to IFS.
     C                   eval      qlen = %len(%trim(qcmd))
     C                   CALL      'QCMDEXC'                            78
     C                   PARM                    qcmd
     C                   PARM                    qlen
     *
     C                   if        *in78 = *on
     C                   eval      error       = *on
     C                   eval      $pmessage   = %trim(stsmsg13)
     C                                           + %subst(qcmd:10:10)
     *
     C                   eval      kytype = '01'
     C                   exsr      getsarec
     C                   eval      pffsts = '3'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = $pmessage
     C                   exsr      updrte
     C                   endif
     *
     C     endrnmlnk     endsr

     *----------------------------------------------------------------
     *  Getsarec      Get SA FTP Status record\
     *----------------------------------------------------------------

     C     getsarec      begsr
     *
     C     saftpky       chain     saftplog
     C                   select
     C                   when      not %found(saftplog)
     C                   eval      pfwhse = $pwhse
750aDC*                  eval      pfrtid = $qrte
750aMC                   eval      pfrtid = wkRte
     C                   eval      pftype = kytype
750aDC*                  eval      pfrte  = $qrte
750aMC                   eval      pfrte  = wkRte
     C                   eval      pffsts = '1'
     C                   eval      pflusr = #user
     C                   time                    currstamp
     C                   eval      pfaddts= currstamp
     C                   endsl
     *
     C     endgetsarec   endsr

     *----------------------------------------------------------------
     *  Updrte        Updaate route being sent to FTP log file.
     *----------------------------------------------------------------

     C     updrte        begsr
     *
     C*                  select
     C*                  when      not %found(saftplog)
     C                   write     saftpr
     *
     C*                  when      %found(saftplog)
     C*                  update    saftpr
     C*                  endsl
     *
     C     endupdrte     endsr

     *----------------------------------------------------------------
     *  chglogstatus    Change status of SAFTPLOG file.
     *----------------------------------------------------------------

     C     chglogstatus  begsr

     C     saftp3ky      setll     saftplog3
     C                   dow       forever = forever
     C     saftp3ky      reade     saftplog3
     C                   select
     C                   when      %eof(saftplog3)
     C                   leave
     C
     C                   when      pffsts = kyfsts
     C
     C                   eval      pffsts = newstatus
     C                   eval      pffmsg = newmessage
     C                   eval      pflusr = #user
     C
     C                   if        updexpinfo = '*YES'
     *    Only update Exported date stamp on first send.
     C                   if        pfexpts = dftstamp
     C                   eval      pfexpts = currstamp
     C                   endif
     C                   eval      pflexts = currstamp
     C                   endif

     C*                  update    saftpr3
     C                   endsl

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  closefiles    Close data and export files.
     *----------------------------------------------------------------

     C     closefiles    begsr
     C                   eval      error = *off

     * Close data file.

     C                   if        %open(aptdata2)
     C                   close(e)  aptdata2
     C                   if        %error
     C                   endif
     C                   endif

     * Close export file.

     C                   if        %open(aptexp)
     C                   close(e)  aptexp
     C                   if        %error
     C                   endif
     C                   endif

     * Delete export file override

     C                   if        ovrdbf
     C                   eval      qcmd = 'DLTOVR FILE(APTEXP)'
     C                   eval      qlen = %len(%trim(qcmd))
     C                   call      'QCMDEXC'
     C                   parm                    qcmd            512
     C                   parm                    qlen             15 5
     C                   eval      ovrdbf = *off
     C                   endif

     C     endcloseexp   endsr

     *----------------------------------------------------------------
     *  crtfilenames    Create export file names to use.
     *----------------------------------------------------------------

     C     crtfilenames  begsr
     C                   eval      error = *off

     *  Retrieve Host FTP info from file.

     C                   eval      opwhse = $pwhse
     C                   eval      opcode = '*APTFTP '
     C     opkey2        chain     options
     C                   if        %found
     C                   eval      ftpserver    = opsrvr

     C                   eval      ftpremotedir = *blanks
     C                   eval      ftpuser      = opuser
     C                   eval      ftppwd       = oppwd

     C                   else
     C
     C                   eval      error       = *on
     C                   eval      $pmessage   = errmsg02
      *
     *      Reset Route(s) status back to Ready to Export.
     C                   eval      kytype     = '01'
     C                   eval      kyfsts     = '2'
     C                   eval      newstatus  = '1'
     C                   eval      newmessage = errmsg02
     C                   exsr      chglogstatus
      *
     C                   clear                   ftpserver
     C                   clear                   ftpremotedir
     C                   clear                   ftpuser
     C                   clear                   ftppwd
     C
     C                   endif

     C                   select

     *  For *SEND, create file name.

     C                   when      $qcmd = '*SEND'
750aAC                             or $qcmd = '*SENDT'
     C**                 eval      $qfilename = ' '
     C                   eval      expfile    = 'APT'
     C                                        + tsyear + tsmonth + tsday
     C                                        + tshour + tsmin + tssec
760 MC                                        + tssbsec + '.TXT'
760 DC*                                       + '.TXT'
     *
     C                   select
     C                   when      client = usfcrp
     *
     C                   select
     C                   when      usfsystype = usfasys
     C                   exsr      openaptdata
     C     error         cabeq     *on           endcrtnames

     *  Read first AptData record to retrieve first tran# in file.

     C     keyap2a       setll     aptdata2
     C     keyap2        reade     aptdata2
     *  Read first LABEL7 record to retrieve USF A-Sys  in file.
     C     aptrn#        setll     label7
     C                   dow       forever = forever
     C     aptrn#        reade     label7
     *
     C                   select
     C                   when      %eof(label7)
     C                   leave
750aDC*                  when      lbrte <> $qrte
750aMC                   when      lbrte <> wkRte
     C                   iter
     C                   endsl
     *
     C                   enddo

     C                   endsl
     C
     C                   eval      apt_expfile = tsyear + tsmonth + tsday
     C                                         + tshour + tsmin + tssec
     C                                         + tssbsec
     C                                         + '.TXT'
     C
     C                   endsl

     *  For *RESEND, use the file name that was sent.

     C                   when      $qcmd = '*RESEND'
     C                             or $qcmd = '*RESENDH'
     C                             or $qcmd = '*RESENDR'
     C                   if        $qfilename = ' '
     C                   eval      error = *on
     C                   eval      $preturn = '*ERROR'
     C                   eval      $pmessage = 'File name must be sent +
     C                                          for *RESEND'
     C                   goto      endcrtnames
     C                   endif
     *
     C                   eval      expfile = %trim($qfilename)

     *  Trap invalid commands.

     C                   other
     C                   eval      error = *on
     C                   eval      $preturn = '*ERROR'
     C                   eval      $pmessage = 'Invalid command sent '
     C                                       + '(' + %trim($qcmd) + ')'
     C                   goto      endcrtnames

     C                   endsl

     *  Create semaphore file name

     C                   select
     C                   when      client = usfcrp
     C                   eval      usf_expfilesem = 'S' + %trim(usf_expfile)
     C                   eval      expfilesem = 'S' + %trim(expfile)
     C                   endsl

     C     endcrtnames   endsr

     *----------------------------------------------------------------
     *  ftpexpfile    FTP export file.
     *----------------------------------------------------------------

     C     ftpexpfile    begsr
     C                   eval      error = *off

     *  Retrieve FTP info from file.

     C                   eval      opwhse = $pwhse
     C                   eval      opcode = '*APTFTP'
     C     opkey         chain     options
     C                   if        %found
     C                   eval      apdata    = opdata
     C                   eval      ftpserver    = ap_srvr
     C                   eval      ftpremotedir = ap_path
     C                   eval      ftpuser      = ap_user
     C                   eval      ftppwd       = ap_pwd
     C
     C                   else
     C
     C                   eval      error       = *on
     C                   eval      $pmessage   = errmsg01
     C                   eval      ap_ftp = 'N'
     C                   clear                   ftpserver
     C                   clear                   ftpremotedir
     C                   clear                   ftpuser
     C                   clear                   ftppwd
     C
     C                   endif
     C

     *  Create remote file name strings.
     *    If Export is Y=Yes.

     C                   if        error = *off
     C                             and ap_ftp = 'Y'
     C
     C                   select
     C                   when      client = usfcrp
     C
     C                   eval      ftpremotefile = %trim(ftpremotedir)
     C                                           + %trim(apt_expfile)
     C                   eval      ftpremotesem = %trim(ftpremotedir)
     C                                          + %trim(apt_expfilesem)
     C
     C                   other
     C
750aDC*                  eval      ftpremotefile = './' + %trim(ftpremotedir)
750aMC                   eval      ftpremotefile = '.'
750aAc                   if        ftpremotedir <> *blanks
750aDC*                  eval      ftpremotefile = './' + %trim(ftpremotedir)
750aMC                   eval      ftpremotefile = '/' + %trim(ftpremotedir)
750aAc                   endif
750aDC*                                          + '/' + %trim(expfile)
750aMC                   eval      ftpremotefile = %trim(ftpremotefile) +
750aMc                                             '/' + %trim(expfile)

     C                   endsl
     C

     *  Open connection.

     *      NbrFtpRetry for x connection attempts.
     C                   eval      nbrftpretry  = ftpretry
     C     #ftpapt01     tag
     *
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

     C                   eval      kytype = '02'
     *
     C                   eval      nbrftpretry = nbrftpretry - 1
     C                   eval      $frtn = '*OK'
     C                   if        $frtn <> '*OK'
     *
     *      Attempt to connect to ftp server x times. If it fails,
     *      then set file status to Error.
     C                   if        nbrftpretry > 0
     C                   exsr      ftpquit
     *      Sleep for a time before retrying.
     C                   callp     sleep(seconds)
     C                   goto      #ftpapt01
     C                   endif
     *
     C                   eval      $preturn = '*ERROR'
     C                   eval      $pmessage = $fmsg
     *
     C                   exsr      getsarec
     C                   eval      pffsts = '3'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = $pmessage
     C                   exsr      updrte
     *
     C                   goto      endftp
     C                   Else
     *
     C                   exsr      getsarec
     C                   eval      pffsts = '2'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = stsmsg01
     C                   exsr      updrte
     *
     C                   endif

     *  Send main export file

     C                   if        client = usfcrp
     C                   eval      $fflib = fromlibc
     C
     C                   Else
     C                   eval      $fflib = ap_flib
     C
     C                   endif
     C
650bA*  Use passive flag from Options record, default 'N'
650bAC                   select
650bAC                   when      ap_pasv = 'Y'
650bAC                             or ap_pasv = 'N'
650bAC                   eval      pasflg = ap_pasv
650bAC                   other
650bAC                   eval      pasflg = 'N'
650bAC                   endsl
     C
     C                   call      'BFCFTP'
     C                   parm      '*ACTION'     $fcmd            10
     C                   parm      ' '           $fsrvr           65
     C                   parm      ' '           $fuser           30
     C                   parm      ' '           $fpwd            30
     C                   parm      'N'           $fbin             1
     C                   parm      ' '           $fnfmt            1
650bDC*                  parm      'N'           $fpasv            1
650bMC                   parm      pasflg        $fpasv            1
     C                   parm      'P'           $factn            1
     C                   parm      'FILE'        $ftype            4
     C                   parm                    $fflib           10
     C                   parm      'APTEXP '     $fffil           10
     C                   parm      expmbr        $ffmbr           10
     C                   parm      ' '           $ffstr           65
     C                   parm      ' '           $ftlib           10
     C                   parm      ' '           $ftfil           10
     C                   parm      ' '           $ftmbr           10
     C                   parm      ftpremotefile $ftstr           65
     C                   parm      ' '           $frtn            10
     C                   parm      ' '           $fmsg            60

     C                   eval      kytype = '02'
     *
     C                   eval      nbrftpretry2 = nbrftpretry2 - 1
     C                   if        $frtn <> '*OK'
     *
     *      Attempt to send file 3 times. If it fails,
     *      then set file status to Error.
     C                   if        nbrftpretry2 > 0
     C                   exsr      ftpquit
     *      Sleep for a time before retrying.
     C                   callp     sleep(seconds)
     C                   goto      #ftpapt01
     C                   endif
     *
     C                   eval      $preturn = '*ERROR'
     C                   eval      $pmessage = $fmsg
     *
     C                   exsr      getsarec
     C                   eval      pffsts = '3'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = $pmessage
     C                   exsr      updrte
     *
     C                   goto      endftp
     C                   Else
     *
     C                   exsr      getsarec
     C                   eval      pffsts = '2'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = stsmsg02
     C                   exsr      updrte
     *
     C                   endif

     *  Send semaphore file

     C                   if        client = usfcrp
     C                   eval      $fflib = fromlibc
     C
     C                   call      'BFCFTP'
     C                   parm      '*ACTION'     $fcmd            10
     C                   parm      ' '           $fsrvr           65
     C                   parm      ' '           $fuser           30
     C                   parm      ' '           $fpwd            30
     C                   parm      'N'           $fbin             1
     C                   parm      ' '           $fnfmt            1
     C                   parm      'N'           $fpasv            1
     C                   parm      'P'           $factn            1
     C                   parm      'FILE'        $ftype            4
     C                   parm                    $fflib           10
     C                   parm      'APTEXP  '    $fffil           10
     C                   parm      ' '           $ffmbr           10
     C                   parm      ' '           $ffstr           65
     C                   parm      ' '           $ftlib           10
     C                   parm      ' '           $ftfil           10
     C                   parm      ' '           $ftmbr           10
     C                   parm      ftpremotesem  $ftstr           65
     C                   parm      ' '           $frtn            10
     C                   parm      ' '           $fmsg            60

     C                   eval      kytype = '02'
     *
     C                   eval      nbrftpretry3 = nbrftpretry3 - 1
     C                   if        $frtn <> '*OK'
     *
     *      Attempt to send file 3 times. If it fails,
     *      then set file status to Error.
     C                   if        nbrftpretry3 > 0
     C                   exsr      ftpquit
     *      Sleep for a time before retrying.
     C                   callp     sleep(seconds)
     C                   goto      #ftpapt01
     C                   endif
     *
     C                   eval      $preturn = '*ERROR'
     C                   eval      $pmessage = $fmsg
     *
     C                   exsr      getsarec
     C                   eval      pffsts = '3'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = $pmessage
     C                   exsr      updrte
     *
     C                   goto      endftp
     C                   Else
     *
     C                   exsr      getsarec
     C                   eval      pffsts = '4'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = stsmsg03
     C                   time                    currstamp
     *    Only update Exported date stamp on first send.
     C                   if        pfexpts = dftstamp
     C                   eval      pfexpts = currstamp
     C                   endif
     C                   eval      pflexts = currstamp
     C*                  exsr      updrte
     *
     C                   endif
     C                   endif

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
     *  ftpexpf_hst   FTP export file to Host P-system.
     *----------------------------------------------------------------

     C     ftpexpf_hst   begsr
     C                   eval      error = *off

     *  Retrieve Host FTP info from file.

     C                   eval      opwhse = $pwhse
     C                   eval      opcode = '*APTFTP '
     C     opkey2        chain     options
     C                   if        %found
     C                   eval      ftpserver    = opsrvr
     *
     *      Note for the psys the path is built in the file name.
     C                   eval      ftpremotedir = *blanks
     C                   eval      ftpuser      = opuser
     C                   eval      ftppwd       = oppwd
     C
     C                   else
     C
     C                   eval      error       = *on
     C                   eval      $pmessage   = errmsg02
     *
     C                   eval      kytype = '01'
     C                   exsr      getsarec
     C                   eval      pffsts = '3'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = $pmessage
     C                   exsr      updrte
     *
     C                   clear                   ftpserver
     C                   clear                   ftpremotedir
     C                   clear                   ftpuser
     C                   clear                   ftppwd
     C
     C                   endif
     C

     *  Create remote file name strings.

     C                   if        error = *off
     C
     C                   select
     C                   when      client = usfcrp
     C
     C                   eval      ftpremotefile = %trim(ftpremotedir)
     C                             + '''' + %trim(usf_expfile) + ''''
     C                   eval      ftpremotesem = %trim(ftpremotedir)
     C                             + '''' + %trim(usf_expfilesem) + ''''
     C
     C                   other
     C
     C                   eval      ftpremotefile = './' + %trim(ftpremotedir)
     C                                           + '/' + %trim(expfile)
     C
     C                   endsl
     C

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

     C                   eval      kytype = '01'
     C                   exsr      getsarec
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
     C                   goto      endftp_host
     C                   Else
     *
     C                   eval      pffsts = '2'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = stsmsg06
     C                   exsr      updrte
     *
     C                   endif

     *  Check if WMS0102.txt file exists on Host system. If not found, okay to
     *  If file found, cancel send of file, update FTP log.

     C                   eval      $fflib = ap_flib
     C                   eval      $fffil = 'APTEXP    '
     C                   eval      $ffmbr = expmbr
     C                   eval      $factn = 'P'
     C
     C                   call      'BFCFTP'
     C                   parm      '*ACTION'     $fcmd            10
     C                   parm      ' '           $fsrvr           65
     C                   parm      ' '           $fuser           30
     C                   parm      ' '           $fpwd            30
     C                   parm      'N'           $fbin             1
     C                   parm      ' '           $fnfmt            1
     C                   parm      'N'           $fpasv            1
     C                   parm                    $factn            1
     C                   parm      'FILE'        $ftype            4
     C                   parm                    $fflib           10
     C                   parm                    $fffil           10
     C                   parm                    $ffmbr           10
     C                   parm      ' '           $ffstr           65
     C                   parm      ' '           $ftlib           10
     C                   parm      ' '           $ftfil           10
     C                   parm      ' '           $ftmbr           10
     C                   parm      ftpremotefile $ftstr           65
     C                   parm      ' '           $frtn            10
     C                   parm      ' '           $fmsg            60

     *    File found on Host. Cancel FTP send. Log error.
     C                   if        $frtn =  '*OK'
     C                   eval      $preturn = '*ERROR'
     *
     C                   eval      kytype = '01'
     C                   exsr      getsarec
     C                   eval      pffsts = '3'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = stsmsg05
     C                   exsr      updrte
     *
     C                   goto      #closeftp
     C                   Else
     *
     *    File NOT found on Host. Continue with FTP send.
     *
     C                   endif
     C     #testskip     tag

     *  Send main export file

     C                   eval      $fflib = ap_flib
     C                   eval      $fffil = 'APTEXP    '
     C                   eval      $ffmbr = expmbr
     C                   eval      $factn = 'P'
     C
     C                   call      'BFCFTP'
     C                   parm      '*ACTION'     $fcmd            10
     C                   parm      ' '           $fsrvr           65
     C                   parm      ' '           $fuser           30
     C                   parm      ' '           $fpwd            30
     C                   parm      'N'           $fbin             1
     C                   parm      ' '           $fnfmt            1
     C                   parm      'N'           $fpasv            1
     C                   parm                    $factn            1
     C                   parm      'FILE'        $ftype            4
     C                   parm                    $fflib           10
     C                   parm                    $fffil           10
     C                   parm                    $ffmbr           10
     C                   parm      ' '           $ffstr           65
     C                   parm      ' '           $ftlib           10
     C                   parm      ' '           $ftfil           10
     C                   parm      ' '           $ftmbr           10
     C                   parm      ftpremotefile $ftstr           65
     C                   parm      ' '           $frtn            10
     C                   parm      ' '           $fmsg            60

     C                   eval      kytype = '01'
     C                   exsr      getsarec
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
     C                   goto      endftp_host
     C                   Else
     *
     C                   eval      pffsts = '4'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = stsmsg04
     C                   time                    currstamp
     *    Only update Exported date stamp on first send.
     C                   if        pfexpts = dftstamp
     C                   eval      pfexpts = currstamp
     C                   endif
     C                   eval      pflexts = currstamp
     C*                  exsr      updrte
     *
     C                   endif

     *  Send semaphore file

     C                   if        client = usfcrp
     *
     *  Skip sending samaphore file. Host to retrieve export file.
     C                   goto      #Closeftp
     *
     C                   eval      $fflib = 'PIRUSFF'
     C
     C                   Else
     C                   eval      $fflib = ap_flib
     C
     C                   endif
     C
     C                   call      'BFCFTP'
     C                   parm      '*ACTION'     $fcmd            10
     C                   parm      ' '           $fsrvr           65
     C                   parm      ' '           $fuser           30
     C                   parm      ' '           $fpwd            30
     C                   parm      'N'           $fbin             1
     C                   parm      ' '           $fnfmt            1
     C                   parm      'N'           $fpasv            1
     C                   parm      'P'           $factn            1
     C                   parm      'FILE'        $ftype            4
     C                   parm                    $fflib           10
     C                   parm      'APTEXP  '    $fffil           10
     C                   parm      ' '           $ffmbr           10
     C                   parm      ' '           $ffstr           65
     C                   parm      ' '           $ftlib           10
     C                   parm      ' '           $ftfil           10
     C                   parm      ' '           $ftmbr           10
     C                   parm      ftpremotesem  $ftstr           65
     C                   parm      ' '           $frtn            10
     C                   parm      ' '           $fmsg            60

     C                   if        $frtn <> '*OK'
     C                   eval      $preturn = '*ERROR'
     C                   eval      $pmessage = $fmsg
     C                   goto      endftp_host
     C                   endif

     *  Close connection.

     C     #closeftp     tag
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
     C                   goto      endftp_host
     C                   endif

     C                   endif

     C     endftp_host   endsr

     *----------------------------------------------------------------
     *  ftpexpf_hosta  FTP export file to Host A-system.
     *----------------------------------------------------------------

     C     ftpexpf_hosta begsr
     C                   eval      error = *off

     *  Retrieve Host FTP info from file.

     C                   eval      opwhse = $pwhse
     C                   eval      opcode = '*APTFTP '
     C     opkey2        chain     options
     C                   if        %found
     C                   eval      ftpserver    = opsrvr
     C                   eval      ftpremotedir = oppath
     C                   eval      ftpuser      = opuser
     C                   eval      ftppwd       = oppwd

     C                   else

     C                   eval      error       = *on
     C                   eval      $pmessage   = errmsg02
     *
     C                   eval      kytype = '01'
     C                   exsr      getsarec
     C                   eval      pffsts = '3'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = $pmessage
     C                   exsr      updrte
     *
     C                   clear                   ftpserver
     C                   clear                   ftpremotedir
     C                   clear                   ftpuser
     C                   clear                   ftppwd

     C                   endif

     *  Create remote file name string.

     C                   if        error = *off

     C                   eval      ftpremotefile = %trim(ftpremotedir)
     C                             + %trim(usf_expfile)

     *  Create IFS folder name and copy APTEXP.mbrname to IFS folder.

     C                   eval      qcmd = 'cpytoimpf'
     C                                  + ' fromfile(*LIBL/APTEXP'
     C                                  + ' ' + expmbr + ')'
     C                                  + ' tostmf(' + Q
     C                                  + '/USFTBEXP' + '/'
     C                                  + expmbr
     C                                  + Q + ')'
     C                                  + ' mbropt(*REPLACE)'
     C                                  + ' stmfcodpag(*PCASCII)'
     C                                  + ' rcddlm(*CRLF)'
     C                                  + ' dtafmt(*FIXED)'

     C                   eval      qlen = %len(%trim(qcmd))
     C                   CALL      'QCMDEXC'                            78
     C                   PARM                    qcmd
     C                   PARM                    qlen
     C                   if        *in78 = *on
     C                   eval      error       = *on
     C                   eval      $pmessage   = errmsg02
     *
     C                   eval      kytype = '01'
     C                   exsr      getsarec
     C                   eval      pffsts = '3'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = stsmsg11
     C                   exsr      updrte
     *
     C                   goto      endftp_hosta
     C                   endif

     *  Open connection.

     *      NbrFtpRetry for x connection attempts.
     C                   eval      nbrftpretry  = ftpretry
     C     #HostA01      tag
     *
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

     C                   eval      kytype = '01'
     *
     C                   eval      nbrftpretry = nbrftpretry - 1
     C                   if        $frtn <> '*OK'
     *
     *      Attempt to connect to ftp server x times. If it fails,
     *      then set file status to Error.
     C                   if        nbrftpretry > 0
     C                   exsr      ftpquit
     *      Sleep for a time before retrying.
     C                   callp     sleep(seconds)
     C                   goto      #hostA01
     C                   endif
     *
     C                   eval      $preturn = '*ERROR'
     C                   eval      $pmessage = $fmsg
     *
     C                   exsr      getsarec
     C                   eval      pffsts = '3'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = $pmessage
     C                   exsr      updrte
     *
     C                   goto      endftp_hosta
     C                   Else
     *
     C                   exsr      getsarec
     C                   eval      pffsts = '2'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = stsmsg07
     C                   exsr      updrte
     *
     C                   endif

     *  Send main export file

     C                   eval      $fflib = ' '
     C                   eval      $fffil = ' '
     C                   eval      $ffmbr = ' '
     C                   eval      $ffstr = '/USFTBEXP'
     C                                      + '/' + expmbr
     C                   eval      $factn = 'P'

     C                   call      'BFCFTP'
     C                   parm      '*ACTION'     $fcmd            10
     C                   parm      ' '           $fsrvr           65
     C                   parm      ' '           $fuser           30
     C                   parm      ' '           $fpwd            30
     C                   parm      'Y'           $fbin             1
     C                   parm      ' '           $fnfmt            1
     C                   parm      'N'           $fpasv            1
     C                   parm                    $factn            1
     C                   parm      'FILE'        $ftype            4
     C                   parm      ' '           $fflib           10
     C                   parm      ' '           $fffil           10
     C                   parm      ' '           $ffmbr           10
     C                   parm                    $ffstr           65
     C                   parm      ' '           $ftlib           10
     C                   parm      ' '           $ftfil           10
     C                   parm      ' '           $ftmbr           10
     C                   parm      ftpremotefile $ftstr           65
     C                   parm      ' '           $frtn            10
     C                   parm      ' '           $fmsg            60

     C                   eval      kytype = '01'
     *
     C                   eval      nbrftpretry2 = nbrftpretry2 - 1
     C                   if        $frtn <> '*OK'
     *
     *      Attempt to send file x times. If it fails,
     *      then set file status to Error.
     C                   if        nbrftpretry2 > 0
     C                   exsr      ftpquit
     *      Sleep for a time before retrying.
     C                   callp     sleep(seconds)
     C                   goto      #hostA01
     C                   endif
     *
     C                   eval      $preturn = '*ERROR'
     C                   eval      $pmessage = $fmsg
     *
     C                   exsr      getsarec
     C                   eval      pffsts = '3'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = $pmessage
     C                   exsr      updrte
     *
     C                   goto      endftp_hosta
     C                   Else
     *
     C                   exsr      getsarec
     C                   eval      pffsts = '4'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = stsmsg08
     C                   time                    currstamp
     *    Only update Exported date stamp on first send.
     C                   if        pfexpts = dftstamp
     C                   eval      pfexpts = currstamp
     C                   endif
     C                   eval      pflexts = currstamp
     C*                  exsr      updrte
     *
     C                   endif

     *  Close connection.

     C     #closeftpa    tag
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
     C                   goto      endftp_hosta
     C                   endif

     *      Rename work file in IFS.
     C                   exsr      rnmlink

     C                   endif

     C     endftp_hosta  endsr

     *----------------------------------------------------------------
     *  ftpexpf_psys   FTP export file to Host P-system.
     *----------------------------------------------------------------

     C     ftpexpf_psys  begsr
     C                   eval      error = *off
     C                   eval      NbrRteExp = 0
     *
     C                   eval      kytype = '01'
     C                   eval      kyfsts = '1'
     C     saftp3ky      setll     saftplog3
     *  If not routes ready for export, get out.
     C                   if        not %equal
     C                   goto      endftpf_psys
     C                   endif

     *  Extract mbr name assigned for route and add to WMS0102 file.

     C                   dow       forever = forever
     C     saftp3ky      reade     saftplog3
     C                   select
     C                   when      %eof(saftplog3)
     *  Exit loop when maximum number of routes written to export file.
     C                             or NbrRteExp >= 20
     C                   unlock    saftplog3
     *
     C                   leave
     C
     C                   when      pffsts = '1'
     C                             and pfmbr > ' '
     C                   eval      pffsts = '2'
     C                   eval      pffmsg = stsmsg10
     C                   update    saftpr3
     *
     *  Count number of routes written to export file.
     C                   eval      NbrRteExp = NbrRteExp + 1
     C
     C                   endsl

     C                   enddo

     *  Retrieve Host FTP info from file.

     C                   eval      opwhse = $pwhse
     C                   eval      opcode = '*APTFTP '
     C     opkey2        chain     options
     C                   if        %found
     C                   eval      ftpserver    = opsrvr
     *
     *      Note for the psys the path is built in the file name.
     C                   eval      ftpremotedir = *blanks
     C                   eval      ftpuser      = opuser
     C                   eval      ftppwd       = oppwd
     C
     C                   else
     C
     C                   eval      error       = *on
     C                   eval      $pmessage   = errmsg02
     *
     *      Reset Route(s) status back to Ready to Export.
     C                   eval      kytype     = '01'
     C                   eval      kyfsts     = '2'
     C                   eval      newstatus  = '1'
     C                   eval      newmessage = errmsg02
     C                   exsr      chglogstatus
     *
     C                   clear                   ftpserver
     C                   clear                   ftpremotedir
     C                   clear                   ftpuser
     C                   clear                   ftppwd
     C
     C                   endif
     C

     *  Create remote file name strings.

     C                   if        error = *off

     C                   if        oppath = *blanks
     C                   eval      oppath = 'PYAPN.R'
     C                   endif
     C                   eval      usf_expfile = %trim(oppath)
     C                                        + '.WH.WMS0102'
     C                                        + '.TXT'

     C                   eval      ftpremotefile =
     C                              '''' + %trim(usf_expfile) + ''''

     *  Open connection.

     *      NbrFtpRetry for x connection attempts.
     C                   eval      nbrftpretry  = ftpretry
     *      NbrFtpRetry2 for x WMS0102 data file send attempts.
     C                   eval      nbrftpretry2 = ftpretry
     *      NbrFtpRetry3 (not referenced in this routine at this time).
     C                   eval      nbrftpretry3 = ftpretry
     C     #HostP01      tag
     *
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

     C                   eval      kytype = '01'
     *
     C                   eval      nbrftpretry = nbrftpretry - 1
     C                   if        $frtn <> '*OK'
     *
     *      Attempt to send file x times. If it fails,
     *      then set file status to Error.
     C                   if        nbrftpretry > 0
     C                   exsr      ftpquit
     *      Sleep for a time before retrying.
     C                   callp     sleep(seconds)
     C                   goto      #hostP01
     C                   endif
     *
     C                   eval      $preturn = '*ERROR'
     C                   eval      $pmessage = $fmsg
     *
     C                   eval      kytype     = '01'
     C                   eval      kyfsts     = '2'
     C                   eval      newstatus  = '1'
     C                   eval      newmessage = $fmsg
     C                   exsr      chglogstatus
     *
     C                   goto      endftpf_psys
     C                   Else
     *      Continue with FTP processing.
     C                   endif

     *  Check if WMS0102.txt file exists on Host system.
     *  If file found, cancel send of file, update FTP log.

     C                   eval      $fflib = ap_flib
     C                   eval      $fffil = 'APTEXP    '
     C                   eval      $ffmbr = expmbr
     C                   eval      $factn = 'P'
     C
     C                   call      'BFCFTP'
     C                   parm      '*ACTION'     $fcmd
     C                   parm      ' '           $fsrvr
     C                   parm      ' '           $fuser
     C                   parm      ' '           $fpwd
     C                   parm      'N'           $fbin
     C                   parm      ' '           $fnfmt
     C                   parm      'N'           $fpasv
     C                   parm                    $factn
     C                   parm      'FILE'        $ftype
     C                   parm                    $fflib
     C                   parm                    $fffil
     C                   parm                    $ffmbr
     C                   parm      ' '           $ffstr
     C                   parm      ' '           $ftlib
     C                   parm      ' '           $ftfil
     C                   parm      ' '           $ftmbr
     C                   parm      ftpremotefile $ftstr
     C                   parm      ' '           $frtn
     C                   parm      ' '           $fmsg

     *    File found on Host. Cancel FTP send. Log error.
     C                   if        $frtn =  '*OK'
     C                   eval      $preturn = '*ERROR'
     *
     C                   eval      kytype     = '01'
     C                   eval      kyfsts     = '2'
     C                   eval      newstatus  = '1'
     C                   eval      newmessage = stsmsg05
     C                   exsr      chglogstatus
     *
     C                   call      'BFCFTP'
     C                   parm      '*QUIT'       $fcmd
     C                   parm      ' '           $fsrvr
     C                   parm      ' '           $fuser
     C                   parm      ' '           $fpwd
     C                   parm      ' '           $fbin
     C                   parm      ' '           $fnfmt
     C                   parm      ' '           $fpasv
     C                   parm      ' '           $factn
     C                   parm      ' '           $ftype
     C                   parm      ' '           $fflib
     C                   parm      ' '           $fffil
     C                   parm      ' '           $ffmbr
     C                   parm      ' '           $ffstr
     C                   parm      ' '           $ftlib
     C                   parm      ' '           $ftfil
     C                   parm      ' '           $ftmbr
     C                   parm      ' '           $ftstr
     C                   parm      ' '           $frtn
     C                   parm      ' '           $fmsg
     *
     C                   eval      $preturn = '*ERROR'
     C                   eval      $pmessage = $fmsg
     C                   eval      kytype     = '01'
     C                   eval      kyfsts     = '2'
     C                   eval      newstatus  = '1'
     C                   eval      newmessage = $fmsg
     C                   eval      updexpinfo = '*YES'
     C                   time                    currstamp
     C                   exsr      chglogstatus
     C                   eval      updexpinfo = '*NO '
     C                   goto      endftpf_psys

     C                   Else
     *
     *    File NOT found on Host. Continue with FTP send.
     *
     C                   endif


     *  Send WMS0102 export file

     C                   eval      $fflib = 'QTEMP     '
     *  File will now be sent via P=Put.
     C                   eval      $factn = 'P'
     C
     C                   call      'BFCFTP'
     C                   parm      '*ACTION'     $fcmd            10
     C                   parm      ' '           $fsrvr           65
     C                   parm      ' '           $fuser           30
     C                   parm      ' '           $fpwd            30
     C                   parm      'N'           $fbin             1
     C                   parm      ' '           $fnfmt            1
     C                   parm      'N'           $fpasv            1
     C                   parm                    $factn            1
     C                   parm      'FILE'        $ftype            4
     C                   parm                    $fflib           10
     C                   parm                    $fffil           10
     C                   parm                    $ffmbr           10
     C                   parm      ' '           $ffstr           65
     C                   parm      ' '           $ftlib           10
     C                   parm      ' '           $ftfil           10
     C                   parm      ' '           $ftmbr           10
     C                   parm      ftpremotefile $ftstr           65
     C                   parm      ' '           $frtn            10
     C                   parm      ' '           $fmsg            60
     *
     C                   eval      nbrftpretry2 = nbrftpretry2 - 1
     C                   if        $frtn <> '*OK'
     *
     *      Attempt to send file x times. If it fails,
     *      then set file status to Error.
     C                   if        nbrftpretry2 > 0
     C                   exsr      ftpquit
     *      Sleep for a time before retrying.
     C                   callp     sleep(seconds)
     C                   goto      #hostP01
     C                   endif
     *
     C                   eval      $preturn = '*ERROR'
     C                   eval      $pmessage = $fmsg
     *
     C                   eval      kytype     = '01'
     C                   eval      kyfsts     = '2'
     C                   eval      newstatus  = '1'
     C                   eval      newmessage = $fmsg
     C                   eval      updexpinfo = '*YES'
     C                   time                    currstamp
     C                   exsr      chglogstatus
     C                   eval      updexpinfo = '*NO '
     *
     C                   goto      endftpf_psys
     C                   Else
     *
     *
     C                   eval      kytype     = '01'
     C                   eval      kyfsts     = '2'
     C                   eval      newstatus  = '2'
     C                   eval      newmessage = stsmsg04
     C                   eval      updexpinfo = '*YES'
     C                   time                    currstamp
     C                   exsr      chglogstatus
     C                   eval      updexpinfo = '*NO '
     *
     C                   endif

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
     C                   eval      $preturn  = '*ERROR'
     C                   eval      $pmessage = $fmsg
     C                   goto      endftpf_psys
     C                   endif

     C                   endif

     C     endftpf_psys  endsr

     *----------------------------------------------------------------
     *  ftpprtjlog    Print Joblog when ftp fails.
     *----------------------------------------------------------------

     C     ftpprtjlog    begsr

     C                   eval      qcmd = 'DSPJOBLOG OUTPUT(*PRINT)'
     C                   eval      qlen = %len(%trim(qcmd))
     C                   call (e)  'QCMDEXC'
     C                   parm                    qcmd
     C                   parm                    qlen             15 5

     C     endftpprtjlog endsr

     *----------------------------------------------------------------
     *  ftpquit    Close FTP connection to remote host.
     *----------------------------------------------------------------

     C     ftpquit       begsr

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

     C     endftpquit    endsr

     *----------------------------------------------------------------
     *  loadexpfile   Load export file.
     *----------------------------------------------------------------

     C     loadexpfile   begsr
     C                   eval      error = *off

     *  Open data file.

     C                   exsr      openaptdata
     C     error         cabeq     *on           endload

     *  Loop through records to be exported.

     C                   eval      count = 0

750aAc                   if        $qCmd='*SENDT'
750aAC     keyap1        setll     aptdata1
750aAc                   else
     C     keyap2        setll     aptdata2
750aAc                   endif
     C                   dow       forever = forever

750aAc                   if        $qCmd='*SENDT'
750aAC     keyap1        reade     aptdata1
750aAc                   else
     C     keyap2        reade     aptdata2
750aAc                   endif
     C                   if        %eof
     *
     *    Update Route status to show mbr created successfully.
     C                   eval      kytype = '01'
     C                   exsr      getsarec
     *    Update Route status to show ready for export to P-Sys.
     C                   eval      pffsts = '1'
     C                   eval      pffmsg = stsmsg09
     C                   exsr      updrte
     *
     C                   leave
     C                   endif

     C                   eval      count = count + 1

     *    First time through, open file.

     C                   if        count = 1
     C                   exsr      openaptexp
     *
     *    Update FTP log with Host export file info.
     C                   if        $qcmd = '*SEND'
750aAC                             or $qcmd = '*SENDT'
     C                   eval      kytype = '01'
     C                   exsr      getsarec
     C                   eval      pfmbr  = expmbr
     C                   eval      pfexpf = expfile
     C                   exsr      updrte
     C                   endif
     *
     *    Update FTP log with export file info.
     C                   if        $qcmd = '*SEND'
750aAC                             or $qcmd = '*SENDT'
     C                             and ap_ftp = 'Y'
     C                   eval      kytype = '02'
     C                   exsr      getsarec
     C                   eval      pfmbr  = expmbr
     C                   eval      pfexpf = expfile
     C                   exsr      updrte
     C                   endif
     *
     C                   if        error
     *    Update FTP log with Host export file failure.
     C                   eval      kytype = '01'
     C                   exsr      getsarec
     C                   eval      pffsts = '3'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = $pmessage
     C                   exsr      updrte
     *
     *    Update FTP log with export file failure.
     C                   If        ap_ftp = 'Y'
     C                   eval      kytype = '02'
     C                   exsr      getsarec
     C                   eval      pffsts = '3'
     C                   eval      pflusr = #user
     C                   eval      pffmsg = $pmessage
     C                   exsr      updrte
     C                   Endif
     *
     C                   leave
     C                   endif
     C                   endif

     *    Write record to export file.

750aAc                   if        $qCmd <> '*SENDT'
740aAc                   eval      %subst(apexpdata:7:6)
740aAc                             = %editw(count:editw6nz)
750aAc                   endif
     C                   eval      axdata = apexpdata
     C                   write(e)  aptxrec

     *    Update record with export info.

     C                   eval      apexpfile = expfile
     C                   eval      apexpts   = currdatestamp
750aAc                   if        $qCmd='*SENDT'
750aAC                   update(e) aptrec1
750aAc                   else
     C                   update(e) aptrec
750aAc                   endif

     C                   enddo

     C     endload       endsr

     *----------------------------------------------------------------
     *  logerror    Log error
     *----------------------------------------------------------------

     C     logerror      begsr
     C                   endsr

     *----------------------------------------------------------------
     *  openaptdata   Open APTDATA1 file.
     *----------------------------------------------------------------

     C     openaptdata   begsr
     C                   eval      error = *off

750aAc                   if        $qCmd = '*SENDT'
750aAC                   if        not %open(aptdata1)
750aAC                   open(e)   aptdata1
750aAC                   if        %error
750aAC                   eval      error = *on
750aAC                   eval      $preturn  = '*ERROR'
750aAC                   eval      $pmessage = 'Error occured trying to '
750aAC                                       + 'open file APTDATA1'
750aAC                   goto      endopendata
750aAC                   endif
750aAC                   endif
750aAc                   endif

     C                   if        not %open(aptdata2)
     C                   open(e)   aptdata2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = '*ERROR'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open file APTDATA2'
     C                   goto      endopendata
     C                   endif
     C                   endif

     C     endopendata   endsr

     *----------------------------------------------------------------
     *  openaptexp  Open APTEXP file
     *----------------------------------------------------------------

     C     openaptexp    begsr
     C                   eval      error = *off

     * Create new member for export file.

     *   Create member name

650aAc                   if        expmbr = *blanks
     C                   select

     C                   when      tsmonth = '01'
     C                   eval      expmbr = 'JA'
     C                   when      tsmonth = '02'
     C                   eval      expmbr = 'FB'
     C                   when      tsmonth = '03'
     C                   eval      expmbr = 'MR'
     C                   when      tsmonth = '04'
     C                   eval      expmbr = 'AP'
     C                   when      tsmonth = '05'
     C                   eval      expmbr = 'MY'
     C                   when      tsmonth = '06'
     C                   eval      expmbr = 'JN'
     C                   when      tsmonth = '07'
     C                   eval      expmbr = 'JL'
     C                   when      tsmonth = '08'
     C                   eval      expmbr = 'AG'
     C                   when      tsmonth = '09'
     C                   eval      expmbr = 'SP'
     C                   when      tsmonth = '10'
     C                   eval      expmbr = 'OC'
     C                   when      tsmonth = '11'
     C                   eval      expmbr = 'NV'
     C                   when      tsmonth = '12'
     C                   eval      expmbr = 'DC'

     C                   endsl

650aDC*                  eval      expmbr = %trim(expmbr)
650aDC*                                   + %trim(#jobnbr)
650aDC*                                   + '00'
650aMC                   eval      expmbr = %trim(expmbr)
650aMC                                    + %trim(tsday)
650aMC                                    + '000001'
650aAc                   endif

     *   Call program to create member

     C                   call      'APTCRTMBR'
     C                   parm                    expmbr
     C                   parm                    $xreturn         10
     C                   parm                    $xmessage        60

     C                   if        $xreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $preturn = $xreturn
     C                   eval      $pmessage = $xmessage
     C                   goto      endopenexp
     C                   endif

     * Override export file member

     C                   eval      qcmd = 'OVRDBF FILE(APTEXP)  '
     C                                  + 'MBR('+%trim(expmbr)+') '
     C                   eval      qlen = %len(%trim(qcmd))
     C                   call      'QCMDEXC'
     C                   parm                    qcmd
     C                   parm                    qlen             15 5
     C                   eval      ovrdbf = *on

     * Open file.

     C                   open(e)   aptexp
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = '*ERROR'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open file APTEXP. '
     C                                       + expmbr
     C                   goto      endopenexp
     C                   endif

     C     endopenexp    endsr

**   Command array
crtdupobj obj(       ) fromlib(          ) objtype(*file) tolib(qtemp)
ovrdbf file(       ) tofile(qtemp/       )
dltf file(qtemp/       )
