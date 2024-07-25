      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TR811     Create version 1.3 Trax XML file.
     *
     *  01 December 2014
     *  Retha Davis
     *
     *  Revisions
     *
710aA*    09/20/17  DAS  7.10a
     *      - **** NEVER USED - SKIPPED TO TR812 (Trax 2.0) ***
     *      - Revised to just return.
     *      - Removed all other code.
     *      - PIROLD710/TR811.1 has old source code.
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $pemp             5
     C                   parm                    sFileSnd         30
     C                   parm                    $prtn             8
     C                   parm                    $perm            60

     C                   eval      *inlr = *on
