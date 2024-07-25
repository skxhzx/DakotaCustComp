     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PIRLLP#     Get next PIR Internal Lot/License number
     *  31 December 2002
     *  Max Blacknik
     *
     *
     *----------------------------------------------------------------
     *  Revisions
     *
417 A*    12/31/02  MLB  4.17
     *      - Created.
640aA*    07/17/12  RTR  6.40a
     *      - Converted to RPGLE.
     *      - Changed to print lock info if data area is locked, and
     *        after retrying display screen to user with lock info.
640bA*    08/17/12  MLB  6.40b
     *      - Fix: Change to 6.40a mod. Revised pgm to make PIRLLP#FM
     *        user controlled open so that only interactive jobs will
     *        open display file.
     *
640cA*    09/12/12  RTR  6.40c
     *      - Fix: Change to 6.40b mod. Added close for screen.
     *      - Enh: Changed screen to PIRLOCKFM generic screen.
     *
700 A*    07/20/15  DAS/MLB  7.00
     *      - Fix: Revised routine, LOCKBATCH to seton ind 90 if
     *        unable to perform IN operation on #NEXT *dtaara. This
     *        is a patch in an attempt to prevent "Unable to allocate
     *        object" error from occuring when pick transactions are
     *        closed via GUI TruckBuilder(r).
700aA*    07/21/15  DAS/MLB  7.00a
     *      - Fix: Revised program to add 2 additional attempts
     *        to perform OUT operation if ind 90 is on and print
     *        lock reports, if unsuccessful.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *
     *----------------------------------------------------------------
     *
     *  File specs
     *
     *----------------------------------------------------------------
     *
     *  Subprogram parameters
     *
     *    Input Parameters
     *    - None -
     *
     *    Returned Parameters
     *    $NXTNM  Next PIR Internal lot/license number (guarenteed to be
     *            unique; not guarenteed to be the next used in
     *            sequence; 000000 is not used)
     *
640aA*----------------------------------------------------------------
640cMFpirlockfm cf   e             workstn usropn
640aA*
640aA*----------------------------------------------------------------
640aA* Variables
640aA*
640aAD prtobjnam       s             10a
640aAD prtobjtyp       s             10a
640aAD retrys          s              3  0
640aAD rtnobjnam       s             20a
640aAD rtnobjtyp       s             10a
640aAD rtnlkjnam       s             10a
640aAD rtnlkjusr       s             10a
640aAD rtnlkjnum       s              6a
640cA*
640cA*----------------------------------------------------------------
640cA* Constants
640cA*
640cAd errmsg          c                   'ERROR CREATING LICENSE'
640aA*
640aA* System API: Retrieve User Job Attributes
640aAd Format          s              8
640aAd RcvVarLen       s             10i 0
640aAd dsJobDta        ds
640aAd  dsJobBytesRtn                10I 0
640aAd  dsJobBytesAvl                10I 0
640aAd  dsJobName                    10A
640aAd  dsJobUser                    10A
640aAd  dsJobNumber                   6A
640aAd  dsJobIntern                  16A
640aAd  dsJobStatus                  10A
640aAd  dsJobType                     1A
640aAd  dsJobSubtype                  1A
640aAd  dsJobReserv1                  2A
640aAd  dsJobRunPty                  10I 0
640aAd  dsJobTimeSlc                 10I 0
640aAd  dsJobDftWait                 10I 0
640aAd  dsJobPurge                   10A
640aA*
640aA*----------------------------------------------------------------
640aA* Called Programs
640aA*
640aAD prtlck          pr                  extpgm('PRTOBJLCK')
640aAD   prtobjn                     10a
640aAD   prtobjt                     10a
640aAD   prtljna                     10a
640aAD   prtljus                     10a
640aAD   prtljnu                      6a
640aA*
640aA* Retrieve lock information
640aAD rtnlckinf       pr                  extpgm('RTNLCKINF')
640aAD   rtnobjn                     20a
640aAD   rtnobjt                     10a
640aAD   rtnljna                     10a
640aAD   rtnljus                     10a
640aAD   rtnljnu                      6a
640aA*
640aA* System API: Retrieve User Job Info
640aAd getjobinfo      pr                  extpgm('QUSRJOBI')
640aAd   DsJob                             like(DsJobDta)
640aAd   Length                      10i 0 const
640aAd   APIFormat                    8    const
640aAd   ApiJob                      26    const
640aAd   InternJob                   16    const
     *
     *----------------------------------------------------------------
     * Main Line
     *
     C     *entry        plist
     C                   parm                    $nxtnm            7 0
     *
     C     *dtaara       define    pirllp#       next#             7 0
640aA*
640aAC                   select
640aAC                   when      dsjobtype = 'I'
640aAC                   exsr      lockinter
640aAC                   other
640aAC                   exsr      lockbatch
640aAC                   endsl
640aA*
     *
     *  Data area contains the next sequence number to use.
     *
     *  Return the unique sequence number.
     *
640aAC                   if        not *in90
     C                   eval      $nxtnm = next#
     *
     *  Update the data area with the next number to be used.
     *  Note: 9999999 and 0 are not allowed.
     *
     C                   add       1             next#
     C                   select
     C                   when      next# = 9999999
     C                   eval      next# = 1
     C                   when      next# = 0
     C                   add       1             next#
     C                   endsl
     *
700aDC*                  out       next#
700aMC                   out       next#                                90
700aA*
700aAC                   if        *in90 = '1'
700aAC                   exsr      getlock
700aAC                   exsr      prtlock
700aAC                   out       next#                                90
700aA*
700aAC                   if        *in90 = '1'
700aAC                   exsr      getlock
700aAC                   exsr      prtlock
700aAC                   out       next#                                90
700aA*
700aAC                   if        *in90 = '1'
700aAC                   exsr      getlock
700aAC                   exsr      prtlock
700aAC                   endif
700aA*
700aAC                   endif
700aA*
700aAC                   endif
700aA*
640aAC                   endif
     *
     C                   return
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
640aA /Free
640aA     // Return current job info to see if batch or inter
640aA     Format = 'JOBI0100';
640aA     RcvVarLen = %Size(DsJobDta);
640aA     getjobinfo(dsjobdta : rcvvarlen : Format : '*' : ' ');
640aA /end-free
     *
     C                   endsr
640aA*
640aA*----------------------------------------------------------------
640aA*
640aA*  DSPLOCK  Display lock information
640aA*
640aA /Free
640aA   begsr dsplock;
640aA
640cA     if not %open(pirlockfm);
640cA       open pirlockfm;
640bA     endif;
640aA
640aA     w1jnam = rtnlkjnam;
640aA     w1jusr = rtnlkjusr;
640aA     w1jnum = rtnlkjnum;
640aA
640aA     dou *inkf = *on;
640cA       w1jmsg = errmsg;
640aA       exfmt screen1;
640aA     enddo;
640aA
640cA     if %open(pirlockfm);
640cA       close pirlockfm;
640cA     endif;
640aA
640aA   endsr;
640aA
640aA /end-free
640aA*
640aA*----------------------------------------------------------------
640aA*
640aA*  GETLOCK  Get lock information
640aA*
640aAC     getlock       begsr
640aA*
640aAC                   eval      rtnobjnam = 'PIRLLP#   *LIBL     '
640aAC                   eval      rtnobjtyp = '*DTAARA   '
640aAC                   eval      rtnlkjnam = *blanks
640aAC                   eval      rtnlkjusr = *blanks
640aAC                   eval      rtnlkjnum = *blanks
640aA*
640aAC                   callp(e)  rtnlckinf(rtnobjnam: rtnobjtyp:
640aAC                                       rtnlkjnam: rtnlkjusr: rtnlkjnum)
640aA*
640aAC                   endsr
640aA*
640aA*----------------------------------------------------------------
640aA*
640aA*  LOCKBATCH   Batch - Lock and retrieve data area
640aA*
640aAC     lockbatch     begsr
640aA*
640aAC                   eval      $nxtnm = 0
640aA*
640aAC     *lock         in        next#                                90
640aAC                   if        not *in90
640aAC                   leavesr
640aAC                   endif
640aA*
640aAC     *lock         in        next#                                90
640aAC                   if        not *in90
640aAC                   leavesr
640aAC                   endif
640aA*
640aAC                   exsr      getlock
640aAC                   exsr      prtlock
700 DC*    *lock         in        next#
700 MC     *lock         in        next#                                90
640aA*
640aAC                   endsr
640aA*
640aA*----------------------------------------------------------------
640aA*
640aA*  LOCKINTER   Interactive - Lock and retrieve data area
640aA*
640aAC     lockinter     begsr
640aA*
640aAC                   eval      $nxtnm = 0
640aAC                   eval      retrys = 0
640aAC                   seton                                        90
640aAC                   dou       not *in90
640aAC     *lock         in        next#                                90
640aA*
640aAC                   if        not *in90
640aAC                   leave
640aAC                   endif
640aA*
640aAC                   if        retrys >= 2
640aAC                   exsr      getlock
640aAC                   exsr      prtlock
640aAC                   exsr      dsplock
640aAC                   endif
640aA*
640aAC                   add       1             retrys
640aAC                   enddo
640aA*
640aAC                   endsr
640aA*
640aA*----------------------------------------------------------------
640aA*
640aA*  PRTLOCK  Print lock information
640aA*
640aAC     prtlock       begsr
640aA*
640aAC                   eval      prtobjnam = 'PIRLLP#   '
640aAC                   eval      prtobjtyp = '*DTAARA   '
640aA*
640aAC                   callp     prtlck(prtobjnam: prtobjtyp:
640aAC                                    rtnlkjnam: rtnlkjusr: rtnlkjnum)
640aA*
640aAC                   endsr
640aA*
