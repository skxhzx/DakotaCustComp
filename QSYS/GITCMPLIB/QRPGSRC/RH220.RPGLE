     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RH220  Will call - Allocate, pick & print
     *  27 August 1997
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
411 A*    05/04/99  DAS  4.11
     *      - Revised to look for a specific route id that is passed in.
     *      - Revised to use RTEHED3 instead of RTEHED2.
     *
500 A*    02/06/06  MLB  5.00
     *      - Enh: Revised program to add client custom code support.
     *
650 A*    04/19/13  MLB  6.50
     *      - Enh: Converted program to ile.
650aA*    04/19/13  MLB  6.50a
     *      - Fix: Revised program to clear Route Inuse flag upon
     *        successful completion of will-call route processing.
     *
650b *    03/24/13  DAS  6.50b
     *      - Revised to use CHKIUSE2.
     *      - No longer uses rhshpd for inuse flag.
     *      - Requires new CHKIUSE2 progam and new RTEINUSE file.
     *
750aA*    02/22/21  DAS  7.50a
     *      - Revised to create RTEHEDEXA record if it doesn't exist
     *        or to update TBType if blank.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: European Imports
     *
EI  A*    02/06/06  MLB  EI
     *      - Revised program to remove route id from full key used
     *        to extract route id to process, just process all Open
     *        Will Call routes.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Chain Indicator
     *  98        Error on screen (Sound Buzzer)
     *  99        Universal Record Indicator (Very Temporary Usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
411 D*TEHED2 IF  E           K        DISK
411 MFrtehed3   if   e           k disk
     F                                     rename(rhrec:record)
500 A*----------------------------------------------------------------
500 A*  Customer id
500 A*
     D @getcl          c                   const('GETCLIENT')
500 A*
EI  AD/COPY QCOPYSRC,ID#EI

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

750aA /copy qcopysrc,c#stdvar

650 A*----------------------------------------------------------------
650 A*  Working variables
650 A*
     D forevr          s              1
     D kyrtid          s                   like(rhrtid)
     D kystat          s                   like(rhstat)
     D kytype          s                   like(rhtype)
     D kywhse          s                   like(rhwhse)
750 AD pmessage        s             80

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

750aA /copy qcopysrc,p.exrtehed
750aA /copy qcopysrc,p.gettbtyp
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
     *  Parameters
     *
     *    Input Parameters
     *      $PWHS   Warehouse
     *      $PTRUK  Truck
     *      $PJTYP  0 - Batch
     *              1 - Interactive
     *      $PPRG   Calling program to send messages to.
411 A*      $PRTID  Route id to process.
     *
     *    Returned Parameters
     *      $RTNCD  *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhs            15 5
     C                   parm                    $ptruk           10
     C                   parm                    $pjtyp            1
     C                   parm                    $pprg            10
411 AC                   parm                    $prtid            5
     C                   parm                    $prtn             8
     *----------------------------------------------------------------
     *  Main line
     *
     *  Loop through open will call routes.
     *
     C                   z-add     $pwhs         kywhse
     C                   eval      kytype = 'W'
     C                   eval      kystat = *on
411 AC                   eval      kyrtid = $prtid
411 D*          KEYRH2    SETLLRTEHED2
EI  AC                   if        client = ei
EI  AC     keyr3e        setll     rtehed3
EI  AC                   else
411 MC     keyrh3        setll     rtehed3
EI  AC                   endif
     *
     C                   dow       forevr = forevr
411 D*          KEYRH2    READERTEHED2                  79
EI  AC                   if        client = ei
EI  AC     keyr3e        reade     rtehed3                                79
EI  AC                   else
411 MC     keyrh3        reade     rtehed3                                79
EI  AC                   endif
     C                   if        *in79
     C                   leave
     C                   endif
750aA
750aA /free
750aA    // Make sure TruckBuilder Processing Type is defined
750aA
750aA    exsr chkTBType;
750aA    if error;
750aA      iter;
750aA    endif;
750aA /end-free
     *
     *     Call program to allocate, pick and print route.
     *
     C                   call      'OR605'
     C                   parm      '*PICK   '    $bcmd             8
     C                   parm      '*ALL    '    $bcmd2            8
     C                   parm      '*WCPICK1'    $btype            8
     C                   parm      $pjtyp        $bjtyp            1
     C                   parm      $pwhs         $bwhs            15 5
     C                   parm      0             $bbat             7 0
     C                   parm      ' '           $bstat            1
     C                   parm      rhrtid        $brtid            5
     C                   parm      0             $bord             7 0
     C                   parm      0             $brwhs            3 0
     C                   parm      ' '           $btrte            5
     C                   parm      ' '           $brtn             8
     C                   parm      ' '           $bmsg             4
     C                   parm      $pprg         $bprg            10
     *
     *     Error occured - Error message sent to program msgq
     *
     C                   if        $brtn = '*PGMQ   '
     C                   leave
650aAC                   else
650aAC                   exsr      zziuse
     C                   endif
     *
     C                   enddo
     *
     C                   seton                                        lr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
500 A*
500 A*  Get client id
500 A*
500 AC                   call      @getcl
500 AC                   parm                    client           10
500 AC                   parm                    cliloc           10
500 A*
     C                   eval      forevr = *on
     *
     *  Define partial key for main file (if needed).
     *
411 D*R         KEYRH2    KLIST
411 MC     keyrh3        klist
     C                   kfld                    kywhse
     C                   kfld                    kystat
     C                   kfld                    kytype
411 AC                   kfld                    kyrtid
EI A *
EI  AC     keyr3e        klist
EI  AC                   kfld                    kywhse
EI  AC                   kfld                    kystat
EI  AC                   kfld                    kytype
     *
     C                   endsr

750aA*----------------------------------------------------------------
750aA*  ChkTBType   Check to make TruckBuilder type exists
750aA*----------------------------------------------------------------
750aA
750aA /free
750aA  begsr ChkTBType;

         // Get RTEHEDEX info. Get out if call error.

         monitor;
           exWhse = rhWhse;
           EXRTEHED('*GET': exRtnCode: exRtnMsg:
                    exWhse: rhRtid: rhatbtype);
         on-error;
           leavesr;
         endmon;

         // Get out if TBType defined

         if rhatbtype <> '';
           leavesr;
         endif;

         // Get default TB type

         monitor;
           GetTBType(rhWhse: rhRtid: rhatbtype);
           if rhatbtype = 'B';
             rhaTbtype = 'E';
           endif;
         on-error;
           error = *on;
           pMessage = 'Error getting TB Processing Type (GetTBType)';
           leavesr;
         endmon;

         // Update/Add TB Type

         monitor;
           if exRtnCode <> '*ERROR';
             EXRTEHED('*CHANGE': exRtnCode: exRtnMsg:
                      exWhse: rhRtid: rhatbtype);
           else;
             EXRTEHED('*ADD': exRtnCode: exRtnMsg:
                      exWhse: rhRtid: rhatbtype);
           endif;
         on-error;
           error = *on;
           pMessage = 'Error updating TB Processing Type (GetTBType)';
           leavesr;
         endmon;

       endsr;
      /end-free
650aA*
650aA*----------------------------------------------------------------
650aA*
650aA*  ZZIUSE   Set Inuse flag for route before proceeding.
650aA*
650aAC     zziuse        begsr
650aA*
650aAC                   eval      $icmd = '*CLEAR  '
650bDC**                 call      'CHKIUSE'
650bDC**                 parm                    $icmd             8
650bDC**                 parm      rhwhse        $iwhse            3 0
650bDC**                 parm      rhrtid        $irtid            5
650bDC**                 parm      *blanks       $irtn             8

650bAC                   call      'CHKIUSE2'
650bAC                   parm                    $icmd             8
650bAC                   parm      rhwhse        $iwhse            3 0
650bAC                   parm      rhrtid        $irtid            5
650bAC                   parm      #prog         $ipgm            20
650bAC                   parm      ''            $iuser           10
650bAC                   parm      ''            $isessid         40
650bAC                   parm                    $irtn             8
650bAC                   parm                    $itext10         10
650bAC                   parm                    $itext30         30
650bAC                   parm                    $iucmd            8
650bAC                   parm                    $iupgm           20
650bAC                   parm                    $iuuser          10
650bAC                   parm                    $iuSessId        40
650bAC                   parm                    $iuJobName       10
650bAC                   parm                    $iuJobNbr         6
650bAC                   parm                    $iuJobUser       10
650bAC                   parm                    $iuStamp         26
650aA*
650aAC                   endsr
650aA*
