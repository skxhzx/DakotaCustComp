      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *             CRTSQLRPGI PGM(XXX/SQL003RG) SRCFILE(XXX/QRPGLESRC)
     *
     *
     * COMPILING. In order to compile this program you will need
     *            to use options which allow it to work correctly
     *            between machines. These options are---
     *
     *               COMMIT = *NONE
     *               RDB    = Machine name that you will connect to.
     *               DLYPRP = *YES
     *               SQLPKG = The name & library that you want to
     *                        use for the package. This will put the
     *                        package on the RDB machine that you
     *                        specify.
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *   Copyright (C) 2021 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  UPDSUM014   Identify items that need upc setup by uom
     *  12 July 2021
     *  Lynn McMahon
     *
750  *    07/12/21  LMC  7.50
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     Fpiritem1  if   e           k disk
     Fitemlnk1  if   e           k disk
     Fpiritem   if   e           k disk    prefix(ssb_) rename(itrec:itrec1)
     Fsum014    uf a e           k disk


     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D slrec         e ds                  extname(slot) inz(*EXTDFT)
     D uprec         e ds                  extname(upc) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pErrMsg        s             99
     d  pSessId        s             40
     d  pWhse          s              3p 0
     d  pWhdp          s              5

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d AddRecs         pr
     d DeleteRecs      pr

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  File info data structures
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------


      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *
      *    Returned Parameters
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Let the show begin .....
      *----------------------------------------------------------------
     c     *entry        plist
     c                   parm                    pErrMsg
     c                   parm                    pSessId
     c                   parm                    pWhse
     c                   parm                    pWhdp

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------


      /free
        *inlr = *on;
        pErrMsg = ' ';


        // Delete existing records for session id

        DeleteRecs();
        AddRecs();


        *inlr = *On;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------



     *----------------------------------------------------------------
     *  AddRecs   Add records
     *----------------------------------------------------------------

     p AddRecs         b
     d AddRecs         pi

     *  Local Variables

     D*wkITem          s             15

      /free
        // process all but the SSB items
        dow forever = forever;
          read piritem1 ;
          if %eof(piritem1);
            leave;
          endif;
          if ittype = 'S';
            iter;
          endif;
          // is this item active - do I have it in a slot?
          exec sql select * into :slrec
               from slot
               where slitem = :ititem
                  and slpick = 'Y'
                 fetch first row only;

          if sqlstt = sqlSuccess;
730aA       smmn = ' ';
730aA       smm1 = ' ';
730aA       smm2 = ' ';
            // found a slot
            // do I have the upc's loaded for normal uom
            exec sql select * into :uprec
                 from upc
                 where upitem = :ititem
                    and upuom  = :itum1
                   fetch first row only;
            if sqlstt <> sqlSuccess;
              // Need to write to work file
              smWHDP  = ITWHDP;
              smTYPE  = ITTYPE;
              smITEM  = ITITEM;
              smDESC  = ITDESC;
              smUM1   = ITUM1;
              smUM2   = ITUM2;
              smFLG1  = ITFLG1;
              smUM3   = ITUM3;
              smFLG2  = ITFLG2;
              smDISP  = SLDISP;
730aA         smmn    = 'Y';
              smsessid = psessid;
              write smrec;
            endif;
            // do I have the upc's loaded for brk1 uom
            if itflg1 = 'Y';
              exec sql select * into :uprec
                   from upc
                   where upitem = :ititem
                      and upuom  = :itum2
                     fetch first row only;
              if sqlstt <> sqlSuccess;
                // Need to write to work file if the item isn't already there
730aA           // we will now update if record exist to identify which
730aA           // UOM is missing
                chain (psessid:ititem) SUM014;
                if not %found(SUM014);
                  SMWHDP  = ITWHDP;
                  SMTYPE  = ITTYPE;
                  SMITEM  = ITITEM;
                  SMDESC  = ITDESC;
                  SMUM1   = ITUM1;
                  SMUM2   = ITUM2;
                  SMFLG1  = ITFLG1;
                  SMUM3   = ITUM3;
                  SMFLG2  = ITFLG2;
                  SMDISP  = SLDISP;
740aA             SMm1 = 'Y';
                  smsessid = psessid;
                  write smrec;
730aA           else;
730aA             smm1 = 'Y';
730aA             update smrec;
                endif;
              endif;
            endif;
            // do I have the upc's loaded for brk2 uom
            if itflg2 = 'Y';
              exec sql select * into :uprec
                   from upc
                   where upitem = :ititem
                      and upuom  = :itum3
                     fetch first row only;
              if sqlstt <> sqlSuccess;
                // Need to write to work file if the item isn't already there
                chain (psessid: ititem) sum014;
                if not %found(sum014);
                  smWHDP  = ITWHDP;
                  smTYPE  = ITTYPE;
                  smITEM  = ITITEM;
                  smDESC  = ITDESC;
                  smUM1   = ITUM1;
                  smUM2   = ITUM2;
                  smFLG1  = ITFLG1;
                  smUM3   = ITUM3;
                  smFLG2  = ITFLG2;
                  smDISP  = SLDISP;
740aA             smm2 = 'Y';
                  smsessid = psessid;
                  write smrec;
730aA           else;
730aA             smm2 = 'Y';
730aA             update smrec;
                endif;
              endif;
            endif;
            //  Now do I have a linked ssb item
            //  need to read each one and check if item is ssb
            setll (itwhse: ititem) itemlnk1;
            dow forever = forever;
              reade (itwhse: ititem) itemlnk1;
              if %eof(itemlnk1);
                leave;
              endif;
              // found one is it an ssb Item?
730aA       smmn = ' ';
730aA       smm1 = ' ';
730aA       smm2 = ' ';
              chain (itwhse: ilitem) piritem;
              if %found(piritem);
                if ssb_ittype = 'S';
                  // do we have a upc loaded?
                  exec sql select * into :uprec
                       from upc
                       where upitem = :ssb_ititem
                          and upuom  = :ssb_itum1
                         fetch first row only;
                  if sqlstt <> sqlSuccess;
                    // Need to write to work file
                    smWHDP  = ssb_ITWHDP;
                    smTYPE  = ssb_ITTYPE;
                    smITEM  = ssb_ititem;
                    smDESC  = ssb_ITDESC;
                    smUM1   = ssb_ITUM1;
                    smUM2   = ssb_ITUM2;
                    smFLG1  = ssb_ITFLG1;
                    smUM3   = ssb_ITUM3;
                    smFLG2  = ssb_ITFLG2;
                    smDISP  = SLDISP;
730aA               smm1    = 'Y';
                    smsessid = psessid;
                    write smrec;
                  endif;
                endif;
              endif;
            enddo;
          endif;
        enddo;
      /end-free


     p AddRecs         e
     *----------------------------------------------------------------
     *  DeleteRecs    Delete records for session id
     *----------------------------------------------------------------

     p DeleteRecs      b
     d DeleteRecs      pi

      /free

        exec sql delete from sum014
                 where smsessid = :pSessId;

      /end-free

     p DeleteRecs      e
