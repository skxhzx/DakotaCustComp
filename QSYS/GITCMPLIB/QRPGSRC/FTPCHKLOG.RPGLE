     F*----------------------------------------------------------------
     F*   Copyright (C) 1999 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  FTPCHKLOG   Check FTP log for errors
     F*  05 March 1999
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
414 AF*    09/13/00  DAS  4.14
     F*      - Changed logged in string from 'logged in' to 'logged'.
     F*      - Added extra 'transfer complete' message.
     F*      - Added message FTP0003.
     F*      - Sending new message when any FTP error occurs.
     F*
520 AF*    09/21/08  MLB  5.20
     F*      - Fix: Add new 'logged in' msg to search for: Add
     F*        "Login successful" to program.
     F*      - Fix: Add new 'Transfer complete' search string.
     F*        "File receive OK" to program.
720a F*    11/14/18  RTR  7.20a
     F*      - Fix: Add new 'logged in' msg to search for:
     F*        Added "Logged on" to program.
     F*      - Fix: Add new 'Transfer complete' search string.
     F*        "File receive OK" to program.
     F*
     F*----------------------------------------------------------------
     F*  Notes
     F*
     F*    FTP does not send error messages through AS/400 message
     F*    queues. Instead, it just writes information to a log file.
     F*    This program will read the log file and search for the
     F*    following messages:
     F*
     F*      'logged in'
     F*
     F*         This message shows a successful log in.  If it is
     F*         not found an error message will be generated.
     F*
     F*      'Transfer complete'
     F*
     F*         Then number of these messages that need to be found
     F*         depends on the export type.  If we don't find the
     F*         correct number an error message will be generated.
     F*
     F*----------------------------------------------------------------
     F* File Specs
     F*
     FFTPEXPLOG IF   E             DISK
     F                                     RENAME(FTPEXPLOG:RECORD)
     F
     D*----------------------------------------------------------------
     D*  Variable/Constant definitions

     D Forever         C                   0
     D True            C                   1
     D False           C                   0

414 DD*LoggedInMsg     C                   'logged in'
414 MD LoggedInMsg     C                   'logged'
520 AD LoggedInMsg2    C                   'Login successful'
720aAD LoggedInMsg3    C                   'Logged on'
     D TfrCompleteMsg  C                   'Transfer complete'
414 AD TfrCompleteMs2  C                   'transfer complete'
520 AD TfrCompleteMs3  C                   'File receive OK'
720aAD TfrCompleteMs4  C                   'Transfer OK'

     D LoggedIn        S              1S 0
     D ScanPos         S              3P 0
520 AD ScanPos2        S              3P 0
     D TfrCount        S              1S 0

0493 D*----------------------------------------------------------------
.    D*  Data structure for error message parameters
0493 D*
     D $MDT            DS
     D  ERRMSG                 1     50
     D                 DS
     D  $EC                    1      2P 0
0493 D*----------------------------------------------------------------
.    D*  Message control
0493 D*
     D #MSGF           C                   CONST('PIRMSGF   ')
     D*
     D                 DS
     D  #MSGDT                 1    128
     D  $MD                    1    128
     D                                     DIM(128)
0493 D*----------------------------------------------------------------
.    D*  Program info data structure
0493 D*
     D                SDS
     D  #PROG            *PROC
.    D  #JOB                 244    253
.    D  #USER                254    263
.    D  #JOBN                264    269
.    D  #JOBDT               276    281  0
.    D  #JOBTM               282    287  0

     C*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PTfrNeeded  Number of 'Transfer complete' messages that
     C*                     should be found
     C*      $PMember     Member name for error messages
     C*      $PPrg        Program to send errom messages to
     C*
     C*    Returned Parameters
     C*      $PReturn     *OK    - No errors found.
     C*                   *PGMQ  - Error occured.
     C*      $PMsgKey     Key of error messasge
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PTfrNeeded       1 0
     C                   PARM                    $PMember         10
     C                   PARM                    $PPrg            10
     C                   PARM                    $PReturn          8
     C                   PARM                    $PMsgKey          4
     C*----------------------------------------------------------------
     C* Main line
     C*
     C                   eval      $PReturn = '*OK'
     C*
     C*  Loop through source records
     C*
     C     Forever       doweq     Forever
     C                   read      FtpExpLog                              79
     C                   if        *IN79 = *ON
     C*                  if        %Eof          (%EOF started in V4R2)
     C                   leave
     C                   endif
     C*
     C*     Check for 'logged in'
     C*
     C                   if        LoggedIn = False
     C                   eval      ScanPos = %Scan(LoggedInMsg:SrcDta)
520 AC                   if        ScanPos = 0
520 AC                   eval      ScanPos = %Scan(LoggedInMsg2:SrcDta)
520 AC                   endif
720aAC                   if        ScanPos = 0
720aAC                   eval      ScanPos = %Scan(LoggedInMsg3:SrcDta)
720aAC                   endif
     C                   if        ScanPos > 0
     C                   eval      LoggedIn  = True
     C                   iter
     C                   endif
     C                   endif
     C*
     C*     Check for 'Transfer complete'
     C*
     C                   eval      ScanPos = %Scan(TfrCompleteMsg:SrcDta)
414 AC                   if        ScanPos = 0
414 AC                   eval      ScanPos = %Scan(TfrCompleteMs2:SrcDta)
414 AC                   endif
520 AC                   if        ScanPos = 0
520 AC                   eval      ScanPos = %Scan(TfrCompleteMs3:SrcDta)
520 AC                   endif
720aAC                   if        ScanPos = 0
720aAC                   eval      ScanPos = %Scan(TfrCompleteMs4:SrcDta)
720aAC                   endif
     C                   if        ScanPos > 0
     C                   eval      TfrCount = TfrCount + 1
     C                   if        TfrCount = $PTfrNeeded
     C                   leave
     C                   else
     C                   iter
     C                   endif
     C                   endif
     C*
     C                   enddo
     C*
     C*  Error if log in failed
     C*
     C                   if        LoggedIn = False
     C                   exsr      ZM0001
     C                   endif
     C*
     C*  See if we found enough completion messages
     C*
     C                   if        LoggedIn = True  AND TfrCount <> $PTfrNeeded
     C                   exsr      ZM0002
     C                   endif
414 AC*
414 AC*  If an error occured send message telling user to look at log.
414 AC*
414 AC                   if        $PReturn = '*PGMQ'
414 AC                   exsr      ZM0003
414 AC                   endif
     C*
     C*  We are finished so get out
     C*
     C                   eval      *INLR = *ON
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*---------------------------------------------------------------
     C*
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*
     C*    ZMSMSG  Send program message to a different program msgq
     C*
     C     ZMSMSG        BEGSR
     C     $MSGF         IFEQ      *BLANKS
     C                   MOVE      #MSGF         $MSGF            10
     C                   END
     C                   CALL      'PUTMSG'
     C                   PARM                    $MSGF
     C                   PARM                    #MSGID            7
     C                   PARM                    #MSGTP            7
     C                   PARM                    #MSGDT
     C                   PARM      $PPRG         #PGMQ2           10
     C                   PARM                    #MSGK             4
     C                   MOVE      *BLANKS       #MSGDT
     C                   MOVE      *BLANKS       $MSGF
     C                   ENDSR
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*     FTP0001  - Log in failed.
     C*
     C     ZM0001        BEGSR
     C                   MOVE      'FTP0001'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   eval      ERRMSG = $PMember
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMSMSG
     C                   eval      $PMsgKey = #MSGK
     C                   eval      $PReturn = '*PGMQ'
     C                   ENDSR
     C*----------------------------------------------------------------
     C*     FTP0002  - Transfer failed.
     C*
     C     ZM0002        BEGSR
     C                   MOVE      'FTP0002'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   eval      ERRMSG = $PMember
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMSMSG
     C                   eval      $PMsgKey = #MSGK
     C                   eval      $PReturn = '*PGMQ'
     C                   ENDSR
414 AC*----------------------------------------------------------------
414 AC*     FTP0003  - FTP export failed - View log.
414 AC*
414 AC     ZM0003        BEGSR
     C                   MOVE      'FTP0003'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   eval      ERRMSG = $PMember
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMSMSG
     C                   eval      $PMsgKey = #MSGK
     C                   eval      $PReturn = '*PGMQ'
     C                   ENDSR
