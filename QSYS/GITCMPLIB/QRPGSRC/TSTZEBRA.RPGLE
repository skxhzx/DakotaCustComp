     H OPTION(*NODEBUGIO)
     *----------------------------------------------------------------
     *
     *  TSTZEBRA     Test printing to Zebra printer from IMPLFMT file
     *  30 June 2005
     *  Dave Sommerville
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fimplfmt   if   e           k disk
     Fpfmtpr    o    f  198        printer oflind(*IN90)
     F                                     usropn

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a12             s              1    dim(12)
     D a40             s              1    dim(40)
     D a50             s              1    dim(50)
     D a58             s              1    dim(58)
     D a80             s              1    dim(80)
     D sti             s              1    dim(75)
     D sto             s              1    dim(198)
     D ovrprt          s             80    DIM(1) CTDATA PERRCD(1)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D maxsti          s              2  0 inz(75)
     D maxsto          s              3  0 inz(198)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *
     *      $pdev - Printer device
     *
     *    Returned Parameters
     *
     *      none
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pdev            10

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     * Open printer file

     C                   exsr      opnprt

     * Print label

     C                   exsr      printlbl

     * Close printer

     C                   close     pfmtpr

     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  OPNPRT   Open printer file.
     *----------------------------------------------------------------

     C     opnprt        begsr

     C                   movea     ovrprt(1)     a80
     C                   movea     $pdev         a80(37)
     C                   movea     '*STD'        a80(58)
     C                   movea     a80           qcmd
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5

     C                   open      pfmtpr

     C                   endsr

     *----------------------------------------------------------------
     *  printstr   Output string to printer.
     *----------------------------------------------------------------

     C     printstr      begsr

     C                   movea     sto           @outpt          198
     C                   if        @outpt <> ' '
     C                   except    #str
     C                   endif
     C                   eval      sto = *blanks
     C                   z-add     0             op

     C                   endsr

     *----------------------------------------------------------------
     *  printlbl  Print label from implfmt file.
     *----------------------------------------------------------------

     C     printlbl      begsr

     C                   eval      sto = *blanks
     C                   z-add     0             op                3 0

     * Loop through file

     C                   dow       1 = 1
     C                   read      implfmt
     C                   if        %eof
     C                   leave
     C                   endif

     C                   if        ilstr = *blanks
     C                   iter
     C                   endif

     C                   movea     ilstr         sti
     C                   z-add     0             ip                3 0

     *   Move record information into output string

     C     1             do        maxsti        ip                3 0

     C                   add       1             op
     C                   move      sti(ip)       sto(op)
     C     op            ifeq      maxsto
     C                   exsr      printstr
     C                   endif

     C                   enddo

     C                   exsr      printstr

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *   Output Specs
     *----------------------------------------------------------------

     Opfmtpr    e            #str           1
     O                       @outpt             198

     *----------------------------------------------------------------
     *   Compile time tables
     *----------------------------------------------------------------

**   OVRPRTF statment
OVRPRTF FILE(PFMTPR) OUTQ(*DEV) DEV(          ) FORMTYPE(          )
