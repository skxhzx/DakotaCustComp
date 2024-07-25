      /copy *libl/qcopysrc,hspecs
     H dftactgrp(*NO) actgrp(*CALLER)
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  IT233     Build workfile for IT234
     *  24 July, 2013
     *  Lynn McMahon
     *
     *  Notes
650 A*    07/24/13  LMC  6.50
     *       Created.
     *
     *  Revisions
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position cursor
     *  21 - 29   Field input error (Reverse display)
500 A*  60        F10=Specific active. Called from LT105.
     *  79        Chain indicator
     *  90        Protect input fields for delete display
     *  97        Always ON (Used for SFLEND keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpiritem   if   e           k disk
     Fslot3     if   e           k disk
     Fitemlnk1  if   e           k disk
     Fitemlnk   if   e           k disk    rename(ilrec:ilrec1)
     Fit234     o    e             disk    usropn
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D  $whse                  1      3  0
     D  $item                  4     18
416aAD  $lalwc                47     47
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PRTKY  Partial key
     *
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $prtky
     C                   parm                    $rtncd            8
     *
     *----------------------------------------------------------------
     *  Main line
     *
      /free
        chain ($whse: $item) piritem;
        if %found(piritem);
          // first need to write for item being sent
          // get slots
          setll ($whse: $item) slot3;
          dow not %eof(slot3);
            reade ($whse: $item) slot3;
            if %eof(slot3);
              leave;
            endif;
            // got a slot
            ilitem = ititem;
            write wkrec;
          enddo;
          select;
            // then write for linked items tied to main
            when ittype = ' ';
              // get linked items
              setll ($whse: $item) itemlnk1;
              dow not %eof(itemlnk1);
                reade ($whse: $item) itemlnk1;
                if %eof(itemlnk1);
                  leave;
                endif;

                setll ($whse: ilitem) slot3;
                dow not %eof(slot3);
                  reade ($whse: ilitem) slot3;
                  if %eof(slot3);
                    leave;
                  endif;
                  // got a slot
                  write wkrec;
                enddo;
              enddo;
            other;
              // get linked items
              setll ($whse: $item) itemlnk;
              dow not %eof(itemlnk);
                reade ($whse: $item) itemlnk;
                if %eof(itemlnk);
                  leave;
                endif;

                setll ($whse: ilitm2) slot3;
                dow not %eof(slot3);
                  reade ($whse: ilitm2) slot3;
                  if %eof(slot3);
                    leave;
                  endif;
                  // got a slot
                  ilitem = ilitm2;
                  write wkrec;
                enddo;
              enddo;
          endsl;
          *inlr = *on;
          close it234;
          return;
        else;
          *inlr = *on;
          close it234;
          return;
        endif;
      /end-free
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      qcmd = 'ADDPFM FILE(IT234) '
     C                                  + 'MBR('
     C                                  + %trim(#JOB)
     C                                  + ')'
640cAC                   call      'QCMDEXC'                            78
640cAC                   parm                    qcmd            256
640cAC                   parm      80            qlen             15 5
640cAc                   if        *in78 = *on
     c
640cAC                   eval      qcmd = 'CLRPFM FILE(IT234) '
     c                                  + 'MBR('
     C                                  + %trim(#JOB)
     C                                  + ')'
640cAC                   call      'QCMDEXC'                            78
640cAC                   parm                    qcmd            256
640cAC                   parm      80            qlen             15 5
     c                   endif

640cAC                   eval      qcmd = 'OVRDBF FILE(IT234) '
     c                                  + 'TOFILE(*LIBL/IT234) '
     c                                  + 'MBR('
     C                                  + %trim(#JOB)
     C                                  + ')'
640cAC                   call      'QCMDEXC'                            78
640cAC                   parm                    qcmd            256
640cAC                   parm      80            qlen             15 5

     C                   open      IT234
     c                   endsr
