417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  PRTPS311    Print Pallet Summary
     *  27 November 2012
     *  Rod Roller
     *
     *  Revisions:
     *
640 A*    11/27/12  RTR  6.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     Freports   if   e           k disk

     *----------------------------------------------------------------
     *  Parameters
     *
     *      pReturn     Error message
     *      pAction     Action type
     *      pMenu       Menu
     *      pSeq        Sequence
     *
     *----------------------------------------------------------------

     D prtps311        pr                  extpgm('PRTPS311')
     D   pWhse                        3  0 const
     D   pRtid                        5    const
     D   pRtn                         8

     D prtps311        pi
     D   pWhse                        3  0 const
     D   pRtid                        5    const
     D   pRtn                         8

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     d @prtpg          c                   const('PS310CL')
     d $pwhse          s              3a
     d $prte           s              5a
     d $prtid          s              5a
     d $dev            s             10a
     d $form           s             10a
     d $msgf           s             10a
     d $pcmd           s              8a
     d $rtn            s              8a
     d wkprtf          s             10a

     *----------------------------------------------------------------
     * Main
     *----------------------------------------------------------------

     C                   eval      *inlr = *on

     C                   eval      $pwhse = %editc(pwhse:'X')
     C                   eval      $prtid = prtid
     C                   eval      $rtn = *blanks
     C                   eval      $dev = *blanks
     C                   eval      $form = *blanks

     C                   movel     'PS311PR '    wkprtf
     C     rpkey         chain     reports                            79
     C                   if        not *in79
     C                   eval      $dev = rpdev
     C                   eval      $form = rpform
     C                   else
     C                   movel     '*JOB    '    $dev
     C                   movel     '*STD    '    $form
     C                   endif

     C                   call(e)   @prtpg
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm                    $rtn
     C                   parm                    $dev
     C                   parm                    $form

     C                   if        %error
     C                   eval      pRtn = '*ERROR'
     C                   endif

     C                   if        $rtn = *blanks
     C                   eval      pRtn = '*OK'
     C                   else
     C                   eval      pRtn = $rtn
     C                   endif

     C                   return

413 AC     rpkey         klist
413 AC                   kfld                    wkprtf

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

      /free
       begsr *pssr;

         // Make sure we don't get caught in an infinite loop

         if pssrflag;
           *inlr = *on;
           return;
         endif;

         pssrflag = *on;

         //  Send message back to calling program

         dump(a);
         pRtn = #pgmmsg;

         *inlr = *on;
         return;

       endsr;
      /end-free
