     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  CALPCKRTE Calculate picked qty, weight and cube for route.
     *  29 October, 2001
     *  Hemant Kapadia
     *
     *  Revisions
     *
416 A*   10/29/01  HNK  4.16
     *     -Created.
     *
500 A*    01/16/06  DAS  5.00
     *     - Added support for client id's.
     *     - Revise to use KYWHDP RTESUM key instead of ITWHDP.
     *
520 A*    06/11/09  CWM  5.20
     *     - Converted to ILE.
     *     - Updated Client Copy Source Statements for ILE.
     *     - Revise to only use LBTYPE 'O' and 'B' to eliminate issue
     *       where Pick Qty was greater than Order Qty.
     *     - Removed Control Level Indicator SR from source.
     *
520aA*    07/23/09  JCJ  5.20a
     *     - Revised program to add LBCUBE / LBSWGT to RSPCKC / RSPCKW
     *       instead of using extended ITCUBE, ITSWGT.
     *
640 A*    05/07/12  RBD  6.40
     *     - Recompiled, LABEL31 changed.
     *
     *----------------------------------------------------------------
     *
CBIaA*    01/16/06  DAS  CBIa
     *      - Revised to use a fictitious department PRD in RTESUM
     *        using a specific range of item numbers (405000 - 492999)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Frtesum    uf   e           k disk
     FLabel31   if   e           k disk
500 A*----------------------------------------------------------------
500 A*  Customer id
500 A*
     D @getcl          c                   const('GETCLIENT')
500 A*
520 A /COPY QCOPYSRC,ID#CHENEY
520 A /COPY QCOPYSRC,ID#CHENEYO
520 A /COPY QCOPYSRC,ID#CHENEYR
500 A*
520 D*/COPY QCOPYSRC,IL#CHENEY
520 D*/COPY QCOPYSRC,IL#CHENEYO
520 D*/COPY QCOPYSRC,IL#CHENEYR
     *----------------------------------------------------------------
500 A* Work Variables
500 A*
     D forevr          s              1
     D w1cube          s              9  3
     D w1swgt          s              9  2
     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $PWHSE   -  Warhouse
     *     $PRTID   -  Route ID
     *
     *  Output parameters
     *
     *     None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     *----------------------------------------------------------------
     *  Main line
500 A*
500 A* Get client id.
500 A*
500 AC                   call      @getcl
500 AC                   parm                    client           10
500 AC                   parm                    cliloc           10
     *
     *
     *   Loop through RTESUM file for route.
     *
     C     rskey         setll     rtesum
     *
     C                   dow       forevr = forevr
     *
     C     rskey         reade     rtesum                                 79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   exsr      zzcalc
     C                   update    rsrec
     C                   enddo
     *
     C                   return
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      forevr = *off
     *
     *  Define partial key for LABEL31 File.
     *
     C     keyl31        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     *  Define key for RTESUM File.
     *
     C     rskey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCALC  Initialization subrotine
     *
     C     zzcalc        begsr
     C                   eval      rspckp = 0
     C                   eval      rspckw = 0
     C                   eval      rspckc = 0
     C                   eval      w1swgt = 0
     C                   eval      w1cube = 0
     *
     *   Loop through LABEL file for route.
     *
     C     keyl31        setll     label31
     *
     C                   dow       forevr = forevr
     *
     C     keyl31        reade     label31                                79
     C                   if        *in79
     C                   leave
     C                   endif
520 A*
520 A*   Validate Type
520 A*
520 AC                   if        lbtype = 'O' or lbtype = 'B'
520 A*
CBIaA*
CBIaA*     Cheney - Change department to PRD for certain items.
CBIaA*
CBIaAC                   select
CBIaAC                   when      client = cheney
CBIaAC                   if        lbitem >= '405000'  and
CBIaAC                             lbitem <= '492999'
CBIaAC                   eval      lbwhdp = 'PRD  '
CBIaAC                   endif
CBIaAC                   endsl
     *
     C                   if        lbwhdp = rswhdp
520 D*    LBTYPE        ANDNE     'M'
     C                   add       lbqpck        rspckp
520aD*    lbqpck        mult      itcube        w1cube
520aD*                  add       w1cube        rspckc
520aMC                   add       lbcube        rspckc
520aD*    lbqpck        mult      itswgt        w1swgt
520aD*                  add       w1swgt        rspckw
520aMC                   add       lbswgt        rspckw
     C                   endif
     *
520 AC                   endif
520 A*
     C                   enddo
     *
     C                   endsr
