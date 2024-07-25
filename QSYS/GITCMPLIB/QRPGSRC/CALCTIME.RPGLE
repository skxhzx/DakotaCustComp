     F*----------------------------------------------------------------
     F*   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (630) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  CALCTIME  Calculate time between two date/time's
     F*  1 May 2001
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
415 AF*    05/01/01  DAS  4.15
     F*      - Created.
     F*
416 AF*    02/26/02  DAS  4.16
     F*      - Added *HOURS and *DAYS
     F*
     D*----------------------------------------------------------------
     D*  Parameter fields
     D*
     D $PCmd           s              8
     D
     D $PFromDate      s              8  0
     D $PFromTime      s              6  0
     D
     D $PToDate        s              8  0
     D $PToTime        s              6  0
     D
     D $PDuration      s              7  2
     D
     D*----------------------------------------------------------------
     D*  Date fields
     D*
     D FromStamp       s               z
     D ToStamp         s               z
     D
     D StdDate         s               d   DatFmt(*ISO)
     D StdTime         s               t   TimFmt(*HMS)
     D
416 AD TtlHrs          s              5  0
     D TtlMin          s              5  0
     D TtlMinSec       s              5  0
     D TtlSec          s              5  0
     D RemSec          s              3  0
     D
     D*----------------------------------------------------------------
     D*  Misc variables
     D*
     D pssrflag        s               n
     D
     I*----------------------------------------------------------------
     I*
     I*  Input parameters
     I*
     I*     $PCommand   - *MINUTES  Calculate duration in minutes (default)
     I*                   *SECONDS  Calculate duration in seconds
416 AI*                   *HOURS    Calculate duration in hours
416 AI*                   *DAYS     Calculate duration in days
     I*     $PFromDate  - From date (YYYYMMDD)
     I*     $PFromTime  - From time (HHMMSS)
     I*     $PToDate    - To date (YYYYMMDD)
     I*     $PToTime    - To time (HHMMSS)
     I*
     I*  Output parameters
     I*
     I*     $PDuration  - Duration
     C*----------------------------------------------------------------
     C*  Let the show begin ...
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PCmd
     C                   PARM                    $PFromDate
     C                   PARM                    $PFromTime
     C                   PARM                    $PToDate
     C                   PARM                    $PToTime
     C                   PARM                    $PDuration
     C*----------------------------------------------------------------
     C*  Main line
     C*
     C*  Convert From date/time into time stamp.
     C*
     C     *ISO          Move      $PFromDate    StdDate
     C     *HMS          Move      $PFromTime    StdTime
     C                   Move      StdDate       FromStamp
     C                   Move      StdTime       FromStamp
     C*
     C*  Convert To date/time into time stamp.
     C*
     C     *ISO          Move      $PToDate      StdDate
     C     *HMS          Move      $PToTime      StdTime
     C                   Move      StdDate       ToStamp
     C                   Move      StdTime       ToStamp
     C*
     C*  Calculate time duration.
     C*
     C                   Select
     C                   When      $PCmd = '*SECONDS'
     C     ToStamp       SubDur    FromStamp     TtlSec:*S
     C                   Eval      $PDuration = TtlSec

     C                   When      $PCmd = '*MINUTES'
     C     ToStamp       SubDur    FromStamp     TtlSec:*S
     C     ToStamp       SubDur    FromStamp     TtlMin:*MN
     C                   Eval      TtlMinSec = TtlMin * 60
     C                   Eval      RemSec = TtlSec - TtlMinSec
     C                   If        RemSec = 0
     C                   Eval      $PDuration = TtlMin
     C                   Else
     C                   Eval      $PDuration = TtlMin + (RemSec/60)
     C                   EndIf

416 AC                   When      $PCmd = '*HOURS'
416 AC     ToStamp       SubDur    FromStamp     TtlMin:*MN
416 AC                   Eval      $PDuration = TtlMin / 60

416 AC                   When      $PCmd = '*DAYS'
416 AC     ToStamp       SubDur    FromStamp     TtlHrs:*H
416 AC                   Eval      $PDuration = TtlHrs / 24
     C*
     C                   EndSl
     C*
     C                   Return

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

     C     *pssr         begsr

     *  Make sure we don't get caught in an infinite loop

 1B  C                   if        pssrflag
     C                   eval      *inlr = *on
     C                   return
     C                   endif

     C                   eval      pssrflag = *on

     *  Send max negative number back to indicate error.

     C                   Eval      $PDuration = -99999.99
     C                   eval      *inlr = *on
 1E  C                   return

     C                   endsr
