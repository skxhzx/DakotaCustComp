      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FRMTVS2   Format virtual slot for special RCV/STG slots
     *  24 October 2008
     *  Dave Sommerville
     *
     *  Revisions
     *
600 A*    10/24/08  DAS  6.00
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D addOn           s              4
     D addOnLen        s              3  0
     D dispLen         s              3  0
     D pos             s              3  0

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pDispIn   Slot display In
     *      pHand     Handstack indicator
     *
     *    Returned Parameters
     *      pDispOut  Slot display Out
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pDispIn          12
     C                   parm                    pLevel            2 0
     C                   parm                    pHand             2
     C                   parm                    pDispOut         12

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      dispLen = %len(%trim(pDispIn))

     C                   eval      addOn = %trim(%editc(pLevel:'Z'))
     C                                   + %trim(pHand)
     C                   eval      addOnLen = %len(%trim(addOn))

     C                   select

     C                   when      (dispLen + addOnLen) <= 11
     C                   eval      pDispOut = %trim(pDispIn)
     C                                      + '-' + addOn

     C                   other
     C                   eval      pos = 12 - addOnLen + 1
     C                   eval      pDispOut = %trim(pDispIn)
     C                   eval      %subst(pDispOut:pos:addOnLen)
     C                             = addOn

     C                   endsl

     C                   return
