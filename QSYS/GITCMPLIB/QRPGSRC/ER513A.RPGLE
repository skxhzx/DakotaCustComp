      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ER513A    Employee Activity Report - Process
     *  Hemant Kapadia
     *  04 September, 2001
     *
     *  Revisions
     *
     *    09/04/01  HNK  4.16
     *      - Created using IT313A
     *
     *  07/22/09   GJA   5.30
     *     -Enh:  Convert to RPGLE, cleaned up and revamped for
     *                 suspended transactions.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Not on file/End of file indicator
     *  90        Overflow Indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fer513     ip   e           k disk
     Fpiritem   if   e           k disk
     Fer513a    o  a e           k disk
     *****************************************************************
     *----------------------------------------------------------------
     *  Called programs
     *
     *----------------------------------------------------------------
     *
     *  Program parameters
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $litem                22     36
     D  $litmf                37     51
     D  $ldesc                52     83
     *----------------------------------------------------------------
     *  Variables
     *
     D first           s              1
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $DISP  - Slot or *all
     *
     *    Returned Parameters
     *      None
     *
     C     *entry        plist
     C                   parm                    $disp            12
     C                   parm                    $rtncd            8
     *----------------------------------------------------------------
     *
     *  Main line
     *
     C     lbgrp2        cabeq     'B'           skip
     *
     C     keyit         chain     piritem                            79
     C                   if        not *in79
     C                   eval      wkdesc = itdesc
     C                   else
     C                   eval      wkdesc = *blanks
     C                   endif
     *
     C                   eval      wkwhse = lbwhse
     C                   eval      wkitem = lbitem
     C                   eval      wkdate = lbrdte
     C                   eval      wkwhdp = lbwhdp
     C                   eval      wkuom = lbucod
     C                   eval      wklbl# = lblbl#
     C                   eval      wktrn# = lbtrn#
     C                   eval      wkdisp = lbdisp
     C                   eval      wkdsp2 = lbdsp2
     C                   eval      wkpo = lbpo
     C                   eval      wktype = lbtype
     C                   eval      wkqty = lbqpck
     C                   eval      wkemp# = ptemp#
     C                   eval      wktask = pttask
     C                   eval      wkshft = ptshft
     C                   eval      wkcrew = ptcrew
     C                   eval      wksdte = ptsdte
     C                   eval      wkstim = ptstim
     C                   eval      wkedte = ptedte
     C                   eval      wketim = ptetim
     C                   eval      wkdmin = ptdmin
     C                   eval      wkimin = ptimin
     C                   eval      wkfnam = usfnam
     C                   eval      wkinit = usinit
     C                   eval      wklnam = uslnam
     C                   write     wkrec
     *
     C     skip          tag
     *
     *****************************************************************
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     C                   eval      first = *on
     *
     *
     *  Define keys.
     *
     *    PIRITEM file
     *
     C     keyit         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbitem
     C                   endsr
     *----------------------------------------------------------------
     *
     C     zrfrmt        begsr
     *
     C                   endsr
     *****************************************************************
     *
