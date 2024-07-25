      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  ER301A    Empl mgmt rpt for an employee(Recv) - Work File
     *  22 November, 2011
     *  Ginger Andrews
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
     *  11/22/11  GJA  6.40
     *   Created
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  77        CHAIN WORKLBL for zone indicator
     *  79        Not on file/End of file indicator
     *  90        Overflow Indicator
     *  9X        Top of page and level X continues.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fer301     uf   e           k disk
     Fpohhdr    if   e           k disk
     Fpohdtl    if   e           k disk
     Fpiritem   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Variables
530bAD forever         s              1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C                   dow       forever = forever
     C                   read      er301
     C                   if        not %EOF(er301)
     C     keypoh        chain(n)  pohhdr
     C                   if        %found(pohhdr)
     C                   eval      wkven# = phhven
     C                   eval      wkvenn = phhvna
     C     keypod        chain(n)  pohdtl
     C                   if        %found(pohdtl)
     C                   eval      wkvitm = phdvit
     C     keyit         chain(n)  piritem
     C                   if        %found(piritem)
     C                   eval      wkitem = ititem
     C                   eval      wkitmd = itdesc
     C                   eval      wkcube = wkpcs * itcube
     C                   eval      wkwgt  = wkpcs * itswgt
     C                   update    wkrec
     C                   endif
     C                   endif
     C                   endif
     C                   else
     C                   eval      *inlr = *on
     C                   return
     C                   endif
     C                   enddo
     *
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     *   Get client code
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     *
     C     keypod        klist
     C                   kfld                    wkwhse
     C                   kfld                    wkpo
     C                   kfld                    wkseq
     *
     C     keypoh        klist
     C                   kfld                    wkwhse
     C                   kfld                    wkpo
     *
     C     keyit         klist
     C                   kfld                    phdwhs
     C                   kfld                    phditm
     *
     C                   eval      forever = *on
     C                   endsr
