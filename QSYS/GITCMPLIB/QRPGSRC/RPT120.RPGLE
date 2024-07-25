      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  RPT120 - Process Report Override Records
     *  07 Jan, 2009
     *  Chuck Manny
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
510 A*  01/07/09  CWM   5.20
     *   - Created.
     *
740 A*  04/16/20  KDE   7.40
     *   - Do not clear one time overrides for R30200.  PS313 will do this.
     *     Reason being is the GUI Truck Map is a MRC report and must have the
     *     device passed from PS313 to MRCRPTSCH instead of using overprtf
     *     parms
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  XX        XXXXXXXX XXXXXXXXX
     *
     *----------------------------------------------------------------
     *
     * ********************************
     ** File Specs
     * ********************************
     *
     frptOvrDtl if   e           k disk
     frptOvrL1  uf   e           k disk    rename(rdrec:wkrdrec)
     f                                     prefix(wk)
     *
     * ********************************
     ** Sub Procedure Prototypes
     * ********************************
     *
     *
     * ********************************
     ** Constants
     * ********************************
     *
     *
     * ********************************
     ** User Defined Work Fields
     * ********************************
     *
     d gwCtr           s              5  0 inz
     d wkCtr           s              5  0 inz
     d wkOne           s              1    inz('Y')
     *
     * ********************************
     ** Data Structure
     * ********************************
     *
     *
     *****************************************************************
     ** Program Entry
     *****************************************************************
     *
     c     *entry        plist
     c                   parm                    $prtf            10
     c                   parm                    $pCtr            15 5
     c                   parm                    $pCmd          1024
     c                   parm                    $pOne             1
     *
     *****************************************************************
     ** Process Report
     *****************************************************************
     *
     ** Process Spool File Using Over Ride Records
     *
     c                   z-add     $pCtr         wkCtr
     c                   eval      $pOne = *blank
     *
     c                   if        wkctr = 1
     c     keyone        chain     rptovrl1
     c                   if        %found(rptovrl1)
     c                   eval      $pCmd = wkRdOvr
740aAc                   if        $prtf <> 'R30200'
     c                   exsr      zzClnUp
740aAc                   endif
     c                   eval      $pOne = 'Y'
     c                   endif
     c                   endif
     *
     c                   if        wkctr <> 0 and $pOne = *blank
     c     $prtf         setll     rptOvrDtl
     c                   dou       %eof(rptOvrDtl)
     c     $prtf         reade     rptOvrDtl
     c                   if        %eof(rptOvrDtl)
     c                   eval      $pctr = *zeros
     c                   eval      $pCmd = *blanks
     c                   leave
     *
     c                   else
     *
     c                   eval      gwCtr = gwCtr + 1
     *
     c                   if        gwCtr = wkCtr
     c                   eval      $pCmd = rdOvr
     c                   leave
     c                   endIf
     *
     c                   endIf
     *
     c                   endDo
     *
     c                   endIf
     *
     c                   eval      *inlr = *on
     *
     *****************************************************************
     **         *INZSR  Initialization subroutine
     *****************************************************************
     *
     c     *inzSr        begSr
     *
     ** Define key
     *
     c     keyOne        klist
     c                   kfld                    $prtf
     c                   kfld                    wkone
     *
     c                   endSr
     *
     *****************************************************************
     **  ZZCLNUP  Cleanup 1 Time Over Ride Records
     *****************************************************************
     *
     c     zzClnUp       begSr
     *
     ** Read Report Over Ride Records and Delete 1 timers
     *
     c     keyone        setll     rptOvrl1
     c                   dou       %eof(rptOvrl1)
     c     keyone        reade     rptOvrl1
     c                   if        %eof(rptOvrl1)
     c                   leave
     *
     c                   else
     *
     c                   if        %found(rptOvrl1)
     c                   delete    wkRdRec
     c                   leave
     c                   endif
     *
     c                   endIf
     *
     c                   endDo
     *
     c                   endSr
     *
     *****************************************************************
     *
