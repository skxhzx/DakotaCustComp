     F*----------------------------------------------------------------
     F*   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (630) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  TSTTIME   Test time duration.
     F*  1 May 2001
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
415 AF*    05/01/01  DAS  4.15
     F*
     F*----------------------------------------------------------------
     F*  Notes
     F*
     F*    This program does not display anything.
     F*    The testing is done through debug.
     F*
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     D FromStamp       s               z
     D ToStamp         s               z
     D
     D StdDate         s               d
     D StdTime         s               t
     D
     D FromDate        s              8  0 inz(20010430)
     D FromTime        s              6  0 inz(233020)
     D
     D ToDate          s              8  0 inz(20010501)
     D ToTime          s              6  0 inz(013000)
     D
     D DurMin          s              5  0 inz(0)
     D DurMin2         s              7  2 inz(0)
     D
     D NewStamp        s               z
     D NewDate         s               d
     D NewDate80       s              8  0
     D NewTime         s               t
     D NewTime60       s              6  0
     D
     C*----------------------------------------------------------------
     C*  Main line
     C*
     C*  Convert From date/time into time stamp.
     C*
     C     *ISO          Move      FromDate      StdDate
     C     *HMS          Move      FromTime      StdTime
     C                   Move      StdDate       FromStamp
     C                   Move      StdTime       FromStamp
     C*
     C*  Convert To date/time into time stamp.
     C*
     C     *ISO          Move      ToDate        StdDate
     C     *HMS          Move      ToTime        StdTime
     C                   Move      StdDate       ToStamp
     C                   Move      StdTime       ToStamp
     C*
     C*  Calculate time duration.
     C*
     C     ToStamp       SubDur    FromStamp     DurMin:*MN
     C*
     C     FromStamp     SubDur    25:*H         NewStamp
     C                   Move      NewStamp      NewDate
     C                   Move      NewStamp      NewTime
     C                   Move      NewDate       NewDate80
     C                   Move      NewTime       NewTime60
     C*
     C*  Test subprogram CalcTime for *MINUTES
     C*
     C                   Call      'CALCTIME'
     C                   Parm      '*MINUTES'    $PCmd             8
     C                   Parm                    FromDate
     C                   Parm                    FromTime
     C                   Parm                    ToDate
     C                   Parm                    ToTime
     C                   Parm      0             DurMin2
     C*
     C*  Test subprogram CalcTime for *SECONDS
     C*
     C                   Call      'CALCTIME'
     C                   Parm      '*SECONDS'    $PCmd             8
     C                   Parm                    FromDate
     C                   Parm                    FromTime
     C                   Parm                    ToDate
     C                   Parm                    ToTime
     C                   Parm      0             DurMin2
     C*
     C                   Move      *On           *INLR
