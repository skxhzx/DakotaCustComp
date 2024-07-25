     F*----------------------------------------------------------------
     F*   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (630) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  CLCDUR2   Calculate new date/time
     F*  29 March 2002
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
415 AF*    03/29/02  DAS  4.16
     F*      - Created.
     F*
710a F*    10/18/17  RTR  7.10a
     F*      - Fix: changed to handle invalid date, just return what was
     F*        passed instead of blowing up.
     F*
     D*----------------------------------------------------------------
     D*  Parameter fields
     D*
     D $PCmd           s              8
     D
     D $PDateIn        s              8  0
     D $PTimeIn        s              6  0
     D
     D $PYears         s              3  0
     D $PMonths        s              3  0
     D $PDays          s              3  0
     D $PHours         s              3  0
     D $PMinutes       s              3  0
     D $PSeconds       s              3  0
     D
     D $PDateOut       s              8  0
     D $PTimeOut       s              6  0
     D
     D*----------------------------------------------------------------
     D*  Date fields
     D*
     D Stamp           s               z
     D
     D StdDate         s               d   DatFmt(*ISO)
     D StdTime         s               t   TimFmt(*HMS)
     D
     I*----------------------------------------------------------------
     I*
     I*  Input parameters
     I*
     I*     $PCommand   - *ADD  Add values to date/time
     I*                   *SUB  Subtract values from date/time
     I*     $PDateIn    - From date (YYYYMMDD)
     I*     $PTimeIn    - From time (HHMMSS)
     I*     $PYears     - Years to add/subtract
     I*     $PMonths    - Months to add/subtract
     I*     $PDays      - Days to add/subtract
     I*     $PHours     - Hours to add/subtract
     I*     $PMinutes   - Minutes to add/subtract
     I*     $PSeconds   - Seconds to add/subtract
     I*
     I*  Output parameters
     I*     $PDateOut   - From date (YYYYMMDD)
     I*     $PTimeOut   - From time (HHMMSS)
     C*----------------------------------------------------------------
     C*  Let the show begin ...
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PCmd
     C                   PARM                    $PDateIn
     C                   PARM                    $PTimeIn
     C                   PARM                    $PYears
     C                   PARM                    $PMonths
     C                   PARM                    $PDays
     C                   PARM                    $PHours
     C                   PARM                    $PMinutes
     C                   PARM                    $PSeconds
     C                   PARM                    $PDateOut
     C                   PARM                    $PTimeOut
     C*----------------------------------------------------------------
     C*  Main line

     C*  Convert input date/time into time stamp.

710aAC                   monitor
     C     *ISO          Move      $PDateIn      StdDate
710aAC                   on-error
710aAC                   eval      $PCmd = '*ERRDATE'
710aAC                   endmon
710aAC                   monitor
     C     *HMS          Move      $PTimeIn      StdTime
710aAC                   on-error
710aAC                   eval      $PCmd = '*ERRTIME'
710aAC                   endmon
     C                   Move      StdDate       Stamp
     C                   Move      StdTime       Stamp

     C*  Add/Subtract values.

     C                   Select

     C                   When      $PCmd = '*ADD'
     C     Stamp         AddDur    $PYears:*Y    Stamp
     C     Stamp         AddDur    $PMonths:*M   Stamp
     C     Stamp         AddDur    $PDays:*D     Stamp
     C     Stamp         AddDur    $PHours:*H    Stamp
     C     Stamp         AddDur    $PMinutes:*MN Stamp
     C     Stamp         AddDur    $PSeconds:*S  Stamp

     C                   When      $PCmd = '*SUB'
     C     Stamp         SubDur    $PYears:*Y    Stamp
     C     Stamp         SubDur    $PMonths:*M   Stamp
     C     Stamp         SubDur    $PDays:*D     Stamp
     C     Stamp         SubDur    $PHours:*H    Stamp
     C     Stamp         SubDur    $PMinutes:*MN Stamp
     C     Stamp         SubDur    $PSeconds:*S  Stamp

710aAC                   Other
710aAC                   Eval      $PDateOut = $PDateIn
710aAC                   Eval      $PTimeOut = $PTimeIn
710aAC                   Return

     C                   endsl

     C*  Convert stamp to output date/time

     C                   Move      Stamp         StdDate
     C                   Move      StdDate       $PDateOut
     C                   Move      Stamp         StdTime
     C                   Move      StdTime       $PTimeOut

     C                   Return
