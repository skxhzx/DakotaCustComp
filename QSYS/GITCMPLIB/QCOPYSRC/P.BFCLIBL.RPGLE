
     *----------------------------------------------------------------
     * Begin P.BFCLIBL - Prototypes for library list functions
     *                   Taken from MC Press 9/11/02 article.
     *                   03/20/07  DAS  5.10  Created
     *----------------------------------------------------------------

     **---------------------------------------------------------------
      ** PUSHLIB - Add library to top of library list.
      **   Usage:  callp pushlib( library )

      **   Return Value:
      **     None
      **   Parameters:
      **     LIB       - Library to add.
     D PushLib         PR
     D  Lib                          10    value

     **---------------------------------------------------------------
      ** POPLIB - Remove library from library list.
      **   Usage:  callp poplib( library )

      **   Return Value:
      **     None
      **   Parameters:
      **     LIB       - Library to remove
     D PopLib          PR
     D  Lib                          10    value

     **---------------------------------------------------------------
      ** GETLIBL - Retrieve the specified library list
      **   Usage:  libl = GetLibl( list-type : rtn-Count )
      **   Note: all parameters are optional.

      **   Return Value:
      **     LIBL - An array that receives the library list.
      **   Parameters:
      **     RTN-COUNT - An optional variable that recieves
      **                 a count of the number of library returned.
      **     LIST-TYPE - An optional parameter that controls which
      **                 library list is to be returned. The named
      **                 constants listed at the ind of this include
      **                 member may be used for this value.

     D GetLibl         PR            11A   DIM(250)
     D  lType                         5I 0 Const Options(*NOPASS)
     D  nLiblCount                    5I 0 Options(*NOPASS)

     **---------------------------------------------------------------
      ** SETLIBL &#8211; Set (change) the library list
      **   Usage:  libl = SetLibl( libl : list-type )

      **   Return Value:
      **     Reserved -  Nothing returned at this time.
      **   Parameters:
      **     LIBL      - An array of 11-character elements.
      **                 Each library name to be placed on the library
      **                 must be stored in a corresponding element.
      **     LIST-TYPE - An optional parameter that controls which
      **                 library list is to be changed. The named
      **                 constants in the LIBL include member may
      **                 be used for this value. The default is
      **                 the user portion of the library list.
     D SetLibl         PR             1N
     D  Libl                         11A   Const DIM(250)
     D  lType                         5I 0 Const Options(*NOPASS)

     **---------------------------------------------------------------
      ** ADDLIBLE &#8211; Add Library List Entries
      **   Usage:  count = AddLiblE( libl : pos-lib : before/after-flag) )

      **   Return Value:
      **     count     - A count of the number of libraries on the library list.
      **   Parameters:
      **     LIBL      - A character string of one or more library
      **                 names separated by one or more blanks.
      **     POSLIB    - An optional parameter that may contain the
      **                 name of a library used to control the placement
      **                 of the library names being added to the list.
      **                 Special values *FIRST, and *LAST may also be
      **                 specified to insert the library names at the start
      **                 or end of the library list.
      **     POS       - An optional parameter that indicates the order
      **                 in which the new library name(s) are inserted
      **                 into the library list. *ON = BEFORE the POSLIB
      **                                        *OFF = AFTER the POSLIB
     D AddLiblE        PR            10I 0
     D  InLibl                     2750A   Const VARYING
     D  PosLib                       10A   Const VARYING
     D                                     Options(*NOPASS)
     D  Pos                           1N   Const
     D                                     Options(*NOPASS)

     **---------------------------------------------------------------
      ** Library list types (parameter 1) named constants
     D llUSRLIBL       C                   Const(0)
     D llCURLIB        C                   Const(1)
     D llSYSLIBL       C                   Const(2)
     D llPRODLIBL      C                   Const(3)

     *** End P.BFCLIBL ***
