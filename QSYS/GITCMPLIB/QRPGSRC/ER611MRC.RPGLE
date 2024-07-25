      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  ER611M    View Summary - MRC copy
     *  Dave Sommerville
     *  13 October 2009
     *
     *  Revisions
     *
     *    10/13/09  DAS  6.10
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fer611a    ip   e           k disk
     Fer611amrc uf a e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D first           s               n   inz(*ON)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse       Warehouse
     *      $pUser       User
     *      $pFDate      From date
     *      $pFTime      From time
     *      $pTDate      To date
     *      $pTTime      To time
     *      $pShift      Shift
     *      $pCrew       Crew
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *
     C     *entry        plist
416aAC                   parm                    $pwhse            3
416aAC                   parm                    $puser           10
416aAC                   parm                    $pfdate           8
416aAC                   parm                    $pftime           6
416aAC                   parm                    $ptdate           8
416aAC                   parm                    $pttime           6
416aAC                   parm                    $pshift           6
416aAC                   parm                    $pcrew            6

     *  Remove existing user records first time through.

     C                   if        first
     C                   eval      first = *off
     C     $puser        setll     er611amrc
     C                   dou       %eof(er611amrc)
     C     $puser        reade     er611amrc
     C                   if        not %eof(er611amrc)
     C                   delete    wkmrec
     C                   endif
     C                   enddo
     C                   endif

     *  Copy er611a record to er611am file.

     C                   eval      wkwhse = %dec($pwhse:3:0)
     C                   eval      wkuser = $puser
     C                   eval      wkfdte = %dec($pfdate:8:0)
     C                   eval      wkftim = %dec($pftime:6:0)
     C                   eval      wktdte = %dec($ptdate:8:0)
     C                   eval      wkttim = %dec($pttime:6:0)
     C                   eval      wkshft = $pshift
     C                   eval      wkcrew = $pcrew

     C                   write(e)  wkmrec

