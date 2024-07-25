      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  RCVEXCPT  -  Return proper data for Receiving Exception Report
     *  13 November 2018
     *  Kenneth Elder
     *
     *  Revisions:
     *
416 A*    11/13/18  KDE  7.20
     *      - Created.  Any changes here should be considered for
     *        EX126 since this simply returns all proper data for
     *        GUI Receiving Exception Report.
730 A*    01/03/20  KDE  7.30
     *      - Replace double quote with \" for json error
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpiritem   if   e           k disk
520a Fitemmsc   if   e           k disk
     Fpomfr1    if   e           k disk
650aAFpocwexcp  if   e           k disk    rename(exrec:cwexrec) prefix(c_)
     FLicense1  if   e           k disk
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *
650aMD desc            s             50    dim(11) ctdata perrcd(1)
     *----------------------------------------------------------------

     *----------------------------------------------------------
     *  SQL record layouts referenced
     *----------------------------------------------------------

     D exrec         E Ds                  Extname(itmexcp)

     *  Redefinition data structures
     *
     D                 ds
     D  m_exfdis               1     12
     D  m_extdis              13     24
     D  dspo                   1      9
     D  dslbl                 10     16  0
     D  dsexpd                17     24  0
417c D  dsupc                  1     20
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     *
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
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $llen           s              3  0
     D $lstr           s             60
     D $plen           s              3  0
     D $pstr           s             60
730 AD pos             s              2  0
730 Ad dblqte          s              1    inz('"')
730 Ad backslash       s              1    inz('\')
730 Ad rpldblqte       s              2    inz('\"')
730 Ad rplspace        s              2    inz(' ')
     D expdte          s              6  0
     D fmdt            s              6  0
     D gendte          s              6  0
     D l               s              1  0
     D m               s                   like(l)
     D mfgdte          s              6  0
     d stat            s             10
     D todt            s              6  0
     D type            s              5
     D wkprtf          s             10
     D errmsg          s             50
     D lcnupc          s             15
     d pOutStr         s           1024    varying
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    pWhse             3 0
     C                   parm                    pWhdp             5
     C                   parm                    pStyp             1
     C                   parm                    pItem            15
     C                   parm                    pfdis            12
     C                   parm                    ptdis            12
     C                   parm                    ptask             6
     C                   parm                    perid             7
     c                   parm                    pOutstr
      *  Get record passed in
      /free
            exec sql select * into :exrec
                  from itmexcp
                   where exwhse=:pWhse and exwhdp=:pWhdp and
                         exitem=:pItem and exfdis=:pfdis and
                         extdis=:ptdis and extask='RCV'
                       fetch first row only;
            if sqlStt = '00000';
               m_extdis=extdis;
               m_exfdis=exfdis;
            else;
             // Build return json string
710aA        pOutStr = '{'
710aA        +  '"Whdp":"'  + %char(pWhse) + '",'
             +  '"Type":"'  + ' ' + '",'
             +  '"Itdesc":"'  + ' ' + '",'
             +  '"pmtrn":"'  + ' ' + '",'
             +  '"lcnupc":"'  + ' ' + '",'
710eA        +  '"imbnbr":"'  + ' ' + '",'
710eA        +  '"po":"'  + ' ' + '",'
             +  '"qty":"'  + ' ' + '",'
             +  '"gdate":"'  + ' ' + '",'
             +  '"gby":"'  + ' ' + '",'
             +  '"expdte":"'  + ' ' + '",'
             +  '"mfgdte":"'  + ' ' + '",'
             +  '"stat":"'  + ' ' + '",'
             +  '"errmsg":"'  + 'No ITMEXCP Data ' + '"}';
               *inlr=*on;
               return;
            endif;
      /end-free
     *
     *  Format Dept/Section/Desig
     *
     C                   if        exstyp = 'P'
     C                   eval      type = 'PIR  '
     C                   else
     C                   if        exstyp = 'F'
     C                   eval      type = 'Fixed'
     C                   else
     C                   eval      type = '*Both'
     C                   endif
     C                   endif

      *  set status
      *
     c                   if        exesta='4'
     c                   eval      stat = 'Closed'
     c                   else
     c                   eval      stat='Open'
     c                   endif

     *----------------------------------------------------------------
     *
     * Detail Calcs
     *
     *  Convert Generated date
     *
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      exgdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      gendte = $cvd6o
     *
     *  Retrieve item description.
     *
     C     itkey         chain     piritem                            79
     C                   if        *in79
     C                   eval      itdesc = *blanks
     C                   endif
520a *
520a C     itkey         chain     itemmsc                            79
520a C                   if        *in79
520a C                   eval      imbnbr = *zeros
520a C                   endif
     *
     *  Setup error description for printing.
     *
     C                   select
     C                   when      exerid = 'EXPDOVR'
     C                   movel     desc(3)       errmsg
510aAC                   when      exerid = 'OA-DOVR'
510aAC                   movel     desc(4)       errmsg
510aAC                   when      exerid = 'OB-DOVR'
510aAC                   movel     desc(5)       errmsg
510aAC                   when      exerid = 'OC-DOVR'
510aAC                   movel     desc(6)       errmsg
510aAC                   when      exerid = 'OD-DOVR'
510aAC                   movel     desc(7)       errmsg
510aAC                   when      exerid = 'OE-DOVR'
510aAC                   movel     desc(8)       errmsg
510aAC                   when      exerid = 'OF-DOVR'
510aAC                   movel     desc(9)       errmsg
510bAC                   when      exerid = 'DD-CODE'
510bAC                   movel     desc(10)      errmsg
650aAC                   when      exerid = 'CW-OVR '
650aAC                   movel     desc(11)      errmsg
     C                   other
     C                   eval      errmsg = exerid
     C                   endsl
     *
     *    Get POMFR record.
     *
417bD*          EXTASK    IFEQ 'EXPOVR'
417b C                   if        exerid = 'EXPDOVR'  or
510a C                             exerid = 'OA-DOVR'  or
510a C                             exerid = 'OB-DOVR'  or
510a C                             exerid = 'OC-DOVR'  or
510a C                             exerid = 'OD-DOVR'  or
510a C                             exerid = 'OE-DOVR'  or
510a C                             exerid = 'OF-DOVR'  or
510bAC                             exerid = 'DD-CODE'
650aAC*                            exerid = 'CW-OVR '
     C     dslbl         chain     pomfr1                             78
     C                   if        *in78
610 AC                   eval      pmpo = dspo
     C                   eval      pmseq = 0
     C                   eval      pmtrn# = 0
     C                   eval      pmexpd = 0
417a C                   eval      lilcns = *blanks
417a *                    Z-ADD0         LILCNS
     C                   endif
417a C                   else
610 AC                   eval      pmpo = dspo
417a C                   eval      pmseq = 0
417a C                   eval      pmtrn# = 0
417a C                   eval      pmexpd = 0
417a C                   eval      lilcns = *blanks
417a C                   endif
520aA*  Convert Expiration date
520aA*
520aAC                   eval      expdte = 0
520aAC                   if        pmexpd <> 0
520aAC                   eval      $cvcmd = '*CMDMDY '
520aAC                   move      pmexpd        $cvd8i
520aAC                   call      @cvtdt
520aAC                   parm                    $cvtdt
520aAC                   eval      expdte = $cvd6o
520aAC                   endif
     *
520bA*  Convert Mfg date
520bA*
520bAC                   eval      mfgdte = 0
520bAC                   if        pmmfgd <> 0
520bAC                   eval      $cvcmd = '*CMDMDY '
520bAC                   move      pmmfgd        $cvd8i
520bAC                   call      @cvtdt
520bAC                   parm                    $cvtdt
520bAC                   eval      mfgdte = $cvd6o
520aAC                   endif
     *
     *    Get LICENSE record.
     *
     C                   if        pmtrn# <> 0
     C     keyli         chain     license1                           78
     C                   if        *in78
417a *                    Z-ADD0         LILCNS
417aMC                   eval      lilcns = *blanks
     C                   endif
     C                   endif
650aA /free
650aA    if exerid = 'CW-OVR ';
650aA      chain (exwhse: dslbl) pocwexcp;
650aA      if not %found(pocwexcp);
650aA        eval lilcns = ' ';
650aA      else;
650aA        chain (c_exwhse:c_extrn#) license1;
650aA        if %found(license1);
650aA        else;
650aA          eval lilcns = ' ';
650aA        endif;
650aA      endif;
650aA      pmtrn# = c_extrn#;
650aA      pmpo = c_expo;
650aA    endif;
650aA /end-free
417c *
417c *  Move License or UPC to out field
417d C                   eval      lcnupc = *blanks
417c C                   if        exerid = 'RDUPUPC'
417c C                   eval      lcnupc = dsupc
417c C                   else
417c C                   movel     lilcns        lcnupc
417c C                   endif
      /free
730 A   // Replace double quotes with slash double qoute
730 A   pos = %scan(dblqte: itdesc);
730 A   dow pos > 0;
730 A      itdesc = %replace(rpldblqte: itdesc: pos: %len(dblqte)) ;
730 A      if (pos+%len(rpldblqte) > %len(itdesc));
730 A         pos = 0;
730 A      else;
730 A         pos = %scan(dblqte: itdesc: pos+%len(rpldblqte));
730 A      endif;
730 A   enddo;
             // Build return json string
710aA   pOutStr = '{'
710aA     +  '"Whdp":"'  + %trim(exwhdp) + '",'
             +  '"Type":"'  + %trim(Type) + '",'
             +  '"Itdesc":"'  + %trim(Itdesc) + '",'
             +  '"pmtrn":"'  + %char(pmTrn#) + '",'
             +  '"lcnupc":"'  + %trim(lcnupc) + '",'
710eA        +  '"imbnbr":"'  + %char(imbnbr) + '",'
710eA        +  '"po":"'  + %trim(dspo) + '",'
             +  '"qty":"'  + %char(exqty) + '",'
             +  '"gdate":"'  + %trim(%editc(gendte:'Y')) + '",'
             +  '"gby":"'  + %trim(exgby) + '",'
             +  '"expdte":"'  + %trim(%editc(expdte:'Y')) + '",'
             +  '"mfgdte":"'  + %trim(%editc(mfgdte:'Y')) + '",'
             +  '"stat":"'  + %trim(stat) + '",'
             +  '"errmsg":"'  + %trim(errmsg) + '"}';
               *inlr=*on;
               return;
      /end-free
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
     C     itkey         klist
     C                   kfld                    exwhse
     C                   kfld                    exitem
     *
     *  Define key for LICENSE1
     *
     C     keyli         klist
     C                   kfld                    pmwhse
     C                   kfld                    pmtrn#
     *
     C                   endsr
     *
     * Compile time tables
     *
** Descriptions
            Open Exceptions
             Closed Exceptions
Exp dte ovrride
MFG Dt-Newer OFlow
MFG Dt-Dt > today
Exp Dt-> # days out
Exp Dt-Short sell
MFG Dt-Short sell
Exp Dt-Newer OFlow
Date Decipher
Catch Weight Ovr
