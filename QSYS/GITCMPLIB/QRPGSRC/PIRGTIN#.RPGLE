      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  PIRGTIN#    Get next sequence number for creation of a GTIN
     *  11 October 2018
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions:
     *    10/11/18  LMC  7.20
     *      - Created - copied from ucilic#
     *
730aA*    08/23/19  LMC  7.30a
     *      - Fix: Checkdigit logic had a flaw. Simplified the logic.
     *----------------------------------------------------------------
     *
     *  File specs
     *
     fpirlockfm cf   e             workstn usropn
     fupc       if   e           k disk
     *
     *----------------------------------------------------------------
     * Variables
     *
     d nextgtin        s             14a
     d nextupc         s             14a
     d checkupc        s             20a
     d prtobjnam       s             10a
     d prtobjtyp       s             10a
     d retrys          s              3  0
     d rtnobjnam       s             20a
     d rtnobjtyp       s             10a
     d rtnlkjnam       s             10a
     d rtnlkjusr       s             10a
     d rtnlkjnum       s              6a
     d stop            s              1
     *
     *----------------------------------------------------------------
     * Constants
     *
     d errmsg          c                   'ERROR CREATING GTIN'
     *
     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d calcgtin        pr            18
     *----------------------------------------------------------------
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
     d prtlck          pr                  extpgm('PRTOBJLCK')
     d   prtobjn                     10a
     d   prtobjt                     10a
     d   prtljna                     10a
     d   prtljus                     10a
     d   prtljnu                      6a
     *
     * Retrieve lock information
     d rtnlckinf       pr                  extpgm('RTNLCKINF')
     d   rtnobjn                     20a
     d   rtnobjt                     10a
     d   rtnljna                     10a
     d   rtnljus                     10a
     d   rtnljnu                      6a
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
     *
     *  Subprogram parameters
     *
     *    Input Parameters
     *    $pwhse - warehouse
     *
     *    Returned Parameters
     *    $NXTNM  Next GTIN#       (guarenteed to be
     *            unique; not guarenteed to be the next used in
     *            sequence; 0000000000000 is not used)
     *
     *----------------------------------------------------------------
     * Main Line
     *
     C     *entry        plist
     C                   parm                    $nxtnm           14
     C                   parm                    $pwhse            3 0

     C     *dtaara       define    pirgtin       next#            13 0
     *
     C*                  eval      $nxtnm = 0
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
     *  Data area contains the next sequence number to use.  If it
     *  has already been used then keep adding 1 until we find one
     *  that hasn't been used (we will take the chance that all
     *  9999999999999 have not been used).
     *
     C                   if        not *in90
     C                   move      *off          stop
     C                   dou       stop = *on
     *
     C                   select
     C                   when      next# = 9999999999999
     C                   eval      next# = 1
     C                   when      next# = 0
     C                   add       1             next#
     C                   endsl
     *

     c                   eval      nextupc = %editc(next#:'X') + '0'
      /free
        nextupc = calcgtin();
        checkupc = '      ' + nextupc;
        chain ($pwhse: checkupc) upc;
        if %found(upc);
          next# = next# + 1;
        else;
          stop = *on;
        endif;
      /end-free
     c*                  eval      nextucilic = 'U:' + (next#a)

     C                   enddo
     *
     *  Return the unique sequence number.
     *
     C                   eval      $nxtnm = nextupc
     *
     *  Update the data area with the next number to be used.
     *
     C                   add       1             next#
     C                   out       next#
     C                   endif
     *
     C                   return
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     c     *inzsr        begsr
     c                   endsr
     *
     *----------------------------------------------------------------
     *
     *  DSPLOCK  Display lock information
     *
      /Free
        begsr dsplock;

          RcvVarLen = %Size(DsJobDta);
          Format = 'JOBI0100';

          getjobinfo(dsjobdta : rcvvarlen : Format : '*' : ' ');

          // Display screen if Interactive ONLY
          if dsjobtype = 'I';
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
     C                   eval      rtnobjnam = 'PIRGTIN *LIBL     '
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
     *  PRTLOCK  Print lock information
     *
     C     prtlock       begsr
     *
     C                   eval      prtobjnam = 'PIRGTIN'
     C                   eval      prtobjtyp = '*DTAARA   '
     *
     C                   callp     prtlck(prtobjnam: prtobjtyp:
     C                                    rtnlkjnam: rtnlkjusr: rtnlkjnum)
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *  calcgtin    Used to generate the check digit for the gtin
     *----------------------------------------------------------------

     p calcgtin        b
     d calcgtin        pi            18

     * Local Variables
     d  chkdgt         s              1  0
     d  digitsSum      s              5  0
     d  instring       s             14
     d  lp             s              2  0

      /free

         // Build 14 character string.  Position 14 is 0 since it will
         // be passed in a check digit calculated.

         inString = %trim(inString) + %editc(next#:'X') + '0';

         lp = 1;
         dow lp < 15;
           // for odd number digits multiply number by 3 nd add to sum
           digitsSum = digitsSum + (%dec(%subst(inString:lp:1):1:0))*3;
           lp = lp + 1;
           // for even number digits simply add digit to sum
           digitsSum = digitsSum + %dec(%subst(inString:lp:1):1:0);
           lp = lp +1;
         enddo;
730aA    if %rem(digitsSum:10) = 0;
730aA      chkDgt = 0;
730aA    else;
730aD      //chkDgt = %rem((10-%rem(digitsSum:10)-1):9)+1;
730aM      chkDgt = 10-%rem(digitsSum:10);
730aA    endif;
         inString = %subst(inString:1:13) + %char(chkDgt);

         return inString;

      /end-free

     p calcgtin        e
