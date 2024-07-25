      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  SL462     Slot Statistics - Work File
     *  29 April 2013
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
650 A*    04/29/13  RBD  6.50
     *      - Created for Dierks Waukesha.
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Dierks Waukesha
     *
DRKaA*    04/29/13  RBD  DRKa
     *      - Exclude specified aisles in DRY and FRZ.
     *      - Redefine aisles which start with 'R' in dept DRY as
     *        dept CLR.
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
     Fsl462a    o  a e           k disk
     Fslot      if   e           k disk
     *----------------------------------------------------------------
     *  Table and array
     *
     *----------------------------------------------------------------
     *  Customer id
     *
      /copy qcopysrc,id#dierks
     *----------------------------------------------------------------
     *  Variables
     *
     D forever         s              1
     *
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

     C                   dow       forever = forever

     C                   read      slot

     C                   if        %eof(slot)
     C                   eval      *inlr = *on
     C                   return
     C                   endif

     C                   select

     *  For Dierks, exclude certain aisles in DRY and FRZ.
     *  For Dierks, redefine certain aisles in DRY as CLR.

DRKaAC                   when      client = dierks and slwhdp = 'DRY  '
DRKaAC                   if           slaisl = '  A'
DRKaAC                             or slaisl = ' CA'
DRKaAC                             or slaisl = ' CF'
DRKaAC                             or slaisl = ' CG'
DRKaAC                             or slaisl = ' CH'
DRKaAC                             or slaisl = ' CJ'
DRKaAC                             or slaisl = ' CK'
DRKaAC                             or slaisl = ' CL'
DRKaAC                             or slaisl = ' CM'
DRKaAC                             or slaisl = ' CX'
DRKaAC                             or slaisl = ' WR'
DRKaAC                             or slaisl = 'XCP'
DRKaAC                             or slaisl = 'XDF'
DRKaAC                             or slaisl = 'XDP'
DRKaAC                             or slaisl = 'X33'
DRKaAC                             or slaisl = 'X38'
DRKaAC                             or slaisl = 'X45'
DRKaAC                             or slaisl = '  Y'
DRKaAC                             or slaisl = '  Z'
DRKaAC                             or slaisl = ' D9'
DRKaAC                   iter
DRKaAC                   endif

DRKaAC                   if           %subst(slaisl:1:1) = 'R'
DRKaAC                             or %subst(slaisl:1:2) = ' R'
DRKaAC                   eval      slwhdp = 'CLR  '
DRKaAC                   endif

DRKaAC                   when      client = dierks and slwhdp = 'FRZ  '
DRKaAC                   if           slaisl = ' FA'
DRKaAC                             or slaisl = ' FB'
DRKaAC                             or slaisl = ' FC'
DRKaAC                             or slaisl = ' FD'
DRKaAC                             or slaisl = ' FT'
DRKaAC                             or slaisl = ' FV'
DRKaAC                             or slaisl = ' FW'
DRKaAC                             or slaisl = ' FX'
DRKaAC                             or slaisl = ' FY'
DRKaAC                             or slaisl = ' FZ'
DRKaAC                             or slaisl = 'R51'
DRKaAC                             or slaisl = 'R52'
DRKaAC                             or slaisl = 'XFF'
DRKaAC                             or slaisl = 'XFP'
DRKaAC                   iter
DRKaAC                   endif

     C                   endsl

     C                   write     wkrec

     C                   enddo

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine

     C     *inzsr        begsr

     *   Get client code

     C                   call      'GETCLIENT'
     C                   parm                    client           10

     C                   eval      forever = *on
     C                   endsr
