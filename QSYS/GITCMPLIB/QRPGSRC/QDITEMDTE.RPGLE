      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *   Set Date sensitive fields by department.
     *----------------------------------------------------------------
     Fpiritem   up   e           k disk
     Fitemmsc   uf   e           k disk
     *
     C     *like         define    itwhse        kywhse
     C**                 eval      kywhse = 002
     C     imkey         klist
     C                   kfld                    itwhse
     C                   kfld                    ititem
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   select
     C                   when      itwhdp = 'FRZ'
     C                   eval      itflgd = 'Y'
     C                   update    itrec
     C
     C     imkey         chain     itemmsc
     *
     C                   if        %found(itemmsc)
     C                   eval      immflg = 'N'
     C                   eval      imdday = 30
     C                   eval      imuday = 30
     C                   eval      immday = 0
     C                   eval      imoday = 730
     C                   update    imrec
     C                   endif

     C                   when      itwhdp = 'REF'
     C                   eval      itflgd = 'Y'
     C                   update    itrec
     C
     C     imkey         chain     itemmsc
     *
     C                   if        %found(itemmsc)
     C                   eval      immflg = 'N'
     C                   eval      imdday = 7
     C                   eval      imuday = 3
     C                   eval      immday = 0
     C                   eval      imoday = 30
     C                   update    imrec
     C                   endif
     C                   other
     C                   endsl
