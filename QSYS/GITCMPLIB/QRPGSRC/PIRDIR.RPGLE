     Hcopyright('(c) Copyright BFC Software, Inc - 2012')
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE')
     Hoption(*srcstmt : *nodebugio)
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PIRDIR    Process IFS Directory - Call Import Programs
     *  10 October 2006
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
510 A*    10/10/06  MLB  5.10
     *      - Created.
510aA*    11/07/06  MLB  5.10a
     *      - Enh: Added copy support to program to copy files to
     *        backup directory in addition to deleting them from
     *        directory being processed.
510bA*    11/10/06  MLB  5.10b
     *      - Enh: Added additional error message support to program.
     *        Warning messages will be sent to QSYSOPR message queue
     *        to better inform users of problems that ocur during
     *        import processing.
640aA*    11/20/12  RTR  6.40a
     *      - Enh: Changed to use customer processing for what import
     *        files to process.
     *
650 A*    01/29/13  MLB  6.50
     *      - Enh: Revised program to add support for FTP Import Item
     *        Updates Ver 4.
     *      - Enh: Revised program to add support for FTP Import Item
     *        Updates Ver 3 to routine PROCBASE.
650aA*    01/31/13  MLB  6.50a
     *      - Fix: Revised routine ZZPROCITEM3 ZZPROCITEM4 to remove
     *        requirement for semaphore flag file for file IMPFITMM.
650bA*    01/31/13  MLB  6.50b
     *      - Enh: Revised routine ZZPROCPO to remove goto that bypassed
     *        processing support for import file, IMPFPODM.
650cA*    01/31/13  MLB  6.50c
     *      - Fix: Revised routine ZZPROCPO to remove requirement for
     *        semaphore flag file for files IMPFPOHM, IMPFPODM.
650dA*    02/01/13  MLB  6.50d
     *      - Fix: Revised routine ZZCPYPO to remove requirement for
     *        semaphore flag file for files IMPFPOHM, IMPFPODM.
650eA*    02/13/13  RTR  6.50e
     *      - Fix: Added IMPFPODM to the PO delete subroutine. Removed
     *        semaphore delete for SIMPFPOHM, SIMPFPOD2, SIMPFPODM.
650fA*    02/15/13  MLB  6.50f
     *      - Fix: Revised program to issue closedir cmd for backup
     *        directory. Believe that may be partially to blame for
     *        CPFA0A4 - Too many files open for process error in
     *        PIRSBMCL.
650gA*    08/06/13  MLB  6.50g
     *      - Fix: Revised routine ZZPROCITEM4 to remove requirement for
     *        semaphore flag file for files IMPFITEMM.
     *
710 A*    05/04/17  MLB  7.10
     *      - Fix: Revised routine ZZPROCITEM4 to build correct file name
     *        when checking for IMPFITMM .txt file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions
     *
ASC A*    03/30/12  RTR  ASC
     *      - Added check for SAP files and call to processing program
     *----------------------------------------------------------------
     *  Client Custom Revisions: Get Fresh Sales
     *
GFS A*    01/31/13  MLB  GFS
     *      - Revised routine, ZZPROCPO2 to set file name length to 24
     *        from 23.  Get Fresh has company id code G/F included in
     *        file name to ensure files are unique per company.
GFSaA*    08/06/13  MLB  GFSa
     *      - Revised routine, ZZPROCITEM4 to set file name length to 10
     *        from 25.  Get Fresh has company id code G/F included in
     *        file name to ensure files are unique per company.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Foptions   if   e           k disk

     *----------------------------------------------------------------
     *  Notes
     *
     *    - Source code for this program courtesy of Scott Klement's
     *      Working with the IFS in RPG IV e-book.
     *
     *----------------------------------------------------------------
     *
     D/copy qcopysrc,c#ifsio_h
     D/copy qcopysrc,c#errno_h
     *
     *----------------------------------------------------------------
     *  *FTPIMP   -  FTP Import options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPIFTP  -  Use FTP for importing (Y,N)
     *    OPISRV  -  FTP Import Server name
     *    OPIUSR  -  FTP Import User id
     *    OPIPWD  -  FTP Import Password
     *    OPIPTH  -  Path for remote file
     *
     * Data structure
     *
     D opdata          ds
     D  opiftp                 1      1
     D  opisrv                 2     33
     D  opiusr                34     48
     D  opipwd                49     63
     D  opipth                64     95
     D  optend               117    117
     *
ASC AD CEEUTCO         PR                  ExtProc('CEEUTCO')
     D   hours                       10I 0
     D   minutes                     10I 0
     D   seconds                      8F
     *
ASC A*----------------------------------------------------------------
ASC A*  Customer id
ASC A*----------------------------------------------------------------
ASC A /copy qcopysrc,id#agar
640aA /copy qcopysrc,id#rfs
GFS A /copy qcopysrc,id#gfs
     *
     *----------------------------------------------------------------
     *  Message control
     *
     D                 ds
510bAD errdir                  1     32
510bAD errtxt                 33    128
510bMD errmsg                  1    128
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *
     D #msgf           c                   const('PIRMSGF   ')
     D $msgf           s             10
     D #msgid          s              7
     D #msgk           s              4
     D #msgkey         s              4  0
     D #msgtp          s              7
     D #pgmq           s             10
     *
     *----------------------------------------------------------------
     *  Working Variables
     *
     D error           S              1A   inz('0')
     D dir             s               *
510aAD dir_backup      s                   like(dir)
     D filefound       S              4A   inz('*NO ')
     D filename        S            640A
     D filenam1        S             40A
     D filenam2        S             40A
     D filenam3        S             40A
     D filenam4        S             40A
     D filenam5        S             40A
     D filenam6        S             40A
     D filesfx         S            640A
     D forever         S              1A   inz('1')
510aAD ifd             S             10I 0
510aAD iflags          S             10U 0
510aAD ilen            S             10I 0
     D len             S              3s 0 inz(0)
     D msg             S             52A
     D newpath         S            640A
510aAD out_fd          S             10I 0
510aAD out_flags       S             10U 0
510aAD out_mode        S             10U 0
     D $pauth          S             10A
     D $pcmd           S              8A
     D path            S            640A
     D path_backup     S            640A
     D $ppath          S            640A
     D $ppath1         S             80A
     D $ppath2         S             80A
     D $ppath3         S             80A
     D $ppath4         S             80A
     D $ppath5         S             80A
     D $ppath6         S             80A
     D $preturn        S              8A
     D $pwhse          S              3A   inz('000')
     D qcmd            S            640A
510aAD rddata          S            512A
     D submit          S              4A   inz('*YES')

ASC AD MyStat          S                   like(statds)
     D epoch           S               Z   inz(z'1970-01-01-00.00.00.000000')
     D modtime         S               Z
     D curtimstp       S               Z
     D hours_utc       s             10I 0
     D mins_utc        s             10I 0
     D secs_utc        s              8F
     D utcoffset       s             10I 0
     D xpos            S              3s 0 inz(0)

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------

     *      Find right most '/', strip to open directory.
     C                   eval      len = %checkr('/ ':opipth)
     C                   if        len = 0
     C                   eval      len    = 1
     C                   eval      opipth = '/'
     C                   endif

     *      Open directory sending path minus trailing '/'.
     C                   eval      dir = opendir(''
     C                                   + %trimr(%subst(opipth:1:len))
     C                                   + '')

510aA*      Open Import directory failed.
     C                   if        dir = *NULL
510bAC                   eval      error  = *on
510bAC                   eval      errmsg = opipth
510bAC                   eval      #pgmq  = 'QSYSOPR'
510bAC                   exsr      zm0139
     C                   endif

510aA*      Open backup directory.
510aAC                   if        error = *off
510aAC                   eval      dir_backup = opendir(''
510aAC                                            + %trimr(%subst(opipth:1:len))
510aAC                                            + '_backup'
510aAC                                            + '')
510aAC                   if        dir_backup = *NULL
510aA*      Create backup directory when it doesn't exist.
510aA*        Read, write, search permission given to user, group and others.
510aAC                   callp     mkdir('' + %trimr(%subst(opipth:1:len))
510aAC                                      + '_backup'
510aAC                                      + '':
510aAC                                      + s_irusr + s_iwusr + s_ixusr
510aAC                                      + s_irgrp + s_iwgrp + s_ixgrp
510aAC                                      + s_iroth + s_iwoth + s_ixoth)
510aAC                   if        dir_backup = *NULL
510bAC                   eval      errdir = %trimr(%subst(opipth:1:len))
510bAC                                      + '_backup'
510bAC                   eval      errtxt =   'CPE' + %trim(%editc(errno:'4'))
510bAC                                        + ' - '
510bAC                                        + %str(strerror(errno))
510bAC                   eval      #pgmq  = 'QSYSOPR'
510bAC                   exsr      zm0140
510aAC                   endif
510aAC                   endif
510aA*
510aA*      Create path to backup directory.
510aAC                   eval      path_backup = %trimr(%subst(opipth:1:len))
510aAC                                      + '_backup/'
510aAC                   endif


     * Process Directory looking for semaphore files.
510aAC                   if        error = *off
     C                   dow       forever = forever
     C                   eval      p_dirent = readdir(dir)
     C                   select
     C                   when      p_dirent = *null
     C                   leave
     C                   other
     *
     C                   eval      filename = %subst(d_name:1:d_namelen)
     *
640aA*      Process based on Customer
640aAC                   select
640aAC                   when      client = agar
640aAC                   exsr      ProcAgar
640aAC                   when      client = rfs
640aAC                   exsr      ProcReinhart
640aAC                   other
640aAC                   exsr      ProcBase
640aAC                   endsl
     *
     C                   endsl
     C                   enddo

     C                   callp     closedir(dir)
650fAC                   callp     closedir(dir_backup)
510aAC                   endif

     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     *   Retrieve Import Options record.
     C                   exsr      zzgetop
     *
     *   Define full key for OPTIONS file
     *
     C     keyop         klist
     C                   kfld                    opwhse
     C                   kfld                    opcode
     *
     C                   endsr
640aA*
640aA*----------------------------------------------------------------
640aA*    ProcAgar - Process files for Agar
640aA*
640aAC     ProcAgar      begsr
ASC A*
ASC A*        For Agar, look for SAP files and process.
ASC AC                   select
ASC AC                   when         %subst(d_name:1:2) = 'O_'
ASC AC                   exsr      zzprocsap
ASC AC                   endsl
640aAC                   endsr
     *
     *----------------------------------------------------------------
     *    ProcBase - Process for base Import files
     *
     C     ProcBase      begsr

     C                   select
     *      Select only Main Semaphore file for Each Import Group.
     C                   when         %subst(d_name:1:9) = 'SIMPFITMN'
     C                   exsr      zzprocitem
650 A*
650 AC                   when      %subst(d_name:1:9) = 'SIMPFITM3'
650 AC                             or %subst(d_name:1:9) = 'simpfitm3'
650 AC                   if        %subst(d_name:10:1) = 'F'
650 AC                             or %subst(d_name:10:1) = 'f'
650 AC                   eval      $pcmd = '*ITM3FUL'
650 AC                   else
650 AC                   eval      $pcmd = '*ITM3PAR'
650 AC                   endif
650 AC                   eval      xpos = 25
650 AC                   exsr      zzprocitem3
650 A*
650 AC                   when      %subst(d_name:1:9) = 'SIMPFITM4'
650 AC                             or %subst(d_name:1:9) = 'simpfitm4'
650 AC                   if        %subst(d_name:10:1) = 'F'
650 AC                             or %subst(d_name:10:1) = 'f'
650 AC                   eval      $pcmd = '*ITM4FUL'
650 AC                   else
650 AC                   eval      $pcmd = '*ITM4PAR'
650 AC                   endif
GFSaAC                   if        client = Getfresh
GFSaAC                   eval      xpos = 10
GFSaAC                   else
650 AC                   eval      xpos = 25
GFSaAC                   endif
650 AC                   exsr      zzprocitem4
     *
     C                   when         %subst(d_name:1:9) = 'SIMPFPOH2'
     C                   exsr      zzprocpo
     *
     C                   when         %subst(d_name:1:9) = 'SIMPFORDH'
     C                   exsr      zzprocord
     *
     C                   endsl
     *
     C                   endsr
640aA*
640aA*----------------------------------------------------------------
640aA*    ProcReinhart - Process files for Reinhart
640aA*
640aAC     ProcReinhart  begsr
640aA*
640aAC                   select
640aA*
640aAC                   when      %subst(d_name:1:9) = 'SIMPFITM3'
640aAC                             or %subst(d_name:1:9) = 'simpfitm3'
640aAC                   if        %subst(d_name:10:1) = 'F'
640aAC                             or %subst(d_name:10:1) = 'f'
640aAC                   eval      $pcmd = '*ITM3FUL'
640aAC                   else
640aAC                   eval      $pcmd = '*ITM3PAR'
640aAC                   endif
640aAC                   eval      xpos = 25
640aAC                   exsr      zzprocitem3
640aA*
640aAC                   when      %subst(d_name:1:10) = 'SIMPFSTUF3'
640aAC                             or %subst(d_name:1:10) = 'simpfstuf3'
640aAC                   if        %subst(d_name:11:1) = 'F'
640aAC                             or %subst(d_name:11:1) = 'f'
640aAC                   eval      $pcmd = '*SLOT3F '
640aAC                   else
640aAC                   eval      $pcmd = '*SLOT3P '
640aAC                   endif
640aAC                   eval      xpos = 26
640aAC                   exsr      zzprocslot3
640aA*
640aAC                   when      %subst(d_name:1:9) = 'SIMPFORDH'
640aAC                             or %subst(d_name:1:9) = 'simpfordh'
640aAC                   eval      xpos = 25
640aAC                   exsr      zzprocord5
640aA*
640aAC                   endsl
640aA*
640aAC                   endsr
     *
     *----------------------------------------------------------------
     *      0105  - Generic message id (50 character data field)
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *
     *----------------------------------------------------------------
     *      0125  - Import Item Update file missing.
     *
     C     zm0125        begsr
     C                   eval      #msgid = 'PIR0125'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *
     *----------------------------------------------------------------
     *      0126  - Import P/O Header file missing.
     *
     C     zm0126        begsr
     C                   eval      #msgid = 'PIR0126'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *
     *----------------------------------------------------------------
     *      0127  - Import P/O Detail file missing.
     *
     C     zm0127        begsr
     C                   eval      #msgid = 'PIR0127'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *
     *----------------------------------------------------------------
     *      0128  - Import Customer Order Hdr file missing.
     *
     C     zm0128        begsr
     C                   eval      #msgid = 'PIR0128'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *
     *----------------------------------------------------------------
     *      0129  - Import Customer Order Dtl file missing.
     *
     C     zm0129        begsr
     C                   eval      #msgid = 'PIR0129'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *
     *----------------------------------------------------------------
     *      0130  - Import Item Misc. Update file missing.
     *
     C     zm0130        begsr
     C                   eval      #msgid = 'PIR0130'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *
     *----------------------------------------------------------------
     *      0131  - Import P/O Hdr Misc. file missing.
     *
     C     zm0131        begsr
     C                   eval      #msgid = 'PIR0131'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *
     *----------------------------------------------------------------
     *      0132  - Import P/O Detail Misc. file missing.
     *
     C     zm0132        begsr
     C                   eval      #msgid = 'PIR0132'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *
     *----------------------------------------------------------------
     *      0133  - Import Customer Order Hdr Misc. file missing.
     *
     C     zm0133        begsr
     C                   eval      #msgid = 'PIR0133'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *
     *----------------------------------------------------------------
     *      0134  - Import Customer Order Dtl Misc. file missing.
     *
     C     zm0134        begsr
     C                   eval      #msgid = 'PIR0134'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *
     *----------------------------------------------------------------
     *      0135  - Error copying files for Item Update.
     *
     C     zm0135        begsr
     C                   eval      #msgid = 'PIR0135'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *
     *----------------------------------------------------------------
     *      0136  - Error copying files for P/O Update.
     *
     C     zm0136        begsr
     C                   eval      #msgid = 'PIR0136'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *
     *----------------------------------------------------------------
     *      0137  - Error copying files for Customer Order Update.
     *
     C     zm0137        begsr
     C                   eval      #msgid = 'PIR0137'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *
     *----------------------------------------------------------------
     *      0138  - Error deleting files. Manual cleanup required.
     *
     C     zm0138        begsr
     C                   eval      #msgid = 'PIR0138'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *
     *----------------------------------------------------------------
     *      0139  - Import Directory not found. Import processing canceled.
     *
     C     zm0139        begsr
     C                   eval      #msgid = 'PIR0139'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *
     *----------------------------------------------------------------
     *      0140  - Create Backup Directory failed. Processing continues.
     *
     C     zm0140        begsr
     C                   eval      #msgid = 'PIR0140'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZMPMSG  Send Message to FTP Import Message Queues.
     *
     C     zmpmsg        begsr
     *
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     *
     C                   eval      #msgkey = #msgkey + 1
     C                   eval      #msgk   = %editc(#msgkey:'X')
     *
     C                   call      'PUTMSGE'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
     *
     C                   endsr
510aA*
510aA*----------------------------------------------------------------
510aA*
510aA*  ZZCPYITEM  Copy Import Item files to Backup Directory.
510aA*
510aAC     zzcpyitem     begsr
510aA*
510aA*      Setup flags, mode for Reading/Writing data to backup directory.
510aA*
510aAc                   eval      iflags    =   o_rdonly
510aAc                   eval      out_flags =   O_wronly + o_creat + o_trunc
510aAc                                         + o_codepage
510aAc                   eval      out_mode  =   s_irusr + s_iwusr
510aAc                                         + s_irgrp + s_iroth
510aA
510aA
510aA*      Load path to IMPFITMN file.
510aAc                   eval      path      = $ppath1
510aA
510aA*      Create path to Backup IMPFITMN file.
510aAC                   eval      newpath = %trim(path_backup)
510aAC                                       + %trim(filenam1)
510aAC                                       + filesfx
510aAc                   exsr      zzcopy
510aA
510aA
510aA*      Create path to semaphore IMPFITMN file.
510aAC                   eval      path = %trim(opipth)
510aAC                                    + 'S'
510aAC                                    + %trim(filenam1)
510aAC                                    + filesfx
510aA
510aA*      Create path to Backup semaphore IMPFITMN file.
510aAC                   eval      newpath = %trim(path_backup)
510aAC                                       + 'S'
510aAC                                       + %trim(filenam1)
510aAC                                       + filesfx
510aAc                   exsr      zzcopy
510aA
510aA
510aA*      Process Import Item Updates Misc. file.
510aAC                   if        $ppath2 > ' '
510aA*
510aA*      Load path to IMPFITMM file.
510aAc                   eval      path      = $ppath2
510aA
510aA*      Create path to Backup IMPFITMM file.
510aAC                   eval      newpath = %trimr(path_backup)
510aAC                                       + %trim(filenam2)
510aAC                                       + filesfx
510aAc                   exsr      zzcopy
510aA
650gD*      Create path to semaphore IMPFITMM file.
650gDC*                  eval      path = %trim(opipth)
650gDC*                                   + 'S'
650gDC*                                   + %trim(filenam2)
650gDC*                                   + filesfx
510aA
650gD*      Create path to Backup semaphore IMPFITMM file.
650gDC*                  eval      newpath = %trim(path_backup)
650gDC*                                      + 'S'
650gDC*                                      + %trim(filenam2)
650gDC*                                      + filesfx
650gDc*                  exsr      zzcopy
510aAC                   endif
510aA*
510aAC                   endsr
510aA*
510aA*----------------------------------------------------------------
510aA*
510aA*  ZZCPYORDER    Copy Import Order files to Backup Directory.
510aA*
510aAC     zzcpyorder    begsr
510aA*
510aA*      Setup flags, mode for Reading/Writing data to backup directory.
510aA*
510aAc                   eval      iflags    =   o_rdonly
510aAc                   eval      out_flags =   O_wronly + o_creat + o_trunc
510aAc                                         + o_codepage
510aAc                   eval      out_mode  =   s_irusr + s_iwusr
510aAc                                         + s_irgrp + s_iroth
510aA
510aA*      Load path to IMPFORDH file.
510aAc                   eval      path      = $ppath1
510aA
510aA*      Create path to Backup IMPFORDH file.
510aAC                   eval      newpath = %trim(path_backup)
510aAC                                       + %trim(filenam1)
510aAC                                       + filesfx
510aAc                   exsr      zzcopy
510aA
510aA*      Create path to semaphore IMPFORDH file.
510aAC                   eval      path = %trim(opipth)
510aAC                                    + 'S'
510aAC                                    + %trim(filenam1)
510aAC                                    + filesfx
510aA
510aA*      Create path to Backup semaphore IMPFORDH file.
510aAC                   eval      newpath = %trim(path_backup)
510aAC                                       + 'S'
510aAC                                       + %trim(filenam1)
510aAC                                       + filesfx
510aAc                   exsr      zzcopy
510aA
510aA*      Process Import Order Header Misc. file.
510aAC                   if        $ppath2 > ' '
510aA*
510aA*      Load path to IMPFORDHM file.
510aAc                   eval      path      = $ppath2
510aA
510aA*      Create path to Backup IMPFORDHM file.
510aAC                   eval      newpath = %trimr(path_backup)
510aAC                                       + %trim(filenam2)
510aAC                                       + filesfx
510aAc                   exsr      zzcopy
510aA
510aA
510aA*      Create path to semaphore IMPFORDHM file.
510aAC                   eval      path = %trim(opipth)
510aAC                                    + 'S'
510aAC                                    + %trim(filenam2)
510aAC                                    + filesfx
510aA
510aA*      Create path to Backup semaphore IMPFORDHM file.
510aAC                   eval      newpath = %trim(path_backup)
510aAC                                       + 'S'
510aAC                                       + %trim(filenam2)
510aAC                                       + filesfx
510aAc                   exsr      zzcopy
510aAC                   endif
510aA
510aA
510aA*      Load path to IMPFORDD file.
510aAc                   eval      path      = $ppath3
510aA
510aA*      Create path to Backup IMPFORDD file.
510aAC                   eval      newpath = %trim(path_backup)
510aAC                                       + %trim(filenam3)
510aAC                                       + filesfx
510aAc                   exsr      zzcopy
510aA
510aA
510aA*      Create path to semaphore IMPFORDD file.
510aAC                   eval      path = %trim(opipth)
510aAC                                    + 'S'
510aAC                                    + %trim(filenam3)
510aAC                                    + filesfx
510aA
510aA*      Create path to Backup semaphore IMPFORDD file.
510aAC                   eval      newpath = %trim(path_backup)
510aAC                                       + 'S'
510aAC                                       + %trim(filenam3)
510aAC                                       + filesfx
510aAc                   exsr      zzcopy
510aA
510aA
510aA*      Process Import Order Detail Misc. file.
510aAC                   if        $ppath4 > ' '
510aA*
510aA*      Load path to IMPFORDDM file.
510aAc                   eval      path      = $ppath4
510aA
510aA*      Create path to Backup IMPFORDDM file.
510aAC                   eval      newpath = %trimr(path_backup)
510aAC                                       + %trim(filenam4)
510aAC                                       + filesfx
510aAc                   exsr      zzcopy
510aA
510aA*      Create path to semaphore IMPFORDDM file.
510aAC                   eval      path = %trim(opipth)
510aAC                                    + 'S'
510aAC                                    + %trim(filenam4)
510aAC                                    + filesfx
510aA
510aA*      Create path to Backup semaphore IMPFORDDM file.
510aAC                   eval      newpath = %trim(path_backup)
510aAC                                       + 'S'
510aAC                                       + %trim(filenam4)
510aAC                                       + filesfx
510aAc                   exsr      zzcopy
510aAC                   endif
510aA*
510aAC                   endsr
640aA*
640aA*----------------------------------------------------------------
640aA*
640aA*  ZZCPYORDER5   Copy Import Order files to Backup Directory.
640aA*
640aAC     zzcpyorder5   begsr
640aA*
640aA*      Setup flags, mode for Reading/Writing data to backup directory.
640aA*
640aAc                   eval      iflags    =   o_rdonly
640aAc                   eval      out_flags =   O_wronly + o_creat + o_trunc
640aAc                                         + o_codepage
640aAc                   eval      out_mode  =   s_irusr + s_iwusr
640aAc                                         + s_irgrp + s_iroth
640aA
640aA*      Load path to File 1.
640aAc                   eval      path      = $ppath1
640aA*      Create path to Backup File 1.
640aAC                   eval      newpath = %trim(path_backup)
640aAC                                       + %trim(filenam1)
640aAC                                       + filesfx
640aAc                   exsr      zzcopy
640aA*
640aA*      Create path to semaphore File 1.
640aAC                   eval      path = %trim(opipth)
640aAC                                    + 'S'
640aAC                                    + %trim(filenam1)
640aAC                                    + filesfx
640aA*      Create path to Backup semaphore File 1.
640aAC                   eval      newpath = %trim(path_backup)
640aAC                                       + 'S'
640aAC                                       + %trim(filenam1)
640aAC                                       + filesfx
640aAc                   exsr      zzcopy
640aA
640aA*      Process File 2.
640aAC                   if        $ppath2 > ' '
640aA*        Load path to File 2.
640aAc                   eval      path      = $ppath2
640aA*        Create path to File 2.
640aAC                   eval      newpath = %trimr(path_backup)
640aAC                                       + %trim(filenam2)
640aAC                                       + filesfx
640aAc                   exsr      zzcopy
640aAC                   endif
640aA
640aA*      Process File 3.
640aAC                   if        $ppath3 > ' '
640aA*        Load path to File 3.
640aAc                   eval      path      = $ppath3
640aA*        Create path to Backup File 3.
640aAC                   eval      newpath = %trim(path_backup)
640aAC                                       + %trim(filenam3)
640aAC                                       + filesfx
640aAc                   exsr      zzcopy
640aAC                   endif
640aA
640aA*      Process File 4.
640aAC                   if        $ppath4 > ' '
640aA*        Load path to File 4.
640aAc                   eval      path      = $ppath4
640aA*        Create path to Backup File 4.
640aAC                   eval      newpath = %trimr(path_backup)
640aAC                                       + %trim(filenam4)
640aAC                                       + filesfx
640aAc                   exsr      zzcopy
640aAC                   endif
640aA*
640aAC                   endsr
510aA*
510aA*----------------------------------------------------------------
ASC A*
ASC A*  ZZCPYSAP      Copy SAP Import Order file to Backup Directory.
ASC A*
ASC AC     zzcpysap      begsr
ASC A*
ASC A*      Setup flags, mode for Reading/Writing data to backup directory.
ASC A*
ASC Ac                   eval      iflags    =   o_rdonly
ASC Ac                   eval      out_flags =   O_wronly + o_creat + o_trunc
ASC Ac                                         + o_codepage
ASC Ac                   eval      out_mode  =   s_irusr + s_iwusr
ASC Ac                                         + s_irgrp + s_iroth
ASC A
ASC A*      Load path to SAP file.
ASC Ac                   eval      path      = $ppath1
ASC A
ASC A*      Create path to Backup SAP file.
ASC AC                   eval      newpath = %trim(path_backup)
ASC AC                                       + %trim(filename)
ASC Ac                   exsr      zzcopy
ASC A*
ASC AC                   endsr
510aA*
510aA*----------------------------------------------------------------
510aA*
510aA*  ZZCPYPO    Copy Import P/O files to Backup Directory.
510aA*
510aAC     zzcpypo       begsr
510aA*
510aA*      Setup flags, mode for Reading/Writing data to backup directory.
510aA*
510aAc                   eval      iflags    =   o_rdonly
510aAc                   eval      out_flags =   O_wronly + o_creat + o_trunc
510aAc                                         + o_codepage
510aAc                   eval      out_mode  =   s_irusr + s_iwusr
510aAc                                         + s_irgrp + s_iroth
510aA
510aA
510aA*      Load path to IMPFPOH2 file.
510aAc                   eval      path      = $ppath1
510aA
510aA*      Create path to Backup IMPFPOH2 file.
510aAC                   eval      newpath = %trim(path_backup)
510aAC                                       + %trim(filenam1)
510aAC                                       + filesfx
510aAc                   exsr      zzcopy
510aA
510aA*      Create path to semaphore IMPFPOH2 file.
510aAC                   eval      path = %trim(opipth)
510aAC                                    + 'S'
510aAC                                    + %trim(filenam1)
510aAC                                    + filesfx
510aA
510aA*      Create path to Backup semaphore IMPFPOH2 file.
510aAC                   eval      newpath = %trim(path_backup)
510aAC                                       + 'S'
510aAC                                       + %trim(filenam1)
510aAC                                       + filesfx
510aAc                   exsr      zzcopy
510aA
510aA
510aA*      Process Import P/O Header Misc. file.
510aAC                   if        $ppath2 > ' '
510aA*
510aA*      Load path to IMPFPOHM file.
510aAc                   eval      path      = $ppath2
510aA
510aA*      Create path to Backup IMPFPOHM file.
510aAC                   eval      newpath = %trimr(path_backup)
510aAC                                       + %trim(filenam2)
510aAC                                       + filesfx
510aAc                   exsr      zzcopy
510aA
510aA
650dD*      Create path to semaphore IMPFPOHM file.
650dDC*                  eval      path = %trim(opipth)
650dDC*                                   + 'S'
650dDC*                                   + %trim(filenam2)
650dDC*                                   + filesfx
510aA
650dD*      Create path to Backup semaphore IMPFPOHM file.
650dDC*                  eval      newpath = %trim(path_backup)
650dDC*                                      + 'S'
650dDC*                                      + %trim(filenam2)
650dDC*                                      + filesfx
650dDc*                  exsr      zzcopy
510aAC                   endif
510aA
510aA
510aA*      Load path to IMPFPOD2 file.
510aAc                   eval      path      = $ppath3
510aA
510aA*      Create path to Backup IMPFPOD2 file.
510aAC                   eval      newpath = %trim(path_backup)
510aAC                                       + %trim(filenam3)
510aAC                                       + filesfx
510aAc                   exsr      zzcopy
510aA
510aA
650dD*      Create path to semaphore IMPFPOD2 file.
650dDC*                  eval      path = %trim(opipth)
650dDC*                                   + 'S'
650dDC*                                   + %trim(filenam3)
650dDC*                                   + filesfx
510aA
650dD*      Create path to Backup semaphore IMPFPOD2 file.
650dDC*                  eval      newpath = %trim(path_backup)
650dDC*                                      + 'S'
650dDC*                                      + %trim(filenam3)
650dDC*                                      + filesfx
650dDc*                  exsr      zzcopy
510aA
510aA
510aA*      Process Import P/O Detail Misc. file.
510aAC                   if        $ppath4 > ' '
510aA*
510aA*      Load path to IMPFPODM file.
510aAc                   eval      path      = $ppath4
510aA
510aA*      Create path to Backup IMPFPODM file.
510aAC                   eval      newpath = %trimr(path_backup)
510aAC                                       + %trim(filenam4)
510aAC                                       + filesfx
510aAc                   exsr      zzcopy
510aA
650dD*      Create path to semaphore IMPFPODM file.
650dDC*                  eval      path = %trim(opipth)
650dDC*                                   + 'S'
650dDC*                                   + %trim(filenam4)
650dDC*                                   + filesfx
510aA
650dD*      Create path to Backup semaphore IMPFPODM file.
650dDC*                  eval      newpath = %trim(path_backup)
650dDC*                                      + 'S'
650dDC*                                      + %trim(filenam4)
650dDC*                                      + filesfx
650dDc*                  exsr      zzcopy
510aAC                   endif
510aA*
510aAC                   endsr
510aA*
510aA*----------------------------------------------------------------
510aA*
510aA*  ZZCOPY        Copy Import files to Directory Backup.
510aA*
510aAC     zzcopy        begsr
510aA
510aA*      Open Import Data file.
510aAc                   eval      iflags    =   o_rdonly
510aAc                   eval      ifd = open(%trimr(path):iflags)
510aAc                   if        ifd < 0
510aAC                   callp     die('opendir(): '+%str(strerror(errno)))
510aAc*                     some kind of error message.....
510aAc                   endif
510aA
510aA*      Create a new file, and assign it a code page of 819:
510aAc                   eval      out_fd = open(%trimr(newpath)
510aAc                                      :out_flags
510aAc                                      :out_mode:819)
510aAc                   if        out_fd < 0
510aAC                   callp     die('opendir(): '+%str(strerror(errno)))
510aAc*                     some kind of error message.....
510aAc                   endif
510aA*
510aAC                   dow       forever = forever
510aAc                   eval      ilen = read(ifd: %addr(rddata):
510aAc                                            %size(rddata))
510aAC                   select
      *
510aAC                   when      ilen <= 0
ASC A*      Close Import Data file opened for read.
ASC Ac                   callp     close(ifd)
ASC A*      Close Import Data file copy opened for write.
ASC Ac                   callp     close(out_fd)
510aAC                   leave
      *
510aAC                   other
510aAc                   callp     write(out_fd: %addr(rddata): ilen)
510aAC                   endsl
510aA
510aAC                   enddo
510aA
510aA*      Close Import Data file opened for read.
510aAc                   callp     close(ifd)
510aA*      Close Import Data file copy opened for write.
510aAc                   callp     close(out_fd)
510aA*
510aAC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZDLTITEM  Delete Item File from Directory after good completion.
     *
     C     zzdltitem     begsr
     *
     C                   eval      #pgmq  = 'IMPITEM'
     *
     *      Delete IMPFITMN file
     C                   eval      path = $ppath1
     C                   exsr      zzunlink
     *
     *      Delete Semaphore file for IMPFITMN.
     C                   eval      path = %trim(opipth)
     C                                    + 'S'
     C                                    + %trim(filenam1)
     C                                    + filesfx
     C                   exsr      zzunlink
     *
     *      Delete IMPFITMM file if sent.
     C                   if        $ppath2 > ' '
     C                   eval      path = $ppath2
     C                   exsr      zzunlink
     *
650gD*      Delete Semaphore file for IMPFITMM.
650gDC*                  eval      path = %trim(opipth)
650gDC*                                   + 'S'
650gDC*                                   + %trim(filenam2)
650gDC*                                   + filesfx
650gDC*                  exsr      zzunlink
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZDLTORDER  Delete Order Files from Directory after good completion.
     *
     C     zzdltorder    begsr
     *
     C                   eval      #pgmq  = 'IMPORD '
     *
     *      Delete IMPFORDH file
     C                   eval      path = $ppath1
     C                   exsr      zzunlink
     *
     *      Delete Semaphore file for IMPFORDH.
     C                   eval      path = %trim(opipth)
     C                                    + 'S'
     C                                    + %trim(filenam1)
     C                                    + filesfx
     C                   exsr      zzunlink
     *
     *      Delete IMPFORDHM file if sent.
     C                   if        $ppath2 > ' '
     C                   eval      path = $ppath2
     C                   exsr      zzunlink
     *
     *      Delete Semaphore file for IMPFORDHM.
     C                   eval      path = %trim(opipth)
     C                                    + 'S'
     C                                    + %trim(filenam2)
     C                                    + filesfx
     C                   exsr      zzunlink
     C                   endif
     *
     *      Delete IMPFORDD file if sent.
     C                   eval      path = $ppath3
     C                   exsr      zzunlink
     *
     *      Delete Semaphore file for IMPFORDD.
     C                   eval      path = %trim(opipth)
     C                                    + 'S'
     C                                    + %trim(filenam3)
     C                                    + filesfx
     C                   exsr      zzunlink
     *
     *      Delete IMPFORDM file if sent.
     C                   if        $ppath4 > ' '
     C                   eval      path = $ppath4
     C                   exsr      zzunlink
     *
     *      Delete Semaphore file for IMPFORDM.
     C                   eval      path = %trim(opipth)
     C                                    + 'S'
     C                                    + %trim(filenam4)
     C                                    + filesfx
     C                   exsr      zzunlink
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZDLTPO    Delete P/O Files from Directory after good completion.
     *
     C     zzdltpo       begsr
     *
     C                   eval      #pgmq  = 'IMPPO  '
     *
     *      Delete IMPFPOH2 file
     C                   eval      path = $ppath1
     C                   exsr      zzunlink
     *
     *      Delete Semaphore file for IMPFPOH2.
     C                   eval      path = %trim(opipth)
     C                                    + 'S'
     C                                    + %trim(filenam1)
     C                                    + filesfx
     C                   exsr      zzunlink
     *
     *      Delete IMPFPOHM file if sent.
     C                   if        $ppath2 > ' '
     C                   eval      path = $ppath2
     C                   exsr      zzunlink
     *
     *      Delete Semaphore file for IMPFPOHM.
650eDC*                  eval      path = %trim(opipth)
650eDC*                                   + 'S'
650eDC*                                   + %trim(filenam2)
650eDC*                                   + filesfx
650eDC*                  exsr      zzunlink
650eDC                   endif
     *
     *      Delete IMPFPOD2 file if sent.
650eAC                   if        $ppath3 <> *blanks
     C                   eval      path = $ppath3
     C                   exsr      zzunlink
     *
     *      Delete Semaphore file for IMPFPOD2.
650eDC*                  eval      path = %trim(opipth)
650eDC*                                   + 'S'
650eDC*                                   + %trim(filenam3)
650eDC*                                   + filesfx
650eDC*                  exsr      zzunlink
650eAC                   endif
650eA*
650eA*      Delete IMPFPODM file if sent.
650eAC                   if        $ppath4 <> *blanks
650eAC                   eval      path = $ppath4
650eAC                   exsr      zzunlink
650eAC                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZDLTSAP  Delete SAP File from Directory after good completion.
     *
     C     zzdltsap      begsr
     *
     C                   eval      #pgmq  = 'SAPORD '
     *
     *      Delete SAPORD_* file
     C                   eval      path = $ppath1
     C                   exsr      zzunlink
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGETOP  Get Import Options Record.
     *
     C     zzgetop       begsr
     *
     C                   eval      opwhse = 0
     C                   eval      opcode = '*FTPIMP '
     *
     C     keyop         chain     options
     C                   select
     C                   when      not %found(options)
     C                   eval      opisrv = ' '
     C                   eval      opipth = ' '
     C                   eval      opiftp = 'N'
     C                   eval      opiusr = ' '
     C                   eval      opipwd = ' '
     C                   endsl
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCKIFSOBJ  Check for existance of IDS object.
     *
     C     zzckifsobj    begsr
     *
     C                   call (e)  'CHKIFSOBJ'
     C                   parm      path          $ppath
     C                   parm      ' '           $pauth
     *
     C                   if        %error
     C                   eval      filefound = '*NO '
     C                   else
     C                   eval      filefound = '*YES'
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZPROCITEM  Process file extracted from directory
     *
     C     zzprocitem    begsr
     *
     *      Initialize path / file fields.
     C                   eval      #pgmq    = 'IMPITEM'
     C                   eval      $pcmd    = '*ITEM2  '
     C                   eval      submit   = '*YES'
     C                   eval      $ppath1  = ' '
     C                   eval      $ppath2  = ' '
     C                   eval      $ppath3  = ' '
     C                   eval      $ppath4  = ' '
     C                   eval      $ppath5  = ' '
     C                   eval      $ppath6  = ' '
     C                   eval      filenam1 = ' '
     C                   eval      filenam2 = ' '
     C                   eval      filenam3 = ' '
     C                   eval      filenam4 = ' '
     C                   eval      filenam5 = ' '
     C                   eval      filenam6 = ' '
     *
     *-------------------------------------------------------------------
     *      Process Import Item Updates.
     C                   eval      filenam1 = %subst(filename:2:8)
     C                   eval      filenam2 = 'IMPFITMM'
     C                   eval      filesfx  = %subst(filename:10:%len(filename)
     C                                        - 10)
     *
     *        Verify file is found in directory.
     C                   eval      path = %trim(opipth)
     C                                    + %trim(filenam1)
     C                                    + filesfx
     C                   exsr      zzckifsobj
     *
     *        Primary file found in directory. Continue processing.
     C                   if        filefound = '*YES'
     C                   eval      $ppath1 = path
     C                   else
     *        Terminal Error - Primary file not found. Cancel processing.
     C                   eval      submit = '*NO '
     C                   eval      errmsg = path
     C                   exsr      zm0125
     *        Rename semaphore file to prevent file from being processed
     *        over and over again.
     C                   eval      path = %trim(opipth)
     C                                    + %trim(filename)
     C                   eval      newpath = %trim(opipth)
     C                                    + 'Err_'
     C                                    + %trim(filename)
     C                   exsr      zzrename
     C                   endif
     *
     *        Check if semaphore file IMPFITMM is found in directory.
     C                   eval      path = %trim(opipth)
     C                                    + 'S'
     C                                    + %trim(filenam2)
     C                                    + filesfx
     C                   exsr      zzckifsobj

     C                   if        filefound = '*YES'
     *        Check if file IMPFITMM is found in directory.
     C                   eval      path = %trim(opipth)
     C                                    + %trim(filenam2)
     C                                    + filesfx
     C                   exsr      zzckifsobj

     C                   if        filefound = '*YES'
     C                   eval      $ppath2 = path
     C                   else
     *
     *        File IMPFITMM not found. Not okay to import.
     C                   eval      submit = '*NO '
     C                   eval      errmsg = path
     C                   exsr      zm0130
     C                   endif
     *
     C                   endif
     *
     C                   select
     *      File(s) found to submit import job for processing.
     C                   when      submit = '*YES'
     *
     *        File(s) found to submit import job for processing.
     C                   exsr      zzsbmimp
     *        Job submitted to batch successfully.
     C                   if        $preturn = '*OK'
510aA
510aA*          Copy import files to Backup Directory.
510aAC                   exsr      zzcpyitem
510aA*
     C                   exsr      zzdltitem
     C                   else
     *        Error(s) submitting job to batch for processing.
     C                   eval      errmsg = filename
     C                   exsr      zm0135
     *        Rename semaphore file to prevent file from being processed
     *        over and over again.
     C                   eval      path = %trim(opipth)
     C                                    + %trim(filename)
     C                   eval      newpath = %trim(opipth)
     C                                    + 'Err_'
     C                                    + %trim(filename)
     C                   exsr      zzrename
     C                   endif
     *
     C                   endsl
     *
     C                   endsr
640aA*
640aA*----------------------------------------------------------------
640aA*
640aA*  ZZPROCITEM3  Process file extracted from directory
640aA*
640aAC     zzprocitem3   begsr
640aA*
640aA*      Initialize path / file fields.
640aAC                   eval      #pgmq    = 'IMPITEM'
640aAC                   eval      submit   = '*YES'
640aAC                   eval      $ppath1  = ' '
640aAC                   eval      $ppath2  = ' '
640aAC                   eval      $ppath3  = ' '
640aAC                   eval      $ppath4  = ' '
640aAC                   eval      $ppath5  = ' '
640aAC                   eval      $ppath6  = ' '
640aAC                   eval      filenam1 = ' '
640aAC                   eval      filenam2 = ' '
640aAC                   eval      filenam3 = ' '
640aAC                   eval      filenam4 = ' '
640aAC                   eval      filenam5 = ' '
640aAC                   eval      filenam6 = ' '
640aA*
640aA*      Process Import Item Updates.
640aAC                   eval      filenam1 = %subst(filename:2:xpos-2)
640aAC                   eval      filenam2 = 'IMPFITMM'
640aAC                   eval      filesfx = %subst(filename:xpos:%len(filename)
640aAC                                       - xpos)
640aA*
640aA*        Verify file is found in directory.
640aAC                   eval      path = %trim(opipth)
640aAC                                    + %trim(filenam1)
640aAC                                    + filesfx
640aAC                   exsr      zzckifsobj
640aA*
640aA*        Primary file found in directory. Continue processing.
640aAC                   if        filefound = '*YES'
640aAC                   eval      $ppath1 = path
640aAC                   else
640aA*        Terminal Error - Primary file not found. Cancel processing.
640aAC                   eval      submit = '*NO '
640aAC                   eval      errmsg = path
640aAC                   exsr      zm0125
640aA*        Rename semaphore file to prevent file from being processed
640aA*        over and over again.
640aAC                   eval      path = %trim(opipth)
640aAC                                    + %trim(filename)
640aAC                   eval      newpath = %trim(opipth)
640aAC                                    + 'Err_'
640aAC                                    + %trim(filename)
640aAC                   exsr      zzrename
640aAC                   endif
640aA*
640aA*        Check if semaphore file IMPFITMM is found in directory.
650aDC*                  eval      path = %trim(opipth)
650aDC*                                   + 'S'
650aDC*                                   + %trim(filenam2)
650aDC*                                   + filesfx
650aDC*                  exsr      zzckifsobj
640aA
650aDC*                  if        filefound = '*YES'
640aA*        Check if file IMPFITMM is found in directory.
640aAC                   eval      path = %trim(opipth)
640aAC                                    + %trim(filenam2)
640aAC                                    + filesfx
640aAC                   exsr      zzckifsobj
640aA
640aAC                   if        filefound = '*YES'
640aAC                   eval      $ppath2 = path
650aDC*                  else
650aMC                   endif
640aA*
650aD*        File IMPFITMM not found. Not okay to import.
650aDC*                  eval      submit = '*NO '
650aDC*                  eval      errmsg = path
650aDC*                  exsr      zm0130
650aDC*                  endif
640aA*
650aDC*                  endif
640aA*
640aAC                   select
640aA*      File(s) found to submit import job for processing.
640aAC                   when      submit = '*YES'
640aA*
640aA*        File(s) found to submit import job for processing.
640aAC                   exsr      zzsbmimp
640aA*        Job submitted to batch successfully.
640aAC                   if        $preturn = '*OK'
640aA
640aA*          Copy import files to Backup Directory.
640aAC                   exsr      zzcpyitem
640aA*
640aAC                   exsr      zzdltitem
640aAC                   else
640aA*        Error(s) submitting job to batch for processing.
640aAC                   eval      errmsg = filename
640aAC                   exsr      zm0135
640aA*        Rename semaphore file to prevent file from being processed
640aA*        over and over again.
640aAC                   eval      path = %trim(opipth)
640aAC                                    + %trim(filename)
640aAC                   eval      newpath = %trim(opipth)
640aAC                                    + 'Err_'
640aAC                                    + %trim(filename)
640aAC                   exsr      zzrename
640aAC                   endif
640aA*
640aAC                   endsl
640aA*
640aAC                   endsr
640aA*
650 A*----------------------------------------------------------------
650 A*
650 A*  ZZPROCITEM4  Process file extracted from directory
650 A*
650 AC     zzprocitem4   begsr
650 A*
650 A*      Initialize path / file fields.
650 AC                   eval      #pgmq    = 'IMPITEM'
650 AC                   eval      submit   = '*YES'
650 AC                   eval      $ppath1  = ' '
650 AC                   eval      $ppath2  = ' '
650 AC                   eval      $ppath3  = ' '
650 AC                   eval      $ppath4  = ' '
650 AC                   eval      $ppath5  = ' '
650 AC                   eval      $ppath6  = ' '
650 AC                   eval      filenam1 = ' '
650 AC                   eval      filenam2 = ' '
650 AC                   eval      filenam3 = ' '
650 AC                   eval      filenam4 = ' '
650 AC                   eval      filenam5 = ' '
650 AC                   eval      filenam6 = ' '
650 A*
650 A*      Process Import Item Updates.
650 AC                   eval      filenam1 = %subst(filename:2:xpos-2)
650 AC                   eval      filenam2 = 'IMPFITMM'
650 AC                   eval      filesfx = %subst(filename:xpos:%len(filename)
650 AC                                       - xpos)
650 A*
650 A*        Verify file is found in directory.
650 AC                   eval      path = %trim(opipth)
650 AC                                    + %trim(filenam1)
650 AC                                    + filesfx
650 AC                   exsr      zzckifsobj
650 A*
650 A*        Primary file found in directory. Continue processing.
650 AC                   if        filefound = '*YES'
650 AC                   eval      $ppath1 = path
650 AC                   else
650 A*        Terminal Error - Primary file not found. Cancel processing.
650 AC                   eval      submit = '*NO '
650 AC                   eval      errmsg = path
650 AC                   exsr      zm0125
650 A*        Rename semaphore file to prevent file from being processed
650 A*        over and over again.
650 AC                   eval      path = %trim(opipth)
650 AC                                    + %trim(filename)
650 AC                   eval      newpath = %trim(opipth)
650 AC                                    + 'Err_'
650 AC                                    + %trim(filename)
650 AC                   exsr      zzrename
650 AC                   endif
650 A*
650 A*        Check if semaphore file IMPFITMM is found in directory.
650aDC*                  eval      path = %trim(opipth)
650aDC*                                   + 'S'
650aDC*                                   + %trim(filenam2)
650aDC*                                   + filesfx
650aDC*                  exsr      zzckifsobj
650 A
650aDC*                  if        filefound = '*YES'
650 A*        Check if file IMPFITMM is found in directory.
650 AC                   eval      path = %trim(opipth)
650 AC                                    + %trim(filenam2)
710 AC                                    + %trim(%subst(filenam1:9:32))
650 AC                                    + filesfx
710 AC                   eval      filenam2 = %trim(filenam2)
710 AC                                    + %trim(%subst(filenam1:9:32))
710 AC                                    + filesfx
650 AC                   exsr      zzckifsobj
650 A
650 AC                   if        filefound = '*YES'
650 AC                   eval      $ppath2 = path
650aDC*                  else
650aMC                   endif
650 A*
650aD*        File IMPFITMM not found. Not okay to import.
650aDC*                  eval      submit = '*NO '
650aDC*                  eval      errmsg = path
650aDC*                  exsr      zm0130
650aDC*                  endif
650 A*
650aDC*                  endif
650 A*
650 AC                   select
650 A*      File(s) found to submit import job for processing.
650 AC                   when      submit = '*YES'
650 A*
650 A*        File(s) found to submit import job for processing.
650 AC                   exsr      zzsbmimp
650 A*        Job submitted to batch successfully.
650 AC                   if        $preturn = '*OK'
650 A
650 A*          Copy import files to Backup Directory.
650 AC                   exsr      zzcpyitem
650 A*
650 AC                   exsr      zzdltitem
650 AC                   else
650 A*        Error(s) submitting job to batch for processing.
650 AC                   eval      errmsg = filename
650 AC                   exsr      zm0135
650 A*        Rename semaphore file to prevent file from being processed
650 A*        over and over again.
650 AC                   eval      path = %trim(opipth)
650 AC                                    + %trim(filename)
650 AC                   eval      newpath = %trim(opipth)
650 AC                                    + 'Err_'
650 AC                                    + %trim(filename)
650 AC                   exsr      zzrename
650 AC                   endif
650 A*
650 AC                   endsl
650 A*
650 AC                   endsr
650 A*
     *----------------------------------------------------------------
     *
     *  ZZPROCORD  Process Customer Orders file extracted from directory
     *
     C     zzprocord     begsr
     *
     *      Initialize path / file fields.
     C                   eval      #pgmq    = 'IMPORD  '
     C                   eval      $pcmd    = '*ROUTE  '
     C                   eval      submit   = '*YES'
     C                   eval      $ppath1  = ' '
     C                   eval      $ppath2  = ' '
     C                   eval      $ppath3  = ' '
     C                   eval      $ppath4  = ' '
     C                   eval      $ppath5  = ' '
     C                   eval      $ppath6  = ' '
     C                   eval      filenam1 = ' '
     C                   eval      filenam2 = ' '
     C                   eval      filenam3 = ' '
     C                   eval      filenam4 = ' '
     C                   eval      filenam5 = ' '
     C                   eval      filenam6 = ' '
     *
     *-------------------------------------------------------------------
     *      Process Import Customer Orders.
     C                   eval      filenam1 = %subst(filename:2:8)
     C                   eval      filenam2 = 'IMPFORDHM'
     C                   eval      filenam3 = 'IMPFORDD'
     C                   eval      filenam4 = 'IMPFORDM'
     C                   eval      filesfx  = %subst(filename:10:%len(filename)
     C                                        - 10)
     *
     *        Verify file IMPFORDH is found in directory.
     C                   eval      path = %trim(opipth)
     C                                    + %trim(filenam1)
     C                                    + filesfx
     C                   exsr      zzckifsobj
     C                   if        filefound = '*YES'
     C                   eval      $ppath1 = path
     C                   else
     *
     *        File IMPFORDH not found. Processing canceled.
     C                   eval      submit = '*NO '
     C                   eval      errmsg = path
     C                   exsr      zm0128
     C                   endif
     *
     *        Verify file IMPFORDD is found in directory.
     C                   eval      path = %trim(opipth)
     C                                    + %trim(filenam3)
     C                                    + filesfx
     C                   exsr      zzckifsobj
     C                   if        filefound = '*YES'
     C                   eval      $ppath3 = path
     C                   else
     *
     *        File IMPFORDD not found. Processing cancelled.
     C                   eval      submit = '*NO '
     C                   eval      errmsg = path
     C                   exsr      zm0129
     C                   endif
     *
     *        Check if file semaphore IMPFORDHM is found in directory.
     C                   eval      path = %trim(opipth)
     C                                    + 'S'
     C                                    + %trim(filenam2)
     C                                    + filesfx
     C                   exsr      zzckifsobj

     C                   if        filefound = '*YES'
     *        Check if file IMPFORDHM is found in directory.
     C                   eval      path = %trim(opipth)
     C                                    + %trim(filenam2)
     C                                    + filesfx
     C                   exsr      zzckifsobj

     *        File IMPFORDHM found. Load path for processing.
     C                   if        filefound = '*YES'
     C                   eval      $ppath2   = path
     *
     C                   else
     *
     *        File IMPFORDHM not found. Not okay to import.
     C                   eval      submit = '*NO '
     C                   eval      errmsg = path
     C                   exsr      zm0133
     C                   endif
     *
     C                   endif
     *
     *        Check if semaphore file IMPFORDM is found in directory.
     C                   eval      path = %trim(opipth)
     C                                    + 'S'
     C                                    + %trim(filenam4)
     C                                    + filesfx
     C                   exsr      zzckifsobj

     *        File IMPFORDM found. Load path for processing.
     C                   if        filefound = '*YES'
     *        Check if file IMPFORDM is found in directory.
     C                   eval      path = %trim(opipth)
     C                                    + %trim(filenam4)
     C                                    + filesfx
     C                   exsr      zzckifsobj

     *        File IMPFORDM found. Load path for processing.
     C                   if        filefound = '*YES'
     C                   eval      $ppath4   = path
     *
     C                   else
     *
     *        File IMPFORDM not found. Not okay to import.
     C                   eval      submit = '*NO '
     C                   eval      errmsg = path
     C                   exsr      zm0134
     C                   endif
     *
     C                   endif
     *
     C                   select
     C                   when      submit = '*NO '
     *        Rename semaphore file to prevent file from being processed
     *        over and over again.
     C                   eval      path = %trim(opipth)
     C                                    + %trim(filename)
     C                   eval      newpath = %trim(opipth)
     C                                    + 'Err_'
     C                                    + %trim(filename)
     C                   exsr      zzrename
     *
     *        Primary files, IMPFORDH, IMPFORDD found in directory. ok to conti
     C                   when      submit = '*YES'
     *
     *        File(s) found to submit import job for processing.
     C                   exsr      zzsbmimp
     *        Job submitted to batch successfully.
     C                   if        $preturn = '*OK'
510aA
510aA*          Copy import files to Backup Directory.
510aAC                   exsr      zzcpyorder
510aA*
     C                   exsr      zzdltorder
     C                   else
     *        Error(s) submitting job to batch for processing.
     C                   eval      errmsg = filename
     C                   exsr      zm0137
     *        Rename semaphore file to prevent file from being processed
     *        over and over again.
     C                   eval      path = %trim(opipth)
     C                                    + %trim(filename)
     C                   eval      newpath = %trim(opipth)
     C                                    + 'Err_'
     C                                    + %trim(filename)
     C                   exsr      zzrename
     C                   endif
     *
     C                   endsl
     *
     C                   endsr
640aA*
640aA*----------------------------------------------------------------
640aA*
640aA*  ZZPROCORD5  Process Customer Orders file extracted from directory
640aA*
640aAC     zzprocord5    begsr
640aA*
640aA*      Initialize path / file fields.
640aAC                   eval      #pgmq    = 'IMPORD  '
640aAC                   eval      $pcmd    = '*ROUTE5 '
640aAC                   eval      submit   = '*YES'
640aAC                   eval      $ppath1  = ' '
640aAC                   eval      $ppath2  = ' '
640aAC                   eval      $ppath3  = ' '
640aAC                   eval      $ppath4  = ' '
640aAC                   eval      $ppath5  = ' '
640aAC                   eval      $ppath6  = ' '
640aAC                   eval      filenam1 = ' '
640aAC                   eval      filenam2 = ' '
640aAC                   eval      filenam3 = ' '
640aAC                   eval      filenam4 = ' '
640aAC                   eval      filenam5 = ' '
640aAC                   eval      filenam6 = ' '
640aA*
640aA*        Process Import Customer Orders.
640aAC                   eval      filenam1 = %subst(filename:2:xpos-2)
640aAC                   eval      filenam2 = 'IMPFORDD5'
640aAC                                        + %subst(filename:11:xpos-11)
640aAC                   eval      filenam3 = 'IMPFORDHM'
640aAC                                        + %subst(filename:11:xpos-11)
640aAC                   eval      filenam4 = 'IMPFORDDM'
640aAC                                        + %subst(filename:11:xpos-11)
640aAC                   eval      filesfx = %subst(filename:xpos:%len(filename)
640aAC                                        - xpos)
640aA*
640aA*        Verify file 1 is found in directory.
640aAC                   eval      path = %trim(opipth)
640aAC                                    + %trim(filenam1)
640aAC                                    + filesfx
640aAC                   exsr      zzckifsobj
640aAC                   if        filefound = '*YES'
640aAC                   eval      $ppath1 = path
640aAC                   else
640aA*        File 1 not found. Processing canceled.
640aAC                   eval      submit = '*NO '
640aAC                   eval      errmsg = path
640aAC                   exsr      zm0128
640aAC                   endif
640aA*
640aA*        Verify file 2 is found in directory.
640aAC                   eval      path = %trim(opipth)
640aAC                                    + %trim(filenam2)
640aAC                                    + filesfx
640aAC                   exsr      zzckifsobj
640aA*        File 2 found. Load path for processing.
640aAC                   if        filefound = '*YES'
640aAC                   eval      $ppath2 = path
640aAC                   else
640aA*        File 2 not found. Processing cancelled.
640aAC                   eval      submit = '*NO '
640aAC                   eval      errmsg = path
640aAC                   exsr      zm0129
640aAC                   endif
640aA*
640aA*        Verify file 3 is found in directory.
640aAC                   eval      path = %trim(opipth)
640aAC                                    + %trim(filenam3)
640aAC                                    + filesfx
640aAC                   exsr      zzckifsobj
640aA*        File 3 found. Load path for processing.
640aAC                   if        filefound = '*YES'
640aAC                   eval      $ppath3   = path
640aAC                   else
640aA*        File 3 not found. Processing cancelled.
640aAC                   eval      submit = '*NO '
640aAC                   eval      errmsg = path
640aAC                   exsr      zm0133
640aAC                   endif
640aA*
640aA*        Verify file 4 is found in directory.
640aAC                   eval      path = %trim(opipth)
640aAC                                    + %trim(filenam4)
640aAC                                    + filesfx
640aAC                   exsr      zzckifsobj
640aA*        File 4 found. Load path for processing.
640aAC                   if        filefound = '*YES'
640aAC                   eval      $ppath4   = path
640aAC                   else
640aA*        File 4 not found. Processing cancelled.
640aAC                   eval      submit = '*NO '
640aAC                   eval      errmsg = path
640aAC                   exsr      zm0133
640aAC                   endif
640aA*
640aAC                   select
640aA*        Primary files not found in directory.
640aAC                   when      submit = '*NO '
640aA*        Rename semaphore file to prevent file from being processed
640aA*        over and over again.
640aAC                   eval      path = %trim(opipth)
640aAC                                    + %trim(filename)
640aAC                   eval      newpath = %trim(opipth)
640aAC                                    + 'Err_'
640aAC                                    + %trim(filename)
640aAC                   exsr      zzrename
640aA*
640aA*        Primary files found in directory. ok to conti
640aAC                   when      submit = '*YES'
640aA*
640aA*        File(s) found to submit import job for processing.
640aAC                   exsr      zzsbmimp
640aA*        Job submitted to batch successfully.
640aAC                   if        $preturn = '*OK'
640aA
640aA*          Copy import files to Backup Directory.
640aAC                   exsr      zzcpyorder5
640aA*
640aAC                   exsr      zzdltorder
640aAC                   else
640aA*        Error(s) submitting job to batch for processing.
640aAC                   eval      errmsg = filename
640aAC                   exsr      zm0137
640aA*        Rename semaphore file to prevent file from being processed
640aA*        over and over again.
640aAC                   eval      path = %trim(opipth)
640aAC                                    + %trim(filename)
640aAC                   eval      newpath = %trim(opipth)
640aAC                                    + 'Err_'
640aAC                                    + %trim(filename)
640aAC                   exsr      zzrename
640aAC                   endif
640aA*
640aAC                   endsl
640aA*
640aAC                   endsr
ASC A*
ASC A*----------------------------------------------------------------
ASC A*
ASC A*  ZZPROCSAP  Process SAP file extracted from directory
ASC A*
ASC AC     zzprocsap     begsr
ASC A*
ASC A*      Initialize path / file fields.
ASC AC                   eval      #pgmq    = 'SAPORD  '
ASC AC                   eval      $pcmd    = '*ROUTE  '
ASC AC                   eval      submit   = '*YES'
ASC AC                   eval      $ppath1  = ' '
ASC A*
ASC A*-------------------------------------------------------------------
ASC A*      Process Import Customer Orders.
ASC A*
ASC A*        Verify file is found in directory.
ASC AC                   eval      path = %trim(opipth)
ASC AC                                    + %trim(filename)
ASC AC                   exsr      zzckifsobj
ASC AC                   if        filefound = '*YES'
ASC AC                   eval      $ppath1 = path
ASC AC                   else
ASC A*
ASC A*        File not found. Processing canceled.
ASC AC                   eval      submit = '*NO '
ASC AC                   eval      errmsg = path
ASC AC                   exsr      zm0128
ASC AC                   endif
ASC A*
ASC A*        Get file info into p_statds
ASC Ac                   if        stat(%trimr(path):
ASC Ac                                %addr(mystat)) < 0
ASC AC                   eval      submit = '*NO '
ASC Ac                   else
ASC Ac                   eval      p_statds = %addr(mystat)
ASC A*
ASC A*        Convert last change time to useable UTC timestamp
ASC Ac     epoch         adddur    st_ctime:*S   modtime
ASC A*        Adjust timestamp to UTC, default to EST if error
ASC Ac                   callp(e)  CEEUTCO(hours_utc: mins_utc: secs_utc)
ASC Ac                   if        %error
ASC Ac                   eval      utcoffset = -14400
ASC Ac                   else
ASC Ac                   eval      utcoffset = secs_utc
ASC Ac                   endif                                                  %error
ASC Ac                   adddur    utcoffset:*S  modtime
ASC A*        Add 2 minutes to last change to be safe
ASC Ac                   adddur    2:*Minutes    modtime
ASC A*
ASC A*        If not 10 minutes since last change, skip file
ASC AC                   if        %timestamp > modtime
ASC AC                   eval      submit = '*YES'
ASC Ac                   else
ASC AC                   eval      submit = '*NO '
ASC Ac                   endif                                                  %timestamp > modtime
ASC A*
ASC A*        If file has 0 bytes, skip file
ASC AC                   if        st_size <= 0
ASC AC                   eval      submit = '*NO '
ASC Ac                   endif
ASC A*
ASC  c                   endif                                                  stat()
ASC A*
ASC AC                   select
ASC A*
ASC A*        Primary file SAPORD_* found in directory. ok to conti
ASC AC                   when      submit = '*YES'
ASC A*
ASC A*        File(s) found, call import pgm for processing.
ASC AC                   call      'SAPIMPCL'
ASC AC                   parm                    $pcmd
ASC AC                   parm                    $pwhse
ASC AC                   parm                    $ppath1
ASC AC                   parm                    $preturn
ASC A*
ASC A*        Job submitted to batch successfully.
ASC AC                   if        $preturn = '*OK'
ASC A
ASC A*          Copy import files to Backup Directory.
ASC AC                   exsr      zzcpysap
ASC A*
ASC AC                   exsr      zzdltsap
ASC AC                   else
ASC A*        Error(s) submitting job to batch for processing.
ASC AC                   eval      errmsg = filename
ASC AC                   exsr      zm0137
ASC AC                   endif
ASC A*
ASC AC                   endsl
ASC A*
ASC AC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZPROCPO  Process P/O file extracted from directory
     *
     C     zzprocpo      begsr
     *
     *      Initialize path / file fields.
     C                   eval      #pgmq    = 'IMPPO   '
     C                   eval      $pcmd    = '*PO2    '
     C                   eval      submit   = '*YES'
     C                   eval      $ppath1  = ' '
     C                   eval      $ppath2  = ' '
     C                   eval      $ppath3  = ' '
     C                   eval      $ppath4  = ' '
     C                   eval      $ppath5  = ' '
     C                   eval      $ppath6  = ' '
     C                   eval      filenam1 = ' '
     C                   eval      filenam2 = ' '
     C                   eval      filenam3 = ' '
     C                   eval      filenam4 = ' '
     C                   eval      filenam5 = ' '
     C                   eval      filenam6 = ' '
     *
     *-------------------------------------------------------------------
     *      Process Import Purchase Orders.
     C                   eval      filenam1 = %subst(filename:2:8)
     C                   eval      filenam2 = 'IMPFPOHM'
     C                   eval      filenam3 = 'IMPFPOD2'
     C                   eval      filenam4 = 'IMPFPODM'
     C                   eval      filesfx  = %subst(filename:10:%len(filename)
     C                                        - 10)
     *
     *        Verify file IMPFPOH2 is found in directory.
     C                   eval      path = %trim(opipth)
     C                                    + %trim(filenam1)
     C                                    + filesfx
     C                   exsr      zzckifsobj
     C                   if        filefound = '*YES'
     C                   eval      $ppath1    = path
     C                   else
     *
     *        File IMPFPOH2 not found. Processing canceled.
     C                   eval      submit = '*NO '
     C                   eval      errmsg = path
     C                   exsr      zm0126
     C                   endif
     *
     *        Verify file IMPFPOD2 is found in directory.
     C                   eval      path = %trim(opipth)
     C                                    + %trim(filenam3)
     C                                    + filesfx
     C                   exsr      zzckifsobj
     C                   if        filefound = '*YES'
     C                   eval      $ppath3    = path
     C                   else
     *
     *        File IMPFPOD2 not found. Processing cancelled.
     C                   eval      submit = '*NO '
     C                   eval      errmsg = path
     C                   exsr      zm0127
     C                   endif
     *
     C                   select
     C                   when      submit = '*NO '
     *        Rename semaphore file to prevent file from being processed
     *        over and over again.
     C                   eval      path = %trim(opipth)
     C                                    + %trim(filename)
     C                   eval      newpath = %trim(opipth)
     C                                    + 'Err_'
     C                                    + %trim(filename)
     C                   exsr      zzrename
     *
     *      Primary files, IMPFPOH2, IMPFPOD2 found in directory. ok to continu
     C                   when      submit = '*YES'
     *
     *        Check if semaphore file IMPFPOHM is found in directory.
650cDC*                  eval      path = %trim(opipth)
650cDC*                                   + 'S'
650cDC*                                   + %trim(filenam2)
650cDC*                                   + filesfx
650cDC*                  exsr      zzckifsobj

     *        File IMPFPOHM is optional. File found. Load path.
650cDC*                  if        filefound = '*YES'
     *
     *        Check if file IMPFPOHM is found in directory.
     C                   eval      path = %trim(opipth)
     C                                    + %trim(filenam2)
     C                                    + filesfx
     C                   exsr      zzckifsobj

     *        File IMPFPOHM is optional. Okay to import without file.
     C                   if        filefound = '*YES'
     C                   eval      $ppath2   = path
     *
650cDC*                  else
650cMC                   endif
     *
     *        File IMPFPOHM not found. Okay to import without file.
650cDC*                  eval      errmsg = path
650c C*                  exsr      zm0131
650cDC*                  endif
     *
650cDC*                  endif
     *
     *  Note: Following code included for future use.
     *        Remove "goto" to activate code.
     *-------------------------------------------------------------------------
650bDC***                goto      skipdtlmisc
     *-------------------------------------------------------------------------
     *        Check if semaphore file IMPFPODM is found in directory.
650cDC*                  eval      path = %trim(opipth)
650cDC*                                   + 'S'
650cDC*                                   + %trim(filenam4)
650cDC*                                   + filesfx
650cDC*                  exsr      zzckifsobj

650cDC*                  if        filefound = '*YES'
     *
     *        Check if file IMPFPODM is found in directory.
     C                   eval      path = %trim(opipth)
     C                                    + %trim(filenam4)
     C                                    + filesfx
     C                   exsr      zzckifsobj

     *        File IMPFPODM is optional. Load path.
     C                   if        filefound = '*YES'
     C                   eval      $ppath4   = path
     *
650cDC*                  else
650cMC                   endif
     *
     *        File IMPFPODM not found. Okay to import without file.
650cDC*                  eval      errmsg = path
650cDC*                  exsr      zm0132
650cDC*                  endif
     *
650cDC*                  endif

     C     skipdtlmisc   tag

     *
     *        File(s) found to submit import job for processing.
     C                   exsr      zzsbmimp
     *        Job submitted to batch successfully.
     C                   if        $preturn = '*OK'
510aA
510aA*          Copy import files to Backup Directory.
510aAC                   exsr      zzcpypo
510aA*
     C                   exsr      zzdltpo
     C                   else
     *        Error(s) submitting job to batch for processing.
     C                   eval      errmsg = filename
     C                   exsr      zm0136
     *        Rename semaphore file to prevent file from being processed
     *        over and over again.
     C                   eval      path = %trim(opipth)
     C                                    + %trim(filename)
     C                   eval      newpath = %trim(opipth)
     C                                    + 'Err_'
     C                                    + %trim(filename)
     C                   exsr      zzrename
     C                   endif
     *
     C                   endsl
     *
     C                   endsr
640aA*
640aA*----------------------------------------------------------------
640aA*
640aA*  ZZPROCSLOT  Process file extracted from directory
640aA*
640aAC     zzprocslot    begsr
640aA*
640aA*      Initialize path / file fields.
640aAC                   eval      #pgmq    = 'IMPSLOT'
640aAC                   eval      submit   = '*YES'
640aAC                   eval      $ppath1  = ' '
640aAC                   eval      $ppath2  = ' '
640aAC                   eval      $ppath3  = ' '
640aAC                   eval      $ppath4  = ' '
640aAC                   eval      $ppath5  = ' '
640aAC                   eval      $ppath6  = ' '
640aAC                   eval      filenam1 = ' '
640aAC                   eval      filenam2 = ' '
640aAC                   eval      filenam3 = ' '
640aAC                   eval      filenam4 = ' '
640aAC                   eval      filenam5 = ' '
640aAC                   eval      filenam6 = ' '
640aA*
640aA*-------------------------------------------------------------------
640aA*      Process Import Item Updates.
640aAC                   eval      filenam1 = %subst(filename:2:9)
640aAC                   eval      filenam2 = filenam1
640aAC                   eval      filesfx  = %subst(filename:11:%len(filename)
640aAC                                        - 11)
640aA*
640aA*        Verify file is found in directory.
640aAC                   eval      path = %trim(opipth)
640aAC                                    + %trim(filenam1)
640aAC                                    + filesfx
640aAC                   exsr      zzckifsobj
640aA*
640aA*        Primary file found in directory. Continue processing.
640aAC                   if        filefound = '*YES'
640aAC                   eval      $ppath1 = path
640aAC                   else
640aA*        Terminal Error - Primary file not found. Cancel processing.
640aAC                   eval      submit = '*NO '
640aAC                   eval      errmsg = path
640aAC                   exsr      zm0125
640aA*        Rename semaphore file to prevent file from being processed
640aA*        over and over again.
640aAC                   eval      path = %trim(opipth)
640aAC                                    + %trim(filename)
640aAC                   eval      newpath = %trim(opipth)
640aAC                                    + 'Err_'
640aAC                                    + %trim(filename)
640aAC                   exsr      zzrename
640aAC                   endif
640aA*
640aA*        Check if semaphore file is found in directory.
640aAC                   eval      path = %trim(opipth)
640aAC                                    + 'S'
640aAC                                    + %trim(filenam2)
640aAC                                    + filesfx
640aAC                   exsr      zzckifsobj
640aA
640aAC                   if        filefound = '*YES'
640aA*        Check if file is found in directory.
640aAC                   eval      path = %trim(opipth)
640aAC                                    + %trim(filenam2)
640aAC                                    + filesfx
640aAC                   exsr      zzckifsobj
640aA
640aAC                   if        filefound = '*YES'
640aAC                   eval      $ppath2 = path
640aAC                   else
640aA*
640aA*        File not found. Not okay to import.
640aAC                   eval      submit = '*NO '
640aAC                   eval      errmsg = path
640aAC                   exsr      zm0130
640aAC                   endif
640aA*
640aAC                   endif
640aA*
640aAC                   select
640aA*      File(s) found to submit import job for processing.
640aAC                   when      submit = '*YES'
640aA*
640aA*        File(s) found to submit import job for processing.
640aAC                   exsr      zzsbmimp
640aA*        Job submitted to batch successfully.
640aAC                   if        $preturn = '*OK'
640aA
640aA*          Copy import files to Backup Directory.
640aAC                   exsr      zzcpyitem
640aA*
640aAC                   exsr      zzdltitem
640aAC                   else
640aA*        Error(s) submitting job to batch for processing.
640aAC                   eval      errmsg = filename
640aAC                   exsr      zm0135
640aA*        Rename semaphore file to prevent file from being processed
640aA*        over and over again.
640aAC                   eval      path = %trim(opipth)
640aAC                                    + %trim(filename)
640aAC                   eval      newpath = %trim(opipth)
640aAC                                    + 'Err_'
640aAC                                    + %trim(filename)
640aAC                   exsr      zzrename
640aAC                   endif
640aA*
640aAC                   endsl
640aA*
640aAC                   endsr
640aA*
640aA*----------------------------------------------------------------
640aA*
640aA*  ZZPROCSLOT3  Process file extracted from directory
640aA*
640aAC     zzprocslot3   begsr
640aA*
640aA*      Initialize path / file fields.
640aAC                   eval      #pgmq    = 'IMPSLOT'
640aAC                   eval      submit   = '*YES'
640aAC                   eval      $ppath1  = ' '
640aAC                   eval      $ppath2  = ' '
640aAC                   eval      $ppath3  = ' '
640aAC                   eval      $ppath4  = ' '
640aAC                   eval      $ppath5  = ' '
640aAC                   eval      $ppath6  = ' '
640aAC                   eval      filenam1 = ' '
640aAC                   eval      filenam2 = ' '
640aAC                   eval      filenam3 = ' '
640aAC                   eval      filenam4 = ' '
640aAC                   eval      filenam5 = ' '
640aAC                   eval      filenam6 = ' '
640aA*
640aA*      Process Slot Updates.
640aAC                   eval      filenam1 = %subst(filename:2:xpos-2)
640aAC                   eval      filenam2 = filenam1
640aAC                   eval      filesfx = %subst(filename:xpos:%len(filename)
640aAC                                        - xpos)
640aA*
640aA*        Verify file is found in directory.
640aAC                   eval      path = %trim(opipth)
640aAC                                    + %trim(filenam1)
640aAC                                    + filesfx
640aAC                   exsr      zzckifsobj
640aA*
640aA*        Primary file found in directory. Continue processing.
640aAC                   if        filefound = '*YES'
640aAC                   eval      $ppath1 = path
640aAC                   else
640aA*        Terminal Error - Primary file not found. Cancel processing.
640aAC                   eval      submit = '*NO '
640aAC                   eval      errmsg = path
640aAC                   exsr      zm0125
640aA*        Rename semaphore file to prevent file from being processed
640aA*        over and over again.
640aAC                   eval      path = %trim(opipth)
640aAC                                    + %trim(filename)
640aAC                   eval      newpath = %trim(opipth)
640aAC                                    + 'Err_'
640aAC                                    + %trim(filename)
640aAC                   exsr      zzrename
640aAC                   endif
640aA*
640aA*        Check if semaphore file is found in directory.
640aAC                   eval      path = %trim(opipth)
640aAC                                    + 'S'
640aAC                                    + %trim(filenam2)
640aAC                                    + filesfx
640aAC                   exsr      zzckifsobj
640aA
640aAC                   if        filefound = '*YES'
640aA*        Check if file is found in directory.
640aAC                   eval      path = %trim(opipth)
640aAC                                    + %trim(filenam2)
640aAC                                    + filesfx
640aAC                   exsr      zzckifsobj
640aA
640aAC                   if        filefound = '*YES'
640aAC                   eval      $ppath2 = path
640aAC                   else
640aA*
640aA*        File not found. Not okay to import.
640aAC                   eval      submit = '*NO '
640aAC                   eval      errmsg = path
640aAC                   exsr      zm0130
640aAC                   endif
640aA*
640aAC                   endif
640aA*
640aAC                   select
640aA*      File(s) found to submit import job for processing.
640aAC                   when      submit = '*YES'
640aA*
640aA*        File(s) found to submit import job for processing.
640aAC                   exsr      zzsbmimp
640aA*        Job submitted to batch successfully.
640aAC                   if        $preturn = '*OK'
640aA
640aA*          Copy import files to Backup Directory.
640aAC                   exsr      zzcpyitem
640aA*
640aAC                   exsr      zzdltitem
640aAC                   else
640aA*        Error(s) submitting job to batch for processing.
640aAC                   eval      errmsg = filename
640aAC                   exsr      zm0135
640aA*        Rename semaphore file to prevent file from being processed
640aA*        over and over again.
640aAC                   eval      path = %trim(opipth)
640aAC                                    + %trim(filename)
640aAC                   eval      newpath = %trim(opipth)
640aAC                                    + 'Err_'
640aAC                                    + %trim(filename)
640aAC                   exsr      zzrename
640aAC                   endif
640aA*
640aAC                   endsl
640aA*
640aAC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZRENAME  Rename directory file when errors occur.
     *
     C     zzrename      begsr
     *
     c                   if        rename(%trimr(Path): %trimr(NewPath))<0
     C                   callp     errno
     C                   eval      errmsg = path
     C                   exsr      zm0138
     c                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZSBMIMP  Submit Import Job for Processing.
     *
     C     zzsbmimp      begsr
     *
     C                   call      'PIRSBMCL'
     C                   parm                    $pcmd
     C                   parm                    $pwhse
     C                   parm                    $ppath1
     C                   parm                    $ppath2
     C                   parm                    $ppath3
     C                   parm                    $ppath4
     C                   parm                    $ppath5
     C                   parm                    $ppath6
     C                   parm      ' '           $preturn
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUNLINK  Unlink (Delete) File from Directory.
     *
     C     zzunlink      begsr
     *
     C                   if        unlink(%trimr(path)) < 0
     C                   callp     errno
     C                   eval      errmsg = path
     C                   exsr      zm0138
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *          IFS Procedure API's / Error Handling
     *----------------------------------------------------------------
      /define errno_load_procedure
      /copy qcopysrc,c#errno_h
