     H OPTION(*NODEBUGIO)
     F*----------------------------------------------------------------
     F*   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*----------------------------------------------------------------
     F*
     F*  LOADR36   Load Driver Route Flagged item list.
     F*  January 22, 2008
     F*  Jose Duque
     F*
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    06/17/09  RBD  5.20
     *      - Enh: Added client custom code support to program.
     *      - Added call to GETWHSE.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney
     *
CBI A*    06/17/09  RBD  CBI
     *      - Coded special produce items logic as specific to Cheney.
     *
     *----------------------------------------------------------------
     F*  File Specs
     F*
     FLdr371c   if   e           k disk
     FOrdh      if   e           k disk
     FPltsum1   if   e           k disk
      *
     FRteflgd   uf   e           k disk
     FDrvrflg   o    e           k disk
      *
     *----------------------------------------------------------------
520 A*  Client ID's
520 A*
CBI A /copy qcopysrc,id#cheney
520 A*
520 AD @getcl          c                   const('GETCLIENT')
     *
     *----------------------------------------------------------------
520 A*  Program info data structure
520 A*
520 AD                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     C     *Entry        Plist
     C                   Parm                    $Rte#             5
     C                   Parm                    $Flag             1
     *
520 A*  Get warehouse for user.
     *
520 AC                   call      'GETWHSE'
520 AC                   parm                    #user
520 AC                   parm      0             #whse             3 0
      *
      *----------------------------------------------------------------
     C     Ordkey        Klist
     C                   Kfld                    Ruwhse
     C                   Kfld                    Lbord
      *
     C     Pltkey        Klist
     C                   Kfld                    Ruwhse
     C                   Kfld                    Lbrte
      *
     C     Rtekey        Klist
     C                   Kfld                    Ruwhse
     C                   Kfld                    $Rte#
     E*----------------------------------------------------------------
     C                   Setoff                                       15
     C     Initread      Tag
     C                   Read      Ldr371c                                LR
     C                   If        *inlr
      *
      *    This route does not have flagedd items.
520 DC***                Eval      Ruwhse = 001
520 MC                   Eval      Ruwhse = #whse
     C     Rtekey        Chain     Rteflgd                            79
     C                   If        Not*in79
     C                   Move      'Y'           Rtprnt
     C                   Move      'N'           Rtflag
     C                   Update    Rtefrec
     C                   Endif
     C                   Move      'N'           $Flag
     C                   Goto      More
     C                   Endif
     C                   If        Ruqyfd = *Zeros
     C                   Goto      Initread
     C                   Endif
      *
     C                   Movel     $Rte#         Drte#
      *
     C                   Exsr      Loadrec
      *
     C     More          Tag
     C     *Inlr         Downe     *on
      *
     C                   If        Ititem  =  Dritem and
     C                             Lbstop  =  Drstop
     C                   If        Ruqyfd  >  Drqyfd
     C                   Move      Ruqyso        Drqyso
     C                   Move      Ruqyfd        Drqyfd
     C                   Goto      Read
     C                   Else
     C                   Goto      Read
     C                   Endif
     C                   Endif
      *
     C                   Write     Drvrec
     C     Rtekey        Chain     Rteflgd                            79
     C                   If        Not*in79
     C                   Move      Hexpd         Rtexpd
     C                   Move      Hexpt         Rtexpt
     C                   Move      'Y'           Rtprnt
     C                   Update    Rtefrec
     C                   Endif
      *
     C                   If        Ruqyfd = *Zeros
     C                   Setoff                                       15
     C                   Goto      Read
     C                   Else
     C                   Exsr      Loadrec
     C                   Endif
      *
     C     Read          Tag
     C                   Read      Ldr371c                                LR
     C                   Enddo
      *
     C                   If        *in15  and
     C                             Rtprnt = *Blank
     C                   Write     Drvrec
     C     Rtekey        Chain     Rteflgd                            79
     C                   If        Not*in79
     C                   Move      Hexpd         Rtexpd
     C                   Move      Hexpt         Rtexpt
     C                   Move      'Y'           Rtprnt
     C                   Update    Rtefrec
     C                   Endif
     C                   Endif
      *
     C*----------------------------------------------------------------
520 AC*  *INZSR  Initialization subrotine
     C*----------------------------------------------------------------
     C*
520 AC     *INZSR        BEGSR
520 A*
520 A*  Get Client ID
     *
520 AC                   call      @getcl
520 AC                   parm                    client           10
     *
520 AC                   endsr
     *
     C*----------------------------------------------------------------
     C* Loadrec  subrotine
     C*----------------------------------------------------------------
     CSR   Loadrec       Begsr
     C*----------------------------------------------------------------
      *
      *    Get customer name from order header file
      *
     C     Ordkey        Chain     Ordh                               79
     C                   If        *in79
     C                   Eval      Drcnam = *blanks
     C                   Else
     C                   Movel     Ohcnam        Drcnam
     C                   Endif
      *
      *    Get pallet label load sequence #
      *
     C                   Eval      Drplt# = *zeros
     C     Pltkey        Setll     Pltsum1
     C     Pltkey        Reade     Pltsum1                                79
     C     *In79         Downe     *on
     C                   If        psplid = lbpal#
     C                   Move      Pspal#        Drplt#
     C                   Leave
     C                   Endif
     C     Pltkey        Reade     Pltsum1                                79
     C                   Enddo
      *
      *    Load rest of output record
      *
     C                   If        Ititem >= '405000' and
     C                             Ititem <= '492999'
CBI AC                             and client = cheney
     C                   Movel     'PRD  '       Drwhdp
     C                   else
     C                   Movel     Ruwhdp        Drwhdp
     C                   Endif
     C                   Move      Ruqyso        Drqyso
     C                   Move      Ruqyfd        Drqyfd
     C                   Move      Lbstop        Drstop
     C                   Move      Lbord         Drord
     C                   Movel     Ititem        Dritem
     C                   Movel     Itdesc        Drdesc
      *
     C                   Move      Rhexpd        Hexpd             8 0
     C                   Move      Rhexpt        Hexpt             6 0
     C                   Seton                                        15
      *
     C     Bottom        Endsr
