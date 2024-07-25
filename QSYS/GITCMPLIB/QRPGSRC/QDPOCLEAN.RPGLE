      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  QDPOCLEAN  Delete Old Open POs - Parm Whse,DelvDte YYMMDD
     *  Rod Roller
     *  March 3, 2020
     *
     *----------------------------------------------------------------
     *  Revisions
     *
740  *    03/06/20  RTR  7.40
     *      - Created.
     *
750 A*    06/15/21  MLB  7.50
     *      - Enh: Revised pgm to add test for PHSTAT = '0' before
     *        attempting to call @DELPG.
     *
     *----------------------------------------------------------------
     *  Notes:
     *    Example call:  CALL QDPOCLEAN PARM('001' '200101')
     *    This call would delete every open PO with delivery date
     *    before 2020-01-01 in status 0.
     *----------------------------------------------------------------
     * File Specs
     *
     fpohdr     ip   e           k disk
     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy qcopysrc,c#stdvar
     *----------------------------------------------------------------
     *  Program info data structure
      /copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Customer id
     d @getcl          c                   const('GETCLIENT')
     d @delpg          c                   const('PO114')
     *----------------------------------------------------------------
     *  Partial key redefinition
     d $parms          ds
     d  $pcmd                  1      8
     d  $pprg                  9     18
     d  $puky                 19     68
     d  $prtn                 69     76
     d  $perm                 77    136
     d  $pmsg                 77     80
     d*   Redefine key
     d  $pwhse                19     21  0
     d  $ppo                  22     30
     d  $pspo                 31     39
     d  $pspsw                65     68
     *----------------------------------------------------------------
     *  Variables
     d chkwhse         s              3s 0
     d chkdate         s              6s 0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pwhsea       Warehouse alpha
     *      pddatea      Delivery date YYMMDD alpha
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     * Main line
     *
     c     *entry        plist
     c                   parm                    pwhsea            3
     c                   parm                    pddatea           6

     c                   if        phwhse = chkwhse
750 Ac                             and phstat = '0'
     c                             and phdate > 0
     c                             and phdate < chkdate
     c                   move      '*DELETE '    $pcmd
     c                   move      #prog         $pprg
     c                   movel     phwhse        $pwhse
     c                   movel     phpo          $ppo
     c                   call      @delpg
     c                   parm                    $parms
     c                   endif

     *----------------------------------------------------------------
     *          Subroutines in Alphabetical Order
     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine

     c     *inzsr        begsr

     c                   clear                   $parms

     c                   monitor
     c                   eval      chkwhse = %dec(pwhsea:3:0)
     c                   eval      chkdate = %dec(pddatea:6:0)
     c                   on-error
     c                   eval      *inlr = *on
     c                   return
     c                   endmon

     c                   endsr

