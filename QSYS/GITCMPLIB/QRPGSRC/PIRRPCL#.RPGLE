     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  PIRRPCL#    Get next PIR Internal replacement license number
     *  17 May 2021
     *  Lynn McMahon
     *
     *
     *----------------------------------------------------------------
     *  Revisions
     *
750 A*    05/17/21  LMC  7.50
     *      - Created. Copied from PIRUCI#
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
     *    $NXTNM  Next PIR Internal replacment license# (guarenteed tobe
     *            unique; not guarenteed to be the next used in
     *            sequence; 000000 is not used)
     *
     *----------------------------------------------------------------
     Fpirlockfm cf   e             workstn usropn
     *
     *----------------------------------------------------------------
     * Variables
     *
     D prtobjnam       s             10a
     D prtobjtyp       s             10a
     D retrys          s              3  0
     D rtnobjnam       s             20a
     D rtnobjtyp       s             10a
     D rtnlkjnam       s             10a
     D rtnlkjusr       s             10a
     D rtnlkjnum       s              6a
     *
     *----------------------------------------------------------------
     * Constants
     *
     d errmsg          c                   'ERROR CREATING REPLACEMENT LCNS#'
     *
     * System API: Retrieve User Job Attributes
     d Format          s              8
     d RcvVarLen       s             10i 0
     d dsJobDta        ds
     d  dsJobBytesRtn                10I 0
     d  dsJobBytesAvl                10I 0
     d  dsJobName                    10A
     d  dsJobUser                    10A
     d  dsJobNumber                   6A
     d  dsJobIntern                  16A
     d  dsJobStatus                  10A
     d  dsJobType                     1A
     d  dsJobSubtype                  1A
     d  dsJobReserv1                  2A
     d  dsJobRunPty                  10I 0
     d  dsJobTimeSlc                 10I 0
     d  dsJobDftWait                 10I 0
     d  dsJobPurge                   10A
     *
     *----------------------------------------------------------------
     * Called Programs
     *
     D prtlck          pr                  extpgm('PRTOBJLCK')
     D   prtobjn                     10a
     D   prtobjt                     10a
     D   prtljna                     10a
     D   prtljus                     10a
     D   prtljnu                      6a
     *
     * Retrieve lock information
     D rtnlckinf       pr                  extpgm('RTNLCKINF')
     D   rtnobjn                     20a
     D   rtnobjt                     10a
     D   rtnljna                     10a
     D   rtnljus                     10a
     D   rtnljnu                      6a
     *
     * System API: Retrieve User Job Info
     d getjobinfo      pr                  extpgm('QUSRJOBI')
     d   DsJob                             like(DsJobDta)
     d   Length                      10i 0 const
     d   APIFormat                    8    const
     d   ApiJob                      26    const
     d   InternJob                   16    const
     *
     *----------------------------------------------------------------
     * Main Line
     *
     C     *entry        plist
     C                   parm                    $nxtnm            7 0
     *
     C     *dtaara       define    pirrpcl#      next#             7 0
     *
     C                   select
     C                   when      dsjobtype = 'I'
     C                   exsr      lockinter
     C                   other
     C                   exsr      lockbatch
     C                   endsl
     *
     *
     *  Data area contains the next sequence number to use.
     *
     *  Return the unique sequence number.
     *
     C                   if        not *in90
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
     C                   out       next#                                90
     *
     C                   if        *in90 = '1'
     C                   exsr      getlock
     C                   exsr      prtlock
     C                   out       next#                                90
     *
     C                   if        *in90 = '1'
     C                   exsr      getlock
     C                   exsr      prtlock
     C                   out       next#                                90
     *
     C                   if        *in90 = '1'
     C                   exsr      getlock
     C                   exsr      prtlock
     C                   endif
     *
     C                   endif
     *
     C                   endif
     *
     C                   endif
     *
     C                   return
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
      /Free
          // Return current job info to see if batch or inter
          Format = 'JOBI0100';
          RcvVarLen = %Size(DsJobDta);
          getjobinfo(dsjobdta : rcvvarlen : Format : '*' : ' ');
      /end-free
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  DSPLOCK  Display lock information
     *
      /Free
        begsr dsplock;

          if not %open(pirlockfm);
            open pirlockfm;
          endif;

          w1jnam = rtnlkjnam;
          w1jusr = rtnlkjusr;
          w1jnum = rtnlkjnum;

          dou *inkf = *on;
            w1jmsg = errmsg;
            exfmt screen1;
          enddo;

          if %open(pirlockfm);
            close pirlockfm;
          endif;

        endsr;

      /end-free
     *
     *----------------------------------------------------------------
     *
     *  GETLOCK  Get lock information
     *
     C     getlock       begsr
     *
     C                   eval      rtnobjnam = 'PIRRPCL#  *LIBL     '
     C                   eval      rtnobjtyp = '*DTAARA   '
     C                   eval      rtnlkjnam = *blanks
     C                   eval      rtnlkjusr = *blanks
     C                   eval      rtnlkjnum = *blanks
     *
     C                   callp(e)  rtnlckinf(rtnobjnam: rtnobjtyp:
     C                                       rtnlkjnam: rtnlkjusr: rtnlkjnum)
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  LOCKBATCH   Batch - Lock and retrieve data area
     *
     C     lockbatch     begsr
     *
     C                   eval      $nxtnm = 0
     *
     C     *lock         in        next#                                90
     C                   if        not *in90
     C                   leavesr
     C                   endif
     *
     C     *lock         in        next#                                90
     C                   if        not *in90
     C                   leavesr
     C                   endif
     *
     C                   exsr      getlock
     C                   exsr      prtlock
     C*    *lock         in        next#
     C     *lock         in        next#                                90
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  LOCKINTER   Interactive - Lock and retrieve data area
     *
     C     lockinter     begsr
     *
     C                   eval      $nxtnm = 0
     C                   eval      retrys = 0
     C                   seton                                        90
     C                   dou       not *in90
     C     *lock         in        next#                                90
     *
     C                   if        not *in90
     C                   leave
     C                   endif
     *
     C                   if        retrys >= 2
     C                   exsr      getlock
     C                   exsr      prtlock
     C                   exsr      dsplock
     C                   endif
     *
     C                   add       1             retrys
     C                   enddo
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  PRTLOCK  Print lock information
     *
     C     prtlock       begsr
     *
     C                   eval      prtobjnam = 'PIRRPCL#  '
     C                   eval      prtobjtyp = '*DTAARA   '
     *
     C                   callp     prtlck(prtobjnam: prtobjtyp:
     C                                    rtnlkjnam: rtnlkjusr: rtnlkjnum)
     *
     C                   endsr
     *
