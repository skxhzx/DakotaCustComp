      /copy qcopysrc,hspecs
501jAH dftactgrp(*NO)
501jAH actgrp(*NEW)

     *----------------------------------------------------------------
     *
     *  SETJDLIBL    Set library list based on job description
     *  24 March 2007
     *  Dave Sommerville
     *
     *  Revisions
     *
720aA*   01/09/19  DAS  7.20a
     *     - Replaced BNDDIR PIRSQLPGM with BFCBND.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

720aMH*bnddir('PIRSQLPGM')
720aMH bnddir('BFCBND')

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcjobd
      /copy qcopysrc,p.bfclibl

     *----------------------------------------------------------------
     * Input parameters
     *----------------------------------------------------------------

     D $pjobd          S             10
     D $preturn        S             10
     D $pmessage       S             60

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     * API Error Data Structure
     *----------------------------------------------------------------

     D APIErrorDS      DS
     D  BytesProvided                10I 0 Inz( %Size( APIErrorDS ) )
     D  BytesAvail                   10I 0 Inz( *Zero )
     D  MsgID                         7    Inz( *Blanks )
     D  Reserved                      1    Inz( X'00' )
     D  MsgDta                      256    Inz( *Blanks )

     D NoAPIError      C                   Const( *Zero )

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D  jobdLibl       s             11    DIM(250)

     D  error          s               n
     D  jobdName       s             10
     D  jobdLib        s             10
     D  llCount        s              5I 0
     D  rtnFlag        s               n

     *----------------------------------------------------------------
     * Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pjobd   Job description
     *
     *    Returned Parameters
     *      $preturn    *OK
     *                  *ERROR
     *      $pmessage   Message for *ERROR
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     c     *entry        Plist
     c                   Parm                    $pjobd
     c                   Parm                    $preturn
     c                   Parm                    $pmessage

     c                   eval      $preturn = '*OK'
     c                   eval      $pmessage = ' '

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     *  Translate input into upper case.

     C     xlower:xupper xlate(p)  $pjobd        $pjobd

     *  Get job descripiton initial library list

     C                   eval      jobdname = $pjobd
     C                   eval      jobdlib = '*LIBL'

     C                   Reset                   APIErrorDS
     C                   Eval      jobdLibl = RtvJobDInlLibL(
     C                                                        jobdname   :
     C                                                        jobdLib    :
     C                                                        APIErrorDS
     C                                                       )

     C                   If        BytesAvail <> NoAPIError
     C                   eval      $preturn = '*ERROR'
     C                   eval      $pmessage = 'Error getting job '
     C                                       + 'description library '
     C                                       + 'list: '
     C                                       + msgid
     C                   return
     C                   EndIf

     *  Set library list to job description initial library list.

     C                   Eval      rtnFlag = SetLibL(
     C                                               jobdLibl  :
     C                                               llUsrLibl
     C                                               )

     C                   eval      *inlr = *on
