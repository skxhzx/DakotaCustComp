      /copy qcopysrc,hspecs
     h dftactgrp(*NO) actgrp(*CALLER)
750 A*----------------------------------------------------------------
750 A*  Binding Directories
750 A*----------------------------------------------------------------

750 AHbnddir('BFCBND') BNDDIR('BFCIFSBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  IT982SSBM  Staging Inventory Comparison Submit NetSuite
     *  13 September 2021
     *  Kenneth Elder
     *
     *----------------------------------------------------------------
     *
750  *    09/13/21  KDE  7.50
     *      - Created
     *
     *----------------------------------------------------------------
     *  Files
750 AFoptions   if   e           k disk
     *----------------------------------------------------------------
     *  Customer ids
EOPaA /copy qcopysrc,id#eop
     *----------------------------------------------------------------
     *  Program info data structure
      /copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy qcopysrc,c#stdvar
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
      /copy qcopysrc,c#stdsql
     *----------------------------------------------------------------
     *  Called Program Prototypes
      /copy qcopysrc,p.qcmdexc

750 A* Prototype for NetSuite API Call
750 A /copy qcopysrc,p.intapins
750 A /copy qcopysrc,p.getopint

     *----------------------------------------------------------------
     *  Working Variables
750 Ad hostopts        s             20a
750 Ad hostoptint      s             20a
750 Ad hostoptlot      s             20a
750 Ad NetSuite        c                   const('NETSUITE')
     D whs#            s              3  0
     D work3a          s              3
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $whse   Warehouse
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $whse             3
     *
     * Main line
     *
      /free

        exsr zzinz2;
        *inlr=*on;
        return;

      /end-free
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
750 Ac                   parm                    clienthost       10
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *  Define partial key for OPTIONS file.
     *
     C     keyop         klist
     C                   kfld                    whs#
     C                   kfld                    opcode
750 A*
750 A*  Get option interface settings
750 A*
750 Ac                   eval      opwhse = 1
750 Ac                   eval      opcode = '*HOST   '
750 Ac     keyop         chain     options
750 Ac                   if        not %found(options)
750 Ac                   eval      hostopts = '*NONE'
750 Ac                   else
750 Ac                   movel     opdata        hostopts
750 Ac                   endif
750 A *  Get Host ERP from OPTIONINT
750 A /free
750 A   // Get debug flag
750 A   optint.type = 'Interface   ';
750 A   optint.cat  = 'General Options     ';
750 A   optint.name = 'Host ERP System     ';
750 A   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
750 A             optint.valn: optint.vala: optint.return);
750 A   if optint.return = '*OK';
750 A     hostoptint = optint.vala;
750 A   else;
750 A     hostoptint = '*NONE';
750 A   endif;
750 A   if (hostopts = NetSuite
750 A    or hostoptint = NetSuite
750 A    or clienthost = NetSuite);
750 A
750 A     ApiNS.Whse = %editc(whs#:'X');
750 A     ApiNS.Batch = *blanks;
750 A     ApiNS.Type = 'IMPICOMP';
750 A     IntApiNS(ApiNS.Whse: ApiNS.Batch: ApiNS.Type:
750 A              ApiNS.Ret: ApiNS.Msg);
750 A     if ApiNS.Ret <> '*OK';
750 A     endif;
750 A   endif;
750 AC                   endsr

