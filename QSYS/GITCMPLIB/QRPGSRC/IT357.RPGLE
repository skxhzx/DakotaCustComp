     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IT357     Build IT357A Work File - rtehed/label picking qty
     *  08 May 2007
     *  Retha Davis
     *
     *  Revisions
     *
     *    05/08/07  RBD  5.10
     *      - Created
     *
     *----------------------------------------------------------------
      *  Notes
      *
      *----------------------------------------------------------------
      *  Indicator usage
      *
      *  21 - 30   Field input error (Reverse Display)
      *  90        View mode (Protect input fields)
      *  91        Change mode (Protect key)
      *  97        Always ON (Used for SFLEND Keyword)
      *  98        Error on screen (Sound buzzer)
      *  99        Universal record indicator (Very temporary usage)
      *
      *----------------------------------------------------------------
      *  File Specs
      *
     Frtehed    if   e           k disk
     Flabel13   if   e           k disk
     Fit357a    uf a e           k disk

      *----------------------------------------------------------------
      *  Data Structures
      *
     D                 ds
     D wktime                  1     12  0
     D htime                   1      6  0
     D hdate                   7     12  0

      *----------------------------------------------------------------
      *  Variables
      *
     D alpha6          S              6
     D forever         S              1

      *----------------------------------------------------------------
      *  Let the show begin .....

      *----------------------------------------------------------------
      *  Main line

     C                   dow       forever = forever
     C                   read      rtehed
     C                   if        %eof
     C                   leave
     C                   endif

     C     key13         setll     label13
     C                   dow       forever = forever
     C     key13         reade     label13

     C                   if        %eof
     C                   leave
     C                   endif

     C                   if        lbtype <> 'O' and
     C                             lbtype <> 'B'
     C                   iter
     C                   endif

     C     lbwhdp        chain     it357a
     C                   if        %found
     C                   eval      wbpck = wbpck + lbqpck
     C                   update    wbrec
     C                   else
     C                   eval      wbwhse = lbwhse
     C                   eval      wbwhdp = lbwhdp
     C                   eval      wbpck = lbqpck
     C                   write     wbrec
     C                   endif

     C                   enddo
     C                   enddo

     C                   eval      *inlr = *on
      *----------------------------------------------------------------
      *
      *  ZZINZ    Extra program initialization. Called from *INZSR.

     C     zzinz         begsr

     C                   endsr

      *----------------------------------------------------------------
      *
      *  *INZSR  Initialization subrotine
      *
     C     *inzsr        begsr
      *
     C     key13         klist
     C                   kfld                    rhwhse
     C                   kfld                    rhrtid
      *
      *  Initialize message handling
      *
     C                   exsr      zzinz
     C                   endsr
