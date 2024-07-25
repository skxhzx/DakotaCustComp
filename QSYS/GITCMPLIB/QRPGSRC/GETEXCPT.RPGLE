     H option(*NODEBUGIO)
      *----------------------------------------------------------------
      *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
      *   BFC Software, Inc.
      *   245 Roosevelt Rd.  Bldg 8, Suite 51
      *   WEST CHICAGO, IL 60158
      *   (630) 562-0375
      *----------------------------------------------------------------
      *
      *  GETEXCPT  Create replenishment flag exceptions file
      *            (replenishments done within 15 minutes and
      *            up from replenishment issue time).
      *
      *  December 01, 2005
      *  Jose Duque
      *
      *  Revisions:
      *
     *----------------------------------------------------------------
     *  File Specs
     *
     Frunner2   if   e           k disk
      *
     FLabel     if   e           k disk
     Fpiritem   if   e           k disk
     Frtehed    if   e           k disk
      *
     FFlgrepl   uf a e           k disk
     F
     *----------------------------------------------------------------
     *  Other working variables.
     *
     D datestamp       s               d
     D dftstamp        s               z
     D timestamp       s               t
     D datkey          s              6  0
     D itmkey          s                   like(lbitem)
     D kywhse          s                   like(lbwhse)
     D kywhdp          s                   like(lbwhdp)
     D kylbl#          s                   like(lblbl#)
     D timkey          s              8  0
     D w3opnd          s              6  0
     D w3opnt          s               t
     D w3rpld          s              6  0
     D w3rplt          s               t
     *----------------------------------------------------------------
     * Data structure
     *
     D Hldtime         DS
     D  HH                     1      2
     D  MM                     3      4
     D  SS                     5      6
     *----------------------------------------------------------------
     * Main line
     *
     *

     C                   exsr      zzinz

     *    Code to use when we do have a partial key to use.
     *
     C     partky2       setll     rurec
     C     partky2       reade(n)  rurec                                  79
     C                   dow       not *in79
     C                   if        rustat <> 'C' and
     C                             rustat <> 'D'
     C                   exsr      zzfill
     C                   endif
     *
     *
     C     partky2       reade(n)  rurec                                  79
     C                   enddo
     *
     C                   seton                                        lr
     C                   return
     *
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill FLGREPL record
     *
     C     zzfill        begsr
     *
     C     rulbl#        chain     label
     C                   if        not %found
     C                   eval      lbitem = ' '
     C                   eval      lblbl# = 0
     C                   eval      lbrte  = ' '
     C                   eval      lbucod = ' '
     C                   endif
     *
     C     keyit         chain     piritem
     C                   if        not %found
     C                   eval      itdesc = ' '
     C                   eval      itpdsc = ' '
     C                   endif
     *
     C     keyrh         chain     rtehed
     C                   if        not %found
     C                   eval      rhrte = ' '
     C                   endif
     *

     *  Convert datestamp to date/time output fields.

     C                   If        ruodts <> dftstamp
     C                   move      ruodts        datestamp
     C                   move      ruodts        timestamp

     *  Load Open Status date/time fields.

     C     *mdy          move      datestamp     w3opnd
     C                   eval      w3opnt = timestamp
     C                   Else
     C                   eval      w3opnd = 0
     C                   eval      w3opnt = *loval
     C                   Endif

    A*  Convert datestamp to date/time output fields.
    A
     C                   If        rurdts <> dftstamp
     C                   move      rurdts        datestamp
     C                   move      rurdts        timestamp

     *  Load Replenished date/time fields.

     C     *mdy          move      datestamp     w3rpld
     C                   eval      w3rplt = timestamp

     C                   Else
     C                   eval      w3rpld = 0
     C                   eval      w3rplt = *loval
     C                   Endif


     *  Load report file with replenishment exceptions.

     C                   Exsr      Zzgetdiff
     *
     C                   If        *In27 = *on  or
     C                             *In28 = *on
     *
     C                   Move      lbitem        itmkey
     C                   Move      w3opnd        datkey
     C                   Move      w3opnt        timkey
     *
     C     Flgkey        Chain     Flgrec                             79
     C                   if        *in79
     *
     C                   Clear                   Flgrec
     C                   Move      ruwhdp        Dept
     C                   Move      lbdisp        Loc#
     C                   Move      ruotrn        Orgtrn
     C                   Move      rutrn#        Flgtrn
     C                   Move      rhrte         route
     C                   Move      ruqyso        short
     C                   Move      lbitem        Item
     C                   Move      w3opnd        Opndat
     C                   Move      w3opnt        Opntim
     C                   Move      w3rpld        Clsdat
     C                   Move      w3rplt        Clstim
     C                   Move      $tdiff        Tdiff

     C                   If        *in27
     C                   Move      'Y'           Yelred
     C                   else
     C                   Move      'R'           Yelred
     C                   Endif

     C                   Write     Flgrec
     C                   Endif
     C                   Endif
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGETDIFF  Get Difference between open replenishment time
     *             and close replenishment time.
     *
     C     Zzgetdiff     begsr
     *

     *  The following routine compares rpl open time against
     *  rpl close time, if the different is 15 to 24 minutes
     *  the close time is displayed on yellow if 25 minutes
     *  or more close time is displayed on flashing red.

     C                   Move      W3opnt        timein            8

     C     2             Subst     Timein:1      HH
     C     2             Subst     Timein:4      MM
     C     2             Subst     Timein:7      SS
     C                   Move      Hldtime       $tstime

     C                   Move      W3rplt        timein

     C     2             Subst     Timein:1      HH
     C     2             Subst     Timein:4      MM
     C     2             Subst     Timein:7      SS
     C                   Move      Hldtime       $tetime

     C                   Move      *blanks       $tdiff

     C                   Call      'GETDIFF'
     C                   parm                    $tstime           6
     C                   parm                    $tetime           6
     C                   parm                    $tdiff            6

     C                   Setoff                                       2728

     C                   move      $tdiff        tdiff             6 0

     C                   if        tdiff >  1500 and
     C                             tdiff <= 2400
     C                   Seton                                        27
     C                   Setoff                                       28
     C                   Endif

     C                   if        tdiff >= 2500
     C                   Seton                                        28
     C                   Setoff                                       27
     C                   Endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ    Program initialization.
     *
     C     zzinz         begsr
     *
     *  Define partial key for main file (if needed).
     *
     C     *like         define    rutype        kytype
     C     partky        klist
     C                   kfld                    kywhse
     C                   kfld                    kytype
     C                   kfld                    kywhdp
     C     partky2       klist
     C                   kfld                    kywhse
     C                   kfld                    kytype
     C*
     *
     *  Define FULL key for PIRITEM file.
     *
     C     keyit         klist
     C                   kfld                    kywhse
     C                   kfld                    lbitem
     *  Define FULL key for RTEHED file.
     *
     C     keyrh         klist
     C                   kfld                    kywhse
     C                   kfld                    lbrte
     *
     *  Define UNIQ key for FLGREPL file.
     *
     C     flgkey        klist
     C                   kfld                    itmkey
     C                   kfld                    datkey
     C                   kfld                    timkey
     *
     *
     C                   eval      kywhse = 1
     C                   eval      kytype = 'N'
     *
     C                   endsr
     *
