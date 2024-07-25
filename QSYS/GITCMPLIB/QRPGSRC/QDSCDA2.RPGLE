     *----------------------------------------------------------------
     *
     *  QDSCD2    CREATE SLOTDGT WHEN GOING FROM 1 to 3
     *  08 November 2013
     *  Ginger Andrews
     *
     *
     *  Revisions
     *
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  78        Chain indicator
     *  79        Chain indicator
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fslotdgt   if   e           k disk
     Fslotdgta  uf a e           k disk
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
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  erwhse                 1      2p 0
     D  erwhdp                 3      7
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
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
     D curdte          s              8  0
     D curtim          s              6  0
     D forevr          s              1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      none
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *  Main line
     *
     *
     *
     *  Read item by item and recalculate cube.
     *
     C     *loval        setll     slotdgt
     C                   dou       forevr <> forevr
     *
     C                   read      slotdgt                                79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *  ADD/UPDATE SLOT DIGIT REC
     *
     C     keyscd        chain     slotdgta                           79
     C                   if        %found(slotdgta)
     C                   if        scddgt2 = 0  and scddgt3 = 0
     C                   eval      scddgt2 = scddgt
     C                   eval      scddgt3 = scddgt
     C                   update    scdreca
     C                   endif
     C                   else
     C                   eval      SCDWHSA = SCDWHS
     C                   eval      SCDWHDA = SCDWHD
     C                   eval      SCDDSPA = SCDDSP
     C                   eval      scddgt2 = scddgt
     C                   eval      scddgt3 = scddgt
     C                   eval      scdaby2 = 'BFC'
     C                   write     scdreca
     C                   endif
     *
     C                   enddo
     *
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      forevr = *on
     *
     *  Define keys.
     *
     *    SLOTDGT file KEY
     *
     C     keyscd        klist
     C                   kfld                    scdwhs
     C                   kfld                    scdwhd
     C                   kfld                    scddsp
     *
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdte = $cvd8o
     C                   time                    curtim
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
