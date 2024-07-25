     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  QDFRF300
     *  28 July 2014
     *  Max Blacknik
     *
     *  Update SLOT1 with new SLSIDE value.
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fslot1     uf   e           k disk
     *----------------------------------------------------------------
     *  working data structure
     *
     D                 ds
     D  loc2                   1      2  0
     D dummy           s              3  0
     D forevr          s              1
     D oddevn          s              3  0
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     * Main line
     *
     * Let the show begin ...
     *
     C                   eval      forevr = *on
     *
     C                   dow       forevr = forevr
     C                   read      slot1                                  79
     C                   select
     C                   when      *in79
     C                   leave
     *
     *    5 character base slot.
     C                   when          %subst(sldisp:3:2) >= '00'
     C                             and %subst(sldisp:3:2) <= '99'
     C                             and %subst(sldisp:6:1)  = ' '
     *
     C                   eval      loca  = '0' + %subst(sidisp:3:2)
     C                   exsr      zzcalcside
     *
     C                   update    slrec
     *
     C                   endsl
     *
     C                   enddo
     *
     C                   eval      *inlr = *on
     *------------------------------------------------------------------*
     *  Calculate SLSIDE value from extracted Slot Display value.
     *
     C     zzcalcside    begsr
     C                   move      loca          loc2
     C     loc2          div       2             dummy
     C                   mvr                     oddevn
     C                   if        oddevn <> 0
     C                   eval      slside = 1
     C                   else
     C                   eval      slside = 0
     C                   endif
     C                   endsr
