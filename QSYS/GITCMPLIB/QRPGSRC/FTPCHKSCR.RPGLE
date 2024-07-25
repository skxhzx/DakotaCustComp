     F*----------------------------------------------------------------
     F*   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  FTPCHKSCR   Check FTP script for *NO EXPORT*.
     F*  13 September 2000
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
414 AF*    09/13/00  DAS  4.14
     F*      - Created.
     F*
     F*----------------------------------------------------------------
     F*  Notes
     F*
     F*    If a client does not want FS-WMS to FTP a file to their
     F*    host system, they can put '*NO EXPORT* in the first line
     F*    of the corresponding export script. This will tell the
     F*    export programs to only create the FTP export member but
     F*    will not attempt to send it to the host. The client is
     F*    then responsible for getting the file to the host.
     F*
     F*----------------------------------------------------------------
     F* File Specs
     F*
     FFTPEXPDFT IF   E             DISK
     F
     D*----------------------------------------------------------------
     D*  Variable/Constant definitions

     D NoExportMsg     C                   '*NO EXPORT*'
     D ScanPos         S              3P 0

     C*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      None
     C*
     C*    Returned Parameters
     C*      $PReturn     *OK       - Allow export.
     C*                   *NOEXP    - Do not export.
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PReturn          8
     C*----------------------------------------------------------------
     C* Main line
     C*
     C                   eval      $PReturn = '*OK'
     C*
     C*  Read first record.
     C*
     C                   read      FtpExpDft                              79
     C                   if        *IN79 = *OFF
     C*
     C*     Check for '*NO EXPORT*'
     C*
     C                   eval      ScanPos = %Scan(NoExportMsg:SrcDta)
     C                   if        ScanPos > 0
     C                   eval      $PReturn  = '*NOEXP'
     C                   endif
     C*
     C                   endif
     C*
     C*  We are finished so get out
     C*
     C                   eval      *INLR = *ON
