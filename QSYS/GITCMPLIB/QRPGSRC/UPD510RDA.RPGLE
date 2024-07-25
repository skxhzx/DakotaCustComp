      /COPY qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  UPD510RDA  Initialize field *ITEMMNT/OPHVY
     *  08 June 2007
     *  Retha Davis
     *
     *  Revisions
510 A*    06/08/07  RBD  5.10   Created
     *      - Initialize OPHVY.
     *
510aA*    10/18/07  RBD  5.10a
     *      - Revised to initialize OPHVY only when its value is
     *        blank.  Had to define as alpha field to prevent
     *        decimal data error.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fwarehs    if   e           k disk
     Foptions   uf   e           k disk
     *----------------------------------------------------------------
     *  *ITEMMNT  -  Item maintenance options.
     *
     *    Fields
     *
     *    OPSTYP  -  Default section type
     *    OPWHDP  -  Default warehouse department
     *    OPUM1   -  Default normal unit of measure
     *    OPDUM   -  Unit of measure for dimensions
     *    OPCUM   -  Unit of measure for cube
     *    OPCDIV  -  Divisor for cube
     *    OPCAUT  -  Automaticaly calculate cube when zero (Y/N)
     *    OPCWRN  -  Display cube warning (Y/N)
     *    OPCRNG  -  Display cube warning range percentage
     *    OPWUM   -  Unit of measure for weight
     *    OPXDSC  -  Use extended description (Y/N)
     *    OPHVY   -  Heavy items are greater than or equal to
     *----------------------------------------------------------------
     * Data structure
     *
     D opdata          ds
     D  opdum                  9     23
     D  opcum                 24     43
     D  opcdiv                44     52  2
     D  opcaut                53     53
     D  opcwrn                54     54
     D  opcrng                55     57  3
     D  opwum                 58     72
     D  opxdsc                73     73
     D  ophvy                 74     75
     D  optend               117    117
     *----------------------------------------------------------------
     *
     * Variables
     *
     D kycode          s                   like(opcode)
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in79 = *off
     C     opkey         klist
     C                   kfld                    whcode
     C                   kfld                    kycode
     C                   eval      kycode = '*ITEMMNT'
     *
     C     *loval        setll     warehs
     C                   dow       not *in79
     C                   read      warehs                                 79
     C                   select
     C                   when      *in79
     C                   leave
     *
     C                   other
     *
     C     opkey         chain     options                            78
     C                   select
     C                   when      not *in78
510aAC                   if        ophvy = '  '
     C                   eval      ophvy = '00'
     C                   update    oprec
510aAC                   endif
     *
     C                   endsl
     C                   endsl
     C                   enddo
     *
     C                   eval      *inlr = *on
     *
