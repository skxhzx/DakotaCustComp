     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  QDDRY050
     *  07 December 2012
     *  Max Blacknik
     *
     *  Add records to ITEMDSC that are missing entries. Load ITDESC
     *  into IXDSC1.
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fpiritem   if   e           k disk
     Fitemdsc   uf a e           k disk
     *----------------------------------------------------------------
     *  working data structure
     *
     D dummy           s              3  0
     D forevr          s              1
     D                 ds
     D  loc2                   1      2  0
     D  slloc                  1      3  0
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
     C     ixkey         klist
     C                   kfld                    itwhse
     C                   kfld                    ititem
     *
     C                   dow       forevr = forevr
     C                   read      piritem
     C                   select
     C                   when      %eof(piritem)
     C                   leave
     *
     C                   other
     *
     C     ixkey         chain     itemdsc
     C                   if        not %found(itemdsc)
     C                   eval      ixwhse = itwhse
     C                   eval      ixitem = ititem
     C                   eval      ixdsc1 = itdesc
     C                   eval      ixdsc2 = ' '
     C                   write     ixrec
     *
     C                   else
     C                   unlock    itemdsc
     C                   endif
     *
     C                   endsl
     *
     C                   enddo
     *
     C                   eval      *inlr = *on
     *
