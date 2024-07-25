     f*----------------------------------------------------------------
     f*   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     f*   BFC Software, Inc.
     f*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     f*   West Chicago, IL  60185
     f*   (630) 562-0375
     f*----------------------------------------------------------------
     f*
     f*  SL745  FTP Export Slot Master - Post
     f*  01 Oct 2008
     f*  Chuck Manny
     f*
     f*  This program creates the Slot Master Export file EXPFSLTM
     f*  from the Dakota slot master file.
     f*
     f*----------------------------------------------------------------
     f*  Revisions
     f*
520 Af*   10/01/08  CWM  5.20
     f*     - Created
520aAf*   11/06/08  MLB  5.20a
     f*     - Fix: Revised record selection in program when virtual slots
     f*       are not to be included in export data.
     f*
700 Af*   12/05/16  MLB  7.00
     f*     - Enh: Revised pgm to retrieve slot dimensions from SLOTDEF
     f*       file using SLSDEF from SLOT file.
     f*
     f*----------------------------------------------------------------
     f*  Client Custom Revisions: XXXXXXX
     f*
     f*----------------------------------------------------------------
     f*  Indicator usage
     f*
     f*----------------------------------------------------------------
     f*  File Specs
     f*
     fslot8     if   e           k disk
700 Afslotdef   if   e           k disk
     fexpfSltm  o  a e           k disk
     f*
     d*----------------------------------------------------------------
     d*  Customer id
     d*
     d** /copy qcopysrc,xxxxxxxxxx
     d*
     d*
     d*----------------------------------------------------------------
     d*  Called programs
     d*
     d @cvtdt          c                   'CVTDTE'
     d*
     d*----------------------------------------------------------------
     d*
     d*  Passed In Parms Definitions
     d*
     d $pWhse          s              3
     d $pWhdp          s              5
     d $pStyp          s              1
     d $pIvrt          s              1
     d*
     d*----------------------------------------------------------------
     d*
     d*  Internally Defined Work Fields
     d*
     d wkItem          s             10
     d wkWhse          s              3  0
     d*
     d*----------------------------------------------------------------
     d*  Called program parameters
     d*
     d $CVTDT          DS
     d  $CVCMD                 1      8
     d  $CVPRG                 9     18
     d  $CVD6I                19     24
     d  $CVD8I                25     32
     d  $CVD6O                33     38  0
     d  $CVD8O                39     46  0
     d  $CVSTO                47     64
     d  $CVRTN                65     72
     d  $CVERM                73    132
     d  $CVMSG                73     76
     d*
     d*----------------------------------------------------------------
     d*  Program info data structure
     d*
     d                SDS
     d  #PROG            *PROC
     d  #job                 244    253
     d  #user                254    263
     d  #jobn                264    269
     d  #jobdt               276    281  0
     d  #jobtm               282    287  0
     d*
     d*----------------------------------------------------------------
     c*
     c* Parameters
     c*
     c*    Input Parameters
     c*
     c*      $pWhse  Warehouse
     c*      $pWhdp  Warehouse department or *ALL
     c*      $pStyp  Section type (F,P,B)
     c*      $pIvrt  Include Virtual Slots  (Y,N)
     c*    Returned Parameters
     c*      None
     c*
     c*----------------------------------------------------------------
     c*  Let the show begin .....
     c*
     c     *entry        plist
     c                   parm                    $pWhse
     c                   parm                    $pWhdp
     c                   parm                    $pStyp
     c                   parm                    $pIvrt
     c*
     c                   move      $pWhse        wkWhse
     c*
     c*----------------------------------------------------------------
     c*
     c* Main line
     c*
     c* Set To Starting Point In File
     c*
     c                   if        $pWhdp = '*ALL'
     c     keySlt1       setll     slot8
     c                   else
     c     keySlt2       setll     slot8
     c                   endIf
     c*
     c* Read Slot File
     c*
     c                   dou       %eof
     c                   if        $pWhdp = '*ALL'
     c     keySlt1       Reade     slot8
     c                   else
     c     keySlt2       Reade     slot8
     c                   endif
     c*
     c* EOF or Dept
     c*
     c                   if        %eof or
     c                                $pWhdp <> '*ALL' and
     c                                   slWhdp <> $pWhdp
     c                   leave
     c                   endif
     c*
     c* Invalid Section Type
     c*
     c                   if        $pStyp <> 'B' and
     c                              slsTyp <> $pStyp
     c                   iter
     c                   endif
700 Ac*
700 Ac* Retrieve slot type
700 AC     keysd         chain     slotdef
700 AC                   if        not %found(slotdef)
700 AC                   eval      sdlen  = 0
700 AC                   eval      sdwdth = 0
700 AC                   eval      sdhgt  = 0
700 AC                   endif
     c*
     c* Clear Export Record
     c*
     c                   clear                   smRec
     c*
     c* Load Record To Export File
     c*
     c                   select
     c*
520aDc*                  when      $pIvrt = 'N' and slStat <> 'V '
520aMc                   when      $pIvrt = 'N' and slRsrv <> 'V'
     c                              or $pIvrt = 'Y'
     c*
     c                   exsr      zzFill
     c*
     c                   exsr      zzWrt
     c*
     c                   endSl
     c*
     c* Write Export File Record
     c*
     c                   endDo
     c*
     c                   eval      *inlr = *on
     c*
     c                   return
     c*
     c*----------------------------------------------------------------
     c*
     c*          Subroutines In Alphabetical Order
     c*
     c*----------------------------------------------------------------
     c*
     c*  *INZSR  Initialization subroutine
     c*
     c     *inzSr        begSr
     c*
     c* Get client id.
     c*
     c                   call      'GETCLIENT'
     c                   parm                    client           10
520aAc                   parm                    clientloc        10
     c*
     c* SLOT8 - Slot Master File
     c*
     c     keySlt1       klist
     c                   kfld                    wkWhse
     c*
     c* SLOT8 - Slot Master File
     c*
     c     keySlt2       klist
     c                   kfld                    wkWhse
     c                   kfld                    $pWhdp
700 Ac*
700 Ac* SLOTDEF - Slot Def File
700 Ac*
700 Ac     keysd         klist
700 Ac                   kfld                    wkWhse
700 Ac                   kfld                    slsdef
     c*
     c* Convert Today's Date Into Century Format.
     c*
     c                   move      '*CURCMD '    $cvCmd
     c                   call      @cvtDt
     c                   parm                    $cvtDt
     c                   z-add     $cvd8O        toDay             8 0
     c*
     c                   endSr
     c*
     c*----------------------------------------------------------------
     c*
     c* Write Export Slot File Record
     c*
     c     zzWrt         begSr
     c*
     c* Write Record
     c*
     c                   write     smrec
     c*
     c                   endSr
     c*
     c*----------------------------------------------------------------
     c*
     c*  Load and Write Export Slot File From Current Record
     c*
     c     zzFill        begSr
     c*
     c                   eval      smWhse = SlWhse
     c                   eval      smDisp = SlDisp
     c                   eval      smAisl = SlAisl
     c                   eval      smLoc  = SlLoc
     c                   eval      smRlvl = SlRlvl
     c                   eval      smHand = SlHand
     c                   eval      smPick = SlPick
     c                   eval      smrSrv = slrSrv
     c                   eval      smpSeq = slpSeq
     c                   eval      smsTyp = slsTyp
     c                   eval      smsDef = slsDef
     c                   eval      smDesg = slDesg
     c                   eval      smActv = slActv
     c                   eval      smBld  = slBld
     c                   eval      smWhdp = slWhdp
700 Ac*
700 Ac                   eval      smlen  = sdlen
700 Ac                   eval      smwdth = sdwdth
700 Ac                   eval      smhgt  = sdhgt
     c*
     c                   endSr
     c*
     c*----------------------------------------------------------------
