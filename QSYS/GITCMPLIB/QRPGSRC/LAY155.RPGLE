     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LAY155     Layout Designer - Extract Item Demand
     *  22 October 2013
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Notes:
     *
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650 A*   10/22/13  MLB  6.50
     *     - Created
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
GLP A*    10/23/13  MLB  GLP
     *      - Revised pgm to omit all items with *INACTIVE in
     *        ext. item description. Per Dave S.
GLPaA*    10/28/13  MLB  GLPa
     *      - Revised pgm to omit type R=Repack items. Per Lyle C.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fpiritem   if   e           k disk
     Fpiritem3  if   e           k disk    rename(itrec : itrec3)
     F                                     prefix(it3)
     Fitemlnk   if   e           k disk
     Fitemmsc   if   e           k disk
     Fitemavg   if   e           k disk
GLP AFitemdsc   if   e           k disk    usropn
     Fslot3     if   e           k disk
     Fexpslayi  o    e           k disk
     *
     *----------------------------------------------------------------
     *  Customer id
     *
GLP A /copy qcopysrc,id#glp
     *
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
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
     *  Called program parameters
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     D  $litem                22     36
     *
     *----------------------------------------------------------------
     *  Working Variables
     *
     D error           s              1
     D first           s              1
     D forevr          s              1
     D impdte          s              8  0
     D imptim          s              6  0
     D kyitem          s                   like(ititem)
     D kyitem2         s                   like(ititem)
     D kyitemsl        s                   like(ititem)
     D kypick          s                   like(slpick)
     D kystat          s                   like(slstat)
     D $pwhse          s              3  0
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
     *  Parameters
     *
     *    Input Parameters
     *      $pwhs   Warehouse number
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     C     *entry        plist
     C                   parm                    $pwhs             3
     *
     *----------------------------------------------------------------
     * Main line
     *
     *  First time through
     *
     C                   exsr      zzinz2
     *
     * Whip through all the download Update Item records
     *
     C                   eval      $pwhse = %dec($pwhs:3:0)
     C     $pwhse        setll     piritem
     C                   dow       forevr = forevr
     *
     C     $pwhse        reade     piritem
     C                   if        %eof(piritem)
     C                   leave
     C                   endif
     *
     C                   eval      kyitem = ititem
GLP A*
GLP AC                   if        client = Greenleaf
GLP AC                   exsr      zzgetix
GLP A*       Omit items flagged as Inactive.
GLP AC                   if        %subst(ixdsc2:8:10) = '*INACTIVE'
GLP AC****               iter
GLP AC                   endif
GLPaA*
GLPaA*       Omit type R=Repack items.
GLPaAC                   if        ittype = 'R'
GLPaAC                   iter
GLPaAC                   endif
GLP A*
GLP AC                   endif
     *
     C                   select
     *---------------------------------------------
     C                   when         ittype = ' '
     C                             or ittype = 'B'
     *       Get ItemMsc record
     C                   exsr      zzgetim
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'Y'
     *       Get Slot3 record
     C                   eval      kyitemsl = kyitem
     C                   exsr      zzgetsl
     *
     *       Get Parent PirItem record.
     C                   if        ittype = 'B'
     C                   exsr      zzgetil
     C                   exsr      zzgetit3
     C                   endif
     *
     *       Get ItemAvg record
     C                   exsr      zzgetig
     *
     *       Fill Layout Designer Import extract file
     C                   exsr      zzfill
     C                   exsr      zzwrite
     *
     *---------------------------------------------
     C                   when         ittype = 'A'
     C                             or ittype = 'S'
     *       Get ItemMsc record
     C                   exsr      zzgetim
     *
     *       Get Item Link record.
     C                   exsr      zzgetil
     C                   eval      kyitemsl = ilitm2
     *       Get Parent PirItem record.
     C                   exsr      zzgetit3
     C                   if            ittype = 'A'
     C                             and it3ittype = 'S'
     *       Get Item Link record for SSB item.
     C                   eval      kyitem2 = ilitm2
     C                   exsr      zzgetil2
     C                   eval      kyitemsl = ilitm2
     C                   endif
     *
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'Y'
     *       Get Slot3 record
     C                   exsr      zzgetsl
     *
     *       Get ItemAvg record
     C                   exsr      zzgetig
     *
     *       Fill Layout Designer Import extract file
     C                   exsr      zzfill
     C                   exsr      zzwrite
     *
     *---------------------------------------------
     C                   when         ittype = 'R'
     *       Get ItemMsc record
     C                   exsr      zzgetim
     *
     *       Get Item Link record.
     C                   exsr      zzgetil
     C                   eval      kyitemsl = ilitm2
     *       Get Parent PirItem record.
     C                   exsr      zzgetit3
     *
     C                   eval      kystat = 'RP'
     *       Get Slot3 record
     C                   exsr      zzgetsl2
     *
     *       Get ItemAvg record
     C                   exsr      zzgetig
     *
     *       Fill Layout Designer Import extract file
     C                   exsr      zzfill
     C                   exsr      zzwrite
     *
     C                   endsl
     *
     C                   enddo
     *
     *
     *  We are finished so get out
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     * Open User Controlled files
     *
GLP AC                   if        client = Greenleaf
GLP A*
GLP AC                   if        not %open(itemdsc)
GLP AC                   open      itemdsc
GLP AC                   endif
GLP A*
GLP AC                   endif
     *
     * Key definitions
     *
     *  Define key for PIRITEM3 file.
     *
     C     it3key        klist
     C                   kfld                    ilitm2
     C                   kfld                    $pwhse
     *
     *  Define key for ITEMLNK file.
     *
     C     ilkey         klist
     C                   kfld                    itwhse
     C                   kfld                    kyitem
     *
     C     ilkey2        klist
     C                   kfld                    itwhse
     C                   kfld                    kyitem2
     *
     *  Define key for ITEMAVG file.
     *
     C     igkey         klist
     C                   kfld                    itwhse
     C                   kfld                    kyitem
     *
     *  Define key for ITEMMSC file.
     *
     C     imkey         klist
     C                   kfld                    itwhse
     C                   kfld                    kyitem
GLP A*
GLP A*  Define key for ITEMDSC file.
GLP A*
GLP AC     ixkey         klist
GLP AC                   kfld                    itwhse
GLP AC                   kfld                    kyitem
     *
     *  Define key for SLOT3 file.
     *
     C     sl3key        klist
     C                   kfld                    itwhse
     C                   kfld                    kyitemsl
     C                   kfld                    kystat
     C                   kfld                    kypick
     *
     C     sl3key2       klist
     C                   kfld                    itwhse
     C                   kfld                    kyitemsl
     C                   kfld                    kystat
     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     *
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGETIG   Get ItemAvg record.
     *
     C     zzgetig       begsr
     *
     C     igkey         chain     itemavg
     C                   if        not %found(itemavg)
     C                   eval      igaqsw = 0
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGETIL   Get ItemLnk record.
     *
     C     zzgetil       begsr
     *
     C     ilkey         chain     itemlnk
     C                   if        not %found(itemlnk)
     C                   eval      ilitm2 = ' '
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGETIL2   Get ItemLnk record (Alias items linked to SSB's)
     *
     C     zzgetil2      begsr
     *
     C     ilkey2        chain     itemlnk
     C                   if        not %found(itemlnk)
     C                   eval      ilitm2 = ' '
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGETIM   Get ItemMsc record.
     *
     C     zzgetim       begsr
     *
     C     imkey         chain     itemmsc
     C                   if        not %found(itemmsc)
     C                   eval      imtie  = 0
     C                   eval      imhigh = 0
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGETIT3   Get PirItem3 record.
     *
     C     zzgetit3      begsr
     *
     C     it3key        chain     piritem3
     C                   if        not %found(piritem3)
     C                   eval      it3itumq2 = 0
     C                   endif
     *
     C                   endsr
GLP A*
GLP A*----------------------------------------------------------------
GLP A*
GLP A*  ZZGETIX   Get ItemDsc record.
GLP A*
GLP AC     zzgetix       begsr
GLP A*
GLP AC     ixkey         chain     itemdsc
GLP AC                   if        not %found(itemdsc)
GLP AC                   eval      ixdsc1 = ' '
GLP AC                   eval      ixdsc2 = ' '
GLP AC                   endif
GLP A*
GLP AC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGETSL   Get SLOT3 record.
     *
     C     zzgetsl       begsr
     *
     C     sl3key        setll     slot3
     C     sl3key        reade     slot3
     C                   if        %eof(slot3)
     C                   eval      sldisp = ' '
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGETSL2   Get SLOT3 record. (Repack items)
     *
     C     zzgetsl2      begsr
     *
     C     sl3key2       setll     slot3
     C     sl3key2       reade     slot3
     C                   if        %eof(slot3)
     C                   eval      sldisp = ' '
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill Item fields.
     *
     C     zzfill        begsr
     *
     C                   if        ittype = ' '
     C                             or ittype = 'B'
     C                   eval      lyitem = ititem
     C                   else
     C                   eval      lyitem = kyitem
     C                   endif
     *
     C                   eval      lytype = ittype
     *
     C                   eval      lydesc = itdesc
     C                   eval      lypdsc = itpdsc
     *
     C                   eval      lywhdp = itwhdp
     *
     C                   eval      lyum1  = itum1
     *
     C                   eval      lyven  = itven#
     C                   eval      lyvitm = itvit#
     *
     C                   eval      lyulen = itulen
     C                   eval      lyuwdt = ituwdt
     C                   eval      lyuhgt = ituhgt
     *
     C                   eval      lycube = itcube
     *
     C                   eval      lyswgt = itswgt
     C                   eval      lycwgt = itcwgt
     *
     C                   eval      lytie  = imtie
     C                   eval      lyhigh = imhigh
     *
     C                   eval      lyavsl = %dec(igaqsw:5:0)
     C                   eval      lyavqy = 0
     *
     C                   select
     C                   when         ittype = 'A'
     C                             or ittype = 'B'
     C                             or ittype = 'S'
     C                             or ittype = 'R'
     C                   eval      lympck = it3itumq2
     C                   eval      lymitm = ilitm2
     C                   other
     C                   eval      lympck = 0
     C                   eval      lymitm = ' '
     C                   endsl
     C                   eval      lydisp = sldisp
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     * Get import date/time.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      impdte = $cvd8o
     C                   time                    imptim
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZWRITE    Write record to import file
     *
     C     zzwrite       begsr
     *
     C                   write     lyrec
     *
     C                   endsr
     *
     *----------------------------------------------------------------*********
     *
     *  Compile Time Tables
     *
