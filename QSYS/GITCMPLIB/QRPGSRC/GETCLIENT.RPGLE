      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     * Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETCLIENT    Get BFC Dakota client id from data area PIRCLIENT
     *  03 June 2004
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
417 A*    06/03/04  DAS  4.17
     *      - Created.
     *
500 A*    01/10/06  DAS  5.00
     *      - Revised to get PIRCLIENT2 location data area.
     *
650 A*    09/29/14  MLB  6.50
     *      - Revised to get PIRCLIENT3 location data area.
     *
740aA*    03/06/10  DAS  7.40
     *      - Revised to get PIRCLIENT3 host system data area.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *   Input
     *
     *    none
     *
     *   Output
     *
     *    $pclientid  -  Id of client.
500 A*    $plocationid  -  Location Id of client.
650 A*    $pclientint   -  Client initials (optional)
740aA*    $phostsys     -  Client host system  (optional)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin ...
     *----------------------------------------------------------------

     C     *entry        plist
417cAC                   parm                    $pclientid       10
500 AC                   parm                    $plocationid     10
650 AC                   parm                    $pclientinit      3
740aAC                   parm                    $phostsys        10

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     *  Get client id

     C     *DTAARA       define    pirclient     clientid         10

     C                   in(e)     clientid

     C                   if        %error
     C                   eval      $pclientid = '*NOTFOUND*'
     C                   else
     C                   eval      $pclientid = clientid
     C                   endif

     *  Get client location id (optional)

500 AC                   if        %parms >= 2
500 A
500 AC     *DTAARA       define    pirclient2    locationid       10
500 A
500 AC                   in(e)     locationid
500 A
500 AC                   if        %error
500 AC                   eval      $plocationid = '*NOTFOUND*'
500 AC                   else
500 AC                   eval      $plocationid = locationid
500 AC                   endif
500 A
500 AC                   endif
650 A
650 A*  Get client initials. (optional)
650 A
650 AC                   if        %parms >= 3
650 A
650 AC     *DTAARA       define    pirclient3    clientinit       10
650 A
650 AC                   in(e)     clientinit
650 A
650 AC                   if        %error
650 AC                   eval      $pclientinit = '*NOTFOUND*'
650 AC                   else
650 AC                   eval      $pclientinit = clientinit
650 AC                   endif
650 A
650 AC                   endif
740 A
740 A*  Get host system (optional)
740 A
740 AC                   if        %parms >= 4
740 A
740 AC     *DTAARA       define    pirclient4    hostsys          10
740 A
740 AC                   in(e)     hostsys
740 A
740 AC                   if        %error
740 AC                   eval      $phostsys = '*NOTFOUND*'
740 AC                   else
740 AC                   eval      $phostsys = hostsys
740 AC                   endif
740 A
740 AC                   endif

     C                   return
