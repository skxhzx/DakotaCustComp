      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  RPLEXCPT  -  Return proper data for Replen Exception Report
     *  13 November 2018
     *  Kenneth Elder
     *
     *  Revisions:
     *
     * ------------------------------------------------------------------
416 A*    11/13/18  KDE  7.20
     *      - Created.  Any changes here should be considered for
     *        IT286 since this simply returns all proper data for
     *        GUI Replen Exception Report.
740 A*    01/13/20  KDE  7.40
     *      - Replace double quote with \" for json error
     * ------------------------------------------------------------------
     *
414aA*    09/05/00  MLB  4.14a
     *      - Added PIRITEM to program.
     *      - Added support to program to print open/closed exceptions.
     *
415aA*  03/23/01  MLB  4.15a
     *    - Revised message text for error id VRTSLT to read
     *      'Vrt slot found' in DESC,2.
415bA*  03/26/01  MLB  4.15a
     *    - Added new message text for error id NOTEMTY.
     *
416 A*  10/03/01  DAS  4.16
     *    - Revised to display *Both instead of *None for section type
416aA*    12/28/01  MLB  4.16a
     *      - Revised program to add 2 new error codes: FIFOROT,SLTEXPD
416bA*    09/20/02  MLB  4.16b
     *      - Revised program to add 1 new error code: LIST
610a *    12/11/09  GJA  6.10a
     *      - Revised program to add LCNS
610b *    02/01/10  GJA  6.10b
     *      - Revised program to add LCNS with IT252
610c *    10/28/10  RH   6.10c
     *      - Fix: Change to display 'Lcn not scanned' for LCNS error
     *        was displaying 000000 for time corrected.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Not on file/End of file indicator
     *  91        Overflow Indicator
     *
     *----------------------------------------------------------------
     *  File Specs
     *
414aAFpiritem   if   e           k disk
     Freports   if   e           k disk
     *----------------------------------------------------------------
     *
     *  Table and array
     *
     *
     D reck            s              7  0 dim(3)
     D lvlk            s              7  0 dim(3)
     *
     D cls             s              5  0 dim(3)
610cMD desc            s             50    dim(10) ctdata perrcd(1)

     *----------------------------------------------------------
     *  SQL record layouts referenced
     *----------------------------------------------------------

     D exrec         E Ds                  Extname(itmexcp)

     *----------------------------------------------------------------
     *
     *  Variables
     *
     D $llen           s              3  0
     D $lstr           s             60
     D $plen           s              3  0
     D $pstr           s             60
740 AD pos             s              2  0
740 Ad dblqte          s              1    inz('"')
740 Ad backslash       s              1    inz('\')
740 Ad rpldblqte       s              2    inz('\"')
740 Ad rplspace        s              2    inz(' ')
     D fmdt            s              6  0
     D gendte          s              6  0
     D l               s              1  0
     D m               s                   like(l)
     d stat            s             10
     D todt            s              6  0
     D type            s              5
     D wkprtf          s             10
     D errmsg          s             50
     d pOutStr         s           1024    varying
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
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    pwhse             3 0
     C                   parm                    pwhdp             5
     C                   parm                    pstyp             1
     C                   parm                    pitem            15
     C                   parm                    pfdis            12
     C                   parm                    ptdis            12
     C                   parm                    ptask             6
     C                   parm                    perid             7
     C                   parm                    pdate             8 0
     C                   parm                    ptime             6 0
     C                   parm                    poutstr
     *  Get record passed in
      /free
            exec sql select * into :exrec
                  from itmexcp
                   where exwhse=:pwhse and exwhdp=:pwhdp and
                         exitem=:pitem and exfdis=:pfdis and
                         extdis=:ptdis and extask in('REPL',
                         'REPLTF','VERIFY','REPLBK','TFRMOV',
                         'LCNS') and
                         exgdte=:pdate and exgtim=:ptime
                       fetch first row only;
            if sqlstt = '00000';
            else;
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
416 D*                    MOVE '*None'   TYPE
416 MC                   eval      type = '*Both'
     C                   endif
     C                   endif
      *
      *  set status
      *
     c                   if        exesta='4'
     c                   eval      stat = 'Closed'
     c                   else
     c                   eval      stat='Open'
     c                   endif
     C*----------------------------------------------------------------
     C*
     C* Detail Calcs
     C*
     C*  Convert Generated date
     C*
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      exgdte        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      gendte = $cvd6o
414aAC*
414aAC*  Retrieve item description.
414aAC*
414aAC     itkey         chain     piritem                            79
414aAC                   if        *in79
414aAC                   eval      itdesc = *blanks
414aAC                   endif
414aAC*
414aAC*  Setup error description for printing.
414aAC*
414aAC                   select
414aAC                   when      exerid = 'WRGITM '
414aAC                   movel     desc(3)       errmsg
414aAC                   when      exerid = 'VRTSLT '
414aAC                   movel     desc(4)       errmsg
414aAC                   when      exerid = 'QTYEXC '
414aAC                   movel     desc(5)       errmsg
415bAC                   when      exerid = 'NOTEMTY'
415bAC                   movel     desc(6)       errmsg
416aAC*
416aAC                   when      exerid = 'FIFOROT'
416aAC                   movel(p)  desc(7)       errmsg
416aAC*
416aAC                   when      exerid = 'SLTEXPD'
416aAC                   movel(p)  desc(8)       errmsg
416aAC*
416bAC                   when      exerid = 'LIST'
416aAC                   movel(p)  desc(9)       errmsg
610aAC*
610aAC                   when      exerid = 'NOSCAN '
610aAC                   if        extdis = 'LT105'  or
610aAC                             extdis = 'IT276'  or
610bAC                             extdis = 'IT252'
610aAC                   eval      extdis = *blanks
610aAC                   eval      errmsg = *blanks
610cDC*                    MOVELEXCTIM    ERRMSG
610cAC                   movel     desc(10)      errmsg
610aAC                   endif
416bAC*
414aAC                   other
414aAC                   movel(p)  exerid        errmsg
414aAC                   endsl
      /free
740 A   // Replace double quotes with slash double qoute
740 A   pos = %scan(dblqte: itdesc);
740 A   dow pos > 0;
740 A      itdesc = %replace(rpldblqte: itdesc: pos: %len(dblqte)) ;
740 A      if (pos+%len(rpldblqte) > %len(itdesc));
740 A         pos = 0;
740 A      else;
740 A         pos = %scan(dblqte: itdesc: pos+%len(rpldblqte));
740 A      endif;
740 A   enddo;
             // Build return json string
710aA   pOutStr = '{'
710aA     +  '"Whdp":"'  + %trim(exwhdp) + '",'
             +  '"Type":"'  + %trim(Type) + '",'
             +  '"Itdesc":"'  + %trim(Itdesc) + '",'
             +  '"qty":"'  + %char(exqty) + '",'
             +  '"gdate":"'  + %trim(%editc(gendte:'Y')) + '",'
             +  '"gtime":"'  + %editw(exgtim:'0 :  :  ') + '",'
             +  '"gby":"'  + %trim(exgby) + '",'
             +  '"stat":"'  + %trim(stat) + '",'
             +  '"errmsg":"'  + %trim(errmsg) + '"}';
               *inlr=*on;
               return;
      /end-free
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     C     *inzsr        begsr
     C*
     Csr   rpkey         klist
     Csr                 kfld                    wkprtf
     C*
414aAC     itkey         klist
414aAC                   kfld                    exwhse
414aAC                   kfld                    exitem
414aAC*
     Csr   exkey         klist
     Csr                 kfld                    exwhse
     Csr                 kfld                    exwhdp
     Csr                 kfld                    exstyp
     Csr                 kfld                    exitem
     Csr                 kfld                    exgdte
     Csr                 kfld                    exgtim
     C                   endsr
     O*----------------------------------------------------------------
     O*
     O* Compile time tables
     O*
** Descriptions
            Open Exceptions
             Closed Exceptions
Wrg itm in slot
Vrt slot found
Qty exception
Empty = No
FIFO Rotation error
Expired product replen'd
Used slot list display
Lcn not scanned
