     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2002')

     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  TSTRTVCORD   Test RTVCORD commands
     *  02 June 2002
     *  Dave Sommerville
     *
416  *    06/02/02  DAS  4.16
     *      - Created
     *
     *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Sub-Command Notes
      *
      *    Sub-Commands
      *
      *      *OPEN             Open program and return.
      *
      *      *CLOSE            Close program with *INLR = *ON
      *
      *      *RTVCORDDT        Retrieve order detail.
      *                        ** Only sent to Host from this program **
      *
      *      *RTVCORDHD        Retrieve order header using customer order #
      *                        ** Only sent to Host from this program **
      *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fimpordd   uf a e           k disk
     Fimpordh   uf a e           k disk

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ORDD
      /COPY *libl/qcopysrc,C#ORDH
     D saveVer#        s                   like($ohver#)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D error           s               n
     D forever         s               n   inz(*on)
     D orddetail       s               n
     D ordheader       s               n
     D pssrflag        s               n

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $psubcmd   Sub-command
      *      $pprogram  Calling program (the one that called interface)
      *      $pdata     Data needed by command
      *
      *    Returned Parameters
      *      $preturn   Return code
      *      $pmessage  Return message
      *      $pdata     Data returned by command
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Let the show begin .....
      *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $psubcmd
     C                   parm                    $pprogram
     C                   parm                    $preturn
     C                   parm                    $pmessage
     C                   parm                    $pdata

     *  Determine data structure to work with.

     C                   if        $psubcmd = '*RTVCORDHD'
     C                   eval      ordheader = *on
     C                   eval      orddetail = *off
     C                   else
     C                   eval      ordheader = *off
     C                   eval      orddetail = *on
     C                   endif

     C                   if        ordheader
     C                   eval      $ordh = $pdata
     C                   else
     C                   eval      $ordd = $pdata
     C                   endif

     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     *  See if we are just opening or closing program.

     C                   select

     C                   when      $psubcmd = '*OPEN'
     C                   goto      bottom

     C                   when      $psubcmd = '*CLOSE'
     C                   eval      *inlr = *on
     C                   goto      bottom

     C                   endsl

     C                   eval      error = *off

     *  Do what user has requested.

     C                   select

     C                   when      $psubcmd = '*RTVCORDHD'
     C                   exsr      rtvcordhd

     C                   when      $psubcmd = '*RTVCORDDT'
     C                   exsr      rtvcorddt

     C                   endsl

     C     bottom        tag

     *  We are finished so get out

     C                   if        ordheader
     C                   eval      $pdata = $ordh
     C                   else
     C                   eval      $pdata = $ordd
     C                   endif

     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * Key definitions

     *  Define key for ORDH file.

     C     keyoh         klist
     C                   kfld                    $ohwhse
     C                   kfld                    $ohcord

     C                   endsr

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

     C     *pssr         begsr

     *  Make sure we don't get caught in an infinite loop

 1B  C                   if        pssrflag
     C                   eval      *inlr = *on
     C                   return
     C                   endif

     C                   eval      pssrflag = *on

     *  Send message back to calling program.

     C                   eval      $preturn = 'U:' + #status
     C                   eval      $pmessage = 'U:'
     C                                       + %trim(#prog)
     C                                       + '('
     C                                       + %trim(%editc(#stmt:'Z'))
     C                                       + ')-'
     C                                       + #pgmmsg
     C                   eval      *inlr = *on
 1E  C                   return

     C                   endsr

     *----------------------------------------------------------------
     *  ordd2ds  Move order detail fields to data structure fields
     *----------------------------------------------------------------

     C     ordd2ds       begsr

      *  Initialize data structure

     C                   eval      savever# = $odver#
     C                   clear                   $ordd
     C                   eval      $odver# = savever#

     C* Move information to data structure.

     C                   eval      $odwhseu = *on
     C                   eval      $odwhse = oidwhs
     C**                 eval      $odoidu  = *on
     C**                 eval      $odoid  = oidord
     C                   eval      $odsequ  = *on
     C                   eval      $odseq  = oidseq
     C                   eval      $oditemu = *on
     C                   eval      $oditem = oiditm
     C                   eval      $odqor1u = *on
     C                   eval      $odqor1 = oidq1
     C                   eval      $odqor2u = *on
     C                   eval      $odqor2 = oidq2
     C                   eval      $odqor3u = *on
     C                   eval      $odqor3 = oidq3
     C                   eval      $odwh2u  = *on
     C                   eval      $odwh2  = oidwh2
     C                   eval      $odor2u  = *on
     C                   eval      $odor2  = oidor2
     C                   eval      $odoitmu = *on
     C                   eval      $odoitm = oidoit
     C                   eval      $odspclu = *on
     C                   eval      $odspcl = oidspc

     C                   endsr

     *----------------------------------------------------------------
     *  ordh2ds  Move order header fields to data structure fields
     *----------------------------------------------------------------

     C     ordh2ds       begsr

      *  Initialize data structure

     C                   eval      savever# = $ohver#
     C                   clear                   $ordh
     C                   eval      $ohver# = savever#

     C* Move information to data structure.

     C                   eval      $ohwhseu = *on
     C                   eval      $ohwhse = oihwhs
     C                   eval      $ohcordu = *on
     C                   eval      $ohcord = oihord
     C                   eval      $ohtypeu = *on
     C                   eval      $ohtype = oihtyp
     C                   eval      $ohcustu = *on
     C                   eval      $ohcust = oihcus
     C                   eval      $ohcnamu = *on
     C                   eval      $ohcnam = oihcnm
     C                   eval      $ohcad1u = *on
     C                   eval      $ohcad1 = oihca1
     C                   eval      $ohcad2u = *on
     C                   eval      $ohcad2 = oihca2
     C                   eval      $ohcctyu = *on
     C                   eval      $ohccty = oihcct
     C                   eval      $ohcstu  = *on
     C                   eval      $ohcst  = oihcst
     C                   eval      $ohczipu = *on
     C                   eval      $ohczip = oihczp
     C                   eval      $ohrteu  = *on
     C                   eval      $ohrte  = oihrte
     C                   eval      $ohstopu = *on
     C                   eval      $ohstop = oihstp
     C                   eval      $ohtruku = *on
     C                   eval      $ohtruk = oihtrk
     C                   eval      $ohmiscu = *on
     C                   eval      $ohmisc = oihmsc

     C                   endsr

     *----------------------------------------------------------------
     *  rtvcordhd   Retreive order header using customer order #
     *----------------------------------------------------------------

     C     rtvcordhd     begsr
     C                   eval      error = *off

     *  Get first matching record (assumes unique customer orders)

     C     keyoh         setll     impordh
     C     keyoh         reade     impordh
 2B
 2B  C                   if        %eof
     C                   eval      error = *on
     C                   eval      $preturn = 'CORDNOTFND'
     C                   eval      $pmessage = 'Customer order not found '
     C                                       + '('
     C                                       + %Trim(%editc($ohwhse:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc($ohcord:'Z'))
     C                                       + ')'
     C                   goto      endrtvcordhd
 2E  C                   endif

     *  Move fields to data structure.

     C                   exsr      ordh2ds

     *  Position pointer for retrieval of detail.

     C     keyoh         setll     impordd

     C     endrtvcordhd  endsr

     *----------------------------------------------------------------
     *  rtvcorddt   Retreive next order detail
     *----------------------------------------------------------------

     C     rtvcorddt     begsr
     C                   eval      error = *off

     *  Get first matching record (assumes unique customer orders)

     C     keyoh         reade     impordd
 2B
 2B  C                   if        %eof
     C                   eval      $preturn = '*EOF'
     C                   eval      $pmessage = ' '
     C                   goto      endrtvcorddt
 2E  C                   endif

     *  Move fields to data structure.

     C                   exsr      ordd2ds

     C     endrtvcorddt  endsr
