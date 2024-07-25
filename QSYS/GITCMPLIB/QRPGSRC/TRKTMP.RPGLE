     H copyright('(c) Copyright BFC Associates Inc - 2006')
     H option(*nodebugio)
     *----------------------------------------------------------------
     *
     *  TRKTMP    Update current truck definitions
     *  25 April 2006
     *  Jeff Jahnke
     *
     *  Revisions
     *
510 A*    09/18/07  JCJ  5.10
     *      - Created
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        POSITION CURSOR
     *  21 - 29   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  79        CHAIN INDICATOR
     *  90        PROTECT INPUT FIELDS FOR DELETE DISPLAY
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Ftruckh    uf a e           k disk    rename(threc:record)
     Ftruckh1   if   e           k disk    rename(threc:record1)
     Ftruckh2   uf   e           k disk    rename(threc:record2)
     Ftemplateh if a e           k disk
     Fnexttmpl  uf   e           k disk
     Fzoneh     uf a e           k disk
     Fzoned1    uf a e           k disk
     Fzonehwk   uf a e           k disk    prefix(x)
     Fzonedwk   uf a e           k disk    prefix(y)
     Foptionz   if   e           k disk
     Foptionz3  if a e           k disk    rename(opzrec:zrec) prefix(z)
     Foptionz4  if   e           k disk    rename(opzrec:zrec2) prefix(x)
     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
530 A*----------------------------------------------------------------
530 A*  *PICKLBL  -  Picking label options
530 A*----------------------------------------------------------------
530 A*
530 A* Fields
530 A*
530 A*    OPCLVL  -  Qty level for combined labels.
530 A*    OPCWRB  -  Print combined label warning before.
530 A*    OPCWRA  -  Print combined label warning after.
530 A*    OPUWRB  -  Print unit of measure warning before.
530 A*    OPUWRA  -  Print unit of measure warning after.
530 A*    OPTEXT  -  Text for last line of label.
530 A*    OPERR   -  Error label ratio.
530 A*    OPCWGT  -  Catch weight label ratio.
530 A*    OPLPGM  -  Picking label program.
530 A*    OPPDEV  -  Printer device.
530 A*    OPPFRM  -  Printer form.
530 A*    OPAISL  -  Print aisle change label (Y/N).
530 A*    OPTAXR  -  Include in Tax Right (Y=Yes, N=No).
530 A*    OPCHKR  -  Include in Check Right (Y=Yes, N=No).
530 A*
530 A* Data structure
530 A*
530 AD opdta2          ds
530 AD  opclvl                 1      3  0
530 AD  opcwra                 4      4
530 AD  opcwrb                 5      5
530 AD  opuwra                 6      6
530 AD  opuwrb                 7      7
530 AD  optext                 8     50
530 AD  operr                 51     52  0
530 AD  opcwgt                53     54  0
530 AD  oplpgm                55     64
530 AD  oppdev                65     74
530 AD  oppfrm                75     84
530 AD  opaisl                85     85
530 AD  optaxr                86     86
530 AD  opchkr                87     87
530 AD  optend               117    117
530 A*----------------------------------------------------------------
530 A*  *PICKLBA -  Label printing options for the standard pick,
530 A*              retail, and tote labels.
530 A*
530 A*     08/12/09  RBD  5.20  P#00219
530 A*       - Added record type *PICKLBA which holds printing info
530 A*         for the standard pick, retail, and tote labels.
530 A*
530 A*----------------------------------------------------------------
530 A* Fields
530 A*
530 A*    OPLB1   -  Print standard pick label Y/N.   - Standard pick label
530 A*    OPCU1   -  Use cutter option Y/N.           - Standard pick label
530 A*    OPLP1   -  Label printing program.          - Standard pick label
530 A*    OPDV1   -  Printer device.                  - Standard pick label
530 A*    OPFM1   -  Form.                            - Standard pick label
530 A*
530 A*    OPLB2   -  Print retail label Y/N.          - Retail label
530 A*    OPCU2   -  Use cutter option Y/N.           - Retail label
530 A*    OPLP2   -  Label printing program.          - Retail label
530 A*    OPDV2   -  Printer device.                  - Retail label
530 A*    OPFM2   -  Form.                            - Retail label
530 A*
530 A*    OPLB3   -  Print tote label Y/N.            - Tote label
530 A*    OPCU3   -  Use cutter option Y/N.           - Tote label
530 A*    OPLP3   -  Label printing program.          - Tote label
530 A*    OPDV3   -  Printer device.                  - Tote label
530 A*    OPFM3   -  Form.                            - Tote label
530 A*
530 A* Data structure
530 A*
530 AD opdta3          ds
530 AD  oplb1                  1      1
530 AD  opcu1                  2      2
530 AD  oplp1                  3     12
530 AD  opdv1                 13     22
530 AD  opfm1                 23     32
530 AD  oplb2                 33     33
530 AD  opcu2                 34     34
530 AD  oplp2                 35     44
530 AD  opdv2                 45     54
530 AD  opfm2                 55     64
530 AD  oplb3                 65     65
530 AD  opcu3                 66     66
530 AD  oplp3                 67     76
530 AD  opdv3                 77     86
530 AD  opfm3                 87     96
530 AD  opend3               117    117
530 A*----------------------------------------------------------------
530 A*  *PICKLBB -  Label printing options for the pick list and
530 A*               ASN labels and pick list report.
530 A*
530 A*     08/12/09  RBD  5.20  P#00219
530 A*       - Added record type *PICKLBB which holds printing info
530 A*         for the pick list and ASN labels and pick list report.
530 A*
530 A*----------------------------------------------------------------
530 A* Fields
530 A*
530 A*    OPLB4   -  Print pick list label Y/N.       - Pick list label
530 A*    OPCU4   -  Use cutter option Y/N.           - Pick list label
530 A*    OPLP4   -  Label printing program.          - Pick list label
530 A*    OPDV4   -  Printer device.                  - Pick list label
530 A*    OPFM4   -  Form.                            - Pick list label
530 A*
530 A*    OPLB5   -  Print ASN label Y/N.             - ASN label
530 A*    OPCU5   -  Use cutter option Y/N.           - ASN label
530 A*    OPLP5   -  Label printing program.          - ASN label
530 A*    OPDV5   -  Printer device.                  - ASN label
530 A*    OPFM5   -  Form.                            - ASN label
530 A*
530 A*    OPLB6   -  Print pick list report Y/N.      - Pick list report
530 A*    OPCU6   -  Use cutter option Y/N.           - Pick list report
530 A*    OPLP6   -  Label printing program.          - Pick list report
530 A*    OPDV6   -  Printer device.                  - Pick list report
530 A*    OPFM6   -  Form.                            - Pick list report
530 A*
530 A*    OPLB7   -  Print PICK labels for ZONPKUP 1/2- Pick labels
530 A*
530 A* Data structure
530 A*
530 AD opdta4          ds
530 AD  oplb4                  1      1
530 AD  opcu4                  2      2
530 AD  oplp4                  3     12
530 AD  opdv4                 13     22
530 AD  opfm4                 23     32
530 AD  oplb5                 33     33
530 AD  opcu5                 34     34
530 AD  oplp5                 35     44
530 AD  opdv5                 45     54
530 AD  opfm5                 55     64
530 AD  oplb6                 65     65
530 AD  opcu6                 66     66
530 AD  oplp6                 67     76
530 AD  opdv6                 77     86
530 AD  opfm6                 87     96
530 AD  oplb7                 97     97
530 AD  opend4               117    117
530 A*----------------------------------------------------------------
530 A*  *PICK  -  Picking options
530 A*
530 A*----------------------------------------------------------------
530 A*
530 A* Fields
530 A*
530 A*    OPNXTP  -  Next pallet number.
530 A*    OPBPCK  -  Bulk pick definition.
530 A*    OPPCUB  -  Maximum cube for PIR.
530 A*    OPFPAL  -  Pallets on fixed fork lift.
530 A*    OPFCUB  -  Maximum cube per fixed pallet.
530 A*    OPFSTP  -  Maximum stops per fixed pallet.
530 A*    OPINCL  -  Include PIR in fixed cube.
530 A*    OPSRCH  -  Number of previous pallets to search for space.
530 A*    OPFBLD  -  Fixed pallet building method.
530 A*                1 = By piece without concern for splitting stop.
530 A*                2 = By stop without splitting stop between plts.
530 A*    OPPBRK  -  Aisle to start new pallet.
530 A*    OPPBLD  -  Pallet building method.
530 A*                1 = By stop then slot location.
530 A*                2 = By slot location then stop.
530 A*                3 = By descening stop, then slot location.
530 A*    OPSELM  -  Selection method.
530 A*                1 = Single pass (By location).
530 A*                2 = Multiple pass (By stop).
530 A*    OPSPLT  -  Allow stop to be split across pallets (Y/N).
530 A*    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
530 A*    OPNWPL  -  Start new pallet when aisle changes if build method
530 A*               is 2=Location.
530 A*    OPFORD  -  Maximun orders per pallet.
530 A*    OPPTYP  -  Pallet type (P=Pallet, T=Tote, B=Batch).
530 A*    OPFTOT  -  Maximum totes per pallet.
530 A*    OPTECB  -  External tote cube.
530 A*    OPTICB  -  Internal tote cube.
530 A*    OPTSTP  -  Maximum stops per tote.
530 A*    OPTPCS  -  Maximum pieces per tote.
530 A*    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
530 A*    OPGCDE  -  USF Group Code (0-9).
530 A*    OPPKUP  -  Picked up by (S=Selector, L=Loader).
530 A*    OPSPAL  -  Merge pallet should only contain
530 A*               items for single truck pallet (Y=Yes, N=No).
530 A*    OPPITM  -  Maximum items per pallet.
530 A*
530 A* Data structure
530 A*
530 AD opdta1          ds
530 AD  opnxtp                 1      7  0 inz(0)
530 AD  oppcub                10     14  2 inz(0)
530 AD  opfpal                15     15  0 inz(0)
530 AD  opfcub                16     20  2 inz(0)
530 AD  opincl                22     22
530 AD  opsrch                23     24  0 inz(0)
530 AD  opfstp                25     26  0 inz(0)
530 AD  opfbld                27     27  0 inz(0)
530 AD  opbpck                28     30  0 inz(0)
530 AD  oppbrk                31     33
530 AD  oppbld                34     34
530 AD  opselm                35     35
530 AD  opsplt                36     36
530 AD  opbmrg                37     37
530 AD  opnwpl                38     38
530 AD  opford                39     40  0 inz(0)
530 AD  opptyp                41     41
530 AD  opftot                42     43  0 inz(0)
530 AD  optecb                44     48  2 inz(0)
530 AD  opticb                49     53  2 inz(0)
530 AD  optstp                54     55  0 inz(0)
530 AD  optord                56     57  0 inz(0)
530 AD  optpcs                58     60  0 inz(0)
530 AD  opstop                61     61
530 A** Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
530 AD**opgcde                62     62
530 AD  oppkup                62     62
530 AD  opspal                63     63
530 AD  oppitm                64     67  0 inz(0)
530 AD  opend1               117    117
     D*----------------------------------------------------------------
     D*  Partial key redefinition
     D*
     D $PRTKY          ds
     D  $len50                 1     50
     D  $kwhse                 1      3  0
     D  $kcode                 4      5
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
     *
     D hcount          s              5  0
     D dcount          s              5  0
     D zhcount         s              5  0
     D zdcount         s              5  0
     D num3            s              3  0
     D whse            s              3  0
     D svtruk          s             10
     D newtemplate     s             10
     D trkdev          s             10
     D zondev          s             10
     D $rtncd          s              8
     D ozcod           s              8
     D alpha3          s              3
     D $whse           s              3
     D continue        s              1
     D match           s              1
     D alpha1          s              1
     *----------------------------------------------------------------
     *  Parameters
     *
     C     *entry        plist
     C                   parm                    $whse
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   exsr      zzinz

     C     tkey          setll     truckh2
     C                   dou       %eof(truckh2)
     C     tkey          reade     truckh2
     C                   if        not %eof(truckh2)
      * Truck Defn only
     C                   if        THZTMP = *Blanks
     C                   exsr      zzsearch
     C                   endif

     C                   endif
     C                   enddo

     C                   eval      *inlr = *on
     C*----------------------------------------------------------------
     C*
     C*  zzsearch  Search for template match
     C*
     C     zzsearch      begsr

     C                   eval      continue = 'N'

     C     *loval        setll     templateh
     C                   dou       %eof(templateh)
     C                   read      templateh
     C                   if        not %eof(templateh)

     C                   exsr      zzchzn
      * check zoned
     C                   if        continue = 'Y'
     C                   exsr      zzchzd
     C                   endif
      * check optionz
     C                   if        continue = 'Y'
     C                   exsr      zzchoz
     C                   endif
      * Template match
     C                   if        continue = 'Y' and zhcount = tmhcnt
     C                                            and zdcount = tmdcnt
     C                   Leave
     C                   endif

     C                   endif
     C                   enddo

xxx D ***                if        continue = 'Y'
xxx MC                   if        continue = 'Y' and zhcount = tmhcnt
xxx MC                                            and zdcount = tmdcnt
      * match, post template code to truck record
     C                   eval      thztmp = tmztmp
      ***                eval      thbulk = *blanks
     C                   eval      thbat  = *blanks
     C                   update    record2
     C                   eval      svtruk = thtruk
     C                   exsr      zzdltzon
     C                   else
      * no match, create new template code and post to truck record
      *                                    and post to optionz record
     C                   eval      svtruk = thtruk
     C                   exsr      zzcrttmp
     C                   eval      thztmp = newtemplate
     C                   update    record2
     C                   eval      thtruk = newtemplate
     C                   eval      thtype = 'Z'
     C                   eval      thztmp = *blanks
     C                   write     record
     C                   exsr      zzdltzon
     C                   exsr      zzcrtopz
     C                   endif

     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  zzchzn   Check for template definition
     C*
     C     zzchzn        begsr

      * Search all templates

     C                   eval      zhcount  = *zeros

     C     zhkey         setll     zoneh
     C                   dou       %eof(zoneh)
     C     zhkey         reade     zoneh
     C                   if        not %eof(zoneh)

     C     zhkey2        chain     zonehwk
     C                   if        %found(zonehwk)
     C                   eval      continue = 'Y'
     C                   eval      zhcount  = zhcount + 1
     C                   else
     C                   eval      continue = 'N'
     C                   leave
     C                   endif

     C                   endif
     C                   enddo

     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  zzchzd   Check for template definition
     C*
     C     zzchzd        begsr

     C                   eval      zdcount  = *zeros

     C     zhkey         setll     zoned1
     C                   dou       %eof(zoned1)
     C     zhkey         reade     zoned1
     C                   if        not %eof(zoned1)

     C     zdkey2        chain     zonedwk
     C                   if        %found(zonedwk)
     C                   eval      continue = 'Y'
     C                   eval      zdcount  = zdcount + 1
     C                   else
     C                   eval      continue = 'N'
     C                   leave
     C                   endif

     C                   endif
     C                   enddo

     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  zzchoz   Check for optionz record match
     C*
     C     zzchoz        begsr

     C                   eval      ozcod = '*PICK'
     C     ozkey         setll     optionz
     C                   dou       %eof(optionz)
     C     ozkey         reade     optionz
     C                   if        not %eof(optionz)

     C     ozkey2        chain     optionz3
     C                   if        %found(optionz3)
     C                   eval      continue = 'Y'
     C                   else
     C                   eval      continue = 'N'
     C                   leave
     C                   endif

     C                   endif
     C                   enddo

     C                   if        continue = 'Y'
     C                   eval      ozcod = '*PICKLBL'
     C     ozkey         setll     optionz
     C                   dou       %eof(optionz)
     C     ozkey         reade     optionz
     C                   if        not %eof(optionz)

     C                   eval      trkdev = *blanks
     C                   eval      zondev = *blanks
     C                   eval      continue = 'N'
     C     ozkey2        chain     optionz3
     C                   if        %found(optionz3)
     C                   eval      trkdev = %subst(zopzdta:65:10)
     C     ozkey4        chain     optionz4
     C                   if        %found(optionz4)
     C                   eval      zondev = %subst(xopzdta:65:10)
     C                   if        trkdev = zondev
     C                   eval      continue = 'Y'
     C                   else
     C                   eval      continue = 'N'
     C                   leave
     C                   endif

     C                   endif
     C                   endif

     C                   endif
     C                   enddo
     C                   endif

     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  zzcrttmp Check for template definition
     C*
     C     zzcrttmp      begsr

      * get next template number

     C     tkey          chain     nexttmpl
     C                   if        %Found(nexttmpl)
     C                   eval      newtemplate = tnztmp
     C                   eval      alpha3 = %subst(tnztmp:6:3)
     C                   move      alpha3        num3
     C                   eval      num3 = num3 + 1
     C                   move      num3          alpha3
     C                   eval      tnztmp = %replace(alpha3:tnztmp:6:3)
     C                   update    tnrec
     C                   endif

     C                   eval      zhcount  = *zeros
     C                   eval      zdcount  = *zeros

     C     zhkey         setll     zoneh
     C                   dou       %eof(zoneh)
     C     zhkey         reade     zoneh
     C                   if        not %eof(zoneh)

     C                   eval      zhtruk = newtemplate
     C                   write     zhrec
     C                   exsr      zzouthwk
     C                   eval      zhcount  = zhcount + 1

     C                   endif
     C                   enddo

     C     zhkey         setll     zoned1
     C                   dou       %eof(zoned1)
     C     zhkey         reade     zoned1
     C                   if        not %eof(zoned1)

     C                   eval      zdtruk = newtemplate
     C                   write     zdrec
     C                   exsr      zzoutdwk
     C                   eval      zdcount  = zdcount + 1

     C                   endif
     C                   enddo

      * Template workfile (templateh)

     C                   eval      tmwhse = thwhse
     C                   eval      tmztmp = newtemplate
     C                   eval      tmhcnt = zhcount
     C                   eval      tmdcnt = zdcount
     C                   write     tmrec

     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  zzcrtopz Create optionz records for new template
     C*
     C     zzcrtopz      begsr

     C                   eval      ozcod = '*PICK'
     C     ozkey3        setll     optionz
     C                   dou       %eof(optionz)
     C     ozkey3        reade     optionz
     C                   if        not %eof(optionz)

     C                   eval      zopzcod = opzcod
     C                   eval      zopzwhs = opzwhs
     C                   eval      zopztrk = newtemplate
     C                   eval      zopzzon = opzzon
     C                   eval      opdta1  = opzdta
530 AC                   eval      opptyp  = 'P'
530 AC                   eval      opford  = 0
530 AC                   eval      opstop  = 'N'
     C                   eval      zopzdta = opdta1
     C                   write     zrec

     C                   endif
     C                   enddo

     C                   eval      ozcod = '*PICKLBL'
     C     ozkey3        setll     optionz
     C                   dou       %eof(optionz)
     C     ozkey3        reade     optionz
     C                   if        not %eof(optionz)

     C                   eval      zopzcod = opzcod
     C                   eval      zopzwhs = opzwhs
     C                   eval      zopztrk = newtemplate
     C                   eval      zopzzon = opzzon
     C                   eval      opdta2  = opzdta
530 AC                   eval      opaisl = 'N'
530 AC                   eval      optaxr = 'N'
530 AC                   eval      opchkr = 'N'
     C                   eval      zopzdta = opdta2
     C                   write     zrec
     C                   eval      zopzcod = '*PICKLBA'
     C                   eval      zopzwhs = opzwhs
     C                   eval      zopztrk = newtemplate
     C                   eval      zopzzon = opzzon
     C                   eval      oplb1 = 'Y'
     C                   eval      opcu1 = 'N'
     C                   eval      oplp1 = oplpgm
     C                   eval      opdv1 = oppdev
     C                   eval      opfm1 = oppfrm
     C                   eval      oplb2 = 'N'
     C                   eval      opcu2 = 'N'
     C                   eval      oplp2 = *blanks
     C                   eval      opdv2 = *blanks
     C                   eval      opfm2 = *blanks
     C                   eval      oplb3 = 'N'
     C                   eval      opcu3 = 'N'
     C                   eval      oplp3 = *blanks
     C                   eval      opdv3 = *blanks
     C                   eval      opfm3 = *blanks
     C                   eval      zopzdta = opdta3
     C                   write     zrec
     C                   eval      zopzcod = '*PICKLBB'
     C                   eval      zopzwhs = opzwhs
     C                   eval      zopztrk = newtemplate
     C                   eval      zopzzon = opzzon
     C                   eval      oplb4 = 'N'
     C                   eval      opcu4 = 'N'
     C                   eval      oplp4 = *blanks
     C                   eval      opdv4 = *blanks
     C                   eval      opfm4 = *blanks
     C                   eval      oplb5 = 'N'
     C                   eval      opcu5 = 'N'
     C                   eval      oplp5 = *blanks
     C                   eval      opdv5 = *blanks
     C                   eval      opfm5 = *blanks
     C                   eval      oplb6 = 'N'
     C                   eval      opcu6 = 'N'
     C                   eval      oplp6 = *blanks
     C                   eval      opdv6 = *blanks
     C                   eval      opfm6 = *blanks
     C                   eval      oplb7 = '2'
     C                   eval      zopzdta = opdta4
     C                   write     zrec

     C                   endif
     C                   enddo

     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  zzdltzon  delete truck zone records
     C*
     C     zzdltzon      begsr

     C     zhkey3        setll     zoneh
     C                   dou       %eof(zoneh)
     C     zhkey3        reade     zoneh
     C                   if        not %eof(zoneh)
     C                   delete    zhrec
     C                   endif
     C                   enddo

     C     zhkey3        setll     zoned1
     C                   dou       %eof(zoned1)
     C     zhkey3        reade     zoned1
     C                   if        not %eof(zoned1)
     C                   delete    zdrec
     C                   endif
     C                   enddo

     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  zzouthwk    outq (zonehwk) record
     C*
     C     zzouthwk      begsr

     C                   eval      xzhchck = *blanks
     C                   eval      xzhwhse = zhwhse
     C                   eval      xzhtruk = zhtruk
     C                   eval      xzhzone = zhzone
     C                   eval      xzhdesc = zhdesc
     C                   eval      xzhcomp = zhcomp
     C                   eval      xzhpzon = zhpzon
     C                   eval      xzhgen  = zhgen
     C                   eval      xzhdrop = zhdrop
     C                   write     zhrecw
     C*
     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  zzoutdwk    outq (zonedwk) record
     C*
     C     zzoutdwk      begsr

     C                   eval      yzdchck = *blanks
     C                   eval      yzdwhse = zdwhse
     C                   eval      yzdtruk = zdtruk
     C                   eval      yzdzone = zdzone
     C                   eval      yzdwhdp = zdwhdp
     C                   eval      yzdstyp = zdstyp
     C                   eval      yzdaisl = zdaisl
     C                   eval      yzdrlvl = zdrlvl
     C                   eval      yzdloc2 = zdloc2
     C                   eval      yzdloc1 = zdloc1
     C                   write     zdrecw

     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  zzinz2   Extra program initialization. Called from main line.
     C*
     C     zzinz2        begsr

     C                   move      $whse         whse

      * Set Truck Type

     C     tkey          setll     truckh
     C                   dou       %eof(truckh)
     C     tkey          reade     truckh
     C                   if        not %eof(truckh)
     C                   eval      alpha1 = %subst(thtruk:1:1)

     C                   select
     C                   when      alpha1 <> '*'
     C                   eval      thtype = 'T'
     C                   update    record
     C                   when      alpha1 =  '*'
     C                   eval      thtype = 'Z'
     C                   update    record
     C                   endsl

     C                   endif
     C                   enddo

      * Load all templates

     C     tkey          setll     truckh1
     C                   dou       %eof(truckh1)
     C     tkey          reade     truckh1
     C                   if        not %eof(truckh1)

      * Zone Header Template (zonehwk)

     C                   eval      hcount = *zeros
     C     zhkey         setll     zoneh
     C                   dou       %eof(zoneh)
     C     zhkey         reade     zoneh
     C                   if        not %eof(zoneh)
     C                   exsr      zzouthwk
     C                   eval      hcount = hcount + 1
     C                   endif
     C                   enddo

      * Zone Detail Template (zonedwk)

     C                   eval      dcount = *zeros
     C     zhkey         setll     zoned1
     C                   dou       %eof(zoned1)
     C     zhkey         reade     zoned1
     C                   if        not %eof(zoned1)
     C                   exsr      zzoutdwk
     C                   eval      dcount = dcount + 1
     C                   endif
     C                   enddo

      * Template workfile

     C                   eval      tmwhse = thwhse
     C                   eval      tmztmp = thtruk
     C                   eval      tmhcnt = hcount
     C                   eval      tmdcnt = dcount
     C                   write     tmrec

     C                   endif
     C                   enddo

     C                   endsr
     C*----------------------------------------------------------------
     C*
     C*  zzinz    Extra program initialization. Called from *INZSR.
     C*
     C     zzinz         begsr
     C*
     C     tkey          klist
     C                   kfld                    whse
     C*
     C     zhkey         klist
     C                   kfld                    thwhse
     C                   kfld                    thtruk
     C*
     C     zhkey2        klist
     C                   kfld                    tmwhse
     C                   kfld                    tmztmp
     C                   kfld                    zhzone
     C                   kfld                    zhdesc
     C                   kfld                    zhcomp
     C                   kfld                    zhpzon
     C                   kfld                    zhgen
     C                   kfld                    zhdrop
     C*
     C     zhkey3        klist
     C                   kfld                    thwhse
     C                   kfld                    svtruk
     C*
     C     zdkey2        klist
     C                   kfld                    tmwhse
     C                   kfld                    tmztmp
     C                   kfld                    zdzone
     C                   kfld                    zdwhdp
     C                   kfld                    zdstyp
     C                   kfld                    zdaisl
     C                   kfld                    zdrlvl
     C                   kfld                    zdloc1
     C                   kfld                    zdloc2
     C*
     C     ozkey         klist
     C                   kfld                    ozcod
     C                   kfld                    thwhse
     C                   kfld                    thtruk
     C*
     C     ozkey2        klist
     C                   kfld                    ozcod
     C                   kfld                    thwhse
     C                   kfld                    thtruk
     C                   kfld                    opzzon
     C*
     C     ozkey3        klist
     C                   kfld                    ozcod
     C                   kfld                    thwhse
     C                   kfld                    svtruk
     C*
     C     ozkey4        klist
     C                   kfld                    ozcod
     C                   kfld                    thwhse
     C                   kfld                    tmztmp
     C                   kfld                    opzzon

     C                   exsr      zzinz2

     C                   endsr
