     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2003')
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *    *** New programs should call ADJTRAN2 directly ***
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  ADJTRAN     Adjust transaction record
     *  04 February 1997
     *  Dave Sommerville
     *  Hemant Kapadia
     *
     *  Revisions
     *
417 A*    05/01/03  DAS  4.17
     *      - Converted to ILE.
     *      - Moved logic into ADJTRAN2.
     *      - Revised program to just call ADJTRAN2.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pprg            10
     C                   parm                    $ptrn#            7 0
     C                   parm                    $ptask            6
     C                   parm                    $pwhse            3 0
     C                   parm                    $pwhdp            5
     C                   parm                    $pstyp            1
     C                   parm                    $pcube            9 3
     C                   parm                    $pswgt            9 2
     C                   parm                    $ppcs             5 0
     C                   parm                    $paisl            5 0
     C                   parm                    $pqty1            5 0
     C                   parm                    $pqty2            5 0
     C                   parm                    $pqty3            5 0
     C                   parm                    $prte             5
     C                   parm                    $ppo              9
     C                   parm                    $pgrp1            1
     C                   parm                    $pgrp2            1
     C                   parm                    $prtn             8
     C                   parm                    $pmsg             4

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   call      'ADJTRAN2'
     C                   parm      $pcmd         $pcmd10          10
     C                   parm                    $pprg
     C                   parm      '*INTER'      $ptype            8
     C                   parm                    $ptrn#
     C                   parm                    $ptask
     C                   parm                    $pwhse
     C                   parm                    $pwhdp
     C                   parm                    $pstyp
     C                   parm                    $pcube
     C                   parm                    $pswgt
     C                   parm                    $ppcs
     C                   parm                    $paisl
     C                   parm                    $pqty1
     C                   parm                    $pqty2
     C                   parm                    $pqty3
     C                   parm                    $prte
     C                   parm                    $ppo
     C                   parm                    $pgrp1
     C                   parm                    $pgrp2
     C                   parm      0             $pdate            8 0
     C                   parm      0             $ptime            6 0
     C                   parm      ' '           $puser           10
     C                   parm                    $prtn
     C                   parm                    $pmsg
     C                   return
