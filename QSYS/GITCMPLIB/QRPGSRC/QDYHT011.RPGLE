      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 60510
     *   (630) 562-0375
     Fpiritem   ip   e             disk    prefix(oha_)
     Fpiritem3  uf   e           k disk    rename(itrec : itrec3)
     Fitemmsc   if   e           k disk    prefix(oha_)
     Fitemmsc1  uf   e           k disk    rename(imrec : imrec1)
     *
     C     *like         define    itwhse        kywhse
     C     it3KEY        klist
     C                   kfld                    oha_ititem
     C                   kfld                    kywhse
     C                   eval      kywhse = 004
     C     imkey         klist
     C                   kfld                    oha_itwhse
     C                   kfld                    oha_ititem
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   if            oha_itwhse = 001
     C
     C     it3key        chain     piritem3
     C                   if        %found(piritem3)
     *
     C                   eval      itflgd = oha_itflgd
     C                   eval      itslif = oha_itslif
     C                   eval      itnday = oha_itnday
     C                   update    itrec3
     C                   endif
     C
     C     imkey         chain     itemmsc
     C                   if        %found(itemmsc)
     *
     C     it3key        chain     itemmsc1
     C                   if        %found(itemmsc1)
     *
     C                   eval      immflg = oha_immflg
     C                   eval      imdday = oha_imdday
     C                   eval      imuday = oha_imuday
     C                   eval      immday = oha_immday
     C                   eval      imoday = oha_imoday
     C                   update    imrec1
     C                   endif
     C
     C                   endif

     C                   endif
