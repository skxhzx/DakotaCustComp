      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     Fpiritem   ip   e             disk    prefix(atl_)
     Fpiritem3  uf   e           k disk    rename(itrec : itrec3)
     Fitemmsc   if   e           k disk    prefix(atl_)
     Fitemmsc1  uf   e           k disk    rename(imrec : imrec1)
     *
     C     *like         define    itwhse        kywhse
     *
     *       To Whse file key.
     C     it3KEY        klist
     C                   kfld                    atl_ititem
     C                   kfld                    kywhse
     C                   eval      kywhse = 001
     C     imkey         klist
     C                   kfld                    atl_itwhse
     C                   kfld                    atl_ititem
     *
     *----------------------------------------------------------------
     *  Main line
     *
     *
     C                   if            atl_itwhse = 002
     C                             and atl_itwhdp = 'CLR'
     C
     C     it3key        chain     piritem3
     C                   if        %found(piritem3)
     *
     C                   eval      itflgd = atl_itflgd
     C                   eval      itslif = atl_itslif
     C                   eval      itnday = atl_itnday
     C                   update    itrec3
     C                   endif
     C
     C     imkey         chain     itemmsc
     C                   if        %found(itemmsc)
     *
     C     it3key        chain     itemmsc1
     C                   if        %found(itemmsc1)
     *
     C                   eval      immflg = atl_immflg
     C                   eval      imdday = atl_imdday
     C                   eval      imuday = atl_imuday
     C                   eval      immday = atl_immday
     C                   eval      imoday = atl_imoday
     C                   update    imrec1
     C                   endif
     C
     C                   endif

     C                   endif
