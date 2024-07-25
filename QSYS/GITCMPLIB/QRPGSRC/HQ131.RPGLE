      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  HQ131     Compare Quantity From Host System To BFC
     *  20 Nov, 2007
     *  Chuck Manny
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
510 A*  11/20/07  CM   5.10
     *   - Created.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  90        Overflow Indicator
     *
     *----------------------------------------------------------------
     *
     * ********************************
     ** File Specs
     * ********************************
     *
     fimpfpqty  if   e           k disk
     fpiritem   if   e           k disk
     fitemqty   if   e           k disk
     fwarehs    if   e           k disk
     fhq131pr   o    e             printer oflind(*in90)
     *
     * ********************************
     ** SUB PROCEDURE PROTOTYPES
     * ********************************
     *
     d prGetItmInf     pr
     *
     d prGetPckSlt     pr            12
     *
     d prPrcPirItm     pr
     *
     d prProQtyCmp     pr
     *
     d prZrFrmt        pr
     *
     d prZrHead        pr
     *
     d prZzCvQy        pr
     *
     * ********************************
     ** Table and Array
     * ********************************
     *
     * ********************************
     ** Constants
     * ********************************
     *
     d cNotFnd         c                   const('Item Not Found')
     d cBrkDwn         c                   const('B')
     d cMatch          c                   const('M')
     d cYes            c                   const('Y')
     d cNo             c                   const('N')
     *
     * ********************************
     ** Program info data structure
     * ********************************
     *
     d                sds
     d  #prog            *proc
     d  #job                 244    253
     d  #user                254    263
     d  #jobn                264    269
     d  #jobdt               276    281  0
     d  #jobtm               282    287  0
     *
     * ********************************
     ** User Defined Work Fields
     * ********************************
     *
     *
     ** Get Pick Slot User Defined Fields
     *
     d $pcmd           s              8    inz('*FIRST  ')
     d $pwhse          s              3  0
     d $pitem          s             15
     d $pslot          s             12
     d $paisl          s              3
     d $ploc           s              3  0
     d $prlvl          s              2  0
     d $phand          s              2
     d $prtn           s              8
     *
     ** Global User Defined Fields
     *
     d gPlen           s              3  0
     d gPstr           s             60
     d gwhse           s              3  0
     d gfirst          s              1
     d gItmTyp         s              1
     d gItUmq2         s              3  0
     d gItUmq3         s              3  0
     d gItFlg1         s              1
     d gItFlg2         s              1
     d gQtyCmp         s              8  0
     d gPrtFlg         s              1
     d gKeyWhse        s              3  0
     d gKeyItem        s             15
     *
     *----------------------------------------------------------------
     *  Customer id
     *
      *****   /COPY QCOPYSRC,ID#TPC
     *----------------------------------------------------------------
     *
     ** Process Report
     *
     c     *loval        setll     impfpqty
     c                   dou       %eof(impfpqty)
     c                   read      impfpqty
     c                   if        %eof(impfpqty)
     c                   leave
     *
     c                   else
     *
     ** Setup Key and Report Work Fields
     *
     c                   eval      r#Item = ijItem
     c                   eval      gKeyWhse = ijWhse
     c                   eval      gKeyItem = ijItem
     *
     ** Process Report Headings
     *
     c                   if        gFirst = *on or *in90
     c                   callp     prZrHead
     c                   endIf
     *
     ** Retrieve Item Information
     *
     c                   callp     prGetItmInf
     *
     ** Retrieve Pick Slot
     *
     c                   eval      r#Slot = prGetPckSlt
     *
     ** Setup Breakdown Item Qty to Total Eaches.
     *
     c                   if        gItmTyp = cBrkDwn
     c                   callp     prZzCvQy
     c                   endIf
     *
     ** Compare Quantities
     *
     c                   callp     prProQtyCmp
     *
     ** Write detail line.
     *
     c                   select
     *
     c                   when      gPrtFlg = cYes
     c                   write     detail1
     *
     c                   when      gPrtFlg = cNo
     c                   write     detail2
     *
     c                   endSl
     *
     c                   endIf
     *
     c                   endDo
     *
     c                   callp     prPrcPirItm
     *
     c                   if        gFirst = *off
     c                   write     foot1
     c                   endIf
     *
     c                   eval      *inlr = *on
     *
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     **         *INZSR  Initialization subroutine
     *
     c     *inzSr        begSr
     *
     ** Get client id.
     *
     c                   call      'GETCLIENT'
     c                   parm                    client           10
     c                   parm                    clientloc        10
     *
     ** Define key for files IMPFPQTY / PIRITEM
     *
     c     keyOne        klist
     c                   kfld                    gKeyWhse
     c                   kfld                    gKeyItem
     *
     c                   time                    time
     *
     c                   eval      gFirst = *on
     *
     c                   move      *all'_'       gBreak
     *
     c                   endSr
     *
     *****************************************************************
     ** Retrieve Item Information - Description / Type
     *****************************************************************
     *
     p prGetItmInf     b
     d  prGetItmInf    pi
     *
     c                   eval      r#Desc = *blanks
     *
     c     keyOne        chain     pirItem
     c                   if        %found
     c                   eval      r#Desc = itDesc
     c                   eval      gItmTyp = itType
     c                   eval      gItUmQ2 = itUmQ2
     c                   eval      gItUmQ3 = itUmQ3
     c                   eval      gItFlg1 = itFlg1
     c                   eval      gItFlg2 = itFlg2
     c                   else
     c                   eval      r#Desc = cNotFnd
     c                   eval      gItmTyp = *blank
     c                   eval      gItUmQ2 = *zeros
     c                   eval      gItUmQ3 = *zeros
     c                   eval      gItFlg1 = *blank
     c                   eval      gItFlg2 = *blank
     c                   endif
     *
     c                   return
     *
     P prGetItmInf     e
     *
     *****************************************************************
     ** Retrieve Pick Slot
     *****************************************************************
     *
     p prGetPckSlt     b
     d  prGetPckSlt    pi            12
     *
     c                   call      'GETPSLT'
     c                   parm                    $pCmd
     c                   parm      gKeyWhse      $pWhse
     c                   parm      gKeyItem      $pItem
     c                   parm      *blanks       $pSlot
     c                   parm      *blanks       $pAisl
     c                   parm      *zeros        $pLoc
     c                   parm      *zeros        $prLvl
     c                   parm      *blanks       $phand
     c                   parm      *blanks       $prtn
     *
     c                   return    $pSlot
     *
     P prGetPckSlt     e
     *
     *****************************************************************
     ** Process Dakota PIRITEM to Host IMPFPQTY compare
     *****************************************************************
     *
     p prPrcPirItm     b
     d  prPrcPirItm    pi
     *
     c                   eval      r#Desc = *blanks
     *
     c     *loval        setll     pirItem
     *
     c                   dou       %eof(pirItem)
     c                   read      pirItem
     c                   if        %eof(pirItem)
     c                   leave
     *
     c                   else
     *
     ** Process Report Headings
     *
     c                   if        gFirst = *on or *in90
     c                   callp     prZrHead
     c                   endIf
     *
     ** Setup Key Work Fields
     *
     c                   eval      gKeyWhse = itWhse
     c                   eval      gKeyItem = itItem
     *
     ** Setup Report Item Number/Desc Work Fields
     *
     c                   eval      r#Item = itItem
     c                   eval      r#Desc = itDesc
     *
     c     keyOne        chain     impfpqty
     c                   if        not %found
     *
     ** Retrieve Pick Slot
     *
     c                   eval      r#Slot = prGetPckSlt
     c                   write     detail3
     *
     c                   endif
     *
     c                   endif
     *
     c                   endDo
     *
     c                   return
     *
     P prPrcPirItm     e
     *
     *****************************************************************
     ** Compare Quantities
     *****************************************************************
     *
     p prProQtyCmp     b
     d  prProQtyCmp    pi
     *
     ** Procedure Only Related Work Fields
     *
     d pWrkQttl        s              8  0
     d pWrkJttl        s              8  0
     *
     c                   eval      gPrtFlg = cMatch
     *
     c     keyOne        chain     itemQty
     c                   if        %found
     *
     c                   select
     *
     c                   when      gItmTyp = *blank and gItUmq2 > 0
     c                                              and gItFlg1 = cYes
     c                   eval      pWrkQttl = iqStk1 * gItUmQ2
     c                   eval      pWrkQttl = pWrkQttl + iqStk2
     *
     c                   eval      pWrkJttl = ijtQh1 * gItUmQ2
     c                   eval      pWrkJttl = pWrkJttl + ijtQh2
     *
     c                   if        pWrkQttl <> pWrkJttl
     c                   eval      gQtyCmp = pWrkQttl - pWrkJttl
     c                   eval      gPrtFlg = cYes
     c                   endIf
     *
     c                   other
     *
     c                   eval      gQtyCmp = ijtQh1 - iqStk1
     *
     c                   if        gQtyCmp <> 0
     c                   eval      gPrtFlg = cYes
     c                   endIf
     *
     c                   endSl
     *
     c                   else
     *
     c                   eval      gprtFlg = cNo
     c                   endIf
     *
     c                   return
     *
     P prProQtyCmp     e
     *
     *****************************************************************
     ** Get/Format Wahehouse Description
     *****************************************************************
     *
     p prZrFrmt        b
     d  prZrFrmt       pi
     *
     ** Get warehouse description.
     *
     c                   eval      whse = *blanks
     c                   eval      gPstr = *blanks
     *
     c     gKeyWhse      chain     warehs
     c                   if        %found
     c                   movel     whDesc        gPstr
     c                   endif
     *
     c                   eval      gPlen = 30
     *
     ** Center warehouse description.
     *
     c                   call      'CENTER'
     c                   parm                    gPstr
     c                   parm                    gPlen
     c                   movel     gPstr         whse
     *
     c                   return
     *
     P prZrFrmt        e
     *
     *****************************************************************
     ** Write Report Headings
     *****************************************************************
     *
     p prZrHead        b
     d  prZrHead       pi
     *
     c                   if        gWhse <> gKeyWhse
     c                   callp     prZrFrmt
     c                   eval      gWhse = gKeyWhse
     c                   endIf
     *
     c                   eval      *in90 = *off
     c                   eval      gFirst = *off
     *
     c                   write     head1
     c                   write     columns
     *
     c                   return
     *
     P prZrHead        e
     *
     *****************************************************************
     ** Convert Total Cases to Total Eaches on Breakdown Items
     *****************************************************************
     *
     p prZzCvQy        b
     d  prZzCvQy       pi
     *
     c                   if        gITUmQ2 > 0
     c                   eval      ijTqh1 = ijTqh1 * gITUmQ2
     c                   endIf
     *
     c                   eval      ijTqh1 = ijTqh1 + ijTqh2
     *
     c                   eval      ijTqh2 = *zeros
     *
     c                   return
     *
     p prZzCvQy        e
