     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  GETLABELS - Get labels for OR620 Build Pallet Routine
     *  22 October 2008
     *  Jeffrey Jahnke
     *
     *  Revisions
     *
416 A*    10/22/08  JCJ  5.20
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Input parameters
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fworklbla  if   e           k disk
     Forddm     if   e           k disk
     For620     o    e           k disk

     *----------------------------------------------------------------
     *  Data Structure
     *----------------------------------------------------------------

     D                 ds
     D  lwcomp                 1      1
     D  lwtzon                 2      7
     D  lwgen                  8      8  0
     D  lwszon                 9     14
     D  lwtype                15     15
     D  lwstop                16     17  0
     D  keytype               18     18
     D  lwwhdp                19     23
     D  lwaisl                24     26
     D  lwpseq                27     31  0
     D  lwrlvl                32     33  0
     D  lwhand                34     35
     D  lwlbl#                36     42  0
     D  lwkey                  1    100

     *----------------------------------------------------------------
     *  Work Fields
     *----------------------------------------------------------------

     D $whse           s              3  0
     D $gen            s              1  0
     D $zone           s              6
     D $lwtzon         s              6
     D $lwszon         s              6
     D $lwrte          s              5
     D $lwhse          s              3
     D $lwgen          s              1
     D $ltype          s              1
     D $lwcomp         s              1
     D $lwtype         s              1

     *----------------------------------------------------------------
     *  Key Lists
     *----------------------------------------------------------------

     C     keylw         klist
     C                   kfld                    $whse
     C                   kfld                    $lwrte
     C                   kfld                    $lwcomp
     C                   kfld                    $lwtzon
     C                   kfld                    $gen
     C                   kfld                    $lwszon
     C                   kfld                    $lwtype
ctwaA*
ctwaA*  Define key for ORDDM file.
ctwaA*
ctwaAC     keyodm        klist
ctwaAC                   kfld                    $whse
ctwaAC                   kfld                    lword
ctwaAC                   kfld                    lwseq
ctwaAC                   kfld                    lwitem

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $lwhse
     C                   parm                    $lwrte
     C                   parm                    $lwcomp
     C                   parm                    $lwtzon
     C                   parm                    $lwgen
     C                   parm                    $lwszon
     C                   parm                    $lwtype

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   move      $lwhse        $whse
     C                   move      $lwgen        $gen

     C                   exsr      $copy

     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *  Sr $copy
     *----------------------------------------------------------------

     C     $copy         begsr

     C     keylw         setll     worklbla
     C                   dou       %eof(worklbla)
     C     keylw         reade     worklbla
     C                   if        not %eof(worklbla)
     C                   eval      keytype = *blanks
     C     keyodm        chain     orddm
     C                   if        %found(orddm)
     C                   eval      keytype = %subst(ommsc1:1:1)
     C                   endif
     C                   write     orrec
     C                   endif
     C                   enddo

     C                   endsr
