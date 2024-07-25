      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  TESTJIT   Test CCJITCL
     *  02 November 2004
     *  Dave Sommerville
     *
     *----------------------------------------------------------------

500bAD $lparm          ds
500bAD  $lcmd                  1      8
500bAD  $lprg                  9     18
500bAD  $luky                 19     68
500bAD  $lrtn                 69     76
500bAD  $lerm                 77    136
500bAD  $lmsg                 77     80
500bA*
500bA*   Redefine key
500bA*
     D  $lwhse                19     21  0
     D  $lrte                 22     26
     D  $lgrp1                27     27
     D  $lgrp2                28     28

500bAC                   eval      $lcmd = '*TKPRTY '
500bAC                   eval      $lprg = 'TSTCCRPL'
500bAC                   eval      $lwhse = 900
500bAC                   eval      $lrte  = '00002'
500bAC                   eval      $lgrp1 = 'S'
500bAC                   eval      $lgrp2 = ' '
500bA*
500bAC                   call      'CCJITP'
500bAC                   parm                    $lparm

     C                   eval      *inlr = *on
