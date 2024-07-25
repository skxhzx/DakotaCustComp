     F*----------------------------------------------------------------
     F*   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     F*   West Chicago, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  IV775     Post item adjustments to slot catchweight export file
     F*  12 June 2006
     F*  MAx Blacknik
     F*
     F*----------------------------------------------------------------
     F*  Revisions
510 AF*    06/12/06  MLB  5.10
     F*      - Created.
     F*      - Included client custom code support.
510aAF*    06/08/07  MLB  5.10a
     F*      - Revise program to process ITEMADJ2 and add records
     F*        to EXPSCW if item/slot not found in file.
     F*
520 AF*    05/05/08  MLB  5.20
     F*      - Fix: Revised program to update non-catchweight item
     F*        adjustment records as exported so that they are not
     F*        processed on Host.
     F*
     F*----------------------------------------------------------------
     F*  Notes
     F*
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
510aDF*expscw    UF   E           K DISK
510aMFexpscw    UF A E           K DISK
     Fitemadj2  UF   E           K DISK
510aAFslot2     if   e           k disk
     D*----------------------------------------------------------------
     D*  Client ID's
     D*
JOR AD/COPY QCOPYSRC,ID#JORDANO
     D*
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D*----------------------------------------------------------------
     D*  Working variable(s)
     D $pwhse          s              3  0
510aAD forever         s              1    inz('1')
     D totalwgt        s              9  2
     D today           s              8  0
     D todayhms        s              6  0
     D*
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD8I                25     32
     D  $CVD6O                33     38  0
     D  $CVD8O                39     46  0
     D  $CVSTO                47     64
     D  $CVRTN                65     72
     D  $CVERM                73    132
     D  $CVMSG                73     76
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
     D                 DS
     D  $EC                    1      2P 0
     D*----------------------------------------------------------------
     D*  Message control
     D*
     D #MSGF           C                   CONST('PIRMSGF   ')
     D*
     D                 DS
     D  #MSGDT                 1    128
     D  $MD                    1    128
     D                                     DIM(128)
     D*----------------------------------------------------------------
     D*  Program info data structure
     D*
     D                SDS
     D  #PROG            *PROC
     D  #JOB                 244    253
     D  #USER                254    263
     D  #JOBN                264    269
     D  #JOBDT               276    281  0
     D  #JOBTM               282    287  0
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PWHSE  Warehouse
     C*      $PWHDP  Warehouse department
     C*
     C*    Returned Parameters
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PWHS             3
     C                   PARM                    $PWHDP            5
     C*----------------------------------------------------------------
     C*  Main line
     C*
     C                   select
     C*      Process all departments
     C                   when      $pwhdp = '*ALL'
510aDC*                  exsr      zzall
510aAC                   exsr      zzall_adj
     C
     C*      Process single department
     C                   when      $pwhdp <> '*ALL '
510aDC*                  exsr      zzdept
510aAC                   exsr      zzdept_adj
     C
     C                   endsl
     C
     C                   eval      *inlr = *on
     C*----------------------------------------------------------------
     C*
     C*          Subroutines in Alphabetical Order
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subroutine
     C*
     C     *INZSR        BEGSR
     C*
     C* Move warehouse into numeric field.
     C                   move      $pwhs         $pwhse
     C*
     C* Get client id.
     C*
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C*
     C*  Define keys.
     C*
     C*    EXPSCW file (Partial key)
     C*
     C     keyevw        KLIST
     C                   KFLD                    $pwhse
     C                   KFLD                    $pwhdp
510aAC     keyevwa       KLIST
510aAC                   KFLD                    $pwhse
510aAC                   KFLD                    iawhdp
510aAC                   KFLD                    iadisp
510aAC                   KFLD                    iaitem
     C*
     C*    ITEMADJ2 file
     C*
     C     *like         define    iacode        kycode
     C     keyia2        KLIST
     C                   KFLD                    $pwhse
     C                   KFLD                    kycode
     C                   KFLD                    evwwhd
     C                   KFLD                    evwdsp
     C                   KFLD                    evwitm
510aAC*
510aAC*    ITEMADJ2 file
510aAC*
510aAC     keyia2a       KLIST
510aAC                   KFLD                    $pwhse
510aAC                   KFLD                    kycode
510aAC*
510aAC     keyia2b       KLIST
510aAC                   KFLD                    $pwhse
510aAC                   KFLD                    kycode
510aAC                   KFLD                    $pwhdp
510aAC*
510aAC*    SLOT2 file
510aAC*
510aAC     keysl2        KLIST
510aAC                   KFLD                    $pwhse
510aAC                   KFLD                    iawhdp
510aAC                   KFLD                    iadisp
     C*
     C*  Convert today's date into century format.
     C*
     C                   MOVE      '*CURCMD '    $CVCMD
     C                   CALL      'CVTDTE'
     C                   PARM                    $CVTDT
     C*
     C                   Z-ADD     $CVD8O        today
     C                   time                    todayhms
     C*
     C                   ENDSR
     *
     *----------------------------------------------------------------
     *  ZZALL  - Process all departments
     *
     C     zzall         begsr
     *
     C                   select
     *      Set item adjustment code to search.
     C                   when      client = jordanos
     C                   eval      kycode = '70'
     C                   endsl
     C
     C     $pwhse        setll     expscw
     C     $pwhse        reade     expscw
     C                   dow       not %eof(expscw)
     *
     *      Position to search for open adjustments.
     C                   eval      totalwgt = 0
     C     keyia2        setll     itemadj2
     C     keyia2        reade     itemadj2
     C                   dow       not %eof(itemadj2)
     C                   if        iaudte = 0
     C                   eval      totalwgt = totalwgt + iacwta
     *      Update export date/time.
     C                   eval      iaudte = today
     C                   eval      iautim = todayhms
     C                   update    iarec
     C                   endif
     *
     C     keyia2        reade     itemadj2
     C                   enddo
     *
     *      Apply total weight adjustment to export weights.
     C                   eval      evwwgt = evwwgt + totalwgt
     C                   update    evwrec
     *
     *      Get next slot catchweight export record.
     C     $pwhse        reade     expscw
     C                   enddo
     *
     CSR                 ENDSR
510aA*
510aA*----------------------------------------------------------------
510aA*  ZZALL_ADJ  - Process all departments w/ITEMADJ as Primary.
510aA*
510aaC     zzall_adj     begsr
510aA*
510aAC                   select
510aA*      Set item adjustment code to search.
510aAC                   when      client = jordanos
510aAC                   eval      kycode = '70'
510aAC                   endsl
510aAC
510aAC     keyia2a       setll     itemadj2
510aAC                   dow       forever = forever
510aAC     keyia2a       reade     itemadj2
510aA*
510aAC                   select
510aAC                   when      %eof(itemadj2)
510aAC                   leave
510aAC
510aAC                   when      iaudte > 0
510aAC                   iter
520 AC
520 A*      Non-Catchwgt Item adjustment entry not processed.
520 AC                   when      iaudte = 0
520 AC                             and iacwta = 0
520 A*
520 A*      Update export date/time on adjustment record.
520 AC                   eval      iaudte = today
520 AC                   eval      iautim = todayhms
520 AC                   update    iarec
510aAC
510aA*      Item adjustment entry not processed.
510aAC                   when      iaudte = 0
510aAC                             and iacwta <> 0
510aA*      Update export catchweight file.
510aAC                   exsr      zzexpwgt
510aA*
510aAC                   endsl
510aAC                   enddo
510aA*
510aAC                   Endsr
     *
     *----------------------------------------------------------------
     *  ZZDEPT - Process single department
     *
     C     zzdept        begsr
     *
     C                   select
     *      Set item adjustment code to search.
     C                   when      client = jordanos
     C                   eval      kycode = '70'
     C                   endsl
     C
     C     keyevw        setll     expscw
     C     keyevw        reade     expscw
     C                   dow       not %eof(expscw)
     *
     *      Position to search for open adjustments.
     C                   eval      totalwgt = 0
     C     keyia2        setll     itemadj2
     C     keyia2        reade     itemadj2
     C                   dow       not %eof(itemadj2)
     C                   if        iaudte = 0
     C                   eval      totalwgt = totalwgt + iacwta
     *
     *      Once adjustment has been applied, update export date/time.
     C                   eval      iaudte = today
     C                   eval      iautim = todayhms
     C                   update    iarec
     C                   endif
     *
     C     keyia2        reade     itemadj2
     C                   enddo
     *
     *      Apply total weight adjustment to export weights.
     C                   eval      evwwgt = evwwgt + totalwgt
     C                   update    evwrec
     *
     *      Get next slot catchweight export record.
     C     keyevw        reade     expscw
     C                   enddo
     *
     C                   ENDSR
510aA*
510aA*----------------------------------------------------------------
510aA*  ZZDEPT_ADJ  - Process Single department w/ITEMADJ as Primary.
510aA*
510aaC     zzdept_adj    begsr
510aA*
510aAC                   select
510aA*      Set item adjustment code to search.
510aAC                   when      client = jordanos
510aAC                   eval      kycode = '70'
510aAC                   endsl
510aAC
510aAC     keyia2b       setll     itemadj2
510aAC                   dow       forever = forever
510aAC     keyia2b       reade     itemadj2
510aA*
510aAC                   select
510aAC                   when      %eof(itemadj2)
510aAC                   leave
510aAC
510aAC                   when      iaudte > 0
510aAC                   iter
520 AC
520 A*      Non-Catchwgt Item adjustment entry not processed.
520 AC                   when      iaudte = 0
520 AC                             and iacwta = 0
520 A*
520 A*      Update export date/time on adjustment record.
520 AC                   eval      iaudte = today
520 AC                   eval      iautim = todayhms
520 AC                   update    iarec
510aAC
510aA*      Item adjustment entry not processed.
510aAC                   when      iaudte = 0
510aAC                             and iacwta <> 0
510aA*      Update export catchweight file.
510aAC                   exsr      zzexpwgt
510aA*
510aAC                   endsl
510aAC                   enddo
510aA*
510aAC                   Endsr
510aA*
510aA*----------------------------------------------------------------
510aA*  ZZEXPWGT  - Update Export Catchweight file.
510aA*
510aaC     zzexpwgt      begsr
510aA*
510aAC     keyevwa       chain     expscw
510aAC                   select
510aAC                   when      not %found(expscw)
510aA*      Retrieve slot master info.
510aAC     keysl2        chain     slot2
510aAC                   if        not %found(slot2)
510aAC                   eval      slaisl = ' '
510aAC                   eval      slloc  = 0
510aAC                   eval      slrlvl = 0
510aAC                   eval      slhand = ' '
510aAC                   eval      slstyp = 'F'
510aAC                   eval      slside = 1
510aAC                   endif
510aAC
510aA*      Add catchweight record to export file.
510aAC                   clear                   evwrec
510aAC                   eval      evwwhs = iawhse
510aAC                   eval      evwdsp = iadisp
510aAC                   eval      evwwhd = iawhdp
510aAC                   eval      evwasl = slaisl
510aAC                   eval      evwloc = slloc
510aAC                   eval      evwlvl = slrlvl
510aAC                   eval      evwhnd = slhand
510aAC                   eval      evwstp = slstyp
510aAC                   eval      evwitm = iaitem
510aAC                   eval      evwsid = slside
510aAC                   eval      evwwgt = iacwta
510aAC                   write     evwrec
510aA*
510aAC                   when      %found(expscw)
510aAC                   eval      evwwgt = evwwgt + iacwta
510aAC                   update    evwrec
510aAC                   endsl
510aA*
510aA*      Update export date/time on adjustment record.
510aAC                   eval      iaudte = today
510aAC                   eval      iautim = todayhms
510aAC                   update    iarec
510aA*
510aAC                   Endsr
     O*----------------------------------------------------------------
     O*
     O*  Compile time tables
     O*
