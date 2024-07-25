      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GETADDON   Get parent route id of add on.
     *
     *             - If route id passed in is the parent,
     *               return *PARENT along with parent route id.
     *             - If route id passed in is a child,
     *               return *CHILD along with parent route id.
     *             - If route id passed in is not found,
     *               return *NONE and parent route id will be blank.
     *
     *  02 December 2020
     *  Retha Davis
     *
740aA*    12/02/20  RBD  7.40a
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D ttmrec        E ds                  extname(ttmerg) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D pWhse           s              3p 0
     D pRteId          s              5
     D pParent         s              5
     D pRtn            s             10

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Parameters
     *   Parameters:
     *     pWhse  - Warehouse
     *     pRteId - Route id
     *
     *   Return Value:
     *     pParent    -  Parent route id of add on
     *     pRtn       -  *PARENT - route passed in is a parent
     *                   *CHILD  - route passed in is a child
     *                   *NONE   - route passed in is not part of
     *                             an add on route
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse
     C                   parm                    pRteId
     C                   parm                    pParent
     C                   parm                    pRtn

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

        exsr GetParentIfAddOn;

       return;

      /end-free

     *----------------------------------------------------------------
     *  GetParentIfAddOn    Get parent route id if route passed
     *                      in is part of an add on.
     *----------------------------------------------------------------

      /free
       begsr GetParentIfAddOn;

          exec sql select ttmwhs, ttmpri, ttmcri
                   into :ttmwhs, :ttmpri, :ttmcri
                   from ttmerg
                   where ttmwhs = :pWhse
                     and ttmpri = :pRteId
                     or  ttmwhs = :pWhse
                     and ttmcri = :pRteId;

          if sqlstt = sqlSuccess or
             sqlstt = '21000';

            pParent = ttmpri;

            if pRteId = ttmpri;
              pRtn = '*PARENT';
            else;
              pRtn = '*CHILD';
            endif;

          else;

            pParent = *blanks;
            pRtn = '*NONE';

          endif;

       endsr;
      /end-free
