     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  UC214a    Delete Multiple UPC code Vendor 0 - Delete
     *  03 November, 2009
     *  Roxanne Harrison
     *
     *  Revisions:
417aA*    11/03/09  RH   5.30
     *      - Created.
     *
700aA*    11/02/16  LMC  7.00a
     *      - Recompile only - UPC file changed.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Not on file/End of file indicator
     *  90        Overflow Indicator
     *  9X        Top of page and level X continues.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fuc214     ip   e           k disk
     F                                     rename(wkrec:record)
     Fupc       uf   e           k disk
     F*eports   if   e           k disk
417a F*iritem   if   e           k disk
417a F*lot3     if   e           k disk
     F*c212pr   o    e             printer oflind(*in90)
     *----------------------------------------------------------------
     *
     *  Table and array
     *
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
     *  Called programs
     *
     *----------------------------------------------------------------
     *  Variables
     D $plen           s              3  0
     D $pmcnt          s              3  0
     D $pstr           s             60
     D $pwhse          s              3  0
     D first           s              1
     D forevr          s              1
     D tsitem          s             15
     D tsven           s             11  0
     D svupc           s             20
     D wkprtf          s             10
     D wpsmct          s              3  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse #
417b *      $PMCNT  # of Multiples
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhs             3
417b C                   parm                    $pmct             3
     C                   move      $pwhs         $pwhse
417b C                   move      $pmct         $pmcnt
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C                   eval      *in81 = *off
     C     partky        setll     upc
     C                   dow       forevr = forevr
     C     partky        reade     upc                                    79
     *
     C                   if        *in79
     C                   leave
     C                   else
417a C                   if        upven = 0
417a C                   eval      tsitem = upitem
417a C                   eval      tsven = upven
417a C                   delete    uprec
417a C                   endif
417a C                   endif
417a C                   iter
     C                   enddo
     *
     *----------------------------------------------------------------
     CLr                 return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   move      $pwhs         $pwhse
417b C                   move      $pmct         $pmcnt
     *
     C     partky        klist
     C                   kfld                    $pwhse
     C                   kfld                    wksupc
     *
     C*                  eval      $cvprg = #prog
417b C                   eval      wpsmct = $pmcnt
     C                   eval      forevr = *on
     C                   endsr
     *----------------------------------------------------------------
     *
     * Compile time tables
     *
