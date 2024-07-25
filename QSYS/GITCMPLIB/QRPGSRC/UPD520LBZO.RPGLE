     Hcopyright('(c) Copyright BFC Software, Inc - 2004')
     Hoptimize(*NONE)
     Hdecedit(*JOBRUN)
     Htruncnbr(*NO)
     Hoption(*srcstmt : *nodebugio)

     *----------------------------------------------------------------
     *
     *  UPD520LBZ  Q&D to create *PICKLBA, *PICKLBB and set defaults
     *             in *PICKLBL for OPAISL, OPTAXR, & OPCHKR
     *  03 November 2009
     *  Ginger Andrews
     *
     *  Revisions
     *    11/03/09   GJA   5.30
     *       -Created
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     Foptionz   up a e           k disk

      *  OPTIONZ data structure
     *----------------------------------------------------------------
     *  *PICKLBL  -  Picking label options
     *
     *----------------------------------------------------------------
     * Fields
     *    OPLPGM  -  Picking label program.
     *    OPPDEV  -  Printer device.
     *    OPPFRM  -  Printer form.
     *    OPAISL  -  Print aisle change label.
     *    OPTAXR  -  Include in tax right.
     *    OPCHKR  -  Include in check right.
     *
     * Data structure
     *
     D opdta2          ds
     D  opclvl                 1      3  0 inz(0)
     D  opcwra                 4      4
     D  opcwrb                 5      5
     D  opuwra                 6      6
     D  opuwrb                 7      7
     D  optext                 8     50
     D  operr                 51     52  0 inz(0)
     D  opcwgt                53     54  0 inz(0)
     D  oplpgm                55     64
     D  oppdev                65     74
     D  oppfrm                75     84
     D  opaisl                85     85
     D  optaxr                86     86
     D  opchkr                87     87
     D  opend2               117    117
     *----------------------------------------------------------------
     *  *PICKLBA   - Label printing options for standard pick,
     *               retail, and tote labels.
     *----------------------------------------------------------------
     * Fields
     *
     *    OPLB1   -  Print standard pick label Y/N.   - Standard pick label
     *    OPCU1   -  Use cutter option Y/N.           - Standard pick label
     *    OPLP1   -  Label printing program.          - Standard pick label
     *    OPDV1   -  Printer device.                  - Standard pick label
     *    OPFM1   -  Form.                            - Standard pick label
     *
     *    OPLB2   -  Print retail label Y/N.          - Retail label
     *    OPCU2   -  Use cutter option Y/N.           - Retail label
     *    OPLP2   -  Label printing program.          - Retail label
     *    OPDV2   -  Printer device.                  - Retail label
     *    OPFM2   -  Form.                            - Retail label
     *
     *    OPLB3   -  Print tote label Y/N.            - Tote label
     *    OPCU3   -  Use cutter option Y/N.           - Tote label
     *    OPLP3   -  Label printing program.          - Tote label
     *    OPDV3   -  Printer device.                  - Tote label
     *    OPFM3   -  Form.                            - Tote label
     *
     * Data structure
     *
     D opdta3          ds
     D  oplb1                  1      1
     D  opcu1                  2      2
     D  oplp1                  3     12
     D  opdv1                 13     22
     D  opfm1                 23     32
     D  oplb2                 33     33
     D  opcu2                 34     34
     D  oplp2                 35     44
     D  opdv2                 45     54
     D  opfm2                 55     64
     D  oplb3                 65     65
     D  opcu3                 66     66
     D  oplp3                 67     76
     D  opdv3                 77     86
     D  opfm3                 87     96
     D  opend3               117    117
     *----------------------------------------------------------------
     *  *PICKLBB -  Label printing options for the pick list and
     *               ASN labels and pick list report.
     *
     *     08/12/09  RBD  5.20  P#00219
     *       - Added record type *PICKLBB which holds printing info
     *         for the pick list and ASN labels and pick list report.
     *
     *----------------------------------------------------------------
     * Fields
     *
     *    OPLB4   -  Print pick list label Y/N.       - Pick list label
     *    OPCU4   -  Use cutter option Y/N.           - Pick list label
     *    OPLP4   -  Label printing program.          - Pick list label
     *    OPDV4   -  Printer device.                  - Pick list label
     *    OPFM4   -  Form.                            - Pick list label
     *
     *    OPLB5   -  Print ASN label Y/N.             - ASN label
     *    OPCU5   -  Use cutter option Y/N.           - ASN label
     *    OPLP5   -  Label printing program.          - ASN label
     *    OPDV5   -  Printer device.                  - ASN label
     *    OPFM5   -  Form.                            - ASN label
     *
     *    OPLB6   -  Print pick list report Y/N.      - Pick list report
     *    OPCU6   -  Use cutter option Y/N.           - Pick list report
     *    OPLP6   -  Label printing program.          - Pick list report
     *    OPDV6   -  Printer device.                  - Pick list report
     *    OPFM6   -  Form.                            - Pick list report
     *
     * Data structure
     *
     D opdta4          ds
     D  oplb4                  1      1
     D  opcu4                  2      2
     D  oplp4                  3     12
     D  opdv4                 13     22
     D  opfm4                 23     32
     D  oplb5                 33     33
     D  opcu5                 34     34
     D  oplp5                 35     44
     D  opdv5                 45     54
     D  opfm5                 55     64
     D  oplb6                 65     65
     D  opcu6                 66     66
     D  oplp6                 67     76
     D  opdv6                 77     86
     D  opfm6                 87     96
     D  opend4               117    117

      *----------------------------------------------------------------
      *  Main Line
      *----------------------------------------------------------------

     * Only grab *PICKLBL records
     C                   if        opzcod = '*PICKLBL'
     C                   eval      opdta2 = opzdta
     * Print Aisle Change Label
     C                   if        opaisl = ' '
     C                   eval      opaisl = 'Y'
     C                   endif
     * Include in Tax Right
     C                   if        optaxr = ' '
     C                   eval      optaxr = 'N'
     C                   endif
     * Include in Check Right
     C                   if        opchkr = ' '
     C                   eval      opchkr = 'N'
     C                   endif
     C                   eval      opzdta = opdta2
     C                   update    opzrec
     * Create *PICKLBA record
     C                   eval      opdta3 = *blanks
     C                   eval      opzcod = '*PICKLBA'
     * If label program exist in *PICKLBL
     C                   if        oplpgm <> *blanks
     C                   eval      oplb1  = 'Y'
     C                   eval      opcu1  = 'N'
     C                   eval      oplp1  = oplpgm
     C                   eval      opdv1  = oppdev
     C                   eval      opfm1  = oppfrm
     C                   else
     C                   eval      oplb1  = 'N'
     C                   eval      opcu1  = 'N'
     C                   eval      oplp1  = ' '
     C                   eval      opdv1  = ' '
     C                   eval      opfm1  = ' '
     C                   endif
     * Set defaults for retail label
     C                   eval      oplb2  = 'N'
     C                   eval      opcu2  = 'N'
     C                   eval      oplp2  = ' '
     C                   eval      opdv2  = ' '
     C                   eval      opfm2  = ' '
     * Set defaults for tote label
     C                   eval      oplb3  = 'N'
     C                   eval      opcu3  = 'N'
     C                   eval      oplp3  = ' '
     C                   eval      opdv3  = ' '
     C                   eval      opfm3  = ' '
     C                   eval      opzdta = opdta3
     C                   write     opzrec
     * Create *PICKLBB record
     C                   eval      opdta4 = *blanks
     C                   eval      opzcod = '*PICKLBB'
     * Set default for pick list label
     C                   eval      oplb4  = 'N'
     C                   eval      opcu4  = 'N'
     C                   eval      oplp4  = ' '
     C                   eval      opdv4  = ' '
     C                   eval      opfm4  = ' '
     * Set default for ASN label
     C                   eval      oplb5  = 'N'
     C                   eval      opcu5  = 'N'
     C                   eval      oplp5  = ' '
     C                   eval      opdv5  = ' '
     C                   eval      opfm5  = ' '
     * Set default for Pick list report
     C                   eval      oplb6  = 'N'
     C                   eval      opcu6  = 'N'
     C                   eval      oplp6  = ' '
     C                   eval      opdv6  = ' '
     C                   eval      opfm6  = ' '
     C                   eval      opcu6 = 'N'
     C                   eval      oplp6 = ' '
     C                   eval      opdv6 = ' '
     C                   eval      opfm6 = ' '
     C                   eval      opzdta = opdta4
     C                   write     opzrec
     C                   endif
     CLR                 return
