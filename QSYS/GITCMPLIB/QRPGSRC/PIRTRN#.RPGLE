     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PIRTRN#     Get next PIR transaction number
     *  29 August 1994
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions:
500 A*    12/07/04  MLB  5.00
     *      - Enh: Revised program to not allow 0 or 9999999 trans-
     *        action number to be assigned.
     *
500aA*    12/06/05  MLB  5.00a
     *      - Fix: Revised program to ensure tran# doesn't exist
     *        in PIRTRAN.
     *
640aA*    09/11/12  RTR  6.40a
     *      - Converted to RPGLE.
     *      - Changed to print lock info if data area is locked, and
     *        after retrying display screen to user with lock info.
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
     *
     *  File specs
     *
640aAFpirlockfm cf   e             workstn usropn
     *RDH1   IF  E           K        DISK
500aAFpirtran   if   e           k disk
     *
     *----------------------------------------------------------------
640aA* Variables
640aA*
640aAd prtobjnam       s             10a
640aAd prtobjtyp       s             10a
640aAd retrys          s              3  0
640aAd rtnobjnam       s             20a
640aAd rtnobjtyp       s             10a
640aAd rtnlkjnam       s             10a
640aAd rtnlkjusr       s             10a
640aAd rtnlkjnum       s              6a
     d stop            s              1
640aA*
640aA*----------------------------------------------------------------
640aA* Constants
640aA*
640aAd errmsg          c                   'ERROR CREATING TRANS'
640aA*
     *----------------------------------------------------------------
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
640aAd prtlck          pr                  extpgm('PRTOBJLCK')
640aAd   prtobjn                     10a
640aAd   prtobjt                     10a
640aAd   prtljna                     10a
640aAd   prtljus                     10a
640aAd   prtljnu                      6a
640aA*
640aA* Retrieve lock information
640aAd rtnlckinf       pr                  extpgm('RTNLCKINF')
640aAd   rtnobjn                     20a
640aAd   rtnobjt                     10a
640aAd   rtnljna                     10a
640aAd   rtnljus                     10a
640aAd   rtnljnu                      6a
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
     *
     *  Subprogram parameters
     *
     *    Input Parameters
     *    - None -
     *
     *    Returned Parameters
     *    $NXTNM  Next PIR transaction number (guarenteed to be
     *            unique; not guarenteed to be the next used in
     *            sequence; 000000 is not used)
     *
     *----------------------------------------------------------------
     * Main Line
     *
     C     *entry        plist
     C                   parm                    $nxtnm            7 0
     C     *dtaara       define    pirtran       next#             7 0
640aA*
640aAC                   select
640aAC                   when      dsjobtype = 'I'
640aAC                   exsr      lockinter
640aAC                   other
640aAC                   exsr      lockbatch
640aAC                   endsl
     *
     *  Data area contains the next sequence number to use.  If it
     *  has already been used then keep adding 1 until we find one
     *  that hasn't been used (we will take the chance that all
     *  9999999 have not been used).
     *
640aAC                   if        not *in90
500aAC                   move      *off          stop
500aAC                   dou       stop = *on
500 A*
500 AC                   select
500 AC                   when      next# = 9999999
500 AC                   eval      next# = 1
500 AC                   when      next# = 0
500 AC                   add       1             next#
500 AC                   endsl
500aA*
500aAC     next#         setll     pirtran                                50
500aAC                   if        not *in50
500aAC                   move      *on           stop
500aAC                   else
500aAC                   add       1             next#
500aAC                   endif
500aAC                   enddo
     *
     *  Return the unique sequence number.
     *
     C                   eval      $nxtnm = next#
     *
     *  Update the data area with the next number to be used.
     *
     C                   add       1             next#
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
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
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
     *
     *  Define partial key for ORDH1.
     *
     *R         FILEKY    KLIST
     *R                   KFLD           OHPBAT
     *R                   ENDSR
640aA*
640aA*----------------------------------------------------------------
640aA*
640aA*  DSPLOCK  Display lock information
640aA*
640aA /Free
640aA   begsr dsplock;
640aA
640aA     RcvVarLen = %Size(DsJobDta);
640aA     Format = 'JOBI0100';
640aA
640aA     getjobinfo(dsjobdta : rcvvarlen : Format : '*' : ' ');
640aA
640aA     // Display screen if Interactive ONLY
640aA     if dsjobtype = 'I';
640aA        if not %open(pirlockfm);
640aA          open pirlockfm;
640aA        endif;
640aA
640aA       w1jnam = rtnlkjnam;
640aA       w1jusr = rtnlkjusr;
640aA       w1jnum = rtnlkjnum;
640aA
640aA       dou *inkf = *on;
640aA         w1jmsg = errmsg;
640aA         exfmt screen1;
640aA       enddo;
640aA
640aA       if %open(pirlockfm);
640aA         close pirlockfm;
640aA       endif;
640aA
640aA     endif;
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
640aAC                   eval      rtnobjnam = 'PIRTRAN   *LIBL     '
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
640aAC                   eval      prtobjnam = 'PIRTRAN   '
640aAC                   eval      prtobjtyp = '*DTAARA   '
640aA*
640aAC                   callp     prtlck(prtobjnam: prtobjtyp:
640aAC                                    rtnlkjnam: rtnlkjusr: rtnlkjnum)
640aA*
640aAC                   endsr
640aA*
