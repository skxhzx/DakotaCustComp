      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     * Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  OP971    Populate OPTIONINT with default values
     *  20 October 2017
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Notes:
     *  - Use parm pType = ' ', will add any missing records and leave
     *    any existing records alone.
     *  - If parm pType = '*RESET', will clear all existing values and
     *    set all values to defaults. ONLY USE *RESET FOR STARTUP or
     *    the file is completely corrupted! This will wipe out client
     *    options!
     *  - Any other value for pType will be treated as blank, add new
     *    records to OPTIONINT and leave any existing records alone.
     *----------------------------------------------------------------
     *  Revisions:
     *
710  *    10/20/17  RTR  7.10
     *      - Created.
710a *    11/01/17  RTR  7.10a
     *      - Added HQ245 Host Picked Qty options.
720a *    02/26/18  RTR  7.20a
     *      - Added Interface|Export POs|Allow Partial Export.
720b *    06/15/18  RTR  7.20b
     *      - Added Interface|Export Item Quantity|Send Base if Virtual.
720c *    07/10/18  RTR  7.20c
     *      - Added Interface|Import POs|Import All option.
     *      - Added Interface|Import Items|Import All option.
720d *    08/13/18  RTR  7.20d
     *      - Added Interface|Export Adjustments|Use FTP Num Ext.
     *      - Added Interface|Export POs|Use FTP Num Ext.
730a *    01/19/19  RTR  7.30a
     *      - Added Interface|Export ItemQty|Overflow if no Pick.
     *      - Added Interface|Export ItemQty|Send Base if Virtual.
     *      - Added Interface|Export ItemQty|Only Pick Changes.
730b *    01/29/19  RTR  7.30b
     *      - Added Interface|Export ItemQty|Export Licenses.
730c *    02/05/19  RTR  7.30c
     *      - Added Interface|Export POs|Print Receiving Rept.
     *
     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy qcopysrc,c#pgminfds
      /copy qcopysrc,c#stdvar
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Variables
     *
     d holdtype        s             12a   inz(' ')
     d holdcat         s             20a   inz(' ')
     d holdname        s             20a   inz(' ')
     d holdcmod        s              1a   inz(' ')
     d holdvalt        s              1a   inz(' ')
     d holdvaln        s              8s 0 inz(0)
     d holdvala        s            100a   inz(' ')
     d holddesc        s            200a   inz(' ')

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pType       Update Type
     *
     *
     *----------------------------------------------------------------
     D main            pr                  extpgm('OP971')
      * Input
     D   pType                        6    const

     D main            pi
      * Input
     D   pType                        6    const

     *----------------------------------------------------------------
     * Main line
     *
      /free

          // Check for *RESET passed, if so then clear everything
          if pType = '*RESET';
            Exec Sql delete from OPTIONINT where OPITYPE <> ' ';
          endif;

          // General Options - Host ERP System
          holdtype = 'Interface   ';
          holdcat  = 'General Options     ';
          holdname = 'Host ERP System     ';
          holdcmod = 'N';
          holdvalt = 'A';
          holdvaln = 0;
          holdvala = 'Not Defined                                    ';
          holddesc = 'Host ERP System that is interfaced with.       ';
          exsr InsertRec;

          // Export Orders - POD Export
          holdtype = 'Interface   ';
          holdcat  = 'Export Orders       ';
          holdname = 'Export POD Record   ';
          holdcmod = 'Y';
          holdvalt = 'A';
          holdvaln = 0;
          holdvala = 'N                                              ';
          holddesc = 'Should POD records be exported? Y/N            ';
          exsr InsertRec;

720dA     // Interface|Export Adjustments|Use FTP Num Ext
720dA     holdtype = 'Interface   ';
720dA     holdcat  = 'Export Adjustments  ';
720dA     holdname = 'Use FTP Num Ext     ';
720dA     holdcmod = 'Y';
720dA     holdvalt = 'A';
720dA     holdvaln = 0;
720dA     holdvala = 'Y                                              ';
720dA     holddesc = 'Use numeric FTP file name extension? (Y/N)     ';
720dA     exsr InsertRec;

          // Export Adjustments - Debug Flag
          holdtype = 'Interface   ';
          holdcat  = 'Export Adjustments  ';
          holdname = 'Debug Flag          ';
          holdcmod = 'Y';
          holdvalt = 'A';
          holdvaln = 0;
          holdvala = 'Y                                              ';
          holddesc = 'Debug Export Adjustments? Y/N                  ';
          exsr InsertRec;

730aA     // Interface|Export ItemQty|Overflow if no Pick
730aA     holdtype = 'Interface   ';
730aA     holdcat  = 'Export ItemQty      ';
730aA     holdname = 'Overflow if no Pick ';
730aA     holdcmod = 'Y';
730aA     holdvalt = 'A';
730aA     holdvaln = 0;
730aA     holdvala = 'N                                              ';
730aA     holddesc = 'If no pick slot, send overflow instead. (Y/N)  ';
730aA     exsr InsertRec;

730aA     // Interface|Export ItemQty|Send Base if Virtual
730aA     holdtype = 'Interface   ';
730aA     holdcat  = 'Export ItemQty      ';
730aA     holdname = 'Send Base if Virtual';
730aA     holdcmod = 'Y';
730aA     holdvalt = 'A';
730aA     holdvaln = 0;
730aA     holdvala = 'N                                              ';
730aA     holddesc = 'If virtual slot, send base slot instead. (Y/N) ';
730aA     exsr InsertRec;

730aA     // Interface|Export ItemQty|Only Pick Changes
730aA     holdtype = 'Interface   ';
730aA     holdcat  = 'Export ItemQty      ';
730aA     holdname = 'Only Pick Changes   ';
730aA     holdcmod = 'Y';
730aA     holdvalt = 'A';
730aA     holdvaln = 0;
730aA     holdvala = 'N                                              ';
730aA     holddesc = 'Only export Pick Slot changes. Y/N             ';
730aA     exsr InsertRec;

730bA     // Interface|Export ItemQty|Export Licenses
730bA     holdtype = 'Interface   ';
730bA     holdcat  = 'Export ItemQty      ';
730bA     holdname = 'Export Licenses     ';
730bA     holdcmod = 'Y';
730bA     holdvalt = 'A';
730bA     holdvaln = 0;
730bA     holdvala = 'N                                              ';
730bA     holddesc = 'Export Licenses in EXPFLCNS/EXPSLCNS. Y/N      ';
730bA     exsr InsertRec;

720dA     // Interface|Export POs|Use FTP Num Ext
720dA     holdtype = 'Interface   ';
720dA     holdcat  = 'Export POs          ';
720dA     holdname = 'Use FTP Num Ext     ';
720dA     holdcmod = 'Y';
720dA     holdvalt = 'A';
720dA     holdvaln = 0;
720dA     holdvala = 'Y                                              ';
720dA     holddesc = 'Use numeric FTP file name extension? (Y/N)     ';
720dA     exsr InsertRec;

730cA     // Interface|Export POs|Print Receiving Rept
730cA     holdtype = 'Interface   ';
730cA     holdcat  = 'Export POs          ';
730cA     holdname = 'Print Receiving Rept';
730cA     holdcmod = 'Y';
730cA     holdvalt = 'A';
730cA     holdvaln = 0;
730cA     holdvala = 'N                                              ';
730cA     holddesc = 'Print Receiving Report when exporting? (Y/N)   ';
730cA     exsr InsertRec;

          // Export POs - Debug Flag
          holdtype = 'Interface   ';
          holdcat  = 'Export POs          ';
          holdname = 'Debug Flag          ';
          holdcmod = 'Y';
          holdvalt = 'A';
          holdvaln = 0;
          holdvala = 'Y                                              ';
          holddesc = 'Debug Export POs? Y/N                          ';
          exsr InsertRec;

          // Export Orders - Debug Flag
          holdtype = 'Interface   ';
          holdcat  = 'Export Orders       ';
          holdname = 'Debug Flag          ';
          holdcmod = 'Y';
          holdvalt = 'A';
          holdvaln = 0;
          holdvala = 'Y                                              ';
          holddesc = 'Debug Export Orders? Y/N                       ';
          exsr InsertRec;

          // Export Returns - Debug Flag
          holdtype = 'Interface   ';
          holdcat  = 'Export Returns      ';
          holdname = 'Debug Flag          ';
          holdcmod = 'Y';
          holdvalt = 'A';
          holdvaln = 0;
          holdvala = 'Y                                              ';
          holddesc = 'Debug Export Returns? Y/N                      ';
          exsr InsertRec;

          // Export Returns RH765 - IFS Path
          holdtype = 'Interface   ';
          holdcat  = 'Export Returns      ';
          holdname = 'RH765 CSV IFS Path  ';
          holdcmod = 'Y';
          holdvalt = 'A';
          holdvaln = 0;
          holdvala = '/                                              ';
          holddesc = 'IFS Path for CSV export file. Example: /Test/  ';
          exsr InsertRec;

710aA     // Import Host Picked Qtys - Debug Flag
710aA     holdtype = 'Interface   ';
710aA     holdcat  = 'Import Picked Qty   ';
710aA     holdname = 'Debug Flag          ';
710aA     holdcmod = 'Y';
710aA     holdvalt = 'A';
710aA     holdvaln = 0;
710aA     holdvala = 'Y                                              ';
710aA     holddesc = 'Debug Import Picked Qty? Y/N                   ';
710aA     exsr InsertRec;

710aA     // Import Host Picked Qtys HQ245S - Create XDK when no slot
710aA     holdtype = 'Interface   ';
710aA     holdcat  = 'Import Picked Qty   ';
710aA     holdname = 'HQ245S No Slot XDK  ';
710aA     holdcmod = 'Y';
710aA     holdvalt = 'A';
710aA     holdvaln = 0;
710aA     holdvala = 'N                                              ';
710aA     holddesc = 'Create XDK slot when no other slot found. Y/N  ';
710aA     exsr InsertRec;

720aA     // Allow Partial PO Export
720aA     holdtype = 'Interface   ';
720aA     holdcat  = 'Export POs          ';
720aA     holdname = 'Allow Partial Export';
720aA     holdcmod = 'Y';
720aA     holdvalt = 'A';
720aA     holdvaln = 0;
720aA     holdvala = 'N                                              ';
720aA     holddesc = 'Allow Partial PO Export. Y/N                   ';
720aA     exsr InsertRec;

720bA     // Export Item Qty - Send Base Pick Slot instead of Virtual
720bA     holdtype = 'Interface   ';
720bA     holdcat  = 'Export Item Quantity';
720bA     holdname = 'Send Base if Virtual';
720bA     holdcmod = 'Y';
720bA     holdvalt = 'A';
720bA     holdvaln = 0;
720bA     holdvala = 'N                                              ';
720bA     holddesc = 'Export base pick slot instead of virtual? Y/N  ';
720bA     exsr InsertRec;

720cA     // Import All Items
720cA     holdtype = 'Interface   ';
720cA     holdcat  = 'Import Items        ';
720cA     holdname = 'Import All          ';
720cA     holdcmod = 'Y';
720cA     holdvalt = 'A';
720cA     holdvaln = 0;
720cA     holdvala = 'N                                              ';
720cA     holddesc = 'Specify if import all (Y) or only changes (N). ';
720cA     exsr InsertRec;

720cA     // Import All POs
720cA     holdtype = 'Interface   ';
720cA     holdcat  = 'Import POs          ';
720cA     holdname = 'Import All          ';
720cA     holdcmod = 'Y';
720cA     holdvalt = 'A';
720cA     holdvaln = 0;
720cA     holdvala = 'N                                              ';
720cA     holddesc = 'Specify if import all (Y) or only changes (N). ';
720cA     exsr InsertRec;

        *inlr = *on;
      /end-free

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
      /free
        begsr *inzsr;
        endsr;  // *inzsr
      /end-free

     *----------------------------------------------------------------
     *
     *  INSERTREC     Write record to OPTIONINT
     *
      /free
        begsr InsertRec;
          Exec Sql Insert into OptionInt
                           (OPITYPE, OPICAT, OPINAME, OPICMOD,
                            OPIVALT, OPIVALN, OPIVALA, OPIDESC)
                     values(:holdtype, :holdcat, :holdname, :holdcmod,
                            :holdvalt, :holdvaln, :holdvala, :holddesc);

        endsr;  // InsertRec
      /end-free
