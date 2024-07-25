      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     * Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  ASPENINTR  Aspen - Populate OPTIONINT with default values
     *  19 September 2018
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
720  *    09/19/18  RTR  7.20
     *      - Created from OP971 for Aspen specific values.
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
     D main            pr                  extpgm('ASPENOPTR')
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
            Exec Sql delete from OPTIONINT
                      where opitype = 'Interface   '
                        and opicat  = 'Aspen Canopy        ';
          endif;

          // General Options - Host ERP System
          holdtype = 'Interface   ';
          holdcat  = 'General Options     ';
          holdname = 'Host ERP System     ';
          holdcmod = 'N';
          holdvalt = 'A';
          holdvaln = 0;
          holdvala = 'Aspen Canopy                                   ';
          holddesc = 'Host ERP System that is interfaced with.       ';
          exsr InsertRec;

          // Interface|Aspen Canopy|FTP Port
          holdtype = 'Interface   ';
          holdcat  = 'Aspen Canopy        ';
          holdname = 'FTP Port            ';
          holdcmod = 'N';
          holdvalt = 'N';
          holdvaln = 21;
          holdvala = '                                               ';
          holddesc = 'Port number for connection to FTP server. '
                   + 'Default should be 21.';
          exsr InsertRec;

          // Interface|Aspen Canopy|Add Whse to
          holdtype = 'Interface   ';
          holdcat  = 'Aspen Canopy        ';
          holdname = 'Add Whse to Item Num';
          holdcmod = 'N';
          holdvalt = 'A';
          holdvaln = 0;
          holdvala = 'N                                              ';
          holddesc = 'Add Canopy warehouse to item number for multi '
                   + 'whse Canopy.';
          exsr InsertRec;

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
