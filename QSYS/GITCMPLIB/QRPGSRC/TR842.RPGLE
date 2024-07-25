      /COPY *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('HTTPAPI')
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  TR842  Trax 2.0 - Process command sent by Trax unit
     *  20 July 2017
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    07/20/17   DAS  7.10
     *      - Created. Loosly based on RH840.
     *
710aA*    09/19/17  DAS  7.10a
     *      - Removed VARYING CONST from incoming parameters.
     *
710bA*    12/29/17  DAS  7.10b
     *      - Added new fields to getempl call.
     *      - Revised to ignore a PALLET item record
     *
710cA*    01/04/18  DAS  710c
     *      - Added exception logging
     *
710dA*    01/08/18  DAS  710d
     *      - Added Host Stop code
     *
720aA*    01/15/18  DAS  720a
     *      - Removed call to TR846. Program modifies fixes issues
     *        with TTEXCP from Trax 1.0 webservice.
     *      - Revised to call TR842D instead of TR844 in order to
     *        have total separation from Trax 1.0.
     *      - Revised to call TR842U instead of TR845 in order to
     *        have total separation from Trax 1.0.
     *
720bA*    02/02/18  DAS  720b
     *      - Added new file TTPICS.
     *      - Revised to write signature file name to TTPICS.
     *      - Revised ElemPicture to write out picture name to TTPICS
     *        for StopsNotesPictures and ItemsReturnedPictures.
     *
720cA*    02/16/18  DAS 7.20c
     *      - Revised to send message back for text/email in the
     *        file name parameter.
     *
720dA*    03/26/18  DAS 7.20d
     *      - Revised ElemRoute to not clear TTRFID and TTRFIT
     *        after setting them.
     *      - Revised ElemLogEntry to set the exception type to 'S'
     *        instead of 'I'. 'S' is used when a valid Trax # was
     *        scanned at the wrong Stop. 'I' is used for situations
     *        like a GS1 was scanned instead of a Trax #.
     *
720eA*    03/28/18  DAS 7.20e
     *      - Added skipRecord to LogEntry data structure
     *      - Revised ElemLogEntry to user logEntry.skipRecord.
     *      - Revised Elem routine to check for count=3 because
     *        the first time in, the count is 3.
     *
720fA*    03/29/18  DAS  7.20f
     *      - Revised 720c how lastOrd and LastLbl are saved
     *
720gA*    04/16/18  RBD  7.20g
     *      - Changed to update scan date and time without regard
     *        to operation flag.
     *
720h *    05/10/18  GJA  7.20h
     *      - Data changed for 7.20g, use item.delvStamp instead
     *
720i *    05/17/18  GJA  7.20i
     *      - Data changed for returned time stamp
     *
720j *    07/01/18  DAS  7.20j
     *     - Revised ElemSignature to copy signature file to a
     *       different folder with Order number in its name.
     *     - Revised GetOptions to get *TRAX2 options which contains
     *       the new customer order signature option OPTOSIG.
     *
720k *    07/13/18  DAS  7.20k
     *     - Added *PSSR subroutine to capture unexpected errors
     *       and pass them back instead of getting stuck.
     *
720l *    07/17/18  DAS  7.20l
     *     - Revised printing 'Log()' lines. They are not looked at
     *       and a program blew up because spool file filled up.
     *
720m *    07/18/18  DAS  7.20m
     *     - Temp mod to return *OK if instead of no filename error.
     *       Device is stuck in a loop sending invalid stop/route
     *       complete commands. This is the quickest way to stop it.
     *       When *OK is sent back, the device will end up deleting
     *       the invalid entries from the send queue.
     *
720n *    08/01/18  DAS  7.20n
     *      - Revised ElemSignature to trim signature name and check
     *        for corresponding Stop.
     *
720oA*    08/21/18  LMC 7.20o
     *      - Added new file HACCPLOG to store the pcm answers.
     *
720p *    09/06/18  GJA 7.20p
     *      - Fix:  TTBFLG was not being populated correctly.
     *
720qA*    11/21/18  RBD 7.20q
     *      - Fix 7.20p was a mod mark only, so this 7.20q mod
     *        will actually fix TTBFLG.
     *
720rA*    12/20/18  RBD 7.20r
     *      - Added bfcdebug logic.
     *
720s *    07/27/18  RTR  7.20s
     *      - Fix: Check for invalid stop.lastord before chain. Was
     *        getting blanks and causing decimal data error.
     *
720tA*    03/31/18  DAS  7.20t
     *      - Revised ElemRoute to update Start Date/Time if zero.
     *
730aA*    03/28/19  DAS  7.30a
     *      - Added signeeName to signature file name.
     *
730bA*    04/01/19  DAS  7.30b
     *      - Removed invalid characters from signataure file name.
     *
730c *    04/10/19  RBD  7.30c
     *      - Fix: Revised ElemRoute to not clear TTRSER after setting it.
     *
730dA*    09/11/19  RBD  7.30d
     *      - Fix: Clear label number if no hit to ORDP, was writing a
     *        label number to added/prev returns record when there is none.
     *
730eA*    09/27/19  RBD  7.30e
     *      - Added customer on site delivery logic, requested by SWT.
     *        Will write ONSITESCAN, ONSITESCANERROR or PALLETSCAN
     *        record to Trax pieces file if conditions met.
     *      - In ElemItem only chain to tttrx1 for update if uci is not
     *        zero. With onsite delivery there will be tttrx records with
     *        a zero Trax# and we don't want to update those guys, we
     *        always want to write them.
     *
740a *    03/05/20  RBD  7.40a
     *      - Fix: StopId was getting populated with hostStop after call
     *        to getstop ... should not have been.  Found this at Colony
     *        because they had host stop greater than 2 digits and it
     *        caused 'receiver too small' error.
     *
740b *    03/10/20  RBD  7.40b
     *      - Fix: Extension of 740a fix, same problem found in other
     *        routines, had to add call to getstop in some routines too.
     *        Found several routines checking for attribute 'stopid'
     *        though the element doesn't have stopId and commented
     *        those out.
     *
740cA*    04/15/20  RBD  7.40c
     *      - Per SWT change ONSITESCAN to INSTORESCAN and
     *        ONSITESCANERROR to INSTORESCANERR.
740dA*    05/26/20  LMC  7.40d
     *      - Recompile Only - Database change
740eA*    06/10/20  KDE  7.40e
     *      - Account for new field in XML.  Bump up scan and message by 1
      *      -
740fA*    06/17/20  RBD  7.40f
     *      - Write host stop instead of stop id in TTTRX record for
     *        PALLETSCAN and INSTORESCAN records.
     *
740gA*    08/06/20  RBD  7.40g
     *      - Fix: Trax returns breakdown flag (TTBFLG). If u/m type
     *        is 'N' it needs to be converted to 0 because that's what
     *        RN250 is expecting ... has been that way since Trax 1.
     *
740hA*    08/24/20  RBD  7.40h
     *      - Don't write PALLETSCAN record if deliveredTimeStamp is
     *        default date 20000101.
     *      - Only write TTRTN record if it doesn't already exist.
     *      - Only update TTRTN record if processed qty equals zero.
     *
740iA*    08/31/20  RBD  7.40i
     *      - Write true operation flag for PALLETSCAN record instead
     *        of hardcoded 'S'.  Don't recall why it was hardcoded.
     *
740j *    09/08/20  GJA  7.40j
     *      - Fix: 7.40h was only chaning with route ID so it would d
     *        only create the first return and not all of them.
     *
750aA*    11/16/20  RBD  7.50k
     *      - Added new files TTIVC and TTIVCH.
     *
750bA*    02/25/21  RBD  7.50b
     *      - Fix: 7.40j was chaining with status 1 thus causing the
     *        return to be duplicated if the return already existed
     *        with a status other than 1.
     *
750cA*    11/04/21  RBD  7.50c
     *      - Revision to 720d mod, instead of hardcoding 'S' for
     *        oper flag in exception record write the item's actual
     *        value for op flag.
     *
750dA*    11/09/21  RBD  7.50d
     *      - Changed 750c, get op flag from Trax pieces record.
     *
750eA*    11/23/21  RBD  7.50e
     *      - Fix: Colony has reported a route here and there that
     *        gets stuck in an infinite loop uploading from the Trax
     *        device to the iSeries, and when this happens the Route
     *        Completion Report (TR340) gets spooled out every time
     *        causing the report to print a gazillion times and/or
     *        fill up the outq. This fix will mitigate this issue by
     *        only calling TR340 if the route has not been previously
     *        uploaded.
     *
     *      - NOTE: Initially I changed this pgm to sqlrpgle and used
     *        sql to determine if report had printed yet or not. However,
     *        I got the following compile error:
     *
     *          /copy LIBHTTPBFC/qrpglesrc,config_h
     *          SQL1003  30    2797  Nested /COPY statements not allowed.
     *
     *          Kenneth and I researched and found copysrc httpapi_h
     *          has a /copy statement, thus causing the nesting error.
     *          We tried changing it from /copy to /include but still got
     *          the same error. So for now I've changed the pgm back to
     *          rpgle and will use old school read instead of sql. I've
     *          saved the sqlrpgle version in PIRWORKRD/TR842.SAV so as
     *          time permits we can play with it and try to get it working.
     *
750fA*    12/15/21  RBD  7.50f
     *      - Fix: Can't use ttlog "try" for 750e mod to see if route
     *        has been previously uploaded, turns out "try" doesn't get
     *        updated on upload to iSeries.  So instead will only call
     *        TR340 if route does not exist in TTRTE yet or if it does
     *        and finish date is 0's.
     *      - Only update finish date and time when posting completed
     *        route.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *    Custom Client Revisions:  ISupply
     *
ISPa *    11/12/13   GJA  ISPa
     *      - Enh: Do no print Completion Report.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *    Custom Client Revisions:  City Line
     *
CLDa *    08/27/19   RBD  CLDa
     *      - Enh: Print Route Completion Report.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *    Custom Client Revisions:  Colony Foods
     *
CFIa *    03/10/20   RBD  CFIa
     *      - Enh: Print Route Completion Report.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *    Custom Client Revisions:  Graves Menu Maker
     *
GMMa *    05/06/20   RBD  GMMa
     *      - Enh: Print Route Completion Report.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  Notes
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

720cAFordh      if   e           k disk
720jAFordh3     if   e           k disk    rename(ohrec:ohrec3)
650aAFordd      if   e           k disk
     Fordp      if   e           k disk
     Foptions   if   e           k disk
640aAFpiruser1  if   e           k disk
     Frtehed    if   e           k disk
     Flabel     if   e           k disk
     Fttlog     uf   e           k disk
     Fttrte     uf a e           k disk
740hDF*ttrtn     uf a e           k disk
740hDF*ttrtn3    uf a e           k disk
740jMFttrtn     uf a e           k disk
     Fttstp     uf a e           k disk
     Ftttrx1    uf a e           k disk
650bAFttstpfr   uf a e           k disk
710cAFttexcp    uf a e           k disk
720bAFttpics    o    e           k disk
720oAFhaccplog  o    e             disk
720oAFhaccplog5 uf   e           k disk    prefix(p_) rename(hlrec:hlrec5)
720oAFhaccpq1   if   e           k disk
720oAFordh9     if   e           k disk    prefix(o_) rename(ohrec:ohrec9)
720rAfbfcdbgflg if   e           k disk    usropn
720rAfbfcdebug  o    e           k disk    usropn
750aAFttivc     o    e           k disk
750aAFttivch    if   e           k disk
     Fqsysprt   o    f  132        printer oflind(*inof)
640bAF                                     usropn

650fA*----------------------------------------------------------------
650fA* Customer ID.
650fA*----------------------------------------------------------------

ISPaA /copy qcopysrc,id#isupply
CLDaA /copy qcopysrc,id#citylin
CFIaA /copy qcopysrc,id#cfi
GMMaA /COPY QCOPYSRC,ID#GMM

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#Item
     D savever#        s                   like($itver#)
     D save$item       s                   like($item)
     D save$item2      s                   like($item2)

     *----------------------------------------------------------------
     *  *TRAX  -  TRAX options
     *
     * Fields
     *
     *    OPTHST  -  Days to keep TRAX export data (1-999)
     *    OPTSLI  -  Save log info
     *    OPTCWR  -  Catch weight required
     *    OPTOFT  -  Order number field type
     *    OPTDFT  -  Driver field type
     *    OPTRFT  -  Route field type
     *    OPTCAP  -  Capitalize input
     *    OPTDBL  -  Double click delivery
     *    OPTEKD  -  Entry key delivery
     *    OPTDAR  -  Delivery after return
     *    OPTIDB  -  Include item data base
     *    OPTBDA  -  Breakdowns allowed
     *    OPTGBD  -  Generic breakdown allowed
     *    OPTRTQ  -  Pre-trip questions
     *    OPTOTQ  -  Post-trip questions
     *    OPTCCE  -  Credit card enabled
     *    OPTSIG  -  Signature enabled
     *    OPTPIV  -  Print invoice
     *    OPTSDA  -  Send data after stop
     *    OPTWSP  -  Ws port
     *    OPTWSI  -  Ws IP
     *    OPTSVD  -  Save days
     *    OPTERT  -  Environment run time
     *    OPTEDV  -  Environment device
     *    OPTEOS  -  Environment OS
     *    OPTESW  -  Environment screen width
     *    OPTESH  -  Environment screen height
     *    OPTARE  -  Add return enabled
     *
     * Data structure
     *
     D opdat2          ds
     D  opthst                 1      3  0
     D  optsli                 4      4
     D  optcwr                 5      5
     D  optoft                 6      6
     D  optdft                 7      7
     D  optrft                 8      8
     D  optcap                 9      9
     D  optdbl                10     10
     D  optekd                11     11
     D  optdar                12     12
     D  optidb                13     13
     D  optbda                14     14
     D  optgbd                15     15
     D  optrtq                16     16
     D  optotq                17     17
     D  optcce                18     18
     D  optsig                19     19
     D  optpiv                20     20
     D  optsda                21     21
     D  optwsp                22     26  0
     D  optwsi                27     41
     D  optsvd                42     43  0
     D  optert                44     47
     D  optedv                48     57
     D  opteos                58     67
     D  optesw                68     71  0
     D  optesh                72     75  0
     D  optare                76     76
     D  opten2               117    117
650gA*----------------------------------------------------------------
650gA*  *TRAX2  -  More TRAX options
650gA*----------------------------------------------------------------
650gA*
650gA* Fields
650gA*
650gA*    OPTSBU  -  Use system suspend battery power timeout.
650gA*    OPTSB   -  System suspend battery power timeout.
650gA*    OPTSEU  -  Use system suspend external power timeout.
650gA*    OPTSE   -  System suspend external power timeout.
650gA*    OPTBBU  -  Use backlight off battery power timeout.
650gA*    OPTBB   -  Backlight off battery power timeout.
650gA*    OPTBEU  -  Use backlight off external power timeout.
650gA*    OPTBE   -  Backlight off external power timeout.
710cA*    OPTV12  -  Default = N.  Y = create V1.2 xml.
710cA*    OPTV20  -  Default = N.  Y = create V2.0 xml.
710dA*    OPTDIR  -  IFS main directory
710eA*    OPTIU   -  IFS user
720cA*    OPTOSIG -  Create Customer Order Signatures (Default = N)
720cA*               OPTOSG add for compatability with OPTIONSDS
650gA*
650gA* Data structure
650gA*
650gAD opdat3          ds
650gAD  optsbu                 1      1
650gAD  optsb                  2      4  0
650gAD  optseu                 5      5
650gAD  optse                  6      8  0
650gAD  optbbu                 9      9
650gAD  optbb                 10     13  0
650gAD  optbeu                14     14
650gAD  optbe                 15     17  0
710cAD  optv12                18     18
710cAD  optv20                19     19
710dAD  optdir                20     39
710eAD  optiu                 40     49
720cAD  optosg                50     50
720cAD  optosig               50     50
650gAD  optend               117    117

     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D client          s             10
     D clientLoc       s             10
     D fileExists      s             10i 0
     D bfcoffset       s              3  0 inz(0)
     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
720rAd dbgflgExists    s               n
720rAd debug           s               n
720rAd debugAfter      s               n
720rAd debugBefore     s               n
720rAd debugLoc        s              1
     D error           s               n
     D filename        s             45A   varying
     D forever         s               n   inz(*on)
750bAD foundReturn     s               n
     D  noStamp        s               z   inz(z'0001-01-01-00.00.00.000000')
750aAd pos             s              3  0
     D PrintLine       s            132A
750eAD printRpt        s               n
     D*userData        ds                  likeds(userData_t) inz

     D qCmd            s           3000    varying
750aAD totalInv        s             14  5 inz(0)
750bAD stat5           s                   like(ttstat) inz('5')
750bAD stat9           s                   like(ttstat) inz('9')

     *----------------------------------------------------------------
     *  Attribute Data Structures
     *----------------------------------------------------------------

     D parent          ds                  qualified
     D  routeId                            like(ttrrti)
     D  route                              like(ttrrte)
     D  truck                              like(ttrtru)
     D  warehouse                          like(ttrwhs)
     D  driverId                      5  0 inz(0)
     D  deviceId                           like(ttrser)
     D  user                               like(ttrusr)
     D  downloadStamp                  z   inz(z'0001-01-01-00.00.00.000000')
     D  downloadDate                  8s 0 inz(0)
     D  downloadTime                  6s 0 inz(0)
     D  uploadStamp                    z   inz(z'0001-01-01-00.00.00.000000')
     D  uploadDate                    8s 0 inz(0)
     D  uploadTime                    6s 0 inz(0)
     D  beginStamp                     z   inz(z'0001-01-01-00.00.00.000000')
     D  beginDate                     8s 0 inz(0)
     D  beginTime                     6s 0 inz(0)
     D  endStamp                       z   inz(z'0001-01-01-00.00.00.000000')
     D  endDate                       8s 0 inz(0)
     D  endTime                       6s 0 inz(0)
     D  returnStamp                    z   inz(z'0001-01-01-00.00.00.000000')
     D  returnDate                    8s 0 inz(0)
     D  returnTime                    6s 0 inz(0)
     D  isRouteReturn                 1
     D  returnNotes                  30

720oAD answer          ds                  qualified
720oAD  routeId                            like(ttfrri)
720oAD  hostStop                      5  0 inz(0)
720oAD  stopId                             inz(0) like(ttfrst)
720oAD  questionSeq                        inz(0) like(hiseq#)
720oAD  valueSeq                      5  0 inz(0)
720oAD  response                     30
720oAD  stamp                          z   inz(z'0001-01-01-00.00.00.000000')
720oAD  date                          8s 0 inz(0)
720oAD  time                          6s 0 inz(0)

     D stop            ds                  qualified
     D  routeId                            like(ttprti)
     D  hostStop                      5  0 inz(0)
     D  stopId                             inz(0) like(ttpstp)
     D  beginTvlStamp                  z   inz(z'0001-01-01-00.00.00.000000')
     D  beginTvlDate                  8s 0 inz(0)
     D  beginTvlTime                  6s 0 inz(0)
     D  endTvlStamp                    z   inz(z'0001-01-01-00.00.00.000000')
     D  endTvlDate                    8s 0 inz(0)
     D  endTvlTime                    6s 0 inz(0)
     D  beginUnlStamp                  z   inz(z'0001-01-01-00.00.00.000000')
     D  beginUnlDate                  8s 0 inz(0)
     D  beginUnlTime                  6s 0 inz(0)
     D  endUnlStamp                    z   inz(z'0001-01-01-00.00.00.000000')
     D  endUnlDate                    8s 0 inz(0)
     D  endUnlTime                    6s 0 inz(0)
     D  beginStamp                     z   inz(z'0001-01-01-00.00.00.000000')
     D  beginDate                     8s 0 inz(0)
     D  beginTime                     6s 0 inz(0)
     D  endStamp                       z   inz(z'0001-01-01-00.00.00.000000')
     D  endDate                       8s 0 inz(0)
     D  endTime                       6s 0 inz(0)
     D  isReturn                      1
     D  returnStamp                    z   inz(z'0001-01-01-00.00.00.000000')
     D  returnDate                    8s 0 inz(0)
     D  returnTime                    6s 0 inz(0)
     D  returnNotes                        like(ttpmem)
     D  isReset                       1
     D  resetStamp                     z   inz(z'0001-01-01-00.00.00.000000')
     D  resetDate                     8s 0 inz(0)
     D  resetTime                     6s 0 inz(0)
     D  printedStamp                   z   inz(z'0001-01-01-00.00.00.000000')
     D  printedDate                   8s 0 inz(0)
     D  printedTime                   6s 0 inz(0)
     D  notes                              like(ttpmem)
720cAD  delvPieces                    7  0 inz(0)
720cAD  returnPieces                  7  0 inz(0)
720cAD  addRtnPieces                  7  0 inz(0)
720cAD  lastLbl#                           like(lblbl#)
720cAD  lastOrd                            like(lbord)

     D stopFlag        ds                  qualified
     D  routeId                            like(ttfrri)
     D  hostStop                      5  0 inz(0)
     D  stopId                             inz(0) like(ttfrst)
     D  order                              inz(0) like(ttfror)
     D  character                          like(ttfrch)
     D  response                           like(ttfrre)
     D  stamp                          z   inz(z'0001-01-01-00.00.00.000000')

     D signature       ds                  qualified
     D  hostStop                      5  0 inz(0)
     D  stopId                             inz(0) like(ttfrst)
     D  stamp                          z   inz(z'0001-01-01-00.00.00.000000')
     D  date                          8s 0 inz(0)
     D  time                          6s 0 inz(0)
     D  notFound                           like(ttpgsn)
     D  name                               like(ttpgna)
     D  fileName                           like(ttpgfn)

     D picture         ds                  qualified
     D  hostStop                      5  0 inz(0)
     D  stopId                             inz(0) like(ttfrst)
     D  item                               like(ttitem)
     D  scanId                       10
720bAD  uci                                like(ttuci)
     D  stamp                          z   inz(z'0001-01-01-00.00.00.000000')
     D  date                          8s 0 inz(0)
     D  time                          6s 0 inz(0)
     D  fileName                           like(ttpcfnam)

     D item            ds                  qualified
     D  hostStop                      5  0 inz(0)
     D  stopId                             inz(0) like(ttfrst)
     D  item                               like(ttitem)
     D  scanId                       10
     D  uci                                like(ttuci)
     D  palletNumber                  7  0 inz(0)
     D  toteNumber                    7  0 inz(0)
     D  initBrkFlag                   1
     D  initUOM                      10
     D  piecesUOM                    10
     D  piecesUOMType                 1
     D  piecesBucket                  1
     D  opFlag                        1
     D  scanStamp                      z   inz(z'0001-01-01-00.00.00.000000')
     D  scanDate                      8s 0 inz(0)
     D  scanTime                      6s 0 inz(0)
     D  delvStamp                      z   inz(z'0001-01-01-00.00.00.000000')
     D  delvDate                      8s 0 inz(0)
     D  delvTime                      6s 0 inz(0)
     D  delvPieces                    5  0 inz(0)
     D  notes                              like(ttmemo)
     D  isAddedReturn                  n
     D  returnStamp                    z   inz(z'0001-01-01-00.00.00.000000')
     D  returnDate                    8s 0 inz(0)
     D  returnTime                    6s 0 inz(0)
     D  returnCode                    2
     D  returnUOM                    10
     D  returnBrkDn                   1
     D  returnPieces                  5  0 inz(0)
     D  returnWeight                  9  2 inz(0)
     D  returnNotes                        like(ttmemo)

710cAD logEntry        ds                  qualified
     D  stamp                              like(ttets)
     D  driver                             like(ttedrv)
     D  stopId                        5
     D  scan                               like(ttescn)
     D  uci                           5p 0 inz(0)
     D  item                               like(tteitm)
     D  intendedStop                       like(ttesti)
     D  transaction                        like(ttetrn)
     D  message                    1024a   varying
720eAD  skipRecord                     n

730eAD onSiteLogEntry  ds                  qualified
730eAD  stopId                             inz(0) like(ttfrst)
730eAD  item                               like(ttitem)
730eAD  opFlag                        1
730eAD  scanStamp                      z   inz(z'0001-01-01-00.00.00.000000')
730eAD  scanDate                      8s 0 inz(0)
730eAD  scanTime                      6s 0 inz(0)
740bAD  hostStop                      5  0 inz(0)

750aAD invoice         ds                  qualified
750aAD  hostStop                      5  0 inz(0)
750aAD  stopId                             inz(0) like(ttfrst)
750aAD  docType                       1
750aAD  docDriver                     5  0 inz(0)
750aAD  docPrintedTS                   z   inz(z'0001-01-01-00.00.00.000000')
750aAD  docNumber                    15
750aAD  docOrdNos                    15
750aAD  docIntOrdNos                 15
750aAD  docCurrency                   1
750aAD  docItmsQty                    7  0 inz(0)
750aAD  docTotB4Tx                    9  2 inz(0)
750aAD  docTotTx                      9  2 inz(0)
750aAD  docTot                        9  2 inz(0)
750aAD  docHasReturns                 1
750aAD  docItmsQtyRtn                 7  0 inz(0)
750aAD  docTotB4TxRtn                 9  2 inz(0)
750aAD  docTotTxRtn                   9  2 inz(0)
750aAD  docTotRtn                     9  2 inz(0)

     *----------------------------------------------------------------
     *  Global Variables
     *----------------------------------------------------------------

     D gEmp#           s              5  0
     D gUser           s             10

     D Stack           ds                  occurs(16)
     D   elementName               1024A   varying
     D   elementPath              24576A   varying

710cA*----------------------------------------------------------------
710cA*  GETFLDS parameters
710cA*----------------------------------------------------------------

     d gfString        s          65535A   varying
     d gfDelimiter     s              1A
     d gfStartFld      s              3  0
     d gfRtnCode       s             10
     d gfFldsReturned  s              3  0
     d gfFld1          s          65535A   varying
     d gfFld2          s          65535A   varying
     d gfFld3          s          65535A   varying
     d gfFld4          s          65535A   varying
     d gfFld5          s          65535A   varying
     d gfFld6          s          65535A   varying
     d gfFld7          s          65535A   varying
     d gfFld8          s          65535A   varying
     d gfFld9          s          65535A   varying
     d gfFld10         s          65535A   varying
     d gfFld11         s          65535A   varying
     d gfFld12         s          65535A   varying
     d gfFld13         s          65535A   varying
     d gfFld14         s          65535A   varying
     d gfFld15         s          65535A   varying
     d gfFld16         s          65535A   varying
     d gfFld17         s          65535A   varying
     d gfFld18         s          65535A   varying
     d gfFld19         s          65535A   varying
     d gfFld20         s          65535A   varying


     *----------------------------------------------------------------
     *  Sub-Procedure Prototypes
     *----------------------------------------------------------------

     d CmdPostCompletedRoute...
     d                 pr

     d CmdPostCompletedStop...
     d                 pr

     d CmdSendRouteStart...
     d                 pr

     d CmdSendStopStart...
     d                 pr

     d ElementEnd      pr
     d   userdata                      *   value
     d   depth                       10I 0 value
     d   name                      1024A   varying const
     d   path                     24576A   varying const
     d   value                    65535A   varying const
     d   Attrs                         *   dim(32767)
     d                                     const options(*varsize)

     d ElementStart    pr
     d   userdata                      *   value
     d   depth                       10I 0 value
     d   name                      1024A   varying const
     d   path                     24576A   varying const
     d   attrs                         *   dim(32767)
     d                                     const options(*varsize)

720oAd ElemAnswer      pr
720oAd  type                         10    const
720oAd  count                        10I 0 const
720oAd  name                        100    varying const
720oAd  value                     65535A   varying const

     d ElemGS1Code     pr
     d  type                         10    const
     d  count                        10I 0 const
     d  name                        100    varying const
     d  value                     65535A   varying const

750aAd ElemInvoice     pr
750aAd  type                         10    const
750aAd  count                        10I 0 const
750aAd  name                        100    varying const
750aAd  value                     65535A   varying const

     d ElemItem        pr
     d  type                         10    const
     d  count                        10I 0 const
     d  name                        100    varying const
     d  value                     65535A   varying const

     d ElemLogEntry    pr
     d  type                         10    const
     d  count                        10I 0 const
     d  name                        100    varying const
     d  value                     65535A   varying const
710cAd  skipElement                    n

730eAd ElemOnSiteLog   pr
730eAd  type                         10    const
730eAd  count                        10I 0 const
730eAd  name                        100    varying const
730eAd  value                     65535A   varying const

     d ElemPicture     pr
     d  type                         10    const
     d  count                        10I 0 const
     d  name                        100    varying const
     d  value                     65535A   varying const

     d ElemRoute       pr
     d  type                         10    const
     d  count                        10I 0 const
     d  name                        100    varying const
     d  value                     65535A   varying const

     d ElemSignature   pr
     d  type                         10    const
     d  count                        10I 0 const
     d  name                        100    varying const
     d  value                     65535A   varying const

     d ElemStop        pr
     d  type                         10    const
     d  count                        10I 0 const
     d  name                        100    varying const
     d  value                     65535A   varying const

     d ElemStopFlag    pr
     d  type                         10    const
     d  count                        10I 0 const
     d  name                        100    varying const
     d  value                     65535A   varying const

     d ElemTRAXData    pr
     d  type                         10    const
     d  count                        10I 0 const
     d  name                        100    varying const
     d  value                     65535A   varying const

     d GetCurrStamp    pr

     d GetOptions      pr

     d GetItem         pr
     d  whse                          3  0 const
     d  item                         15    const

     d GetTraxRoute    pr

     d Log             pr
     d   depth                       10I 0 value
     d   proc                        30A   varying const
     d   value                      100A   varying const

     d LowerToUpper    pr         65535A   varying
     d  value                     65535A   varying const

     d Print           pr
     d   text                       132A   value

730bAd RmvInvldChar    pr         65535A   varying
730bAd  value                     65535A   varying const

     d StampToDate     pr             8s 0
     d  stampIn                        z   const

     d StampToTime     pr             6s 0
     d  stampIn                        z   const

     d SetLogTime      pr

     d UpdateTTLog     pr

     d ValueToStamp    pr              z
     d  value                     65535A   varying const

     d VfyEmployee     pr

     d VfyRteId        pr

     d ZZDriCop        pr

720rAd WrtDebugLibl    pr

720rAd WrtDebugParms   pr

720rAd WrtDebug        pr
720rAd  name                        100    varying const

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.qcmdexc
      /copy qcopysrc,p.dricop
      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.getempl
710cA /copy qcopysrc,p.getflds
710dAD/copy qcopysrc,p.getstop


720aDD*tr844           pr                  extpgm('TR844')
720aMD tr842D          pr                  extpgm('TR842D')
     D  pwhse                         3  0
     D  prtid                         5
     D  prtn                          8
     D  perm                         60
     D  pversion                      5
     D  pcommand                     30
     D  pstop                         2  0

720aDD*TR845           pr                  extpgm('TR845')
720aMD TR842U          pr                  extpgm('TR842U')
     D  whse                          3  0
     D  rtid                          5
     D  rtncd                         8
     D  rtnmsg                       60
     D  pversion                      5
     D  pcommand                     30
     D  pstop                         2  0

720aDd*TR846           pr                  extpgm('TR846')

     D tr847           pr                  extpgm('TR847')
     D  pwhse                         3  0
     D  prtid                         5
     D  prtn                          8
     D  perm                         60

     D TR340           pr                  extpgm('TR340')
     D  whse                          3  0
     D  rtid                          5

720rA*----------------------------------------------------------------
720rA*  Prototypes
720rA*----------------------------------------------------------------

720rAd GetLiblCL       pr                  extpgm('GETLIBLCL')
720rAd  libList                    1024


     *----------------------------------------------------------------
     *  IFS Prototypes
     *----------------------------------------------------------------

720jA /copy qcopysrc,p.copyifs
      /copy qcopysrc,c#ifsio_h
      /copy qcopysrc,errno_h
      /copy qcopysrc,httpapi_h
      /copy qcopysrc,ifsio_h

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pVersion    Trax Version
     *      pCommand    Command
     *      pEmpNo      Employee Number
     *      pWhse       Warehouse
     *      pRtid       Route id
     *      pStop       Stop number
     *      pPath       Path to file
     *      pFile       XML file name
     *      pStamp      Timestamp
     *      pLatitude   Latitude
     *      pLongitude  Longitude
     *
     *    Returned Parameters
     *      pRtnCode    -  Return code (*OK, *ERROR)
     *      pRtnMessage -  Error message
     *
     *----------------------------------------------------------------

     d TR842           pr                  extpgm('TR842')
     d  pVersion                      5
     d  pCommand                     30
     d  pEmpNo                        5
     d  pWhse                         3  0
     d  pRtid                         5
     d  pStop                         5
     d  pPath                       100
     d  pFile                       100
     d  pStamp                       19
     d  pLatitude                    15
     d  pLongitude                   15
     d  pRtnCode                     10
     d  pRtnMessage                  60

     d TR842           pi
     d  pVersion                      5
     d  pCommand                     30
     d  pEmpNo                        5
     d  pWhse                         3  0
     d  pRtid                         5
     d  pStop                         5
     d  pPath                       100
     d  pFile                       100
     d  pStamp                       19
     d  pLatitude                    15
     d  pLongitude                   15
     d  pRtnCode                     10
     d  pRtnMessage                  60

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------

      /free

        *inlr = *on;
        pRtnCode = '*OK';
        pRtnMessage = '';

720rA   // See if debug is turned on

720rA   debug = *off;
720rA   if dbgflgExists;
720rA     chain(e) (#pgm) bfcdbgflg;
720rA     if %found(bfcdbgflg);
720rA       select;
720rA         when bdfflag > 0;
720rA           debug = *on;
720rA       endsl;
720rA     endif;
720rA   endif;

720rA   if debug;
720rA     WrtDebugLibl();
720rA     WrtDebugParms();
720rA   endif;

        // Verify employee number

        VfyEmployee();
        if pRtnMessage <> ' ';
          return;
        endif;

        // Verify route id

        VfyRteId();
        if pRtnMessage <> ' ';
          return;
        endif;


        // *** TEST TEST TEST ***
        //pRtnMessage = 'Test Only - No processing done for command ' + pCommand;
        //return;


        // Combine path and file name

        fileName = %trim(pPath) + %trim(pFile);

        // Verify file exists for some commands

        if pCommand = 'postCompletedRoute'
          or pCommand = 'postCompletedStop';
            if pFile = '';
720mA         return;
              pRtnCode = '*ERROR';
              pRtnMessage = 'TR842: Error - No file name sent';
              return;
            endif;
            fileExists = Access(fileName: F_OK);
            if fileExists < 0;
720mA         return;
              pRtnCode = '*ERROR';
              pRtnMessage = 'TR842: Error - File not found: ' + fileName;
              return;
            endif;
        endif;

        // Process command

        select;

          when pCommand = 'postCompletedRoute';
            CmdPostCompletedRoute();

          when pCommand = 'sendRouteStart';
            CmdSendRouteStart();

          when pCommand = 'sendStopStart';
            CmdSendStopStart();

          when pCommand = 'postCompletedStop';
            CmdPostCompletedStop();

        endsl;

        return;

      /end-free

     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     *----------------------------------------------------------------
     C     *inzsr        begsr
      /free

720rA    open(e) bfcdbgflg;
720rA    if %error;
720rA      dbgflgExists = *off;
720rA    else;
720rA      dbgflgExists = *on;
720rA    endif;

       GetClient(client: clientLoc);

       qcmd = 'ovrprtf file(qsysprt) outq(qprint)';
       qcmdexc(qcmd: %len(qcmd));

       open(e) qsysprt;

      /end-free
     C                   endsr

720ka*----------------------------------------------------------------
720kA*  *PSSR  Unexpected error handler
720kA*----------------------------------------------------------------
720kA
720kA /free
720kA  begsr *pssr;

         // Make sure we don't get caught in an infinite loop

         if pssrflag;
           *inlr = *on;
           return;
         endif;

         pssrflag = *on;

         //  Send message back to calling program

         dump(a);

         pRtnCode = '*ERROR';
         pRtnMessage = 'Error: '
               + %trim(#pgm) + '(' + %char(#stmt) + ') '
               + %trim(#pgmmsg) + ' - ' + #status
               + ' (' + %trimr(#job) + '/'
               + %trimr(#jobn) + '/' + %trimr(#curruser) + ')';

         *inlr = *on;
         return;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  Printer output
     *
     *----------------------------------------------------------------

     Oqsysprt   E
     O                       PrintLine          132

     *----------------------------------------------------------------
     *  CmdPostCompletedRoute    Process completed route XML file
     *----------------------------------------------------------------

     p CmdPostCompletedRoute...
     p                 b
     d CmdPostCompletedRoute...
     d                 pi

     * Local Variables

     d rtnCode         s              8
     d rtnMsg          s             60
     d zeroStop        s              2  0

      /free

        // Process XML File

        if http_parse_xml_stmf( filename
                              : HTTP_XML_CALC
                              : %paddr(ElementStart)
                              : %paddr(ElementEnd)
                              : *null ) < 0;
          print(http_error() + '-' + fileName);
          pRtnCode = '*ERROR';
          pRtnMessage = 'TR842: Error parsing file ' + fileName
                      + ' (PostCompleteRoute)';
          print(pRtnMessage);
          return;
        endif;

        // Update TTLOG record

        UpdateTTLog();

        // Close printer file

        qcmd = 'dltovr file(qsysprt)';
        qcmdexc(qcmd: %len(qcmd));
        close(e)   qsysprt;

        // Do final updating and print report

        if pRtnCode = '*OK';

720aD     //TR845(parent.Warehouse: parent.RouteId: rtnCode: rtnMsg:
720aM     TR842U (parent.Warehouse: parent.RouteId: rtnCode: rtnMsg:
                  pVersion: pCommand: zeroStop);

720aD     //TR846();

          TR847(parent.warehouse: parent.routeId: rtnCode: rtnMsg);


          // ***** TEST TEST - Not Printing Report Right Now ***
CLDaA     // Print report for City Line
CFIaA     // Print report for Colony
GMMaA     // Print report for Graves Menu Maker


ISPaA     select;
ISPaA       when client = ISupply;
ISPaA         // no report
ISPaA       other;

750eA       // print if route has not been previously uploaded
750eA       if printRpt = *on;

CLDaA         if client = cityline
CFIaA           or client = colony
GMMaA           or client = MenuMaker;
CLDaM           TR340(parent.warehouse: parent.routeId);
CLDaA         endif;

750eA       endif;
ISPaA     endsl;

        endif;

        return;
      /end-free
     p                 e

     *----------------------------------------------------------------
     *  CmdPostCompletedStop    Process completed stop XML file
     *
     *    This assumes TRAXData only contains information for 1 Stop
     *
     *----------------------------------------------------------------

     p CmdPostCompletedStop...
     p                 b
     d CmdPostCompletedStop...
     d                 pi

     * Local Variables

     d rtnCode         s              8
     d rtnMsg          s             60
     d temp200         s            200

      /free

        // Process XML File

        if http_parse_xml_stmf( filename
                              : HTTP_XML_CALC
                              : %paddr(ElementStart)
                              : %paddr(ElementEnd)
                              : *null ) < 0;
          print(http_error() + '-' + fileName);
          pRtnCode = '*ERROR';
          pRtnMessage = 'TR842: Error parsing file ' + fileName
                      + ' (PostCompleteStop)';
          print(pRtnMessage);
          return;
        endif;

        // Update TTLOG record

        UpdateTTLog();

        // Close printer file

        qcmd = 'dltovr file(qsysprt)';
        qcmdexc(qcmd: %len(qcmd));
        close(e)   qsysprt;

        // Do final updating

        if pRtnCode = '*OK';

720aD     //TR845(parent.Warehouse: parent.RouteId: rtnCode: rtnMsg:
720aM     TR842U (parent.Warehouse: parent.RouteId: rtnCode: rtnMsg:
                  pVersion: pCommand: stop.stopId);

710aD     //TR846();

          TR847(parent.warehouse: parent.routeId: rtnCode: rtnMsg);

        endif;

720cA   // Format message for test/email
720cA
720sA   monitor;
720sA     stop.lastOrd = stop.lastOrd * 1;
720sA   on-error;
720sA     stop.lastOrd = 0;
720sA   endmon;
720sA
720cA   chain (parent.warehouse: stop.lastOrd) ordh;
720cA   if not %found(ordh);
720cA     ohcnam = '';
720cA   endif;
720cA
720cA   temp200 = 'Route ' + %trim(parent.route) + '/' + parent.routeId + ', '
720cA           + 'Stop ' + %char(stop.stopId) + ' - '
720cA           + 'Customer ' + %char(ohcord) + ' ' + %trim(ohcnam) + ' - '
720cA           + 'Completed.';
720cA
720cA   if stop.returnPieces = 0;
720cA     temp200 = %trimr(temp200) + ' All pieces delivered.';
720cA   else;
720cA     temp200 = %trimr(temp200) + ' '
720cA             + 'Pieces delivered: ' + %char(stop.delvPieces) + '. '
720cA             + 'Pieces returned: ' +  %char(stop.returnPieces) + '.';
720cA   endif;
720cA
720ca   if stop.addRtnPieces > 0;
720cA     temp200 = %trimr(temp200) + ' Previous Pieces returned: '
720cA             +  %char(stop.addRtnPieces) + '.';
720cA   endif;
720cA
720cA   // Move message into Path/File fields to return to web service
720cA
720cA   pPath = %subst(temp200: 1: 100);
720cA   pFile = %subst(temp200: 101: 100);

        return;
      /end-free
     p                 e

     *----------------------------------------------------------------
     *  CmdSendRouteStart   Process start of route
     *----------------------------------------------------------------

     p CmdSendRouteStart...
     p                 b
     d CmdSendRouteStart...
     d                 pi

     * Local Variables

     d stampIn         s               z

      /free

        // Update/Create TTRTE record

        chain (pWhse: pRtId) ttrte;
        if not %found(ttrte);
          clear ttrrec;
        endif;


        stampIn = ValueToStamp(pStamp);
        ttrsrd = StampToDate(stampIn);
        ttrsrt = StampToTime(stampIn);

        if %found(ttrte);
          update(e) ttrrec;
        else;
          ttrwhs = pWhse;
          ttrrti = pRtid;
          write(e) ttrrec;
        endif;

        return;
      /end-free
     p                 e

     *----------------------------------------------------------------
     *  CmdSendStopStart    Process start of stop
     *----------------------------------------------------------------

     p CmdSendStopStart...
     p                 b
     d CmdSendStopStart...
     d                 pi

     * Local Variables

     d stampIn         s               z
     d stopId          s              2  0
710dAd dktStop         s              2  0
710dAd hostStop        s              5  0

      /free

        // Convert sent Host Stop to numeric. If error, get out.

        monitor;
710dM     hoststop = %dec(pStop:5:0);
        on-error;
          return;
        endmon;

710dA  // Get Dakota Stop number
710dA
710dA  GetStop('*DKTSTP': pwhse: pRtid: 0: dktStop: hostStop);

740eA   // Fix should be reviewed by Retha.
740eA   if dktStop = 0;
740eA     if hostStop > 99;
740eA       dktStop = 0;
740eA     else;
740eA       dktStop = hostStop;
740eA     endif;
740eA   endif;

710dA   // Extra protection that valid dktStop is returned.
710dA
710dA   monitor;
710dA     stopId = dktStop;
710dA   on-error;
710dA     return;
710dA   endmon;

710dA   //stopId = hostStop;   **740aD**

710dA   // Get out if Dakota Stop is zero
710dA
710dA   if stopId = 0;
710dA     return;
710dA   endif;

        // Update/Create TTSTP record

        chain (pWhse: pRtId: stopId) ttstp;
        if not %found(ttstp);
          clear ttprec;
        endif;

        stampIn = ValueToStamp(pStamp);
        ttpsrd = StampToDate(stampIn);
        ttpsrt = StampToTime(stampIn);

        if %found(ttstp);
          update(e) ttprec;
        else;
          ttpwhs = pWhse;
          ttprti = pRtid;
          ttpstp = stopId;
          write(e) ttprec;
        endif;

        return;
      /end-free
     p                 e

720oA*----------------------------------------------------------------
720oA* ElemAnswer    -  Process Answer Element
720oA*----------------------------------------------------------------

720oAp ElemAnswer      b
720oAd ElemAnswer      pi
720oAd  type                         10    const
720oAd  count                        10I 0 const
720oAd  name                        100    varying const
720oAd  value                     65535A   varying const

720oA* Local Variables

740bAd dktStop         s              2  0
740bAd hostStop        s              5  0

720oA /free

720oA   // Initialize attribute data structure

720oA   // Save attributes to data structure

720oA   select;

720oA     when type = 'attribute' and name = 'parentRouteID';
720oA       answer.routeId = value;

720oA     when type = 'attribute' and name = 'stopNumber';
720oA       monitor;
740eA         if value = '';
740eA           answer.hostStop =0;
740eA         else;
720oA           answer.hostStop = %dec(value:5:0);
740eA         endif;
720oA       on-error;
720oA         answer.hostStop = 99999;
720oA       endmon;
720oA       //answer.stopId = answer.hostStop;   **740bD**

740bA       // Get Dakota Stop number
740bA
740bA       hostStop = answer.hostStop;
740bA       GetStop('*DKTSTP': pwhse: pRtid: 0: dktStop: hostStop);

740eA   // Fix should be reviewed by Retha.
740eA   if dktStop = 0;
740eA     if hoststop > 99;
740eA       dktStop=0;
740eA     else;
740eA       dktStop = hostStop;
740eA     endif;
740eA   endif;

740bA        // Extra protection that valid dktStop is returned.
740bA
740bA        monitor;
740bA          answer.stopId = dktStop;
740bA        on-error;
740bA          return;
740bA        endmon;

720oA     when type = 'attribute' and name = 'answerSequence';
720oA       monitor;
720oA         answer.valueSeq = %dec(value:5:0);
720oA       on-error;
720oA         answer.valueSeq = 0;
720oA       endmon;

720oA     when type = 'attribute' and name = 'questionNumber';
720oA       monitor;
720oA         answer.questionSeq = %dec(value:5:0);
720oA       on-error;
720oA         answer.questionSeq = 0;
720oA       endmon;

720oA     //when type = 'attribute' and name = 'stopNumber';   **740bD**
720oA     //  monitor;                                         **740bD**
720oA     //    answer.stopId  = %dec(value:3:0);              **740bD**
720oA     //  on-error;                                        **740bD**
720oA     //    answer.stopId  = 0;                            **740bD**
720oA     //  endmon;                                          **740bD**

720oA     when type = 'attribute' and name = 'questionResponse';
720oA       answer.response = value;

720oA     when type = 'attribute' and name = 'stopFlagTimeStamp';
720oA       answer.stamp = ValueToStamp(value);

720oA   endsl;

720oA   // Process attributes

720oA   if name = '*NoMoreAttributes';

720oA     if answer.routeId <> parent.routeID;
720oA       return;
720oA     endif;

720oA     //if answer.stopId = 0;               **740bD**
720oA     //  answer.stopId = answer.hostStop;  **740bD**
720oA     //endif;                              **740bD**

720oA     // get the PCM QUESTION

720oA     chain (parent.warehouse: answer.questionSeq) haccpq1;
720oA     // do we already have this question answered?
720oA     // if we find the question already answered we will obsolete
720oA     // the one found and reload with the new answer.
720oA     chain (parent.warehouse: answer.routeId:
720oA            answer.stopId: answer.questionSeq) haccplog5;
720oA     if %found(haccplog5);
720oA       p_hlobsolete = 'Y';
720oA       getCurrStamp();
720oA       p_hlchgts = currstampsys;
720oA       p_hlchguc = CurrStampuc;
720oA       p_hlchgcpgm = ' ';
720oA       p_hlchgjpgm = #prog;
720oA       p_hlchgeusr = #curruser;
720oA       update hlrec5;
720oA     endif;

720oA     // Answer now gets loaded

720oA     hlwhse = parent.warehouse;
720oA     hlseq# = answer.questionSeq;
720oA     hlpcmd = 'TRAX';
720oA     hllevl = hilevl;
720oA     hltype = hitype;
720oA     hldata = answer.response;
720oA     hlspo  = ' ';
720oA     hlpo   = ' ';
720oA     // get customer name from ordh9
720oA     chain (parent.warehouse: answer.routeId:
720oA            answer.stopId) ordh9;
720oA     if %found(ordh9);
720oA       hlname = o_ohcnam;
720oA       hlord  = o_ohord;
720oA       hlcord  = o_ohcord;
720oA       hlcust = o_ohcust;
720oA       hloseq = 0;
720oA     else;
720oA       hlname = ' ';
720oA       hlord  = 0;
720oA       hlcord  = 0;
720oA       hlcust = 0;
720oA       hloseq = 0;
720oA     endif;
720oA     hlposeq = 0;
720oA     hllcns = ' ';
720oA     hlitem = ' ';
720oA     hlrte  = answer.routeId;
720oA     hlwarn = ' ';
720oA     hlvsq# = answer.valueSeq;
720oA     getCurrStamp();
720oA     hladdts = currstampsys;
720oA     hladduc = CurrStampuc;
720oA     hladdcpgm = ' ';
720oA     hladdjpgm = #prog;
720oA     hladdeusr = #curruser;
720oA     hlchgts = *loval;
720oA     hlchguc = *loval;
720oA     hlchgcpgm = ' ';
720oA     hlchgjpgm = ' ';
720oA     hlchgeusr = ' ';
720oA     hlexpts = *loval;
720oa     hlexpuc = *loval;
720oA     hlexpjusr = ' ';
720oA     hlobsolete = ' ';
720oA     hlsid = *loval;
720oA     hlstop = answer.stopId;
720oA     write hlrec;
720oA     clear answer;
720oA   endif;

720oA   return;
720oA /end-free
720oAp                 e

     *----------------------------------------------------------------
     * ElementEnd  -  Called for each XML end element tag
     *
     *   Attributes are available
     *   Element value is available
     *
     *----------------------------------------------------------------

     p ElementEnd      b
     d ElementEnd      pi
     d  userdata                       *   value
     d  depth                        10I 0 value
     d  name                       1024A   varying const
     d  path                      24576A   varying const
     d  value                     65535A   varying const
     d  attrs                          *   dim(32767)
     d                                     const options(*varsize)

     * Local Variables

     d attrval         s            100A   varying
     d text            s            132A
     d proc            s             30A

      /free

        // Position to stack occurance

        %occur(stack) = depth;

        // Process element value

        select;
          when name = 'Picture';
            ElemPicture('value': 0: '': value);
          when name = 'Signature';
            ElemSignature('value': 0: '': value);
        endsl;

        // Print end element line

        log(depth: 'E': '');

        // Pop element off stack by clearing stack field

        clear stack;

        return;
      /end-free
     p                 e

     *----------------------------------------------------------------
     * ElementStart  -  Called for each new XML element
     *
     *   Attributes are available
     *   Element value is not available
     *
     *----------------------------------------------------------------

     p ElementStart    b
     d ElementStart    pi
     d  userdata                       *   value
     d  depth                        10I 0 value
     d  name                       1024A   varying const
     d  path                      24576A   varying const
     d  attrs                          *   dim(32767)
     d                                     const options(*varsize)

     * Local Variables

     d count           s             10I 0
     d attrname        s            100A   varying
     d attrval         s          65535A   varying
710cAd skipElement     s               n

      /free

        // Push element onto stack

        %occur(stack) = depth;
        elementName = name;
        if depth = 1;
          elementPath = '/';
        else;
          elementPath = path + '/';
        endif;

        // Print start of element

        log(depth: 'S': '');

        // Process element attributes

        count = 1;
710cA   skipElement = *off;

        dow forever = forever;

          if attrs(count) <> *NULL;
            attrname = %str(attrs(count));
            count = count + 1;
            attrval = %str(attrs(count));
            count = count + 1;
          else;
            attrname = '*NoMoreAttributes';
            attrval = '';
          endif;

          select;

720oA       when name = 'Answer';
720oA         ElemAnswer('attribute': count: attrname: attrval);

            when name = 'GS1Code';
              ElemGS1Code('attribute': count: attrname: attrval);

            when name = 'Item';
              ElemItem('attribute': count: attrname: attrval);

            when name = 'LogEntry';
710cM         ElemLogEntry('attribute': count: attrname: attrval: skipElement);

730eA       when name = 'OnSiteLogEntry';
730eA         ElemOnSiteLog('attribute': count: attrname: attrval);

            when name = 'Picture';
              ElemPicture('attribute': count: attrname: attrval);

            when name = 'Route';
              ElemRoute('attribute': count: attrname: attrval);

            when name = 'Signature';
              ElemSignature('attribute': count: attrname: attrval);

            when name = 'Stop';
              ElemStop('attribute': count: attrname: attrval);

            when name = 'StopFlag';
              ElemStopFlag('attribute': count: attrname: attrval);

            when name = 'TRAXData';
              ElemTRAXData('attribute': count: attrname: attrval);

750aA       when name = 'docPrinted';
750aA         ElemInvoice('attribute': count: attrname: attrval);

          endsl;

710cM     if attrname = '*NoMoreAttributes' or skipElement;
            leave;
          endif;

        enddo;

        return;
      /end-free
     p                 e

     *----------------------------------------------------------------
     * ElemGS1Code  -  Process GS1Code Element
     *----------------------------------------------------------------

     p ElemGS1Code     b
     d ElemGS1Code     pi
     d  type                         10    const
     d  count                        10I 0 const
     d  name                        100    varying const
     d  value                     65535A   varying const

      /free

        // Initialize attribute data structure

720eM   if count = 3;
        endif;

        // Save attribute to data structure

        select;



        endsl;

        // Process attributes

        if name = '*NoMoreAttributes';
        endif;

        return;
      /end-free
     p                 e

750aA*----------------------------------------------------------------
750aA* ElemInvoice  -  Process Invoice (docPrinted) Element
750aA*----------------------------------------------------------------
750aA
     p ElemInvoice     b
     d ElemInvoice     pi
     d  type                         10    const
     d  count                        10I 0 const
     d  name                        100    varying const
     d  value                     65535A   varying const

     * Local Variables


      /free

        // Initialize attribute data structure

        if count = 3;
          clear invoice;
        endif;

        // Save attribute to data structure

        select;

          when type = 'attribute' and name = 'stopId';
            monitor;
              invoice.stopId = %dec(value:2:0);
            on-error;
              invoice.stopId = 0;
            endmon;

          when type = 'attribute' and name = 'docType';
            invoice.doctype = value;

          when type = 'attribute' and name = 'docDriver';
            monitor;
              invoice.docDriver = %dec(value:5:0);
            on-error;
              invoice.docDriver = 0;
            endmon;

          when type = 'attribute' and name = 'docPrintedTimeStamp';
            invoice.docPrintedTS = ValueToStamp(value);

          when type = 'attribute' and name = 'docNumber';
            invoice.docNumber = value;

          when type = 'attribute' and name = 'docOrderNumbers';
            invoice.docOrdNos = value;

          when type = 'attribute' and name = 'docInternalOrderNumbers';
            invoice.docIntOrdNos = value;

          when type = 'attribute' and name = 'docCurrency';
            invoice.docCurrency = value;

          when type = 'attribute' and name = 'docItemsQuantity';
            monitor;
              invoice.docItmsQty = %dec(value:7:0);
            on-error;
              invoice.docItmsQty = 0;
            endmon;

          when type = 'attribute' and name = 'docTotalBeforeTax';
            monitor;
              invoice.docTotB4Tx = %dec(value:9:2);
            on-error;
              invoice.docTotB4Tx = 0;
            endmon;

          when type = 'attribute' and name = 'docTotalTax';
            monitor;
              invoice.docTotTx = %dec(value:9:2);
            on-error;
              invoice.docTotTx = 0;
            endmon;

          when type = 'attribute' and name = 'docTotal';
            monitor;
              invoice.docTot = %dec(value:9:2);
            on-error;
              invoice.docTot = 0;
            endmon;

          when type = 'attribute' and name = 'docHasReturns';
            invoice.docHasReturns = value;

          when type = 'attribute' and name = 'docReturnsItemsQuantity';
            monitor;
              invoice.docItmsQtyRtn = %dec(value:7:0);
            on-error;
              invoice.docItmsQtyRtn = 0;
            endmon;

          when type = 'attribute' and name = 'docReturnsTotalBeforeTax';
            monitor;
              invoice.docTotB4TxRtn = %dec(value:9:2);
            on-error;
              invoice.docTotB4TxRtn = 0;
            endmon;

          when type = 'attribute' and name = 'docReturnsTotalTax';
            monitor;
              invoice.docTotTxRtn = %dec(value:9:2);
            on-error;
              invoice.docTotTxRtn = 0;
            endmon;

          when type = 'attribute' and name = 'docReturnsTotal';
            monitor;
              invoice.docTotRtn = %dec(value:9:2);
            on-error;
              invoice.docTotRtn = 0;
            endmon;

        endsl;

        // Process attributes

        if name = '*NoMoreAttributes';

          ttvwhs = parent.warehouse;
          ttvrti = parent.routeId;
          ttvstp = invoice.stopId;
          ttvtyp = invoice.docType;
          ttvemp = invoice.docDriver;
          ttvinv = invoice.docNumber;
          ttvcord = invoice.docOrdNos;
          ttvordid = invoice.docIntOrdNos;
          ttviqty = invoice.docItmsqty;
          ttvibtx = invoice.docTotB4Tx;
          ttvittx = invoice.docTotTx;
          ttvitot = invoice.docTot;
          ttvcur  = invoice.docCurrency;
          ttvprt = invoice.docPrintedTS;
          ttvrtn = invoice.docHasReturns;
          ttvrqty = invoice.docItmsQtyRtn;
          ttvrbtx = invoice.docTotB4TxRtn;
          ttvrttx = invoice.docTotTxRtn;
          ttvrtot = invoice.docTotRtn;

          getCurrStamp();
          ttvadd  = currStampLoc;

          // See if this is an invoice exception

          totalInv = 0;
          setll (ttvwhs: ttvrti: ttvinv) ttivch;

          dow forever = forever;

            reade (ttvwhs: ttvrti: ttvinv) ttivch;

            if %eof(ttivch);
              leave;
            endif;

            pos = 0;
            pos = %scan(tvhorda: ttvcord);
            if pos = 0;
              iter;
            endif;

            totalInv += tvhtotinv;

          enddo;

          if totalInv <> ttvitot;
            ttvexcp = 'Y';
          else;
            ttvexcp = 'N';
          endif;

          write(e) ttvrec;

        endif;

        return;
      /end-free
     p                 e

     *----------------------------------------------------------------
     * ElemItem     -  Process Item Element
     *----------------------------------------------------------------

     p ElemItem        b
     d ElemItem        pi
     d  type                         10    const
     d  count                        10I 0 const
     d  name                        100    varying const
     d  value                     65535A   varying const

740bA* Local Variables

740bAd dktStop         s              2  0
740bAd hostStop        s              5  0

      /free

        // Initialize attribute data structure

720eM   if count = 3;
          clear item;
        endif;

        // Save attribute to data structure

        select;

          when type = 'attribute' and name = 'stopNumber';
            monitor;
740eA         if value = '';
740eA           item.hostStop =0;
740eA         else;
720oA           item.hostStop = %dec(value:5:0);
740eA         endif;
            on-error;
              item.hostStop = 99999;
            endmon;
740bD     //item.stopId = item.hostStop;

740bD     //when type = 'attribute' and name = 'stopId';
740bD     //  monitor;
740bD     //    item.stopId = %dec(value:2:0);
740bD     //  on-error;
740bD     //    item.stopId = 99;
740bD     //  endmon;

740bA       // Get Dakota Stop number
740bA
740bA       hostStop = item.hostStop;
740bA       GetStop('*DKTSTP': pwhse: pRtid: 0: dktStop: hostStop);

740eA   // Fix should be reviewed by Retha.
740eA   if dktStop = 0;
740eA     if hostStop > 99;
740eA       dktstop = 0;
740eA     else;
740eA       dktStop = hostStop;
740eA     endif;
740eA   endif;

740bA        // Extra protection that valid dktStop is returned.
740bA
740bA        monitor;
740bA          item.stopId = dktStop;
740bA        on-error;
740bA          return;
740bA        endmon;

          when type = 'attribute' and name = 'itemNumber';
            item.item = value;

          when type = 'attribute' and name = 'scanID';
            item.scanId = value;
            monitor;
              item.uci = %dec(%subst(value:6:5):5:0);
            on-error;
              item.uci = 0;
            endmon;

          when type = 'attribute' and name = 'palletNumber';
            monitor;
              item.palletNumber = %dec(value:7:0);
            on-error;
              item.palletNumber = 0;
            endmon;

          when type = 'attribute' and name = 'toteNumber';
            monitor;
              item.toteNumber = %dec(value:7:0);
            on-error;
              item.toteNumber = 0;
            endmon;

          when type = 'attribute' and name = 'initialBreakDownFlag';
            item.initBrkFlag = value;

          when type = 'attribute' and name = 'initialUnitMeasure';
            item.initUOM = value;

          when type = 'attribute' and name = 'piecesUOM';
            item.piecesUOM = value;

          when type = 'attribute' and name = 'operationFlag';
            item.opFlag = value;

          when type = 'attribute' and name = 'scanTimeStamp';
            item.scanStamp = ValueToStamp(value);

          when type = 'attribute' and name = 'deliveredTimeStamp';
            item.delvStamp = ValueToStamp(value);

          when type = 'attribute' and name = 'deliveredPieces';
            monitor;
              item.delvPieces = %dec(value:5:0);
            on-error;
              item.delvPieces = 0;
            endmon;

          when type = 'attribute' and name = 'notes';
            item.notes = value;

          when type = 'attribute' and name = 'isAddedReturn';
            if value = '1';
              item.isAddedReturn = *on;
            else;
              item.isAddedReturn = *off;
            endif;

          when type = 'attribute' and name = 'returnedTimeStamp';
            item.returnStamp = ValueToStamp(value);

          when type = 'attribute' and name = 'returnedCode';
            item.returnCode = value;

          when type = 'attribute' and name = 'returnedBreakDownUM';
            item.returnUOM = value;

          when type = 'attribute' and name = 'returnedBreakDownQuantity';
            item.returnBrkDn = value;

          when type = 'attribute' and name = 'returnedPieces';
            monitor;
              item.returnPieces = %dec(value:5:0);
            on-error;
              item.returnPieces = 0;
            endmon;

          when type = 'attribute' and name = 'returnedCatchWeight';
            monitor;
              item.returnWeight = %dec(value:9:2);
            on-error;
              item.returnWeight = 0;
            endmon;

          when type = 'attribute' and name = 'returnedNotes';
            item.returnNotes = value;

        endsl;

        // Process attributes

        if name = '*NoMoreAttributes';

730eD     // Nothing to do if record is a special PALLET record
730eA     // Write a PALLETSCAN Trax pieces record before leaving
710bA
710bA     if item.initUOM = 'PALLET' and item.piecesUOM = 'PALLET';
740hA       ttxsrd = StampToDate(item.delvStamp);
740hA       if ttxsrd <> 20000101;

730eA     ttxwhs = parent.warehouse;
730eA     ttxrti = parent.routeId;
730eA     ttxrte = parent.route;
740fA     if item.hostStop > 99;
740fD       //ttxstp = item.stopId;
740fM       ttxstp = 0;
740fA     else;
740fA       ttxstp = item.hostStop;
740fA     endif;
730eA     ttxitm = 'PALLETSCAN';
730eA     ttxum  = *blanks;
730eA     ttxtrx = 0;
730eA     // 740iD  ttxopf = 'S';
740iM     ttxopf = item.opFlag;
730eA     ttxibf = *blanks;
730eA     ttxrbf = *blanks;
730eA     ttxsrd = StampToDate(item.delvStamp);
730eA     ttxsrt = StampToTime(item.delvStamp);
730eA     ttxbq  = 0;
730eA     ttxbqr = 0;
730eA     ttxqs1 = 0;
730eA     ttxqs2 = 0;
730eA     ttxqs3 = 0;
730eA     ttxqn1 = 0;
730eA     ttxqn2 = 0;
730eA     ttxqn3 = 0;
730eA     ttxqc1 = 0;
730eA     ttxqc2 = 0;
730eA     ttxqc3 = 0;
730eA     ttxqp1 = 0;
730eA     ttxqp2 = 0;
730eA     ttxqp3 = 0;

730eA       write(e) ttxrec;
740hA       endif;

710bA       return;
710bA     endif;

710bA     // For an added return, make sure item is uppercase
710bA
710bA     if item.isAddedReturn;
710bA       item.item = LowerToUpper(item.item);
710bA     endif;

          // Get corresponding ORDP record

          chain (parent.warehouse: parent.routeId: item.uci) ordp;
          if not %found(ordp);
            orplbl = 0;
            orpord = 0;
            orpsq# = 0;
          endif;

720fA     // Save label# and order# to return to webservice

720fA     stop.lastLbl# = orplbl;
720fA     stop.lastOrd = orpord;

          // Get corresponding LABEL record

          chain (orplbl) label;
          if not %found(label);
            lbucod = '--';
            lbutyp = 'N';
730dA       lblbl# = 0;
720fD     //else;
720fD     //  stop.lastLbl# = lblbl#;
720fD     //  stop.lastOrd = lbord;
          endif;

          // Determine UOM  type

          if item.piecesUOM = item.initUOM;
            item.piecesUOMType = lbutyp;
          else;
            GetItem(parent.warehouse: item.item);
            select;
              when item.piecesUOM = $itum1;
                item.piecesUOMType = 'N';
              when item.piecesUOM = $itum2;
                item.piecesUOMType = '1';
              when item.piecesUOM = $itum3;
                item.piecesUOMType = '2';
              other;
                item.piecesUOMType = '2';
            endsl;
          endif;

          // Protect against TTTRX record already existing
730eA      // ONLY IF TRAX# (item.uci) IS NOT ZERO.

730eA     if item.uci <> 0;
          chain (parent.warehouse: parent.routeId: item.uci) tttrx1;
          if not %found(tttrx1);
          endif;
730eA     endif;

          // Assume we should always be creating the record

          clear ttxrec;
          ttxwhs = parent.warehouse;
          ttxrti = parent.routeId;
          ttxrte = parent.route;
          ttxstp = item.stopId;
          ttxitm = item.item;
          ttxum  = item.piecesUOM;
          ttxtrx = item.uci;
          ttxopf = item.opFlag;
          ttxibf = lbutyp;
          ttxrbf = item.piecesUOMType;

          // Record delivered pieces (scanned vs not scanned)

720gD   //ttxsrd = StampToDate(item.scanStamp);
720gD   //ttxsrt = StampToTime(item.scanStamp);
720iA           select;
720iA             when item.delvStamp = nostamp;
720iA               ttxsrd = StampToDate(item.returnStamp);
720iA               ttxsrt = StampToTime(item.returnStamp);
720iA             other;
720hA               ttxsrd = StampToDate(item.delvStamp);
720hA               ttxsrt = StampToTime(item.delvStamp);
720iA           endsl;

          if item.delvPieces > 0;
            select;
              when item.opFlag = 'S';
720gD     //    ttxsrd = StampToDate(item.scanStamp);
720gD     //    ttxsrt = StampToTime(item.scanStamp);
                select;
                  when item.piecesUOMType = 'N';
                    ttxqs1 = item.delvPieces;
                  when item.piecesUOMType = '1';
                    ttxqs2 = item.delvPieces;
                  when item.piecesUOMType = '2';
                    ttxqs3 = item.delvPieces;
                endsl;
              other;
                select;
                  when item.piecesUOMType = 'N';
                    ttxqn1 = item.delvPieces;
                  when item.piecesUOMType = '1';
                    ttxqn2 = item.delvPieces;
                  when item.piecesUOMType = '2';
                    ttxqn3 = item.delvPieces;
                endsl;
            endsl;
          endif;

          // Record returned pieces (added/previous vs current)

          if item.returnPieces > 0;
            select;
              when item.isAddedReturn;
                select;
                  when item.piecesUOMType = 'N';
                    ttxqp1 = item.returnPieces;
                  when item.piecesUOMType = '1';
                    ttxqp2 = item.returnPieces;
                  when item.piecesUOMType = '2';
                    ttxqp3 = item.returnPieces;
                endsl;
              other;
                select;
                  when item.piecesUOMType = 'N';
                    ttxqc1 = item.returnPieces;
                  when item.piecesUOMType = '1';
                    ttxqc2 = item.returnPieces;
                  when item.piecesUOMType = '2';
                    ttxqc3 = item.returnPieces;
                endsl;
            endsl;
          endif;

          // Create/Update TTTRX record

          if %found(tttrx1);
            update(e) ttxrec;
          else;
            write(e) ttxrec;
          endif;

          // Extra Return logic

          if item.returnPieces > 0;

            ttwhse = parent.warehouse;
            ttrtid = parent.routeId;
            ttrout = parent.route;
            ttusr  = parent.user;
            ttstop = item.stopId;
            ttord  = orpord;
            ttitem = item.item;

            //ttbflg = 'returnedBreakDownQuantity??????????????????????????';
720qA       // 740gD  if item.initUOM = item.piecesUOM;
720qA       // 740gD    ttbflg = '0';
720qA       // 740gD  else;
720qA       // 740gD    ttbflg = item.piecesUOMType;
720qA       // 740gD  endif;

740gA       if item.piecesUOMType = 'N';
740gA         ttbflg = '0';
740gA       else;
740gA         ttbflg = item.piecesUOMType;
740gA       endif;

            ttoqty = item.returnPieces;
            ttuom  = item.piecesUOM;
            ttpqty = 0;
            ttcwgt = item.returnWeight;
            ttolbl = lblbl#;
            ttuci  = item.uci;
            ttrcod = item.returnCode;
            ttmemo = item.returnNotes;
            ttudte = StampToDate(%timestamp());
            ttutim = StampToTime(%timestamp());
            ttstat = '1';
            ttstsd = StampToDate(%timestamp());
            ttstst = StampToTime(%timestamp());
            ttcnam = '';

750bA       // For readability deleted this chunk of code, followed by new code.
740hD  //750bD //chain (pWhse: pRtId) ttrtn3;
740jA  //750bD   chain (TTWhse: TTStat: TTrout: TTrtid: TTolbl: TTitem:
740jA  //750bD   TTUCI) ttrtn;
740hD  //750bD //if not %found(ttrtn3);
740JA  //750bD   if not %found(ttrtn);
       //750bD   write(e) ttrec;
740hA  //750bD else;
740hA  //750bD   if ttpqty = 0;
740hA  //750bD     update(e) ttrec;
740hA  //750bD   endif;
740hA  //750bD endif;

750bA       // tr842d has now run and deleted returns for this route
750bA       // for which no qty was processed, so if you find a hit now
750bA       // for any status it means qty has already been processed and
750bA       // we will bypass this return
750bA       foundReturn = *off;
750bA       // look for status 1
750bA       chain (TTWhse: TTStat: TTrout: TTrtid: TTolbl: TTitem:
750bA       ttuci) ttrtn;
750bA       if %found(ttrtn);
750bA         foundReturn = *on;
750bA       else;
750bA         // look for status 5
750bA         chain (TTWhse: stat5: TTrout: TTrtid: TTolbl: TTitem:
750bA         ttuci) ttrtn;
750bA         if %found(ttrtn);
750bA           foundReturn = *on;
750bA         else;
750bA           // look for status 9
750bA           chain (TTWhse: stat9: TTrout: TTrtid: TTolbl: TTitem:
750bA           ttuci) ttrtn;
750bA           if %found(ttrtn);
750bA             foundReturn = *on;
750bA           endif;
750bA         endif;
750bA       endif;
750bA       if foundReturn = *off;
750bA         write(e) ttrec;
750bA       endif;

          endif;

720cA     // Update total pieces delivered/returned for text/email message
720cA
720cA     stop.delvPieces += item.delvPieces;
720cA     if item.isAddedReturn;
720cA       stop.addRtnPieces += item.returnPieces;
720cA     else;
720cA       stop.returnPieces += item.returnPieces;
720cA     endif;

        endif;

        return;
      /end-free
     p                 e

     *----------------------------------------------------------------
     * ElemLogEntry -  Process LogEntry Element
     *----------------------------------------------------------------

     p ElemLogEntry    b
     d ElemLogEntry    pi
     d  type                         10    const
     d  count                        10I 0 const
     d  name                        100    varying const
     d  value                     65535A   varying const
710cAd  skipElement                    n

     * Local Variables

     d pos             s              5  0
     d periodPos       s              5  0
     d hashPos         s              5  0
720eDd*skipRecord      s               n

      /free

        // Initialize attribute data structure

720eM   if count = 3;
          clear logEntry;
720eM     logEntry.skipRecord = *off;
        endif;

        // Save attribute to data structure

        select;

          when type = 'attribute' and name = 'logTimeStamp';
            logEntry.stamp = %char(ValueToStamp(value));

          when type = 'attribute' and name = 'logLevel';

          when type = 'attribute' and name = 'logMessageLevel';
            if value <> 'ERROR';
              skipElement = *on;
720eM         logEntry.skipRecord = *on;
            endif;

          when type = 'attribute' and name = 'logMessageText';
            gfString = value;
            gfDelimiter = '|';
            gfStartFld = 1;
            GetFlds(gfString: gfDelimiter: gfStartFld:
                    gfRtnCode: gfFldsReturned:
                    gfFld1: gfFld2: gfFld3: gfFld4: gfFld5:
                    gfFld6: gfFld7: gfFld8: gfFld9: gfFld10:
                    gfFld11: gfFld12: gfFld13: gfFld14: gfFld15:
                    gfFld16: gfFld17: gfFld18: gfFld19: gfFld20);

            if gfRtnCode <> '*OKMORE' and gfRtnCode <> '*OKEND';
              skipElement = *on;
720eM         logEntry.skipRecord = *on;
            endif;

            logEntry.driver = gfFld1;
            logEntry.stopId = gfFld3;
740eA       if %len(gfFld4) = 10;
              logEntry.scan = gfFld4;
              logEntry.message = gfFld5;
740eA       else;
740eA         logEntry.scan = gfFld5;
740eA         logEntry.message = gfFld6;
740eA       endif;

          when type = 'attribute' and name = 'logTag';

        endsl;

        // Process attributes

        if name = '*NoMoreAttributes';

          // See if we are skipping the record (e.g., record wasn't ERROR)

720eM     if logEntry.skipRecord;
            return;
          endif;

          // Only write exceptions for invalid Trax # scans.
          // Message ends with "This piece belongs to Stop #2."

          pos = %scan('belongs to Stop': logEntry.message);

          if pos = 0;
            return;
          endif;

          // Get intended Stop for scanned Trax#

          hashPos = %scan('#': logEntry.message: 1);
          if hashPos > 0;
            periodPos = %scan('.': logEntry.message: hashPos);
            if periodPos > 0;
              monitor;
                logEntry.intendedStop = %dec(value:2:0);
              on-error;
                logEntry.intendedStop = 0;
              endmon;
            endif;
          endif;

          // Get Item/Stop for scanned Trax #
          // Protect against positions 6 - 10 being non-numeric,
          // otherwise GUI report will blow up.
          // Based on TR846

          logEntry.uci = 0;

          if %len(logEntry.scan) < 10;
              %len(logEntry.Scan) = 10;
          endif;

          monitor;
            logEntry.uci = %dec(%subst(logEntry.scan:6:5):5:0);
            chain (parent.warehouse: parent.routeId: logEntry.uci) ordp;
            if %found(ordp);
              chain (orplbl) label;
              if %found(label);
                logEntry.item = lbitem;
                logEntry.intendedStop = lbstop;
                logEntry.transaction = lbtrn#;
              endif;
            endif;
          on-error;
            logEntry.uci = 0;
            %len(logEntry.Scan) = 100;
            %subst(logEntry.scan:96:5) = %subst(logEntry.scan:6:5);
            %subst(logEntry.scan:6:5) = '00000';
          endmon;

          // Write exception record
720dA     // Excpetion type 'S' is when a Trax# is scanned at wrong Stop.
720dA     // Exception type 'I' is used for a situation like a GS1 was
720dA     // scanned instead of a Trax #.

          clear tterec;
720dD     //tteopf = 'I';
750cD     //tteopf = 'S';
750dD     //tteopf = item.opFlag;
750dA     chain (parent.warehouse: parent.routeId: logEntry.uci) tttrx1;
750dA     if %found(tttrx1);
750dA       tteopf = ttxopf;
750dA     else;
750dA       tteopf = ' ';
750dA     endif;
          ttewhs = %char(parent.warehouse);
          tterid = parent.routeId;
          ttets = logEntry.stamp;
          ttedrv = logEntry.driver;
          ttesti = logEntry.intendedStop;
          tteitm = logEntry.item;
          ttestp = logEntry.stopId;
          ttetrn = logEntry.transaction;
          ttescn = logEntry.scan;

          write(e) tterec;

        endif;

        return;
      /end-free
     p                 e

730eA*----------------------------------------------------------------
730eA* ElemOnSiteLog   -  Process On Site Delivery Log Entry
730eA*----------------------------------------------------------------

     p ElemOnSiteLog   b
     d ElemOnSiteLog   pi
     d  type                         10    const
     d  count                        10I 0 const
     d  name                        100    varying const
     d  value                     65535A   varying const

740bA* Local Variables

740bAd dktStop         s              2  0
740bAd hostStop        s              5  0

      /free

        // Initialize attribute data structure

        if count = 3;
          clear onSiteLogEntry;
        endif;

        // Save attribute to data structure

        select;

          when type = 'attribute' and name = 'stopNumber';
            monitor;
740eA         if value = '';
740eA           onSiteLogEntry.hostStop = 0;
740eA         else;
740bD         //onSiteLogEntry.stopId = %dec(value:5:0);
740bM           onSiteLogEntry.hostStop = %dec(value:5:0);
740eA         endif;
            on-error;
740bD         //onSiteLogEntry.stopId = 99;
740bM         onSiteLogEntry.hostStop = 99999;
            endmon;

740bA       // Get Dakota Stop number
740bA
740bA       hostStop = onSiteLogEntry.hostStop;
740bA       GetStop('*DKTSTP': pwhse: pRtid: 0: dktStop: hostStop);

740eA   // Fix should be reviewed by Retha.
740eA   if dktStop = 0;
740eA     if hostStop > 99;
740eA       dktstop=0;
740eA     else;
740eA       dktStop = hostStop;
740eA     endif;
740eA   endif;

740bA        // Extra protection that valid dktStop is returned.
740bA
740bA        monitor;
740bA          onSiteLogEntry.stopId = dktStop;
740bA        on-error;
740bA          return;
740bA        endmon;

          when type = 'attribute' and name = 'actionFlag';
            if value = 'O';
              onSiteLogEntry.opFlag = 'C';
            else;
              onSiteLogEntry.opFlag = 'S';
            endif;

          when type = 'attribute' and name = 'errorMsg';
            if value = *blanks;
740cD     //  onSiteLogEntry.item = 'ONSITESCAN';
740cM         onSiteLogEntry.item = 'INSTORESCAN';
            else;
740cD     //  onSiteLogEntry.item = 'ONSITESCANERROR';
740cM         onSiteLogEntry.item = 'INSTORESCANERR';
            endif;

          when type = 'attribute' and name = 'actionTimeStamp';
            onSiteLogEntry.scanStamp = ValueToStamp(value);

        endsl;

        // Process attributes

        if name = '*NoMoreAttributes';

          clear ttxrec;
          ttxwhs = parent.warehouse;
          ttxrti = parent.routeId;
          ttxrte = parent.route;
          ttxstp = onSiteLogEntry.stopId;
          ttxitm = onSiteLogEntry.item;
          ttxum  = *blanks;
          ttxtrx = 0;
          ttxopf = onSiteLogEntry.opFlag;
          ttxibf = *blanks;
          ttxrbf = *blanks;
          ttxsrd = StampToDate(onSiteLogEntry.scanStamp);
          ttxsrt = StampToTime(onSiteLogEntry.scanStamp);
          ttxbq  = 0;
          ttxbqr = 0;
          ttxqs1 = 0;
          ttxqs2 = 0;
          ttxqs3 = 0;
          ttxqn1 = 0;
          ttxqn2 = 0;
          ttxqn3 = 0;
          ttxqc1 = 0;
          ttxqc2 = 0;
          ttxqc3 = 0;
          ttxqp1 = 0;
          ttxqp2 = 0;
          ttxqp3 = 0;

            write(e) ttxrec;

        endif;

        return;
      /end-free
     p                 e

     *----------------------------------------------------------------
     * ElemPicture  -  Process Picture Element
     *----------------------------------------------------------------

     p ElemPicture     b
     d ElemPicture     pi
     d  type                         10    const
     d  count                        10I 0 const
     d  name                        100    varying const
     d  value                     65535A   varying const
720oA* Local Variables

720oAd pos             s              2  0
720oAd endpos          s              2  0
720oAd worktype        s             10
740bAd dktStop         s              2  0
740bAd hostStop        s              5  0

      /free

        // Initialize attribute data structure

720eM   if count = 3;
        endif;

        // Save attribute to data structure

        select;

          when type = 'attribute' and name = 'stopNumber';
            monitor;
740eA         if value='';
740eA           picture.hostStop = 0;
740eA         else;
                picture.hostStop = %dec(value:5:0);
740eA         endif;
            on-error;
              picture.hostStop = 99999;
            endmon;
740bD       //picture.stopId = picture.hostStop;

740bA       // Get Dakota Stop number
740bA
740bA       hostStop = picture.hostStop;
740bA       GetStop('*DKTSTP': pwhse: pRtid: 0: dktStop: hostStop);

740eA   // Fix should be reviewed by Retha.
740eA   if dktStop = 0;
740eA     if hostStop > 99;
740eA       dktStop = 0;
740eA     else;
740eA       dktStop = hostStop;
740eA     endif;
740eA   endif;

740bA        // Extra protection that valid dktStop is returned.
740bA
740bA        monitor;
740bA          picture.stopId = dktStop;
740bA        on-error;
740bA          return;
740bA        endmon;

740bD     //when type = 'attribute' and name = 'stopId';
740bD     //  monitor;
740bD     //    picture.stopId = %dec(value:2:0);
740bD     //  on-error;
740bD     //    picture.stopId = 99;
740bD     //  endmon;

720bA     when type = 'attribute' and name = 'itemNumber';
720bA       picture.item = value;

720bA     when type = 'attribute' and name = 'scanID';
720bA       picture.scanId = value;
720bA       monitor;
720bA         picture.uci = %dec(%subst(value:6:5):5:0);
720bA       on-error;
720bA         picture.uci = 0;
720bA       endmon;

          when type = 'attribute' and name = 'pictureTimeStamp';
            picture.stamp = ValueToStamp(value);

          when type = 'attribute' and name = 'fileName';
            picture.fileName = value;


        endsl;

        // Process attributes

        if name = '*NoMoreAttributes';

720bA     //if picture.stopId = 0;                 **740bD**
720bA     //  picture.stopId = picture.hostStop;   **740bD**
720bA     //endif;                                 **740bD**

720bA     clear ttpcrec;
720bA
720bA     select;
720bA       when elementPath = '/TRAXData/StopsNotesPictures/';
720bA         ttpctype = 'STOP';
720bA       when elementPath = '/TRAXData/ItemsReturnedPictures/';
720bA         ttpctype = 'RETURNS';
              ttpcitm = picture.item;
              ttpctrx = picture.uci;
720oA       when elementPath = '/TRAXData/QuestionsPictures/';
720oA         // extract the type from the filename
720oA         pos = %scan('.':picture.fileName);
720oA         if pos > 0;
720oA           endpos = (pos - 11);
720oA           worktype = %subst(picture.fileName:11:endpos);
720oA         ttpctype = worktype;
720oA         endif;
720bA     endsl;
720bA
720bA     ttpcwhs = parent.warehouse;
720bA     ttpcrtid = parent.routeId;
720bA     ttpcrte = parent.route;
720bA     ttpcstp = picture.stopId;
720bA     ttpcfnam = picture.fileName;
720bA     ttpcfts = picture.stamp;
720bA     write(e) ttpcrec;

        endif;

        // Process element value

        if type = 'value';
        endif;

        return;
      /end-free
     p                 e

     *----------------------------------------------------------------
     * ElemRoute    -  Process Route Element
     *----------------------------------------------------------------

     p ElemRoute       b
     d ElemRoute       pi
     d  type                         10    const
     d  count                        10I 0 const
     d  name                        100    varying const
     d  value                     65535A   varying const

     * Local Variables

     d ttrteExists     s               n

      /free

        // Initialize attribute data structure

720eM   if count = 3;
          // parent structure already cleared ElemTRAXData
        endif;

        // Save attribute to data structure

        select;

          when type = 'attribute' and name = 'parentRouteID';
            // Already captured from TRAXData

          when type = 'attribute' and name = 'warehouseCode';
            // Already captured from TRAXData

          when type = 'attribute' and name = 'driverID';
            // Already captured from TRAXData

          when type = 'attribute' and name = 'downloadRouteTimeStamp';
            parent.DownloadStamp = ValueToStamp(value);

          when type = 'attribute' and name = 'uploadRouteTimeStamp';
            parent.UploadStamp = ValueToStamp(value);

          when type = 'attribute' and name = 'beginRouteTimeStamp';
            parent.beginStamp = ValueToStamp(value);

          when type = 'attribute' and name = 'endRouteTimeStamp';
            parent.endStamp = ValueToStamp(value);

          when type = 'attribute' and name = 'isRouteReturned';
            parent.IsRouteReturn = value;

          when type = 'attribute' and name = 'routeReturnedTimeStamp';
            parent.ReturnStamp = ValueToStamp(value);

          when type = 'attribute' and name = 'routeReturnedNotes';
            parent.ReturnNotes = value;


        endsl;

        // Process attributes

        if name = '*NoMoreAttributes';

          chain (parent.Warehouse: parent.RouteId) ttrte;
          if not %found(ttrte);
            clear ttrrec;
750fA       printRpt = *on;
750fA     else;
750fA       if ttrfid = 0;
750fA         printRpt = *on;
750fA       endif;
          endif;

          ttrrte = parent.route;
          ttrtru = parent.truck;
          ttrusr = parent.user;
          ttrser = parent.deviceId;
720tA     if ttrsrd = 0;
720tM       ttrsrd = StampToDate(parent.beginStamp);
720tM       ttrsrt = StampToTime(parent.beginStamp);
720tA     endif;
          //ttrsrd = StampToDate(parent.beginStamp);
          //ttrsrt = StampToTime(parent.beginStamp);
750fA     // only update finish date and time when completed route
750fA     if pCommand = 'postCompletedRoute';
            ttrfid = StampToDate(parent.endStamp);
            ttrfit = StampToTime(parent.endStamp);
750fA     endif;
          ttrstd = StampToDate(%timestamp());
          ttrscn = '';
          ttrs   = 0;
          ttrsd  = 0;
          ttrqs1 = 0;
          ttrqs2 = 0;
          ttrqs3 = 0;
          ttrqn1 = 0;
          ttrqn2 = 0;
          ttrqn3 = 0;
          ttrqc1 = 0;
          ttrqc2 = 0;
          ttrqc3 = 0;
          ttrqp1 = 0;
          ttrqp2 = 0;
          ttrqp3 = 0;
          //ttrsrd = 0;
          //ttrsrt = 0;
720dD     //ttrfid = 0;
720dD     //ttrfit = 0;
730cD     //ttrser = ' ';

          if %found(ttrte);
            update(e) ttrrec;
          else;
            ttrwhs = parent.warehouse;
            ttrrti = parent.routeId;
            write(e) ttrrec;
          endif;

        endif;

        return;
      /end-free
     p                 e

     *----------------------------------------------------------------
     * ElemSignature  -  Process Signature Element
     *----------------------------------------------------------------

     p ElemSignature   b
     d ElemSignature   pi
     d  type                         10    const
     d  count                        10I 0 const
     d  name                        100    varying const
     d  value                     65535A   varying const

     * Local Variables

720jAd ifsCmd          s             10
720jAd ifsFromPath     s            256    varying
720jAd ifsFromFile     s            128    varying
720jAd ifsToPath       s            256    varying
720jAd ifsToFile       s            128    varying
720jAd ifsRtn          s             10
720jAd ifsMessage      s             60
740bAd dktStop         s              2  0
740bAd hostStop        s              5  0

      /free

        // Initialize attribute data structure

720eM   if count = 3;
          clear signature;
        endif;

        // Save attribute to data structure

        select;

          when type = 'attribute' and name = 'stopNumber';
            monitor;
740eA         if value='';
740eA           signature.hostStop = 0;
740eA         else;
                signature.hostStop = %dec(value:5:0);
740eA         endif;
            on-error;
              signature.hostStop = 99999;
            endmon;
740bD       //signature.stopId = signature.hostStop;

740bA       // Get Dakota Stop number
740bA
740bA       hostStop = signature.hostStop;
740bA       GetStop('*DKTSTP': pwhse: pRtid: 0: dktStop: hostStop);

740eA   // Fix should be reviewed by Retha.
740eA   if dktStop = 0;
740eA     if hostStop > 99;
740eA       dktStop=0;
740eA     else;
740eA       dktStop = hostStop;
740eA     endif;
740eA   endif;

740bA        // Extra protection that valid dktStop is returned.
740bA
740bA        monitor;
740bA          signature.stopId = dktStop;
740bA        on-error;
740bA          return;
740bA        endmon;

740bD     //when type = 'attribute' and name = 'stopId';
740bD     //  monitor;
740bD     //    signature.stopId = %dec(value:2:0);
740bD     //  on-error;
740bD     //    signature.stopId = 99;
740bD     //  endmon;

          when type = 'attribute' and name = 'signatureTimeStamp';
            signature.stamp = ValueToStamp(value);

          when type = 'attribute' and name = 'fileName';
            signature.fileName = value;

          when type = 'attribute' and name = 'signeeNotFound';
            signature.notFound = value;

          when type = 'attribute' and name = 'signeeName';
            signature.name = value;

        endsl;

        // Process attributes

        if name = '*NoMoreAttributes';

          chain (parent.warehouse: parent.routeId: signature.stopId) ttstp;

          if not %found(ttstp);
            clear ttprec;
            ttpwhs = parent.warehouse;
            ttprti = parent.routeId;
720bA       ttprte = parent.route;
            ttpstp = signature.stopId;
          endif;

          ttpgna = signature.name;
          ttpgfn = signature.fileName;
          ttpgsn = signature.notFound;
          ttpgdt = StampToDate(signature.stamp);
          ttpgtm = StampToTime(signature.stamp);

          if %found(ttstp);
            update(e) ttprec;
          else;
            write(e) ttprec;
          endif;

720bA     clear ttpcrec;
720bA     ttpctype = 'SIG';
720bA     ttpcwhs = parent.warehouse;
720bA     ttpcrtid = parent.routeId;
720bA     ttpcrte = parent.route;
720bA     ttpcstp = signature.stopId;
720bA     ttpcfnam = signature.fileName;
720bA     ttpcfts = signature.stamp;
720bA     write(e) ttpcrec;

720jA     // See if we should copy signature for order(s)
720jA
720nA     if optosig = 'Y' and ttpcfnam <> '';
720jA
720jA       ifsFromPath = %trim(pPath) + 'Pictures/JPG/';
720nA       ifsFromFile = %trim(ttpcfnam);
720jA       ifsToPath = ifsFromPath + 'ByOrder';
720jA
720jA       setll (ttpwhs: ttprti) ordh3;
720jA       dow forever = forever;
720jA         reade (ttpwhs: ttprti) ordh3;
720jA         if %eof(ordh3);
720jA           leave;
720jA         endif;
720nA
720nA         if ohstop <> signature.stopId;
720nA           iter;
720nA         endif;
720jA
730aD         //ifsToFile = 'o' + %char(ohcord) + ifsFromFile;
730aM         ifsToFile = 'o' + %char(ohcord)
730bM                   + 'n' + RmvInvldChar(%trim(signature.name)) + '_'
730aM                   + ifsFromFile;
720jA
720jA         CopyIFS('COPY': ifsFromPath: ifsFromFile: ifsToPath: ifsToFile:
720jA                 ifsRtn:ifsMessage);
720jA         if ifsRtn <> '*OK';
720jA           ifsMessage = ifsMessage;
720jA         endif;
720jA       enddo;
720jA     endif;
720jA
720jA   endif;

        // Process element value

        if type = 'value';
        endif;

        return;
      /end-free
     p                 e

     *----------------------------------------------------------------
     * ElemStop  -  Process Stop Element
     *----------------------------------------------------------------

     p ElemStop        b
     d ElemStop        pi
     d  type                         10    const
     d  count                        10I 0 const
     d  name                        100    varying const
     d  value                     65535A   varying const

     * Local Variables

     d $prtn           s              8
     d $perm           s             60
740bAd dktStop         s              2  0
740bAd hostStop        s              5  0

      /free

        // Initialize attribute data structure

720eM   if count = 3;
          clear stop;
        endif;

        // Save attribute to data structure

        select;

          when type = 'attribute' and name = 'parentRouteID';
            stop.routeId = value;

          when type = 'attribute' and name = 'stopNumber';
            monitor;
740eA         if value='';
740eA           stop.hostStop = 0;
740eA         else;
                stop.hostStop = %dec(value:5:0);
740eA         endif;
            on-error;
              stop.hostStop = 99999;
            endmon;
740bD       //stop.stopId = stop.hostStop;

740bA       // Get Dakota Stop number
740bA
740bA       hostStop = stop.hostStop;
740bA       GetStop('*DKTSTP': pwhse: pRtid: 0: dktStop: hostStop);

740eA   // Fix should be reviewed by Retha.
740eA   if dktStop = 0;
740eA     if hostStop > 99;
740eA       dktStop =0;
740eA     else;
740eA       dktStop = hostStop;
740eA     endif;
740eA   endif;

740bA        // Extra protection that valid dktStop is returned.
740bA
740bA        monitor;
740bA          stop.stopId = dktStop;
740bA        on-error;
740bA          return;
740bA        endmon;

740bD     //when type = 'attribute' and name = 'stopId';
740bD     //  monitor;
740bD     //    stop.stopId = %dec(value:2:0);
740bD     //  on-error;
740bD     //    stop.stopId = 99;
740bD     //  endmon;

          when type = 'attribute' and name = 'beginStopTravelTimeStamp';
            stop.beginTvlStamp = ValueToStamp(value);

          when type = 'attribute' and name = 'endStopTravelTimeStamp';
            stop.endTvlStamp = ValueToStamp(value);

          when type = 'attribute' and name = 'beginStopUnloadTimeStamp';
            stop.beginUnlStamp = ValueToStamp(value);

          when type = 'attribute' and name = 'endStopUnloadTimeStamp';
            stop.endUnlStamp = ValueToStamp(value);

          when type = 'attribute' and name = 'beginStopTimeStamp';
            stop.beginStamp = ValueToStamp(value);

          when type = 'attribute' and name = 'completedStopTimeStamp';
            stop.endStamp = ValueToStamp(value);

          when type = 'attribute' and name = 'isStopReturned';
            stop.isReturn = value;

          when type = 'attribute' and name = 'stopReturnedTimeStamp';
            stop.returnStamp = ValueToStamp(value);

          when type = 'attribute' and name = 'stopReturnedNotes';
            stop.returnNotes = value;

          when type = 'attribute' and name = 'isStopReset';
            stop.isReset = value;

          when type = 'attribute' and name = 'stopResetTimeStamp';
            stop.resetStamp = ValueToStamp(value);

          when type = 'attribute' and name = 'receiptPrintedTimeStamp';
            stop.printedStamp = ValueToStamp(value);

          when type = 'attribute' and name = 'notes';
            stop.notes = value;

        endsl;

        // Process attributes

        if name = '*NoMoreAttributes';

          // Make sure route id's match

          if stop.routeId <> parent.routeID;
            return;
          endif;

740bD     //if stop.stopId = 0;
740bD     //  stop.stopId = stop.hostStop;
740bD     //endif;

          // Clear TT files information when posting only 1 Stop

          if pCommand = 'postCompletedStop';
720aD       //TR844 (parent.warehouse: parent.routeId: $prtn: $perm:
720aM       TR842D (parent.warehouse: parent.routeId: $prtn: $perm:
                    pVersion: pCommand: stop.stopId);
          endif;

          // Update/Create TTSTP record

          chain (parent.warehouse: parent.routeId: stop.stopId) ttstp;
          if not %found(ttstp);
            clear ttprec;
          endif;

          ttprte = parent.route;
          ttpmem = stop.notes;
          ttpsrd = StampToDate(stop.beginStamp);
          ttpsrt = StampToTime(stop.beginStamp);
          ttpfid = StampToDate(stop.endStamp);
          ttpfit = StampToTime(stop.endStamp);

          if %found(ttstp);
            update(e) ttprec;
          else;
            ttpwhs = parent.warehouse;
            ttprti = parent.routeId;
            ttpstp = stop.stopId;
            write(e) ttprec;
          endif;

        endif;

        return;
      /end-free
     p                 e

     *----------------------------------------------------------------
     * ElemStopFlag  -  Process StopFlag Element
     *----------------------------------------------------------------

     p ElemStopFlag    b
     d ElemStopFlag    pi
     d  type                         10    const
     d  count                        10I 0 const
     d  name                        100    varying const
     d  value                     65535A   varying const

740bA* Local Variables

740bAd dktStop         s              2  0
740bAd hostStop        s              5  0

      /free

        // Initialize attribute data structure


720eM   if count = 3;
          clear stopFlag;
        endif;

        // Save attributes to data structure

        select;

          when type = 'attribute' and name = 'parentRouteID';
            stopFlag.routeId = value;

          when type = 'attribute' and name = 'stopNumber';
            monitor;
740eA         if value='';
740eA           stopFlag.hostStop = 0;
740eA         else;
740bA           stopFlag.hostStop = %dec(value:5:0);
740eA         endif;
            on-error;
              stopFlag.hostStop = 99999;
            endmon;
740bD       //stopFlag.stopId = stopFlag.hostStop;

740bA       // Get Dakota Stop number
740bA
740bA       hostStop = stopFlag.hostStop;
740bA       GetStop('*DKTSTP': pwhse: pRtid: 0: dktStop: hostStop);

740eA   // Fix should be reviewed by Retha.
740eA   if dktStop = 0;
740eA     if hostStop > 99;
740eA       dktstop=0;
740eA     else;
740eA       dktStop = hostStop;
740eA     endif;
740eA   endif;

740bA        // Extra protection that valid dktStop is returned.
740bA
740bA        monitor;
740bA          stopFlag.stopId = dktStop;
740bA        on-error;
740bA          return;
740bA        endmon;

740bD     //when type = 'attribute' and name = 'stopId';
740bD     //  monitor;
740bD     //    stopFlag.stopId = %dec(value:2:0);
740bD     //  on-error;
740bD     //    stopFlag.stopId = 99;
740bD     //  endmon;

          when type = 'attribute' and name = 'stopFlagChar';
            stopFlag.character = value;

          when type = 'attribute' and name = 'stopFlagResponse';
            stopFlag.response = value;

          when type = 'attribute' and name = 'stopFlagTimeStamp';
            stopFlag.stamp = ValueToStamp(value);


        endsl;

        // Process attributes

        if name = '*NoMoreAttributes';


          if stopFlag.routeId <> parent.routeID;
            return;
          endif;

740bD     //if stopFlag.stopId = 0;
740bD     //  stopFlag.stopId = stopFlag.hostStop;
740bD     //endif;

          // Update/Create TTSTPFR record

          chain (parent.warehouse: parent.routeId: stopFlag.stopId:
                 stopFlag.order: stopFlag.character) ttstpfr;
          if not %found(ttstpfr);
            clear ttfrrc;
          endif;

          ttfrre = stopFlag.response;
          ttfrd = StampToDate(stopFlag.stamp);
          ttfrt = StampToTime(stopFlag.stamp);

          if %found(ttstpfr);
            update(e) ttfrrc;
          else;
            ttfrwh = parent.warehouse;
            ttfrri = parent.routeId;
            ttfrrt = parent.route;
            ttfrst = stopFlag.stopId;
            ttfror = stopFlag.order;
            ttfrch = stopFlag.character;
            write(e) ttfrrc;
          endif;



        endif;

        return;
      /end-free
     p                 e

     *----------------------------------------------------------------
     * ElemTRAXData  -  Process TRAXData Element
     *----------------------------------------------------------------

     p ElemTRAXData    b
     d ElemTRAXData    pi
     d  type                         10    const
     d  count                        10I 0 const
     d  name                        100    varying const
     d  value                     65535A   varying const

     * Local Variables

     d $prtn           s              8
     d $perm           s             60
     d zeroStop        s              2  0

      /free

        // Initialize attribute data structure

720eM   if count = 3;
          clear parent;
        endif;

        // Save attributes to data structure

        select;

          when type = 'attribute' and name = 'parentRouteID';
            parent.routeId = value;

          when type = 'attribute' and name = 'warehouseCode';
            monitor;
              parent.warehouse = %dec(value:3:0);
            on-error;
              parent.warehouse = 0;
            endmon;

          when type = 'attribute' and name = 'driverID';
            monitor;
              parent.driverId = %dec(value:5:0);
            on-error;
              parent.driverId = 99999;
            endmon;
            chain (parent.driverId) piruser1;
            if %found();
              parent.user = uscode;
            else;
              parent.user = %char(parent.driverId);
            endif;

          when type = 'attribute' and name = 'deviceID';
            parent.deviceId = value;

          when type = 'attribute' and name = 'fileCreationTimeStamp';

        endsl;

        // Process attributes

720rA    if debug;
720rA      bdtype='ElemTRA..1';
720rA      wrtDebug(name);
720rA    endif;

        if name = '*NoMoreAttributes';

          // Clear TT files information when posting completed route

720rA    if debug;
720rA      bdtype='ElemTRA..2';
720rA      wrtDebug(name);
720rA    endif;

          if pCommand = 'postCompletedRoute';
720aD       //TR844 (parent.warehouse: parent.routeId: $prtn: $perm:
720aM       TR842D (parent.warehouse: parent.routeId: $prtn: $perm:
                    pVersion: pCommand: zeroStop);
          endif;

          // Get Host route and truck

          chain (parent.warehouse: parent.routeId) rtehed;
          if %found(rtehed);
            parent.route = rhrte;
            parent.truck = rhtruk;
          endif;

          // Get options

          GetOptions();

        endif;

        return;
      /end-free
     p                 e

     *----------------------------------------------------------------
     *  GetCurrStamp   Get current timestamps
     *----------------------------------------------------------------

     p GetCurrStamp    b
     d GetCurrStamp    pi

      /free

       getmicrotime(currstampuc:currstampsys);
       currstamploc = currstampsys + %hours(bfcoffset);

      /end-free

     p GetCurrStamp    e

     *----------------------------------------------------------------
     *  GetItem  Get item info.
     *----------------------------------------------------------------

     p GetItem         b
     d GetItem         pi
     d  whse                          3  0 const
     d  item                         15    const

      /free

       savever# = $itver#;
       clear $item;
       clear $item2;
       $itver# = savever#;

       $itwhse   = whse;
       $ititem   = item;

       $dricommand = '*ITEM';
       $drisubcmd  = '%GETMAIN';
       $drisys2upd = 'D';

       ZZDricop();

       if error = *on;
         $itcwgt = 'N';
         $itdesc = *blanks;
         $itupc  = *blanks;
         $itum2  = *blanks;
         $itumq2 = 0;
         $itum3  = *blanks;
         $itumq3 = 0;
         $itdesg = *blanks;
       endif;

      /end-free

     p GetItem         e


     *----------------------------------------------------------------
     * GetOptions    Get options
     *----------------------------------------------------------------

     p GetOptions      b
     d GetOptions      pi

      /free

       chain (parent.warehouse: '*TRAX') Options;

       if not %found;
         opdat2 = ' ';
         else;
         opdat2 = opdata;
       endif;

720jA  chain (parent.warehouse: '*TRAX2') Options;
720jA
720jA  if not %found;
720jA    opdat3 = ' ';
720jA    else;
720jA    opdat3 = opdata;
720jA  endif;

      /end-free
     p                 e

     *----------------------------------------------------------------
     * GetTraxRoute   Get Trax route record
     *----------------------------------------------------------------

     p GetTraxRoute    b
     d GetTraxRoute    pi

      /free

        chain (parent.Warehouse: parent.RouteId) ttrte;

        //  There may or may not be a TTRTE record
        //  Turn on update flage if it exists.

        //  Initialize fields.

        if not %found(ttrte);
          ttrwhs = 0;
          ttrrti = ' ';
          ttrusr = ' ';
        endif;

        ttrtru = ' ';
        ttrscn = ' ';
        ttrs   = 0;
        ttrsd  = 0;
        ttrqs1 = 0;
        ttrqs2 = 0;
        ttrqs3 = 0;
        ttrqn1 = 0;
        ttrqn2 = 0;
        ttrqn3 = 0;
        ttrqc1 = 0;
        ttrqc2 = 0;
        ttrqc3 = 0;
        ttrqp1 = 0;
        ttrqp2 = 0;
        ttrqp3 = 0;
        ttrsrd = 0;
        ttrsrt = 0;
        ttrfid = 0;
        ttrfit = 0;
        ttrser = ' ';

        return;
      /end-free
     p                 e

     *----------------------------------------------------------------
     * Log  -  Prints procedure flow
     *----------------------------------------------------------------

     p Log             b
     d Log             pi
     d  depth                        10I 0 value
     d  proc                         30A   varying const
     d  value                       100A   varying const

     * Local Variables

     d logLine         ds                  qualified
     d  depth                         3A
     d  spacer_2                      3
     d  path                        126A

      /free

720lA   // No longer printing log line. They were not looked at and
720lA   // a client had the spool file blow up with too many records (900+ pages)
720lA
720lA   return;


        logLine.depth = %char(%occur(stack)) + proc;
        logLine.path = elementPath + elementName + '/' + value;

        Print(logLine);

      /end-free
     p                 e

     *----------------------------------------------------------------
     * LowerToUpper   Convert lowercase to uppercase
     *----------------------------------------------------------------

     p LowerToUpper    b
     d LowerToUpper    pi         65535A   varying
     d  value                     65535A   varying const

     * Local Variables

     d strOut          s          65535A   varying
     d lowercase       c                   'abcdefghijklmnopqrstuvwxyz'
     d uppercase       c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

      /free

        strOut = %xlate(lowercase: uppercase: value);

        return strOut;

      /end-free
     p                 e

     *----------------------------------------------------------------
     * Print  -  Prints sent in text
     *----------------------------------------------------------------

     p Print           b
     d Print           pi
     d  text                        132A   value

      /free

        PrintLine = text;
        except;

      /end-free
     p                 e

730bA*----------------------------------------------------------------
730bA* RmvInvldChar   Remove invaid file name characters
730bA*----------------------------------------------------------------
730bA
730bAp RmvInvldChar    b
     d RmvInvldChar    pi         65535A   varying
     d  value                     65535A   varying const

     * Local Variables

     d strOut          s          65535A   varying
     d InvldChar       c                   '<>:/\|?*"'''
     d space           c                   '          '

      /free

        strOut = %xlate(invldChar: space: value);

        return strOut;

      /end-free
     p                 e

     *----------------------------------------------------------------
     * StampToDate    Convert Timestamp to YYYYMMDD date
     *----------------------------------------------------------------

     p StampToDate     b
     d StampToDate     pi             8s 0
     d  stampIn                        z   const

     * Local Variables

     d dateOut         s              8s 0

      /free

740eA   monitor;
          dateOut = %dec(%date(stampIn):*iso);
740eA   on-error;
740eA     dateOut = 0;
740eA   endmon;

        return dateOut;

      /end-free
     p                 e

     *----------------------------------------------------------------
     * StampToTime    Convert Timestamp to HHMMSS time
     *----------------------------------------------------------------

     p StampToTime     b
     d StampToTime     pi             6s 0
     d  stampIn                        z   const

     * Local Variables

     d timeOut         s              6s 0

      /free

740eA   monitor;
          timeOut = %dec(%time(stampIn):*hms);
740eA   on-error;
740eA     timeOut = 0;
740eA   endmon;

        return timeOut;

      /end-free
     p                 e

     *----------------------------------------------------------------
     * UpdateTTLog   Update log record
     *----------------------------------------------------------------

     p UpdateTTLog     b
     d UpdateTTLog     pi

      /free

         setll (parent.warehouse: parent.routeId) ttlog;
            dow forever = forever;
         reade (parent.warehouse: parent.routeId) ttlog;

         if %eof;
             leave;
         endif;

         if ttlStatus <> '3';
             iter;
         endif;

         //  This one's a status 3, so change it to 4.

         ttlStatus = '4';
         ttlErrCode = 'UPLOADED';
         ttlErrMsg  = 'File has been uploaded';
650dA    ttlSer = parent.deviceId;

         getCurrStamp();
         ttlTS9   = currStampLoc;

         update(e) ttlrec;

         enddo;

        return;
      /end-free
     p                 e

     *----------------------------------------------------------------
     * ValueToStamp   Convert Trax stamp to Dakota stamp/date/time
     *                2017-01-02T03:04:05 to 2017-01-02-03.04.05
     *                2017.01.02T03:04:05 to 2017-01-02-03.04.05
     *----------------------------------------------------------------

     p ValueToStamp    b
     d ValueToStamp    pi              z
     d  value                     65535A   varying const

     * Local Variables

     d stampIn         s             26
     d stampOut        s               z
     d fromChar        c                   'T:.'
     d toChar          c                   '-.-'
     d noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')

      /free

        // Convert stamp from 2017-01-02T03:04:05 to 2017-01-02-03.04.05

        stampIn = %xlate(fromChar: toChar: value);

        // Convert into timestamp field

        monitor;
          stampOut = %timestamp(stampIn);
        on-error;
          stampOut = noStamp;
        endmon;

        return stampOut;

      /end-free
     p                 e

     *----------------------------------------------------------------
     *  VfyEmployee  Verify employee number
     *----------------------------------------------------------------

     p VfyEmployee     b
     d VfyEmployee     pi

     * Local variables

     d e$whse          s              3  0
     d e$user          s             10
     d e$fnam          s             15
     d e$init          s              1
     d e$lnam          s             20
     d e$whdp          s              5
     d e$styp          s              1
     d e$shft          s              6
     d e$crew          s              6
     d e$nhrs          s              3  1
     d e$rtn           s              8
     d e$bpu           s              1
     d e$lng           s              2
710bAd e$email         s              1
710bAd e$pics          s              1

      /free

         if pEmpNo = 'N/A' or pEmpNo = 'uid';
           gEmp# = 99999;
         else;
           monitor;
             gEmp# = %dec(pEmpNo:5:0);
           on-error;
             pRtnCode    = '*ERROR';
             pRtnMessage = '(TR842) Invalid Emp# - ' + pEmpNo;
             return;
           endmon;
         endif;

         // Convert to a number

         monitor;
           gEmp# = %dec(pEmpNo:5:0);
         on-error;
           pRtnCode    = '*ERROR';
           pRtnMessage = '(TR842) Invalid Emp# - ' + pEmpNo;
           return;
         endmon;

         // Get employee info

         monitor;
           //getEmpl(gEmp#: e$Whse: gUser: e$fnam: e$init: e$lnam:
           //        e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
           //        e$bpu: e$lng: e$email: e$pics);
           getEmpl(gEmp#: e$Whse: gUser: e$fnam: e$init: e$lnam:
                   e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                   e$bpu: e$lng);
         on-error;
           pRtnCode    = '*ERROR';
           pRtnMessage = '(TR842) Error calling getEmpl';
           return;
         endmon;

         if e$rtn = '*ERROR';
           pRtnCode    = '*ERROR';
           pRtnMessage = '(TR842) User not found for emp# ' + pEmpNo;
           return;
         endif;

       return;
      /end-free

     p VfyEmployee     e

     *----------------------------------------------------------------
     *  VfyRteId   Verify route id
     *----------------------------------------------------------------

     p VfyRteId        b
     d VfyRteId        pi

      /free

         // Verify route exists in RTEHED file

         chain (pWhse: pRtid) rtehed;
         if not %found(rtehed);
           pRtnCode    = '*ERROR';
           pRtnMessage = '(TR842) Route not found (' + %trim(pRtId) + ')';
           return;
         endif;

         // Verify route status is Closed or Exported

         If rhstat <> '5' and rhstat <> '6';
           pRtnCode    = '*ERROR';
           pRtnMessage = '(TR842) Route not at Closed '
                   + 'or Exported status ('
                   + %trim(pRtId) + ')';
           return;
         endif;

       return;
      /end-free

     p VfyRteId        e

720rA*----------------------------------------------------------------
720rA*  wrtDebugLibl   Write out debug parm record
720rA*----------------------------------------------------------------
720rA
     p WrtDebugLibl    b
     d WrtDebugLibl    pi

      /free

        if not %open(bfcdebug);
          open bfcdebug;
        endif;

        bdtype = 'LIBL';

        GetLiblCL(bdvalues);

        bdaddts = %timestamp();
        bdaddpgm = #pgm;
        bdaddcusr = #curruser;
        bdaddjusr = #user;
        bdaddjob = #job;
        bdaddnbr = #jobnbr;

        write bdrec;

      /end-free
     p                 e

720rA*----------------------------------------------------------------
720rA*  wrtDebugParms  Write out debug parm record
720rA*----------------------------------------------------------------
720rA
     p WrtDebugParms   b
     d WrtDebugParms   pi

      /free

        if not %open(bfcdebug);
          open bfcdebug;
        endif;

        bdtype = 'PARMS';

        bdvalues = 'pVersion=' + pVersion + ', '
                 + 'pCommand=' + pCommand + ', '
                 + 'pWhse=' + %trim(%char(pWhse)) + ', '
                 + 'pRtid=' + pRtid + ', '
                 + 'pStop=' + pStop + ', '
                 + 'pPath=' + pPath + ', '
                 + 'pFile=' + pFile;

        bdaddts = %timestamp();
        bdaddpgm = #pgm;
        bdaddcusr = #curruser;
        bdaddjusr = #user;
        bdaddjob = #job;
        bdaddnbr = #jobnbr;

        write(e) bdrec;

      /end-free

     p                 e

720rA*----------------------------------------------------------------
720rA*  wrtDebug  Write out debug record
720rA*----------------------------------------------------------------
720rA
     p WrtDebug        b
     d WrtDebug        pi
     d  name                        100    varying const

     * Local Variables

     d zeroStop        s              2  0

      /free

        if not %open(bfcdebug);
          open bfcdebug;
        endif;

        bdvalues = 'name=' + name + ', '
                 + 'pCommand=' + pCommand + ', '
                 + 'parent.routeid=' + parent.routeId + ', '
                 + 'pVersion=' + pVersion + ', '
                 + 'zeroStop=' + %trim(%char(zeroStop));

        bdaddts = %timestamp();
        bdaddpgm = #pgm;
        bdaddcusr = #curruser;
        bdaddjusr = #user;
        bdaddjob = #job;
        bdaddnbr = #jobnbr;

        write(e) bdrec;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ZZDriCop   Get item info.
     *----------------------------------------------------------------

     p ZZDriCop        b
     d ZZDriCop        pi

      /free

       error = *off;

       select;
         when $dricommand = '*ITEM';
           $dridata = $item;
           $dridata2 = $item2;
       endsl;

       driCop($dricommand: $drisubcmd: $drisys2upd: #prog:
                $drireturn: $drimessage: $dridata: $dridata2);

       select;
         when %error;
           error = *on;
         when $drireturn <> '*OK';
           error = *on;
       endsl;

       select;
         when $dricommand = '*ITEM';
           $item = $dridata;
           $item2 = $dridata2;
       endsl;

      /end-free

     p ZZDriCop        e

     *----------------------------------------------------------------
     * For IFS routines
     *----------------------------------------------------------------

      /define ERRNO_LOAD_PROCEDURE
      /copy qcopysrc,errno_h
