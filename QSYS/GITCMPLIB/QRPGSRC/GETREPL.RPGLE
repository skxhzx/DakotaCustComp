     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  GETREPL   Check for open Letdown/Priority Replenishment.
     *  13 May 2005
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*   05/13/05  MLB  5.00
     *     - Created.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Flabel12   if   e           k disk
     Fprplfil5  if   e           k disk
     *
     *----------------------------------------------------------------
     *  Work fields
     *
     D forevr          s              1
     *
     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $PCMD10  -  *LTDWNPRTY - Get first replenishment
     *                 *LETDOWN   - Get first letdown
     *                 *PRIOROTY  - Get first priority replenishment
     *     $PWHSE   -  Warhouse
     *     $PWHDP   -  Department
     *     $PDISP   -  Slot to be replenished (pick slot)
     *     $PITEM   -  Item number
     *
     *  Output parameters
     *
     *     $PTRN#   - Transaction number of letdown
     *     $PSEQ#   - Sequence number of priority replenishment
     *     $PRTN    - *OK    - Letdown and/or priority replenishment found.
     *                *ERROR - No Letdown or priority replenishment found.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd10          10
     C                   parm                    $pwhse            3 0
     C                   parm                    $pwhdp            5
     C                   parm                    $pdisp           12
     C                   parm                    $pitem           15
     C                   parm                    $ptrn#            7 0
     C                   parm                    $pseq#            5 0
     C                   parm                    $prtn             8
     *
     *----------------------------------------------------------------
     *  Main line
     *
     *   Initialize return parameters.
     *
     C                   eval      $ptrn# = 0
     C                   eval      $pseq# = 0
     C                   eval      $prtn  = '*ERROR  '
     *
     *   Loop through active overflow slots for item.
     *
     C                   select
     *
     *    Retrieve both Letdown / Priority Replenishment, if any.
     C                   when      $pcmd10 = '*LTDWNPRTY'
     C                   eval      kygrp1  = 'L'
     C                   eval      kygrp2  = ' '
     C                   exsr      zzletdown
     *
     C                   exsr      zzprtyrepl
     *
     *    Retrieve only Letdowns, if any.
     C                   when      $pcmd10 = '*LETDOWN'
     C                   eval      kygrp1  = 'L'
     C                   eval      kygrp2  = ' '
     C                   exsr      zzletdown
     *
     *    Retrieve only Priority Replenishments, if any.
     C                   when      $pcmd10 = '*PRTYRPL'
     C                   exsr      zzprtyrepl
     *
     C                   endsl
     *
     *
     C                   return
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     C                   eval      forevr = *off
     *
     *  Define partial key for LABEL12 file.
     *
     C     *like         define    lbgrp1        kygrp1
     C     *like         define    lbgrp2        kygrp2
     C     keylb12       klist
     C                   kfld                    $pwhse
     C                   kfld                    kygrp1
     C                   kfld                    kygrp2
     C                   kfld                    $pwhdp
     C                   kfld                    $pdisp
     *
     *  Define partial key for PRPLFIL5 file.
     *
     C     keypr5        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $pdisp
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZLETDOWN  Find first letdown for item.
     *
     C     zzletdown     begsr
     *
     C     keylb12       setll     label12
     C     keylb12       reade     label12
     C                   dow       not %eof(label12)
     *
     *    Send back transaction number of open letdown.
     C                   if        lbstat = 'P'
     C                   eval      $ptrn# = lbtrn#
     C                   eval      $prtn = '*OK     '
     C                   leave
     C                   endif
     *
     C     keylb12       reade     label12
     C                   enddo
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZPRTYREPL  Find first priority replenishment for item.
     *
     C     zzprtyrepl    begsr
     *
     C     keypr5        setll     prplfil5
     C     keypr5        reade     prplfil5
     C                   dow       not %eof(prplfil5)
     *
     *    Send back sequence number of open priority replenishment.
     C                   if        prflag = 'S'
     C                   eval      $pseq# = prseq#
     C                   eval      $prtn = '*OK     '
     C                   leave
     C                   endif
     *
     C     keypr5        reade     prplfil5
     C                   enddo
     *
     C                   endsr
