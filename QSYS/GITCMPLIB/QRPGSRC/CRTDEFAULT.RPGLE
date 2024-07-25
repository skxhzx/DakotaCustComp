     F*----------------------------------------------------------------
     F*   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  CRTDEFAULT  Create default FTP script
     F*  11 September 2000
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
     F*----------------------------------------------------------------
     F* File Specs
     F*
     FFTPEXPDFT O  A E             DISK
     D*----------------------------------------------------------------
     D*  Variable/Constant definitions

     D ScrpLn          S             80    DIM(47) CTDATA PERRCD(1)
     D MaxLine         C                   47
     D @CVTDT          C                   CONST('CVTDTE')

     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD8I                25     32
     D  $CVD6O                33     38  0
     D  $CVD8O                39     46  0
     D  $CVSTO                47     64
     D  $CVRTN                65     72
     D  $CVERM                73    132
     D  $CVMSG                73     76

     C*----------------------------------------------------------------
     C* Main line
     C*
     C*   Write table records to file.
     C*
     C     1             do        MaxLine       I                 3 0
     C                   eval      SrcSeq = I
     C                   eval      SrcDat = Today
     C                   eval      SrcDta = ScrpLn(I)
     C                   write     FtpExpScr
     C*
     C                   enddo
     C*
     C*  We are finished so get out
     C*
     C                   eval      *INLR = *ON
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     CSR   *INZSR        BEGSR
     C*
     C*  Get current date
     C*
     CSR                 MOVE      '*CURYMD '    $CVCMD
     CSR                 CALL      @CVTDT
     CSR                 PARM                    $CVTDT
     CSR                 Z-ADD     $CVD6O        TODAY             6 0
     C                   ENDSR
     O*----------------------------------------------------------------
     O*
     O*  Compile time tables
     O*
**  ScrpLn
open <FTP Server>
user <UserName Password>
put <LibraryName/FileName.MemberName> <RemotePathName><RemoteFileName>
quit
*-------------------------------------------------------------------------------
* Comments (Any line starting with an '*' will be removed from the final script)
*
*   There is a separate export script for each export within FS-WMS. The script
*   name matches the corresponding FTP export file. For example: the script for
*   the inventory adjustment export is named EXPFADJ. There is also a script
*   named DEFAULT. A program exists (CRTEXPDFT) which can create the DEFAULT
*   script if it does not exist and then will use the script to create any
*   other script that does not exist.
*
*   There are three variables that will be filled in during runtime:
*
*     <FTP Server>
*        This will be replaced with the FTP Server entered into the FTP options.
*
*     <UserName Password>
*        This will be replaced with the user name (id) and password entered
*        into the FTP options.
*
*     <LibraryName/FileName.MemberName>
*        This will contain the local file name.  The member name will be
*        unique for each export.  The file and member name depends upon
*        which export is being performed.
*
*     <RemotePathName>
*        This will be replaced with the remote path name entered into the
*        FTP options.
*
*     <RemoteFileName>
*        This will contain the remote file name that will be created on
*        your system.  This will only contain the actual file name and not
*        the path. Replace 'pathname' with the correct path where the file
*        should be put.
*
*   See export documentation for file name created on host system.
*
***********************************************************************
*** To prevent this script from executing copy the '*NO EXPORT*'    ***
*** line (found below) to the first line of this script.            ***
***********************************************************************
*
*NO EXPORT*
*
