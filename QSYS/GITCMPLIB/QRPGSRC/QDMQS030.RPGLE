     H OPTION(*NODEBUGIO)
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  QDMQS030  Extract data to IMPSPCKQ to adjust quantity
     *  03 May, 2018
     *  Roxanne Harrison
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
640 A*  09/17/12  MLB  6.40
     *    - Created.
     *
     *
     *----------------------------------------------------------------

     fPIRITEM   ip   e           k disk
     fslot3     if   e           k disk
     fimpspckq  o  a e             disk
     *
     D kywhse          s              3  0
     *
     C     keysl         klist
     C                   kfld                    kywhse
     C                   kfld                    ititem
     *
    AC                   eval      kywhse = 001
     C                   if        itdesg = 'SPCL' or
     C                             itdesg = 'I/P '
     C     keysl         setll     slot3
     C                   move      '1'           forever           1
     C                   dow       forever = forever
     C     keysl         reade     slot3
     C                   if        %eof(slot3)
     C                   leave
     C                   endif
     C*
     C                   if        slsdef='ST'
     C                   iter
     C                   endif
     C*
     C                   if        sldesg<> 'SPCL' and
     C                             sldesg<> 'I/P '
     C                   iter
     C                   endif
     C*
     C                   eval      ipqwhs = itwhse
     C                   eval      ipqbatid='18050399999'
     C                   eval      ipqstatus ='R'
     C                   eval      ipqitm = slitem
     C                   eval      ipqwhd = slwhdp
     C                   eval      ipqdsp = sldisp
     C                   eval      ipqqp1 = slstk1
     C                   eval      ipqqp2 = slstk2
     C                   eval      ipqqp3 = slstk3
     C                   eval      ipqadj = 'CC'
     C                   eval      ipqsof = 'N'
     C                   eval      ipqmem = 'Fix for SPCL I/P count'
     *
     c                   write     ipqrec
     *
     c                   enddo
     *
     c                   endif
     C***                eval      *inlr = '1'
     *
